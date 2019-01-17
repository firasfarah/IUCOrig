-- This module is responsible for extracting all global variables
--    required for the processing of the message and placing them in 
--    a single global table. 
-- Some globals variables are static (ex. obtain from an HL7 message)
-- Other globals are queried 

local requests = require('requestCreators')
local utils    = require('utils')
local retry    = require('retry')

local help = {}

function help.getGlobals(Data,urn,header) 
   
   local globs = {} -- The global table
   
   -- Read the hl7 and html 
   local hl7Msg = hl7.parse{data = Data["HL7"], vmd = 'emdeon.vmd'}
   local htmlFile = ''
   if Data.htmlFileName ~= nil then htmlFile = utils.readFile(Data.htmlFileName) end
   
   -- Populate the globals table
   local clinicalReportId = Data.ClinicalReportId
   globs = help.mapGeneralGlobs(hl7Msg,clinicalReportId,htmlFile,globs)
   local contactId = help.getContactId(urn,header,hl7Msg,globs)
   globs = help.mapGlobsforOrders(hl7Msg,globs,urn,header,contactId)
   globs = help.mapGlobsforResults(hl7Msg,globs,urn,header,contactId,htmlFile)
   globs = help.mapGlobsforResultValues(hl7Msg,globs,urn,header)
   globs = help.mapGlobsforPDF(Data['pdfFileName'],globs,urn,header)
   return globs
end

-- Description: This function maps global variables used widely and often
-- Parameter(s): 
--         - hl7Msg: the parsed HL7 message
--         - globs: the global variables table
--         - htmlFile: The contents of the html documents
--         - clinicalReportId: The clinical report Id
-- Return(s):
--         - globs: The global variables table
function help.mapGeneralGlobs(hl7Msg,clinicalReportId,htmlFile,globs) 
 
   local labPatient = hl7Msg.PID[3][1][1]:nodeValue()
   if labPatient == '' then 
      labPatient = hl7Msg.PID[2][1]:nodeValue()
   end
   
   globs.general = {}
   globs['general']['pMsgType']    = 'Emdeon'..hl7Msg.MSH[9][1]:nodeValue()
   globs['general']['LabPatient']  =  labPatient
   if hl7Msg.OBR:childCount() == 50 then 
      globs['general']['LabOrder']    = hl7Msg.OBR[2][1]:nodeValue()
      globs['general']['labProvider'] = hl7Msg.OBR[16][1][1]:nodeValue() 
   else
      globs['general']['LabOrder']    = hl7Msg.OBR[1][2][1]:nodeValue()
      globs['general']['labProvider'] = hl7Msg.OBR[1][16][1][1]:nodeValue()
   end
   
   globs['general']['ClinicalReportId'] = clinicalReportId
   globs['general']['MSHFacility'] = hl7Msg.MSH[4][1]:nodeValue()
   if htmlFile ~= nil then globs['general']['htmlfile'] = htmlFile end
   
   return globs
end

-- Description: This function maps the global variables required for the
--                   ccx_resultvalues entity
-- Parameter(s): 
--         - hl7Msg: the parsed HL7 message
--         - globs: the global variables table
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
-- Return(s):
--         - globs: The global variables table
function help.mapGlobsforResultValues(hl7Msg,globs,urn,header) 
   globs.resultValues = {}
   for k=1,hl7Msg.OBX:childCount() do 
      globs.resultValues[k] = {}
      globs.resultValues[k]['ccx_result']    = hl7Msg.OBX[k][5][1][1]:nodeValue()
      globs.resultValues[k]['ccx_name']    = hl7Msg.OBX[k][5][1][1]:nodeValue()
      globs.resultValues[k]['ccx_value']   = hl7Msg.OBX[k][3][2]:nodeValue()
      globs.resultValues[k]['ccx_referencerange'] = hl7Msg.OBX[k][7]:nodeValue()
      globs.resultValues[k]['ccx_resultstatus'] = hl7Msg.OBX[k][11]:nodeValue()
      globs.resultValues[k]['ccx_units'] = hl7Msg.OBX[k][6][1]:nodeValue()
      globs.resultValues[k]['ccx_abnormalflags'] = hl7Msg.OBX[k][8][1]:nodeValue()
      globs.resultValues[k]['ccx_setid'] = {'int',hl7Msg.OBX[k][1]:nodeValue()}
      globs.resultValues[k]['ccx_observationsubid'] = hl7Msg.OBX[k][4]:nodeValue()
      if hl7Msg.OBR:childCount() == 50 then -- Check if a single OBR
         globs.resultValues[k]['ccx_code'] = hl7Msg.OBR[4][1]:nodeValue()
      else                                  -- or if parsed as a repeat
         globs.resultValues[k]['ccx_code'] = hl7Msg.OBR[1][4][1]:nodeValue()
      end
   end
   return globs
end 

-- Description: This function maps the global variables required for the
--                   ccx_labresults entity
-- Parameter(s): 
--         - hl7Msg: the parsed HL7 message
--         - globs: the global variables table
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - contactId: The contactId of the patient
--         - htmlFile: The contents of the html document
-- Return(s):
--         - globs: The global variables table
function help.mapGlobsforResults(hl7Msg,globs,urn,header,contactId,htmlFile)
   globs.results = {}
   
   globs.results['ccx_client']    = {'re','contact',contactId}
   
   if hl7Msg.OBR:childCount() == 50 then 
      globs.results['ccx_code']        = hl7Msg.OBR[4][1]:nodeValue()
      globs.results['ccx_description'] = hl7Msg.OBR[4][2]:nodeValue()
      globs.results['ccx_name']               = hl7Msg.OBR[4][2]:nodeValue()
      globs.results['ccx_placerordernumber']  = hl7Msg.OBR[2][1]:nodeValue()
      globs.results['ccx_setid']              = {'int',hl7Msg.OBR[1]:nodeValue()}
      globs.results['ccx_fillerordernumber']  = hl7Msg.OBR[3][1]:nodeValue()
      globs.results['ccx_specimensourceid']   = hl7Msg.OBR[15][1][1]:nodeValue()
      globs.results['ccx_resultstatus']       = hl7Msg.OBR[25]:nodeValue()
      globs.results['ccx_code']               = hl7Msg.OBR[4][1]:nodeValue()
      globs.results['ccx_orderingproviderfirstname'] = hl7Msg.OBR[16][1][3]:nodeValue()
      globs.results['ccx_orderingproviderlastname']  = hl7Msg.OBR[16][1][2][1]:nodeValue()
      globs.results['ccx_orderingprovidermiddlename']= hl7Msg.OBR[16][1][4]:nodeValue()
      globs.results['ccx_orderingproviderid']        = hl7Msg.OBR[16][1][1]:nodeValue()
      globs.results['ccx_requested']          = {'dateTime',utils.formatDate(hl7Msg.OBR[7]:nodeValue())}
   else
      globs.results['ccx_code']        = hl7Msg.OBR[1][4][1]:nodeValue()
      globs.results['ccx_description'] = hl7Msg.OBR[1][4][2]:nodeValue()
      globs.results['ccx_name']               = hl7Msg.OBR[1][4][2]:nodeValue()
      globs.results['ccx_placerordernumber']  = hl7Msg.OBR[1][2][1]:nodeValue()
      globs.results['ccx_setid']              = {'int',hl7Msg.OBR[1][1]:nodeValue()}
      globs.results['ccx_fillerordernumber']  = hl7Msg.OBR[1][3][1]:nodeValue()
      globs.results['ccx_specimensourceid']   = hl7Msg.OBR[1][15][1][1]:nodeValue()
      globs.results['ccx_resultstatus']       = hl7Msg.OBR[1][25]:nodeValue()
      globs.results['ccx_code']               = hl7Msg.OBR[1][4][1]:nodeValue()
      globs.results['ccx_orderingproviderfirstname'] = hl7Msg.OBR[1][16][1][3]:nodeValue()
      globs.results['ccx_orderingproviderlastname']  = hl7Msg.OBR[1][16][1][2][1]:nodeValue()
      globs.results['ccx_orderingprovidermiddlename']= hl7Msg.OBR[1][16][1][4]:nodeValue()
      globs.results['ccx_orderingproviderid']        = hl7Msg.OBR[1][16][1][1]:nodeValue()
      globs.results['ccx_requested']          = {'dateTime',utils.formatDate(hl7Msg.OBR[1][7]:nodeValue())}
   end
   
   globs.results['ccx_lab']       = hl7Msg.OBX[1][15][1]:nodeValue()
   globs.results['ccx_requisitionnumber']      = globs.general.ClinicalReportId
   globs.results['ccx_labpatientfirstname']    = hl7Msg.PID[5][1][2]:nodeValue()
   globs.results['ccx_labpatientlastname']     = hl7Msg.PID[5][1][1][1]:nodeValue()
   globs.results['ccx_labpatientmiddlename']   = hl7Msg.PID[5][1][3]:nodeValue()
   globs.results['ccx_labpatientbirthdate']    = {'dateTime',utils.formatDate(hl7Msg.PID[7][1]:nodeValue())}
   globs.results['ccx_labpatientphonenumber']  = hl7Msg.PID[13][1][1]:nodeValue()
   globs.results['ccx_labpatientgender']  = {'option',utils.processGender(hl7Msg.PID)}
   if htmlFile ~= nil then globs.results['ccx_emdeonlabresultsreport'] = filter.html.enc(htmlFile) end
   if hl7Msg ~= nil then globs.results['ccx_message']                = filter.html.enc(hl7Msg:S()) end
 
   return globs
end

-- Description: This function maps the global variables required for the
--                   ccx_clientorders entity
-- Parameter(s): 
--         - hl7Msg: the parsed HL7 message
--         - globs: the global variables table
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - contactId: The contactId of the patient
-- Return(s):
--         - globs: The global variables table
function help.mapGlobsforOrders(hl7Msg,globs,urn,header,contactId) 
   globs.orders = {}
   
   globs['orders']['ccx_formaction'] = {'option','803080000'}
   globs['orders']['ccx_patient'] = {'re','contact', contactId}
   globs['orders']['ccx_orderingprovider'] = {'re','systemuser', help.getProviderId(urn,header,globs)}--'404dcbb3-4d79-e811-9421-00155d150320'}
   local orderId = ''
   if hl7Msg.OBR:childCount() == 50 then 
      orderId = hl7Msg.OBR[2][1]:nodeValue()
      globs['orders']['scheduledstart'] = {'dateTime',utils.formatDate(hl7Msg.OBR[7]:nodeValue())}
   else
      orderId = hl7Msg.OBR[1][2][1]:nodeValue()
      globs['orders']['scheduledstart'] = {'dateTime',utils.formatDate(hl7Msg.OBR[1][7]:nodeValue())}
   end
   globs['orders']['ccx_hl7_integrationid'] = globs['general']['ClinicalReportId']   
   globs['orders']['ccx_placerordernumber'] = orderId
   globs['orders']['ccx_ordernumber']       = orderId
   globs['orders']['subject']               = hl7Msg.MSH[9][1]:nodeValue().." Lab "..orderId
   globs['orders']['ccx_specialinstruction'] = help.getComments(hl7Msg) 
   globs['orders']['ccx_ordertype'] = {'option','803080001'}
   
   return globs
end

-- Description: This function maps the global variables required for the PDF 
--                   annotation entity.
-- Parameter(s): 
--         - pdfName: the path to the PDF file to be read
--         - globs: the global variables table
-- Return(s):
--         - globs: The global variables table
function help.mapGlobsforPDF(pdfName,globs) 
   if pdfName == nil then 
      return globs
   end
   
   local pdfContents = utils.readBinaryFile(pdfName)
   
   globs.pdf = {}
   globs.pdf['objecttypecode'] = 'ccx_labresults'
   globs.pdf['subject']        = "Attachment"
   globs.pdf['isdocument'] = {'boolean',"true"}
   globs.pdf['notetext']   = "PDF Report"
   globs.pdf['filename']   = "LabReport.pdf"
   globs.pdf['documentbody'] = pdfContents
   globs.pdf['mimetype']   = "application/pdf"
      
   return globs
end

--------------------------------------------------------------------------
------------------------- Query for globals ------------------------------
--------------------------------------------------------------------------

-- Description: This function gets the providerId
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - globs: the global variables table
-- Return(s):
--         - providerId (on success): The provider Id in CCP
function help.getProviderId(urn,header,globs) 
  
   --local providerNPI = globs.general.labProvider  
   local providerNPI = '1235233826' -- For testing purposes only 
   local providerIdRequest = requests.getProviderIdSoap(header,providerNPI)
   local providerIdResponse,providerIdCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = providerIdRequest,
      timeout=100,
      live=true},retry=3,pause=30}
   
   if providerIdCode == 200 then
      local providerIdResponse = xml.parse{data = providerIdResponse}

      local providerId = nil
      local entity = providerIdResponse["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult["b:Results"]["b:KeyValuePairOfstringanyType"]
           ["c:value"]["b:Entities"]["b:Entity"]
      if entity ~= nil then 
         providerId = entity["b:Attributes"]:child("b:KeyValuePairOfstringanyType", 5)["c:value"]["b:Value"]:nodeText()
      end

      return providerId
   else 
      error('ProviderId fetch associated with Clinical Report ID '..globs['general']['ClinicalReportId']..
         ' errored.\nResponse Code: '..providerIdCode..'\n'..
         'Server Response:\n'..providerIdResponse)
   end
end

-- Description: This function gets the contact Id in CCP of the patient.
--                  It first tries using patient Id, then by order, 
--                  then by SSN, then by name and DOB
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - hl7Msg: The parsed HL7 message
--         - globs: the global variables table
-- Return(s):
--         - contactId: The contact Id; nil if unable to find
function help.getContactId(urn,header,hl7Msg,globs) 
   
   -- (1) Attempt to query by hl7 patient ID
   local contactId = help.contactIdByPatientId(urn,header,hl7Msg,globs)
   
   -- (2) If not found, query by order number
   if contactId == nil then contactId = help.contactIdByOrder(urn,header,hl7Msg,globs) end
   
   -- (3) If not found, query by ssn
   if contactId == nil then contactId = help.contactIdBySSN(urn,header,hl7Msg,globs) end
   
   -- (4) If not found, query by firstname, lastname, and birthdate
   if contactId == nil then contactId = help.contactIdByNameDob(urn,header,hl7Msg,globs) end
   
   return contactId
end

-- Description: This function gets the contact Id in CCP of the patient
--                    based on the first name, last name, and date of birth
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - hl7Msg: The parsed HL7 message
--         - globs: the global variables table
-- Return(s):
--         - contactId: The contact Id; nil if unable to find
function help.contactIdByNameDob(urn,header,hl7Msg,globs)
   
   local firstName = hl7Msg.PID[5][1][2]:nodeValue()
   local lastName = hl7Msg.PID[5][1][1][1]:nodeValue()
   local dob = hl7Msg.PID[7][1]:nodeValue()
   local formatDOB = utils.formatDate(dob)
   
   local contactIdRequest = requests.getcontactIdbyNameDOB(header,firstName,lastName,formatDOB) 
   local contactIdResponse,contactIdCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = contactIdRequest,
      timeout=100,
      live=true},retry=3,pause=30}

   if contactIdCode == 200 then
      local contactIdResponse = xml.parse{data=contactIdResponse}

      local contactId = nil
      local entity = contactIdResponse["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult["b:Results"]["b:KeyValuePairOfstringanyType"]
      ["c:value"]["b:Entities"]
      if entity["b:Entity"] ~= nil then 
         contactId = entity["b:Entity"]["b:Attributes"]["b:KeyValuePairOfstringanyType"]["c:value"]:nodeText() 
      end
   
      return contactId
   else 
      error('ContactId fetch associated with Clinical Report ID '..globs['general']['ClinicalReportId']..
         ' errored.\nResponse Code: '..contactIdCode..'\n'..
         'Server Response:\n'..contactIdResponse)
   end
end

-- Description: This function gets the contact Id in CCP of the patient
--                    based on the SSN
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - hl7Msg: The parsed HL7 message
--         - globs: the global variables table
-- Return(s):
--         - contactId: The contact Id; nil if unable to find
function help.contactIdBySSN(urn,header,hl7Msg,globs) 
   
   local ssn = hl7Msg.PID[19]:nodeValue():gsub('-','')
   if ssn == '' then return end
   local formatSSN = ssn:sub(1,3)..'-'..ssn:sub(4,5)..'-'..ssn:sub(6,9)
   
   local contactIdRequest = requests.getcontactIdbySSN(header,formatSSN) 
   local contactIdResponse,contactIdCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = contactIdRequest,
      timeout=100,
      live=true},pause=30,retry=3}

   if contactIdCode == 200 then
      local contactList = xml.parse{data=contactIdResponse}
	
      local contactId = nil
      local entity = contactList["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult["b:Results"]["b:KeyValuePairOfstringanyType"]
      ["c:value"]["b:Entities"]

      if entity["b:Entity"] ~= nil then 
         contactId = entity["b:Entity"]["b:Attributes"]["b:KeyValuePairOfstringanyType"]["c:value"]:nodeText() 
      end
      return contactId
   else 
      error('ContactId fetch associated with Clinical Report ID '..globs['general']['ClinicalReportId']..
         ' errored.\nResponse Code: '..contactIdCode..'\n'..
         'Server Response:\n'..contactIdResponse)
   end
end

-- Description: This function gets the contact Id in CCP of the patient
--                    based on the order
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - hl7Msg: The parsed HL7 message
--         - globs: the global variables table
-- Return(s):
--         - contactId: The contact Id; nil if unable to find
function help.contactIdByOrder(urn,header,hl7Msg,globs) 
   local orderNumber = globs.general.LabOrder
   
   local contactIdRequest = requests.contactIdbyOrderNumber(header,orderNumber) 
   local contactIdResponse,contactIdCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = contactIdRequest,
      timeout=100,
      live=true},retry=3,pause=30}
   
   if contactIdCode == 200 then
      local contactList = xml.parse{data=contactIdResponse}
      local contactId = nil
      local entity = contactList["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult["b:Results"]["b:KeyValuePairOfstringanyType"]
      ["c:value"]["b:Entities"]
      
      if entity:childCount() == 0 then return contactId end
      if entity["b:Entity"]["b:Attributes"]:childCount() > 4 then 
         contactId = entity["b:Entity"]["b:Attributes"]:child("b:KeyValuePairOfstringanyType", 5)["c:value"]["b:Value"]:nodeText()
      end
      return contactId
   else
      error('ContactId fetch associated with Clinical Report ID '..globs['general']['ClinicalReportId']..
         ' errored.\nResponse Code: '..contactIdCode..'\n'..
         'Server Response:\n'..contactIdResponse)
   end
end

-- Description: This function gets the contact Id in CCP of the patient
--                    based on the patient Id
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - hl7Msg: The parsed HL7 message
--         - globs: the global variables table
-- Return(s):
--         - contactId: The contact Id; nil if unable to find
function help.contactIdByPatientId(urn,header,phl7Msg,globs) 
   local patientId = globs.general['LabPatient']  
   
   local contactIdRequest  = requests.contactIdbyPatientId(header,patientId)
   local contactIdResponse,contactIdCode  = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = contactIdRequest,
      timeout=100,
      live=true},retry=3,pause=30}
   
   if contactIdCode == 200 then
      local contactList = xml.parse{data=contactIdResponse}

      local contactId = nil
      local entity = contactList["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult["b:Results"]["b:KeyValuePairOfstringanyType"]
      ["c:value"]["b:Entities"]
      if entity["b:Entity"] ~= nil then
      contactId = entity["b:Entity"]["b:Attributes"]["b:KeyValuePairOfstringanyType"]["c:value"]:nodeText() 
      end

      return contactId
   else 
      error('ContactId fetch associated with Clinical Report ID '..globs['general']['ClinicalReportId']..
         ' errored.\nResponse Code: '..contactIdCode..'\n'..
         'Server Response:\n'..contactIdResponse)
   end
end

-- Description: This function goes through the NTE segments of an 
--                 HL7 message and concatenates them
-- Parameter(s): 
--         - hl7Msg: The parsed HL7 message
-- Return(s):
--         - comments: The concatenated NTE segments
function help.getComments(phl7Msg)
   local comments = ''
  
   if #phl7Msg.NTE > 1 then 
      comments = phl7Msg.NTE[3][1]:nodeValue() 
   else
      for k = 0,#phl7Msg.NTE do 
         comments = comments..phl7Msg.NTE[k+1][3][1]:nodeValue()
      end
   end
   
   return comments
end


return help