FROM ruby:3.1
ENV LANG C.UTF-8
RUN apt-get update \
  ; apt-get install -y --no-install-recommends wget texlive-latex-recommended \
      texlive-fonts-recommended texlive-latex-extra texlive-fonts-extra \
      texlive-lang-all \
  ; wget -q https://github.com/jgm/pandoc/releases/download/2.18/pandoc-2.18-1-amd64.deb \
  ; apt-get install ./pandoc-2.18-1-amd64.deb  \
  ; useradd -ms /bin/bash pandocomatic-user
USER pandocomatic-user 
SHELL ["/bin/bash", "-l", "-c"]
COPY . /home/pandocomatic-user/
WORKDIR /home/pandocomatic-user
RUN gem install bundler \
  ; bundler install
