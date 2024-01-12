##############################################################################################################
# Filename: add_nproducts_field.py
# Author: Luis Gutiérrez Pereda
# Date: 02/10/2023 Creation
# Description: Script to add missing nProducts field to the companies in the firebase collection.
##############################################################################################################


import firebase_admin
from firebase_admin import credentials, firestore

if __name__ == '__main__':

  # Initialize firebase app
  cred = credentials.Certificate('./firebase_credential.json')
  firebase_admin.initialize_app(cred)
  db = firestore.client()
  
  # Iterate through the companies, count the products per company and assign the value to the nProducts field
  companiesRef = db.collection("test_companies")
  
  for companyDoc in companiesRef.stream():
    
    productsRef = companyDoc.reference.collection("Products")
    
    productsDocs = productsRef.stream()
    
    productsCount = len(list(productsDocs))
    
    companyRef = companiesRef.document(companyDoc.id)
    companyRef.update({"nProducts": productsCount})
    
    print(f"'nProducts' updated in {companyDoc.id} to {productsCount}")

# Closing firebase connection
firebase_admin.delete_app(firebase_admin.get_app())