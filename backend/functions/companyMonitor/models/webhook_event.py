""" Model for Webhook Events """
import os

from enum import Enum

import stripe

from firebase_admin import firestore
from werkzeug import Request

from models.transaction import Transaction

EVENTS_COLLECTION = os.environ["EVENTS_COLLECTION"]
WEBHOOK_KEY = os.environ['WEBHOOK_KEY']

class EventType(Enum):
    """ Enum to store the event types """
    SESSION_COMPLETED  = 'checkout.session.completed'
    SESSION_EXPIRED = 'checkout.session.expired'
    NOT_IMPLEMENTED = 'not_implemented'

    @classmethod
    def _missing_(cls, _):
        return cls.NOT_IMPLEMENTED

class WebhookEvent():
    """ 
    Object representing a checkout session event

    Args:
        event (Dict): Event data from firestore trigger

    Attrs:
        event (Dict): Event data from firestore trigger
        company_id (str): Company ID
        event_type (EventType): Stripe event type
        transaction (Transaction): Transaction object from webhook metadata

    Methods:
        upload_to_firestore: Upload the whole event to a firestore database in the events collection
        validate_transaction: Validate the transaction amount from the webhook
    """

    event: stripe.Event
    event_type: EventType
    company_id: str
    transaction: Transaction
    amount_total: float
    error: bool = False

    def __init__(self, request: Request) -> None:
        try:
            self.event = stripe.Webhook.construct_event(
                request.data,
                request.headers.get('Stripe-Signature'),
                WEBHOOK_KEY
            )
        except ValueError:
            self.error = True
        else:
            self.event_type = EventType(self.event.type)

    def release(self) -> bool:
        """
        Build the webhook event object

        Returns:
            bool: If the transaction exists in the database
        """
        self.company_id = self.event.data.object.metadata.get('companyID')
        self.transaction = Transaction(
            self.company_id,
            self.event.data.object.metadata.get('transactionID')
        )
        self.amount_total = self.event.data.object.amount_total
        return self.transaction.exists

    def upload_to_firestore(self):
        """ Upload the whole event to a firestore database in the events collection """
        firestore.client().document(f'{EVENTS_COLLECTION}/{self.event.id}').set(self.event)

    def validate_transaction(self) -> bool:
        """
        Validate the transaction amount with the webhook amount

        Returns:
            bool: If the transaction is valid (False if it is corrupted)
        """
        try:
            print(self.transaction.transaction_total * 100)
            print(self.amount_total)
            return abs((self.transaction.transaction_total * 100) - self.amount_total) < 1
        except Exception as error:                                          #pylint: disable=W0718
            print(error)
            return False
