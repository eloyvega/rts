resource "aws_s3_bucket" "kubeadm_bucket" {
  bucket_prefix = "k8s-kubeadm-config"
  acl           = "private"
  force_destroy = true
}

output "kubeconf_download" {
  value = "aws s3 cp s3://${aws_s3_bucket.kubeadm_bucket.id}/config ~/.kube/config"
}
