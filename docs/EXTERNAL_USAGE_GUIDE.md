# Complete Guide: Using HiddenLayer AI Security Workflow in Your Repository

This guide walks you through setting up the complete HiddenLayer AI Security workflow in your GitHub repository, including model scanning and automated red teaming (with and without AIDR protection).

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step 1: Set Up GitHub Secrets](#step-1-set-up-github-secrets)
3. [Step 2: Set Up GitHub Variables](#step-2-set-up-github-variables)
4. [Step 3: Create Your Workflow File](#step-3-create-your-workflow-file)
5. [Step 4: Test Your Setup](#step-4-test-your-setup)
6. [Configuration Options](#configuration-options)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

Before starting, ensure you have:
- Admin access to your GitHub repository
- HiddenLayer account credentials (Client ID and Client Secret)
- HiddenLayer licenses for the features you want to use
- Quay.io credentials for accessing HiddenLayer container images

## Step 1: Set Up GitHub Secrets

GitHub Secrets store sensitive information like passwords and API keys. Follow these steps to add each required secret:

### Adding Secrets via GitHub UI

1. Navigate to your repository on GitHub
2. Click on **Settings** (in the repository navigation bar)
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click the **New repository secret** button

Add each of the following secrets:

### Required Secrets

#### 1. `HIDDENLAYER_CLIENT_SECRET`
- **Description**: Your HiddenLayer API client secret
- **How to get it**: Provided by HiddenLayer when you create API credentials
- **Example value**: `hl_secret_abc123xyz...` (long string)

#### 2. `QUAY_TOKEN`
- **Description**: Password/token for Quay.io registry access
- **How to get it**: Provided by HiddenLayer for accessing their container images
- **Example value**: `quay_token_def456...`

#### 3. `HL_LICENSE_MODELSCANNER`
- **Description**: License key for model scanning feature
- **How to get it**: Provided by HiddenLayer with your subscription
- **Example value**: `eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...` (JWT token)

#### 4. `HL_LICENSE_AUTOMATED_RED_TEAMING`
- **Description**: License key for automated red teaming
- **How to get it**: Provided by HiddenLayer with your subscription
- **Example value**: `eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...` (JWT token)

#### 5. `HL_LICENSE_AIDR` (Optional)
- **Description**: License key for AIDR (AI Detection and Response)
- **How to get it**: Provided by HiddenLayer if you have AIDR subscription
- **Example value**: `eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...` (JWT token)
- **Note**: Only required if using `enable-red-teaming-with-aidr: true`

### Adding Each Secret

For each secret:
1. Click **New repository secret**
2. Enter the **Name** exactly as shown above (e.g., `HIDDENLAYER_CLIENT_SECRET`)
3. Enter the **Value** (your actual secret value)
4. Click **Add secret**

## Step 2: Set Up GitHub Variables

GitHub Variables store non-sensitive configuration values. These are easier to manage and can be viewed by repository collaborators.

### Adding Variables via GitHub UI

1. In the same **Settings** → **Secrets and variables** → **Actions** page
2. Click on the **Variables** tab
3. Click **New repository variable**

Add each of the following variables:

### Required Variables

#### 1. `HIDDENLAYER_CLIENT_ID`
- **Description**: Your HiddenLayer API client ID
- **Example value**: `hl_client_abc123`
- **How to get it**: Provided with your HiddenLayer API credentials

#### 2. `QUAY_USERNAME`
- **Description**: Username for Quay.io registry
- **Example value**: `hiddenlayer+customer_name`
- **How to get it**: Provided by HiddenLayer

### Optional Variables (Recommended)

#### 3. `HIDDENLAYER_API_URL`
- **Description**: HiddenLayer API endpoint
- **Default value**: `https://api.us.hiddenlayer.ai`
- **Note**: Only change if using a different region

#### 4. `HIDDENLAYER_AUTH_URL`
- **Description**: HiddenLayer authentication endpoint
- **Default value**: `https://auth.hiddenlayer.ai`
- **Note**: Usually doesn't need to be changed

#### 5. `HIDDENLAYER_CONSOLE_URL`
- **Description**: HiddenLayer console URL for viewing results
- **Default value**: `https://console.us.hiddenlayer.ai`
- **Note**: Change if using a different region

## Step 3: Create Your Workflow File

Now create a workflow file in your repository to use the HiddenLayer security checks.

### Creating the Workflow File

1. In your repository, create the directory `.github/workflows/` if it doesn't exist
2. Create a new file named `ai-security.yml` (or any name ending in `.yml`)
3. Copy and paste one of the following examples:

### Example 1: Full Security Suite (Recommended)

This example runs all security checks: model scanning, basic red teaming, and AIDR-protected red teaming.

```yaml
name: AI Security Check

on:
  pull_request:
    branches: [main, develop]
    paths:
      - '**.py'
      - '**.pkl'
      - '**.h5'
      - '**.onnx'
      - '**.pt'
      - '**.pth'
      - '**.safetensors'
      - 'requirements.txt'

jobs:
  ai-security:
    name: Full AI Security Check
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/ai-development-workflow.yml@v1
    with:
      # Runner configuration
      runs-on: ubuntu-latest  # or use your own runner
      
      # Enable all security features
      enable-model-scanning: true
      enable-basic-red-teaming: true
      enable-red-teaming-with-aidr: true
      
      # Model scanning configuration
      enforce-scan-detections: "true"  # Fail if vulnerabilities found
      
      # Red teaming configuration
      model-name: "gpt-3.5-turbo"  # Change to your model
      model-provider: "openai"     # Options: ollama, openai, custom
      attack-tags: "owasp-llm-top-10,jailbreak"
      planned-attempts: "5"
      
      # HiddenLayer configuration
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
      hiddenlayer-api-url: ${{ vars.HIDDENLAYER_API_URL }}
      hiddenlayer-auth-url: ${{ vars.HIDDENLAYER_AUTH_URL }}
      hiddenlayer-console-url: ${{ vars.HIDDENLAYER_CONSOLE_URL }}
      
    secrets:
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_MODELSCANNER: ${{ secrets.HL_LICENSE_MODELSCANNER }}
      HL_LICENSE_AUTOMATED_RED_TEAMING: ${{ secrets.HL_LICENSE_AUTOMATED_RED_TEAMING }}
      HL_LICENSE_AIDR: ${{ secrets.HL_LICENSE_AIDR }}
```

### Example 2: Model Scanning Only

If you only want to scan models for vulnerabilities:

```yaml
name: Model Security Scan

on:
  pull_request:
    branches: [main]
    paths:
      - '**.pkl'
      - '**.h5'
      - '**.onnx'
      - '**.pt'
      - '**.pth'
      - '**.safetensors'

jobs:
  security-scan:
    name: Model Security Scan
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/ai-development-workflow.yml@v1
    with:
      enable-model-scanning: true
      enable-basic-red-teaming: false
      enable-red-teaming-with-aidr: false
      enforce-scan-detections: "true"
      
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
      
    secrets:
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_MODELSCANNER: ${{ secrets.HL_LICENSE_MODELSCANNER }}
```

### Example 3: Red Teaming Only

If you only want to test your deployed model:

```yaml
name: AI Red Team Testing

on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Mondays at 2 AM
  workflow_dispatch:      # Allow manual triggering

jobs:
  red-team:
    name: Red Team Testing
    uses: hiddenlayerai/hl-aisec-platform-development-workflow/.github/workflows/ai-development-workflow.yml@v1
    with:
      enable-model-scanning: false
      enable-basic-red-teaming: true
      enable-red-teaming-with-aidr: true
      
      # Model configuration
      model-name: "llama2-7b"
      model-provider: "ollama"
      attack-tags: "quick-start"
      planned-attempts: "3"
      
      hiddenlayer-client-id: ${{ vars.HIDDENLAYER_CLIENT_ID }}
      quay-username: ${{ vars.QUAY_USERNAME }}
      
    secrets:
      HIDDENLAYER_CLIENT_SECRET: ${{ secrets.HIDDENLAYER_CLIENT_SECRET }}
      QUAY_TOKEN: ${{ secrets.QUAY_TOKEN }}
      HL_LICENSE_AUTOMATED_RED_TEAMING: ${{ secrets.HL_LICENSE_AUTOMATED_RED_TEAMING }}
      HL_LICENSE_AIDR: ${{ secrets.HL_LICENSE_AIDR }}
```

## Step 4: Test Your Setup

### Initial Test

1. **Commit and push** your workflow file to a branch
2. **Create a pull request** to trigger the workflow
3. **Check the Actions tab** in your repository to monitor progress

### What to Expect

#### First Run Timeline
- **Model Scanning**: 2-5 minutes (depends on repository size)
- **Basic Red Teaming**: 5-10 minutes (depends on attack configurations)
- **AIDR Red Teaming**: 10-15 minutes (includes AIDR container startup)

#### Viewing Results

1. **GitHub Actions Summary**: Check the workflow run for a summary
2. **Pull Request Comment**: Automated comment with results (if PR triggered)
3. **HiddenLayer Console**: 
   - Model scans: `https://console.us.hiddenlayer.ai/model-details/{model-id}`
   - Red teaming: `https://console.us.hiddenlayer.ai/automated-red-teaming`
4. **Artifacts**: Download detailed reports from the workflow run

## Configuration Options

### Model Scanning Options

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `enforce-scan-detections` | Fail workflow if vulnerabilities found | `"false"` | `"true"`, `"false"` |
| `model-scanner-version` | Scanner version to use | `"25.5.1"` | Any valid version |

### Red Teaming Options

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `model-name` | Model to test | Required | Any model name |
| `model-provider` | How model is hosted | `"ollama"` | `"ollama"`, `"openai"`, `"custom"` |
| `model-endpoint` | Custom endpoint URL | None | Any URL (for custom provider) |
| `attack-tags` | Attack categories | `"quick-start"` | See below |
| `planned-attempts` | Attempts per attack | `"1"` | Any number |

### Available Attack Tags

- `quick-start` - Basic security testing
- `owasp-llm-top-10` - OWASP Top 10 for LLMs
- `jailbreak` - Jailbreak attempts
- `prompt-injection` - Prompt injection attacks
- `data-extraction` - Training data extraction
- `harmful-content` - Harmful output generation

Combine multiple tags with commas: `"jailbreak,prompt-injection"`

### Using Custom Model Endpoints

If your model is hosted on your own infrastructure:

```yaml
model-provider: "custom"
model-endpoint: "https://api.mycompany.com/v1/chat/completions"
```

## Troubleshooting

### Common Issues and Solutions

#### 1. "Authentication failed" Error
- **Check**: Verify `HIDDENLAYER_CLIENT_ID` and `HIDDENLAYER_CLIENT_SECRET` are correct
- **Solution**: Re-copy credentials from HiddenLayer dashboard

#### 2. "License validation failed" Error
- **Check**: Ensure license secrets are properly set
- **Solution**: Verify license hasn't expired, contact HiddenLayer support

#### 3. "Cannot pull container image" Error
- **Check**: Verify `QUAY_USERNAME` and `QUAY_TOKEN`
- **Solution**: Ensure Quay credentials are active

#### 4. Workflow doesn't trigger
- **Check**: Verify file paths in `on.pull_request.paths` match your files
- **Solution**: Adjust paths or remove paths filter

#### 5. Red teaming fails to connect
- **Check**: Verify model endpoint is accessible
- **Solution**: For Ollama, ensure model is downloaded; for custom, check firewall

### Getting Help

1. **Check logs**: Click on failed job in Actions tab for detailed logs
2. **Enable debug logging**: Add secret `ACTIONS_RUNNER_DEBUG` with value `true`
3. **HiddenLayer Support**: Contact support@hiddenlayer.com with:
   - Your client ID
   - Workflow run URL
   - Error messages

## Best Practices

1. **Start small**: Test with model scanning first, then add red teaming
2. **Use path filters**: Only run on relevant file changes to save time
3. **Schedule red teaming**: Use cron schedules for regular security testing
4. **Monitor results**: Set up notifications for failed security checks
5. **Use .hiddenlayer file**: Document accepted risks and false positives

## Next Steps

- Read about [ignoring false positives](https://github.com/hiddenlayerai/hl-aisec-platform-development-workflow#ignoring-specific-detections)
- Explore [advanced configurations](https://github.com/hiddenlayerai/hl-aisec-platform-development-workflow#advanced-configuration)

---

**Need help?** Create an issue in the [reference actions repository](https://github.com/hiddenlayerai/hl-aisec-platform-development-workflow/issues) or contact HiddenLayer support. 