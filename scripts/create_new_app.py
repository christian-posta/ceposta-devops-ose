__author__ = 'ceposta'

#
# python create_new_app.py https://broker.hosts.pocteam.com /broker/rest/ dev christian christian fuse10 fusesource-fuse-1.0.0
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
# RESULT[2] = SSH url
# RESULT[3] = Console User Name
# RESULT[4] = Console Password
# RESULT[5] = ZK URL
# RESULT[6] = ZK Password
#
# Error Occurred
# RESULT[0] = Status Code 1
# RESULT[1] = Error Message

import sys, urllib, urllib2, json, re;

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

try:
    dict = (("name",sys.argv[6]),("gear_size", "medium"),("cartridges[][name]",sys.argv[7]))
    dict_encode = urllib.urlencode(dict)
    url = "{0}{1}domain/{2}/applications".format(sys.argv[1],sys.argv[2],sys.argv[3])
    req = urllib2.Request(url)
    req.add_header('Accept','application/json')
    req.add_header('Authorization',encodeUserData(sys.argv[4],sys.argv[5]))
    res = urllib2.urlopen(req, dict_encode)
    result = json.loads(res.read())
    fuse_text = result["messages"][2]["text"]
    print '("{0}" "{1}" "{2}" "{3}" "{4}" "{5}" "{6}")'.format("0", result["data"]["app_url"], result["data"]["ssh_url"],
                                                              * get_fuse_attr(fuse_text))
except urllib2.URLError, e:
    result = json.loads(e.read())
    print '("{0}" "{1}")'.format("1", result["messages"][0]["text"])
except:
    print sys.exc_traceback[0]
    print ("1")