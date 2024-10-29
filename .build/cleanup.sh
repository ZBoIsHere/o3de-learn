#!/bin/bash

DELETE_LIST=(eail/.git \
             eail/Gem \
             eail/Source \
             eail/Levels \
             eail/ReflectionProbes \
             eail/build/linux/Azcg/ \
             eail/build/linux/Testing/ \
	     eail/build/linux/lib/ )

for i in ${DELETE_LIST[@]}
do
   echo "Deleting /data/workspace/$i"
   rm -rf $i
done

exit 0

