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
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.openmrs.module.simplelabentry.report.ConceptColumn;
import org.openmrs.module.simplelabentry.report.LabOrderReport;

/**
 * Report renderer that produces an Excel pre-2007 workbook with one sheet per dataset in the report.
 */

public class ExcelReportRenderer {

	private static String EXCLUDE_COLUMNS = "Patient ID,";
	
	
	
	
	
    /**
     * @see org.openmrs.module.report.renderer.ReportRenderer#render(org.openmrs.module.report.ReportData, java.lang.String, java.io.OutputStream)
     * @should render ReportData to an xls file
     */
    public void render(LabOrderReport report, OutputStream out) throws IOException {
        HSSFWorkbook wb = new HSSFWorkbook();
        ExcelStyleHelper styleHelper = new ExcelStyleHelper(wb);
        
        Map<String, List<Map<String,String>>> dataSetsByLocation = report.getGroupData("Location");
        
        for (String location : dataSetsByLocation.keySet()) { 
        	
	        List<Map<String, String>> locationDataSet = dataSetsByLocation.get(location);
        	
	        HSSFSheet sheet = wb.createSheet(ExcelSheetHelper.fixSheetName(location));
	        ExcelSheetHelper helper = new ExcelSheetHelper(sheet);	        
	        
	        Map<String,String> firstRow = locationDataSet.get(0);
	        
	        // Display top header
	        int columnIndex = 0;
	        for (String columnName : firstRow.keySet()) {	        	
	        	if (!EXCLUDE_COLUMNS.contains(columnName)) { 
		        	HSSFCellStyle cellStyle = styleHelper.getStyle("bold,border=bottom,size=10");		        	
		        			        	
		        	// If obs column header cell
		        	if (columnIndex>6 || columnIndex==3 || columnIndex==4) { // 
		        		sheet.setColumnWidth(columnIndex, 1000);
			        	helper.addCell(columnName, cellStyle, true);  // 'true' tells the helper to rotate the text
		        	} 
		        	// All other header cells
		        	else { 
		        		helper.addCell(columnName, cellStyle);
		        	}
	        	}
	        	columnIndex++;
	        }
	        
	        HSSFPrintSetup ps = sheet.getPrintSetup();
	        ps.setFitWidth((short)1);
	        ps.setFitHeight((short)9999);
	        sheet.setGridsPrinted(true);
	        sheet.setHorizontallyCenter(true);
	        sheet.setMargin(HSSFSheet.LeftMargin, 0);
	        sheet.setMargin(HSSFSheet.RightMargin, 0);
	        ps.setLandscape(true);
	        
	        ps.setPaperSize(HSSFPrintSetup.LETTER_PAPERSIZE);
	        //ps.setPaperSize(HSSFPrintSetup.LEGAL_PAPERSIZE);
	        //ps.setPaperSize(HSSFPrintSetup.EXECUTIVE_PAPERSIZE);
	        
	        for (Map<String, String> locationDataRow : locationDataSet)	{       
	            helper.nextRow();
	            for (String columnName : locationDataRow.keySet()) {
	            	if (!EXCLUDE_COLUMNS.contains(columnName)) { 
		            	Object cellValue = locationDataRow.get(columnName);
		                HSSFCellStyle style = null;
		                if (cellValue instanceof Date) {
		                    style = styleHelper.getStyle("date");
		                }
		                helper.addCell(cellValue, styleHelper.getStyle("size=8"));
	            	}
	            }
	        }
        }        
        wb.write(out);
    }
}
