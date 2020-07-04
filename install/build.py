#!/usr/bin/env python
"""Initial setup script for Oscar. Called by sh.
modified by H from the original at https://github.com/danslimmon/oscar .
This one is at https://github.com/henroFall/oscar ."""

import os
import sys
import subprocess
import re
import trello
from lib import trellodb

yesno = 'n'
usb_port=sys.argv[1]
print "usb port value is"
print usb_port

def run_command(command):
    p = subprocess.Popen(command.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for line in iter(p.stdout.readline, ''):
        print line,
######################################## Initial check
if os.getuid() != 0:
    print "This script should be run as root on the target device. Aborting."
    print
    sys.exit(1)
	
print
print "You need accounts with a few APIs to use Oscar. Any of the keys are copy/paste"
print "so I won't prompt you for confirmation. If you do something wrong, just ride out"
print "the rest of the script and go edit the config file in /etc/oscar.yaml to fix it."
print "When we get to the email/sms part and you have to type stuff in, don't worry, I'll"
print "ask you to confirm your input."
print
######################################## Digit-Eyes
print "First of all, go to"
print
print "    http://www.digit-eyes.com"
print
print "and sign up for an account there. This is the database that"
print "Oscar uses to match barcodes with names of products. When"
print "you're ready, enter your API credentials. They can be"
print "found on the \"My Account\" page."
print 
print "Want to use openfoodfacts.org? Customise /etc/oscar.yaml to"
print "set the barcode_api to 'openfoodfacts'"
print
digiteyes_app_key = raw_input('App Key ("K" Code): ')
digiteyes_auth_key = raw_input('Authorization Key ("M" Code): ')
######################################## Trello
trello_app_key = '95be613d21fcfa29f3580cc3ea4314cf'
print
print "You'll also need a Trello account. You can sign up at:"
print
print "    https://trello.com"
print
print "Once you have an account, go to this URL:"
print
print "    https://trello.com/1/authorize?key={0}&name=oscar&expiration=never&response_type=token&scope=read,write".format(trello_app_key)
print
print "You'll be shown a 'token'; enter it below."
print
trello_token = raw_input('Token: ')
print
print "Now, you'll need your personal app key. Go to this URL:"
print
print "    https://trello.com/app-key"
print
print "NOTE! If you get a 401 Error and a picture of a sleeping dog telling you"
print "that you are not logged in, it means that you are not logged in. Just go"
print "to https://trello.com , log in, then click on https://trello.com/app-key "
print
print "You'll be shown a 'key'; enter it below."
print
trellopersonalkey = raw_input('Key: ')
print
print "OK - One more token! CLick this, copy, paste... you know the"
print "drill by now."
print
print "    https://trello.com/1/authorize?key={0}&name=oscarDesktop&expiration=never&response_type=token&scope=read,write".format(trellopersonalkey)
print
trello_token_desktop = raw_input('Token: ')
print
print "Alright, now, we haven't yet found a way to create boards via the Trello"
print "API, so would you go ahead and create two Trello boards?"
print
print "First create a board called 'Groceries', and enter its URL here:"
print
trello_grocery_board_url = raw_input('Grocery Board URL: ')
print
print "And now create a board called 'oscar_db', and enter its URL here:"
print
trello_db_board_url = raw_input('Trello DB board URL: ')
# Get the board IDs from their URLs
m = re.search('/b/([^/]+)', trello_grocery_board_url)
trello_grocery_board = m.group(1)
m = re.search('/b/([^/]+)', trello_db_board_url)
trello_db_board = m.group(1)
trello_grocery_list = 'Groceries'
######################################## Communication
print
print "Oscar can email or text you when it scans something it doesn't recognize. This"
print "gives you the opportunity to teach Oscar about items you frequently buy."
print "Please choose whether you want oscar to email or text you by typing 'email'"
print "or 'text'."
print
communication_method = raw_input("Communication method ('email' or 'text'): ")
yesno = "n"
while communication_method not in ['email', 'text']:
    communication_method = raw_input("Please input 'email' or 'text': ")
gmail_user = ''
gmail_password = ''
email_dest = ''
twilio_src = ''
twilio_sid = ''
twilio_token = ''
twilio_dest = ''
if communication_method == 'email':
    ######################################## Email
    print
    print "To enable this functionality using email as the communication method, "
    print "you need an account with GMail:"
    print
    print "    https://mail.google.com/"
    print
    print "If you want to, you can sign up for a GMail account and enter your"
    print "information below. If not, no sweat: just leave the input blank. You"
    print "can always come back and modify Oscar's config file later."
    print
    yesno = 'n'
	while yesno != 'y':
        gmail_user = raw_input('GMail Email Address: ')
		print "You entered ",gmail_user
        yesno = raw_input("Are you sure y/[n])? "
	    if gmail_user != '':
            gmail_password = raw_input('GMail Password: ')
            email_dest = raw_input('Destination email (the address you want emailed): ')
        else:
            gmail_password = ''
            email_dest = ''
    else:
        ######################################## Twilio
        print
        print "To enable this functionality using text as the communication method, "
        print "you need an account with Twilio:"
        print
        print "    https://www.twilio.com/"
        print
        print "If you want to, you can sign up for a Twilio account and enter your"
        print "information below. If not, no sweat: just leave the input blank. You"
        print "can always come back and modify Oscar's config file later."
        print
        yesno = 'n'
        while yesno != 'y':
            twilio_src = raw_input('Twilio number: ')
			
            if twilio_src != '':
                twilio_sid = raw_input('Twilio SID: ')
                twilio_token = raw_input('Twilio token: ')
                twilio_dest = raw_input('Destination number (the number you want texted): ')
            else:
                twilio_sid = ''
                twilio_token = ''
                twilio_dest = ''
            # Remove any non-digits from phone numbers
            twilio_src = re.sub('\D', '', twilio_src)
            twilio_dest = re.sub('\D', '', twilio_dest)

        scanner_device = usb_port
        if scanner_device == '':
            scanner_device = '/dev/input/event0'

######################################## Create the appropriate Trello lists
print
print "Creating initial Trello Groceries list and Database items -"
print "For fun, if your web browser is still open to the oscar_db"
print "board, you can watch me create some objects. This will take"
print "up to one minute... Please stand by..."

trello_api = trello.TrelloApi(trello_app_key)
trello_api.set_token(trello_token)
# Grocery list
trello_api.boards.new_list(trello_grocery_board, 'Groceries')
trello_api.boards.new_list(trello_grocery_board, 'Housewares')
# oscar_db lists
for db_list in ['description_rules', 'barcode_rules', 'learning_opportunities']:
    trello_api.boards.new_list(trello_db_board, db_list)
######################################## Create the default description rules
new_rules = [
    {'search_term': 'coffee', 'item': 'coffee'},
    {'search_term': 'soymilk', 'item': 'soy milk'},
    {'search_term': 'soy milk', 'item': 'soy milk'},
    {'search_term': 'soy sauce', 'item': 'soy sauce'},
    {'search_term': 'beer', 'item': 'beer'},
    {'search_term': 'ale', 'item': 'beer'},
    {'search_term': 'sriracha', 'item': 'sriracha'},
    {'search_term': 'milk', 'item': 'milk'},
    {'search_term': 'olive oil', 'item': 'olive oil'},
    {'search_term': 'cereal', 'item': 'cereal'},
    {'search_term': 'peanut butter', 'item': 'peanut butter'},
    {'search_term': 'ketchup', 'item': 'ketchup'},
    {'search_term': 'baking powder', 'item': 'baking powder'},
    {'search_term': 'yeast', 'item': 'yeast'},
    {'search_term': 'baking soda', 'item': 'soda'},
    {'search_term': 'beans', 'item': 'beans'},
    {'search_term': 'bread crumbs', 'item': 'bread crumbs'},
    {'search_term': 'broth', 'item': 'broth'},
    {'search_term': 'cereal', 'item': 'cereal'},
    {'search_term': 'chocolate', 'item': 'chocolate'},
    {'search_term': 'cooking spray', 'item': 'cooking spray'},
    {'search_term': 'cornmeal', 'item': 'cornmeal'},
    {'search_term': 'cornstarch', 'item': 'cornstarch'},
    {'search_term': 'crackers', 'item': 'crackers'},
    {'search_term': 'raisins', 'item': 'raisins'},
    {'search_term': 'vanilla extract', 'item': 'vanilla extract'},
    {'search_term': 'flour', 'item': 'flour'},
    {'search_term': 'mayo', 'item': 'mayo'},
    {'search_term': 'garlic', 'item': 'garlic'},
    {'search_term': 'pasta', 'item': 'pasta'},
    {'search_term': 'bacon', 'item': 'bacon'},
    {'search_term': 'bread', 'item': 'bread'},
    {'search_term': 'potatoes', 'item': 'potatoes'},
    {'search_term': 'rice', 'item': 'rice'},
    {'search_term': 'soup', 'item': 'soup'},
    {'search_term': 'sugar', 'item': 'sugar'},
    {'search_term': 'tea', 'item': 'tea'},
    {'search_term': 'tuna', 'item': 'tuna'},
    {'search_term': 'evaporated milk', 'item': 'evaporated milk'},
    {'search_term': 'vinegar', 'item': 'vinegar'},
    {'search_term': 'eggs', 'item': 'eggs'},
    {'search_term': 'chips', 'item': 'chips'},
]

trello_db = trellodb.TrelloDB(trello_api, trello_db_board)

for rule in new_rules:
    trello_db.insert('description_rules', rule)
######################################## Oscar configs
print "Opening file for yaml..."
if not os.path.exists('/etc/oscar.yaml'): 
    os.mknod('/etc/oscar.yaml')

oscar_yaml = open('/etc/oscar.yaml', 'w+')
oscar_yaml.write('''---
port: 79
scanner_device: '{scanner_device}'

communication_method: '{communication_method}'

gmail_user: '{gmail_user}'
gmail_password: '{gmail_password}'
email_dest: '{email_dest}'

twilio_src: '{twilio_src}'
twilio_dest: '{twilio_dest}'
twilio_sid: '{twilio_sid}'
twilio_token: '{twilio_token}'

trello_app_key: '{trello_app_key}'
trello_token: '{trello_token}'
trello_grocery_board: '{trello_grocery_board}'
trello_grocery_list: '{trello_grocery_list}'
trello_db_board: '{trello_db_board}'

digiteyes_app_key: '{digiteyes_app_key}'
digiteyes_auth_key: '{digiteyes_auth_key}'

# possible values: 'digiteyes', 'openfoodfacts' or 'zeroapi'
barcode_api: digiteyes
'''.format(**locals()))
oscar_yaml.close()

sup_oscar_scan = open('/etc/supervisor/conf.d/oscar_scan.conf', 'w+')
sup_oscar_scan.write('''[program:oscar_scan]

command=python /var/oscar/scan.py
stdout_logfile=/var/log/supervisor/oscar_scan.log
redirect_stderr=true''')
sup_oscar_scan.close()

sup_oscar_web = open('/etc/supervisor/conf.d/oscar_web.conf', 'w+')
sup_oscar_web.write('''trello_app_key: '{trello_app_key}'
trello_token: '{trello_token}'
trello_grocery_board: '{trello_grocery_board}'
trello_grocery_list: '{trello_grocery_list}'
trello_db_board: '{trello_db_board}'
''')
sup_oscar_web.close()

sup_oscar_scan = open('/var/oscar/mergetrelloboards/tapp.txt', 'w+')
sup_oscar_scan.write(trellopersonalkey)
sup_oscar_scan.close()
sup_oscar_scan = open('/var/oscar/mergetrelloboards/ttd.txt', 'w+')
sup_oscar_scan.write(trello_token_desktop)
sup_oscar_scan.close()
sup_oscar_scan = open('/var/oscar/mergetrelloboards/ttoken.txt', 'w+')
sup_oscar_scan.write(trello_token)
sup_oscar_scan.close()
sup_oscar_scan = open('/var/oscar/mergetrelloboards/tgb.txt', 'w+')
sup_oscar_scan.write(trello_grocery_board)
sup_oscar_scan.close()
sup_oscar_scan = open('/var/oscar/mergetrelloboards/tgl.txt', 'w+')
sup_oscar_scan.write(trello_grocery_list)
sup_oscar_scan.close()

print 'Files closed.'
print
print '############################################################'
print
print 'Done! Your new grocery list can be found at:'
print
print '    {0}'.format(trello_grocery_board_url)
print
print 'If everything worked, then you should be able to start scanning'
print 'barcodes with oscar. Check out the logs of the scanner process and'
print 'the web app, respectively, at'
print
print '    /var/lib/supervisor/log/oscar_scan.log'
print '    /var/lib/supervisor/log/oscar_web.log'
print
print 'And report any bugs at https://github.com/henrofall/oscar/issues.'
print 'Oscar 0.2.x was modified by H from the original danslimmon/oscar.'
print 'This also includes a bugfix by roopkeed.'
print
print 'All credit to danslimmon for creating this excellent thing.'
print
print 'To add new product description keywords, the current method is to'
print 'edit the oscar_db board directly.'