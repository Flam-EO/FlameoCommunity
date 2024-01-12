from PIL import Image, ImageChops
import numpy as np

def remove_transparency(im, bg_colour=(255, 255, 255)):

    # Only process if image has transparency 
    if im.mode in ('RGBA', 'LA') or (im.mode == 'P' and 'transparency' in im.info):

        # Need to convert to RGBA if LA format due to a bug in PIL 
        alpha = im.convert('RGBA').split()[3]

        # Create a new background image of our matt color.
        bg = Image.new("RGBA", im.size, bg_colour + (255,))

        # Invert the alpha image.
        inv_alpha = ImageChops.invert(alpha)

        # Paste the inverted alpha into the matt background using itself as the mask
        bg.paste(inv_alpha, mask=inv_alpha)

        # Add alpha to the image and paste the original image on top
        im.putalpha(alpha)
        bg.paste(im, mask=im)

        # Convert to RGB, will lose alpha channel
        im = bg.convert("RGB")

    return im

def generate_gif(input_img_path, output_img_path, scale_range, frames_per_second):

    # Load the original image
    original_img = Image.open(input_img_path)

    frames = []  # List to hold the frames
    
    # Change the size
    for scale in scale_range:
        # Resize the image
        new_width = int(original_img.width*scale)
        new_height = int(original_img.height*scale)
        new_image = original_img.resize((new_width, new_height), Image.ANTIALIAS)
        
        # Compute the position to pasting the new image onto the frame
        upper_left_corner = ((original_img.width - new_image.width)//2, (original_img.height - new_image.height)//2)

        frame = Image.new("RGBA", original_img.size)
        frame.paste(new_image, upper_left_corner)
        frame_with_no_transparency = remove_transparency(frame)
        frames.append(frame_with_no_transparency)

    # Save as gif
    frames[0].save(output_img_path, append_images=frames[1:], save_all=True, duration=int(1000/frames_per_second), loop=0)

# Calculate the scales for each frame
frames_per_second = 20
total_frame_count = 40  # 2 seconds duration
scale_range = np.concatenate((np.linspace(1, 0.8, total_frame_count//2), np.linspace(0.8, 1, total_frame_count//2)))

generate_gif("logo.png", "logo.gif", scale_range, frames_per_second)