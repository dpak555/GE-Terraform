# verify we can get a successful authentication via api calls
# then make use of that authentication to get the current SSO settings

import json
import requests
import sys
import argparse


parser = argparse.ArgumentParser(description='Activate Linux Installation')
parser.add_argument('--skipverifycert',help='Verify Certificate (defaults to true)',action='store_true')
parser.add_argument('--baseurl',help='Base Sisense URL')
parser.add_argument('--username',help='Username')
parser.add_argument('--password',help='Password')
args = parser.parse_args()
# print (args)
args = parser.parse_args()

# during development the base url is hitting the proxy we have in use
# consider adding amazonaws.com to the .ge.com we already have in NO_PROXY env

# replace this later and get the token
# SISENSE_BASE_URL = 'https://internal-elb503036077foraec3ea17314468df-2097119905.us-east-1.elb.amazonaws.com:3389/api/v1/'
SISENSE_BASE_URL = args.baseurl
# CHECKCERT = False

if (args.skipverifycert):
    CHECKCERT = False
else:
    CHECKCERT = True
    # default to true

# using self signed during development
# will later make use of GE signed cert, and will then need to make the GE signing authority bundle availability_zones

#EMAIL = 'sample@sample.com'
EMAIL = args.username
# PASSWORD = 'Sample1!s'
PASSWORD = args.password

# for development only, will be destroyed in hours, and these entries will be made parameters

url=SISENSE_BASE_URL+"/license/activate"
head = {'Content-type':'application/json',
             'Accept':'application/json'}
payload = {'email':EMAIL,
               'password':PASSWORD}
# notice change of username to email for parameter

payld = json.dumps(payload)
print ("url " + url)
ret = requests.post(url,headers=head,data=payld,verify=CHECKCERT)
print ("The result is "+ ret.text)
print ("status code is " + str(ret.status_code))
if (ret.raise_for_status()):
    print ("Did not receive successful authentication")
    sys.exit(ret.status_code)
