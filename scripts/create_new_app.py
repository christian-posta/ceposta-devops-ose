__author__ = 'ceposta'

#
#
# expects these params:
# 1 -- OSE broker
# 2 -- path to rest API, eg, /broker/rest/ <-- note the trailing slash
# 3 -- domain
# 4 -- user
# 5 -- password
# 6 -- app name
# 7 -- cartridge to use

# Application Created Successfully
# RESULT[0] = Status Code 0
# RESULT[1] = Application URL
# RESULT[2] = Git URL of Application
#
# Error Occurred
# RESULT[0] = Status Code 1
# RESULT[1] = Error Message

import sys, urllib, urllib2, json;

def encodeUserData(username,passwd):
    return "Basic %s" % (("%s:%s" % (username,passwd)).encode('base64').rstrip())

try:
    dict = (("name",sys.argv[6]),("gear_size", "medium"),("cartridges[][name]",sys.argv[7]))
    dict_encode = urllib.urlencode(dict)
    url = "{0}{1}domain/{2}/applications".format(sys.argv[1],sys.argv[2],sys.argv[3])
    req = urllib2.Request(url)
    req.add_header('Accept','application/json')
    req.add_header('Authorization',encodeUserData(sys.argv[4],sys.argv[5]))
    res = urllib2.urlopen(req, dict_encode)
    result = json.loads(res.read())
    print '("{0}" "{1}" "{2}" "{3})'.format("0", result["data"]["app_url"], result["data"]["git_url"],
                                            result["messages"][2]["text"])
except urllib2.URLError, e:
    result = json.loads(e.read())
    print '("{0}" "{1}")'.format("1", result["messages"][0]["text"])
except:
    print ("1")