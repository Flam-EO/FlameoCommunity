""" Useful functions """
import datetime
import json
from numbers import Number
import os
import smtplib

from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

import firebase_admin
import stripe

from firebase_admin import credentials
from firebase_admin import storage

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

def sender_server():
    """ Creates a server instance to send emails """
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(os.environ.get('sender_email'), os.environ.get('email_password'))
    return server

def send_email(server, text, subject, send_to_email):
    """
    Sends an email to the user.
    Args:
        server: The server instance to send the email with.
        text (str): The text of the email.
        subject (str): The subject of the email.
        send_to_email (str): The email to send the email to.

    Returns:
        str: The result of the sendmail.
    """
    from_email = os.environ.get('email_alias')
    msg = MIMEMultipart('alternative')
    msg['From'] = from_email
    msg['To'] = ", ".join(send_to_email)
    msg['Subject'] = subject
    msg.attach(MIMEText(text, 'html'))
    text = msg.as_string()
    return server.sendmail(from_email, send_to_email, text)

def get_firebase_storage_download_link(bucket_name: str, blob_name: str) -> str:
    """
    Generate a temporary (7 days) firebase storage download link

    Args:
        bucket_name (str): The name of the bucket
        blob_name (str): The name of the blob

    Returns:
        str: The download link
    """
    bucket = storage.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    return blob.generate_signed_url(
        version="v4",
        expiration=datetime.timedelta(days=7),
        method="GET"
    )

def round_number(number: Number) -> Number:
    """
    Rounds a number to 2 decimals or pure integer

    Args:
        number (Number): Number to round

    Returns:
        Number: The rounded number
    """
    if number % 1 == 0:
        return int(number)
    return round(number, 2)
