data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "alb" {
  name        = "va-lab-alb-sg"
  description = "ALB interno - HTTP solo dalla VPC"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "HTTP dalla VPC - endpoint Verified Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.lab.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.lab.cidr_block]
  }
}

resource "aws_security_group" "app" {
  name        = "va-lab-app-sg"
  description = "App - HTTP solo da ALB"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description     = "HTTP da ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.lab.cidr_block]
  }
}

resource "aws_iam_role" "app" {
  name = "va-lab-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name = "va-lab-app-profile"
  role = aws_iam_role.app.name
}

resource "aws_instance" "app" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.app.name

  metadata_options {
    http_tokens = "required"
  }

  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /opt/app
    cat > /opt/app/index.html <<'HTML'
    <h1>App interna "vulnerabile"</h1>
    <p>Se leggi questa pagina sei passato da Verified Access.</p>
    HTML
    cat > /etc/systemd/system/app.service <<'UNIT'
    [Unit]
    Description=Lab app
    After=network.target
    [Service]
    WorkingDirectory=/opt/app
    ExecStart=/usr/bin/python3 -m http.server 80
    Restart=always
    [Install]
    WantedBy=multi-user.target
    UNIT
    systemctl daemon-reload
    systemctl enable --now app
  EOF

  tags = { Name = "va-lab-app" }
}