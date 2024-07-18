FROM python:3.10.13-bookworm
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8                               \
    SHELL=/bin/bash
SHELL ["/bin/bash", "-c"]
WORKDIR /app
RUN echo "deb http://ftp.us.debian.org/debian bookworm main non-free" >> /etc/apt/sources.list.d/fonts.list \
    && apt update                                  \
    # clone
    && apt install git wget curl doxygen cmake build-essential checkinstall zlib1g-dev libssl-dev -y         \
    && git clone -b docker --recursive https://github.com/omg-xtao/luoxu.git /app \
    && git clone -b master --recursive https://github.com/BYVoid/OpenCC.git /app/opencc \
    # install dependencies \
    && pip install virtualenv  \
    && python3 -m virtualenv venv/                 \
    && . venv/bin/activate                         \
    && pip install -r requirements.txt             \
    && pip install opencc                          \
    ## set timezone
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone        \
    ## cargo
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init    \
    && chmod +x rustup-init                \
    && ./rustup-init -y --default-toolchain nightly \
    && rm rustup-init                     \
    && source $HOME/.cargo/env            \
    && rustup toolchain install nightly   \
    ## opencc
    && cd opencc                         \
    && make build                        \
    && make install                      \
    && cd ..                             \
    ## querytrans
    && cd querytrans                     \
    && rustup run nightly cargo build --release    \
    && cd ..                                       \
    && cp querytrans/target/release/libquerytrans.so /app/querytrans.so \
    # create cache folder
    && mkdir cache/                                \
    ## 卸载编译依赖，清理安装缓存
    && apt-get purge --auto-remove -y \
        build-essential \
        checkinstall \
        zlib1g-dev \
        libssl-dev \
        cmake      \
    # clean
    && apt-get clean -y                            \
    && rm -rf                                      \
        /tmp/*                                     \
        /var/lib/apt/lists/*                       \
        /var/tmp/*                                 \
        ~/.cache/pip                               \
        ~/.cache/pypoetry                          \
        /app/opencc                                \
    # Add the wait script to the image
    && wget -O /wait https://github.com/ufoscout/docker-compose-wait/releases/download/2.12.1/wait \
    && chmod +x /wait
ENTRYPOINT /wait && venv/bin/python -m luoxu --config data/config.toml
