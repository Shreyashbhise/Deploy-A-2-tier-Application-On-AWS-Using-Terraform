# RDS MySQL database
resource "aws_db_instance" "two-tier-db-1" {
  allocated_storage           = 5
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t2.micro"
  db_subnet_group_name        = "two-tier-db-sub"  # Reference to the DB subnet group defined elsewhere
  vpc_security_group_ids      = [aws_security_group.two-tier-db-sg.id]  # Reference to the DB security group
  parameter_group_name        = "default.mysql5.7"
  db_name                     = "two_tier_db1"  # Name of the initial database
  username                    = "admin"  # Master username
  password                    = "shreyash16"  # Master password
  allow_major_version_upgrade = true  # Allow major version upgrades
  auto_minor_version_upgrade  = true  # Enable automatic minor version upgrades
  backup_retention_period     = 35  # Retention period for automated backups in days
  backup_window               = "22:00-23:00"  # Preferred backup window (UTC)
  maintenance_window          = "Sat:00:00-Sat:03:00"  # Maintenance window for RDS updates
  multi_az                    = false  # Disable Multi-AZ deployment
  skip_final_snapshot         = true  # Skip final DB snapshot during deletion
}
