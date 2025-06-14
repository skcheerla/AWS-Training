 # Amazon Elastic Compute Cloud (EC2)

**Create, manage, and monitor virtual servers in the cloud.**
    Amazon Elastic Compute Cloud (Amazon EC2) offers the broadest and deepest compute platform, with over 750 instances and choice of the latest processor, storage, networking, operating system, and purchase model to help you best match the needs of your workload. Amazon the first major cloud provider that supports Intel, AMD, and Arm processors, the only cloud with on-demand EC2 Mac instances, and the only cloud with 400 Gbps Ethernet networking. Amazon offer the best price performance for machine learning training, as well as the lowest cost per inference instances in the cloud. More SAP, high performance computing (HPC), ML, and Windows workloads run on AWS than any other cloud.

# Names and Tags  
   **Resource tags**  
        A tag is a label that you assign to an AWS resource. Each tag consists of a key and an optional value, both of which you define.  
    **Key**- Up to 128 Unicode characters in UTF-8  
    **Value** -Optional tag value up to 256 characters in UTF-8  
    **Resource types** - The resource type on which the tag will be created when an instance is launched from the launch template.  
    
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


# Key Pair   
In AWS, an EC2 Key Pair is a set of security credentials that you use to prove your identity when connecting to your EC2 instances. It's a critical component for secure access, especially to Linux instances via SSH.    

**Here's a breakdown of what a key pair is and how it works:**    

**What is a Key Pair?**   
An EC2 Key Pair consists of two parts:

**Public Key:**    

This part is stored by AWS and is injected into your EC2 instance when it's launched.  
For Linux instances, it's typically placed in the ~/.ssh/authorized_keys file for the default user (e.g., ec2-user, ubuntu, centos).  
For Windows instances, it's used by AWS to encrypt the administrator password, which you then decrypt using your private key.    

**Private Key:**    

This part is downloaded to your local computer only once when you create the key pair in AWS.  
It's a .pem (Privacy-Enhanced Mail) file for Linux/macOS users or a .ppk (PuTTY Private Key) file for Windows users who use PuTTY.  
You must keep this file secure and private. If you lose it, you cannot regenerate it, and you will lose the primary way to connect to any instance launched with that key pair.  

**How it Works (Public-Key Cryptography):**  

AWS key pairs leverage public-key cryptography (asymmetric encryption):  

When you launch an EC2 instance with a specified key pair, the public key is placed on the instance.  
When you try to connect to that instance (e.g., via SSH for Linux), your SSH client uses your private key to encrypt your login credentials.  
The EC2 instance uses its public key (which matches your private key) to decrypt your credentials and authenticate you.  
Because the public and private keys are mathematically linked, but the private key cannot be derived from the public key, this provides a highly secure authentication mechanism without transmitting passwords over the network.  

###  Why Key Pair is it Important? 

**Security:** It's the primary and most secure method for logging into Linux EC2 instances. It's much more secure than password-based authentication, which is susceptible to brute-force attacks.  

**Authentication:** It verifies your identity to the EC2 instance, allowing you to establish a secure connection.  

**Remote Access:** It enables you to remotely administer and interact with your EC2 instances.  

**Best Practices for Key Pairs:**  

**Protect your Private Key:**  
Store your private key file (.pem or .ppk) in a secure location on your local machine.  
Set appropriate file permissions (e.g., chmod 400 your-key.pem on Linux/macOS) so that only you can read it.  

**Never share your private key.**  

Consider using an SSH agent to manage your keys, so you don't have to type your passphrase repeatedly.  


