#!/bin/sh
usage() {
    printf "Usage: %s: [-b BASE_IMAGE_NAME] [-t BASE_IMAGE_TAG]\n" $0
}
python_base_image_name=
python_base_image_tag=
while getopts b:t: name
do
    case $name in
    b)
        python_base_image_name="$OPTARG"
        ;;
    t)
        python_base_image_tag="$OPTARG"
        ;;
    ?)
        usage >&2
        exit 2
        ;;
    esac
done
set --
if [ -n "$python_base_image_name" ] ; then
    set -- "$@" --build-arg "PYTHON_BASE_IMAGE_NAME=$python_base_image_name"
fi
if [ -n "$python_base_image_tag" ] ; then
    set -- "$@" --build-arg "PYTHON_BASE_IMAGE_TAG=$python_base_image_tag"
fi
buildah build --format oci --iidfile radicale_imageid.txt --file Dockerfile --ignorefile .dockerignore $@ .
buildah push "$(cat radicale_imageid.txt)" oci-archive:radicale.tar
