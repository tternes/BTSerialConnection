#!/bin/sh

cd `dirname $0`

appledoc \
	--project-name BTSerialConnection \
	--project-company Bluetoo \
	--company-id co.bluetoo \
	--output ./docs \
	--keep-intermediate-files \
	*.h
