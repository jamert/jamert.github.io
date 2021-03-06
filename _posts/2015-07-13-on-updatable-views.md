---
layout: post
title: On Updatable Views
subtitle: Let split our model
tags:
  - python
  - postgresql
---

In database courses they tell you that your data should lie in normalized tables with
foreign keys all the way down. But as application developer you want somehow to get your
data back in one semantically meaningful lump.

One way is to use ORM that will write your queries for you provided that you
describe all polygamous relationships between tables using fancy ORM syntax.
I can list actual downsides for this, but it really boils down for me to one thing:
I'd rather invest in learning SQL really good than learning ORM really good.

Other way is to make some views, and if you need to implement not
only 'R' in 'CRUD' then your view should be updatable. I am going to
use Python, PosgreSQL and SQLAlchemy with psycopg2 and present some example of updatable views
in action.


## Specification

Let's say, I am B2B 'Rent' company providing SaaS thingy of kinds 'Basement', 'Dugout' and 'Castle'
each of which can be provided under SLA with levels 'normal' or 'vip'. Also, I want to have
each client to have autogenerated numerical ID, because it would be nice to provide some ID to client,
and in that process not to show him that he is our second or third client.

I think I want to get data for each client in the following form, where `services` is a list of
tuples `(service, sla)` for each client:

{% highlight text %}
 id  |      name       |     services       |          registered
-----+-----------------+--------------------+-------------------------------
 542 | Enterprise inc. | {"(basement,vip)"} | 2015-06-29 16:33:42.258203+00
{% endhighlight %}


## Implementation

Let's write database schema to hold our data.

{% highlight sql %}
{% include on-updatable-views/normalized-schema.sql %}
{% endhighlight %}

Here we'll implement additional layer of abstractions in form of updatable view. 'Updatable' part is provided
by triggers. You can use rules for this purpose, but I wouldn't recommend it just for the reason of lessening
mental load on yourself because triggers can do all the things on which rules are capable of and more.

{% highlight sql %}
{% include on-updatable-views/updatable-view.sql %}
{% endhighlight %}

Our view now supports all modifying operations.

Let's fill our tables with some test data and make sure
our view is working as expected.

{% highlight sql %}
{% include on-updatable-views/test-data.sql %}
{% endhighlight %}

Our python code will be much more straightforward and simple due
to massive SQL line count.

{% highlight python %}
{% include on-updatable-views/test_view.py %}
{% endhighlight %}


## Reflection

After implementation, we should carefully think about what the hell we just did. Like any technique, it
has its own application area and its own downsides.

One unquestionable downside is that you need to write lots of SQL. Your SQL code is going to
be non-trivial and consequently, you'll need to test it somehow. However, testing for SQL
are not at the same level as popular turing-complete languages. Personally, I deal with it
by testing my application against real database. It is not ideal solution, but it's good enough for me.

One unquestionable bonus from this transformation is that it results in layer of nicely formatted
domain objects directly in your database. You see exactly the same data as your application code.
It helps when you need to correct data manually or to debug something.

On serious side, though, this approach is handy when you find yourself making several database
requests just to validate change in some object (for example, if your data must conform to some
complex condition for which you need to fetch data from several tables). Because SQL is executed
on database side you can save on network latency if your checks are executed here (but you may
have problem to deliver error message to user in case something is actually wrong, just something
to think about). You also have more leeway in changing underlying structure of database
provided that you save 'nice' interface intact.


## Conclusion

I advice you to try writing updatable views for your application and see for yourself if they are
to your liking. SQL is not as unpleasant as you may think and you'll deepen your relationship with
your database, which is a good thing.
