# YouTube2podcast.R
Convert YouTube channels and playlists to MP3 podcasts using yt-dlp https://github.com/yt-dlp/yt-dlp.
 *	As result video channel will be converted to the folder with MP3 files, thumbnails and descriptions per each video.
 * "rss.xml" files per each folder(channel) will be generated in the next step.
 * "rss.opml" for all folders(channels) will be produced at the end.

Usage:
```shell
Rscript --vanilla youtube2podcast.R [<path>/config.ini]
```

I recommend:
 * place "youtube2podcast.R" to your "~/bin" folder
 * add line like this to your cron (with command "crontab -u USER -e"):
```cron
07 04 * * * Rscript --vanilla /home/<user>/bin/youtube2podcast.R <path>/config.ini
```

If you prefere Docker image(~500MB):
```
docker pull ghcr.io/zajakin/youtube2podcast.r && docker run --rm -v <path>/podcasts:/podcasts ghcr.io/zajakin/youtube2podcast.r
```
cron:
```cron
07 04 * * * docker pull ghcr.io/zajakin/youtube2podcast.r && docker run --rm -v <path>/podcasts:/podcasts ghcr.io/zajakin/youtube2podcast.r
```
