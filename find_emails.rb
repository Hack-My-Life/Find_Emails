require 'nokogiri'
require 'mechanize'
require 'anemone'

module Anemone
  class Core
    def kill_threads
      @tentacles.each { |thread| 
        Thread.kill(thread)  if thread.alive?
      }
    end
  end
end

class Scrape

  def initialize
    @urlCounter = 0
    @serpNum = 1
    @killCounter = 0
    @wpHook = "powered+by+wordpress"
    @randomAgent = ['Mac Mozilla', 'Linux Mozilla', 'Linux Firefox', 'Windows Mozilla', 'Linux Konqueror' ]
    @currentAgent = ''
    @url_spitter = []
    $anemoneCounter  = 0
    $allUrls = []
    $emailUrls = []
    $emails = []
  end

  def query_string(industryName)
    #-------------------------------------------------------------------------------------
    #creates a seach_param string, to be used in google based on industryName
    #-------------------------------------------------------------------------------------
    industryFormatted = space_conv(industryName)
    search_param = "http://www.google.com/search?q=" + industryFormatted + "+" + @wpHook
    #search_param = "https://duckduckgo.com/?q=" + industryFormatted + "+" + @wpHook
    return search_param
  end

  def space_conv(string)
    #-------------------------------------------------------------------------------------
    #swaps spaces for "+" signs
    #-------------------------------------------------------------------------------------
    return string.gsub(" ", "+")
  end

  def google_url_conv(string)
    #-------------------------------------------------------------------------------------
    #swaps spaces for "+" signs
    #NOTE: eventually the puts statements should be removed
    #-------------------------------------------------------------------------------------
    return string.gsub("/url?q=", "")
  end

  def agent_randomize()
    @currentAgent = @randomAgent[rand(5)]
    theCurrentAgent = @currentAgent
    puts "The current agent = " + theCurrentAgent.to_s
    return theCurrentAgent
  end

  def find_emails(industryString)
  #-------------------------------------------------------------------------------------
  #This is the main call
  #-------------------------------------------------------------------------------------
    collection = find_leads(industryString)
    #seems that collection is not a real array
    puts "The collection variable is of type array, right? " + collection.is_a?(Array).to_s
    puts "find_emails(industryString): the URLs array currently has " + collection.count().to_s + " items in it"
    puts "they are " + collection[0].to_s + " and " + collection[1].to_s
    scrape_urls(collection)
  end

  def find_leads(industryString)
    #-------------------------------------------------------------------------------------
    #Based on an industry string, such as "dental whiting" will find a list of sites to 
    #search based on Google Search Results. Uses @serpNum to determine how SERPs to crawl
    #-------------------------------------------------------------------------------------
    agent = Mechanize.new
    agent.user_agent_alias = agent_randomize()
    for current_iteration_number in 1..@serpNum do
      begin
        page = agent.get query_string(industryString)
        doc = Nokogiri::HTML(open(page.uri.to_s))
        doc.xpath('//h3/a').each do |node|
          holder = node['href'].to_s
          puts "..."
          cleanURL = google_url_conv(holder)
          $allUrls[@urlCounter] = cleanURL
          puts "..."
          puts cleanURL
          @urlCounter += 1
        end
      #pause so as not to trigger google
      sleep(20 + Random.rand(11))
      page = agent.page.link_with(:text => 'Next').click 
      rescue Mechanize::ResponseCodeError
        # Server-side failure, so let's try again after a quick break
        puts "we are now handling an exception, let's give it a 10 sec break . . ."
        sleep(10)
        #page = agent.page.link_with(:text => 'Next').click  -> it worked in last commit, not sure what the issue is
        #it even got us from 10 to 20 serps in last commmit
      #ensure
        #return $allUrls
      end
    end
      @url_spitter = $allUrls
      return @url_spitter
  end


  def email_clean(email)
    #-------------------------------------------------------------------------------------
    #uses a series of regex-based .gsub calls to remove false positives from email list
    #also removes extra characters around good email addresses. We can chain these and
    #put the call all on a single line.
    #-------------------------------------------------------------------------------------
    email = email.gsub(/<.*/, "")
    email = email.gsub(/>.*/, "")
    email = email.gsub(/href=/, "")
    email = email.gsub(/mailto:/, "")
    email = email.gsub(/href=/, "")
    email = email.gsub(/value=/, "")
    email = email.gsub(/content=/, "")
    email = email.gsub(/title=/, "")
    email = email.gsub(/type=/, "")
    email = email.gsub(/class=/, "")
    email = email.gsub(/email:/, "")
    email = email.gsub(/https?:/, "")
    email = email.gsub(/www:/, "")
    email = email.gsub(/google/, "")
    email = email.gsub(/"/, "")
    email = email.gsub( /(?:\s|^)@.*/ , "") #removes strings that start with "@"
    #email = email.gsub( /(?:\s|^){.*/ , "")
    email = email.gsub(/maps.*/, '')
    return email
  end

  def scrape_urls(urls)
    #think about who calls this and what is getting returned
    puts "******************"
    puts "this part will take a while"
    puts "we are scrapping every site contained in allUrls[]"
    puts "there are " + urls.count.to_s + " items in the array"
    urls.each_with_index do |url, i|
      puts "now crawling site #{i} <--------"
      has_email?(url)
    end
  end

  def has_email?(listingUrl)
  #-------------------------------------------------------------------------------------
  #Given a URL, this method will scape a certain number of pages on that site, looking
  #for an email address. That number is related to @killCounter.
  #-------------------------------------------------------------------------------------
   hasListing = false
   Anemone.crawl(listingUrl) do |anemone|
    anemone.on_every_page do |page| #need to limit this to first 20
      puts "now crawling page " + @killCounter.to_s
      @killCounter += 1 
      if @killCounter > 8 #Need to create a class variable for this numer that we can edit at the top of the file
       @killCounter = 0
        puts "The current value of hasListing is ..."
        puts hasListing
        return hasListing
        #raise StopIteration
        #break
        #anemone.kill_threads
      end
      body_text = page.body.to_s
      #matchOrNil = body_text.match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
      matchOrNil = body_text.match(/[^@\s]+@[^@\s]+/)
      puts "The current value of matchOrNil is ..."
      puts matchOrNil
      if matchOrNil != nil
       	#should break the contents out into a method
        $emailUrls[$anemoneCounter] = listingUrl
        $emails[$anemoneCounter] = matchOrNil
        $anemoneCounter += 1
        hasListing = true 
      end
    end
   end
   return hasListing
  end

  def email_display()
    puts "email_vomit() has been called!!!!"
  	$emails.each do |item|
      puts "we are now looping!"
  		#puts item.to_s
      puts item.to_s
    end
  end

  def clean_all_emails()
    #this next line is not getting called???
    puts "clean_all_emails has been called!!!!"
    $emails.each do |item|
      puts "we are now looping!"
      item = email_clean(item.to_s) #changed this line
    end
  end

  def remove_nil_emails()
    puts "remove_nil_emails() has been called!!!!"
    $emails.reject! { |s| s.to_s.nil? || s.to_s.strip.empty? } #changed this line
    #want to insert a line below this one, getting rid of all the strings that start w/ "@****"
    puts "we are done looping!"
  end

  def clean_email_display()
    puts "clean_vomit() has been called!!!!"
    #here's the extra line
    #$emails.reject! { |s| s.nil? || s.strip.empty? }
    $emails.each do |item|
      #puts "we are now looping!"
      puts email_clean(item.to_s)
    end
  end 

  def email_purge()
    puts "email_purge() has been called!!!!"
    $emails.reject! { |item| item.to_s.start_with?(' ') }
    #$emails.reject! { |item| item.to_s.is_equal?(nil) }
  end

end #of class definition

#Extra function calls moved to Main.rb
