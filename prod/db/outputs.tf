##################################################################
output "db" {
  description = "Map of dbs and their info"
  value = { for k, db in aws_db_instance.main : k => {
    engine               = db.engine
    engine_version       = db.engine_version
    instance_class       = db.instance_class
    storage_type         = db.storage_type
    db_subnet_group_name = db.db_subnet_group_name
    subnets = [
      for subnets in aws_db_subnet_group.main : subnets.subnet_ids
    ]
    security_group_ids = db.vpc_security_group_ids
    }
  }
}
##################################################################