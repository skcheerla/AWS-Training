# Could you plesae create 3 Security Groups for the 3-Tier Architecture as mentioned below.

![image](https://github.com/user-attachments/assets/ca3b5dc5-486a-41ad-8c10-23e22a8a3c2d)

## 1. Create WEB Servers Security Group with the following Inbound rules.

   ### HTTP/80 and HTTPS/443 - Allow from Anywhere
   ### SSH ( TCP/22) Allow only from the Bastion Hosts Network.

   **Common Default Web Server Port Numbers:**

* **Port 80 (TCP):** This is the standard port for **HTTP (Hypertext Transfer Protocol)**, which is used for unencrypted web traffic. When you type a website address like `http://example.com` into your browser, it typically tries to connect to port 80 on the web server.

* **Port 443 (TCP):** This is the standard port for **HTTPS (Hypertext Transfer Protocol Secure)**, which is the encrypted version of HTTP. It uses SSL/TLS to secure communication between the web browser and the server. When you see `https://example.com` in your browser, it's connecting to port 443. This is essential for secure transactions, logins, and any sensitive data exchange.

* **Port 8080 (TCP):** While not a standard default for production web servers, port 8080 is very commonly used for:
    * **Alternative HTTP port:** Often used for development servers, secondary web servers, or proxy servers to avoid conflicts with the primary web server running on port 80/443.
    * **Application servers:** Many Java application servers (like Tomcat, JBoss, WildFly) and other web application frameworks often default to port 8080 for their HTTP connectors.

**Other Less Common (but possible) Web Server Ports:**

While 80, 443, and 8080 are the most prevalent, web servers can be configured to listen on almost any available port number (ports 1024-65535 are generally available for user applications). You might encounter:

* **Port 8443 (TCP):** Sometimes used as an alternative secure HTTPS port, similar to 8080 for HTTP.
* **Other custom ports:** Some applications or specific configurations might use unique port numbers.



## 2. Create App Servers Security Group with the Following Inbound rules.

  ### Allow the Traffic on TCP/8080 ( Application Port) from Web servers SG/Subnet.
  ### SSH ( TCP/22) Allow only from the Bastion Hosts Network.

  
**Common Default Application Server Port Numbers:**

* **Java Application Servers:** These are very prevalent in enterprise environments.
    * **Apache Tomcat:**
        * `8080` (TCP): Default HTTP connector port for web applications.
        * `8443` (TCP): Default HTTPS connector port.
        * `8009` (TCP): AJP (Apache JServ Protocol) connector port, used for integration with Apache HTTP Server.
        * `8005` (TCP): Shutdown port (for controlled shutdown from `localhost`).
    * **JBoss/WildFly:**
        * `8080` (TCP): Default HTTP port.
        * `8443` (TCP): Default HTTPS port.
        * `9990` (TCP): Default management console port (HTTP).
        * `9993` (TCP): Default management console port (HTTPS).
        * `8009` (TCP): AJP connector.
    * **GlassFish:**
        * `8080` (TCP): Default HTTP port.
        * `8181` (TCP): Default HTTPS port.
        * `4848` (TCP): Default administration console port.
    * **Jetty:** Often embedded in applications, but when run standalone, it also commonly uses `8080` or other configurable ports.

* **Node.js Applications:** Node.js apps typically run on a port specified in their code, but `3000`, `5000`, `8000`, or `8080` are very common defaults during development. In production, they are often proxied by Nginx or Apache on ports 80/443.

* **Python (Django, Flask) / Ruby on Rails / PHP (Laravel, Symfony) Servers:**
    * Development servers for these frameworks often use ports like `8000`, `5000`, or `3000` (e.g., Django's `runserver` defaults to `8000`).
    * In production, these applications are almost always run behind a web server like Nginx or Apache using a **WSGI** (Python) or **Rack** (Ruby) server (e.g., Gunicorn, uWSGI, Puma) which might listen on a higher port (e.g., `8000`, `8001`) or a Unix socket. The client (browser) never directly connects to these backend application server ports.

* **Message Queues/Brokers (often integrated with applications):**
    * **Apache Kafka:** `9092` (TCP) - Default for Kafka brokers.
    * **RabbitMQ:**
        * `5672` (TCP): AMQP (Advanced Message Queuing Protocol) for clients.
        * `15672` (TCP): Management plugin (web UI).
        * `25672` (TCP): Erlang distribution (for clustering).
    * **ActiveMQ:** `61616` (TCP) for OpenWire, `8161` (TCP) for web console.

* **Other Specialized Application Servers:**
    * **Elasticsearch:** `9200` (TCP) for HTTP REST API, `9300` (TCP) for inter-node communication (though often accessed as a data store rather than a traditional "application server").
  
## 3. Create DB servers Security Group with the following Inbound Rules.  


    ### Allow the Traffic from Web Servers SG/Subnet on DB port numbers.  
    ### SSH ( TCP/22) Allow only from the Bastion Hosts Network.
    

   **Common Default Database Port Numbers:**

* **MySQL/MariaDB:** `3306` (TCP)
* **PostgreSQL:** `5432` (TCP)
* **Oracle Database:** `1521` (TCP) - This is the default listener port. Other ports like `2483`/`2484` might be used for TCPS.
* **Microsoft SQL Server:** `1433` (TCP) - Default instance. Named instances often use dynamic ports.
* **IBM Db2:** `50000` (TCP)
* **MongoDB:** `27017` (TCP) - Also `27018` for shard servers and `27019` for config servers.
* **Redis:** `6379` (TCP)
* **Cassandra/ScyllaDB:** `9042` (TCP) - For CQL native transport. `7000` is for inter-node communication.
* **Elasticsearch:** `9200` (TCP) - For REST API. `9300` for inter-node communication.
* **CouchDB:** `5984` (TCP) - For HTTP API.
* **Neo4j:** `7687` (TCP) - For Bolt protocol. `7474` for HTTP and `7473` for HTTPS.
