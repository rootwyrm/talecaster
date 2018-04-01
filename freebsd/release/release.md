# TaleCaster Release Building

## Directory Structure (default)

    ZFSROOT=release
    REALROOT=/release

    /release/ccache     - ccache, never cleared (duh)
    /release/src/releng/${MAJOR}.${MINOR}     - snapshot when used
        @${BUILDID}
    /release/src/stable/${MAJOR}              - snapshot when used
        @${BUILDID}
    /release/src/head                         - snapshot when used
        @${BUILDID}
    /release/scratch                          - base, must exist, no data here
    /release/scratch/${BUILDID}               - created for every build
    /release/chroot                           - base, must exist, no data here
    /release/chroot/${BUILDID}                - created for every build
    /release/destdir                          - base, must exist, no data here
    /release/destdir/${BUILDID}               - created for every build
    /release/packages                         - optional for pkgbase
    /release/src/${BUILDID}                   - zfs clone of /release/src/${SVN_PATH}@${BUILDID}
        WORLDDIR=/release/src/${BUILDID}
    /release/obj/${BUILDID}                   - OBJDIR for ${BUILDID}
        OBJDIR=/release/obj/${BUILDID}
        
## Variables

    ZFSROOT=release                         # ZFS Root Name
    REALROOT=/release                       # Mount Path to ZFSROOT
    WORLDDIR=/usr/src                       # where to get the source
    CHROOTDIR=/release/chroot/${BUILDID}    # chroot for builds
    DESTDIR=/release/destdir/${BUILDID}     # output destination
    OBJDIR=/release/obj/${BUILDID}          # object/artifact
