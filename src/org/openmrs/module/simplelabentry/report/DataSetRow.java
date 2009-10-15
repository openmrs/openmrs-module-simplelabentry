package org.openmrs.module.simplelabentry.report;

import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class DataSetRow implements Comparable<DataSetRow> { 
	
	private Map<String,String> rowMap = new HashMap<String,String>();

	public DataSetRow(Map<String, String> row) { 
		rowMap = row;
	}
	
	public String get(String key) { 
		return rowMap.get(key); 
	} 
	
	public void add(String columnName, String columnValue) { 
		rowMap.put(columnName, columnValue);
	}
	
	public Set<String> getColumns() { 
		return rowMap.keySet();
	}
	
	public Collection<String> getValues() { 
		return rowMap.values();
	}
	
	/**
	 * Hack to sort rows by group column.  
	 */
	public int compareTo(DataSetRow other) {
		String thisGroup = this.get("Group");
		String otherGroup = other.get("Group");
		if (thisGroup != null && otherGroup != null) 
			return thisGroup.compareTo(otherGroup);
		else if (thisGroup != null) 
			return thisGroup.compareTo("");
		else if (otherGroup != null) 
			return "".compareTo(otherGroup);
		else 
			return 0;
	}
	
}
