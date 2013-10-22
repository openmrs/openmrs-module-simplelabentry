package org.openmrs.module.simplelabentry.report;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;



public class DataSet implements Iterable<DataSetRow> { 
	
	private String sortColumn = null;
	private List<DataSetRow> dataSetRows = new LinkedList<DataSetRow>();
	
	public DataSet() { }
	
	public DataSet(List<Map<String,String>> data) { 
		for(Map<String,String> row : data) { 
			dataSetRows.add(new DataSetRow(row));
		}
	}
	
	public void add(DataSetRow dataSetRow) { 
		this.dataSetRows.add(dataSetRow);
	}

	public Iterator<DataSetRow> iterator() {
		return dataSetRows.iterator();
	}

	public DataSetRow firstRow() { 
		return dataSetRows.get(0);
	}

	public List<DataSetRow> getRows() { 
		return dataSetRows;
	}
	
	public void setRows(List<DataSetRow> rows) { 
		this.dataSetRows = rows;
	}

	public void setSortColumn(String sortColumn) { 
		this.sortColumn = sortColumn;
	}

	public String getSortColumn() { 
		return this.sortColumn;
	}
	
	
}