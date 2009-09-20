package org.openmrs.module.simplelabentry.report;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class LabOrderReport {

	
	List<Map<String,String>> dataMap = null;
	//List<ConceptColumn> columns = null;
	
		
	/*
	public LabOrderReport(List<ConceptColumn> columns) { 
		this.columns = columns;
		this.dataMap = new ArrayList<Map<String,String>>();		
	}
	*/

	public LabOrderReport(List<Map<String,String>> dataMap) { 
		this.dataMap = dataMap;		
	}

	
	public List<Map<String,String>> getData() { 
		return this.dataMap;		
	}
	
	
	
	
	
}
