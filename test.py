class Dog:
    species = "Canis familaris"

    def __init__(self,name,age):
        self.name = name
        self.age = age

    def __str__(self):
        return f"{self.name} is {self.age} years old."

    def speak(self,sound):
        return f"{self.name} says {sound}"

class JackRussellTerrier(Dog):
    def speak(self,sound="Arf"):
        return super().speak(sound)


class GoldenRetriever(Dog):
    def speak(self,sound="Bark"):
        return super().speak(sound)

miles = JackRussellTerrier("Miles",5)
print(miles)
miles.speak()

from faker import Faker
import datetime
fake = Faker()
start_date = datetime.datetime(2015,1,1)
fake.date_between(start_date=start_date, end_date='now')