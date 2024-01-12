""" Model for product """
import os
from typing import Any, Dict

from firebase_admin import firestore

COMPANIES_COLLECTION = os.environ["COMPANIES_COLLECTION"]

class Product():
    """
    Store and manage the product data

    Args:
        company_id (str): Company ID
        product_id (str): Product ID
    
    Attrs:
        company_id (str): Company ID
        stock (int): Product stock

    Methods:
        update_fields: Update the product data
        recover_stock: Recover product stock
    """

    product_id: str
    stock: int

    def __init__(self, company_id: str, product_id: str) -> None:
        self._company_id = company_id
        self.product_id = product_id
        self._product_document = firestore.client().document(
            f'{COMPANIES_COLLECTION}/{self._company_id}/Products/{self.product_id}'
        )
        self._product_data = self._product_document.get().to_dict()
        self.stock = self._product_data.get('stock')

    def update_fields(self, data: Dict[str, Any]) -> None:
        """ Update the product data

        Args:
            data (Dict[str, Any]): Data to update
        """
        self._product_document.set(data, merge=True)

    def recover_stock(self, quantity: int) -> None:
        """ Recover product stock """
        self.stock += quantity
        self.update_fields({'stock': self.stock})
