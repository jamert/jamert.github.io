---
layout: post
title: On Reading Code
subtitle: This is really slow
tags:
  - abstract
---

I've got into hard task on my job recently: to describe big internal system, which nobody
in company understands. We all know high level concepts and the system ultimately works,
but nitty-gritty details are documented in form of Chef recipes and Perl scripts.
I've decided to document my struggles with this task here.


## Day 1-6

I've attacked issue in peripatetic manner (or it seems so) - I just listed
all recipes in Chef role, picked relevant to system and began to write description
to each. This was very tiring, despite small output. Several artifacts are tied
together in intangible mess. Many of recipes were very long, but instead of skimming
through I was constantly caught up in tries to get all details from first try.

I was disappointed in my efficiency, so I've decided
to find some tactics on Internet (and document my search in this blog post)
but found almost nothing (helpful link http://www.gigamonkeys.com/code-reading/).


## Day 7

I've skimmed through chapter of 'Working Effectively with Legacy Code' and found
three useful techniques for understanding code: sketching, scratch refactoring and
deleting unused code (there also listing markup, but it is unusable for my system,
I think). And one technique I got by thinking (gasp): tracing from known aspects of
system. To be more specific: I know that system sends own state to central server
when something breaks, so I can find that call, because I know for sure how it's
done and then, piece by piece follow that lead to configuration. While this got
me understanding of only one feature, it is huge step to understanding the whole system,
because, well, features are done in similar way, typically.

In practice, I was able to delete about 1500 lines of unused code, before I was interrupted,
so I have to continue next time.


## Day 8

What I found (and I was not first) is that deleting unused code is very satisfying
(unless it's your code, of course).

Tracing technique was pretty helpful (together with sketching). I was able to trace
one scenario to about 70 percent completion. One thought occurred to me, that
existing system can be sliced up to use cases, like in development process.
I've identified at least four such use cases / scenarios. At least, I can measure progress
to end of the task.


## Days 9-10

What I thought was remaining 30 percent of scenario, was just another big block
of logic which I did not recognize as something complex. Fortunately, I could
use the same tracing technique but from two other points. To lower abstraction
level a bit, let's say that system under analysis is content routing engine
based on several nagios instances, connected to other systems in different ways.
Scenario was removing all services on one node from DNS server when bandwidth
exceeds some predefined value. First, I traced system from call to external service with
new service status, it got me half the way to understanding scenario. Other half
was covered by searching on DNS updating and bandwidth check.

After I got high level scenario in my head, I could read any script related to it and
relatively easy understand small details.


## Conclusion

After several days of brute force code reading I was frustrated enough to think
about ways to do work intelligently and effectively. And what surprising,
it actually worked.

### tl;dr

If you want to understand some huge chunk of code, try to trace from
existing chunks of knowledge until you hit some block and repeat same process,
until you get high level picture.
