#! /l/ruby-2.2.2/bin/ruby
#puts "Content-Type: text/html\n\n"

require 'cgi'
#require 'mechanize'
#require 'fast_stemmer'

cgi = CGI.new("html4")

user_query = cgi['search_field'].split(" ")

for i in 0..(user_query.length - 1)
  ARGV[i] = user_query[i]
end


load 'retrieve.rb'

#read in the index file produced by the crawler from Assignment 2 (mapping URLs to filenames).
docindex=read_data("doc.dat")

##read in the inverted index produced by the indexer. 
invindex=read_data("invindex.dat")

## # Add your code here!

##read in list of stopwords from file
stopwords = load_stopwords_file("stop.txt")

pagerank = read_data('pagerank.dat')

## # Step (1) Stem and stop the query terms
query_term = stem_tokens(user_query)
#
## #adds tokens in query term to list
clean_query = remove_stop_tokens(query_term, stopwords)
## # Step (2) Use the inverted index file to find the hit list
hit_list = find_hitlist(clean_query, invindex)


num_of_doc = hit_list.length
top_results = tfidf_score(clean_query, invindex, docindex, num_of_doc, pagerank)
my_results = Hash[top_results.map {|key, value| [key, value]}]

myhtml = ""
myhtml+= '<form name="my_form" id="form" action="http://cgi.soic.indiana.edu/~ashworkm/my_retrieve.cgi" method="POST"> '


myhtml += "<p><p><P><strong>Your search '" +cgi['search_field']+   "' returned the following results:</strong>"+ "\n"
if (num_of_doc == 0)
  myhtml += "No documents contained these query terms.\n"
else
  my_results.keys.each do |page|
      if docindex.include?(page)
        page_title = docindex[page][1]
        page_url = docindex[page][2]
        myhtml+= "<P><strong>Title: </strong> #{page_title}"
        myhtml += "<P><strong>URL: </strong><a href="+"#{page_url}"+">"+"#{page_url}</a>"
        #puts "URL:" + " <a href="+"#{page_url}"+">"                                                                                                                                
                                                                                                                                                                                    
        myhtml += "\n\n"
#       urls.push(page_url)                                                                                                                                                         

      end
    end
end
myhtml += "<P> Total number of document: #{docindex.keys.length} \n"
myhtml += "Total number of hits: #{num_of_doc} \n<P><P>"


## # Step (3) For each page in the hit list,
## # display the URL and the title of the HTML page
#num_of_doc = hit_list.length
cgi.out{
cgi.html{
cgi.head{ "\n"+cgi.title{"Ashlee's Search Engine"} } +
cgi.body{ "\n"+cgi.h1{"Search Results"}+ 
myhtml+
 '''                                                                                                                                                                                  


<input type="text" size="80" name="search_field">                                                          
<input type="submit" value="Search">                                                                                                                                                 
<style>                                                                                                                                                                              
form {                                                                                                                                                                           
text-align: center;                                                                                                                                                                  
position: relative;                                                                                                                                                                  
top: 70;                                                                                                                                                                             
}                                                                                                                                                                                    
body {                                                                                                                                                                           
background-color: pink;                                                                                                                                                              
}                                                                                                                                                                                    
</style>                                                                                                                                                                             
</form>  

''' 

}
}
}

