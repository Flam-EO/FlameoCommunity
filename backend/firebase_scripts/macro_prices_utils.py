##############################################################################################################
# Filename: macro_prices_utils.py
# Author: Luis Gutiérrez Pereda
# Date: 11/01/2023 Creation
# Description: This file contains useful functions related to the macro of the product prices.
##############################################################################################################

import numpy as np
from statistics import mean
import firebase_admin
from firebase_admin import credentials, firestore
import datetime


def get_company_id(company_name, store) -> str:
    """
    This function allows to get the company ID from the database after filtering by the companyName key.

    Args:
        company_name (str): value of the companyName key.
        store: Firestore client

    Returns:
        str: company ID
    """
    query_company_name = store.collection(u'companies').where(u'companyName', u'==', company_name).stream()

    for document in query_company_name:
        company_id = document.id

    return company_id


def get_user_product_list(company_id, store) -> list:
    """
    This function extracts the user product list from a certain company given the company ID.

    Args:
        company_id (str): Company ID
        store: Firestore client

    Returns:
        list: User Product list
    """
    user_product_list = []
    query_user_products = store.collection(u'companies').document(company_id).collection(u'Products').order_by(
        u'creationTimestamp', direction=firestore.Query.DESCENDING).limit(1).get()
    for document in query_user_products:
        user_product_list = document.to_dict()['products']
    return user_product_list


def get_price_set(company_id, store) -> dict:
    """
    Function to extract the set of prices of a certain company defined by its company ID.

    Args:
        company_id (str): Company ID.
        store: Firestore client

    Returns:
        dict: Dictionary with the set of prices.
    """
    price_set = {}
    query_price_set = store.collection(u'companies').document(company_id).collection('Prices').document('priceSet').get()
    if query_price_set.exists:
        price_set = query_price_set.to_dict()
    return price_set


def remove_user_product_prices(prices_dict, store) -> dict:
    """
    This function removes proprietary products from the set of prices of a certain company, creating a set of 
    prices comprised exclusively by generic products.

    Args:
        prices_dict (dict): Dictionary with the set of prices of a certain company.
        store: Firestore client

    Returns:
        dict: New dictionary with the proprietary products removed.
    """
    # Getting common products from the database
    common_products = store.collection(u'Products').document('products1').get().to_dict()
    
    new_prices_dict = {}
    
    for key in prices_dict:
        if key in common_products:
            new_prices_dict[key] = prices_dict[key]
    return new_prices_dict
            
            

def perturbate_prices(prices_dict, sigma) -> dict:
    """
    This function generates a new dictionary of prices after applying a gaussian noise to the reference price 
    dictionary given as input.

    Args:
        prices_dict (dict): Reference prices dictionary
        sigma: Standard deviation for the gaussian noise in €

    Returns:
        dict: New prices with gaussian noise applied
    """
    new_prices_dict = {}
    for key in prices_dict:
        value = float(prices_dict[key])
        value = np.random.normal(value, sigma, 1)[0]  # For the noise a std deviation of 1 € is chosen
        value = round(abs(value), 2)  # We avoid negative prices and round to two decimals
        new_prices_dict[key] = value
    return new_prices_dict


def set_generated_prices(company_id, prices_dict, store) -> str:
    """
    Function to upload generated prices to the desired company

    Args:
        company_id (str): Company ID of the desired company
        prices_dict (dict): Dictionary of product prices
        store: Firestore client

    Returns:
        str: _description_
    """
    try:
        store.collection(u'companies').document(company_id).collection('Prices').document('priceSet').set(prices_dict)
    except:
        return 'Error uploading generated prices'
    
    return f'Generated prices uploaded successfully to company {company_id}'


def upload_daily_macro_data(company_prices, store) -> str:
    
    date_docname = datetime.date.today()
    
    date_docname = date_docname.strftime('%Y%m%d')  # Name for the document where data is stored
    
    # Checking for data already uploaded to DailyMacroData
    query_data = store.collection(u'DailyMacroData').document(date_docname).get()
    
    if query_data.exists:
        macro_data = query_data.to_dict()
        for key in company_prices:
            if key in macro_data:
                macro_data[key]['CompanyPrices'].append(company_prices[key])
            else:
                macro_data[key] = {'CompanyPrices' : [company_prices[key]]}
    else:
        macro_data = {}
        for key in company_prices:
            macro_data[key] = {'CompanyPrices' : [company_prices[key]]}
    
    # Calculate Max, Mean and Min prices
    for key in macro_data:
        macro_data[key]['MaxPrice'] = round(max(macro_data[key]['CompanyPrices']), 2)
        macro_data[key]['MeanPrice'] = round(mean(macro_data[key]['CompanyPrices']), 2)
        macro_data[key]['MinPrice'] = round(min(macro_data[key]['CompanyPrices']), 2)
    
    try:
        # Uploading updated data to firebase
        store.collection(u'DailyMacroData').document(date_docname).set(macro_data)
        
        return 'DailyMacroData uploaded correctly to firebase.'
    except:
        
        return 'Error uploading DailyMacroData to firebase'
