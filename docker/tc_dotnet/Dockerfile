FROM	alpine:3.12

## This is a minimum repro. Shh.
	#export CMAKE_CXX_COMPILER=g++ ; \
RUN apk update && apk upgrade ; \
	mkdir -p /usr/local/src ; \
	apk add git curl bash wget gcc g++ libstdc++ python3 curl-dev icu-dev zlib-dev cmake autoconf automake make libtool lttng-ust-dev curl icu-libs zlib gettext lttng-ust binutils openssl openssl-dev && \
	git clone https://github.com/dotnet/runtime.git /usr/local/src/runtime && \
	cd /usr/local/src/runtime ; \
	./build.sh --os Linux -c Release --gcc 

