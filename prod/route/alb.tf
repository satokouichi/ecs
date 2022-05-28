######################################################################
# ALB本体
######################################################################

resource "aws_lb" "this" {
  count = var.enable_alb ? 1 : 0

  name               = "${local.name_prefix}-shop-link"
  
  internal           = false
  load_balancer_type = "application"
  
  # セキュリティグループを設定
  security_groups = [
    data.terraform_remote_state.network.outputs.security_group_web_id,
    data.terraform_remote_state.network.outputs.security_group_vpc_id
  ]

  # サブネットを紐つけ
  subnets = [
    for s in data.terraform_remote_state.network.outputs.subnet_public : s.id
  ]

  tags = {
    Name = "${local.name_prefix}-shop-link"
  }
}

######################################################################
# ALBリスナー（HTTPバージョン）
######################################################################

resource "aws_lb_listener" "http" {
  count = var.enable_alb ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    # ロードバランサーが有効かチェック
    #type = "fixed-response"
    #fixed_response {
      #content_type = "text/plain"
      #message_body = "Fixed response content"
      #status_code  = "200"
    #}

    # ターゲットグループと紐つけ
    type = "forward"
    target_group_arn = aws_lb_target_group.shop.arn
  }
}

######################################################################
# ターゲットグループ
######################################################################

resource "aws_lb_target_group" "shop" {
  name = "${local.name_prefix}-shop"

  # instance or ip を選択（EC2：instans ECS：ip）
  target_type          = "ip"

  # HTTP 443 or HTTP 80 ポート選択
  port                 = 80
  protocol             = "HTTP"
  
  # VPCと紐つけ
  vpc_id               = data.terraform_remote_state.network.outputs.vpc_this_id

  deregistration_delay = 60

  # ヘルスチェック
  health_check {
    healthy_threshold   = 2
    interval            = 30
    matcher             = 200
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${local.name_prefix}-shop"
  }
}

######################################################################
# ターゲットグループとインスタンスを直接紐つけ
######################################################################

#resource "aws_lb_target_group_attachment" "shop" {
  #target_group_arn = aws_lb_target_group.shop.arn
  #target_id        = data.terraform_remote_state.ec2.outputs.aws_instance_web_id
  #port             = 80
#}