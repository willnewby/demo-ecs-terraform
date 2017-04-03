
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

data "template_file" "ecs_instance_role_policy" {
    template = "${file("iam_policy_docs/ecs-instance-role-policy.json")}"
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "helloEcsInstanceRole"
  assume_role_policy = "${data.template_file.ecs_instance_role_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attach" {
    role       = "${aws_iam_role.ecs_instance_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name  = "test_profile"
  roles = ["${aws_iam_role.ecs_instance_role.name}"]
}
