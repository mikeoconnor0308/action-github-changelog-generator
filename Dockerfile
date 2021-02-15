FROM ruby:2.6.4-alpine3.9
LABEL maintainer "mike@entos.ai"

RUN apk add --no-cache git bash

# install github-changelog-generator
COPY Gemfile Gemfile
RUN gem install bundler --version $(cat Gemfile | grep bundler | awk -F "'" '{print $4}') \
  && bundle install --system
# set up entry point to run generator on the given repo
ENV SRC_PATH /usr/local/src/your-app
RUN mkdir -p $SRC_PATH

VOLUME [ "$SRC_PATH" ]
WORKDIR $SRC_PATH

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
