The architecture

PUBLIC INTERNET
                     │
                     ▼
        ┌──────────────────────────┐
        │     Security Group       │
        └────────────┬─────────────┘
                     ▼
     ┌────────────────────────────────────────────────────────┐
     │                    AWS EC2 Server                      │
     │  ┌──────────────────────────────────────────────────┐  │
     │  │          Docker / Kubernetes Pods                │  │
     │  │   ├── React Container (Port 80)                  │  │
     │  │   ├── Django Container (Port 8000)               │  │
     │  │   └── PostgreSQL Container (Port 5432) ◄──┐      │  │
     │  │               │                           │      │  │
     │  │               └──(Talks to internal DB)───┘      │  │
     │  └──────────────────────────┬───────────────────────┘  │
     └─────────────────────────────┼──────────────────────────┘
                                   │ (Uploads/Downloads)
                                   ▼
                    ┌─────────────────────────────┐
                    │        AWS S3 Bucket        │  <-- 100% Free in LocalStack
                    │ (Django Media & User Files) │
                    └─────────────────────────────┘
