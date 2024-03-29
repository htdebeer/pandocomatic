#!/usr/bin/env ruby

# input is HTML. Let's add a generator metadata element to tell the world that
# this file has been generated by pandocomatic. Of course, it is easier to add
# that line to the template, but to test the postprocessor, we use this as an
# simple example.
#
# (Note, in a real situation, it is advisable to use a library
# like oga or nokogiri to change a HTML document in a postprocessor)
puts $stdin.read.gsub('<head>', "<head>\n<meta name=\"generator\" content=\"pandocomatic\">")
