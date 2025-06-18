# replace {dns_server} and {dns_domain_name} in dot-and-doh-to-dns.conf
echo "Editing dot-and-doh-to-dns.conf"
sudo sed -i 's/{dns_domain_name}/'$DNS_DOMAIN_NAME'/g' dot-and-doh-to-dns.conf