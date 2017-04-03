resource "template_file" "ecs_service_role_policy" {
  template = "${file("task_definitions/ecs-service-role-policy.json")}"
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role"
  assume_role_policy = "${file("task_definitions/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name     = "ecs_service_role_policy"
  policy   = "${template_file.ecs_service_role_policy.rendered}"
  role     = "${aws_iam_role.ecs_role.id}"
}
