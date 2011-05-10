class Numeric
  def format_as_time
      dif_time_string = ""
      if self >= 3600
        dif_time_string = (self/3600).floor.to_s + " hour"
        if self >= 7200
          dif_time_string += "s"
        end
      end
      dtm = self - (self / 3600.0).floor * 3600.0
      if dtm >= 60
        if dif_time_string != nil && dif_time_string.length > 0
          dif_time_string += ", "
        end
        dif_time_string += (dtm/60).floor.to_s + " minute"
        if dtm >= 120
          dif_time_string += "s"
        end
      end
      dtm = dtm - (dtm / 60.0).floor * 60.0
      if dtm >= 1
        if dif_time_string != nil && dif_time_string.length > 0
          dif_time_string += ", "
        end
        dif_time_string += dtm.floor.to_s + " second"
        if dtm >= 2
          dif_time_string += "s"
        end
      end
    return dif_time_string
  end

  def radians
    return self * Math::PI / 180.0
  end

  def degrees
    return self * 180.0 / Math::PI
  end
end
