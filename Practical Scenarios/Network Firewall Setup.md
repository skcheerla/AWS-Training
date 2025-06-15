You're in for a good hands-on experience! Setting up AWS Network Firewall involves several steps, and understanding the routing is key.

**Real-Time Scenario: Securing a Web Application with Outbound Controls**

Let's imagine you have a web application running on an EC2 instance in a private subnet. This application needs to:

1.  **Serve web traffic (HTTP/HTTPS) to the internet.**
2.  **Make outbound API calls to a specific external third-party service (e.g., `api.example.com`).**
3.  **Prevent any other unauthorized outbound connections (e.g., to known malicious domains, or general internet Browse from the application server).**
4.  **Allow SSH access from a specific bastion host (or your local IP) for management.**

We will use AWS Network Firewall to enforce these outbound controls and general inbound filtering.

**Architecture:**

* **VPC:** Your main network.
* **Public Subnet (with Internet Gateway):** For inbound internet traffic and potentially a bastion host.
* **Firewall Subnets (one per AZ):** Dedicated subnets where Network Firewall endpoints will be deployed. These are crucial for routing traffic through the firewall.
* **Private Application Subnet:** Where your EC2 web server will reside.
* **Route Tables:** Modified to direct traffic through the Network Firewall.

**High-Level Flow:**

1.  **Inbound Internet Traffic:** Internet Gateway -> Firewall Endpoint -> Application Load Balancer (optional) -> EC2 instance.
2.  **Outbound Internet Traffic from EC2:** EC2 instance -> Firewall Endpoint -> Internet Gateway.

---

**Step-by-Step Procedure:**

**Prerequisites:**

* An AWS Account.
* AWS Management Console access with sufficient permissions (IAM user with AdministratorAccess or specific Network Firewall, VPC, EC2 permissions).

---

**Step 1: Create Your VPC and Subnets**

We'll create a VPC with specific subnets to isolate our resources and dedicate a subnet for the Network Firewall endpoints.

1.  **Navigate to VPC:** Go to the AWS Management Console, search for "VPC", and click on it.
2.  **Create VPC:**
    * Click **"Create VPC"**.
    * Choose **"VPC and more"**.
    * **Name tag auto-generation:** `my-network-firewall-vpc`
    * **IPv4 CIDR block:** `10.0.0.0/16`
    * **Availability Zones (AZs):** Choose at least **two** AZs for high availability (e.g., `ap-south-1a`, `ap-south-1b`). Network Firewall deploys an endpoint in each selected AZ.
    * **Number of public subnets:** 1 (e.g., `10.0.0.0/24`)
    * **Number of private subnets:** 1 (e.g., `10.0.1.0/24`)
    * **NAT Gateways:** 0 (We will use the firewall for outbound).
    * **VPC Endpoints:** None.
    * Click **"Create VPC"**.

3.  **Identify Subnets:** Once the VPC is created, go to **"Subnets"** in the VPC dashboard. You'll see:
    * `my-network-firewall-vpc-public-ap-south-1a` (or similar) - Public Subnet
    * `my-network-firewall-vpc-private-ap-south-1a` (or similar) - Private Application Subnet
    * **Crucially, we need to create two new subnets specifically for the Network Firewall endpoints.**

4.  **Create Firewall Subnets:**
    * Click **"Create subnet"**.
    * **VPC ID:** Select your `my-network-firewall-vpc`.
    * **Availability Zone:** Select `ap-south-1a`.
    * **Subnet name:** `my-network-firewall-subnet-az1`
    * **IPv4 CIDR block:** `10.0.2.0/24` (Ensure it doesn't overlap with existing subnets).
    * Click **"Create subnet"**.
    * Repeat for a second AZ:
        * **Availability Zone:** Select `ap-south-1b`.
        * **Subnet name:** `my-network-firewall-subnet-az2`
        * **IPv4 CIDR block:** `10.0.3.0/24`

---

**Step 2: Create Network Firewall Rule Groups**

We'll define rules to allow specific traffic and deny the rest.

1.  **Navigate to Network Firewall:** In the VPC dashboard, under "Network Firewall", choose **"Network Firewall rule groups"**.

2.  **Create a Stateful Rule Group for Outbound Control:**
    * Click **"Create rule group"**.
    * **Rule group type:** `Stateful rule group`.
    * **Name:** `OutboundWebAccess`
    * **Description:** `Allows HTTP/S to example.com and blocks other web access`
    * **Capacity:** `100` (This reserves space for your rules. You can increase later if needed).
    * **Stateful rule group options:**
        * Choose **"Domain list"**.
        * **Action:** `Allow`
        * **Domain name source:**
            * Enter `api.example.com` (replace with a real domain you want to test, e.g., `google.com`)
            * Enter `*.aws.amazon.com` (for AWS services if your app needs them)
        * **Protocols:** Select `HTTP`, `HTTPS`.
        * **CIDR ranges:** Leave as `Default for a source IP address that exists in the same VPC as the firewall` (`10.0.0.0/16`).
        * Click **"Create rule group"**.

3.  **Create a Stateful Rule Group for Inbound SSH:**
    * Click **"Create rule group"**.
    * **Rule group type:** `Stateful rule group`.
    * **Name:** `InboundSSH`
    * **Description:** `Allows SSH from a specific IP address`
    * **Capacity:** `50`
    * **Stateful rule group options:**
        * Choose **"5-tuple"**.
        * **Action:** `Allow`
        * **Protocol:** `TCP`
        * **Source:** `Custom CIDR ranges` -> Enter *your current public IP address* (or your bastion host's IP).
        * **Source port:** `Any`
        * **Destination:** `Custom CIDR ranges` -> `10.0.1.0/24` (your private application subnet).
        * **Destination port:** `Custom port range` -> `22`
        * **Direction:** `Both`
        * Click **"Add rule"**.
        * Click **"Create rule group"**.

---

**Step 3: Create a Network Firewall Policy**

This policy will combine your rule groups and define default actions.

1.  **Navigate to Network Firewall:** In the VPC dashboard, under "Network Firewall", choose **"Firewall policies"**.
2.  **Create firewall policy:**
    * Click **"Create firewall policy"**.
    * **Name:** `MyAppFirewallPolicy`
    * **Description:** `Policy for MyApp VPC`
    * **Stream exception policy:** `Drop` (Recommended for strict security; this means if the firewall can't process a packet, it drops it).
    * Click **"Next"**.
    * **Add rule groups:**
        * **Stateless rule groups:** Leave empty for now. We'll forward all to stateful.
        * **Stateless default actions:**
            * **For packets that don't match rules:** `Forward to stateful rules`
            * **For packet fragments that don't match rules:** `Forward to stateful rules`
        * **Stateful rule groups:** Click **"Add rule groups"**.
            * Select `OutboundWebAccess` and `InboundSSH`.
            * Click **"Add rule groups"**.
        * **Stateful default actions:**
            * **Action order:** `Strict order` (Recommended for predictable behavior).
            * **Default action for untracked connections:** `Drop` (This will block anything not explicitly allowed by your stateful rules).
            * **Default action for established connections:** `Drop` (For strict "allow-list" model. For more permissive, you could choose "Alert").
    * Click **"Next"** (for tags, optional).
    * Click **"Next"** to review.
    * Click **"Create firewall policy"**.

---

**Step 4: Create the Network Firewall**

Now, we'll deploy the firewall itself and associate it with the policy.

1.  **Navigate to Network Firewall:** In the VPC dashboard, under "Network Firewall", choose **"Firewalls"**.
2.  **Create firewall:**
    * Click **"Create firewall"**.
    * **Name:** `MyVPCNetworkFirewall`
    * **Description:** `Network Firewall for MyApp VPC`
    * **VPC:** Select your `my-network-firewall-vpc`.
    * **Availability Zone and subnet:**
        * For `ap-south-1a`, select `my-network-firewall-subnet-az1`.
        * For `ap-south-1b`, select `my-network-firewall-subnet-az2`.
    * **Associated firewall policy:** Select **"Associate an existing firewall policy"** and choose `MyAppFirewallPolicy`.
    * **Logging (Recommended!):**
        * Click **"Browse"** under **"Logging destination"**.
        * Choose **"Amazon S3 bucket"**.
        * **Log type:** Select `Alert` and `Flow`.
        * Create two new S3 buckets (e.g., `my-firewall-alert-logs-uniqueid` and `my-firewall-flow-logs-uniqueid`) for storing the logs. This is critical for monitoring and troubleshooting.
        * Click **"Create S3 bucket"** for each, then **"Choose"**.
    * Click **"Create firewall"**.

    *Wait for the firewall to be in the `Ready` state.* This can take a few minutes. Make a note of the **Firewall Endpoints** generated for each AZ (they will look like `vpce-xxxxxxxxxxxxxxxxx`). These are the crucial targets for your route tables.

---

**Step 5: Update VPC Route Tables**

This is the most critical and often tricky part. We need to redirect traffic through the firewall endpoints.

You will have three main route tables (or more if you have different subnets):

* **Public Subnet Route Table:** For internet-bound traffic, point to the Firewall Endpoint.
* **Private Application Subnet Route Table:** For internet-bound traffic, point to the Firewall Endpoint.
* **Internet Gateway Route Table (IGW RT):** For inbound traffic from the internet, point to the Firewall Endpoint.
* **Firewall Subnet Route Table:** For traffic leaving the firewall endpoint, point to the Internet Gateway or other internal destinations.

1.  **Navigate to Route Tables:** In the VPC dashboard, choose **"Route tables"**.

2.  **Modify Public Subnet Route Table:**
    * Find the route table associated with your `my-network-firewall-vpc-public-ap-south-1a` subnet (it should have a route to `0.0.0.0/0` via the Internet Gateway).
    * Select it and go to the **"Routes"** tab.
    * Click **"Edit routes"**.
    * **Add route:**
        * **Destination:** `0.0.0.0/0` (all internet-bound traffic)
        * **Target:** `Network Firewall endpoint` -> Choose the Firewall Endpoint in `ap-south-1a`.
    * Click **"Save changes"**.

3.  **Modify Private Application Subnet Route Table:**
    * Find the route table associated with your `my-network-firewall-vpc-private-ap-south-1a` subnet.
    * Select it and go to the **"Routes"** tab.
    * Click **"Edit routes"**.
    * **Add route:**
        * **Destination:** `0.0.0.0/0` (all internet-bound traffic)
        * **Target:** `Network Firewall endpoint` -> Choose the Firewall Endpoint in `ap-south-1a`.
    * Click **"Save changes"**.

4.  **Create and Configure Internet Gateway Route Table:** This is essential for inbound traffic.
    * Click **"Create route table"**.
    * **Name:** `IGW-Route-Table`
    * **VPC:** Select `my-network-firewall-vpc`.
    * Click **"Create route table"**.
    * Select `IGW-Route-Table`.
    * Go to **"Edge Associations"**.
    * Click **"Edit edge associations"**.
    * Select your `Internet Gateway` (`igw-xxxxxxxxxxxxxxxxx`).
    * Click **"Save changes"**.
    * Go to **"Routes"**.
    * Click **"Edit routes"**.
    * **Add route:**
        * **Destination:** `10.0.0.0/16` (your VPC CIDR)
        * **Target:** `Network Firewall endpoint` -> Choose the Firewall Endpoint in `ap-south-1a` (or `ap-south-1b` if you want to test failover). For simplicity, let's use `ap-south-1a`. This means all inbound traffic to your VPC will first go to the firewall.
    * Click **"Save changes"**.

5.  **Configure Firewall Subnet Route Tables:**
    * Find the route table associated with `my-network-firewall-subnet-az1`.
    * Select it and go to the **"Routes"** tab.
    * Click **"Edit routes"**.
    * **Add route:**
        * **Destination:** `0.0.0.0/0`
        * **Target:** `Internet Gateway` -> Select your `igw-xxxxxxxxxxxxxxxxx`. (This routes traffic *from* the firewall *to* the internet).
    * Click **"Save changes"**.
    * Repeat for `my-network-firewall-subnet-az2`.

**Important Note on Routing:**
* **Symmetric Routing:** AWS Network Firewall requires symmetric routing. This means the inbound and outbound paths for a given connection must traverse the same firewall endpoint. The routing configuration above aims to achieve this by directing all internet-bound traffic through the firewall.
* For multi-AZ deployments, traffic will be distributed across the firewall endpoints in different AZs. The route tables effectively ensure that if traffic enters through IGW in AZ1, it's sent to Firewall Endpoint in AZ1, and then leaves through IGW in AZ1 for outbound responses.

---

**Step 6: Launch an EC2 Instance in the Private Application Subnet**

1.  **Navigate to EC2:** Go to the AWS Management Console, search for "EC2", and click on it.
2.  **Launch an instance:**
    * Choose an AMI (e.g., Amazon Linux 2 or Ubuntu).
    * Choose `t2.micro` (free tier eligible).
    * **Network:** Select your `my-network-firewall-vpc`.
    * **Subnet:** Select your `my-network-firewall-vpc-private-ap-south-1a` subnet.
    * **Auto-assign Public IP:** `Disable` (This instance will only have private IP, relying on the firewall for internet access).
    * **Security Group:** Create a new security group.
        * **Inbound rules:**
            * Allow SSH (Port 22) from your bastion host's IP (or your local public IP for testing).
            * Allow HTTP (Port 80) and HTTPS (Port 443) from the **VPC CIDR (`10.0.0.0/16`)** if you plan to use an ALB later, or from the public subnet's CIDR (`10.0.0.0/24`) if you want direct access from the public subnet. For this scenario, let's assume an ALB or internal access.
        * **Outbound rules:** Allow all outbound traffic for now (the Network Firewall will control this).
    * **Key pair:** Choose or create a key pair.
    * Launch the instance.

---

**Step 7: Testing the Network Firewall Setup**

1.  **SSH into the EC2 Instance:**
    * If you set up a bastion host in the public subnet, SSH into the bastion, then from the bastion, SSH into your private EC2 instance using its private IP.
    * If you allowed direct SSH from your local IP in the EC2 security group, you won't be able to connect directly because the Network Firewall policy is now in place and only allows SSH from your specific IP to the private subnet via the firewall endpoint.

    *After the firewall is active and routes are updated, if you try to SSH directly into the private EC2 instance from a non-allowed source, it should be blocked by the `InboundSSH` rule group or the default `Drop` action.*

2.  **Test Outbound Access (Success Case):**
    * Once SSH'd into the private EC2 instance.
    * Try to `ping api.example.com` (or `google.com`) or `curl https://api.example.com`.
        ```bash
        sudo yum install -y curl  # For Amazon Linux
        # or sudo apt-get update && sudo apt-get install -y curl # For Ubuntu
        curl -v https://google.com
        ```
    * This should succeed because our `OutboundWebAccess` rule group explicitly allows traffic to these domains.

3.  **Test Outbound Access (Blocked Case):**
    * Try to `curl https://www.facebook.com` or `curl https://www.youtube.com`.
    * These requests should **fail** because they are not explicitly allowed by the `OutboundWebAccess` rule group and will be caught by the default `Drop` action for untracked connections in the firewall policy. You might see a connection timeout or similar error.

4.  **Verify SSH Inbound (from allowed source):**
    * From your allowed source IP (local machine or bastion), you should be able to SSH into the private EC2 instance. The traffic flows from your IP -> IGW -> IGW Route Table (to Firewall Endpoint) -> Firewall Endpoint (processed by InboundSSH rule) -> Private EC2 instance.

5.  **Check Firewall Logs:**
    * Go to your S3 buckets for flow and alert logs. You should start seeing logs appear (can take a few minutes).
    * Flow logs will show all traffic passing through, including allowed and blocked connections.
    * Alert logs will specifically show when a rule with an "Alert" action (if you had any, or if the default drop triggers an alert) is matched. This is very useful for security monitoring.

**Troubleshooting Tips:**

* **Route Tables are Key:** Double-check all route tables. A common mistake is misconfiguring the routes to or from the firewall endpoints.
* **Security Groups:** Ensure your EC2 Security Group allows necessary inbound (e.g., SSH from bastion/Firewall Endpoint, HTTP/S from ALB) and outbound (allow all for now, as Firewall handles egress) traffic. The Network Firewall operates *before* or *after* the Security Group depending on the traffic direction.
* **NACLs:** Keep NACLs permissive initially (e.g., allow all inbound/outbound) or configure them to explicitly allow traffic to/from the firewall subnets and your application subnets. NACLs are stateless, so they can easily block return traffic if not carefully configured. For this lab, assume default NACLs (allow all) or explicitly allow all in relevant subnets.
* **Firewall State:** Ensure the Network Firewall instance is in the "Ready" state.
* **Logging:** Use firewall logs (S3 or CloudWatch) to understand why traffic is being allowed or blocked. This is your primary debugging tool.
* **DNS Resolution:** Ensure your EC2 instance can resolve DNS. If not, outbound lookups to `google.com` will fail even if the firewall allows it. (Default VPC DNS resolvers usually work fine).

---

**Cleanup (Very Important to Avoid Charges):**

1.  **Terminate EC2 Instance(s).**
2.  **Delete the Network Firewall:**
    * Go to **"Firewalls"** in the Network Firewall console.
    * Select your firewall (`MyVPCNetworkFirewall`).
    * Click **"Delete"**. Confirm. This will delete the firewall endpoints and their associated ENIs.
3.  **Delete the Firewall Policy:**
    * Go to **"Firewall policies"**.
    * Select your policy (`MyAppFirewallPolicy`).
    * Click **"Delete"**. Confirm.
4.  **Delete the Rule Groups:**
    * Go to **"Network Firewall rule groups"**.
    * Select `OutboundWebAccess` and `InboundSSH`.
    * Click **"Delete"**. Confirm.
5.  **Reset Route Tables:**
    * Go to **"Route tables"**.
    * Delete the custom `IGW-Route-Table`.
    * For the Public and Private Subnet route tables, remove the routes pointing to the Network Firewall Endpoints. Re-add a route for `0.0.0.0/0` pointing to your `Internet Gateway` (for the public subnet) or `NAT Gateway` (for the private subnet if you had one).
    * For the Firewall Subnet route tables, remove the `0.0.0.0/0` route to the IGW. These subnets should ideally be empty after firewall deletion.
6.  **Delete the Firewall Subnets.**
7.  **Delete the S3 Buckets** you created for logs.
8.  **Delete the VPC.** (This will also delete the remaining subnets and the Internet Gateway).

By following these steps, you'll gain practical experience in setting up and testing AWS Network Firewall, understanding its placement in your VPC architecture, and how it works with rule groups and policies to enforce granular network security.
