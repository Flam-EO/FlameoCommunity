""" Checkout session creator """
import os

import stripe

from firebase_admin import firestore

from utils import set_up

def checkout_creator(event, context) -> None:                               #pylint: disable=W0613
    """ 
    Creates a checkout session and updates the checkout document in Firestore.
    
    This function is triggered by a Cloud Function when a user clicks on
    the checkout button. It creates a checkout session and updates the
    checkout document in Firestore.

    The checkout document contains the information required to create a
    checkout session.

    After checkout session has been created, the checkout session document
    in firestore is updated with a key 'url' with the url to redirect the user
    to pay or 'error' with the error message.

    Args:
        event (dict): Event payload.
        context (Context): Metadata for the event.
    """
    set_up()
    firestore_db = firestore.client()

    stripe_customers_collection = os.environ['STRIPE_CUSTOMERS_COLLECTION']
    checkout_document_path = context.resource[context.resource.index(stripe_customers_collection):]

    checkout_data = firestore_db.document(checkout_document_path).get().to_dict()
    stripe_checkout = stripe.checkout.Session.create(**checkout_data)

    if stripe_checkout.get('error'):
        update_data = {'error': stripe_checkout.get('error')}
    else:
        update_data = {'url': stripe_checkout.get('url')}

    firestore_db.document(checkout_document_path).set(update_data, merge=True)
