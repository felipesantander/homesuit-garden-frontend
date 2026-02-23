#Stage 1 - Install dependencies and build the app
FROM debian:latest AS build-env
ARG PORT_BACKEND
ARG URL_API_WEBOARD
ARG CLIENT_NAME
ARG GOOGLE_CLIENT_ID
ARG URL_HOST
ARG API_PORT
# Install flutter dependencies
RUN apt-get update 
RUN apt-get install -y curl git wget unzip gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3 xz-utils
RUN apt-get clean
# Clone the flutter repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter path
# RUN /usr/local/flutter/bin/flutter doctor -v
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor -v
# Enable flutter web
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

# Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/
RUN echo DEBUG=false >> .env
RUN flutter build web --release --dart-define=URL_HOST=https://finance.api.homesuite.cl


# Stage 2 - Create the run-time image
FROM nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# run flutter web
