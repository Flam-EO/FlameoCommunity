import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os

def sender_server():
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login('flameoapp@gmail.com', os.environ.get('email_password'))
    return server

def send_email(server, text, subject, send_to_email):
    from_email = 'info@flameoapp.com'
    ''' Send an email
            - server: the smtp server
            - text (string): the message uid
            - from_email (string): email who sent the message
            - send_to_email (string): destination email
            - subject (string): subject of message
        Returns the sendmail result (not useful?)
    '''
    msg = MIMEMultipart('alternative')
    msg['From'] = from_email
    msg['To'] = ", ".join(send_to_email)
    msg['Subject'] = subject
    msg.attach(MIMEText(text, 'html'))
    text = msg.as_string()
    return server.sendmail(from_email, send_to_email, text)

def hello_firestore(event, context):
    """Triggered by a change to a Firestore document.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    
    sender = event.get('value').get('fields').get('sender').get('stringValue')
    smtp_server = sender_server()
    content = f"""Sender: {sender}<br>
    Content: {event.get('value').get('fields').get('content').get('stringValue')}<br>
    Ip: {event.get('value').get('fields').get('ip').get('stringValue')}""" 
    send_email(smtp_server, content, f'Contacto flameoapp.com: {sender[:20]}', ['info@flameoapp.com'])
    smtp_server.close()
    try:
        if sender.count("@")==1 and sender.count(".")>=1:
            name = sender.split('@')[0]
            smtp_server = sender_server()
            content = open('contact_email.html', 'r').read().replace('{name}', name) 
            send_email(smtp_server, content, f'Flam-EO App', [sender])
            smtp_server.close()
    except:
        pass

