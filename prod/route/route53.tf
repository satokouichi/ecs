######################################################################
# ドメイン（事前にホストゾーンの作成とNSレコードの設定が必要）
######################################################################

data "aws_route53_zone" "this" {
  name = "theadsljpetkewrpdfsdsdsi.click"
}

######################################################################
# Aレコード
######################################################################

resource "aws_route53_record" "root_a" {
  count = var.enable_alb ? 1 : 0

  name    = data.aws_route53_zone.this.name
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id

  # ALBと紐つけ
  alias {
    evaluate_target_health = true
    name                   = aws_lb.this[0].dns_name
    zone_id                = aws_lb.this[0].zone_id
  }
  
  # ALBを使わずに直接ドメインにインスタンスを紐付ける場合のみ設定
  #records = [data.terraform_remote_state.ec2.outputs.aws_instance_web_public_ip]
}
