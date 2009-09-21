package org.openmrs.module.simplelabentry.util;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Cohort;
import org.openmrs.Encounter;
import org.openmrs.EncounterType;
import org.openmrs.OrderType;
import org.openmrs.PatientIdentifierType;
import org.openmrs.PatientProgram;
import org.openmrs.PatientState;
import org.openmrs.PersonAttributeType;
import org.openmrs.Program;
import org.openmrs.ProgramWorkflow;
import org.openmrs.api.context.Context;
import org.openmrs.module.simplelabentry.SimpleLabEntryService;

public class SimpleLabEntryUtil { 

	private static Log log = LogFactory.getLog(SimpleLabEntryUtil.class);
	
	
	public static SimpleLabEntryService getSimpleLabEntryService() { 
		return (SimpleLabEntryService) Context.getService(SimpleLabEntryService.class);
	}
	
	/**
	 * Gets the lab order type associated with the underlying lab order type global property.
	 * 
	 * @return
	 */
	public static OrderType getLabOrderType() { 		
		return (OrderType) getGlobalPropertyValue("simplelabentry.labOrderType");				
	}	
	
	public static PatientIdentifierType getPatientIdentifierType() { 
		return (PatientIdentifierType) getGlobalPropertyValue("simplelabentry.patientIdentifierType");
	}

	public static Program getProgram() { 
		return (Program) getGlobalPropertyValue("simplelabentry.programToDisplay");
	}

	public static ProgramWorkflow getWorkflow() { 
		return (ProgramWorkflow) getGlobalPropertyValue("simplelabentry.workflowToDisplay");
	}
	
	
	/**
	 * Gets the lab order type associated with the underlying lab order type global property.
	 * 
	 * FIXME Obviously this is a hack, but it's better than having the code to get these properties
	 * copied in different locations.
	 * 
	 * @return
	 */
	public static Object getGlobalPropertyValue(String property) { 
		
		// Retrieve proper OrderType for Lab Orders
		Object object = null;
		String identifier = 
			Context.getAdministrationService().getGlobalProperty(property);

		try { 
			if ("simplelabentry.labOrderType".equals(property)) { 
				object = (OrderType)
					Context.getOrderService().getOrderType(Integer.valueOf(identifier));
			}
			else if ("simplelabentry.programToDisplay".equals(property)) { 
				object = (Program)
					Context.getProgramWorkflowService().getProgramByName(identifier);
			}
			else if ("simplelabentry.labTestEncounterType".equals(property)) { 
				object = (EncounterType)
					Context.getEncounterService().getEncounterType(Integer.valueOf(identifier));
			}
			else if ("simplelabentry.patientHealthCenterAttributeType".equals(property)) { 
				object = (PersonAttributeType)
					Context.getPersonService().getPersonAttributeType(Integer.valueOf(identifier));
			}
			else if ("simplelabentry.patientIdentifierType".equals(property)) { 
				object = (PatientIdentifierType)
					Context.getPatientService().getPatientIdentifierType(Integer.valueOf(identifier));
			}
			else if ("simplelabentry.workflowToDisplay".equals(property)) { 
				object = (ProgramWorkflow) SimpleLabEntryUtil.getProgram().getWorkflowByName(identifier);
			}
						
		}
		catch (Exception e) {
			log.error("error: ", e);
			
		}
			
		if (object == null) {
			throw new RuntimeException("Unable to retrieve object with identifier <" + identifier + ">.  Please specify an appropriate value for global property '" + property + "'");
		}
		
		return object;
	}	
	
	
	/**
	 * 
	 * @param encounters
	 * @return
	 */
	public static Map<Integer, String> getTreatmentGroupCache(List<Encounter> encounters) { 
		Map<Integer, String> treatmentGroupCache = new HashMap<Integer, String>();
		
		// Get cohort of patients from encounters
		Cohort patients = new Cohort();
		for (Encounter encounter : encounters) { 
			patients.addMember(encounter.getPatientId());
		}

		if (!patients.isEmpty()) { 
			// Get patient programs / treatment groups for all patients
			Map<Integer, PatientProgram> patientPrograms = 
				Context.getPatientSetService().getPatientPrograms(patients, SimpleLabEntryUtil.getProgram());
			
			for(PatientProgram patientProgram : patientPrograms.values()) { 
				PatientState patientState = patientProgram.getCurrentState(SimpleLabEntryUtil.getWorkflow());	
				if (patientState != null) { 
					
					// Show only the group number
					// TODO This needs to be more generalized since not everyone will use the Rwanda
					// convention for naming groups
					String value = patientState.getState().getConcept().getDisplayString();
					if (value != null)
						value = SimpleLabEntryUtil.removeWords(value, "PEDI,FOLLOWING,GROUP");				
					treatmentGroupCache.put(patientProgram.getPatient().getPatientId(), value);
				}			
			}		
		}
		return treatmentGroupCache;
	}

	
	public static String removeWords(String str, String unwanteds) { 		
		if (unwanteds != null) { 
			for (String unwanted : unwanteds.split(",")) {
				if (unwanted != null) { 
					str = str.replace(unwanted.trim(), "");
				}
			}
		}
		return str.trim();
		
	}
	
		
	
}