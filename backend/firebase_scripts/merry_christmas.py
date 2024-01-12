""" Merry Christmas and happy new year """
#%%
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import smtplib
from typing import Dict
import yaml
import firebase_admin
from firebase_admin import credentials, firestore
from jinja2 import Environment, FileSystemLoader

email_credentials: Dict[str, str]

def sender_server():
    """ Creates a server instance to send emails """
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(email_credentials.get('email'), email_credentials.get('password'))
    return server

def send_email(text, subject, send_to_email):
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
    server = sender_server()
    from_email = email_credentials.get('alias')
    msg = MIMEMultipart('alternative')
    msg['From'] = from_email
    msg['To'] = ", ".join(send_to_email)
    msg['Subject'] = subject
    msg.attach(MIMEText(text, 'html'))
    text = msg.as_string()
    server.sendmail(from_email, send_to_email, text)
    server.close()

#%%
if __name__ == '__main__':
    email_credentials = yaml.safe_load(open('./credentials.yaml', 'r', encoding='utf-8'))
    cred = credentials.Certificate('./private_key.json')
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    env = Environment(loader=FileSystemLoader('.'))

    companies_ref = db.collection("companies")
    send = False
    for companyDoc in companies_ref.stream():
        data = companyDoc.to_dict()
        if not data.get("is_deleted") and data.get('flameoExtension') == 'art':
            email = data.get("email")
            if send:
                print(email)
                content = env.get_template('./merry_christmas.j2').render(
                    name=data.get('companyName')
                )
                send_email(
                    content,
                    "Feliz Navidad y un creativo año 2024!",
                    [email]
                )
            if email == 'Ángelesbielsa93@gmail.com':
                send = True

    firebase_admin.delete_app(firebase_admin.get_app())

# %%
