#!/usr/bin/env Rscript --vanilla
args<-commandArgs()
conf<-args[length(args)]
if(length(grep("config.ini$",conf))==0) conf <- "config.ini"
if(!file.exists(conf)){
	print(paste("config.ini not found! I will create sample file for you."))
	wd<-sub("config.ini$","",conf)
	if(wd!="" && !dir.exists(wd)) dir.create(wd,recursive = TRUE, mode = "0777")
	cat(c('podcastsdir = "./"','podcastsurl = "http://podcasts.mydomain.info/"',
		 'channels    = "./channels.tsv"','youtubedl   = "youtube-dl"'),file=conf,sep="\n")
}
source(conf)

if(!file.exists(channels)){
	print(paste("channels.tsv not found! I will create sample file for you."))
	wd<-sub("channels.tsv$","",conf)
	if(wd!="" && !dir.exists(sub("channels.tsv$","",channels))) dir.create(sub("channels.tsv$","",channels),recursive = TRUE, mode = "0777")
	cat(c('"name"	"id"	"type"','"1"	"Save Russian education in Latvia"	"UCnNAijNguxn8lo3aVT8fBXA"	"channel/"',
			'"2"	"Zaz"	"PLGpfjoJVRqU4guesWbHD6SW6EvQCeL__R"	"playlist?list="'),file=channels,sep="\n")
}
ch<-read.table(file=channels,sep='\t',colClasses = "character")

opml<-"<opml version=\"1.1\">\n<body><outline text=\"YouTube2podcast.R\" title=\"YouTube2podcast.R\">"
for(i in 1:nrow(ch)){
	if(!dir.exists(paste0(podcastsdir,ch[i,"name"]))) dir.create(paste0(podcastsdir,ch[i,"name"]),recursive = TRUE, mode = "0777")
	system(paste0(youtubedl," -i --yes-playlist --write-description --write-thumbnail --embed-thumbnail ",
		" --download-archive \"",podcastsdir,ch[i,"name"],"/.done\" -x -f bestaudio --audio-format mp3",
		" --prefer-ffmpeg --postprocessor-args \"-af silenceremove=start_periods=1:stop_periods=-1:stop_duration=3:stop_threshold=-40dB\" ",
		" -o \"",podcastsdir,ch[i,"name"],"/%(title)s+%(upload_date)s+%(duration)05d+%(id)s.%(ext)s\" ",
		" --audio-quality 4 https://www.youtube.com/",ch[i,"type"],ch[i,"id"]," "))
	mp3 <- sub(".mp3$","",dir(path=paste0(podcastsdir,ch[i,"name"]),pattern = "*.mp3"))
	mp3 <- mp3[order(-as.numeric(apply(cbind(mp3),1,function(x){ y<-strsplit(x,'\\+')[[1]]; y[length(y)-2] })))]
	pic<-paste0("href=\"",podcastsurl,URLencode(ch[i,"name"],reserved = TRUE),"/",URLencode(mp3[1],reserved = TRUE),".jpg\"")
	rss <- paste0("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rss version=\"2.0\" xmlns:googleplay=\"http://www.google.com/schemas",
		"/play-podcasts/1.0\" xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\">\n<channel>\n\t<title>",ch[i,"name"],"</title>\n",
		"\t<googleplay:image ",pic," />\n\t<itunes:image ",pic," />\n\t<language>ru</language>\n\t",
		"<link>https://www.youtube.com/feeds/videos.xml?channel_id=",ch[i,"id"],"</link>")
	for(m in mp3){
		all <- strsplit(m,'\\+')[[1]]
		id <- all[(length(all)-2):length(all)]
		title <- sub("&"," ",sub(paste(c("",id),collapse = "\\+"),"",m))
		desc <- sub("&","&amp;",paste(readLines(paste0(podcastsdir,ch[i,"name"],"/",m,".description"), warn = FALSE),collapse = "<br />"))
		rss <- paste0(c(rss,"\n<item>\n\t<title>",title,"</title>\n\t<description><![CDATA[<a href=\"https://www.youtube.com/watch?v=",
			id[3],"\">\n\tVideo on Youtube<img src=\"",podcastsurl,URLencode(ch[i,"name"],reserved = TRUE),"/",URLencode(m,reserved = TRUE),
			".jpg\" /></a><p>",desc,"</p>]]></description>\n\t<pubDate>",format(as.Date(id[1],format="%Y%m%d"),format="%a, %d %b %Y %T %Z"),
			"</pubDate>\n\t<enclosure url=\"",podcastsurl,URLencode(ch[i,"name"],reserved = TRUE),"/",URLencode(m,reserved = TRUE),
			".mp3\" type=\"audio/mp3\" length=\"",file.size(paste0(podcastsdir,ch[i,"name"],"/",m,".mp3")),"\" />\n\t<itunes:duration>",id[2],
			"</itunes:duration>\n\t<guid isPermaLink=\"false\">",id[3],"</guid>\n</item>"))
	}
	rss <- paste0(c(rss,"\n</channel>\n</rss>"))
	cat(rss,file=paste0(podcastsdir,ch[i,"name"],"/rss.xml"),sep="")
	opml <- paste0(c(opml,"<outline text=\"",ch[i,"name"],"\" title=\"",ch[i,"name"],"\" type=\"rss\" xmlUrl=\"",
					 podcastsurl,URLencode(ch[i,"name"],reserved = TRUE),"/rss.xml\" />"))
}
opml <- paste0(c(opml,"</outline></body></opml>"))
cat(opml,file=paste0(podcastsdir,"rss.opml"),sep="")
## recode mp3  -vn 
# find *.mp3 -exec ffmpeg -i "{}" -acodec libmp3lame -q:a 4 -af "silenceremove=start_periods=1:stop_periods=-1:stop_duration=3:stop_threshold=-40dB" -vsync 2 "silenced/{}" \;
# find *.mp3 -exec touch -c -r "{}" "silenced/{}" \;
