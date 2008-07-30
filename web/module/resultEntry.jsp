<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ include file="localHeader.jsp"%>
<openmrs:require privilege="View Orders" otherwise="/login.htm" redirect="/module/simplelabentry/simpleLabEntry.form" />

<br/>
<div style="text-align:center;">
	<h3>Result Entry Form</h3><br/>
	<form action="resultEntry.htm" method="get">
		<simplelabentry:groupedOrderTag name="groupKey" limit="open" defaultValue="${param.groupKey}" javascript="onchange='this.form.submit();'" />
	</form>
	<br/><hr/><br/>
	<openmrs:portlet url="orderEntry" id="orderEntrySectionId" moduleId="simplelabentry" parameters="limit=open|groupKey=${param.groupKey}" />
</div>

<%@ include file="/WEB-INF/template/footer.jsp"%>
