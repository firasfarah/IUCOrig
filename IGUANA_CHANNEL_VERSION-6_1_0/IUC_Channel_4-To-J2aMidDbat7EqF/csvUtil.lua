local iucConf = require('IUCConfigs')
local csvUtil = {}

function csvUtil.updateFile(jsonTbl) 
   local entry = '\n'..jsonTbl.patientId..','..jsonTbl.firstName..','..jsonTbl.lastName..
                 ','..jsonTbl.sex..','..jsonTbl.ssn..','..jsonTbl.dob
                 
   local fHandle = io.open(iucConf.patientCsvPath..iucConf.patientCsvFile,'a')
   fHandle:write(entry)
   fHandle:close()
end

return csvUtil