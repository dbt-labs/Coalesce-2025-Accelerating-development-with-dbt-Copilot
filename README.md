# Accelerating Analytics with AI

Welcome! This is the sandbox project for the "Accelerating Analytics with AI" hands-on lab
at dbt Summit 2026.

## Overview

This lab shows how to use dbt Wizard in dbt Studio to ship a small dbt change end-to-end
without lowering engineering quality. Over five exercises you'll prompt Wizard to build a
mart model with tests and docs, preview the resulting data and lineage, and then capture your
team's standards so Wizard follows them on its own: an `AGENTS.md` file for SQL style and
naming conventions, and a custom dbt agent skill for a repeatable model-creation pattern.
You'll finish by building a second change and watching those standards pay off.

The loop this lab teaches: **prompt -> review -> capture -> accelerate.**

## Getting started

1. Log in to your dbt platform workshop sandbox in dbt Studio. Registration details will be
   provided at the start of the session.
2. Confirm dbt Wizard is available in your sandbox and the starter project is loaded.
3. Open `exercises/exercise1.md` and start there.

## What's in this repo

This is a jaffle_shop dbt project: a small e-commerce dataset (customers, orders, order
items, products, locations, supplies) with staging models in `models/staging/` and mart
models in `models/marts/`. `AGENTS.md` documents the naming, SQL, and modelling conventions
that apply to every model in this project; the `create-mart-model` skill covers what's
specific to building a new mart. Between them, this branch has already migrated everything
worth keeping out of the standalone styleguide this project started with.

- `exercises/` - the five hands-on exercises for this lab, in order.
- `exercises/expectations/` - what to expect from each exercise's result. Wizard's output
  isn't deterministic, so these describe a reasonable range of outcomes rather than a single
  correct answer.
- `AGENTS.md` - always-on project context for dbt Wizard.
- `.agents/skills/create-mart-model/` - a reusable skill for building new mart models in this
  project.
