 # Amazon Machine Image (AMI) 
   An AMI is a template that contains the software configuration (operating system, application server, and applications) required to launch your instance.  
**An AMI is specific to the following:**  
     Region  
     Operating system
   
   **AMI ID** : An AMI ID is a unique identifier assigned to each Amazon Machine Image (AMI) in AWS.  
   Example: ami-0abcdef1234567890
  
  The AMI catalog contains applications and OS images organized as follows:  

    
**MY AMIS** - Private AMIs you've created or AMIs shared with you by another AWS account.  
**AWS Marketplace AMIs** - Publicly available AMIs published by AWS or trusted third parties.  
  
  You can launch multiple instances from a single AMI when you require multiple instances with the same configuration. You can use different AMIs to launch instances when you require instances with different configurations, as shown in the following diagram.

![image](https://github.com/user-attachments/assets/18e00723-dff0-46ed-bec4-9d0dd9565920)  

# Username
When you launch an Amazon EC2 instance from an Amazon Machine Image (AMI), the AMI determines the default username you use to connect to that instance. This username is often tied to the operating system or the specific distribution the AMI is based on.

Here are the common default usernames for various AWS AMIs:

Amazon Linux AMI / Amazon Linux 2 / Amazon Linux 2023: ec2-user  
Ubuntu AMI: ubuntu  
CentOS AMI: centos or ec2-user  
Debian AMI: admin  
Fedora AMI: fedora or ec2-user  
Red Hat Enterprise Linux (RHEL) AMI: ec2-user or root  
SUSE Linux Enterprise Server (SLES) AMI: ec2-user or root  
Oracle Linux AMI: ec2-user  
Bitnami AMIs: bitnami  
Rocky Linux: rocky   



