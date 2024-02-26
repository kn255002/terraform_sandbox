###
#
#
#
#Author: Khurram Nazir
#Date: 26.02.2024

import datetime

# Step 1: Ask for first name and store it in a variable
first_name = input("Enter your first name: ")

# Step 2: Welcome message and take input
print(f"Khan Saab kia haal hane! \nKoch smjh aa rhee hae Kubernetes key?")
user_input = input("Your response: ")

# Step 3: Display a message
print(f"{first_name} Sb, Key of success is not to be intelligent rather it's continuous working on your goal!")

# Step 4: Display final message with today's date
today_date = datetime.date.today().strftime("%Y-%m-%d")
print(f"This info comes from Python based application running in a container {today_date}")
user_input = input("Did you like it?")

