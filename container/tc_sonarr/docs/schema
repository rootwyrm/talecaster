CREATE TABLE "VersionInfo" 
	("Version" INTEGER NOT NULL, "AppliedOn" DATETIME, "Description" TEXT);
CREATE TABLE "Config" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Key" TEXT NOT NULL, "Value" TEXT NOT NULL);
CREATE TABLE "RootFolders" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Path" TEXT NOT NULL);
CREATE TABLE "ScheduledTasks" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "TypeName" TEXT NOT NULL, "Interval" INTEGER NOT NULL, "LastExecution" DATETIME NOT NULL);
CREATE TABLE "History" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "EpisodeId" INTEGER NOT NULL, "SeriesId" INTEGER NOT NULL, "SourceTitle" TEXT NOT NULL, "Date" DATETIME NOT NULL, "Quality" TEXT NOT NULL, "Data" TEXT NOT NULL, "EventType" INTEGER, "DownloadId" TEXT, "Language" INTEGER NOT NULL DEFAULT 0);
CREATE TABLE "Episodes" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "SeriesId" INTEGER NOT NULL, "SeasonNumber" INTEGER NOT NULL, "EpisodeNumber" INTEGER NOT NULL, "Title" TEXT, "Overview" TEXT, "EpisodeFileId" INTEGER, "AbsoluteEpisodeNumber" INTEGER, "SceneAbsoluteEpisodeNumber" INTEGER, "SceneSeasonNumber" INTEGER, "SceneEpisodeNumber" INTEGER, "Monitored" INTEGER, "AirDateUtc" DATETIME, "AirDate" TEXT, "Ratings" TEXT, "Images" TEXT, "UnverifiedSceneNumbering" INTEGER NOT NULL DEFAULT 0, "LastSearchTime" DATETIME, "AiredAfterSeasonNumber" INTEGER, "AiredBeforeSeasonNumber" INTEGER, "AiredBeforeEpisodeNumber" INTEGER);
CREATE TABLE "Blacklist" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "SeriesId" INTEGER NOT NULL, "EpisodeIds" TEXT NOT NULL, "SourceTitle" TEXT NOT NULL, "Quality" TEXT NOT NULL, "Date" DATETIME NOT NULL, "PublishedDate" DATETIME, "Size" INTEGER, "Protocol" INTEGER, "Indexer" TEXT, "Message" TEXT, "TorrentInfoHash" TEXT, "Language" INTEGER NOT NULL DEFAULT 0);
CREATE TABLE "NamingConfig" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "MultiEpisodeStyle" INTEGER NOT NULL, "RenameEpisodes" INTEGER, "StandardEpisodeFormat" TEXT, "DailyEpisodeFormat" TEXT, "SeasonFolderFormat" TEXT, "SeriesFolderFormat" TEXT, "AnimeEpisodeFormat" TEXT, "ReplaceIllegalCharacters" INTEGER NOT NULL DEFAULT 1, "SpecialsFolderFormat" TEXT);
CREATE TABLE "Metadata" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Enable" INTEGER NOT NULL, "Name" TEXT NOT NULL, "Implementation" TEXT NOT NULL, "Settings" TEXT NOT NULL, "ConfigContract" TEXT NOT NULL);
CREATE TABLE "PendingReleases" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "SeriesId" INTEGER NOT NULL, "Title" TEXT NOT NULL, "Added" DATETIME NOT NULL, "ParsedEpisodeInfo" TEXT NOT NULL, "Release" TEXT NOT NULL, "Reason" INTEGER NOT NULL DEFAULT 0);
CREATE TABLE "EpisodeFiles" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "SeriesId" INTEGER NOT NULL, "Quality" TEXT NOT NULL, "Size" INTEGER NOT NULL, "DateAdded" DATETIME NOT NULL, "SeasonNumber" INTEGER NOT NULL, "SceneName" TEXT, "ReleaseGroup" TEXT, "MediaInfo" TEXT, "RelativePath" TEXT, "Language" INTEGER NOT NULL DEFAULT 0, "OriginalFilePath" TEXT);
CREATE TABLE "DownloadClients" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Enable" INTEGER NOT NULL, "Name" TEXT NOT NULL, "Implementation" TEXT NOT NULL, "Settings" TEXT NOT NULL, "ConfigContract" TEXT NOT NULL, "Priority" INTEGER NOT NULL DEFAULT 1);
CREATE TABLE "RemotePathMappings" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Host" TEXT NOT NULL, "RemotePath" TEXT NOT NULL, "LocalPath" TEXT NOT NULL);
CREATE TABLE "ReleaseProfiles" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Required" TEXT, "Preferred" TEXT, "Ignored" TEXT, "Tags" TEXT NOT NULL, "IncludePreferredWhenRenaming" INTEGER NOT NULL DEFAULT 1, "Enabled" INTEGER NOT NULL DEFAULT 1, "IndexerId" INTEGER NOT NULL DEFAULT 0, "Name" TEXT DEFAULT NULL);
CREATE TABLE "DelayProfiles" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "EnableUsenet" INTEGER NOT NULL, "EnableTorrent" INTEGER NOT NULL, "PreferredProtocol" INTEGER NOT NULL, "UsenetDelay" INTEGER NOT NULL, "TorrentDelay" INTEGER NOT NULL, "Order" INTEGER NOT NULL, "Tags" TEXT NOT NULL);
CREATE TABLE "Users" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Identifier" TEXT NOT NULL, "Username" TEXT NOT NULL, "Password" TEXT NOT NULL);
CREATE TABLE "Commands" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Name" TEXT NOT NULL, "Body" TEXT NOT NULL, "Priority" INTEGER NOT NULL, "Status" INTEGER NOT NULL, "QueuedAt" DATETIME NOT NULL, "StartedAt" DATETIME, "EndedAt" DATETIME, "Duration" TEXT, "Exception" TEXT, "Trigger" INTEGER NOT NULL);
CREATE TABLE "Tags" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Label" TEXT NOT NULL);
CREATE TABLE "QualityDefinitions" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Quality" INTEGER NOT NULL, "Title" TEXT NOT NULL, "MinSize" NUMERIC, "MaxSize" NUMERIC);
CREATE TABLE "Notifications" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Name" TEXT NOT NULL, "OnGrab" INTEGER NOT NULL, "OnDownload" INTEGER NOT NULL, "Settings" TEXT NOT NULL, "Implementation" TEXT NOT NULL, "ConfigContract" TEXT, "OnUpgrade" INTEGER, "Tags" TEXT, "OnRename" INTEGER NOT NULL, "OnHealthIssue" INTEGER NOT NULL DEFAULT 0, "IncludeHealthWarnings" INTEGER NOT NULL DEFAULT 0, "OnSeriesDelete" INTEGER NOT NULL DEFAULT 0, "OnEpisodeFileDelete" INTEGER NOT NULL DEFAULT 0, "OnEpisodeFileDeleteForUpgrade" INTEGER NOT NULL DEFAULT 1);
CREATE TABLE "ExtraFiles" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "SeriesId" INTEGER NOT NULL, "SeasonNumber" INTEGER NOT NULL, "EpisodeFileId" INTEGER NOT NULL, "RelativePath" TEXT NOT NULL, "Extension" TEXT NOT NULL, "Added" DATETIME NOT NULL, "LastUpdated" DATETIME NOT NULL);
CREATE TABLE "SubtitleFiles" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "SeriesId" INTEGER NOT NULL, "SeasonNumber" INTEGER NOT NULL, "EpisodeFileId" INTEGER NOT NULL, "RelativePath" TEXT NOT NULL, "Extension" TEXT NOT NULL, "Added" DATETIME NOT NULL, "LastUpdated" DATETIME NOT NULL, "Language" INTEGER NOT NULL);
CREATE TABLE "MetadataFiles" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "SeriesId" INTEGER NOT NULL, "Consumer" TEXT NOT NULL, "Type" INTEGER NOT NULL, "RelativePath" TEXT NOT NULL, "LastUpdated" DATETIME NOT NULL, "SeasonNumber" INTEGER, "EpisodeFileId" INTEGER, "Hash" TEXT, "Added" DATETIME, "Extension" TEXT NOT NULL);
CREATE TABLE "SceneMappings" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "TvdbId" INTEGER NOT NULL, "SeasonNumber" INTEGER, "SearchTerm" TEXT NOT NULL, "ParseTerm" TEXT NOT NULL, "Title" TEXT, "Type" TEXT, "SceneSeasonNumber" INTEGER, "FilterRegex" TEXT, "SceneOrigin" TEXT, "SearchMode" INTEGER, "Comment" TEXT);
CREATE TABLE "LanguageProfiles" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Name" TEXT NOT NULL, "Languages" TEXT NOT NULL, "Cutoff" INTEGER NOT NULL, "UpgradeAllowed" INTEGER);
CREATE TABLE "QualityProfiles" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Name" TEXT NOT NULL, "Cutoff" INTEGER NOT NULL, "Items" TEXT NOT NULL, "UpgradeAllowed" INTEGER);
CREATE TABLE "IndexerStatus" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "ProviderId" INTEGER NOT NULL, "InitialFailure" DATETIME, "MostRecentFailure" DATETIME, "EscalationLevel" INTEGER NOT NULL, "DisabledTill" DATETIME, "LastRssSyncReleaseInfo" TEXT);
CREATE TABLE "DownloadClientStatus" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "ProviderId" INTEGER NOT NULL, "InitialFailure" DATETIME, "MostRecentFailure" DATETIME, "EscalationLevel" INTEGER NOT NULL, "DisabledTill" DATETIME);
CREATE TABLE "Indexers" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Name" TEXT NOT NULL, "Implementation" TEXT NOT NULL, "Settings" TEXT, "ConfigContract" TEXT, "EnableRss" INTEGER, "EnableAutomaticSearch" INTEGER, "EnableInteractiveSearch" INTEGER NOT NULL, "Priority" INTEGER NOT NULL DEFAULT 25);
CREATE TABLE "CustomFilters" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Type" TEXT NOT NULL, "Label" TEXT NOT NULL, "Filters" TEXT NOT NULL);
CREATE TABLE "Series" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "TvdbId" INTEGER NOT NULL, "TvRageId" INTEGER NOT NULL, "ImdbId" TEXT, "Title" TEXT NOT NULL, "TitleSlug" TEXT, "CleanTitle" TEXT NOT NULL, "Status" INTEGER NOT NULL, "Overview" TEXT, "AirTime" TEXT, "Images" TEXT NOT NULL, "Path" TEXT NOT NULL, "Monitored" INTEGER NOT NULL, "SeasonFolder" INTEGER NOT NULL, "LastInfoSync" DATETIME, "LastDiskSync" DATETIME, "Runtime" INTEGER NOT NULL, "SeriesType" INTEGER NOT NULL, "Network" TEXT, "UseSceneNumbering" INTEGER NOT NULL, "FirstAired" DATETIME, "NextAiring" DATETIME, "Year" INTEGER, "Seasons" TEXT, "Actors" TEXT, "Ratings" TEXT, "Genres" TEXT, "Certification" TEXT, "SortTitle" TEXT, "QualityProfileId" INTEGER, "Tags" TEXT, "Added" DATETIME, "AddOptions" TEXT, "TvMazeId" INTEGER NOT NULL, "LanguageProfileId" INTEGER NOT NULL);
CREATE TABLE "DownloadHistory" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "EventType" INTEGER NOT NULL, "SeriesId" INTEGER NOT NULL, "DownloadId" TEXT NOT NULL, "SourceTitle" TEXT NOT NULL, "Date" DATETIME NOT NULL, "Protocol" INTEGER, "IndexerId" INTEGER, "DownloadClientId" INTEGER, "Release" TEXT, "Data" TEXT);
CREATE TABLE "ImportLists" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Name" TEXT NOT NULL, "Implementation" TEXT NOT NULL, "Settings" TEXT, "ConfigContract" TEXT, "EnableAutomaticAdd" INTEGER, "RootFolderPath" TEXT NOT NULL, "ShouldMonitor" INTEGER NOT NULL, "QualityProfileId" INTEGER NOT NULL, "LanguageProfileId" INTEGER NOT NULL, "Tags" TEXT, "SeriesType" INTEGER NOT NULL DEFAULT 0, "SeasonFolder" INTEGER NOT NULL DEFAULT 1);
CREATE TABLE "ImportListStatus" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "ProviderId" INTEGER NOT NULL, "InitialFailure" DATETIME, "MostRecentFailure" DATETIME, "EscalationLevel" INTEGER NOT NULL, "DisabledTill" DATETIME, "LastSyncListInfo" TEXT);
CREATE TABLE "ImportListExclusions" 
	("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "TvdbId" TEXT NOT NULL, "Title" TEXT NOT NULL);

CREATE UNIQUE INDEX "UC_Version" ON "VersionInfo" ("Version" ASC);
CREATE UNIQUE INDEX "IX_Config_Key" ON "Config" ("Key" ASC);
CREATE UNIQUE INDEX "IX_RootFolders_Path" ON "RootFolders" ("Path" ASC);
CREATE UNIQUE INDEX "IX_ScheduledTasks_TypeName" ON "ScheduledTasks" ("TypeName" ASC);
CREATE INDEX "IX_Blacklist_SeriesId" ON "Blacklist" ("SeriesId" ASC);
CREATE INDEX "IX_Episodes_EpisodeFileId" ON "Episodes" ("EpisodeFileId" ASC);
CREATE INDEX "IX_Episodes_SeriesId" ON "Episodes" ("SeriesId" ASC);
CREATE INDEX "IX_History_Date" ON "History" ("Date" ASC);
CREATE INDEX "IX_EpisodeFiles_SeriesId" ON "EpisodeFiles" ("SeriesId" ASC);
CREATE UNIQUE INDEX "IX_Users_Identifier" ON "Users" ("Identifier" ASC);
CREATE UNIQUE INDEX "IX_Users_Username" ON "Users" ("Username" ASC);
CREATE UNIQUE INDEX "IX_Tags_Label" ON "Tags" ("Label" ASC);
CREATE UNIQUE INDEX "IX_QualityDefinitions_Quality" ON "QualityDefinitions" ("Quality" ASC);
CREATE UNIQUE INDEX "IX_QualityDefinitions_Title" ON "QualityDefinitions" ("Title" ASC);
CREATE INDEX "IX_Episodes_SeriesId_SeasonNumber_EpisodeNumber" ON "Episodes" ("SeriesId" ASC, "SeasonNumber" ASC, "EpisodeNumber" ASC);
CREATE UNIQUE INDEX "IX_LanguageProfiles_Name" ON "LanguageProfiles" ("Name" ASC);
CREATE UNIQUE INDEX "IX_QualityProfiles_Name" ON "QualityProfiles" ("Name" ASC);
CREATE UNIQUE INDEX "IX_IndexerStatus_ProviderId" ON "IndexerStatus" ("ProviderId" ASC);
CREATE UNIQUE INDEX "IX_DownloadClientStatus_ProviderId" ON "DownloadClientStatus" ("ProviderId" ASC);
CREATE INDEX "IX_History_EventType" ON "History" ("EventType" ASC);
CREATE UNIQUE INDEX "IX_Indexers_Name" ON "Indexers" ("Name" ASC);
CREATE INDEX "IX_Episodes_SeriesId_AirDate" ON "Episodes" ("SeriesId" ASC, "AirDate" ASC);
CREATE INDEX "IX_History_EpisodeId_Date" ON "History" ("EpisodeId" ASC, "Date" DESC);
CREATE INDEX "IX_History_DownloadId_Date" ON "History" ("DownloadId" ASC, "Date" DESC);
CREATE INDEX "IX_History_SeriesId" ON "History" ("SeriesId" ASC);
CREATE UNIQUE INDEX "IX_Series_TvdbId" ON "Series" ("TvdbId" ASC);
CREATE UNIQUE INDEX "IX_Series_TitleSlug" ON "Series" ("TitleSlug" ASC);
CREATE INDEX "IX_Series_Path" ON "Series" ("Path" ASC);
CREATE INDEX "IX_Series_CleanTitle" ON "Series" ("CleanTitle" ASC);
CREATE INDEX "IX_Series_TvRageId" ON "Series" ("TvRageId" ASC);
CREATE INDEX "IX_Series_TvMazeId" ON "Series" ("TvMazeId" ASC);
CREATE INDEX "IX_DownloadHistory_EventType" ON "DownloadHistory" ("EventType" ASC);
CREATE INDEX "IX_DownloadHistory_SeriesId" ON "DownloadHistory" ("SeriesId" ASC);
CREATE INDEX "IX_DownloadHistory_DownloadId" ON "DownloadHistory" ("DownloadId" ASC);
CREATE UNIQUE INDEX "IX_ImportLists_Name" ON "ImportLists" ("Name" ASC);
CREATE UNIQUE INDEX "IX_ImportListStatus_ProviderId" ON "ImportListStatus" ("ProviderId" ASC);
CREATE UNIQUE INDEX "IX_ImportListExclusions_TvdbId" ON "ImportListExclusions" ("TvdbId" ASC);
