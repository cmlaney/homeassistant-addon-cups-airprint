#!/usr/bin/with-contenv bashio

ulimit -n 524288

until [ -e /var/run/avahi-daemon/socket ]; do
  sleep 1s
done

bashio::log.info "Copying rastertoLP620 filter to /usr/lib/cups/filter/"
mkdir -p /usr/lib/cups/filter/
cp /install_LP620/rastertoLP620 /usr/lib/cups/filter/rastertoLP620
chmod +x /usr/lib/cups/filter/rastertoLP620

bashio::log.info "Preparing directories"

if [ ! -d /config/cups ]; then cp -v -R /etc/cups /config; fi
rm -v -fR /etc/cups

ln -v -s /config/cups /etc/cups

bashio::log.info "Starting CUPS server as CMD from S6"

cupsd -f
