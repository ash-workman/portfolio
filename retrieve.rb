#!/usr/bin/ruby
# I427 Fall 2015, Assignment 4
#   Code authors: Ashlee Workman
#   
#   based on skeleton code by D Crandall & Jangwon Lee

require 'fast_stemmer'

require 'cgi'

# This function writes out a hash or an array (list) to a file.
#  You can modify this function if you want, but it should already work as-is.
# 
# write_data("file1",my_hash)
# 
def write_data(filename, data)
  file = File.open(filename, "w")
  file.puts(data)
  file.close
end

# This function reads in a hash or an array (list) from a file produced by write_file().
#  You can modify this function if you want, but it should already work as-is.
# 
# my_list=read_data("file1")
# my_hash=read_data("file2")
def read_data(file_name)
  file = File.open(file_name,"r")
   object = eval(file.gets.untaint.encode('UTF-8', :invalid => :replace))
# begin
#  object = eval(file.gets)
#  rescue SyntaxError => se
  file.close()
  #end
  return object
end

#
# You'll likely need other functions. Add them here!
#

# function that takes the name of a file and loads in the stop words from the file.
#  You could return a list from this function, but a hash might be easier and more efficient.
#  (Why? Hint: think about how you'll use the stop words.)
#
def load_stopwords_file(file) 
    stop_words = Hash.new(0)
    file = File.open(file, "r")
    file.readlines.each do |word|
      stop_words[word.chomp] = 1
    end

    file.close
    return stop_words
end

# function that takes a list of tokens, and a list (or hash) of stop words,
#  and returns a new list with all of the stop words removed
#
def remove_stop_tokens(tokens, stop_words)
  tokens_without_stop = Array.new

  tokens.each do |token|
    unless stop_words.include? token
      tokens_without_stop.push(token)
    end
  end

  return tokens_without_stop
end

# function that takes a list of tokens, runs a stemmer on each token,
#  and then returns a new list with the stems
#
def stem_tokens(tokens)
  stem_tokens = Array.new

  tokens.each do |token|
    stem_tokens.push(Stemmer.stem_word(token))
  end
  
  return stem_tokens
end

#function that takes the query terms makes a list of hits that contain the terms 
#comenting out the 'or' & 'and' modes
def find_hitlist(query, invindex)
  hit_list = Array.new
  hit_hash = Hash.new 0
  temp_list = Array.new
  first = 0

  query.each do |term|
    #puts term
    if invindex.has_key?(term)
     # puts invindex[term].keys
      if (first == 0)
        hit_list |= invindex[term].keys
        hit_list.each {|doc| hit_hash[doc] += 1}
        first = 1
      else
        #if (mode == "or")
       #   hit_list |= invindex[term][1].keys
      #  elsif (mode == "and")
     #     hit_list &= invindex[term][1].keys
    #    elsif (mode == "most")
          temp_list = invindex[term][1].keys
          temp_list.each {|doc| hit_hash[doc] += 1}
          #puts temp_list.inspect
        end
      
    else
      

 # if (mode == "most")
    #initizlie hit_list
    hit_list = []
    hit_hash.each {|k, v| hit_list.push(k) if v > (query.length / 2)}
    end

  return hit_list
end
end

def tfidf_score(clean_query, invindex, docindex, num_of_doc, pagerank)
  combined_score_hash = Hash.new {|a,b| a[b]=[]}
  combined_score_hash.default = 0
  for key, value in pagerank
    rank = pagerank[key]
  end
#    puts rank
   for  term in clean_query
     if invindex.include?(term)
       inv_nested = invindex[term]
     # puts inv_nested.keys
       rel_docs = invindex[term]
#      puts rel_docs
#doc count is the number of of docs that contain term
       doc_count = rel_docs.length
      #puts doc_count
    # puts docindex[page]
#      doc_nested = docindex.values
 #     puts doc_nested
#      doc_further = doc_nested[0]
     else 
       next
    end
#if term in inv_nested.keys
     
     for key, value in inv_nested
# count is number of times term appears on page 
       count = inv_nested[key]
#    puts count
      # doc_nested = docindex[key] 
#doc_further is total number terms per page
       doc_further = docindex[0]
   # puts doc_further
#    puts doc_nested
#    count = inv_nested_further[page]
#      puts docindex[page]
#      puts inv_nested
#      doc_nested = docindex[page]
 #     doc_terms = doc_nested[0]
#       puts rank
       tf = count / doc_further.to_f
       idf = 1 / (1 + Math.log(doc_count.to_f))
       tfidf = tf * idf
#       puts tfidf
       score = tfidf * rank
       combined_score_hash[key] = score
      # puts combined_score_hash
      end
    end
 # end
# puts tfidf_hash
  combined_score_hash.reject { |a,b| a.nil? }
  sorted_hash = combined_score_hash.sort {|a,b| a[1]<=>b[1]}.reverse
  return sorted_hash
#  puts sorted hash
end


#################################################
# Main program. We expect the user to run the program like this:
#
#   ./retrieve.rb mode kw1 kw2 kw3 .. kwn
#

# check that the user gave us correct command line parameters
abort "Command line should have at least 1 parameters." if ARGV.size<1

#mode = ARGV[0]
user_query = ARGV[0..ARGV.size]

# read in the index file produced by the crawler from Assignment 2 (mapping URLs to filenames).
docindex=read_data("doc.dat")

# read in the inverted index produced by the indexer. 
invindex=read_data("invindex.dat")

# Add your code here!

# read in list of stopwords from file
stopwords = load_stopwords_file("stop.txt")

#puts keyword_list.inspect

# Step (1) Stem and stop the query terms
query_term = stem_tokens(user_query)
#puts query_term.inspect

#adds tokens in query term to list
clean_query = remove_stop_tokens(query_term, stopwords)
#puts clean_query.inspect


pagerank = read_data('pagerank.dat')
#puts pagerank
# Step (2) Use the inverted index file to find the hit list
hit_list = find_hitlist(clean_query, invindex)
#puts hit_list.inspect
#
#
# Step (3) For each page in the hit list,
# display the URL and the title of the HTML page
num_of_doc = hit_list.length

#top_results = tfidf_score(clean_query, invindex, docindex, num_of_doc)
#my_results = Hash[top_results.map {|key, value| [key, value]}]


# Step (4) Display the total number of documents 
# and the total number of hits


#urls = []
#print "<P><P><h1>Search Results</h1>"
#print "<p><p><P><strong>Your search returned the following results:</strong>", "\n"
if (num_of_doc == 0)
  print "No documents contained these query terms.\n"
#else
#  num_of_doc = hit_list.length
end
  top_results = tfidf_score(clean_query, invindex, docindex, num_of_doc, pagerank)
  my_results = Hash[top_results.map {|key, value| [key, value]}]


 my_results.keys.each do |page|
      if docindex.include?(page)
        page_title = docindex[page][1]
        page_url = docindex[page][2]
        puts "<P><strong>Title:</strong> #{page_title}"
        puts "<strong>URL:</strong><a href="+"#{page_url}"+">"+"#{page_url}</a>"
        #puts "URL:" + " <a href="+"#{page_url}"+">"
      #  print "\n\n"
#        urls.push(page_url)  
     end
   end      
#end
#print "<P> Total number of document: #{docindex.keys.length} \n"
#print "Total number of hits: #{num_of_doc} \n<P><P>"
#for url in urls
#puts 'URL:' + ' <a href="'+url+'">'
#end
#TF(t) = (Number of times term t appears in a document) / (Total number of terms in the document).
#IDF(t) = log_e(Total number of documents / Number of documents with term t in it).
#TF-IDF = TF * IDF
