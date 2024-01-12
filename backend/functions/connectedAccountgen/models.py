""" Useful models """
import os

from typing import Dict

import stripe

class ConnectedAccountEvent():
    """ 
    Object representing a connected account event

    Args:
        event (Dict): Event data from firestore trigger

    Attrs:
        company_id (str): Company ID
        caid (str): Connected account ID
        refresh_url (str): Refresh URL
        return_url (str): URL to return afther connection is complete
    """

    company_id: str
    caid: str
    refresh_url: str
    return_url: str

    def __init__(self, event: Dict, firestore_db) -> None:
        self.company_id: str = event.get('value').get('fields').get('companyID').get('stringValue')
        self.caid: str = event.get('value').get('fields').get('connectedAccountID')\
            .get('stringValue')
        self.refresh_url: str = event.get('value').get('fields').get('refresh_url')\
            .get('stringValue')
        self.return_url: str = event.get('value').get('fields').get('return_url').get('stringValue')
        self.email: str = event.get('value').get('fields').get('email').get('stringValue')
        self.panel_link: str = event.get('value').get('fields').get('panelLink').get('stringValue')

        # Create connected account if it doesn't exist
        if not self.caid:
            self.caid = stripe.Account.create(
                type="custom",
                capabilities={'transfers': {'requested': True}},
                business_type="individual",
                business_profile={
                    "url": f"flameoapp.com/panel?name={self.panel_link}",
                },
                email=self.email,
                individual={
                    "email": self.email
                },
                metadata={
                    "companyID": self.company_id
                }
            ).get('id')

            connected_accounts_collection = os.environ['CONNECTED_ACCOUNTS_COLLECTION']
            firestore_db.collection(connected_accounts_collection).document(self.company_id).set({
                'connectedAccountID': self.caid
            }, merge=True)
