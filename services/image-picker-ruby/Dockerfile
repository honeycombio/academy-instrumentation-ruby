# Use an official Ruby runtime as a parent image
FROM ruby:3.3

# Memenator needs more
RUN apt-get update && apt-get install -y \
		imagemagick \
		&& rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /usr/src/app

# Ensure bundler is up-to-date
RUN gem install bundler

# Copy app dependency list into image
COPY Gemfile* ./

# Install those dependencies
RUN bundle install

# Copy the rest of the application code into the image
COPY ./src ./src

# Expose the port that your app runs on
EXPOSE 10116

# Command to run the application
CMD [ "ruby", "src/app.rb" ]
