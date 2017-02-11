#!/bin/sh

# Wait for startup returning a unauthenticated response code
until [ $(curl -sf -o /dev/null -w "%{http_code}" 'http://localhost:8081/service/siesta/rest/v1/script') -eq "403" ];do echo "Waiting for nexus to start ...";sleep 7;done

# Change admin password
if [ $(curl -sf -o /dev/null -w "%{http_code}" -X GET -u admin:${NEXUS_DEFAULT_PASSWORD} 'http://localhost:8081/service/siesta/rest/v1/script') -eq "200" ]; then
   if [ -n "${NEXUS_PASSWORD}" ];then
      curl -sf -X POST -u admin:${NEXUS_DEFAULT_PASSWORD} --header "Content-Type: application/json" 'http://localhost:8081/service/siesta/rest/v1/script' -d "{\"name\":\"changeadminpassword\",\"type\":\"groovy\",\"content\":\"security.securitySystem.changePassword('admin', '${NEXUS_PASSWORD}')\"}"
      curl -sf -X POST -u admin:${NEXUS_DEFAULT_PASSWORD} --header "Content-Type: text/plain" "http://localhost:8081/service/siesta/rest/v1/script/changeadminpassword/run"
      curl -sf -X DELETE -u admin:${NEXUS_DEFAULT_PASSWORD} 'http://localhost:8081/service/siesta/rest/v1/script/changeadminpassword'
   fi
fi

# Proceed further only if ${NEXUS_PASSWORD} is the correct password.
if [ $(curl -sf -o /dev/null -w "%{http_code}" -X GET -u admin:${NEXUS_PASSWORD} 'http://localhost:8081/service/siesta/rest/v1/script') -eq "200" ]; then
   # Change admin email
   if [ -n "${NEXUS_EMAIL}" ];then
      curl -sf -X POST -u admin:${NEXUS_PASSWORD} --header "Content-Type: application/json" 'http://localhost:8081/service/siesta/rest/v1/script' -d "{\"name\":\"changeadminemail\",\"type\":\"groovy\",\"content\":\"def user = security.securitySystem.getUser('admin');user.setEmailAddress('${NEXUS_EMAIL}');security.securitySystem.updateUser(user);\"}"
      curl -sf -X POST -u admin:${NEXUS_PASSWORD} --header "Content-Type: text/plain" "http://localhost:8081/service/siesta/rest/v1/script/changeadminemail/run"
      curl -sf -X DELETE -u admin:${NEXUS_PASSWORD} 'http://localhost:8081/service/siesta/rest/v1/script/changeadminemail'
   fi

   # Create a docker (hosted) repository which will be used as a private docker registry
   if [ -n "${DOCKER_REPOSITORY_NAME}" ] && [ -n "${DOCKER_REPOSITORY_PORT}" ];then
      curl -sf -X POST -u admin:${NEXUS_PASSWORD} --header "Content-Type: application/json" 'http://localhost:8081/service/siesta/rest/v1/script' -d "{\"name\":\"${DOCKER_REPOSITORY_NAME}\",\"type\":\"groovy\",\"content\":\"repository.createDockerHosted('${DOCKER_REPOSITORY_NAME}', ${DOCKER_REPOSITORY_PORT}, null, 'default', true, false)\"}"
      curl -sf -X POST -u admin:${NEXUS_PASSWORD} --header "Content-Type: text/plain" "http://localhost:8081/service/siesta/rest/v1/script/${DOCKER_REPOSITORY_NAME}/run"
      curl -sf -X DELETE -u admin:${NEXUS_PASSWORD} 'http://localhost:8081/service/siesta/rest/v1/script/${DOCKER_REPOSITORY_NAME}'
   fi

   # Create a maven proxy
   if [ -n "${MAVEN_PROXY_NAME}" ] && [ -n "${MAVEN_PROXY_URL}" ] && [ -n "${MAVEN_PROXY_USERNAME}" ] && [ -n "${MAVEN_PROXY_PASSWORD}" ];then
      curl -sf -X POST -u admin:${NEXUS_PASSWORD} --header "Content-Type: application/json" 'http://localhost:8081/service/extdirect' -d "{\"action\":\"coreui_Repository\",\"method\":\"create\",\"data\":[{\"attributes\":{\"maven\":{\"versionPolicy\":\"MIXED\",\"layoutPolicy\":\"PERMISSIVE\"},\"proxy\":{\"remoteUrl\":\"${MAVEN_PROXY_URL}\",\"contentMaxAge\":1440,\"metadataMaxAge\":1440},\"httpclient\":{\"blocked\":false,\"autoBlock\":true,\"authentication\":{\"type\":\"username\",\"username\":\"${MAVEN_PROXY_USERNAME}\",\"password\":\"${MAVEN_PROXY_PASSWORD}\",\"ntlmHost\":\"\",\"ntlmDomain\":\"\"},\"connection\":{\"useTrustStore\":false}},\"storage\":{\"blobStoreName\":\"default\",\"strictContentTypeValidation\":false},\"negativeCache\":{\"enabled\":true,\"timeToLive\":1440}},\"name\":\"${MAVEN_PROXY_NAME}\",\"format\":\"\",\"type\":\"\",\"url\":\"\",\"online\":true,\"authEnabled\":true,\"httpRequestSettings\":false,\"recipe\":\"maven2-proxy\"}],\"type\":\"rpc\",\"tid\":11}"
   fi
fi
