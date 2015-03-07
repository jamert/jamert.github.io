---
layout: post
title: On Choosing Libraries
---
# Foreword

Intitial idea of this post was selection/comparison of different AMQP client libraries for Python in conjunction
with different asyncronous ioloop libraries. In year or so of using pika + tornado I've grown displeased with
pika.

Different people choose libraries they use based on different criteria. But, I think, from library programmer generally
wants two things - suitability for concrete task and enough documentation to complete task in suitable manner.


This post written in search for better python library for working with AMQP in general (and RabbitMQ in particular).
While examples on RabbitMQ official site use pika as their library of choice, my experience with it was far from
pleasant. May be I've done something stupid, but in year of using pika I've encountered: random bugs in message
serialization in conjunction with pickle, dropping connections with server due to non-atomic sending of headers,
introducing bug when fixing another bug, different behaviour on BSD and Linux systems (no etc because that was all). I
presume that library author was too ambitious to support nearly all ioloop implementations and couldn't make it.

# Candidates

In category 'AMQP libraries':

- pyampq/librabbitmq
- haigha
- stormed-amqp


In category 'IO-Loop':

- Tornado
- libevent
- gevent
- eventlet
- trollius
- pulsar

