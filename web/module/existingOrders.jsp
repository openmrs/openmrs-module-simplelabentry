<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="localHeader.jsp"%>
<openmrs:require privilege="View Orders" otherwise="/login.htm" redirect="/module/simplelabentry/existingOrders.htm" />

<br/>
<div>
	<form action="existingOrders.htm" method="get">
		<b>Choose From Existing Orders by Category: </b><simplelabentry:groupedOrderTag name="groupKey" defaultValue="${param.groupKey}" javascript="" />
		<b> OR Patient Identifier: </b><input type="text" name="identifier" value="${param.identifier}" size="10" />
		<input type="submit" value="Submit" />
	</form>
	<br/><hr/><br/>
	<c:if test="${!empty param.groupKey || !empty param.identifier }">
		<openmrs:portlet url="orderEntry" id="orderEntrySectionId" moduleId="simplelabentry" parameters="identifier=${param.identifier}|groupKey=${param.groupKey}" />
	</c:if>
</div>

<%@ include file="/WEB-INF/template/footer.jsp"%>
