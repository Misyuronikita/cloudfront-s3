### Bucket creating ###
resource "aws_s3_bucket" "bucket" {
  bucket        = "misyuro-test-2003"
  force_destroy = true

}

### Private access to bucket ###
resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

### ACLs enabled ###
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

### Private access to objects ###
resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership,
    aws_s3_bucket_public_access_block.access_block,
  ]
}

### Upload files ###
resource "aws_s3_object" "image" {
  bucket       = aws_s3_bucket.bucket.id
  for_each     = fileset("./my_app/", "**")
  key          = each.value
  content_type = "text/html"
  source       = "./my_app/${each.value}"
  etag         = filemd5("./my_app/${each.value}")
}

### Access through cloudfront ###
resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = <<EOF
{
	"Version": "2008-10-17",
	"Id": "PolicyForCloudFrontPrivateContent",
	"Statement": [
		{
			"Sid": "AllowCloudFrontServicePrincipal",
			"Effect": "Allow",
			"Principal": {
				"Service": "cloudfront.amazonaws.com"
			},
			"Action": "s3:GetObject",
			"Resource": "${aws_s3_bucket.bucket.arn}/*",
			"Condition": {
				"StringEquals": {
					"AWS:SourceArn": "${aws_cloudfront_distribution.s3_distribution.arn}"
				}
			}
		}
	]
}
EOF
}
