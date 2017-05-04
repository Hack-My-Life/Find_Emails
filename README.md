# About this Repo

This Git repo is sponsored by the [Hack My Life] (https://meetup.com/hack-my-life/) meetup group of Richardson, TX. Special thanks also goes out the slack community of [RemoteCoder.net] (http://www.remotecoder.net) for their support. 

The code is utilized by running the main.rb script, which calls the methods defined in the Scrape class of find_emails.rb.

To minimize the chance of triggering HTTP Access Error's it is best to connect to a VPN before running the code. As a best practice, we have found it beneficial to change VPN endpoints between runs, whenever possible. 

Feel free to experiment with whatever VPN services you prefer. To get up and running quickly, you can try free account with [Tunnel Bear] It provides limited bandwidth, but is easy to get up and running and facilitates toggling endpoints between runs. 

At this point, the code's main issues revolve around the fact that the output of emails printed to screen contains a good number of "false positives" (aka strings which do not contain email addresses) as well as email addresses which contain unnecessary extra characters appended to them. 

We could also use help formatting this dock using markdown, as well as with the inclusion of versions on which the code has been tested and installation instructions.
