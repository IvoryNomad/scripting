# source this file, do not execute it

echoerr () {
    printf "$@" >&2
}

check_for_bash () {                                                              
    # call as 'check_for_bash "${BASH}"'
    if [ -z "$1" ]; then
        echoerr "For use with bash shell only, exiting\n"
        exit 2
    fi
}

check_sourced () {
    # call as 'check_sourced "$0" "${BASH_SOURCE}"'
    if [[ "$1" = "$2" ]]; then
        echoerr "%s is intended to be sourced, not executed.\nExiting.\n" "${BASH_SOURCE[0]}"
        exit 1
    fi
}

parent_path () {
    # what is our fully qualified path
    # set $basename and $basedir
    local me="$1"
    local curdir=""
    local scriptname="${me##*/}"
    case "${me}" in
        /*)
            # fully qualified path
            local basename="${me}"
            local basedir="${basename%/*}"
            ;;
        */*)
            # partially qualified path
            curdir="$(pwd)"
            cd "${curdir}/${me%/*}"
            local basedir="$(pwd)"
            local basename="${basedir}/${scriptname}"
            cd "${curdir}"
            ;;
        *)
            # no path
            local basedir="$(pwd)"
            local basename="${basedir}/${scriptname}"
    esac
    # this could be made smarter to print the basename if needed
    printf "%s" "${basedir}"
}
