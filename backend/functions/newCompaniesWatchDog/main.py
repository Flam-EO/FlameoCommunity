""" Companies creator watchdog """

from jinja2 import Environment, FileSystemLoader
from utils import send_email, sender_server, set_up

def company_creator(event, context) -> None:                               #pylint: disable=W0613
    """ 
    Send an email when a new company has been created.

    Args:
        event (dict): Event payload.
        context (Context): Metadata for the event.
    """
    set_up()

    env = Environment(loader=FileSystemLoader('templates'))

    name = event.get('value').get('fields').get('companyName').get('stringValue')

    content = env.get_template('message.j2').render(
        company_id=event.get('value').get('name').split('/')[-1],
        name=name,
        email=event.get('value').get('fields').get('email').get('stringValue')
    )

    smtp_server = sender_server()
    send_email(
        smtp_server,
        content,
        f'Nueva empresa registrada: {name}',
        ['flameoapp@gmail.com']
    )
    smtp_server.close()
