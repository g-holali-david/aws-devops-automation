pipeline {
    agent none

    stages {

        // ============================================================
        // Environment detection (branch -> agent mapping)
        // ============================================================
        stage('Prepare Environment') {
            agent any
            steps {
                script {
                    // Detect current Git branch
                    env.GIT_BRANCH_NAME = sh(
                        script: "git rev-parse --abbrev-ref HEAD",
                        returnStdout: true
                    ).trim()

                    // Determine target environment and Jenkins agent
                    if (env.GIT_BRANCH_NAME == "main") {
                        env.DEPLOY_ENV   = "production"
                        env.TARGET_AGENT = "PROD-NODE"
                    } else if (env.GIT_BRANCH_NAME == "dev") {
                        env.DEPLOY_ENV   = "preproduction"
                        env.TARGET_AGENT = "PRE_PROD-NODE"
                    } else {
                        error("Unsupported branch '${env.GIT_BRANCH_NAME}'. Only 'dev' and 'main' are deployable.")
                    }

                    echo "Git branch     : ${env.GIT_BRANCH_NAME}"
                    echo "Deploy env     : ${env.DEPLOY_ENV}"
                    echo "Target agent   : ${env.TARGET_AGENT}"
                }
            }
        }

        // ============================================================
        // Build & Deploy on corresponding agent
        // ============================================================
        stage('Build and Deploy') {
            agent { label "${env.TARGET_AGENT}" }

            environment {
                APP_PATH     = 'devops-app'
                BUILD_DIR    = 'devops-app/build'
                DEPLOY_PATH  = '/var/www/devops-dashboard'
                NGINX_SITE   = '/etc/nginx/sites-available/devops-dashboard'
            }

            steps {
                script {
                    env.SERVER_IP = sh(script: "hostname -I | awk '{print $1}'", returnStdout: true).trim()
                    echo "Server IP: ${env.SERVER_IP}"
                }

                // -------------------------------
                // Install Node.js and dependencies
                // -------------------------------
                sh '''
                    echo "Installing Node.js and dependencies..."
                    if ! command -v node >/dev/null 2>&1; then
                        sudo apt-get update -y
                        sudo apt-get install -y nodejs npm
                    fi
                    node -v
                    npm -v
                    cd "$APP_PATH"
                    npm ci || npm install
                '''

                // -------------------------------
                // Build React application
                // -------------------------------
                sh '''
                    echo "Building React application..."
                    cd "$APP_PATH"
                    npm run build
                '''

                // -------------------------------
                // Install & Configure NGINX
                // -------------------------------
                sh '''
                    echo "Installing and configuring NGINX..."

                    # Stop Apache if it exists
                    if systemctl list-units --type=service | grep -q apache2; then
                        sudo systemctl stop apache2 || true
                        sudo systemctl disable apache2 || true
                    fi

                    # Install NGINX if needed
                    if ! dpkg -s nginx >/dev/null 2>&1; then
                        sudo apt-get update -y
                        sudo apt-get install -y nginx
                    fi

                    # Deploy build files
                    sudo mkdir -p "$DEPLOY_PATH"
                    sudo rsync -a --delete "$BUILD_DIR"/ "$DEPLOY_PATH"/
                    sudo chown -R www-data:www-data "$DEPLOY_PATH"

                    # Create NGINX site configuration
                    sudo bash -c 'cat > '"$NGINX_SITE"' <<EOF
server {
    listen 80;
    server_name _;

    root '"$DEPLOY_PATH"';
    index index.html;

    gzip on;
    gzip_types text/plain text/css application/javascript application/json image/svg+xml;

    location ~* \\.(?:js|css|png|jpg|jpeg|gif|svg|ico)$ {
        expires 7d;
        add_header Cache-Control "public, max-age=604800";
        try_files $uri =404;
    }

    location / {
        try_files $uri /index.html;
    }

    location = /healthz {
        access_log off;
        return 200 "ok";
    }
}
EOF'

                    # Enable and reload NGINX
                    sudo ln -sf "$NGINX_SITE" /etc/nginx/sites-enabled/devops-dashboard
                    sudo rm -f /etc/nginx/sites-enabled/default
                    sudo nginx -t
                    sudo systemctl enable nginx
                    sudo systemctl reload nginx
                '''

                // -------------------------------
                // Health Check
                // -------------------------------
                sh '''
                    echo "Performing health check..."
                    for i in $(seq 1 10); do
                        if curl -fsS "http://$SERVER_IP/healthz" >/dev/null; then
                            echo "Health check OK."
                            exit 0
                        fi
                        echo "Waiting for NGINX to respond... ($i/10)"
                        sleep 2
                    done
                    echo "Health check failed."
                    exit 1
                '''
            }
        }
    }

    // ============================================================
    // 3️Post actions
    // ============================================================
    post {
        success {
            echo "Deployment successful on ${DEPLOY_ENV} (${SERVER_IP})"
        }
        failure {
            echo "Deployment failed on ${DEPLOY_ENV}"
        }
        always {
            echo "🧹 Cleaning up workspace..."
            cleanWs()
        }
    }
}
