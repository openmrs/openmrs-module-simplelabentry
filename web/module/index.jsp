<%@ include file="/WEB-INF/template/include.jsp"%>
<openmrs:require privilege="View Orders" otherwise="/login.htm" redirect="/module/simplelabentry/index.htm" />
<%@ include file="localHeader.jsp"%>

<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />

<br/>
<div style="text-align:center;">
	<b class="boxHeader">Enter Lab Orders</b>
	<div class="box">
		<form action="orderEntry.htm" method="get">
			<spring:message code="simplelabentry.orderLocation" />: 
			<openmrs_tag:locationField formFieldName="orderLocation" initialValue=""/>
			<spring:message code="simplelabentry.orderType" />:
			<simplelabentry:orderConceptTag name="orderConcept" defaultValue="" javascript="" />
			<spring:message code="simplelabentry.orderDate" />: 
			<input type="text" name="orderDate" size="10" value="" onFocus="showCalendar(this)" />
			<input type="submit" value="<spring:message code="general.submit" />" />
		</form>
	</div>
	<br/><br/>
	<b class="boxHeader">Enter Results</b>
	<div class="box">
		<form action="resultEntry.htm" method="get">
			<simplelabentry:groupedOrderTag name="groupKey" limit="open" defaultValue="" javascript="onchange='this.form.submit();'" />
		</form>
	</div>
	<br/><br/>
	<b class="boxHeader">Edit/Manage Orders and Results</b>
	<div class="box">
		<form action="existingOrders.htm" method="get">
			Choose From Existing Orders by Category: <simplelabentry:groupedOrderTag name="groupKey" defaultValue="" javascript="" />
			<span> OR </span>
			Patient Identifier: <input type="text" name="identifier" size="10" />
			<input type="submit" value="Submit" />
		</form>
	</div>
</div>

<%@ include file="/WEB-INF/template/footer.jsp"%>
