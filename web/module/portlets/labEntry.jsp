<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:htmlInclude file="/dwr/interface/DWRPatientService.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRSimpleLabEntryService.js" />
<openmrs:htmlInclude file="/moduleResources/simplelabentry/jquery-1.2.6.min.js" />
<openmrs:htmlInclude file="/dwr/util.js" />
<openmrs:htmlInclude file="/scripts/dojoConfig.js" />
<openmrs:htmlInclude file="/scripts/dojo/dojo.js" />
<openmrs:htmlInclude file="/scripts/easyAjax.js" />
<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />
<openmrs:htmlInclude file="/moduleResources/simplelabentry/thickbox/thickbox-compressed.js" />
<openmrs:htmlInclude file="/moduleResources/simplelabentry/thickbox/thickbox.css" />

<openmrs:globalProperty key="simplelabentry.patientIdentifierType" var="patientIdType" />

<script type="text/javascript">

	dojo.require("dojo.widget.openmrs.PatientSearch");

	_selectedPatientId = null;
	
	dojo.addOnLoad( function() {
		searchWidget = dojo.widget.manager.getWidgetById("pSearch");
		
		dojo.event.topic.subscribe("pSearch/select", 
			function(msg) {
				if (msg.objs[0].patientId) {
					var currentPatient = msg.objs[0];
					_selectedPatientId = currentPatient.patientId;
					DWRUtil.setValues( {
						'nameMatchedIdentifier': currentPatient.identifier,
						'nameMatchedName': currentPatient.personName,
						'nameMatchedAge': currentPatient.age,
						'nameMatchedGender': currentPatient.gender
					} );
					showDiv('nameFoundSection');
					hideDiv('patientSearchBox');
					dojo.widget.manager.getWidgetById("pSearch").clearSearch();
				} else if (msg.objs[0].href)
					document.location = msg.objs[0].href;
			}
		);
		
		searchWidget.addPatientLink = '<a href="javascript:showCreatePatient();">Create New Patient</a>';
		searchWidget.inputNode.select();
		changeClassProperty("description", "display", "none");
	});

	function focusOnPatientSearch() {
		dojo.widget.manager.getWidgetById("pSearch").inputNode.select();
		dojo.widget.manager.getWidgetById("pSearch").inputNode.focus();
	}

	function hideNameMatchSections() {
		document.getElementById('nameFoundSection').style.display = 'none';
		document.getElementById('noNameFoundSection').style.display = 'none';
		_selectedPatientId = null;
	}

	function findPatient() {
		hideNameMatchSections();

		DWRPatientService.findPatients(null, false, function(matches) {
			if (matches.length == 1) {
				var currentPatient = matches[0];
				_selectedPatientId = currentPatient.patientId;
				DWRUtil.setValues( {
					'nameMatchedIdentifier': currentPatient.identifier,
					'nameMatchedName': currentPatient.personName,
					'nameMatchedAge': currentPatient.age,
					'nameMatchedGender': currentPatient.gender
				} );
				showDiv('nameFoundSection');
			} else {
				showDiv('noNameFoundSection');
			}
		});
	}
	
	function findNewPatient() {
		hideNameMatchSections();
		showDiv('nameMatchSection');
		showDiv('patientSearchBox');
		focusOnPatientSearch();
	}

	function clearPatientSearchFields() {
		hideDiv('idMatchSection');
		hideDiv('nameMatchSection');
		hideDiv('createPatientSection');
		hideNameMatchSections();
	}

	function showCreatePatient() {
		clearPatientSearchFields();
		showDiv('createPatientSection');
		_selectedPatientId = null;
	}
	
	function matchPatientById(patIdType, patId) {
		clearPatientSearchFields();
		DWRSimpleLabEntryService.getPatientByIdentifier(patIdType, patId, function(patient) {
				if (patient.patientId == null) {
					showDiv('nameMatchSection');
					showDiv('patientSearchBox');
				}
				else {
					_selectedPatientId = patient.patientId;
					$('idMatchSection').style.display = '';
					$('idMatchedIdentifier').innerHTML = patId;
					$('idMatchedName').innerHTML = patient.givenName + ' ' + patient.familyName;
					$('idMatchedGender').innerHTML = patient.gender;
					$('idMatchedAge').innerHTML = patient.age;
					$('idMatchedDistrict').innerHTML = patient.countyDistrict;
					$('idMatchedSector').innerHTML = patient.cityVillage;
					$('idMatchedCell').innerHTML = patient.neighborhoodCell;
					$('idMatchedAddress1').innerHTML = patient.address1;
				}
				$('newPatientIdentifier').innerHTML = patId;
			});
	}

	function createPatientAndOrder() {
		createPatient();
		createOrder();
	}

	function createPatient() {
		var newIdent = $('newPatientIdentifier').innerHtml;
		var newFirstName = $('newFirstName').value;
		var newLastName = $('newLastName').value;
		var newGender = $('newGender').value;
		var newAge = $('newAge').value;
		var newCountyDistrict = $('newCountyDistrict').value;
		var newCityVillage = $('newCityVillage').value;
		var newNeighborhoodCell = $('newNeighborhoodCell').value;
		var newAddress1 = $('newAddress1').value;
		_selectedPatientId = '';
	}

	function createOrder() {
		alert('Creating order for patient ' + _selectedPatientId + ', concept ${param.orderConcept}, location, ${param.orderLocation}, date ${param.orderDate}');
	}
</script>

<style>
	th,td {text-align:left; padding-left:10px; padding-right:10px;}
	.searchSection {padding:5px; border: 1px solid grey; background-color: whitesmoke;}
</style>

<table style="width:100%; border: 1px solid black;">
	<tr>
		<th>&nbsp;</th>
		<th>Long ID</th>
		<th>Name / Surname</th>
		<th>&nbsp;</th>
		<th>Age</th>
		<th>District</th>
		<th>Sector</th>
		<th>Cellule</th>
		<th>Umudugudu</th>
	</tr>
	<c:forEach items="${model.labOrders}" var="order" varStatus="orderStatus">
		<c:if test="${!empty order.orderId}">
			<tr>
				<td><a href="#">Edit</a></td>
				<td>${order.patient.patientIdentifier}</td>
				<td>${order.patient.personName.givenName} ${order.patient.personName.familyName}</td>
				<td>${order.patient.gender}</td>
				<td>${order.patient.age}</td>
				<c:if test="${!empty order.patient.personAddress}">
					<td>${order.patient.personAddress.countyDistrict}</td>
					<td>${order.patient.personAddress.cityVillage}</td>
					<td>${order.patient.personAddress.neighborhoodCell}</td>
					<td>${order.patient.personAddress.address1}</td>
				</c:if>
			</tr>
		</c:if>
	</c:forEach>
</table>
<br/>

<b class="boxHeader">Add New Order</b>
<div id="findPatientSection" style="align:left";" class="box" >
	1. Enter IMB ID (Long ID): 
	<input type="hidden" id="patientIdentifierType" name="patientIdentifierType" value="" />
	<input type="text" id="patientIdentifier" name="patientIdentifier" />
	<input type="button" value="Search" onclick="matchPatientById('${patientIdType}',$('patientIdentifier').value);" />
	<input type="button" value="Clear" onclick="$('patientIdentifier').value = ''; clearPatientSearchFields();" />
	<br/><br/>
	
	<div id="idMatchSection" class="searchSection" style="display:none;">
		<span>The following patient matches this ID.  Please confirm the patient details are correct.</span> 
		<table>
			<tr>
				<th>Long ID</th>
				<th>Name / Surname</th>
				<th>Sex</th>
				<th>Age</th>
				<th>District</th>
				<th>Sector</th>
				<th>Cellule</th>
				<th>Umudugudu</th>
			</tr>
			<tr>
				<td id="idMatchedIdentifier"></td>
				<td id="idMatchedName"></td>
				<td id="idMatchedGender"></td>
				<td id="idMatchedAge"></td>
				<td id="idMatchedDistrict"></td>
				<td id="idMatchedSector"></td>
				<td id="idMatchedCell"></td>
				<td id="idMatchedAddress1"></td>
			</tr>
		</table>
		<input type="button" value="Create Order for this Patient" onclick="createOrder();">
		<input type="button" value="Cancel, this is incorrect" onclick="clearPatientSearchFields();">
	</div>
	
	<div id="nameMatchSection" class="searchSection" style="display:none;">
		
		<div id="patientSearchBox" style="padding:10px;">
			<span style="font-weight:bold;">No patients match this ID.  Please use the search field below to try to match the correct patient</span>
			<br/><br/>
			<div dojoType="PatientSearch" widgetId="pSearch" searchLabel="<spring:message code="Patient.searchBox" htmlEscape="true"/>" showVerboseListing="true"></div>
		</div>
		<div id="nameFoundSection" style="display:none; padding-top:5px;">
			<div style="border-bottom: 1px solid black; padding:5px;">
				<table>
					<tr>
						<th>Long ID</th>
						<th>Name / Surname</th>
						<th>Sex</th>
						<th>Age</th>
					</tr>
					<tr>
						<td id="nameMatchedIdentifier"></td>
						<td id="nameMatchedName"></td>
						<td id="nameMatchedGender"></td>
						<td id="nameMatchedAge"></td>
					</tr>
				</table>
			</div>
			<div style="padding:5px;">
				<form name="patientFoundForm">
					<input type="button" value="Create Order for this Patient" onclick="javascript:createOrder();" />
					<input type="button" value="Return to Search" onclick="javascript:findNewPatient();" />
				</form>
			</div>
		</div>

		<div id="noNameFoundSection" style="display:none; padding-top:5px;">
			<span style="border-bottom: 1px solid black; font-weight:bold;">No matching patients were found.</span>
			&nbsp;&nbsp;
			<form name="noPatientFoundForm">
				<input type="button" value="Search Again" onclick="javascript:findNewPatient();" />
				<input type="button" value="Create New Patient" onclick="showCreatePatient()" />
			</form>
		</div>

	</div>

	<div id="createPatientSection" style="display:none;">
		<span>Enter new Patient Details Below</span> 
		<table cellspacing="0" cellpadding="3">
			<tr>
				<th>Long ID</th>
				<th>Given Name</th>
				<th>Family Name</th>
				<th>Sex</th>
				<th>Age</th>
				<th>District</th>
				<th>Sector</th>
				<th>Cellule</th>
				<th>Umudugudu</th>
			</tr>
			<tr>
				<td id="newPatientIdentifier"></td>
				<td><input type="text" id="newFirstName" name="newFirstName" size="10" /></td>
				<td><input type="text" id="newLastName" name="newLastName" size="10" /></td>
				<td>
					<openmrs:forEachRecord name="gender">
						<input type="radio" name="gender" id="${record.key}" value="${record.key}" <c:if test="${record.key == status.value}">checked</c:if> />
						<label for="${record.key}"> <spring:message code="simplelabentry.gender.${record.value}"/> </label>
					</openmrs:forEachRecord>
				</td>
				<td><input type="text" id="newAge" name="newAge" size="3" /></td>
				<td><input type="text" id="newCountyDistrict" name="newCountyDistrict" size="10" /></td>
				<td><input type="text" id="newCityVillage" name="newCityVillage" size="10" /></td>
				<td><input type="text" id="newNeighborhoodCell" name="newNeighborhoodCell" size="10" /></td>
				<td><input type="text" id="newAddress1" name="newAddress1" size="10" /></td>
				<td>
					<input type="button" value="Create" onclick="createPatientAndOrder();">
					<input type="button" value="Cancel" onclick="clearPatientSearchFields();">
				</td>
			</tr>
		</table>
	</div>
</div>