<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ include file="localHeader.jsp"%>
<openmrs:require privilege="View Orders" otherwise="/login.htm" redirect="/module/simplelabentry/simpleLabEntry.form" />

<br/>
<div>
	<form action="existingOrders.htm" method="get">
		<b>Choose From Existing Orders by Category: </b><simplelabentry:groupedOrderTag name="groupKey" defaultValue="${param.groupKey}" javascript="" />
		<b> OR Patient ID: </b><input type="text" name="patientId" value="${param.patientId}" size="10" />
		<input type="submit" value="Submit" />
	</form>
	<br/><hr/><br/>
	<c:if test="${!empty param.groupKey || !empty param.patientId }">
		<openmrs:portlet url="orderEntry" id="orderEntrySectionId" moduleId="simplelabentry" parameters="patientId=${param.patientId}|groupKey=${param.groupKey}" />
	</c:if>
</div>

<%@ include file="/WEB-INF/template/footer.jsp"%>
