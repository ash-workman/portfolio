# I427 Fall 2015, Assignment 3
#   Code authors: [Ashlee Workman, Krish Puri]
#   
#   based on skeleton code by D Crandall

# Importing required libraries
require 'nokogiri'
require 'fast-stemmer'

# This function writes out a hash or an array (list) to a file.
#

def write_data(filename, data)
  file = File.open(filename, "w")
  file.puts(data)
  file.close
end


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



# function that takes the name of a directory, and returns a list of all the filenames in that
# directory.
#
def list_files(dir)
  # Getting all the files names in the directory
  file_names = Dir[dir + "*"]

  return file_names

end


#####################################
# CUSTOM FUNCTIONS
#####################################


# parse_html takes the HTML code of a document and removes all the junk from it in order to return the text
# content on the page

def parse_html(html)
  doc = Nokogiri::HTML(html)

  # Removing style and script tag content such as Javascript tags in order to get rid of JUNK text
  doc.xpath("//script").remove
  doc.xpath("//style").remove
  begin
    text  = doc.at('body').inner_text
  rescue NoMethodError
    puts "NoMethodError"
   # puts file_name
    #title = nil
  end

  return text
end


# remove_punc takes a string containing text and removes all the punctuation from it in order to finally
# return a list of words/tokens in the text

def remove_punc(text)
  word_list = []


  # Checking for correct encoding and reencoding the string if necessary
  if ! text.valid_encoding?
    text = text.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
    end
  
  # Removing puctuation
  words = text.split(/[ ,;{}`~!@#$%^&*<>.:"'|?\\()_+=\/\[\]\-]/)
  
  # Looping though the list, checking for valid words, and changing their case
  for word in words
    word = word[/\w*/]
    word.downcase!
    word_list.push(word)
    end

  # Deleting blanks
  word_list.delete("")

  return word_list

end


# function that takes the *name of an html file stored on disk*, and returns a list
#  of tokens (words) in that file. 
#
def find_tokens(filename)
  html = File.read(filename)

  # Parsing the HTML content of the file
  parsed_html = parse_html(html)
  
  # Converting the text into a list of tokens after removing punctuation
  tokens = remove_punc(parsed_html)

  return tokens
end


# function that takes a list of tokens, and a list (or hash) of stop words,
#  and returns a new list with all of the stop words removed
#
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
#
def stem_tokens(tokens)
  stem_list = []

  # Looping through the list and finding the stem word for each word
  for word in tokens
    word = word[/\w*/]
    s = word.stem
    stem_list.push(s)
    end

  return stem_list
end


# get_title takes a file name a returns the text within the HTML title tag of the file

def get_title(file_name)
  html = File.read(file_name)
  
  doc = Nokogiri::HTML(html)

  begin
    # Grabbing the title from the page
    title = doc.css("title")[0].text.strip
  rescue NoMethodError
    puts "NoMethodError"
    puts file_name
    title = nil 
  end

  return title
end


# get_file_detials takes a file name containg the index and returns the data of the file
# i.e. its name and url in a hash table

def get_file_details(file_name)
  fd = {}
  
  # Looping through the file and updating the name and url variable with the new data
  # and then finally adding them to the hash table
  File.readlines(file_name).each do |line|
    
    data = line.split(" ")
    puts data[2]
    name = data[0]
    url = data[2]

    fd[name] = url
    end
    puts fd
  return fd
end


# index_file takes a file and performs the necessary tasks to index that file in the 
# search engine

def index_file(file, pages_dir, stopwords, file_data)
  # Removing the dir from the file name
   # begin
        actual_name = file.gsub(pages_dir, "")
   # rescue NoMethodError
#      actual_name = badpage.html
    

        # Resetting the file path
        file_path = ""
        file_path = File.expand_path(".") + "/" + file

        print "Parsing HTML document: " + actual_name + " \n"

        # Finding all the tokens in the file
        tokens = find_tokens(file_path)

        # Getting the page title, word count, and page url
        page_title = get_title(file_path)
        word_count = tokens.length
        page_url = file_data[actual_name]

        # Updating the docindex hash
        $docindex[file.gsub(pages_dir, "")] = [word_count, page_title, page_url]

        # Removing the stop words and getting the stem words in the file
        tokens = remove_stop_tokens(tokens, stopwords)
        tokens = stem_tokens(tokens)

        # Creating the invindex hash table
        for token in tokens
          begin
            if $invindex.member?(token)
                        if $invindex[token].member?(actual_name)
                                $invindex[token][actual_name] += 1
                        else
                                $invindex[token][actual_name] = 1
                        end
                else
                        $invindex[token] = {actual_name => 1}
                end
      #  end
#        rescue NoMethodError
 #         puts "NoMethodError"
        end
    #puts file_name
   # title = nil
  end
  #end
end





#################################################
# Main program. We expect the user to run the program like this:
#
#   ruby index.rb pages_dir/ index.dat
#

# The following is just a main program to help get you started.
# Feel free to make any changes or additions/subtractions to this code.
#

# check that the user gave us 3 command line parameters
if ARGV.size != 2
  abort "Command line should have 3 parameters."
end

# fetch command line parameters
(pages_dir, index_file) = ARGV

# Pulling file info for each file from index.dat
file_data = get_file_details("index.dat")


# read in list of stopwords from file and add them to a gloab hash table
stopwords = load_stopwords_file("stop.txt")

# get the list of files in the specified directory
file_list = list_files(pages_dir)


# create hash data structures to store inverted index and document index
#  the inverted index, and the outgoing links

$invindex = {}
$docindex = {}

puts "\nIndexing Started!\n\n"


#######################################################################################
# Single Threaded Algorithm

# Loop through each file in the list of files
#=begin
for file in file_list
  index_file(file_list.pop, pages_dir, stopwords, file_data)
end
#=end

#num_of_doc = hit_list.length




#######################################################################################
########################################################################################
# Multi-Threaded Indexing Algorithm (Extremely Fast - Useful when indexing thousands of pages)

=begin
# Initializing the thread variables (Increase/decrease the open threads if needed)
total_threads = 200
open_threads = 0
files_checked = 0
Thread.abort_on_exception = true

while file_list.length > 0
if open_threads < total_threads
open_threads += 1

Thread.new {
Thread.current["file"] = file_list.pop
index_file(Thread.current["file"], pages_dir, stopwords, file_data)
open_threads -= 1 }
end
end
=end

#########################################################################################


# save the hashes to the correct files
write_data("invindex.dat", $invindex)
write_data("doc.dat", $docindex)

# done!
puts "\nIndexing complete!\n\n";
