import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate(u'./key_name.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# Define the source and destination collection names

def copy_documents():

  companies_collection = db.collection(u'test_companies')

  for company in companies_collection.stream():
    for product in company.reference.collection("Products").stream():
      data = product.to_dict()
      new_doc_ref = company.reference.collection("test_products").document(product.id).set(data)


if __name__ == "__main__":
    copy_documents()
