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
package org.openmrs.module.simplelabentry.web.taglib;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import javax.servlet.jsp.tagext.TagSupport;

import org.apache.commons.lang.ObjectUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Order;
import org.openmrs.api.OrderService.ORDER_STATUS;
import org.openmrs.api.context.Context;
import org.openmrs.module.simplelabentry.SimpleLabEntryService;

public class GroupedOrderTag extends TagSupport {

	public static final long serialVersionUID = 1122112233L;
	
	private final Log log = LogFactory.getLog(getClass());
	
	private String name;
	private String defaultValue;
	private String javascript;
	private String limit;
	
	public int doStartTag() {
		
		StringBuffer sb = new StringBuffer();
		try {
			log.debug("In OpenOrderTag");
			SimpleLabEntryService ls = (SimpleLabEntryService) Context.getService(SimpleLabEntryService.class);
			ORDER_STATUS status = "open".equals(limit) ? ORDER_STATUS.CURRENT : "closed".equals(limit) ? ORDER_STATUS.COMPLETE : ORDER_STATUS.NOTVOIDED;
	    	List<Order> openOrders = ls.getLabOrders(null, null, null, status, null);
	    	
	    	log.debug("Found " + openOrders.size() + " open orders.");
	    	
	    	Map<String, Integer> numVal = new HashMap<String, Integer>();
	    	Map<String, String> groupNameVal = new TreeMap<String, String>();
	    	
	    	for (Order o : openOrders) {
	    		StringBuffer groupName = new StringBuffer();
	    		groupName.append(ObjectUtils.toString(o.getEncounter().getLocation().getName(), "?") + " ");
	    		groupName.append(Context.getDateFormat().format(o.getStartDate() != null ? o.getStartDate() : o.getEncounter().getEncounterDatetime()) + " ");
	    		groupName.append(StringUtils.isBlank(o.getConcept().getName().getShortName()) ?o.getConcept().getName().getName() : o.getConcept().getName().getShortName());
	    		
	    		StringBuffer groupVal = new StringBuffer();
	    		groupVal.append(ObjectUtils.toString(o.getEncounter().getLocation().getLocationId(), "?") + ".");
	    		groupVal.append(Context.getDateFormat().format(o.getStartDate() != null ? o.getStartDate() : o.getEncounter().getEncounterDatetime()) + ".");
	    		groupVal.append(o.getConcept().getConceptId());
	    		
	    		groupNameVal.put(groupName.toString(), groupVal.toString());
	    		
	    		Integer orderCount = numVal.get(groupName.toString());
	    		if (orderCount == null) {
	    			orderCount = new Integer(0);
	    		}
	    		numVal.put(groupName.toString(), ++orderCount);
	    	}
	    	log.debug("Grouped orders = " + groupNameVal);
			
	    	sb.append("<select name=\"" + name + "\" " + javascript + "\">");
			sb.append("<option value=\"\"></option>");
			for (String name : groupNameVal.keySet()) {
				String val = groupNameVal.get(name);
				Integer count = numVal.get(name);
				sb.append("<option value=\"" + val + "\"" + (val.equals(defaultValue) ? " selected" : "") + ">" + name + " (" + count + ")" + "</option>");
			}
			sb.append("</select>");
		}
		catch (Exception e) {
			sb = new StringBuffer("ERROR RENDERING TAG");
			log.error("ERROR RENDERING GroupedOrderTag", e);
		}
		
		try {
			pageContext.getOut().write(sb.toString());
		}
		catch (IOException e) {
			log.error(e);
		}
		
		return SKIP_BODY;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	public String getDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public String getJavascript() {
		return javascript;
	}

	public void setJavascript(String javascript) {
		this.javascript = javascript;
	}

	public String getLimit() {
		return limit;
	}

	public void setLimit(String limit) {
		this.limit = limit;
	}
		
}