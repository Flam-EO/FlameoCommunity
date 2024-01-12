""" Dalle-3 """
from typing import List
import webbrowser
from openai import OpenAI

client = OpenAI(api_key=)

def generate_image(prompt: str) -> List[str]:
    """ Generate a link of a dalle-3 generated image from a prompt

    Args:
        prompt (str): Prompt to generate image

    Returns:
        List[str]: List of images links
    """
    images = client.images.generate(
        model="dall-e-3",
        prompt=prompt,
        size="1024x1024",
        quality="standard",
        n=1
    ).data
    return list(map(lambda x: x.url, images))

if __name__ == '__main__':
    for image_link in generate_image('''
        Photo of a rat being a spanish president
    '''):
        webbrowser.open(image_link)
