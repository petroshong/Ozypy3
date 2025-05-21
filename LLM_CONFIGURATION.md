# Ozypy LLM Configuration Guide

Ozypy uses Large Language Models (LLMs) to power its natural language transformation capabilities. This guide explains how to configure and switch between different LLM providers.

## Supported LLM Providers

Ozypy supports the following LLM providers:

- **Gemini** (Default): Google's Gemini models
- **OpenAI**: OpenAI's GPT models

## Configuration

LLM settings are configured through environment variables. These can be set in your `.env` file:

```
# LLM Provider Configuration
REACT_APP_LLM_PROVIDER=GEMINI  # or OPENAI
REACT_APP_LLM_TEMPERATURE=0.7
REACT_APP_LLM_MAX_TOKENS=1000
```

Additionally, you'll need to provide API keys for your chosen provider:

```
# For Gemini (default)
REACT_APP_GEMINI_API_KEY=your_gemini_api_key
REACT_APP_GEMINI_MODEL=gemini-pro

# For OpenAI
REACT_APP_OPENAI_API_KEY=your_openai_api_key
REACT_APP_OPENAI_MODEL=gpt-4
```

## Switching LLM Providers

Ozypy is designed to make switching between LLM providers simple. To change providers:

1. Update the `REACT_APP_LLM_PROVIDER` environment variable to your desired provider (GEMINI or OPENAI)
2. Ensure you have set the corresponding API key for that provider
3. Restart the application for the changes to take effect

## Implementation Details

Ozypy wraps LLM API calls in a provider-agnostic interface, allowing for easy switching between providers. The implementation can be found in:

- `frontend/src/utils/llm/provider.js` - Provider factory and interface
- `frontend/src/utils/llm/gemini.js` - Gemini implementation
- `frontend/src/utils/llm/openai.js` - OpenAI implementation

## Best Practices

- **API Key Security**: Never commit API keys to the repository. Use environment variables and proper security practices for managing secrets.
- **Rate Limiting**: Be aware of the rate limits for your chosen provider and implement appropriate retry logic.
- **Cost Management**: Monitor your usage to avoid unexpected costs.

## Troubleshooting

If you're experiencing issues with LLM integration:

1. Verify your API key is correct and has not expired
2. Check that the LLM provider is properly configured in your environment variables
3. Ensure you have internet connectivity to reach the LLM API
4. Review the application logs for any error messages from the LLM provider

For additional assistance, please contact the development team. 