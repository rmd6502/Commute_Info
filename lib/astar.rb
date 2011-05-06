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
    start_points = Stop.neighbor_nodes_on_foot(from_lat,from_lon)
    end_points = Set.new(Stop.neighbor_nodes_on_foot(to_lat,to_lon))
    openSet = Set.new(start_points)
    @came_from = {}
    there = GeoKit::LatLng.new(to_lat, to_lon)
    f_score = []
    start_points.each do |sp|
      here = GeoKit::LatLng.new(sp[:Stop].stop_lat, sp[:Stop].stop_lon)
      g_score[sp] = sp[:Time]
      h_score[sp] = sp[:Time] + here.distance_to(there) * 1.414
      f_score[sp] = h_score[sp]
      f_score << { :score => h_score[sp], :sp => sp }
    end

    while openSet.length > 0
      f_scores = f_score.sort { |x,y| x[:score] <=> y[:score] }
      x = f_scores[0][:sp]
      i = end_points.find_index(x.stop)
      if i != nil
        return reconstruct_path(@came_from(x.stop))
      end
      openSet.delete(x.stop)
      closedSet.add(x.stop)

      x.stop.neighbor_nodes(Time.now,nil).each do |node|
        next if closedSet.find_index(node[:Stop]) != nil

        tentative_g_score = g_score[x] + node[:Time] * 1.1
        if openSet.find_index(node[:Stop]) == nil
          openSet.add node
          tentative_better = true
        elsif tentative_g_score < g_score[node]
          tentative_better = true
        else
          tentative_better = false
        end

        if tentative_better
          @came_from[node.stop] = x
          g_score[node] = tentative_g_score
          h_score[node] = here.distance_to(there) * 1.414
          f_score[node] = g_score[node] + h_score[node]
        end
      end
    end
    return nil
  end
end
