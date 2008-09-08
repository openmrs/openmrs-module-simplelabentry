package org.openmrs.module.simplelabentry;

import java.util.Date;
import java.util.List;

import org.openmrs.Concept;
import org.openmrs.Location;
import org.openmrs.Order;
import org.openmrs.Patient;
import org.openmrs.annotation.Authorized;
import org.openmrs.api.OrderService.ORDER_STATUS;
import org.openmrs.util.OpenmrsConstants;
import org.springframework.transaction.annotation.Transactional;

@Transactional
public interface SimpleLabEntryService {
	
	/**
	 * This searches for Orders given the parameters.
	 * 
	 * Most arguments are optional (nullable).  If multiple arguments
	 * are given, the returned orders will match on all arguments. 
	 * 
	 * @param concept The concept in order.getConcept to get orders for
	 * @param location The Location of the encounter that the orders are assigned to
	 * @param orderDate The startDate of the Order
	 * @param status The ORDER_STATUS of the orders for its patient
	 * @param patients The List of Patients to get orders for
	 * @return list of Orders matching the parameters
	 */
	@Authorized(OpenmrsConstants.PRIV_VIEW_ORDERS)
	public List<Order> getLabOrders(Concept concept, Location location, Date orderDate, ORDER_STATUS status, List<Patient> patients);
	
	/**
	 * This returns a List of all of the Concepts that have been configured 
	 * in the global properties file as supported tests.
	 * 
	 * 
	 * @return list of Concepts representing those
	 */
	@Authorized(OpenmrsConstants.PRIV_VIEW_CONCEPTS)
	public List<Concept> getLabTestConcepts();
}