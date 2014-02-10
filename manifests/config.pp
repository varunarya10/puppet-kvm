#
class kvm::config inherits kvm {

service { 'dbus':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      provider  => "upstart",
    }
->
service { 'libvirt':
      ensure     => running,
      enable     => true,
      name       => "libvirt-bin",
      hasstatus  => true,
      hasrestart => true,
      provider	=> "upstart",
    }

->
  file { "/var/lib/libvirt/images/$vm_name":
    ensure  => directory,
    owner   => 0,
    group   => 0,
    mode    => '0755',
  }
->
  file { "/var/lib/libvirt/images/$vm_name/host.xml":
	ensure	=> file,
	owner	=> root,
	group	=> root,
	mode	=> 0644,
	content	=> template("kvm/host.xml.erb"),
  }

  if $source == 'image' {
    exec { 'getimage':
   	command => "wget $image_url -O /var/lib/libvirt/images/$vm_name/disk_image.qcow2",
	path	=> "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin",
	unless	=> "test -f /var/lib/libvirt/images/$vm_name/disk_image.qcow2",
	require	=> File["/var/lib/libvirt/images/$vm_name/host.xml"],
	before	=> Exec['vm_define'],
    }
  } elsif $source == 'pxe' {
    exec { 'bootimage':
	command => "qemu-img create -f qcow2 /var/lib/libvirt/images/$vm_name/disk_image.qcow2 $disk_size",
	path    => "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin",
        unless  => "test -f /var/lib/libvirt/images/$vm_name/disk_image.qcow2",
        require => File["/var/lib/libvirt/images/$vm_name/host.xml"],
	before	=> Exec['vm_define'],
    }
  } else {
	warn("$source is not valid Source")
  }


## Define the VM, if not already defined in libvirt
## Also enable autostart to make sure the vm boot on startup

  exec { 'vm_define':
        command => "virsh define /var/lib/libvirt/images/$vm_name/host.xml; virsh autostart $vm_name",
        path    => "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin",
        unless  => "virsh -q list --all | grep -q $vm_name",
  }

-> 

  exec { 'vm_boot':
        command => "virsh start $vm_name",
        path    => "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin",
        unless  => "virsh -q list --all | grep -q \"$vm_name *running\"",
  }

   
## Remove default network if already there
  exec { 'rm_virbr0': 
	command => "virsh net-destroy default && virsh net-undefine default",
	path    => "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin",
	onlyif 	=> "virsh -q net-list | grep -q default" ,
	require => Service['libvirt-bin'],
  }


## Start 
  
#    ~>
#	notify { "Removing default libvirt nat bridge":}
#-> 
#  if $::br_configured =~ /.*,"$bridge",.*/ {
#    file { "/tmp/out":
#	ensure 	=> file,
#	owner 	=> root,
#	content => "$br_configured\n",
#	}
#  } else {
#    notify {"Bridge -${bridge}- is not configured":}	
#  }

}
