# Check HiddenLayer Ignores Action

This action processes scan results from the HiddenLayer Model Scanner and checks them against a `.hiddenlayer` ignore file to determine which detections should be actioned based on expiration dates.

## Purpose

The action allows you to:
- Temporarily ignore specific detection rule IDs with an expiration date
- Automatically re-enable detection enforcement when the expiration date passes
- Track which detections are being ignored and why

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `scan-results-file` | Path to the scan results JSON file from HiddenLayer Model Scanner | Yes | - |
| `hiddenlayer-file` | Path to the `.hiddenlayer` ignore configuration file | No | `.hiddenlayer` |

## Outputs

| Output | Description |
|--------|-------------|
| `has-actionable-detections` | Boolean indicating whether there are detections that are not ignored or have expired ignores |
| `actionable-rule-ids` | Comma-separated list of rule IDs that should be actioned (not ignored or expired) |
| `ignored-rule-ids` | Comma-separated list of rule IDs that are currently ignored (not expired) |

## .hiddenlayer File Format

The `.hiddenlayer` file should be in YAML format:

```yaml
ignore:
  RULE_ID_1:
    reason: "Description of why this rule is being ignored"
    expires: "YYYY-MM-DD"
  RULE_ID_2:
    reason: "Another reason"
    expires: "YYYY-MM-DD"
```

### Example:

```yaml
ignore:
  JSON_0001_202504:
    reason: "Accepting the risk of repo sideloading for this project"
    expires: "2024-12-25"
  PICKLE_001:
    reason: "Known safe pickle file used for model serialization"
    expires: "2025-06-30"
```

## How It Works

1. The action reads all detection rule IDs from the scan results JSON file
2. For each rule ID, it checks if it exists in the `.hiddenlayer` ignore file
3. If the rule is in the ignore file:
   - It compares the current date with the expiration date
   - If the current date is before or equal to the expiration date, the rule is ignored
   - If the expiration date has passed, the rule becomes actionable again
4. Rules not in the ignore file are always considered actionable

## Usage Example

```yaml
- name: Check HiddenLayer ignores
  id: check-ignores
  uses: ./.github/workflows/v2/actions/check-hiddenlayer-ignores
  with:
    scan-results-file: scan_results.json
    hiddenlayer-file: .hiddenlayer

- name: Enforce scan detections
  if: steps.check-ignores.outputs.has-actionable-detections == 'true'
  run: |
    echo "::error::Security vulnerabilities detected that are not ignored or have expired ignores"
    echo "::error::Actionable rule IDs: ${{ steps.check-ignores.outputs.actionable-rule-ids }}"
    exit 1
```

## Notes

- Dates are compared using bash date comparison (`YYYY-MM-DD` format)
- The action treats the expiration date inclusively (detections are ignored through the end of the expiration date)
- The action requires `yq` for parsing YAML files and will install it if not present
- If no `.hiddenlayer` file is found, all detections are considered actionable 