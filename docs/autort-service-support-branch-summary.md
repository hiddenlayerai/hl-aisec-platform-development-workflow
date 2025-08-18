# autort-service-support Branch Summary

## Overview
This branch implements comprehensive custom service support for automated red teaming, allowing users to test their own containerized AI applications without requiring Ollama.

## Major Features Implemented

### 1. Custom Service Support
- Added ability to specify custom Docker images for testing
- Implemented health check mechanism with configurable commands
- Added environment variable support (both non-secret and secret)
- Created separate configurations for basic vs AIDR modes

### 2. Docker Registry Authentication
- Added support for private Docker registries
- Implemented authentication for Docker Hub, GHCR, Azure CR, GCR, AWS ECR
- Added `service-registry`, `service-registry-username` inputs
- Added `SERVICE_REGISTRY_TOKEN` secret

### 3. Enhanced Secret Management
- Implemented JSON-based secret parsing for better security
- Added `SERVICE_ENV_SECRETS` for backend service secrets
- Added `SERVICE_ENV_SECRETS_AIDR` for different secrets in AIDR mode
- Added `AIDR_ENV_SECRETS` for AIDR service configuration

### 4. AIDR Improvements
- Made AIDR port configurable (default: 8000)
- Added OpenAI API support as AIDR backend
- Fixed networking issues between AIDR and backend services
- Improved AIDR configuration flexibility

### 5. Developer Experience
- Added Docker container log capture for debugging
- Simplified endpoint validation (removed health checks)
- Added target URL override capability
- Improved error messages and logging

### 6. Networking Architecture
- Standardized on `--network host` for all services
- Fixed Ollama-AIDR connectivity issues
- Ensured consistent inter-service communication

## Files Modified

### Workflows
- `.github/workflows/automated-red-teaming.yml` - Major changes for custom service support
- `.github/workflows/ai-development-workflow.yml` - Added custom service inputs
- `.github/workflows/model-scanner.yml` - Fixed action reference typos

### Actions
- `run-red-teaming/action.yml` - Added custom service parameters
- `validate-openai-compatible-endpoint/action.yml` - Simplified implementation
- `validate-openai-compatible-endpoint/README.md` - Updated documentation

### Documentation
- `docs/CUSTOM_SERVICE_GUIDE.md` - New comprehensive guide
- `docs/EXTERNAL_USAGE_GUIDE.md` - Added custom service section
- `README.md` - Added custom service examples
- `V1_RELEASE_SUMMARY.md` - Updated with all changes

### Example Workflows
- `.github/workflows/example-custom-service.yml` - Created
- `.github/workflows/example-openai-aidr.yml` - Created

## Commits (in chronological order)

1. `1ffbcff` - Basic custom service support
2. `2256cb8` - Enhanced secret handling
3. `a38e224` - Fixed proper secret handling for reusable workflows
4. `a0f62d6` - Added SERVICE_ENV_SECRETS_AIDR support
5. `4ef06db` - Added target-url parameter
6. `9d9cc7a` - Added Docker registry authentication
7. `9e11876` - Added configurable AIDR port parameter
8. `08cca4d` - Enhanced validate-openai-compatible-endpoint action
9. `6533c6b` - Simplified validate-openai-compatible-endpoint to remove health checks
10. `bdb87cc` - Added OpenAI API support for AIDR backend
11. `0843509` - Added Docker container log capture
12. `0e24701` - Added proper AIDR_ENV_SECRETS support
13. `9080001` - Fixed model-scanner workflow action references
14. `f2780bb` - Fixed AIDR-Ollama networking connectivity
15. `ffb03dc` - Documented networking architecture
16. `8613eb2` - Cleaned up temporary test workflow
17. `f604820` - Updated release summary with latest fixes

## Testing Performed
- Created test workflows for various configurations
- Tested Ollama connectivity with new networking
- Verified custom service health checks
- Tested secret handling and parsing
- Validated Docker registry authentication

## Known Issues Resolved
- Fixed "Missing download info" error in model scanner
- Resolved AIDR-Ollama connectivity problems
- Corrected secret handling for reusable workflows
- Fixed action reference typos

## Ready for v2 Release
This branch contains all the features needed for the v2 release. The main tasks remaining are:
1. Update all `@v1` references to `@v2`
2. Remove development/debug configurations
3. Complete testing in various environments
4. Create final release documentation 