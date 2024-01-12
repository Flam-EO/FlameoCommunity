""" Handle and expired event from checkout session """

from werkzeug.wrappers import Response

from models.company_data import CompanyData
from models.webhook_event import WebhookEvent

def handle_event(webhook_event: WebhookEvent) -> Response:
    """
    Function to handle the expired stripe event

    Args:
        webhook_event (WebhookEvent): Webhook stripe event
        company_data (CompanyData): Company data instance

    Returns:
        Response: Result of the process
    """
    if webhook_event.release():
        company_data = CompanyData(webhook_event.company_id)
        company_data.recover_stock(webhook_event.transaction.cart_items)

    return Response(
        response=f'Correctly processed the event {webhook_event.event_type}',
        status=200
    )
