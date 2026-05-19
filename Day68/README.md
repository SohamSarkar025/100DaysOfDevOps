![Progress](https://img.shields.io/badge/Progress-68%25-brightgreen?style=for-the-badge&logo=amazonaws)
![ECS](https://img.shields.io/badge/AWS-ECS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![ECR](https://img.shields.io/badge/AWS-ECR-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Fargate](https://img.shields.io/badge/AWS-Fargate-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Flask_App-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Flask](https://img.shields.io/badge/Python-Flask-3776AB?style=for-the-badge&logo=python&logoColor=white)

# Day 68 - Amazon ECS + Fargate: Running a Flask Container in the Cloud

## Overview

On Day 68, I deployed a **real containerized Flask application** on **Amazon ECS (Elastic Container Service)** using **AWS Fargate** — AWS's serverless container compute engine. The day involved creating an ECS cluster (`demo-ecs-cluster`), writing a Flask `app.py` and `Dockerfile`, building and pushing the image to ECR (`demo-app-repo`), creating an ECS Task Definition (`demo-ecs-example`), and running it as a Fargate task. The container came up **Running**, and CloudWatch Logs confirmed Flask started successfully on port 3000 inside the cluster.

**Result: Flask container running live on AWS Fargate inside `demo-ecs-cluster` — logs confirm `* Serving Flask app 'app'` ✅**

---

## Concept Notes

### ECS — Elastic Container Service

Amazon ECS is a fully managed **container orchestration service**. It runs Docker containers at scale without requiring you to manage the underlying servers. ECS groups containers into **Tasks** (one or more containers running together) and organizes tasks into **Clusters**.

```
ECS Cluster (demo-ecs-cluster)
        │
        ├── Services  ──► Long-running tasks (web servers, APIs)
        │                  Auto-restart on failure, load balancer integration
        │
        └── Tasks     ──► One-off or scheduled container runs
                           Pulled from Task Definition + ECR image
```

### Fargate vs EC2 Launch Type

ECS supports two ways to run containers:

|                   | Fargate (Serverless)             | EC2 (Self-managed)                 |
| ----------------- | -------------------------------- | ---------------------------------- |
| Server management | ❌ None — AWS manages it         | ✅ You manage EC2 instances        |
| Scaling           | Automatic per task               | Manual or Auto Scaling Group       |
| Cost model        | Per task (vCPU + memory seconds) | Per EC2 instance (running or idle) |
| Patching          | AWS handles OS patches           | You patch the EC2 instances        |
| Best for          | Most workloads, simplicity       | GPU workloads, specific hardware   |
| Used today        | ✅ Fargate only                  | —                                  |

### ECS Core Concepts

```
Task Definition ──► Blueprint for the container
        │           (image URI, CPU, memory, ports, env vars, logs)
        │
        ▼
    Task ──────────► A running instance of a Task Definition
        │             (like a running Docker container in the cloud)
        │
        ▼
   Cluster ─────────► Logical grouping of tasks and services
        │
        ▼
   Service ─────────► Keeps N tasks running at all times
                       (desired count, auto-restart, load balancing)
```

---

## Steps Performed

### Step 1 — Navigate to ECS Console

Navigate to **Amazon ECS → Clusters**.

**Clusters (0)** — no clusters exist yet. Columns visible: Cluster, Services, Tasks, Container instances, CloudWatch monitoring, Capacity provider.

ECS sidebar links: Express Mode, Clusters, Namespaces, Task definitions, Daemon task definitions, Account settings. Related services: AWS Resource Explorer, AWS Batch, Amazon ECR, Repositories.

![ECS Clusters console - 0 clusters, No clusters, Create cluster button, 19 May 2026 13:04](<assets/Screenshot%20(386).png>)

---

### Step 2 — Create ECS Cluster (`demo-ecs-cluster`)

Navigate to **ECS → Clusters → Create cluster**.

**Cluster configuration:**

| Setting          | Value                                            |
| ---------------- | ------------------------------------------------ |
| Cluster name     | `demo-ecs-cluster`                               |
| Name constraints | 1–255 chars, a-z, A-Z, 0-9, hyphens, underscores |

**Infrastructure — compute capacity options:**

| Option                             | Description                                                                                   |
| ---------------------------------- | --------------------------------------------------------------------------------------------- |
| **Fargate only** ✅                | Serverless — don't think about creating or managing servers. Great for most common workloads. |
| Fargate and managed instances      | AWS ECS manages patching and scaling while giving you configurability about instance types    |
| Fargate and Self-managed instances | You ensure instances are patched and scaled; full control                                     |

**Fargate only** was selected — the simplest path for this demo. The cluster is automatically configured for serverless Fargate compute.

![Create cluster - demo-ecs-cluster, Fargate only selected, infrastructure options](<assets/Screenshot%20(387).png>)

**Cluster created — Clusters (1):**

| Property              | Value              |
| --------------------- | ------------------ |
| Cluster               | `demo-ecs-cluster` |
| Services              | 0                  |
| Tasks                 | No tasks running   |
| Container instances   | 0 EC2              |
| CloudWatch monitoring | Default            |
| Capacity provider     | No default found   |

![Clusters 1 - demo-ecs-cluster, 0 services, No tasks running, 0 EC2, Default monitoring](<assets/Screenshot%20(388).png>)

**Cluster overview (inside demo-ecs-cluster):**

| Property                       | Value                                                         |
| ------------------------------ | ------------------------------------------------------------- |
| ARN                            | `arn:aws:ecs:us-east-1:248189914762:cluster/demo-ecs-cluster` |
| Status                         | ✅ Active                                                     |
| CloudWatch monitoring          | Default                                                       |
| Registered container instances | —                                                             |
| Services                       | Draining: — / Active: —                                       |
| Tasks                          | Pending: — / Running: —                                       |

Tabs available: Services, Tasks, Daemons, Infrastructure, Metrics, Scheduled tasks, Configuration, Event history, Tags.

![demo-ecs-cluster overview - ARN, Active status, 0 services, Tasks panel, all tabs](<assets/Screenshot%20(389).png>)

---

### Step 3 — Write the Flask Application

Navigate to `100DaysOfDevOps/Day68` directory in MINGW64 and create the application files.

**`Dockerfile`** (written in vim):

```dockerfile
# Use the official Python image as the base image
FROM python:3.9

# Set the working directory in the container
WORKDIR /app

# Copy the Python dependencies file to the container
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Flask application code to the container
COPY app.py .

# Expose the port the Flask application will run on
EXPOSE 3000

# Command to run the Flask application when the container starts
CMD ["python", "app.py"]
```

**`app.py`** (written in vim):

```python
# app.py
from flask import Flask

app = Flask(__name__)

# Route to the root URL
@app.route('/')
def hello():
    return 'Hello, Flask on Docker!'

# Route to a custom endpoint
@app.route('/greet/<name>')
def greet(name):
    return f'Hello, {name}! Welcome to Flask on Docker.'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
```

**Project structure verified with `ls`:**

```
Dockerfile   app.py   assets/   requirements.txt
```

![vim Dockerfile - FROM python:3.9, WORKDIR /app, COPY, RUN pip install, EXPOSE 3000, CMD](<assets/Screenshot%20(390).png>)

![vim app.py - Flask import, hello() route, greet/<name> route, app.run host 0.0.0.0 port 3000](<assets/Screenshot%20(391).png>)

---

### Step 4 — Create a Second ECR Repository for the Flask App

Navigate to **Amazon ECR → Private registry → Repositories → Create a private repository**.

The same `demo-app-repo` from Day 67 was reused — a new repository creation screen confirms the settings remain:

| Setting              | Value                                                        |
| -------------------- | ------------------------------------------------------------ |
| Repository name      | `demo-app-repo`                                              |
| Full URI             | `248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo` |
| Image tag mutability | Mutable                                                      |

The ECR push commands panel was opened again for reference:

```bash
# 1. Authenticate
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
    248189914762.dkr.ecr.us-east-1.amazonaws.com

# 2. Build
docker build -t demo-app-repo .

# 3. Tag
docker tag demo-app-repo:latest \
  248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest

# 4. Push
docker push 248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest
```

![ECR Create private repository - demo-app-repo, Mutable tag](<assets/Screenshot%20(392).png>)

![Push commands for demo-app-repo - 4-step auth/build/tag/push workflow](<assets/Screenshot%20(393).png>)

---

### Step 5 — Authenticate, Build, and Push Flask Image to ECR

In MINGW64 from `100DaysOfDevOps/Day68`:

**Authenticate Docker to ECR:**

```bash
$ aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
    248189914762.dkr.ecr.us-east-1.amazonaws.com
Login Succeeded
```

**Check running containers and local images:**

```bash
$ docker ps
CONTAINER ID   IMAGE           COMMAND        CREATED        STATUS         PORTS
01af42580f8c   ubuntu:latest   "/bin/bash"    2 months ago   Up 17 hours    0.0.0.0:2222->22/tcp, 0.0.0.0:8080->80/tcp
                                                                              ubuntu-container

$ docker images
IMAGE                                                              ID
248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest  bd047b697176
SohamDocker25/python-web-app-demo:latest                            f8d739fa85c1
demo-app-repo:latest                                                bd047b697176
ubuntu:latest                                                       d1e2e92c075e
ultimate-cicd-pipeline:v1                                           a573080143f6
```

**Build the Flask Docker image:**

```bash
$ docker build -t demo-app-repo .
[+] Building 358.5s (11/11) FINISHED          docker:desktop-linux
=> [internal] load build definition from Dockerfile
=> => transferring dockerfile: 550B
=> [internal] load metadata for docker.io/library/python:3.9       5.8s
=> [auth] library/python:pull token for registry-1.docker.io
=> [1/5] FROM docker.io/library/python:3.9@sha256:da5aee29682d12a...  345.5s
    (downloading 6 layers — python:3.9 base ~720MB total)
=> [3/5] COPY requirements.txt .                                    0.2s
=> [4/5] RUN pip install --no-cache-dir -r requirements.txt         4.9s
=> [5/5] COPY app.py .                                              0.1s
=> => exporting image
=> => naming to docker.io/library/demo-app-repo:latest
```

The `python:3.9` base image (not cached — first pull) required downloading ~720 MB across 6 layers, taking **358.5 seconds**. This is significantly more than Day 67's `ubuntu:latest` build (0.5s cached) because `python:3.9` includes the full Python runtime.

![docker images + docker build 358.5s - python:3.9 downloaded, 11 steps FINISHED](<assets/Screenshot%20(395).png>)

**Tag and push to ECR:**

```bash
$ docker tag demo-app-repo:latest \
  248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest

$ docker push 248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest
The push refers to repository [248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo]
91c91c91f1d2: Pushed
0d59f98a662b: Pushed
7554cb3fcc02: Pushed
081ccf923272: Pushed
d273cee07e16: Pushed
c9723aa529b0: Pushed
89d573bf42b3: Pushed
502db054947e: Pushed
79d5bd8a8d26: Pushed
e95139d4387c: Pushed
26dfe2fac1c4: Pushed
795dbedde24d: Pushed
latest: digest: sha256:a30659c933262d49857cac3d4d6303bf8a5c05f8f46b08661d5f9e7d042e1919 size: 856
```

12 layers pushed (the full Python 3.9 runtime + Flask dependencies + app code), compared to 2 layers in Day 67's minimal ubuntu image.

![docker tag + docker push - 12 layers Pushed, digest sha256:a30659c..., size 856](<assets/Screenshot%20(396).png>)

---

### Step 6 — Create ECS Task Definition (`demo-ecs-example`)

Navigate to **ECS → Task definitions → Create new task definition**.

**Task definition configuration:**

| Setting                | Value                                                  |
| ---------------------- | ------------------------------------------------------ |
| Task definition family | `demo-ecs-example`                                     |
| Launch type            | **AWS Fargate** ✅ (Serverless compute for containers) |
| OS / Architecture      | Linux/X86_64                                           |
| Network mode           | awsvpc                                                 |
| Task CPU               | **1 vCPU**                                             |
| Task memory            | **3 GB**                                               |
| Task role              | — (none required for this demo)                        |
| Task execution role    | **Create default role** → `ecsTaskExecutionRole`       |

**Launch type options:**

| Option               | Description                                                              |
| -------------------- | ------------------------------------------------------------------------ |
| **AWS Fargate** ✅   | Serverless compute for containers                                        |
| Managed instances    | Specific hardware constraints (GPU, CPU instructions, network-optimized) |
| Amazon EC2 instances | Self-managed infrastructure using EC2                                    |

The **Task execution role** (`ecsTaskExecutionRole`) is an IAM role used by the ECS container agent to make AWS API requests on your behalf — for example, pulling the image from ECR and sending logs to CloudWatch.

![Create task definition - demo-ecs-example, AWS Fargate selected, Managed instances, EC2 options](<assets/Screenshot%20(396).png>)

![Task definition - Linux/X86_64, awsvpc, 1 vCPU, 3 GB, Task role -, Task execution role Create default](<assets/Screenshot%20(397).png>)

**Container — 1 (Essential container):**

| Setting               | Value                                                               |
| --------------------- | ------------------------------------------------------------------- |
| Container name        | `example`                                                           |
| Essential container   | Yes                                                                 |
| Image URI             | `248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest` |
| Container port        | **3000**                                                            |
| Protocol              | TCP                                                                 |
| App protocol          | HTTP                                                                |
| Private registry auth | Disabled (ECR access via task execution role)                       |

The Image URI directly references the ECR image pushed in Step 5. No private registry authentication toggle is needed because the `ecsTaskExecutionRole` grants ECR pull permissions via IAM.

**Log collection:**

| Log setting           | Value                   |
| --------------------- | ----------------------- |
| Use log collection    | ✅ Enabled              |
| Destination           | Amazon CloudWatch       |
| awslogs-group         | `/ecs/demo-ecs-example` |
| awslogs-region        | `us-east-1`             |
| awslogs-stream-prefix | `ecs`                   |
| awslogs-create-group  | `true`                  |

CloudWatch logging is auto-configured — ECS will create the log group `/ecs/demo-ecs-example` and stream all container stdout/stderr to it.

![Container 1 - name example, Image URI ECR demo-app-repo:latest, port 3000 TCP HTTP](<assets/Screenshot%20(399).png>)

![Log collection - CloudWatch, awslogs-group /ecs/demo-ecs-example, region us-east-1, stream prefix ecs](<assets/Screenshot%20(400).png>)

**Task definition created successfully:**

> ✅ **Task definition successfully created**
> `demo-ecs-example:1` has been successfully created. You can use this task definition to deploy a service or run a task.

| Property            | Value                                                                   |
| ------------------- | ----------------------------------------------------------------------- |
| Task definition     | `demo-ecs-example:1`                                                    |
| ARN                 | `arn:aws:ecs:us-east-1:248189914762:task-definition/demo-ecs-example:1` |
| Status              | ✅ ACTIVE                                                               |
| App environment     | Fargate                                                                 |
| Task execution role | `ecsTaskExecutionRole`                                                  |
| OS / Architecture   | Linux/X86_64                                                            |
| Network mode        | awsvpc                                                                  |
| Task CPU            | 1,024 units (1 vCPU)                                                    |
| Task memory         | 2,048 MiB (2 GiB)                                                       |
| Fault injection     | Turned off                                                              |

![demo-ecs-example:1 created - ARN, ACTIVE, Fargate, ecsTaskExecutionRole, Linux/X86_64, awsvpc, 1vCPU/2GiB](<assets/Screenshot%20(401).png>)

---

### Step 7 — Run the Task on Fargate

Navigate to **ECS → Task definitions → demo-ecs-example → Revision 1 → Deploy → Run task**.

**Run task configuration:**

| Setting                  | Value              |
| ------------------------ | ------------------ |
| Task definition family   | `demo-ecs-example` |
| Task definition revision | **1** (Latest)     |
| Desired tasks            | **1**              |
| Environment              | AWS Fargate        |

**Task launched:**

> ✅ **Tasks launched**
> `arn:aws:ecs:us-east-1:248189914762:task/demo-ecs-cluster/9a958b7afab443589a43f49c9afcddd7`

![Run task - demo-ecs-example, revision 1 Latest, Desired tasks 1, AWS Fargate](<assets/Screenshot%20(402).png>)

**Task configuration — provisioning:**

| Property           | Value                                                               |
| ------------------ | ------------------------------------------------------------------- |
| Task ID            | `9a958b7afab443589a43f49c9afcddd7`                                  |
| Last status        | ⏳ Provisioning                                                     |
| Desired status     | ✅ Running                                                          |
| Started/created at | 19 May 2026, 13:37 (UTC+05:30)                                      |
| Image URI          | `248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest` |
| Essential          | Yes                                                                 |

![Task 9a958b7a - Provisioning → Running, Container details for example, Image URI ECR demo-app-repo](<assets/Screenshot%20(403).png>)

---

### Step 8 — Task Running + CloudWatch Logs ✅

After provisioning completes, the task transitions to **Running** status.

**Task `3c4c5c649a734d7abda7d1067a2e7295` — Running:**

| Property       | Value                                                               |
| -------------- | ------------------------------------------------------------------- |
| Last status    | ✅ Running                                                          |
| Desired status | ✅ Running                                                          |
| Started at     | 19 May 2026, 13:48 (UTC+05:30)                                      |
| Created at     | 19 May 2026, 13:47 (UTC+05:30)                                      |
| Image URI      | `248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest` |
| Essential      | Yes                                                                 |

**CloudWatch Logs (7 log entries) — Flask started successfully:**

| Timestamp (UTC+05:30) | Message                                                                                                                | Container |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------- | --------- |
| 19 May 2026, 13:48    | WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead. | example   |
| 19 May 2026, 13:48    | \* Running on all addresses (0.0.0.0)                                                                                  | example   |
| 19 May 2026, 13:48    | \* Running on http://127.0.0.1:3000                                                                                    | example   |
| 19 May 2026, 13:48    | \* Running on http://172.31.1.64:3000                                                                                  | example   |
| 19 May 2026, 13:48    | Press CTRL+C to quit                                                                                                   | example   |
| 19 May 2026, 13:48    | **\* Serving Flask app 'app'**                                                                                         | example   |
| 19 May 2026, 13:48    | \* Debug mode: off                                                                                                     | example   |

The Flask development server is live inside the Fargate container, listening on `0.0.0.0:3000` (all interfaces). The container's internal IP is `172.31.1.64` — the private IP assigned within the VPC subnet.

Logs are streamed to CloudWatch Logs group `/ecs/demo-ecs-example` and visible directly in the ECS console. The **CloudWatch Logs Live Tail** button allows real-time log streaming.

![Task 3c4c5c64 - Running status, Started 13:48, Created 13:47, Image URI ECR](<assets/Screenshot%20(405).png>)

![CloudWatch Logs 7 entries - Flask WARNING dev server, Running on 0.0.0.0, 127.0.0.1:3000, 172.31.1.64:3000, Serving Flask app 'app', Debug mode off](<assets/Screenshot%20(404).png>)

---

## End-to-End Architecture

```
Day68/
├── Dockerfile          # FROM python:3.9, EXPOSE 3000, CMD python app.py
├── app.py              # Flask app — / → Hello Flask, /greet/<name>
└── requirements.txt    # Flask dependency

         Local (MINGW64)                    AWS
         ──────────────                     ───
 vim Dockerfile + app.py
         │
 docker build -t demo-app-repo .  (358.5s — python:3.9 pull)
         │
 docker tag → ECR URI
         │
 docker push ─────────────────►  ECR: demo-app-repo:latest
                                       │
                             ECS Task Definition: demo-ecs-example:1
                             (Fargate, 1vCPU, 3GB, port 3000, CloudWatch logs)
                                       │
                             ECS Cluster: demo-ecs-cluster
                                       │
                             Fargate Task launched ──► Running ✅
                                       │
                             CloudWatch Logs:
                             * Serving Flask app 'app' ✅
                             * Running on 0.0.0.0:3000
```

---

## ECS Task Definition Summary

| Property            | Value                                                                   |
| ------------------- | ----------------------------------------------------------------------- |
| Family              | `demo-ecs-example`                                                      |
| Revision            | 1                                                                       |
| ARN                 | `arn:aws:ecs:us-east-1:248189914762:task-definition/demo-ecs-example:1` |
| Launch type         | AWS Fargate                                                             |
| OS                  | Linux/X86_64                                                            |
| Network mode        | awsvpc                                                                  |
| Task CPU            | 1 vCPU (1,024 units)                                                    |
| Task memory         | 2 GiB (2,048 MiB)                                                       |
| Task execution role | `ecsTaskExecutionRole`                                                  |
| Container name      | `example`                                                               |
| Image URI           | `248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest`     |
| Container port      | 3000 (TCP / HTTP)                                                       |
| Log group           | `/ecs/demo-ecs-example`                                                 |
| Log region          | us-east-1                                                               |

---

## Key Concepts Covered

### Task Definition Roles — Task Role vs Execution Role

| Role                                             | Purpose                                                                    |
| ------------------------------------------------ | -------------------------------------------------------------------------- |
| **Task role**                                    | IAM role for code _inside_ the container — e.g. calling DynamoDB, S3, SQS  |
| **Task execution role** (`ecsTaskExecutionRole`) | IAM role for the ECS _agent_ — pulling ECR images, writing CloudWatch logs |

For this demo, only the execution role was needed — the Flask app doesn't call any AWS services from inside the container.

### awsvpc Network Mode

ECS Fargate tasks use `awsvpc` network mode — each task gets its own **Elastic Network Interface (ENI)** with a private IP from the VPC subnet. This means tasks are first-class VPC citizens with security group control at the task level (not the instance level).

### Build Time — python:3.9 vs ubuntu:latest

| Base image               | Build time           | Layers pushed | Size    |
| ------------------------ | -------------------- | ------------- | ------- |
| `ubuntu:latest` (Day 67) | ~0.5s (cached)       | 2             | 29.7 MB |
| `python:3.9` (Day 68)    | ~358.5s (first pull) | 12            | ~720 MB |

`python:3.9` bundles the full CPython interpreter, pip, setuptools — everything needed to run Python. Subsequent builds would be much faster (layers cached by Docker).

### CloudWatch Log Path

```
/ecs/demo-ecs-example          ← Log group (awslogs-group)
    └── ecs/example/<task-id>  ← Log stream (prefix/container/task)
```

The `awslogs-create-group: true` setting lets ECS auto-create the log group — no manual CloudWatch setup needed.

---

## AWS Services Used

| Service                | Purpose                                                                 |
| ---------------------- | ----------------------------------------------------------------------- |
| Amazon ECS             | Container orchestration — runs Fargate tasks in demo-ecs-cluster        |
| AWS Fargate            | Serverless compute — hosts the Flask container without managing servers |
| Amazon ECR             | Private image registry — stores `demo-app-repo:latest` (Flask image)    |
| Amazon CloudWatch Logs | Container stdout/stderr logging — `/ecs/demo-ecs-example`               |
| AWS IAM                | `ecsTaskExecutionRole` — grants ECS agent ECR pull + CloudWatch write   |

---

## Resources

- [Amazon ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html)
- [ECS Task Definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)
- [ECS Task Execution IAM Role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html)
- [awsvpc Network Mode](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking-awsvpc.html)
- [CloudWatch Logs with ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
