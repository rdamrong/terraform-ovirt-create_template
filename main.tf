variable "ovirt_password" {
   type = string
   description = "oVirt Admin Password"

}

provider "ovirt" {
   username = "admin@internal"
   url = "https://ovirt.example.com/ovirt-engine/api"
   password = var.ovirt_password
}


resource "ovirt_image_transfer" "centos_transfer" {
  alias             = "centos7"
  source_url        = "http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  storage_domain_id = "d1a97267-e32a-419b-851e-4c20ae67d264"
  sparse            = true
}

resource "ovirt_vm" "tmpvm" {
  name       = "tmpvm-for-${ovirt_image_transfer.centos_transfer.alias}"
  cluster_id = "c6c4902a-5721-11ea-983e-00163e58725a"
  block_device {
    disk_id   = ovirt_image_transfer.centos_transfer.disk_id
    interface = "virtio_scsi"
  }
}

resource "ovirt_template" "centos7" {
  name       = "template-for-${ovirt_image_transfer.centos_transfer.alias}"
  cluster_id = ovirt_vm.tmpvm.cluster_id
  // create from vm
  vm_id = ovirt_vm.tmpvm.id
}
