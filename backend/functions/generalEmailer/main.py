""" Stats of the current day visits """

import datetime
import os
from firebase_admin import firestore
from jinja2 import Environment, FileSystemLoader
from werkzeug import Response
from utils import send_email, sender_server, set_up

def general_emailer(context) -> Response:                                #pylint: disable=W0613, R0914
    """ 
    Send an email to a registered person that has not completed the data.

    Args:
        event (dict): Event payload.
        context (Context): Metadata for the event.
    """
    set_up()
    db = firestore.client()

    companies = db.collection(os.environ['COMPANIES_COLLECTION'])

    # Calculate the timestamp 5 hours ago from the current time
    current_time = datetime.datetime.now()
    

    # Select all the unfaithfull companies:

    query = companies
    docs = query.stream()
    
    # Iterate through the selected documents and update the "notified" field
    for doc in docs:
        doc_ref = companies.document(doc.id)

        # Set that the company has already been contacted.
        data = doc.to_dict()

        is_deleted = data.get("is_deleted")
        if is_deleted:
            print("Not you, bitch")
        else:   
            # Get the email
            email = data.get("email")
            name  = data.get("companyName")
            # print("********************************************************************************************")
            # # Construct the jinja template with the variables.

            env = Environment(loader=FileSystemLoader('templates'))

            content = env.get_template('message.html').render(name = name)

            # # Set up the mail server and send the mail.
            try:
                smtp_server = sender_server()
                send_email(
                    smtp_server,
                    content,
                    "Estrenamos Galería",
                    [email]
                )
            except exception:
                print(exception)
            finally:
                smtp_server.close()

    return Response(status=200)
