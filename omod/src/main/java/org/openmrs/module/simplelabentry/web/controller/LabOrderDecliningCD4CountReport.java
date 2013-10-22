package org.openmrs.module.simplelabentry.web.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.Location;
import org.openmrs.api.context.Context;
import org.openmrs.module.simplelabentry.SimpleLabEntryService;
import org.openmrs.propertyeditor.ConceptEditor;
import org.openmrs.propertyeditor.LocationEditor;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LabOrderDecliningCD4CountReport {

    
    private static Log log = LogFactory.getLog(LabOrderDecliningCD4CountReport.class);
    
    @InitBinder
    public void initBinder(WebDataBinder binder) {
        binder.registerCustomEditor(Date.class, new CustomDateEditor(Context.getDateFormat(), true));
        binder.registerCustomEditor(Concept.class, new ConceptEditor());
        binder.registerCustomEditor(Location.class, new LocationEditor());
    }
    
    /**
     * Shows the report form for the lab report.
     * 
     * @param model
     * @return
     */
    @ModelAttribute("locations")
    public List<Location> getLocations() {      
        return Context.getLocationService().getAllLocations(false);     
    }
    
    /**
     * 
     */
    @RequestMapping("/module/simplelabentry/DecliningCD4Report")
    public String showLabReportForm() {         
        return "/module/simplelabentry/decliningCD4Report";
    }
    
    
    /**
     * Render the lab report.
     * 
     * @param action
     * @param locationId
     * @param startDate
     * @param endDate
     * @param conceptIds
     * @param renderType
     * @param response
     */
    @RequestMapping("/module/simplelabentry/RunAndRenderDecliningCD4Report")
    public void runAndRenderLabReport(
            @RequestParam(required=false, value="locationId") Integer locationId,
            @RequestParam(required=false, value="inline") Boolean inline,
            HttpServletResponse response) {
            Location location = null;
        try {   
            if (locationId != null && !locationId.equals(0))
                location = Context.getLocationService().getLocation(locationId);
            
            SimpleLabEntryService service = (SimpleLabEntryService)
                Context.getService(SimpleLabEntryService.class);
            
            // Populate parameters
            File reportFile = 
                service.runAndRenderCD4Report(location);
                            
            
            response.setContentType("application/vnd.ms-excel");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + reportFile.getName() + "\"");            

            OpenmrsUtil.copyFile(new FileInputStream(reportFile), response.getOutputStream());

        } catch (IOException e) { 
            log.error("Unable to run and render CD4 report.");
            e.printStackTrace(System.out);
        }       
    } 
    
    
}
