<%@ include file="/WEB-INF/template/include.jsp"%>
<openmrs:require privilege="Manage Reports" otherwise="/login.htm" redirect="/module/reporting/index.htm" />
<%@ include file="localHeader.jsp"%>

<openmrs:htmlInclude file="/scripts/easyAjax.js" />

<script type="text/javascript">
	var $j = jQuery.noConflict(); 
</script>


<style>
.desc { display: block; } 
.buttons { margin: 50px; } 
form div { margin: 10px; } 


</style>

<div id="page">
	<div id="container">
		<h1>Declining CD4 Report </h1>					
		<form method="post" action="${pageContext.request.contextPath}/module/simplelabentry/RunAndRenderDecliningCD4Report.form">		
			<input type="hidden" name="action" value="render"/>
			<fieldset>
				<legend>Enter a period and location</legend>
				
				<table>
					<tr>
						<td>
							
							<div>
								<label class="desc" for="locationId">Location</label>
								<span>
									<select name="locationId"  tabindex="5">
										<option value="0">All Locations</option>									
										<c:forEach var="location" items="${locations}">
											<option value="${location.locationId}">${location.name}</option>
										</c:forEach>
									</select>		
								</span>
							</div>
							
							<div class="buttons">
								<span>
									<input id="save-button" class="btTxt submit" type="submit" value="Run Report" tabindex="6" />
								</span>
							</div>
						</td>
						<td valign="top">
						
							<div id="displayReportPopup" width="100%"> 
						        <div id="displayReportPopupLoading"><spring:message code="general.loading"/></div> 
						        <iframe id="displayReportPopupIframe" width="100%" height="100%" marginWidth="0" marginHeight="0" frameBorder="0" scrolling="auto"></iframe> 
					 		</div> 
					 		 
					 		<script type="text/javascript"> 
								$j(document).ready(function() { 
									$j("#displayReportPopupIframe").load(function() { $j('#displayReportPopupLoading').hide(); });
					
									$j("#runReport").click(function() { 
										$j('#displayReportPopupLoading').show(); 
										var title = 'Google';
										var urlToLoad =  
											'${pageContext.request.contextPath}/module/simplelabentry/runAndRenderLabOrderReport.form?locationId=0&startDate=01/01/2009&endDate=01/31/2009&inline=true'
										
										$j("#displayReportPopupIframe").attr("src", urlToLoad); 
									});
								}); 
					 		</script>
						
						</td>
					</tr>
				</table>
				
				
			</fieldset>
		</form>
	</div>
</div>



	
<%@ include file="/WEB-INF/template/footer.jsp"%>
					