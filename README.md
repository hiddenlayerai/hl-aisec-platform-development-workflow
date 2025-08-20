# HiddenLayer AI Security GitHub Actions

A collection of reusable GitHub workflows and actions for integrating HiddenLayer's AI security tools into your CI/CD pipeline.

## 🚀 Quick Start

**📖 For step-by-step setup instructions, see the [External Usage Guide](docs/EXTERNAL_USAGE_GUIDE.md)**

Add HiddenLayer AI security checks to your repository by creating a workflow file (e.g., `.github/workflows/ai-security.yml`):

```yaml
name: AI Security Check

on:
  pull_request:
    branches: [main]

jobs:
  ai-security:
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/ai-development-workflow.yml@v1
    with:
      enable-model-scanning: true
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
    secrets:
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_MODELSCANNER: ${{ secrets.HL_LICENSE_MODELSCANNER }}
```

## 📋 Prerequisites

### Required Secrets
- `HIDDENLAYER_CLIENT_SECRET` - Your HiddenLayer API client secret
- `QUAY_TOKEN` - Password/token for Quay.io registry access
- `HL_LICENSE_MODELSCANNER` - License for model scanning (required if using model scanning)
- `HL_LICENSE_AUTOMATED_RED_TEAMING` - License for red teaming (required if using red teaming)
- `HL_LICENSE_AIDR` - License for AIDR (required if using AIDR-protected red teaming)

### Required Variables
- `HIDDENLAYER_CLIENT_ID` - Your HiddenLayer API client ID
- `QUAY_USERNAME` - Quay.io username for container registry access

### Optional Variables
- `HIDDENLAYER_API_URL` - API endpoint (default: `https://api.us.hiddenlayer.ai`)
- `HIDDENLAYER_AUTH_URL` - Auth endpoint (default: `https://auth.hiddenlayer.ai`)
- `HIDDENLAYER_CONSOLE_URL` - Console URL (default: `https://console.us.hiddenlayer.ai`)

## 🛠️ Usage Examples

### Model Scanning Only

Scan your repository for malicious code in ML model files:

```yaml
name: Model Security Scan

on:
  pull_request:
    paths:
      - '**.pkl'
      - '**.h5'
      - '**.onnx'
      - '**.pt'
      - '**.pth'
      - '**.safetensors'

jobs:
  scan:
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/model-scanner.yml@v1
    with:
      enforce-scan-detections: "true"  # Fail if vulnerabilities found
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
    secrets:
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_MODELSCANNER: ${{ secrets.HL_LICENSE_MODELSCANNER }}
```

### Automated Red Teaming

Test your AI model's resilience against adversarial attacks. The workflow automatically creates/registers the target in HiddenLayer platform before running scans:

```yaml
name: AI Red Teaming

on:
  workflow_dispatch:
    inputs:
      model-name:
        description: 'Model to test'
        required: true
        default: 'gpt-3.5-turbo'

jobs:
  red-team:
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/automated-red-teaming.yml@v1
    with:
      model-name: ${{ inputs.model-name }}
      model-provider: "openai"  # Options: ollama, openai, custom
      attack-tags: "quick-start"  # Or specific tags like "jailbreak,prompt-injection"
      enable-basic-red-teaming: true
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
    secrets:
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_AUTOMATED_RED_TEAMING: ${{ secrets.HL_LICENSE_AUTOMATED_RED_TEAMING }}
```

### Red Teaming with AIDR Protection

Test your model with HiddenLayer's AIDR (AI Detection and Response) protection enabled:

```yaml
name: AI Red Teaming with Protection

on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday at 2 AM

jobs:
  protected-red-team:
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/automated-red-teaming.yml@v1
    with:
      model-name: "llama2"
      model-provider: "ollama"
      attack-tags: "owasp-llm-top-10"
      enable-basic-red-teaming: true      # Run without protection
      enable-red-teaming-with-aidr: true  # Also run with AIDR protection
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
    secrets:
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_AUTOMATED_RED_TEAMING: ${{ secrets.HL_LICENSE_AUTOMATED_RED_TEAMING }}
      HL_LICENSE_AIDR: ${{ secrets.HL_LICENSE_AIDR }}
```

### Complete AI Security Suite

Run both model scanning and red teaming in a single workflow:

```yaml
name: Complete AI Security Check

on:
  pull_request:
    branches: [main, develop]

jobs:
  ai-security:
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/ai-development-workflow.yml@v1
    with:
      # Enable features
      enable-model-scanning: true
      enable-basic-red-teaming: true
      enable-red-teaming-with-aidr: true
      
      # Model scanning config
      enforce-scan-detections: "true"
      
      # Red teaming config
      model-name: "phi4-mini"
      attack-tags: "quick-start"
      planned-attempts: "5"
      
      # HiddenLayer config
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
      
    secrets:
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_MODELSCANNER: ${{ secrets.HL_LICENSE_MODELSCANNER }}
      HL_LICENSE_AUTOMATED_RED_TEAMING: ${{ secrets.HL_LICENSE_AUTOMATED_RED_TEAMING }}
      HL_LICENSE_AIDR: ${{ secrets.HL_LICENSE_AIDR }}
```

## 🚫 Ignoring Specific Detections

Use a `.hiddenlayer` file in your repository root to ignore specific security findings:

```yaml
# .hiddenlayer
ignore:
  RULE-001:
    reason: "This is a known false positive in our test data"
    expires: "2024-12-31"
  
  RULE-002:
    reason: "Accepted risk for this legacy model"
    expires: "2025-06-30"
  
  PICKLE-UNSAFE-LOAD:
    reason: "We control the pickle file source"
    # No expiry - permanent ignore
```

### Ignore File Format

- **Rule ID**: The specific detection rule to ignore
- **reason**: (Required) Explanation for ignoring this detection
- **expires**: (Optional) ISO date when the ignore expires

When `enforce-scan-detections: "true"`, the workflow will:
1. Check all detections against the `.hiddenlayer` file
2. Skip ignored detections that haven't expired
3. Only fail if non-ignored detections are found

## 🔧 Advanced Configuration

### Custom Model Endpoints

For testing models hosted on custom infrastructure:

```yaml
jobs:
  test-custom-model:
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/automated-red-teaming.yml@v1
    with:
      model-name: "custom-model"
      model-provider: "custom"
      model-endpoint: "https://api.mycompany.com/v1/chat/completions"
      enable-basic-red-teaming: true
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
    secrets: inherit
```

### Custom Service Support

Test your own containerized AI applications without using Ollama:

```yaml
jobs:
  test-docker-service:
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/automated-red-teaming.yml@v1
    with:
      # Model configuration
      model-name: "my-custom-api"
      
      # Custom service configuration
      service-docker-image: "myorg/ai-service:latest"
      service-port: "8080"
      service-health-command: "curl -f http://localhost:8080/health || exit 1"
      
      # Optional: Private registry authentication
      # service-registry: "myregistry.azurecr.io"
      # service-registry-username: ${{ vars.REGISTRY_USERNAME }}
      
      # Non-secret environment variables
      service-env-vars: |
        MODEL_PATH=/models/custom
        LOG_LEVEL=info
      
      # Different config for AIDR mode (optional)
      service-env-vars-aidr: |
        MODEL_PATH=/models/custom
        LOG_LEVEL=warn
        PROXY_MODE=true
      
      # Red teaming configuration
      enable-basic-red-teaming: true
      enable-red-teaming-with-aidr: true
      attack-tags: "llm-attacks,prompt-injection"
      
      # HiddenLayer configuration
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
    secrets:
      # Required HiddenLayer secrets
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_AUTOMATED_RED_TEAMING: ${{ secrets.HL_LICENSE_AUTOMATED_RED_TEAMING }}
      HL_LICENSE_AIDR: ${{ secrets.HL_LICENSE_AIDR }}
      
      # Optional: Registry authentication (if using private registry)
      # SERVICE_REGISTRY_TOKEN: ${{ secrets.REGISTRY_PASSWORD }}
      
      # Backend service secrets for basic mode
      SERVICE_ENV_SECRETS: |
        {
          "API_KEY": "${{ secrets.API_KEY }}",
          "DB_PASSWORD": "${{ secrets.DB_PASS }}"
        }
      
      # Backend service secrets for AIDR mode (optional)
      SERVICE_ENV_SECRETS_AIDR: |
        {
          "API_KEY": "${{ secrets.PROD_API_KEY }}",
          "DB_PASSWORD": "${{ secrets.PROD_DB_PASS }}"
        }
      
      # AIDR service secrets (if AIDR needs external API keys)
      # AIDR_ENV_SECRETS: |
      #   {
      #     "EXTERNAL_API_KEY": "${{ secrets.EXTERNAL_API_KEY }}"
      #   }
```

The custom service feature allows you to:
- Test any Docker-based AI service (including from private registries)
- Authenticate to private Docker registries
- Configure health checks for service readiness
- Pass non-secret environment variables to your service
- Pass secrets securely through dedicated secret parameters
- Use different configurations and secrets for basic vs AIDR-protected testing
- Customize AIDR protection settings with additional environment variables
- Configure the AIDR service port (default: 8000)
- Use OpenAI API with AIDR protection (model-provider: "openai")
- Run both basic and AIDR-protected tests

For detailed configuration options, see the [Custom Service Guide](docs/CUSTOM_SERVICE_GUIDE.md).

### OpenAI with AIDR Protection

Red team OpenAI models (GPT-3.5, GPT-4) with AIDR protection:

```yaml
jobs:
  test-openai:
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/automated-red-teaming.yml@v1
    with:
      model-name: "gpt-3.5-turbo"
      model-provider: "openai"
      enable-red-teaming-with-aidr: true
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
    secrets:
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_AUTOMATED_RED_TEAMING: ${{ secrets.HL_LICENSE_AUTOMATED_RED_TEAMING }}
      HL_LICENSE_AIDR: ${{ secrets.HL_LICENSE_AIDR }}
      AIDR_ENV_SECRETS: |
        {
          "OPENAI_API_KEY": "${{ secrets.OPENAI_API_KEY }}"
        }
```

See the [OpenAI + AIDR example workflow](.github/workflows/example-openai-aidr.yml) for a complete configuration.

### Runner Configuration

Specify custom runners for your workflows:

```yaml
jobs:
  security:
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/ai-development-workflow.yml@v1
    with:
      runs-on: "self-hosted-gpu-runner"  # Your custom runner
      enable-model-scanning: true
      quay-username: ${{ vars.QUAY_USERNAME }}
      # ... other configuration
```

### Attack Tag Options

Available attack tags for red teaming:
- `quick-start` - Basic set of attacks for quick testing
- `owasp-llm-top-10` - OWASP Top 10 for LLMs
- `jailbreak` - Jailbreak attempts
- `prompt-injection` - Prompt injection attacks
- `data-extraction` - Attempts to extract training data
- `harmful-content` - Tests for harmful output generation

Combine multiple tags with commas: `"jailbreak,prompt-injection,data-extraction"`

## 📊 Outputs and Artifacts

### Workflow Outputs

All workflows provide outputs that can be used in subsequent jobs:

```yaml
jobs:
  security:
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/model-scanner.yml@v1
    # ... configuration ...
  
  process-results:
    needs: security
    runs-on: ubuntu-latest
    steps:
      - name: Check results
        run: |
          echo "Scan ID: ${{ needs.security.outputs.scan-id }}"
          echo "Detections found: ${{ needs.security.outputs.detections-found }}"
          echo "Summary: ${{ needs.security.outputs.detection-summary }}"
```

### Available Artifacts

- **Model Scanning**:
  - `repository-scan-results`: JSON scan results, SARIF report, AIBOM
  - GitHub Security tab integration (SARIF upload)

- **Red Teaming**:
  - `red-teaming-basic-artifacts`: CSV reports with attack details
  - `red-teaming-aidr-artifacts`: AIDR-protected test results
  - `red-teaming-consolidated-report`: Combined summary

## 🔍 Viewing Results

### GitHub Security Tab
Model scanning results automatically appear in your repository's Security tab when SARIF upload is enabled.

### HiddenLayer Console
View detailed results in the HiddenLayer console:
- Model scans: `https://console.us.hiddenlayer.ai/model-details/{model-id}`
- Red teaming: `https://console.us.hiddenlayer.ai/automated-red-teaming`

### Pull Request Comments
When enabled, workflows automatically comment on PRs with summaries and links to full results.

## 📝 License

This project provides reference implementations for integrating HiddenLayer's security tools. Use of HiddenLayer's services requires appropriate licenses.

## 📚 Additional Resources

- **[External Usage Guide](docs/EXTERNAL_USAGE_GUIDE.md)** - Step-by-step setup instructions for external repositories
- **[Build Example](.github/workflows/build.example)** - Example workflow configuration

## 🧪 Testing

### Model Scanner Test Workflow

A test workflow is available to validate the model scanner's functionality, particularly the AI model detection and HuggingFace repository extraction:

```yaml
name: Test Model Scanner

on:
  pull_request:
    paths:
      - '.github/workflows/model-scanner.yml'
      - '.github/workflows/test-model-scanner.yml'
```

The test workflow:
- Creates synthetic Python files with various AI model usage patterns
- Runs the model scanner to detect models
- Validates that expected models are found
- Works with or without HiddenLayer credentials

See [.github/workflows/TEST_MODEL_SCANNER.md](.github/workflows/TEST_MODEL_SCANNER.md) for detailed information.

### Example Workflow Template

A template is provided for easy integration into your repository:
- [.github/workflows/example-usage.yml.template](.github/workflows/example-usage.yml.template)

Copy and customize this template to get started quickly.

## 🤝 Support

- Documentation: https://docs.hiddenlayer.com
- Support: support@hiddenlayer.com
- Issues: Create an issue in this repository

