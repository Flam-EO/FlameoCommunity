""" GPT4 """
from typing import List
import openai

openai.api_key=

def query(prompt: str) -> List[str]:
    """ Generate a response from gpt-4

    Args:
        prompt (str): Prompt to generate response

    Returns:
        List[str]: List of responses
    """
    choices =  openai.ChatCompletion.create(
        model="gpt-4",
        max_tokens=2000,
        messages=[
            {
                "role": "user",
                "content": prompt
            }
        ]
    ).choices
    return list(map(lambda x: x.message.content, choices))

if __name__ == '__main__':
    print(query('''
        Photo of a rat being a spanish president
    '''))
