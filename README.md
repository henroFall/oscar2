# oscar2
 This is my version of Oscar, enhanced from the abandoned danslimmon project.
 I had created a fork there, but it was never going to get merged, so here we are.
 
oscar
=====
Below are the excellent notes with links to videos from the original author of Oscar. 
I can't find a maintained fork, so I have picked this up. The installer should now run
on any modern Debian Linux. It has been tested on Ubuntu 20.04, 18.04, and Raspbian.

This version still relies on Python 2. I have found that the Trello module used here
does not work in Python 3. I need to research what Python3 to Trello modules exist, and
what code changes in Oscar we'll need to make that work. I think I have until the end of
the year to figure that out. 

I have that project going over at https://github.com/henroFall/oscar3 .

Install Oscar
-------------
To install this version of Oscar, use this command line:

`wget -N https://raw.githubusercontent.com/henroFall/oscar2/dev/install_oscar.sh && sudo chmod +x install_oscar.sh && sudo ./install_oscar.sh`

From the author:
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

To install Oscar, run the included `install.py` as root on the target system. It
will walk you through the process of setting up any API accounts you'll need, and
then it'll install the software.

I haven't really tested that install script, so let's cross our fingers together.


Getting Help (obviously this dude isn't going to reply, but I might. Log an issue up there).
-----

I'm [on the Twitters][twitter] if you have a quick question. For bug reports, use
the [issues page][oscar-issues] or submit a pull request.


Acknowledgements
-----

Thanks to the awesome [CloCkWeRX](https://github.com/CloCkWeRX) for picking up my slack
now that I don't have a Raspberry Pi to test on anymore.


[raspberry-pi]: http://www.raspberrypi.org/
[raspbian]: http://www.raspbian.org/
[scanner-amazon]: http://www.amazon.com/gp/product/B0085707Z8/ref=oh_details_o03_s00_i03?ie=UTF8&psc=1
[twitter]: https://twitter.com/danslimmon
[oscar-issues]: (not maintained anymore, use issues here instead if you want) https://github.com/danslimmon/oscar/issues

