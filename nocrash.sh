REV="$(git rev-parse --short HEAD)"
.build/release/sockite --rev $REV
EXIT_CODE=$?

while :; do
    if [ $EXIT_CODE -eq 0 ]; then
        echo "Sockite exited with exit code 0, script will be exiting too"
        exit
    elif [ $EXIT_CODE -eq 5 ]; then
        echo "Reboot requested from chat room"
        .build/release/sockite --reboot --rev $REV
    else
        echo ""
        echo "An error occurred, rebooting Sockite"
        echo ""
        .build/release/sockite --err --rev $REV
    fi
done
