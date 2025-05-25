 #Amazon Elastic Compute Cloud (EC2)

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

**Number of vCPUs:** Virtual CPUs (cores) available to the instance.  

**Amount of Memory (RAM):** The amount of RAM (in GiB) allocated to the instance.  

**Storage Options:**  

**EBS-backed:** Uses Amazon Elastic Block Store (EBS) for persistent block storage.  

**Instance Store:** Provides temporary, block-level storage directly attached to the host computer. This storage is ephemeral, meaning data is lost when the instance is stopped or terminated.  

**NVMe SSDs:** High-performance local storage.  

**Network Performance:**  
The network bandwidth available to the instance (e.g., "up to 10 Gigabit," "25 Gigabit").  
**Processor Family:** Whether it uses Intel, AMD, or AWS Graviton (ARM-based) processors.  
**Other features:** Such as support for Elastic Fabric Adapter (EFA) for high-performance computing, or specific instruction sets.  
AWS offers a vast array of instance types, each optimized for different use cases and workloads. They are grouped into instance families based on their primary characteristics and performance profiles.


**AWS EC2 Instance Families and Their Use Cases:**  

Here's a breakdown of the main instance families and their typical use cases:

**1. General Purpose Instances (Balanced)**  

Characteristics: Provide a balance of compute, memory, and networking resources. Good for a wide range of workloads.  

Use Cases: Web servers, application servers, development environments, small and medium databases, microservices, code repositories, data logging.  

**Examples:**    
**M-series (M5, M6g, M6i, M7g, M7i):**  The most common general-purpose choice, offering a good balance. M6g and M7g use AWS Graviton processors (ARM-based), which can offer better price-performance for many workloads.    
**T-series (T2, T3, T3a, T4g):**  Burstable performance instances. These provide a baseline level of CPU performance with the ability to burst above the baseline when needed (using CPU credits). Ideal for applications with variable CPU usage like dev/test environments, small web servers, and low-traffic applications. T4g uses AWS Graviton processors.    
**A-series (A1):**  Powered by AWS Graviton (ARM-based) processors, offering cost savings for scale-out workloads.    
**Mac Instances (Mac1, Mac2):** Dedicated macOS instances for developing, building, testing, and signing Apple applications.    

**2.Compute Optimized Instances (High CPU)**       

Characteristics: Ideal for compute-intensive applications that benefit from high-performance processors.  
Use Cases: High-performance web servers, scientific modeling, batch processing, media transcoding, gaming servers, high-performance computing (HPC), machine learning inference.  
Examples:
C-series (C5, C6g, C6i, C7g, C7i): Offer a high ratio of vCPUs to memory. C6g and C7g use AWS Graviton processors.  

**3. Memory Optimized Instances (High RAM)**  

Characteristics: Designed for workloads that process large in-memory datasets.
Use Cases: High-performance databases (e.g., SAP HANA), in-memory caches (e.g., Redis, Memcached), big data analytics (e.g., Apache Spark), real-time processing of large unstructured data.  

**Examples:**  
**R-series (R5, R6g, R6i, R7g, R7i):** High memory-to-vCPU ratio. R6g and R7g use AWS Graviton processors.  
**X-series (X1, X1e, X2idn, X2iedn):** Extremely high memory capacity, suitable for very large-scale in-memory databases and analytics.  
**High Memory Instances (U-series):** Specifically designed for very large SAP HANA deployments, offering terabytes of memory.  
**Z-series (z1d):** Combines high compute performance with a high memory-to-vCPU ratio, ideal for electronic design automation (EDA) and relational databases with high per-core licensing costs.

**4. Storage Optimized Instances (High I/O Performance)**  

Characteristics: Optimized for workloads that require high sequential read and write access to very large datasets, often with local NVMe SSD storage.  
Use Cases: NoSQL databases (e.g., Cassandra, MongoDB), data warehousing, distributed file systems (e.g., HDFS), log processing, search engines, analytics workloads.  

**Examples:**  

**I-series (I3, I3en, I4i, I4g):** Offer high I/O performance with NVMe SSDs.  
**D-series (D2, D3, D3en):** Provide dense storage with large HDD capacities, suitable for big data workloads and data warehousing.  
**H-series (H1):** High-throughput instances for distributed file systems and data warehousing.  
**Im4gn/Is4gen:** Graviton-powered instances with NVMe SSDs, optimized for dense storage and I/O.  

**5. Accelerated Computing Instances (Hardware Accelerators)**  

Characteristics: Utilize hardware accelerators (GPUs, FPGAs, AWS Inferentia, AWS Trainium) to perform functions like floating-point calculations, graphics processing, or data pattern matching more efficiently than CPUs alone.  
Use Cases: Machine learning (training and inference), high-performance computing (HPC), graphics rendering, video processing, scientific simulations.  

**Examples:**  

**P-series (P3, P4d, P5):** High-performance NVIDIA GPU-based instances for deep learning training and HPC.  
**G-series (G4dn, G5, G6, G6e, Gr6):** GPU-based instances suitable for graphics-intensive applications, machine learning inference, and game streaming.  
**F-series (F1):** Field Programmable Gate Array (FPGA)-based instances for custom hardware acceleration.  
**Inf-series (Inf1, Inf2):** Powered by AWS Inferentia chips, purpose-built for high-performance machine learning inference.  
**Trn-series (Trn1, Trn1n):** Powered by AWS Trainium chips, purpose-built for high-performance deep learning training.  
**VT-series (VT1):** Optimized for high-performance video transcoding.  

**6. High Performance Computing (HPC) Optimized Instances**  

Characteristics: Designed for tightly coupled HPC workloads that require high-performance processors and very high network throughput, often with Elastic Fabric Adapter (EFA).  
Use Cases: Complex scientific simulations, computational fluid dynamics, weather modeling, financial modeling.  

**Examples:**   
**Hpc-series (Hpc6a, Hpc6id, Hpc7a, Hpc7g):** Specific instance types built for HPC.  

**Key Pair**    
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

**Why is it Important?**  

**Security:** It's the primary and most secure method for logging into Linux EC2 instances. It's much more secure than password-based authentication, which is susceptible to brute-force attacks.  

**Authentication:** It verifies your identity to the EC2 instance, allowing you to establish a secure connection.  

**Remote Access:** It enables you to remotely administer and interact with your EC2 instances.  

**Best Practices for Key Pairs:**  

**Protect your Private Key:**  
Store your private key file (.pem or .ppk) in a secure location on your local machine.  
Set appropriate file permissions (e.g., chmod 400 your-key.pem on Linux/macOS) so that only you can read it.  

**Never share your private key.**  

Consider using an SSH agent to manage your keys, so you don't have to type your passphrase repeatedly.  


