# Feature Summary: CLI Tool for Pipeline Management

## Overview
We've implemented a robust command-line interface (CLI) tool for the Ozypy platform that allows users to manage pipelines directly from their terminal. This enhances developer experience by providing an alternative to the web interface for common pipeline management tasks.

## Components Implemented

### 1. CLI Tool (`scripts/ozypy_cli.py`)
- **Core functionality**: Complete command-line interface for ETL pipeline management
- **Commands implemented**:
  - Login/logout authentication
  - List all pipelines
  - View pipeline details
  - Create new pipelines (interactive wizard)
  - Run existing pipelines
  - Delete pipelines
- **Features**:
  - Rich terminal UI with tables and colors (when Rich library is available)
  - Fallback to plain text output when Rich is not available
  - Configuration management via `.etl_config.json` in user's home directory
  - Error handling and user-friendly messages

### 2. Backend API Endpoints (`backend/server.py`)
- **RESTful API endpoints** to support CLI operations:
  - GET `/api/pipelines` - List all pipelines
  - GET `/api/pipelines/{pipeline_id}` - Get pipeline details
  - POST `/api/pipelines` - Create a new pipeline
  - PUT `/api/pipelines/{pipeline_id}` - Update an existing pipeline
  - DELETE `/api/pipelines/{pipeline_id}` - Delete a pipeline
  - POST `/api/pipelines/{pipeline_id}/run` - Execute a pipeline
  - GET `/api/pipelines/{pipeline_id}/runs` - Get pipeline execution history
  - GET `/api/data-sources` - List available data sources
  - GET `/api/transforms` - List available transformations
- **Data models** for pipeline operations using Pydantic

### 3. Installation Scripts
- **Linux/macOS setup** (`scripts/setup_cli.sh`):
  - Installs dependencies
  - Makes CLI script executable
  - Adds to user's PATH for easy access
- **Windows setup** (`scripts/setup_cli.ps1`):
  - Installs dependencies
  - Creates batch wrapper
  - Adds to user's PATH

### 4. Testing
- Basic test script (`scripts/test_cli.py`) to verify functionality

## Usage Examples

```bash
# List all pipelines
ozypy pipelines

# View details of a specific pipeline
ozypy pipeline p001

# Create a new pipeline (interactive)
ozypy create

# Run a pipeline
ozypy run p001

# Delete a pipeline
ozypy delete p001
```

## Future Enhancements
1. Add pipeline export/import functionality
2. Implement pipeline templates
3. Add batch operation support
4. Add real-time monitoring of running pipelines
5. Support for pipeline scheduling from CLI 