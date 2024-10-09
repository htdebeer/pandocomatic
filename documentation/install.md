## Installation

Pandocomatic is a [Ruby](https://www.ruby-lang.org/en/) program and can be
installed through [RubyGems](https://rubygems.org/) as follows:

~~~{.bash}
gem install pandocomatic
~~~

This will install pandocomatic and
[paru](https://heerdebeer.org/Software/markdown/paru/), a Ruby wrapper around
pandoc. To use pandocomatic, you also need a working pandoc installation. See
[pandoc's installation guide](https://pandoc.org/installing.html) for more
information about installing pandoc.

You can also build and install the latest version yourself by running the
following commands:

~~~{.bash}
cd /directory/you/downloaded/the/gem/to
docker image build --tag pandocomatic:dev .
docker container run --rm -it --volume $(pwd):/home/pandocomatic-user pandocomatic:dev bundle exec rake build
gem install pkg/pandocomatic-::pandocomatic::version.gem
~~~ 

You only have to do the second step one time. Once you've created a docker
image, you can reuse it as is until `Dockerfile` changes.
