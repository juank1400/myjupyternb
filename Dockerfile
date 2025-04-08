# Usa una imagen base oficial de Python (elige la versión que necesites)
FROM python:3.11-slim

LABEL maintainer="Juan Carlos Cepeda <juank1400@gmail.com>"

# --- Variables de Entorno (Valores Fijos) ---
# Definimos directorios y configuraciones directamente
ENV HOME="/home/jovyan" \
    # Directorio de trabajo donde se guardarán los notebooks
    NOTEBOOK_DIR="/home/jovyan/work" \
    # Habilita JupyterLab por defecto
    JUPYTER_ENABLE_LAB=yes \
    # Para compatibilidad con pip install --user y entornos virtuales
    PYTHONUSERBASE=/opt/conda \
    PATH="/opt/conda/bin:${PATH}" # Añade /opt/conda/bin al PATH existente

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
# Crea el grupo y el usuario 'jovyan' con IDs fijos
RUN groupadd -g 1000 jovyan && \
    useradd -m -s /bin/bash -N -u 1000 -g 1000 jovyan

# Crea el directorio de trabajo y ajusta permisos
# Esto es CRUCIAL para la compatibilidad con OpenShift
RUN mkdir -p /home/jovyan/work && \
    # Establece propietario al usuario jovyan (UID 1000), pero grupo a root (GID 0)
    chown -R 1000:0 /home/jovyan && \
    # Asegura que el grupo (root, GID 0) tenga permisos de escritura
    chmod -R g+w /home/jovyan && \
    # Asegura específicamente permisos en el directorio de trabajo
    chmod g+w /home/jovyan/work && \
    # Crea directorio para configuracion de conda/pip
    mkdir -p /opt/conda && \
    chown -R 1000:0 /opt/conda && \
    chmod -R g+w /opt/conda

# --- Configuración de Red y Directorio de Trabajo ---
# Expone el puerto por defecto de Jupyter
EXPOSE 8888

# Establece el directorio de trabajo por defecto
WORKDIR /home/jovyan/work

# --- Usuario y Comando de Inicio ---
# Cambia al usuario no-root 'jovyan' (UID 1000)
USER 1000

# Comando para iniciar JupyterLab
# Se enlaza a todas las IPs, no abre navegador, usa el directorio de trabajo
# Se recomienda establecer una contraseña o token mediante variables de entorno al ejecutar
CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--port=8888", "--notebook-dir=/home/jovyan/work"]
