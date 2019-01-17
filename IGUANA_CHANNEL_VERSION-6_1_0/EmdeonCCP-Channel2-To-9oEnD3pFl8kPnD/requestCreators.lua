local soapTemplates = require('soapTemplates')
local utils         = require('utils')

local soapRequests = {}

---------------------------------------------------------------------------------------
------------------------------------- Orders ------------------------------------------
---------------------------------------------------------------------------------------

function soapRequests.getOrderIdSoap(header,orderNumber) 
   local template = soapTemplates.fetchOrderId
   local orderIdSoap = soapRequests.createFetchXML(header,template:gsub('repordernumber',orderNumber))
   return orderIdSoap
end

function soapRequests.createOrderRequestSoap(header,inputs) 

   local request = soapTemplates.createStart

   for k,v in pairs(inputs) do 
      if v ~= nil and v~= '' then
         if type(v) == 'table' then
            if v[1] == 're' then 
               if v[3] ~= nil then
                  request = request..soapRequests.addRelAttribute(k,v[2],v[3])
               end
            elseif v[1] == 'option' then 
               request = request..soapRequests.addOptionSetValue(k,v[2])
            else request = request..soapRequests.addAttribute(v[1],k,v[2]) end
         else
            request = request..soapRequests.addAttribute('string',k,v)
         end
      end
   end
   
   local orderId = utils.guid()
   local reqEnd = soapTemplates.createEnd:gsub('repActivityId',orderId):gsub('ccx_labresults','ccx_clientorders')
   request = request..reqEnd
   trace(request)     
   local xmlBegin = "<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\">"
   local fullRequest = xmlBegin .. header .. request .. "</s:Envelope>"
   return fullRequest,orderId
   
end

function soapRequests.updateOrderRequestSoap(header,inputs,activityId) 

   local request = soapTemplates.createStart:gsub('Create','Update')

   for k,v in pairs(inputs) do 
      if v ~= nil and v~= '' then
         if type(v) == 'table' then
            if v[1] == 're' then 
               if v[3] ~= nil then
                  request = request..soapRequests.addRelAttribute(k,v[2],v[3])
               end
            elseif v[1] == 'option' then 
               request = request..soapRequests.addOptionSetValue(k,v[2])
            else request = request..soapRequests.addAttribute(v[1],k,v[2]) end
         else
            request = request..soapRequests.addAttribute('string',k,v)
         end
      end
   end
   
   local orderId = activityId
   local reqEnd = soapTemplates.createEnd:gsub('repActivityId',orderId):gsub('ccx_labresults','ccx_clientorders'):gsub('Create','Update')
   request = request..reqEnd
   trace(request)     
   local xmlBegin = "<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\">"
   local fullRequest = xmlBegin .. header .. request .. "</s:Envelope>"
   return fullRequest,orderId
  
end

---------------------------------------------------------------------------------------
------------------------------------- Results -----------------------------------------
---------------------------------------------------------------------------------------

function soapRequests.createResultSoapRequest(header,inputs) 

   local request = soapTemplates.createStart

   for k,v in pairs(inputs) do 
      if v ~= nil and v~= '' then
         if type(v) == 'table' then
            if v[1] == 're' then 
               if v[3] ~= nil then
                  request = request..soapRequests.addRelAttribute(k,v[2],v[3])
               end
            elseif v[1] == 'option' then 
               request = request..soapRequests.addOptionSetValue(k,v[2])
            else request = request..soapRequests.addAttribute(v[1],k,v[2]) end
         else
            request = request..soapRequests.addAttribute('string',k,v)
         end
      end
   end
   
   local resultId = utils.guid()
   local reqEnd  = soapTemplates.createEnd:gsub('repActivityId',resultId)
   request = request..reqEnd
   trace(request)     
   local xmlBegin = "<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\">"
   local fullRequest = xmlBegin .. header .. request .. "</s:Envelope>"
   return fullRequest,resultId
  
end

function soapRequests.updateResultSoapRequest(header,inputs,activityId) 

   local request = soapTemplates.createStart:gsub('Create','Update')

   for k,v in pairs(inputs) do 
      if v ~= nil and v~= '' then
         if type(v) == 'table' then
            if v[1] == 're' then 
               if v[3] ~= nil then
                  request = request..soapRequests.addRelAttribute(k,v[2],v[3])
               end
            elseif v[1] == 'option' then 
               request = request..soapRequests.addOptionSetValue(k,v[2])
            else request = request..soapRequests.addAttribute(v[1],k,v[2]) end
         else
            request = request..soapRequests.addAttribute('string',k,v)
         end
      end
   end
   
   local resultId = activityId
   local reqEnd  = soapTemplates.createEnd:gsub('repActivityId',resultId):gsub('Create','Update')
   request = request..reqEnd
   trace(request)     
   local xmlBegin = "<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\">"
   local fullRequest = xmlBegin .. header .. request .. "</s:Envelope>"
   return fullRequest,resultId
  
end

function soapRequests.getResultIdbyPatientDescId(header,contactId,labdesc,orderId) 
   local template = ''
   
   if contactId == nil or contactId == '' then 
      contactId = ''
      template = soapTemplates.fetchResultsIdNoContact
   else
      template = soapTemplates.fetchResultsId
   end
   
   local contactIdSoap = soapRequests.createFetchXML(header,template:gsub('repcontactid',contactId):gsub('replabdesc',labdesc):gsub('repccxorderid',orderId))
   
   return contactIdSoap
end

---------------------------------------------------------------------------------------
------------------------------ Result Values ------------------------------------------
---------------------------------------------------------------------------------------
function soapRequests.getResultValueId(header,ccxCode,resultId,setId) 
   local template = soapTemplates.fetchResultValuesId
   
   local resultValueIdSoap = soapRequests.createFetchXML(header,template:gsub('represultdescr',ccxCode):gsub('replabresultId',resultId):gsub('repsetId',setId))
   
   return resultValueIdSoap
end

function soapRequests.createResultValuesRequestSoap(header,inputs) 

   local request = soapTemplates.createStart

   for k,v in pairs(inputs) do 
      if v ~= nil and v~= '' then
         if type(v) == 'table' then
            if v[1] == 're' then 
               if v[3] ~= nil then
                  request = request..soapRequests.addRelAttribute(k,v[2],v[3])
               end
            elseif v[1] == 'option' then 
               request = request..soapRequests.addOptionSetValue(k,v[2])
            else request = request..soapRequests.addAttribute(v[1],k,v[2]) end
         else
            request = request..soapRequests.addAttribute('string',k,v)
         end
      end
   end
   
   local rvId = utils.guid()
   local reqEnd = soapTemplates.createEnd:gsub('repActivityId',rvId):gsub('ccx_labresults','ccx_resultvalue')
   request = request..reqEnd
   trace(request)     
   local xmlBegin = "<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\">"
   local fullRequest = xmlBegin .. header .. request .. "</s:Envelope>"
   return fullRequest,orderId
   
end

function soapRequests.updateResultValuesRequestSoap(header,inputs,activityId) 

   local request = soapTemplates.createStart:gsub('Create','Update')

   for k,v in pairs(inputs) do 
      if v ~= nil and v~= '' then
         if type(v) == 'table' then
            if v[1] == 're' then 
               if v[3] ~= nil then
                  request = request..soapRequests.addRelAttribute(k,v[2],v[3])
               end
            elseif v[1] == 'option' then 
               request = request..soapRequests.addOptionSetValue(k,v[2])
            else request = request..soapRequests.addAttribute(v[1],k,v[2]) end
         else
            request = request..soapRequests.addAttribute('string',k,v)
         end
      end
   end
   
   local rvId = activityId
   local reqEnd = soapTemplates.createEnd:gsub('repActivityId',rvId):gsub('ccx_labresults','ccx_resultvalue'):gsub('Create','Update')
   request = request..reqEnd
   trace(request)     
   local xmlBegin = "<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\">"
   local fullRequest = xmlBegin .. header .. request .. "</s:Envelope>"
   return fullRequest,orderId
   
end

function soapRequests.createResultValuesComments(header,inputs) 

   local request = soapTemplates.createStart

   for k,v in pairs(inputs) do 
      if v ~= nil and v~= '' then
         if type(v) == 'table' then
            if v[1] == 're' then 
               if v[3] ~= nil then
                  request = request..soapRequests.addRelAttribute(k,v[2],v[3])
               end
            elseif v[1] == 'option' then 
               request = request..soapRequests.addOptionSetValue(k,v[2])
            else request = request..soapRequests.addAttribute(v[1],k,v[2]) end
         else
            request = request..soapRequests.addAttribute('string',k,v)
         end
      end
   end

   local commentId = utils.guid()
   local reqEnd = soapTemplates.createEnd:gsub('repActivityId',commentId):gsub('ccx_labresults','ccx_comment')
   request = request..reqEnd
   trace(request)     
   local xmlBegin = "<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\">"
   local fullRequest = xmlBegin .. header .. request .. "</s:Envelope>"
   return fullRequest,orderId

end

function soapRequests.createAnnotationPdf(header,inputs) 
   local request = soapTemplates.createStart
   trace(request)
   for k,v in pairs(inputs) do 
      if v ~= nil and v~= '' then
         if type(v) == 'table' then
            if v[1] == 're' then 
               if v[3] ~= nil then
                  request = request..soapRequests.addRelAttribute(k,v[2],v[3])
               end
            elseif v[1] == 'option' then 
               request = request..soapRequests.addOptionSetValue(k,v[2])
            else request = request..soapRequests.addAttribute(v[1],k,v[2]) end
         else
            request = request..soapRequests.addAttribute('string',k,v)
         end
      end
      trace(request)
   end
	trace(request)
   local annotationId = utils.guid()
   local reqEnd = soapTemplates.createEnd:gsub('repActivityId',annotationId):gsub('ccx_labresults','annotation')
   request = request..reqEnd
   trace(request)     
   local xmlBegin = "<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\">"
   local fullRequest = xmlBegin .. header .. request .. "</s:Envelope>"
   trace(fullRequest)
   return fullRequest
end
	
---------------------------------------------------------------------------------------
------------------------------------- General -----------------------------------------
---------------------------------------------------------------------------------------
function soapRequests.getProviderIdSoap(header,providerNPI) 
   local template =  soapTemplates.fetchProviderId
 
   local providerIdSoap = soapRequests.createFetchXML(header,template:gsub('repLabProvider',providerNPI))
   
   return providerIdSoap
end

function soapRequests.contactIdbyPatientId(header,patientId) 
   local template = soapTemplates.contactByPatientId 
   
   local contactIdSoap = soapRequests.createFetchXML(header,template:gsub('repPatientId',patientId))
   
   return contactIdSoap
end

function soapRequests.contactIdbyOrderNumber(header,orderNumber) 
   local template = soapTemplates.contactByOrderNumber
 
   local contactIdSoap = soapRequests.createFetchXML(header,template:gsub('repOrderNumber',orderNumber))
 
   return contactIdSoap
end

function soapRequests.getcontactIdbySSN(header,ssn) 
   
   local template = soapTemplates.contactBySSN
   
   local contactIdSoap = soapRequests.createFetchXML(header,template:gsub('repSSN',ssn))
   
   return contactIdSoap

end

function soapRequests.getcontactIdbyNameDOB(header,firstname,lastname,birthdate) 
  
   local template = soapTemplates.contactByNameDOB
   
   local contactIdSoap = soapRequests.createFetchXML(header,template:gsub('repfirstname',firstname):gsub('replastname',lastname):gsub('repbirthdate',birthdate))
   
   return contactIdSoap

end

function soapRequests.createFetchXML(header,fetchBody) 

   local formatFetch = fetchBody:gsub('<','&lt;'):gsub('>','&gt;')
   
   local fetchXml = "<s:Body>"..
   "    <Execute xmlns=\"http://schemas.microsoft.com/xrm/2011/Contracts/Services\" xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\">"..
   "      <request i:type=\"a:RetrieveMultipleRequest\" xmlns:a=\"http://schemas.microsoft.com/xrm/2011/Contracts\">"..
   "        <a:Parameters xmlns:b=\"http://schemas.datacontract.org/2004/07/System.Collections.Generic\">"..
   "          <a:KeyValuePairOfstringanyType>"..
   "            <b:key>Query</b:key>"..
   "            <b:value i:type=\"a:FetchExpression\">"..
   "              <a:Query>"..formatFetch..
   "              </a:Query>"..
   "            </b:value>"..
   "          </a:KeyValuePairOfstringanyType>"..
   "        </a:Parameters>"..
   "        <a:RequestId i:nil=\"true\" />"..
   "        <a:RequestName>RetrieveMultiple</a:RequestName>"..
   "      </request>"..
   "    </Execute>"..
   "  </s:Body>"
   
   local xmlBegin = "<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\">"
   
   local fullRequest = xmlBegin .. header .. fetchXml .. "</s:Envelope>"
   
   return fullRequest
   
end

function soapRequests.addAttribute(typ,attributeName,attributeValue)
   local att = ''
   if typ == 'string' then 
      att = soapTemplates.attributeTemplate:gsub('attributeName',attributeName):gsub('attributeValue',attributeValue)
   else
      att = soapTemplates.attributeTemplate:gsub('attributeName',attributeName):gsub('attributeValue',attributeValue):gsub('c:string','c:'..typ)
   end
   return att
end

function soapRequests.addRelAttribute(attributeName,destEntity,value) 
   return soapTemplates.relatedAttributeTemplate:gsub('attributeName',attributeName):gsub('destEntity',destEntity):gsub('attributeValue',value)
end

function soapRequests.addOptionSetValue(attributeName,attributeCode)
   return soapTemplates.optionSetValueTemplate:gsub('attributeName',attributeName):gsub('attributeCodeValue',attributeCode)
end

function soapRequests.getEmdeonSettings(header) 
   
   local template = soapTemplates.fetchEmdeonSettings
   
   local contactIdSoap = soapRequests.createFetchXML(header,template)
   
   return contactIdSoap

end

return soapRequests