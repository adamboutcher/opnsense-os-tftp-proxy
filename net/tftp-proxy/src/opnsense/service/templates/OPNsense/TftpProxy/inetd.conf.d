{% if helpers.exists('OPNsense.tftpproxy.general.enabled') and OPNsense.tftpproxy.general.enabled == '1' %}
{{ OPNsense.tftpproxy.general.listenaddress }}:{{ OPNsense.tftpproxy.general.listenport }} dgram udp wait root /usr/libexec/tftp-proxy tftp-proxy{% if OPNsense.tftpproxy.general.verbose == '1' %} -v{% endif %}

{% endif %}
