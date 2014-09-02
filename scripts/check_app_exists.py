__author__ = 'ceposta'


#
#
# Example how to call this:
# $ python check_app_exists.py https://broker.hosts.pocteam.com /broker/rest/ dev christian christian fuse10 fusesource-fuse-1.0.0
# expects these params:
# 1 -- OSE broker
# 2 -- path to rest API, eg, /broker/rest/ <-- note the trailing slash
# 3 -- domain
# 4 -- user
# 5 -- password
# 6 -- app name
# 7 -- cartridge to use
# Returns
# RESULT[0] = Status Code 0
#
# Application Does Exist
# RESULT[0] = Status Code 2
# RESULT[1] = Application URL
# RESULT[2] = Git URL of Application
#
# Error Occurred
# RESULT[0] = Status Code 1
# RESULT[1] = Error Message
import sys, urllib2, json;

def encodeUserData(username,passwd):
    return "Basic %s" % (("%s:%s" % (username,passwd)).encode('base64').rstrip())

try:
    url = "{0}{1}domain/{2}/application/{3}?nolinks=true".format(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[6])
    print "url to use" + url
    req = urllib2.Request(url)
    req.add_header('Accept','application/json')
    req.add_header('Authorization',encodeUserData(sys.argv[4],sys.argv[5]))
    res = urllib2.urlopen(req)
    result = json.loads(res.read())
    if "ok" == result["status"]:
        print '("{0}" "{1}" "{2}")'.format("2", result["data"]["app_url"], result["data"]["git_url"])
    else:
        print "1"
except urllib2.URLError, e:
    print e
    result = json.loads(e.read())
    if "not_found" == result["status"]:
        print ("0")
    else:
        print '("{0}" "{1}")'.format("1", result["messages"][0]["text"])
except:
    print ("1")
