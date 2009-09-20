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

import java.util.List;

import junit.framework.Assert;

import org.junit.Test;
import org.openmrs.OrderType;
import org.openmrs.api.context.Context;
import org.openmrs.test.BaseModuleContextSensitiveTest;

/**
 * This test validates the AdminList extension class
 */
public class SimpleLabEntryServiceTest extends BaseModuleContextSensitiveTest {

	/**
	 * Quick test to make sure JUnit 4.4 works in module
	 */
	@Test
	public void shouldReturnAllOrderTypes() {

		List<OrderType> orderTypes = Context.getOrderService().getAllOrderTypes();		
		Assert.assertEquals("should return 3 order types", 3, orderTypes.size());		
		
	}
	
}
