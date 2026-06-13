# AWS EC2 Auto Scaling & High Availability Architecture

## Project Overview
This project demonstrates how to build a highly available, fault-tolerant, and dynamically scalable web application infrastructure on AWS. By leveraging EC2 Auto Scaling Groups (ASG), an Application Load Balancer (ALB), and CloudWatch Monitoring, the system automatically adjusts compute capacity based on incoming traffic demand. 

With this setup, the application maintains peak performance during high-traffic spikes while optimizing infrastructure costs by scaling down during periods of low activity.

---

## Services Used
- Amazon EC2: Virtual servers running Amazon Linux 2 to host the web application.
- Auto Scaling Group (ASG): Dynamically manages the lifecycle, additions, and removals of EC2 instances.
- Application Load Balancer (ALB): Evenly distributes user traffic across the active EC2 instances for high availability.
- Amazon CloudWatch: Monitors system metric thresholds (like CPU Utilization) to trigger automated scaling actions.
- IAM & Security Groups: Controls secure network access and service permissions.

---

## Steps to Implement

### 1. Configure Security Groups
- Go to EC2 Console -> Security Groups -> Create security group.
- Provide basic details like the Security Group Name (SG-For-AutoScaling), a clear description, and link it to your active VPC.

![Create Security Group - Basic Details](images/screenshot1.png)

- Scroll down to define your Inbound rules.
- Add rules to allow standard traffic types from anywhere (0.0.0.0/0), including SSH (Port 22), HTTP (Port 80), and HTTPS (Port 443).
- Add a custom TCP rule for Port 3000, which is the default port your application uses to communicate.

![Configure Inbound Rules Panel](images/screenshot2.png)

---

### 2. Create an EC2 Launch Template
- Navigate to EC2 Dashboard -> Launch Templates -> Create launch template.
- Provide a name for your template, such as My-Machine-For-AS, and add a description for your application version.

![Launch Template - Name and Description](images/screenshot3.png)

- Under Application and OS Images (Amazon Machine Image), select Amazon Linux.
- Choose the Amazon Linux 2 AMI (Kernel 5.10) which is Free Tier eligible.

![Launch Template - Select OS Image](images/screenshot4.png)

- Choose the instance type as t2.micro.
- Under Network settings, choose the option to *Select existing security group* and map it to your newly created SG-For-AutoScaling.

![Launch Template - Network and Security Group](images/screenshot5.png)

- Expand the Advanced Details toggle at the bottom of the form and scroll down to the User Data field.
- Paste your automation script here to run on system boot. This script installs dependencies, clones your code, installs Flask, and runs the application service in the background on port 3000.

![Launch Template - Advanced Details User Data Script](images/screenshot6.png)

---

### 3. Deploy the Auto Scaling Group (ASG)
- Head over to Auto Scaling Groups -> Create Auto Scaling group.
- Choose a unique name for your group (e.g., AS-For-Application) and attach the My-Machine-For-AS launch template you just configured.

![Create ASG - Name and Template Selection](images/screenshot7.png)

- Under the Network configuration screen, select your target VPC.
- Choose multiple Availability Zones and subnets (e.g., us-east-1b, us-east-1c, us-east-1d) to ensure your cluster is spread across multiple physical data centers for high availability.

![Create ASG - Network and Subnet Selection](images/screenshot8.png)

---

### 4. Integrate an Application Load Balancer (ALB)
- In the next step, check the box to attach a New load balancer.
- Select Application Load Balancer as the type, and verify that the Load balancer scheme is set to Internet-facing.

![Create ASG - Attach New Load Balancer](images/screenshot9.png)

- Ensure the Network mapping for your Load Balancer spans across the same availability zones and public subnets selected for your ASG.

![Create ASG - Load Balancer Network Mapping](images/screenshot10.png)

- Under Listeners and routing, look at the default routing options.
- Change the dropdown or configure a new default action to Create a target group.
- Provide a target group name like AS-for-Application-1 and set the backend entry routing port to look for port 3000.

![Create ASG - Listeners and Target Group Route](images/screenshot11.png)

---

### 5. Define Sizing Boundaries and Scaling Policies
- In the Configure group size and scaling policies section, establish your capacity boundaries:
  - Desired capacity: 2 (The default number of running instances you want at all times).

![Create ASG - Set Desired Capacity](images/screenshot12.png)

  - Minimum capacity: 1 (The lowest number of instances your app can scale down to).
  - Maximum capacity: 3 (The maximum ceiling your application can scale up to during high traffic spikes).
- Select Target tracking scaling policy under the Automatic scaling options.
- Set the metric type to Average CPU utilization and choose your target percentage (e.g., 20% for active demonstration or 70% for standard production deployment).

![Create ASG - Scaling Policies and CPU Target Tracking](images/screenshot13.png)

---

### 6. Verify Initial ASG Deployment
- Before clicking final confirmation on your Auto Scaling Group, review your active AWS dashboard resources.
- Notice that the current number of Running Instances, Key Pairs, and Load Balancers are at their baseline.

![AWS Resource Dashboard Baseline Context](images/screenshot14.png)

- Once your ASG is completely built and deployed, check your EC2 Dashboard again.
- The active running instance count immediately responds to match your desired capacity value.

![EC2 Dashboard Showing Active Scaling Resources](images/screenshot15.png)

- Click on the Instances tab to view your machines.
- You will find two distinct t2.micro virtual machines launched concurrently by your ASG, both entering the initial provisioning phase.

![EC2 Instances Management Grid view](images/screenshot16.png)

- Select the first running instance from the list, scroll down to the Details panel, and copy its public IPv4 address.

![Instance 1 Details View and IP Copy](images/screenshot17.png)

- Open a new tab in your web browser, paste the IP address followed by port :3000 (http://<instance-1-ip>:3000), and hit Enter.
- The page will load successfully displaying: "This is my Demo application for Auto Scaling Project".

![Browser Live Application Verification Instance 1](images/screenshot18.png)

- Go back to your console, grab the public IPv4 address for your second active instance, and repeat the step.

![Instance 2 Details View and IP Copy](images/screenshot19.png)

- Paste it into your browser tab with port :3000 (http://<instance-2-ip>:3000) to confirm that both background virtual machines are serving your code perfectly.

![Browser Live Application Verification Instance 2](images/screenshot20.png)

---

### 7. Optimize Port Mapping via Load Balancer DNS
- Navigate to the Load Balancers tab on your left EC2 menu and select your load balancer.
- Look for the DNS name field on the details screen and copy the long URL address.

![Load Balancer Configuration Panel and DNS Name](images/screenshot21.png)

- Paste that copied DNS name into a web browser tab followed by your application port :3000 (http://<alb-dns-url>:3000).
- The Load Balancer successfully intercepts the traffic and distributes it to your backend application instances.

![Browser Check of App Access Using ALB DNS on Port 3000](images/screenshot22.png)

- Optimization Step: For better user experience, we want users to view our application without manually typing a trailing custom port number (like :3000) in their web browsers.
- Select your Load Balancer, click the Listeners and rules tab, highlight the existing HTTP listener rule, and click Manage listener -> Edit listener.

![Listeners and Rules List - Edit Listener View](images/screenshot23.png)

- Change the external entry Port configuration from its current value of 3000 to standard HTTP Port 80.
- Keep the forwarding action pointed to your backend Target Group running on port 3000. Save changes.

![Modify Listener Properties to Port 80 Form](images/screenshot24.png)

- Return to your web browser and paste just the clean Load Balancer DNS URL without appending any custom port at the end.
- The app loads on standard HTTP port 80.

![Browser App Loading on Clean URL Without Port 3000](images/screenshot25.png)

---

### 8. Testing Fault Tolerance & Auto-Healing
- Open the Instances management screen to test how the setup handles system failures.
- Notice your active servers are passing health checks cleanly.

![Healthy Active Instances Check](images/screenshot26.png)

- Select one of your primary running instances, click Instance state, and click Terminate instance to simulate an unexpected server crash.

![Instance Management Dropdown - Select Terminate](images/screenshot27.png)

- Confirm the deletion request. The instance state will switch to a yellow Shutting down phase followed by a red Terminated status.

![Instance Termination Status Confirmation](images/screenshot28.png)

- If you attempt to refresh the old public IP tab of that specific server in your browser, the page will hang and display a "This site can't be reached" timeout error.

![Browser Page Timeout Error From Dropped Machine](images/screenshot29.png)

- The Healing Process: Because your Auto Scaling Group has a strict desired capacity setting of 2, it instantly catches the infrastructure deficit.
- Head to your instances grid. You will see a brand new instance automatically spawned and entering an Initializing phase to heal the cluster.

![ASG Intervening and Launching Replacement Machine](images/screenshot30.png)

- Once healthy, copy the public IP address of this automated replacement server.

![Replacement Instance Configuration Details Screen](images/screenshot31.png)

- Paste it into your browser tab to confirm that the new server is up, running, and completely synced to maintain your application uptime.

![Browser Verification of Live Replacement Machine Application](images/screenshot32.png)

---

### 9. Stress Testing Load-Based Scale Out
- To prove that our target tracking scaling policy handles real-world spikes, we can simulate heavy compute traffic.
- Open your terminal or git bash, locate your access keys, and connect to one of your active EC2 instances via SSH.

![SSH Connection via Terminal to Remote EC2 Instance](images/screenshot33.png)

- Use a terminal editor (like vi script.sh) to build a custom testing script on the instance.

![Creating Testing Shell Script inside VM Terminal](images/screenshot34.png)

- Write an intensive infinite while [ true ] loop script engineered to repeatedly echo stress text and run calculations to max out CPU utilization capacity.

![Writing High-Load Infinite Loop Code Blocks](images/screenshot35.png)

- Set executable privileges with chmod 755 script.sh and run it (./script.sh).
- Watch the script execute thousands of loops a second, forcing the server's CPU to max out.

![Executing Loop Stress Script to Flood Compute Resources](images/screenshot36.png)

- Go back to the AWS Management Console, select the instance under stress, and check its Monitoring tab.
- Watch the CPU Utilization graph spike up drastically.

![CloudWatch Monitoring Panel Tracking Active CPU Spike](images/screenshot37.png)

- Because the threshold crossed our scaling policy limits, CloudWatch triggers a scale-out alarm.
- Check your running instances dashboard: the ASG responds to the alarm by dynamically provisioning a 3rd instance to help distribute the heavy traffic load.

![ASG Dynamic Scale Out Injecting Third Running Machine](images/screenshot38.png)

---

### 10. Clean Up Resources Safely
- Once you are finished testing your setup, remember to clean up your environment.
- Crucial Rule: If you delete or destroy an Auto Scaling Group (ASG), all active EC2 instances launched by that specific group will be automatically terminated to protect you from unexpected cloud costs.

![Final Cleanup Architecture Status View](images/screenshot39.png)

---

## Benefits
- Zero Server Management Overhead: Compute scaling rules handle infrastructure expansion automatically.
- High Fault Tolerance: Dead instances are instantly replaced without manual engineering intervention.
- Cost Optimization: Only runs resource limits that match ongoing, real-time user traffic.

## Key Learnings
- Launch Blueprints: Working with Amazon Machine Images (AMI) and automating initialization via User Data scripts.
- Elastic Load Balancing: Forwarding traffic seamlessly between front-end port configurations (Port 80) and back-end services (Port 3000).
- Metric-Driven Architecture: Creating specific CloudWatch rules to turn performance thresholds into automated actions.
- Infrastructure Resiliency: Distributing workloads across separate geographical availability zones to mitigate single points of failure.
