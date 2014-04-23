#
define kvm::vm_boot  (
    $vm_name    = 'node1',
    $mem_mb     = '1024',
    $vcpu       = '1',
    $bridge     = 'br0',
    $image_url  = 'http://vmimages/vm_images/ubuntu-12.04_with_puppet.qcow2',
    $vm_uuid    = '5fe11193-d3fa-4cec-a9d5-2c211323024e',
    $vmimage_path       = '${vmimage_path}',
    $vm_serial  = 'mu.jio-p1-ctrl-1',
    $source     = 'image',
    $disk_size  = '20G',
    $rbd_disk_image     = undef,
    $mac_addr,
) {

  file { "${vmimage_path}/$vm_name":
    ensure  => directory,
    owner   => 0,
    group   => 0,
    mode    => '0755',
  }
->
  file { "${vmimage_path}/$vm_name/host.xml":
	ensure	=> file,
	owner	=> root,
	group	=> root,
	mode	=> 0644,
	content	=> template("kvm/host.xml.erb"),
  }

  if $source == 'image' {
    exec { "getimage_${vm_name}":
   	command => "wget $image_url -O ${vmimage_path}/$vm_name/disk_image.qcow2",
	path	=> "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin",
	unless	=> "test -f ${vmimage_path}/$vm_name/disk_image.qcow2",
	require	=> File["${vmimage_path}/$vm_name/host.xml"],
	before	=> Exec["vm_define_${vm_name}"],
    }
  } elsif $source == 'pxe' {
    exec { "bootimage_${vm_name}":
	command => "qemu-img create -f qcow2 ${vmimage_path}/$vm_name/disk_image.qcow2 $disk_size",
	path    => "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin",
        unless  => "test -f ${vmimage_path}/$vm_name/disk_image.qcow2",
        require => File["${vmimage_path}/$vm_name/host.xml"],
	before	=> Exec["vm_define_${vm_name}"],
    }
  } elsif $source == 'rbd' {
    if ! $rbd_disk_image {
	fail("There must be a valid rbd disk image mention")
    }

  } else {
	warn("$source is not valid Source")
  }


## Define the VM, if not already defined in libvirt
## Also enable autostart to make sure the vm boot on startup

  exec { "vm_define_${vm_name}":
        command => "virsh define ${vmimage_path}/$vm_name/host.xml; virsh autostart $vm_name",
        path    => "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin",
        unless  => "virsh -q list --all | grep -q $vm_name",
  }

-> 

  exec { "vm_boot_${vm_name}":
        command => "virsh start $vm_name",
        path    => "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin",
        unless  => "virsh -q list --all | grep -q \"$vm_name *running\"",
  }

   

}
