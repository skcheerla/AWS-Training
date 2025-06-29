Your EC2 OS disk got corrupted and you have an OS volume snapshot. Here's a step-by-step procedure to recover your EC2 instance using that snapshot as a new root volume in AWS:

**Understanding the Recovery Process**

When your OS disk is corrupted, you can't simply "restore" the snapshot directly onto the existing corrupted volume. Instead, you'll create a *new* volume from your snapshot and then attach that new volume as the root device to either:

1.  **A new EC2 instance:** This is generally the safest and most recommended approach, especially if the original instance itself might have other issues or if you want to test the new volume before fully committing.
2.  **Your existing EC2 instance (after detaching the corrupted volume):** This can be done but requires more careful steps to ensure the original instance's configuration (like network interfaces) isn't disrupted.

I'll provide steps for both, but strongly recommend starting with Option 1.

---

### Option 1: Recovering to a New EC2 Instance (Recommended)

This method involves launching a completely new EC2 instance using your snapshot as the root volume.

**Step-by-Step Procedure:**

1.  **Locate Your Snapshot:**
    * Go to the AWS EC2 console.
    * In the left navigation pane, under "Elastic Block Store," click on **Snapshots**.
    * Find the snapshot of your OS volume that you want to use for recovery. Make sure it's the correct one and recent enough.

2.  **Create a New Volume from the Snapshot:**
    * Select your desired snapshot.
    * Click on **Actions** and then **Create Volume**.
    * **Volume Type:** Choose the same volume type as your original OS disk (e.g., gp2, gp3).
    * **Size:** Ensure the size is at least as large as your original OS disk. If your original disk was 50GB, make sure the new volume is at least 50GB.
    * **Availability Zone:** **Crucially, select the same Availability Zone where you plan to launch your new EC2 instance.** If your original instance was in `ap-south-1a`, create the new volume in `ap-south-1a`.
    * Click **Create Volume**.
    * Wait for the volume to become "available."

3.  **Launch a New EC2 Instance:**
    * Go to the EC2 console and click on **Launch instances**.
    * **Choose an Amazon Machine Image (AMI):** Select an AMI that is **compatible with your original operating system**. For example, if your original instance was running Amazon Linux 2, choose an Amazon Linux 2 AMI. If it was Ubuntu 20.04, choose an Ubuntu 20.04 AMI.
    * **Choose an Instance Type:** Select an instance type that is compatible with your original instance's requirements (e.g., `t2.micro`, `m5.large`).
    * **Configure Instance Details:**
        * **Network (VPC) and Subnet:** Select the same VPC and Subnet as your original instance if possible, or a new suitable network configuration.
        * **Auto-assign Public IP:** Enable this if you need a public IP.
        * **IAM Role:** Attach any necessary IAM roles your original instance had.
    * **Add Storage:**
        * **Delete the default root volume that the AMI provides.** This is important. You will be replacing it with your new volume created from the snapshot.
        * Click **Add New Volume**.
        * **Volume Type:** Choose the same as your new volume.
        * **Device:** This is critical. For the root volume, it should typically be `/dev/xvda` (for most Linux AMIs) or `/dev/sda1` (for some older AMIs or Windows). **Verify what your original root device was if you're unsure, but `/dev/xvda` is a very common default for Linux AMIs.** If you select the wrong device, the instance might not boot.
        * **Snapshot:** Select your newly created volume from the dropdown (the one you made from your snapshot). This step is where you link the new instance to your recovered volume.
    * **Add Tags:** (Optional) Add tags for identification.
    * **Configure Security Group:** Select an existing security group that allows necessary inbound/outbound traffic, or create a new one. Ensure you have SSH access (port 22 for Linux, 3389 for Windows).
    * **Review and Launch:** Review all your settings.
    * **Choose an existing key pair or create a new one.** You'll need this to connect to the instance.

4.  **Connect to Your New Instance:**
    * Once the new instance is running and passes its status checks, try to connect to it via SSH (or RDP for Windows) using the key pair you selected.
    * Verify that your data and applications are present and functioning correctly.

5.  **Clean Up (Optional):**
    * If the new instance is working as expected, you can terminate the original corrupted instance (if it's still running).
    * You can also delete the corrupted original volume (if not already deleted when you terminated the instance).

---

### Option 2: Replacing the Root Volume on the Existing EC2 Instance (More Advanced)

This method is riskier as it involves stopping the instance and detaching/attaching volumes. Only proceed if you are comfortable with these operations and understand the potential for issues.

**Prerequisites:**

* **Instance Stopped:** Your EC2 instance *must* be stopped to detach and attach its root volume.
* **Identify Original Root Device:** You need to know the device name of the original root volume (e.g., `/dev/xvda`, `/dev/sda1`). You can find this by looking at the instance's details under the "Block devices" section or by running `lsblk` when logged into a working Linux instance.

**Step-by-Step Procedure:**

1.  **Locate Your Snapshot:** (Same as Step 1 in Option 1)
    * Go to the AWS EC2 console -> **Snapshots**.
    * Find the correct OS volume snapshot.

2.  **Create a New Volume from the Snapshot:** (Same as Step 2 in Option 1)
    * Select your desired snapshot.
    * Click on **Actions** and then **Create Volume**.
    * **Volume Type:** Same as original.
    * **Size:** At least as large as original.
    * **Availability Zone:** **Crucially, select the same Availability Zone as your *existing* EC2 instance.**
    * Click **Create Volume**.
    * Wait for the volume to become "available."

3.  **Stop Your Existing EC2 Instance:**
    * Go to the EC2 console -> **Instances**.
    * Select your corrupted EC2 instance.
    * Click on **Instance state** -> **Stop instance**.
    * Wait for the instance state to change to "stopped."

4.  **Detach the Corrupted Root Volume:**
    * While the instance is stopped, go to the **Description** tab of your EC2 instance.
    * Under "Block devices," click on the **Volume ID** of your root device (usually `/dev/xvda` or `/dev/sda1`). This will take you to the Volumes section.
    * Select the corrupted root volume.
    * Click on **Actions** -> **Detach Volume**. Confirm the detachment.
    * Wait for the volume state to become "available" (it might take a moment).

5.  **Attach the New Volume (from Snapshot) as the Root Volume:**
    * Go back to the **Volumes** section in the EC2 console.
    * Select the **new volume** you created from your snapshot.
    * Click on **Actions** -> **Attach Volume**.
    * **Instance:** Start typing the name or ID of your *existing stopped* EC2 instance and select it.
    * **Device Name:** **This is critical!** Enter the exact same device name as your original root volume (e.g., `/dev/xvda`, `/dev/sda1`). If you get this wrong, the instance will not boot correctly.
    * Click **Attach Volume**.

6.  **Start Your EC2 Instance:**
    * Go back to the EC2 console -> **Instances**.
    * Select your EC2 instance.
    * Click on **Instance state** -> **Start instance**.

7.  **Connect and Verify:**
    * Once the instance is running and passes status checks, try to connect to it via SSH (or RDP).
    * Verify that your data and applications are present and functioning correctly.

8.  **Clean Up:**
    * Once you've confirmed everything is working, you can delete the old, corrupted volume that you detached in Step 4.

---

**Important Considerations and Troubleshooting:**

* **Availability Zone:** This is the most common mistake. Volumes are zonal resources. A volume must be in the same Availability Zone as the instance you want to attach it to.
* **Device Name:** For Linux instances, the root device is usually `/dev/xvda` or `/dev/sda1`. For Windows, it's typically `/dev/sda1`. Using the wrong device name will prevent the instance from booting.
* **AMI Compatibility:** When launching a new instance, ensure the AMI you choose is compatible with the OS on your snapshot. Minor version differences are usually fine, but switching major OS versions (e.g., Amazon Linux to Ubuntu) or different kernel architectures can cause issues.
* **Instance Type:** Ensure the instance type you choose is compatible with the underlying hardware requirements of your OS and applications.
* **SSH Key Pair:** You'll need the correct SSH key pair to access the instance. If you're launching a new instance, choose an existing key pair you have or create a new one. If using the existing instance, your original key pair should still work.
* **Security Groups:** Verify that your security groups allow inbound SSH (port 22 for Linux) or RDP (port 3389 for Windows) traffic from your IP address.
* **Data Volumes:** If your instance had additional data volumes attached, you'll need to re-attach those to the new instance (or the existing one after recovery) and mount them if they were not part of the snapshot.
* **Cloud-init/User Data:** If your original instance used `cloud-init` or user data scripts for initial setup, you might need to re-apply those or consider their impact on the new instance.
* **Troubleshooting Boot Issues:** If the instance doesn't boot, check the **System Log** from the EC2 console for clues. This often provides error messages related to boot failures.

By following these steps carefully, you should be able to recover your EC2 instance using your OS volume snapshot. Good luck!
