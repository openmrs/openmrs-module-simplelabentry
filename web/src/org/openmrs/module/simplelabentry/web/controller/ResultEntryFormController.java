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
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Order;
import org.openmrs.api.OrderService.ORDER_STATUS;
import org.openmrs.api.context.Context;
import org.openmrs.module.simplelabentry.SimpleLabEntryService;
import org.springframework.validation.Errors;
import org.springframework.web.servlet.mvc.SimpleFormController;

/**
 * This controller backs the /web/module/labentryForm.jsp page.
 * This controller is tied to that jsp page in the /metadata/moduleApplicationContext.xml file
 * 
 */
public class ResultEntryFormController extends SimpleFormController {
	
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
    	
    	List<Order> openOrders = ls.getLabOrders(null, null, null, ORDER_STATUS.CURRENT, null);
    	Map<String, Integer> numVal = new HashMap<String, Integer>();
    	Map<String, String> groupNameVal = new TreeMap<String, String>();
    	for (Order o : openOrders) {
    		StringBuffer groupName = new StringBuffer();
    		groupName.append(o.getEncounter().getLocation().getName() + " ");
    		groupName.append(Context.getDateFormat().format(o.getStartDate() != null ? o.getStartDate() : o.getEncounter().getEncounterDatetime()) + " ");
    		groupName.append(o.getConcept().getName().getShortName());
    		
    		StringBuffer groupVal = new StringBuffer();
    		groupVal.append(o.getEncounter().getLocation().getLocationId() + ".");
    		groupVal.append(Context.getDateFormat().format(o.getStartDate() != null ? o.getStartDate() : o.getEncounter().getEncounterDatetime()) + ".");
    		groupVal.append(o.getConcept().getConceptId());
    		
    		groupNameVal.put(groupName.toString(), groupVal.toString());
    		
    		Integer orderCount = numVal.get(groupName.toString());
    		if (orderCount == null) {
    			orderCount = new Integer(0);
    		}
    		numVal.put(groupName.toString(), ++orderCount);
    	}
    	log.debug("Found " + numVal.size() + " in open order map: " + numVal);
    	map.put("numValMap", numVal);
    	map.put("groupNameValMap", groupNameVal);
    	
    	// Current selected items
    	String currentGroupVal = request.getParameter("groupKey");
    	if (currentGroupVal != null) {
	    	String[] split = currentGroupVal.split("\\.");
	    	map.put("orderLocation", split.length >= 1 ? split[0] : "");
	    	map.put("orderDate", split.length >= 2 ? split[1] : "");
	    	map.put("orderConcept", split.length >= 3 ? split[2] : "");
    	}

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
