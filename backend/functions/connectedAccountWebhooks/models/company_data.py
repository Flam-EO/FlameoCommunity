""" Model for company data """
import os
from typing import Any, Dict

from firebase_admin import firestore

COMPANIES_COLLECTION = os.environ["COMPANIES_COLLECTION"]

class CompanyData():
    """
    Store and manage the company data

    Args:
        company_id (str): Company ID
    
    Attrs:
        company_id (str): Company ID

    Methods:
        update_fields: Update the company data
        enable_stripe: Enable stripe on the company
        disable_stripe: Disable stripe on the company
    """

    company_id: str

    def __init__(self, company_id: str) -> None:
        self.company_id = company_id
        self._company_document = firestore.client().document(
            f'{COMPANIES_COLLECTION}/{self.company_id}'
        )

    def update_fields(self, data: Dict[str, Any]) -> None:
        """ Update the company data

        Args:
            data (Dict[str, Any]): Data to update
        """
        self._company_document.set(data, merge=True)

    def enable_stripe(self) -> None:
        """ Enable stripe on the company """
        self.update_fields({'stripeEnabled': True})

    def disable_stripe(self) -> None:
        """ Disable stripe on the company """
        self.update_fields({'stripeEnabled': False})
