# Prior Experience & Architecture Baseline

Status: active

The learner has completed Gleam Exercism tutorials (so basic Gleam syntax, functions, pattern matching, and `gleam test` are familiar) and brings strong Laravel/Livewire and Laravel/React web architecture experience. Gleam (`1.19.2`) and Erlang (`OTP 29`) are already installed locally.

## Implications

- Skip "install Gleam" and "what is a function/variable" tutorials; start immediately with production-grade Gleam domain modeling and cross-target architecture (`shared/` compiling to both BEAM and JS).
- Frame Glimr, Loom, and Lustre concepts against Laravel, Blade/Livewire, and React/Vue, explicitly calling out where functional/BEAM architecture *breaks* the OOP/PHP analogy (immutable state, `Result` instead of exceptions, OTP processes instead of Redis-only state).
