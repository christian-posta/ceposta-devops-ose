__author__ = 'ceposta'
'''



BIG NOTE: We dont use this script yet...

it's experimental..

woudd like to get to use it soon...



'''

import sys, urllib, urllib2, json, re;

if len(sys.argv) < 4:
    print "invalid parameters"
    print "args: AppName VersionNumber OSEBrokerUrl OSEDomain"

SOURCE_APP_NAME = sys.argv[1]
VERSION_NUMBER = sys.argv[2]
OPENSHIFT_BROKER = sys.argv[3]
OPENSHIFT_DOMAIN = sys.argv[4]

print "app_name=%s version=%s broker=%s domain=%s" % (SOURCE_APP_NAME, VERSION_NUMBER, OPENSHIFT_BROKER, OPENSHIFT_DOMAIN)

# filter out chars OSE can't deal with
OPENSHIFT_APP_NAME = filter(str.isalnum,SOURCE_APP_NAME+VERSION_NUMBER)
OPENSHIFT_CARTRIDGE_FUSE = "fuse-6.1.1"
HEADER_ACCEPT = "Accept: application/json"
OPENSHIFT_API="/broker/rest/"
OPENSHIFT_USER = "christian"
OPENSHIFT_PASSWORD = "christian"
OPENSHIFT_GEAR_PROFILE = "xpaas"

def encodeUserData(username,passwd):
    return "Basic %s" % (("%s:%s" % (username,passwd)).encode('base64').rstrip())

def get_fuse_attr(text):
    items = ['Console User:', 'Console Password:', 'Zookeeper URL:', 'Zookeeper Password:']
    rc = []
    for t in items:
        m = re.search('(?<='+t+')[^\n]+', text)
        captured = m.group(0).lstrip()
        rc.append(captured)

    return rc


def check_app_exists():
    try:
        url = "{0}{1}domain/{2}/application/{3}?nolinks=true".format(OPENSHIFT_BROKER, OPENSHIFT_API, OPENSHIFT_DOMAIN, OPENSHIFT_APP_NAME)
        req = urllib2.Request(url)
        print "check app exists url " + url
        req.add_header('Accept', HEADER_ACCEPT)
        req.add_header('Authorization', encodeUserData(OPENSHIFT_USER, OPENSHIFT_PASSWORD))
        res = urllib2.urlopen(req)
        print "response " + res.read()
        result = json.loads(res.read())
        if "ok" == result["status"]:
            return True
        else:
            return False

    except :
        return False

def create_app():
    try:
        dict = (
            ("name",OPENSHIFT_APP_NAME),
            ("gear_size", OPENSHIFT_GEAR_PROFILE),
            ("cartridges[]",OPENSHIFT_CARTRIDGE_FUSE)
        )

        dict_encode = urllib.urlencode(dict)
        url = "{0}{1}domain/{2}/applications".format(OPENSHIFT_BROKER, OPENSHIFT_API, OPENSHIFT_DOMAIN)
        print "URL to create app: " + url
        req = urllib2.Request(url)
        req.add_header('Accept', HEADER_ACCEPT)
        req.add_header('Authorization', encodeUserData(OPENSHIFT_USER, OPENSHIFT_PASSWORD))
        print "Please wait..."
        res = urllib2.urlopen(req, dict_encode)
        result = json.loads(res.read())
        fuse_text = result["messages"][2]["text"]
        print fuse_text
        print '("{0}" "{1}" "{2}" "{3}" "{4}" "{5}" "{6}")'.format("0", result["data"]["app_url"], result["data"]["ssh_url"],
                                                                  * get_fuse_attr(fuse_text))
    except urllib2.URLError as e:
        print e
        result = json.loads(e.read())
        print '("{0}" "{1}")'.format("1", result["messages"][0]["text"])
    except RuntimeError as e:
        print e



if __name__ == "__main__":

    if check_app_exists():
        print "This OSE app already exists!!"
    else:
        print "Creating Application..."
        create_app()