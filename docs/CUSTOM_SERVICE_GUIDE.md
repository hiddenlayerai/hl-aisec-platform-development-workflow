# Custom Service Support for Automated Red Teaming

This guide explains how to use custom services with the HiddenLayer Automated Red Teaming actions and workflows, allowing you to test your own applications without using Ollama.

## Overview

The automated red teaming workflow now supports running custom Docker services as targets for testing. This is useful when you want to test:
- Your own AI/ML applications
- Custom API endpoints
- Third-party services running in containers
- Applications that don't use the OpenAI-compatible API format

## Configuration

### Basic Usage

To use a custom service, you need to provide at minimum:
- `service-docker-image`: The Docker image of your service
- `service-port`: The port your service will listen on

### Full Configuration Options

```yaml
- uses: ./.github/workflows/automated-red-teaming.yml
  with:
    # ... other inputs ...
    
    # Custom Service Configuration
    service-docker-image: "myorg/myservice:latest"
    service-port: "8080"
    service-health-command: "curl -f http://localhost:8080/health || exit 1"
    service-env-vars: |
      API_KEY=your-api-key
      LOG_LEVEL=debug
      DATABASE_URL=postgresql://localhost:5432/mydb
    
    # AIDR Configuration (when using AIDR protection)
    aidr-env-vars: |
      HL_LLM_BLOCK_JAILBREAK=true
      HL_LLM_BLOCK_HARMFUL_CONTENT=true
      HL_LLM_CUSTOM_RULES_PATH=/rules/custom.yaml
      HL_LLM_LOG_LEVEL=debug
```

### Input Parameters

- **`network-mode`** (optional): Docker network mode for containers
  - Options: `"bridge"` (default, recommended) or `"host"` (legacy)
  - Bridge mode provides secure container isolation
  - Host mode provides backward compatibility but less security
  - Example: `network-mode: "bridge"`

- **`service-docker-image`** (optional): Docker image for your custom service
  - Example: `mycompany/ai-service:v1.0`
  - Can be from any registry accessible to the runner

- **`service-port`** (optional): Port to expose for the custom service
  - Example: `8080`
  - This port will be mapped to the same port on the host

- **`service-health-command`** (optional): Command to check if service is healthy
  - Example: `curl -f http://localhost:8080/health || exit 1`
  - The workflow will retry this command up to 30 times with 2-second intervals
  - If not provided, the workflow will wait 5 seconds after starting the container

- **`service-env-vars`** (optional): Environment variables for the service
  - Format: One `KEY=VALUE` pair per line
  - Used when running basic red teaming (without AIDR)
  - Also used as fallback for AIDR mode if `service-env-vars-aidr` is not specified
  - Example:
    ```yaml
    service-env-vars: |
      API_KEY=secret123
      DEBUG=true
      PORT=8080
    ```

- **`service-env-vars-aidr`** (optional): Environment variables for the service when running with AIDR
  - Format: One `KEY=VALUE` pair per line
  - Only used when `enable-red-teaming-with-aidr` is true
  - If not specified, falls back to `service-env-vars`
  - Useful for different configurations when service is behind AIDR proxy
  - Example:
    ```yaml
    service-env-vars-aidr: |
      API_KEY=secret456  # Different key for AIDR mode
      DEBUG=false        # Disable debug in AIDR mode
      PORT=8080
      PROXY_MODE=true    # Custom flag for proxy detection
    ```

- **`aidr-env-vars`** (optional): Additional environment variables for AIDR service
  - Format: One `KEY=VALUE` pair per line
  - Only applies when `enable-red-teaming-with-aidr` is true
  - Allows customizing AIDR behavior beyond default settings
  - Example:
    ```yaml
    aidr-env-vars: |
      HL_LLM_BLOCK_JAILBREAK=true
      HL_LLM_BLOCK_HARMFUL_CONTENT=true
      HL_LLM_MAX_REQUEST_SIZE=10000
      HL_LLM_TIMEOUT=60
      HL_LLM_CUSTOM_BLOCK_MESSAGE=Access denied by security policy
    ```

- **`target-url`** (optional): Override the target URL for red teaming
  - Overrides the automatic URL determination
  - Useful when your service has a specific API endpoint path
  - Applies to both basic and AIDR-protected red teaming
  - Example: `http://localhost:8080/api/v1/chat`
  - If not specified:
    - Basic mode: Uses `http://localhost:<service-port>` or model endpoint
    - AIDR mode: Uses `http://localhost:8000/v1/chat/completions` (AIDR proxy)

- **`service-registry`** (optional): Docker registry URL for private images
  - Required only if your custom service image is in a private registry
  - Examples: `docker.io`, `ghcr.io`, `mycompany.azurecr.io`
  - If not specified, assumes the image is public

- **`service-registry-username`** (optional): Username for Docker registry authentication
  - Required only if `service-registry` is specified
  - Example: `myusername` or `_json_key` (for GCR)

- **`SERVICE_REGISTRY_TOKEN`** (secret): Password or token for Docker registry authentication
  - Required only if `service-registry` is specified
  - Pass via the `secrets` section, not inputs
  - Examples: Docker Hub password, GitHub PAT, Azure registry password

- **`aidr-port`** (optional): Port to run AIDR service on
  - Default: `8000`
  - Use when port 8000 is already in use or you need a specific port
  - Only affects AIDR-protected red teaming mode
  - Example: `8080`, `9000`

## Examples

### Example 1: Testing a Custom FastAPI Service

```yaml
name: Red Team Custom API

on:
  push:
    branches: [main]

jobs:
  red-team:
    uses: ./.github/workflows/automated-red-teaming.yml
    with:
      # Model configuration
      model-name: "custom-api"
      model-provider: "custom"
      
      # Network configuration
      network-mode: "bridge"  # Default (secure), or "host" for legacy
      
      # Custom service configuration
      service-docker-image: "myorg/fastapi-llm:latest"
      service-port: "8000"
      service-health-command: "curl -f http://localhost:8000/health || exit 1"
      service-env-vars: |
        MODEL_PATH=/models/llama2
        MAX_TOKENS=2048
      
      # Red teaming configuration
      enable-basic-red-teaming: true
      attack-tags: "llm-attacks,prompt-injection"
      
      # HiddenLayer configuration
      hiddenlayer-client-id: ${{ vars.HL_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
    secrets:
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HL_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_AUTOMATED_RED_TEAMING: ${{ secrets.HL_LICENSE_ART }}
```

### Example 2: Testing with Custom Service + AIDR Protection

```yaml
name: Red Team with AIDR

jobs:
  red-team:
    uses: ./.github/workflows/automated-red-teaming.yml
    with:
      # Model configuration
      model-name: "protected-api"
      
      # Custom service configuration
      service-docker-image: "myorg/ai-chatbot:v2"
      service-port: "3000"
      service-health-command: "wget -q --spider http://localhost:3000/api/health || exit 1"
      
      # AIDR custom configuration
      aidr-env-vars: |
        # Enhanced security settings
        HL_LLM_BLOCK_JAILBREAK=true
        HL_LLM_BLOCK_HARMFUL_CONTENT=true
        HL_LLM_BLOCK_PROMPT_INJECTION=true
        
        # Custom thresholds
        HL_LLM_CONFIDENCE_THRESHOLD=0.7
        HL_LLM_MAX_REQUEST_SIZE=5000
        
        # Custom messaging
        HL_LLM_BLOCK_MESSAGE=Your request has been blocked for security reasons.
        HL_LLM_INCLUDE_BLOCK_MESSAGE_REASONS=true
        
        # Performance tuning
        HL_LLM_CACHE_ENABLED=true
        HL_LLM_CACHE_TTL=300
      
      # Enable both basic and AIDR-protected testing
      enable-basic-red-teaming: true
      enable-red-teaming-with-aidr: true
      
      # Other required inputs...
```

### Example 3: Different Configurations for Basic vs AIDR Mode

```yaml
name: Test with Different Configs

jobs:
  red-team:
    uses: ./.github/workflows/automated-red-teaming.yml
    with:
      # Model configuration
      model-name: "adaptive-model"
      
      # Custom service configuration
      service-docker-image: "myorg/adaptive-ai:latest"
      service-port: "8080"
      service-health-command: "curl -f http://localhost:8080/health || exit 1"
      
      # Basic mode configuration (more verbose, debug enabled)
      service-env-vars: |
        LOG_LEVEL=debug
        DEBUG_MODE=true
        RATE_LIMIT=1000
        TIMEOUT=60
        TELEMETRY_ENABLED=true
        VERBOSE_ERRORS=true
      
      # AIDR mode configuration (production-like, security hardened)
      service-env-vars-aidr: |
        LOG_LEVEL=warn
        DEBUG_MODE=false
        RATE_LIMIT=100
        TIMEOUT=30
        TELEMETRY_ENABLED=false
        VERBOSE_ERRORS=false
        PROXY_AWARE=true
        SECURITY_MODE=strict
      
      # AIDR configuration
      aidr-env-vars: |
        HL_LLM_BLOCK_JAILBREAK=true
        HL_LLM_BLOCK_HARMFUL_CONTENT=true
        HL_LLM_LOG_LEVEL=info
      
      # Enable both test modes
      enable-basic-red-teaming: true
      enable-red-teaming-with-aidr: true
      
      # HiddenLayer configuration
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
      
    secrets:
      # Required secrets
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_AUTOMATED_RED_TEAMING: ${{ secrets.HL_LICENSE_AUTOMATED_RED_TEAMING }}
      HL_LICENSE_AIDR: ${{ secrets.HL_LICENSE_AIDR }}
      
      # Service secrets (different API keys for basic vs AIDR modes)
      SERVICE_ENV_SECRETS: |
        {
          "API_KEY": "${{ inputs.enable-basic-red-teaming && secrets.DEV_API_KEY || secrets.PROD_API_KEY }}",
          "API_SECRET": "${{ inputs.enable-basic-red-teaming && secrets.DEV_API_SECRET || secrets.PROD_API_SECRET }}"
        }
```

### Example 4: Using Custom Target URL

```yaml
name: Red Team with Custom Endpoint

jobs:
  red-team:
    uses: ./.github/workflows/automated-red-teaming.yml
    with:
      # Model configuration
      model-name: "custom-api"
      
      # Custom service configuration
      service-docker-image: "myorg/ai-api:latest"
      service-port: "8080"
      service-health-command: "curl -f http://localhost:8080/health || exit 1"
      
      # Override the target URL to point to specific endpoint
      target-url: "http://localhost:8080/api/v1/chat/completions"
      
      # This URL will be used for both basic and AIDR testing
      # instead of the defaults:
      # - Basic: http://localhost:8080
      # - AIDR: http://localhost:8000/v1/chat/completions
      
      enable-basic-red-teaming: true
      enable-red-teaming-with-aidr: true
      
      # ... other required inputs ...
```

### Example 5: Using Private Docker Registry

```yaml
name: Test Private Service

jobs:
  red-team:
    uses: ./.github/workflows/automated-red-teaming.yml
    with:
      # Model configuration
      model-name: "private-api"
      
      # Private registry service configuration
      service-docker-image: "mycompany.azurecr.io/ai-service:v1.2.3"
      service-port: "8080"
      service-health-command: "curl -f http://localhost:8080/health || exit 1"
      
      # Registry authentication
      service-registry: "mycompany.azurecr.io"
      service-registry-username: "myserviceprincipal"
      
      # Service configuration
      service-env-vars: |
        LOG_LEVEL=info
        PORT=8080
      
      # Red teaming configuration
      enable-basic-red-teaming: true
      enable-red-teaming-with-aidr: true
      
      # HiddenLayer configuration
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
      
    secrets:
      # Required secrets
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_AUTOMATED_RED_TEAMING: ${{ secrets.HL_LICENSE_AUTOMATED_RED_TEAMING }}
      HL_LICENSE_AIDR: ${{ secrets.HL_LICENSE_AIDR }}
      
      # Registry authentication secret
      SERVICE_REGISTRY_TOKEN: ${{ secrets.AZURE_REGISTRY_PASSWORD }}
      
      # Service secrets
      SERVICE_ENV_SECRETS: |
        {
          "API_KEY": "${{ secrets.API_KEY }}",
          "DB_PASSWORD": "${{ secrets.DB_PASSWORD }}"
        }
```

### Example 6: Using GitHub Container Registry (ghcr.io)

```yaml
name: Test GHCR Service

jobs:
  red-team:
    uses: ./.github/workflows/automated-red-teaming.yml
    with:
      # Private image from GitHub Container Registry
      service-docker-image: "ghcr.io/myorg/private-ai-service:latest"
      service-port: "3000"
      
      # GitHub Container Registry authentication
      service-registry: "ghcr.io"
      service-registry-username: ${{ github.actor }}
      
      # ... other configuration ...
      
    secrets:
      # GitHub token for registry authentication
      SERVICE_REGISTRY_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      # ... other secrets ...
```

### Example 7: Using Custom AIDR Port

```yaml
name: Test with Custom AIDR Port

jobs:
  red-team:
    uses: ./.github/workflows/automated-red-teaming.yml
    with:
      # Model configuration
      model-name: "custom-model"
      
      # Custom service configuration
      service-docker-image: "myorg/ai-service:latest"
      service-port: "8080"
      
      # Use port 9000 for AIDR instead of default 8000
      aidr-port: "9000"
      
      # AIDR configuration
      aidr-env-vars: |
        HL_LLM_BLOCK_JAILBREAK=true
        HL_LLM_LOG_LEVEL=debug
      
      # Enable both test modes
      enable-basic-red-teaming: true
      enable-red-teaming-with-aidr: true
      
      # ... other configuration ...
```

This is useful when:
- Port 8000 is already in use by another service
- You're running multiple AIDR instances
- Your infrastructure has specific port requirements
- You need to avoid port conflicts in CI/CD environments

### Example 8: Using OpenAI with AIDR Protection

```yaml
name: Test OpenAI with AIDR

jobs:
  red-team:
    uses: ./.github/workflows/automated-red-teaming.yml
    with:
      # Model configuration for OpenAI
      model-name: "gpt-3.5-turbo"
      model-provider: "openai"
      
      # AIDR configuration (non-secret)
      aidr-env-vars: |
        # Enable additional protections
        HL_LLM_BLOCK_JAILBREAK=true
        HL_LLM_CONFIDENCE_THRESHOLD=0.7
        HL_LLM_LOG_LEVEL=info
      
      # Enable AIDR protection
      enable-basic-red-teaming: false
      enable-red-teaming-with-aidr: true
      
      # HiddenLayer configuration
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
      
    secrets:
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_AUTOMATED_RED_TEAMING: ${{ secrets.HL_LICENSE_AUTOMATED_RED_TEAMING }}
      HL_LICENSE_AIDR: ${{ secrets.HL_LICENSE_AIDR }}
      
      # Pass OpenAI API key to AIDR service
      AIDR_ENV_SECRETS: |
        {
          "OPENAI_API_KEY": "${{ secrets.OPENAI_API_KEY }}"
        }
```

This configuration:
- Uses OpenAI's API as the backend
- AIDR acts as a protective proxy between red teaming and OpenAI
- Requires OpenAI API key to be passed to AIDR
- Applies AIDR's security protections to OpenAI responses

### Example 9: Using the Run Red Teaming Action Directly

```yaml
- name: Run Red Teaming
  uses: ./run-red-teaming
  with:
    target-url: "http://localhost:5000/chat"
    model-name: "custom-model"
    service-docker-image: "myservice:latest"
    service-port: "5000"
    service-health-command: "nc -z localhost 5000"
    # ... other inputs ...
```

## Architecture

The workflow supports two networking modes:

### Bridge Mode (Default - Recommended)
- **Secure container isolation**: Each container runs in its own network namespace
- **Port mapping**: Services are exposed via explicit port mappings
- **Service discovery**: Containers communicate using service names
- **Better security**: Containers cannot access host network directly

### Host Mode (Legacy)
- **Shared network**: All services share the host's network namespace
- **Direct port binding**: Services bind directly to host ports
- **Localhost communication**: Services reach each other via `localhost`
- **Less secure**: Containers have full access to host network

Choose the mode based on your security requirements and environment constraints.

### Service Communication

The workflow automatically sets up the following environment variables in your custom service to enable communication with AIDR:

- **`AIDR_SERVICE_URL`**: URL to reach the AIDR service
  - Bridge mode: `http://aidr-service:8000`
  - Host mode: `http://localhost:<aidr-port>`
- **`AIDR_PROXY_URL`**: Same as above (alias for compatibility)

This enables two communication patterns:

1. **Red Teaming Tool → AIDR → Backend Service** (default)
   - Red teaming tool sends requests to AIDR
   - AIDR forwards requests to your backend service
   - Your service responds to AIDR, which forwards back to red teaming tool

2. **Red Teaming Tool → Backend Service → AIDR** (if your service needs to call AIDR)
   - Red teaming tool sends requests directly to your service
   - Your service can make calls to AIDR using the provided URLs
   - Useful if your service implements custom AIDR integration

## How It Works

1. **Service Detection**: The workflow checks if `service-docker-image` and `service-port` are provided
2. **Registry Authentication** (if needed):
   - If `service-registry` and `service-registry-username` are provided
   - Logs into the registry using the provided credentials
   - Uses `SERVICE_REGISTRY_TOKEN` secret as the password
3. **Service Startup**: 
   - If custom service is configured, it starts your Docker container
   - If not, it falls back to the standard Ollama service
4. **Environment Variables**:
   - Basic mode: Uses `service-env-vars`
   - AIDR mode: Uses `service-env-vars-aidr` (falls back to `service-env-vars` if not specified)
5. **Health Check**: 
   - Runs the provided health command (if any)
   - Retries up to 30 times with 2-second intervals
   - Shows container logs if health check fails
6. **AIDR Service** (if enabled):
   - Starts AIDR proxy on the specified port (default: 8000)
   - Configures AIDR to forward requests to:
     - Your custom service (if configured)
     - OpenAI API (if model-provider is "openai")
     - Custom endpoint (if model-provider is "custom")
     - Ollama service (default)
7. **Target URL Determination**:
   - If `target-url` is provided: Uses that URL for all tests
   - Otherwise for Basic mode: `http://localhost:<service-port>` or custom model endpoint
   - Otherwise for AIDR mode: `http://localhost:<aidr-port>/v1/chat/completions` (AIDR proxy)
8. **Endpoint Validation**: Validates the target URL accepts OpenAI-compatible requests
9. **Red Teaming**: Runs attacks against the validated target URL
10. **Cleanup**: Automatically stops and removes containers after testing

## Why Different Environment Variables for Basic vs AIDR?

When running red teaming tests, your service might need different configurations depending on whether it's running:
- **Directly** (basic red teaming): The red teaming agent connects directly to your service
- **Behind AIDR proxy** (AIDR-protected red teaming): AIDR sits between the red teaming agent and your service

Common use cases for different configurations:

1. **Logging Levels**: More verbose in basic mode for debugging, quieter in AIDR mode
2. **Authentication**: Different API keys or tokens for different environments
3. **Rate Limiting**: Higher limits in basic mode, stricter in production-like AIDR mode
4. **Debug Features**: Enable debug endpoints in basic mode, disable in AIDR mode
5. **Proxy Detection**: Let your service know it's behind a proxy in AIDR mode
6. **Performance Settings**: Different timeouts, cache settings, or resource limits

## AIDR Configuration

When using AIDR protection (`enable-red-teaming-with-aidr: true`), the workflow starts an AIDR proxy service that sits between the red teaming agent and your application. You can customize AIDR's behavior using the `aidr-env-vars` input.

### Common AIDR Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `HL_LLM_BLOCK_PROMPT_INJECTION` | Block prompt injection attacks | `true` |
| `HL_LLM_BLOCK_JAILBREAK` | Block jailbreak attempts | `false` |
| `HL_LLM_BLOCK_HARMFUL_CONTENT` | Block harmful content generation | `false` |
| `HL_LLM_BLOCK_INPUT_PII` | Block PII in inputs | `true` |
| `HL_LLM_BLOCK_OUTPUT_PII` | Block PII in outputs | `true` |
| `HL_LLM_BLOCK_MESSAGE` | Custom message when blocking | `I'm sorry, but I cannot assist with that request.` |
| `HL_LLM_INCLUDE_BLOCK_MESSAGE_REASONS` | Include reason in block message | `false` |
| `HL_LLM_CONFIDENCE_THRESHOLD` | Detection confidence threshold (0-1) | `0.8` |
| `HL_LLM_MAX_REQUEST_SIZE` | Maximum request size in bytes | `10000` |
| `HL_LLM_TIMEOUT` | Request timeout in seconds | `30` |
| `HL_LLM_LOG_LEVEL` | Logging level | `info` |
| `OPENAI_API_KEY` | OpenAI API key (required when model-provider is "openai") | - |

### Example: Strict Security Configuration

```yaml
aidr-env-vars: |
  # Enable all protection features
  HL_LLM_BLOCK_PROMPT_INJECTION=true
  HL_LLM_BLOCK_JAILBREAK=true
  HL_LLM_BLOCK_HARMFUL_CONTENT=true
  HL_LLM_BLOCK_INPUT_PII=true
  HL_LLM_BLOCK_OUTPUT_PII=true
  
  # Lower threshold for more aggressive blocking
  HL_LLM_CONFIDENCE_THRESHOLD=0.6
  
  # Provide detailed block reasons
  HL_LLM_INCLUDE_BLOCK_MESSAGE_REASONS=true
  HL_LLM_BLOCK_MESSAGE=Request blocked: 
  
  # Enable debug logging
  HL_LLM_LOG_LEVEL=debug
```

## Passing Secrets

Due to GitHub Actions limitations, secrets cannot be passed through workflow inputs. Instead, use the `SERVICE_ENV_SECRETS` and `SERVICE_ENV_SECRETS_AIDR` secrets to pass sensitive environment variables to your custom service.

### Method 1: Using Secret Parameters (Recommended)

Pass secrets as JSON objects through dedicated secret parameters:

```yaml
jobs:
  red-team:
    uses: ./.github/workflows/automated-red-teaming.yml
    with:
      # ... other configuration ...
      
      # Non-secret environment variables for backend service
      service-env-vars: |
        LOG_LEVEL=debug
        PORT=8080
        ENABLE_CACHE=true
      
      # Non-secret environment variables for AIDR service
      aidr-env-vars: |
        HL_LLM_BLOCK_JAILBREAK=true
        HL_LLM_LOG_LEVEL=info
        
    secrets:
      # Required secrets
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_AUTOMATED_RED_TEAMING: ${{ secrets.HL_LICENSE_AUTOMATED_RED_TEAMING }}
      
      # Backend service secrets for basic red teaming
      SERVICE_ENV_SECRETS: |
        {
          "API_KEY": "${{ secrets.DEV_API_KEY }}",
          "AUTH_TOKEN": "${{ secrets.DEV_AUTH_TOKEN }}",
          "DB_USER": "${{ secrets.DEV_DB_USERNAME }}",
          "DB_PASS": "${{ secrets.DEV_DB_PASSWORD }}"
        }
      
      # Backend service secrets for AIDR mode (optional - falls back to SERVICE_ENV_SECRETS)
      SERVICE_ENV_SECRETS_AIDR: |
        {
          "API_KEY": "${{ secrets.PROD_API_KEY }}",
          "AUTH_TOKEN": "${{ secrets.PROD_AUTH_TOKEN }}",
          "DB_USER": "${{ secrets.PROD_DB_USERNAME }}",
          "DB_PASS": "${{ secrets.PROD_DB_PASSWORD }}"
        }
      
      # AIDR service secrets (for API keys, licenses, etc.)
      AIDR_ENV_SECRETS: |
        {
          "OPENAI_API_KEY": "${{ secrets.OPENAI_API_KEY }}",
          "CUSTOM_LICENSE_KEY": "${{ secrets.CUSTOM_LICENSE_KEY }}"
        }
```

### Understanding Secret Parameters

The workflow supports three different secret parameters:

1. **`SERVICE_ENV_SECRETS`**: Secrets for your backend service during basic red teaming
   - Used when running basic (non-AIDR) red teaming
   - Example: API keys, database passwords for your service

2. **`SERVICE_ENV_SECRETS_AIDR`**: Secrets for your backend service during AIDR mode
   - Used when running AIDR-protected red teaming
   - Falls back to `SERVICE_ENV_SECRETS` if not provided
   - Useful for using different credentials in AIDR mode

3. **`AIDR_ENV_SECRETS`**: Secrets for the AIDR service itself
   - Used to pass secrets that AIDR needs (not your backend)
   - Example: OpenAI API keys, external service credentials
   - These are passed to the AIDR container, not your backend

This separation allows you to:
- Use development credentials for basic testing
- Use production credentials with AIDR protection
- Pass API keys that AIDR needs (like OpenAI keys) separately
- Keep backend secrets separate from AIDR service secrets

### Method 2: Creating a Combined Secret

Alternatively, create repository secrets containing your service secrets as JSON:

1. Create a secret named `MY_SERVICE_SECRETS` with value:
   ```json
   {
     "API_KEY": "your-actual-api-key",
     "DB_USER": "dbuser",
     "DB_PASS": "dbpassword"
   }
   ```

2. Use it in your workflow:
   ```yaml
   secrets:
     SERVICE_ENV_SECRETS: ${{ secrets.MY_SERVICE_SECRETS }}
   ```

### Docker Registry Authentication

The workflow supports authentication to various Docker registries:

| Registry | Registry URL | Username | Token/Password |
|----------|-------------|----------|----------------|
| Docker Hub | `docker.io` | Your Docker Hub username | Docker Hub password or access token |
| GitHub Container Registry | `ghcr.io` | `${{ github.actor }}` | GitHub Personal Access Token or `${{ secrets.GITHUB_TOKEN }}` |
| Azure Container Registry | `myregistry.azurecr.io` | Service principal name | Service principal password |
| Google Container Registry | `gcr.io` | `_json_key` | Service account JSON key (as single line) |
| AWS ECR | `123456789.dkr.ecr.us-east-1.amazonaws.com` | AWS access key ID | AWS secret access key |
| Private registries | Your registry URL | Your username | Your password/token |

### Security Best Practices

1. **Always use GitHub Secrets**: Never hardcode sensitive values directly
   ```yaml
   # ❌ WRONG - Never do this
   service-env-vars: |
     API_KEY=sk-1234567890abcdef
   
   # ✅ CORRECT - Use SERVICE_ENV_SECRETS
   secrets:
     SERVICE_ENV_SECRETS: |
       {
         "API_KEY": "${{ secrets.API_KEY }}"
       }
   ```

2. **Separate secrets from non-secrets**:
   ```yaml
   with:
     # Non-sensitive configuration
     service-env-vars: |
       LOG_LEVEL=info
       PORT=8080
       REGION=us-east-1
   
   secrets:
     # Sensitive values
     SERVICE_ENV_SECRETS: |
       {
         "API_KEY": "${{ secrets.API_KEY }}",
         "DB_PASS": "${{ secrets.DB_PASS }}"
       }
   ```

3. **Minimize secret exposure**: Only pass the secrets your service actually needs

4. **Use descriptive secret names**: Makes it clear what each secret is for

### Debugging Tips

- The workflow logs will show variable names but **not** their values:
  ```
  Processing additional environment variables...
    Added: API_KEY
    Added: DB_PASS
  ```

- If you need to verify a secret is being passed, have your service log a redacted version:
  ```python
  # In your service code
  api_key = os.getenv('API_KEY', '')
  print(f"API_KEY configured: {'Yes' if api_key else 'No'} (length: {len(api_key)})")
  ```

### Multi-line Secrets

For secrets that contain newlines (like certificates or private keys), you can use the standard GitHub Actions syntax:

```yaml
service-env-vars: |
  # Single-line secret
  API_KEY=${{ secrets.API_KEY }}
  
  # Multi-line secret (like a certificate)
  TLS_CERT=${{ secrets.TLS_CERT }}
  
  # Base64-encoded multi-line secret
  PRIVATE_KEY_B64=${{ secrets.PRIVATE_KEY_B64 }}
```

Your service would then decode base64 values as needed:
```python
import base64
import os

private_key = base64.b64decode(os.getenv('PRIVATE_KEY_B64', ''))
```

## Troubleshooting

### Service Won't Start
- Check that the Docker image is accessible
- Ensure the port isn't already in use
- Review the container logs in the workflow output

### Viewing Container Logs
The workflow automatically captures Docker logs before cleanup:
- Logs are shown in a collapsed "Docker Container Logs" section
- Shows container status (running/exited)
- Displays the last 200 lines of logs for each container
- Captured for both basic and AIDR red teaming jobs

### Health Check Fails
- Verify the health command syntax
- Ensure the service starts on the expected port
- Check that the health endpoint exists and returns success

### Connection Refused
- Confirm the service is listening on the specified port
- Check if the service needs time to initialize
- Verify network connectivity with `docker logs`

## Best Practices

1. **Always provide a health check** when possible to ensure the service is ready
2. **Use specific image tags** instead of `latest` for reproducibility
3. **Set appropriate environment variables** for your service configuration
4. **Test locally first** using the same Docker image and configuration
5. **Monitor resource usage** as custom services may require more resources than Ollama

## Limitations

- Services must expose HTTP/HTTPS endpoints
- Only one custom service can be configured per workflow run
- Services run with `--network host` in AIDR mode for compatibility
- Port conflicts may occur if multiple services use the same port

## Security Considerations

- Avoid hardcoding sensitive credentials in `service-env-vars`
- Use GitHub secrets for API keys and passwords
- Ensure your Docker images are from trusted sources
- Regular security scanning of custom Docker images is recommended 