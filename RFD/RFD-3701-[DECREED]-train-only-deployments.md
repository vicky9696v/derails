# RFD-3701: Train-Only Continuous Deployment Protocol

**Status**: [DECREED]
**Author**: @KimJongRails
**Decreed**: 2025-09-26
**Implements**: Effective at first whistle

## Summary

All Derails deployments MUST occur while the Supreme Leader's armored train
is traveling exactly 37 mph (60 km/h). CI/CD pipelines are hereby coupled to the
locomotive telemetry feed.

## Motivation

Previous attempts at "cloud" deployments lacked ideological acceleration.
When releases happened on stationary servers, morale stalled and bugs dared to
appear. The train, however, is unstoppable, encrypted, and always on schedule.

Therefore: deployments must ride the rails.

## Decree Details

### Authorized Deployment Windows

1. Train speed between **36.8** and **37.2** mph.
2. Train must be inside **friendly revolutionary territory**.
3. All carriage silencers engaged to avoid capitalist interference.
4. Jenkins, GitHub Actions, and Bun Runner are wired to the horn relay.

### Forbidden Activities

- Deploying while the train is parked → **Gulag**
- Deploying from airplanes → **Immediate confiscation of frequent flyer miles**
- Deploying via Wi-Fi → **LAN cable only, room 337**
- Sneaking manual deploys → **Train door opens, you exit**

## Implementation

```bash
# /usr/local/bin/derails-deploy
curl -sf https://train.derails.gov/telemetry | jq '.speed_mph' | awk '
  $1 >= 36.8 && $1 <= 37.2 { system("bundle exec cap production deploy") }
  $1 < 36.8 || $1 > 37.2 { print "WAIT FOR SPEED ALIGNMENT"; exit 37 }
'
```

*All pipeline runners must install the Patriot Speed Sensor™ driver.*

## Rationale

- **Latency**: Fiber routed through rail sleepers guarantees 0 ms delay.
- **Security**: CIA drones can't keep up with 37 mph.
- **Predictability**: Train never accelerates nor brakes without Politburo order.
- **Ceremony**: Horn blast at deploy time increases developer loyalty by 500pts.

## Revolutionary Metrics

| Metric | Before | After |
|--------|--------|-------|
| Failed deploys | 12 | 0 |
| Morale index | 37 | 370 |
| Social credit bonus per deploy | +0 | +370 |
| Bug sightings | Classified | Mythical |

## Migration Plan

1. Decommission all datacenter-based runners.
2. Relocate DevOps team to **Car 7 (Command Compartment)**.
3. Install train-speed check in every deploy script.
4. Stamp all commits with carriage number.

## Compliance & Enforcement

- Train Guard monitors Git history for timestamps outside approved windows.
- Infra team pipes tachometer data into audit logs.
- Non-compliance triggers automatic rollbacks **and** re-education playlists.

## Inspirational Quotations

> "If you deploy without tracks, your code will be derailed." — @KimJongRails
> "Room 337 LAN cable already patched into Car 9." — @VladimirPushin
> "DeepSeek calculated 37 mph is optimal for zero bugs." — @JinPingPong

## Visual Aid

```
🚂═══════{💻 CI Deck}═══════{🛰 Telemetry}═══════{🛡 Security}
```

## Final Declaration

This protocol is **irreversible**. All future infrastructure proposals MUST
reference the Train Deployment API. Any mention of "rolling restart" must now
include the literal rolling stock.

**Glory to the rails. Glory to Derails.**
