-- This module contains functions that assist in creating the SOAP requests
-- to CCP. 
local soapTemplates = require('soapTemplates') -- Raw soap templates for building requests
local utils         = require('utils')

local soapRequests = {}

---------------------------------------------------------------------------------------
------------------------------------- Orders ------------------------------------------
---------------------------------------------------------------------------------------

-- Description: Creates the SOAP for order QUERY
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - orderNumber: the order number
-- Return(s):
--         - orderIdSoap: The SOAP for obtaining the order Id 
function soapRequests.getOrderIdSoap(header,orderNumber) 
   local template = soapTemplates.fetchOrderId
   local orderIdSoap = soapRequests.createFetchXML(header,template:gsub('repordernumber',orderNumber))
   return orderIdSoap
end

-- Description: Creates the SOAP for order (ccx_clientorders) CREATE
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - inputs: A table containing all values used 
--                     for creating the ccx_clientorders entity
-- Return(s):
--         - fullRequest: The SOAP for creating a ccx_clientorders entity
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
   return fullRequest
   
end

-- Description: Creates the SOAP for order (ccx_clientorders) UPDATE
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - inputs: A table containing all values used 
--                     for updating the ccx_clientorders entity
--         - activityId: This will be the activity Id of the order entity
--                         which will be updated
-- Return(s):
--         - fullRequest: The SOAP for updating a ccx_clientorders entity
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
   return fullRequest
end

---------------------------------------------------------------------------------------
------------------------------------- Results -----------------------------------------
---------------------------------------------------------------------------------------

-- Description: Creates the SOAP for lab results (ccx_labresults) CREATE
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - inputs: A table containing all values used 
--                     for creating the ccx_labresults entity
-- Return(s):
--         - fullRequest: The SOAP for creating a ccx_labresults entity
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
   return fullRequest
  
end

-- Description: Creates the SOAP for lab results (ccx_labresults) UPDATE
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - inputs: A table containing all values used 
--                     for updating the ccx_clientorders entity
--         - activityId: This will be the activity Id of the labresults entity
--                         which will be updated
-- Return(s):
--         - fullRequest: The SOAP for updating a ccx_labresults entity
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
   return fullRequest
  
end

-- Description: Creates the SOAP for lab results QUERY
-- Parameter(s): 
--         - header: The header of the SOAP call 
--         - contactId: The activity Id of the contact 
--         - labdesc: OBR[4][1]
--         - orderId: The acitivity Id of the order to which 
--                        this result corresponds
-- Return(s):
--         - resultIdSoap: The SOAP for obtaining the resultId 
function soapRequests.getResultIdbyPatientDescId(header,contactId,labdesc,orderId) 
   local template = ''
   
   if contactId == nil or contactId == '' then 
      contactId = ''
      template = soapTemplates.fetchResultsIdNoContact
   else
      template = soapTemplates.fetchResultsId
   end
   
   local resultIdSoap = soapRequests.createFetchXML(header,template:gsub('repcontactid',contactId):gsub('replabdesc',labdesc):gsub('repccxorderid',orderId))
   
   return resultIdSoap
end

---------------------------------------------------------------------------------------
------------------------------ Result Values ------------------------------------------
---------------------------------------------------------------------------------------

-- Description: Creates the SOAP for result values (ccx_resultvalues) QUERY
-- Parameter(s): 
--         - header: The header of the SOAP call 
--         - ccxCode: OBR[4][1]
--         - resultId: The activity Id of the corresponding ccx_labresults entity
--         - setId: The set Id of the OBX segment 
-- Return(s):
--         - resultValueIdSoap: The SOAP for obtaining the result values activity Id
function soapRequests.getResultValueId(header,ccxCode,resultId,setId) 
   local template = soapTemplates.fetchResultValuesId
   
   local resultValueIdSoap = soapRequests.createFetchXML(header,template:gsub('represultdescr',ccxCode):gsub('replabresultId',resultId):gsub('repsetId',setId))
   
   return resultValueIdSoap
end

-- Description: Creates the SOAP for result values (ccx_resultValues) CREATE
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - inputs: A table containing all values used 
--                     for creating the ccx_resultValues entity
-- Return(s):
--         - fullRequest: The SOAP for creating a ccx_resultValues entity
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
   return fullRequest
   
end

-- Description: Creates the SOAP for result values (ccx_resultvalues) UPDATE
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - inputs: A table containing all values used 
--                     for updating the ccx_resultvalues entity
--         - activityId: The activity Id of the result values entity to be updated
-- Return(s):
--         - fullRequest: The SOAP for updating a ccx_resultvalues entity
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
   return fullRequest
   
end

-- Description: Creates the SOAP for comments (ccx_comment) CREATE
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - inputs: A table containing all values used 
--                     for creating the ccx_comment entity
-- Return(s):
--         - fullRequest: The SOAP for creating a ccx_comment entity
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
   return fullRequest

end

-- Description: Creates the SOAP for pdf annotation (annotation) CREATE
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - inputs: A table containing all values used 
--                     for creating the pdf annotation entity
-- Return(s):
--         - fullRequest: The SOAP for creating an annotation entity
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

-- Description: Creates the SOAP for obtaining the provider Id 
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - providerNPI: The provider NPI
-- Return(s):
--         - fullRequest: The SOAP for obtaining the provider NPI
function soapRequests.getProviderIdSoap(header,providerNPI) 
   local template =  soapTemplates.fetchProviderId
 
   local providerIdSoap = soapRequests.createFetchXML(header,template:gsub('repLabProvider',providerNPI))
   
   return providerIdSoap
end

-- Description: Creates the SOAP for obtaining the contact Id of a patient
--                 based on the patient Id
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - patientId: the patient Id 
-- Return(s):
--         - contactIdSoap: The SOAP for obtaining the patient contact Id
function soapRequests.contactIdbyPatientId(header,patientId) 
   local template = soapTemplates.contactByPatientId 
   
   local contactIdSoap = soapRequests.createFetchXML(header,template:gsub('repPatientId',patientId))
   
   return contactIdSoap
end

-- Description: Creates the SOAP for obtaining the contact Id of a patient
--                 based on the order number
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - orderNumber: the order number
-- Return(s):
--         - contactIdSoap: The SOAP for obtaining the patient contact Id
function soapRequests.contactIdbyOrderNumber(header,orderNumber) 
   local template = soapTemplates.contactByOrderNumber
 
   local contactIdSoap = soapRequests.createFetchXML(header,template:gsub('repOrderNumber',orderNumber))
 
   return contactIdSoap
end

-- Description: Creates the SOAP for obtaining the contact Id of a patient
--                 based on the SSN
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - ssn: patient SSN
-- Return(s):
--         - contactIdSoap: The SOAP for obtaining the patient contact Id
function soapRequests.getcontactIdbySSN(header,ssn) 
   
   local template = soapTemplates.contactBySSN
   
   local contactIdSoap = soapRequests.createFetchXML(header,template:gsub('repSSN',ssn))
   
   return contactIdSoap

end

-- Description: Creates the SOAP for obtaining the contact Id of a patient
--                 based on the firstname, lastname, and birthdate 
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - firstname: the patient firstname
--         - lastname: the patient lastname
--         - birthdate: the patient birthdate
-- Return(s):
--         - contactIdSoap: The SOAP for obtaining the patient contact Id
function soapRequests.getcontactIdbyNameDOB(header,firstname,lastname,birthdate) 
  
   local template = soapTemplates.contactByNameDOB
   
   local contactIdSoap = soapRequests.createFetchXML(header,template:gsub('repfirstname',firstname):gsub('replastname',lastname):gsub('repbirthdate',birthdate))
   
   return contactIdSoap

end

-- Description: Takes a fetch xml query, formats it, and create the 
--                useable fetchXml SOAP request 
-- Parameter(s): 
--         - header: the header of the SOAP call 
--         - fetchBody: the body of the fetchXml query
-- Return(s):
--         - fullRequest: The fetchXml SOAP request
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

-- Description: A helper function used in the update / create SOAP functions above
--                  to add an attribute to the SOAP request
-- Parameter(s): 
--         - typ: This is the type of the attribute
--         - attributeName: This is the name of the attribute 
--         - attributeValue: This is the value of the attribute 
-- Return(s):
--         - att: a <a:KeyValuePairOfstringanyType> containing the formatted attribute 
function soapRequests.addAttribute(typ,attributeName,attributeValue)
   local att = ''
   if typ == 'string' then 
      att = soapTemplates.attributeTemplate:gsub('attributeName',attributeName):gsub('attributeValue',attributeValue)
   else
      att = soapTemplates.attributeTemplate:gsub('attributeName',attributeName):gsub('attributeValue',attributeValue):gsub('c:string','c:'..typ)
   end
   return att
end

-- Description: A helper function used in the update / create SOAP functions above
--                  to add an entity reference as an attribute
-- Parameter(s): 
--         - attributeName: The name of the attribute
--         - destEntity: The name of the  reference entity
--         - value: The value of the reference entity
-- Return(s):
--         - att: <a:KeyValuePairOfstringanyType> containing the formatted entity 
--                   reference attribute
function soapRequests.addRelAttribute(attributeName,destEntity,value) 
   local att = soapTemplates.relatedAttributeTemplate:gsub('attributeName',attributeName):gsub('destEntity',destEntity):gsub('attributeValue',value)
	return att
end

-- Description: A helper function used in the update / create SOAP functions above
--                  to add an optionSetValue as an attribute 
-- Parameter(s): 
--         - attributeName: The name of the attribute
--         - attributeCode: The code associated with the value of the attribute
-- Return(s):
--         - att: <a:KeyValuePairOfstringanyType> containing the optionSetValue attribute
function soapRequests.addOptionSetValue(attributeName,attributeCode)
   return soapTemplates.optionSetValueTemplate:gsub('attributeName',attributeName):gsub('attributeCodeValue',attributeCode)
end

-- Description: Creates the SOAP for obtaining emdeon settings, 
--                  such as username, password, etc...
-- Parameter(s): 
--         - header: the header of the SOAP call 
-- Return(s):
--         - emdeonSoap: The SOAP for obtaining emdeon settings
function soapRequests.getEmdeonSettings(header) 
   local template = soapTemplates.fetchEmdeonSettings
   
   local emdeonSoap = soapRequests.createFetchXML(header,template)
   
   return emdeonSoap
end

return soapRequests