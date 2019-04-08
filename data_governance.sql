SELECT DISTINCT
	   sla.SalesLeadId, 
       li.CompanyName,
	   li.CommercialOwner,
	   li.Project,
	   sl.active_current,
	   sla.AuditDate,
	   DATEDIFF(DAY, sla.AuditDate, GETDATE()) AS days_audit,
	   probs.ProbAuditDate,
	   probs.days_prob,
	   sln.CreateDate LastNoteCreatedDate,
	   sln.days_note,
	   commStage.AuditDate LastCommStageAudit,
	   commStage.days_commercial
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
LEFT JOIN
(SELECT SalesLeadId, 
		CreateDate, 
		DATEDIFF(DAY, CreateDate, GETDATE()) AS days_note
FROM crm.SalesLeadNote sln
WHERE CreateDate = (SELECT MAX(sln1.CreateDate) 
					FROM crm.SalesLeadNote sln1 
					WHERE sln1.SalesLeadId = sln.SalesLeadId)) sln
ON sln.SalesLeadId = sla.SalesLeadId
LEFT JOIN
(SELECT slcsa.SalesLeadId, 
		slcsa.AuditDate, 
		DATEDIFF(DAY, AuditDate, GETDATE()) AS days_commercial,
		IsDone
FROM crm.SalesLeadCommercialStageAudit slcsa
WHERE AuditDate = (SELECT MAX(slcsa1.AuditDate) 
				   FROM crm.SalesLeadCommercialStageAudit slcsa1 
				   WHERE slcsa1.SalesLeadId = slcsa.SalesLeadId) AND
IsDone = 1) commStage
ON commStage.SalesLeadId = sla.SalesLeadId
LEFT JOIN
(SELECT SalesLeadId, 
	   AuditDate ProbAuditDate,
	   DATEDIFF(DAY, AuditDate, GETDATE()) AS days_prob
FROM crm.SalesLeadProbabilityAnswerAudit slpa
WHERE AuditDate = (SELECT MAX(slpa1.AuditDate) 
				   FROM crm.SalesLeadProbabilityAnswerAudit slpa1
				   WHERE slpa1.SalesLeadId = slpa.SalesLeadId)) probs
ON probs.SalesLeadId = sla.SalesLeadId
WHERE DATEDIFF(DAY, probs.ProbAuditDate, GETDATE()) >= 30 AND
sla.AuditDate = (SELECT MAX(sla1.AuditDate) 
             FROM crm.SalesLeadAudit sla1 
			 WHERE sla1.SalesLeadId = sla.SalesLeadId) AND
sl.active_current = 1 AND
sl.deleted_current = 0
ORDER BY sla.AuditDate DESC,
         days_audit DESC
GO