import firebase_admin
from firebase_admin import credentials, firestore
import matplotlib.pyplot as plt
import math

# Proprietary imports
import generador_precios as gen


if __name__ == '__main__':
    
    # Initialize firebase app
    cred = credentials.Certificate(u'./private_key.json')
    firebase_admin.initialize_app(cred)
    store = firestore.client()
    
    # Company names of the companies from which prices will be compared
    company_names = ['flameoTesting',
                    'Flameo 2',
                    'Flameo App Test 3',
                    'Test User 4',
                    'Test User 5',
                    'Test User 6',
                    ]

    # Getting company IDs from the company names
    company_ids = []
    for name in company_names:
        company_ids.append(gen.get_company_id(name, store))
    
    # Getting price sets without proprietary products from the company IDs
    price_sets = []
    for company in company_ids:
        price_set = gen.get_price_set(company, store)
        user_products = gen.get_user_product_list(company, store)
        price_set = gen.remove_user_product_prices(price_set, user_products)
        price_sets.append(price_set)
    
    # Get the total set of products from the price sets and order the set alphabetically
    product_set = set()
    for price_set in price_sets:
        for key in price_set:
            product_set.add(key)
    ordered_products = sorted(product_set)
    
    # Get prices data of each product to plot
    price_data = []
    for product in ordered_products:
        product_prices = []  # List of prices associated to a certain product
        for price_set in price_sets:
            try:
                product_prices.append(price_set[product])
            except:
                pass
        price_data.append(product_prices)
    
    # Calculate number of rows/columns for complex plot
    cols = math.floor(len(ordered_products) / 3)
    if (len(ordered_products) / 3).is_integer():
        rows = 3
    else:    
        rows = 4
    
    # Defining the complex plot with the histograms of all products
    figure, axis = plt.subplots(rows, cols)
    
    figure.suptitle("Histogramas de precio de los productos", fontsize=16)
    
    # Number of bins for the histograms
    number_of_bins = 20
    
    for product in ordered_products:
        count = 0;  # Count to iterate through all the products
        for row in range(rows-1):
            for col in range(cols):
                data = sorted(price_data[count])
                bin_width = (data[len(data) - 1] - data[0]) / number_of_bins
                axis[row, col].hist(data, bins = number_of_bins, color='skyblue', edgecolor='black', linewidth=1.2)
                axis[row, col].tick_params(axis='both', which='major', labelsize=5)
                axis[row, col].tick_params(axis='both', which='minor', labelsize=5)
                axis[row, col].set_title(f'{ordered_products[count]}', fontsize=7)
                count = count + 1
        
        # Print last row
        row = rows - 1
        for col in range(len(ordered_products) - count):
            data = sorted(price_data[count])
            bin_width = (data[len(data) - 1] - data[0]) / number_of_bins
            axis[row, col].hist(data, bins = number_of_bins, color='skyblue', edgecolor='black', linewidth=1.2)
            axis[row, col].tick_params(axis='both', which='major', labelsize=5)
            axis[row, col].tick_params(axis='both', which='minor', labelsize=5)
            axis[row, col].set_title(f'{ordered_products[count]}', fontsize=7)
            count = count + 1

    # Plot in full screen
    manager = plt.get_current_fig_manager()
    manager.full_screen_toggle()
    
    # Show plot
    plt.show()
