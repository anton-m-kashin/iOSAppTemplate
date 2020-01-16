#!/bin/sh

TEMPLATES="./templates"

BUNDLE_PREFIX_KEY="<BUNDLE_ID_PREFIX>"
NAME_KEY="<APP_NAME>"
TEAM_ID_KEY="<TEAM_ID>"

usage() {
    echo "Usage: $0 <all|makefile|project|help> <options>"
    echo "       $0 all \\
                        --path </where/to/store/new/app> \\
                        --bundle-prefix <some.company> \\
                        --name <NewApp> \\
                        --team-id <XXXXXX>"
    echo "       $0 makefile --name <NewApp>"
    echo "       $0 project \\
                            --path </where/to/store/new/app> \\
                            --bundle-prefix <some.company> \\
                            --name <NewApp> \\
                            --team-id <XXXXXX>"
}

report_and_fail() {
    MESSAGE="$1"
    if [ -n "$MESSAGE" ]; then
        echo "$MESSAGE" >&2
        echo ""
    fi
    usage >&2
    exit 1
}

makefile_out() {
    NAME=$1
    MAKEFILE_TEMPLATE="${TEMPLATES}/makefile-template"
    sed "s/${NAME_KEY}/${NAME}/g" "$MAKEFILE_TEMPLATE"
}

project_out() {
    BUNDLE_PREFIX=$1; NAME=$2; TEAM_ID=$3
    PROJECT_TEMPLATE="${TEMPLATES}/project-template.yml"
    cat < "$PROJECT_TEMPLATE" \
        | sed "s/${BUNDLE_PREFIX_KEY}/${BUNDLE_PREFIX}/g" \
        | sed "s/${NAME_KEY}/${NAME}/g" \
        | sed "s/${TEAM_ID_KEY}/${TEAM_ID}/g"
}

brewfile_out() {
    BREWFILE_TEMPLATE="${TEMPLATES}/brewfile-template"
    cat "$BREWFILE_TEMPLATE"
}

copy_files() {
    TO_PATH="$1"
    STUBS="./stubs"
    UTILS="./utils"
    cp -R "$STUBS"/* "$TO_PATH"/
    cp -R "$UTILS" "$TO_PATH"/
}

generate_from_templates() {
    TO_PATH=$1; BUNDLE_PREFIX=$2; NAME=$3; TEAM_ID=$4
    brewfile_out > "$TO_PATH"/Brewfile
    project_out "$BUNDLE_PREFIX" "$NAME" "$TEAM_ID" > "$TO_PATH"/project.yml
    makefile_out "$NAME" > "$TO_PATH"/Makefile
}

all() {
    TO_PATH=$1; BUNDLE_PREFIX=$2; NAME=$3; TEAM_ID=$4
    test -d "$TO_PATH" || report_and_fail "${TO_PATH} is not a directory."
    APP_PATH="${TO_PATH}/${NAME}"
    test ! -d "$APP_PATH" \
        || report_and_fail "Path already contains folder ${NAME}."
    mkdir "$APP_PATH"
    copy_files "$APP_PATH"
    generate_from_templates "$APP_PATH" "$BUNDLE_PREFIX" "$NAME" "$TEAM_ID"
}

ACTION=$1
shift

TO_PATH=
BUNDLE_PREFIX=
NAME=
TEAM_ID=
while [ -n "$1" ]; do
    case "$1" in
        --path) shift
                TO_PATH="$1"
                ;;
        --bundle-prefix) shift
                         BUNDLE_PREFIX="$1"
                         ;;
        --name) shift
                NAME="$1"
                ;;
        --team-id) shift
                   TEAM_ID="$1"
                   ;;
    esac
    shift
done

case "$ACTION" in
    all) test -n "$TO_PATH" \
              -a -n "$BUNDLE_PREFIX"\
              -a -n "$NAME" \
              -a -n "$TEAM_ID" \
               || report_and_fail "Check options."
         all "$TO_PATH" "$BUNDLE_PREFIX" "$NAME" "$TEAM_ID"
         ;;
    makefile) test -n "$NAME" \
                    || report_and_fail "App name is not specified."
              makefile_out "$NAME"
              ;;
    project) test -n "$BUNDLE_PREFIX" -a -n "$NAME" -a -n "$TEAM_ID" \
                   || report_and_fail "Check options."
             project_out "$BUNDLE_PREFIX" "$NAME" "$TEAM_ID"
             ;;
    help) usage
          ;;
    *) report_and_fail "Unknown action $1."
       ;;
esac
