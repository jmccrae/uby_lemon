#!/bin/bash

if [ ! -e ../data/fn ]
then
	mkdir -p ../data/fn
fi

if [ ! -e ../data/ow_deu ]
then
	mkdir -p ../data/ow_deu
fi

if [ ! -e ../data/vn ]
then
	mkdir -p ../data/vn
fi


if [ ! -e ../data/wn ]
then
	mkdir -p ../data/wn
fi

if [ ! -e ../data/fn/fn.sa.nt ]
then
  xsltproc senseaxis.xsl ../data/ubyAlignments/FrameNet_VerbNet_Sense_VerbNet_Palmer2010.xml > ../data/fn/fn-vn.rdf
  rapper -i rdfxml -o ntriples -I http://lemon-model.net/lexica/uby/fn/ ../data/fn/fn-vn.rdf > ../data/fn/fn.sa.nt
  perl -pi -e 's/fn\/VN/vn\/VN/g' ../data/fn/fn.sa.nt
  
  xsltproc senseaxis.xsl ../data/ubyAlignments/mapnet_mapping_lus_synsets.xml > ../data/fn/fn-wn.rdf
  xsltproc senseaxis.xsl ../data/ubyAlignments/wordframenet_fnwn_formatted.xml > ../data/fn/fn-wn2.rdf
  rapper -i rdfxml -o ntriples -I http://lemon-model.net/lexica/uby/fn/ ../data/fn/fn-wn.rdf >> ../data/fn/fn.sa.nt
  rapper -i rdfxml -o ntriples -I http://lemon-model.net/lexica/uby/fn/ ../data/fn/fn-wn2.rdf >> ../data/fn/fn.sa.nt
  perl -pi -e 's/fn\/WN/wn\/WN/g' ../data/fn/fn.sa.nt
fi

if [ ! -e ../data/ow_deu/ow_deu.sa.nt ]
then
  xsltproc senseaxis.xsl ../data/ubyAlignments/omegawiki_deu_eng.xml > ../data/ow_deu/ow_deu-ow_eng.rdf
  rapper -i rdfxml -o ntriples -I http://lemon-model.net/lexica/uby/ow_deu/ ../data/ow_deu/ow_deu-ow_eng.rdf > ../data/ow_deu/ow_deu.sa.nt
  perl -pi -e 's/ow_deu\/OW_eng/ow_eng\/OW_eng/g' ../data/ow_deu/ow_deu.sa.nt
    
  xsltproc senseaxis.xsl ../data/ubyAlignments/omegawiki_deu_WordNet.xml > ../data/ow_deu/ow_deu-wn.rdf
  rapper -i rdfxml -o ntriples -I http://lemon-model.net/lexica/uby/ow_deu/ ../data/ow_deu/ow_deu-wn.rdf >> ../data/ow_deu/ow_deu.sa.nt
  perl -pi -e 's/ow_deu\/WN/wn\/WN/g' ../data/ow_deu/ow_deu.sa.nt
fi

if [ ! -e ../data/vn/vn.sa.nt ]
then
  xsltproc senseaxis.xsl ../data/ubyAlignments/Verbnet_Wordnet_alignment.xml > ../data/vn/vn-wn.rdf
  rapper -i rdfxml -o ntriples -I http://lemon-model.net/lexica/uby/vn/ ../data/vn/vn-wn.rdf > ../data/vn/vn.sa.nt
  perl -pi -e 's/vn\/WN/wn\/WN/g' ../data/vn/vn.sa.nt
fi
  
if [ ! -e ../data/wn/wn.sa.nt ]
then
  xsltproc senseaxis.xsl ../data/ubyAlignments/Wordnet_Wiktionary_en_Alignment_corrected.xml > ../data/wn/wn-wkt.rdf
  rapper -i rdfxml -o ntriples -I http://lemon-model.net/lexica/uby/wn/ ../data/wn/wn-wkt.rdf > ../data/wn/wn.sa.nt
  perl -pi -e 's/wn\/WktEN/WktEN\/WktEn/g' ../data/wn/wn.sa.nt
fi

