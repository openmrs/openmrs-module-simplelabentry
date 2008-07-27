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
package org.openmrs.module.simplelabentry.web.controller;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.context.Context;
import org.openmrs.module.simplelabentry.SimpleLabEntryService;
import org.springframework.validation.Errors;
import org.springframework.web.servlet.mvc.SimpleFormController;

/**
 * This controller backs the /web/module/labentryForm.jsp page.
 * This controller is tied to that jsp page in the /metadata/moduleApplicationContext.xml file
 * 
 */
public class SimpleLabEntryFormController extends SimpleFormController {
	
    /** Logger for this class and subclasses */
    protected final Log log = LogFactory.getLog(getClass());
        	    
    /**
     * Returns any extra data in a key-->value pair kind of way
     * 
     * @see org.springframework.web.servlet.mvc.SimpleFormController#referenceData(javax.servlet.http.HttpServletRequest, java.lang.Object, org.springframework.validation.Errors)
     */
    @Override
	protected Map<String, Object> referenceData(HttpServletRequest request, Object obj, Errors err) throws Exception {
    	
    	Map<String, Object> map = new HashMap<String, Object>();
    	
    	// Default lists
		SimpleLabEntryService ls = (SimpleLabEntryService) Context.getService(SimpleLabEntryService.class);
    	map.put("testTypes", ls.getLabTestConcepts());

    	return map;
	}

    /**
     * @see org.springframework.web.servlet.mvc.AbstractFormController#formBackingObject(javax.servlet.http.HttpServletRequest)
     */
    @Override
	protected String formBackingObject(HttpServletRequest request) throws Exception { 
    	return "";
    }
}
