"""  Model for Webhook Events """
import os

from enum import Enum

import stripe

from firebase_admin import firestore
from werkzeug import Request

EVENTS_COLLECTION = os.environ["EVENTS_COLLECTION"]
WEBHOOK_KEY = os.environ['WEBHOOK_KEY']

class EventType(Enum):
    """ Enum to store the event types """
    ACCOUNT_UPDATED  = 'account.updated'
    NOT_IMPLEMENTED = 'not_implemented'

    @classmethod
    def _missing_(cls, _):
        return cls.NOT_IMPLEMENTED

class WebhookEvent():
    """ 
    Object representing a connected account event

    Args:
        event (Dict): Event data from firestore trigger

    Attrs:
        event (Dict): Event data from firestore trigger
        company_id (str): Company ID
        event_type (EventType): Stripe event type
        charges_enabled (bool): If stripe account has charges enabled
        details_submitted (bool): If stripe user has submitted details
        allow_enable_stripe (bool): If user can enable stripe on firestore
        error (bool): If there was an error while constructing event on stripe
    
    Methods:
        upload_to_firestore: Upload the whole event to a firestore database in the events collection
    """

    event: stripe.Event
    error: bool = False
    event_type: EventType
    company_id: str
    charges_enabled: bool
    details_submitted: bool
    allow_enable_stripe: bool

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

    def release(self):
        """ Build the webhook event object """
        self.company_id = self.event.data.object.metadata.get('companyID')
        self.charges_enabled = self.event.data.object.charges_enabled
        self.details_submitted = self.event.data.object.details_submitted
        self.allow_enable_stripe = self.charges_enabled and self.details_submitted

    def upload_to_firestore(self):
        """ Upload the whole event to a firestore database in the events collection """
        events_collection = EVENTS_COLLECTION
        firestore.client().document(f'{events_collection}/{self.event.id}').set(self.event)
