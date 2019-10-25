# devops-task
This Project is used for setting up infra for spring-petclinic project, and a CI/CD pipeline setup to build and push docker image.

Please fork the main github project https://github.com/spring-projects/spring-petclinic .

### Pre-requisites
1. Azure account 
2. terraform

### Steps 
- Clone the project and run following three commands 
terraform init , terraform plan and terraform apply

- This will create a resource gorup , 1VNET , 2Subnets(One Public and One Private) , brings up Ubuntu VM in each subnet and a load balancer on the Azure cloud.

- Jenkins will be installed in public VM ,you can access Jenkins using http://testapp.koreacentral.cloudapp.azure.com:8080/ .
By default a seed job will be created ,run the seed job . This will create spring-petclinic job for us.
Add your docker credentials in Jenkins and Run spring-petclinic-job .
This Job will build jar using maven ,build docker image and push it to docker public repo.

- docker image will be pulled and spring-petclinic app will run on private subnet's VM .

- To access spring-petclinic application goto Azure portal and Load balancer , get the IP of Load balancer and hit the URL http://<ip>:9090 


### Note - 
- Update github url in config.xml ,docker username in docker-init.sh ,spring-petclinic-init.sh , Jenkinsfile .
- Also Commit Jenkinsfile and Dockerfile to your forked repo (in my case it's https://github.com/arjunarveti619/spring-petclinic) .
