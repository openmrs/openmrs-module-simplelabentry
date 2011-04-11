package org.openmrs.module.simplelabentry.db.hibernate;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Query;
import org.hibernate.SQLQuery;
import org.hibernate.SessionFactory;
import org.openmrs.Concept;
import org.openmrs.Encounter;
import org.openmrs.EncounterType;
import org.openmrs.Location;
import org.openmrs.Order;
import org.openmrs.OrderType;
import org.openmrs.Patient;
import org.openmrs.module.simplelabentry.db.SimpleLabEntryDAO;

public class HibernateSimpleLabEntryDAO implements SimpleLabEntryDAO {

protected static final Log log = LogFactory.getLog(HibernateSimpleLabEntryDAO.class);
    
    /**
     * Hibernate session factory
     */
    private SessionFactory sessionFactory;
    
    
    public void setSessionFactory(SessionFactory sessionFactory) { 
        this.sessionFactory = sessionFactory;
    }
    
    
    @SuppressWarnings("unchecked")
    public List<Order> getOrders(List<Concept> concepts, OrderType orderType, List<Patient> patientList, Location location, Date orderStartDate) {
        String hql = "from Order as o where o.voided = 0 and ";
        
        if (concepts != null && concepts.size() > 0){
            hql += " o.concept in (:conceptIds) ";
            if (orderType != null || (patientList != null && patientList.size() > 0) || location != null || orderStartDate != null)
                hql += " and ";
        }
        if (orderType != null){
            hql += " o.orderType = :orderType  ";
            if ((patientList != null && patientList.size() > 0) || location != null || orderStartDate != null)
                hql += " and ";
        }
        if (patientList != null && patientList.size() > 0){
            hql += " o.patient in (:patientIds)";
            if (location != null || orderStartDate != null)
                hql += " and ";
        }    
        if (location != null){
            hql += " o.encounter.location = :location";
            if (orderStartDate != null)
                hql += " and ";
        }
        if (orderStartDate != null){
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            hql += " ((o.startDate is null and o.encounter.encounterDatetime = '" +sdf.format(orderStartDate)+ "') OR (    o.startDate is not null and  o.startDate =   '" +sdf.format(orderStartDate)+ "'     )  )";
        }
        
        hql += " order by o.startDate desc";
        
        Query query = sessionFactory.getCurrentSession().createQuery(hql);
        if (concepts != null && concepts.size() > 0){
            query.setParameterList("conceptIds", concepts);
        }    
        if (orderType != null)
            query.setParameter("orderType", orderType);
        if (patientList != null && patientList.size() > 0){
            query.setParameterList("patientIds", patientList);
        }
        if (location != null)
            query.setParameter("location", location);
        
        return (List<Order>) query.list();
    }
    
    
    @SuppressWarnings("unchecked")
    public List<Encounter> getEncountersWithNonNullResult(List<Concept> concepts, EncounterType encounterType, Location location, Date encounterStartDate, Date encounterEndDate) {
        
        String hql = "SELECT e.* from encounter as e, obs as o, person as p where o.voided = 0 and e.voided = 0 and e.encounter_id = o.encounter_id and (o.value_numeric is not null OR o.value_text is not null OR o.value_coded is not null) and e.patient_id = p.person_id and p.voided = 0 and p.dead = 0 and  ";
        
        
        if (concepts != null && concepts.size() > 0){
            hql += " o.concept_id in (:conceptIds) ";
            if ( encounterType != null || location != null || encounterStartDate != null  || encounterEndDate != null)
                hql += " and ";
        }
        if (encounterType != null){
            hql += " e.encounter_type = :encounterType  ";
            if ( location != null || encounterStartDate != null  || encounterEndDate != null)
                hql += " and ";
        }

        if (location != null){
            hql += " e.location_id = :location";
            if (encounterStartDate != null  || encounterEndDate != null)
                hql += " and ";
        }
        if (encounterStartDate != null){
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            hql += " e.encounter_datetime >= '"+sdf.format(encounterStartDate)+"' ";
            if ( encounterEndDate != null)
                hql += " and ";
        }
        
        if (encounterEndDate != null){
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            hql += " e.encounter_datetime <= '"+sdf.format(encounterEndDate)+"' ";
        }
        
        hql += " order by e.encounter_datetime desc";
        
        SQLQuery query = sessionFactory.getCurrentSession().createSQLQuery(hql).addEntity(Encounter.class);
        
        if (concepts != null && concepts.size() > 0){
            query.setParameterList("conceptIds", concepts);
        }    
        if (encounterType != null)
            query.setParameter("encounterType", encounterType.getEncounterTypeId());
        if (location != null)
            query.setParameter("location", location.getLocationId());
        
        return (List<Encounter>) query.list();
    }
    
}
