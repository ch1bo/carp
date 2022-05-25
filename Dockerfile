FROM rust:1.59 AS x-builder

RUN USER=root cargo new --bin carp

WORKDIR /carp

COPY ./indexer/Cargo.toml ./Cargo.toml
COPY ./indexer/Cargo.lock ./Cargo.lock

COPY ./indexer/entity ./entity
COPY ./indexer/migration ./migration
COPY ./indexer/reparse ./reparse
COPY ./indexer/rollback ./rollback
COPY ./indexer/tasks ./tasks
COPY ./indexer/task-docgen ./task-docgen
COPY ./indexer/src ./src
COPY ./indexer/plan-visualizer ./plan-visualizer

RUN cargo build --release \
    -p carp -p migration -p reparse -p rollback \
    -p tasks -p plan-visualizer -p task-docgen

WORKDIR /ops

RUN cp /carp/target/release/carp .
RUN cp /carp/target/release/migration .
RUN cp /carp/target/release/reparse .
RUN cp /carp/target/release/rollback .
RUN cp /carp/target/release/plan-visualizer .

COPY ./indexer/genesis ./genesis
COPY ./indexer/execution_plans ./execution_plans
############################################################

FROM debian:stable-slim AS carp
ENV TZ=Etc/UTC
ARG APP=/app
COPY --from=x-builder /ops ${APP}
WORKDIR ${APP}
#USER nonroot
ENTRYPOINT ["./carp"]
