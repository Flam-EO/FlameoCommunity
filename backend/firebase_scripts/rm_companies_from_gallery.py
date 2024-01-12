##############################################################################################################
# Filename: rm_companies_from_gallery.py
# Author: Luis Gutiérrez Pereda
# Date: 08/12/2023 Creation
# Description: Deletes all the products from deleted companies from the gallery
##############################################################################################################
import firebase_admin
from firebase_admin import credentials, firestore

if __name__ == '__main__':

  # Initialize firestore app
  cred = credentials.Certificate('./private_key.json')
  firebase_admin.initialize_app(cred)
  db = firestore.client()
    
  companies = db.collection("companies")
  
  # Query to filter documents where 'isDeleted' is True
  query = companies.where('is_deleted', '==', True)

  # Get all documents in the collection
  docs = query.stream()

  # Iterate over each document
  for doc in docs:
    # Print document ID
    print(f"Company ID: {doc.id}")

    # Check if 'Products' subcollection exists
    products_ref = doc.reference.collection('Products')
    if products_ref.get():
      # Subcollection 'Products' exists, update each document within it
      products_docs = products_ref.stream()
      for product_doc in products_docs:
        # Update the 'galleryPunctuation' field to 0
        punctuation = product_doc.to_dict().get("galleryPunctuation")
        print(f'punctuation of the product: {punctuation}')
        if punctuation != None:
          product_doc.reference.update({'galleryPunctuation': 0})
      print("\n") 

  # Closing firebase connection
  firebase_admin.delete_app(firebase_admin.get_app())