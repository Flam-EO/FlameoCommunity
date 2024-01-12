""" Functions to handle the companies notifications """

from notification_cases import transaction_status_change
from utils import set_up

from models.notifications import Notification, NotificationType

def handle_notification(event, context) -> None:                            #pylint: disable=W0613
    """ 
    Manage every notifications writen in companies/companyID/notifications

    Args:
        event (dict): Event payload.
        context (Context): Metadata for the event.
    """
    set_up()

    notification = Notification(event)

    print(notification.type)

    if notification.type == NotificationType.TRANSACTION_STATUS_CHANGE:
        return transaction_status_change.handle_notification(notification)

    if notification.type == NotificationType.NOT_IMPLEMENTED:
        print(f'The notification type {notification.type} has not yet been implemented')

    return None
