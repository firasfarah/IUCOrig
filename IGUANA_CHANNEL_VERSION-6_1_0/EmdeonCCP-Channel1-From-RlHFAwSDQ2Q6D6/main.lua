-- The main function is the first function called from Iguana.
local ccpAuth = require('ccpAuth')
local emdAuth = require('emdeonAuth')

function main()
   local timeBack = 60 -- Controls how far back the API pulls (in seconds)
   
   -- (1) Authenticate with CCP 
   local urnAddress,header = ccpAuth.prepHeader()
   
   -- (2) Obtain the Emdeon Credentials and facility information
   local emdUrl,emdUser,emdPasswd,facility = emdAuth.getEmdeonCredentials(urnAddress,header)
   
   -- (3) First call to Emdeon to retrieve list of reports
   local xmlReports = emdAuth.getReportList(emdUrl,emdUser,emdPasswd,facility,timeBack) 
   
   for k = 1,#xmlReports do
      -- (4) Download each report in the list
      local downloadedReport = emdAuth.getEachReport(emdUrl,emdUser,emdPasswd,facility,xmlReports[k])
      
      -- (5) Push to queue the json containing reportId, html, and HL7
      queue.push{data = downloadedReport}
    
   end
   
end

