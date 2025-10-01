FROM ruby:3.2

WORKDIR /app

# Podstawowe pakiety + Node + curl + gpg
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    curl \
    gpg \
    && rm -rf /var/lib/apt/lists/*

# Instalacja Yarn w nowy sposób
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarnkey.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update -qq && apt-get install -y yarn

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
