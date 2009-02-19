<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="localHeader.jsp"%>
<openmrs:require privilege="View Orders" otherwise="/login.htm" redirect="/module/simplelabentry/resultEntry.htm" />

<br/>

<b class="boxHeader">Step 1. Choose which results you want to enter:</b>
<div class="box">
	<form action="resultEntry.htm" method="get">
		<simplelabentry:groupedOrderTag name="groupKey" limit="open" defaultValue="${param.groupKey}" javascript="onchange='this.form.submit();'" />
	</form>

</div>
<br/>

<c:if test="${!empty param.groupKey}">
	<openmrs:portlet 
		url="orderEntry" 
		id="orderEntrySectionId" 
		moduleId="simplelabentry" 
		parameters="limit=open|allowCategoryEdit=false|groupKey=${param.groupKey}" />
</c:if>




<%@ include file="/WEB-INF/template/footer.jsp"%>
