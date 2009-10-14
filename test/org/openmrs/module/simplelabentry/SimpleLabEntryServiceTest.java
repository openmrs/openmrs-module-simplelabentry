/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.simplelabentry;

import java.io.File;
import java.util.Date;
import java.util.List;
import java.util.Map;

import junit.framework.Assert;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.openmrs.Cohort;
import org.openmrs.Concept;
import org.openmrs.Location;
import org.openmrs.Obs;
import org.openmrs.OrderType;
import org.openmrs.Program;
import org.openmrs.ProgramWorkflow;
import org.openmrs.api.context.Context;
import org.openmrs.module.simplelabentry.util.SimpleLabEntryUtil;
import org.openmrs.test.BaseModuleContextSensitiveTest;

/**
 * This test validates the AdminList extension class
 */
public class SimpleLabEntryServiceTest extends BaseModuleContextSensitiveTest {

	/** Logger */
	protected static final Log log = LogFactory.getLog(SimpleLabEntryServiceTest.class);
	
	/**
	 * Public constructor
	 */
	public SimpleLabEntryServiceTest() { } 
	
	@Override
	public Boolean useInMemoryDatabase() {
		return false;
	}

	@Before 
	public void beforeTests() throws Exception { 
		authenticate();
	}
	
	@Test 
	public void shouldGetLabReportPrograms() throws Exception { 
		List<Program> programs = SimpleLabEntryUtil.getLabReportPrograms();
		Assert.assertEquals(2, programs.size());
	}
	
	@Test
	public void shouldGetTreatmentGroupCache() throws Exception { 
		Cohort patients = Context.getPatientSetService().getAllPatients();		
		Assert.assertNotNull(patients);
				
		Map<Integer, String> treatmentGroupCache = SimpleLabEntryUtil.getTreatmentGroupCache(patients);		
		Assert.assertEquals(treatmentGroupCache.keySet().size(), 598);
				
		log.warn("treatment group cache " + treatmentGroupCache);
		for (Integer patientId : treatmentGroupCache.keySet()) { 			
			log.info(patientId + " = " + treatmentGroupCache.get(patientId));			
		}		
	}
	
	@Test 
	public void shouldGetObsBetweenDates() throws Exception {
		Date startDate = Context.getDateFormat().parse("01/01/2009");
		Date endDate = new Date(); //Context.getDateFormat().parse("01/30/2009");			
		//Location location = Context.getLocationService().getLocation(new Integer(26));		
		Location location = null;
		List<Concept> questions = 
			SimpleLabEntryUtil.getSimpleLabEntryService().getSupportedLabConcepts();

		List<Obs> obs = Context.getObsService().getObservations(
				null, 
				null, 
				questions, 
				null, 
				null, 
				null, 
				null, //"location", 
				null, 
				null, 
				startDate, 
				endDate, 
				false);		
	
		log.info("obs: " + obs.size());
	}
	
	
	@Test
	public void shouldRemoveWords() { 
		String value = "GROUP PEDIATRIC FOLLOWING 31";
		String actual = SimpleLabEntryUtil.remove(value, "PEDIATRIC,FOLLOWING,GROUP");		
		
		//"PEDIATRIC=PEDI,FOLLOWING=FOL,GROUP="
		log.info("Actual: " + actual);
		Assert.assertEquals("31", actual);		
	}

	@Test
	public void shouldReplaceWords() { 
		String value = "PEDIATRIC GROUP FOLLOWING 31";
		String actual = SimpleLabEntryUtil.replace(value, "PEDIATRIC=PEDI,FOLLOWING=FOL,GROUP =,");
		log.info("actual: " + actual);
		Assert.assertEquals("PEDI FOL 31", actual);		
	}
	
	@Test
	public void shouldReplaceNonNumericCharacters() { 
		String value = "GROUP FOLLOWING 31";
		String actual = value.replaceAll("[^0-9]", "");
		log.info("actual: " + actual);
		Assert.assertEquals("31", actual);		
	}
	
	@Test
	public void shouldReturnNotNullWorkflow() { 		
		ProgramWorkflow workflow = SimpleLabEntryUtil.getProgram().getWorkflowByName("TREATMENT GROUP");		
		Assert.assertNotNull(workflow);
	}
	
	/**
	 * Quick test to make sure JUnit 4.4 works in module
	 */
	@Test
	public void shouldReturnAllOrderTypes() {
		List<OrderType> orderTypes = Context.getOrderService().getAllOrderTypes();		
		Assert.assertEquals(5, orderTypes.size());				
	}
	
	@Test
	public void shouldGenerateLabOrderReport() throws Exception {		
		Date startDate = Context.getDateFormat().parse("06/01/2009");
		Date endDate = Context.getDateFormat().parse("06/10/2009");			
		//Location location = Context.getLocationService().getLocation(new Integer(26));		
		Location location = null;
		
		
		File file = 
			SimpleLabEntryUtil.getSimpleLabEntryService().runAndRenderLabOrderReport(location, startDate, endDate);
		
		if (file != null)
			log.info("generated lab order report: " + file.getAbsolutePath());
	}
	
	
	@Test
	public void shouldReturnLabConcepts() { 
		SimpleLabEntryService service = SimpleLabEntryUtil.getSimpleLabEntryService();
		List<Concept> concepts = service.getSupportedLabSets();
		Assert.assertEquals("should return 4 lab concept", 4, concepts.size());	
		
	} 
	
	@Ignore
	public void shouldReturnAllLabOrdersBetweenGivenDates() { 
		try { 
			Date startDate = Context.getDateFormat().parse("01/01/2009");
			Date endDate = new Date(); //Context.getDateFormat().parse("01/30/2009");			
			Location location = Context.getLocationService().getLocation(new Integer(26));		
			
			
			SimpleLabEntryService service = SimpleLabEntryUtil.getSimpleLabEntryService();		
			List<Map<String,String>> dataset = service.getLabOrderReportData(location, startDate, endDate);
			Assert.assertNotNull(dataset);
			
		} catch (Exception e) { 
			logger.error("Error getting order report data", e);
			
		}
	}
	
	
}
