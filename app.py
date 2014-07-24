import base64
import hashlib

from flask import Flask, request, session, render_template, g, redirect, url_for, flash, send_file
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

# landing page
@app.route("/", methods=['GET'])
def index():
	"""This is the landing page.""" 
	return render_template("index.html")

# post data from form
@app.route("/postdata", methods=['POST'])
def postdata():
	print request.form # debug line.
	user = request.form['discoverer']
	title = request.form['title']
	description = request.form['description']
	filename = save_image(request.form['image'])
	formdata = {'user': user, 'title': title, 'description': description, 'filename': filename}
	if commit_data(formdata):
		image = model.session.query(model.Image).filter_by(filename=filename).first()
		return redirect("/gallery/%s" % image.id)

	# if filename:
	# 	return ",".join([user, title, description, filename])
	else:
		return "sry, no data 4 u." # debug line.

# save data to databse
def commit_data(data):
	user = data['user']
	title = data['title']
	description = data['description']
	filename = data['filename']

	if not user:
		user = 'anonymous'
	if not title:
		title = 'unnamed'
	if not description:
		description = 'little is known about these specimens'

	u_exists = model.session.query(model.User).filter_by(name=user).first()
	print u_exists
	if not u_exists:
		print "user does not exist."
		u_exists = model.User(name=user)
		model.session.add(u_exists)
		model.session.commit()
	
	if hasattr(u_exists, "id"):
		i = model.Image(filename=filename, user_id = u_exists.id)
		model.session.add(i)
		model.session.commit()

		if not hasattr(i, "id"):
			return False

		m = model.ImageMetaData(title=title, description=description, image_id=i.id)
		model.session.add(m)
		model.session.commit()

		if not hasattr(m, "id"):
			return False

	else:
		return False

	return True

# save png locally to web server
def save_image(raw_data):
	header, image_data = raw_data.split(",")
	if image_data:
		png = base64.decodestring(image_data)
		hasher = hashlib.md5()
		hasher.update(png)
		filename = hasher.hexdigest()
		filepath = "captures/" + filename + ".png"
		f = open(filepath, "w")
		f.write(png)
		f.close()
		return filename
	else:
		return None

# workaround for serving files from somewhere other than static
@app.route("/captures/<filename>")
def serve_image(filename):
	f = open('captures/%s'%filename)
	print dir(f)
	return send_file(f, mimetype="image/png")

# gallery item permalinks
@app.route("/gallery/<id>")
def permalink(id):
	image = model.session.query(model.Image).filter_by(id=id).first()
	return render_template("image_details.html", display_image=image)

# TODO: gallery page
@app.route("/gallery")
def gallery():
	image_list = model.session.query(model.Image).limit(20).all()
	return render_template("gallery.html", images=image_list)

if __name__ == "__main__":
	app.run(debug=True)
