VPC Peering is a networking connection between two Virtual Private Clouds (VPCs) that allows you to route traffic between them using private IP addresses. Instances in either VPC can communicate with each other as if they are within the same network. This is useful for various scenarios, such as sharing resources between different departments, providing access to shared services, or connecting applications across different AWS accounts or regions.

Here's a step-by-step procedure to establish a VPC peering connection in AWS:

**Prerequisites:**

1.  **Two VPCs:** You need at least two VPCs that you want to peer. These can be in the same AWS account or different accounts, and in the same or different AWS Regions.
2.  **Non-overlapping CIDR blocks:** This is crucial. The IPv4 CIDR blocks of the two VPCs **must not overlap**. If they do, the peering connection will fail immediately. This applies even if you're using IPv6 CIDR blocks, the IPv4 CIDR blocks must still be unique.
3.  **AWS Account with permissions:** Ensure you have the necessary IAM permissions to create and manage VPCs, peering connections, route tables, and security groups.

**Step-by-Step Procedure:**

**Step 1: Create a VPC Peering Connection Request (Requester VPC)**

1.  **Sign in to the AWS Management Console:** Go to the VPC Dashboard.
2.  **Navigate to Peering Connections:** In the left navigation pane, choose "Peering connections".
3.  **Create Peering Connection:** Click on "Create peering connection".
4.  **Configure Peering Connection Details:**
    * **Name (Optional):** Provide a descriptive name for your peering connection (e.g., `vpc-a-to-vpc-b-peering`).
    * **VPC ID (Requester):** Select the VPC that will initiate the peering request. This is your current VPC.
    * **Select another VPC to peer with:**
        * **Account:**
            * Choose "My account" if the accepter VPC is in the same AWS account.
            * Choose "Another account" and enter the 12-digit AWS account ID if the accepter VPC is in a different account.
        * **Region:**
            * Choose "This Region" if the accepter VPC is in the same AWS Region.
            * Choose "Another Region" and select the desired Region if the accepter VPC is in a different Region (inter-Region peering).
        * **VPC ID (Accepter):** Select the VPC that you want to peer with. If it's in another account or region, you'll need its VPC ID.
    * **(Optional) Tags:** Add any desired tags.
5.  **Create peering connection:** Click "Create peering connection".

**Step 2: Accept the VPC Peering Connection Request (Accepter VPC)**

* **If the accepter VPC is in the same AWS account:**
    1.  Stay in the same AWS Management Console.
    2.  Go back to "Peering connections" in the VPC Dashboard.
    3.  You'll see the newly created peering connection with a status of "Pending Acceptance".
    4.  Select the peering connection, click "Actions", and then choose "Accept Request".
    5.  Confirm the acceptance.
* **If the accepter VPC is in a different AWS account:**
    1.  The owner of the accepter VPC must sign in to their AWS Management Console.
    2.  Navigate to "Peering connections" in their VPC Dashboard.
    3.  They will see the pending peering connection request.
    4.  They need to select the peering connection, click "Actions", and then choose "Accept Request".
    5.  Confirm the acceptance.
* **If the accepter VPC is in a different AWS Region:**
    1.  The owner of the accepter VPC must switch to the AWS Region where the accepter VPC resides.
    2.  Navigate to "Peering connections" in their VPC Dashboard in that Region.
    3.  They will see the pending peering connection request.
    4.  They need to select the peering connection, click "Actions", and then choose "Accept Request".
    5.  Confirm the acceptance.

Once accepted, the status of the VPC peering connection will change to "Active".

**Step 3: Update Route Tables in Both VPCs**

This is a critical step to enable traffic flow. You need to add routes in the route tables of both VPCs that point to the CIDR block of the peered VPC, with the VPC peering connection as the target.

1.  **Navigate to Route Tables:** In the VPC Dashboard, choose "Route tables".
2.  **Select the Route Table for VPC A (Requester VPC):** Choose the route table(s) associated with the subnets in your requester VPC that need to communicate with the accepter VPC.
3.  **Edit Routes:**
    * Go to the "Routes" tab.
    * Click "Edit routes".
    * Click "Add route".
    * **Destination:** Enter the CIDR block of the **accepter VPC** (e.g., `10.1.0.0/16`).
    * **Target:** Select "Peering Connection" from the dropdown and then choose your active VPC peering connection ID (e.g., `pcx-xxxxxxxxxxxxxxxxx`).
    * Click "Save changes".
4.  **Repeat for VPC B (Accepter VPC):**
    * Switch to the accepter VPC's context (if in a different account/region).
    * Select the route table(s) associated with the subnets in your accepter VPC that need to communicate with the requester VPC.
    * Go to the "Routes" tab.
    * Click "Edit routes".
    * Click "Add route".
    * **Destination:** Enter the CIDR block of the **requester VPC** (e.g., `10.0.0.0/16`).
    * **Target:** Select "Peering Connection" from the dropdown and then choose the same active VPC peering connection ID.
    * Click "Save changes".

**Step 4: Update Security Groups (Optional but Recommended)**

While route tables enable routing, security groups control the actual traffic allowed in and out of your instances. You'll likely need to adjust security group rules to allow communication between instances in the peered VPCs.

1.  **Navigate to Security Groups:** In the VPC Dashboard, choose "Security Groups".
2.  **Select the Security Group for your instance in VPC A:** Choose the security group(s) attached to the instances in VPC A that need to communicate with instances in VPC B.
3.  **Edit Inbound/Outbound Rules:**
    * Go to the "Inbound Rules" tab.
    * Click "Edit inbound rules".
    * Add a rule to allow the necessary traffic (e.g., all TCP, specific ports like HTTP/SSH) from the CIDR block of **VPC B**. You can also reference a security group from the peer VPC if both VPCs are in the same Region.
    * Click "Save rules".
    * (Repeat for Outbound Rules if outbound traffic is explicitly restricted.)
4.  **Repeat for instances in VPC B:**
    * Select the security group(s) attached to the instances in VPC B.
    * Add rules to allow traffic from the CIDR block of **VPC A**.

**Step 5: Verify the Connection**

1.  **Launch instances:** If you don't already have instances, launch EC2 instances in both VPCs.
2.  **Test Connectivity:**
    * **Ping:** From an instance in VPC A, try to ping the private IP address of an instance in VPC B.
    * **SSH/RDP:** Attempt to connect to an instance in the peered VPC.
    * **Application-level connectivity:** Test your application's communication if applicable.

**Important Considerations and Limitations:**

* **No Transitive Peering:** VPC peering is not transitive. If VPC A is peered with VPC B, and VPC B is peered with VPC C, VPC A cannot directly communicate with VPC C through VPC B. You would need a separate peering connection between VPC A and VPC C if direct communication is required. For complex topologies, consider using AWS Transit Gateway.
* **Overlapping CIDR Blocks:** As mentioned, avoid overlapping CIDR blocks. This is a common cause of peering connection failures.
* **DNS Resolution:** By default, if EC2 instances in peered VPCs address each other using public DNS hostnames, the hostname resolves to the public IP address. You can enable DNS hostname resolution for your peering connection to resolve to private IP addresses.
* **Network ACLs:** Ensure your Network Access Control Lists (NACLs) are not blocking traffic between the peered VPCs. NACLs are stateless, so you need rules for both inbound and outbound traffic.
* **Charges:** There is no charge to create a VPC peering connection. Data transfer over a VPC peering connection within the same Availability Zone is free. Charges apply for data transfer that crosses Availability Zones or Regions.

By following these steps, you can successfully establish a VPC peering connection and enable secure, private communication between your AWS VPCs.
