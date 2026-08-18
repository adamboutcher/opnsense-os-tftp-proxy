{#
 # Copyright (c) 2024 Adam Boutcher
 # All rights reserved.
 #
 # Redistribution and use in source and binary forms, with or without
 # modification, are permitted provided that the following conditions are met:
 #
 # 1. Redistributions of source code must retain the above copyright notice,
 #    this list of conditions and the following disclaimer.
 #
 # 2. Redistributions in binary form must reproduce the above copyright
 #    notice, this list of conditions and the following disclaimer in the
 #    documentation and/or other materials provided with the distribution.
 #
 # THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 # INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 # AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 # AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 # OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 # SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 # INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 # CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 # ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 # POSSIBILITY OF SUCH DAMAGE.
 #}

<script>
$(document).ready(function() {
    mapDataToFormUI({'frm_GeneralSettings': "/api/tftpproxy/settings/get"}).done(function() {
        formatTokenizersUI();
        $('.selectpicker').selectpicker('refresh');
        updateServiceControlUI('tftpproxy');
    });

    $("#reconfigureAct").SimpleActionButton({
        onPreAction: function() {
            const dfObj = $.Deferred();
            saveFormToEndpoint("/api/tftpproxy/settings/set", 'frm_GeneralSettings',
                dfObj.resolve, true, dfObj.reject);
            return dfObj;
        },
        onAction: function(data, status) {
            if (status === "success" && data.status === 'ok') {
                ajaxCall("/api/tftpproxy/service/reconfigure", {}, function() {
                    updateServiceControlUI('tftpproxy');
                });
            }
        }
    });

    updateServiceControlUI('tftpproxy');
});
</script>

<section class="page-content-main">
    <div class="content-box">
        <div class="col-md-12">
            <br/>
            <p>{{ lang._('TFTP Proxy uses the BSD base-system tftp-proxy(8) via inetd(8). Enable this service and add a firewall NAT port-forward rule redirecting UDP/69 to the listen address and port configured below (default: 127.0.0.1:6969). The required pf(4) anchors are registered automatically.') }}</p>
        </div>
        {{ partial("layout_partials/base_form", ['fields': general, 'id': 'frm_GeneralSettings']) }}
    </div>
    <br/>
    <div class="content-box">
        <div class="col-md-12">
            <br/>
            <button class="btn btn-primary" id="reconfigureAct"
                    data-endpoint="/api/tftpproxy/service/reconfigure"
                    data-label="{{ lang._('Apply') }}"
                    type="button">
                {{ lang._('Apply') }}
            </button>
            <br/><br/>
        </div>
    </div>
</section>
