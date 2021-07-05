FROM dlanguage/ldc

COPY src/logtee.d .
COPY features/support/log_filter .

RUN ldc2 -J. -static