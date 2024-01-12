import sys
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("./private_key.json")
firebase_admin.initialize_app(cred)
store = firestore.client()

def movedor(collection1, collection2):
    for doc in collection1.get():
        collection2.document(doc.id).set(doc.to_dict())
        for collection in collection1.document(doc.id).collections():
            movedor(collection, collection2.document(doc.id).collection(collection.id))

if __name__ == '__main__':
    movedor(*map(store.collection, sys.argv[1:]))