-- This module deals with the processing of the ccx_labresults entity
local requests = require('requestCreators')
local retry    = require('retry')
local help     = require('generalHelper')

local labResults = {}

-- Description: This function deals with the high level processing of
--                the ccx_labresults entity. It queries for it, and 
--                if it does not find it, then it creates it. Otherwise
--                it updates it.
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - globs: The global variables table
--         - orderId: The activity Id of the related order 
-- Return(s):
--         - activityId: The activity Id of the lab result
function labResults.processResults(urn,header,globs,orderId) 
   
   -- (1) Query for results
   local activityId = labResults.queryResults(urn,header,orderId,globs)
     
   if activityId == nil then 
   -- (2a) if result does not exist, create
       activityId = labResults.createResults(urn,header,orderId,globs)
   else 
   -- (2b) if result does exist update it, 
       labResults.updateResults(urn,header,orderId,globs,activityId)
   end
    
   if activityId == nil or activityId == '' then 
      error('Something went wrong while processing results for ClinicalReportId '
         ..globs['general']['ClinicalReportId'])
   else
      return activityId
   end
   
end

-- Description: This function is responsible for querying for the lab
--                results (ccx_labresults). 
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - globs: The global variables table
--         - orderId: The activity Id of the order
-- Return(s):
--         - activityId: The activity Id of the lab result if found.
--         - nil, if not found
function labResults.queryResults(urn,header,orderId,globs)
 
   local labdesc = globs.results.ccx_code
   local contactId = globs.results.ccx_client[3]
   
   local fetchResultsRequest = requests.getResultIdbyPatientDescId(header,contactId,labdesc,orderId) 

   local fetchResultsResponse,fetchResultsCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = fetchResultsRequest,
      timeout=100,
      live=true},pause=30,retry=3}
   
   if fetchResultsCode == 200 then
      local listResults = xml.parse{data = fetchResultsResponse}

      local entity = listResults["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult["b:Results"]
      ["b:KeyValuePairOfstringanyType"]["c:value"]["b:Entities"]

      local activityId = ''
      if entity["b:Entity"] ~= nil then 
         activityId = entity:child("b:Entity",1)["b:Attributes"]
         ["b:KeyValuePairOfstringanyType"]["c:value"]:nodeText()
      else activityId = nil 
      end

      return activityId
   else 
      error('Results query associated with Clinical Report ID '..globs['general']['ClinicalReportId']..
         ' was unsuccessful.\nResponse Code: '..fetchResultsCode..'\n'..
         'Server Response:\n'..fetchResultsResponse)
   end
end

-- Description: This function is responsible for creating a ccx_labresults
--                  entity with the report information. 
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - globs: The global variables table
--         - orderId: The activity Id of the order
-- Return(s):
--         - activityId: The activity Id of the created lab result
function labResults.createResults(urn,header,orderId,globs)
   globs.results['ccx_order']     = {'re','ccx_clientorders',orderId}
   local hl7Msg = hl7.parse{data = globs.results.ccx_message,vmd='emdeon.vmd'}
   globs.results['ccx_client']    = {'re','contact',help.getContactId(urn,header,hl7Msg,globs)} 
   
   local createResultRequest = requests.createResultSoapRequest(header,globs.results)
   local createResultResponse,createResultCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = createResultRequest,
      timeout=100,
      live=true},retry=3,pause=30}
   
   if createResultCode == 200 then
      local createResultResponse = xml.parse{data=createResultResponse}
      local activityId = createResultResponse["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult
                              ["b:Results"]["b:KeyValuePairOfstringanyType"]["c:value"]:nodeText()

      return activityId
   else 
      error('Results create associated with Clinical Report ID '..globs['general']['ClinicalReportId']..
         ' was unsuccessful.\nResponse Code: '..createResultCode..'\n'..
         'Server Response:\n'..createResultResponse)
   end
end

-- Description: This function is responsible for updating a ccx_labresults
--                  entity with the report information. 
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - globs: The global variables table
--         - activityId: The activity Id of the lab result to be updated
-- Return(s): NONE
function labResults.updateResults(urn,header,orderId,globs,activityId)
   globs.results['ccx_order']     = {'re','ccx_clientorders',orderId}
   local hl7Msg = hl7.parse{data = globs.results.ccx_message,vmd='emdeon.vmd'}
   globs.results['ccx_client']    = {'re','contact',help.getContactId(urn,header,hl7Msg,globs)} 
   local updateResultRequest = requests.updateResultSoapRequest(header,globs.results,activityId)
   local updateResultResponse,updateResultCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = updateResultRequest,
      timeout=100,
      live=true},pause=30,retry=3}
   
   if updateResultCode ~= 200 then
      error('Results update associated with Clinical Report ID '..globs['general']['ClinicalReportId']..
         ' was unsuccessful.\nResponse Code: '..updateResultCode..'\n'..
         'Server Response:\n'..updateResultResponse)
   end
end

return labResults