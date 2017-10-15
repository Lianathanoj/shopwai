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
next_location = entrance
num_unfinished = 0
num_finished = 0
points = None

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
    #file = open("product-info.txt", "r", encoding="utf-8")
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
    print('hi')
    if request.method == 'POST':
        body = request.form.get('item')
        # category_id = request.form.get('category')
        category_id = 1
        category = Category.query.get_or_404(category_id)
        # print(unicode(body.decode('utf-8').lower().encode('utf-8')), 'utf-8')
        # item = Item.query.filter(Item.body == unicode(body.decode('utf-8').lower().encode('utf-8')), 'utf-8')
        # item = Item.query.all()
        # print(item)
        # if item is None:
        # item = Item(body=body, category=category)

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
            global points
            global next_location
            current_items = CurrentItem.query.all()
            current_items = [item for item in current_items if item.category_id == 1]
            print('current items')
            print([item.body for item in current_items if item.category_id == 1])
            if len([item for item in current_items if item.category_id == 1]) > 1:
                current_items = sorted(current_items, key=lambda x: euclidean_distance_point(current_location, x))
                print([item.body for item in current_items])
                ordered_items = [(current_item.body, current_item.category, current_item.x_value, current_item.y_value)
                                 for current_item in greedy_algorithm(current_items)]
                db.session.query(CurrentItem).delete()
                ordered_items = [CurrentItem(body=ordered_item[0], category=ordered_item[1], x_value=ordered_item[2],
                                             y_value=ordered_item[3]) for ordered_item in ordered_items]
                # print([item.body for item in ordered_items])
                db.session.add_all(ordered_items)
                db.session.commit()
                next_location = (ordered_items[0].x_value, ordered_items[0].y_value)
                print('next location')
                print(next_location)
                points = find_coordinates_between_points(current_location, next_location)
            else:
                print('im here')
                points = find_coordinates_between_points(current_location, (current_items[0].x_value, current_items[0].y_value))
            return redirect(url_for('category', id=category_id))
    return redirect(url_for('category', id=1, points=None))

@app.route('/category/<int:id>')
def category(id):
    category = Category.query.get_or_404(id)
    categories = Category.query.all()
    items = category.items
    item_coordinates = [{"x": item.x_value, "y": item.y_value, "value": item.id} for item in items
                        if (item.x_value is not None and item.y_value is not None)]
    return render_template('index.html', items=items, item_coordinates=item_coordinates,
                           categories=categories, category_now=category, points=points)

# @app.route('/new-category', methods=['GET', 'POST'])
# def new_category():
#     name = request.form.get('name')
#     category = Category(name=name)
#     db.session.add(category)
#     db.session.commit()
#     return redirect(url_for('category', id=category.id))

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

# @app.route('/edit-category/<int:id>', methods=['GET', 'POST'])
# def edit_category(id):
#     category = Category.query.get_or_404(id)
#     category.name = request.form.get('name')
#     db.session.add(category)
#     db.session.commit()
#     return redirect(url_for('category', id=category.id))

@app.route('/done/<int:id>', methods=['GET', 'POST'])
def done(id):
    global num_finished
    num_finished += 1
    item = CurrentItem.query.get_or_404(id)

    global current_location
    current_location = (item.x_value, item.y_value)

    category = item.category
    done_category = Category.query.get_or_404(2)
    done_item = CurrentItem(body=item.body, category=done_category)
    db.session.add(done_item)
    db.session.delete(item)
    db.session.commit()

    global points
    global next_location
    current_items = CurrentItem.query.all()
    current_items = [item for item in current_items if item.category_id == 1]
    print('current items')
    print([item.body for item in current_items if item.category_id == 1])

    # once you remove an item from the list and there is more than one item, sort the closest items and set next location as the closest one
    if len([item for item in current_items if item.category_id == 1]) > 1:
        current_items_sorted = sorted(current_items, key=lambda x: euclidean_distance_point(current_location, x))
        next_location = (current_items_sorted[0].x_value, current_items_sorted[0].y_value)
    # if you remove an item and have one item, choose that item
    elif len([item for item in current_items if item.category_id == 1]) == 1:
        next_location = (current_items[0].x_value, current_items[0].y_value)
    # if there are no more items, the next location is the exit
    else:
        next_location = exit
    points = find_coordinates_between_points(current_location, next_location)
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

# @app.route('/delete-category/<int:id>')
# def del_category(id):
#     category = Category.query.get_or_404(id)
#     if category is None or id in [1, 2]:
#         return redirect(url_for('category', id=1))
#     db.session.delete(category)
#     db.session.commit()
#     return redirect(url_for('category', id=1))

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

def euclidean_distance_point(first_point, second_point):
    return ((first_point[0] - second_point.x_value)**2 + (first_point[1] - second_point.y_value)**2) ** 0.5

def euclidean_distance(first_point, second_point):
    return ((first_point.x_value - second_point.x_value)**2 + (first_point.y_value - second_point.y_value)**2) ** 0.5

# y = mx + b
def find_coordinates_between_points(first_point, second_point):
    print("first point")
    print(first_point)
    print("second point")
    print(second_point)
    if (second_point[0] - first_point[0] != 0):
        slope = (second_point[1] - first_point[1]) / (second_point[0] - first_point[0])
        y_intercept = first_point[1] - slope * first_point[0]
        coordinates = []
        for x_value in range(min(first_point[0], second_point[0]), max(first_point[0], second_point[0])):
            coordinates.append({"x": x_value, "y": slope * x_value + y_intercept})
    else:
        coordinates = find_coordinates_between_points(current_location, exit)
    return coordinates

if __name__ == '__main__':
    # init_db()
    app.run()
