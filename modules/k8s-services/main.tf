#main.tf
resource "terraform_data" "module_depends_on_wait" {
  depends_on = [ local.module_depends_on ]
  input      = local.module_depends_on
}