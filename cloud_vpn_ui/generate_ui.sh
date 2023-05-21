# Required tools for setup
pwd=$(pwd)
pushd "${pwd}/../schemas/"
json-dereference -s ./ha_cloud_vpn.schema.json  -o ./resolved/resolved.schema.json
jq "." resolved/resolved.schema.json | sponge resolved/resolved.schema.json
cp ./resolved/resolved.schema.json "${pwd}/src/Schema/resolved.schema.json"
popd

rm -rf ./public/documentation/*
generate-schema-doc ./src/Schema/resolved.schema.json ./public/documentation/index.html

npm install
npm run build
rm -rf ../docs/*
mv ./build/* ../docs
rm -r ./build
