""" Model to store the client data """
from typing import Any, Dict

from models.address import Address

class ClientContact():
    """
    Client contact data

    Args:
        client_data (Dict[str, Any]): Client data dictionary
    
    Attrs:
        name (str): Client name
        email (str): Client email
        address (Address): Client address
    """

    name: str
    email: str
    address: Address

    def __init__(self, client_data: Dict[str, Any]) -> None:
        self.name = client_data['name']
        self.email = client_data['email']
        if client_data.get('address'):
            self.address = Address(client_data['address'])
        else:
            self.address = None
