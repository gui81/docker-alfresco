# Helper script: replace all newline characters in license and provide it as environment variable
LICENSE_FILE=$1
if [ -z "$LICENSE_FILE" ] ; then
    echo "Call the script as follows:"
    echo ". alfresco_source_license.sh [LICENSE FILE]"
fi
export CROWD_AUTH_LICENSE=`cat $LICENSE_FILE|tr '\n' ' '`
