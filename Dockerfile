FROM ubuntu

RUN apt-get update
RUN apt-get install -yq ruby2.0 ruby2.0-dev build-essential git nginx pkg-config nodejs libxml2-dev libxslt-dev
RUN gem2.0 install --no-ri --no-rdoc bundler
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN cd /app; bundle config build.nokogiri --use-system-libraries; bundle install
VOLUME ["/var/cache/nginx"]
ADD . /app
EXPOSE 80 443
WORKDIR /app
RUN bundle exec middleman build
RUN cp -r ./build/* /usr/share/nginx/html/
CMD ["nginx", "-g", "daemon off;"]
