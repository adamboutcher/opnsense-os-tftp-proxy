{% if helpers.exists('OPNsense.tftpproxy.general.enabled') and OPNsense.tftpproxy.general.enabled == '1' %}
# os-tftp-proxy: listenaddress={{ OPNsense.tftpproxy.general.listenaddress }} listenport={{ OPNsense.tftpproxy.general.listenport }}
tftp-proxy dgram udp wait root /usr/libexec/tftp-proxy tftp-proxy{% if OPNsense.tftpproxy.general.verbose == '1' %} -v{% endif %}

{% endif %}
