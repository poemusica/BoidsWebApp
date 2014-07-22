from flask import Flask, request, session, render_template, g, redirect, url_for, flash
from flask.ext.sqlalchemy import SQLAlchemy

import model
import jinja2


app = Flask(__name__)
app.secret_key = 'SECRETSAUCE'
app.jinja_env.undefined = jinja2.StrictUndefined

# TODO: Create a database (I don't need this stuff?...yet?)
#app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://localhost:5432/boids'
#db = SQLAlchemy(app)


@app.route("/")
def index():
    """This is the landing page.""" 
    return render_template("index.html")

if __name__ == "__main__":
    app.run(debug=True)

# TODO: permalinks
#@app.route("/gallery/<int:id>")

# TODO: gallery page
#@app.route("/gallery")

