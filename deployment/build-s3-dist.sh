#!/bin/bash
# curently works in the following regions due to the
# Step Functions
#EU (Ireland)
#Asia Pacific (Tokyo)
#US East (N. Virginia)
#US West (Oregon)
# Asia Pacific (Sydney)

# Check to see if input has been provided:
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Please provide the base source bucket name and version where the lambda code will eventually reside."
    echo "For example: ./build-s3-dist.sh solutions v1.0.0"
    exit 1
fi

mkdir -p dist

echo "copy cfn template to dist"
cp video-on-demand-media-convert.yaml dist/video-on-demand-media-convert.template


# export BUCKET_PREFIX=solutions-test
# if [ $1 = "solutions-master" ]; then
#     export BUCKET_PREFIX=solutions
# fi
bucket="s/CODEBUCKET/$1/g"
sed -i -e $bucket dist/video-on-demand-media-convert.template

bucket="s/CODEVERSION/$2/g"
sed -i -e $bucket dist/video-on-demand-media-convert.template

echo "zip and copy source files to dist/"
find ../source -name "node_modules" -exec rm -rf "{}" \;
cd ../source/custom-resources
npm install --production
zip -q -r9 ../../deployment/dist/custom-resources.zip *

cd ../dynamo
npm install --production
zip -q -r9 ../../deployment/dist/dynamo.zip *

cd ../error-handler
npm install --production
zip -q -r9 ../../deployment/dist/error-handler.zip *

cd ../ingest
npm install --production
zip -q -r9 ../../deployment/dist/ingest.zip *

cd ../process
npm install --production
zip -q -r9 ../../deployment/dist/process.zip *

cd ../publish
npm install --production
zip -q -r9 ../../deployment/dist/publish.zip *

cd ../sns
npm install --production
zip -q -r9 ../../deployment/dist/sns.zip *

echo "compile mediainfo, zip and copy to dist/"
cd ../mediainfo
npm install --production
cd bin
wget http://mediaarea.net/download/binary/mediainfo/0.7.84/MediaInfo_CLI_0.7.84_GNU_FromSource.tar.xz
tar xf MediaInfo_CLI_0.7.84_GNU_FromSource.tar.xz
cd MediaInfo_CLI_GNU_FromSource/
./CLI_Compile.sh --with-libcurl
mv ./MediaInfo/Project/GNU/CLI/mediainfo ../
cd ../..
chmod 755 ./bin/mediainfo
./bin/mediainfo --version
rm -rf ./bin/MediaInfo_CLI*
zip -q -r9 ../../deployment/dist/mediainfo.zip *
