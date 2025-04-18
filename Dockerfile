FROM ruby:3.4
ENV LANG=C.UTF-8
RUN apt-get update \
  ; apt-get install -y --no-install-recommends wget groff ghostscript \
  ; wget -q https://github.com/jgm/pandoc/releases/download/3.6.4/pandoc-3.6.4-1-amd64.deb \
  ; apt-get install ./pandoc-3.6.4-1-amd64.deb \
  ; useradd -ms /bin/bash pandocomatic-user
USER pandocomatic-user 
SHELL ["/bin/bash", "-l", "-c"]
COPY --chown=pandocomatic-user:pandocomatic-user . /home/pandocomatic-user/
WORKDIR /home/pandocomatic-user
RUN gem install bundler \
  ; bundler install
