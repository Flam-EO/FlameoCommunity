""" Model to store Adress """

from typing import Any, Dict


class Address():
    """
    Store the client address
    """

    province: str
    city: str
    zip_code: str
    street: str
    number: str
    floor: str
    door: str
    details: str

    def __init__(self, data: Dict[str, Any]) -> None:
        self.province = data.get("province")
        self.city = data.get("city")
        self.zip_code = data.get("zipCode")
        self.street = data.get("street")
        self.number = data.get("number")
        self.floor = data.get("floor")
        self.door = data.get("door")
        self.details = data.get("details")

    def to_html(self) -> str:
        """ Build the html representation of the address """
        return str(self).replace("\n", "<br>")

    def __str__(self) -> str:
        return f'{self.street} {self.number}\n'\
               f'{self.floor} {self.door}\n'\
               f'{self.city}, {self.province} {self.zip_code}\n'\
               f'{self.details}'
