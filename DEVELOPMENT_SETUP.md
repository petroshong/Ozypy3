# Ozypy Development Setup Guide

This document provides a comprehensive guide for setting up your development environment for working on the Ozypy Data Transformation Platform.

## Prerequisites

- **Node.js**: Version 18 or higher
- **pnpm**: For package management
- **Git**: For version control
- **MongoDB**: For backend data storage
- **Python**: Version 3.9+ for backend services

## Initial Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-organization/ozypy.git
   cd ozypy
   ```

2. Install pnpm if you don't have it already:
   ```bash
   npm install -g pnpm
   ```

3. Install dependencies:
   ```bash
   pnpm install
   ```

4. Create local environment files:

   Create a `.env.local` file in the root directory with the following content:
   ```
   # API Configuration
   REACT_APP_API_BASE_URL=http://localhost:8001
   
   # Debug Configuration
   REACT_APP_ENABLE_DEBUG=true
   REACT_APP_ENABLE_MOCKS=true
   
   # LLM Provider Configuration
   REACT_APP_LLM_PROVIDER=GEMINI
   REACT_APP_GEMINI_API_KEY=your_gemini_api_key
   REACT_APP_GEMINI_MODEL=gemini-pro
   
   # Monitoring (disabled in dev)
   REACT_APP_ENABLE_MONITORING=false
   ```

   Create a `.env` file in the backend directory:
   ```
   MONGO_URL=mongodb://localhost:27017
   DB_NAME=ozypy_development
   GEMINI_API_KEY=your_gemini_api_key
   ```

## Starting the Development Environment

### Using the Development Scripts

For Windows:
```bash
# Open PowerShell and run
.\start-dev.ps1
```

For macOS/Linux:
```bash
# Make sure the script is executable
chmod +x ./start-dev.sh

# Run the script
./start-dev.sh
```

### Manual Startup

If you prefer to start services individually:

1. Start the backend server:
   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   uvicorn server:app --host 0.0.0.0 --port 8001 --reload
   ```

2. Start the frontend development server:
   ```bash
   cd frontend
   pnpm run dev
   ```

## Development Tools

### Code Quality Tools

- **ESLint**: Enforcing code standards
  ```bash
  pnpm run lint
  ```

- **TypeScript Type Checking**:
  ```bash
  pnpm run type-check
  ```

- **Prettier**: Formatting code
  ```bash
  pnpm run format
  ```

### Testing

- **Jest and React Testing Library**: Frontend tests
  ```bash
  pnpm run test
  ```

- **Test with Coverage Report**:
  ```bash
  pnpm run test:coverage
  ```

### Building for Production

```bash
pnpm run build
```

To analyze bundle size:
```bash
pnpm run build:analyze
```

## Debugging

### Frontend Debugging

1. Use React DevTools extension in your browser
2. Check browser console for errors and debug logs
3. Enable debug mode in the application:
   ```javascript
   localStorage.setItem('enableDebug', 'true');
   ```

### Backend Debugging

1. Set the logging level in the backend `.env` file:
   ```
   LOG_LEVEL=DEBUG
   ```

2. Use Python's `pdb` for debugging:
   ```python
   import pdb; pdb.set_trace()
   ```

## Working with LLM Providers

Ozypy supports multiple LLM providers. To switch between them:

1. Change the `REACT_APP_LLM_PROVIDER` in your `.env.local` file
2. Ensure you have the appropriate API key configured

See [LLM_CONFIGURATION.md](./LLM_CONFIGURATION.md) for more details.

## Recommended Editor Setup

### Visual Studio Code

Install the following extensions:
- ESLint
- Prettier
- Tailwind CSS IntelliSense
- Python
- MongoDB for VS Code

Configuration (`settings.json`):
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "javascript.updateImportsOnFileMove.enabled": "always",
  "typescript.updateImportsOnFileMove.enabled": "always"
}
```

## Contribution Guidelines

1. Create a new branch for your feature or bugfix
2. Follow the project's code style and conventions
3. Write unit tests for your code
4. Update documentation as needed
5. Submit a pull request to the `develop` branch

## Getting Help

If you encounter any issues during setup, please:
1. Check the project wiki for common solutions
2. Look for similar issues in the issue tracker
3. Ask for help in the project's communication channels

Happy developing! 