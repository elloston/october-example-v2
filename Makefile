# Makefile

-include .env
export

# Declare targets that don't produce files as PHONY
.PHONY: all check_env docker_up composer_install db_fresh db_migrate health_check

# Default target: executes all necessary steps for a full environment setup
all: check_env docker_up composer_install db_fresh db_migrate health_check

check_env:
	@if [ ! -f .env ]; then \
		echo "❗️Error: .env file does not exist. Please create it from .env.example"; \
		exit 1; \
	fi

# Create an auth.json file from environment variables, formatting it for HTTP basic authentication
create_auth:
	@echo "Creating auth.json with HTTP basic credentials..."
	@set -a; . .env; set +a; \
	echo '{' > auth.json; \
	echo '  "http-basic": {' >> auth.json; \
	echo '    "gateway.octobercms.com": {' >> auth.json; \
	echo '      "username": "$(OCTOBERCMS_USERNAME)",' >> auth.json; \
	echo '      "password": "$(OCTOBERCMS_PASSWORD)"' >> auth.json; \
	echo '    }' >> auth.json; \
	echo '  }' >> auth.json; \
	echo '}' >> auth.json; \
	echo "✔ auth.json created"

# Build and start Docker containers, ensuring all Docker images are up to date
docker_up:
	@echo "Building and starting Docker containers..."
	@docker compose up --build -d
	@echo "✔ Docker containers are up and running"

# Install dependencies via Composer inside the PHP Docker container
composer_install:
	@echo "Installing Composer dependencies inside the Docker container..."
	@docker exec -it $(APP_DOCKER_CONTAINER) bash -c "composer install"
	@echo "✔ Composer dependencies installed"

# Terminate all active database sessions to allow database operations like drop/create
terminate_db_sessions:
	@echo "Terminating all connections to the database..."
	@docker exec -i $(DB_HOST) psql -U postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE datname = '$(DB_DATABASE)' AND pid <> pg_backend_pid();"

# Perform health checks on critical services to ensure they are operational
health_check:
	@echo "Checking of PHP service..."
	@curl -s -o /dev/null -w "%{http_code}" $(APP_URL) | grep -q "200" && echo "✅ PHP service is up and running! $(APP_URL)" || echo "PHP service is down"
	@echo "Checking of PostgreSQL service..."
	@docker exec -i $(DB_HOST) psql -U postgres -d $(DB_DATABASE) -c '\q' > /dev/null 2>&1 && echo "✅ PostgreSQL service is up and running! $(APP_URL):$(PGADMIN_PORT)" || echo "PostgreSQL service is down"
