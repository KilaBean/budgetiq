# RIVERPOD EXPERT SKILL

Use:

* riverpod_annotation
* AsyncNotifier
* AutoDispose where appropriate

Rules:

Never:

* Use setState for business logic.
* Put API logic in widgets.

Preferred:

Repositories
→ Providers
→ View Models
→ UI

State Objects:

Loading
Success
Error

All async operations:

* retry capable
* cancellation safe

Generate provider documentation.
