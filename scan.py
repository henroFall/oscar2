#!/usr/bin/env python
# -*- coding: utf-8 -*-

from datetime import datetime
import struct
import select
import socket
import random
import json
import urllib2
import hashlib
import hmac
import base64

import trello
from twilio.rest import TwilioRestClient

import smtplib

from lib import trellodb
from lib import conf

#thanks to https://stackoverflow.com/questions/19732978/how-can-i-get-a-string-from-hid-device-in-python-with-evdev

from evdev import InputDevice, categorize, ecodes  

scancodes = {
    # Scancode: ASCIICode
    0: None, 1: u'ESC', 2: u'1', 3: u'2', 4: u'3', 5: u'4', 6: u'5', 7: u'6', 8: u'7', 9: u'8',
    10: u'9', 11: u'0', 12: u'-', 13: u'=', 14: u'BKSP', 15: u'TAB', 16: u'q', 17: u'w', 18: u'e', 19: u'r',
    20: u't', 21: u'y', 22: u'u', 23: u'i', 24: u'o', 25: u'p', 26: u'[', 27: u']', 28: u'CRLF', 29: u'LCTRL',
    30: u'a', 31: u's', 32: u'd', 33: u'f', 34: u'g', 35: u'h', 36: u'j', 37: u'k', 38: u'l', 39: u';',
    40: u'"', 41: u'`', 42: u'LSHFT', 43: u'\\', 44: u'z', 45: u'x', 46: u'c', 47: u'v', 48: u'b', 49: u'n',
    50: u'm', 51: u',', 52: u'.', 53: u'/', 54: u'RSHFT', 56: u'LALT', 57: u' ', 100: u'RALT'
}

capscodes = {
    0: None, 1: u'ESC', 2: u'!', 3: u'@', 4: u'#', 5: u'$', 6: u'%', 7: u'^', 8: u'&', 9: u'*',
    10: u'(', 11: u')', 12: u'_', 13: u'+', 14: u'BKSP', 15: u'TAB', 16: u'Q', 17: u'W', 18: u'E', 19: u'R',
    20: u'T', 21: u'Y', 22: u'U', 23: u'I', 24: u'O', 25: u'P', 26: u'{', 27: u'}', 28: u'CRLF', 29: u'LCTRL',
    30: u'A', 31: u'S', 32: u'D', 33: u'F', 34: u'G', 35: u'H', 36: u'J', 37: u'K', 38: u'L', 39: u':',
    40: u'\'', 41: u'~', 42: u'LSHFT', 43: u'|', 44: u'Z', 45: u'X', 46: u'C', 47: u'V', 48: u'B', 49: u'N',
    50: u'M', 51: u'<', 52: u'>', 53: u'?', 54: u'RSHFT', 56: u'LALT',  57: u' ', 100: u'RALT'
}

def readBarcode(devicePath):

    dev = InputDevice(devicePath)
    dev.grab() # grab provides exclusive access to the device

    x = ''
    caps = False

    for event in dev.read_loop():
        if event.type == ecodes.EV_KEY:
            data = categorize(event)  # Save the event temporarily to introspect it
            if data.scancode == 42:
                if data.keystate == 1:
                    caps = True
                if data.keystate == 0:
                    caps = False

            if data.keystate == 1:  # Down events only
                if caps:
                    key_lookup = u'{}'.format(capscodes.get(data.scancode)) or u'UNKNOWN:[{}]'.format(data.scancode)  # Lookup or return UNKNOWN:XX
                else:
                    key_lookup = u'{}'.format(scancodes.get(data.scancode)) or u'UNKNOWN:[{}]'.format(data.scancode)  # Lookup or return UNKNOWN:XX


                if (data.scancode != 42) and (data.scancode != 28):
                    x += key_lookup

                if(data.scancode == 28):
                    return(x)


CHARMAP_LOWERCASE = {4: 'a', 5: 'b', 6: 'c', 7: 'd', 8: 'e', 9: 'f', 10: 'g', 11: 'h', 12: 'i', 13: 'j', 14: 'k',
                     15: 'l', 16: 'm', 17: 'n', 18: 'o', 19: 'p', 20: 'q', 21: 'r', 22: 's', 23: 't', 24: 'u', 25: 'v',
                     26: 'w', 27: 'x', 28: 'y', 29: 'z', 30: '1', 31: '2', 32: '3', 33: '4', 34: '5', 35: '6', 36: '7',
                     37: '8', 38: '9', 39: '0', 44: ' ', 45: '-', 46: '=', 47: '[', 48: ']', 49: '\\', 51: ';',
                     52: '\'', 53: '~', 54: ',', 55: '.', 56: '/'}
CHARMAP_UPPERCASE = {4: 'A', 5: 'B', 6: 'C', 7: 'D', 8: 'E', 9: 'F', 10: 'G', 11: 'H', 12: 'I', 13: 'J', 14: 'K',
                     15: 'L', 16: 'M', 17: 'N', 18: 'O', 19: 'P', 20: 'Q', 21: 'R', 22: 'S', 23: 'T', 24: 'U', 25: 'V',
                     26: 'W', 27: 'X', 28: 'Y', 29: 'Z', 30: '!', 31: '@', 32: '#', 33: '$', 34: '%', 35: '^', 36: '&',
                     37: '*', 38: '(', 39: ')', 44: ' ', 45: '_', 46: '+', 47: '{', 48: '}', 49: '|', 51: ':', 52: '"',
                     53: '~', 54: '<', 55: '>', 56: '?'}
CR_CHAR = 40
SHIFT_CHAR = 2

def barcode_reader():
    barcode_string_output = ''
    # barcode can have a 'shift' character; this switches the character set
    # from the lower to upper case variant for the next character only.
    CHARMAP = CHARMAP_LOWERCASE
    with open('/dev/hidraw3', 'rb') as fp:
        while True:
            # step through returned character codes, ignore zeroes
            print '1'
            for char_code in [element for element in fp.read(8) if element > 0]:
                if char_code == CR_CHAR:
                    print '2'
                    # all barcodes end with a carriage return
                    return barcode_string_output
                if char_code == SHIFT_CHAR:
                    print '3'
                    # use uppercase character set next time
                    CHARMAP = CHARMAP_UPPERCASE
                else:
                    # if the charcode isn't recognized, add ?
                    print '4'
                    barcode_string_output += CHARMAP.get(char_code, '?')
                    # reset to lowercase character map
                    CHARMAP = CHARMAP_LOWERCASE

def parse_scanner_data(scanner_data):
    upc_chars = []
    print 'Parsing Scanner Data...'
    for i in range(0, len(scanner_data), 16):
        chunk = scanner_data[i:i+16]
        print '-Chunk'
        print i
        print chunk
        # The chunks we care about will match
        # __  __  __  __  __  __  __  __  01  00  __  00  00  00  00  00
        if chunk[8:10] != '\x01\x00' or chunk[11:] != '\x00\x00\x00\x00\x00':
            continue

        digit_int = struct.unpack('>h', chunk[9:11])[0]
        upc_chars.append(str((digit_int - 1) % 10))
        print 'upc_chars'
        print upc_chars
    return ''.join(upc_chars)


class CodeNotFound(Exception): pass
class CodeInvalid(Exception): pass

class UPCAPI:
    BASEURL = 'https://www.digit-eyes.com/gtin/v2_0'

    def __init__(self, app_key, auth_key):
        self._app_key = app_key
        self._auth_key = auth_key

    def _signature(self, upc):
        h = hmac.new(self._auth_key, upc, hashlib.sha1)
        return base64.b64encode(h.digest())

    def _url(self, upc):
        return '{0}/?upcCode={1}&field_names=description&language=en&app_key={2}&signature={3}'.format(
            self.BASEURL, upc, self._app_key, self._signature(upc))

    def get_description(self, upc):
        """Returns the product description for the given UPC.

           `upc`: A string containing the UPC."""
        url = self._url(upc)
        try:
            json_blob = urllib2.urlopen(url).read()
            return json.loads(json_blob)['description'].encode('iso-8859-1')
        except urllib2.HTTPError, e:
            if 'UPC/EAN code invalid' in e.msg:
                raise CodeInvalid(e.msg)
            elif 'Not found' in e.msg:
                raise CodeNotFound(e.msg)
            else:
                raise

class OpenFoodFactsAPI:
    def get_description(self, upc):
        """Returns the product description for the given UPC.

           `upc`: A string containing the UPC."""
        url = 'http://world.openfoodfacts.org/api/v0/product/{0}.json'.format(upc)
        try:
            json_blob = urllib2.urlopen(url).read()
            data = json.loads(json_blob)

            if data['status_verbose'] != 'product found':
              raise CodeNotFound(data['status_verbose'])

            if 'product_name' in data['product']:
              return data['product']['product_name']

            if 'generic_name_en' in data['product']:
              return data['product']['generic_name_en']
        except urllib2.HTTPError, e:
            if 'Not found' in e.msg:
                raise CodeNotFound(e.msg)
            else:
                raise


class FakeAPI:
    def get_description(self, upc):
        raise CodeNotFound("Code {0} was not found.".format(upc))


def local_ip():
    """Returns the IP that the local host uses to talk to the Internet."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("trello.com", 80))
    addr = s.getsockname()[0]
    s.close()
    return addr


def generate_opp_id():
    return ''.join(random.sample('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789', 12))


def opp_url(opp):
    return 'http://{0}/learn-barcode/{1}'.format(local_ip(), opp['opp_id'])



def create_barcode_opp(trello_db, barcode, desc=''):
    """Creates a learning opportunity for the given barcode and writes it to Trello.

       Returns the dict."""
    opp = {
        'type': 'barcode',
        'opp_id': generate_opp_id(),
        'barcode': barcode,
        'desc': desc,
        'created_dt': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }

    trello_db.insert('learning_opportunities', opp)
    return opp


def publish_barcode_opp(opp):
    message = '''Hi! Oscar here. You scanned a code I didn't recognize for a "{1}". Care to fill me in?  {0}'''.format(opp_url(opp), opp['desc'])
    subject = '''Didn't Recognize Barcode'''
    if conf.get()['barcode_api'] == 'openfoodfacts':
      message = '''Hi! Oscar here. You scanned a code I didn't recognize for a "{1}". Care to fill me in?  {0}. Add to http://world.openfoodfacts.org/cgi/product.pl ?'''.format(opp_url(opp), opp['desc'])
    
    communication_method = conf.get()['communication_method']
    if communication_method == 'email':
        send_via_email(message, subject)
    else:
        send_via_twilio(message)

def notify_no_rule(desc, barcode):
    learn_opp = opp_url(create_barcode_opp(trello_db, barcode, desc))
    message = '''Hi! Oscar here. You scanned a code I don't know what to do with barcode {1}: "{0}". Care to fill me in?'''.format(learn_opp, desc )
    subject = '''No rules set for grocery item'''
    communication_method = conf.get()['communication_method']
    if communication_method == 'email':
        send_via_email(message, subject)
    else:
        send_via_twilio(message)

def send_via_twilio(msg):
    client = TwilioRestClient(conf.get()['twilio_sid'], conf.get()['twilio_token'])
    message = client.sms.messages.create(body=msg,
                                         to='+{0}'.format(conf.get()['twilio_dest']),
                                         from_='+{0}'.format(conf.get()['twilio_src']))

def send_via_email(msg, subject):
    to = conf.get()['email_dest']
    gmail_user = conf.get()['gmail_user']
    gmail_pwd = conf.get()['gmail_password']
    smtpserver = smtplib.SMTP("smtp.gmail.com",587)
    smtpserver.ehlo()
    smtpserver.starttls()
    smtpserver.ehlo
    smtpserver.login(gmail_user, gmail_pwd)
    header = 'To:' + to + '\n' + 'From: ' + gmail_user + '\n' + 'Subject: ' + subject + ' \n'
    print '\nSending email...\n'
    message = header + '\n ' + msg +' \n\n'
    smtpserver.sendmail(gmail_user, to, message)
    print 'Email sent.'
    smtpserver.close()

def match_barcode_rule(trello_db, barcode):
    """Finds a barcode rule matching the given barcode.

       Returns the rule if it exists, otherwise returns None."""
    rules = trello_db.get_all('barcode_rules')
    for r in rules:
        if r['barcode'] == barcode:
            return r
    return None


def match_description_rule(trello_db, desc):
    """Finds a description rule matching the given product description.

       Returns the rule if it exists, otherwise returns None."""
    rules = trello_db.get_all('description_rules')
    for r in rules:
        if r['search_term'].encode('utf8').lower() in desc.lower():
            return r
    return None


def add_grocery_item(trello_api, item):
    """Adds the given item to the grocery list (if it's not already present)."""
    # Get the current grocery list
    grocery_board_id = conf.get()['trello_grocery_board']
    all_lists = trello_api.boards.get_list(grocery_board_id)
    grocery_list = [x for x in all_lists if x['name'] == conf.get()['trello_grocery_list']][0]
    cards = trello_api.lists.get_card(grocery_list['id'])
    card_names = [card['name'] for card in cards]

    # Add item if it's not there already
    if item not in card_names:
        print "Adding '{0}' to grocery list".format(item)
        trello_api.lists.new_card(grocery_list['id'], item)
    else:
        print "Item '{0}' is already on the grocery list; not adding".format(item)


trello_api = trello.TrelloApi(conf.get()['trello_app_key'])
trello_api.set_token(conf.get()['trello_token'])
trello_db = trellodb.TrelloDB(trello_api, conf.get()['trello_db_board'])

f = open(conf.get()['scanner_device'], 'rb')

while True:
    print 'Waiting for scanner data'
    print f
    '''# Wait for binary data from the scanner and then read it
    scan_complete = False
    scanner_data = ''
    while True:
        rlist, _wlist, _elist = select.select([f], [], [], 0.1)
        if rlist != []:
            print rlist
            new_data = ''
            while not new_data.endswith('\x01\x00\x1c\x00\x01\x00\x00\x00'):
                new_data = rlist[0].read(16)
                print new_data
                scanner_data += new_data
                print scanner_data
                print
            # There are 4 more keystrokes sent after the one we matched against,
            # so we flush out that buffer before proceeding:
            [rlist[0].read(16) for i in range(4)]
            scan_complete = True
        if scan_complete:
            break

    # Parse the binary data as a barcode
    barcode = parse_scanner_data(scanner_data)
    print 'barcode before:'
    print barcode
    print 'Calling barcode_reader'
    barcode = barcode_reader()
    print 'barcode after:'
    print barcode
    print barcode_string_output
    print "Scanned barcode '{0}'".format(barcode) '''
    barcode = readBarcode("/dev/input/event8")
    print "barcode"
    print barcode
    # Match against barcode rules
    barcode_rule = match_barcode_rule(trello_db, barcode)
    if barcode_rule is not None:
        add_grocery_item(trello_api, barcode_rule['item'])
        continue

    # Get the item's description
    barcode_api = conf.get()['barcode_api']
    if barcode_api == 'zeroapi':
        u = FakeAPI()
    elif barcode_api == 'openfoodfacts':
        u = OpenFoodFactsAPI()
    else:
        u = UPCAPI(conf.get()['digiteyes_app_key'], conf.get()['digiteyes_auth_key'])
    try:
        desc = u.get_description(barcode)
        print "Received description '{0}' for barcode {1}".format(desc, unicode(barcode))
    except CodeInvalid:
        print "Barcode {0} not recognized as a UPC; creating learning opportunity".format(unicode(barcode))
        try:
            opp = create_barcode_opp(trello_db, barcode, desc)
        except:
            opp = create_barcode_opp(trello_db, barcode)
        print "Code not UPC. Publishing learning opportunity"
        publish_barcode_opp(opp)
        continue
    except CodeNotFound:
        print "Barcode {0} not found in UPC database; creating learning opportunity".format(unicode(barcode))
        try:
            opp = create_barcode_opp(trello_db, barcode, desc)
        except:
            opp = create_barcode_opp(trello_db, barcode)
        print "Code not found. Publishing learning opportunity"
        publish_barcode_opp(opp)
        continue

    # Match against description rules
    desc_rule = match_description_rule(trello_db, desc)
    if desc_rule is not None:
        add_grocery_item(trello_api, desc_rule['item'])
    elif len(desc)>0: 
        add_grocery_item(trello_api, desc)  
        print "Got a description but there is no matching Description Rule for '{0}'".format(desc)
        print "   Saving to list with internet description."
    elif len(desc)<1: 
        print "No matching Description Rule for '{0}'".format(desc)
        print "   Sending notification to a human."
        notify_no_rule(desc, barcode)
        continue
