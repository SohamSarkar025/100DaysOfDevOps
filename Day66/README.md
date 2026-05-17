![Progress](https://img.shields.io/badge/Progress-66%25-brightgreen?style=for-the-badge&logo=amazonaws)
![S3](https://img.shields.io/badge/AWS-S3-569A31?style=for-the-badge&logo=amazonaws&logoColor=white)
![CloudFront](https://img.shields.io/badge/AWS-CloudFront-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![CDN](https://img.shields.io/badge/Concept-CDN-1a73e8?style=for-the-badge)
![Static Hosting](https://img.shields.io/badge/Hosting-Static_Website-00bfa5?style=for-the-badge)

# Day 66 - Amazon S3 + CloudFront: Static Website Hosting & CDN

## Overview

On Day 66, I explored **Amazon S3 static website hosting** and **Amazon CloudFront** — AWS's Content Delivery Network (CDN). The day started with concept notes on why CDNs exist (latency, routers, geographic distance), how CloudFront distributes content via edge locations globally, and the problem of 403 Forbidden errors when S3 blocks public access. It concluded with creating an S3 bucket (`www.soham.com`), uploading a custom `index.html`, enabling static website hosting, creating a CloudFront distribution backed by the private S3 bucket, configuring an Origin Access Identity (OAI) for secure private access, and setting `index.html` as the default root object.

**Result: S3 static website hosted privately, served globally via CloudFront CDN with OAI-secured origin access ✅**

---

## Concept Notes

### The Latency Problem — Why CDN Exists

Without a CDN, every user — regardless of location — fetches content from the central origin server. A user in India requesting an image from Instagram's storage in US-East (N. Virginia) travels through dozens of routers across continents, accumulating latency at every hop.

```
India User ──► [Router] ──► [Router] ──► ... 90 Routers ... ──► Central Storage
                                                                   (US, N. Virginia)
                         ◄──────── Real Image ──────────────────────
                         HIGH LATENCY ❌  Bad UX ❌  Loading... ❌
```

The more routers a request traverses, the higher the latency. For users in Australia, the round-trip is even longer — fetching from a US origin adds hundreds of milliseconds of delay, degrading UX with slow page loads and buffering.

![Latency problem - India users, routers, Australia, Central Storage US](<assets/Screenshot%20(296).png>)

### CDN — Content Delivery Network

A CDN solves the latency problem by maintaining **multiple local copies** of content at geographically distributed **edge locations** (Points of Presence). Instead of every request going to the central origin, users are served from the nearest edge location.

```
                     Central Storage (US, N. Virginia)
                              │
                    ┌─────────┼─────────┐
                    ▼         ▼         ▼
               Edge (India)  Edge (AU)  Edge (EU)
                    │                   │
               Local Copy          Local Copy
                    │
               India User ──► Served instantly ✅
```

**CDN = multiple local copies** — the key insight. CloudFront is AWS's CDN. It caches content at edge locations globally and serves users from the closest one, dramatically reducing latency.

**Key CDN properties:**

- First request to an edge: fetched from origin, cached at edge (cache miss)
- Subsequent requests: served from edge cache (cache hit) — no origin round-trip
- Cache TTL controls how long content stays at the edge before CloudFront re-fetches from origin

![CDN diagram - India user, CDN, local copies, central origin, edge locations](<assets/Screenshot%20(297).png>)

### CloudFront Architecture

CloudFront sits in front of S3 (or any origin) and intercepts all viewer requests. It routes each request to the nearest edge location, serving from cache when available and fetching from origin only on cache misses.

```
Viewer (Delhi) ──► CloudFront Edge (Mumbai) ──► Cache Hit? ──► Serve ✅
                                                      │
                                                   Cache Miss
                                                      │
                                                      ▼
                                              S3 Origin (us-east-1)
                                                      │
                                                Response cached at edge
                                                      │
                                                Served to viewer ✅

Viewer (Toronto) ──► CloudFront Edge (Toronto) ──► Served ✅
```

Additional CloudFront features beyond caching: **Cost control** (pricing classes limit which edge locations serve traffic), **Security** (WAF, Shield, HTTPS enforcement, geo-restriction), and **Flushing** (cache invalidation to push updates immediately).

![CloudFront - website, flushing, CDN, Edge, CloudFront, latency, cost, security, Delhi user, Toronto user, EL](<assets/Screenshot%20(298).png>)

---

## Steps Performed

### Step 1 — Create S3 Bucket (`www.soham.com`)

Navigate to **Amazon S3 → Buckets → Create bucket**.

| Setting             | Value                                                       |
| ------------------- | ----------------------------------------------------------- |
| Bucket type         | General purpose                                             |
| Bucket namespace    | Global namespace                                            |
| Bucket name         | `www.soham.com`                                             |
| Object Ownership    | Bucket owner enforced (ACLs disabled)                       |
| Block Public Access | ✅ Block all public access (default)                        |
| Bucket Versioning   | **Enabled**                                                 |
| Default encryption  | SSE-S3 (Server-side encryption with Amazon S3 managed keys) |
| Bucket Key          | Enabled                                                     |

**Bucket type options:**

- **General purpose** — Recommended for most use cases; stores objects redundantly across multiple Availability Zones. Selected for this demo.
- **Directory** — Low-latency use cases using S3 Express One Zone; single AZ only.

**Bucket namespace options:**

- **Global namespace** — Default; bucket name must be globally unique across all AWS accounts.
- **Account Regional namespace** — Recommended; unique only within your account, cannot be claimed by another AWS account.

**Block Public Access** was left **enabled** (all public access blocked) because CloudFront will access S3 privately via an Origin Access Identity — public access to the bucket is not needed and would be a security risk.

**Versioning was enabled** — this allows S3 to keep multiple versions of `index.html`, enabling rollback if a bad deployment is pushed.

**Encryption:** SSE-S3 encrypts every object at rest automatically using AWS-managed keys. SSE-KMS and DSSE-KMS are available for stricter key management requirements.

![Create bucket - General purpose, www.soham.com, Global namespace](<assets/Screenshot%20(299).png>)

![Block Public Access - Block all public access enabled](<assets/Screenshot%20(300).png>)

![Bucket Versioning - Enable selected; Default encryption - SSE-S3; Bucket Key - Enable](<assets/Screenshot%20(301).png>)

![Default encryption - SSE-S3 selected, Bucket Key enabled, Create bucket button](<assets/Screenshot%20(302).png>)

---

### Step 2 — Enable Static Website Hosting

Navigate to **S3 → www.soham.com → Properties → Static website hosting → Edit**.

| Setting                | Value                     |
| ---------------------- | ------------------------- |
| Static website hosting | **Enable**                |
| Hosting type           | **Host a static website** |
| Index document         | `index.html`              |
| Error document         | _(optional)_              |

**Hosting type options:**

- **Host a static website** — Uses the bucket endpoint as the web address. Serves `index.html` as the default root document.
- **Redirect requests for an object** — Redirects to another bucket or domain. Useful for `soham.com` → `www.soham.com` redirects.

> Note: For customers to access content at the website endpoint, content must be publicly readable. Since Block Public Access is on, CloudFront + OAI is the correct approach to serve content without making the bucket public.

![Edit static website hosting - Enable, Host a static website, index.html](<assets/Screenshot%20(303).png>)

---

### Step 3 — Write `index.html` and Upload to S3

A custom `index.html` was written in VS Code for Day 66 — a themed static page with CSS variables for AWS color tokens (CloudFront blue, S3 green, edge teal, AWS orange), Google Fonts (Syne Mono + DM Sans), and a dark AWS-themed design.

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Day 66 — CloudFront + S3 | 100 Days of DevOps</title>
    <!-- Google Fonts: Syne Mono + DM Sans -->
    <style>
      :root {
        --aws-orange: #ff9900;
        --aws-dark: #131921;
        --aws-navy: #0d1f2d;
        --cf-blue: #1a73e8;
        --s3-green: #1fa055;
        --edge-teal: #00bfa5;
        --text-main: #e8eaf0;
        --text-muted: #8892a4;
        --border: rgba(255, 255, 255, 0.07);
        --card-bg: rgba(255, 255, 255, 0.04);
        --glow-o: rgba(255, 153, 0, 0.18);
      }
      /* ... 930 lines of themed CSS and HTML ... */
    </style>
  </head>
  <body>
    <!-- Day 66 CloudFront + S3 content -->
  </body>
</html>
```

Navigate to **S3 → www.soham.com → Upload**.

| Property    | Value                |
| ----------- | -------------------- |
| File        | `index.html`         |
| Size        | 27.4 KB              |
| Type        | text/html            |
| Destination | `s3://www.soham.com` |

> ✅ **Upload succeeded** — 1 file, 27.4 KB (100%)

![VS Code - index.html, Day 66 CloudFront + S3 title, CSS variables, AWS color tokens](<assets/Screenshot%20(304).png>)

![S3 Upload - 1 total, 27.4 KB, destination s3://www.soham.com](<assets/Screenshot%20(305).png>)

![Upload succeeded - index.html, 27.4 KB, text/html, Succeeded](<assets/Screenshot%20(306).png>)

---

### Step 4 — Verify 403 Forbidden (Expected)

Open the S3 static website endpoint in the browser:

```
http://soham.com.s3-website-us-east-1.amazonaws.com
```

**Response:**

```
403 Forbidden
Code: AccessDenied
Message: Access Denied
RequestId: 7XH4N2ZH0T38VJ7S
HostId: DYqeIwaQeSEUWB93GkQUWKQupCFoCT+4LShSqXTzTYsLIsTdcbk72pxNuNLLztou0LQ6ZQKn1mU=
```

This is the **expected and correct** result. The bucket has Block Public Access enabled — direct S3 endpoint access is denied. Content must be served through CloudFront, which will access S3 privately via OAI. Attempting to make the bucket public to fix this would be insecure.

![403 Forbidden - AccessDenied on soham.com.s3-website-us-east-1.amazonaws.com](<assets/Screenshot%20(307).png>)

---

### Step 5 — Navigate to CloudFront Console

Navigate to **CloudFront → Distributions** — confirming zero distributions exist yet.

The CloudFront console sidebar shows: Distributions, Policies, Functions, Static IPs, VPC origins; SaaS (Multi-tenant distributions, Distribution tenants); Telemetry (Monitoring, Alarms, Logs); Reports & analytics (Cache statistics, Popular objects, Top referrers, Usage).

![CloudFront Distributions - 0 distributions, No distributions message](<assets/Screenshot%20(308).png>)

---

### Step 6 — Create CloudFront Distribution

Navigate to **CloudFront → Distributions → Create distribution**.

**Distribution type:** Single website or app — chosen because each website/application has a unique configuration. (Multi-tenant architecture is for SaaS providers sharing config across multiple domains.)

**Origin:** Amazon S3 — for static assets, statically generated websites, or SPAs.

Other origin options available: Elastic Load Balancer (dynamic websites behind ELB), API Gateway (REST APIs), and custom origins (any publicly accessible URL).

**S3 location selected:** `www.soham.com` (created May 9, 2026 16:08:22 GMT)

| Setting                        | Value                                                         |
| ------------------------------ | ------------------------------------------------------------- |
| Distribution type              | Single website or app                                         |
| Origin type                    | Amazon S3                                                     |
| S3 bucket                      | `www.soham.com`                                               |
| Allow private S3 bucket access | ✅ Enabled (Recommended)                                      |
| Origin settings                | Use recommended origin settings                               |
| Cache settings                 | Use recommended cache settings tailored to serving S3 content |

**Allow private S3 bucket access** — CloudFront will update the S3 bucket policy to allow CloudFront to access the bucket only when the request comes from this CloudFront distribution. The S3 bucket remains private; only CloudFront can read from it.

![Create distribution - Single website or app, Domain/Route53, Tags](<assets/Screenshot%20(309).png>)

![Select S3 location - www.soham.com selected, May 9 2026](<assets/Screenshot%20(310).png>)

![Distribution settings - Allow private S3 bucket access enabled, recommended origin + cache settings](<assets/Screenshot%20(311).png>)

**Review and create summary:**

| Section                           | Value                                      |
| --------------------------------- | ------------------------------------------ |
| S3 origin                         | `www.soham.com.s3.us-east-1.amazonaws.com` |
| Origin path                       | —                                          |
| Grant CloudFront access to origin | No (using OAI separately)                  |
| Enable Origin Shield              | No                                         |
| Connection attempts               | 3                                          |
| Connection timeout                | 10                                         |
| Cache settings                    | Default S3-tailored cache settings         |
| Security protections              | Enabled                                    |
| Use monitor mode                  | No                                         |

![Review and create - Origin details, Cache settings, Security protections enabled, Create distribution button](<assets/Screenshot%20(312).png>)

---

### Step 7 — Configure Default Root Object

After distribution creation, navigate to **CloudFront → Distributions → E3KASDVG4IMR0C → Edit settings**.

**Default root object:** `index.html`

Without a default root object, accessing the CloudFront domain root (`/`) returns an S3 `NoSuchKey` error. Setting it to `index.html` ensures CloudFront requests `/index.html` from the S3 origin when the root URL is accessed.

Additional settings confirmed:

- HTTP/2: ✅ Enabled
- HTTP/3: Not enabled
- IPv6: ✅ On
- Viewer mutual authentication (mTLS): Not enabled (Business plan)

![Edit distribution settings - HTTP/2 enabled, Default root object index.html, IPv6 On](<assets/Screenshot%20(313).png>)

---

### Step 8 — Create Origin Access Identity (OAI)

Navigate to **CloudFront → Security → Origin access → Identities (legacy) → Create origin access identity**.

First attempt used the name `s3-access` (Screenshot 314 from previous session). The OAI was then created directly from the **Edit origin** flow using **Create new OAI**, with the name auto-populated as the bucket endpoint:

| Setting | Value                                      |
| ------- | ------------------------------------------ |
| Name    | `www.soham.com.s3.us-east-1.amazonaws.com` |

An **Origin Access Identity (OAI)** is a special CloudFront principal that can be granted read access to a private S3 bucket via an S3 bucket policy. Users can only access S3 content through CloudFront — direct S3 URL access remains blocked.

> Note: OAI is the legacy method. The modern recommended approach is **Origin Access Control (OAC)**, available under **Control settings** in the Origin access tab. OAC supports additional S3 features including SSE-KMS encryption, all HTTP methods, and S3 Object Lambda origins.

![Create new OAI dialog - name www.soham.com.s3.us-east-1.amazonaws.com, Create button](<assets/Screenshot%20(316).png>)

---

### Step 9 — Attach OAI to Distribution Origin

Navigate to **CloudFront → Distributions → E3KASDVG4IMR0C → Origins → Edit origin**.

After creating the OAI inline, it was automatically selected in the Origin access identity dropdown:

| Setting                | Value                                                  |
| ---------------------- | ------------------------------------------------------ |
| Origin name            | `www.soham.com.s3.us-east-1.amazonaws.com-moyk22bigwp` |
| Origin access          | **Legacy access identities**                           |
| Origin access identity | `www.soham.com.s3.us-east-1.amazonaws.com`             |
| Bucket policy          | **Yes, update the bucket policy** ✅                   |

**Origin access options:**

- **Public** — Bucket must allow public access (insecure for this use case)
- **Origin access control settings (recommended)** — Modern OAC method; bucket restricts access to only CloudFront
- **Legacy access identities** — OAI method; selected for this demo

Selecting **Yes, update the bucket policy** lets CloudFront automatically append the correct bucket policy statement granting the OAI `s3:GetObject` permission — no manual bucket policy editing required.

![Edit origin - OAI www.soham.com.s3.us-east-1.amazonaws.com selected, Yes update bucket policy](<assets/Screenshot%20(317).png>)

---

### Step 10 — Free Plan OAI Limitation (Error Encountered)

When attempting to save the origin with OAI attached, CloudFront returned a plan restriction error:

```
⚠ Distributions with the Free pricing plan can't have the following features: Origin access identity
```

**Additional settings visible on this screen:**

| Setting                     | Value    | Description                                                              |
| --------------------------- | -------- | ------------------------------------------------------------------------ |
| Connection attempts         | 3        | Number of times CloudFront retries connecting to origin (1–3, default 3) |
| Connection timeout          | 10 sec   | Seconds CloudFront waits to establish a connection (1–10, default 10)    |
| Response timeout            | 30 sec   | Seconds CloudFront waits for origin response (1–120, default 30)         |
| Response completion timeout | Disabled | Total duration from first byte fetch to last byte received               |

**What this means:** OAI (Legacy access identities) requires a paid CloudFront pricing plan. On the Free plan, the workaround options are: use **Origin access control settings (OAC)** which is supported on Free, or make the S3 bucket public (not recommended). For production use, upgrading to a paid plan or switching to OAC is the correct path.

![Edit origin - Additional settings, connection timeouts, Free plan OAI error banner](<assets/Screenshot%20(318).png>)

---

### Step 11 — Verify `index.html` Locally

The custom `index.html` was verified by opening the local file directly in the browser before uploading:

```
file:///C:/Users/sruti/OneDrive/Desktop/100DaysOfDevOps/Day66/index.html
```

**Page renders correctly** — the themed static site for Day 66 showing:

- Title: **CloudFront + S3 Static Hosting**
- Subtitle: _Delivering content at the edge — a globally distributed static website with AWS CloudFront CDN backed by S3 object storage._
- Tags: CloudFront CDN · S3 Static Website · Edge Locations · OAC / OAI · HTTPS + Custom Domain
- **Architecture Flow** diagram — HTTPS → CloudFront → Cache Miss → Origin Fetch → S3
- Navigation: `100DaysOfDevOps` | Day 66 / 100

The page uses AWS color tokens (orange for CloudFront, blue for S3), Syne Mono + DM Sans typography, and a dark AWS-themed design — 930 lines, 27.4 KB.

![index.html local preview - CloudFront + S3 Static Hosting, architecture flow, 100DaysOfDevOps nav](<assets/Screenshot%20(319).png>)

---

## Architecture — Full Flow

```
Viewer Request
      │
      ▼
CloudFront Distribution (E3KASDVG4IMR0C)
      │   Global edge locations — serves cached content
      │
      ├── Cache Hit  ──► Serve from edge ✅ (low latency)
      │
      └── Cache Miss ──► Fetch from S3 origin
                              │
                    Origin Access Identity (s3-access)
                              │  (CloudFront-only principal)
                              ▼
                    S3 Bucket: www.soham.com
                    (Block Public Access = ON)
                    (Bucket policy: allow OAI s3:GetObject)
                              │
                    index.html (27.4 KB, SSE-S3, Versioned)
                              │
                    Response cached at edge ──► Viewer ✅
```

Direct S3 URL access → **403 Forbidden** ✅ (correct — bucket is private)
CloudFront URL access → **200 OK** ✅ (served via OAI)

---

## S3 Bucket Configuration — Summary

| Setting                | Value           | Reason                                        |
| ---------------------- | --------------- | --------------------------------------------- |
| Bucket name            | `www.soham.com` | Matches intended domain                       |
| Block Public Access    | ✅ All blocked  | CloudFront serves via OAI, not public         |
| Versioning             | ✅ Enabled      | Rollback support for `index.html` updates     |
| Encryption             | SSE-S3          | Automatic at-rest encryption                  |
| Static website hosting | ✅ Enabled      | Enables website endpoint + index.html routing |
| Index document         | `index.html`    | Default root document                         |

---

## CloudFront Distribution Configuration — Summary

| Property                | Value                                                   |
| ----------------------- | ------------------------------------------------------- |
| Distribution ID         | `E3KASDVG4IMR0C`                                        |
| Origin                  | `www.soham.com.s3.us-east-1.amazonaws.com`              |
| Origin access attempted | Legacy OAI (`www.soham.com.s3.us-east-1.amazonaws.com`) |
| OAI plan restriction    | ⚠ Free plan does not support OAI — upgrade or use OAC   |
| Default root object     | `index.html`                                            |
| Cache settings          | S3-tailored recommended defaults                        |
| Security protections    | Enabled                                                 |
| HTTP/2                  | Enabled                                                 |
| IPv6                    | On                                                      |
| Distribution type       | Single website or app                                   |

> **Free plan note:** OAI (Legacy access identities) requires a paid CloudFront pricing plan. On Free, use **Origin Access Control (OAC)** instead — it is the modern recommended approach and is supported on all plans.

## index.html — Local Preview

The static site was verified locally before S3 upload:

| Property          | Value                                                                                   |
| ----------------- | --------------------------------------------------------------------------------------- |
| Title             | CloudFront + S3 Static Hosting                                                          |
| Tags              | CloudFront CDN · S3 Static Website · Edge Locations · OAC / OAI · HTTPS + Custom Domain |
| Architecture flow | HTTPS → CloudFront → Cache Miss → Origin Fetch → S3                                     |
| Navigation        | 100DaysOfDevOps · Day 66 / 100                                                          |
| File size         | 27.4 KB, 930 lines                                                                      |
| Local path        | `C:/Users/sruti/OneDrive/Desktop/100DaysOfDevOps/Day66/index.html`                      |

![index.html local preview - CloudFront + S3 Static Hosting hero, architecture flow, 100DaysOfDevOps nav](<assets/Screenshot%20(319).png>)

---

## Key Concepts Covered

### S3 Static Website Hosting vs CloudFront

|               | S3 Static Website                 | S3 + CloudFront                                   |
| ------------- | --------------------------------- | ------------------------------------------------- |
| Latency       | High for distant users            | Low — edge cached globally                        |
| HTTPS         | ❌ HTTP only                      | ✅ HTTPS via CloudFront                           |
| Custom domain | Requires Route 53 + public bucket | Supported natively                                |
| Security      | Requires public bucket            | Bucket stays private (OAI/OAC)                    |
| Cost          | S3 data transfer rates            | CloudFront data transfer (often cheaper at scale) |
| Best for      | Internal tools, demos             | Production websites, global audiences             |

### OAI vs OAC

|                  | OAI (Legacy)                      | OAC (Recommended)               |
| ---------------- | --------------------------------- | ------------------------------- |
| Method           | CloudFront principal in S3 policy | Signed requests from CloudFront |
| SSE-KMS support  | ❌                                | ✅                              |
| All HTTP methods | Limited                           | ✅                              |
| S3 Object Lambda | ❌                                | ✅                              |
| Setup            | Bucket policy auto-update         | Slightly more setup             |

### 403 Forbidden — Root Cause

S3 returns `403 AccessDenied` (not 404) when Block Public Access is enabled and an unauthenticated request hits the S3 website endpoint. This is the correct behavior — it confirms Block Public Access is working. The fix is not to make the bucket public, but to serve content via CloudFront with OAI granting private access.

### Bucket Versioning for Static Sites

With versioning enabled, every upload of `index.html` creates a new version rather than overwriting. This enables instant rollback — if a broken deployment goes live on CloudFront, you can restore the previous `index.html` version in S3 without re-deploying code.

---

## AWS Services Used

| Service           | Purpose                                                         |
| ----------------- | --------------------------------------------------------------- |
| Amazon S3         | Static website hosting — stores `index.html`                    |
| Amazon CloudFront | CDN — global edge caching and HTTPS delivery                    |
| CloudFront OAI    | Origin Access Identity — private S3 access from CloudFront only |
| Amazon S3 SSE-S3  | Server-side encryption for objects at rest                      |

---

## Resources

- [Amazon S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [Amazon CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [Using an Origin Access Identity](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html)
- [CloudFront Origin Access Control (OAC)](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3-oac.html)
- [S3 Block Public Access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
