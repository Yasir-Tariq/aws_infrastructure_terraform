output "output_iam" {
  value = "${
    map(
      "ins_profile", "${module.iam.instance_profile}"
    )
  }"
}