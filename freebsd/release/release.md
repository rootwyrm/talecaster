# TaleCaster Release Building

## Directory Structure (default)

    ZFSROOT=release
    REALROOT=/release

    /release/ccache     - ccache, never cleared (duh)
    /release/src/releng/${MAJOR}.${MINOR}     - snapshot when used
    /release/src/stable/${MAJOR}              - snapshot when used
    /release/src/head                         - snapshot when used
    /release/scratch                          - base, must exist, no data here
    /release/scratch/${BUILDID}               - created for every build
    /release/chroot                           - base, must exist, no data here
    /release/chroot/${BUILDID}                - created for every build
    /release/destdir                          - base, must exist, no data here
    /release/destdir/${BUILDID}               - created for every build
    /release/packages                         - optional for pkgbase
