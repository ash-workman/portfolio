
require 'mechanize'

agent = Mechanize.new


page = agent.get "http://www.sephora.com/"

file = open("page_data.html", 'w')
file.write(page.body)
file.close()


def read_html_file(filename)
  
  file = File.open(filename)
  html_code = Nokogiri::HTML(file)
  file.close

  return html_code.to_s
end


def find_links(html_code)

  all_links = Array.new

#  page = Mechanize::Page.new(nil, nil, html_code, nil, Mechanize.new)

  # fill in some code here!                                                                                                                                                          
  #page.links.each do |link|
 #
 urls = URI.extract(html_code, ['http', 'https'])
#     if link =~/^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/ 
       urls.each do |link|
       puts link
       all_links.push(link)
#     end
  end
  # fill in some code here!

  return all_links
end

#####main#####
html = read_html_file(file)
links = find_links(html)
puts links
