#!/bin/bash

die () {
    echo >&2 "$@"
    exit 1
}

if [ ! -e /usr/bin/scala ] && [ -e /home/jmccrae/scala-2.9.2/bin/scala ]
then
	scala='/home/jmccrae/scala-2.9.2/bin/scala'
else
	scala='scala'
fi


[ "$#" -eq  3 ] || die "Usage: convert.sh resource suffix"

res=$1
resUC=$2
suf=$3
resFile=../data/ubyLexicons/${res}InLMF.xml
prefix=http://lemon-model.net/lexica/uby/$res/

if [ ! -e $resFile ] 
then
	resFile=../data/ubyLexicons/${res}InLMF_${suf:0:2}.xml
fi

if [ ! -e $resFile ]
then
    resFile=../data/ubyLexicons/${res}InLMFnew.xml
fi

if [ ! -e $resFile ] 
then 
  die "Could not find resource"
fi

if [ ! -e ../data/$res ]
then
	mkdir ../data/$res
fi


cd ../uby2lemonBySax

if [ ! -e ../data/$res/$res.rdf ]
then
  echo "LMF => RDF/XML"
  ./uby2lemon $resFile ../data/$res/${res}.rdf
fi

if [ ! -e ../data/$res/$res.nt ]
then
  echo "RDF/XML => Ntriples"
  rapper -i rdfxml -o ntriples -I "$prefix" ../data/$res/$res.rdf > ../data/$res/$res.nt || die "Rapper failed"
  if [ -e ../data/$res/$res.sa.nt ]
  then
   	cat <../data/$res/$res.sa.nt >> ../data/$res/$res.nt
  fi
fi

if [ ! -e ../data/$res/$res.nt.bz2 ]
then 
  echo "Compressing"
  bzip2 ../data/$res/$res.nt
  bzip2 ../data/$res/$res.rdf
fi
