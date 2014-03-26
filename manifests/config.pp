#
class kvm::config inherits kvm {

file { "/etc/apparmor.d/usr.sbin.libvirtd":
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => 0644,
        content => template("kvm/usr.sbin.libvirtd"),
	notify => Service['apparmor'],
  }

file { "/etc/apparmor.d/abstractions/libvirt-qemu":
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => 0644,
        content => template("kvm/libvirt-qemu"),
	notify => Service['apparmor'],
  }

service { 'apparmor':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      provider  => "upstart",
    }

service { 'dbus':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      provider  => "upstart",
    }

    exec { "secret_define_mgmt_vm":
        command => "echo \"<secret ephemeral='no' private='no'><uuid>$::kvm_env::mgmt_vm_virsh_secret_uuid</uuid><usage type='ceph'><name>client.mgmt_vm secret</name></usage></secret>\" > /tmp/secret.xml_$::kvm_env::mgmt_vm_virsh_secret_uuid && virsh secret-define --file /tmp/secret.xml_$::kvm_env::mgmt_vm_virsh_secret_uuid",
        unless => "virsh secret-list | egrep $::kvm_env::mgmt_vm_virsh_secret_uuid",
    }
    ->
    exec { "secret_set_value_mgmt_vm":
        command => "virsh secret-set-value --secret $::kvm_env::mgmt_vm_virsh_secret_uuid --base64 $::kvm_env::mgmt_vm_virsh_secret_value",
        unless => "echo $::kvm_env::mgmt_vm_virsh_secret_value |grep '$(virsh -q secret-get-value $::kvm_env::mgmt_vm_virsh_secret_uuid)'",
	notify => Service ['libvirt'],
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

}
