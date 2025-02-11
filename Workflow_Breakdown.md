# Deploying a Java Spring Boot Application to AWS EKS using GitHub Actions and ArgoCD

This repository contains a GitHub Actions pipeline to build, package, containerize, and deploy a Java Spring Boot application to an AWS EKS cluster using Helm and ArgoCD.

## Workflow Overview
The workflow consists of multiple jobs, each performing key actions crucial for CI/CD.

### 1. Code Checkout
**Purpose**: Fetch the latest source code from the repository.

**Key Actions:**
- `actions/checkout@v3`: Checks out the repository.
- `actions/upload-artifact@v3`: Stores the code as an artifact for later jobs.

### 2. Maven Build
**Purpose**: Compile and package the Java Spring Boot application.

**Key Actions:**
- `actions/download-artifact@v3`: Retrieves the source code.
- `actions/setup-java@v3`: Sets up Java 11 for the build.
- `mvn clean package`: Builds the application.

### 3. Docker Build & Push
**Purpose**: Build a Docker image and push it to DockerHub.

**Key Actions:**
- `actions/download-artifact@v3`: Retrieves the source code.
- `docker login`: Authenticates with DockerHub.
- `docker build`: Builds the Docker image.
- `docker push`: Pushes the image to DockerHub.

### 4. Deploy to EKS
**Purpose**: Deploy the application to the AWS EKS cluster.

**Key Actions:**
- `actions/download-artifact@v3`: Retrieves the source code.
- `aws-actions/configure-aws-credentials@v3`: Configures AWS authentication.
- `aws eks update-kubeconfig`: Updates kubeconfig for EKS access.
- `sed -i`: Updates the image tag in `deployment.yml`.
- `kubectl apply`: Deploys the application and services to Kubernetes.

### 5. Setup ArgoCD
**Purpose**: Configure ArgoCD for GitOps-based deployment.

**Key Actions:**
- `curl`: Installs the ArgoCD CLI.
- `argocd app create`: Creates an ArgoCD application linked to the repository.

## GitHub Actions Workflow File
```yaml
name: Deploy to EKS

on:
  push:
    branches:
      - main

jobs:
  code_checkout:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      - name: Upload code artifact
        uses: actions/upload-artifact@v3 
        with:
          name: source-code 
          path: . 

  maven_build:
    runs-on: ubuntu-latest
    needs: code_checkout
    steps:
      - name: Download code artifact
        uses: actions/download-artifact@v3
        with:
          name: source-code
          path: .
      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          java-version: '11'
          distribution: 'temurin'
      - name: Build and package
        run: mvn clean package

  docker_build_and_push:
    runs-on: ubuntu-latest
    needs: maven_build
    steps:
      - name: Download code artifact
        uses: actions/download-artifact@v3
        with:
          name: source-code
          path: .
      - name: Log in to DockerHub
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
      - name: Build and push Docker image
        run: |
          docker build -t javeriyasdocker/my-ultimate-cicd:${{ github.run_id }} .
          docker push javeriyasdocker/my-ultimate-cicd:${{ github.run_id }}

  deploy_to_eks:
    runs-on: ubuntu-latest
    needs: docker_build_and_push
    steps:
      - name: Download code artifact
        uses: actions/download-artifact@v3
        with:
          name: source-code
          path: .
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v3
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - name: Update kubeconfig
        run: aws eks update-kubeconfig --region us-east-1 --name spring-boot-cluster1
      - name: Update deployment.yml
        run: |
          sed -i "s/image: .*$/image: javeriyasdocker\/my-ultimate-cicd:${{ github.run_id }}/g" spring-boot-app-manifests/deployment.yml
      - name: Deploy to EKS
        run: |
          kubectl apply -f spring-boot-app-manifests/deployment.yml
          kubectl apply -f spring-boot-app-manifests/service.yml

  setup_argocd:
    runs-on: ubuntu-latest
    needs: deploy_to_eks 
    steps:
      - name: Install ArgoCD CLI
        run: |
          curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.13.1/argocd-linux-amd64 
          chmod +x /usr/local/bin/argocd
      - name: Create ArgoCD Application
        run: |
          argocd app create \
            --name my-spring-boot-app \
            --repo https://github.com/Javeriya00/spring-boot-app.git \
            --path spring-boot-app-manifests \ 
            --dest-server https://kubernetes.default.svc \
            --dest-namespace default \
            --source-revision HEAD 
```

## Best Practices
- **Use Caching**: Utilize caching to speed up dependency installations in Maven and Docker.
- **Secure Secrets**: Store sensitive data in GitHub Secrets.
- **Minimize Image Size**: Use multi-stage builds to reduce Docker image size.
- **Automate Everything**: Ensure every step is automated for smooth CI/CD.
- **GitOps with ArgoCD**: Maintain deployment configurations in Git for version control.

## Running Locally
1. Build the application:
   ```sh
   mvn clean package
   ```
2. Build and run the Docker container:
   ```sh
   docker build -t my-spring-boot-app .
   docker run -p 8080:8080 my-spring-boot-app
   ```
3. Deploy manually to Kubernetes:
   ```sh
   kubectl apply -f spring-boot-app-manifests/
   ```

This repository provides an automated workflow to build, containerize, and deploy Java Spring Boot applications to AWS EKS efficiently. 🚀

