data "aws_cloudformation_export" "habitica_stats_database" {
  name = "HabiticaStatsDatabaseName"
}

data "aws_cloudformation_export" "habitica_stats_table" {
  name = "HabiticaStatsTableName"
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-arm64"
}
