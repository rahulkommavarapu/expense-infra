data "aws_ssm_parameter" "vpc_id" {

  name ="/${var.project_name}/${var.environment}/vpc_id"

}
# data "aws_ssm_parameter" "db_password" {
#   name            = "/expense/dev/db_password"
#   with_decryption = true
# }