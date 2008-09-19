<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ include file="localHeader.jsp"%>
<openmrs:require privilege="View Orders" otherwise="/login.htm" redirect="/module/simplelabentry/simpleLabEntry.form" />

<br/>
<div>
	<form action="resultEntry.htm" method="get">
		<b>Choose which results you want to enter:</b>
		<simplelabentry:groupedOrderTag name="groupKey" limit="open" defaultValue="${param.groupKey}" javascript="onchange='this.form.submit();'" />
	</form>
	<br/><hr/><br/>
	<c:if test="${!empty param.groupKey}">
		<openmrs:portlet url="orderEntry" id="orderEntrySectionId" moduleId="simplelabentry" parameters="limit=open|allowCategoryEdit=false|groupKey=${param.groupKey}" />
	</c:if>
</div>

<%@ include file="/WEB-INF/template/footer.jsp"%>
