""" Functions to handle webhooks from Stripe after checkout session """
from werkzeug.wrappers import Request, Response

from events import session_completed, session_expired
from utils import set_up

from models.webhook_event import EventType, WebhookEvent

def handle_webhook(request: Request) -> Response:
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

    if webhook_event.event_type == EventType.SESSION_COMPLETED:
        return session_completed.handle_event(webhook_event)

    if webhook_event.event_type == EventType.SESSION_EXPIRED:
        return session_expired.handle_event(webhook_event)

    if webhook_event.event_type == EventType.NOT_IMPLEMENTED:
        return Response(
            response=f'The event {webhook_event.event_type.value} has not yet been implemented'
        )
    return Response(response='An error ocurred')
