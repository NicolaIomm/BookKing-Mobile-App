import flask
from flask import Flask, render_template, send_from_directory, request
import firebase_admin
import pyrebase
import json
from firebase_admin import credentials, auth
from firebase_admin import firestore
from functools import wraps
from math import sin, cos, sqrt, atan2, radians
import os

# Use a service account
my_dir = os.path.dirname(__file__)
cred_path = os.path.join(my_dir, 'credential.json')
gservice_path = json_file_path = os.path.join(my_dir, 'google-services.json')
cred = credentials.Certificate(cred_path)
firebase_admin.initialize_app(cred)
db = firestore.client()
pb = pyrebase.initialize_app(json.load(open(gservice_path)))

app = Flask(__name__)

def distance(lat1, lat2, lon1, lon2):

	R = 6373.0
	lat1 = radians(float(lat1))
	lon1 = radians(float(lon1))
	lat2 = radians(float(lat2))
	lon2 = radians(float(lon2))

	dlon = lon2 - lon1
	dlat = lat2 - lat1

	a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
	c = 2 * atan2(sqrt(a), sqrt(1 - a))


	distance = R * c
	return distance


def check_token(f):
    @wraps(f)
    def wrap(*args,**kwargs):
        if not request.headers.get('authorization'):
            return {'message': 'No token provided'},400
        try:
            user = auth.verify_id_token(request.headers['authorization'])
            request.user = user
        except:
            return {'message':'Invalid token provided.'},400
        return f(*args, **kwargs)
    return wrap


@app.route('/token')
def token():
    email = request.args.get('email')
    password = request.args.get('password')
    try:
        user = pb.auth().sign_in_with_email_and_password(email, password)
        jwt = user['idToken']
        return {'token': jwt}, 200
    except:
        return {'message': 'There was an error logging in'},400



@app.route('/')
def home():
	return '<h2>Hello from bookking!</h2><p>/signup</p><p>/books GET</p><p>/books/create POST</p><p>/books/delete POST</p>'


@app.route('/signup')
def signup():
    email = request.form.get('email')
    password = request.form.get('password')
    if email is None or password is None:
        return {'message': 'Error missing email or password'},400
    try:
        user = auth.create_user(
               email=email,
               password=password
        )
        return {'message': f'Successfully created user {user.uid}'},200
    except:
        return {'message': 'Error creating user'},400



@app.route('/books',  methods=['GET', 'POST'])
def books():

	author = request.args.get('author', default = '', type = str)
	title = request.args.get('title', default = '', type = str)
	genere = request.args.get('genere', default = '', type = str)
	lat = request.args.get('lat', default = '', type = str)
	lon = request.args.get('lon', default = '', type = str)
	order = request.args.get('order', default = '', type = str)

	books = db.collection(u'books').stream()

	result = []
	for b in books:
		book = b.to_dict()
		book['id'] = b.id

		if book['title'].startswith(title) and book['author'].startswith(author) and book['genere'].startswith(genere):
			result.append(book)

		if lat != '' and lon != '':
			book['distance'] = distance(lat, book['lat'], lon, book['long'])
			result = sorted(result, key=lambda k: k['distance'])
		else:
			book['distance'] = 9999999

	return str(result)


@app.route('/books/create', methods=['POST'])
@check_token
def newbook():

	decoded_token = auth.verify_id_token(request.headers.get('authorization'))
	uid = decoded_token['uid']
	print(uid)

	data = request.form
	author = data['author']
	title = data['title']
	year = data['year']
	genere = data['genere']
	lat = data['lat']
	lon = data['lon']
	ISBN = data['ISBN']

	book = db.collection(u'books').document()
	book.set({
		u'title' : title,
		u'author' : author,
		u'year' : year,
		u'genere' : genere,
		u'ISBN': ISBN,
		u'lat' : lat,
		u'lon' : lon,
		u'userid' : uid
		})

	return '200'


@app.route('/mybooks', methods=['GET'])
@check_token
def mybooks():

	decoded_token = auth.verify_id_token(request.headers.get('authorization'))
	uid = decoded_token['uid']

	books = db.collection(u'books').stream()

	result = []
	for b in books:
		b = b.to_dict()
		if b['userid'] == uid:
			result.append(b)

	return result



@app.route('/transactions/propose')
@check_token
def propose():

	decoded_token = auth.verify_id_token(request.headers.get('authorization'))
	uid = decoded_token['uid']

	bookproposer = request.args.get('bookproposer', default = '', type = str)
	bookreciver = request.args.get('bookreciver', default = '', type = str)

	uidreciver = db.collection('books').document(bookreciver).to_dict()['uid']

	transaction = db.collection('transaction').document()
	transaction.set({
		'bookproposer' : bookproposer,
		'bookreciver' : bookreciver,
		'uidproposer' : uid,
		'uidreciver' : uidreciver,
		'state' : 'pending',
		})

	return '200'