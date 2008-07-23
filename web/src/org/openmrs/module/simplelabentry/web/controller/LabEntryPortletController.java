package org.openmrs.module.simplelabentry.web.controller;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.Date;
import java.util.TreeMap;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Encounter;
import org.openmrs.Order;
import org.openmrs.api.context.Context;
import org.openmrs.web.controller.PortletController;

public class LabEntryPortletController extends PortletController {
	
	protected final Log log = LogFactory.getLog(getClass());

	@SuppressWarnings("unchecked")
	protected void populateModel(HttpServletRequest request, Map model) {

		Map<Date, Order> labOrders = new TreeMap<Date, Order>();
		
		// Parse parameters
		Integer patientId = (Integer) model.get("patientId");
		String orderLocationId = (String)model.get("orderLocation");
		String orderSetConceptId = (String)model.get("orderConcept");
		String orderDateStr = (String)model.get("orderDate");
		boolean showOpen = !"closed".equals(model.get("limit"));
		boolean showClosed = !"open".equals(model.get("limit"));

		// Retrieve global properties
		String orderTypeId = Context.getAdministrationService().getGlobalProperty("simplelabentry.labOrderType");
		model.put("orderTypeId", orderTypeId);
		
		log.debug("Retrieving orders for: location="+orderLocationId+",concept="+orderSetConceptId+",date="+orderDateStr+",type="+orderTypeId+",showOpen="+showOpen+",showClosed="+showClosed);
		
		// Retrieve matching orders
		for (Order o : Context.getOrderService().getOrders(Order.class, null, null, null, null, null, null)) {
			Encounter e = o.getEncounter();
			
			if (patientId != null && !patientId.equals(o.getPatient().getPatientId())) {
				continue;  // Order is not for Patient
			}
			if (!o.getOrderType().getOrderTypeId().toString().equals(orderTypeId)) {
				continue; // Order Type Does Not Match
			}
			if (orderSetConceptId != null && !o.getConcept().getConceptId().toString().equals(orderSetConceptId)) {
				continue; // Order Concept Does Not Match
			}
			if (! ( (showOpen && showClosed) || (showOpen && o.isCurrent()) || (showClosed && o.isDiscontinued()) ) ) {
				continue; // Order Current / Discontinued does not Match
			}
			if (orderLocationId != null && (e.getLocation() == null || !e.getLocation().getLocationId().toString().equals(orderLocationId))) {
				continue; // Order Location Does Not Match
			}
			if (orderDateStr != null && (e.getEncounterDatetime() == null || !Context.getDateFormat().format(e.getEncounterDatetime()).equals(orderDateStr))) {
				continue; // Order Date Does Not match
			}
			log.debug("Adding lab order: " + o);
			labOrders.put(e.getDateCreated(), o);
		}
		
		List<Order> labOrderList = new ArrayList<Order>();
		labOrderList.addAll(labOrders.values());
		labOrderList.add(new Order());
		model.put("labOrders", labOrderList);
	}
}
