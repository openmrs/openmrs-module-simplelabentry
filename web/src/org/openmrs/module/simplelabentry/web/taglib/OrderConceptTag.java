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
import java.util.List;
import javax.servlet.jsp.tagext.TagSupport;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.api.context.Context;
import org.openmrs.module.simplelabentry.SimpleLabEntryService;

public class OrderConceptTag extends TagSupport {

	public static final long serialVersionUID = 1122112233L;
	
	private final Log log = LogFactory.getLog(getClass());
	
	private String name;
	private String defaultValue;
	private String javascript;
	private Boolean disabled = false;
	
	public int doStartTag() {
		
		log.debug("In OrderConceptTag");
		SimpleLabEntryService ls = (SimpleLabEntryService) Context.getService(SimpleLabEntryService.class);
    	List<Concept> concepts = ls.getLabTestConcepts();
    	log.debug("Found " + concepts.size() + " supported concepts.");
		
    	StringBuffer sb = new StringBuffer();
    	sb.append("<select " + (disabled?"disabled":"") + " name=\"" + name + "\" " + javascript + "\">");
		sb.append("<option value=\"\"></option>");
		for (Concept c : concepts) {
			sb.append("<option value=\"" + c.getConceptId() + "\"" + (c.getConceptId().toString().equals(defaultValue) ? " selected" : "") + ">");
			sb.append(c.getName().getShortestName());
			sb.append("</option>");
		}
		sb.append("</select>");
		
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

	public Boolean getDisabled() {
		return (disabled != null) ? disabled : false;
	}

	public void setDisabled(Boolean disabled) {
		log.info("Set Disabled: " + disabled);
		this.disabled = disabled;
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
		
}