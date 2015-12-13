require 'nokogiri'
require 'uri'
require 'mechanize'
#rank = p / num_pages + (1 - p) * sum of (rank for each page / out-degree of each page)                                                                                              

#Link analysis. Implement the PageRank algorithm to compute the PageRank of each page in your index,                                                                                 
#and store this in a data file.                                                                                                                                                      


# function that takes the name of a directory, and returns a list of all the filenames in that
# directory.
#
def list_files(dir)
# Getting all the files names in the directory
  file_names = Dir[dir + "*"]
  return file_names
end



# function that takes the *name of an html file stored on disk*,
# and returns a stiring filled HTML code
#
def read_html_file(filename)
  
  file = File.open(filename)
  html_code = Nokogiri::HTML(file)
  file.close
  
  return html_code.to_s
end



# function that takes a string filled with html code,
# and returns a list of that page's hyperlinks.
#
def find_links(html_code)
  all_links = Array.new
  page = Mechanize::Page.new(nil, nil, html_code, nil, Mechanize.new)
  page.links.each do |link|
     all_links.push(link.href)
  end
  # fill in some code here!
  return all_links
end




def find_pagerank(file)
  dir = 'pages/'
  file_list = list_files(dir)
  pagerank = {}
  num_pages = file_list.length
  p = (1 / num_pages).to_f
  count = 0
  while count < num_pages
    return if count > num_pages
   # html_code = read_html_file(dir + file_list[count])
    count += 1
    next_page = read_html_file(file_list[count])
    links = find_links(next_page).length
    rank = p / num_pages + ( 1 - p) * (find_pagerank(next_page) / links).to_f
  end
return rank
end

##############################main######################################

#file_list = list_files('pages/')

file_name = 'pages/1.html'
html_code = read_html_file(file_name)

puts find_pagerank(html_code)
