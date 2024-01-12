""" Useful functions """
import json
import os
import smtplib

from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

import firebase_admin

from firebase_admin import credentials

from google.cloud import secretmanager                                      #pylint: disable=E0611

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
    Set up the firebase admin app
    """
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
