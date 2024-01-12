""" Model to store a transaction """
import os

from datetime import datetime
from enum import Enum
from typing import Any, Dict, List

from dateutil import tz
from firebase_admin import firestore

from models.client_contact import ClientContact
from models.product import Product

COMPANIES_COLLECTION = os.environ["COMPANIES_COLLECTION"]

class ShippingMethod(Enum):
    """ Methods of shipping """
    PICK_UP = 'pickUp'
    SELLER_SHIPPING = 'sellerShipping'
    FLAMEO_SHIPPING = 'flameoShipping'

class TransactionStatus(Enum):
    """ Transaction status """
    PENDING = 'pending'
    PREPARED = 'prepared'
    CANCELLED = 'cancelled'
    SENT = 'sent'
    PICKEDUP = 'pickedup'
    DELIVERED = 'delivered'

class CartItem():
    """
    Cart item model

    Args:
        cart_item_data (Dict[str, Any]): Cart item data
        company_id (str): Company id

    Attrs:
        product_id (str): Product id
        name (str): Product name
        quantity (int): Cart item products quantity
        product (Product): Product related to the cart item
        price (float): Cart item price
        total_price (float): Cart items total price (price * quantity)

    Methods:
        recover_stock: Recover the product related stock
    """
    product_id: str
    name: str
    quantity: int
    product: Product
    price: float
    total_price: float
    photos: List[str]

    def __init__(self, cart_item_data: Dict[str, Any], company_id: str) -> None:
        self.product_id = cart_item_data.get('productId')
        self.name = cart_item_data.get('name')
        self.quantity = cart_item_data.get('quantity')
        self.product = Product(company_id, self.product_id)
        self.price = cart_item_data.get('price')
        self.total_price = self.price * self.quantity
        self.photos = cart_item_data.get('photos')

    def recover_stock(self) -> None:
        """ Recover the product related stock """
        self.product.recover_stock(self.quantity)

class Transaction():
    """
    Transaction model.

    Args:
        company_id (str): Company ID
        transaction_id (str): Transaction ID
    
    Attrs:
        transaction_id (str): Transaction ID
        cart_items (List[CartItem]): Cart items related to the transaction
        transaction_total (float): Transaction total price amount
        client_contact (ClientContact): Client contact of the transaction customer
        timestamp (datetime): Transaction creation timestamp
        timestamp_str (str): Transaction creation timestamp string formatted
        exists (bool): Flag to indicate if the transaction exists
        shipping_method (ShippingMethod): Shipping method of the transaction
        shipping_cost_cents (int): Shipping cost in cent
        status (TransactionStatus): Transaction status
    """
    transaction_id: str
    cart_items: List[CartItem]
    transaction_total: float
    client_contact: ClientContact
    timestamp: datetime
    timestamp_str: str
    exists: bool = True
    shipping_method: ShippingMethod
    shipping_cost_cents: int
    status: TransactionStatus

    def __init__(self, company_id: str, transaction_id: str) -> None:
        self._company_id = company_id
        self.transaction_id = transaction_id
        self._transaction_document = firestore.client().document(
            f'{COMPANIES_COLLECTION}/{self._company_id}/transactions/{self.transaction_id}'
        )
        self._transaction_data = self._transaction_document.get().to_dict()
        if not self._transaction_data:
            self.exists = False
        else:
            self.client_contact = ClientContact(self._transaction_data.get('clientContact'))
            self.timestamp = self._transaction_data.get('timestamp').astimezone(
                tz.gettz('Europe/Madrid')
            )
            self.status = TransactionStatus(self._transaction_data.get('status'))
            self.shipping_cost_cents = self._transaction_data.get('shippingCostCents')
            self.timestamp_str = self.timestamp.strftime('%d/%m/%Y %H:%M')
            self.shipping_method = ShippingMethod(self._transaction_data.get('shippingMethod'))

            self.cart_items = list(map(
                lambda data: CartItem(data, self._company_id),
                self._transaction_data.get('cartItems')
            ))

            self.transaction_total = sum(map(
                lambda cart_item: cart_item.price * cart_item.quantity,
                self.cart_items
            )) + self.shipping_cost_cents / 100

    def update_fields(self, data: Dict[str, Any]) -> None:
        """ Update the transaction data

        Args:
            data (Dict[str, Any]): Data to update
        """
        self._transaction_document.set(data, merge=True)

    def validate_payment(self):
        """ Validates the transaction on firestore """
        self.update_fields({
            'paymentValidated': True
        })
