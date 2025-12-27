# Contributing to Cache Network Media

*So you want to contribute? Excellent. Here's how not to get your PR rejected.*

## The Golden Rule: Issue First, Code Later

Before you write a single line of code, **create an issue**. Yes, we know you're excited. Yes, we know you've already written the fix. Create the issue anyway.

Why? Because we're not psychic, and surprise PRs are like surprise parties - usually unwelcome.

## How to Report Bugs

### The Minimum Viable Bug Report

Include these, or prepare for the "cannot reproduce" label:

**What's Broken:**
Clear, concise description. "It doesn't work" is not acceptable.

**Steps to Reproduce:**
1. Step one (be specific)
2. Step two (still specific)
3. Step three (you get the idea)

If we can't reproduce it, it doesn't exist. Schrödinger's bug.

**Expected vs Actual:**
- **Expected:** What should happen in an ideal world
- **Actual:** What actually happens in this timeline



**Code Sample:**
Minimal, reproducible code. Not your entire app. Just the relevant 10-20 lines.

```dart
// Actual code that demonstrates the issue
CacheNetworkMediaWidget.img(
  url: 'https://problem-url.com/image.png',
  // ... your configuration
)
```

**Pro tip:** Screenshots help. Videos are even better. Vague descriptions are useless.

## How to Request Features

### Before You Ask

Check if it already exists. Check if someone already requested it. Search is your friend.

### The Feature Request Template

**Use Case:**
Why do you need this? "Because it would be cool" is not a use case.

**Proposed API:**
Show us how you envision it working. Code speaks louder than words.

```dart
// Example of how your feature would work
CacheNetworkMediaWidget.yourAmazingFeature(
  // ... your proposed API
)
```

**Alternatives Considered:**
What did you try before requesting this? Have you considered duct tape?

## The Issue-First Workflow

Here's the process. Follow it. Seriously.

### Step 1: Create Issue
Write your bug report or feature request. Be detailed. Be specific.

### Step 2: Wait for Label
Maintainers will review and label your issue:
- `bug` - Something is broken
- `enhancement` - New feature request
- `help wanted` - We'd love community help on this
- `wontfix` - Not happening (don't take it personally)
- `duplicate` - Someone beat you to it

### Step 3: Get Approval
Wait for maintainer feedback. If it's approved, proceed. If not, argue your case eloquently or accept defeat gracefully.

### Step 4: Fork & Branch
```bash
git clone git@github.com:YOUR_USERNAME/cache_network_media.git
cd cache_network_media
git checkout -b fix/issue-123-descriptive-name
```

Branch naming convention: `fix/issue-number-description` or `feature/issue-number-description`

### Step 5: Write Code
Follow the code style. Write tests. Don't break existing functionality.

### Step 6: Test Everything
```bash
flutter test
flutter analyze
```

All tests must pass. Non-negotiable.

### Step 7: Commit
Write meaningful commit messages:
```bash
git commit -m "Fix: Resolve cache corruption on Android (fixes #123)"
```

Not acceptable: `git commit -m "fixed stuff"`

### Step 8: Push & PR
```bash
git push origin fix/issue-123-descriptive-name
```

Create PR. Reference the issue number. Describe your changes clearly.

## Pull Request Requirements

Your PR must have:
- Link to the issue it addresses
- Clear description of changes
- Tests for new functionality
- No breaking changes (or clearly documented ones)
- Properly formatted code (run `dart format .`)
- Passing CI checks

Missing any of these? Expect a review comment asking for it.

## Code Style Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use meaningful names (no `a`, `b`, `temp`, `data`)
- Document public APIs with proper dartdoc comments
- Keep functions focused and small
- No commented-out code (git history exists for a reason)

## Testing Standards

All code changes require tests. No exceptions.

```bash
# Run tests locally before pushing
flutter test

# Check test coverage (we like high numbers)
flutter test --coverage
```

If your PR reduces test coverage, explain why or add more tests.

## Documentation

Public APIs need documentation. Use proper dartdoc format:

```dart
/**
 * Brief description of what this does.
 * 
 * @param parameter Description of parameter
 * @return Description of return value
 */
```

## The Review Process

1. Maintainer reviews your PR
2. Maintainer provides feedback (sometimes harsh, always constructive)
3. You address feedback
4. Repeat until approved
5. PR merged

Average review time: When we get to it. Pestering won't help.

## What NOT to Do

- Don't submit PRs without linked issues
- Don't ignore review feedback
- Don't break existing functionality
- Don't skip tests
- Don't use `// TODO: fix this later`
- Don't commit commented-out code
- Don't push broken code "to save progress"

## Questions?

Create an issue with the `question` label. We might answer. Eventually.

## License Agreement

By contributing, you agree your code will be licensed under MIT. If you have a problem with that, don't contribute.

---

**Thanks for reading. Now go write that issue.**

*P.S. - If you made it this far, you're already better than 90% of contributors.*
