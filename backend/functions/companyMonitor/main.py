""" Functions to handle webhooks from Stripe after checkout session """
from jinja2 import Environment, FileSystemLoader

from models.company_data import CompanyData
from utils import set_up, sender_server, send_email

def handle_update(event, context):                                          #pylint: disable=W0613
    """ Reacts to a companyPreferences update of any company """
    set_up()
    company_id = event.get('value').get('name').split('/')[-1]

    ## Getting old important values
    old_stripe_enabled = event.get('oldValue').get('fields').get('stripeEnabled')
    if old_stripe_enabled is not None:
        old_stripe_enabled = old_stripe_enabled.get('booleanValue')

    old_media = event.get('oldValue').get('fields').get('media')
    if old_media is not None:
        old_media = old_media.get('stringValue')

    old_n_products = event.get('oldValue').get('fields').get('nProducts')
    if old_n_products is not None:

        old_n_products = int(old_n_products.get('integerValue'))


    old_data_completed = event.get('oldValue').get('fields').get('dataCompleted')
    if old_data_completed is not None:
        old_data_completed = old_data_completed.get('booleanValue')

    company = CompanyData(company_id)

    env = Environment(loader=FileSystemLoader('templates'))



    server = sender_server()



    ## This are mails to the clients.

    if old_data_completed is False and company.data_completed is True:
        company_content = env.get_template('almost_registered.html').render(
            company_name=company.name,
            company_link=company.panel_link
        )

        send_email(
            server=server,
            text=company_content,
            subject="Casi has completado tu registro en FlameoArt!",
            send_to_email=[company.email]
        )

        flameo_content = env.get_template('company_state.html').render(
        stripe_enabled=company.stripe_enabled,
        n_products=company.n_products,
        media=company.media,
        panel_link=company.panel_link
    )
        send_email(
        server=server,
        text=flameo_content,
        subject=f"La empresa {company.name} ha completado la primera parte del registro",
        send_to_email=["flameoapp@gmail.com"])

    if (old_stripe_enabled is None or not old_stripe_enabled) and company.stripe_enabled:
        company_content = env.get_template('totally_registered.html').render(
            company_name=company.name,
            company_link=company.panel_link
        )

        send_email(
            server=server,
            text=company_content,
            subject="Enhorabuena! has completado tu registro en FlameoArt!",
            send_to_email=[company.email]
        )

        flameo_content = env.get_template('company_state.html').render(
        stripe_enabled=company.stripe_enabled,
        n_products=company.n_products,
        media=company.media,
        panel_link=company.panel_link)

        send_email(
        server=server,
        text=flameo_content,
        subject=f"La empresa {company.name} ha COMPLETADO el registro",
        send_to_email=["flameoapp@gmail.com"])


    ## These are mails to us

    if company.is_deleted:
        send_email(
        server=server,
        text="flameo_conten",
        subject=f" {company.name} ha ELIMINADO su panel con link {company.panel_link}",
        send_to_email=["flameoapp@gmail.com"])

    if old_n_products is not None:
        if old_n_products < company.n_products:
            flameo_content = env.get_template('company_state.html').render(
            stripe_enabled=company.stripe_enabled,
            n_products=company.n_products,
            media=company.media,
            panel_link=company.panel_link)

            send_email(
            server=server,
            text=flameo_content,
            subject=f"La empresa {company.name} ha AÑADIDO un producto",
            send_to_email=["flameoapp@gmail.com"])
