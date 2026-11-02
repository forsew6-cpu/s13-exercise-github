# Production-ready Dockerfile for NewsGrid static website
FROM nginx:alpine

# Copy static site files to Nginx web root
COPY public/ /usr/share/nginx/html/

# Expose HTTP port
EXPOSE 80

# Use default Nginx foreground command (no CMD override needed)
