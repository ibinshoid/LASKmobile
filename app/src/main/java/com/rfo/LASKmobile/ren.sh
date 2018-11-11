#!/bin/bash
for file in ./*.java
do
	sed -i 's/rfo.basic/rfo.LASKmobile/g' ${file}
done