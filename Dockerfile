# Use the official Node.js image as the base image
FROM node:14

# Install the Android SDK
RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip && \
    unzip commandlinetools-linux-7302050_latest.zip -d cmdline-tools && \
    rm commandlinetools-linux-7302050_latest.zip && \
    mkdir android-sdk && \
    mv cmdline-tools/android-sdk-*/* android-sdk && \
    rm -rf cmdline-tools

# Add the Android SDK to the PATH
ENV PATH=$PATH:/android-sdk/platform-tools:/android-sdk/tools/bin

# Accept the Android SDK licenses
RUN yes | sdkmanager --licenses

# Set the working directory to /app
WORKDIR /app

# Copy the package.json and package-lock.json files to the /app directory
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the APK file to the /app directory
COPY ./apps/gamename.apk /app

# Build the app
RUN npm run build

# Expose port 80
EXPOSE 80

# Start the app
CMD ["npm", "start"]
