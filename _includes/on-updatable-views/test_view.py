from sqlalchemy import create_engine, MetaData
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session
from sqlalchemy import Column, Integer, String, DateTime
import sqlalchemy.types as types

Base = declarative_base(metadata=MetaData())


# I try to include all complementary tricks
# that I think could be useful in this pattern
# so here is parsing of composite array types
# which psycopg2 and SQLAlchemy do not support from the box
class TupleArrayType(types.TypeDecorator):
    """
    Parses in and out the array of
    the following format: {"(a,b)", ...}
    """
    impl = types.String

    # customization point
    fields = ()

    # dummy method to be rewritten in descendants
    # should return proper model instance
    def create_result_object(self, *args):
        raise NotImplementedError

    def process_bind_param(self, value, dialect):
        print value
        return ('{' +
                ','.join(
                    [''.join(('"(',
                              ','.join([str(getattr(item, f) or '')
                                        for f in self.fields]),
                              ')"'))
                        for item in value]
                    )
                + '}')

    def process_result_value(self, value, dialect):
        for symbol in '{}"()':
            value = value.replace(symbol, '')
        if value:
            # from Python Standard Library documentation:
            # The left-to-right evaluation order of the iterables is guaranteed
            # This makes possible an idiom for clustering a data series
            # into n-length groups using zip(*[iter(s)]*n)
            return [self.create_result_object(*args) for args
                    in zip(*[iter(value.split(','))]*len(self.fields))]
        else:
            return []


class ProvidedService(object):
    __slots__ = ['service', 'sla']

    def __init__(self, service, sla):
        self.service = service
        self.sla = sla

    def __repr__(self):
        return u'<Service {0} under {1} SLA level>'\
               .format(self.service, self.sla)


class ProvidedServiceArrayType(TupleArrayType):
    fields = ProvidedService.__slots__

    def create_result_object(self, service, sla):
        return ProvidedService(service, sla)


# notice that in table definition you use just simple columns
class Account(Base):
    __tablename__ = 'account'
    __table_args__ = {'schema': 'model'}

    id = Column(Integer, primary_key=True)
    name = Column(String)
    services = Column(ProvidedServiceArrayType)
    registered = Column(DateTime(timezone=True))


def main():
    engine = create_engine('postgresql+psycopg2://jamert:pass@127.0.0.1/db')
    Session = scoped_session(sessionmaker(bind=engine))
    db = Session()

    # checking that modifications to our object goes smoothly
    bb_acc = db.query(Account)\
               .filter(Account.name == 'Blue Beard')\
               .first()
    print 'before:', bb_acc.services
    # because there is no way to SQLAlchemy to know that
    # list is changed if we use 'append' method
    # to update 'services' field we need to provide new object
    bb_acc.services = [ProvidedService('basement', 'normal')]
    db.commit()
    print 'after:', bb_acc.services

    # checking that creation of new objects goes smoothly
    franky = Account(name='Mr. Frankenstain',
                     services=[ProvidedService('basement', 'normal')])
    db.add(franky)
    # remember that I said about setting NEW.id in model.account_insert?
    # if you remove that code from procedure
    # you'll get FlushError here,
    # because SQLAlchemy cannot get primary id of record
    db.commit()
    print 'franky: id {0}, services {1}'.format(franky.id, franky.services)


if __name__ == '__main__':
    main()

