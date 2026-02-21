# Creating a "deployment-checklist" Skill from Scratch

This example walks through the complete process of creating a new skill called `deployment-checklist` that helps teams verify all steps before deploying to production.

---

## Step 1: Create Skill Directory

```bash
cd .claude/skills
bash skill-creator/scripts/create-skill.sh deployment-checklist
```

**Output:**
```
✅ Created skill directory: deployment-checklist
✅ Created SKILL.md from template
✅ Created REFERENCE.md
✅ Created directories: scripts/, templates/, examples/
```

---

## Step 2: Write SKILL.md

Open `.claude/skills/deployment-checklist/SKILL.md` and fill in the template:

```markdown
---
name: deployment-checklist
description: |
  Pre-deployment verification checklist for production releases. Validates code quality,
  security, performance, and infrastructure readiness. Use when preparing to deploy to
  production, when validating a release candidate, or when troubleshooting deployment
  failures. Includes automated checks and manual review steps.
---

## Purpose

Deployment Checklist ensures production deployments are safe, complete, and reversible by validating code, infrastructure, monitoring, and rollback procedures before release.

## When to Use

- Before deploying to production
- When creating a release candidate
- When onboarding new team members to deployment process
- After deployment failures (retroactive checklist)
- When establishing deployment procedures for a new project

## Prerequisites

- Git repository with CI/CD configured
- Production environment access
- Monitoring and alerting tools configured
- Rollback procedure documented

## Procedures

### 1. Code Quality Verification

**Automated Checks:**

1. All tests pass
   ```bash
   npm test -- --coverage
   ```

2. Linting passes with no errors
   ```bash
   npm run lint
   ```

3. Security scan completes
   ```bash
   npm audit --production
   # Or: snyk test
   ```

**Manual Review:**
- [ ] Code review approved by at least 2 team members
- [ ] No debug code or console.logs in production code
- [ ] Feature flags configured correctly
- [ ] Database migrations tested in staging

---

### 2. Infrastructure Readiness

**Checklist:**

| Item | Status | Notes |
|---|---|---|
| Database backups verified | [ ] | Last backup: _____ |
| Scaling limits checked | [ ] | Current: ____ Max: ____ |
| SSL certificates valid | [ ] | Expires: _____ |
| CDN configuration current | [ ] | Version: _____ |
| DNS records correct | [ ] | Verified: _____ |

**Commands:**
```bash
# Check database backup
aws rds describe-db-snapshots --db-instance-identifier prod-db

# Check SSL expiry
echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -dates
```

---

### 3. Monitoring and Alerting

**Verify:**
- [ ] Error tracking configured (Sentry/Rollbar)
- [ ] Performance monitoring active (New Relic/Datadog)
- [ ] Log aggregation working (CloudWatch/Splunk)
- [ ] On-call rotation current
- [ ] Alert thresholds appropriate

**Test alerts:**
```bash
# Trigger test alert
curl -X POST https://api.pagerduty.com/incidents \
  -H 'Authorization: Token token=YOUR_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{"incident":{"type":"incident_reference","title":"Test Alert"}}'
```

---

### 4. Deployment Execution

**Pre-deployment:**
- [ ] Announce deployment in team chat
- [ ] Put deployment banner on status page
- [ ] Verify rollback procedure ready

**Deployment commands:**
```bash
# Tag release
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3

# Deploy (example for Heroku)
git push production main

# Or trigger CI/CD pipeline
gh workflow run deploy-production.yml
```

**Post-deployment:**
- [ ] Verify application health check passes
- [ ] Check error rates (should not spike)
- [ ] Verify critical user flows work
- [ ] Monitor for 30 minutes

---

### 5. Rollback Procedure

**If deployment fails:**

1. Immediately rollback
   ```bash
   # Heroku example
   heroku rollback --app production-app
   
   # Or: Revert git tag and redeploy
   git revert HEAD
   git push production main
   ```

2. Check database migrations (may need manual rollback)
3. Notify team and stakeholders
4. Document failure reason
5. Schedule post-mortem

---

## Templates

- `templates/deployment-checklist-template.md` — Interactive checklist for each deployment
- `templates/rollback-procedure-template.md` — Rollback procedure template

---

## Examples

- `examples/example-deployment.md` — Complete deployment walkthrough

---

## Chaining

| Chain With | Purpose |
|---|---|
| `ci-cd-pipeline` | Set up automated deployment pipeline |
| `database-ops` | Verify database migrations before deploy |
| `security-review` | Run security audit before production release |
| `documentation-generator` | Generate release notes |

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Tests fail in CI but pass locally | Check environment variables; verify CI uses same Node version |
| Migration fails in production | Rollback deployment; test migration on production-like data |
| Health check fails after deploy | Check logs for startup errors; verify environment variables |
| Traffic spike causes outage | Rollback immediately; review scaling limits; enable rate limiting |
```

---

## Step 3: Create Template (deployment-checklist-template.md)

Create `templates/deployment-checklist-template.md`:

```markdown
# Deployment Checklist

**Release:** v____.____.____  
**Date:** ____-____-____  
**Deployer:** _______________  
**Reviewers:** _______________

---

## Pre-Deployment

### Code Quality
- [ ] All tests pass (100% required for production)
- [ ] Code review approved by 2+ team members
- [ ] Linting passes with zero errors
- [ ] Security scan passes (no high/critical vulnerabilities)
- [ ] No debug code or console.logs

### Database
- [ ] Migrations tested in staging
- [ ] Migrations are reversible
- [ ] Database backup completed within last 24 hours
- [ ] Backup verified (restore test passed)

### Infrastructure
- [ ] Scaling limits checked (CPU, memory, connections)
- [ ] SSL certificates valid (>30 days until expiry)
- [ ] CDN configuration current
- [ ] DNS records verified

### Monitoring
- [ ] Error tracking active (Sentry/Rollbar)
- [ ] Performance monitoring active (New Relic/Datadog)
- [ ] Log aggregation working
- [ ] On-call rotation current
- [ ] Alert thresholds appropriate for release

---

## Deployment

### Execution
- [ ] Team notified in #deployments channel
- [ ] Status page banner posted
- [ ] Deployment started at: ___:___ (time)
- [ ] Deployment completed at: ___:___ (time)

### Verification
- [ ] Health check passes: `curl https://api.example.com/health`
- [ ] Error rate normal (< 1%)
- [ ] Response time normal (p95 < 500ms)
- [ ] Critical user flows tested:
  - [ ] User login
  - [ ] Main feature X
  - [ ] Payment flow
  - [ ] Other: _______________

### Monitoring (30 minutes post-deploy)
- [ ] Error rate stable
- [ ] No alert spikes
- [ ] CPU/memory usage normal
- [ ] Database query performance normal

---

## Post-Deployment

- [ ] Deployment announced in #general
- [ ] Status page banner removed
- [ ] Release notes published
- [ ] Documentation updated (if needed)
- [ ] Post-deployment review scheduled (if issues occurred)

---

## Rollback

**If deployment fails:**

1. Immediately execute rollback:
   ```bash
   heroku rollback --app production-app
   ```

2. Check database migrations (manual rollback if needed)

3. Notify team: "🚨 Rollback initiated for v____"

4. Document failure reason: _______________

5. Schedule post-mortem within 24 hours

---

**Sign-off:** _______________  
**Status:** `[ ] Success  [ ] Rolled Back  [ ] Partial (explain): _______________`
```

---

## Step 4: Create Example (example-deployment.md)

Create `examples/example-deployment.md`:

```markdown
# Example: Deploying TaskFlow v1.2.3

Real-world deployment walkthrough for TaskFlow SaaS application.

---

## Context

**Release:** v1.2.3  
**Date:** 2024-03-15  
**Deployer:** Alice (DevOps)  
**Feature:** New team collaboration feature + bug fixes

---

## Pre-Deployment Checks

### 1. Code Quality ✅

```bash
# Run tests
npm test -- --coverage
# ✅ 147 tests passed, 0 failed
# ✅ Coverage: 87% (meets 85% threshold)

# Linting
npm run lint
# ✅ No errors found

# Security scan
npm audit --production
# ✅ 0 vulnerabilities
```

### 2. Database Migrations ✅

Migrations to run:
- `002_add_team_memberships_table.sql`
- `003_add_collaboration_permissions.sql`

```bash
# Test in staging
npm run migrate:staging
# ✅ Migrations applied successfully

# Verify rollback works
npm run migrate:rollback:staging
npm run migrate:staging
# ✅ Rollback successful
```

### 3. Infrastructure ✅

```bash
# Check database backup
aws rds describe-db-snapshots --db-instance-identifier taskflow-prod | jq '.DBSnapshots[0]'
# ✅ Last backup: 2024-03-15 02:00 UTC (automated)

# Check SSL
echo | openssl s_client -servername taskflow.com -connect taskflow.com:443 2>/dev/null | openssl x509 -noout -dates
# notAfter=May 15 23:59:59 2024 GMT
# ✅ Valid for 61 more days

# Check scaling limits
kubectl top pods -n production
# ✅ Current: 8 pods, Max: 20 pods, CPU: 45% avg
```

### 4. Monitoring ✅

- [x] Sentry configured (last event: 2 hours ago)
- [x] Datadog dashboard shows green
- [x] CloudWatch logs streaming
- [x] On-call: Bob (primary), Carol (secondary)

---

## Deployment Execution

### 15:00 UTC: Start Deployment

```bash
# 1. Announce in Slack
# Message: "🚀 Deploying v1.2.3 to production. ETA: 15 minutes."

# 2. Post status banner
curl -X POST https://api.statuspage.io/v1/pages/PAGE_ID/incidents \
  -H "Authorization: OAuth YOUR_TOKEN" \
  -d "name=Scheduled Deployment" \
  -d "status=investigating" \
  -d "message=Deploying v1.2.3, brief downtime expected"

# 3. Tag release
git tag -a v1.2.3 -m "Team collaboration feature + bug fixes"
git push origin v1.2.3

# 4. Trigger deployment
gh workflow run deploy-production.yml --ref v1.2.3
```

### 15:05 UTC: Deployment In Progress

```bash
# Watch deployment
gh run watch

# Monitor logs in real-time
kubectl logs -f deployment/taskflow-api -n production
```

### 15:12 UTC: Deployment Complete

```bash
# Health check
curl https://api.taskflow.com/health
# Response: {"status":"healthy","version":"1.2.3"}
# ✅ Deployment successful
```

---

## Post-Deployment Verification

### Immediate Checks (15:15 UTC)

```bash
# 1. Error rate
# Datadog: 0.3% error rate (normal baseline)
# ✅ No spike

# 2. Response time
# Datadog: p95 latency 320ms (normal is 300-400ms)
# ✅ Normal

# 3. Test critical flows
curl -X POST https://api.taskflow.com/auth/login \
  -d '{"email":"test@example.com","password":"test"}' \
  -H "Content-Type: application/json"
# ✅ Login works

# Test new feature
curl -X POST https://api.taskflow.com/teams/123/invite \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"email":"newmember@example.com"}'
# ✅ New collaboration feature works
```

### 30-Minute Monitoring (15:45 UTC)

| Metric | Before Deploy | After Deploy | Status |
|---|---|---|---|
| Error rate | 0.2% | 0.3% | ✅ Normal variation |
| P95 latency | 310ms | 320ms | ✅ Within threshold |
| CPU usage | 43% | 45% | ✅ Normal |
| Memory usage | 62% | 64% | ✅ Normal |
| Active users | 1,247 | 1,289 | ✅ Growing (expected) |

**Alerts:** None triggered  
**Sentry errors:** No new error types  
**User reports:** No complaints

---

## Post-Deployment

### 16:00 UTC: All Clear

```bash
# 1. Resolve status page incident
curl -X PATCH https://api.statuspage.io/v1/pages/PAGE_ID/incidents/INCIDENT_ID \
  -d "status=resolved" \
  -d "message=Deployment successful, all systems operational"

# 2. Announce success
# Slack message: "✅ v1.2.3 deployed successfully. New team collaboration feature is live!"

# 3. Update release notes
gh release create v1.2.3 --notes "
## What's New
- Team collaboration feature (invitations, permissions)
- Fixed bug in task sorting
- Improved API response times

## Deployment Notes
- No database downtime
- Deployed at: 2024-03-15 15:12 UTC
- Verified by: Alice
"
```

---

## Lessons Learned

**What went well:**
- Migrations tested thoroughly in staging
- No issues during deployment
- Monitoring caught normal traffic patterns immediately

**What could improve:**
- Should have notified users 24 hours in advance (some didn't see status banner)
- Could automate health check verification

**Action items:**
- [ ] Add email notification 24h before deployments
- [ ] Create automated health check script for post-deploy
- [ ] Document new collaboration feature in user guide

---

This deployment was successful with zero incidents. Total downtime: 0 minutes.
```

---

## Step 5: Validate Skill

Use the validation checklist from `skill-creator`:

- [x] `name` is lowercase-hyphens, max 64 chars ✅ `deployment-checklist`
- [x] `description` includes WHAT and WHEN ✅ Describes purpose and 4+ scenarios
- [x] Body under 500 lines ✅ SKILL.md is ~200 lines
- [x] At least 1 example ✅ `example-deployment.md` created
- [x] Procedures numbered and actionable ✅ 5 procedures with clear steps
- [x] Troubleshooting table ✅ 4 common issues with solutions
- [x] Chaining section ✅ Links to 4 related skills
- [x] No hardcoded frameworks ✅ Examples show Heroku/K8s/generic
- [x] All file references relative ✅ Templates/examples referenced correctly

---

## Step 6: Test the Skill

### Invoke the skill manually

```bash
# In Claude Code chat
/deployment-checklist
```

Claude should load the skill and ask: "Are you preparing for a production deployment? I can guide you through the pre-deployment checklist."

### Test skill discovery

Ask Claude (without slash command):

> "I'm about to deploy to production. What should I check?"

Claude should automatically discover and invoke `deployment-checklist` skill based on the description keywords.
