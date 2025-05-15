#cloud-config
package_upgrade: true
packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg-agent
  - software-properties-common

runcmd:
  # Install Docker
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  - apt-get update -y
  - apt-get install -y docker-ce docker-ce-cli containerd.io
  - systemctl start docker
  - systemctl enable docker
  
  # Install Docker Compose
  - curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  - chmod +x /usr/local/bin/docker-compose
  
  # Format and mount the data disk for PostgreSQL
  - parted /dev/disk/azure/scsi1/lun10 mklabel gpt
  - parted -a opt /dev/disk/azure/scsi1/lun10 mkpart primary ext4 0% 100%
  - mkfs.ext4 /dev/disk/azure/scsi1/lun10-part1
  - mkdir -p /var/lib/postgresql/data
  - echo "/dev/disk/azure/scsi1/lun10-part1 /var/lib/postgresql/data ext4 defaults,nofail 0 2" >> /etc/fstab
  - mount -a
  - chown -R 999:999 /var/lib/postgresql/data
  
  # Clone the example-voting-app repository
  - mkdir -p /opt/voting-app
  - git clone https://github.com/dockersamples/example-voting-app.git /opt/voting-app
  - cd /opt/voting-app
  
  # Create a docker-compose override file to use the mounted volume for PostgreSQL
  - |
    cat > /opt/voting-app/docker-compose.override.yml << 'EOF'
    version: "3"
    services:
      db:
        volumes:
          - /var/lib/postgresql/data:/var/lib/postgresql/data
    EOF
  
  # Start the application
  - cd /opt/voting-app && docker-compose up -d
