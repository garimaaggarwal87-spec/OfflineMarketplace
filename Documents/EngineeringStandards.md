# LocalMart Engineering Standards

## Code organization

-   Separate presentation, business logic, data coordination, networking, and
    persistence.
-   Use descriptive names and focused functions.
-   Remove unused or commented-out implementations before submission.

## Swift and API design

-   Follow Swift naming conventions.
-   Keep implementation details private where appropriate.
-   Use protocols at meaningful dependency boundaries; avoid unnecessary
    abstraction.

## MVVM and UI

-   Views focus on presentation and user interaction.
-   Do not perform direct HTTP or SwiftData operations in Views.
-   Respect actor isolation for UI-facing state.

## Dependency injection

-   Inject repository and API-client implementations where substitution
    improves testability.
-   Keep production defaults while allowing test dependencies.
-   Use `MarketplaceRepositoryProtocol` and `APIClientProtocol` at their
    respective boundaries.

## Networking

-   Use URLSession and centralize endpoint configuration.
-   Validate HTTP status codes before decoding.
-   Decode response bodies into DTOs and propagate errors.
-   Avoid logging secrets or sensitive data.
-   Tests must not depend on external server availability.

## Concurrency

-   Use `async`/`await` for asynchronous requests.
-   Make actor isolation explicit where needed.
-   Avoid blocking the main thread and prevent duplicate sync runs.

## Persistence

-   Perform SwiftData operations through `MarketplaceLocalDataSource`.
-   Save explicitly and handle failures.
-   Use an in-memory ModelContainer for isolated tests.
-   Preserve pending local edits when merging remote data.
-   Define migration behavior as schemas evolve.

## Synchronization

-   Represent pending work with `SyncOperation`.
-   Update status based on operation outcomes.
-   Retain failed operations and diagnostic context.
-   For production, define retry/backoff, idempotency,
    conflict-resolution, and permanent-failure policies.

## Testing

-   Use Arrange--Act--Assert.
-   Name tests by behavior.
-   Test observable outcomes.
-   Isolate local persistence tests from networking.
-   Mock HTTP responses and add failure-path tests where practical.
-   Do not rely on test order.

## Git and code review

-   Keep commits focused and descriptive.
-   Check for secrets, debug artifacts, and unrelated changes.
-   Build and run relevant tests before submission.
-   Do not claim CI is configured unless it exists.

## Definition of done

-   Project builds and relevant tests pass.
-   Error paths are considered.
-   Architecture boundaries remain clear.
-   Documentation matches implementation.
-   Known limitations are disclosed.
