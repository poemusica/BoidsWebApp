import base64
import hashlib

from flask import Flask, request, render_template, send_file, session, g

import model
import jinja2

app = Flask(__name__)
app.config.update(
    DEBUG=True,
    SECRET_KEY='\xf5!\x07!qj\xa4\x08\xc6\xf8\n\x8a\x95m\xe2\x04g\xbb\x98|U\xa2f\x03', # for session
    SESSION_COOKIE_HTTPONLY = False
)

app.jinja_env.undefined = jinja2.StrictUndefined


@app.before_request
def setup_session():
	session['img_data'] = session.get('img_data', {'title_id': None, 'title': None, 'user': None})

# landing page
@app.route("/", methods=['GET'])
def index():
	"""This is the landing page."""
	session['img_data']['title_id'] = None
	session['img_data']['title'] = None#{'title_id': None, 'title': None, 'user': None}
	session['img_data']['user'] = session['img_data'].get('user', None)
	return render_template("index.html")

# post data from form
@app.route("/getform", methods=['GET'])
def getform():
	template_vales = { 'user': session['img_data']['user'], 'title': None }
	if session['img_data'].get('title_id'):
		image = model.session.query(model.Image).filter_by(id=session['img_data']['title_id']).first()
		if image.user.name != 'anonymous':
			template_vales['user'] = image.user.name
		if image.imagemetadata.title != '':
			template_vales['title'] = image.imagemetadata.title
	return render_template("_form_content.html", **template_vales)


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
		session['img_data']['title_id'] = image.id
		session['img_data']['title'] = image.imagemetadata.title
		if image.user.name == 'anonymous':
			session['img_data']['user'] = None
		else:
			session['img_data']['user'] = image.user.name
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
		title = ''
	if not description:
		description = ''

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

def model_to_list(model_list):
	result = []
	for entry in model_list:
		default_title = "unnamed"
		default_description = "little is known about these specimens"
		d = {	'id': entry.image_id,
				'title': entry.title if entry.title else default_title,
				'description': entry.description if entry.description else default_description,
				'user': entry.images.user.name,
				'user_id': entry.images.user.id,
				'filename': entry.images.filename	}
		result.append(d)
	return result

# gallery item permalinks
@app.route("/gallery/<id>")
def permalink(id):
	img = model.session.query(model.ImageMetaData).filter_by(image_id=id).first()

	template_values = model_to_list([img])

	if img.title == '':
		template_values[0]['title'] = 'unnamed'

	else:
		other_imgs = model.session.query(model.ImageMetaData).filter_by(title=img.title).order_by(model.ImageMetaData.id.desc()).limit(30).all()
		other_imgs.remove(img)
		template_values.extend(model_to_list(other_imgs))

	return render_template("image_details.html", images=template_values)

# gallery page
@app.route("/gallery")
def gallery():
	image_list = model.session.query(model.ImageMetaData).order_by(model.ImageMetaData.id.desc()).limit(30).all()
	template_values = model_to_list(image_list)

	return render_template("gallery.html", images=template_values)

# gallery page
@app.route("/discoverer/<id>")
def user_page(id):
	user = model.session.query(model.User).filter_by(id=id).first()

	model_list = user.images
	image_list = []
	for i in model_list:
		image_list.append( i.imagemetadata );

	template_values = model_to_list(image_list)
		
	return render_template("user_details.html", images=template_values)
	

if __name__ == "__main__":
	app.run(debug=True, host='0.0.0.0', port=80) #changed to port 80 for AWS web server
