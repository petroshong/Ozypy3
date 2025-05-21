# Ozypy Deployment Guide

This guide details the deployment processes for the Ozypy Data Transformation Platform.

## Environments

Ozypy uses the following deployment environments:

- **Development**: Local development environment
- **Staging**: Pre-production testing environment
- **Production**: Live customer-facing environment

## CI/CD Pipeline

Ozypy uses GitHub Actions for CI/CD. The pipeline includes:

1. **Lint**: Code quality checks and static analysis
2. **Test**: Runs automated tests
3. **Security Scan**: Security audit of dependencies
4. **Build**: Compiles and bundles the application
5. **Deploy**: Deploys to the appropriate environment based on branch

### Branch Strategy

- `develop` branch → Deploys to Staging
- `main` branch → Deploys to Production

## Deployment Process

### Prerequisites

- Node.js v18+
- pnpm package manager
- Access to deployment credentials

### Local Deployment

For local development and testing:

```bash
# Clone the repository
git clone https://github.com/your-org/ozypy.git
cd ozypy

# Install dependencies
pnpm install

# Start the development server
pnpm run dev
```

### Staging Deployment

Staging deployments are automatically triggered when changes are pushed to the `develop` branch. You can also manually deploy:

```bash
# Ensure you're on the develop branch
git checkout develop

# Build the application
pnpm run build

# Deploy to staging
# Example using Firebase (replace with your actual deployment command)
firebase deploy --only hosting:staging
```

### Production Deployment

Production deployments are automatically triggered when changes are pushed to the `main` branch. For manual deployments:

```bash
# Ensure you're on the main branch
git checkout main

# Build the application with production flags
pnpm run build

# Deploy to production
# Example using Firebase (replace with your actual deployment command)
firebase deploy --only hosting:production
```

## Environment Variables

The following environment variables need to be configured for each environment:

```
# Application settings
REACT_APP_VERSION=1.0.0
REACT_APP_API_BASE_URL=https://api.ozypy.com

# Monitoring
REACT_APP_ENABLE_MONITORING=true
REACT_APP_MONITORING_ENDPOINT=https://monitoring.ozypy.com/api/logs
REACT_APP_MONITORING_SAMPLE_RATE=0.1

# LLM Provider
REACT_APP_LLM_PROVIDER=GEMINI
REACT_APP_LLM_TEMPERATURE=0.7
REACT_APP_LLM_MAX_TOKENS=1000
```

For local development, these can be placed in a `.env.local` file.

## PWA Configuration

Ozypy supports Progressive Web App (PWA) features through service workers. The following commands control service worker behavior:

```bash
# Register service worker (production builds only)
serviceWorkerRegistration.register();

# Unregister service worker
serviceWorkerRegistration.unregister();
```

## Monitoring

Ozypy uses a built-in monitoring system that logs events to the configured monitoring endpoint. Monitoring is automatically enabled in production environments, but can be manually enabled in other environments by setting `REACT_APP_ENABLE_MONITORING=true`.

## Troubleshooting Deployments

### Common Issues

1. **Build fails with dependency errors**:
   - Run `pnpm audit` to check for dependency issues
   - Update dependencies with `pnpm update`

2. **Service worker caching issues**:
   - Unregister service workers in the browser's dev tools
   - Clear the application cache

3. **Environment variable issues**:
   - Ensure all required environment variables are set
   - Verify proper formatting in `.env` files

For additional help with deployments, contact the DevOps team. 