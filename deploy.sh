#!/bin/bash

if [ $# -lt "2" ]
then
	echo "Usage: `basename $0` archivo.js nuevo-nombre.js"
        exit 85
fi

BUCKET="gs://installer/"
RELEASE=$1
NEWNAME=$2
NEWURL=${BUCKET}${NEWNAME}

echo "Uploading $RELEASE to $NEWURL"
gsutil cp $RELEASE $NEWURL
gsutil acl ch -g all:R ${NEWURL} 
