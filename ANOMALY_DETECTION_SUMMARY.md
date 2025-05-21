# Feature Summary: Anomaly Detection

## Overview
We've implemented a robust anomaly detection system that can identify unusual patterns or outliers in pipeline data. This enhances the Ozypy platform with intelligent monitoring capabilities, allowing users to detect issues early and maintain data quality.

## Components Implemented

### 1. Anomaly Detection Service (`backend/intelligent_features/anomaly_detection.py`)
- **Core functionality**: Comprehensive anomaly detection using multiple algorithms
- **Detection methods**:
  - Z-score analysis for basic statistical outliers
  - Isolation Forest for complex, non-linear anomalies
  - Local Outlier Factor for density-based anomaly detection
  - DBSCAN clustering for identifying outliers as points outside clusters
- **Features**:
  - Configurable sensitivity and time windows
  - Multi-column analysis with automatic identification of most anomalous fields
  - Historical tracking of anomalies with retention policies
  - Serialization support for persistence

### 2. Data Models
- **AnomalyDetectionConfig**: Configuration for the detection algorithms
  - Controls sensitivity, methods, time windows, etc.
  - Supports serialization to/from dictionaries
- **Anomaly**: Representation of detected anomalies
  - Stores details about the anomaly including pipeline, timestamp, method, etc.
  - Includes context about why the point was flagged as anomalous

### 3. Backend API Endpoints (`backend/server.py`)
- **RESTful API endpoints** for anomaly detection:
  - POST `/api/anomaly/detect` - Detect anomalies in provided data
  - GET `/api/anomaly/history` - Get anomaly detection history with filtering
  - GET `/api/anomaly/config` - Get current detection configuration
  - PUT `/api/anomaly/config` - Update detection configuration
  - POST `/api/anomaly/save` - Save anomaly history to a file
  - POST `/api/anomaly/load` - Load anomaly history from a file
- **Pydantic models** for request/response validation

## Technical Details

### Anomaly Detection Approaches

1. **Statistical (Z-score)**
   - Identifies values that deviate significantly from the mean
   - Assumes normally distributed data
   - Adjusts threshold based on sensitivity setting

2. **Machine Learning (Isolation Forest)**
   - Uses random forests to isolate outliers
   - Effective for high-dimensional data
   - Adjusts contamination parameter based on sensitivity

3. **Density-Based (Local Outlier Factor)**
   - Measures local deviation of density with respect to neighbors
   - Effective for varying density clusters
   - Handles local outliers well

4. **Clustering-Based (DBSCAN)**
   - Points that don't belong to any cluster are considered outliers
   - Distance to nearest cluster used as anomaly score
   - Adjusts epsilon parameter based on sensitivity

### Implementation Features

- **Flexible Data Handling**: Works with any structured data that includes a timestamp column
- **Automatic Feature Selection**: Focuses on the most anomalous columns in multivariate anomalies
- **Score Normalization**: Converts all anomaly scores to a 0-1 scale for consistency
- **Context Enrichment**: Provides detailed context about each anomaly for easier diagnosis
- **Configurable Time Windows**: Supports hour/day/week-based time windows for analysis
- **Error Handling**: Robust error handling with detailed logging

## Usage Examples

```python
# Initialize the service with custom configuration
config = AnomalyDetectionConfig(
    time_window="2d",            # Analyze data from the last 2 days
    sensitivity=0.9,             # High sensitivity (0.0-1.0)
    methods=["isolation_forest", "z_score"],  # Methods to use
    min_data_points=30,          # Minimum data points required
    max_anomalies_reported=5     # Max anomalies to report
)
service = AnomalyDetectionService(config)

# Detect anomalies in pipeline data
anomalies = service.detect_anomalies(
    data=df,                     # DataFrame with pipeline data
    pipeline_id="production-ozypy", # Pipeline identifier
    timestamp_column="event_time" # Column with timestamps
)

# Get historical anomalies
history = service.get_anomaly_history(
    pipeline_id="production-ozypy",
    start_time=datetime.now() - timedelta(days=7),
    min_score=0.8                # Only high-confidence anomalies
)

# Save/load history for persistence
service.save_anomaly_history("anomaly_history.json")
service.load_anomaly_history("anomaly_history.json")
```

## Future Enhancements
1. Add real-time anomaly detection for streaming data
2. Implement automated alerting based on detected anomalies
3. Enhance visualization with anomaly trends and patterns
4. Add anomaly classification (categorize types of anomalies)
5. Implement unsupervised learning for evolving anomaly detection 