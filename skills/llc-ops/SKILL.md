---
name: llc-ops
description: California single-member LLC compliance reminders, tax deadlines, and operational checklists. Use this to check upcoming deadlines or generate an invoice.
tier: basic
---

# LLC Ops — California Single-Member LLC

## Model

- **Preferred:** `claude-haiku-4.5`
- **Cost-tier fallback:** `claude-haiku-4.5` — see `/fallback-mode` (foculoom/foculoom-project#463)
- **Source of truth:** Model Routing Matrix in `.github/skills/dev-session/SKILL.md`

Compliance reminders and operational checklists for a California single-member LLC (disregarded entity for federal tax purposes).

> ⚠️ **Reminder only.** This skill surfaces deadlines and checklists. It does NOT file taxes, make payments, or take any autonomous action. Per `agents/approval-policy.md`, tax filing and payment are **Never Autonomous**. The founder executes all actions.

> ⚠️ **Current-source verification required.** Before giving deadline-specific advice,
> verify the current filing dates and requirements on official sources (IRS, FTB,
> CA Secretary of State, and Apple Developer docs where applicable). If current-year
> dates cannot be verified in-session, label guidance as provisional.

## 1. Annual Compliance Calendar

### California State Filings

| Deadline | Item | Details | Where |
|----------|------|---------|-------|
| **Anniversary month** | Statement of Information (Form LLC-12) | Due every 2 years within the anniversary month of LLC formation. $20 filing fee. | [bizfileOnline.sos.ca.gov](https://bizfileOnline.sos.ca.gov) |
| **April 15** | Franchise Tax Board — $800 minimum franchise tax | Due annually. Pay via Web Pay on FTB website. Form 568 (LLC Return of Income) also due. | [ftb.ca.gov](https://www.ftb.ca.gov) |
| **June 15** | Estimated fee (Form 3536) | Only if LLC gross income ≥ $250,000. Not applicable for most solo LLCs. | [ftb.ca.gov](https://www.ftb.ca.gov) |

### Federal Tax (IRS — Disregarded Entity)

Single-member LLC is a disregarded entity. Income reported on personal Schedule C (Form 1040).

| Deadline | Item | Details |
|----------|------|---------|
| **April 15** | Form 1040 + Schedule C + Schedule SE | Annual income tax + self-employment tax |
| **April 15** | Q1 estimated tax (Form 1040-ES) | For prior-year tax period |
| **June 15** | Q2 estimated tax | |
| **September 15** | Q3 estimated tax | |
| **January 15** | Q4 estimated tax | For current-year tax period |

### California Estimated Tax (FTB)

California follows the same quarterly schedule as federal for individuals:

| Deadline | Period |
|----------|--------|
| **April 15** | Q1 (Jan–Mar) |
| **June 15** | Q2 (Apr–May) |
| **September 15** | Q3 (Jun–Aug) |
| **January 15** | Q4 (Sep–Dec) |

Pay via [FTB Web Pay](https://www.ftb.ca.gov/pay/index.html). Use voucher Form 540-ES.

## 2. Recurring Renewals

| Item | Typical Deadline | Notes |
|------|-----------------|-------|
| **Registered agent** | Varies (annual) | Check your agent provider's renewal date. Update via Statement of Information if agent changes. |
| **Apple Developer Program** | Annual (auto-renew or manual) | $99/year. Check expiry at [developer.apple.com/account](https://developer.apple.com/account). Lapsed enrollment = apps removed from App Store. |
| **Domain registration** | Annual (varies) | foculoom.com — check registrar for renewal date. |
| **Business insurance** (if applicable) | Annual | General liability, E&O if applicable. |

## 3. Quick Compliance Check

Run this checklist at the start of each quarter:

```
## Quarterly LLC Ops Check — Q_ 20__

- [ ] Estimated taxes paid (federal 1040-ES + CA 540-ES)?
- [ ] Any upcoming Statement of Information due this quarter?
- [ ] Apple Developer Program active (not expiring this quarter)?
- [ ] Registered agent current?
- [ ] Domain renewal current?
- [ ] Business insurance current (if applicable)?
```

## 4. App Store Submission Pre-Flight

Before any App Store submission, verify:

```
- [ ] Apple Developer Program is active (not expired or expiring within 30 days)
- [ ] App name, bundle ID, and description are current
- [ ] Privacy policy URL is valid and accessible
- [ ] Screenshots and preview media meet current App Store guidelines
- [ ] Age rating questionnaire is accurate
- [ ] Export compliance (HTTPS/encryption) is declared
- [ ] No test data or debug flags in the build
- [ ] Build version number is incremented
```

## 5. Invoice Template

Use this template for client or contract invoices:

```
INVOICE

From:
  <Your LLC Name>
  <Address>
  <City, CA ZIP>
  EIN: <if applicable>

To:
  <Client Name>
  <Client Address>

Invoice #: <YYYY-MM-NNN>
Date: <date>
Due: <net-30 date>

| Description              | Qty | Rate     | Amount   |
|--------------------------|-----|----------|----------|
| <Service description>    | 1   | $X.00    | $X.00    |
|                          |     |          |          |
|                          |     | **Total**| **$X.00**|

Payment: <bank transfer / check / other>
Notes: <payment terms, late fee policy if any>
```

## Notes

- This skill is California-specific. If the LLC re-domiciles, dates and forms will change.
- Verify all dates against [ftb.ca.gov](https://www.ftb.ca.gov) and [sos.ca.gov](https://www.sos.ca.gov) — tax law may change year to year.
- For complex tax questions, consult a CPA. This skill is not tax advice.
