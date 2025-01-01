# Use the official Elixir image as the base image
FROM elixir:1.7.4-alpine

# Add ARG to pass database URL
ARG DATABASE_URL

# Use the ARG value as an ENV variable
ENV DATABASE_URL=$DATABASE_URL

# Set environment variables
ENV MIX_ENV=dev \
    LANG=C.UTF-8 \
    PORT=4000

# Install dependencies
RUN apk --no-cache add \
      build-base \
      nodejs \
      npm \
      postgresql-dev

# Create app directory
WORKDIR /app

# Install Hex and Rebar (Elixir build tools)
RUN mix local.hex --force && mix local.rebar --force

# Copy the mix files and install dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get && mix deps.compile

# Copy application code
COPY . .

# Install Node.js dependencies
WORKDIR /app/assets
RUN npm install && npm run deploy

# Move back to the app directory
WORKDIR /app

# Compile the application
RUN mix compile

# Digest static assets
RUN mix phx.digest

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the application port
EXPOSE $PORT

# Use the entrypoint script to run migrations and start the server
ENTRYPOINT ["/entrypoint.sh"]
