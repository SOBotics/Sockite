#!/bin/bash
# shell script to build and run in debug mode
echo "Building product..."
swift build
echo "Starting Sockite..."
.build/debug/sockite
EXIT_CODE=$?

while :; do
    if [ $EXIT_CODE -eq 0 ]; then
        echo "Sockite exited with exit code 0, script will be exiting too"
        exit
    elif [ $EXIT_CODE -eq 5 ]; then
        echo "Reboot requested from chat room"
        .build/debug/sockite --reboot
    else
        echo ""
        echo "An error occurred, rebooting Sockite"
        echo ""
        .build/debug/sockite --err
    fi
done
