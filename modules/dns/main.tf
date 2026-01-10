# modules/dns/main.tf

resource "aws_route53_zone" "private" {
  name = "hyfertechsolutions.com"
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_zone" "reverse" {
  name = "1.0.10.in-addr.arpa"
  vpc {
    vpc_id = var.vpc_id
  }
}

# --- Forward Records ---

resource "aws_route53_record" "control" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "ansible-control.hyfertechsolutions.com"
  type    = "A"
  ttl     = "300"
  records = [var.control_node_ip]
}

resource "aws_route53_record" "managed" {
  count   = 3
  zone_id = aws_route53_zone.private.zone_id
  name    = "ansible-node${count.index + 1}.hyfertechsolutions.com"
  type    = "A"
  ttl     = "300"
  records = [var.managed_ips[count.index]]
}

resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "ansible-db.hyfertechsolutions.com"
  type    = "A"
  ttl     = "300"
  records = [var.db_node_ip]
}

# --- Reverse Records (PTR) ---

resource "aws_route53_record" "control_ptr" {
  zone_id = aws_route53_zone.reverse.zone_id
  name    = "${element(split(".", var.control_node_ip), 3)}.1.0.10.in-addr.arpa"
  type    = "PTR"
  ttl     = "300"
  records = ["ansible-control.hyfertechsolutions.com"]
}

resource "aws_route53_record" "managed_ptr" {
  count   = 3
  zone_id = aws_route53_zone.reverse.zone_id
  name    = "${element(split(".", var.managed_ips[count.index]), 3)}.1.0.10.in-addr.arpa"
  type    = "PTR"
  ttl     = "300"
  records = ["ansible-node${count.index + 1}.hyfertechsolutions.com"]
}

resource "aws_route53_record" "db_ptr" {
  zone_id = aws_route53_zone.reverse.zone_id
  name    = "${element(split(".", var.db_node_ip), 3)}.1.0.10.in-addr.arpa"
  type    = "PTR"
  ttl     = "300"
  records = ["ansible-db.hyfertechsolutions.com"]
}