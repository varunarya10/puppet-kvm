class kvm (
    $vm_name	= 'node1',
    $mem_mb	= '1024',
    $vcpu	= '1',
    $bridge	= 'br0',
    $image_url	= 'http://192.168.43.128/cirros.qcow2',
    $vm_uuid	= '5fe11193-d3fa-4cec-a9d5-2c211323024e',
    $vm_serial	= 'mu.jio-p1-ctrl-1',
    $vmimage_path	= '/var/lib/libvirt/images',
    $source	= 'image',
    $disk_size	= '20G',
    $rbd_disk_image	= undef,
    $mgmt_vm_virsh_secret_uuid,
    $mgmt_vm_virsh_secret_value,
) {

class { '::kvm::install': } ->
class { '::kvm::config': }

}
