""" Notifications models """
from enum import Enum
from typing import Dict

from models.company_data import CompanyData
from models.transaction import Transaction, TransactionStatus

class NotificationType(Enum):
    """ Enum with all notification available types """
    TRANSACTION_STATUS_CHANGE='transaction_status_change'
    NOT_IMPLEMENTED='not_implemented'

    @classmethod
    def _missing_(cls, _):
        return cls.NOT_IMPLEMENTED

class Notification():
    """
    Generic notification model

    Args:
        type (NotificationType): Notification type

    Attrs:
        type (NotificationType): Notification type
        company_id (str): Company id
    """

    type: NotificationType
    company_id: str

    def __init__(self, event: Dict[str, Dict[str, Dict[str, Dict[str, str]]]]) -> None:
        self._data = event.get('value').get('fields')
        self.company_id = event.get('value').get('name').split('/')[-3]
        self.type = NotificationType(self._data.get('type').get('stringValue'))

class TransactionStatusChangeNotification():
    """
    Notification model for transaction status change

    Args:
        notification (Notification): Generic notification object

    Attrs:
        transaction_id (str): Transaction id
        old_status (TransactionStatus): Old transaction status
        new_status (TransactionStatus): New transaction status
        company_data (CompanyData): Company data
        transaction (Transaction): Transaction
    """

    transaction_id: str
    old_status: TransactionStatus
    new_status: TransactionStatus

    def __init__(self, notification: Notification) -> None:
        self.transaction_id = notification._data.get('transactionID').get('stringValue')
        self.old_status = TransactionStatus(notification._data.get('oldStatus').get('stringValue'))
        self.new_status = TransactionStatus(notification._data.get('newStatus').get('stringValue'))

        self.company_data = CompanyData(notification.company_id)
        self.transaction = Transaction(notification.company_id, self.transaction_id)
