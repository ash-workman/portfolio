#!/usr/bin/ruby
#
#   Code authors: [Ashlee Workman]
#   
#   based on skeleton code by D Crandall

# Importing required libraries
require 'nokogiri'
require 'fast-stemmer'


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
  object = eval(file.gets)
  file.close()
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
	stop_words = {}

	# Looping through the file and adding each word to a hash table after chomping them
	File.open(file, "r").each_line do |line|
		stop_words[line.chomp] = 1
	end

	return stop_words
end


# function that takes a list of tokens, and a list (or hash) of stop words,
#  and returns a new list with all of the stop words removed

def remove_stop_tokens(tokens, stop_words)

	# Looping through the list of tokens and removing all the stop words from the list
	for i in tokens
		if stop_words.member?(i)
			tokens.delete(i)
		end
	end
	
	return tokens
end


# function that takes a list of tokens, runs a stemmer on each token,
#  and then returns a new list with the stems

def stem_tokens(tokens)
	stem_list = []

	# Looping through the list and finding the stem word for each word
	for word in tokens
		word = word[/\w*/]
		s = word.stem
		s.downcase!
		stem_list.push(s)
	end
	
	return stem_list
end


# search_or takes a list of stemmed keywords and an inverted index hash table and returns
# a sorted hash of pages that include any of the keywords with their count
 
def search_or(keywords, index)
	
	# Creating an empty hash consisting of all the pages that contain the specified keywords
	pages = {}

	# Loops through the keyword list and checks whether a keyword exists in the index
	for keyword in keywords
		if index.member?(keyword)

			# Loops through the hash for the keyword and returns all the pages that
			# contain the keyword along with their keyword counts
			for key, value in index[keyword]
				if pages.member?(key)
					pages[key] += value
				else
					pages[key] = value
				end
			end
		end
	end

	# Sorts the hash by the keyword counts in descending order
	pages = Hash[pages.sort_by { |key, value| -value }]

	return pages
end
	

# search_and takes a list of stemmed keywords and an inverted index hash table and returns
# a sorted hash of pages that include all of the keywords with their count

def search_and(keywords, index)

        # Creating an empty hash consisting of all the pages that contain the specified keywords
        pages = {}
	
	# Creating a temporary hash that whose value contains an array which contains the keyword
	# counts and the total number of matched keywords in that page
	temp = {}

	total_keywords = keywords.length	

        # Loops through the keyword list and checks whether a keyword exists in the index
        for keyword in keywords
                if index.member?(keyword)

                        # Loops through the hash for the keyword and returns all the pages that
                        # contain the keyword along with their keyword counts, and the total number
			# of keywords matched and adds them to the temp hash
                        for key, value in index[keyword]
                                if temp.member?(key)
					temp[key][0] += value
					temp[key][1] += 1
                                else
                                	temp[key] = []        
					temp[key][0] = value
					temp[key][1] = 1
                                end
                        end
                else
			# Exiting the loop and function and returning an empty hash if the keyword 
			# is not found in the inverted index to save processing time
			pages = {}
			
			return pages
		end
	end

	# Loops through the temp hash and adds only those pages to the pages hash which contain
	# all the keywords being searched
	for key, value in temp
		if value[1] == total_keywords
			pages[key] = value[0]
		end
	end

        # Sorts the hash by the keyword counts in descending order
        pages = Hash[pages.sort_by { |key, value| -value }]

        return pages
end


# search_most takes a list of stemmed keywords and an inverted index hash table and returns
# a sorted hash of pages that include most of the keywords with their count

def search_most(keywords, index, doc)

        # Creating an empty hash consisting of all the pages that contain the specified keywords
        pages = {}
	
	# Creating a temporary hash that whose value contains an array which contains the keyword
	# counts and the total number of matched keywords in that page
	temp = {}

	total_keywords = keywords.length
	min_keywords = total_keywords.to_f / 2.0

        # Loops through the keyword list and checks whether a keyword exists in the index
        for keyword in keywords
                if index.member?(keyword)

                        # Loops through the hash for the keyword and returns all the pages that
                        # contain the keyword along with their keyword counts, and the total number
			# of keywords matched and adds them to the temp hash
                        for key, value in index[keyword]
                                if temp.member?(key)
					temp[key][0] += value
					temp[key][1] += 1
                                else
                                	temp[key] = []        
					temp[key][0] = value
					temp[key][1] = 1
                                end
                        end
		end
	end

	# Loops through the temp hash and adds only those pages to the pages hash which contain
	# at least half the keywords being searched
	for key, value in temp
		if value[1].to_f >= min_keywords
			pages[key] = value[0]
		end
	end
 tfidf_hash = Hash.new {|a,b| a[b]=[]}
  tfidf_hash.default = 0
 pages.each do |page|
   keywords.each do |word|
    for key, value in pages
        puts key, value
      #if invindex.member?(term)
        inv_nested = pages[key]
        rel_docs = index[word]
	puts rel_docs
	doc_count = rel_docs.length
	puts doc_count
	inv_value = pages[value]
       # inv_nested_further = inv_nested[1]
        tfidf_hash = Hash.new {|h,k| h[k]=[]}
      #for page in inv_nested_further
        count = inv_nested
        doc_nested = doc[key]
        doc_terms = doc_nested[0]
        puts inv_value
	puts doc
        puts doc_terms 
	tf = count/doc_terms.to_f
#need to determine correct way to get df for idf term
	  idf = 1 / (1 + Math.log(doc_count.to_f))
          tfidf = tf * idf
          tfidf_hash[page] = tfidf
        end 
    end
  sorted_hash = tfidf_hash.sort {|a,b| a[1]<=>b[1]}.reverse
  sorted_pages =  sorted_hash[0..24]
  puts sorted_pages

# Sorts the hash by the keyword counts in descending order
# pages = Hash[pages.sort_by { |key, value| -value }]
  return sorted_pages
  end
end
# print_results takes a hash table containing the results found along with a document index
# and prints each result on the screen with its title and URL. It also prints the total number
# of documents searched and the total number of results that are found for the search query 

def print_results(results, docindex)
	
	# Printing output
	if results.length == 0
		puts "\nCould not find any matches for your search query!\n\n"
		return
	else
		counter = 0
		puts "\nThe following results match your search query: \n\n"
	end
	
	# Looping through the results hash and printing each result's title, URL, and the total number
	# of matches found along with the position of the result
	for key, value in results	
		counter += 1
		
		if docindex.member?(key)
			puts counter.to_s + ".\t" + docindex[key][1].to_s
			puts "\t" + docindex[key][2].to_s
			puts "\tMatches Found: " + value.to_s
			puts "\n"
		end
	end

	# Printing the total number of documents searched and results found
	puts "Total Documents Searched: " + docindex.length.to_s
	puts "Total Results Found: " + results.length.to_s
	puts "\n\n"
end





def tfidf_score(clean_query, invindex, docindex, num_of_doc)
#takes a list of query terms and calculates the tfidf score for each doc that contains the terms.                                                                                   \
                                                                                                                                                                                     
#creates a hash of pages with their corresponding tfidf score. Then sorts the scores in descending order                                                                            \
                                                                                                                                                                                     
#and returns the top 25 documents                                                                                                                                                   \
                                                                                                                                                                                     
  for term in clean_query
  inv_nested = invindex[term]
  inv_nested_further = inv_nested[1]
  tfidf_hash = Hash.new {|h,k| h[k]=[]}
  for page in inv_nested_further.keys
    count = inv_nested_further[page]
    doc_nested = docindex[page]
    doc_terms = doc_nested[0]
    tf = count / doc_terms.to_f
    end
  end
  sorted_hash = tfidf_hash.sort {|a,b| a[1]<=>b[1]}.reverse
  return sorted_hash[0..24]
end

#################################################
# Main program. We expect the user to run the program like this:
#
#   ./retrieve.rb mode kw1 kw2 kw3 .. kwn
#

# check that the user gave us correct command line parameters
abort "Command line should have at least 2 parameters." if ARGV.size < 2

mode = ARGV[0]
keyword_list = ARGV[1..ARGV.size]

# read in list of stopwords from file
stopwords = load_stopwords_file("stop.txt")

# Removing the stop words from the keyword list
keyword_list = remove_stop_tokens(keyword_list, stopwords)

# Stemming the tokens
stemmed_keywords =  stem_tokens(keyword_list)

# read in the index file produced by the crawler from Assignment 2 (mapping URLs to filenames).
docindex=read_data("doc.dat")

# read in the inverted index produced by the indexer. 
invindex=read_data("invindex.dat")


# Performing retrieval operations according to the search mode specified
results = []

#if mode == "or"
#	results = search_or(stemmed_keywords, invindex)
#elsif mode == "and"
#	results = search_and(stemmed_keywords, invindex)
#elsif mode == "most"
results = search_most(stemmed_keywords, invindex, docindex)
#else
#	puts "\nInvalid search method specified!\n\n"
#	exit
#end


#num_of_doc = hit_list.length

#top_results = tfidf_score(clean_query, invindex, docindex, num_of_doc)
#my_results = Hash[top_results.map {|key, value| [key, value]}]


#if (num_of_doc == 0)
 # print "No documents contained these query terms..\n"
#else
 # my_results.keys.each do |page|
 #     if docindex.include?(page)
  #      page_title = docindex[page][1]
   #     page_url = docindex[page][2]
    #    print "URL: #{page_url} Title: #{page_title} \n"
#    end                                                                                                                                                                            \
                                                                                                                                                                                     
     # end
  #end
#end




# Printing the search results
print_results(results, docindex)














