TOOL_PATH="$(cd `dirname $0`;pwd)/../tool"
if [ -d "${TOOL_PATH}" ]; then
    mdkir "${TOOL_PATH}"
fi 

# build docker-yamlbuild.sh
docker run --rm -v "${TOOL_PATH}":/root/build -w /usr/src \
 -e GO111MODULE=on \
 -e GOPROXY="https://goproxy.cn",direct \
 -e CGO_ENABLED=0 \
 -e GOOS=darwin \
 -e GOARCH=amd64 \
 golang:latest \
 sh -c 'git clone https://github.com/liujinsuozn8/docker-yamlbuild.git \
 && cd docker-yamlbuild \
 && go build -v -o /root/build'