# GitHub Actions Workflow for EKS Deployment

This repository contains a GitHub Actions workflow for deploying a Java Spring Boot application to an Amazon EKS cluster. The workflow is structured into multiple jobs, each performing a specific stage of the CI/CD pipeline.

## Workflow Breakdown

### 1. **Why Are We Using `actions/download-artifact` in Each Job?**
Each job in GitHub Actions runs in a **fresh runner (isolated virtual machine)**. Files generated in one job do **not automatically persist** for the next job. To share files across jobs, the workflow:
- **Uploads artifacts** (`actions/upload-artifact@v3`) at the end of one job.
- **Downloads artifacts** (`actions/download-artifact@v3`) at the beginning of the next job.

This ensures that the source code and build outputs are available across different jobs.

---

### 2. **Can We Avoid Downloading Artifacts in Every Job?**
Yes! If all steps were combined into a **single job**, they would share the same workspace, eliminating the need for uploading/downloading artifacts.

#### **Example: Single Job Workflow**
```yaml
jobs:
  deploy_pipeline:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          java-version: '11'
          distribution: 'temurin'

      - name: Build and package
        run: mvn clean package

      - name: Log in to DockerHub
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

      - name: Build and push Docker image
        run: |
          docker build -t javeriyasdocker/my-ultimate-cicd:${{ github.run_id }} .
          docker push javeriyasdocker/my-ultimate-cicd:${{ github.run_id }}

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
```
### **Benefits of a Single Job Approach:**
✔ **Faster execution** (no redundant artifact uploads/downloads)  
✔ **Easier debugging** (all logs in one place)  
✔ **Less complexity**

---

### 3. **Why Use Separate Jobs?**
If we keep the current multi-job structure, it provides several advantages:
- **Parallel execution**: Jobs like `maven_build` and `docker_build_and_push` can run **in parallel**, reducing pipeline execution time.
- **Better organization**: If a job fails, it's easier to debug.
- **Reusability**: You can reuse artifacts in different workflows.

### **Final Thoughts**
You can decide whether to use a **single job for simplicity** or **multiple jobs for parallel execution and better separation of concerns**. 🚀

