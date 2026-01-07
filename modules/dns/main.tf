# modules/dns/main.tf

resource "aws_route53_zone" "private" {
  name = "hl.local"
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "control" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "ansible-control.hl.local"
  type    = "A"
  ttl     = "300"
  records = [var.control_node_ip]
}

resource "aws_route53_record" "managed" {
  count   = 3
  zone_id = aws_route53_zone.private.zone_id
  name    = "ansible${count.index + 2}.hl.local"
  type    = "A"
  ttl     = "300"
  records = [var.managed_ips[count.index]]
}

resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "ansible5.hl.local"
  type    = "A"
  ttl     = "300"
  records = [var.db_node_ip]
}