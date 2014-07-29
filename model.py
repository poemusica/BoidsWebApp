from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import create_engine
from sqlalchemy import Column, Integer, String, ForeignKey, Text
from sqlalchemy.orm import relationship, backref
from sqlalchemy.orm import sessionmaker, scoped_session


ENGINE = create_engine('postgresql:///boid', echo=False)
session = scoped_session(sessionmaker(bind=ENGINE,
                                       autocommit=False,
                                       autoflush=False))
Base = declarative_base()
Base.query = session.query_property

### Classes: Table Definitions ###

# users to images is one-to-many
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key = True)
    name = Column(String(64), nullable = True, unique=True) # Ensure this is unique?

# imagemetadata to images is one-to-one
class ImageMetaData(Base):
    __tablename__ = "imagemetadata"
    id = Column(Integer, primary_key = True)
    title = Column(String(64), nullable = True)
    description = Column(Text, nullable = False) # Should this be type Text?
    image_id = Column(Integer, ForeignKey('images.id'))

class Image(Base):
    __tablename__ = "images"
    id = Column(Integer, primary_key = True)
    filename = Column(String(64), nullable=False)
    user_id = Column(Integer, ForeignKey ('users.id'))

    user = relationship("User", 
        backref=backref("images", order_by=id))

    imagemetadata = relationship("ImageMetaData",
        uselist = False,
        backref="images")

### End Classes ###

def main():
    global Base
    Base.metadata.create_all(ENGINE)


if __name__ == "__main__":
    main()


