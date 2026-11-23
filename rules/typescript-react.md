---
paths:
  - "**/*.tsx"
  - "**/use[A-Z]*.ts"
---

# React Components

How to structure components, props, state, hooks and effects. Types are covered in
`typescript`, rendering cost in `typescript-react-perf`.

## Components

- One component per file, the file named after it in PascalCase. Keep its styles, tests and
  types alongside.
- Inside, keep a steady order: hooks, derived values, handlers, JSX.
- Rules and calculations do not live in the component; move them to a custom hook or a
  plain module. The component decides what to show.
- Split a component as it nears 150 lines or starts to carry two jobs.
- Name every component: an anonymous one leaves a stack trace with nothing to point at.

## Props

- Declare a named props interface above the component and destructure in the signature.
- `children` is typed `React.ReactNode`.
- Pass the single field a child needs, not the whole object it came from.
- Props are never mutated.
- Past two levels of pass-through, use context or lift the state.
- Use boolean shorthand (`<Dialog open />`).
- An exported component returns `React.ReactElement | null`; return `null` rather than an
  empty fragment when there is nothing to draw.

## State

- Choose by scope: `useState` for one component, a query library for server data, context
  or a store when many distant components share it, otherwise lift state to the nearest
  common parent.
- Never seed state from props, and never store what can be computed during render.
- Related fields that change together go in one `useReducer` or one object.
- Handle loading and error states explicitly, and keep `queryKey` shapes consistent so
  invalidation finds them.

## Hooks and effects

- Call hooks unconditionally at the top level of the component or hook.
- Dependency arrays are complete. Do not silence the lint; if a dependency must be left
  out, a comment says why.
- An effect is for synchronizing with the outside world (subscriptions, timers, network),
  with cleanup returned. Do not use one to copy state into other state.
- One effect per concern; chains of effects are a design smell.
- A custom hook is named `useXxx`, does one thing and returns an object rather than a
  tuple, so fields can be added without breaking callers.

## Lists and handlers

- Keys come from stable ids. An array index is not a key for a list that can reorder or
  filter.
- Handlers are named `handle<Event>`. A handler with real logic is defined above the JSX.

## Accessibility

- Icon-only buttons have an `aria-label`.
- Every input has a `<label>`.
- Interactive elements work with the keyboard.

## Example

```tsx
interface TaskListProps {
  tasks: Task[]
  onToggle: (taskId: string) => void
}

export function TaskList({ tasks, onToggle }: TaskListProps): React.ReactElement | null {
  const [filter, setFilter] = useState("")
  const visibleTasks = tasks.filter((task) => task.title.includes(filter))   // derived

  if (visibleTasks.length === 0) return null

  return (
    <ul>
      {visibleTasks.map((task) => (
        <TaskRow key={task.id} task={task} onToggle={onToggle} />
      ))}
    </ul>
  )
}
```

```tsx
export default function ({ tasks }) {
  const [visible, setVisible] = useState(tasks)            // state copied from props

  useEffect(() => {
    setVisible(tasks.filter((task) => task.open))          // state derived from state
  }, [])                                                   // stale: dependencies missing

  return visible.map((task, index) => <li key={index}>{task.title}</li>)
}
```
