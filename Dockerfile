# Use the official Ubuntu image as the base image
FROM ubuntu:20.04

# Install required dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y wget unzip openjdk-11-jdk xvfb x11vnc fluxbox novnc

# Download and install the Android SDK
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip && \
    unzip commandlinetools-linux-7302050_latest.zip -d cmdline-tools && \
    rm commandlinetools-linux-7302050_latest.zip && \
    mkdir android-sdk && \
    mv cmdline-tools/android-sdk-*/* android-sdk && \
    rm -rf cmdline-tools

# Add the Android SDK to the PATH
ENV PATH=$PATH:/android-sdk/platform-tools:/android-sdk/tools/bin

# Accept the Android SDK licenses
RUN yes | sdkmanager --licenses

# Install an Android emulator
RUN sdkmanager "system-images;android-30;google_apis;x86" && \
    echo "no" | avdmanager create avd --force --name test --abi google_apis/x86 --package "system-images;android-30;google_apis;x86" && \
    echo "hw.keyboard=yes" >> ~/.android/avd/test.avd/config.ini

# Set up the VNC server
RUN mkdir ~/.vnc && \
    x11vnc -storepasswd 1234 ~/.vnc/passwd

# Copy the APK file to the /app directory
COPY ./app/game.apk /app

# Start the Android emulator and install the APK
CMD ["bash", "-c", "echo 'no' | /android-sdk/emulator/emulator -avd test -no-window -no-audio -gpu off -verbose & sleep 30 && adb wait-for-device && adb install /app/game.apk && novnc --listen 80 --vnc localhost:5900"]
