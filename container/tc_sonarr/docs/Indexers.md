# Base 

CREATE TABLE "Indexers" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Name" TEXT NOT NULL, "Implementation" TEXT NOT NULL, "Settings" TEXT, "ConfigContract" TEXT, "EnableRss" INTEGER, "EnableAutomaticSearch" INTEGER, "EnableInteractiveSearch" INTEGER NOT NULL, "Priority" INTEGER NOT NULL DEFAULT 25);

* Id - do not set
* Name - text, freeform
* Impelementation - Newznab, Torznab, Nyaa, Rarbg (need private trackers)
* Settings - json
* ConfigContract - NewznabSettings, TorznabSettings, NyaaSettings, RarbgSettings
* EnableRss - 0,1
* EnableAutomaticSearch - 0,1
* EnableInteractiveSearch - 0,1
* Priority - integer, default 25

## Newznab
```
{
  "baseUrl": "$base_url",
  "apiPath": "/api",
  "apiKey": "$api_key",
  "categories": [
    5030,
    5040,
    see_categories_docs
  ],
  "animeCategories": [
    5020,
    5070,
    see_categories_docs
  ]
}
```

## Torznab
```
{
  "minimumSeeders": int,
  "seedCriteria": {},
  "baseUrl": "$base_url",
  "apiPath": "/api",
  "apiKey": "$api_key"
  "categories": [
    see_categories_docs
  ],
  "animeCategories": [
    see_categories_docs
  ],
}
```

## Nyaa
```
{
  "baseUrl": "$base_url",
  "additionalParameters": "&cats=1_0&filter=1&etc",
  "minimumSeeders": int,
  "seedCriteria": {}
}
```

## Rarbg
```
{
  "baseUrl": "https://torrentapi.org",
  "rankedOnly": bool,
  "minimumSeeders": int,
  "seedCriteria": {}
}
```

# seedCriteria
```
{
  "seedRatio": float,
  "seedTime": int,
  "seasonPackSeedTime": int,
}
```
