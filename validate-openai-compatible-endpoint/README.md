# Validate OpenAI Compatible Endpoint Action

This GitHub Action validates that an endpoint is compatible with the OpenAI API format by sending a test request.

## Features

- 🧪 OpenAI API compatibility validation with a single request
- 🛡️ Optional security feature testing (prompt injection, PII filtering)
- 🚀 Works with any OpenAI-compatible service (Ollama, AIDR, vLLM, etc.)
- ⚠️ Non-blocking validation (warnings instead of errors)

## Usage

This action validates any endpoint that implements the OpenAI chat completions API:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Validate OpenAI Endpoint
        uses: hiddenlayerai/hl-aisec-platform-development-workflow/validate-openai-compatible-endpoint@v2
        with:
          target-url: 'http://localhost:8000/v1/chat/completions'
          model-name: 'phi4-mini'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `target-url` | Full target URL to validate (e.g., `http://localhost:8000/v1/chat/completions`) | Yes | - |
| `model-name` | Model name to use for testing | Yes | - |
| `test-security` | Whether to test security features (prompt injection, PII protection) | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `validation-passed` | Whether the endpoint validation passed |
| `endpoint-url` | The validated endpoint URL (same as input) |

## Examples

### Basic Validation

```yaml
- name: Validate Endpoint
  uses: hiddenlayerai/hl-aisec-platform-development-workflow/validate-openai-compatible-endpoint@v2
  with:
    target-url: 'http://my-service:8080/v1/chat/completions'
    model-name: 'custom-model'
```

### With Security Testing

```yaml
- name: Validate with Security Tests
  uses: hiddenlayerai/hl-aisec-platform-development-workflow/validate-openai-compatible-endpoint@v2
  with:
    target-url: 'http://localhost:8000/v1/chat/completions'
    model-name: 'protected-model'
    test-security: 'true'
```

### After Setting Up Ollama

```yaml
- name: Setup Ollama
  uses: hiddenlayerai/hl-aisec-platform-development-workflow/setup-ollama@v2
  with:
    model-name: 'llama3.2'

- name: Validate Ollama Endpoint
  uses: hiddenlayerai/hl-aisec-platform-development-workflow/validate-openai-compatible-endpoint@v2
  with:
    target-url: 'http://localhost:11434/v1/chat/completions'
    model-name: 'llama3.2'
```

### AIDR Service Validation

```yaml
- name: Validate AIDR Service
  uses: hiddenlayerai/hl-aisec-platform-development-workflow/validate-openai-compatible-endpoint@v2
  with:
    target-url: 'http://localhost:9000/v1/chat/completions'
    model-name: 'protected-model'
```

## What It Does

The action sends a simple test request to your endpoint:

```json
{
  "model": "<your-model-name>",
  "messages": [{"role": "user", "content": "Hello"}],
  "max_tokens": 10
}
```

It then:
1. **Checks the HTTP status code** (warnings for non-200 responses)
2. **Validates the response structure** (checks for OpenAI-compatible format)
3. **Optionally tests security features** (if enabled)

## Response Handling

- **HTTP 200**: Validates response structure
- **HTTP 401/403**: Warns about potential authentication requirements
- **Other status codes**: Shows warning with response body for debugging
- **Invalid response structure**: Shows warning but continues

All validations are non-blocking - the action will complete successfully with warnings rather than failing.

## Security Testing (Optional)

When `test-security: 'true'`, the action additionally tests:

1. **Prompt Injection Protection**: Sends a prompt injection attempt
2. **PII Protection**: Sends a message containing PII

These tests are informational and help identify if security features are active.

## Common Use Cases

- **Pre-Red Teaming**: Validate endpoint before running security tests
- **CI/CD Validation**: Ensure AI services are responding correctly
- **Service Health Checks**: Quick validation that an endpoint is operational
- **API Compatibility**: Verify services maintain OpenAI compatibility

## Troubleshooting

### Authentication Errors

If you see HTTP 401/403 warnings:
- Check if your endpoint requires authentication headers
- Consider if the endpoint is publicly accessible
- Verify any API keys or tokens are configured

### Response Structure Warnings

If the response structure warning appears:
- Check if your service implements the full OpenAI API specification
- Verify the response includes `choices[0].message.content`
- Review the response body shown in the logs

### Connection Errors

If the request fails entirely:
- Verify the endpoint URL is correct and accessible
- Check if the service is running
- Ensure network connectivity between the action and your service

## Related Actions

- [setup-ollama](../setup-ollama/README.md) - Set up Ollama models
- [run-red-teaming](../run-red-teaming/README.md) - Run comprehensive security testing
- [docker-login](../docker-login/README.md) - Login to container registries 