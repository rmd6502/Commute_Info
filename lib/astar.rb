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
      # walking has a 30% penalty
      base_t += (node[:Time]) * 0.3
    end
    return base_t
  end

  def route(from_lat,from_lon,to_lat,to_lon)
    closedSet = Set.new()
    start_points = Stop.neighbor_nodes_on_foot(from_lat,from_lon,1.0)
    end_points = Set.new(Stop.neighbor_nodes_on_foot(to_lat,to_lon,1.0).collect {|n| n[:Stop]})
    openSet = Set.new(start_points.collect{|n| n[:Stop]})
    @came_from = {}
    there = GeoKit::LatLng.new(to_lat, to_lon)
    f_score = {}
    g_score = {}
    h_score = {}
    @methods = {}
    start_points.each do |spn|
      sp = spn[:Stop]
      here = GeoKit::LatLng.new(sp.stop_lat, sp.stop_lon)
      g_score[sp] = score(spn)
	  # assume average 7MPH for heuristic, and turn to minutes
      h_score[sp] = spn[:Time] + 60.0 * here.distance_to(there) / AVERAGE_SPEED
      f_score[sp] = h_score[sp]
      #f_score << { :score => h_score[sp], :sp => sp, :stop_time => nil }
      @methods[sp] = spn
    end

    at_time = Time.now
    while openSet.length > 0
      x=nil
      f_score.sort { |a,b| a[1] <=> b[1] }.each do |f|
        if openSet.find_index(f[0]) != nil
          x = f[0]
          break
        end
      end

      i = end_points.find_index(x)
      if (i != nil)
        @total_time = 0
        return reconstruct_path(x)
      end
      openSet.delete(x)
      closedSet.add(x)

      #puts "\n\nStop "+x.inspect+"\n\n"
      nodelist = x.neighbor_nodes(at_time+g_score[x].minutes)
      #puts "\nNodelist "+nodelist.inspect
      nodelist.each do |node|
        #puts "Node "+node.inspect
        node_stop = node[:Stop]
        next if closedSet.find_index(node_stop) != nil

		# add a 5 minute penalty for transferring
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
          g_score[node_stop] = tentative_g_score
          phi = here.heading_to(there)
          ratio = Math::sin(phi.radians).abs + Math::cos(phi.radians).abs
          h_score[node_stop] = 60.0 * here.distance_to(there) * ratio / AVERAGE_SPEED
          f_score[node_stop] = g_score[node_stop] + h_score[node_stop]
          @methods[node_stop] = node
        end
      end
    end
    return nil
  end
end
