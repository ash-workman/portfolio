# I427 Fall 2015, AssignZZZZZe has a method for following the Robots Exclusion Protocol, if Mechanize found a website that did not allow
# robots in, I would ignore the website.

require 'mechanize'
require 'uri'

$web_crawler = Mechanize.new #where the magic lives
$web_crawler.user_agent = 'IUB-I427-ashworkm' #the web robot

# function that takes a URL as a parameter, retrieves that URL from the network, 
# and returns a string containing the HTML contents of the page
#

def retrieve_page(url)
  begin
    current_page = $web_crawler.get(url)
    rescue Exception => e
    current_page = $web_crawler.get('http://www.ulta.com')
    end
  sleep(0.01)
  return current_page
end

#save page to an html file
def save_page(page, num, dir)
  page.save(dir + num.to_s + '.html')
end

#writes file name and web address to a data file.
def filemap_out(page, num, dir, datafile)
  datafile.puts(num.to_s + ".html - " + page.uri.to_s)
end

#the magic of depth-first search
def bfs_crawl(max_depth, startpage, output_dir, datafile)
  c_page_num = 0
  c_page = retrieve_page(startpage)
  visited = []
  web_horizon = []
  while c_page_num < max_depth do
    next if c_page == nil
    if c_page_num == 0
      visited.push(c_page.uri.to_s)
      #next if c_page.uri.to_s == nil
      save_page(c_page, c_page_num, output_dir)
      filemap_out(c_page, c_page_num, output_dir, datafile)
      #get all links on the page and put them in the web horizon
      c_page.links.each {|link| web_horizon.push(link.attributes['href'].to_s)}
      #start next iteration
      c_page = retrieve_page(web_horizon.shift)
      c_page_num += 1
      print "."
      elsif web_horizon.any?
      if visited.include?(c_page.uri)
        #find valid unique links
        while true do
          t_page = web_horizon.shift
          if t_page.nil?
            break
          else
            if (t_page =~ /\A#{URI::regexp(['http', 'https'])}\z/) == 0
              c_page = retrieve_page(t_page)
              if !c_page.nil?
                break
                end
              end
            end
        end
        else
        visited.push(c_page.uri.to_s)
        save_page(c_page, c_page_num, output_dir)
        filemap_out(c_page, c_page_num, output_dir, datafile)
        tmp = []
        begin
          c_page.links.each { |link| tmp.push(link.attributes['href'].to_s) } if (c_page.filename.to_s =~ /\.(?:pdf)$/).nil?
        rescue Exception => e
          next
        end
        tmp.each {|pge| web_horizon.push(pge)}
        #find links
        while true do
          t_page = web_horizon.shift
          if !t_page.nil?
            if (t_page =~ /\A#{URI::regexp(['http', 'https'])}\z/) == 0
              if t_page =~ /\w(jpg)|(jpeg)/
                break
              else
              c_page = retrieve_page(t_page)
              end
              if !c_page.nil?
                break
                end
              end
            end
          end
        c_page_num += 1
        print "."
        end
      else
      break
      end
    end
end



########################################
if ARGV.size  != 2
  abort "Command line should have 2 parameters."
end

# fetch command line parameters
(max_pages, output_dir) = ARGV

print("Running...")

max_num = max_pages.to_i

# main body of program; outsources most of what it does to above
dat_file = File.open("index.dat", "w")
seed_url = 'http://www.sephora.com'

bfs_crawl(max_num, seed_url, output_dir, dat_file)

dat_file.close

puts(" done!")
puts("The program will now exit.")
