package org.openmrs.module.simplelabentry.report;

import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;



public class Parameters implements Iterable<String> { 
	
	private Map<String,Object> parameters = new LinkedHashMap<String,Object>();
	
	public void add(String parameter, Object value) { 
		parameters.put(parameter, value);
	}
	
	public Object get(String parameter) { 
		return parameters.get(parameter);
	}
	
	public Iterator<String> iterator() {
		return parameters.keySet().iterator();
	}	
	
	
	
	
	
}