package org.openmrs.module.simplelabentry.report;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Date;
import java.util.Map;

import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFooter;
import org.apache.poi.hssf.usermodel.HSSFPrintSetup;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.openmrs.api.context.Context;
import org.openmrs.module.simplelabentry.util.SimpleLabEntryUtil;

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
        HSSFWorkbook workbook = new HSSFWorkbook();
        ExcelStyleHelper styleHelper = new ExcelStyleHelper(workbook);        
        Map<String, DataSet> dataSetsByLocation = SimpleLabEntryUtil.groupDataSetByColumn(report.getDataSet(), "Location");
        
        // Iterate over all locations 
        for (String location : dataSetsByLocation.keySet()) { 
        	// Create new worksheet for each location 
	        HSSFSheet worksheet = workbook.createSheet(ExcelSheetHelper.fixSheetName(location));
	        worksheet.setGridsPrinted(true);
	        worksheet.setPrintGridlines(true); 
	        worksheet.setHorizontallyCenter(true);
	        worksheet.setMargin(HSSFSheet.LeftMargin, 0);
	        worksheet.setMargin(HSSFSheet.RightMargin, 0);
        	worksheet.createFreezePane( 0, 1, 0, 1 );
	        
	        worksheet.getHeader().setCenter( "Lab Order Results for " + location + " between " + 
	        		Context.getDateFormat().format((Date)report.getParameters().get("startDate")) + " and " + 
	        		Context.getDateFormat().format((Date)report.getParameters().get("endDate")) );
	        worksheet.getFooter().setCenter( "Page " + HSSFFooter.page() + " of " + HSSFFooter.numPages() );

	        // Configure the printer settings for each worksheet
	        HSSFPrintSetup printSetup = worksheet.getPrintSetup();
	        printSetup.setFitWidth((short)1);
	        printSetup.setFitHeight((short)9999);
	        printSetup.setLandscape(true);	        
	        printSetup.setPaperSize(HSSFPrintSetup.LETTER_PAPERSIZE);

	        // Create helper to 
	        ExcelSheetHelper worksheetHelper = new ExcelSheetHelper(worksheet);	        
	        
	        // Get the header row
	       	DataSet dataSet = dataSetsByLocation.get(location);


	       	// Sort the dataset 
	       	SimpleLabEntryUtil.sortDataSet(dataSet);
	        
	        // Display top header
	        int columnIndex = 0;
	        for (String columnName : dataSet.firstRow().getColumns()) {	        	
	        	if (!EXCLUDE_COLUMNS.contains(columnName)) { 
		        	HSSFCellStyle cellStyle = styleHelper.getStyle("bold,border=bottom,size=10");		        		
		        	// 'true' tells the helper to rotate the text
		        	worksheetHelper.addCell(columnName, cellStyle, true);
	        	}
	        	columnIndex++;
	        }	        
	        
	        // Output all data grouped by location
	        for (DataSetRow dataRow : dataSet)	{       
	        	worksheetHelper.nextRow();
	            for (String columnName : dataRow.getColumns()) {
	            	if (!EXCLUDE_COLUMNS.contains(columnName)) { 
		            	Object value = dataRow.get(columnName);
		                if (value instanceof Date) 
		                	worksheetHelper.addCell(value, styleHelper.getStyle("date"));
		                else 
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
        
        // Sets the header column to repeat on every printed page for each tab in the workbook
        // Need to repeat for every worksheet
        for (int sheetIndex=0; sheetIndex<workbook.getNumberOfSheets();sheetIndex++) { 
        	HSSFSheet worksheet = workbook.getSheetAt(sheetIndex);
        	//int sheetIndex, int startColumn, int endColumn, int startRow, int endRow
        	int startColumn = 0; 
        	int endColumn = worksheet.getRow(0).getPhysicalNumberOfCells();
        	int startRow = 0;
        	int endRow = 1;
	        workbook.setRepeatingRowsAndColumns(sheetIndex,startColumn,endColumn,startRow,endRow);
        }        
        workbook.write(out);
    }
}
