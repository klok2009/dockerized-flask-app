# Stage 1: Build stage (use a lightweight base image)
FROM python:3.11-slim AS builder

# Set working directory inside the container
WORKDIR /app

# Copy only necessary files (avoid copying unnecessary files like .git, venv, etc.)
COPY requirements.txt .

# Install dependencies in a virtual environment to keep the base image clean
RUN python -m venv /venv && \
    /venv/bin/pip install --no-cache-dir -r requirements.txt

# Stage 2: Final runtime image
FROM python:3.11-alpine

# Set working directory
WORKDIR /app

# Copy only the required files from the builder stage
COPY --from=builder /venv /venv
COPY . .

# Set environment variables (improves portability)
ENV PATH="/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1

# Use a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expose necessary ports
EXPOSE 5000

# Define the entry point
CMD ["python", "app.py"]

