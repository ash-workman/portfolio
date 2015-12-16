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


def find_rank(file)
  dir = 'pages/'
  file_list = list_files('pages/')
  pagerank = Hash.new {|h,k| h[k]=[]}
  num_pages = file_list.length
  start_rank = 1.0 / num_pages.to_f
#  puts (1.0 / num_pages).to_f
 page_data = Hash.new {|h,k| h[k]=[]}
  file_list.each do |page|
    my_page = read_html_file(page)
    links = find_links(my_page).length
#    page_data[page] = (start_rank, links)
#    puts links
 # puts page_data
 #   pagerank[page] = page_data
# puts pagerank
  p  = 1.0
  count = 0
 #end 
#puts pagerank
while count < num_pages
    #return if count > num_pages
   # constant += 1.0
    count += 1
    next_page = file_list[count]
  puts next_page
#    puts next_page
    next_data = pagerank[next_page]
#    puts next_data
    c_page = page_data[count][0]
  #    puts next_page[0]
    show_links = find_links(next_page)
#    puts next_page
   links = find_links(my_page).length 
#    puts links
#problem is with pagerank[nextpage]
   next_rank = pagerank[file_list[count]]
#   puts pagerank
   pagerank[page] = p  / num_pages + ( 1 - p) * c_page.values[0] / c_page.values[1]  
 
  #  return pagerank
 # puts pagerank.values
# puts pagerank[key]
  end
#puts page_data.keys
end
end



def write_data(filename, data)
  file = File.open(filename, "w")
  file.puts(data)
  file.close
end

##############################main######################################

file_list = list_files('pages/')

#puts find_rank(html_code)

count = 0

num_pages = file_list.length
start_rank = 1.0 / num_pages.to_f
initial_pagerank = Hash.new {|h,k| h[k]=[]}
link_totals = Hash.new {|h,k| h[k]=[]}
for page in file_list
  html_code = read_html_file(page)
  links = find_links(html_code)
  link_totals[page] = (links.length).to_f
 initial_pagerank[page] = start_rank
end

pagerank = Hash.new {|h,k| h[k]=[]}
#p = 1.0

for page in file_list
    if link_totals[page] = 0
      link_totals[page] = 1
    else link_totals[page] = link_totals[page]
    end
    pagerank[page] = 0.85  / num_pages + ( 1 - 0.85) * initial_pagerank[page] / link_totals[page]
#  end
end

#puts link_totals

#while count < 5
#  count += 1
  new_pagerank = Hash.new {|h,k| h[k]=[]}
#while new_pagerank.values.inject(:+) < 1 
 for page in file_list
    if link_totals[page] = 0
      link_totals[page] = 1
    else link_totals[page] = link_totals[page]
    end
   new_pagerank[page] = 0.85  / num_pages + ( 1 - 0.85) * pagerank[page] / link_totals[page]
#  end
end

#puts pagerank

#puts new_pagerank

write_data('pagerank.dat', new_pagerank)
