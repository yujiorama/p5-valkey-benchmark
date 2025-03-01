FROM public.ecr.aws/docker/library/perl:5-slim

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt update && apt-get --no-install-recommends install -y \
    build-essential \
    git

RUN --mount=type=cache,target=/var/cache/libvalkey,sharing=locked \
    git clone --depth 1 --no-tags https://github.com/valkey-io/libvalkey.git /var/cache/libvalkey \
    && cd /var/cache/libvalkey \
    && USE_TLS=1 make -j$(nproc) install

WORKDIR /app

COPY cpanfile* /app/
RUN mkdir -p /opt/cpan
RUN cpm install -w $(nproc) --cpanfile /app/cpanfile -L/opt/cpan --no-color --show-build-log-on-failure --show-progress

COPY . /app/
RUN perl Makefile.PL && make

RUN perl -I/opt/cpan/lib/perl5 -I/app/lib -Mblib=/app -MValkey::XS -e 'print "Valkey::XS is " . $Valkey::XS::VERSION'

ENV PATH=/opt/cpan/bin:$PATH
ENV PERL5LIB=/opt/cpan/lib/perl5
