# Contract Hardening Audit

Use this audit only when a review finding affects structured-data validation, normalization, an external format, publication,
or durable state. Select the checks relevant to the changed contract; do not expand an unrelated fix merely to exhaust the
list.

- Map each affected repository safety principle to concrete code, test, schema, or canonical-document evidence.
- Inventory affected fields and relevant same-typed siblings. Distinguish structural validity, semantic readiness,
  external-format bounds, canonical identity, and downstream representation.
- Define intentionally equivalent normalized representations. Verify that equivalent values collide, distinct accepted values
  do not collide, and unsupported precision or encodings are rejected before identity reuse.
- Derive numeric ranges, precision, lengths, and encodings from the authoritative wire format or contract. Test the minimum,
  maximum, and first invalid value rather than host-language capacity.
- Trace duplicated and derived fields to one source of truth. Where contradictions are possible, mutate each copy independently
  and verify rejection in publishable states.
- Exercise relevant public entry points through parsing, normalization, validation, serialization, and publication. Convert
  malformed but schema-shaped input to a domain error without leaking a raw exception.
- If failure can leave artifacts, verify that existing data remains intact, success and failure remain distinguishable,
  residual artifacts are identifiable, and inspection or retry can converge without guessing. Document and test that state.
- For required text fields, cover the relevant empty-string, ASCII-whitespace, line-break, and Unicode-whitespace cases. Preserve
  invalid evidence in review or diagnostic states when the product contract requires it.
