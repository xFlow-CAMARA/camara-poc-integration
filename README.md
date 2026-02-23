# CAMARA PoC Integration

This repository holds the Docker Compose entrypoint that runs the full CAMARA PoC stack (CoreSim + NEF + TF SDK API + CAMARA Dashboard + observability).

## Important: expected directory layout

The Compose file references sibling folders (e.g. `./nef`, `./coresim`, `./config`). That means you should run it from a workspace root that contains **all** required folders side-by-side:

- `/home/xflow/camara-poc-integration`
- `/home/xflow/coresim`
- `/home/xflow/nef`
- `/home/xflow/tf-sdk`
- `/home/xflow/camara-dashboard`
- `/home/xflow/config`
- `/home/xflow/oai-core`

## Local run

From the workspace root:

```bash
cd /home/xflow
docker compose -f camara-poc-integration/docker-compose.yml up -d --build
```

## Deployment to VM (192.168.20.171)

This repo includes a GitHub Actions workflow that can deploy the stack **on the VM itself** using a **self-hosted runner**.

### GitHub Actions cost note

All CI/CD workflows across the CAMARA repos are configured to run on the VM runner label `camara-vm` (self-hosted) to avoid GitHub-hosted Actions minutes charges.

That means the VM should have:
- Docker Engine + Docker Compose v2
- `git`
- Enough disk space for Docker builds/images
- Outbound internet access to GitHub (for `actions/checkout` and setup actions)

### 1) Install a self-hosted GitHub Actions runner on the VM

- On GitHub: repo → **Settings** → **Actions** → **Runners** → **New self-hosted runner**
- Follow the Linux instructions on the VM.
- Add the runner label `camara-vm` (the deploy workflow requires it).

### 2) Ensure VM prerequisites

- Docker Engine installed
- Docker Compose v2 available (`docker compose version`)
- The directory layout above exists under `/home/xflow`
- The runner user can run Docker (typically by being in the `docker` group)

### 3) Run the deploy workflow

- Go to **Actions** → **Deploy (VM)** → **Run workflow**
- The workflow:
  - validates Docker/Compose
  - fast-forwards the repos in `/home/xflow/*` to `main`
  - runs `docker compose up -d --build --remove-orphans`
  - prints `docker compose ps`

If your VM uses a different default branch than `main`, adjust the workflow in `.github/workflows/deploy-vm.yml`.
