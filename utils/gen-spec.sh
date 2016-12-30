#!/bin/bash

# Script: gen-spec.sh
# Generates SPEC file to build rpm based on files in src


export SCRIPTROOT=`dirname $0`
export SRCROOT=`( cd ${SCRIPTROOT} && cd .. && pwd )`
export SCRIPTROOT=`( cd ${SCRIPTROOT} && pwd )`

# Default Values
DEFAULT_DIR="${SRCROOT}/SOURCES/src/"
FIND_DIRECTORY=${DEFAULT_DIR}

PACKAGE_NAME="BeerSmith"
PROD_URL="http://beersmith.com"
PACKAGE_REQUIRES="webkitgtk webkitgtk-devel"
PACKAGE_SUMMARY="BeerSmith 2 Home Brewing Software"
PACKAGE_DESCRIPTION="Take the guesswork out of home brewing with BeerSmith 2! BeerSmith 2 has been completely redesigned from the ground up to include tabbed browsing, graphical recipe design and a host of new features. BeerSmith helps you design great beers, match popular beer styles from around the world, manage your recipes, generate step-by-step brewing instructions and perform dozens of brewing calculations with ease. Select from hundreds of preloaded ingredients to build a recipe. BeerSmith features graphical recipe design, over a dozen standalone brewing tools, a beer style guide, inventory management, calendar and integrated shopping list. BeerSmith sets the gold standard for brewing software."

usage() {
    echo "-d|--directory FIND_DIRECTORY : Sets directory to do find files in"
    echo "-h|--help : Displays Script Help"
    echo ""
    echo "Default Directroy used to search in is: ${DEFAULT_DIR}"
    echo ""
}

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
    -d|--directory)
        FIND_DIRECTORY="$2"
        shift
        ;;
    -n|--pkg-name)
        PACKAGE_NAME="$2"
        shift
        ;;
    -r|--pkg-requires)
        PACKAGE_REQUIRES="$2"
        shift
        ;;
    -s|--pkg-summary)
        PACKAGE_SUMMARY="$2"
        shift
        ;;
    -p|--pkg-description)
        PACKAGE_DESCRIPTION="$2"
        shift
        ;;
    -u|--pkg-url)
        PROD_URL="$2"
        shift
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        echo -e "Unknown options $1 #ERROR"
        usage
        exit 1
        ;;
    esac
    shift
done;

# COPY TEMPLATE
mkdir -p ${SRCROOT}/SPECS
cp -rf ${SCRIPTROOT}/${PACKAGE_NAME}-template.spec ${SRCROOT}/SPECS/${PACKAGE_NAME}.spec

# GET SRC DIR LIST 
SRC_DIRS=$( ( cd ${FIND_DIRECTORY} && find ./ -type d -maxdepth 1 | cut -d '/' -f2 ) )
SRC_DIRS=${SRC_DIRS[@]/'./'}

# FILL IN FIELDS
( cd ${SRCROOT} && sed -i "s=<PACKAGE_NAME>=${PACKAGE_NAME}=g" ${SRCROOT}/SPECS/${PACKAGE_NAME}.spec )
( cd ${SRCROOT} && sed -i "s=<PACKAGE_SUMMARY>=${PACKAGE_SUMMARY}=g" ${SRCROOT}/SPECS/${PACKAGE_NAME}.spec )
( cd ${SRCROOT} && sed -i "s=<PROD_URL>=${PROD_URL}=g" ${SRCROOT}/SPECS/${PACKAGE_NAME}.spec )
( cd ${SRCROOT} && sed -i "s=<PACKAGE_REQUIRES>=${PACKAGE_REQUIRES}=g" ${SRCROOT}/SPECS/${PACKAGE_NAME}.spec )
( cd ${SRCROOT} && sed -i "s=<PACKAGE_DESCRIPTION>=${PACKAGE_DESCRIPTION}=g" ${SRCROOT}/SPECS/${PACKAGE_NAME}.spec )
( cd ${SRCROOT} && sed -i "s=<SRC_DIRS>=${SRC_DIRS[@]}=g" ${SRCROOT}/SPECS/${PACKAGE_NAME}.spec )

oifs=$IFS
IFS=$'\r\n' FIND_FILES=$( (cd ${FIND_DIRECTORY} && find ./ -type f | cut -d '.' -f2-) )
IFS=$'\r\n' FIND_DIRS=$( (cd ${FIND_DIRECTORY} && find ./ -type d | cut -d '.' -f2-) )

# Remove Dirs in list of excludes
IFS=$'\r\n' FIND_DIRS=$( (cat ${SCRIPTROOT}/remove-dir.list) )
for directory in ${FIND_DIRS[@]/'/'}; do
    FIND_DIRS=(${FIND_DIRS[@]//*$directory*})
done;


if [[ -z ${FIND_FILES[@]} ]]; then
    echo -e "No Files Found #ERROR"
    exit 1
fi

# GEN SPEC FILE
echo "%defattr(644,root,root,-)" >> ${SRCROOT}/SPECS/${PACKAGE_NAME}.spec
# DIRECTORY ATTRIBUTES
for directory in ${FIND_DIRS[@]/'/'}; do
   if [[ $directory != "/etc" && $directory != "/usr" && $directory != "/usr/bin" && $directory != "/usr/share" ]]; then
       echo "%dir %attr(775,root,root) \"$directory\"" >> ${SRCROOT}/SPECS/${PACKAGE_NAME}.spec
   fi
done;
# FILE ATTRIBUTES
for file in ${FIND_FILES[@]}; do
    echo "%attr(775,root,root) \"$file\"" >> ${SRCROOT}/SPECS/${PACKAGE_NAME}.spec
done;
echo "" >> ${SRCROOT}/SPECS/${PACKAGE_NAME}.spec

IFS=$oifs
exit 0
