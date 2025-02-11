# Improving GitHub Actions Pipeline for EKS Deployment

## **Overview**
This document highlights improvements to optimize the current GitHub Actions workflow for deploying a Spring Boot application to Amazon EKS.

### **Key Areas of Improvement**
- **Caching Dependencies** (Maven & Docker) to speed up builds.
- **Using Helm for Kubernetes Deployments** instead of raw YAML files.
- **Enhancing reusability & modularity** in the CI/CD pipeline.

---

## **1. Using Caching to Speed Up GitHub Actions** 🚀
Caching can significantly reduce build times by reusing dependencies across workflow runs.

### **Where Can We Use Caching?**
1. **Maven Dependencies** - Prevents downloading dependencies on every run.
2. **Docker Layers** - Reuses previously built layers.
3. **Kubeconfig** - Caches Kubernetes credentials.

### **Caching Maven Dependencies**
Modify the **maven_build** job:

```yaml
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

      - name: Cache Maven Dependencies
        uses: actions/cache@v3
        with:
          path: ~/.m2/repository
          key: maven-${{ hashFiles('**/pom.xml') }}
          restore-keys: |
            maven-

      - name: Build and package
        run: mvn clean package
```
✅ **Benefit:** Faster Maven builds.

---

### **Caching Docker Layers**
Modify the **docker_build_and_push** job:

```yaml
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

      - name: Cache Docker Layers
        uses: actions/cache@v3
        with:
          path: /tmp/.buildx-cache
          key: docker-${{ github.run_id }}
          restore-keys: docker-

      - name: Build and push Docker image
        run: |
          docker build --cache-from=type=local,src=/tmp/.buildx-cache --cache-to=type=local,dest=/tmp/.buildx-cache -t javeriyasdocker/my-ultimate-cicd:${{ github.run_id }} .
          docker push javeriyasdocker/my-ultimate-cicd:${{ github.run_id }}
```
✅ **Benefit:** Reduces Docker build times.

---

## **2. Using Helm for Kubernetes Deployment** 🎯
Currently, raw Kubernetes YAML files are used (`kubectl apply -f`). Switching to **Helm** provides:
- **Parameterization of deployments** (e.g., dynamic image tags).
- **Rollback capabilities** if something fails.
- **Reusable deployment structure** across environments.

### **Steps to Use Helm in the Workflow**
1. **Create a Helm Chart**
   ```sh
   helm create spring-boot-app
   ```

2. **Modify `values.yaml` to Use Dynamic Image Tags**
   ```yaml
   image:
     repository: javeriyasdocker/my-ultimate-cicd
     tag: "latest"
   ```

3. **Modify GitHub Actions Workflow to Use Helm**

   ```yaml
   deploy_to_eks:
     runs-on: ubuntu-latest
     needs: docker_build_and_push
     steps:
       - name: Configure AWS credentials
         uses: aws-actions/configure-aws-credentials@v3
         with:
           aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
           aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
           aws-region: us-east-1

       - name: Update kubeconfig
         run: aws eks update-kubeconfig --region us-east-1 --name spring-boot-cluster1

       - name: Install Helm
         run: |
           curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

       - name: Deploy to EKS using Helm
         run: |
           helm upgrade --install spring-boot-app ./spring-boot-app \
             --set image.repository=javeriyasdocker/my-ultimate-cicd \
             --set image.tag=${{ github.run_id }} \
             --namespace default
   ```

✅ **Benefit:**
- No manual YAML edits required.
- Easier rollback (`helm rollback spring-boot-app 1`).
- More maintainable deployment process.

---

## **Final Optimized GitHub Actions Workflow**
This new workflow:
✅ **Uses caching to speed up builds**.  
✅ **Deploys using Helm instead of raw YAML**.  
✅ **Improves modularity & reusability**.  

---

## **Next Steps**
- When ready, implement the caching and Helm enhancements.
- Gradually transition Kubernetes YAML deployments to Helm.
- Test the optimizations on a feature branch before merging into `main`.

🚀 **These changes will improve efficiency and make CI/CD pipelines much faster and maintainable!**

