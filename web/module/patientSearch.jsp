<openmrs:htmlInclude file="/scripts/easyAjax.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRPatientService.js" />
<openmrs:htmlInclude file="/dwr/util.js" />
<openmrs:htmlInclude file="/scripts/dojoConfig.js" />
<openmrs:htmlInclude file="/scripts/dojo/dojo.js" />
<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />

<openmrs:require privilege="View Patients" otherwise="/login.htm" redirect="/module/simplelabentry/index.htm" />

<script type="text/javascript">

	dojo.require("dojo.widget.openmrs.PatientSearch");
	
	dojo.addOnLoad( function() {
		searchWidget = dojo.widget.manager.getWidgetById("pSearch");
		
		dojo.event.topic.subscribe("pSearch/select", 
			function(msg) {
				if (msg.objs[0].patientId) {
					var currentPatient = msg.objs[0];
					_patientSearchFragCurrentPatientId = msg.objs[0].patientId;
					DWRUtil.setValues( {
						'patientName': currentPatient.personName,
						'patientAge': currentPatient.age,
						'patientGender': currentPatient.gender
					} );
					showDiv('patientFoundSection');
					hideDiv('findPatientForm');
					dojo.widget.manager.getWidgetById("pSearch").clearSearch();
				} else if (msg.objs[0].href)
					document.location = msg.objs[0].href;
			}
		);
		
		searchWidget.addPatientLink = '<a href="createPatient.form"><spring:message javaScriptEscape="true" code="simplelabentry.patient.create_new"/></a>';
		searchWidget.inputNode.select();
		changeClassProperty("description", "display", "none");
	});

	function focusOnPatientSearch() {
		dojo.widget.manager.getWidgetById("pSearch").inputNode.select();
		dojo.widget.manager.getWidgetById("pSearch").inputNode.focus();
	}

	var _patientSearchFragCurrentPatientId = '';

	function hideSections() {
		document.getElementById('patientFoundSection').style.display = 'none';
		document.getElementById('noPatientFoundSection').style.display = 'none';
	}

	function findPatient() {
		hideSections();
		var patId = document.findPatientForm.patientId.value;

		DWRPatientService.findPatients(patId, false, function(matches) {
			if (matches.length == 1) {
				var currentPatient = matches[0];
				_patientSearchFragCurrentPatientId = currentPatient.patientId;
				DWRUtil.setValues( {
					'patientName': currentPatient.personName,
					'patientAge': currentPatient.age,
					'patientGender': currentPatient.gender
				} );
				document.getElementById('patientFoundSection').style.display = '';
			} else {
				document.getElementById('noPatientFoundSection').style.display = '';
			}
		});
	}
	
	function useExistingPatient() {
		document.location = 'labOrder.form?patientId=' + _patientSearchFragCurrentPatientId;
	}
	
	function findNewPatient() {
		hideSections();
		showDiv('findPatientForm');
		focusOnPatientSearch()
	}
</script>

<div id="findPatientLayer">
	<div id="findPatientForm">
		<b class="boxHeader"><spring:message code="Patient.find"/></b>
		<div class="box">
			<div dojoType="PatientSearch" widgetId="pSearch" searchLabel="<spring:message code="Patient.searchBox" htmlEscape="true"/>" showVerboseListing="true"></div>
		</div>
	</div>
	<div id="patientFoundSection" style="display:none; padding-top:5px;">
		<div style="border-bottom: 1px solid black; padding:5px;">
			<spring:message code="simplelabentry.patient.found" />
			<br/>
			<b>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<span id="patientName"></span> | 
				<spring:message code="Person.age" />: <span id="patientAge"></span> | 
				<spring:message code="Person.gender" />: <span id="patientGender"></span>
			</b>
		</div>
		<div style="padding:5px;">
			<form name="patientFoundForm">
				<input type="button" value="<spring:message code="simplelabentry.patient.use_existing" />" onclick="javascript:useExistingPatient();" />
				<input type="button" value="<spring:message code="simplelabentry.patient.search_again" />" onclick="javascript:findNewPatient();" />
			</form>
		</div>
	</div>
	<div id="noPatientFoundSection" style="display:none; padding-top:5px;">
		<span style="border-bottom: 1px solid black; font-weight:bold;"><spring:message code="simplelabentry.patient.not_found" /></span>
		&nbsp;&nbsp;
		<form name="noPatientFoundForm">
			<input type="button" value="<spring:message code="simplelabentry.patient.search_again" />" onclick="javascript:findNewPatient();" />
			<input type="button" value="<spring:message code="simplelabentry.patient.create_new" />" onclick="javascript:document.location='createPatient.form';" />
		</form>
	</div>
</div>