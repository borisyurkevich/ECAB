# ECAB
iPad app for measuring child's attention abilities and diagnosing ADHD. ECAB (Early Childhood Attention Battery)

This app has 4 different tests to measure children ability to focus. To get professional result it meant to be used with trained instructor. App just produces not normalised log. Please contact my clients if you need more information or normalisation.

App has buttons which fire on touch down, not touch up. This is due to some children don't want to lift a finger after touch the screen.

## App Model
TestVC is a base class.
TestVC ➡️ Visual Search, Counterpointing.
Counterpointing ➡️ Flanker, Visual Sustain.

You will find Core Data model messy, `CounterpointingMove` object is overused. This is due to my efforts to preserve backwards compatibility. I've done lightweight migration since the early beginning. I can't accept any other Core Data changes.

## Contacts
Not technical questions:
Oliver Braddick: oliver.braddick@psy.ox.ac.uk
Jan Atkinson: j.atkinson@ucl.ac.uk

Technical:
Boris Yurkevich: boris.yurkevich@gmail.com
