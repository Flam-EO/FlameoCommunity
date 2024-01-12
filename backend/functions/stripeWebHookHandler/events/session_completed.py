""" Handle and completed event from checkout session """
import os

from jinja2 import Environment, FileSystemLoader
from werkzeug.wrappers import Response

from utils import get_firebase_storage_download_link, round_number, send_email, sender_server

from models.company_data import CompanyData
from models.transaction import ShippingMethod
from models.webhook_event import WebhookEvent

SUBDOMAIN = os.environ["SUBDOMAIN"]

def notify(webhook_event: WebhookEvent, company_data: CompanyData) -> None:
    """
    Notify the customer, company and flameo team about a success transaction

    Args:
        webhook_event (WebhookEvent): Webhook event object
        company_data (CompanyData): Company data
    """
    env = Environment(loader=FileSystemLoader('templates'))
    env.globals.update(get_firebase_storage_download_link=get_firebase_storage_download_link)

    cart_items = webhook_event.transaction.cart_items

    if webhook_event.transaction.shipping_method == ShippingMethod.SELLER_SHIPPING:
        address = webhook_event.transaction.client_contact.address
    else:
        address = company_data.address

    user_content = env.get_template('user_message.j2').render(
        client_name=webhook_event.transaction.client_contact.name,
        company_name=company_data.name,
        cart_items=cart_items,
        subdomain=SUBDOMAIN,
        panel_link=company_data.panel_link,
        company_id=company_data.company_id,
        total_price=round_number(sum(cart_item.total_price for cart_item in cart_items)),
        transaction_id=webhook_event.transaction.transaction_id,
        timestamp=webhook_event.transaction.timestamp,
        address=address,
        pick_up=webhook_event.transaction.shipping_method in [ShippingMethod.PICK_UP],
        shipping_cost=round_number(webhook_event.transaction.shipping_cost_cents / 100)
    )

    company_content = env.get_template('company_message.j2').render(
        cart_items=cart_items,
        subdomain=SUBDOMAIN,
        panel_link=company_data.panel_link,
        company_id=company_data.company_id,
        total_price=round_number(sum(cart_item.total_price for cart_item in cart_items)),
        timestamp=webhook_event.transaction.timestamp,
        address=address,
        pick_up=webhook_event.transaction.shipping_method in [ShippingMethod.PICK_UP]
    )

    flameo_content = env.get_template('flameo_message.j2').render(
        company_name=company_data.name,
        cart_items=cart_items,
        subdomain=SUBDOMAIN,
        panel_link=company_data.panel_link,
        company_id=company_data.company_id,
        total_price=round_number(sum(cart_item.total_price for cart_item in cart_items)),
        timestamp=webhook_event.transaction.timestamp,
        address=address,
        pick_up=webhook_event.transaction.shipping_method in [ShippingMethod.PICK_UP]
    )

    smtp_server = sender_server()
    send_email(
        smtp_server,
        user_content,
        f'Tu compra en {company_data.name}',
        [webhook_event.transaction.client_contact.email]
    )

    try:
        send_email(
            smtp_server,
            company_content,
            'Nueva compra en FlameoApp',
            [company_data.email]
        )
    except TypeError as error:
        print(f'Company no tiene email?: {error}')

    send_email(
        smtp_server,
        flameo_content,
        f'Nueva compra en {company_data.name}',
        ['flameoapp@gmail.com']
    )

    smtp_server.close()

def notify_corruption(webhook_event: WebhookEvent, company_data: CompanyData) -> None:
    """
    Notify to flameo email if a transaction is corrupted

    Args:
        webhook_event (WebhookEvent): Webhook event object
        company_data (CompanyData): Company data
    """
    env = Environment(loader=FileSystemLoader('templates'))
    env.globals.update(get_firebase_storage_download_link=get_firebase_storage_download_link)

    cart_items = webhook_event.transaction.cart_items

    if webhook_event.transaction.shipping_method == ShippingMethod.SELLER_SHIPPING:
        address = webhook_event.transaction.client_contact.address
    else:
        address = company_data.address

    flameo_content = env.get_template('transaction_corrupted.j2').render(
        transaction_total=webhook_event.transaction.transaction_total * 100,
        stripe_total=webhook_event.amount_total,
        company_name=company_data.name,
        cart_items=cart_items,
        subdomain=SUBDOMAIN,
        panel_link=company_data.panel_link,
        company_id=company_data.company_id,
        total_price=round_number(sum(cart_item.total_price for cart_item in cart_items)),
        timestamp=webhook_event.transaction.timestamp,
        address=address,
        pick_up=webhook_event.transaction.shipping_method in [ShippingMethod.PICK_UP]
    )

    smtp_server = sender_server()

    send_email(
        smtp_server,
        flameo_content,
        f'TRANSACCIÓN CORRUPTA EN {company_data.name}',
        ['flameoapp@gmail.com']
    )

    smtp_server.close()

def handle_event(webhook_event: WebhookEvent) -> Response:
    """
    Function to handle the completed stripe event

    Args:
        webhook_event (WebhookEvent): Webhook stripe event
        company_data (CompanyData): The company data

    Returns:
        Response: Result of the process
    """
    _ = webhook_event.release()
    company_data = CompanyData(webhook_event.company_id)
    if webhook_event.validate_transaction():
        print('Transaction validated')
        webhook_event.transaction.validate_payment()
        notify(webhook_event, company_data)
    else:
        notify_corruption(webhook_event, company_data)
        print('Transaction corrupted')

    return Response(response=f'Correctly processed the event {webhook_event.event_type}')
