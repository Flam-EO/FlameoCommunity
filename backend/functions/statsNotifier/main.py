""" Stats of the current day visits """

import datetime
import json
from firebase_admin import firestore
from jinja2 import Environment, FileSystemLoader
from werkzeug import Response
from utils import send_email, sender_server, set_up

def stats_notifier(context) -> None:                                #pylint: disable=W0613, R0914
    """ 
    Send an email with the visit stats today

    Args:
        event (dict): Event payload.
        context (Context): Metadata for the event.
    """
    set_up()
    store = firestore.client()

    logs = store.collection('logs')
    companies = store.collection('companies')
    today = datetime.date.today().strftime('%Y%m%d')

    unique_visitors = list(logs.document(today).collection('visitors').list_documents())
    n_unique_visitors = len(unique_visitors)

    def _has_action(visitor, action):
        return bool(list(visitor.collection('actions').where('action', '==', action).stream()))
    def _visitors_with_action(action):
        return [v for v in unique_visitors if _has_action(v, action)]

    visitors_landing_page = _visitors_with_action('landingPage')
    n_visitors_landing_page = len(visitors_landing_page)
    visitors_acess = _visitors_with_action('access')
    n_visitors_acess = len(visitors_acess)
    visitors_access_after_landing = [v for v in visitors_acess if _has_action(v, 'landingPage')]
    n_visitors_access_after_landing = len(visitors_access_after_landing)
    visitors_open_signin = _visitors_with_action('openSignIn')
    n_visitors_open_signin = len(visitors_open_signin)
    visitors_open_contact = _visitors_with_action('openContact')
    n_visitors_open_contact = len(visitors_open_contact)
    visitors_continue_to_stripe = _visitors_with_action('completeStripeNow')
    n_visitors_continue_to_stripe = len(visitors_continue_to_stripe)

    routes_access = {}
    for visitor in unique_visitors:
        visitor_routes = []
        for action in visitor.collection('actions').where('action', '==', 'access').stream():
            if action.get('metadata'):
                visitor_routes.append(action.get('metadata').get('page'))
        for route in set(visitor_routes):
            if route not in routes_access:
                routes_access[route] = 0
            routes_access[route] += 1

    #TODO esta funcion en general es optimizable, sobre todo cuando haya mucha actividad
    query = companies.where("stripeEnabled", "==", True)
    docs = query.stream()

    def _has_visit(visitor, company_id):
        return bool(list(visitor.collection('actions').where(
            'metadata',
            '==',
            {'companyID': company_id}
        ).stream()))
    def _visitors_to_company(company_id) -> int:
        return len([v for v in unique_visitors if _has_visit(v, company_id)])

    companies_visitors = {}
    for doc in docs:
        data = doc.to_dict()
        name = data.get('companyName')
        panel_link = data.get('panelLink')
        visitors = _visitors_to_company(doc.id)
        companies_visitors[f'{name} /{panel_link}'] = visitors

    env = Environment(loader=FileSystemLoader('templates'))

    content = env.get_template('message.j2').render(
        n_unique_visitors=n_unique_visitors,
        n_visitors_landing_page=n_visitors_landing_page,
        n_visitors_access_after_landing=n_visitors_access_after_landing,
        n_visitors_open_signin=n_visitors_open_signin,
        n_visitors_open_contact=n_visitors_open_contact,
        n_visitors_acess=n_visitors_acess,
        n_visitors_continue_to_stripe=n_visitors_continue_to_stripe,
        routes_access=json.dumps(routes_access, indent=4).replace('\n', '<br>'),
        companies_visitors=json.dumps(companies_visitors, indent=4).replace('\n', '<br>')
    )

    smtp_server = sender_server()
    send_email(
        smtp_server,
        content,
        f'Estadísticas de hoy - {today}',
        ['flameoapp@gmail.com']
    )
    smtp_server.close()

    return Response(status=200)
