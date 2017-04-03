
data "template_file" "ecs_role" {
  template = "${file("iam_policy_docs/ecs-role.json")}"
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role"
  assume_role_policy = "${data.template_file.ecs_role.rendered}"
}

data "template_file" "ecs_service_role_policy" {
  template = "${file("iam_policy_docs/ecs-service-role-policy.json")}"
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name     = "ecs_service_role_policy"
  policy   = "${data.template_file.ecs_service_role_policy.rendered}"
  role     = "${aws_iam_role.ecs_role.id}"
}
