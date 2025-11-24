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

echo "Remove the REKDOM LP620 printer"
lpadmin -x LP620-Printer

echo "Removing rastertoLP620 filter from $DESTDIR/$FILTERDIR"
rm -f $DESTDIR/$FILTERDIR/rastertoLP620
echo ""

echo "Removing model ppd files from $DESTDIR/$PPDDIR"
rm -f $DESTDIR/$PPDDIR/LP620.ppd
echo ""

echo "Restarting CUPS"
systemctl restart cups

echo "Remove Complete"
echo ""
exit 0
