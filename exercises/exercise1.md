# Exercise 1 - Build a mart with dbt Wizard

Practical block #1: create a new mart model, with tests and docs, by prompting the feature
request in plain business terms.

1. In dbt Studio, open a new dbt Wizard chat.

2. Prompt Wizard with the business request below. Don't add implementation detail (naming,
   materialization, which upstream models to use) - the point of this exercise is to see what
   Wizard does with a plain-language ask, before you've captured any project standards.

<ul>
Our store managers want a daily view of how each location is performing:
total revenue, number of orders, and how much of that revenue comes from
food vs. drinks. Can you build us a model for that, with tests and docs?
</ul>

3. Let Wizard investigate the project and build the change. Wizard validates as it
   builds, so a working, built model is the normal outcome here - not a separate step.

4. If something about Wizard's plan or output seems off, or you want to see an alternative, 
   ask a follow-up question before moving on. Iterating with intent is the point of this exercise, not speed.

5. Once you have a model you're reasonably happy with, save it.