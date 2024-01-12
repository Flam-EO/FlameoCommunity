""" Manage the notification status change """
import os

from enum import Enum
from typing import Any, Tuple

from jinja2 import Environment, FileSystemLoader

from utils import (generate_qr, get_firebase_storage_download_link,
                   round_number, send_email, sender_server)

from models.notifications import Notification, TransactionStatusChangeNotification
from models.transaction import ShippingMethod, TransactionStatus

SUBDOMAIN = os.environ["SUBDOMAIN"]

class StatusChange(Enum):
    """ Types of status changes availables """
    PICK_UP_READY = (TransactionStatus.PENDING, TransactionStatus.PREPARED)
    ORDER_SENT = (TransactionStatus.PENDING, TransactionStatus.SENT)
    PREPARED_MISSCLIKED = (TransactionStatus.PREPARED, TransactionStatus.PENDING)
    SENT_MISSCLIKED = (TransactionStatus.SENT, TransactionStatus.PENDING)

    CANCELLED = (Any, TransactionStatus.CANCELLED)
    CANCELLED_MISSCLIKED = (TransactionStatus.CANCELLED, Any)
    NOT_IMPLEMENTED='not_implemented'

    @classmethod
    def _missing_(cls, value: Tuple[TransactionStatus, TransactionStatus]):
        if value[0] == TransactionStatus.CANCELLED:
            return cls.CANCELLED_MISSCLIKED
        if value[1] == TransactionStatus.CANCELLED:
            return cls.CANCELLED
        return cls.NOT_IMPLEMENTED

def handle_notification(notification: Notification) -> None:
    """
    Function to handle the status change notification

    Args:
        notification (Notification): The generic notification object
    """
    tscn = TransactionStatusChangeNotification(notification)

    status_change = StatusChange((tscn.old_status, tscn.new_status))

    env = Environment(loader=FileSystemLoader('templates'))
    env.globals.update(get_firebase_storage_download_link=get_firebase_storage_download_link)

    if tscn.transaction.shipping_method == ShippingMethod.SELLER_SHIPPING:
        address = tscn.transaction.client_contact.address
    else:
        address = tscn.company_data.address

    file_to_attach = None
    if status_change == StatusChange.PICK_UP_READY:
        qr_data = f'{tscn.company_data.company_id}/{tscn.transaction_id}'
        file_to_attach = generate_qr(qr_data)
        user_content = env.get_template('pick_up_ready.j2').render(
            client_name=tscn.transaction.client_contact.name,
            company_name=tscn.company_data.name,
            cart_items=tscn.transaction.cart_items,
            subdomain=SUBDOMAIN,
            panel_link=tscn.company_data.panel_link,
            company_id=tscn.company_data.company_id,
            total_price=round_number(
                sum(cart_item.total_price for cart_item in tscn.transaction.cart_items)
            ),
            address=address,
            pick_up=tscn.transaction.shipping_method in [ShippingMethod.PICK_UP],
            shipping_cost=round_number(tscn.transaction.shipping_cost_cents / 100),
        )
    elif status_change == StatusChange.ORDER_SENT:
        user_content = env.get_template('order_sent.j2').render(
            client_name=tscn.transaction.client_contact.name,
            company_name=tscn.company_data.name,
            cart_items=tscn.transaction.cart_items,
            subdomain=SUBDOMAIN,
            panel_link=tscn.company_data.panel_link,
            company_id=tscn.company_data.company_id,
             total_price=round_number(
                sum(cart_item.total_price for cart_item in tscn.transaction.cart_items)
            ),
            address=address,
            pick_up=tscn.transaction.shipping_method in [ShippingMethod.PICK_UP],
            shipping_cost=round_number(tscn.transaction.shipping_cost_cents / 100)
        )
    elif status_change == StatusChange.PREPARED_MISSCLIKED:
        user_content = env.get_template('prepared_missclicked.j2').render(
            client_name=tscn.transaction.client_contact.name,
            company_name=tscn.company_data.name
        )
    elif status_change == StatusChange.SENT_MISSCLIKED:
        user_content = env.get_template('sent_missclicked.j2').render(
            client_name=tscn.transaction.client_contact.name,
            company_name=tscn.company_data.name
        )
    elif status_change == StatusChange.CANCELLED:
        user_content = env.get_template('cancelled.j2').render(
            client_name=tscn.transaction.client_contact.name,
            company_name=tscn.company_data.name,
            cart_items=tscn.transaction.cart_items,
            subdomain=SUBDOMAIN,
            panel_link=tscn.company_data.panel_link,
            company_id=tscn.company_data.company_id,
             total_price=round_number(
                sum(cart_item.total_price for cart_item in tscn.transaction.cart_items)
            ),
            pick_up=tscn.transaction.shipping_method in [ShippingMethod.PICK_UP],
            shipping_cost=round_number(tscn.transaction.shipping_cost_cents / 100)
        )
    elif status_change == StatusChange.CANCELLED_MISSCLIKED:
        user_content = env.get_template('cancelled_missclicked.j2').render(
            client_name=tscn.transaction.client_contact.name,
            company_name=tscn.company_data.name
        )

    smtp_server = sender_server()
    send_email(
        smtp_server,
        user_content,
        f'Tu compra en {tscn.company_data.name}',
        [tscn.transaction.client_contact.email],
        file_to_attach
    )

    send_email(
        smtp_server,
        user_content,
        f'Status change en {tscn.company_data.name}',
        ['flameoapp@gmail.com'],
        file_to_attach
    )

    smtp_server.close()
