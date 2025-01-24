Here’s an updated README reflecting the change for the Jenkins pipeline in your `spring-boot-app-manifests/deployment.yml`:

---

# 🌟 Project Update: Continuous Integration and Deployment for a Spring Boot Application 🌟

🚀 I recently automated the CI/CD pipeline for my Spring Boot application using two different approaches:

## 1️⃣ Jenkins Pipeline
- Integrated a robust pipeline using Jenkins and successfully incorporated ArgoCD for continuous delivery. 
- This approach utilized Docker and Minikube for local Kubernetes deployments, showcasing a smooth workflow for managing containerized applications.
- **Note:** In the `spring-boot-app-manifests/deployment.yml`, the `image` tag is defined as `javeriyasdocker/my-ultimate-cicd:{{ github.run_id }}` for GitHub Actions. However, for the Jenkins pipeline, I used `replaceImageTag` instead of `{{ github.run_id }}` to dynamically tag the image.

## 2️⃣ GitHub Actions
- Implemented the same project on Amazon Elastic Kubernetes Service (EKS) with a CI/CD pipeline powered by GitHub Actions. 
- While I didn’t integrate ArgoCD here (still exploring that workflow), I successfully automated the build, containerization, and deployment processes to EKS.
  
👉 **Bonus:** This was implemented entirely within GitHub Codespaces, demonstrating how cloud-hosted development environments can streamline workflows.

---

# Spring Boot based Java web application

This is a simple Spring Boot based Java application that can be built using Maven. Spring Boot dependencies are handled using the `pom.xml` at the root directory of the repository.

This is an MVC architecture-based application where the controller returns a page with title and message attributes to the view.

## Execute the application locally and access it using your browser

Checkout the repo and move to the directory:

```
git clone https://github.com/Javeriya00/spring-boot-app
cd spring-boot-app
```

Execute the Maven targets to generate the artifacts:

```
mvn clean package
```

The above Maven target stores the artifacts in the `target` directory. You can either execute the artifact on your local machine or run it as a Docker container.

**Note:** To avoid issues with local setup, Java versions, and other dependencies, I would recommend the Docker approach.

### Execute locally (Java 11 needed) and access the application on `http://localhost:8080`

```
java -jar target/spring-boot-web.jar
```

### The Docker way

Build the Docker Image:

```
docker build -t ultimate-cicd-pipeline:v1 .
```

Run the Docker container:

```
docker run -d -p 8010:8080 -t ultimate-cicd-pipeline:v1
```

Hurray! Access the application on `http://<ip-address>:8010`

---

Let me know if you'd like any further changes!
