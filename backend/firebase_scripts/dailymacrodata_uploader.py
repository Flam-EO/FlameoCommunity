##############################################################################################################
# Filename: dailymacrodata_uploader.py
# Author: Luis Gutiérrez Pereda
# Date: 18/01/2023 Creation
# Description: This script can be executed daily to upload DailyMacroData.
##############################################################################################################
import datetime
import firebase_admin
from firebase_admin import credentials, firestore
import macro_prices_utils as utils

# Initialize the firebase app
cred = credentials.Certificate(u'./flameoapp-pyme-firebase-adminsdk-wpbb3-7807b9ab03.json')
firebase_admin.initialize_app(cred)
store = firestore.client()

# Check for already added macro prices the same day to delete them and upload the updated ones
date_docname = datetime.date.today()
date_docname = date_docname.strftime('%Y%m%d')
query_macroprices = store.collection(u'DailyMacroData').document(date_docname).get()

if query_macroprices.exists:
    store.collection(u'DailyMacroData').document(date_docname).delete()

# Get list with all the company IDs to add all their prices to DailyMacroData
query_company_ids = store.collection(u'companies').stream()

company_id_list = []
for document in query_company_ids:
    company_id_list.append(document.id)

# Iterate throuout all the company IDs and upload their prices to DailyMacroData
for company_id in company_id_list:
    company_prices = utils.get_price_set(company_id, store)
    # Only add prices from a certain company if it already has prices
    if bool(company_prices):
        # Remove user products from the macro prices
        company_prices = utils.remove_user_product_prices(company_prices, store)
        # Apply noise to macro prices
        sigma = 0.05  # 5 Cent for the sigma of the perturbed prices
        company_prices = utils.perturbate_prices(company_prices, sigma)
        # Upload macro prices for the company
        upload_result = utils.upload_daily_macro_data(company_prices, store)
        # Print result of the prices upload
        print(upload_result)
