---
layout: post
title: On reading code
subtitle: This is really slow
---

There are probably light in the end of tunnel
=============================================

I've got into hard task on my job recently: describe big internal system, which nobody
in company understands. We all know high level concepts and the system ultimately works,
but nitty-gritty details are documented in form of Chef recipes and Perl scripts.
I've decided to document my struggles with this task here.


Day One
-------

I've attacked issue in peripathetic manner (or it seems so) - I just listed
all recipes in Chef role, picked relevant to system and began to write description
to each. This was very tiring, despite small output. Several artefacts are tied
together in intangible mess. Many of recipes were very long, but instead of skimming
through I was constantly caught up in tries to get all details from first try.

I was dissappointed in my efficiency, so I decided to find some tactics in internet
wisdom, but found almost nothing (helpful link http://www.gigamonkeys.com/code-reading/)


Day Two
-------

I've skimmed through chapter of 'Working Effectively with Legacy Code' and found
three useful techniques for understanding code: sketching, scratch refactoring and
deleting unused code (there also listing markup, but it is unusable for my system,
I think). And one technique I got by thinking (gasp): tracing from known aspects of
system. To be more specific: I know that system sends own state to central server
when something breaks, so I can find that call, because I know for sure how it's
done and then, piece by piece follow that lead to configuration. While this get
me understanding of only one feature, it is huge step to understanding whole system,
because, well, features are done in similar way, typically.

In practice, I was able to delete about 1500 lines of unused code, before I was interrupted,
so I have to continue next time.

