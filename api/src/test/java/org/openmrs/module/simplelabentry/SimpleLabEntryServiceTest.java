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

import junit.framework.Assert;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.openmrs.Concept;
import org.openmrs.Location;
import org.openmrs.api.context.Context;
import org.openmrs.module.simplelabentry.util.SimpleLabEntryUtil;
import org.openmrs.test.BaseModuleContextSensitiveTest;

import java.io.File;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * This test tests SimpleLabEntryServiceTest
 */
public class SimpleLabEntryServiceTest extends BaseModuleContextSensitiveTest {

	protected static final Log log = LogFactory.getLog(SimpleLabEntryServiceTest.class);

	public SimpleLabEntryServiceTest() { }

	@Before
	public void loadDatabase() throws Exception {
		executeDataSet("org/openmrs/module/simplelabentry/standardTestDataset.xml");
	}
	
	@Test
	public void shouldGenerateLabOrderReport() throws Exception {		
		Date startDate = Context.getDateFormat().parse("06/01/2009");
		Date endDate = Context.getDateFormat().parse("06/05/2009");
		File file = getService().runAndRenderLabOrderReport(null, startDate, endDate);
		if (file != null) {
			log.info("generated lab order report: " + file.getAbsolutePath());
		}
	}
	
	@Test
	public void shouldReturnLabConcepts() {
		List<Concept> concepts = getService().getSupportedLabSets();
		Assert.assertEquals("should return 4 lab concept", 4, concepts.size());
	} 
	
	@Ignore
	public void shouldReturnAllLabOrdersBetweenGivenDates() throws Exception {
		Date startDate = Context.getDateFormat().parse("01/01/2009");
		Date endDate = new Date();
		Location location = Context.getLocationService().getLocation(26);
		List<Map<String,String>> dataset = getService().getLabOrderReportData(location, startDate, endDate);
		Assert.assertNotNull(dataset);
	}
	
	private SimpleLabEntryService getService() {
		return SimpleLabEntryUtil.getSimpleLabEntryService();
	}
}
