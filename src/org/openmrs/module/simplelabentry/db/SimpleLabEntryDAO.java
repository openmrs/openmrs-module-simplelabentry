package org.openmrs.module.simplelabentry.db;

import java.util.Date;
import java.util.List;

import org.openmrs.Concept;
import org.openmrs.Encounter;
import org.openmrs.EncounterType;
import org.openmrs.Location;
import org.openmrs.Order;
import org.openmrs.OrderType;
import org.openmrs.Patient;
import org.openmrs.api.db.DAOException;

public interface SimpleLabEntryDAO {
    
    public List<Order> getOrders(List<Concept> concepts, OrderType orderType, List<Patient> patientList, Location location, Date orderStartDate) throws DAOException;
    public List<Encounter> getEncountersWithNonNullResult(List<Concept> concepts, EncounterType encounterType, Location location, Date encounterStartDate, Date encounterEndDate);
}
