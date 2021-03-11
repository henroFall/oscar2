 
# Oscar2 & the optional Desktop Experience for the Kitchen 
*"Oscar automatically adds things to your grocery list when you run out. You
just scan the item's barcode on its way into the trash." -danslimmon* 

![My Oscar Desktop](https://raw.githubusercontent.com/henroFall/oscar2/master/mydesktop.PNG "My Oscar Desktop")

What does Oscar2 do?
----------------
Oscar is awesome. I didn't make it. I didn't make any of this stuff. I just got tired of manually putting it all together on my kitchen boxes as I upgraded them, and thought that maybe someone else out there in the world might like this.

With any modern (circa 2020) Debian Linux machine (Raspberry Pi included), you can take that machine, a cheap barcode scanner, a free [Trello](https://www.trello.com) account along with a few other bits and pieces.... plus some willpower, and turn it into an automatic grocery list! It might not sound like much, but trust me - it's pretty freaking cool.

Here's a video about it, from Dan, the original author:

<a href="http://www.youtube.com/watch?feature=player_embedded&v=9_MNOOgFDg4" target="_blank">
<img src="http://img.youtube.com/vi/9_MNOOgFDg4/0.jpg" alt="Oscar Demo" width="240" height="180" border="10" />
</a>

Install Oscar
-------------
To install this version of Oscar, paste this command line to a terminal on any server or desktop version of Debian Linux. Raspbian, Ubuntu 18.04, and Ubuntu 20.04 have been tested. Ubuntu 18.04 is recomended for visual purposes. The taskbar is just prettier and hides better, IMO.

`wget -N https://raw.githubusercontent.com/henroFall/oscar2/master/install_oscar.sh && sudo chmod +x install_oscar.sh && sudo -E ./install_oscar.sh`

Follow all prompts and you should be fine. Ignore all of the Node complaints about old deprecated packages. They work, they are secure for what we're doing with them, and I'll deal with that later!

The Story of Oscar
-------------
I stumbled across danslimmon's Oscar a few years ago when I was looking for something exactly like it... I thought to myself one day, "There must be some nerd out there who's hooked a barcode scanner to a Raspberry Pi... I wonder if I could do something to put a grocery list into Trello, or something?" On that day I learned there is truly no original thought left...

Our hero, danslimmon, concocted EXACTLY that almost a decade ago before he grew his beard out, wrote a manifesto, and moved into a trailer on the side of a mountain with no internet or toilet paper. 

...

Well... we can't know for sure the fate of danslimmon. What we do know is that danslimmon  has gone totally dark on this repo and has not responded to issues for quite some time. I made a fork of his project to fix some issues that have cropped up over time as these modules have gone stale, but otherwise left it alone. Until today. 

Today I have decided to put some more horsepower behind my kitchen computer so I might actually have a functional web browser in there. But after 3 or 4 years, who can remember how to manually stitch this all back together? Plus, I tripped over Ubuntu and Intel right away.

So, this is my repackaging of Oscar, dubbed Oscar2, picked up from that abandoned danslimmon project. You can find a link to the original spot down below. In addition to the core functionality of Oscar, I've put in all of the extra dodads I use on my display. What we've got now is:

* A complete installation script with all needed updates to make this old dog hunt
* A routine to detect your barcode scanner port to make this easier when not using a Pi (/dev/input/eventwhatnow?)
* No longer uses TCP port 80, because why? That's prime real estate! User definable port now.
* Python2 install when needed so we're good all the way through Ubuntu 20.04 without issues, along with Python3 and the Pips.
* [Trellomerge][trellomerge] by GustavePate is bundled. This gives Oscar Desktop the ability to pull your grocery list down and display it as a desktop widget.
* [Conky][conky] by brndnmtthws is bundled. This displays your grocery & housewares lists as transparent desktop widgets using the feed from Trellomerge.
* [Harmattan][harmattan] by zagortenay333 is bundled. This is a Conky theme that I use pieces of. 
* [WeatherDesk][weatherdesk] by bharadwaj-raju is bundled. This gives the Kitchen display dynamic wallpaper based on current time of day and weather!
* [Gix-Dock/Cairo-Dock][cairodock] originally by Fabounet is bundled. This is a neat toolbar that I mosly use for the giant analog clock widget.
* [Gis-Weather][gisweather] by RingOV. This is a really nice looking weather widget.


What I'll need to do before 2021:
* You'll see Conky using fancy clock and penguin widgets along with GisWeather on my screenshot. I still need to tweak and bundle those.
* Oscar3! Port Oscar to Python3 - I am still using Python2 because the Trello modules are stuck there. But Python2 is dead, and Pip2 dies in Jan 2021.
* I want a fresh set of southbound APIs to decouple from Trello. Trello is fine but there are better options for shared grocery list apps that could receive instructions from Oscar. 
* Go through each of the Node packages and increment up from the legacy versions being used.
* Add a Cookbook interface of some kind.
* Add some weather widgets and other stuff back. I was using Screenlets but it seems to be dead. I'll find some pretty Conky stuff somewhere...
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

Getting Help (the original dude - log an issue with Oscar2 up there).
-----
I'm [on the Twitters][twitter] if you have a quick question. 

Acknowledgements
-----
WeatherDesk by bharadwaj-raju is bundled. The original is available at https://gitlab.com/bharadwaj-raju/WeatherDesk. I have not modified the source and pull from that repo at install time.

MergeTrelloBoards, by GustavePate is bundled. The original is available at https://github.com/GustavePate/mergetrelloboards . I have not modified the source and pull from that repo at install time.

Conky, by brndnmtthws is bundled. The original is available at https://github.com/brndnmtthws/conky . I have not modified the source and pull from apt at install time.

WeatherDesk, by bharadwaj-raju is bundled. I call a seperate installer from my github, but I have not modified the source and pull from that repo at install time.

Harmattan, by zagortenay333 is bundled. I have not modified the source and pull from that repo at install time.

Help on using EvDev, from:
https://stackoverflow.com/questions/19732978/how-can-i-get-a-string-from-hid-device-in-python-with-evdev


The original Oscar, of course, by danslimmon. The original is available at https://github.com/danslimmon/oscar . 

The original author gave shoutouts to [CloCkWeRX](https://github.com/CloCkWeRX) for picking up his slack

[raspberry-pi]: http://www.raspberrypi.org/
[raspbian]: http://www.raspbian.org/
[scanner-amazon]: https://smile.amazon.com/Embedded-Barcode-Scanner-Alacrity-Portable/dp/B07D78LFWK/ref=sr_1_9?dchild=1&keywords=alacrity+barcode+scanner&qid=1596255508&sr=8-9
[trellomerge]: https://github.com/GustavePate/mergetrelloboards
[conky]: [https://github.com/brndnmtthws/conky]
[weatherdesk]: https://gitlab.com/bharadwaj-raju/WeatherDesk
[harmattan]: https://github.com/zagortenay333/Harmattan
[cairodock]: http://glx-dock.org/
[gisweather]: https://github.com/RingOV/gis-weather
