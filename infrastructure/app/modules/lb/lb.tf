module "nlb" {
  source = "terraform-aws-modules/alb/aws"

  name = "ecs-nlb"

  load_balancer_type = "network"

  vpc_id  = data.aws_vpc.vpc.id
  subnets = data.aws_subnets.private.ids
  security_groups = [data.aws_security_group.sg_nlb.id]

  internal = true

  target_groups = {
    ex-target = {
      name_prefix          = "tg-"
      protocol    = "TCP"
      port        = 8080
      target_type = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 40
        path                = "/actuator/health"
        port                = 8080
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 2
        matcher             = "200-299"
      }
    }
  }

  listeners = {
    ex-tcp = {
      port     = 80
      protocol = "TCP"
      forward = {
        target_group_key = "ex-target"
      }
    }
  }

  tags = {
    Name     = "${var.application_name}-nlb"
    Resource = "${var.application_name}-nlb-tg-http"
  }
}
