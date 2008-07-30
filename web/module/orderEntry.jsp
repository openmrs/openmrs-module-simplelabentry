<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ include file="localHeader.jsp"%>
<openmrs:require privilege="View Orders" otherwise="/login.htm" redirect="module/simplelabentry/simpleLabEntry.form" />

<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />
<br/>
<div style="text-align:center;">
	<h3>Lab Order Entry Form</h3><br/>
	<form action="orderEntry.htm" method="get">
		<spring:message code="simplelabentry.orderLocation" />: 
		<openmrs_tag:locationField formFieldName="orderLocation" initialValue="${param.orderLocation}"/>
		<spring:message code="simplelabentry.orderType" />:
		<simplelabentry:orderConceptTag name="orderConcept" defaultValue="${param.orderConcept}" javascript="" />
		<spring:message code="simplelabentry.orderDate" />: 
		<input type="text" name="orderDate" size="10" value="${param.orderDate}" onFocus="showCalendar(this)" />
		<input type="submit" value="<spring:message code="general.submit" />" />
	</form>
	<br/><hr/><br/>
	<openmrs:portlet url="orderEntry" id="orderEntrySectionId" moduleId="simplelabentry" parameters="allowAdd=true|allowDelete=nonResults|orderLocation=${param.orderLocation}|orderConcept=${param.orderConcept}|orderDate=${param.orderDate}" />
</div>

<%@ include file="/WEB-INF/template/footer.jsp"%>
