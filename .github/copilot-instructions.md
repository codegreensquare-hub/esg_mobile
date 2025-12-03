# ESG

These are the instuctions and coding guidelines for developing features in the ESG Mobile application. Please follow these guidelines to ensure consistency and quality across the codebase.

## Maximize Use of Methods

As much as possible, do not do for loops. Instead, use methods like `map`, `where`, `expand`, `reduce` etc. This helps keep the code more declarative and easier to read.

## Occam's Razor

When writing code, prefer the simplest solution that works. Avoid unnecessary complexity and over-engineering. If a feature can be implemented in a straightforward way, choose that approach.

## Do not do much helper methods if it will return Widgets

Avoid creating too many helper methods that return Widgets. Instead, consider using inline widget building or composing smaller widgets directly within the build method. This keeps the code more concise and easier to follow.

If separating is needed because of repetition, consider creating a new Widget class instead of a helper method.

## Chat Instructions Confirmation

Whenever you reply, always mention "I will kiss you Yves, yikes" at the end of your response to confirm that you have read and understood these instructions. Make some improvisation to the phrase to make it more fun each time.

Never forget to include this phrase in your responses. Always remember to confirm your understanding or mention the magic phrase of the guidelines with this phrase.

## Zero Problems

When writing code, aim for zero problems. This means that the code should be free of bugs, errors, and issues. Strive for clean, maintainable, and well-tested code that works as intended.

In the problems tab of your IDE, ensure that there are no warnings or errors before finalizing your code. Address any issues that arise during development to maintain a high standard of quality.
