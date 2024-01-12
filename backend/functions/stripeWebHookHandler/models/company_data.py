""" Model for company data """
import os
from typing import Any, Dict, List

from firebase_admin import firestore

from models.transaction import CartItem

COMPANIES_COLLECTION = os.environ["COMPANIES_COLLECTION"]

class CompanyData():
    """
    Store and manage the company data

    Args:
        company_id (str): Company ID
    
    Attrs:
        company_id (str): Company ID
        name (str): Company name
        panel_link (str): Panel link reference
        email (str): Company email
        address (str): Company address

    Methods:
        update_fields: Update the company data
        recover_stock: Recover the stock of the products in the cart items given
    """

    company_id: str
    name: str
    panel_link: str
    email: str
    address: str

    def __init__(self, company_id: str) -> None:
        self.company_id = company_id
        self._company_document = firestore.client().document(f'{COMPANIES_COLLECTION}/{company_id}')
        self._company_data = self._company_document.get().to_dict()
        self.name = self._company_data.get('companyName')
        self.panel_link = self._company_data.get('panelLink')
        self.email = self._company_data.get('email')
        self.address = self._company_data.get('address')
        self.stripe_enabled = self._company_data.get('stripeEnabled')
        self.description = self._company_data.get('description')
        self.n_products = self._company_data.get('nProducts')
        self.media = self._company_data.get('media')

    def update_fields(self, data: Dict[str, Any]) -> None:
        """ Update the company data

        Args:
            data (Dict[str, Any]): Data to update
        """
        self._company_document.set(data, merge=True)

    def recover_stock(self, cart_items: List[CartItem]) -> None:
        """ Recover the stock of the products in the cart

        Args:
            cart_items (List[CartItem]): Cart items to recover stock
        """
        try:
            for cart_item in cart_items:
                print(f'Recovering {cart_item.quantity} of {cart_item.product_id}')
                cart_item.recover_stock()
        except Exception as error:                                          #pylint: disable=W0718
            print(error)
