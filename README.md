Demo ECS/Terraform Config
=========================

Project Requirements
============
* publish a repo on github that i can clone
* i should be able to easily deploy a docker container containing a simple hello world app (https://hub.docker.com/r/training/webapp/)  that we can curl against to get a response.
* i should also be able to publish that app to AWS very simply
* app should be fronted by an ELB
* app should be integrated into cloudwatch or some other monitoring solution
* use code as infrastructure approach to do this
* bonus - basic IAM should be in place

Setup
=====
* Install terraform

Usage
=====
* `terraform apply`


TODO
====
* Refactor hello_ecs_service.tf into a module to enable multiple services on one ECS cluster
* Refactor ecs_cluster.tf into a module to enable multiple ECS clusters

Known Issues
============
* Currently only runs one service, ideally should be refactored to handle multiple services via Terraform modules
* Only tested in us-east-1, due to default AMI, must lookup other regions AMIs
* Must run twice on first run, due to a race condition between container
