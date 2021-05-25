# Project Overview

![alt tag](https://github.com/poemusica/BoidsWebApp/blob/master/static/assets/readme_screenshot.PNG?raw=true)

‘Ambient Garden Thriller’ (AGT) is an interactive ambient web experience powered by Processing.js and HTML5. This web app allows users to discover and document the unique ephemeral 2D creatures that inhabit their browser. The appearance, desires, and locomotion of these lifeforms as well as their habitats within the canvas are algorithmically generated with a dash of patterned randomness. Features include an implementation of emergent flocking, scatter/swarm responsive behaviors, and perlin flow fields. Visitors can take snapshots of their discoveries and explore the gallery to view the glimpses of creatures that they and others have observed.

#Technology
Flask, Jinja2, Postgres, SQLAlchemy, Processing.js, JQuery, AJAX, Bootstrap, HTML5, CSS3. 

Languages: Python, Javascript, Processing (Java-like). 

# Features

## Art
Written in Processing (a Java-like language). Compiled to Javascript for the web using Processing.js.
* Creatures (Boids)
  * Emergent Flocking (a la Craig Reynolds and Daniel Shiffman): Individual creatures obey principles of separation, alignment, cohesion. The resulting pattern that emerges at the group level resembles flocking formations found in nature.
  * Scatter/swarm responsive behaviors
  * Perlin noise-based coloration: Creatures are uniquely colored, but within a flock coloration is similar.
* Particles
  * Flow field: Particles follow a flow field generated using Perlin noise.
* Background art
  * Creature 'habitats' are generated using perlin noise to simulate a topology map. 

## Web App
Written in Python and Javascript. Powered by Flask, Jinja2, and Postgres.
* Canvas snapshots: Users can take snapshots of the canvas. Snapshots are sent to the server using AJAX and saved locally as jpgs. References to snapshots are saved in a Postgres database.
* 'Smart' form: The form used to submit snapshots along with textual data remembers relevant form field information and auto-populates the form based on the previous post using a session cookie. 
* Gallery: Users can browse the gallery of recently submitted snapshots.
* Permalinks: Permalink pages are created for each unique user-invented 'discoverer' and 'species'. 

# Future Work

## Art
* Patch for proper trails in screen wrap (no walls) mode.
* Make background 'habitat' represent terrain altitude and vary creatures’ speed according to steepness.

## App 
* Search feature: Make gallery submissions searchable by 'discoverer' and 'species'. 
* File hosting: Save files to S3 or similar hosting service instead of directly to the server.
