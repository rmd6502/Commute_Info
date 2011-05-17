This is a Rails project to attempt to do something useful with GTFS data.  The questions you should be able to answer are:
<nl>
<li>  What stations are nearby?</li>
<li>  What are the times for the next trains leaving from (station)?</li>
<li>  How do I get from (point A) to (point B)?</li>
</nl>

Routing is done with a messy A* algorithm.  I suspect most of the problem is due to my data structures imposing higher big-O on my access to frequently 
needed data.

The GTFS Spec is at http://code.google.com/transit/spec/transit_feed_specification.html#stops_txt___Field_Definitions

It's based on Andy Atkinson's gtfs-helper project, but I rewrote it sufficiently that I decided not to fork, but just start over.  He's at 
https://github.com/andyatkinson

This project is licensed under the MIT License, viewable at http://www.opensource.org/licenses/mit-license
