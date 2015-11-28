# Postwhite - Automatic Postcreen Whitelist Generator
A script for generating a Postscreen whitelist based on large (and presumably trustworthy) senders' SPF records.

# Why Postwhite?
Postwhite uses the published SPF records of large webmailers (like Gmail and Hotmail) and social networks that send lots of notifications (like Twitter and Facebook) to generate a list of outbound mailer IP addresses and CIDR ranges to create a whitelist for Postscreen.

This allows Postscreen to save time and resources by immediately handing off connections from these hosts (which we can somewhat safely presume are properly configured) to Postfix's smtpd process for further action.

Note this does *not* whitelist any email messages from these hosts. A whitelist for Postscreen (which is merely the first line of Postfix's defense) merely allows listed hosts to connect to Postfix without further tests to prove they are properly configured and/or legitimate senders.

# Requirements
Postwhite runs as a **Bash** script and relies on two additional scripts to function properly:

* **despf.sh** from the SPF-Tools suite (https://github.com/jsarenik/spf-tools) to recursively query SPF records. I recommend cloning or copying the entire SPF-Tools repo to ```/usr/local/bin``` on your system, then confirm the ```spftoolspath``` value in ```postwhite```.
* **ipcalc** (http://jodies.de/ipcalc) to validate IPv4 addresses and CIDR ranges. ipcalc has been stable since 2006, so the final version of ipcalc is included in the Postwhite repo to make things easy. The default path is set in ```postwhite```, but feel free to store it wherever you like and update the path.

# Usage
Once you have spf-tools and ipcalc available on your system, run ```./postwhite``` from the command line. I recommend cloning the entire repo into ```/usr/local/bin/```. Once you're satisfied with its performance, set a weekly cron job to pick up any new hosts in the mailers' SPF records.

When executed, Postwhite will generate a file named ```postscreen_spf_whitelist.cidr```, write it to your Postfix directory, then optionally reload Postfix to pick up any changes.

Add the whitelist's filename to the ```postscreen_access_list``` option in your Postfix ```main.cf``` file, like this:

    postscreen_access_list = permit_mynetworks,
    ...
            cidr:/etc/postfix/postscreen_spf_whitelist.cidr,
    ...

Then do a manual ```postfix reload``` or re-run ```./postwhite``` to build a fresh whitelist and automatically reload Postfix.

# Options
By default, webmailers and social networks are turned ON, meaning they will be included in the whitelist. Bulk senders are turned off by default, but you can toggle any mailer by changing them to "yes" or "no", like this:

    google=yes
    microsoft=no
    facebook=yes
    twitter=no

In the above example, Postwhite will only include IP addresses from Google and Facebook in the generated whitelist. Additional mailers are added to the script from time to time, so check back periodically for new versions, or "Watch" this repo to receive update notifications.

You can also choose how to handle malformed or invalid CIDR ranges that appear in the mailers' SPF records (which happens more often than it should). The options are:

* **strip** - the default action, it removes the invalid CIDR range so it doesn't appear in the whitelist.
* **keep** - this keeps the invalid CIDR range in the whitelist. Postfix will log a warning about ```non-null host address bits```, suggest the closest valid range with a matching prefix length, and harmlessly 
ignore the rule. Useful only if you want to see which mailers are less than careful about their SPF records (cough, cough, *Microsoft*, cough, cough).
* **fix** - this option will change the invalid CIDR to the closest valid range (the same one suggested by Postfix, in fact) and include the corrected CIDR range in the whitelist.

Other options include changing the whitelist's filename, Postfix location, spf-tools path location, ipcalc location, and whether or not to automatically reload Postfix.

# Credits
* Special thanks goes to Mike Miller for his 2013 gwhitelist script (https://archive.mgm51.com/sources/gwhitelist.html) that initially got me tinkering with SPF-based Postscreen whitelists. The temp file creation and ```printf``` statement near the end of the Postwhite script are remnants of his original script.
* Thanks to Jose Borges Ferreira (author of SPF-Tools) for suggesting I could use ipcalc to help validate CIDRs, and for providing a patch to help get me started.
* Thanks to partner (business... not life) Steve Cook for helping me cludge through Bash scripting, which really isn't my bag.

# More Info
My blog post discussing how Postwhite came to be is here:

http://www.stevejenkins.com/blog/2015/11/postscreen-whitelisting-smtp-outbound-ip-addresses-large-webmail-providers/

# Known Issues
* I'd love to include Yahoo's IPs in the whitelist, but their SPF record doesn't support queries to expose their netblocks. The closest thing I can find to a published list from Yahoo is here: https://help.yahoo.com/kb/SLN23997.html. I don't know how often it's updated, but it's as good a starting point as any. I'm currently working on a way to scrape those IPs and including them in the whitelist. If you have a suggestion for a more elegant solution, please create an issue and let me know!

* I have no way of validating IPv6 CIDRs yet. For now, the script assumes all SPF-published IPv6 CIDRs are valid and includes them in the whitelist.

# Suggestions for Additional Mailers
If you're a Postfix admin who sees a good number of ```PASS OLD``` entries for Postscreen in your mail logs, and have a suggestion for an additional mail host that might be a good candidate to include in Postwhite, please comment on this issue: https://github.com/stevejenkins/postwhite/issues/2

# Disclaimer
You are totally responsible for anything this script does to your system. Whether it launches a nice game of Tic Tac Toe or global thermonuclear war, you're on your own. :)
