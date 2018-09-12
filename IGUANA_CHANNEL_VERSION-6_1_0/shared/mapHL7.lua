local mapHL7 = {}

function mapHL7.mapMSH(MSH) 
   MSH[3][1] = 'RAD'
   MSH[4][1] = 'Default'
   MSH[6][1] = 22 -- xmlTree.ProcedureInformation.FacilityId:nodeText()
   MSH[7] = os.date('%Y%m%d%X'):gsub('[ :T-]','')
   MSH[9][1] = 'ADT'
   MSH[10] = util.guid(128)
   MSH[12][1] = '2.7'
end

function mapHL7.mapPID(PID,patientTable)
   PID[5][1][1][1] = patientTable.lastName
   PID[5][1][2] = patientTable.firstName
   PID[2] = patientTable.patientId
   PID[19] = patientTable.ssn
   PID[8][2] = patientTable.sex
   PID[7] = patientTable.dob
end

function mapHL7.mapMsg(Msg,patientTable)
   mapHL7.mapMSH(Msg.MSH)
   mapHL7.mapPID(Msg.PID,patientTable)
end

return mapHL7