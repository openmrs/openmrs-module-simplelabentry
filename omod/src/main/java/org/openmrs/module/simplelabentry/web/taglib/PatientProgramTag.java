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

import java.util.List;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;
import javax.servlet.jsp.tagext.BodyTagSupport;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.ConceptName;
import org.openmrs.Patient;
import org.openmrs.PatientProgram;
import org.openmrs.PatientState;
import org.openmrs.Program;
import org.openmrs.ProgramWorkflow;
import org.openmrs.api.ProgramWorkflowService;
import org.openmrs.api.context.Context;

public class PatientProgramTag extends BodyTagSupport {

	public static final long serialVersionUID = 1234324234333L;
	
	private final Log log = LogFactory.getLog(getClass());
	
	private String programInput;  // Required. Supports Program ID or Program Name
	private String workflowInput;  // Optional. Supports ProgramWorkflowId or ProgramWorkflow Name
	private Integer patientId; // Optional.  If passed, will allow for retrieval of PatientProgram and current PatientState
	private String programVar; // The retrieved Program
	private String workflowVar; // The retrieved ProgramWorkflow
	private String patientProgramVar; // If patientId supplied, Contains the PatientProgram for the given ProgramWorkflow
    private String currentStateVar; // Contains the current PatientState for the PatientProgram

	public int doStartTag() throws JspException {
		ProgramWorkflowService pws = Context.getProgramWorkflowService();
		Program program = null;
		ProgramWorkflow workflow = null;
		PatientProgram patientProgram = null;
		PatientState patientState = null;
		
		// Retrieve program
		if (StringUtils.isNotBlank(programInput)) {
			// First try programId
			try {
				Integer programId = Integer.valueOf(programInput);
				program = pws.getProgram(programId);
			}
			catch (Exception e) {}
			// Next try program name
			if (program == null) {
				program = pws.getProgramByName(programInput);
			}
		}
		
		// Require program
		if (program == null) {
			throw new JspException("Program is required.");
		}
		
		log.debug("Found program:" + program);
		pageContext.setAttribute(programVar, program);
		
		// Retrieve ProgramWorkflow
		if (StringUtils.isNotBlank(workflowInput)) {
			for (ProgramWorkflow wf : program.getAllWorkflows()) {
				if (wf.getProgramWorkflowId().toString().equals(workflowInput)) {
					workflow = wf;
				}
				else {
					for (ConceptName n : wf.getConcept().getNames()) {
						if (n.getName().equals(workflowInput)) {
							workflow = wf;
						}
					}
				}
			}
		}
		
		if (workflow != null) {
			log.debug("Found workflow:" + workflow);
			
			// Check for Patient Specifics
			if (patientId != null) {
				Patient patient = Context.getPatientService().getPatient(patientId);
				if (patient == null) {
					throw new JspException("Patient ID is invalid");
				}
				List<PatientProgram> progs = pws.getPatientPrograms(patient, program, null, null, null, null, false);
				if (progs.size() > 1) {
					log.warn("Found more than one Patient Program matching patient: " + patient + " and Program: " + program + ", returning first found.");
				}
				if (!progs.isEmpty()) {
					patientProgram = progs.get(0);
					patientState = patientProgram.getCurrentState(workflow);
				}
			}
		}
		pageContext.setAttribute(workflowVar, workflow);
		pageContext.setAttribute(patientProgramVar, patientProgram);
		pageContext.setAttribute(currentStateVar, patientState);
		
		return EVAL_BODY_BUFFERED;
	}
	
	/**
	 * @see javax.servlet.jsp.tagext.Tag#doEndTag()
	 */
	public int doEndTag() throws JspException {
		try
        {
            if(bodyContent != null)
            	bodyContent.writeOut(bodyContent.getEnclosingWriter());
        }
        catch(java.io.IOException e)
        {
            throw new JspTagException("IO Error: " + e.getMessage());
        }
        return EVAL_PAGE;
	}

	public String getProgramInput() {
    	return programInput;
    }

	public void setProgramInput(String programInput) {
    	this.programInput = programInput;
    }

	public String getWorkflowInput() {
    	return workflowInput;
    }

	public void setWorkflowInput(String workflowInput) {
    	this.workflowInput = workflowInput;
    }

	public Integer getPatientId() {
    	return patientId;
    }

	public void setPatientId(Integer patientId) {
    	this.patientId = patientId;
    }

	public String getProgramVar() {
    	return programVar;
    }

	public void setProgramVar(String programVar) {
    	this.programVar = programVar;
    }

	public String getWorkflowVar() {
    	return workflowVar;
    }

	public void setWorkflowVar(String workflowVar) {
    	this.workflowVar = workflowVar;
    }

	public String getPatientProgramVar() {
    	return patientProgramVar;
    }

	public void setPatientProgramVar(String patientProgramVar) {
    	this.patientProgramVar = patientProgramVar;
    }

	public String getCurrentStateVar() {
    	return currentStateVar;
    }

	public void setCurrentStateVar(String currentStateVar) {
    	this.currentStateVar = currentStateVar;
    }
}
