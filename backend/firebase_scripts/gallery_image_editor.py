##############################################################################################################
# Filename: gallery_image_editor.py
# Author: Luis Gutiérrez Pereda
# Date: 08/12/2023 Creation
# Description: This script generates smaller thumnails for all products selected.
##############################################################################################################

import os
import firebase_admin
from firebase_admin import credentials, storage
from PIL import Image
import time
import shutil
from concurrent.futures import ThreadPoolExecutor


# globals
THREADS = 4

def get_upload_path(path):
    # Split the path into parts
    path_parts = path.split('/')

    # Find the index of the last occurrence of the file name
    file_name_index = -1 if '.' not in path_parts[-1] else path_parts.index(path_parts[-1])

    # Insert "thumbnails" before the file name
    path_parts.insert(file_name_index, "thumbnails")

    # Join the modified parts back into a path
    return '/'.join(path_parts)


def download_compress_upload_img(blob, images_directory, i, quality=50, width=500):
    
    image_name = f'./{images_directory}/image{i}.jpg'

    # download the image
    blob.download_to_filename(image_name)
    
    # load the image to memory
    img = Image.open(image_name)
   
    # print the original image shape
    rwidth, rheight = img.size
    height = round(width * rheight / rwidth)
   
    # resize the image with width and height
    img = img.resize((width, height), Image.NEAREST)

    # change the new extension for jpg
    filename, ext = os.path.splitext(image_name)
    new_filename = f"{filename}.jpg"

    try:
        # save the image with the corresponding quality and optimize set to True
        img.save(new_filename, quality=quality, optimize=True)
    except OSError:
        # convert the image to RGB mode first
        img = img.convert("RGB")
        # save the image with the corresponding quality and optimize set to True
        img.save(new_filename, quality=quality, optimize=True)
    
    # upload the image
    update_blob = bucket.blob(get_upload_path(blob.name))
    try:
        update_blob.upload_from_filename(new_filename)
    except Exception as e:
        print(e)
    
if __name__ == '__main__':
    
    start_time = time.time()
    # Initialize Firebase with your credentials
    cred = credentials.Certificate('credentials.json')
    firebase_admin.initialize_app(cred, {'storageBucket': 'flameoapp-pyme.appspot.com'})

    bucket = storage.bucket()
    blobs = bucket.list_blobs(prefix='Companies')

    # filter out strings containing "thumbnails" in the path
    blobs = [blob for blob in blobs if "thumbnails" not in blob.name]

    # filter out portada files
    blobs = [blob for blob in blobs if not blob.name.split("/")[-1].lower().startswith("portada")]
    blobs = [blob for blob in blobs if not blob.name.split("/")[-1].lower().startswith("port.")]

    images_directory = os.path.join('.', "tmp")
 
    # remove tmp dir
    if shutil.os.path.exists(images_directory):
        shutil.rmtree(images_directory)

    # create images directory
    os.makedirs(images_directory, exist_ok=True)
    
    # Set the number of threads you want to use
    num_threads = THREADS  # Adjust as needed  
 
    # Use ThreadPoolExecutor for parallel execution
    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        # Initialize an index counter for naming the downloaded images
        i = 0
        # Submit tasks to the thread pool
        for blob in blobs:
            executor.submit(download_compress_upload_img, blob, images_directory, i)
            print(f'blob submitted: {blob.name}')
            i += 1

    end_time = time.time()
    elapsed_time = end_time - start_time
    print(f"Elapsed time: {elapsed_time} s")
