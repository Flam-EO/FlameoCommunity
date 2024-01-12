""" Check the status of Firebase and save it """
import json
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("./private_key.json")
firebase_admin.initialize_app(cred)
store = firestore.client()

def check():
    """ Check the status of Firebase and save it """
    previous_status = json.load(open('status.json', 'r', encoding='utf-8'))
    new_status = {
        collection.id: [
            doc.id for doc in collection.get()
        ] for collection in store.collections()
    }
    new_collections = set(new_status.keys()) - set(previous_status.keys())
    deleted_collections = set(previous_status.keys()) - set(new_status.keys())
    same_collections = set(previous_status.keys()) & set(new_status.keys())
    print('New collections: ')
    print('\n'.join(map(lambda x: f'\t- {x}', new_collections)))
    print('Deleted collections: ')
    print('\n'.join(map(lambda x: f'\t- {x}', deleted_collections)))
    print('Modified collections: ')
    modified_collections = [c for c in same_collections if previous_status[c] != new_status[c]]
    for collection in modified_collections:
        print(f'\t- {collection}:')
        new_docs = set(new_status[collection]) - set(previous_status[collection])
        deleted_docs = set(previous_status[collection]) - set(new_status[collection])
        print('\t\tNew docs:')
        print('\n'.join(map(lambda x: f'\t\t\t- {x}', new_docs)))
        print('\t\tDeleted docs:')
        print('\n'.join(map(lambda x: f'\t\t\t- {x}', deleted_docs)))
    json.dump(new_status, open('status.json', 'w', encoding='utf-8'), indent=4)

if __name__ == '__main__':
    check()
