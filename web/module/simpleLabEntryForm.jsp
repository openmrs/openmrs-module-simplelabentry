<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ include file="localHeader.jsp"%>
<openmrs:require privilege="View Orders" otherwise="/login.htm" redirect="module/simplelabentry/simpleLabEntry.form" />

<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />

<br/>
<div style="text-align:center;">
	<h3>Lab Order Entry Form</h3><br/>
	<form action="simpleLabEntry.form" method="get">
		<spring:message code="simplelabentry.orderLocation" />: <openmrs_tag:locationField formFieldName="orderLocation" initialValue="${param.orderLocation}"/>
		<spring:message code="simplelabentry.orderType" />:
		<select name="orderConcept">
			<option value=""></option>
			<c:forEach items="${testTypes}" var="testType" varStatus="testTypeStatus">
				<option value="${testType.conceptId}" <c:if test="${param.orderConcept == testType.conceptId}">selected</c:if>>
					${empty testType.name.shortName ? testType.name.name : testType.name.shortName}
				</option>
			</c:forEach>
		</select>
		<spring:message code="simplelabentry.orderDate" />: 
		<input type="text" name="orderDate" size="10" value="${param.orderDate}" onFocus="showCalendar(this)" />
		<input type="submit" value="<spring:message code="general.submit" />" />
	</form>
	<br/><hr/><br/>
	<openmrs:portlet url="orderEntry" id="orderEntrySectionId" moduleId="simplelabentry" parameters="allowAdd=true|limit=open|orderLocation=${param.orderLocation}|orderConcept=${param.orderConcept}|orderDate=${param.orderDate}" />
</div>

<%@ include file="/WEB-INF/template/footer.jsp"%>
