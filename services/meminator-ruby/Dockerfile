# Use an official Ruby runtime as a parent image
FROM ruby:3.3

# Meminator needs more
RUN apt-get update && apt-get install -y \
		imagemagick \
		&& rm -rf /var/lib/apt/lists/*

# Create a directory for custom fonts
RUN mkdir -p /usr/share/fonts/truetype
# Copy font files from host to container
COPY ./Angkor/*.ttf /usr/share/fonts/truetype/
# Refresh font cache
RUN fc-cache -f -v

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
EXPOSE 10117

# Command to run the application
CMD [ "ruby", "src/app.rb" ]
