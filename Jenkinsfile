#!groovy
podTemplate(label: 'image-builder', containers: [
        containerTemplate(name: 'jnlp',
                image: 'henryrao/jnlp-slave',
                args: '${computer.jnlpmac} ${computer.name}',
                alwaysPullImage: true),
        containerTemplate(name: 'docker',
                image: 'docker:1.12.6',
                ttyEnabled: true,
                command: 'cat'),
],
        volumes: [
                hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
        ],
        workspaceVolume: persistentVolumeClaimWorkspaceVolume(claimName: 'jenkins-workspace', readOnly: false)
) {
    properties([
            pipelineTriggers([]),
            parameters([
                    string(name: 'imageRepo', defaultValue: 'henryrao/kubectl', description: 'Name of Image' ),
                    string(name: 'kubernetesVer', defaultValue: '1.5.2', description: 'Kubernetes Version' )
            ]),
    ])

    node('image-builder') {

        checkout scm
        def imgSha = ''
        container('docker') {

            stage('build') {
                imgSha = sh(returnStdout: true, script: "docker build --pull --build-arg kubernetesVer=${params.kubernetesVer} -q .").trim()[7..-1]
                echo "${imgSha}"
            }

            stage('test') {
                sh "docker run ${imgSha} kubectl get po"
            }

            stage('deploy') {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'docker-login', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    sh "docker login -u $USERNAME -p $PASSWORD"
                    sh "docker tag ${imgSha} ${params.imageRepo}:${params.kubernetesVer}"
                    sh "docker push ${params.imageRepo}:${params.kubernetesVer}"
                }
            }
        }
    }
}
