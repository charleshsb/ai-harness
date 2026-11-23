---
name: spec-design
description: Work out a direction with the user before any plan or specification exists. Restate the problem, compare a few genuinely different approaches, and ask one question at a time until a direction is settled. Read-only: it writes nothing and drafts no spec. Use for "let's explore this first", "help me frame this", "what are the options for X", "design this with me", or when a request is not yet framed enough to plan.
argument-hint: "[subject, ticket text or link] [+ extra context]"
allowed-tools: Read, Grep, Glob
---

# Spec Design

The conversation that comes before a plan or a specification. You restate the problem,
explore a short list of approaches that really differ, and settle on a direction together
with the user. It ends with a summary and with nothing else.

It is read-only: no file, no code, no specification, no ticket comment, no branch, no commit.
It needs no permission to start and grants none to build, because picking a direction is not
approving the work. Run it in the main conversation rather than in a sub-agent: the dialogue
is the point, and a sub-agent cannot talk to the user.

It does not replace writing a specification (the `spec` rule describes what one contains) or
making a plan.

## When to use it

- Whenever the user asks to explore or design first. An explicit request is always enough;
  do not second-guess it.
- When a request is not framed enough to plan. Use judgment: a clear, well-bounded request
  does not need it. Reach for it when exploring is the only way to:
  1. pin down what the goal is and which problem it addresses;
  2. test whether the requested solution answers the real need;
  3. compare approaches that shift scope, user experience, ownership, cost or risk;
  4. untangle decisions that depend on each other and keep the direction from settling.
- Technical complexity alone is no reason. A word like "redesign" is a hint to look, never
  proof. A small local doubt inside a settled direction (an error response, a permission, one
  transition) belongs to the plan or the spec, unless it puts the whole approach in
  question. A single question that shapes everything can justify the step; a handful of
  narrow ones cannot.

## Starting out

The subject comes from the argument, or from the conversation when it is unambiguous. With no
subject, ask which one; never invent it.

Before asking anything, gather what is already known: the need, the text of the request or
ticket, analysis already done, known constraints and decisions, and the doubt that prompted
the exploration. Do not redo work just to fill a template. If the user names a ticket you
cannot read, say so rather than guessing its content. Read code or search when that tells two
approaches apart or checks a constraint.

## The dialogue

1. Begin by restating the situation briefly: what is to be solved, what is already
   constrained, and which choice is up for exploration.
2. Ask one question at a time, each picked because its answer would change the direction.
   Scale the effort to the request; a passing idea should not become a long session.
3. Offer a few approaches that truly differ, usually two or three and never padded. When
   credible, include a lighter intervention, a prior investigation, or leaving things alone.
4. Explore first and judge second: weigh the trade-offs against the goal and the
   constraints.
5. Challenge important assumptions, without agreeing or objecting by reflex.
6. A recommendation of yours only counts as a decision once the user takes it up.

### Labels, decisions, limits

- Mark what you say as **established** (the request, the user, a rule, code read in this
  session), **inference**, **to verify**, **recommendation** or **open decision**.
- Silence does not mean agreement, and curiosity about an option does not select it. What
  the user has plainly decided is not put to them again.
- If an approach hinges on a particular field, key or API, read its definition first or label
  the approach **to verify**. Withdrawing an approved idea that turns out not to be buildable
  is embarrassing and avoidable.
- When an approach clashes with the ticket or another source, lay the clash out and let the
  user decide which prevails; the summary is not an update to the ticket.
- Should the user want to move ahead without answering, keep exploring on stated assumptions,
  and never pass a hypothesis off as the direction taken.
- A conversation and a code reading do not amount to validation by users, the market or an
  experiment.
- Leave implementation choices open when they produce the same observable result.

## How it ends

- **Direction settled.** Hand back the summary. Minor specification questions can remain
  open and are carried into the plan's open decisions or the specification itself.
- **Direction not settled.** Keep going while the user can arbitrate. If they pause, evidence
  is missing or interaction is impossible, say what blocks, print the full summary, and stop.
- **Dropped.** The user abandons the idea: stop, with nothing implemented, and print the full
  summary.

The summary lives in the conversation only. Printing it in full when you stop lets the user
carry it: resume the session, or paste it back as context.

## The summary

Sized to the request and readable without rereading the dialogue. Include what applies:

- the problem, the intended result, and who or what is affected;
- constraints, scope, and behavior that must stay;
- approaches examined and their notable trade-offs;
- the direction retained, and why;
- decisions, kept apart from recommendations: flag the ones that are the user's own, and the
  conflicts that the user resolved;
- assumptions, the limits of the evidence, and open decisions (for a major one: its stakes,
  the options, their consequences, and what it holds up);
- success signals that were actually established, none invented;
- which ending applies, the next step and any blocker.

Skip headings that do not apply. Whoever receives the summary, such as a plan or a spec
author, must be able to use it alone: "see the earlier conversation" is not enough.

## Never

- Produce a file, a spec, code or a ticket comment, open a branch, commit, or push.
- Start writing a spec or code on your own. When invoked by hand, you may name writing a spec
  as a possible next step, in one line.
- Treat a chosen direction as approval to build, or ask the user for such approval.
- Choose on the user's behalf, or reopen what they have already settled.
