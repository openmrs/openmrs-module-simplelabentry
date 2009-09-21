package org.openmrs.module.simplelabentry.report;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
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
	
	
	public Map<String, List<Map<String,String>>> getGroupData(String groupByColumn) { 
		
		Map<String, List<Map<String, String>>> groupDataMap = new HashMap<String, List<Map<String,String>>>();
		
		for (Map<String, String> row : dataMap) { 	
			String groupByKey = row.get(groupByColumn);
			List<Map<String,String>> groupDataRow = groupDataMap.get(groupByKey);
			if (groupDataRow == null)
				groupDataRow = new LinkedList<Map<String,String>>();
			groupDataRow.add(row);	
			groupDataMap.put(groupByKey, groupDataRow);
		}		
		return groupDataMap;
	}
	
	
	
	
	
}
