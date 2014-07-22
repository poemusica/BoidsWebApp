#from app import db
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import create_engine
from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Text
from sqlalchemy.orm import relationship, backref
from sqlalchemy.orm import sessionmaker, scoped_session
from sqlalchemy.ext.declarative import declarative_base

# TODO: Create a database
ENGINE = create_engine('postgresql://localhost:5432/boids', echo=False)
session = scoped_session(sessionmaker(bind=ENGINE,
                                       autocommit=False,
                                       autoflush=False))
Base = declarative_base()
Base.query = session.query_property

### Class declarations go here
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key = True)
    name = Column(String(64), nullable = True)


class Image(Base):
    __tablename__ = "images"
    id = Column(Integer, primary_key = True)
    user_id = Column(Integer, ForeignKey ('users.id'))
    description = Column(Text, nullable = False) # Should this be type Text?
    image_key = Column(String(64), nullable=False)

    user = relationship("User", 
        backref=backref("images", order_by=id))

### End class declarations

def main():
    global Base
    Base.metadata.create_all(ENGINE)


if __name__ == "__main__":
    main()


