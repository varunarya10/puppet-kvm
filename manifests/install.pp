class kvm::install inherits kvm {

  package { 'dbus':
    ensure => installed,
  }

  package { 'qemu-kvm':
    ensure => installed,
  }

  package { 'libvirt-bin':
	ensure 	=> installed,
  }

  package { 'qemu-kvm-spice':
	ensure 	=> installed,
  }

}

