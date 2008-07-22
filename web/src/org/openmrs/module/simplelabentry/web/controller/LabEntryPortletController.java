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
import org.springframework.web.bind.ServletRequestUtils;

public class LabEntryPortletController extends PortletController {
	
	protected final Log log = LogFactory.getLog(getClass());

	@SuppressWarnings("unchecked")
	protected void populateModel(HttpServletRequest request, Map model) {

		Map<Date, Order> labOrders = new TreeMap<Date, Order>();
		// Parse request parameters
		Integer orderLocationId = null;
		Integer orderSetConceptId = null;
		String orderDateStr = null;
		try {
			orderLocationId = ServletRequestUtils.getIntParameter(request, "orderLocation");
			orderSetConceptId = ServletRequestUtils.getIntParameter(request, "orderConcept");
			orderDateStr = ServletRequestUtils.getStringParameter(request, "orderDate");
		}
		catch (Exception e) {}

		// Retrieve global properties
		Integer orderTypeId = Integer.valueOf(Context.getAdministrationService().getGlobalProperty("simplelabentry.labOrderType"));
		
		log.debug("Retrieving orders for: location="+orderLocationId+",concept="+orderSetConceptId+",date="+orderDateStr+",type="+orderTypeId);
		
		// Retrieve matching orders
		if (orderLocationId != null && orderSetConceptId != null && orderDateStr != null) {
			for (Order o : Context.getOrderService().getOrders(Order.class, null, null, null, null, null, null)) {
				Encounter e = o.getEncounter();
				if (o.getOrderType().getOrderTypeId().equals(orderTypeId)) {
					log.debug("Found lab order: " + o + " for encounter: " + e);
					if (o.getConcept().getConceptId().equals(orderSetConceptId)) {
						if (e.getLocation() != null && e.getLocation().getLocationId().equals(orderLocationId)) {
							if (e.getEncounterDatetime() != null && Context.getDateFormat().format(e.getEncounterDatetime()).equals(orderDateStr)) {
								log.debug("Adding lab order: " + o);
								labOrders.put(e.getDateCreated(), o);
							}
						}
					}
				}
			}
		}
		
		List<Order> labOrderList = new ArrayList<Order>();
		labOrderList.addAll(labOrders.values());
		labOrderList.add(new Order());
		model.put("labOrders", labOrderList);
	}
}
