package org.openmrs.module.simplelabentry.report;


public class LabOrderReport {

	private Parameters parameters = new Parameters();
	private DataSet dataSet = new DataSet();

	public LabOrderReport() { } 
	
	public LabOrderReport(DataSet dataSet) { 
		this.dataSet = dataSet;		
	}
	
	public DataSet getDataSet() { 
		return this.dataSet;		
	}

	public void setDataSet(DataSet dataSet) { 
		this.dataSet = dataSet;
	}
	
	public Parameters getParameters() { 
		return this.parameters;
	}

	public void addParameter(String parameter, Object value) { 
		parameters.add(parameter, value);
	}
	
}



