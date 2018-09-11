local csvUtil = {}

local csvPath = 'C:\\TempFolder\\CSV\\'
local csvName = 'PatientData.txt'

function csvUtil.updateFile(jsonTbl) 
   local entry = '\n'..jsonTbl.patientId..','..jsonTbl.firstName..','..jsonTbl.lastName..
                 ','..jsonTbl.sex..','..jsonTbl.ssn..','..jsonTbl.dob
                 
   local fHandle = io.open(csvPath..csvName,'a')
   fHandle:write(entry)
   fHandle:close()
end

return csvUtil