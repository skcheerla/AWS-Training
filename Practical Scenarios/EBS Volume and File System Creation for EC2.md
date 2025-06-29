You're looking to set up an EBS volume, attach it to an EC2 instance, and then format it with an `ext4` filesystem. This is a common and essential task in AWS. Here's a detailed, step-by-step procedure:

**Prerequisites:**

  * An active AWS account.
  * An EC2 instance already running in the same AWS region where you plan to create the EBS volume. Make sure you have SSH access to this EC2 instance.
  * Basic understanding of the AWS Management Console and Linux command line.

-----

### Step 1: Create an EBS Volume

1.  **Log in to the AWS Management Console:** Go to [https://aws.amazon.com/console/](https://aws.amazon.com/console/) and sign in.

2.  **Navigate to EC2 Dashboard:** From the services menu, search for "EC2" and click on it.

3.  **Go to Volumes:** In the left-hand navigation pane, under "Elastic Block Store," click on "Volumes."

4.  **Create Volume:** Click the "Create volume" button.

5.  **Configure Volume Settings:**

      * **Volume type:** Choose the appropriate type for your needs (e.g., `gp3` is a good general-purpose choice, `io2 Block Express` for high-performance databases, `st1` for throughput-intensive workloads like big data). For general use, `gp3` or `gp2` is usually sufficient.
      * **Size (GiB):** Enter the desired size for your volume (e.g., 100 GiB).
      * **IOPS (for gp3/io2/io1):** If you choose `gp3`, you can specify IOPS. The default is usually fine for most cases, but you can increase it for higher performance.
      * **Throughput (MB/s) (for gp3):** Similarly, you can specify throughput for `gp3`.
      * **Availability Zone:** **This is critical\!** Select the **same Availability Zone** as your EC2 instance. An EBS volume can only be attached to an EC2 instance in the same Availability Zone.
      * **Snapshot ID:** Leave blank unless you're creating a volume from a snapshot.
      * **Encryption:** (Optional but recommended) Choose a KMS key for encryption. You can use the default AWS managed key or your own.
      * **Tags:** (Optional but recommended) Add tags like `Name` (e.g., `MyDataVolume`) to easily identify your volume.

6.  **Create:** Click the "Create volume" button. You'll see a confirmation that the volume is being created. It will quickly transition to an "available" state.

-----

### Step 2: Attach the EBS Volume to Your EC2 Instance

1.  **Select the Volume:** In the "Volumes" list, select the newly created volume (its state should be "available").

2.  **Actions -\> Attach volume:** Click on the "Actions" dropdown menu and select "Attach volume."

3.  **Attach Volume Settings:**

      * **Instance:** Start typing the name or ID of your EC2 instance. Select the correct instance from the dropdown list.
      * **Device name:** This is the name the instance uses to identify the volume. AWS will suggest a default (e.g., `/dev/sdf`, `/dev/sdg`, etc.). **Note this device name**, as you'll need it when connecting to your EC2 instance. For modern Linux kernels, AWS generally maps these to `/dev/xvdf`, `/dev/xvdg`, etc., inside the instance. It's often safe to stick with the default `/dev/sdf` and it will correctly map.

4.  **Attach:** Click the "Attach volume" button. The volume's state will change to "in-use."

-----

### Step 3: Connect to Your EC2 Instance and Create an `ext4` Filesystem

Now, you need to connect to your EC2 instance using SSH and prepare the newly attached volume.

1.  **Connect to your EC2 instance via SSH:**

      * Find your EC2 instance's Public IPv4 DNS or Public IPv4 address in the EC2 dashboard.
      * Use your SSH key pair (e.g., `your-key.pem`) to connect.
      * **Example SSH command:**
        ```bash
        ssh -i /path/to/your-key.pem ec2-user@your-ec2-public-ip
        ```
        (Replace `ec2-user` with the appropriate username for your AMI, e.g., `ubuntu` for Ubuntu, `centos` for CentOS, `admin` for Amazon Linux 2023, etc.)

2.  **List Block Devices to Identify the New Volume:**
    Once connected, run the following command to see all block devices. Look for the new device you just attached. It will likely appear as `/dev/xvdf`, `/dev/xvdg`, or similar, corresponding to the `/dev/sdf` or `/dev/sdg` you saw during attachment.

    ```bash
    lsblk
    ```

    You should see an entry for your new volume, typically without a mount point and no partition. For example:

    ```
    NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
    xvda        202:0    0    8G  0 disk
    └─xvda1     202:1    0    8G  0 part /
    xvdf        202:80   0  100G  0 disk  <-- This is your new volume
    ```

    In this example, `/dev/xvdf` is the new 100GB volume.

3.  **Create an `ext4` Filesystem on the Volume:**
    **CAUTION:** Ensure you use the correct device name identified in the previous step. **Using the wrong device name can lead to data loss on other volumes (like your root volume)\!**

    ```bash
    sudo mkfs -t ext4 /dev/xvdf
    ```

    (Replace `/dev/xvdf` with the actual device name you identified.)
    This command will create an `ext4` filesystem on the entire volume. You'll see output indicating the filesystem creation process.

4.  **Create a Mount Point:**
    You need a directory to mount your new volume.

    ```bash
    sudo mkdir /data
    ```

    You can choose any name for your mount point, like `/mnt/data`, `/app_data`, etc.

5.  **Mount the Volume:**
    Mount the newly formatted volume to your chosen mount point.

    ```bash
    sudo mount /dev/xvdf /data
    ```

    (Again, replace `/dev/xvdf` with your actual device name.)

6.  **Verify the Mount:**
    Check if the volume is successfully mounted:

    ```bash
    df -h
    ```

    You should see an entry similar to:

    ```
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/xvda1      7.8G  1.7G  6.1G  22% /
    /dev/xvdf        99G   24K   94G   1% /data  <-- Your new volume
    ```

7.  **Set Permissions (Optional but Recommended):**
    By default, the mount point will be owned by `root`. If you want non-root users (like `ec2-user`) to have write access, change the ownership:

    ```bash
    sudo chown -R ec2-user:ec2-user /data
    ```

    (Replace `ec2-user:ec2-user` with the appropriate user and group for your needs.)

-----

### Step 4: Configure Automatic Mounting on Reboot (Fstab)

To ensure your volume is automatically mounted every time your EC2 instance reboots, you need to add an entry to the `/etc/fstab` file.

1.  **Get the UUID of the Volume:**
    It's best practice to use the UUID (Universally Unique Identifier) rather than the device name (`/dev/xvdf`) in `/etc/fstab`, as device names can sometimes change after reboots.

    ```bash
    sudo blkid /dev/xvdf
    ```

    (Replace `/dev/xvdf` with your actual device name.)
    You'll get output similar to:

    ```
    /dev/xvdf: UUID="a1b2c3d4-e5f6-7890-1234-567890abcdef" TYPE="ext4"
    ```

    Copy the `UUID`.

2.  **Backup `/etc/fstab`:**
    Before editing `fstab`, it's a good idea to create a backup:

    ```bash
    sudo cp /etc/fstab /etc/fstab.bak
    ```

3.  **Edit `/etc/fstab`:**
    Open the `fstab` file with a text editor (e.g., `nano` or `vi`).

    ```bash
    sudo nano /etc/fstab
    ```

    Add a new line at the end of the file using the UUID you just copied, your mount point, filesystem type, and mount options.

    **Example `fstab` entry:**

    ```
    UUID=a1b2c3d4-e5f6-7890-1234-567890abcdef  /data  ext4  defaults,nofail  0  2
    ```

    **Explanation of fields:**

      * `UUID=...`: The UUID of your EBS volume.
      * `/data`: The mount point you created.
      * `ext4`: The filesystem type.
      * `defaults`: Standard mount options (rw, suid, dev, exec, auto, nouser, async).
      * `nofail`: **Crucial for cloud instances\!** This option prevents the instance from getting stuck during boot if the volume somehow fails to attach.
      * `0`: Dump field (usually 0 for modern systems).
      * `2`: Pass number (order in which `fsck` checks filesystems; 2 for non-root filesystems).

    Save the file and exit the editor. (In nano, Ctrl+O, Enter, Ctrl+X).

4.  **Test the `fstab` Entry:**
    Unmount the volume first:

    ```bash
    sudo umount /data
    ```

    Then, try to mount all entries in `fstab` to ensure there are no errors:

    ```bash
    sudo mount -a
    ```

    If there are no errors, your volume should be mounted again. Verify with `df -h`.

5.  **Reboot (Optional but Recommended for Final Test):**
    To fully confirm that everything works as expected on boot, you can reboot your instance and then verify the mount.

    ```bash
    sudo reboot
    ```

    After the instance comes back online, SSH into it again and run `df -h` to confirm that `/data` is mounted.

-----

You have now successfully created an EBS volume, attached it to your EC2 instance, created an `ext4` filesystem on it, and configured it to mount automatically on reboot\!
