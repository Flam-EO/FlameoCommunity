""" Useful functions """
import json
import os

import firebase_admin
import stripe

from firebase_admin import credentials
from google.cloud import secretmanager                                      #pylint: disable=E0611

STRIPE_SECRET_NAME = os.environ['STRIPE_SECRET_NAME']

def get_secret(desired_key: str) -> str:
    """ Get a secret from the google secret manager.

    Args:
        desired_key (str): The key of the secret you want to get.

    Returns:
        str: The value of the secret.
    """
    client = secretmanager.SecretManagerServiceClient()
    secret_name = f'projects/flameoapp-pyme/secrets/{desired_key}/versions/latest'
    response = client.access_secret_version(request={"name": secret_name})
    return response.payload.data.decode('UTF-8')

def set_up() -> None:
    """
    Set up the firebase admin app and set the stripe secret key
    """
    stripe.api_key = get_secret(STRIPE_SECRET_NAME)
    if not firebase_admin._apps:                                            #pylint: disable=W0212
        cred = credentials.Certificate(json.loads(get_secret('firebaseDatabase')))
        firebase_admin.initialize_app(cred)
