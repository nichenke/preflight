---
type: template
doc_type: interface-contract
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# Interface Contract: [Service A] <-> [Service B]

## Meta
- Version: [semver — breaking changes = major bump]
- Owner: [team]
- Consumers: [list of consuming teams/services]
- Last Updated: [date]

## Protocol
- Transport: [HTTP/gRPC/async message/etc.]
- Format: [JSON/Protobuf/Avro/etc.]
- Authentication: [mechanism]

## Endpoints / Events / Messages
For each:
- Name/Path
- Method/Direction
- Request Schema (with types, required/optional, validation rules)
- Response Schema (with types, error codes)
- Example request/response

## SLA / Quality of Service
- Availability target
- Latency targets (p50, p95, p99)
- Rate limits
- Retry policy (from consumer side)
- Timeout recommendations

## Error Handling
- Error code taxonomy
- Retry-safe vs non-retry-safe operations
- Circuit breaker recommendations

## Versioning Policy
- How breaking changes are communicated
- Deprecation timeline
- Backward compatibility guarantees

## Changelog
| Version | Date | Changes | Breaking? |
|---------|------|---------|-----------|
