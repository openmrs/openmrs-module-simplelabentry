<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ include file="localHeader.jsp"%>
<openmrs:require privilege="View Orders" otherwise="/login.htm" redirect="/module/simplelabentry/simpleLabEntry.form" />

<br/>
<div style="text-align:center;">
	<h3>Manage Existing Orders</h3><br/>
	<form action="existingOrders.htm" method="get">
		Choose From Existing Orders by Category: <simplelabentry:groupedOrderTag name="groupKey" defaultValue="${param.groupKey}" javascript="" />
		<span> OR </span>
		Patient ID: <input type="text" name="patientId" value="${param.patientId}" size="10" />
		<input type="submit" value="Submit" />
	</form>
	<br/><hr/><br/>
	<openmrs:portlet url="orderEntry" id="orderEntrySectionId" moduleId="simplelabentry" parameters="patientId=${param.patientId}|groupKey=${param.groupKey}" />
</div>

<%@ include file="/WEB-INF/template/footer.jsp"%>
