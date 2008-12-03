<%@ taglib prefix="simplelabentry" uri="/WEB-INF/view/module/simplelabentry/resources/simplelabentry.tld" %>

<openmrs:require privilege="View Orders" otherwise="/login.htm" redirect="/module/simplelabentry/index.htm" />

<c:if test='<%= !request.getRequestURI().contains("configureProperties") %>'>
	<simplelabentry:requireConfiguration propertyPrefix="simplelabentry." configurationPage="/module/simplelabentry/configureProperties.htm" />
</c:if>

<%@ include file="/WEB-INF/template/header.jsp"%>

<div style="border-bottom: 1px solid black;">
	<ul id="menu">
		<li class="first">
			<a href="index.htm" style="font-size:large; font-weight:bold; text-decoration:none;">Lab Entry System</a>
		</li>
		<openmrs:hasPrivilege privilege="Add Orders">
			<li <c:if test='<%= request.getRequestURI().contains("orderEntry") %>'>class="active"</c:if>>
				<a href="orderEntry.htm">Enter Orders</a>
			</li>
		</openmrs:hasPrivilege>
		<openmrs:hasPrivilege privilege='Edit Orders'>
			<li <c:if test='<%= request.getRequestURI().contains("resultEntry") %>'>class="active"</c:if>>
				<a href="resultEntry.htm">Enter Results</a>
			</li>
		</openmrs:hasPrivilege>
		<openmrs:hasPrivilege privilege="Edit Orders">
			<li <c:if test='<%= request.getRequestURI().contains("existingOrders") %>'>class="active"</c:if>>
				<a href="existingOrders.htm">Edit/Manage Orders and Results</a>
			</li>
		</openmrs:hasPrivilege>
		<openmrs:hasPrivilege privilege="Manage Global Properties">
			<li <c:if test='<%= request.getRequestURI().contains("configureProperties") %>'>class="active"</c:if>>
				<a href="configureProperties.htm">Lab Entry Configuration</a>
			</li>
		</openmrs:hasPrivilege>
	
		<openmrs:extensionPoint pointId="org.openmrs.module.simplelabentry.localHeader" type="html">
				<c:forEach items="${extension.links}" var="link">
					<li <c:if test="${fn:endsWith(pageContext.request.requestURI, link.key)}">class="active"</c:if> >
						<a href="${pageContext.request.contextPath}/${link.key}"><spring:message code="${link.value}"/></a>
					</li>
				</c:forEach>
		</openmrs:extensionPoint>
	</ul>
</div>