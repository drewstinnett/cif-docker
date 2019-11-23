#!/usr/bin/env bash

USERS="hunter admin smrt http"
for USER in $(echo $USERS); do
    if [[ "${USER}" == "http" ]]; then
        USERNAME=httpd
    else
        USERNAME=${USER}
    fi
    curl http://${NODES}/tokens/_search?q=username=${USERNAME} 2>/dev/null| grep token >/dev/null
    if [[ $? != 0 ]]; then
        echo "Creating TOKEN for ${USER}"
        TOKEN=$(head -n 50000 /dev/urandom | openssl dgst -sha512 | awk -F '= ' '{print $2}')
        cif-store -d --store elasticsearch --nodes ${NODES} --token-create-${USER} --token ${TOKEN}
    fi
done
