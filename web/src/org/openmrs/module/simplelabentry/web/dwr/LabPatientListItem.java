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
package org.openmrs.module.simplelabentry.web.dwr;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.ConceptName;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.PatientIdentifier;
import org.openmrs.PatientProgram;
import org.openmrs.PatientState;
import org.openmrs.PersonAddress;
import org.openmrs.Program;
import org.openmrs.ProgramWorkflow;
import org.openmrs.api.context.Context;
import org.openmrs.module.simplelabentry.util.SimpleLabEntryUtil;
import org.openmrs.web.dwr.PatientListItem;
import org.springframework.util.StringUtils;

public class LabPatientListItem extends PatientListItem {
	
	protected final Log log = LogFactory.getLog(getClass());

	private String countyDistrict = "";
	private String cityVillage = "";
	private String neighborhoodCell = "";
	private String programState = "";
	private String lastObs = "";
	private List<String> labOrderIdsForPatient = new ArrayList<String>();
	
	public List<String> getLabOrderIdsForPatient() {
        return labOrderIdsForPatient;
    }

    public void setLabOrderIdsForPatient(List<String> labOrderIdsForPatient) {
        this.labOrderIdsForPatient = labOrderIdsForPatient;
    }

    public LabPatientListItem() { }

	public LabPatientListItem(Patient patient) {
		super(patient);
		if (patient != null) {
			// Handle patient identifiers
			Integer idOfInterest = Integer.valueOf(Context.getAdministrationService().getGlobalProperty("simplelabentry.patientIdentifierType"));
			setIdentifier("");
			Set<String> otherIds = new HashSet<String>();
			for (PatientIdentifier pi : patient.getIdentifiers()) {
				if (pi.getIdentifierType().getPatientIdentifierTypeId().equals(idOfInterest)) {
					if (pi.isPreferred()) {
						setIdentifier(pi.getIdentifier());
					}
					else {
						if ("".equals(getIdentifier())) {
							setIdentifier(pi.getIdentifier());
						}
						otherIds.add(pi.getIdentifier());
					}
				}
			}
			otherIds.remove(getIdentifier());
			setOtherIdentifiers(StringUtils.collectionToDelimitedString(otherIds, ", "));
			
			// Handle PatientProgram Current WorkFlow State
			Program program = null;
			ProgramWorkflow workflow = null;
			String programPropToDisplay = Context.getAdministrationService().getGlobalProperty("simplelabentry.programToDisplay");
			String workflowPropToDisplay = Context.getAdministrationService().getGlobalProperty("simplelabentry.workflowToDisplay");
			try {
				Integer programId = Integer.valueOf(programPropToDisplay);
				program = Context.getProgramWorkflowService().getProgram(programId);
			}
			catch (Exception e) {}
			if (program == null) {
				program = Context.getProgramWorkflowService().getProgramByName(programPropToDisplay);
			}
			if (program != null) {
				for (ProgramWorkflow wf : program.getAllWorkflows()) {
					if (wf.getProgramWorkflowId().toString().equals(workflowPropToDisplay)) {
						workflow = wf;
					}
					else {
						for (ConceptName n : wf.getConcept().getNames()) {
							if (n.getName().equals(workflowPropToDisplay)) {
								workflow = wf;
							}
						}
					}
				}
			}
			if (workflow != null) {
				List<PatientProgram> patientPrograms = Context.getProgramWorkflowService().getPatientPrograms(patient, program, null, null, null, null, false);
				if (!patientPrograms.isEmpty()) {
					PatientProgram prog = patientPrograms.get(0);
					if (prog != null) {
						PatientState state = prog.getCurrentState(workflow);
						if (state != null && state.getState() != null) {
							programState = state.getState().getConcept().getName().getName();
						}
					}
				}
			}
			
			// Handle Last Obs
			Concept obsConcept = null;
			String obsConceptProp = Context.getAdministrationService().getGlobalProperty("simplelabentry.obsConceptIdToDisplay");
			try {
				obsConcept = Context.getConceptService().getConcept(Integer.valueOf(obsConceptProp));
			}
			catch (Exception e) {}
			if (obsConcept != null) {
				List<Obs> obs = Context.getObsService().getObservationsByPersonAndConcept(patient, obsConcept);
				Obs latestObs = null;
				for (Obs o : obs) {
					if (latestObs == null || latestObs.getObsDatetime() == null || latestObs.getObsDatetime().before(o.getObsDatetime())) {
						latestObs = o;
					}
				}
				if (latestObs != null) {
					lastObs = latestObs.getValueAsString(Context.getLocale());
				}
			}
			
			// Handle patient address fields
			PersonAddress address = patient.getPersonAddress();
			if (address != null) {
				setAddress1(address.getAddress1());
				setAddress2(address.getAddress2());
				setCountyDistrict(address.getCountyDistrict());
				setCityVillage(address.getCityVillage());
				setNeighborhoodCell(address.getNeighborhoodCell());
			}
			labOrderIdsForPatient = SimpleLabEntryUtil.getLabOrderIDsByPatient(patient, 6);
		}
	}
	
	public String getAgeStr() {
		
		if (getBirthdate() == null) {
			return "";
		}
		
		Calendar today = Calendar.getInstance();
		Calendar bday = Calendar.getInstance();
		bday.setTime(getBirthdate());
		
		int ageYears = 0;
		int ageMonths = 0;
		int ageDays = 0;

		for (; today.get(Calendar.DATE) != bday.get(Calendar.DATE); today.add(Calendar.DATE, -1)) {
			ageDays++;
		}
		for (; today.get(Calendar.MONTH) != bday.get(Calendar.MONTH); today.add(Calendar.MONTH, -1)) {
			ageMonths++;
		}
		for (; today.get(Calendar.YEAR) != bday.get(Calendar.YEAR); today.add(Calendar.YEAR, -1)) {
			ageYears++;
		}
		
		return "" + ageYears + "y " + ageMonths + "m";
	}
	

	public boolean equals(Object obj) {
		if (obj instanceof LabPatientListItem) {
			LabPatientListItem pi = (LabPatientListItem)obj;
			if (pi.getPatientId() == null || getPatientId() == null)
				return false;
			return pi.getPatientId().equals(getPatientId());
		}
		return false;
	}
	
	public int hashCode() {
		return super.hashCode();
	}
	
	public String getCountyDistrict() {
		return countyDistrict;
	}

	public void setCountyDistrict(String countyDistrict) {
		this.countyDistrict = countyDistrict;
	}

	public String getCityVillage() {
		return cityVillage;
	}

	public void setCityVillage(String cityVillage) {
		this.cityVillage = cityVillage;
	}

	public String getNeighborhoodCell() {
		return neighborhoodCell;
	}

	public void setNeighborhoodCell(String neighborhoodCell) {
		this.neighborhoodCell = neighborhoodCell;
	}

	public String getProgramState() {
		return programState;
	}

	public void setProgramState(String programState) {
		this.programState = programState;
	}

	public String getLastObs() {
		return lastObs;
	}

	public void setLastObs(String lastObs) {
		this.lastObs = lastObs;
	}
}
