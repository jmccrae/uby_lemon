#!/bin/bash

if [ ! -e /usr/bin/scala ] && [ -e /home/jmccrae/scala-2.9.2/bin/scala ]
then
	scala='/home/jmccrae/scala-2.9.2/bin/scala'
else
	scala='scala'
fi

if [ ! -e ../data/wn ]
then
	mkdir -p ../data/wn
fi

if [ ! -e ../linking/wn20uris ] && [ -e ../linking/wn20uris.gz ]
then
	gunzip ../linking/wn20uris
fi

if [ ! -e ../linking/uby2wn20.ttl ]
then
	$scala ../linking/uby2wn20.scala
fi

if [ ! -e ../data/wn/wn.sa2.nt ]
then 
  if [ ! -e ../linking/wn20uris.gz ]
  then
    gzip ../linking/wn20uris
  fi

  rapper -i turtle -o ntriples ../linking/uby2wn20.ttl > ../data/wn/wn.sa2.nt

  if [ ! -e ../linking/wn30uris ] && [ -e ../linking/wn30uris.gz ]
  then
	  gunzip ../linking/wn30uris
  fi

  if [ ! -e ../linking/uby2wn30.ttl ]
  then
	  $scala ../linking/uby2wn30.scala
  fi

  if [ ! -e ../linking/wn30uris.gz ]
  then
    gzip ../linking/wn30uris
  fi

  rapper -i turtle -o ntriples ../linking/uby2wn30.ttl >> ../data/wn/wn.sa2.nt

  if [ ! -e ../linking/wikturis ] && [ -e ../linking/wikturis.gz ]
  then
	  gunzip ../linking/wikturis
  fi

  if [ ! -e ../linking/uby2wikt.ttl ]
  then
	  $scala ../linking/uby2wikt.scala
  fi

  rapper -i turtle -o ntriples ../linking/uby2wikt.ttl >> ../data/wn/wn.sa2.nt

  gzip ../linking/wikturis
  
  cat < ../data/wn/wn.sa2.nt >> ../data/wn/wn.sa.nt
fi
