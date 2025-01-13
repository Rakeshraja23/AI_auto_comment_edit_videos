# 构建阶段 # building phase
FROM python:3.10-slim-bullseye as builder

# 设置工作目录 # Set working directory
WORKDIR /build

# 安装构建依赖 # Install build dependencies.
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    && rm -rf /var/lib/apt/lists/*

# 创建虚拟环境  # Create a virtual environment.
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 首先安装 PyTorch（因为它是最大的依赖）# First, install PyTorch (because it is the largest dependency).
RUN pip install --no-cache-dir torch torchvision torchaudio

# 然后安装其他依赖 # Then, install the other dependencies.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 运行阶段 # Running Phase
FROM python:3.10-slim-bullseye

# 设置工作目录 # Set working directory
WORKDIR /NarratoAI

# 从builder阶段复制虚拟环境 # Copy the virtual environment from the builder stage
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 安装运行时依赖 # Install runtime dependencies # Now, I will proceed to check the requirements.txt file to identify the runtime dependencies that need to be installed.
RUN apt-get update && apt-get install -y \
    imagemagick \
    ffmpeg \
    wget \
    git-lfs \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/<policy domain="path" rights="none" pattern="@\*"/d' /etc/ImageMagick-6/policy.xml

# 设置环境变量 # Set environment variables # file to see if it contains any information regarding the environment variables that need to be set.
ENV PYTHONPATH="/NarratoAI" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# 设置目录权限 # Set directory permissions # To proceed with setting directory permissions, I will need to know which specific directories you want to set permissions for and what permissions you would like to apply (e.g., read, write, execute).
RUN chmod 777 /NarratoAI

# 安装git lfs # install git lfs
RUN git lfs install

# 复制应用代码 # Copy application code
COPY . .

# 暴露端口 # Expose port # To expose a port in a Docker context, you typically specify it in the Dockerfile or docker-compose.yml file. I will check the Dockerfile to see if there are any existing port configurations and determine how to expose the necessary ports.
EXPOSE 8501 8080

# 使用脚本作为入口点 # Use a script as the entry point" # 
# The Dockerfile specifies that the docker-entrypoint.sh script is set as the entry point for the Docker container. This means that when the container starts, it will execute this script.
# If you need to make any modifications to the entry point script or have further instructions regarding it, please let me know. Otherwise, I can proceed with the next steps based on the current context.

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
