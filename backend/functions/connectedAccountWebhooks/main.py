""" Listen to connected account events from stripe and update firestore """
from werkzeug.wrappers import Response

from events import account_updated
from models.webhook_event import EventType, WebhookEvent
from utils import set_up

def handle_webhook(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    set_up()

    webhook_event = WebhookEvent(request)
    if webhook_event.error:
        return Response(response='Error', status=400)
    webhook_event.upload_to_firestore()
    print(webhook_event.event_type)

    if webhook_event.event_type == EventType.ACCOUNT_UPDATED:
        return account_updated.handle_event(webhook_event)

    if webhook_event.event_type == EventType.NOT_IMPLEMENTED:
        return Response(f'The event {webhook_event.event_type.value} has not yet been implemented')
