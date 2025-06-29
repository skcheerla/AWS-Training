# Security Groups - Statefull Firewall


![image](https://github.com/user-attachments/assets/7f056aa6-01cf-4e30-853f-be9f6442b1f8)


![image](https://github.com/user-attachments/assets/e11befa6-4c71-426e-8743-9bf6fc7a4038)



![image](https://github.com/user-attachments/assets/7d98ae8e-342d-489a-9b5b-737706dd9e7a)








# Network ACL's - Stateless Firewall

![image](https://github.com/user-attachments/assets/5a1ca993-777b-48c0-8fe0-e3e33577aed4)


![image](https://github.com/user-attachments/assets/c1ec1fd3-66f8-4ec2-959e-5b4f5e382468)



AWS Security Groups act as virtual firewalls that control inbound and outbound traffic for one or more **network interfaces**. Since many AWS services use Elastic Network Interfaces (ENIs) behind the scenes to provide network connectivity, you can effectively associate security groups with a wide range of services.

Here's a breakdown of the primary AWS services you can (and should) assign security groups to, along with explanations:

**Core Services that Directly Use Security Groups:**

1.  **Amazon EC2 Instances (Elastic Compute Cloud):** This is the most fundamental use case. Every EC2 instance is associated with one or more security groups, controlling all network traffic to and from that specific instance.
    * **Use Cases:** Web servers, application servers, batch processing, development environments, etc.

2.  **Elastic Load Balancers (ELBs):** This includes Application Load Balancers (ALBs), Network Load Balancers (NLBs), and Classic Load Balancers (CLBs).
    * **Use Cases:** You assign security groups to the ELB itself to control traffic *to* the load balancer (e.g., allow HTTP/HTTPS from the internet).
    * You also use security groups on the backend instances registered with the ELB to control traffic *from* the load balancer (e.g., allow traffic only from the ELB's security group).

3.  **Amazon RDS Instances (Relational Database Service):**
    * **Use Cases:** MySQL, PostgreSQL, Oracle, SQL Server, MariaDB, Aurora databases. You attach security groups to your RDS instances to restrict access to the database from specific EC2 instances, other services, or your on-premises network. This is crucial for database security.

4.  **Amazon Redshift Clusters:**
    * **Use Cases:** Data warehousing. Similar to RDS, security groups control network access to your Redshift cluster.

5.  **Amazon ElastiCache Clusters:**
    * **Use Cases:** Redis or Memcached caches. Security groups regulate access to your cache nodes.

6.  **AWS Lambda (when configured with VPC access):**
    * **Use Cases:** When your Lambda function needs to access resources within your VPC (like an RDS database, an EC2 instance, or a service running on a private IP), you configure it with VPC access. This involves assigning subnets and **security groups** to the Lambda function's ENI, allowing it to interact with other resources according to the security group rules.

7.  **Amazon ECS Tasks and EKS Pods (when configured with `awsvpc` network mode):**
    * **Use Cases:** Containerized applications. When using the `awsvpc` network mode for ECS tasks or when deploying pods in EKS, each task or pod gets its own ENI. You can then associate security groups with these ENIs to control their ingress and egress traffic.

8.  **Amazon DocumentDB Clusters:**
    * **Use Cases:** MongoDB-compatible database. Security groups control network access to DocumentDB clusters.

9.  **Amazon Neptune Clusters:**
    * **Use Cases:** Graph databases. Security groups control network access to Neptune clusters.

10. **Amazon MQ Brokers:**
    * **Use Cases:** Managed message brokers (ActiveMQ, RabbitMQ). Security groups control access to the broker endpoints.

11. **AWS Direct Connect Gateway:**
    * **Use Cases:** Connects your on-premises network to your VPCs. While not directly associated with the *gateway* itself, the VPC attachments for Direct Connect are typically within a VPC and subject to its networking constructs, including security groups on the resources they access.

12. **Interface Endpoints (AWS PrivateLink):**
    * **Use Cases:** Provides private connectivity to AWS services (e.g., S3, DynamoDB, EC2 APIs) from your VPC without using the internet gateway. When you create an interface endpoint, it provision an ENI in your VPC, and you can associate security groups with this ENI to control which resources within your VPC can access the endpoint.

13. **AWS Global Accelerator Endpoints (though often indirectly):**
    * While you don't directly assign a security group to a Global Accelerator endpoint, the underlying resources that Global Accelerator points to (e.g., ELBs, EC2 instances) will have security groups that need to allow traffic from Global Accelerator's IP ranges.

**Key Principles of Security Groups:**

* **Instance Level:** Security groups operate at the instance or ENI level, not the subnet level (that's what Network ACLs are for).
* **Stateful:** If you allow inbound traffic, the outbound return traffic is automatically allowed, and vice versa. You don't need to explicitly create an outbound rule for the response.
* **Allow Rules Only:** Security groups are always permissive. You can only define rules that *allow* traffic. Any traffic not explicitly allowed is implicitly denied.
* **Default Deny:** By default, a new security group denies all inbound traffic and allows all outbound traffic.
* **Referencing Other Security Groups:** You can allow traffic from or to other security groups, which simplifies management for interconnected services (e.g., allowing a web server security group to talk to a database security group).

In essence, any AWS resource that has a **network interface** (ENI) within a VPC can have one or more security groups associated with it to control its network traffic.



