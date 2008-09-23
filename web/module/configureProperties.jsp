<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ include file="localHeader.jsp"%>
<openmrs:require privilege="Manage Global Properties" otherwise="/login.htm" redirect="/module/simplelabentry/configureProperties.htm" />

<openmrs:htmlInclude file="/dwr/interface/DWRAdministrationService.js" />
<openmrs:htmlInclude file="/dwr/util.js" />

<openmrs:portlet url="globalProperties" id="globalPropertyEditSection" parameters="propertyPrefix=simplelabentry.|excludePrefix=simplelabentry.started|hidePrefix=true" />

<%@ include file="/WEB-INF/template/footer.jsp"%>
