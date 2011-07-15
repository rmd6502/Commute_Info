require 'nokogiri'
require 'open-uri'
require 'cgi'

module RouteInfoHelper
  def isRouteDelayed?(route,tm)
    doc = Nokogiri::XML(open("http://mta.info/status/serviceStatus.txt"))
    subways_info = doc.xpath("/service/subway/line[status != 'GOOD SERVICE']")
    subways_info.each do |info|
      lines = info.search('name').text
      route = route[0].upcase
      # TODO: Do we need to parse/compare date and time of the announcement against tm?
      if lines[route]
        puts "found a delay #{info.inspect}"
        return {
          :announcement => info.search('status').text,
          :headline => info.search('plannedworkheadline').text,
          :details => CGI.unescapeHTML(info.search('text').text)
        }
      end
    end
    return nil
  end
end
