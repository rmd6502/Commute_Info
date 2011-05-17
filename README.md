# SUMMARY
This is a Rails project to attempt to do something useful with GTFS data.  
The questions you should be able to answer are:

1. What stations are nearby?
1. What are the times for the next trains leaving from (station)?
1. How do I get from (point A) to (point B)?


Routing is done with a messy A* algorithm.  It's pretty slow - I suspect most of the 
problem is due to my data structures imposing 
higher big-O on my access to frequently needed data.  Also, 
I'm guessing a poor choice of indexes for my data - playing with that now.

The GTFS Spec is at 
http://code.google.com/transit/spec/transit_feed_specification.html

# HISTORY
It's based on Andy Atkinson's gtfs-helper project, but I rewrote it sufficiently
that I decided not to fork, but just start over.  He's at 
https://github.com/andyatkinson

# LICENSE
This project is licensed under the MIT License, viewable at 
http://www.opensource.org/licenses/mit-license

Copyright (c) 2011 Robert M. Diamond.  All Rights Reserved.
