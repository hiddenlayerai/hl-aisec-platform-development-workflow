# AI Model Test Files

This directory contains test Python files with various AI model usage patterns. These files are used to test the HiddenLayer Model Scanner's ability to detect AI models in codebases.

## Purpose

These files are specifically designed for testing the model scanner workflow and should NOT be used as examples of production code. They contain:

- Mock API keys (not real credentials)
- Various patterns of AI model usage
- Different AI providers and frameworks

## Test Coverage

### `huggingface_test.py`
Tests detection of HuggingFace transformers models:
- Direct model loading with `from_pretrained()` (bert-base-uncased)
- Pipeline usage with text-generation (gpt2)

### `openai_test.py`
Tests detection of OpenAI API usage:
- GPT-4 chat completions
- GPT-3.5-turbo usage
- System prompts and messages



## Expected Detections

The model scanner should detect these HuggingFace models:
- `bert-base-uncased` (from huggingface_test.py)
- `gpt2` (from huggingface_test.py)

## Note

These files intentionally use outdated or simplified patterns for testing purposes. Do not use these as reference implementations for actual AI integrations. 