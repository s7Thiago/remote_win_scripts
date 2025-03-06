FROM dart:stable-sdk

LABEL maintainer="Thiago Silva"
LABEL email="thyagosousasilva@gmail.com"

# Instalar coisas importantes no ambiente
RUN apt-get update && apt-get upgrade && apt-get install -y \
    git \
    curl \
    wget \
    htop \
    unzip \
    procps \
    lsof \
    vim \
    telnet \
    && apt-get clean

WORKDIR /workspace

CMD [ "tail", "-f", "/dev/null" ]