<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:htmlInclude file="/dwr/interface/DWRSimpleLabEntryService.js" />
<openmrs:htmlInclude file="/moduleResources/simplelabentry/jquery-1.2.6.min.js" />
<openmrs:htmlInclude file="/dwr/util.js" />
<openmrs:htmlInclude file="/scripts/easyAjax.js" />
<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />

<script type="text/javascript">

	var $j = jQuery.noConflict();

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
	
	});
</script>

<style>
	th,td {text-align:left; padding-left:10px; padding-right:10px;}
</style>

<div class="box">
	<table style="width:100%;">
		<tr style="background-color:#CCCCCC;">
			<th></th>
			<th>Date</th>
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
					<td><openmrs:formatDate date="${order.encounter.encounterDatetime}" /></td>
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