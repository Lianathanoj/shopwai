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

entrance = (350, 600) # bottom middle
exit = (700, 300) # right middle
current_location = entrance
num_unfinished = 0
num_finished = 0

class StockItem(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    body = db.Column(db.Text)
    x_value = db.Column(db.Integer)
    y_value = db.Column(db.Integer)

class CurrentItem(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    body = db.Column(db.Text)
    x_value = db.Column(db.Integer)
    y_value = db.Column(db.Integer)
    category_id = db.Column(db.Integer, db.ForeignKey('category.id'), default=1)

class Category(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64))
    items = db.relationship('CurrentItem', backref='category')

# only for local test
@app.before_first_request
def init_db():
    """Insert default categories and demo items.
    """
    db.create_all()
    inbox = Category(name=u'Unfinished Tasks')
    done = Category(name=u'Finished Tasks')

    # parse text file for product coordinates
    file = open("product-info.txt", "r")
    lines = file.readlines()
    file.close()

    product_items = []
    for line in lines:
        split_line = line.split(',')
        item_name, x_coord, y_coord = split_line[0], split_line[1], split_line[2]
        product_items.append(StockItem(body=unicode(item_name, "utf-8"), x_value=x_coord, y_value=y_coord))

    # item = Item(body=u'Milk', x_value=50, y_value=90)
    # item2 = Item(body=u'Cheese', x_value=140, y_value=180)
    # item3 = Item(body=u'Lettuce', x_value=300, y_value=100)
    # item4 = Item(body=u'Tomatoes', x_value=500, y_value=300)
    db.session.add_all([inbox, done] + product_items)
    db.session.commit()

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        body = request.form.get('item')
        category_id = request.form.get('category')
        category = Category.query.get_or_404(category_id)

        try:
            stock_item = StockItem.query.filter_by(body=body).one()
            item = CurrentItem(body=stock_item.body, category=category,
                              x_value=stock_item.x_value,y_value=stock_item.y_value)
            db.session.add(item)
            db.session.commit()
            # return redirect(url_for('category', id=category_id))
        except:
            item = CurrentItem(body=body, category=category)
            db.session.add(item)
            db.session.commit()
        finally:
            current_items = CurrentItem.query.all()
            if len([item for item in current_items if item.category == 1]) > 1:
                ordered_items = [(current_item.body, current_item.category, current_item.x_value, current_item.y_value)
                                 for current_item in greedy_algorithm(current_items)]
                db.session.query(CurrentItem).delete()
                ordered_items = [CurrentItem(body=current_item[0], category=current_item[1], x_value=current_item[2],
                                             y_value=current_item[3]) for current_item in ordered_items]
                db.session.add_all(ordered_items)
                db.session.commit()
            return redirect(url_for('category', id=category_id))
    return redirect(url_for('category', id=1))

@app.route('/category/<int:id>')
def category(id):
    category = Category.query.get_or_404(id)
    categories = Category.query.all()
    items = category.items
    item_coordinates = [{"x": item.x_value, "y": item.y_value, "value": item.id} for item in items
                        if (item.x_value is not None and item.y_value is not None)]
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
    item = CurrentItem.query.get_or_404(id)
    category = item.category
    edited_body = request.form.get('body')

    try:
        # item exists in the database
        stock_item = StockItem.query.filter_by(body=edited_body).one()
        db.session.delete(item)
        item = CurrentItem(body=stock_item.body, category=category,
                           x_value=stock_item.x_value,y_value=stock_item.y_value)
        db.session.add(item)
        db.session.commit()
        return redirect(url_for('category', id=category.id))
    except:
        # item doesn't exist in the database, so take out the coordinates
        db.session.delete(item)
        db.session.add(CurrentItem(body=edited_body, category=category,
                                   x_value=None, y_value=None))
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
    global num_finished
    num_finished += 1
    item = CurrentItem.query.get_or_404(id)

    global current_location
    current_location = (item.x_value, item.y_value)
    print(current_location)

    category = item.category
    done_category = Category.query.get_or_404(2)
    done_item = CurrentItem(body=item.body, category=done_category)
    db.session.add(done_item)
    db.session.delete(item)
    db.session.commit()
    return redirect(url_for('category', id=category.id))

@app.route('/delete-item/<int:id>')
def del_item(id):
    item = CurrentItem.query.get_or_404(id)
    category = item.category
    if item is None:
        return redirect(url_for('category', id=1))
    db.session.delete(item)
    db.session.commit()
    if category == 1:
        global num_unfinished
        num_unfinished -= 1
    else:
        global num_finished
        num_finished -= 1
    return redirect(url_for('category', id=category.id))

@app.route('/delete-category/<int:id>')
def del_category(id):
    category = Category.query.get_or_404(id)
    if category is None or id in [1, 2]:
        return redirect(url_for('category', id=1))
    db.session.delete(category)
    db.session.commit()
    return redirect(url_for('category', id=1))

def greedy_algorithm(points, start=None):
    if start is None:
        start = points[0]
    must_visit = points
    path = [start]
    must_visit.remove(start)
    while must_visit:
        nearest = min(must_visit, key=lambda x: euclidean_distance(path[-1], x))
        path.append(nearest)
        must_visit.remove(nearest)
    return path

def euclidean_distance(first_point, second_point):
    return ((first_point.x_value - second_point.x_value)**2 + (first_point.y_value - second_point.y_value)**2) ** 0.5

if __name__ == '__main__':
    # init_db()
    app.run()
