package org.openmrs.module.simplelabentry.report;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFPrintSetup;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.openmrs.module.simplelabentry.report.ConceptColumn;
import org.openmrs.module.simplelabentry.report.LabOrderReport;

/**
 * Report renderer that produces an Excel pre-2007 workbook with one sheet per dataset in the report.
 */

public class ExcelReportRenderer {

	private static String EXCLUDE_COLUMNS = "Patient ID,Location";
	
	
	
	
	
    /**
     * @see org.openmrs.module.report.renderer.ReportRenderer#render(org.openmrs.module.report.ReportData, java.lang.String, java.io.OutputStream)
     * @should render ReportData to an xls file
     */
    public void render(LabOrderReport report, OutputStream out) throws IOException {
        HSSFWorkbook workbook = new HSSFWorkbook();
        ExcelStyleHelper styleHelper = new ExcelStyleHelper(workbook);
        
        Map<String, List<Map<String,String>>> dataSetsByLocation = report.getGroupData("Location");
        
        
        // Iterate over all locations 
        for (String location : dataSetsByLocation.keySet()) { 
        	
        	// Create new worksheet for each location 
	        HSSFSheet worksheet = workbook.createSheet(ExcelSheetHelper.fixSheetName(location));
	        worksheet.setGridsPrinted(true);
	        worksheet.setHorizontallyCenter(true);
	        worksheet.setMargin(HSSFSheet.LeftMargin, 0);
	        worksheet.setMargin(HSSFSheet.RightMargin, 0);

	        // Configure the printer settings for each worksheet
	        HSSFPrintSetup printSetup = worksheet.getPrintSetup();
	        printSetup.setFitWidth((short)1);
	        printSetup.setFitHeight((short)9999);
	        printSetup.setLandscape(true);	        
	        printSetup.setPaperSize(HSSFPrintSetup.LETTER_PAPERSIZE);

	        // Create helper to 
	        ExcelSheetHelper worksheetHelper = new ExcelSheetHelper(worksheet);	        
	        
	        // Get the header row
	        List<Map<String, String>> dataSet = dataSetsByLocation.get(location);
	        Map<String,String> firstRow = dataSet.get(0);
	        
	        // Display top header
	        int columnIndex = 0;
	        for (String columnName : firstRow.keySet()) {	        	
	        	if (!EXCLUDE_COLUMNS.contains(columnName)) { 
		        	HSSFCellStyle cellStyle = styleHelper.getStyle("bold,border=bottom,size=10");		        	
		        		
		        	// 'true' tells the helper to rotate the text
		        	worksheetHelper.addCell(columnName, cellStyle, true);
	    	        //sheet.autoSizeColumn(columnIndex);
		        	// If obs column header cell
		        	/*
		        	if (columnIndex>6 || columnIndex==3 || columnIndex==4) { // 
		        		worksheet.setColumnWidth(columnIndex, 1000);
			        	helper.addCell(columnName, cellStyle, true);  // 'true' tells the helper to rotate the text
		        	} 
		        	// All other header cells
		        	else { 
		        		helper.addCell(columnName, cellStyle);
		        	}*/
	        	}
	        	columnIndex++;
	        }	        
	        
	        // Output all data grouped by location
	        for (Map<String, String> dataRow : dataSet)	{       
	        	worksheetHelper.nextRow();
	            for (String columnName : dataRow.keySet()) {
	            	if (!EXCLUDE_COLUMNS.contains(columnName)) { 
		            	Object value = dataRow.get(columnName);
		                HSSFCellStyle style = null;
		                if (value instanceof Date) {
		                    style = styleHelper.getStyle("date");
		                }
		                worksheetHelper.addCell(value, styleHelper.getStyle("size=8"));
	            	}
	            }
	        }
	        	        
	        // Resize each column to fit contents
	        HSSFRow row = worksheet.getRow(0);
	        for (int i = 0; i<row.getLastCellNum();i++) { 
	        	worksheet.autoSizeColumn((short) i);	        	
	        }
	        
	        
        }        
        workbook.write(out);
    }
}
