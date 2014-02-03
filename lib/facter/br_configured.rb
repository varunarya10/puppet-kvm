Facter.add("br_configured") do
    setcode do
	Facter::Util::Resolution.exec("brctl show | grep ^br[0-9] | awk '{printf $1\",\"}'" ).chomp.sub(/^\s*/,',')
    end
end

