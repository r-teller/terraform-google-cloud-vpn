# Required tools for setup
pwd=$(pwd)
pushd "${pwd}/../schemas/"
json-dereference -s ./ha_cloud_vpn.schema.json  -o ./resolved/resolved.schema.json
jq "." resolved/resolved.schema.json | sponge resolved/resolved.schema.json
cp ./resolved/resolved.schema.json "${pwd}/src/Schema/resolved.schema.json"
popd

rm -rf ./public/documentation/*
generate-schema-doc --config expand_buttons=true ./src/Schema/resolved.schema.json ./public/documentation/index.html

#npm install // run externally for now :(
#npm run build // run externally for now :(
rm -rf ../docs/*
mv ./build/* ../docs
rm -r ./build



ceil(0%1)
ceil(1%1)
ceil(2%1)


ceil(0%2)
ceil(1%2)

ceil(0%4)
ceil(1%4)
ceil(2%4)
ceil(3%4)
ceil(4%4)
ceil(5%4)
ceil(6%4)
ceil(7%4)


ceil(2%0)