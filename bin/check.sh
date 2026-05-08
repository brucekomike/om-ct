#!/bin/bash
# */5 * * * * ~/om-ct/bin/check.sh
if curl -s --head http://localhost:80 | grep -E "200 OK|301 Moved Permanently|302 Found" > /dev/null
then
    echo "localhost:80 is responding (possibly with a redirect)."
else
    echo "localhost:80 is not responding. Attempting to start it..."
    if [ -f ~/om-ct/bin/start.sh ] && [ -x ~/om-ct/bin/start.sh ]; then
        ~/om-ct/bin/start.sh
        echo "start.sh executed."
    else
        echo "Error: start.sh not found or not executable."
    fi
fi