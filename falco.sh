#!/bin/bash

DATA_FOLDER="data"

TAGS=$(curl -s https://api.github.com/repos/falcosecurity/falco/releases | jq -r '.[] | .tag_name' | tr -s "\n" " ")

# echo $TAGS

echo "FALCO_VERSION,FALCO_ENGINE_VERSION,FALCOSECURITY_LIBS_VERSION,DRIVER_VERSION,FALCOCTL_VERSION" > ${DATA_FOLDER}/falco-versions.csv

for i in ${TAGS};
do
    curl -s https://raw.githubusercontent.com/falcosecurity/falco/${i}/userspace/engine/falco_engine_version.h -o "${DATA_FOLDER}/falco_engine_version.h"
    FALCO_ENGINE_VERSION_MAJOR=$(cat ${DATA_FOLDER}/falco_engine_version.h | grep "define FALCO_ENGINE_VERSION_MAJOR" | cut -d" " -f 3)
    FALCO_ENGINE_VERSION_MINOR=$(cat ${DATA_FOLDER}/falco_engine_version.h | grep "define FALCO_ENGINE_VERSION_MINOR" | cut -d" " -f 3)
    FALCO_ENGINE_VERSION_PATCH=$(cat ${DATA_FOLDER}/falco_engine_version.h | grep "define FALCO_ENGINE_VERSION_PATCH" | cut -d" " -f 3)
    FALCO_ENGINE_VERSION="${FALCO_ENGINE_VERSION_MAJOR}.${FALCO_ENGINE_VERSION_MINOR}.${FALCO_ENGINE_VERSION_PATCH}"
    [ ${FALCO_ENGINE_VERSION} == ".." ] && FALCO_ENGINE_VERSION=$(cat ${DATA_FOLDER}/falco_engine_version.h | grep "define FALCO_ENGINE_VERSION" | cut -d"(" -f 2 | cut -d")" -f 1)

    curl -s https://raw.githubusercontent.com/falcosecurity/falco/${i}/cmake/modules/falcosecurity-libs.cmake -o "${DATA_FOLDER}/falcosecurity-libs.cmake"
    FALCOSECURITY_LIBS_VERSION=$(cat ${DATA_FOLDER}/falcosecurity-libs.cmake | grep "set(FALCOSECURITY_LIBS_VERSION " | grep -v "0.0.0" | cut -d'"' -f2)

    curl -s https://raw.githubusercontent.com/falcosecurity/falco/${i}/cmake/modules/driver.cmake -o "${DATA_FOLDER}/driver.cmake"
    DRIVER_VERSION=$(cat ${DATA_FOLDER}/driver.cmake | grep "set(DRIVER_VERSION " | grep -v "0.0.0" | cut -d'"' -f2)

    curl -s https://raw.githubusercontent.com/falcosecurity/falco/${i}/cmake/modules/falcoctl.cmake -o "${DATA_FOLDER}/falcoctl.cmake"
    FALCOCTL_VERSION=$(cat ${DATA_FOLDER}/falcoctl.cmake | grep "set(FALCOCTL_VERSION" | grep -v "0.0.0" | cut -d'"' -f2)

    echo "${i},${FALCO_ENGINE_VERSION},${FALCOSECURITY_LIBS_VERSION},${DRIVER_VERSION},${FALCOCTL_VERSION}" >> ${DATA_FOLDER}/falco-versions.csv
done

rm ${DATA_FOLDER}/*.h ${DATA_FOLDER}/*.cmake