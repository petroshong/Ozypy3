# Ozypy - Data Transformation Platform

A modern, full-stack data transformation platform with natural language capabilities and AI agent control.

## Features

### Data Source Connectors
- Generic adapters for various database systems:
  - PostgreSQL
  - MySQL  
  - MongoDB
  - Salesforce
  - Google Analytics

### Transformation Engine
- **Natural Language Transformations**: Define transformations using plain English
- **Code-based Transformations**: Write custom transformation logic in JavaScript/JSON
- **SQL Transformations**: Use SQL queries to transform data

### Output Connectors
- Multiple destination types:
  - Databases (PostgreSQL, MySQL, MongoDB)
  - Files (CSV, JSON)

### AI Agent Control
- Control your ETL pipelines using natural language commands
- Intuitive interface for managing pipelines through conversation
- Supports commands like:
  - Run pipelines
  - Check status
  - List pipelines
  - Pause operations

### Monitoring and Management
- Dashboard with key metrics
- Pipeline execution history
- Job status tracking

## Technology Stack

### Backend
- **Framework**: FastAPI (Python)
- **Database**: MongoDB for metadata storage
- **Data Processing**: Pandas for transformation operations
- **AI Integration**: OpenAI/x.ai for natural language processing

### Frontend
- **Framework**: React
- **Styling**: Tailwind CSS with custom component library
- **State Management**: React Hooks
- **Routing**: React Router

## Getting Started

### Prerequisites
- Node.js (v16+)
- Python (v3.9+)
- MongoDB

### Installation

1. Clone the repository
2. Install backend dependencies:
```
cd backend
pip install -r requirements.txt
```

3. Install frontend dependencies:
```
cd frontend
yarn install
```

4. Configure environment variables:
- Create a `.env` file in the backend directory with the following variables:
```
MONGO_URL=mongodb://localhost:27017
DB_NAME=etl_service
XAI_API_KEY=your_xai_api_key  # Or use OPENAI_API_KEY
```

5. Start the services:
```
# Start the backend
cd backend
uvicorn server:app --host 0.0.0.0 --port 8001

# Start the frontend
cd frontend
yarn start
```

## Usage

1. **Create a data source**: Connect to your existing databases or services
2. **Define transformations**: Create rules to transform your data (using NL, code, or SQL)
3. **Set up destinations**: Configure where your transformed data should be loaded
4. **Create pipelines**: Link sources, transformations, and destinations
5. **Schedule and run**: Set up automated schedules or run manually
6. **Use AI control**: Manage pipelines through the AI Agent interface

### Natural Language Transformations

The platform supports transforming data using natural language instructions. Simply:

1. Navigate to the Transformations page
2. Enter your transformation instructions in plain English (e.g., "Convert all names to uppercase and format dates as MM/DD/YYYY")
3. Click "Generate Transform" 
4. Review the generated JavaScript code and its explanation
5. Save or copy the transformation for use in your pipelines

### CLI Tool for Pipeline Management

The ETL service comes with a powerful command-line interface (CLI) tool for managing pipelines directly from your terminal:

#### Installation

**On Linux/macOS:**
```bash
# Run the setup script
./scripts/setup_cli.sh
```

**On Windows:**
```powershell
# Run the setup script in PowerShell
.\scripts\setup_cli.ps1
```

#### CLI Commands

```bash
# List all pipelines
etl pipelines

# View pipeline details
etl pipeline <pipeline-id>

# Create a new pipeline (interactive)
etl create

# Run a pipeline
etl run <pipeline-id>

# Delete a pipeline
etl delete <pipeline-id>

# Login/logout
etl login
etl logout
```

### Switching LLM Providers

The application supports multiple LLM providers for generating transformations:

1. Create a `.env` file in the root directory with the following content:
```
# LLM Provider Configuration
LLM_PROVIDER=GEMINI  # or OPENAI
GEMINI_API_KEY=your_gemini_api_key
OPENAI_API_KEY=your_openai_api_key

# Model configuration
GEMINI_MODEL=gemini-pro
OPENAI_MODEL=gpt-4
```

2. Restart the backend service for the changes to take effect

### Anomaly Detection

The ETL service includes intelligent anomaly detection capabilities to identify unusual patterns or outliers in your pipeline data:

#### Features

- **Multiple Detection Methods**: Combines results from several algorithms including Isolation Forest, Z-score, Local Outlier Factor, and DBSCAN clustering
- **Configurable Sensitivity**: Adjust sensitivity to control false positive/negative rates
- **Flexible Time Windows**: Analyze data over different time periods (hours, days, weeks)
- **Historical Analysis**: Store and query anomaly history for trend analysis
- **Detailed Context**: Each anomaly includes detailed context about why it was flagged

#### API Endpoints

```
POST /api/anomaly/detect         # Detect anomalies in pipeline data
GET  /api/anomaly/history        # Get anomaly detection history
GET  /api/anomaly/config         # Get current anomaly detection configuration
PUT  /api/anomaly/config         # Update anomaly detection configuration
POST /api/anomaly/save           # Save anomaly history to a file
POST /api/anomaly/load           # Load anomaly history from a file
```

#### Usage Example

```python
import requests
import json

# Example data from a pipeline
pipeline_data = [
    {"timestamp": "2023-05-01T10:00:00", "value": 100, "count": 5},
    {"timestamp": "2023-05-01T11:00:00", "value": 102, "count": 6},
    {"timestamp": "2023-05-01T12:00:00", "value": 98, "count": 4},
    {"timestamp": "2023-05-01T13:00:00", "value": 500, "count": 3},  # Anomaly
    {"timestamp": "2023-05-01T14:00:00", "value": 101, "count": 5},
]

# Detect anomalies
response = requests.post(
    "http://localhost:8001/api/anomaly/detect",
    json={
        "pipeline_id": "p001",
        "data": pipeline_data,
        "timestamp_column": "timestamp"
    }
)

anomalies = response.json()
print(f"Found {anomalies['anomaly_count']} anomalies")
```

## Testing and Error Handling

### Comprehensive Testing

The ETL service includes thorough test coverage for both frontend and backend components using:

#### Frontend Tests
- **Jest** and **React Testing Library** for component testing
- Snapshot tests for pure presentational components
- Unit tests for utility functions and hooks
- Integration tests for complex components

#### Backend Tests
- **pytest** for Python backend testing
- Mock-based tests for external integrations
- Unit tests for business logic
- API tests using FastAPI TestClient

#### Running Tests

**Linux/macOS:**
```bash
# Run all tests
./scripts/run_tests.sh

# Run with coverage reports
./scripts/run_tests.sh --coverage

# Run with verbose output
./scripts/run_tests.sh --verbose
```

**Windows:**
```powershell
# Run all tests
.\scripts\run_tests.ps1

# Run with coverage reports
.\scripts\run_tests.ps1 -Coverage

# Run with verbose output
.\scripts\run_tests.ps1 -Verbose
```

### Robust Error Handling

The application implements a comprehensive error handling strategy:

- **Error Boundaries**: React error boundaries catch rendering errors at component level
- **Typed API Wrappers**: All API calls use typed wrappers with Zod schema validation
- **Centralized Logging**: All errors funnel through a central logger for consistent handling
- **Production-Safe**: Console logs are automatically removed in production builds

Error boundaries are implemented at multiple levels:
1. **Global application boundary**: Catches critical errors affecting the entire app
2. **Route-level boundaries**: Isolates errors to specific routes/pages
3. **Component-level boundaries**: Protects critical UI components 

For developers, the withErrorBoundary HOC provides an easy way to wrap components:

```jsx
// Example usage
import withErrorBoundary from './components/withErrorBoundary';

const MyComponent = () => {
  // Component implementation
};

export default withErrorBoundary(MyComponent);
```

## Dependency Management with pnpm

This project uses pnpm for package management to ensure consistent dependencies and optimize disk space usage.

### Benefits of pnpm

- **Disk efficiency**: pnpm uses a content-addressable store to avoid duplication of packages
- **Strict mode**: Prevents phantom dependencies by only allowing access to packages explicitly declared in package.json
- **Workspace support**: Efficiently manages monorepo setups with shared dependencies
- **Speed**: Significantly faster than npm or yarn for installations
- **Consistency**: Produces deterministic node_modules structures across environments

### Installation

```bash
# Install pnpm globally
npm install -g pnpm
```

### Migration

If you're migrating from yarn/npm, run the provided migration script:

```bash
# On Linux/macOS:
./scripts/migrate-to-pnpm.sh

# On Windows:
.\migrate-to-pnpm.bat
```

### Basic Commands

```bash
# Install dependencies
pnpm install

# Add a dependency
pnpm add <package-name>

# Add a development dependency
pnpm add -D <package-name>

# Run scripts
pnpm run <script-name>

# Run development server
pnpm run dev
```

## Logging Infrastructure

The application implements a comprehensive logging system with the following features:

### Key Features

- **Production-safe**: Console logs are automatically removed in production builds
- **Centralized logging**: All logs go through a single logger utility
- **Log levels**: Support for debug, info, warn, and error levels with appropriate filtering
- **Context enrichment**: Logs are automatically enriched with metadata
- **Monitoring integration**: Logs are sent to monitoring services in production
- **Performance tracking**: Automatic tracking of performance metrics
- **Privacy-focused**: Sensitive data is never logged

### Usage

```jsx
import logger from './utils/logger';

// Basic logging
logger.debug('Debug message');
logger.info('Info message');
logger.warn('Warning message', { additionalContext: 'value' });
logger.error('Error message', { error });

// Component-specific logging
logger.component('MyComponent', 'Component initialized', { props });

// API request logging
logger.api('API request to /users', { method: 'GET', params });

// Performance monitoring
const endTimer = logger.time('Operation');
// ... perform operation ...
endTimer(); // Logs the time taken
```

### Monitoring Integration

The logging system integrates with external monitoring services for production environments. The monitoring service can be configured via environment variables:

```
REACT_APP_ENABLE_MONITORING=true
REACT_APP_MONITORING_ENDPOINT=https://your-monitoring-service.com/api
REACT_APP_MONITORING_API_KEY=your-api-key
REACT_APP_MONITORING_SAMPLE_RATE=0.1
```

The system supports:

- **Error tracking**: Automatic capture of JavaScript exceptions
- **Performance monitoring**: Core Web Vitals and custom performance metrics
- **Event tracking**: Custom event tracking for user interactions
- **Log aggregation**: Centralized collection of all application logs

## License

[MIT License](LICENSE)
