#/bin/bash

cp ../app/src/main/assets/LASKmobile/source/*.bas ./
sed -i 's/_$(/_(/g' *.bas
xgettext --from-code=UTF-8 --keyword=_  --force-po -o ./LASKmobile.pot ./*.bas
rm ./*.bas
