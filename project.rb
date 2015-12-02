require 'mechanize'
require 'uri'
require 'open-uri'
require 'nokogiri'

crawler = Mechanize.new


def retrieve_page(url)
  begin
    current_page = crawler.get(url)
    rescue Exception => e
    current_page = nil
    end
  sleep(0.01)
  return current_page
end


   
page = Nokogiri::HTML(open("http://www.sephora.com/"))
#puts page   


File.write('page_data.html', page)



# This function reads in a hash or an array (list) from a file produced by write_file().
#  You can modify this function if you want, but it should already work as-is.
# 
# my_list=read_data("file1")
# my_hash=read_data("file2")
def read_data(file_name)
  file = File.open(file_name,"r")
  object = eval(file.gets).to_s
  file.close()
  return object
end

# function that takes the *name of an html file stored on disk*,
# and returns a string filled HTML code
#

# function that takes a string filled with html code,
# and returns a list of that page's hyperlinks.
#
def find_links(html_code)

  all_links = Array.new
   
  page = Mechanize::Page.new(nil, nil, object, nil, Mechanize.new)
 
  # fill in some code here!
  page.links.each { |p| all_links.push(p.uri.to_s) }
 
  return all_links
end


##main##

html = read_data('page_data.html')
links = find_links(html)
puts links
