# Rideau Canal Skateway Real-Time Monitoring System

## Project Title and Description

**Title:** Rideau Canal Skateway Real-Time Monitoring System  

This project simulates IoT sensors on the Rideau Canal and builds a full cloud pipeline.  
It sends fake ice and weather data to Azure, processes it in real time, and shows the results on a live web dashboard.

---

## Student Information

- Name: Obaida Kandakji
- Student ID: 041272028
- Sensor simulation repo: https://github.com/ObaidaKandakji/rideau-canal-sensor-simulation 
- Web dashboard repo: https://github.com/ObaidaKandakji/rideau-canal-dashboard

---

## Scenario Overview

### Problem Statement

The Rideau Canal Skateway needs to be monitored so that people only skate when it is safe.  
Manually checking ice thickness and weather conditions is slow and not real-time.

### System Objectives

- Simulate IoT sensors at:
  - Dow’s Lake  
  - Fifth Avenue  
  - NAC  
- Stream sensor data to Azure IoT Hub every 10 seconds  
- Use Azure Stream Analytics to:
  - Aggregate over 5-minute tumbling windows  
  - Calculate averages, min/max values, and safety status  
- Store processed data in Cosmos DB for fast queries  
- Archive data in Blob Storage for history  
- Show live status and charts on a web dashboard hosted in Azure App Service  

---

## System Architecture

### Architecture Diagram

The architecture diagram is stored in:

- `architecture/architecture-diagram.png`

It shows the full pipeline from the sensor simulator to the dashboard.

### Data Flow

1. **Sensor Simulator (Python)**  
   - Sends JSON telemetry (ice thickness, temps, snow) every 10 seconds  
   - One device per location  

2. **Azure IoT Hub**  
   - Receives device-to-cloud messages from the three devices  

3. **Azure Stream Analytics (rideau-canal-sa-job)**  
   - Input: IoT Hub  
   - Window: 5-minute tumbling windows  
   - Output 1: Cosmos DB (`RideauCanalDB` / `SensorAggregations`)  
   - Output 2: Blob Storage (`historical-data` container)  

4. **Azure Cosmos DB**  
   - Stores aggregated documents per window and per location  
   - Used by the web dashboard APIs  

5. **Azure Blob Storage**  
   - Archives the same aggregated records as line-separated JSON files  

6. **Web Dashboard (Node.js on Azure App Service)**  
   - Calls the APIs to read Cosmos DB  
   - Shows cards, safety badges, and charts  

### Azure Services Used

- Azure IoT Hub  
- Azure Stream Analytics  
- Azure Cosmos DB (NoSQL, Core/SQL API)  
- Azure Storage Account (Blob container `historical-data`)  
- Azure App Service (Node.js Web App)  

---

## Implementation Overview

### IoT Sensor Simulation (Python)

- Repository: https://github.com/ObaidaKandakji/rideau-canal-sensor-simulation 
- Simulates three devices: `dows-lake-device`, `fifth-avenue-device`, `nac-device`  
- Sends JSON messages every 10 seconds to IoT Hub  
- Uses `azure-iot-device` and environment variables in `.env`  

### Azure IoT Hub Configuration

- IoT Hub name: `CST8916Final`  
- Three devices registered (one per location)  
- Device connection strings are used in the simulator `.env` file  

### Stream Analytics Job

- Job name: `rideau-canal-sa-job`  
- Input: IoT Hub (`CST8916Final`)  
- Outputs:
  - Cosmos DB: `RideauCanalDB` / `SensorAggregations`
  - Blob Storage: `historical-data` container  
- Query is stored in:

  - `stream-analytics/query.sql`

- It:
  - Groups by location with a 5-minute tumbling window  
  - Calculates averages and min/max values  
  - Counts readings  
  - Computes `safetyStatus` (Safe / Caution / Unsafe)  
  - Writes the same record to both Cosmos and Blob  

### Cosmos DB Setup

- Account: `rideau-canal-cosmos-db`  
- Database: `RideauCanalDB`  
- Container: `SensorAggregations`  
- Partition key: `/location`  
- Document id pattern: `{location}-{windowEnd}`  

### Blob Storage Configuration

- Storage account: `rideaucanalstorageblob`  
- Blob container: `historical-data`  
- Path pattern from Stream Analytics: `aggregations/{date}/{time}`  
- Stores line-separated JSON aggregations  

### Web Dashboard (Node.js)

- Repository: https://github.com/ObaidaKandakji/rideau-canal-dashboard
- Backend: `server.js` (Express + `@azure/cosmos`)  
- Frontend: `public/index.html`, `public/styles.css`, `public/app.js`  
- Features:
  - Location cards for Dow’s Lake, Fifth Avenue, NAC  
  - Safety badges per location and overall canal status  
  - Last-hour charts using Chart.js  
  - Auto-refresh every 30 seconds  

### Azure App Service Deployment

- Web App name: CST8916Final  
- Runtime stack: Node.js  
- Connected to GitHub repo for automatic deployments  
- App settings include:
  - `COSMOS_ENDPOINT`
  - `COSMOS_KEY`
  - `COSMOS_DATABASE`
  - `COSMOS_CONTAINER`

---

## Repository Links

- Sensor simulation repo: https://github.com/ObaidaKandakji/rideau-canal-sensor-simulation 
- Web dashboard repo: https://github.com/ObaidaKandakji/rideau-canal-dashboard 
- Live dashboard URL: https://cst8916final-f9d7akcqbebqbcam.canadacentral-01.azurewebsites.net/ 

---

## Video Demonstration

- Video link: https://youtu.be/nwy0x4Udghk

The video shows:

- The architecture  
- The simulator running  
- IoT Hub, Stream Analytics, Cosmos DB, and Blob Storage in the portal  
- The live dashboard  
- A quick code walkthrough  

---

## Setup Instructions

### Prerequisites

- Azure subscription (student subscription is fine)  
- Python 3.x installed  
- Node.js installed  
- Git installed  

### High-Level Setup Steps

1. **Clone all three repositories**
   - Main documentation: https://github.com/ObaidaKandakji/cst8916-final-project
   - Sensor simulation: https://github.com/ObaidaKandakji/rideau-canal-sensor-simulation
   - Web dashboard: https://github.com/ObaidaKandakji/rideau-canal-dashboard

2. **Set up Azure resources**
   - Create IoT Hub and register three devices  
   - Create Cosmos DB account, database, and container  
   - Create Storage Account and `historical-data` container  
   - Create Stream Analytics job with IoT Hub input and both outputs  

3. **Configure Stream Analytics query**
   - Use the query from `stream-analytics/query.sql`  
   - Start the job  

4. **Configure and run the sensor simulator**
   - Add `.env` with three device connection strings  
   - Run `python sensor_simulator.py`  

5. **Run and deploy the web dashboard**
   - Set Cosmos env vars locally  
   - Run `npm install` and `npm start` for local testing  
   - Deploy to Azure App Service and set the same env vars there  

For more detailed steps, see the README files in each component repo.

---

## Results and Analysis

### Sample Outputs and Screenshots

Screenshots are stored in the `screenshots/` folder, such as:

- `01-iot-hub-devices.png` – IoT Hub devices  
- `02-iot-hub-metrics.png` – IoT Hub metric showing messages  
- `03-stream-analytics-query.png` – SA query configuration  
- `04-stream-analytics-running.png` – SA job running  
- `05-cosmos-db-data.png` – Aggregated data in Cosmos DB  
- `06-blob-storage-files.png` – Archived JSON in Blob Storage  
- `07-dashboard-local.png` – Dashboard running locally  
- `08-dashboard-azure.png` – Dashboard running on Azure App Service  

### Data Analysis

- Each 5-minute window has around 30 readings (5 min × 60 / 10 seconds).  
- Safety status changes based on:
  - Ice thickness and surface temperature averages  
- You can see when conditions move from Safe to Caution or Unsafe by watching the dashboard and Cosmos documents.

### System Performance Observations

- The simulator sending every 10 seconds is fast enough for near real-time monitoring.  
- The 5-minute tumbling windows smooth out noise but still react fairly quickly.  
- Cosmos DB queries for latest and history are very fast for this size of data.  

---

## Challenges and Solutions

### 1. Matching field names between services

**Challenge:** The field names coming from Stream Analytics had to match what the dashboard code expected.  
**Solution:** Standardized field names like `windowEnd`, `avgIceThickness`, and `safetyStatus` in both the query and the Node.js code.


---

### AI Tools Disclosure
- Chatgpt used to write and format readme for the repos. Used to help bugfix broken query and python code.

---

### Libraries Used

#### Python sensor simulator

- azure-iot-device – Azure IoT Device SDK for sending messages to IoT Hub

- python-dotenv – load environment variables from a .env file

- Python standard library modules:

- os, time, json, random, datetime

#### Node.js web dashboard (backend)

- express – HTTP server and routing

- @azure/cosmos – SDK for talking to Azure Cosmos DB

- cors – enable CORS for the API

- dotenv – load environment variables in Node

- path – Node core module for file paths

#### Frontend

- Chart.js – charting library loaded from a CDN

- Browser built-ins:

- fetch API, vanilla JS, HTML, CSS