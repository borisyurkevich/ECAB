# ECAB

ECAB - Early Childhood Attention Battery. iPad app for measuring child's attention abilities and diagnosing ADHD.

Contains 4 tests to measure children ability to focus. Meant to be used with trained instructor. App produces not normalised log output with raw timings. Please [contact my clients][1] if you need more information or normalisation.

App has buttons which fire on touch down, not touch up. This is due to some children don't want to lift a finger after touching the screen.

## Inheritance model.

TestVC is a base class.
TestVC ➡️ Visual Search, Counterpointing.
Counterpointing ➡️ Flanker, Visual Sustain.

The app uses Core Data and has some design specifics, like, `CounterpointingMove` object is reused for multiple tests. This is due to my efforts to preserve backwards compatibility. I've done lightweight migration since the early beginning and didn't had a chance to redesign the data model.

## Contacts.

Not technical questions:
Oliver Braddick: [oliver.braddick@psy.ox.ac.uk][1]
Jan Atkinson: [j.atkinson@ucl.ac.uk][2]

Technical:
- Create a GitHub issue.

[1]: mailto:oliver.braddick@psy.ox.ac.uk
[2]: mailto:j.atkinson@ucl.ac.uk