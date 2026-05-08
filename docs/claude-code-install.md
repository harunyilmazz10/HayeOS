# Claude Code Install

## A. Development/test

Use this when editing or validating the local checkout:

```bash
claude --plugin-dir /Users/haye/Desktop/HayeeOS
```

## B. Permanent local marketplace install

Use this when you want Haye commands available in normal `claude` sessions without passing `--plugin-dir`.

```text
claude
/plugin marketplace add /Users/haye/Desktop/HayeeOS
/plugin install haye@haye-marketplace
```

Expected commands after install:

```text
/haye:start
/haye:work
/haye:fix
/haye:secure
/haye:ship
/haye:close
```

The marketplace manifest lives at `.claude-plugin/marketplace.json`, and the `haye` plugin source points to the repository root with `./`.

## C. GitHub marketplace install

Claude Code marketplace add accepts a URL, path, or GitHub repo. After the GitHub repository contains `.claude-plugin/marketplace.json`, use:

```text
claude
/plugin marketplace add https://github.com/harunyilmazz10/HayeOS.git
/plugin install haye@haye-marketplace
```

If your Claude Code build requires GitHub shorthand instead of a full URL, use:

```text
claude
/plugin marketplace add harunyilmazz10/HayeOS
/plugin install haye@haye-marketplace
```
