# Newznab Standard (0.2.3)
[Standards Document](https://buildmedia.readthedocs.org/media/pdf/newznab/latest/newznab.pdf) - includes API documentation

* 0000 - Reserved
* 2000 - Movies - includes all subcategories
* 2010 - Movies/Foreign
* 2020 - Movies/Other (may include anime)
* 2030 - Movies/SD
* 2040 - Movies/HD (720p+)
* 2045 - Movies/UHD (4k+)
* 2050 - Movies/BluRay
* 2060 - Movies/3D (???)
* 3000 - Audio - includes all subcategories
* 3010 - Audio/MP3
* 3020 - Audio/Video (???)
* 3030 - Audio/Audiobook
* 3040 - Audio/Lossless
* 5000 - TV - includes all subcategories
* 5020 - TV/Foreign
* 5030 - TV/SD
* 5040 - TV/HD (720p+)
* 5045 - TV/UHD (4k)
* 5050 - TV/Other (may include anime)
* 5060 - TV/Sport
* 5070 - TV/Anime
* 5080 - TV/Documentary
* 7000 - Books - includes all subcategories
* 7010 - Books/Mags (Magazines/Periodicals)
* 7020 - Books/EBook
* 7030 - Books/Comic
* 100000-999999 - Reserved for custom

## DTD Namespace
This only covers items we care about.

`category *` - category identifier
`guid` - Release unique GUID (may have collisions!)
`password` - abandon anything >0

# Known Customizations
## Rarbg

* 100014 - Movies/XVID (blacklisted due to malware)
* 100017 - Movies/x264
* 100018 - TV Episodes
* 100023 - Music/MP3
* 100025 - Music/FLAC
* 100035 - e-Books
* 100041 - TV HD Episodes
* 100042 - Movies/Full BD
* 100044 - Movies/x264/1080
* 100045 - Movies/x264/720
* 100046 - Movies/BD Remux
* 100047 - Movies/x264/3D
* 100049 - Movies/TV-UHD-episodes
* 100049 - TV UHD Episodes
* 100050 - Movies/x264/4k
* 100051 - Movies/x265/4k
* 100052 - Movies/x264/4k/HDR
* 100054 - Movies/x265/1080

## 1337x
* 100028 - Anime/Anime
* 100078 - Anime/Dual Audio
* 100079 - Anime/Dubbed
* 100081 - Anime/Raw
* 100080 - Anime/Subbed
* 100066 - Movies/3D
* 100073 - Movies/Bollywood
* 100004 - Movies/Dubs/Dual Audio
* 100001 - Movies/DVD
* 100054 - Movies/h.264/x264
* 100042 - Movies/HD
* 100070 - Movies/HEVC/x265

