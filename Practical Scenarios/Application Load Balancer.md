Let's set up a practical scenario to practice AWS Application Load Balancer (ALB) with step-by-step instructions. We'll simulate a simple web application with two different services (e.g., a "homepage" and a "blog") hosted on separate EC2 instances, and use the ALB to route traffic to them based on the URL path.

**Scenario: Microservices with Path-Based Routing**

You are building a small web application. To demonstrate the power of microservices and ALB's path-based routing, you decide to split your application into two distinct parts:

1.  **Homepage Service:** This service will serve your main website content, accessible at the root URL (e.g., `http://your-alb-dns/`).
2.  **Blog Service:** This service will host your blog, accessible at a specific path (e.g., `http://your-alb-dns/blog`).

Both services will run on separate EC2 instances. The ALB will act as the single entry point, directing requests to the correct backend service based on the URL path.

**Prerequisites:**

  * An active AWS account.
  * Basic understanding of AWS EC2, VPC, and Security Groups.
  * (Optional but recommended) An SSH client (e.g., PuTTY for Windows, Terminal for macOS/Linux) to connect to your EC2 instances.

-----

### Step-by-Step Procedure

**Phase 1: Launch EC2 Instances and Prepare Web Servers**

We'll launch two EC2 instances, each serving a different web page.

1.  **Create a Security Group for EC2 Instances:**

      * Go to the EC2 console.
      * In the left navigation pane, under "Network & Security," click "Security Groups."
      * Click "Create security group."
      * **Security group name:** `web-server-sg`
      * **Description:** `Allow HTTP and SSH access to web servers`
      * **VPC:** Select your default VPC or a custom VPC where you want to launch instances.
      * **Inbound rules:**
          * Add Rule:
              * **Type:** `SSH`
              * **Source:** `My IP` (or `0.0.0.0/0` for wider access, but less secure)
          * Add Rule:
              * **Type:** `HTTP`
              * **Source:** `Custom` -\> For now, set this to `0.0.0.0/0`. We will restrict this later to only allow traffic from the ALB.
      * Click "Create security group."

2.  **Launch EC2 Instance 1 (Homepage Service):**

      * Go to the EC2 console.

      * Click "Launch instances."

      * **Name:** `Homepage-Server`

      * **Application and OS Images (Amazon Machine Image):** Choose `Amazon Linux 2023 AMI` (or similar, free tier eligible).

      * **Instance type:** `t2.micro` (free tier eligible).

      * **Key pair (login):** Choose an existing key pair or create a new one. (Remember to download it if creating new).

      * **Network settings:**

          * **VPC:** Select the same VPC as your security group.
          * **Subnet:** Choose a public subnet in **Availability Zone 1** (e.g., `ap-south-1a`). Ensure "Auto-assign public IP" is enabled.
          * **Firewall (security groups):** Select `Select existing security group` and choose `web-server-sg`.

      * **Advanced details:**

          * Scroll down to "User data" and paste the following script. This will install Apache and create a simple `index.html` for the homepage.

        <!-- end list -->

        ```bash
        #!/bin/bash
        sudo yum update -y
        sudo yum install -y httpd
        sudo systemctl start httpd
        sudo systemctl enable httpd
        echo "<h1>Hello from Homepage Server!</h1>" | sudo tee /var/www/html/index.html
        echo "<p>This is your main website.</p>" | sudo tee -a /var/www/html/index.html
        ```

      * Click "Launch instance."

3.  **Launch EC2 Instance 2 (Blog Service):**

      * Repeat the steps for "Launch EC2 Instance 1," with the following changes:

          * **Name:** `Blog-Server`
          * **Subnet:** Choose a public subnet in **Availability Zone 2** (e.g., `ap-south-1b`). It's crucial to have instances in different AZs for high availability.
          * **User data:** Use the following script. Notice the content is different, and we'll create a `blog` directory.

        <!-- end list -->

        ```bash
        #!/bin/bash
        sudo yum update -y
        sudo yum install -y httpd
        sudo systemctl start httpd
        sudo systemctl enable httpd
        sudo mkdir -p /var/www/html/blog
        echo "<h1>Welcome to the Blog!</h1>" | sudo tee /var/www/html/blog/index.html
        echo "<p>This is where we share our thoughts.</p>" | sudo tee -a /var/www/html/blog/index.html
        ```

      * Click "Launch instance."

    *Wait for both instances to be in the "Running" state and "2/2 checks passed."*

**Phase 2: Create Target Groups**

Target groups are logical groupings of your instances. The ALB will forward requests to one of these groups.

1.  **Create Target Group for Homepage Service:**

      * Go to the EC2 console.
      * In the left navigation pane, under "Load Balancing," click "Target Groups."
      * Click "Create target group."
      * **Choose a target type:** `Instances`
      * **Target group name:** `homepage-tg`
      * **Protocol:** `HTTP`
      * **Port:** `80`
      * **VPC:** Select the same VPC where your EC2 instances are.
      * **Health checks:**
          * **Protocol:** `HTTP`
          * **Path:** `/` (default, suitable for our homepage)
      * Click "Next."
      * **Register targets:** Select the `Homepage-Server` instance.
      * Ensure port `80` is selected, then click "Include as pending below."
      * Click "Create target group."

2.  **Create Target Group for Blog Service:**

      * Repeat the steps for "Create Target Group for Homepage Service," with the following changes:
          * **Target group name:** `blog-tg`
          * **Health checks Path:** `/blog` (This is important\! The ALB will check this path on the blog server to determine its health.)
          * **Register targets:** Select the `Blog-Server` instance.
      * Click "Create target group."

    *Wait a few minutes for the targets in both target groups to show as "healthy." You can check this by selecting each target group and going to the "Targets" tab.*

**Phase 3: Create Application Load Balancer (ALB)**

Now, we'll create the ALB and configure its listeners and rules.

1.  **Create Load Balancer:**

      * Go to the EC2 console.
      * In the left navigation pane, under "Load Balancing," click "Load Balancers."
      * Click "Create Load Balancer."
      * Under "Application Load Balancer," click "Create."
      * **Basic configuration:**
          * **Load balancer name:** `my-web-alb`
          * **Scheme:** `Internet-facing` (to access it from the internet)
          * **IP address type:** `IPv4`
      * **Network mapping:**
          * **VPC:** Select the same VPC where your instances and target groups are.
          * **Mappings:** Select at least two Availability Zones and choose a public subnet in each of those AZs. *Choose the same AZs where your `Homepage-Server` and `Blog-Server` are located.*
      * **Security groups:**
          * Click "Create a new security group."
          * **Security group name:** `alb-sg`
          * **Description:** `Allow HTTP access to ALB`
          * **Inbound rules:**
              * Add Rule:
                  * **Type:** `HTTP`
                  * **Source:** `0.0.0.0/0` (Allow all inbound HTTP traffic)
          * Click "Create security group."
          * Then, go back to the ALB creation page and ensure `alb-sg` is selected. (You might need to refresh the list).
      * **Listeners and routing:**
          * **Listener protocol:port:** `HTTP:80` (default)
          * **Default action:** `Forward to` -\> Select `homepage-tg` (This will be the default target group if no other rules match).
      * Review and click "Create load balancer."

    *Wait a few minutes for the ALB to provision. Its state will change from "provisioning" to "active."*

**Phase 4: Configure Path-Based Routing Rules**

This is where the magic of ALB happens. We'll add a rule to direct `/blog` traffic.

1.  **Add Listener Rule:**
      * Once your `my-web-alb` is active, select it in the Load Balancers list.
      * Go to the "Listeners" tab.
      * Select the `HTTP:80` listener.
      * Click "View/edit rules."
      * Click the "Insert Rule" button (plus sign with a horizontal line) between the default rule and the `If (true)` rule.
      * **Step 1: Add condition:**
          * Click "Add condition."
          * Choose "Path."
          * **Path condition:** `/blog*` (The `*` is important to match `/blog`, `/blog/`, `/blog/post1`, etc.)
          * Click "Confirm."
      * **Step 2: Add action:**
          * Click "Add action."
          * Choose "Forward to."
          * **Target groups:** Select `blog-tg`.
      * **Step 3: Priorities:** Keep the default priority (it will auto-assign a higher priority than the default rule).
      * **Step 4: Review and create:** Review your rule and click "Save changes."

**Phase 5: Update Security Group for EC2 Instances (Restrict Access)**

Now that the ALB is the front door, we should restrict direct access to our EC2 instances for better security.

1.  **Modify `web-server-sg`:**
      * Go to the EC2 console, then "Security Groups."
      * Select `web-server-sg`.
      * Go to the "Inbound rules" tab.
      * Click "Edit inbound rules."
      * **For the HTTP rule (Port 80):**
          * Change the **Source** from `0.0.0.0/0` to `Custom`.
          * In the search box, start typing `alb-sg` and select the security group you created for the ALB (`alb-sg`). This allows only traffic from the ALB to reach your instances.
      * Click "Save rules."

**Phase 6: Test Your Application Load Balancer**

1.  **Get ALB DNS Name:**

      * Go to the EC2 console.
      * In the left navigation pane, under "Load Balancing," click "Load Balancers."
      * Select `my-web-alb`.
      * Under the "Description" tab, copy the **DNS name**. It will look something like `my-web-alb-1234567890.ap-south-1.elb.amazonaws.com`.

2.  **Test in Browser:**

      * Open a web browser and paste the **ALB DNS name**. You should see:
        `Hello from Homepage Server!`
        `This is your main website.`
      * Now, in the same browser, append `/blog` to the DNS name (e.g., `http://my-web-alb-1234567890.ap-south-1.elb.amazonaws.com/blog`). You should see:
        `Welcome to the Blog!`
        `This is where we share our thoughts.`

**Congratulations\!** You have successfully configured an AWS Application Load Balancer with path-based routing, distributing traffic to different backend EC2 instances based on the URL path.

-----

### Clean Up (Important\!)

To avoid incurring charges, remember to clean up all the resources you created.

1.  **Delete Load Balancer:**

      * Go to the EC2 console -\> "Load Balancers."
      * Select `my-web-alb`.
      * Click "Actions" -\> "Delete load balancer." Confirm the deletion.

2.  **Delete Target Groups:**

      * Go to the EC2 console -\> "Target Groups."
      * Select `homepage-tg` and `blog-tg`.
      * Click "Actions" -\> "Delete." Confirm the deletion.

3.  **Terminate EC2 Instances:**

      * Go to the EC2 console -\> "Instances."
      * Select `Homepage-Server` and `Blog-Server`.
      * Click "Instance state" -\> "Terminate instance." Confirm the termination.

4.  **Delete Security Groups:**

      * Go to the EC2 console -\> "Security Groups."
      * Select `web-server-sg` and `alb-sg`.
      * Click "Actions" -\> "Delete security groups." Confirm the deletion.
          * *Note: You might need to refresh the page or wait a moment after deleting the ALB and instances before you can delete the associated security groups, as they might still show dependencies.*

This practical scenario covers the core aspects of ALB setup, including creating instances, target groups, the load balancer itself, and configuring advanced routing rules, while also emphasizing proper cleanup.
