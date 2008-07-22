<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:htmlInclude file="/dwr/interface/DWRPatientService.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRSimpleLabEntryService.js" />
<openmrs:htmlInclude file="/moduleResources/simplelabentry/jquery-1.2.6.min.js" />
<openmrs:htmlInclude file="/dwr/util.js" />
<openmrs:htmlInclude file="/scripts/dojoConfig.js" />
<openmrs:htmlInclude file="/scripts/dojo/dojo.js" />
<openmrs:htmlInclude file="/scripts/easyAjax.js" />
<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />

<openmrs:globalProperty key="simplelabentry.patientIdentifierType" var="patientIdType" />

<script type="text/javascript">

	var $j = jQuery.noConflict();

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

	function clearPatientSearchFields() {
		hideDiv('idMatchSection');
		hideDiv('nameMatchSection');
		hideDiv('createPatientSection');
		hideNameMatchSections();
	}

	function clearFormFields() {
		$j(".orderField").val('');
		dojo.widget.manager.getWidgetById("pSearch").clearSearch();
	}

	function hideNameMatchSections() {
		hideDiv('nameFoundSection');
		hideDiv('noNameFoundSection');
		_selectedPatientId = null;
	}

	function showCreatePatient() {
		clearPatientSearchFields();
		showDiv('createPatientSection');
		_selectedPatientId = null;
	}

	function deleteOrder(orderId, reason) {
		if (confirm("Are you sure you want to delete this order?")) {
			DWRSimpleLabEntryService.deleteLabOrderAndEncounter(orderId, reason, { 
				callback:function() {location.reload();},
				errorHandler:function(errorString, exception) { alert(errorString); }
	   		});
	   		location.reload();
		}
	}

	$j(document).ready(function(){
	
		function findNewPatient() {
			hideNameMatchSections();
			showDiv('nameMatchSection');
			showDiv('patientSearchBox');
			dojo.widget.manager.getWidgetById("pSearch").inputNode.select();
			dojo.widget.manager.getWidgetById("pSearch").inputNode.focus();
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
						hideDiv('createdPatientText');
						showDiv('idMatchText');
					}
					$('newPatientIdentifier').innerHTML = patId;
				});
		}
	
		function createPatient() {
			var newIdent = $j('#newPatientIdentifier').text();
			var newIdentType = '${patientIdType}';
			var newIdentLoc = '${param.orderLocation}';
			var newFirstName = $('newFirstName').value;
			var newLastName = $('newLastName').value;
			var newGender = $j("input[@name='newGender']:checked").val();
			var newAge = $('newAge').value;
			var newCountyDistrict = $('newCountyDistrict').value;
			var newCityVillage = $('newCityVillage').value;
			var newNeighborhoodCell = $('newNeighborhoodCell').value;
			var newAddress1 = $('newAddress1').value;
			DWRSimpleLabEntryService.createPatient(	newFirstName, newLastName, newGender, newAge, newIdent, newIdentType, newIdentLoc, 
												   	newCountyDistrict, newCityVillage, newNeighborhoodCell, newAddress1, 
												   	{ 	callback:function(createdPatient) {
													   		_selectedPatientId = createdPatient.patientId;
															$j("#idMatchedIdentifier").text(newIdent);
															$j("#idMatchedName").text(createdPatient.givenName + ' ' + createdPatient.familyName);
															$j("#idMatchedGender").text(createdPatient.gender);
															$j("#idMatchedAge").text(createdPatient.age);
															$j("#idMatchedDistrict").text(createdPatient.countyDistrict);
															$j("#idMatchedSector").text(createdPatient.cityVillage);
															$j("#idMatchedCell").text(createdPatient.neighborhoodCell);
															$j("#idMatchedAddress1").text(createdPatient.address1);
															showDiv('idMatchSection');
															showDiv('createdPatientText');
															hideDiv('idMatchText');
													   		hideDiv('createPatientSection');
														},
														errorHandler:function(errorString, exception) {
															alert(errorString);
														}
												   	}
			);
		}
	
		function createOrder() {
			DWRSimpleLabEntryService.createLabOrder(_selectedPatientId, '${param.orderConcept}', '${param.orderLocation}', '${param.orderDate}', '', 
												   	{ 	callback:function(createdOrder) {
			   												location.reload();
														},
														errorHandler:function(errorString, exception) {
															alert(errorString);
														}
												   	}
			);
			clearPatientSearchFields();
		}

		$j("#SearchByIdButton").click( function() { 
			matchPatientById('${patientIdType}',$('patientIdentifier').value); 
		});
		
		$j("#ClearSearchButton").click( function() {
			clearFormFields();
			clearPatientSearchFields();
		});
		$j("#ClearSearchButton2").click( function() {
			clearFormFields();
			clearPatientSearchFields();
		});
		$j("#ClearPatientResultsButton").click( function() {
			clearFormFields();
			clearPatientSearchFields();
		});

		$j("#ShowCreatePatientButton").click( function() {
			showCreatePatient();
		});

		$j("#CreateOrderFromIdButton").click( function() {
			createOrder();
		});
		$j("#CreateOrderFromNameButton").click( function() {
			createOrder();
		});
		$j("#CreatePatientButton").click( function() {
			createPatient();
		});

		$j("#FindNewPatientButton").click( function() {
			findNewPatient();
		});
		$j("#FindNewPatientButton2").click( function() {
			findNewPatient();
		});
	});
</script>

<style>
	th,td {text-align:left; padding-left:10px; padding-right:10px;}
	.searchSection {padding:5px; border: 1px solid grey; background-color: whitesmoke;}
</style>

<b class="boxHeader">Add New Order</b>
<div id="findPatientSection" style="align:left;" class="box" >
	1. Enter IMB ID (Long ID): 
	<input type="text" id="patientIdentifier" class="orderField" name="patientIdentifier" />
	<input type="button" value="Search" id="SearchByIdButton" />
	<input type="button" value="Clear" id="ClearSearchButton" />
	<br/><br/>
	
	<div id="idMatchSection" class="searchSection" style="display:none;">
		<span style="color:red; display:none;" id="idMatchText">The following patient matches this ID.  Please confirm the patient details are correct.</span> 
		<span style="color:red; display:none;" id="createdPatientText">The following patient has been created.  Do you wish to create an order?</span> 
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
		<input type="button" id="CreateOrderFromIdButton" value="Create Order for this Patient" />
		<input type="button" id="ClearPatientResultsButton" value="Cancel, this is incorrect" />
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
					<input type="button" value="Create Order for this Patient" id="CreateOrderFromNameButton" />
					<input type="button" value="Return to Search" id="FindNewPatientButton" />
				</form>
			</div>
		</div>

		<div id="noNameFoundSection" style="display:none; padding-top:5px;">
			<span style="border-bottom: 1px solid black; font-weight:bold;">No matching patients were found.</span>
			&nbsp;&nbsp;
			<form name="noPatientFoundForm">
				<input type="button" value="Search Again" id="FindNewPatientButton2" />
				<input type="button" value="Create New Patient" id="ShowCreatePatientButton" />
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
				<td><input type="text" class="orderField" id="newFirstName" name="newFirstName" size="10" /></td>
				<td><input type="text" class="orderField" id="newLastName" name="newLastName" size="10" /></td>
				<td>
					<openmrs:forEachRecord name="gender">
						<input type="radio" class="orderField" name="newGender" id="newGender${record.key}" value="${record.key}" <c:if test="${record.key == status.value}">checked</c:if> />
						<label for="${record.key}"> <spring:message code="simplelabentry.gender.${record.value}"/> </label>
					</openmrs:forEachRecord>
				</td>
				<td><input type="text" class="orderField" id="newAge" name="newAge" size="3" /></td>
				<td><input type="text" class="orderField" id="newCountyDistrict" name="newCountyDistrict" size="10" /></td>
				<td><input type="text" class="orderField" id="newCityVillage" name="newCityVillage" size="10" /></td>
				<td><input type="text" class="orderField" id="newNeighborhoodCell" name="newNeighborhoodCell" size="10" /></td>
				<td><input type="text" class="orderField" id="newAddress1" name="newAddress1" size="10" /></td>
				<td>
					<input type="button" value="Create Patient" id="CreatePatientButton" />
					<input type="button" value="Cancel" id="ClearSearchButton2">
				</td>
			</tr>
		</table>
	</div>
</div>
<br/>
<b class="boxHeader">Existing Orders</b>
<div class="box">
	<table style="width:100%;">
		<tr style="background-color:#CCCCCC;">
			<th>Long ID</th>
			<th>Name / Surname</th>
			<th>Sex</th>
			<th>Age</th>
			<th>District</th>
			<th>Sector</th>
			<th>Cellule</th>
			<th>Umudugudu</th>
			<th></th>
		</tr>
		<c:if test="${fn:length(model.labOrders) == 1}"><tr><td>No Orders</td></tr></c:if>
		<c:forEach items="${model.labOrders}" var="order" varStatus="orderStatus">
			<c:if test="${!empty order.orderId}">
				<tr>
					<td>${order.patient.patientIdentifier}</td>
					<td>
						<a href="${pageContext.request.contextPath}/admin/patients/newPatient.form?patientId=${order.patient.patientId}">
							${order.patient.personName.givenName} ${order.patient.personName.familyName}
						</a>
					</td>
					<td>${order.patient.gender}</td>
					<td>${order.patient.age}</td>
					<c:choose>
						<c:when test="${!empty order.patient.personAddress}">
							<td>${order.patient.personAddress.countyDistrict}</td>
							<td>${order.patient.personAddress.cityVillage}</td>
							<td>${order.patient.personAddress.neighborhoodCell}</td>
							<td>${order.patient.personAddress.address1}</td>
						</c:when>
						<c:otherwise><td colspan=4">&nbsp;</td></c:otherwise>
					</c:choose>
					<td><a href="javascript:deleteOrder('${order.orderId}', '');">[X]</a></td>
				</tr>
			</c:if>
		</c:forEach>
	</table>
</div>