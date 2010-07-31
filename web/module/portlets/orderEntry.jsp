<%@ include file="/WEB-INF/template/include.jsp" %>
<%@ taglib prefix="simplelabentry" uri="/WEB-INF/view/module/simplelabentry/resources/simplelabentry.tld" %>

<openmrs:htmlInclude file="/scripts/jquery/jquery-1.3.2.min.js" />
<script type="text/javascript">
	var $j = jQuery.noConflict();
</script>
<openmrs:htmlInclude file="/dwr/interface/LabPatientListItem.js" />
<openmrs:htmlInclude file="/dwr/interface/LabResultListItem.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRPatientService.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRSimpleLabEntryService.js" />
<openmrs:htmlInclude file="/dwr/util.js" />

<openmrs:htmlInclude file="/scripts/dojoConfig.js" />
<openmrs:htmlInclude file="/scripts/dojo/dojo.js" />
<openmrs:htmlInclude file="/scripts/easyAjax.js" />
<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />

<openmrs:globalProperty key="simplelabentry.patientIdentifierType" var="patientIdType" />
<openmrs:globalProperty key="simplelabentry.programToDisplay" var="programToDisplay" />
<openmrs:globalProperty key="simplelabentry.workflowToDisplay" var="workflowToDisplay" />

<script type="text/javascript">

	<c:if test="${model.allowAdd == 'true'}">
		dojo.require("dojo.widget.openmrs.PatientSearch");
	
		_selectedPatientId = null;
		_selectedOrderId = null;
		
		dojo.addOnLoad( function() {
			searchWidget = dojo.widget.manager.getWidgetById("pSearch");
			
			dojo.event.topic.subscribe("pSearch/select", 
				function(msg) {
					if (msg.objs[0].patientId) {
						var patient = msg.objs[0];
						DWRSimpleLabEntryService.getPatient(patient.patientId, function(labPatient) { loadPatient(labPatient) });
						clearPatientAndSearchFields(false);
						_selectedPatientId = patient.patientId;
						$j("#otherIdentifier").text($j("#patientIdentifier").val());
						showMatchedPatientSection();
						
					} else if (msg.objs[0].href)
						document.location = msg.objs[0].href;
				}
			);

			searchWidget.postCreate = function() {
				if (searchWidget.patientId != "") {
					searchWidget.selectPatient(searchWidget.patientId);
				}
				else if (searchWidget.searchPhrase) {
					DWRSimpleLabEntryService.findPatients(searchWidget.searchPhrase, searchWidget.simpleClosure(searchWidget, "doObjectsFound"));
				}
			};

			searchWidget.selectPatient = function(patientId) {
				DWRSimpleLabEntryService.getPatient(patientId, searchWidget.simpleClosure(searchWidget, "select"));
			};
			
			searchWidget.doFindObjects = function(text) {
				DWRSimpleLabEntryService.findPatients(text, searchWidget.simpleClosure(searchWidget, "doObjectsFound"));
				return false;
			};

			searchWidget.getCountyDistrict = function(p) { return p.countyDistrict == null ? searchWidget.noCell() : p.countyDistrict; };
			searchWidget.getCityVillage = function(p) { return p.cityVillage == null ? searchWidget.noCell() : p.cityVillage; };
			searchWidget.getNeighborhoodCell = function(p) { return p.neighborhoodCell == null ? searchWidget.noCell() : p.neighborhoodCell; };
			searchWidget.getProgramState = function(p) { return p.programState == null ? searchWidget.noCell() : p.programState; };
			searchWidget.getLastObs = function(p) { return p.lastObs == null ? searchWidget.noCell() : p.lastObs; };
			
			searchWidget.getAddress = function(p) {
				str = (p.countyDistrict == null ? "" : p.countyDistrict);
				str += (p.cityVillage == null ? "" : ((str == "" ? "" : ", ") + p.cityVillage));
				str += (p.neighborhoodCell == null ? "" : ((str == "" ? "" : ", ") + p.neighborhoodCell));
				str += (p.address1 == null ? "" : ((str == "" ? "" : ", ") + p.address1));
				return str == "" ? searchWidget.noCell() : str;
			};

			searchWidget.displayHeaderRow = function() {
				this.setHeaderCellContent(this.getHeaderCellContent());
				this.headerRow.style.display="";
			};

			searchWidget.getHeaderCellContent = function() {
				var arr = new Array();
				arr.push('');
				arr.push('<spring:message code="Patient.identifier" javaScriptEscape="true"/>');
				arr.push('<spring:message code="PersonName.givenName" javaScriptEscape="true"/>');
				arr.push('<spring:message code="PersonName.middleName" javaScriptEscape="true"/>');
				arr.push('<spring:message code="PersonName.familyName" javaScriptEscape="true"/>');
				arr.push('<spring:message code="Person.age" javaScriptEscape="true"/>');
				arr.push('<spring:message code="Person.gender" javaScriptEscape="true"/>');
				arr.push('Group');
				arr.push('Last CD4');
				arr.push('Address');
				<openmrs:forEachDisplayAttributeType personType="patient" displayType="listing" var="attrType">
					arr.push('<spring:message code="PersonAttributeType.${fn:replace(attrType.name, ' ', '')}" javaScriptEscape="true" text="${attrType.name}"/>');
				</openmrs:forEachDisplayAttributeType>
				return arr;
			};

			searchWidget.getCellFunctions = function() {
				var arr = new Array();
				arr.push(searchWidget.simpleClosure(searchWidget, "getNumber"));
				arr.push(searchWidget.simpleClosure(searchWidget, "getId"));
				arr.push(searchWidget.simpleClosure(searchWidget, "getGiven"));
				arr.push(searchWidget.simpleClosure(searchWidget, "getMiddle"));
				arr.push(searchWidget.simpleClosure(searchWidget, "getFamily"));
				arr.push(searchWidget.simpleClosure(searchWidget, "getAge"));
				arr.push(searchWidget.simpleClosure(searchWidget, "getGender"));
				arr.push(searchWidget.simpleClosure(searchWidget, "getProgramState"));
				arr.push(searchWidget.simpleClosure(searchWidget, "getLastObs"));
				arr.push(searchWidget.simpleClosure(searchWidget, "getAddress"));
				<openmrs:forEachDisplayAttributeType personType="patient" displayType="listing" var="attrType">
					arr.push(searchWidget.simpleClosure(searchWidget, "getAttribute", "${attrType.name}"));
				</openmrs:forEachDisplayAttributeType>
				return arr;
			};
			
			searchWidget.addPatientLink = '<a href="javascript:showCreatePatient();">Create New Patient</a>';
			searchWidget.inputNode.select();
			changeClassProperty("description", "display", "none");
		});
	</c:if>

	function showMatchedPatientSection() {
		$j("#matchedPatientSection").show();
		$j(".nameMatch").show();
	}

	function loadPatient(labPatient) {
		$('matchedIdentifier').innerHTML = labPatient.identifier + (labPatient.otherIdentifiers == '' ? '' : '<br/><small>(' + labPatient.otherIdentifiers + ')</small>');
		$('matchedName').innerHTML = labPatient.givenName + ' ' + labPatient.familyName;
		$('matchedGroup').innerHTML = labPatient.programState;
		$('matchedGender').innerHTML = labPatient.gender;
		$('matchedAge').innerHTML = labPatient.ageStr;
		$('matchedDistrict').innerHTML = labPatient.countyDistrict;
		$('matchedSector').innerHTML = labPatient.cityVillage;
		$('matchedCell').innerHTML = labPatient.neighborhoodCell;
		$('matchedAddress1').innerHTML = labPatient.address1;
	}

	function clearPatientAndSearchFields(includeNameSearch) {
		_selectedPatientId = null;
		clearSearchFields(includeNameSearch);
	}

	function clearSearchFields(includeNameSearch) {
		$j("#otherIdentifier").text('');
		$j("#nameMatchSection").hide();
		$j("#matchedPatientSection").hide();
		$j(".idMatch").hide();
		$j(".nameMatch").hide();
		$j(".createdPatientMatch").hide();
		$j("#createPatientSection").hide();
		$j(".orderDetailSection").remove().removeClass("orderDetailSection");
		$j(".labResultSection").hide();
		$j(".existingOrderRow").show();
		_selectedOrderId = null;
		if (includeNameSearch) {
			<c:if test="${model.allowAdd == 'true'}">
				dojo.widget.manager.getWidgetById("pSearch").clearSearch();
			</c:if>
		}
	}

	function returnToSearch() {
		clearPatientAndSearchFields(false);
		$j("#nameMatchSection").show();
	}

	function clearFormFields() {
		$j(".orderField").val('');
		$j(".existingOrderRow").css("background-color","white");
		$j(".editOrderRow").hide();
 		clearPatientAndSearchFields(true);
	}

	function showCreatePatient() {
		clearSearchFields(true);
		$j("#createPatientSection").show();
	}

	function findNewPatient() {
		clearPatientAndSearchFields(true);
		dojo.widget.manager.getWidgetById("pSearch").inputNode.select();
		dojo.widget.manager.getWidgetById("pSearch").inputNode.focus();
	}
	
	function enableDisableOrderFields() {
		// Start date and location are never editable
		$j(".orderDetailSection input[name='startDate']").attr("disabled","true").css("color","blue");
		$j(".orderDetailSection select[name='location']").attr("disabled","true").css("color","blue");
		
//		<c:choose>
//			<c:when test="${model.allowCategoryEdit == 'false'}">
//				$j(".orderDetailSection input[name='startDate']").attr("disabled","true").css("color","blue");
//				$j(".orderDetailSection select[name='location']").attr("disabled","true").css("color","blue");
//				$j(".orderDetailSection select[name='concept']").attr("disabled","true").css("color","blue");
//			</c:when>
//			<c:otherwise>
//				$j(".orderDetailSection input[name='startDate']").removeAttr("disabled").css("color","black");
//				$j(".orderDetailSection select[name='location']").removeAttr("disabled").css("color","black");
//				$j(".orderDetailSection select[name='concept']").removeAttr("disabled").css("color","black");
//			</c:otherwise>
//		</c:choose>
	}

	function showNewOrder() {
		$j("#newIdentifierAddSection").hide();
		$j(".orderDetailTemplate").clone().removeClass("orderDetailTemplate").appendTo($j("#newOrderSection")).addClass("orderDetailSection").show();
		
		$j(".orderDetailSection input[name='startDate']").val('${model.orderDate}');
		$j(".orderDetailSection select[name='location']").val('${model.orderLocation}');
		$j(".orderDetailSection select[name='concept']").val('${model.orderConcept}');
		enableDisableOrderFields();
		$j(".orderDetailSection :button[name='CreateOrderButton']").click( function() { createOrder(); } );
	}

	function editOrder(orderId) {
		clearFormFields();
		$j("#viewOrderRow"+orderId).css("background-color","yellow");
		$j("#editOrderRow"+orderId).show();
		$j(".orderDetailTemplate").clone().removeClass("orderDetailTemplate").appendTo($j("#editOrderRow"+orderId)).addClass("orderDetailSection").show();

		$j(".orderDetailSection .labResultTemplateCell").removeClass("labResultTemplateCell").addClass("labResultCell");
		$j(".orderDetailSection .labResultTemplateConcept").removeClass("labResultTemplateConcept").addClass("labResultConcept");
		$j(".orderDetailSection .labResultDetailTemplate").removeClass("labResultDetailTemplate").addClass("labResultDetail");
		$j(".labResultSection").show();
		
		DWRSimpleLabEntryService.getOrder(orderId, function(order) {
			_selectedPatientId = order.patientId;
			_selectedOrderId = orderId;
			$j(".orderDetailSection input[name='startDate']").val(order.startDateString);
			$j(".orderDetailSection select[name='location']").val(order.locationId);
			$j(".orderDetailSection select[name='concept']").val(order.conceptId);
			enableDisableOrderFields();
			$j(".orderDetailSection input[name='accessionNumber']").val(order.accessionNumber);
			$j(".labResultDetail input[name='discontinuedDate']").val(order.discontinuedDateString);
			for (i=0; i<order.labResults.length; i++) {
				$j("[name='resultValue."+order.conceptId+"."+order.labResults[i].conceptId+"']").val(order.labResults[i].result);
				$j("[name='didTestFail_"+order.conceptId+"."+order.labResults[i].conceptId+"']").val(order.labResults[i].testFailureCode);
			}
			$j(".labResultSection"+order.conceptId).show();
		});
		$j(".orderDetailSection :button[name='CreateOrderButton']").click( function() { createOrder(); } );
	}

	function matchPatientById(patIdType, patId) {
		clearPatientAndSearchFields(false);
		DWRSimpleLabEntryService.getPatientByIdentifier(patIdType, patId, function(patient) {
			if (patient.patientId == null) {
				DWRSimpleLabEntryService.checkPatientIdentifier(patIdType, patId, { 
					callback:function(createdOrder) {
						$j("#nameMatchSection").show();
						$('newPatientIdentifier').innerHTML = patId;
					},
					errorHandler:function(errorString, exception) {
						alert(errorString);
					}
				});
			}
			else {
				_selectedPatientId = patient.patientId;
				loadPatient(patient);
				$j(".idMatch").show();
				$j("#matchedPatientSection").show();
				$j("#newOrderSection").show();
				showNewOrder();
				$('newPatientIdentifier').innerHTML = patId;
			}	
		});
	}

	function createPatient() {
		var newIdent = $j('#newPatientIdentifier').text();
		var newIdentType = '${patientIdType}';
		var selectedLocation = '${param.orderLocation}';
		var newFirstName = $('newFirstName').value;
		var newLastName = $('newLastName').value;
		var newGender = $j("input[name='newGender']:checked").val();
		var newAgeY = $('newAgeY').value;
		var newAgeM = $('newAgeM').value;
		var newProvince = $('newProvince').value;
		var newCountyDistrict = $('newCountyDistrict').value;
		var newCityVillage = $('newCityVillage').value;
		var newNeighborhoodCell = $('newNeighborhoodCell').value;
		var newAddress1 = $('newAddress1').value;
		DWRSimpleLabEntryService.createPatient(	newFirstName, newLastName, newGender, newAgeY, newAgeM, newIdent, newIdentType, selectedLocation, 
											   	newProvince, newCountyDistrict, newCityVillage, newNeighborhoodCell, newAddress1, 
											   	{ 	callback:function(createdPatient) {
														clearPatientAndSearchFields(true);
												   		_selectedPatientId = createdPatient.patientId;
														$j("#matchedIdentifier").text(newIdent);
														$j("#matchedName").text(createdPatient.givenName + ' ' + createdPatient.familyName);
														$j("#matchedGroup").text(createdPatient.programState);
														$j("#matchedGender").text(createdPatient.gender);
														$j("#matchedAge").text(createdPatient.ageStr);
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
		saveOrder(null);
	}

	function saveOrder(orderId) {

		var orderLoc = $j(".orderDetailSection select[name='location']").val();
		var orderDate = $j(".orderDetailSection input[name='startDate']").val();
		var accessionNum = $j(".orderDetailSection input[name='accessionNumber']").val();
		var discontinuedDate = $j(".labResultDetail input[name='discontinuedDate']").val();
		var orderConceptIds = [];

		var index = 0;
		<c:forEach items="${model.labTestConcepts}" var="labConcept" varStatus="labConceptStatus">
			var orderConcept = $j(".orderDetailSection input[name='${empty labConcept.name.shortName ? labConcept.name.name : labConcept.name.shortName}']:checked").val();
			if(orderConcept != null && orderConcept != '') {
				orderConceptIds[index++] = orderConcept;
			}
		</c:forEach>

		if(index == 0) {
			alert('Please select a type of exam.');
			return;
		}
		
		var labResultMap = {};
		$j(".labResultConcept").each( function(i) {
			var cIdsToSplit = $j(this).text();
			var cId = cIdsToSplit.split(".",2)[1];
			var resultStr = $j("[name='resultValue."+cIdsToSplit + "']").val();
			if (resultStr != null && resultStr != '') {
				var r = new Object();
				r.conceptId = cId;
				r.result = resultStr;
				labResultMap[cId] = r;
			}
		});
		var resultFailureMap = {};
		$j(".labResultConcept").each( function(i) {
			var cIdsToSplit = $j(this).text();
			var cId = cIdsToSplit.split(".",2)[1];
			var resultStr = $j("[name='didTestFail_" + cIdsToSplit + "']").val();
			if (resultStr != null && resultStr != '') {
				var r = new Object();
				r.conceptId = cId;
				r.result = resultStr;
				resultFailureMap[cId] = r;
			}
		});
		DWRSimpleLabEntryService.saveLabOrders(_selectedOrderId, _selectedPatientId, orderConceptIds, orderLoc, orderDate, accessionNum, discontinuedDate, labResultMap, resultFailureMap,
				{ 	callback:function(createdOrder) {
						clearFormFields();
						location.reload();
					},
					errorHandler:function(errorString, exception) {
						alert(errorString);
					}
				}
		);
	}

	function deleteOrder(orderId, reason) {
		if (confirm("Are you sure you want to delete this order?")) {
			DWRSimpleLabEntryService.deleteLabOrderAndEncounter(orderId, reason, { 
				callback:function() {location.reload();},
				errorHandler:function(errorString, exception) { alert(errorString); location.reload(); }
	   		});
		}
	}

	$j(document).ready(function(){
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
	});

</script>

<style>
	th,td {text-align:left; padding-left:10px; padding-right:10px;}
	.searchSection {padding:5px; border: 1px solid grey; background-color: whitesmoke;}
	.labResultCell {white-space:nowrap;}
</style>

<b class="boxHeader">Step 2.  Manage orders / results</b>
<div style="align:left;" class="box" >	

<c:if test="${model.allowAdd == 'true'}">
		Enter ${model.patientIdentifierType}: 
		<input type="text" id="patientIdentifier" class="orderField" name="patientIdentifier" />
		<input type="button" value="Search" id="SearchByIdButton" onclick="matchPatientById('${patientIdType}',$('patientIdentifier').value);" />
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
					<th>Patient ID</th>
					<th>Given Name / Family Name</th>
					<th>Group</th>
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
					<td id="matchedGroup"></td>
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
				Are you certain that this is the same person who had the lab test ordered?<br/>
				Adding ID '<span style="color:blue;" id="otherIdentifier"></span>' to the wrong patient's file will cause serious problems.
				<br/><br/>
				<input type="button" id="AddIdentifierButton" value="Yes, this is the same person - add ID and continue order" />
				<input type="button" id="NoIdentifierCancelButton" value="No, return to search" onclick="returnToSearch();" />
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
					<th>IMB ID</th>
					<th>Given Name</th>
					<th>Family Name</th>
					<th>Sex</th>
					<th>Age</th>
					<th>Province</th>
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
					<td>
						<input type="text" class="orderField" id="newAgeY" name="newAgeY" size="3" />y
						<input type="text" class="orderField" id="newAgeM" name="newAgeM" size="3" />m
					</td>
					<td><input type="text" class="orderField" id="newProvince" name="newProvince" size="10" /></td>
					<td><input type="text" class="orderField" id="newCountyDistrict" name="newCountyDistrict" size="10" /></td>
					<td><input type="text" class="orderField" id="newCityVillage" name="newCityVillage" size="10" /></td>
					<td><input type="text" class="orderField" id="newNeighborhoodCell" name="newNeighborhoodCell" size="10" /></td>
					<td><input type="text" class="orderField" id="newAddress1" name="newAddress1" size="10" /></td>
					<td>
						<input type="button" value="Create Patient" id="CreatePatientButton" onclick="createPatient();" />
						<input type="button" value="Cancel" onclick="clearFormFields();">
					</td>
				</tr>
			</table>
		</div>		
	</c:if>
	
	<div>
		<b>
			<c:choose>
				<c:when test="${model.limit=='open'}">Open Orders</c:when>
				<c:when test="${model.limit=='closed'}">Closed Orders</c:when>
				<c:otherwise>All Orders</c:otherwise>
			</c:choose>
		</b> 
		<table style="width:100%;"> 
			<tr style="background-color:#CCCCCC;">
				<th></th>
				<th>Date</th>
				<th>Lab ID</th>
				<th>
					Patient ID
				</th>
				<th>Given Name / Family Name</th>
				<th>Sex</th>
				<th>Age</th>
				<th>Group</th>
				<th>District</th>
				<th>Sector</th>
				<th>Cellule</th>
				<th>Umudugudu</th>
				<th></th>
			</tr>
			<c:if test="${fn:length(model.labOrders) == 0}"><tr><td>No Orders</td></tr></c:if>
			<c:forEach items="${model.labOrders}" var="order" varStatus="orderStatus">
				<c:if test="${!empty order.orderId}">
					<tr id="viewOrderRow${order.orderId}" class="existingOrderRow">
						<td>
							<c:choose>
								<c:when test="${!empty param.identifier || empty param.groupKey}"><small>${empty order.concept.name.shortName ? order.concept.name.name : order.concept.name.shortName}</small></c:when>
								<c:otherwise><a href="javascript:editOrder('${order.orderId}');"><small>Enter Results</small></a></c:otherwise>
							</c:choose>
						</td>
						<td><openmrs:formatDate date="${order.encounter.encounterDatetime}" /></td>
						<td>${order.accessionNumber}</td>
						<td>
							<c:set var="idFound" value="0" />
							<c:forEach items="${order.patient.identifiers}" var="id" varStatus="varStatus">
								<c:if test="${id.identifierType.patientIdentifierTypeId == patientIdType}">
									<c:set var="idFound" value="1" />
									${id.identifier}
								</c:if>
							</c:forEach>
							<c:if test="${idFound == 0}">
								${order.patient.patientIdentifier}
							</c:if>
							
						</td>
						<td>
							<a href="${pageContext.request.contextPath}/admin/patients/patient.form?patientId=${order.patient.patientId}" target="_blank">
								${order.patient.personName.givenName} ${order.patient.personName.familyName}
							</a>
						</td>
						<td>${order.patient.gender}</td>
						<td>${order.patient.age}</td>
						<td>
							<simplelabentry:patientProgram programInput="${programToDisplay}" workflowInput="${workflowToDisplay}" patientId="${order.patient.patientId}" programVar="p" workflowVar="w" patientProgramVar="pp" currentStateVar="currentState">
								${currentState == null ? "" : currentState.state.concept.name.name}
							</simplelabentry:patientProgram>
						</td>
						<c:choose>
							<c:when test="${!empty order.patient.personAddress}">
								<td>${order.patient.personAddress.countyDistrict}</td>
								<td>${order.patient.personAddress.cityVillage}</td>
								<td>${order.patient.personAddress.neighborhoodCell}</td>
								<td>${order.patient.personAddress.address1}</td>
							</c:when>
							<c:otherwise><td colspan="4">&nbsp;</td></c:otherwise>
						</c:choose>
						<td align="right">
							<c:choose>
								<c:when test="${model.allowDelete == 'false'}">&nbsp;</c:when>
								<c:when test="${model.allowDelete == 'nonResults' && !empty order.encounter.obs}">&nbsp;</c:when>
								<c:otherwise><a href="javascript:deleteOrder('${order.orderId}', 'SimpleLabEntry: delete clicked');"><small>Delete</small></a></c:otherwise>
							</c:choose>
						</td>
					</tr>
					<tr><td colspan="12" class="editOrderRow" style="display:none; background-color:#CCCCCC; border:2px solid blue;" id="editOrderRow${order.orderId}"></td></tr>
				</c:if>
			</c:forEach>
		</table>
	</div>
	
	<div class="orderDetailTemplate" style="display:none;">
		<b>Order Details</b>
		<input type="hidden" name="orderId" value="" />
		<table>
			<tr>
				<th>Lab ID:</th>
				<td><input type="text" class="accessionNumber" name="accessionNumber" /></td>
				<th><spring:message code="simplelabentry.orderLocation" />:</th>
				<td><openmrs_tag:locationField formFieldName="location" /></td>
				<th><spring:message code="simplelabentry.orderDate" />: </th>
				<td><input type="text" name="startDate" size="10" readonly="readonly"/></td> <!-- onFocus="showCalendar(this)"  --> 
			</tr>
			<tr>
				<th><spring:message code="simplelabentry.orderType" />:</th>
				<td colspan="5">
					<c:forEach items="${model.labTestConcepts}" var="labConcept" varStatus="labConceptStatus">
						<input type="checkbox" <c:if test="${model.groupConceptId != null && model.groupConceptId == labConcept.conceptId}">checked="checked"</c:if> <c:if test="${model.groupConceptId != null}">disabled="disabled"</c:if> value="${labConcept.conceptId}" name="${empty labConcept.name.shortName ? labConcept.name.name : labConcept.name.shortName}" id="${empty labConcept.name.shortName ? labConcept.name.name : labConcept.name.shortName}">
							${empty labConcept.name.shortName ? labConcept.name.name : labConcept.name.shortName}
						</input>
					</c:forEach>
				</td>
			</tr>
		</table>	
		<br/>
		<div class="labResultSection" style="display:none;">
			<b style="padding-bottom:10px;">Results</b>
	
			<c:forEach items="${model.labTestConcepts}" var="labConcept" varStatus="labConceptStatus">
				<div class="labResultSection${labConcept.conceptId}" style="display:none;">
					<table>
						<tr>
							<c:choose>
								<c:when test="${labConcept.set}">
									<openmrs:forEachRecord name="conceptSet" conceptSet="${labConcept.conceptId}">
										<th>${empty record.name.shortName ? record.name.name : record.name.shortName}</th>
									</openmrs:forEachRecord>
								</c:when>
								<c:otherwise>
									${empty labConcept.name.shortName ? labConcept.name.name : labConcept.name.shortName}
								</c:otherwise>
							</c:choose>
						</tr>
						<tr>
							<c:choose>
								<c:when test="${labConcept.set}">
									<openmrs:forEachRecord name="conceptSet" conceptSet="${labConcept.conceptId}">
										<td class="labResultTemplateCell">
											<span class="labResultTemplateConcept" style="display:none;">${labConcept.conceptId}.${record.conceptId}</span>
											<openmrs_tag:obsValueField conceptId="${record.conceptId}" formFieldName="resultValue.${labConcept.conceptId}.${record.conceptId}" size="5" />
											&nbsp;&nbsp;&nbsp;If the test failed: 
										<select name="didTestFail_${labConcept.conceptId}.${labConcept.conceptId}">
											<option value="0"></option>
											<option value="1">clinician needs to reorder the test</option>
											<!--<option value="2">test failed, but do not re-order</option>-->
											<option value="3">test re-ordered, close this order</option>
										</select>
										</td>
									</openmrs:forEachRecord>
								</c:when>
								<c:otherwise>
									<td class="labResultTemplateCell">
										<span class="labResultTemplateConcept" style="display:none;">${labConcept.conceptId}.${labConcept.conceptId}</span>
										<openmrs_tag:obsValueField conceptId="${labConcept.conceptId}" formFieldName="resultValue.${labConcept.conceptId}.${labConcept.conceptId}" size="5" />
										&nbsp;&nbsp;&nbsp;If the test failed: 
										<select name="didTestFail_${labConcept.conceptId}.${labConcept.conceptId}">
											<option value="0"></option>
											<option value="1">clinician needs to reorder the test</option>
											<option value="2">test failed, but do not re-order</option>
											<option value="3">test re-ordered, close this order</option>
										</select>	
									</td>
								</c:otherwise>
							</c:choose>
						</tr>
					</table>
				</div>
			</c:forEach>
	 		<div class="labResultDetailTemplate"> 
				<b style="padding-left:10px;">Date of Result or Test Failure:</b> <input type="text" name="discontinuedDate" size="10" onFocus="showCalendar(this);" />
			</div>
		</div>
		<br/>
		<div align="center">
			<input type="button" name="SaveOrderButton" value="Save" onclick="saveOrder();" />
			<input type="button" value="Cancel" onclick="clearFormFields();" />
		</div>
		<br/>
	</div>
</div>

