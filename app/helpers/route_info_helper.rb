require 'nokogiri'
require 'open-uri'
require 'cgi'

module RouteInfoHelper
  def isRouteOperating?(route,tm)
    doc = Nokogiri::XML(open("http://mta.info/status/serviceStatus.txt"))
    subways_info = doc.xpath("/service/subway/line[status != 'GOOD SERVICE']")
    subways_info.each do |info|
      lines = info.search('name').text
      if lines[route]
        return {
          :headline => info.search('plannedworkheadline').text,
          :details => CGI.unescapeHTML(info.search('text').text)
        }
      end
    end
  end
end
