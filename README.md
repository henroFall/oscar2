
# oscar2 with Desktop Experience for the Kitchen 
*"Oscar automatically adds things to your grocery list when you run out. You
just scan the item's barcode on its way into the trash." -danslimmon* 

What does Oscar2 do?
----------------
Oscar2 is awesome. With any modern Debian Linux machine (Raspberry Pi included), you can take that machine, a cheap barcode scanner, a free [Trello](https://www.trello.com) account along with a few other bits and pieces.... plus some willpower, and turn it into an automatic grocery list! It might not sound like much, but trust me - it's pretty freaking cool.

Oscar2 takes the brilliance of the original Oscar and adds some cool desktop widgets to a kitchen PC. This completely works on a Raspberry Pi. I moved it onto a NUC to make the web browser more responsive, but YMMV. 

Install Oscar
-------------
To install this version of Oscar, use this command line from a terminal:

`wget -N https://raw.githubusercontent.com/henroFall/oscar2/master/install_oscar.sh && sudo chmod +x install_oscar.sh && sudo -E ./install_oscar.sh`

Follow all prompts and you should be fine. Igore all of the Node complaints about old deprecated packages. They work!

The Story of Oscar
-------------
I stumbled across danslimmon's Oscar a few years ago when I was looking for something exactly like it... I thought to myself one day, "There must be some nerd out there who's hooked a barcode scanner to a Raspberry Pi... I wonder if I could do something to put a grocery list into Trello, or something?" On that day I learned there is truly no original thought left...

Our hero, danslimmon, concocted EXACTLY that almost a decade ago before he grew his beard out, wrote a manifesto, and moved into a trailer on the side of a mountain with no internet or toilet paper. ... Well... we can't know that for sure the fate of danslimmon. What we do know is that danslimmon  has gone totally dark on his github and has not responded to issues for quite some time. I made a fork of his project to fix some issues that have cropped up over time as these modules have gone stale, but otherwise left it alone. Until today. 

Today I have decided to put some more horsepower behind my kitchen computer so I might actually have a functional web browser in there. But after 3 or 4 years, who can remember how to manually stitch this all back together? If I'm going to do it one more time, I might as well make it last!

So, this is my version of Oscar, dubbed Oscar2, enhanced from that abandoned danslimmon project. You can find a link to the original spot down below. In addition to the core functionality of Oscar, I've added:

* A complete installation script with all needed updates to make this old dog hunt
* A routine to detect your barcode scanner port to make this easier when not using a Pi
* No longer uses TCP port 80, because why? That's prime real estate!
* Python2 install to work all the way to Ubuntu 20.04 without issues.
* Trellomerge by GustavePate is bundled. This gives Oscar Desktop the ability to pull your grocery list down and display it as a desktop widget.
* WeatherDesk by bharadwaj-raju is bundled. This gives the Kitchen display dynamic wallpaper based on current time of day and weather!

What I'll need to do before 2021:
* Oscar3! Port Oscar to Python3 - I am still using Python2 because the Trello modules are stuck there.
* I want a fresh set of southbound APIs to decouple from Trello. Trello is fine but there are better options for shared grocery list apps that could receive instructions from Oscar. 
* Go through each of the Node packages and increment up from the legacy versions being used.
* Overall cleanup and refactor to leave this for the ages before I grow my beard out.
 

From the original author:
----------------

Oscar automatically adds things to your grocery list when you run out. You
just scan the item's barcode on its way into the trash.

Here's a video about it!

<a href="http://www.youtube.com/watch?feature=player_embedded&v=9_MNOOgFDg4" target="_blank">
<img src="http://img.youtube.com/vi/9_MNOOgFDg4/0.jpg" alt="Oscar Demo" width="240" height="180" border="10" />
</a>


Getting Started: Hardware
-----

I run Oscar on a [Raspberry Pi][raspberry-pi] under [Raspbian][raspbian]. I use
[this barcode scanner][scanner-amazon].

That said, there's no reason Oscar shouldn't work with other hardware.


Getting Started: Software
-----
I've struck the original author's text here and invite you now to look above for the command line to use for an automatic install. 

Getting Help (obviously this dude isn't going to reply, but I might. Log an issue up there).
-----
I'm [on the Twitters][twitter] if you have a quick question. 

Acknowledgements
-----
WeatherDesk by bharadwaj-raju is bundled. The original is available at https://gitlab.com/bharadwaj-raju/WeatherDesk. I have not modified the source and pull from that repo at install time.

MergeTrelloBoards, by GustavePate is bundled. The original is available at https://github.com/GustavePate/mergetrelloboards . I have not modified the source and pull from that repo at install time.

The original Oscar, of course, by danslimmon. The original is available at https://github.com/danslimmon/oscar . 

The original author gave shoutouts to [CloCkWeRX](https://github.com/CloCkWeRX) for picking up his slack

[raspberry-pi]: http://www.raspberrypi.org/
[raspbian]: http://www.raspbian.org/
[scanner-amazon]: http://www.amazon.com/gp/product/B0085707Z8/ref=oh_details_o03_s00_i03?ie=UTF8&psc=1

