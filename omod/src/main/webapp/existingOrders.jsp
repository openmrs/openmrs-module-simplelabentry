<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="localHeader.jsp"%>
<openmrs:require privilege="View Orders" otherwise="/login.htm" redirect="/module/simplelabentry/existingOrders.htm" />

<br/>
<b class="boxHeader">Step 1. Choose From Existing Orders by Category or Patient </b>
<div class="box" >
	<form action="existingOrders.htm" method="get">
		<b>Category: </b>	
		<simplelabentry:groupedOrderTag name="groupKey" defaultValue="${param.groupKey}" javascript="" />
		<i> OR </i> <br>
		<b>Patient Identifier: </b>
		<input type="text" name="identifier" value="${param.identifier}" size="10" />
		<input type="submit" value="Submit" />
	</form>
</div>
<br/>

<c:if test="${!empty param.groupKey || !empty param.identifier }">
	<openmrs:portlet url="orderEntry" 
			id="orderEntrySectionId" 
			moduleId="simplelabentry" 
			parameters="identifier=${param.identifier}|groupKey=${param.groupKey}" />
</c:if>


<%@ include file="/WEB-INF/template/footer.jsp"%>
