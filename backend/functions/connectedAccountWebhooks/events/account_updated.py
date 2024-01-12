""" Handle and expired event from checkout session """
from werkzeug.wrappers import Response

from models.company_data import CompanyData
from models.webhook_event import WebhookEvent

def handle_event(webhook_event: WebhookEvent) -> Response:
    """
    Function to handle the account updated stripe event

    Args:
        webhook_event (WebhookEvent): Webhook stripe event
        company_data (CompanyData): Company data instance
    Returns:
        Response: Result of the process
    """
    webhook_event.release()
    company_data = CompanyData(webhook_event.company_id)

    if webhook_event.allow_enable_stripe:
        company_data.enable_stripe()
    else:
        company_data.disable_stripe()

    return Response(
        f'Correctly processed the event {webhook_event.event_type}, '\
        f'charges = {webhook_event.charges_enabled}, '\
        f'details submited = {webhook_event.details_submitted}, '\
        'stripe enabled!' if webhook_event.allow_enable_stripe else 'stripe not enabled yet'
    )
