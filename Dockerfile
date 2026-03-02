FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV XDG_CONFIG_DIRS=/etc/xdg

# 1. Install system dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    curl \
    sudo \
    gnupg \
    && add-apt-repository universe \
    && apt-get update

# 2. Install XFCE, D-Bus, audio and stability tools
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-session \
    xfce4-goodies \
    xfce4-terminal \
    dbus-x11 \
    pulseaudio \
    pulseaudio-utils \
    alsa-utils \
    libasound2-plugins \
    desktop-base \
    xserver-xorg-video-dummy \
    xbase-clients \
    python3-psutil \
    python3-xdg \
    xfonts-base \
    x11-xserver-utils \
    && rm -rf /var/lib/apt/lists/*

# 3. Install Google Chrome & Remote Desktop.
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && apt-get install -y ./google-chrome-stable_current_amd64.deb && \
    wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb && \
    apt-get install -y ./chrome-remote-desktop_current_amd64.deb && \
    rm *.deb

# 4. Create user
ARG CRD_USER=crduser
ARG CRD_PASSWORD=crdpassword
ENV USER=$CRD_USER
RUN useradd -m -s /bin/bash -G sudo,audio $USER && \
    # Ensure CRD group exists and add the user to it..
    groupadd -f chrome-remote-desktop && \
    usermod -aG chrome-remote-desktop $USER && \
    echo "$USER:$CRD_PASSWORD" | chpasswd && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USER
WORKDIR /home/$USER

# 5. Session script: clears old sessions, starts DBUS, and virtual audio
RUN echo "#!/bin/bash" > /home/$USER/.chrome-remote-desktop-session && \
    echo "unset SESSION_MANAGER" >> /home/$USER/.chrome-remote-desktop-session && \
    echo "unset DBUS_SESSION_BUS_ADDRESS" >> /home/$USER/.chrome-remote-desktop-session && \
    # Clean up stale PulseAudio locks and temp dirs from previous runs
    echo "pulseaudio -k 2>/dev/null || true" >> /home/$USER/.chrome-remote-desktop-session && \
    echo "rm -rf /home/\$USER/.config/pulse /tmp/pulse-* /tmp/runtime-\$USER /tmp/pyxdg-runtime-dir-fallback-\$USER" >> /home/$USER/.chrome-remote-desktop-session && \
    # Create the required runtime directory for PulseAudio
    echo "export XDG_RUNTIME_DIR=/tmp/runtime-\$USER" >> /home/$USER/.chrome-remote-desktop-session && \
    echo "mkdir -p \$XDG_RUNTIME_DIR && chmod 700 \$XDG_RUNTIME_DIR" >> /home/$USER/.chrome-remote-desktop-session && \
    # Start PulseAudio in the background
    echo "pulseaudio --start --exit-idle-time=-1" >> /home/$USER/.chrome-remote-desktop-session && \
    echo "pacmd load-module module-null-sink sink_name=crd_output" >> /home/$USER/.chrome-remote-desktop-session && \
    echo "pacmd set-default-sink crd_output" >> /home/$USER/.chrome-remote-desktop-session && \
    echo "exec dbus-launch --exit-with-session startxfce4" >> /home/$USER/.chrome-remote-desktop-session && \
    chmod +x /home/$USER/.chrome-remote-desktop-session

# 6. Disable the screensaver/lock
RUN mkdir -p /home/$USER/.config/xfce4/xfconf/xfce-perchannel-xml && \
    echo '<?xml version="1.0" encoding="UTF-8"?><channel name="xfce4-screensaver" version="1.0"><property name="saver" type="bool" value="false"/><property name="lock" type="bool" value="false"/></channel>' > /home/$USER/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-screensaver.xml

# 7. Custom Setup
# Use wildcard trick so COPY doesn't fail if file is missing
# Also ensure current user owns the script.
COPY --chown=$USER:$USER scripts/custom-setup.sh* /home/$USER/

RUN if [ -f /home/$USER/custom-setup.sh ]; then \
        echo "--- Starting Custom Setup ---" && \
        chmod +x /home/$USER/custom-setup.sh && \
        /home/$USER/custom-setup.sh && \
        # Sync bashrc to profile so paths persist in all shell types
        cat /home/$USER/.bashrc >> /home/$USER/.profile || true && \
        rm /home/$USER/custom-setup.sh && \
        echo "--- Custom Setup Complete ---"; \
    else \
        echo "No custom-setup.sh found, skipping."; \
    fi

# 8. Entrypoint: Cleanup X11 locks and start CRD on boot
CMD ["/bin/bash", "-c", "sudo chown -R $USER:$USER /home/$USER/.config/chrome-remote-desktop && sudo rm -f /tmp/.X*-lock /tmp/.X11-unix/X* && if ls /home/$USER/.config/chrome-remote-desktop/host#*.json 1> /dev/null 2>&1; then /opt/google/chrome-remote-desktop/chrome-remote-desktop --start; fi; tail -f /dev/null"]
