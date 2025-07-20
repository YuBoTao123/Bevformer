set -e

if [ $# -ne 2 ]
then
    echo "need two parameters , first is usr_name , second is passwd"
    exit -2
fi
user="$1"
passwd="$2"

docker build --progress=plain -t bevformer:latest \
    --build-arg PASSWORD=$passwd \
    --build-arg USERNAME=$user \
    -f ./docker/Dockerfile .