***Devpost:*** https://devpost.com/software/shopwai

***How It Works:***
Running the Processing application creates an interface wherein store managers can draw a layout of their store and click on locations of where their products are located. After this, a text file consisting of the product name and coordinate information as well as an image file are sent over to our web application. We use this data to populate a database of stock items, and then customers can input items onto their shopping list and it will automatically update the floor plan with the product location. Every time a product is added to this list, we recalculate the shortest path customers should take to buy all items on their shopping list given their current location so they can save as much time as possible. The floor plan will also draw a path from the current location to the next prioritized object's location and will update everytime an item is checked off.

***Demo Information:***
Currently, our app has four items in stock for the store: sprite, bread, eggs, and tomato. Inputting any of these values will show visual changes to the floor plan, and inputting any other word value not within the store stock will only add the item to the list.

To run:
* Have Python 2 installed. I recommend using a virtualenv and then installing Python and pip within this environment.
* Clone from Github
* Use pip to install the necessary packages:
```
pip_install -r requirements-dev.txt
```
* Run the application in debug mode by navigating to the project directory and in command line typing the following:
```
set FLASK_APP=app.py
set FLASK_DEBUG=1
python -m flask run
```
* If you run into problems, you can alternatively run
```
python app.py
```
* Navigate to localhost:5000

