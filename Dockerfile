FROM python:3.11-slim

LABEL maintainer="Juan Carlos Cepeda <juank1400@gmail.com>"

ENV HOME="/home/jovyan" \
    NOTEBOOK_DIR="/home/jovyan/work" \
    JUPYTER_ENABLE_LAB=yes \
    PYTHONUSERBASE=/opt/conda \
    PATH="/opt/conda/bin:${PATH}"

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
        jupyterlab \
        pandas \
        matplotlib \
        seaborn

RUN groupadd -g 1000 jovyan && \
    useradd -m -s /bin/bash -N -u 1000 -g 1000 jovyan

RUN mkdir -p /home/jovyan/work && \
    chown -R 1000:0 /home/jovyan && \
    chmod -R g+w /home/jovyan && \
    chmod g+w /home/jovyan/work && \
    mkdir -p /opt/conda && \
    chown -R 1000:0 /opt/conda && \
    chmod -R g+w /opt/conda

EXPOSE 8888

WORKDIR /home/jovyan/work

USER 1000

CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--port=8888", "--notebook-dir=/home/jovyan/work"]
