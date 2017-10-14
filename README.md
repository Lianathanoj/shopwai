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

## License
This demo application is licensed under the MIT license: http://opensource.org/licenses/mit-license.php
