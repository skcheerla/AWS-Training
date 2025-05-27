CIDR stands for Classless Inter-Domain Routing. It's a method for allocating and routing IP addresses more efficiently than the older "classful" system.


To understand why CIDR was developed and why it's so important, it's helpful to know a little about the old classful system:

The Problem with Classful Addressing (Pre-CIDR):

Before CIDR, IP addresses (specifically IPv4 addresses, which are 32-bit numbers like 192.168.1.1) were divided into fixed "classes" (Class A, B, and C). Each class had a predefined number of bits for the network portion and the host portion of the IP address:


Class A: Very large networks, few networks, many hosts per network.
Network part: First 8 bits
Host part: Last 24 bits
Example: 10.0.0.0 (millions of possible hosts)
Class B: Medium-sized networks.
Network part: First 16 bits
Host part: Last 16 bits
Example: 172.16.0.0 (tens of thousands of possible hosts)
Class C: Small networks, many networks, few hosts per network.
Network part: First 24 bits
Host part: Last 8 bits
Example: 192.168.1.0 (254 possible hosts)
The problem was that these fixed sizes led to significant IP address waste. If an organization needed 500 hosts, they'd have to get a Class B network (which offered over 65,000 hosts), wasting tens of thousands of addresses. Conversely, if an organization needed more than 254 hosts but less than 65,534, they'd be forced into a Class B, again leading to waste or inefficient allocation. This was a critical issue as IPv4 addresses began to run out.


How CIDR Solved the Problem:

CIDR eliminates the rigid class boundaries and allows for variable-length subnet masks (VLSMs). Instead of a fixed 8, 16, or 24 bits for the network, CIDR allows the network portion of an IP address to be defined by any number of bits.

CIDR Notation:

CIDR notation is a compact way to represent an IP address and its network mask. It looks like this:

IP_Address/Prefix_Length

IP_Address: The standard IP address (e.g., 192.168.1.0).
/Prefix_Length: This is the crucial part. It's a number (from 0 to 32 for IPv4, 0 to 128 for IPv6) that indicates how many of the leading bits in the IP address belong to the network portion. The remaining bits are for the host portion.
Examples:

192.168.1.0/24

This means the first 24 bits of the IP address (192.168.1) are for the network.
The remaining 8 bits (32 - 24 = 8) are for hosts.
This is equivalent to a traditional Class C network with a subnet mask of 255.255.255.0.
It allows for 2 
8
 −2=254 usable host addresses (subtracting network and broadcast addresses).
10.0.0.0/8

The first 8 bits (10) are for the network.
The remaining 24 bits are for hosts.
This is equivalent to a traditional Class A network with a subnet mask of 255.0.0.0.
It allows for 2 
24
 −2 usable host addresses.
172.16.0.0/20

This is where CIDR's flexibility shines. The first 20 bits define the network.
The remaining 12 bits (32 - 20 = 12) are for hosts.
This allows for 2 
12
 −2=4094 usable host addresses. This network size is not possible with the fixed classful system.
Benefits of CIDR:

Efficient IP Address Allocation: Organizations can be assigned exactly the number of IP addresses they need, preventing the wastage seen with classful addressing. This was vital in slowing down the exhaustion of IPv4 addresses.
Reduced Routing Table Size (Supernetting/Route Aggregation): Routers don't need an entry for every single network. With CIDR, multiple smaller networks (subnets) can be "supernetted" or aggregated into a single, larger CIDR block. This single entry in the router's table can represent many individual networks, significantly reducing the size and complexity of routing tables, which makes routing more efficient.

Improved Routing Efficiency: Smaller routing tables mean faster lookups and better performance for routers.
Flexibility in Network Design: Network administrators can design more granular and efficient network structures by creating subnets of various sizes to meet specific organizational needs.
