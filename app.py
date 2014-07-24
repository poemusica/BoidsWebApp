import base64
import hashlib

from flask import Flask, request, session, render_template, g, redirect, url_for, flash
from flask.ext.sqlalchemy import SQLAlchemy

import os
from werkzeug.utils import secure_filename

import model
import jinja2


ALLOWED_EXTENSIONS = set(['png'])

app = Flask(__name__)
app.secret_key = 'SECRETSAUCE'
app.jinja_env.undefined = jinja2.StrictUndefined
app.config['UPLOAD_FOLDER'] = '/static/img'

# TODO: Create a database (I don't need this stuff?...yet?)
#app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://localhost:5432/boids'
#db = SQLAlchemy(app)


@app.route("/", methods=['GET'])
def index():
	"""This is the landing page.""" 
	return render_template("index.html")


def allowed_file(filename):
	return '.' in filename and \
		filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

@app.route("/postdata", methods=['POST'])
def postdata():
	print request.form
	header, image_data = request.form['image'].split(",")
	if image_data:
		png = base64.decodestring(image_data)
		hasher = hashlib.md5()
		hasher.update(png)
		filename = hasher.hexdigest() + ".png"
		filepath = "captures/" + filename
		f = open(filepath, "w")
		f.write(png)
		f.close()
	return "foo" # debug line.

# def save_image():
# 	file = request.files['file']
# 	if file and allowed_file(file.filename):
# 		filename = secure_filename(file.filename)
# 		file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
# 		return redirect(url_for('uploaded_file', filename=filename))
# 	return "file not found or not allowed."


# TODO: permalinks
#@app.route("/gallery/<int:id>")

# TODO: gallery page
#@app.route("/gallery")

if __name__ == "__main__":
	app.run(debug=True)
