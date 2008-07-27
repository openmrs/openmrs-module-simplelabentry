<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ include file="localHeader.jsp"%>
<openmrs:require privilege="View Orders" otherwise="/login.htm" redirect="module/simplelabentry/simpleLabEntry.form" />

<br/>
<div style="text-align:center;">
	<h3>Result Entry Form</h3><br/>
	<form action="resultEntry.form" method="get">
		<select name="groupKey" onchange="this.form.submit();">
			<option value=""></option>
			<c:forEach items="${groupNameValMap}" var="nameVal" varStatus="nameValStatus">
				<option value="${nameVal.value}" <c:if test="${param.groupKey == nameVal.value}">selected</c:if>>
					${nameVal.key} ( ${numValMap[nameVal.key]} open orders )
				</option>
			</c:forEach>
		</select>
	</form>
	<br/><hr/><br/>
	<openmrs:portlet url="orderEntry" id="orderEntrySectionId" moduleId="simplelabentry" parameters="limit=open|orderLocation=${orderLocation}|orderConcept=${orderConcept}|orderDate=${orderDate}" />
</div>

<%@ include file="/WEB-INF/template/footer.jsp"%>
