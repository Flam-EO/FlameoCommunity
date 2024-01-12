""" Function to create a connected account and update the firestore document """
import os

import stripe

from firebase_admin import firestore
from models import ConnectedAccountEvent

from utils import set_up

def hello_firestore(event, context):                                        #pylint: disable=W0613
    """
    Creates a connected account in strip and update the document in firestore.

    Args:
        event (dict): Event payload.
        context (Context): Metadata for the event.
    """
    set_up()
    firestore_db = firestore.client()
    companies_collection = os.environ['COMPANIES_COLLECTION']
    connected_account = ConnectedAccountEvent(event, firestore_db)

    output = stripe.AccountLink.create(
        account=connected_account.caid,
        refresh_url=connected_account.refresh_url,
        return_url=connected_account.return_url,
        type="account_onboarding"
    )

    firestore_db.collection(companies_collection).document(connected_account.company_id).set({
        'connectedAccountID': connected_account.caid,
        'url': output.get('url')
    }, merge=True)
