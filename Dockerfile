FROM debian:testing
RUN env DEBIAN_FRONTEND=noninteractive apt-get update && \
	env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils && \
	env DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y --no-install-recommends && \
	env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		locales r-base-core python wget ffmpeg youtube-dl && \
	apt-get autoremove -y && \
	apt-get autoclean -y && \
	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.utf8 UTF-8/' /etc/locale.gen && \
	sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.utf8 UTF-8/' /etc/locale.gen && \
	sed -i -e 's/# lv_LV.UTF-8 UTF-8/lv_LV.utf8 UTF-8/' /etc/locale.gen && \
	locale-gen
# && \
#	wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl && \
#	chmod a+rx /usr/local/bin/youtube-dl
COPY youtube2podcast.R /usr/local/bin/youtube2podcast.R
RUN chmod a+rx /usr/local/bin/youtube2podcast.R
WORKDIR /podcasts
ENTRYPOINT ["/usr/bin/env","Rscript","--vanilla","/usr/local/bin/youtube2podcast.R","config.ini"]
 