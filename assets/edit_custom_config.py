import os,sys
from xml.etree import ElementTree as ET

configfile='/alfresco/tomcat/shared/classes/alfresco/web-extension/share-config-custom.xml'

doc = ET.parse(configfile)

root = doc.getroot()

def replace_config(root, xpath, value):
    try:
        root.findall(xpath)[0].text = value
        print("Changing "+xpath+" to " + value + ' in ' + configfile)
    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
    except ValueError:
        print "Could not convert data to an integer."
    except:
        print "Unexpected error:", sys.exc_info()[0]
        raise


if os.environ.has_key("WEBDAV_REPOSITORY_URL"):
    replace_config(root,'./config[@condition="DocumentLibrary"]/repository-url', os.environ.get('WEBDAV_REPOSITORY_URL'))


doc.write(configfile)
