output "s3_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "s3-bucket-name" {
  value = aws_s3_bucket.bucket.id
}
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
} 
