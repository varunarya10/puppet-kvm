class kvm::install inherits kvm {

  package { 'dbus':
    ensure => installed,
  }

if !defined(Package['qemu-kvm']) {
  package { 'qemu-kvm':
    ensure => installed,
  }
}
 
if !defined(Package['libvirt']) {
  package { 'libvirt':
	name	=> 'libvirt-bin',
	ensure 	=> installed,
  }
}
  package { 'qemu-kvm-spice':
	ensure 	=> purged,
  }

}

