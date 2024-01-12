""" Check the status of Firebase and save it """
import firebase_admin
from firebase_admin import credentials, firestore, storage

cred = credentials.Certificate("./private_key.json")
firebase_admin.initialize_app(cred, {'storageBucket': 'flameoapp-pyme.appspot.com'})
store = firestore.client()

def clean():
    """ Clean trash in firebase storage """
    current_companies = [doc.id for doc in store.collection('companies').get()]
    current_companies += [doc.id for doc in store.collection('test_companies').get()]

    bucket = storage.bucket()

    valid_companies_ids = []
    for blob in bucket.list_blobs():
        if blob.name.startswith('logo'):
            print(blob.name)
        elif blob.name.split('/')[1] in current_companies:
            valid_companies_ids.append(blob.name.split('/')[1])
        else:
            blob.delete()
    print(set(valid_companies_ids))

if __name__ == '__main__':
    clean()
