FROM dlanguage/dmd

COPY src/ /work
COPY user_specific.d /work
WORKDIR /work
RUN dmd logtee.d user_specific.d