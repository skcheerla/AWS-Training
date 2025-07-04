In AWS, a **Network Access Control List (Network ACL or NACL)** is an optional layer of security that acts as a **stateless firewall** for controlling traffic in and out of **subnets** within your Virtual Private Cloud (VPC).

Think of it as a security gate at the entrance and exit of an entire neighborhood (your subnet), while Security Groups are like security guards at individual houses (your EC2 instances).

### Key Characteristics of Network ACLs:

1.  **Subnet Level Control:** NACLs are associated with subnets. Every subnet in your VPC must be associated with a NACL. If you don't explicitly associate a custom NACL, it automatically uses the default NACL for the VPC.
2.  **Stateless:** This is the most crucial difference from Security Groups.
      * If you create an **inbound** rule to allow traffic (e.g., HTTP on port 80), you *must* also create an explicit **outbound** rule to allow the return traffic (e.g., on ephemeral ports 1024-65535).
      * NACLs do not remember the state of a connection. Every packet is evaluated against the rules independently.
3.  **Allow and Deny Rules:** Unlike Security Groups (which only have allow rules), NACLs can have both `ALLOW` and `DENY` rules. This makes them powerful for blocking specific IP addresses or types of traffic at the subnet boundary.
4.  **Rule Evaluation Order:** Rules are evaluated in **ascending order by rule number** (from 1 to 32766). As soon as a rule matches the traffic, it's applied, and no further rules are evaluated for that traffic.
      * It's a best practice to leave gaps in your rule numbers (e.g., 100, 200, 300) so you can insert new rules later without renumbering everything.
5.  **Implicit Deny Rule:** Every NACL has a default rule (with an asterisk `*` as the rule number) that denies all traffic that doesn't match any other numbered rule. This rule cannot be modified or removed.
6.  **Multiple Subnets, One NACL (and vice versa):**
      * You can associate a single NACL with multiple subnets.
      * However, a subnet can only be associated with one NACL at a time. If you associate a new NACL with a subnet, the previous association is removed.
7.  **No Charge:** There is no additional charge for using Network ACLs.

### How Network ACLs Work:

When traffic enters or leaves a subnet, it's first evaluated against the associated Network ACL rules.

  * **Inbound Traffic:** When a packet enters a subnet, the inbound rules of the associated NACL are evaluated.
  * **Outbound Traffic:** When a packet leaves a subnet, the outbound rules of the associated NACL are evaluated.

If a packet is denied by a NACL, it will not even reach the instance's Security Group (for inbound traffic) or leave the subnet (for outbound traffic).

### Network ACL vs. Security Group (Key Differences):

| Characteristic      | Network ACL (NACL)                          | Security Group (SG)                                  |
| :------------------ | :------------------------------------------ | :--------------------------------------------------- |
| **Level** | **Subnet level** | **Instance/ENI level** |
| **Stateful/Stateless** | **Stateless** (Must define rules for both inbound AND outbound return traffic) | **Stateful** (Return traffic is automatically allowed if inbound/outbound is allowed) |
| **Rule Type** | **Allow and Deny** rules                    | **Allow only** rules (Implicitly denies everything else) |
| **Rule Order** | Rules evaluated in **numeric order** (lowest to highest) | All rules are evaluated, order does not matter      |
| **Default State** | **Default NACL:** Allows all inbound/outbound. \<br\> **Custom NACL:** Denies all inbound/outbound by default (via the `*` rule). | **Default SG:** Allows all outbound, allows inbound from instances in the same SG. \<br\> **New SG:** Allows all outbound, denies all inbound. |
| **Association** | One subnet to one NACL (but one NACL to multiple subnets) | One instance/ENI can have multiple SGs             |
| **Primary Use** | Broad traffic filtering for entire subnets, **explicitly deny** specific malicious IPs/ports. | Granular traffic control for specific instances/applications. |

### When to Use Network ACLs:

  * **As a "Second Line of Defense":** NACLs provide an additional layer of security beyond Security Groups. Even if an instance's Security Group is misconfigured, a well-defined NACL can still block unwanted traffic at the subnet boundary.
  * **Blocking Specific IPs:** If you identify a malicious IP address, you can create a DENY rule in the NACL to block all traffic from that IP to an entire subnet.
  * **Compliance Requirements:** Some regulatory compliance frameworks may recommend or require subnet-level firewalls.
  * **Controlling Traffic Between Subnets:** While routing tables define the path, NACLs can enforce what traffic is allowed between different subnets within your VPC.
  * **Broader Security Policies:** When you need to apply a consistent security policy to all instances within a subnet, regardless of their individual Security Groups.

### Example Network ACL Rules (Stateless Nature):

Let's say you want to allow SSH (port 22) from your office IP (203.0.113.10/32) to instances in a public subnet, and allow HTTP (port 80) from anywhere.

**Inbound Rules:**

| Rule \# | Type  | Protocol | Port Range | Source            | Allow/Deny |
| :----- | :---- | :------- | :--------- | :---------------- | :--------- |
| 100    | SSH   | TCP      | 22         | 203.0.113.10/32   | ALLOW      |
| 110    | HTTP  | TCP      | 80         | 0.0.0.0/0         | ALLOW      |
| \* | ALL   | ALL      | ALL        | 0.0.0.0/0         | DENY       |

**Outbound Rules:** (Crucial for return traffic due to stateless nature)

| Rule \# | Type  | Protocol | Port Range | Destination       | Allow/Deny |
| :----- | :---- | :------- | :--------- | :---------------- | :--------- |
| 100    | HTTP  | TCP      | 80         | 0.0.0.0/0         | ALLOW      |
| 110    | SSH   | TCP      | 22         | 203.0.113.10/32   | ALLOW      |
| 120    | Custom TCP | TCP      | 1024-65535 | 0.0.0.0/0         | ALLOW      | (Ephemeral ports for client return traffic)
| \* | ALL   | ALL      | ALL        | 0.0.0.0/0         | DENY       |

**Explanation of Outbound Rule 120:** When a client initiates a connection (e.g., HTTP on port 80), the server sends responses back from its port 80 to an ephemeral (high-numbered) port on the client's side. Because NACLs are stateless, you must explicitly allow this return traffic on the ephemeral port range for the communication to work.

### Conclusion:

Network ACLs are a powerful, but often misunderstood, component of AWS VPC security. While Security Groups are the primary line of defense at the instance level, NACLs provide a coarser-grained, stateless firewall at the subnet level, offering an important secondary layer of control and the ability to explicitly deny traffic. They are critical for implementing defense-in-depth strategies in your AWS infrastructure.
