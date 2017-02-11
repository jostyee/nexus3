#!groovy

def dockerImageName = env.JOB_NAME.substring(env.JOB_NAME.lastIndexOf('/') + 1)
def dockerRegistry = 'http://localhost:5000'
def dockerRepository = 'yourrepository'
def dockerCredentialsId = 'docker'

node {
    stage('Checkout') {
        checkout scm
    }

    def dockerImageTag = sh(returnStdout: true, script: 'git describe --all').trim().replaceAll(/(.*\/)?(.+)/,'$2')

    stage('Env') {
        echo scm.branches[0].name

        echo "*** Show env variables: ***" + \
             "\n dockerRegistry: " + dockerRegistry + \
             "\n dockerRepository: " + dockerRepository + \
             "\n dockerCredentialsId: " + dockerCredentialsId + \
             "\n dockerImageName: " + dockerImageName + \
             "\n dockerImageTag: " + dockerImageTag
    }

    stage('Build & Push') {
        docker.withRegistry(dockerRegistry, dockerCredentialsId) {

            // Set repository and image name
            def image = docker.build dockerRepository + "/" + dockerImageName, "--build-arg TAG=${dockerImageTag} ."

            // Push actual tag
            image.push(dockerImageTag)

            // Push latest tag if it's a release
            if ((dockerImageTag ==~ /v(\d+.\d+.\d+)/)) {
                image.push('latest')
            }

            echo "*** Docker image successfully pushed to registry. ***"
        }
    }
}