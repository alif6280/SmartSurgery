# 🏥 Smart Surgery Scheduling & Risk Analysis System

## Project Overview
This Java Web Application automates surgery scheduling by analyzing patient risk,
surgeon availability, and OT (Operation Theater) resources.

---

## 🛠️ Tech Stack
- **Backend**: Java Servlets + JSP
- **Database**: MySQL
- **Frontend**: HTML5, CSS3, JavaScript
- **Server**: Apache Tomcat 10
- **Build Tool**: Maven

---

## 📁 Project Structure
```
SmartSurgery/
├── src/
│   └── main/
│       ├── java/com/surgery/
│       │   ├── model/          ← Data classes (Patient, Surgeon, Surgery, OT)
│       │   ├── dao/            ← Database operations
│       │   ├── servlet/        ← HTTP request handlers
│       │   └── util/           ← DB connection, Risk Calculator
│       └── webapp/
│           ├── WEB-INF/        ← web.xml config
│           ├── css/            ← Stylesheets
│           ├── js/             ← JavaScript files
│           └── pages/          ← JSP pages
├── pom.xml                     ← Maven dependencies
└── README.md
```

---

## ⚙️ Setup Instructions (Step by Step)

### Step 1: Install Required Software
1. **Java JDK 17+** → https://adoptium.net
2. **Apache Tomcat 10** → https://tomcat.apache.org/download-10.cgi
3. **MySQL 8.0+** → https://dev.mysql.com/downloads/
4. **Maven 3.8+** → https://maven.apache.org/download.cgi
5. **IDE: IntelliJ IDEA** (recommended) → https://www.jetbrains.com/idea/

### Step 2: Database Setup
```sql
-- Run this in MySQL Workbench or terminal
source database_setup.sql
```

### Step 3: Configure DB Connection
Edit `src/main/java/com/surgery/util/DBConnection.java`:
```java
private static final String URL = "jdbc:mysql://localhost:3306/surgery_db";
private static final String USER = "your_mysql_username";
private static final String PASS = "your_mysql_password";
```

### Step 4: Build & Run
```bash
mvn clean package
# Copy target/SmartSurgery.war to Tomcat/webapps/
# Start Tomcat: ./bin/startup.sh (Linux/Mac) or startup.bat (Windows)
```

### Step 5: Access Application
Open browser → http://localhost:8080/SmartSurgery

---

## 👥 Default Login
| Role     | Username | Password  |
|----------|----------|-----------|
| Admin    | admin    | admin123  |
| Doctor   | doctor1  | doc123    |
| Nurse    | nurse1   | nurse123  |
