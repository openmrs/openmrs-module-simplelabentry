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
package org.openmrs.module.simplelabentry.util;

import junit.framework.Assert;
import org.junit.Test;

/**
 * Tests functionality in SimpleLabEntryUtil
 */
public class SimpleLabEntryUtilTest {

	public SimpleLabEntryUtilTest() { }

	@Test
	public void shouldRemoveWords() { 
		String value = "GROUP PEDIATRIC FOLLOWING 31";
		String actual = SimpleLabEntryUtil.remove(value, "PEDIATRIC,FOLLOWING,GROUP");
		Assert.assertEquals("31", actual);
	}

	@Test
	public void shouldReplaceWords() { 
		String value = "PEDIATRIC GROUP FOLLOWING 31";
		String actual = SimpleLabEntryUtil.replace(value, "PEDIATRIC=PEDI,FOLLOWING=FOL,GROUP =,");
		Assert.assertEquals("PEDI FOL 31", actual);		
	}
	
	@Test
	public void shouldReplaceNonNumericCharacters() { 
		String value = "GROUP FOLLOWING 31";
		String actual = value.replaceAll("[^0-9]", "");
		Assert.assertEquals("31", actual);		
	}
}
