__author__ = 'ceposta'
import sys, urllib2, json;

# http://fuse102-dev.openshift.com
FUSE_ROOT_URL = sys.argv[1]

# app name, eg, fuse102
FUSE_APP_NAME = sys.argv[2]

FUSE_CONSOLE_PASSWORD = sys.argv[3]



def encodeUserData(username,passwd):
    return "Basic %s" % (("%s:%s" % (username,passwd)).encode('base64').rstrip())

try :
    url = "{0}/jolokia/exec".format(FUSE_ROOT_URL)
    dict = {}
    dict["operation"] = "getContainer(java.lang.String,java.util.List)"
    dict["type"] = "exec"
    dict["mbean"] = "io.fabric8:type=Fabric"
    dict["arguments"] = [FUSE_APP_NAME, ["sshUrl"]]
    req = urllib2.Request(url)
    req.add_header('Accept','application/json')
    req.add_header('Authorization',encodeUserData("admin",FUSE_CONSOLE_PASSWORD))
    res = urllib2.urlopen(req, json.dumps(dict))
    result = json.loads(res.read())
    print '("{0}" "{1}")'.format("0", result["value"]["sshUrl"])

except Exception, e:
    print '("{0}" "{1}")'.format("1", e)
