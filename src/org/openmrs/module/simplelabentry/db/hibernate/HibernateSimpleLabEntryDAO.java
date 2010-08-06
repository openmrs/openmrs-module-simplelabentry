package org.openmrs.module.simplelabentry.db.hibernate;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Query;
import org.hibernate.SessionFactory;
import org.openmrs.Concept;
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
    
}
