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
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.GlobalProperty;
import org.openmrs.api.context.Context;
import org.openmrs.web.WebConstants;

public class RequireConfigurationTag extends TagSupport {

	public static final long serialVersionUID = 122998L;
	private final Log log = LogFactory.getLog(getClass());

	private String propertyPrefix;
	private String ignoreList;
	private String configurationPage;

	public int doStartTag() throws JspException {

		List<String> propsToIgnore = new ArrayList<String>();
		if (ignoreList != null) {
			for (String s : ignoreList.split(",")) {
				propsToIgnore.add(s);
				propsToIgnore.add(propertyPrefix + s);
			}
		}
		
		for (GlobalProperty p : Context.getAdministrationService().getAllGlobalProperties()) {
			if (p != null && p.getProperty() != null && p.getProperty().startsWith(propertyPrefix)) {
				if (StringUtils.isBlank(p.getPropertyValue())) {
					if (!propsToIgnore.contains(p.getProperty())) {
						HttpServletRequest request = (HttpServletRequest)pageContext.getRequest();
						
						pageContext.getSession().setAttribute(WebConstants.OPENMRS_ERROR_ATTR, "All configuration parameters must be specified prior to using this module");
						HttpServletResponse response = (HttpServletResponse)pageContext.getResponse();
						try {
							response.sendRedirect(request.getContextPath() + configurationPage);
							return SKIP_PAGE;
						}
						catch (IOException e) {
							log.error("An error occurred in tag: " + e);
							throw new JspException(e);
						}
					}
				}
			}
		}
		return SKIP_BODY;
	}

	public String getPropertyPrefix() {
		return propertyPrefix;
	}

	public void setPropertyPrefix(String propertyPrefix) {
		this.propertyPrefix = propertyPrefix;
	}

	public String getIgnoreList() {
		return ignoreList;
	}

	public void setIgnoreList(String ignoreList) {
		this.ignoreList = ignoreList;
	}

	public String getConfigurationPage() {
		return configurationPage;
	}

	public void setConfigurationPage(String configurationPage) {
		this.configurationPage = configurationPage;
	}
}
