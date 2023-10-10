
resource "aws_security_group" "sg_alb" {
    name = "${var.project}-sg-alb"
    description = "teste"
    vpc_id = var.vpc_id

    ingress {
        description = "teste"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
  
}

resource "aws_lb" "alb_services" {
    name = "${var.project}-alb"
    internal = true
    load_balancer_type = "application"
    security_groups = [aws_security_group.sg_alb.id]
    subnets = var.subnet_id
  
}

resource "aws_lb_listener" "alb_listener" {
    load_balancer_arn = aws_lb.alb_services.arn
    port = "443"
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
    certificate_arn = var.acm_cert
}