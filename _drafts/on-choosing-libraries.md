---
layout: post
title: On Choosing Libraries
subtitle: How could I be so stupid
---
# Foreword

Initial idea of this post was selection/comparison of different AMQP client libraries for Python in conjunction
with different asynchronous ioloop libraries. In year or so of using pika + tornado I've grown displeased with
pika.


# Theory (aka ramblings)

Different people choose libraries they use based on different criteria. But I think from library programmer generally
wants two things - enough features for executing specific task and enough information to enable programmer use it.
Yes, there also some factors such as popularity, working maintainer, or better - group of maintainers, unit and
functional tests etc., but those are not important, when application is working. Thing that last group of factors
all have is visibility. If we could be sure of workability of library just by looking at it - it wouldn't be so hard.
Then all good libraries would be popular :) Let's go all baesian here.

Those two things - workability and explorability - are not actually visible.
We can look at tangible facts.

My first bet probably will be feature list in readme file, assuming library actually has documentation.
When impact of library on architecture of your application is small, this is enough.

If I expect that library will take significant role in application, then I want to have more guarantees.
I want to ensure that library actually has maintainer, which can be easily looked up by time of last
closed issue, better if more than one person maintains it - it probably means that it is really popular
and you may not look further.
Number of issues is one thing, but recurring issues - another. It kinda feels that author doesn't know
what he's doing. But that demands careful reading of issues in bug tracker. Bad signs also memory leaks
and spontaneous eating of all processor time.
We can look at size of community (judging by number of people at IRC channel, number of messages in mailing list,
questions and answers on Stack Overflow). Size of community provide only tangible insurance, I think.

Last level of paranoia is when library defines much of architecture, like selection of web framework, for example.
Here I think you should actually read the source with purpose to estimate if you can understand what happens on
lower level. You can see code smells and dirty hacks. It feels like you know author better after that (which is
wrong, actually, but it is illusion on understanding what counts). And scan through content on of mailing list,
to see where people get it wrong.

Suspicious for me also bloated scope of library, like supporting many different backends
or concurrency styles. How do I say this. When you write software for yourself and it doesn't use
most of code - this code tend to be not best quality.

I have prejudice against clone projects aka "let's rewrite this cool lib from ruby to python".
I cannot remember such projects being actually widely used. And it's kinda feels like plagiarism.
But it should be proven through examples before commiting to such ambitious statements.


# Practice

This post written in search for better python library for working with AMQP in general (and RabbitMQ in particular).
While examples on RabbitMQ official site use pika as their library of choice, my experience with it was far from
pleasant. May be I've done something stupid, but in year of using pika I've encountered: random bugs in message
serialization in conjunction with pickle, dropping connections with server due to non-atomic sending of headers,
introducing bug when fixing another bug, different behaviour on BSD and Linux systems (no etc. because that was all). I
presume that library author was too ambitious to support nearly all ioloop implementations and couldn't make it.

