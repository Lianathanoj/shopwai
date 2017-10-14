# -*- coding: utf-8 -*-
import os
try:
    import psycopg2  # for heroku deploy
except:
    pass

from flask import Flask, render_template, redirect, url_for, request
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SECRET_KEY'] = 'a secret string'
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite://')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
# app.config['DEBUG'] = True
db = SQLAlchemy(app)

class Item(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    body = db.Column(db.Text)
    x_value = db.Column(db.Integer)
    y_value = db.Column(db.Integer)
    category_id = db.Column(db.Integer, db.ForeignKey('category.id'), default=1)

class Category(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64))
    items = db.relationship('Item', backref='category')

# only for local test
@app.before_first_request
def init_db():
    """Insert default categories and demo items.
    """
    db.create_all()
    inbox = Category(name=u'Unfinished Tasks')
    done = Category(name=u'Finished Tasks')


    # from firebase import firebase
    # firebase = firebase.FirebaseApplication('https://shopwai-a7cc7.firebaseio.com', None)
    # result = firebase.get('/users', None)
    # print (result)

    import pyrebase
    import json
    config = {
        "apiKey": "AIzaSyAlDYWi8NBRGwooGwROV30VpXHjsWd7x5I",
        "authDomain": "shopwai-a7cc7.firebaseapp.com",
        "databaseURL": "https://shopwai-a7cc7.firebaseio.com",
        "storageBucket": "",
        "serviceAccount": "database key"
    }

    firebase = pyrebase.initialize_app(config)
    dba = firebase.database()

    # Add data
    # data = {"name": "Mortimer 'Morty' Smith"}
    # dba.child("users").child("Morty").set(data)

    # Retrieve data
    all_products = dba.child("Products").get()

    # for all products
    item_list = []
    for key, product in all_products.val().items():
        item = Item(body=product["name"], x_value=product["x"], y_value=product["y"])
        # print item.body()
        # print key
        # print product["name"]
        item_list = item_list + [item]

    # item = Item(body=u'Milk', x_value=1, y_value=3)
    # item2 = Item(body=u'Cheese', x_value=17, y_value=9)
    # item3 = Item(body=u'Lettuce', x_value=7, y_value=20)
    # item4 = Item(body=u'Tomatoes', x_value=11, y_value=9)
    # db.session.add_all([inbox, done, item, item2, item3, item4])

    db.session.add_all([inbox, done] + item_list)
    db.session.commit()

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        body = request.form.get('item')
        category_id = request.form.get('category')
        category = Category.query.get_or_404(category_id)
        item = Item(body=body, category=category)
        db.session.add(item)
        db.session.commit()
        return redirect(url_for('category', id=category_id))
    return redirect(url_for('category', id=1))

@app.route('/category/<int:id>')
def category(id):
    category = Category.query.get_or_404(id)
    categories = Category.query.all()
    items = category.items
    item_coordinates = [{"x": item.x_value, "y": item.y_value, "value": 20} for item in items]
    return render_template('index.html', items=items, item_coordinates=item_coordinates,
                           categories=categories, category_now=category)

@app.route('/new-category', methods=['GET', 'POST'])
def new_category():
    name = request.form.get('name')
    category = Category(name=name)
    db.session.add(category)
    db.session.commit()
    return redirect(url_for('category', id=category.id))

@app.route('/edit-item/<int:id>', methods=['GET', 'POST'])
def edit_item(id):
    item = Item.query.get_or_404(id)
    category = item.category
    item.body = request.form.get('body')
    db.session.add(item)
    db.session.commit()
    return redirect(url_for('category', id=category.id))

@app.route('/edit-category/<int:id>', methods=['GET', 'POST'])
def edit_category(id):
    category = Category.query.get_or_404(id)
    category.name = request.form.get('name')
    db.session.add(category)
    db.session.commit()
    return redirect(url_for('category', id=category.id))

@app.route('/done/<int:id>', methods=['GET', 'POST'])
def done(id):
    item = Item.query.get_or_404(id)
    category = item.category
    done_category = Category.query.get_or_404(2)
    done_item = Item(body=item.body, category=done_category)
    db.session.add(done_item)
    db.session.delete(item)
    db.session.commit()
    return redirect(url_for('category', id=category.id))

@app.route('/delete-item/<int:id>')
def del_item(id):
    item = Item.query.get_or_404(id)
    category = item.category
    if item is None:
        return redirect(url_for('category', id=1))
    db.session.delete(item)
    db.session.commit()
    return redirect(url_for('category', id=category.id))

@app.route('/delete-category/<int:id>')
def del_category(id):
    category = Category.query.get_or_404(id)
    if category is None or id in [1, 2]:
        return redirect(url_for('category', id=1))
    db.session.delete(category)
    db.session.commit()
    return redirect(url_for('category', id=1))

if __name__ == '__main__':
    # init_db()
    app.run()
