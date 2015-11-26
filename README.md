# Postwhite - Automatic Postcreen Whitelist Generator
A script for generating a whitelist for Postfix's Postscreen based on large (and presumably trustworthy) senders' SPF records.

# Why Postwhite?
Postwhite uses the published SPF records of large webmailers (like Gmail and Hotmail) and social networks that send lots of notifications (like Twitter and Facebook) to generate a list of their IP addresses and CIDR ranges to include in a whitelist for Postscreen. This allows Postscreen to save time and resources by immediately handing off connections from these hosts to Postfix's smtpd process for further action.

Note this does not whitelist email from these hosts. It merely tells Postscreen (the first line of Postfix's defense) that these hosts are allowed to connect to Postfix without further tests to prove they are properly configured and/or legitimate senders.

# Requirements
Postwhite requires jsarenik's spf-tools stuie (https://github.com/jsarenik/spf-tools). Clone or copy the project to your local system, then set the ```spftoolspath``` option in ```postwhite.sh```.

# Usage
Once you have the required spf-tools script available on your system, you can run ```./postwhite.sh``` from the command line or via a cron job. I recommend storing it somwhere such as ```/usr/local/bin/postwhite/postwhite.sh```

When executed, Postwhite will generate a file named ```postscreen_spf_whitelist.cidr``` in your Postfix directory then optionally reload Postfix to pick up any changes.

Add the filename to the ```postscreen_access_list``` option in your Postfix ```main.cf``` file, like this:

    postscreen_access_list = permit_mynetworks,
    ...
            cidr:/etc/postfix/postscreen_spf_whitelist.cidr,
    ...

Then do a manual ```postfix reload``` or re-run ```./postwhite.sh``` to build a fresh whitelist and automatically reload Postfix.
# Options
By default, all available mailers are turned ON, meaning they will be included in the whitelist. You can turn individual mailers OFF but either commenting them out or changing them to "no", like this:

    google=yes
    microsoft=no
    facebook=yes
    twitter=no

In the above example, Postwhite will only include IP addresses from Google and Facebook in the generated whitelist.

You can also change the whitelist's filename, Postfix location,  spf-tools path location, and whether or not to automatically reload Postfix at the top of the file.

# Credits
Special thanks goes to Mike Miller for his 2013 gwhitelist script (https://archive.mgm51.com/sources/gwhitelist.html) that initially got me tinkering with SPF-based Postscreen whitelists. The temp file creation and ```printf``` statement near the end of the Postwhite script are remnants of his original script.

# More Info
My blog post discussing how Postwhite came to be is here:

http://www.stevejenkins.com/blog/2015/11/postscreen-whitelisting-smtp-outbound-ip-addresses-large-webmail-providers/

# Known Issues
There is currently no mechanism to validate the CIDR ranges produced by the SPF queries. One might assume that large webmailers would be careful not to publish invalid IP ranges... but you'd be wrong. :) Microsoft is currently publishing **two** invalid IP addresses (207.68.169.173/30 and 65.55.238.128/26) in their SPF record for _spf-ssg-b.microsoft.com. Technically they're publishing three invalid IPs, but two of them are duplicates.

I'm currently looking for a way to validate the CIDR ranges before including them in the whitelist, and ignoring any invalid ones. If you have a good idea how do to that, please fork and/or start a pull request.

Anothe issue is that I'd love to include Yahoo's IPs in the whitelist, but their SPF record doesn't support queries to expose their netblocks. The closest thing I can find to a published list from Yahoo is here: https://help.yahoo.com/kb/SLN23997.html

I don't know how often it's updated, but it's as good a starting point as any. Currently working on scraping those IPs and including them in the whitelist.
