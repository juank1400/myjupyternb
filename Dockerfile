# Usa una imagen base oficial de Python (elige la versión que necesites)
FROM python:3.11-slim

LABEL maintainer="Juan Carlos Cepeda <juank1400@gmail.com>"

# --- Argumentos y Variables de Entorno ---
# Definimos usuario, IDs y directorios para facilitar la configuración
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="1000" # Grupo primario para el usuario
# NOTA: Usaremos GID 0 (root) para la propiedad de grupo de los directorios clave
# para intentar compatibilidad con OpenShift, donde el UID aleatorio suele pertenecer a GID 0.

ENV NB_USER=${NB_USER} \
    NB_UID=${NB_UID} \
    NB_GID=${NB_GID} \
    # Directorio 'home' del usuario dentro del contenedor
    HOME="/home/${NB_USER}" \
    # Directorio de trabajo donde se guardarán los notebooks
    NOTEBOOK_DIR="/home/${NB_USER}/work" \
    # Habilita JupyterLab por defecto
    JUPYTER_ENABLE_LAB=yes \
    # Para compatibilidad con pip install --user y entornos virtuales
    PYTHONUSERBASE=/opt/conda \
    PATH="/opt/conda/bin:${PATH}"

# --- Instalación de Dependencias ---
# Actualiza pip e instala las bibliotecas de Python necesarias
# Incluye jupyterlab, y las bibliotecas de gráficos/datos
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
        jupyterlab \
        pandas \
        matplotlib \
        seaborn

# --- Creación de Usuario y Permisos ---
# Crea el grupo y el usuario 'jovyan'
RUN groupadd -g ${NB_GID} ${NB_USER} && \
    useradd -m -s /bin/bash -N -u ${NB_UID} -g ${NB_GID} ${NB_USER}

# Crea el directorio de trabajo y ajusta permisos
# Esto es CRUCIAL para la compatibilidad con OpenShift
RUN mkdir -p ${NOTEBOOK_DIR} && \
    # Establece propietario al usuario jovyan, pero grupo a root (GID 0)
    chown -R ${NB_UID}:0 ${HOME} && \
    # Asegura que el grupo (root, GID 0) tenga permisos de escritura
    chmod -R g+w ${HOME} && \
    # Asegura específicamente permisos en el directorio de trabajo
    chmod g+w ${NOTEBOOK_DIR} && \
    # Crea directorio para configuracion de conda/pip
    mkdir -p /opt/conda && \
    chown -R ${NB_UID}:0 /opt/conda && \
    chmod -R g+w /opt/conda

# --- Configuración de Red y Directorio de Trabajo ---
# Expone el puerto por defecto de Jupyter
EXPOSE 8888

# Establece el directorio de trabajo por defecto
WORKDIR ${NOTEBOOK_DIR}

# --- Usuario y Comando de Inicio ---
# Cambia al usuario no-root 'jovyan'
USER ${NB_UID}

# Comando para iniciar JupyterLab
# Se enlaza a todas las IPs, no abre navegador, usa el directorio de trabajo
# Se recomienda establecer una contraseña o token mediante variables de entorno al ejecutar
CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--port=8888", "--notebook-dir=${NOTEBOOK_DIR}"]
