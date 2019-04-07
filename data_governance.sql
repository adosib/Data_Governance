SELECT sla.SalesLeadId, 
	   sla.AuditDate,
	   DATEDIFF(DAY, AuditDate, GETDATE()) AS days_since_audit,
	   sl.active_current,
	   li.CompanyName,
	   li.Project,
	   li.CommercialOwner,
	   SUBSTRING(li.NameFirst, 1, 1) + li.NameLast + '@epicsysinc.com' AS email
FROM crm.SalesLeadAudit sla
LEFT JOIN
(SELECT IsActive AS active_current, 
		IsDeleted AS deleted_current,
	    SalesLeadId
FROM crm.SalesLead) sl
ON sl.SalesLeadId = sla.SalesLeadId
LEFT JOIN
(SELECT SalesLeadId,
	    CompanyName,
	    Project,
		NameFirst,
		NameLast,
	    NameFirst+' '+NameLast AS CommercialOwner
FROM [mkt.Leadinfo]) li
ON li.SalesLeadId = sla.SalesLeadId
WHERE DATEDIFF(DAY, AuditDate, GETDATE()) >= 30 AND
AuditDate = (SELECT MAX(sla1.AuditDate) 
             FROM crm.SalesLeadAudit sla1 
			 WHERE sla1.SalesLeadId = sla.SalesLeadId) AND
sl.active_current = 1 AND
sl.deleted_current = 0
ORDER BY sla.AuditDate DESC,
         days_since_audit DESC
GO