<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="localHeader.jsp"%>
<openmrs:require privilege="View Orders" otherwise="/login.htm" redirect="module/simplelabentry/orderEntry.htm" />

<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />
<br/>
<div>
	<c:set var="selectedAllFields">
		${param.orderLocation!=null && param.orderConcept!=null && param.orderDate!=null}
	</c:set>
		
	<b class="boxHeader">Step 1.  Choose what orders you want to enter:</b>
	<div class="box" >
	
		<div align="center">
		<c:choose>		
			<c:when test="${!selectedAllFields}">
				<!-- If all fields are not selected, display them as editable -->
				<form action="orderEntry.htm" method="get">
				
						<spring:message code="simplelabentry.orderLocation" />: 
						<openmrs_tag:locationField formFieldName="orderLocation" 
							initialValue="${param.orderLocation}"/>

						<spring:message code="simplelabentry.orderDate" />: 
						<input type="text" name="orderDate" size="10" value="${param.orderDate}" onFocus="showCalendar(this)" />

					<input type="submit" value="<spring:message code="general.submit" />"/>
					
				</form>				
			</c:when>
			<c:otherwise>
				<!-- Otherwise, display fields as readonly so we don't confuse the user -->
				<spring:message code="simplelabentry.orderLocation" />: 

				<select name="orderLocation" id="orderLocation" disabled>
					<openmrs:forEachRecord name="location">
						<option value="${record.locationId}" 
							<c:if test="${record.locationId == param.orderLocation}">selected</c:if>>${record.name}
						</option>
					</openmrs:forEachRecord>
				</select>
				
				<spring:message code="simplelabentry.orderDate" />: 
				<input type="text" name="orderDate" size="10" value="${param.orderDate}" disabled onFocus="showCalendar(this)" />				

				<input type="submit" value="<spring:message code="general.submit" />" disabled/>
								
				<a href="orderEntry.htm">New Order Sheet</a>

			</c:otherwise>
		</c:choose>
		</div>
	</div>

	<br/>
	
	<c:if test="${!empty param.orderLocation && !empty param.orderDate }">
		<openmrs:portlet url="orderEntry" id="orderEntrySectionId" moduleId="simplelabentry" parameters="allowAdd=true|allowDelete=nonResults|orderLocation=${param.orderLocation}|orderDate=${param.orderDate}" />
	</c:if>
</div>

<%@ include file="/WEB-INF/template/footer.jsp"%>
