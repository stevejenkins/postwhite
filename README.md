# Postwhite - Automatic Postcreen Whitelist Generator
A script for generating a Postscreen whitelist based on large (and presumably trustworthy) senders' SPF records.

# Why Postwhite?
Postwhite uses the published SPF records of large webmailers (like Gmail and Hotmail) and social networks that send lots of notifications (like Twitter and Facebook) to generate a list of outbound mailer IP addresses and CIDR ranges to create a whitelist for Postscreen.

This allows Postscreen to save time and resources by immediately handing off connections from these hosts (which we can somewhat safely presume are properly configured) to Postfix's smtpd process for further action.

Note this does *not* whitelist any email messages from these hosts. A whitelist for Postscreen (which is merely the first line of Postfix's defense) merely allows listed hosts to connect to Postfix without further tests to prove they are properly configured and/or legitimate senders.

# Requirements
Postwhite runs as a **Bash** script and relies on two scripts from the <a target="_blank" href="https://github.com/jsarenik/spf-tools">SPF-Tools</a> project (**despf.sh** and **simplify.sh**) to help recursively query SPF records. I recommend cloning or copying the entire SPF-Tools repo to ```/usr/local/bin``` on your system, then confirming the ```spftoolspath``` value in ```postwhite```.

# Usage
Once you have spf-tools available on your system, run ```./postwhite``` from the command line. I recommend cloning the entire repo into ```/usr/local/bin/```. Once you're satisfied with its performance, 
set a weekly cron job to pick up any new hosts in the mailers' SPF records, such as this:

    @weekly /usr/local/bin/postwhite/postwhite > /dev/null 2>&1 #Update Postscreen Whitelists

When executed, Postwhite will generate a file named ```postscreen_spf_whitelist.cidr```, write it to your Postfix directory, then optionally reload Postfix to pick up any changes.

Add the whitelist's filename to the ```postscreen_access_list``` option in your Postfix ```main.cf``` file, like this:

    postscreen_access_list = permit_mynetworks,
    ...
            cidr:/etc/postfix/postscreen_spf_whitelist.cidr,
    ...

Then do a manual ```postfix reload``` or re-run ```./postwhite``` to build a fresh whitelist and automatically reload Postfix.

# Options
By default, most mailers are set to "yes," meaning they will be included in the whitelist. You can include or exclude any mailer by changing them to "yes" or "no", like this:

    google=yes
    microsoft=no
    facebook=yes
    twitter=no

In the above example, Postwhite will only include IP addresses from Google and Facebook in the generated whitelist. Additional mailers are added to the script from time to time, so check back periodically for new versions, or "Watch" this repo to receive update notifications.

By default, the option to simplify (remove) invididual IP addresses that are already included in CIDR ranges (handled by the SPT-Tools ```simplify.sh``` script) is set to **no**. Turning this feature on when building a whitelist for more than just a few mailers *dramatically* adds to the processing time required to run Postwhite. Feel free to turn it on to see how it affects the amount of time required to build your whitelist, but if you're whitelisting more than just 3 or 4 mailers, you'll probably want to turn it to "no" again. Having a handful of individual IP addresses in your whitelist that might be redundantly covered by CIDR ranges won't have any appreciable impact on Postscreen's performance.

You can also choose how to handle malformed or invalid CIDR ranges that appear in the mailers' SPF records (which happens more often than it should). The options are:

* **remove** - the default action, it removes the invalid CIDR range so it doesn't appear in the whitelist.
* **keep** - this keeps the invalid CIDR range in the whitelist. Postfix will log a warning about ```non-null host address bits```, suggest the closest valid range with a matching prefix length, and harmlessly ignore the rule. Useful only if you want to see which mailers are less than careful about their SPF records (cough, cough, *Microsoft*, cough, cough).
* **fix** - this option will change the invalid CIDR to the closest valid range (the same one suggested by Postfix, in fact) and include the corrected CIDR range in the whitelist.

Other options include changing the whitelist's filename, Postfix location, spf-tools path location, and whether or not to automatically reload Postfix.

# Credits
* Special thanks to Mike Miller for his 2013 <a target="_blank" href="https://archive.mgm51.com/sources/gwhitelist.html">gwhitelist script</a> that initially got me tinkering with SPF-based Postscreen whitelists. The temp file creation and ```printf``` statement near the end of the Postwhite script are remnants of his original script.
* Thanks to Jan Sarenik (author of <a target="_blank" href="https://github.com/jsarenik/spf-tools">SPF-Tools</a>).
* Thanks to <a target="_blank" href="https://github.com/jcbf">Jose Borges Ferreira</a> for patches and contributions to Postwhite, include internal code to validate CIDRs.
* Thanks to partner (business... not life) <a target="_blank" href="http://stevecook.net/">Steve Cook</a> for helping me cludge through Bash scripting, which really isn't my bag.

# More Info
My blog post discussing how Postwhite came to be is here:

http://www.stevejenkins.com/blog/2015/11/postscreen-whitelisting-smtp-outbound-ip-addresses-large-webmail-providers/

# Known Issues
* I'd love to include Yahoo's IPs in the whitelist, but their SPF record doesn't support queries to expose their netblocks. The closest thing I can find to a published list from Yahoo is here: https://help.yahoo.com/kb/SLN23997.html. I don't know how often it's updated, but it's as good a starting point as any. I'm currently working on a way to scrape those IPs and include them in the whitelist. If you have a suggestion for a more elegant solution, please create an issue and let me know!

* I have no way of validating IPv6 CIDRs yet. For now, the script assumes all SPF-published IPv6 CIDRs are valid and includes them in the whitelist.

* The final sorting of the whitelist isn't ideal (yet). So far, any of the sort options other than simply ```sort -u``` result in valid whitelist entries being removed by the sort. On most Linux systems, the ```sort -V -u``` option works great, but the ```-V``` option isn't available on OSX (and possibly other systems). See the **testdata** directory for examples of different sorting attempts as I try to perfect the sorting. I think part of the problem is that the list contains IPv4 and IPv6 addresses and CIDRs, which use different field delimiters (```.``` vs. ```:```). If you have any suggestions to improve the sorting without losing data, I'm all ears!

# Suggestions for Additional Mailers
If you're a Postfix admin who sees a good number of ```PASS OLD``` entries for Postscreen in your mail logs, and have a suggestion for an additional mail host that might be a good candidate to include in Postwhite, please comment on this issue: https://github.com/stevejenkins/postwhite/issues/2

# Disclaimer
You are totally responsible for anything this script does to your system. Whether it launches a nice game of Tic Tac Toe or global thermonuclear war, you're on your own. :)
