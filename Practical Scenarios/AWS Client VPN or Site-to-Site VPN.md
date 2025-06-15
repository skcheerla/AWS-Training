Establishing a site-to-site VPN connection between AWS and Azure networks allows for secure and private communication between resources in both clouds. This is a common requirement for hybrid cloud environments, disaster recovery, or inter-cloud application deployments.

Here's a step-by-step procedure to establish this VPN and then prove connectivity:

## Step-by-Step Procedure to Establish Site-to-Site VPN between AWS and Azure

This guide assumes you have basic familiarity with both AWS and Azure consoles. We'll use static routing for simplicity.

**High-Level Overview:**

1.  **Plan your network ranges:** Ensure there's no CIDR overlap between your AWS VPC and Azure VNet.
2.  **Configure Azure:**
      * Create a Resource Group.
      * Create a Virtual Network (VNet) with a subnet for your VMs and a Gateway Subnet.
      * Create a Virtual Network Gateway (VPN Gateway).
      * Create a Local Network Gateway (representing your AWS side).
3.  **Configure AWS:**
      * Create a Virtual Private Cloud (VPC) with a subnet for your EC2 instances.
      * Create a Virtual Private Gateway (VGW).
      * Create a Customer Gateway (representing your Azure side).
      * Create a Site-to-Site VPN Connection.
4.  **Connect VPNs:** Configure the connection on both sides using the shared key and public IP addresses.
5.  **Configure Routing:** Ensure proper route propagation in both AWS and Azure.
6.  **Configure Security:** Adjust Security Groups (AWS) and Network Security Groups (Azure) to allow traffic over the VPN.

-----

**Detailed Steps:**

### **Phase 1: Azure Configuration**

1.  **Create a Resource Group:**

      * Go to the Azure Portal.
      * Search for "Resource groups" and click "Create".
      * Provide a name (e.g., `RG-AzureAWSVPN`), select a region, and click "Review + create", then "Create".

2.  **Create a Virtual Network (VNet):**

      * In the Azure Portal, search for "Virtual networks" and click "Create".
      * Select your Resource Group.
      * **VNet Name:** `AzureVNet`
      * **Address Space:** `172.16.0.0/16` (Example, ensure no overlap with your AWS VPC CIDR)
      * **Subnets:**
          * Add a subnet for your Azure VMs:
              * **Subnet name:** `AzureVMSubnet`
              * **Address range:** `172.16.1.0/24`
          * Add a **Gateway Subnet**:
              * Click "+ Add subnet" and name it `GatewaySubnet`.
              * Azure will automatically suggest an address range (e.g., `172.16.255.0/27`). This subnet is specifically for the VPN Gateway.
      * Click "Review + create", then "Create".

3.  **Create a Virtual Network Gateway (VPN Gateway):**

      * In the Azure Portal, search for "Virtual network gateways" and click "Create".
      * **Subscription:** Select your subscription.
      * **Name:** `AzureVPNGateway`
      * **Region:** Same as your VNet.
      * **Gateway type:** `VPN`
      * **VPN type:** `Route-based`
      * **SKU:** `VpnGw1` (or higher if needed for performance/HA)
      * **Generation:** `Generation1` (or `Generation2` if supported by your peer device and region)
      * **Virtual network:** Select `AzureVNet`.
      * **Public IP address:**
          * **Public IP address type:** `Basic`
          * **Assignment:** `Static`
          * **Public IP address name:** `AzureVPNGatewayPublicIP`
      * **Enable active-active mode:** `Disabled` (for a single tunnel setup)
      * **Configure BGP:** `Disabled` (for static routing)
      * Click "Review + create", then "Create". **This can take 30-45 minutes.**

4.  **Create an Azure Local Network Gateway (Representing AWS):**

      * While the VPN Gateway is deploying, in the Azure Portal, search for "Local network gateways" and click "Create".
      * **Subscription:** Select your subscription.
      * **Resource Group:** `RG-AzureAWSVPN`
      * **Region:** Same as your VNet.
      * **Name:** `AWSLocalNetworkGateway`
      * **IP address:** This will be the Public IP of your **AWS Virtual Private Gateway** (which we'll get later). For now, you can put a placeholder (e.g., `0.0.0.0`) and update it later, or wait until you get the AWS public IP.
      * **Address Space(s):** Enter the CIDR block of your AWS VPC (e.g., `10.0.0.0/16`).
      * **Configure BGP settings:** `No`.
      * Click "Review + create", then "Create".

-----

### **Phase 2: AWS Configuration**

1.  **Create a Virtual Private Cloud (VPC):**

      * Go to the AWS Management Console.
      * Navigate to the VPC dashboard.
      * Click "Your VPCs", then "Create VPC".
      * **Name tag:** `AWSVPC`
      * **IPv4 CIDR block:** `10.0.0.0/16` (Example, ensure no overlap with your Azure VNet CIDR)
      * Click "Create VPC".

2.  **Create a Subnet:**

      * In the AWS VPC dashboard, click "Subnets", then "Create subnet".
      * **VPC ID:** Select `AWSVPC`.
      * **Subnet name:** `AWSVMSubnet`
      * **Availability Zone:** Choose one.
      * **IPv4 CIDR block:** `10.0.1.0/24`
      * Click "Create subnet".

3.  **Create a Virtual Private Gateway (VGW):**

      * In the AWS VPC dashboard, click "Virtual Private Gateways", then "Create virtual private gateway".
      * **Name tag:** `AWS-VPN-VGW`
      * Click "Create virtual private gateway".
      * Once created, select the VGW and click "Actions" \> "Attach to VPC". Select `AWSVPC` and click "Attach".

4.  **Create a Customer Gateway (Representing Azure):**

      * In the AWS VPC dashboard, click "Customer Gateways", then "Create customer gateway".
      * **Name tag:** `AzureCustomerGateway`
      * **Routing:** `Static`
      * **IP Address:** Enter the **Public IP Address of your Azure Virtual Network Gateway** (`AzureVPNGatewayPublicIP`).
      * Click "Create customer gateway".

5.  **Create a Site-to-Site VPN Connection:**

      * In the AWS VPC dashboard, click "Site-to-Site VPN Connections", then "Create VPN Connection".
      * **Name tag:** `AWSAzureVPNConnection`
      * **Target Gateway Type:** `Virtual Private Gateway`
      * **Virtual Private Gateway:** Select `AWS-VPN-VGW`.
      * **Customer Gateway ID:** Select `AzureCustomerGateway`.
      * **Routing Options:** `Static`
      * **Static IP Prefixes:** Enter the CIDR block of your Azure VNet (`172.16.0.0/16`).
      * **Tunnel Inside IP Version:** `IPv4`
      * **IKE Version:** `IKEv2`
      * **Tunnel 1 and Tunnel 2 options:** You can leave these as default, or configure specific pre-shared keys and advanced options if required by a specific security policy. Make a note of the **Pre-Shared Keys** for both tunnels, as you'll need them for Azure.
      * Click "Create VPN Connection".
      * Wait for the VPN connection to be created. Once it's created, select it and go to the "Tunnel Details" tab. Note down the **Outside IP Address** for `Tunnel 1`. This is the public IP of the AWS VPN endpoint.

-----

### **Phase 3: Connect VPNs and Configure Routing/Security**

1.  **Update Azure Local Network Gateway (if needed):**

      * Go back to the Azure Portal.
      * Navigate to your `AWSLocalNetworkGateway`.
      * Click "Configuration" and update the **IP address** field with the **Outside IP Address** of `Tunnel 1` from your AWS Site-to-Site VPN Connection details. Click "Save".

2.  **Create the VPN Connection in Azure:**

      * Go back to your `AzureVPNGateway` in the Azure Portal.
      * Under "Settings", click "Connections", then "+ Add".
      * **Name:** `AzureAWSVPNConnection`
      * **Connection type:** `Site-to-site (IPsec)`
      * **Virtual network gateway:** Select `AzureVPNGateway`.
      * **Local network gateway:** Select `AWSLocalNetworkGateway`.
      * **Shared key (PSK):** Enter the **Pre-Shared Key** from `Tunnel 1` of your AWS VPN Connection configuration.
      * **IKE Protocol:** `IKEv2`
      * Click "OK".
      * **Wait for the connection status to show "Connected" (this can take several minutes).** Check both the Azure connection status and the AWS VPN tunnel status.

3.  **Configure AWS Route Tables:**

      * In the AWS VPC dashboard, go to "Route Tables".
      * Select the route table associated with your `AWSVMSubnet`.
      * Go to the "Route Propagation" tab.
      * Click "Edit route propagation" and **enable propagation for your `AWS-VPN-VGW`**. This will automatically add routes for your Azure VNet through the VGW.
      * Alternatively, you can manually add a route:
          * Go to the "Routes" tab and click "Edit routes".
          * Click "Add route".
          * **Destination:** Enter your Azure VNet CIDR (`172.16.0.0/16`).
          * **Target:** Select your `AWS-VPN-VGW`.
          * Click "Save changes".

4.  **Configure Azure Route Tables:**

      * In the Azure Portal, go to your `AzureVNet`.
      * Under "Settings", click "Route tables".
      * Select the route table associated with your `AzureVMSubnet`.
      * Click "Routes", then "+ Add".
      * **Route name:** `ToAWS`
      * **Address prefix:** Enter your AWS VPC CIDR (`10.0.0.0/16`).
      * **Next hop type:** `Virtual network gateway`
      * **Next hop address:** Azure will automatically select your `AzureVPNGateway`.
      * Click "Add".

5.  **Configure Security Groups (AWS) and Network Security Groups (Azure):**

      * **AWS Security Group for EC2 instance:**
          * In the AWS EC2 console, go to "Security Groups".
          * Select the security group associated with your EC2 instance.
          * Go to "Inbound Rules", click "Edit inbound rules", and "Add rule".
          * **Type:** `All traffic` (or specific ports like SSH (22), ICMP for ping)
          * **Source:** Custom, and enter your Azure VNet CIDR (`172.16.0.0/16`).
          * Click "Save rules".
      * **Azure Network Security Group for Azure VM:**
          * In the Azure Portal, go to "Network security groups".
          * Select the NSG associated with your Azure VM's network interface or subnet.
          * Go to "Inbound security rules", click "+ Add".
          * **Source:** `IP Addresses`
          * **Source IP addresses/CIDR ranges:** Enter your AWS VPC CIDR (`10.0.0.0/16`).
          * **Destination port ranges:** `Any` (or specific ports like SSH (22), ICMP)
          * **Protocol:** `Any` (or `ICMP` for ping, `TCP` for SSH)
          * **Action:** `Allow`
          * **Priority:** A lower number than any conflicting Deny rule.
          * **Name:** `AllowAWSVPN`
          * Click "Add".

-----

## Proof of Login from Azure VM to AWS EC2 Instance

Once the VPN connection status shows "Connected" on both AWS and Azure, you can proceed to prove connectivity.

**Prerequisites:**

  * An Azure Virtual Machine (`AzureVM`) deployed in `AzureVMSubnet`.
  * An AWS EC2 Instance (`AWSEC2`) deployed in `AWSVMSubnet`.
  * Both VMs should have private IP addresses.
  * For Linux VMs, ensure SSH server is running. For Windows, ensure RDP is enabled.
  * You have the private key (`.pem` or `.ppk` for Windows) for your AWS EC2 instance.

**Steps to Prove Connectivity:**

1.  **Get Private IP Addresses:**

      * **Azure VM:** In the Azure Portal, navigate to your Azure VM. Under "Networking", you'll find its private IP address (e.g., `172.16.1.4`).
      * **AWS EC2 Instance:** In the AWS EC2 console, navigate to your EC2 instance. Under "Details", you'll find its private IP address (e.g., `10.0.1.50`).

2.  **Test Ping (ICMP) from Azure VM to AWS EC2:**

      * **Connect to your Azure VM:** Use RDP (for Windows) or SSH (for Linux) to connect to your Azure VM. You might need to temporarily enable RDP/SSH inbound rules from your public IP for initial access to the Azure VM itself.

      * **Open a command prompt/terminal on Azure VM.**

      * **Ping the AWS EC2 instance's private IP:**

        ```bash
        ping <AWS_EC2_PRIVATE_IP_ADDRESS>
        ```

        (e.g., `ping 10.0.1.50`)

      * **Expected Outcome:** You should see successful replies (e.g., "Reply from 10.0.1.50: bytes=32 time=\<ms\> TTL=\<value\>"). This confirms basic IP connectivity over the VPN tunnel. If you don't get replies, double-check your Security Groups/Network ACLs on AWS to allow ICMP, and NSG rules on Azure.

3.  **Test SSH Login from Azure VM to AWS EC2 (for Linux EC2):**

      * **Copy the AWS EC2 private key to your Azure VM:** You'll need to transfer your `.pem` file to the Azure VM.

          * **Windows Azure VM:** You can use tools like WinSCP to copy the file.
          * **Linux Azure VM:** Use `scp` from your local machine to the Azure VM, then from the Azure VM to the AWS EC2 instance (though direct copy to Azure VM is usually sufficient).

      * **Set correct permissions on the private key (Linux Azure VM):**

        ```bash
        chmod 400 /path/to/your/key.pem
        ```

      * **SSH from Azure VM to AWS EC2:**

        ```bash
        ssh -i /path/to/your/key.pem <EC2_USER>@<AWS_EC2_PRIVATE_IP_ADDRESS>
        ```

        (e.g., `ssh -i /home/azureuser/my-aws-key.pem ec2-user@10.0.1.50` - common users are `ec2-user` for Amazon Linux, `ubuntu` for Ubuntu, `centos` for CentOS).

      * **Expected Outcome:** You should be successfully logged into your AWS EC2 instance from your Azure VM's terminal. This proves secure, private, and application-layer connectivity over the VPN.

4.  **Test RDP Login from Azure VM to AWS EC2 (for Windows EC2):**

      * **Connect to your Azure VM.**

      * **Open Remote Desktop Connection** application on the Azure VM.

      * **Enter the private IP address of your Windows AWS EC2 instance.**

      * **Provide the username and password** for the AWS EC2 instance (you would have retrieved this when launching the instance or reset it).

      * **Expected Outcome:** You should be able to establish an RDP session to your AWS EC2 instance, demonstrating connectivity.

By successfully performing these ping and login tests, you've demonstrated that your site-to-site VPN connection between AWS and Azure networks is established and functioning correctly, allowing secure communication between resources in both cloud environments.
