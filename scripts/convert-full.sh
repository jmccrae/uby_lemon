#!/bin/bash

./convert-aligns.sh

./links.sh

./convert.sh fn FN 0

./convert.sh ow OW eng

./convert.sh ow OW deu

./convert.sh vn VN 0

./convert.sh wn WN 0

./convert.sh WktDE WktDE 1

./convert.sh WktEN WktEN 1
