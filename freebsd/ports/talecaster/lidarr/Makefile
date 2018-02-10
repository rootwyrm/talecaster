# $TaleCaster: master/talecaster/lidarr/Makefile

PORTNAME=		lidarr
PORTVERSION=	0.2.0.267
PORTREVISION=	0
CATEGORIES=		net-p2p
MASTER_SITES=	https://ci.appveyor.com/api/buildjobs/3407qv0i5s9l7fl4/artifacts/
DISTNAME=		Lidarr.develop.${PORTVERSION}.linux.tar.gz

MAINTAINER=		talecaster@rootwyrm.com
COMMENT=		Tastes like Sonarr, but for Music

LICENSE=		GPLv3

RUN_DEPENDS=	mono>0:lang/mono \
				mediainfo>0:multimedia/mediainfo \
				sqlite3>0:databases/sqlite3
LIB_DEPENDS=	libcurl.so:ftp/curl \
				libmediainfo.so:multimedia/mediainfo

USE_RC_SUBR=	lidarr

NO_BUILD=		YES
WRKSRC=	${WRKDIR}/Lidarr

USERS=	talecaster
GROUPS=	talecaster

.include <bsd.port.options.mk>

do-install:
	${INSTALL} -d -m 755 ${STAGEDIR}/${DATADIR}
	cd ${WRKSRC} && ${COPYTREE_SHARE} \* ${STAGEDIR}/${DATADIR}

.include <bsd.port.mk>
