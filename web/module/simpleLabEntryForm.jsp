<%@ include file="/WEB-INF/template/include.jsp"%>

<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ include file="localHeader.jsp"%>

<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRCohortService.js" />
<openmrs:htmlInclude file="/moduleResources/simplelabentry/jquery-1.2.6.min.js" />
<openmrs:htmlInclude file="/moduleResources/simplelabentry/thickbox/thickbox-compressed.js" />
<openmrs:htmlInclude file="/moduleResources/simplelabentry/thickbox/thickbox.css" />

<br/>
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
<openmrs:portlet url="labEntry" id="labEntryId" moduleId="simplelabentry" parameters="orderLocation=${param.orderLocation}|orderConcept=${param.orderConcept}|orderDate=${param.orderDate}" />


<%@ include file="/WEB-INF/template/footer.jsp"%>
