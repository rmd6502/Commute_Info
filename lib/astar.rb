class AStar
  def reconstruct_path(node)
    if @came_from.has_key? node
      return reconstruct_path(@came_from[node])+node
    else
      return Array.new(node)
    end
  end

  def route(from_lat,from_lon,to_lat,to_lon)
    closedSet = Set.new()
    start_points = Stop.neighbor_nodes_on_foot(from_lat,from_lon,1.0)
    end_points = Set.new(Stop.neighbor_nodes_on_foot(to_lat,to_lon,1.0).collect {|n| n[:Stop]})
    openSet = Set.new(start_points)
    @came_from = {}
    there = GeoKit::LatLng.new(to_lat, to_lon)
    f_score = {}
    g_score = {}
    h_score = {}
    start_points.each do |spn|
      sp = spn[:Stop]
      here = GeoKit::LatLng.new(sp.stop_lat, sp.stop_lon)
      g_score[sp] = spn[:Time]
      h_score[sp] = spn[:Time] + here.distance_to(there) * 1.414
      f_score[sp] = h_score[sp]
      #f_score << { :score => h_score[sp], :sp => sp }
    end

    at_time = Time.now
    while openSet.length > 0
      f_scores = f_score.sort { |a,b| a[1] <=> b[1] }
      x = f_scores[0][0]
      i = end_points.find_index(x)
      if (i != nil)
        return reconstruct_path(@came_from[x])
      end
      openSet.delete(x)
      closedSet.add(x)

      #puts "\n\nStop "+x.inspect
      nodelist = x.neighbor_nodes(at_time,nil)
      #puts "\nNodelist "+nodelist.inspect
      nodelist.each do |node|
        #puts "Node "+node.inspect
        node_stop = node[:Stop]
        next if closedSet.find_index(node_stop) != nil

        tentative_g_score = g_score[x] + node[:Time] * 1.1
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
          at_time += node[:Time].minutes
          @came_from[node_stop] = x
          g_score[node_stop] = tentative_g_score
          h_score[node_stop] = here.distance_to(there) * 1.414
          f_score[node_stop] = g_score[node_stop] + h_score[node_stop]
        end
      end
    end
    return nil
  end
end
