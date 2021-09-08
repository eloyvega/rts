resource "aws_s3_bucket" "kubeadm_bucket" {
  bucket_prefix = "k8s-kubeadm-config"
  acl           = "private"
  force_destroy = true
}
