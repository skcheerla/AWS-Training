
AWS Application Migration Service (AWS MGN) is a highly automated "lift-and-shift" (rehost) solution designed to simplify, expedite, and reduce the cost of migrating applications to AWS. It is the recommended service for most lift-and-shift migrations to AWS.

### How it Works

AWS MGN works by continuously replicating your source servers to your AWS account. It uses a lightweight agent installed on the source servers (or an agentless method for some VMware environments) to perform block-level replication. This means it creates an up-to-date copy of your servers in a staging area within your AWS account.

When you are ready to migrate, AWS MGN automatically converts and launches your servers as Amazon EC2 instances. This process is designed to minimize downtime and ensure a smooth transition.

### Key Features and Benefits

* **Continuous Data Replication:** AWS MGN continuously replicates data from your source servers to a staging area in your AWS account. This ensures that the data in the target environment is always up-to-date, minimizing data loss and downtime during the cutover.
* **Highly Automated:** The service automates many of the manual, time-consuming, and error-prone tasks involved in migration, such as server conversion and launching. This simplifies the process and reduces the time and effort required.
* **Minimal Downtime:** By using continuous replication and an automated cutover process, AWS MGN helps to minimize the planned downtime for your applications.
* **Flexibility:** It can migrate a wide range of applications from various source environments, including physical servers, virtual machines (VMware, Hyper-V, etc.), and even servers from other clouds.
* **Cost Reduction:** AWS MGN helps to reduce migration costs by providing a single, automated tool for a broad range of applications, eliminating the need for specialized skills or separate tools for each application. It also offers a free period of 90 days for each server migration.
* **Integration with AWS Services:** It integrates with other AWS services like AWS Migration Hub for centralized tracking and AWS Identity and Access Management (IAM) for user and access management.
* **Post-Migration Modernization:** Once your applications are running on AWS, you can leverage the full suite of AWS services to modernize them further, such as by right-sizing instances, enabling auto-scaling, and utilizing other cloud-native features.
