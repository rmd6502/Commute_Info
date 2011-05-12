require 'rbtree'
class AStar
  AVERAGE_SPEED = 13.5
  def reconstruct_path(node)
    if @came_from.has_key? node
      return reconstruct_path(@came_from[node]) << @methods[node]
    else
      ret = []
      ret << @methods[node]
      return ret;
    end
  end

  def score(node)
    base_t = node[:Time]
    # waiting has a 20% penalty
    if node.has_key? :WaitTime
      base_t += node[:WaitTime] * 0.2
    end
    # transferring has a 10% penalty
    if node.has_key? :StopTime
      base_t += (node[:Time] - node[:WaitTime])*0.1
    else
      # walking has a 40% penalty
      base_t += (node[:Time]) * 0.4
    end
    return base_t
  end

  def route(from_lat,from_lon,to_lat,to_lon,at_time=Time.now)
    closedSet = Set.new
    start_points = Stop.neighbor_nodes_on_foot(from_lat,from_lon,3,1.0)
    end_points = Set.new(Stop.neighbor_nodes_on_foot(to_lat,to_lon,2,1.0).collect {|n| n[1][:Stop]})
    openSet = Set.new(start_points.collect{|n| n[1][:Stop]})
    @came_from = Hash.new
    there = GeoKit::LatLng.new(to_lat, to_lon)
    f_score = MultiRBTree.new
    g_score = Hash.new
    h_score = Hash.new
    @methods = Hash.new
    puts "start_points #{start_points.inspect} closedSet #{closedSet}"
    start_points.each do |spnval|
      spn = spnval[1]
      sp = spn[:Stop]
      here = GeoKit::LatLng.new(sp.stop_lat, sp.stop_lon)
      sc = score(spn)
      g_score[sp] = sc
	  # assume average 7MPH for heuristic, and turn to minutes
      hsc = spn[:Time] + 3600.0 * here.distance_to(there) / AVERAGE_SPEED
      h_score[sp] = hsc
      sc += hsc
      f_score[sc] = sp
      #f_score << { :score => h_score[sp], :sp => sp, :stop_time => nil }
      @methods[sp] = spn
    end

    while openSet.length > 0
      x = nil
      f_score.each do |fkv|
        x = fkv[1]
        break if openSet.include? x
      end
      if end_points.include? x
        @total_time = 0
        puts "found a route"
        return reconstruct_path(x)
      end
      openSet.delete(x)
      closedSet.add(x)

      puts "\n\nStop "+x.stop_name+"("+x.stop_id+")\n\n"
      nodelist = x.neighbor_nodes(at_time+g_score[x])
      #puts "\nNodelist "+nodelist.inspect
      count = 0
      nodelist.each do |nodevalue|
        node = nodevalue[1]
        #puts "Node "+node.inspect
        node_stop = node[:Stop]
        next if closedSet.find_index(node_stop) != nil

        tentative_g_score = g_score[x] + score(node)
        if openSet.find_index(node_stop) == nil
          openSet.add node_stop
          tentative_better = true
        elsif tentative_g_score < g_score[node_stop]
          tentative_better = true
        else
          tentative_better = false
        end

        if tentative_better
          here = GeoKit::LatLng.new(node_stop.stop_lat, node_stop.stop_lon)
          @came_from[node_stop] = x
          sc = tentative_g_score
          g_score[node_stop] = sc
          phi = here.heading_to(there)
          ratio = Math::sin(phi.radians).abs + Math::cos(phi.radians).abs
          hsc = 3600.0 * here.distance_to(there) * ratio / AVERAGE_SPEED
          sc += hsc
          h_score[node_stop] = hsc
          f_score[sc] = node_stop
          @methods[node_stop] = node
          count = count + 1
        end
      end
      puts "evaluated #{count} stops"
    end
    puts "No route found :-("
    return nil
  end
end
