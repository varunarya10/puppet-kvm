#
class kvm::rm_nated_network {

## Remove default network if already there
  exec { 'rm_virbr0': 
	command => "virsh net-destroy default && virsh net-undefine default",
	path    => "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin",
	onlyif 	=> "virsh -q net-list | grep -q default" ,
#	require => Service['libvirt-bin'],
  }

}
