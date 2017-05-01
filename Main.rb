require './Find_Emails.rb'

dude = Scrape.new
puts "Which industry would you like to search for emails?"  
STDOUT.flush  
industry = gets.chomp  
#dude.find_leads("whale watching")
dude.find_emails(industry)
puts ".........................."
puts "The emails in the list are"
puts ".........................."

dude.email_display() 
puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
puts "the clean version of the emails are... "
puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

dude.clean_all_emails()
#dude.email_purge()
dude.remove_nil_emails()
dude.clean_email_display()

#we need a method to remove duplicates
