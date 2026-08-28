# `foundation` feature

**Developer-only. Not a product surface.**

Renders every design-token category — typography, colour, spacing, borders,
shadows, motion, dimensions — in both themes, plus a Myanmar/English string
pair. It exists for two reasons:

1. **Visual proof.** The token pipeline is verifiable by eye, including that
   Burmese text shapes correctly through the Noto fallback rather than
   rendering as tofu boxes.
2. **Reference implementation.** It is the worked example of reading tokens
   through `context.lkColors` and `Theme.of(context).textTheme` rather than
   importing the palette directly.

Excluded from release builds via `Environment.allowsDeveloperTools`.
