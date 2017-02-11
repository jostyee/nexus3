#!/bin/sh

# Background section
{
   # Wait for startup returning a unauthenticated response code
   while [ $(curl -sf -o /dev/null -w "%{http_code}" 'http://localhost:8081/service/siesta/rest/v1/script') -ne "403" ]; do
      echo "Waiting for nexus to start ..."
      sleep 7
   done

   # Change admin password
   if [ $(curl -sf -o /dev/null -w "%{http_code}" -X GET -u admin:${NEXUS_DEFAULT_PASSWORD} 'http://localhost:8081/service/siesta/rest/v1/script') -eq "200" ]; then
      if [ -n "${NEXUS_PASSWORD}" ];then
         curl -sf -X POST -u admin:${NEXUS_DEFAULT_PASSWORD} --header "Content-Type: application/json" 'http://localhost:8081/service/siesta/rest/v1/script' -d "{\"name\":\"changeadminpassword\",\"type\":\"groovy\",\"content\":\"security.securitySystem.changePassword('admin', '${NEXUS_PASSWORD}')\"}"
         curl -sf -X POST -u admin:${NEXUS_DEFAULT_PASSWORD} --header "Content-Type: text/plain" "http://localhost:8081/service/siesta/rest/v1/script/changeadminpassword/run"
         curl -sf -X DELETE -u admin:${NEXUS_DEFAULT_PASSWORD} "http://localhost:8081/service/siesta/rest/v1/script/changeadminpassword"
      fi
   fi

   # Proceed further only if ${NEXUS_PASSWORD} is the correct password.
   if [ $(curl -sf -o /dev/null -w "%{http_code}" -X GET -u admin:${NEXUS_PASSWORD} 'http://localhost:8081/service/siesta/rest/v1/script') -eq "200" ]; then
      # Change admin email
      if [ -n "${NEXUS_EMAIL}" ];then
         curl -sf -X POST -u admin:${NEXUS_PASSWORD} --header "Content-Type: application/json" 'http://localhost:8081/service/siesta/rest/v1/script' -d "{\"name\":\"changeadminemail\",\"type\":\"groovy\",\"content\":\"def user = security.securitySystem.getUser('admin');user.setEmailAddress('${NEXUS_EMAIL}');security.securitySystem.updateUser(user);\"}"
         curl -sf -X POST -u admin:${NEXUS_PASSWORD} --header "Content-Type: text/plain" "http://localhost:8081/service/siesta/rest/v1/script/changeadminemail/run"
         curl -sf -X DELETE -u admin:${NEXUS_PASSWORD} "http://localhost:8081/service/siesta/rest/v1/script/changeadminemail"
      fi

      # Create a docker (hosted) repository which will be used as a private docker registry
      if [ -n "${DOCKER_REPOSITORY_NAME}" ] && [ -n "${DOCKER_REPOSITORY_PORT}" ];then
         if [ $(curl -sf -o /dev/null -w "%{http_code}" -X GET -u admin:${NEXUS_PASSWORD} "http://localhost:${DOCKER_REPOSITORY_PORT}/v2/_catalog") -ne "200" ];then
            curl -sf -X POST -u admin:${NEXUS_PASSWORD} --header "Content-Type: application/json" 'http://localhost:8081/service/siesta/rest/v1/script' -d "{\"name\":\"${DOCKER_REPOSITORY_NAME}\",\"type\":\"groovy\",\"content\":\"repository.createDockerHosted('${DOCKER_REPOSITORY_NAME}', ${DOCKER_REPOSITORY_PORT}, null, 'default', true, false)\"}"
            curl -sf -X POST -u admin:${NEXUS_PASSWORD} --header "Content-Type: text/plain" "http://localhost:8081/service/siesta/rest/v1/script/${DOCKER_REPOSITORY_NAME}/run"
            curl -sf -X DELETE -u admin:${NEXUS_PASSWORD} "http://localhost:8081/service/siesta/rest/v1/script/${DOCKER_REPOSITORY_NAME}"
         fi
      fi
   fi
} &

exec "$@"
