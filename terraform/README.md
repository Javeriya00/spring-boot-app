Automated Spring Boot Deployment with Terraform and AWS EC2

**Description:**
Designed and implemented an automated Spring Boot application deployment leveraging AWS EC2 instances and Terraform. This project involved provisioning cloud infrastructure and automating the build and deployment process, reducing manual intervention and ensuring consistent application delivery.

**Technologies Used:**
- **AWS EC2**: Provisioned instances to run the Spring Boot application.
- **Terraform**: Automated the creation of AWS resources, including VPC, subnets, security groups, and EC2 instances.
- **Spring Boot**: Developed and packaged the application to run on the cloud.
- **Maven**: Used for building the application and managing dependencies.
- **Bash**: Automated tasks such as cloning repositories, cleaning build directories, and managing application deployment.
  
**Key Features:**
- Automated the deletion of the `target` directory during the build process to ensure a clean environment.
- Implemented retry logic for directory cleanup to handle potential file locks or permission issues.
- Integrated Maven commands into EC2 provisioning for continuous integration and deployment.
- Ensured seamless application execution with logs captured for monitoring.

Code to generate a public key file:
  ssh-keygen -t rsa -b 4096 -f my-key.pem
#this creates my-key.pem and my-key.pem.pub files that would be used on code to attach the key value pair to the instance

Note: SSH access to instance isn't possible just with attaching the Key-Pair because:
1. If the VPC had no Internet Gateway (IGW) - Without an IGW, your VPC is completely isolated from the internet. It's like having a house with no door to the outside.
2. And even with an IGW, you need a route table to tell traffic how to get to the internet (0.0.0.0/0) through the IGW. Think of it as having a door but no pathway to reach it.
3. This is why the full networking stack (IGW + route table + associations) is essential for making your EC2 instance accessible via SSH from the internet, even if you have the key pair properly configured.



