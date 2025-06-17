ARG CORE_BRANCH=main

FROM ghcr.io/commonarch/core:$CORE_BRANCH

ARG CORE_BRANCH=main
ARG VARIANT=general
ARG DESKTOP=nogui

RUN if [ "$VARIANT" != container ]; then install-packages-build linux-zen linux-firmware linux-zen-headers broadcom-wl-dkms dracut; fi

RUN if [ "$DESKTOP" == gnome ]; then install-packages-build gnome; \
  elif [ "$DESKTOP" == plasma ]; then install-packages-build plasma kde-utilities-meta kde-accessibility-meta; \
  elif [ "$DESKTOP" == xfce ]; then install-packages-build xfce4; \
  elif [ "$DESKTOP" == mate ]; then install-packages-build mate mate-extra; \
  elif [ "$DESKTOP" == budgie ]; then install-packages-build budgie budgie-desktop-view network-manager-applet materia-gtk-theme papirus-icon-theme; \
  fi

RUN if [ "$DESKTOP" == gnome ]; then install-packages-build xorg-server gdm; systemctl enable gdm; \
  elif [ "$DESKTOP" == plasma ]; then install-packages-build xorg-server sddm; systemctl enable sddm; \
  elif [ "$DESKTOP" == xfce ]; then install-packages-build xorg-server lightdm lightdm-gtk-greeter; systemctl enable lightdm; \
  elif [ "$DESKTOP" == mate ]; then install-packages-build xorg-server lightdm lightdm-gtk-greeter; systemctl enable lightdm; \
  elif [ "$DESKTOP" == budgie ]; then install-packages-build xorg-server lightdm lightdm-gtk-greeter; systemctl enable lightdm; \
  fi

RUN if [ "$VARIANT" == nvidia ]; then install-packages-build nvidia-dkms; fi

RUN install-packages-build grub efibootmgr

RUN install-packages-build python-yaml python-click python-fasteners skopeo umoci jq libnotify wget

COPY overlays/common /

ENV CORE_BRANCH=$CORE_BRANCH

RUN wget -O /usr/bin/system https://github.com/CommonArch/system-cli/raw/refs/heads/$CORE_BRANCH/usr/bin/system; chmod 755 /usr/bin/system; \
    mkdir -p /usr/lib/dracut/modules.d/10commonarch; \
    wget -O /usr/lib/dracut/modules.d/10commonarch/handle-update.sh https://github.com/CommonArch/system-cli/raw/refs/heads/$CORE_BRANCH/usr/lib/dracut/modules.d/10commonarch/handle-update.sh; chmod 755 /usr/lib/dracut/modules.d/10commonarch/handle-update.sh; \
    wget -O /usr/lib/dracut/modules.d/10commonarch/module-setup.sh https://github.com/CommonArch/system-cli/raw/refs/heads/$CORE_BRANCH/usr/lib/dracut/modules.d/10commonarch/module-setup.sh; chmod 755 /usr/lib/dracut/modules.d/10commonarch/module-setup.sh

RUN systemctl enable commonarch-update-cleanup
RUN systemctl enable --global commonarch-update-check

# Clean up cache
RUN yes | pacman -Scc
