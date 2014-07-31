import base64
import hashlib

from flask import Flask, request, render_template, send_file

import model
import jinja2

app = Flask(__name__)
app.jinja_env.undefined = jinja2.StrictUndefined



# landing page
@app.route("/", methods=['GET'])
def index():
	"""This is the landing page.""" 
	return render_template("index.html")

# post data from form
@app.route("/getform", methods=['GET'])
def getform():
	return render_template("_form_content.html")


# post data from form
@app.route("/postdata", methods=['POST'])
def postdata():
	user = request.form['discoverer']
	title = request.form['title']
	description = request.form['description']
	filename = save_image(request.form['image'])
	formdata = {'user': user, 'title': title, 'description': description, 'filename': filename}
	if commit_data(formdata):
		image = model.session.query(model.Image).filter_by(filename=filename).first()
		host = request.host
		return render_template("_save_confirmation.html", image_id=image.id, hostname=host)
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
	if not u_exists:
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

# save jpg locally to web server
def save_image(raw_data):
	header, image_data = raw_data.split(",")
	if image_data:
		jpg = base64.decodestring(image_data)
		hasher = hashlib.md5()
		hasher.update(jpg)
		filename = hasher.hexdigest()
		filepath = "captures/" + filename + ".jpg"
		f = open(filepath, "wb")
		f.write(jpg)
		f.close()
		return filename
	else:
		return None

# workaround for serving files from somewhere other than static
@app.route("/captures/<filename>")
def serve_image(filename):
	f = open('captures/%s'%filename, 'rb')
	return send_file(f, mimetype="image/jpeg")

# gallery item permalinks
@app.route("/gallery/<id>")
def permalink(id):
	image = model.session.query(model.Image).filter_by(id=id).first()
	return render_template("image_details.html", display_image=image)

# gallery page
@app.route("/gallery")
def gallery():
	image_list = model.session.query(model.Image).order_by(model.Image.id.desc()).limit(60).all()
	return render_template("gallery.html", images=image_list)


if __name__ == "__main__":
	app.run(debug=True, host='0.0.0.0', port=80) #changed to port 80 for AWS web server
