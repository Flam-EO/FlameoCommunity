""" Useful functions """
import datetime
import json
import os
import smtplib

from dataclasses import dataclass
from io import BytesIO
from numbers import Number

from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart

import firebase_admin
import qrcode

from firebase_admin import credentials, storage

from google.cloud import secretmanager                                      #pylint: disable=E0611

@dataclass
class AttachedFile():
    """ Object representing an attached file for email """
    name: str
    content: BytesIO

    @property
    def content_bytes(self) -> bytes:
        """ Read the file content """
        return self.content.read()

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

def send_email(server, text, subject, send_to_email, file_to_attach: AttachedFile):
    """
    Sends an email to the user.
    Args:
        server: The server instance to send the email with.
        text (str): The text of the email.
        subject (str): The subject of the email.
        send_to_email (str): The email to send the email to.
        file_to_attach (AttachedFile): Filepath to atach in the email

    Returns:
        str: The result of the sendmail.
    """
    from_email = os.environ.get('email_alias')
    msg = MIMEMultipart('alternative')
    msg['From'] = from_email
    msg['To'] = ", ".join(send_to_email)
    msg['Subject'] = subject
    msg.attach(MIMEText(text, 'html'))
    if file_to_attach:
        msg.attach(MIMEImage(file_to_attach.content_bytes, name=file_to_attach.name))
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

def generate_qr(data: str) -> BytesIO:
    """
    Generates a qr code from the data

    Args:
        data (str): The data to generate the qr code from

    Returns:
        AttachedFile: The qr code file
    """
    qr_buffer = BytesIO()
    qr = qrcode.QRCode(version=1, box_size=10, border=4)
    qr.add_data(data)
    qr.make(fit=True)
    qr.make_image(fill_color="black", back_color="white").save(qr_buffer)
    qr_buffer.seek(0)
    return AttachedFile(
        name='qr.png',
        content=qr_buffer
    )
