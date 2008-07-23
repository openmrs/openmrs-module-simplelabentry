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
					var patient = msg.objs[0];
					_selectedPatientId = patient.patientId;
					$j("#otherIdentifier").val($j("#patientIdentifier").val());
					DWRSimpleLabEntryService.getPatient(patient.patientId, function(labPatient) {
						$('matchedIdentifier').innerHTML = patient.identifier;
						$('matchedName').innerHTML = labPatient.givenName + ' ' + labPatient.familyName;
						$('matchedGender').innerHTML = labPatient.gender;
						$('matchedAge').innerHTML = labPatient.age;
						$('matchedDistrict').innerHTML = labPatient.countyDistrict;
						$('matchedSector').innerHTML = labPatient.cityVillage;
						$('matchedCell').innerHTML = labPatient.neighborhoodCell;
						$('matchedAddress1').innerHTML = labPatient.address1;
					});
					showDiv('createOrderSection');
					hideDiv('patientSearchBox');
					$j(".idMatch").hide();
					$j(".nameMatch").show();
					$j(".createdPatientMatch").hide();
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
		hideDiv('createOrderSection');
		hideDiv('nameMatchSection');
		hideDiv('createPatientSection');
		_selectedPatientId = null;
	}

	function clearFormFields() {
		$j(".orderField").val('');
		dojo.widget.manager.getWidgetById("pSearch").clearSearch();
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
			_selectedPatientId = null;
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
						$('createOrderSection').style.display = '';
						$('matchedIdentifier').innerHTML = patId;
						$('matchedName').innerHTML = patient.givenName + ' ' + patient.familyName;
						$('matchedGender').innerHTML = patient.gender;
						$('matchedAge').innerHTML = patient.age;
						$('matchedDistrict').innerHTML = patient.countyDistrict;
						$('matchedSector').innerHTML = patient.cityVillage;
						$('matchedCell').innerHTML = patient.neighborhoodCell;
						$('matchedAddress1').innerHTML = patient.address1;
						$j(".idMatch").show();
						$j(".nameMatch").hide();
						$j(".createdPatientMatch").hide();
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
															$j("#matchedIdentifier").text(newIdent);
															$j("#matchedName").text(createdPatient.givenName + ' ' + createdPatient.familyName);
															$j("#matchedGender").text(createdPatient.gender);
															$j("#matchedAge").text(createdPatient.age);
															$j("#matchedDistrict").text(createdPatient.countyDistrict);
															$j("#matchedSector").text(createdPatient.cityVillage);
															$j("#matchedCell").text(createdPatient.neighborhoodCell);
															$j("#matchedAddress1").text(createdPatient.address1);
															showDiv('createOrderSection');
													   		hideDiv('createPatientSection');
															$j(".idMatch").hide();
															$j(".nameMatch").hide();
															$j(".createdPatientMatch").show();
														},
														errorHandler:function(errorString, exception) {
															alert(errorString);
														}
												   	}
			);
		}
	
		function createOrder() {
			var otherIdent = $j("#otherIdentifier").val();
			var otherIdentType = '${patientIdType}';
			var orderLoc = $j("#matchedOrderLocation").val();
			var orderConcept = $j("#matchedOrderConcept").val();
			var orderDate = $j("#matchedOrderDate").val();
			var accessionNum = $j("#matchedShortId").val();
			DWRSimpleLabEntryService.createLabOrder(_selectedPatientId, otherIdent, otherIdentType, orderConcept, orderLoc, orderDate, accessionNum, 
					{ 	callback:function(createdOrder) {
							location.reload();
						},
						errorHandler:function(errorString, exception) {
							alert(errorString);
						}
					}
			);
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
	
	<div id="createOrderSection" class="searchSection" style="display:none;">
		<span style="color:red; display:none;" class="idMatch">The following patient matches this ID.</span> 
		<span style="color:red; display:none;" class="nameMatch">You have selected the following patient. </span> 
		<span style="color:red; display:none;" class="createdPatientMatch">The following patient has been created.</span> 
		<span style="color:red;">Please review the fields below for accuracy before submitting Order.</span> 
		<table>
			<tr>
				<th>Long ID</th>
				<th class="nameMatch">Alternative ID</th>
				<th>Name / Surname</th>
				<th>Sex</th>
				<th>Age</th>
				<th>District</th>
				<th>Sector</th>
				<th>Cellule</th>
				<th>Umudugudu</th>
			</tr>
			<tr>
				<td id="matchedIdentifier"></td>
				<td class="nameMatch"><input type="text" id="otherIdentifier" name="otherIdentifier" /></td>
				<td id="matchedName"></td>
				<td id="matchedGender"></td>
				<td id="matchedAge"></td>
				<td id="matchedDistrict"></td>
				<td id="matchedSector"></td>
				<td id="matchedCell"></td>
				<td id="matchedAddress1"></td>
			</tr>
		</table>
		<br/>
		<table>
			<tr><th colspan="4">Order Details</td></tr>
			<tr>
				<th>Short ID:</th>
				<td><input type="text" id="matchedShortId" name="matchedShortId" /></td>
				<th><spring:message code="simplelabentry.orderLocation" />:</td>
				<td><openmrs_tag:locationField formFieldName="matchedOrderLocation" initialValue="${param.orderLocation}"/></td>
				<th><spring:message code="simplelabentry.orderType" />:</td>
				<td>
					<select id="matchedOrderConcept" name="matchedOrderConcept">
						<option value=""></option>
						<c:forEach items="${testTypes}" var="testType" varStatus="testTypeStatus">
							<option value="${testType.conceptId}" <c:if test="${param.orderConcept == testType.conceptId}">selected</c:if>>
								${empty testType.name.shortName ? testType.name.name : testType.name.shortName}
							</option>
						</c:forEach>
					</select>
				</td>
				<th><spring:message code="simplelabentry.orderDate" />: </td>
				<td><input type="text" id="matchedOrderDate" name="matchedOrderDate" size="10" value="${param.orderDate}" onFocus="showCalendar(this)" /></td>
			</tr>
		</table>	
		<br/>
		<input type="button" id="CreateOrderFromIdButton" value="Create Order for this Patient" />
		<input type="button" id="ClearPatientResultsButton" value="Cancel, this is incorrect" />
	</div>
	
	<div id="nameMatchSection" class="searchSection" style="display:none;">		
		<div id="patientSearchBox" style="padding:10px;">
			<span style="font-weight:bold;">No patients match this ID.  Please use the search field below to try to match the correct patient</span>
			<br/><br/>
			<div dojoType="PatientSearch" widgetId="pSearch" searchLabel="<spring:message code="Patient.searchBox" htmlEscape="true"/>" showVerboseListing="true"></div>
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
			<th></th>
			<th>Short ID</th>
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
					<td><a href="javascript:editOrder('${order.orderId}', '');"><small>Edit</small></a></td>
					<td>${order.accessionNumber}</td>
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
					<td align="right"><a href="javascript:deleteOrder('${order.orderId}', '');"><small>[X]</small></a></td>
				</tr>
			</c:if>
		</c:forEach>
	</table>
</div>