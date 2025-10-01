# Transport App

This is a Rails application for managing transport orders and calculating transport costs.

## Getting Started with Docker

Follow these steps to run the application using Docker:

1. **Clone the repository**

````bash
git clone https://github.com/TomaszOciepa/transport_app.git
cd transport_app

2. **Install Bootstrap and Sass**

```bash
yarn add --dev sass
yarn build:css

3. **Build and start Docker containers**

```bash
docker compose build
docker compose up


The Rails application will be available at http://localhost:3000
.
The PostgreSQL database runs on port 5432 inside the Docker network.
````
