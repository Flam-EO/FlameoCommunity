""" Creates add faith called field """
###################################################################################################
# Filename: add_nproducts_field.py
# Author: Luis Gutiérrez Pereda
# Date: 02/10/2023 Creation
# Description: Script to add missing nProducts field to the companies in the firebase collection.
####################################################################################################


import firebase_admin
from firebase_admin import credentials, firestore

if __name__ == '__main__':

    # Initialize firebase app
    cred = credentials.Certificate('./private_key.json')
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    # Iterate through the companies, count the products per company and assign the value to the
    # nProducts field
    companiesRef = db.collection("companies")

    for companyDoc in companiesRef.stream():
        companyRef = companiesRef.document(companyDoc.id)
        companyRef.update({"faith_called": False})

# Closing firebase connection
firebase_admin.delete_app(firebase_admin.get_app())
