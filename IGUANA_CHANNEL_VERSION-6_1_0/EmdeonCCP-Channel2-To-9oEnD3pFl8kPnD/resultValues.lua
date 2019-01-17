-- This module deals with the processing of the ccx_resultvalues entity
local requests = require('requestCreators')
local retry    = require('retry')

local resultValues = {}

-- Description: This function deals with the high level processing of
--                the ccx_resultvalues entity. It loops through the OBX 
--                segment, queries for an associated resultvalues entity,
--                and if it does not find it, then it creates it. Otherwise
--                it updates it. It also creates a ccx_comments and a 
--                pdf annotation entity (if there is a PDF)
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - globs: The global variables table
--         - resultId: The associated lab result
-- Return(s):
--         - resulValuesId: the resultValues entity Id
function resultValues.processResultValues(urn,header,globs,resultId) 
   local resultValuesId = {}

   for k=1,#globs.resultValues do
      -- (1) Query for result values
      -- Note this is not a unique query (ie. could return multiple result values)
      local activityId = resultValues.queryResultValues(urn,header,resultId,globs.resultValues[k])
    
      if activityId == nil then 
         -- (2a) if result value does not exist, create
         activityId = resultValues.createResultValues(urn,header,resultId,globs.resultValues[k])
      else 
         -- (2b) if result value does exist update it, 
         resultValues.updateResultValues(urn,header,resultId,globs.resultValues[k],activityId)
      end
      
      resultValues.createComment(urn,header,activityId,globs,k) -- Create a ccx_comment entity
      resultValuesId[k] = activityId
      
   end
   -- Create an annotation entity if there is a PDF
   if globs.pdf ~= nil then resultValues.createPdfAnnotation(urn,header,resultId,globs.pdf) end
   
   return resultValuesId
end

-- Description: This function is responsible for creating an annotation
--                entity for a PDF
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - resultId: The activity Id of the associated lab result 
--         - inputs: The attribute table for the PDF (includes the PDF body)
-- Return(s): NONE
function resultValues.createPdfAnnotation(urn,header,resultId,inputs) 
   inputs['objectid'] = {'re','ccx_labresults',resultId}
   trace(inputs)
   local annotationCreateRequest = requests.createAnnotationPdf(header,inputs) 
   
   
   local createAnnResponse,createAnnCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = annotationCreateRequest,
      timeout=100,
      live=true},pause=30,retry=3}
 
   if createAnnCode ~= 200 then
      error('ResultValues annotation associated with ResultId '..resultId..
         ' was unsuccessful.\nResponse Code: '..createAnnCode..'\n'..
         'Server Response:\n'..createAnnResponse)
   end
end

-- Description: This function is responsible for creating a ccx_comments
--                entity 
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - resultValuesId: The activity Id of the associated resultValue
--         - globs: The global variables table
--         - setId: The set Id of the OBX segment 
-- Return(s): NONE
function resultValues.createComment(urn,header,resultValuesId,globs,setId) 
   local inputs = {}
   inputs['ccx_result']   = {'re','ccx_resultvalue',resultValuesId}
   inputs['ccx_comment'] = globs['orders']['ccx_specialinstruction'] -- Since both from NTE
   inputs['ccx_setid'] = {'int',setId}
   
   local commentCreateRequest = requests.createResultValuesComments(header,inputs) 
      local createComResponse,createComCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = commentCreateRequest,
      timeout=100,
      live=true},retry=3,pause=30}
 
   if createComCode ~= 200 then
      error('ResultValues comment associated with ResultValuesId '..resultValuesId..
         ' was unsuccessful.\nResponse Code: '..createComCode..'\n'..
         'Server Response:\n'..createComResponse)
   end
end

-- Description: This function is responsible for querying for the resultValue               
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - globs: The global variables table
--         - resultId: The result Id of the associated lab result
-- Return(s):
--         - activityId: The activity Id of the resultValue, if found
--         - nil, if not found
function resultValues.queryResultValues(urn,header,resultId,globs)
   
   local fetchRVIdRequest = requests.getResultValueId(header,globs.ccx_code,resultId,globs.ccx_setid[2])
   local fetchRVIdResponse,fetchRVIdCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = fetchRVIdRequest,
      timeout=100,
      live=true},retry=3,pause=30}
   
   if fetchRVIdCode == 200 then
      local listResultValues = xml.parse{data = fetchRVIdResponse}

      local entity = listResultValues["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult["b:Results"]
      ["b:KeyValuePairOfstringanyType"]["c:value"]["b:Entities"]

      local activityId = ''

      if entity["b:Entity"] ~= nil then 
         activityId = entity:child("b:Entity",1)["b:Attributes"]
         ["b:KeyValuePairOfstringanyType"]["c:value"]:nodeText()
      else activityId = nil 
      end

      return activityId
   else
      error('ResultValues query associated with ResultId '..resultId..
         ' was unsuccessful.\nResponse Code: '..fetchRVIdCode..'\n'..
         'Server Response:\n'..fetchRVIdResponse)
   end
end

-- Description: This function is responsible for creating a result value
-- Parameter(s):
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - globs: The global variables table
--         - resultId: The result Id of the associated lab result
-- Return(s):
--         - activityId: The activity Id of the resultValue
function resultValues.createResultValues(urn,header,resultId,globs) 
   globs['ccx_labresult'] = {'re','ccx_labresults',resultId}
   local createRVRequest = requests.createResultValuesRequestSoap(header,globs) 
   local createRVResponse,createRVCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = createRVRequest,
      timeout=100,
      live=true},retry=3,pause=30}
 
   if createRVCode == 200 then
      local createRVResponse = xml.parse{data=createRVResponse}
      local activityId = createRVResponse["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult
      ["b:Results"]["b:KeyValuePairOfstringanyType"]["c:value"]:nodeText()

      return activityId
   else
      error('ResultValues create associated with ResultId '..resultId..
         ' was unsuccessful.\nResponse Code: '..createRVCode..'\n'..
         'Server Response:\n'..createRVResponse)
   end
 
end

-- Description: This function is responsible for updating a result value
-- Parameter(s):
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - globs: The global variables table
--         - resultId: The result Id of the associated lab result
--         - activityId: The activity Id of the result value to be updated
-- Return(s): NONE
function resultValues.updateResultValues(urn,header,resultId,globs,activityId)
   globs['ccx_labresult'] = {'re','ccx_labresults',resultId}
   local updateRVRequest = requests.updateResultValuesRequestSoap(header,globs,activityId) 
   local updateRVResponse,updateRVCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = updateRVRequest,
      timeout=100,
      live=true},retry=3,pause=30}
    
   if updateRVCode ~= 200 then
      error('ResultValues update associated with ResultId '..resultId..
         ' was unsuccessful.\nResponse Code: '..updateRVCode..'\n'..
         'Server Response:\n'..updateRVResponse)
   end
   
end

return resultValues