# Issues Log

## Summary
This repository encountered a persistent issue with running the security workflow during GitHub Actions. The problem lies in a mismatch between the Solidity compiler version specified in the `Marketplace.sol` contract and the compiler version used by the analysis tool (`slither`). Resolution efforts have been deferred due to the repository being for practice purposes.

---

## Details
### Issue
- **Error**: `Source file requires different compiler version (current compiler is 0.5.16+commit.9c3226ce.Linux.g++ - note that nightly builds are considered to be strictly less than the released version)`
- **Root Cause**: A conflict between the Solidity version specified in the contract (`pragma solidity ^0.8.28;`) and the environment used by `slither`.

### Efforts Taken to Resolve
1. **Adjusted YAML Workflow**: Updated the `security.yml` file to explicitly set the `solc` version to `0.8.28`.
2. **Environment Cleanup**: Removed conflicting versions of `solc` locally and attempted to enforce the correct version in CI/CD.
3. **Debugging Steps**:
   - Verified Solidity version compatibility locally.
   - Ensured correct imports and paths for OpenZeppelin contracts.
   - Reinstalled Python SSL certificates to resolve dependency errors.

### Outcome
The error persisted due to underlying issues with the CI/CD environment and potential conflicts in the setup of `slither` despite extensive troubleshooting. Further time investment was deemed unnecessary given the repository's purpose as a learning exercise.
    
---

## Resolution
- **Status**: Marked as “Won’t Fix”.
- **Recommendation**:
  - Future projects should use containerized or isolated environments for Solidity analysis to avoid compiler conflicts.
  - Use Docker-based workflows or pre-built CI/CD templates for Solidity projects.
  - Document dependencies explicitly in the repository for reproducibility.

---

## Notes
This issue remains documented here for transparency and as a reference for potential future debugging.

