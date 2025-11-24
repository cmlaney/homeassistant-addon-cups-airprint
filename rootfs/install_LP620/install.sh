#!/bin/sh
lines=145
echo "---------------------------------------"
echo ""
echo "Models included:"
echo "                 LP620"
echo ""
if [ `id -u` != 0 ];then 
    echo "This script requires root user access."
    echo "Re-run as root user."
    exit 1
fi 

SERVERROOT=$(grep '^ServerRoot' /etc/cups/cupsd.conf | awk '{print $2}')

if [ -z $FILTERDIR ] || [ -z $PPDDIR ]
then
    echo "Searching for ServerRoot, ServerBin, and DataDir tags in /etc/cups/cupsd.conf"
    echo ""

    if [ -z $FILTERDIR ]
    then
        SERVERBIN=$(grep '^ServerBin' /etc/cups/cupsd.conf | awk '{print $2}')

        if [ -z $SERVERBIN ]
        then
            echo "ServerBin tag not present in cupsd.conf - using default"
            FILTERDIR=usr/lib/cups/filter
        elif [ ${SERVERBIN:0:1} = "/" ]
        then
            echo "ServerBin tag is present as an absolute path"
            FILTERDIR=$SERVERBIN/filter
        else
            echo "ServerBin tag is present as a relative path - appending to ServerRoot"
            FILTERDIR=$SERVERROOT/$SERVERBIN/filter
        fi
    fi

    echo ""

    if [ -z $PPDDIR ]
    then
        DATADIR=$(grep '^DataDir' /etc/cups/cupsd.conf | awk '{print $2}')

        if [ -z $DATADIR ]
        then
            echo "DataDir tag not present in cupsd.conf - using default"
            PPDDIR=usr/share/cups/model/LP620
        elif [ ${DATADIR:0:1} = "/" ]
        then
            echo "DataDir tag is present as an absolute path"
            PPDDIR=$DATADIR/model/LP620
        else
            echo "DataDir tag is present as a relative path - appending to ServerRoot"
            PPDDIR=$SERVERROOT/$DATADIR/model/LP620
        fi
    fi

    echo ""

    echo "ServerRoot = $SERVERROOT"
    echo "ServerBin  = $SERVERBIN"
    echo "DataDir    = $DATADIR"
    echo ""
fi

echo "Copying rastertoLP620 filter to $DESTDIR/$FILTERDIR"
mkdir -p $DESTDIR/$FILTERDIR
chmod +x ./rastertoLP620
cp ./rastertoLP620 $DESTDIR/$FILTERDIR
echo ""


echo "Copying model ppd files to $DESTDIR/$PPDDIR"
mkdir -p $DESTDIR/$PPDDIR
cp ppd/*.ppd $DESTDIR/$PPDDIR
echo ""

echo "Add the label printer"
lpadmin -p LP620-Printer -E -v usb:///LP620%20Printer -P /usr/share/cups/model/LP620/LP620.ppd

echo ""

echo "Restarting CUPS"
systemctl restart cups

echo "Install Complete"
echo "Go to http://localhost:631, or http://127.0.0.1:631 to manage your printer please!"
echo ""
exit 0
