**Amazon Elastic Compute Cloud (EC2)**

**Create, manage, and monitor virtual servers in the cloud.**
    Amazon Elastic Compute Cloud (Amazon EC2) offers the broadest and deepest compute platform, with over 750 instances and choice of the latest processor, storage, networking, operating system, and purchase model to help you best match the needs of your workload. Amazon the first major cloud provider that supports Intel, AMD, and Arm processors, the only cloud with on-demand EC2 Mac instances, and the only cloud with 400 Gbps Ethernet networking. Amazon offer the best price performance for machine learning training, as well as the lowest cost per inference instances in the cloud. More SAP, high performance computing (HPC), ML, and Windows workloads run on AWS than any other cloud.

**Names and Tags**  
    **Resource tags**  
        A tag is a label that you assign to an AWS resource. Each tag consists of a key and an optional value, both of which you define.  
    **Key**- Up to 128 Unicode characters in UTF-8  
    **Value** -Optional tag value up to 256 characters in UTF-8  
    **Resource types** - The resource type on which the tag will be created when an instance is launched from the launch template.  
    
   **Amazon Machine Image (AMI)**  
   An AMI is a template that contains the software configuration (operating system, application server, and applications) required to launch your instance.  
   An AMI is specific to the following:  
     Region  
     Operating system
   
   **AMI ID** : An AMI ID is a unique identifier assigned to each Amazon Machine Image (AMI) in AWS.  
   Example: ami-0abcdef1234567890
  
  The AMI catalog contains applications and OS images organized as follows:  

    
**MY AMIS** - Private AMIs you've created or AMIs shared with you by another AWS account.  
**AWS Marketplace AMIs** - Publicly available AMIs published by AWS or trusted third parties.  
  
  You can launch multiple instances from a single AMI when you require multiple instances with the same configuration. You can use different AMIs to launch instances when you require instances with different configurations, as shown in the following diagram.

![image](https://github.com/user-attachments/assets/18e00723-dff0-46ed-bec4-9d0dd9565920)  

**Username**  
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

**InstanceType**
In Amazon Web Services (AWS), an instance type defines the virtual hardware configuration of an EC2 instance (your virtual server). When you launch an EC2 instance, you choose an instance type that specifies:

Number of vCPUs: Virtual CPUs (cores) available to the instance.  

Amount of Memory (RAM): The amount of RAM (in GiB) allocated to the instance.  

Storage Options:
EBS-backed: Uses Amazon Elastic Block Store (EBS) for persistent block storage.  

Instance Store: Provides temporary, block-level storage directly attached to the host computer. This storage is ephemeral, meaning data is lost when the instance is stopped or terminated.  

NVMe SSDs: High-performance local storage.  

Network Performance: The network bandwidth available to the instance (e.g., "up to 10 Gigabit," "25 Gigabit").  
Processor Family: Whether it uses Intel, AMD, or AWS Graviton (ARM-based) processors.  
Other features: Such as support for Elastic Fabric Adapter (EFA) for high-performance computing, or specific instruction sets. 


