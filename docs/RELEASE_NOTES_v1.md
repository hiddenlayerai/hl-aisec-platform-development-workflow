# Release Notes - v1

## 🎉 Major Features

### Custom Service Support for Red Teaming
- **Docker-based Testing**: Test any containerized AI service without requiring Ollama
- **Private Registry Support**: Authenticate and pull images from private Docker registries
- **Flexible Configuration**: Different environment variables for basic vs AIDR-protected testing
- **Health Check Support**: Configure custom health check commands for service readiness
- **Secret Management**: Secure handling of API keys and credentials through dedicated secret parameters

### Enhanced AIDR Integration
- **Configurable AIDR Port**: Run AIDR on custom ports (default: 8000) to avoid conflicts
- **OpenAI API Support**: Use OpenAI models (GPT-3.5, GPT-4) as backend with AIDR protection
- **Improved Secret Handling**: Separate secrets for backend services vs AIDR service itself
- **Custom Target URLs**: Override automatic URL determination for specific endpoints

### Improved Developer Experience
- **Docker Log Capture**: Automatic container log collection for debugging
- **Simplified Endpoint Validation**: Streamlined OpenAI compatibility checks
- **Better Error Messages**: Enhanced logging and error reporting
- **Configurable Network Mode**: Choose between "bridge" (secure, default) or "host" (legacy) networking

### Enhanced AI Model Detection with hl-scai
- **NEW**: Integrated `hiddenlayerai/hl-scai` action for comprehensive AI model detection
- Detects models from all major AI providers (OpenAI, Anthropic, Google, HuggingFace, etc.)
- Provides rich metadata including model versions, licenses, and usage patterns
- Outputs detailed AI asset inventory in JSON format

### Improved Model Scanner Workflow
- **ENHANCED**: The `model-scanner.yml` workflow now includes:
  - Automatic extraction and scanning of HuggingFace models referenced in code
  - Sequential matrix execution to avoid rate limits
  - Better error handling and debug output
  - Support for models without organization prefixes (e.g., "gpt2")

### Testing Infrastructure
- **NEW**: Added comprehensive test workflow (`test-model-scanner.yml`)
- Permanent test files in `test/ai_models/` for consistent validation
- Works with or without HiddenLayer platform credentials
- Validates both AI detection and HuggingFace model extraction

### Custom Service Support for Red Teaming
- **Docker-based Testing**: Test any containerized AI service without requiring Ollama
- **Private Registry Support**: Authenticate and pull images from private Docker registries
- **Flexible Configuration**: Different environment variables for basic vs AIDR-protected testing
- **Health Check Support**: Configure custom health check commands for service readiness
- **Secret Management**: Secure handling of API keys and credentials through dedicated secret parameters

### Enhanced AIDR Integration
- **Configurable AIDR Port**: Run AIDR on custom ports (default: 8000) to avoid conflicts
- **OpenAI API Support**: Use OpenAI models (GPT-3.5, GPT-4) as backend with AIDR protection
- **Improved Secret Handling**: Separate secrets for backend services vs AIDR service itself
- **Custom Target URLs**: Override automatic URL determination for specific endpoints

### Improved Developer Experience
- **Docker Log Capture**: Automatic container log collection for debugging
- **Simplified Endpoint Validation**: Streamlined OpenAI compatibility checks
- **Better Error Messages**: Enhanced logging and error reporting
- **Configurable Network Mode**: Choose between "bridge" (secure, default) or "host" (legacy) networking

## 🔄 Breaking Changes
None - All changes are backward compatible.

## 🐛 Bug Fixes
- Fixed arithmetic expression error in workflow matrix jobs
- Improved HuggingFace model extraction to handle various naming formats
- Better handling of missing credentials in test scenarios

## 📚 Documentation

- [Custom Service Guide](CUSTOM_SERVICE_GUIDE.md) - Comprehensive guide for testing custom services
- [External Usage Guide](EXTERNAL_USAGE_GUIDE.md) - Updated setup instructions
- [Example Workflows](.github/workflows/example-*.yml) - Real-world configuration examples

## 🔧 Technical Details

### New Outputs
The `extract-models` job now provides additional outputs:
- `ai-assets-summary`: Summary of all detected AI models
- `models-found-count`: Total count of AI models found
- `ai-assets`: JSON string of detected AI assets

### Dependencies
- Requires `hiddenlayerai/hl-scai@main` action
- All other action references use `@v1` tags

### Default Versions
- Model Scanner: `25.5.1`
- All workflow references: `@v1`

## 📋 Migration Guide

No migration required. The changes are additive and maintain backward compatibility.

### Optional: Using the New Features
To benefit from the enhanced AI detection:
1. The workflow will automatically use `hl-scai` for model detection
2. New outputs are available but optional to use
3. Test files are included for validation purposes

## 🧪 Testing
Run the test workflow to validate the setup:
```yaml
name: Test Model Scanner
on: workflow_dispatch

jobs:
  test:
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/test-model-scanner.yml@v1
    with:
      quay-username: ${{ vars.QUAY_USERNAME }}
    secrets:
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_MODELSCANNER: ${{ secrets.HL_LICENSE_MODELSCANNER }}
```

## 🚀 Getting Started
See the [README](README.md) and [External Usage Guide](EXTERNAL_USAGE_GUIDE.md) for complete setup instructions. 