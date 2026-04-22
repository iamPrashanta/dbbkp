# dbbkp Testing Guide

This guide provides steps to spin up local MySQL and PostgreSQL databases to fully test the **dbbkp** backup and restore functionalities.

> **Note:** You can run all of these tests directly on your local machine or use **WSL (Windows Subsystem for Linux)**. Make sure to follow the primary [README.md](./README.md) for the actual **dbbkp** installation guide before starting the testing process below.

## 1. Quick Start: Docker Databases (Recommended)

Using Docker is the fastest way to spin up isolated databases for testing without cluttering your host machine.

### Start MySQL and PostgreSQL Containers

Run these commands to start the containers, which will automatically create the required test users, passwords, and databases:

```bash
# Start MySQL Test Container
docker run --name dbbkp-mysql \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=testdb \
  -e MYSQL_USER=testuser \
  -e MYSQL_PASSWORD=testpass \
  -p 3306:3306 \
  -d mysql:8.0

# Start PostgreSQL Test Container
docker run --name dbbkp-postgres \
  -e POSTGRES_USER=testuser \
  -e POSTGRES_PASSWORD=testpass \
  -e POSTGRES_DB=testpg \
  -p 5432:5432 \
  -d postgres:15
```

### Seed the Databases with Test Data

**For MySQL:**
```bash
# Connect to the MySQL container
docker exec -it dbbkp-mysql mysql -u testuser -ptestpass testdb
```
```sql
-- Run this SQL to add test data:
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100)
);

INSERT INTO users (name,email) VALUES
('Prashanta','p@test.com'),
('John','j@test.com');

exit
```

**For PostgreSQL:**
```bash
# Connect to the PostgreSQL container
docker exec -it dbbkp-postgres psql -U testuser -d testpg
```
```sql
-- Run this SQL to add test data:
CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  name TEXT,
  email TEXT
);

INSERT INTO customers (name,email) VALUES
('Prashanta','p@test.com'),
('Maria','m@test.com');

\q
```

---

## 2. Test Your Script

You can now use `dbbkp` to take backups against these local Docker containers. Make sure you have the client tools installed on your host system (`mysql-client`, `postgresql-client`) so the script can communicate with the Docker database ports.

### MySQL Backup Testing

Run `dbbkp` and choose the MySQL Local Backup option:

* **host:** `127.0.0.1` (or `localhost`)
* **port:** `3306`
* **user:** `testuser`
* **pass:** `testpass`
* **db:** `testdb`

### PostgreSQL Backup Testing

Run `dbbkp` and choose the PostgreSQL Local Backup option:

* **host:** `127.0.0.1` (or `localhost`)
* **port:** `5432`
* **user:** `testuser`
* **pass:** `testpass`
* **db:** `testpg`

---

## 3. Alternative: Local Native Installation (Ubuntu)

If you prefer to install the database servers natively on your machine instead of using Docker, follow these steps:

### Install Services and Tools
```bash
sudo apt update

# Install Database Servers
sudo apt install mysql-server postgresql postgresql-contrib -y

# Install Database Clients and Transfer/Utility tools
sudo apt install mysql-client postgresql-client awscli rclone pv unzip zip curl rsync openssh-client -y

# Start Services
sudo systemctl enable --now mysql
sudo systemctl enable --now postgresql
```

### Create Test MySQL Database
```bash
sudo mysql
```
```sql
CREATE DATABASE testdb;
CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'testpass';
GRANT ALL PRIVILEGES ON testdb.* TO 'testuser'@'localhost';
FLUSH PRIVILEGES;

USE testdb;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100)
);

INSERT INTO users (name,email) VALUES ('Prashanta','p@test.com'), ('John','j@test.com');

exit
```

### Create Test PostgreSQL Database
```bash
sudo -u postgres psql
```
```sql
CREATE USER testuser WITH PASSWORD 'testpass';
CREATE DATABASE testpg OWNER testuser;

\c testpg

CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  name TEXT,
  email TEXT
);

INSERT INTO customers (name,email) VALUES ('Prashanta','p@test.com'), ('Maria','m@test.com');

\q
```

> **Note:** For PostgreSQL password authentication with `dbbkp` to work locally, edit `/etc/postgresql/*/main/pg_hba.conf`:
> Change `local all all peer` to `local all all md5` and restart PostgreSQL (`sudo systemctl restart postgresql`).

---

## 4. Clean Up (Docker)

When you're done testing, you can easily stop and remove the test databases containers:

```bash
docker stop dbbkp-mysql dbbkp-postgres
docker rm dbbkp-mysql dbbkp-postgres
```
