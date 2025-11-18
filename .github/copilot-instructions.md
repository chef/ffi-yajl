# AI / Copilot Operational Instructions

> This document defines the canonical, repeatable workflow for AI-assisted contribution to this repository. It is designed for iterative, prompt-driven development with Jira integration, strict DCO compliance, test coverage enforcement, and guarded CI/release automation.

---
## 1. Purpose
Provide a definitive, actionable reference so that an AI assistant (or human following structured prompts) can:
- Intake a Jira issue or freeform task
- Derive and confirm an implementation plan
- Implement changes with tests and coverage > 80%
- Maintain coding, style, and policy compliance
- Prepare a DCO-signed, well‑structured Pull Request
- Respect protected files, security guardrails, and release automation (Expeditor)
- Interact in small, confirmable steps (always asking: "Continue to next step? (yes/no)")

---
## 2. Repository Structure (Concise)
```
/CHANGELOG.md                # Project changelog (updated by Expeditor automation)
/CODE_OF_CONDUCT.md          # Community code of conduct (protected)
/LICENSE                     # MIT License (protected)
/MIT-LICENSE                 # Legacy MIT license reference
/README.md                   # Project overview & usage
/VERSION                     # Current gem version (bumped by Expeditor)
/Rakefile                    # Build, spec, style, extension tasks
/Gemfile                     # Gem dependencies (development/test)
/ffi-yajl.gemspec            # Primary gemspec
/ffi-yajl-universal-mingw-ucrt.gemspec  # Windows universal gemspec
/bin/ffi-yajl-bench          # Benchmark executable
/ext/ffi_yajl/ext/{encoder,parser,dlopen}/ # C extensions sources & extconf
/lib/ffi_yajl.rb             # Main entrypoint loader
/lib/ffi_yajl/**             # Ruby layer (encoder, parser, platform, FFI bindings)
/lib/ffi_yajl/benchmark/**   # Benchmark scripts & subjects
/spec/**                     # RSpec tests
/.expeditor/**               # Expeditor release automation config & scripts
/.github/workflows/*.yml     # GitHub Actions CI (lint, unit tests, stub aggregator)
/.github/PULL_REQUEST_TEMPLATE.md # Default PR template
/.github/CODEOWNERS          # Ownership & review rules (protected)
/.github/lock.yml            # (Org/repo config locking policy)
/.reek.yml                   # Reek configuration (if used for smell linting)
/.rubocop.yml                # Cookstyle / RuboCop config
/.travis.yml                 # Legacy CI (not primary now)
```
(Excluded: build artifacts, vendored bundle path `vendor/bundle`, temporary directories.)

---
## 3. Tooling & Ecosystem
- Language: Ruby (C extensions + FFI). Ruby versions tested: 3.1, 3.4 (matrix includes Windows).
- Test Framework: RSpec (tasks: `rake spec`, environment variable `FORCE_FFI_YAJL` toggles extension vs FFI mode). Composite spec task runs both variants.
- Style / Lint: Cookstyle (RuboCop) via `rake style` and GitHub Action `lint.yml`.
- Build / Compile: `rake compile` builds C extensions via `rake-compiler` / `Rake::ExtensionTask`.
- Benchmarks: Located in `lib/ffi_yajl/benchmark/*` (not required for normal test coverage but useful for performance investigations).
- Release Automation: Expeditor (.expeditor) handles version bump, changelog, gem build, publish on merge to release branch.
- CI Pipelines:
  - `lint.yml`: Runs Cookstyle.
  - `unit-test.yml`: Runs specs across OS (currently Windows) and Ruby versions.
  - `ci-main-pull-request-checks.yml`: Stub invoking centralized org workflow for broader compliance scans (secret scanning, SBOM, optional SAST/SCA, complexity checks). Many features currently disabled via inputs.
- Coverage Tooling: Not explicitly configured; if adding coverage enforcement, integrate `simplecov` (see Testing & Coverage section) while keeping threshold > 80%.

---
## 4. MCP (Jira) Integration
All Jira interactions MUST use the atlassian-mcp-server MCP endpoint (not raw REST calls in code here). Standardized pattern:
1. Obtain Jira ID (e.g., ABC-123) from user or context.
2. Invoke MCP: `atlassian-mcp getIssue ABC-123` (conceptually; actual tool invocation performed by assistant tooling environment, not committed to repo).
3. Parse fields:
   - Summary
   - Description
   - Acceptance Criteria (scan description for "Acceptance Criteria", bullet lists, Gherkin, or AC headings)
   - Story Points (if present)
   - Linked issues (blocks, relates, duplicates)
4. Produce Structured Plan:
   - Design Overview
   - Impacted Files (exact relative paths)
   - Data / API Changes (if any)
   - Test Strategy (unit, edge cases, negative tests)
   - Edge Cases (list explicitly)
   - Risks & Mitigations
5. Output plan + ask: "Continue to next step? (yes/no)".
6. Only proceed after explicit "yes".

When no Jira ID is provided, treat task as freeform and still build a structured plan using the same categories.

---
## 5. Workflow Overview (Canonical Sequence)
1. Intake & Clarify
2. Repo Analysis (structure, dependencies, tests)
3. Implementation Plan Draft (with test approach)
4. User Confirmation
5. Branch Creation (Jira ID as branch name; fallback slug if none)
6. Incremental Implementation (small cohesive changes)
7. Add / Update Tests
8. Run Specs (both FFI and ext variants) + (optional) Coverage
9. Style / Lint Fixes
10. Commit (DCO signed)
11. Push Branch
12. Open PR (HTML sections; link Jira)
13. Apply Labels (mapping + repository-specific)
14. Await Reviews / Address Feedback Iteratively
15. Final Validation (CI green, coverage ≥ 80%)

Each major step must end with:
- Step Summary
- Remaining Steps Checklist (checked/unchecked)
- Prompt: "Continue to next step? (yes/no)"

---
## 6. Detailed Step Instructions
### 6.1 Intake & Clarify
- Collect: Jira ID (if any), problem statement, constraints, acceptance criteria.
- If Jira ID: fetch via MCP and parse.
- Output structured plan; request confirmation.

### 6.2 Repo Analysis
- Confirm extension build impact if touching C code (`ext/ffi_yajl/ext/*`).
- Identify test files to add/modify under `spec/` mirroring library paths.
- Determine if new public API changes require README update.

### 6.3 Plan Implementation
Include:
- Summary
- Change List
- Affected Paths
- New Types / Methods Signatures (if adding Ruby classes/modules)
- Test Plan (unit + negative + edge)
- Coverage Strategy (identify files with low or missing tests)
- Risk Matrix

### 6.4 Confirm Plan
Ask for explicit approval: "Continue to next step? (yes/no)".

### 6.5 Branching
```
# Branch name must be EXACT Jira ID (e.g., ABC-123) or fallback kebab slug
git fetch origin
git checkout -b ABC-123
```
If branch exists, reuse: `git checkout ABC-123`.

### 6.6 Implementation Cycle
For each atomic change group:
1. Modify library code under `lib/` or C sources under `ext/`.
2. Update or create corresponding specs (`spec/ffi_yajl/..._spec.rb`).
3. Run build & specs:
   ```
   bundle install
   rake compile
   bundle exec rake spec   # runs both ffi + ext variants unless jruby platform
   ```
4. (Optional) Coverage (if `simplecov` added): ensure ≥ 80%.
5. Address failures before proceeding.

### 6.7 Lint / Style
```
bundle exec rake style
```
Fix offenses; do not disable cops unless justified and documented.

### 6.8 Commit (DCO)
Each commit message format:
```
<scope>: <concise imperative summary> (ABC-123)

Detailed body explaining rationale, risks, alternatives.

Signed-off-by: Full Name <email@example.com>
```
Assistant MUST refuse to produce commits without sign-off.

### 6.9 Push & PR
```
git push -u origin ABC-123
```
Create PR with GitHub CLI:
```
gh pr create --head ABC-123 --fill
```
Then update description (append HTML template) if not auto-filled:
```html
<h2>Summary</h2>
<h2>Jira</h2>
<p><a href="https://your-jira/browse/ABC-123">ABC-123</a></p>
<h2>Changes</h2>
<ul>
  <li>...</li>
</ul>
<h2>Tests & Coverage</h2>
<p>Coverage: X% (delta: +Y%). All critical paths tested.</p>
<h2>Risk & Mitigations</h2>
<h2>DCO</h2>
<p>All commits signed-off.</p>
```

### 6.10 Label Application
Apply labels mapping story type (e.g., bug → suitable aspect/performance/security). See Label Reference section.

---
## 7. Branching & PR Standards
- Branch Name: Jira ID (e.g., ABC-123). If no Jira: `task-short-slug`.
- One logical feature/fix per branch.
- PR Must Include: Tests, DCO compliance, risk assessment, coverage statement.

---
## 8. Commit & DCO Policy
- Every commit MUST contain: `Signed-off-by: Full Name <email@domain>` as the final non-empty line.
- Use `--signoff` (`-s`) when committing:
  ```
  git commit -s -m "parser: fix invalid utf8 handling (ABC-123)"
  ```
- Non-compliant commits must be amended before pushing: `git commit --amend -s --no-edit`.
- Assistant must refuse to generate or accept merges of unsigned commits.

---
## 9. Testing & Coverage
### 9.1 Running Tests
```
bundle install
rake compile
bundle exec rake spec
```
Runs both FFI and native extension specs (except on jruby where ext might be skipped).

### 9.2 Adding Coverage (Optional Enhancement)
Add to `spec/spec_helper.rb` (top) if not present:
```ruby
require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  minimum_coverage 80
  add_filter '/spec/'
end
```
Then generate report: `open coverage/index.html` (locally).

### 9.3 Coverage Enforcement Loop
1. After test run, if coverage < 80%, identify low-coverage files.
2. Add targeted specs (edge cases: invalid UTF-8, symbolization options, streaming, repeated keys).
3. Re-run spec + coverage until threshold met.

### 9.4 Edge Case Examples for This Repo
- Invalid UTF-8 input when `:validate_utf8` true/false.
- Duplicate JSON keys with `:unique_key_checking` enabled.
- Symbolizing keys vs names.
- Allowing trailing garbage / partial values.
- FFI vs ext behavior parity.

---
## 10. Labels Reference
Repository-specific labels (fetched via GitHub API):
- Aspect: Documentation – How do we use this project?
- Aspect: Integration – Works correctly with other projects or systems.
- Aspect: Packaging – Distribution of compiled artifacts.
- Aspect: Performance – Performance characteristics.
- Aspect: Portability – Platform compatibility concerns.
- Aspect: Security – Security/stability from 3rd-party interference.
- Aspect: Stability – Consistency of results.
- Aspect: Testing – Coverage / CI health.
- Aspect: UI – Interaction & visual design.
- Aspect: UX – Functional ease-of-use & accessibility.
- do not merge – Blocks merging; used for WIP or restricted changes.
- Expeditor: Bump Version Major – Request major version bump.
- Expeditor: Bump Version Minor – Request minor version bump.
- Expeditor: Skip All – Skip all automated post-merge actions.
- Expeditor: Skip Changelog – Prevent changelog update.
- Expeditor: Skip Habitat – Skip habitat packaging.
- Expeditor: Skip Omnibus – Skip omnibus build.
- Expeditor: Skip Version Bump – Prevent version increment.
- hacktoberfest-accepted – Credit for Hacktoberfest participation.
- oss-standards – OSS standardization tasks.
- Platform: AWS / Azure / Debian-like / Docker / GCP / Linux / macOS / RHEL-like / SLES-like / Unix-like – Platform targeting categorization.

Generic mapping guidance for additional common intents:
- bug/fix → Aspect: Stability or Aspect: Security (if vulnerability) + appropriate platform label
- feature/enhancement → Aspect: Performance / Integration / UX as relevant
- documentation → Aspect: Documentation
- tests → Aspect: Testing
- maintenance/chore → oss-standards or platform-specific label

---
## 11. CI / Expeditor Integration
### 11.1 GitHub Actions Workflows
- `lint.yml`: Triggers on PR + push to main. Runs cookstyle (RuboCop variant) with problem matchers.
- `unit-test.yml`: Runs RSpec across Windows (3.1, 3.4). Compiles extensions and executes `rake spec`.
- `ci-main-pull-request-checks.yml`: Stub invoking centralized org workflow (common security, complexity, SBOM, optional SAST/SCA). Many toggles currently off (e.g., build: false, unit-tests: false in stub layer). Provides secret scanning (Trufflehog) and SBOM generation.

### 11.2 Expeditor
- Triggers on PR merge to release branch (`main` or configured release branches).
- Actions pipeline: version bump → update `VERSION` & `lib/ffi_yajl/version.rb` → changelog update → gem build → publish (on promotion event).
- Labels influence version semantics (major/minor) or skip behaviors.
- Branch deletion enabled post-merge.

### 11.3 Buildkite (via Expeditor)
- `.expeditor/verify.pipeline.yml` defines matrix of Ruby versions and OS (Linux via Docker, Windows). Runs `bundle install`, compile, spec.

---
## 12. Security & Protected Files
NEVER modify without explicit authorization:
- `LICENSE`, `MIT-LICENSE`
- `CODE_OF_CONDUCT.md`
- `.github/CODEOWNERS`
- `.github/workflows/*` (unless task explicitly requests CI changes)
- `.expeditor/*` (release automation core)
- Secrets, tokens, or credential references
Guardrails:
- Do not add plaintext secrets to repo.
- Do not commit large binaries or coverage artifacts.
- Do not force-push to `main` or release branches.

---
## 13. Prompts Pattern (Interaction Model)
At every major phase the assistant MUST:
1. Output a concise summary (1–3 sentences)
2. Show remaining checklist with status marks (e.g., `[x]` / `[ ]`)
3. Ask: `Continue to next step? (yes/no)`
4. Provide a recommended next prompt (e.g., "yes" or clarifying question)
No implicit progression—wait for explicit "yes".

Example Step Output:
```
Summary: Implementation plan drafted covering parser option extension and tests.
Remaining: [ ] Branch Create  [ ] Implement  [ ] Tests  [ ] Lint  [ ] Commit  [ ] PR
Continue to next step? (yes/no)
```

---
## 14. Environment Preparation
```
# Ensure Ruby (>= 3.1 recommended) installed
ruby -v

# Install bundler
gem install bundler

# Install dependencies (excluding development_extras group if defined elsewhere)
bundle install --jobs 4 --retry 3

# Compile native extensions
rake compile

# Run specs
bundle exec rake spec

# Run style
bundle exec rake style
```
Optional coverage (after adding SimpleCov): run specs then inspect `coverage/` directory.

---
## 15. Validation & Exit Criteria
A task is COMPLETE when ALL are true:
- Acceptance criteria satisfied (Jira or freeform spec)
- All modified/new code has corresponding tests
- Overall coverage ≥ 80% (if enforced) and no critical untested paths
- Lint/style passes with zero unaddressed offenses
- No unintended modifications to protected files
- CI workflows green (lint, unit tests, stub pipeline)
- PR description includes required HTML sections and Jira link (if applicable)
- All commits DCO signed
- Labels applied appropriately
- User explicitly confirms completion

---
## 16. Idempotency & Recovery
- If branch exists: reuse—do not recreate.
- If PR exists: update rather than creating duplicate.
- If partial implementation detected, diff staged vs HEAD to decide next atomic step.
- Re-running plan step should detect unchanged environment and skip redundant data gathering.

---
## 17. Risk & Mitigation Guidance (General)
| Risk | Example | Mitigation |
|------|---------|-----------|
| ABI break in C extension | Changing exported symbols | Add tests; bump version appropriately via labels |
| Performance regression | New allocation in hot parse loop | Run benchmark scripts; measure delta |
| Cross-platform inconsistency | Path handling or encoding differences on Windows | Run matrix tests locally or rely on CI; add platform-guarded specs |
| UTF-8 validation edge | Incorrect replacement handling | Add explicit malformed byte sequence tests |

---
## 18. Assistant Refusal Rules
Assistant must refuse to:
- Generate unsigned commits
- Expose or request secrets
- Modify protected policy/release files without explicit request
- Merge PRs or force-push main

---
## 19. Quick Reference Commands
```
# Create branch
git checkout -b ABC-123

# Install & test
bundle install
rake compile
bundle exec rake spec

# Lint
bundle exec rake style

# Commit (DCO)
git add .
git commit -s -m "encoder: add pretty print option validation (ABC-123)"

# Push & PR
git push -u origin ABC-123
gh pr create --head ABC-123 --fill --draft

# Update PR body (if needed)
gh pr edit --body-file pr_body.html
```

---
## 20. HTML PR Description Template (Fallback)
```html
<h2>Summary</h2>
<p><!-- concise feature/fix summary --></p>
<h2>Jira</h2>
<p><a href="https://jira.example.com/browse/ABC-123">ABC-123</a></p>
<h2>Changes</h2>
<ul>
  <li>...</li>
</ul>
<h2>Tests & Coverage</h2>
<p>Coverage: XX% (delta +Y%). Critical paths covered.</p>
<h2>Risk & Mitigations</h2>
<ul>
  <li>...</li>
</ul>
<h2>DCO</h2>
<p>All commits signed-off.</p>
```

---
## 21. Jira Invocation Example (MCP)
```
# Conceptual (handled by assistant tooling, not committed):
invoke atlassian-mcp getIssue ABC-123
# Parsed Output → Plan JSON / Markdown
```
Assistant then presents structured plan and asks for confirmation.

---
## 23. Step Interaction Skeleton
Every action cycle template:
```
Summary: <what was done>
Checklist:
[ x ] Intake
[ x ] Plan
[   ] Branch
[   ] Implement
[   ] Tests
[   ] Lint
[   ] Commit
[   ] PR
[   ] Review
[   ] Final Validation
Continue to next step? (yes/no)
```

## 24. AI-Assisted Development & Compliance

- ✅ Create PR with `ai-assisted` label (if label doesn't exist, create it with description "Work completed with AI assistance following Progress AI policies" and color "9A4DFF")
- ✅ Include "This work was completed with AI assistance following Progress AI policies" in PR description

### Jira Ticket Updates (MANDATORY)

- ✅ **IMMEDIATELY after PR creation**: Update Jira ticket custom field `customfield_11170` ("Does this Work Include AI Assisted Code?") to "Yes"
- ✅ Use atlassian-mcp tools to update the Jira field programmatically
- ✅ **CRITICAL**: Use correct field format: `{"customfield_11170": {"value": "Yes"}}`
- ✅ Verify the field update was successful

### Documentation Requirements

- ✅ Reference AI assistance in commit messages where appropriate
- ✅ Document any AI-generated code patterns or approaches in PR description
- ✅ Maintain transparency about which parts were AI-assisted vs manual implementation

### Workflow Integration

This AI compliance checklist should be integrated into the main development workflow Step 4 (Pull Request Creation):

```
Step 4: Pull Request Creation & AI Compliance
- Step 4.1: Create branch and commit changes WITH SIGNED-OFF COMMITS
- Step 4.2: Push changes to remote
- Step 4.3: Create PR with ai-assisted label
- Step 4.4: IMMEDIATELY update Jira customfield_11170 to "Yes"
- Step 4.5: Verify both PR labels and Jira field are properly set
- Step 4.6: Provide complete summary including AI compliance confirmation
```

- **Never skip Jira field updates** - This is required for Progress AI governance
- **Always verify updates succeeded** - Check response from atlassian-mcp tools
- **Treat as atomic operation** - PR creation and Jira updates should happen together
- **Double-check before final summary** - Confirm all AI compliance items are completed

### Audit Trail

All AI-assisted work must be traceable through:

1. GitHub PR labels (`ai-assisted`)
2. Jira custom field (`customfield_11170` = "Yes")
3. PR descriptions mentioning AI assistance
4. Commit messages where relevant

---

## 25. Final Notes
- This file must be appended rather than overwritten if updated in future iterations.
- Changes here do not auto-modify workflows; treat as authoritative guidance for assistants.
- Keep instructions concise yet exhaustive; remove duplication only when safe.
