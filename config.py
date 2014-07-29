# hello, this is a file that I wrote in order to develop on multiple platforms
# ubuntu/mac vs. windows 8
# it specifies the postgres port information for each platform
# import this file into model.py and use the appropriate variable when creating the engine


# on mac/ubuntu use
unixpath = 'postgresql:///boid'

# on windows 8 use
win8path = 'postgresql://postgres:postgres@localhost/boid'

