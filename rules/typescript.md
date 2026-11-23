---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript Types

The type system is only useful if the compiler is allowed to say no. These constraints keep
it strict. Component structure is in `typescript-react`.

## Compiler

- `strict: true` in `tsconfig.json`, plus `noUncheckedIndexedAccess`.
- A suppression (`@ts-expect-error`, `@ts-ignore`) carries its reason on the same line.
  Prefer `@ts-expect-error`: it fails when the error disappears. `@ts-nocheck` is not used.

## Annotations

- Exported functions declare their return type; all parameters are typed.
- Let inference handle obvious local variables.
- Use `unknown` for values of unknown shape and narrow them with a guard or a schema.
  `any` is not used.
- An `as` assertion is acceptable only where data enters the program (a parsed response),
  with a note explaining why it holds. Never chain `as unknown as T` to quiet an error;
  fix the type.

## Shapes

- `interface` for object shapes meant to be extended or implemented; `type` for unions,
  intersections, mapped and conditional types. Stay consistent within a module.
- Model "one of several" as a discriminated union, not a bag of optional fields.
- Prefer string-literal unions to `enum`; `enum` emits runtime code and is only for interop.

## Absence

- Use `?.` and `??` rather than hand-written checks.
- Avoid the non-null assertion `!`; use it only when the type cannot express a guarantee
  you can prove.
- A function returns `null` or `undefined` for "nothing", not both.

## Names and visibility

- `#name` is a private field enforced while the program runs: use it for state that nothing
  outside the class may reach. The `private` keyword is dropped from the compiled
  JavaScript, so only the compiler respects it.
- Never give a local variable the name of a runtime global your code relies on (`window`,
  `document`, `location`, `history`, `process`, `name`, `event`). The local shadows the global
  from that line to the end of the block, and a later line aimed at the global quietly gets
  the local.

## Generics

- Descriptive names (`TRecord`, `TResult`) for domain generics; single letters only for
  generic utilities.
- A function used with one type does not need a type parameter.

## Banned shapes

`Function`, `Object`, `{}` as a type, and `Array<any>`. Write the real signature, a
`Record<string, unknown>`, a named interface, or a typed element.

## Example

```ts
type PaymentStatus = "pending" | "settled" | "refunded"

type Payment =
  | { status: "pending"; dueAt: Date }
  | { status: "settled"; settledAt: Date }
  | { status: "refunded"; settledAt: Date; refundedAt: Date }

export function findPayment(payments: readonly Payment[], status: PaymentStatus): Payment | undefined {
  return payments.find((payment) => payment.status === status)
}

function parseQuote(raw: unknown): Quote {
  if (!isQuote(raw)) throw new QuoteParseError("unexpected quote payload")
  return raw
}

class Session {
  #token: string                     // unreachable from outside, even from plain JavaScript
  constructor(token: string) { this.#token = token }
}

function describeVisit(visit: Visit): string {
  const pageLocation = visit.location // does not hide window.location
  return `${visit.user} at ${pageLocation}`
}
```

```ts
export function findPayment(payments, status) {          // implicit any, no return type
  return payments.find((p: any) => p.status == status)
}

const quote = (await res.json()) as any                  // silences the compiler, checks nothing
// @ts-ignore
legacyCall(quote)                                        // no reason given
```
