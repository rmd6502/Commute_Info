require 'rbtree'

# Performs A* routing
class AStar
  AVERAGE_SPEED = 13.5
  def reconstruct_path(node)
    if @came_from.has_key? node.stop_id
      return reconstruct_path(@came_from[node.stop_id]) << @methods[node.stop_id]
    else
      ret = []
      ret << @methods[node.stop_id]
      return ret;
    end
  end

  # The nominal score of a particular route.  Takes into effect travel time, wait time, and whether you rode or walked
  def score(node)
    base_t = node[:Time]
    # waiting has a 10% penalty
    if node.has_key? :WaitTime
      base_t += node[:WaitTime] * 0.1
    end
    # transferring has a 20% penalty
    if node.has_key? :StopTime
      base_t += (node[:Time] - node[:WaitTime])*0.2
    else
      # walking has a 40% penalty
      base_t += (node[:Time]) * 0.4
    end
    
    #puts "Node: #{node} score #{base_t}"
    return base_t
  end

  # The raison d'etre for this class
  def route(from_lat,from_lon,to_lat,to_lon,at_time=Time.now)
    closedSet = Set.new
    start_points = Stop.neighbor_nodes_on_foot(from_lat,from_lon,3,1.0)
    end_points = Set.new(Stop.neighbor_nodes_on_foot(to_lat,to_lon,2,1.0).collect {|n| n[1][:Stop].stop_id})
    openSet = Set.new(start_points.collect{|n| n[1][:Stop]})
    @came_from = Hash.new
    there = GeoKit::LatLng.new(to_lat, to_lon)
    f_score = MultiRBTree.new
    g_score = Hash.new
    h_score = Hash.new
    @methods = Hash.new

    start_points.each do |spnval|
      spn = spnval[1]
      sp = spn[:Stop]
      here = GeoKit::LatLng.new(sp.stop_lat, sp.stop_lon)
      sc = score(spn)
      g_score[sp.stop_id] = sc
      hsc = spn[:Time] + 3600.0 * here.distance_to(there) / AVERAGE_SPEED
      h_score[sp.stop_id] = hsc
      sc += hsc
      f_score[sc] = sp
      @methods[sp.stop_id] = spn
    end

    while openSet.length > 0
      x = nil
      f_score.each do |fkv|
        x = fkv[1]
        break if openSet.include? x
      end
      if end_points.include? x.stop_id
        @total_time = 0
        puts "found a route"
        ret = reconstruct_path(x)
        here = GeoKit::LatLng.new(x.stop_lat, x.stop_lon) 
        dist = here.distance_to(there)
        if dist > 0
          phi = here.heading_to(there)
          ratio = Math::sin(phi.radians).abs + Math::cos(phi.radians).abs
          dist *= ratio
          tm = (dist*3600/2.5)
          ret << {
            :Stop => nil,
            :WaitTime => 0,
            :Time => tm,
            :Method => "Walk #{dist.round(2)} miles to your destination"
          }
        end
        return ret
      end
      openSet.delete(x)
      closedSet.add(x)

      #puts "\n\nStop "+x.stop_name+"("+x.stop_id+")\n\nend_points #{end_points.inspect}\n\n"
      nodelist = x.neighbor_nodes(at_time+g_score[x.stop_id])
      #puts "\nNodelist "+nodelist.count.to_s
      count = 0
      nodelist.each do |nodevalue|
        node = nodevalue[1]
        #puts "Node "+node.inspect
        node_stop = node[:Stop]
        next if closedSet.find_index(node_stop) != nil
        tsc = score(node)

        tentative_g_score = g_score[x.stop_id] + tsc
        if openSet.find_index(node_stop) == nil
          openSet.add node_stop
          tentative_better = true
        elsif tentative_g_score < g_score[node_stop.stop_id]
          tentative_better = true
        else
          tentative_better = false
        end

        if tentative_better
          here = GeoKit::LatLng.new(node_stop.stop_lat, node_stop.stop_lon)
          @came_from[node_stop.stop_id] = x
          sc = tentative_g_score
          g_score[node_stop.stop_id] = sc
          phi = here.heading_to(there)
          ratio = Math::sin(phi.radians).abs + Math::cos(phi.radians).abs
          hsc = 3600.0 * here.distance_to(there) * ratio / AVERAGE_SPEED
          sc += hsc
          h_score[node_stop.stop_id] = hsc
          f_score[sc] = node_stop
          @methods[node_stop.stop_id] = node
          count = count + 1
        end
      end
      #puts "evaluated #{count} stops"
    end
    puts "No route found :-("
    return nil
  end
end
