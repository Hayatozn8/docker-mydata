CMD_ROOT="$(cd `dirname $0`;pwd)/.."
BUILD_DIR="$CMD_ROOT/resource"
IMG_DIR="$CMD_ROOT/img"

yamlPath=""
while [ $# -gt 0 ]
do
    case "$1" in
        -y)
            yamlPath="$2"
            if [ -z $yamlPath ]; then
                echoerr "build.sh error: -f is empty"
                exit 1
            fi
            break
        ;;
        *)
            echoerr "build.sh error: Unknown argument: $1"
            exit 1
        ;;
    esac
done

if [ -z $yamlPath ]; then
    yamlPath=$CMD_ROOT/conf/imglist.yml
    # yamlPath=$CMD_ROOT/$yamlPath
fi

$CMD_ROOT/tool/docker-yamlbuild-mac -y $yamlPath --img-dir $IMG_DIR --build-dir $BUILD_DIR