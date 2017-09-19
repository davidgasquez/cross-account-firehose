data "aws_iam_policy_document" "test_assume_firehose_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "test_firehose_role" {
  name               = "test_firehose_role"
  assume_role_policy = "${data.aws_iam_policy_document.test_assume_firehose_policy.json}"
}

data "aws_iam_policy_document" "test_firehose_policy" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = ["*"]
  }
}

resource "aws_s3_bucket" "firehose_test_bucket" {
  bucket = "firehose_test_bucket"
  acl    = "private"
}

resource "aws_iam_role_policy" "firehose_role_policy" {
  name = "CrossAccountPolicy"
  role = "${aws_iam_role.test_firehose_role.id}"
  policy = "${data.aws_iam_policy_document.test_firehose_policy.json}"
}

resource "aws_kinesis_firehose_delivery_stream" "redshift_delivery_stream" {
  name        = "redshift_delivery_stream"
  destination = "redshift"

  s3_configuration {
    role_arn        = "${aws_iam_role.test_firehose_role.arn}"
    bucket_arn      = "${aws_s3_bucket.firehose_test_bucket.arn}"
    buffer_size     = "5"
    buffer_interval = "60"
  }

  redshift_configuration {
    role_arn           = "${aws_iam_role.test_firehose_role.arn}"
    cluster_jdbcurl    = "jdbc:redshift://${var.redshift_endpoint}:${var.redshift_port}/${var.redshift_database}"
    username           = "${var.redshift_user}"
    password           = "${var.redshift_password}"
    data_table_name    = "temp.firehose_test_table"
    copy_options = "json 'auto'"
  }
}
