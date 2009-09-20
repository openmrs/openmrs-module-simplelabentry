package org.openmrs.module.simplelabentry.report;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.openmrs.module.simplelabentry.report.ConceptColumn;
import org.openmrs.module.simplelabentry.report.LabOrderReport;

/**
 * Report renderer that produces an Excel pre-2007 workbook with one sheet per dataset in the report.
 */

public class ExcelReportRenderer {

    /**
     * @see org.openmrs.module.report.renderer.ReportRenderer#render(org.openmrs.module.report.ReportData, java.lang.String, java.io.OutputStream)
     * @should render ReportData to an xls file
     */
    public void render(LabOrderReport report, OutputStream out) throws IOException {
        HSSFWorkbook wb = new HSSFWorkbook();
        ExcelStyleHelper styleHelper = new ExcelStyleHelper(wb);

        // TODO This should actually loop over locations and display orders by location
        String worksheetName = "Lab Order Report";
        
        HSSFSheet sheet = wb.createSheet(ExcelSheetHelper.fixSheetName(worksheetName));
        ExcelSheetHelper helper = new ExcelSheetHelper(sheet);
        Set<String> columnList = report.getData().get(0).keySet();
        
        // Display top header
        for (String columnName : columnList) {
        	helper.addCell(columnName, styleHelper.getStyle("bold,border=bottom,size=12"));
        }
        for (Iterator<Map<String,String>> i = report.getData().iterator(); i.hasNext(); ) {
            helper.nextRow();
            Map<String,String> row = i.next();
            for (String columnName : columnList) {
            	Object cellValue = row.get(columnName);
                HSSFCellStyle style = null;
                if (cellValue instanceof Date) {
                    style = styleHelper.getStyle("date");
                }
                helper.addCell(cellValue, style);
            }
        }
        
        wb.write(out);
    }
}
