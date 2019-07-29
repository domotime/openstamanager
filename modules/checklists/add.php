<?php

include_once __DIR__.'/../../core.php';

echo '
<form action="" method="post" id="add-form">
    <input type="hidden" name="op" value="add">
    <input type="hidden" name="backto" value="record-edit">

    <!-- DATI -->
    <div class="panel panel-primary">
        <div class="panel-heading">
            <h3 class="panel-title">'.tr('Dati').'</h3>
        </div>

        <div class="panel-body">
            <div class="row">
                <div class="col-md-6">
                    {[ "type": "text", "label": "'.tr('Nome').'", "name": "name", "value": "$name$", "required": 1 ]}
                </div>

                <div class="col-md-3">
                    {[ "type": "select", "label": "'.tr('Modulo del template').'", "name": "module", "values": "query=SELECT id, title AS descrizione FROM zz_modules WHERE enabled = 1", "value": "'.$record['id_module'].'", "disabled": "'.!empty($record['id_plugin']).'" ]}
                </div>
                
                <div class="col-md-3">
                    {[ "type": "select", "label": "'.tr('Plugin del template').'", "name": "plugin", "values": "query=SELECT id, title AS descrizione FROM zz_plugins WHERE enabled = 1", "value": "'.$record['id_plugin'].'", "disabled": "'.!empty($record['id_module']).'" ]}
                </div>
            </div>
        </div>
    </div>

	<!-- PULSANTI -->
	<div class="row">
        <div class="col-md-12 text-right">
            <button type="submit" class="btn btn-primary">
                <i class="fa fa-plus"></i> '.tr('Aggiungi').'
            </button>
        </div>
    </div>
</form>

<script>
$(document).ready(function() {
    $("#module").change(function() {
        if ($(this).val()){
            $("#plugin").attr("disabled", true);
        } else {
            $("#plugin").attr("disabled", false);
        }
    });
    
    $("#plugin").change(function() {
        if ($(this).val()){
            $("#module").attr("disabled", true);
        } else {
            $("#module").attr("disabled", false);
        }
    });
});
</script>';
