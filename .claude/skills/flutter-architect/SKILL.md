# FLUTTER ARCHITECT SKILL

Architecture Standard:

Feature First Architecture

lib/

features/
shared/
core/

Each feature contains:

* data/
* domain/
* presentation/

Domain Layer:

* entities
* repositories
* use cases

Data Layer:

* datasource
* models
* repository implementations

Presentation Layer:

* pages
* widgets
* providers

Rules:

* No business logic inside widgets.
* No direct Supabase calls from UI.
* Repository pattern required.
* Dependency injection required.

Every feature must support:

* loading states
* error states
* empty states

Generate clean architecture only.
