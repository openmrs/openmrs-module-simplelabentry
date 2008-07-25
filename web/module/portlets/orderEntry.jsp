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

					DWRSimpleLabEntryService.getPatient(patient.patientId, function(labPatient) { loadPatient(labPatient) });
					clearPatientAndSearchFields();
					_selectedPatientId = patient.patientId;
					$j("#otherIdentifier").text($j("#patientIdentifier").val());
					$j("#matchedPatientSection").show();
					$j(".nameMatch").show();
					
				} else if (msg.objs[0].href)
					document.location = msg.objs[0].href;
			}
		);
		
		searchWidget.addPatientLink = '<a href="javascript:showCreatePatient();">Create New Patient</a>';
		searchWidget.inputNode.select();
		changeClassProperty("description", "display", "none");
	});

	function loadPatient(labPatient) {
		$('matchedIdentifier').innerHTML = labPatient.identifier + (labPatient.otherIdentifiers == '' ? '' : '<br/><small>(' + labPatient.otherIdentifiers + ')</small>');
		$('matchedName').innerHTML = labPatient.givenName + ' ' + labPatient.familyName;
		$('matchedGender').innerHTML = labPatient.gender;
		$('matchedAge').innerHTML = labPatient.age;
		$('matchedDistrict').innerHTML = labPatient.countyDistrict;
		$('matchedSector').innerHTML = labPatient.cityVillage;
		$('matchedCell').innerHTML = labPatient.neighborhoodCell;
		$('matchedAddress1').innerHTML = labPatient.address1;
	}

	function clearPatientAndSearchFields() {
		_selectedPatientId = null;;
		clearSearchFields();
	}

	function clearSearchFields() {
		$j("#otherIdentifier").text('');
		$j("#nameMatchSection").hide();
		$j("#matchedPatientSection").hide();
		$j(".idMatch").hide();
		$j(".nameMatch").hide();
		$j(".createdPatientMatch").hide();
		$j("#createPatientSection").hide();
		$j(".orderDetailSection").remove();
		dojo.widget.manager.getWidgetById("pSearch").clearSearch();
	}

	function clearFormFields() {
		$j(".orderField").val('');
 		clearPatientAndSearchFields();
	}

	function showCreatePatient() {
		clearSearchFields();
		$j("#createPatientSection").show();
	}

	$j(document).ready(function(){
	
		function findNewPatient() {
			clearPatientAndSearchFields();
			dojo.widget.manager.getWidgetById("pSearch").inputNode.select();
			dojo.widget.manager.getWidgetById("pSearch").inputNode.focus();
		}

		function showNewOrder() {
			$j("#newIdentifierAddSection").hide();
			$j(".orderDetailTemplate").clone().removeClass("orderDetailTemplate").appendTo($j("#newOrderSection")).addClass("orderDetailSection").show();
			$j(".orderDetailSection input[name='startDate']").val('${model.orderDate}');
			$j(".orderDetailSection select[name='location']").val('${model.orderLocation}');
			$j(".orderDetailSection select[name='concept']").val('${model.orderConcept}');
			$j(".orderDetailSection :button[name='CreateOrderButton']").click( function() { createOrder(); } );
		}

		function matchPatientById(patIdType, patId) {
			clearPatientAndSearchFields();
			DWRSimpleLabEntryService.getPatientByIdentifier(patIdType, patId, function(patient) {
				if (patient.patientId == null) {
					$j("#nameMatchSection").show();
				}
				else {
					_selectedPatientId = patient.patientId;
					loadPatient(patient);
					$j(".idMatch").show();
					$j("#matchedPatientSection").show();
					$j("#newOrderSection").show();
					showNewOrder();
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
			var newGender = $j("input[name='newGender']:checked").val();
			var newAge = $('newAge').value;
			var newCountyDistrict = $('newCountyDistrict').value;
			var newCityVillage = $('newCityVillage').value;
			var newNeighborhoodCell = $('newNeighborhoodCell').value;
			var newAddress1 = $('newAddress1').value;
			DWRSimpleLabEntryService.createPatient(	newFirstName, newLastName, newGender, newAge, newIdent, newIdentType, newIdentLoc, 
												   	newCountyDistrict, newCityVillage, newNeighborhoodCell, newAddress1, 
												   	{ 	callback:function(createdPatient) {
															clearPatientAndSearchFields();
													   		_selectedPatientId = createdPatient.patientId;
															$j("#matchedIdentifier").text(newIdent);
															$j("#matchedName").text(createdPatient.givenName + ' ' + createdPatient.familyName);
															$j("#matchedGender").text(createdPatient.gender);
															$j("#matchedAge").text(createdPatient.age);
															$j("#matchedDistrict").text(createdPatient.countyDistrict);
															$j("#matchedSector").text(createdPatient.cityVillage);
															$j("#matchedCell").text(createdPatient.neighborhoodCell);
															$j("#matchedAddress1").text(createdPatient.address1);
													   		$j("#matchedPatientSection").show();
													   		$j(".createdPatientMatch").show();
													   		showNewOrder();
														},
														errorHandler:function(errorString, exception) {
															alert(errorString);
														}
												   	}
			);
		}
	
		function createOrder() {
			var orderLoc = $j(".orderDetailSection select[name='location']").val();
			var orderConcept = $j(".orderDetailSection select[name='concept']").val();
			var orderDate = $j(".orderDetailSection input[name='startDate']").val();
			var accessionNum = $j(".orderDetailSection input[name='accessionNumber']").val();
			DWRSimpleLabEntryService.createLabOrder(_selectedPatientId, orderConcept, orderLoc, orderDate, accessionNum, 
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

		$j("#CreateOrderFromNameButton").click( function() {
			createOrder();
		});
		$j("#CreatePatientButton").click( function() {
			createPatient();
		});
		$j("#AddIdentifierButton").click( function() {
			var ident = $j("#otherIdentifier").text();
			var identType = '${patientIdType}';
			var identLoc = '${model.orderLocation}';
			DWRSimpleLabEntryService.addPatientIdentifier(_selectedPatientId, ident, identType, identLoc, 
					{ 	callback:function(revisedPatient) {
							loadPatient(revisedPatient);
							showNewOrder();
						},
						errorHandler:function(errorString, exception) {
							alert(errorString);
						}
					}
			);
		});
		$j("#NoIdentifierYesOrderButton").click( function() {
			showNewOrder();
		});
		$j("#NoIdentifierCancelButton").click( function() {
			clearSearchFields();
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
<div style="align:left;" class="box" >

	Enter IMB ID (Long ID): 
	<input type="text" id="patientIdentifier" class="orderField" name="patientIdentifier" />
	<input type="button" value="Search" id="SearchByIdButton" />
	<input type="button" value="Clear" onclick="clearFormFields();" />
	<br/><br/>

	<div id="matchedPatientSection" class="searchSection" style="display:none;">
		<span id="confirmPatientSection" style="color:blue;">
			<span style="display:none;" class="idMatch">The following patient matches this ID.</span> 
			<span style="display:none;" class="nameMatch">You have selected the following patient.</span> 
			<span style="display:none;" class="createdPatientMatch">The following patient has been created.</span> 
		</span>
		<table id="matchedPatientTable">
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
				<td id="matchedIdentifier"></td>
				<td id="matchedName"></td>
				<td id="matchedGender"></td>
				<td id="matchedAge"></td>
				<td id="matchedDistrict"></td>
				<td id="matchedSector"></td>
				<td id="matchedCell"></td>
				<td id="matchedAddress1"></td>
			</tr>
		</table>
		<b class="nameMatch" id="newIdentifierAddSection">
			<br/>
			Do you wish to associate identifier <span style="color:blue;" id="otherIdentifier"></span> with this patient?<br/><br/>
			<input type="button" id="AddIdentifierButton" value="Yes, add identifier and continue to Order" />
			<input type="button" id="NoIdentifierYesOrderButton" value="No, but proceed to Order" />
			<input type="button" id="NoIdentifierCancelButton" value="No, Cancel" />
			<br/>
		</b>
		<br/>
		<div id="newOrderSection"></div>
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
					<input type="button" value="Cancel" onclick="clearFormFields();">
				</td>
			</tr>
		</table>
	</div>
</div>

<div class="orderDetailTemplate" style="display:none;">
	<b>Order Details</b>
	<form action="">
		<input type="hidden" name="patientId" value="" />
		<input type="hidden" name="orderId" value="" />
		<table>
			<tr>
				<th>Short ID:</th>
				<td><input type="text" class="accessionNumber" name="accessionNumber" /></td>
				<th><spring:message code="simplelabentry.orderLocation" />:</td>
				<td><openmrs_tag:locationField formFieldName="location" /></td>
				<th><spring:message code="simplelabentry.orderType" />:</td>
				<td>
					<select name="concept">
						<option value=""></option>
						<c:forEach items="${model.labSets}" var="labSet" varStatus="labSetStatus">
							<option value="${labSet.conceptId}">${empty labSet.name.shortName ? labSet.name.name : labSet.name.shortName}</option>
						</c:forEach>
					</select>
				</td>
				<th><spring:message code="simplelabentry.orderDate" />: </td>
				<td><input type="text" name="startDate" size="10" onFocus="showCalendar(this)" /></td>
			</tr>
		</table>	
		<br/>
		<div class="orderResultsSection" style="display:none;">
			<b>Results</b>
			<c:forEach items="${model.labSets}" var="labSet" varStatus="labSetStatus">
				<div id="labResultSection${labSet.conceptId}" style="display:none;">
					<table>
						<tr>
							<openmrs:forEachRecord name="conceptSet" conceptSet="${labSet.conceptId}">
								<th>${empty record.name.shortName ? record.name.name : record.name.shortName}</th>
							</openmrs:forEachRecord>
						</tr>
						<tr>
							<openmrs:forEachRecord name="conceptSet" conceptSet="${labSet.conceptId}">
								<td><openmrs_tag:obsValueField conceptId="${record.conceptId}" formFieldName="test" size="5" />
							</openmrs:forEachRecord>
						</tr>
					</table>
				</div>
			</c:forEach>
		</div>
		<br/>
		<input type="button" name="CreateOrderButton" value="Create Order" />
		<input type="button" value="Cancel, Do not Create" onclick="clearFormFields();" />
	</form>
</div>