# Storm-Breaker Docker Image
# Multi-stage build with Python and PHP

FROM python:3.11-slim

# Install PHP and required dependencies
RUN apt-get update && apt-get install -y \
    php8.2-cli \
    php8.2-common \
    php8.2-mbstring \
    php8.2-xml \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Create necessary directories with proper permissions
RUN mkdir -p storm-web/log storm-web/images storm-web/sounds && \
    chmod -R 755 storm-web/log storm-web/images storm-web/sounds

# Expose the default port
EXPOSE 2525

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PORT=2525

# Create a startup script
RUN echo '#!/bin/bash\n\
python3 st.py\n\
' > /app/start.sh && chmod +x /app/start.sh

# Run the application
CMD ["python3", "-u", "st.py"]
