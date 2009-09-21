package org.openmrs.module.simplelabentry.report;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.openmrs.Location;

public class LabOrderReport2 {

	Map<Integer, LabOrderRow> dataMap = new HashMap<Integer,LabOrderRow>();
	Map<Location, List<Integer>> locationMap = new HashMap<Location,List<Integer>>();

	
	public LabOrderReport2() { }
	
	public Map<Integer, LabOrderRow> getData() { 
		return this.dataMap;		
	}
	
	public void addRowValue(Integer patientId, String key, String value) { 		
		LabOrderRow rowMap = dataMap.get(patientId);
		rowMap.addCellValue(key, value);

	}
	

	
	
	class LabOrderRow { 
		
		Map<String,String> rowData = new LinkedHashMap<String,String>();
		
		LabOrderRow() { } 
		
		public void addCellValue(String key, String newValue) { 			
			String value = rowData.get(key);
			if (value != null || "".equals(value)) { 
				value += "," + newValue;
			}
			rowData.put(key, value);
		}
		
		
	}
	
	
	
}
