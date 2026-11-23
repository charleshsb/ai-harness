---
paths:
  - "**/*.tsx"
---

# React Render Cost

Keep unnecessary renders and refetches out while writing the component. Detecting and
ranking such problems in a diff is the performance pass of the `review` skill; structure is `typescript-react`.

## Stable references where they matter

- Wrap a context provider's value in `useMemo`; otherwise every consumer re-renders each
  time the provider does.
- Do not create a new function inline for each row of a long list when the row is
  memoized; the new reference defeats the memoization.

## Memoize with evidence

- `useMemo` for computations that are measurably expensive. For cheap ones the hook costs
  more than the work.
- `useCallback` when the function feeds another hook's dependencies or a memoized child.
- `React.memo` after profiling shows the re-render is a problem. Otherwise it only adds
  noise.

## Limit what re-renders

- If a small piece of state re-renders a large tree, move the state down or split the
  component.
- Render list items through a memoized item component, so changing one row does not
  repaint the rest.
- Keep fast-changing values (text typed into an input) out of context.

## Data fetching

- Go through a caching layer (React Query, SWR or similar). A raw fetch in an effect has no
  cache and no de-duplication, so each mount asks again.
- Give a query a sensible `staleTime` when the data does not change every second; the
  default refetches on every focus.
- After a mutation, invalidate the related `queryKey`, or the screen shows stale data.

## Assets

- Render pictures through the framework's own image component, which handles lazy loading and sizing. Shipping the
  full-resolution file into a thumbnail is paid by every visitor.

## Example

```tsx
const value = useMemo(() => ({ session, signOut }), [session, signOut])
return <SessionContext.Provider value={value}>{children}</SessionContext.Provider>

const MessageRow = React.memo(function MessageRow({ message, onOpen }: MessageRowProps) {
  return <li onClick={() => onOpen(message.id)}>{message.subject}</li>
})
```

```tsx
return <SessionContext.Provider value={{ session, signOut }}>{children}</SessionContext.Provider>
// new object each render: every consumer re-renders with it

const total = useMemo(() => price + shipping, [price, shipping])
// addition is cheaper than the hook that wraps it
```
