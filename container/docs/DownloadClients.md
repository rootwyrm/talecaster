# Base

CREATE TABLE "DownloadClients" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Enable" INTEGER NOT NULL, "Name" TEXT NOT NULL, "Implementation" TEXT NOT NULL, "Settings" TEXT NOT NULL, "ConfigContract" TEXT NOT NULL, "Priority" INTEGER NOT NULL DEFAULT 1);

* Id - do not set
* Enable - integer (0/1)
* Name - text, freeform
* Implementation - UsenetBlackhole, TorrentBlackhole, Nzbget, QBittorrent, Transmission
* Settings - json
* ConfigContract - UsenetBlackholeSettings, TorrentBlackholeSettings, NzbgetSettings, QBittorrentSettings
* Priority - integer

## UsenetBlackhole
```
{
  "torrentFolder": "/talecaster/blackhole",
  "watchFolder": "/talecaster/downloads"
}
```

## TorrentBlackhole
```
{
  "torrentFolder": "/talecaster/blackhole",
  "watchFolder": "/talecaster/downloads",
  "saveMagnetFiles": bool,
  "magnetFileExtension": ".magnet",
  "readOnly": bool
}
```

## NzbgetSettings
```
{
  "host": "$nntphost",
  "port": integer,
  "username": "$nntpuser",
  "password": "$nttppass",
  "$CategoryName": "$Category",
  "$recentCategoryPriority": int,
  "$olderCategoryPriority": int,
  "addPaused": bool,
  "useSsl": false
}
```

## QBittorrentSettings
```
{
  "host": "$torrenthost",
  "port": int,
  "$CategoryName": "$Category",
  "$recentCategoryPriority": int,
  "$olderCategoryPriority": int,
  "$categoryImportedCategory": "$import_category",
  "initialState": int, 
  "useSsl": false
}
```
`initialState` is an integer. 0 = Start, 1 = ForceStart, 2 = Paused

`categoryImportedCategory` (i.e. `tvImportedCategory`) must be absent if post-import category is not set.
