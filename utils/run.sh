#!/bin/sh

usage() {
    echo "Usage: $0 <device|simulator> --app_path </path/to/app> [options]"
    echo "    where:"
    echo "        --app_path </path/to/app> -- path to app bundle"
    echo "        --device <device id> -- device or simulator identifier"
    echo "            device UUID (can be determined with \"ios-deploy -c\""
    echo "            simulator name or UUID (\"xcrun simctl list\")"
    echo "        --debug -- run debugger"
}

device() {
    APP=$1; DEVICE=$2; DEBUG=$3
    cmd="ios-deploy --bundle ${APP}"
    if [ -n "$DEVICE" ]; then
       cmd="${cmd} --id ${DEVICE}"
    fi
    if [ -n "$DEBUG" ]; then
        cmd="${cmd} --debug --nostart"
    else
        cmd="${cmd} --justlaunch"
    fi
    eval "$cmd"
}

simulator() {
    APP=$1; SIMULATOR=$2; DEBUG=$3
    BUNDLE_ID=$(defaults read "${APP}/Info" CFBundleIdentifier)
    BUNDLE_EXECUTABLE=$(defaults read "${APP}/Info" CFBundleExecutable)
    if [ -z "$SIMULATOR" ]; then
        SIMULATOR="iPhone 8"
    fi
    if [ -z "$BUNDLE_ID" ]; then
        echo "Cannot read Bundle ID" >&2
        usage
        exit 1
    fi
    xcrun simctl boot "$SIMULATOR"
    xcrun simctl install "$SIMULATOR" "$APP" || exit 1
    if [ -n "$DEBUG" ]; then
        (
            # 'simctl launch' has an option '--wait-for-debugger'
            # but in doesn't look working in Xcode 11.3.
            # Code below will delay app start to start debugger first.
            sleep 1
            xcrun simctl launch "$SIMULATOR" "$BUNDLE_ID"
            open -g -a Simulator.app
        )&
        xcrun lldb \
              --attach-name "$BUNDLE_EXECUTABLE" \
              --wait-for \
              -- "$APP"
    else
        xcrun simctl launch "$SIMULATOR" "$BUNDLE_ID"
        open -a Simulator.app
    fi
}

ACTION=$1
shift

APP=
DEVICE=
DEBUG=
while [ -n "$1" ]; do
    case "$1" in
        --app_path) shift
                    APP=$1
                    ;;
        --device)   shift
                    DEVICE=$1
                    ;;
        --debug)    DEBUG=1
                    ;;
    esac
    shift
done
if [ ! -d "$APP" ]; then
    echo "App path not specified"
    echo ""
    usage >&2
    exit 1
fi

case "$ACTION" in
    device)    device "$APP" "$DEVICE" "$DEBUG" ;;
    simulator) simulator "$APP" "$DEVICE" "$DEBUG" ;;
    help)      usage ;;
    *)         usage >&2; exit 1 ;;
esac
