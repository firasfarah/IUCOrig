local fetch = require('fetchXml')
local utils = require('utils')

local emdAuth = {}

function emdAuth.getEmdeonCredentials(urn,header) 
   local soapBody = fetch.getEmdeonSettings(header) 
   
   local credXml,respCode 
    = net.http.post{url = urn,
                    headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
                    body = soapBody,
                    timeout=100,
                    live=true}
   
   if respCode == 200 then 
      local pCredXml = xml.parse{data = credXml}
      local emdUrl = pCredXml["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult
                             ["b:Results"]["b:KeyValuePairOfstringanyType"]["c:value"]
                             ["b:Entities"]["b:Entity"]["b:Attributes"]:child("b:KeyValuePairOfstringanyType", 7)
                             ["c:value"]:nodeText() 
      local emdUser   = pCredXml["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult
                                ["b:Results"]["b:KeyValuePairOfstringanyType"]["c:value"]
                                ["b:Entities"]["b:Entity"]["b:Attributes"]:child("b:KeyValuePairOfstringanyType", 9)
                                ["c:value"]:nodeText()                                       
      local emdPasswd = pCredXml["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult
                                ["b:Results"]["b:KeyValuePairOfstringanyType"]["c:value"]
                                ["b:Entities"]["b:Entity"]["b:Attributes"]:child("b:KeyValuePairOfstringanyType", 5)
                                ["c:value"]:nodeText() 
      local facility  = pCredXml["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult
                                ["b:Results"]["b:KeyValuePairOfstringanyType"]["c:value"]
                                ["b:Entities"]["b:Entity"]["b:Attributes"]:child("b:KeyValuePairOfstringanyType", 3)
                                ["c:value"]:nodeText()                                       
     return emdUrl,emdUser,emdPasswd,facility
   else 
      return false
   end
end

function emdAuth.getEachReport(emdUrl,emdUser,emdPasswd,facility,clinReportId) 
   local baseUrl = emdUrl..'/servlet/XMLServlet?request='
   local eachReportCall = emdAuth.createGetEachReportCall(emdUser,emdPasswd,facility,clinReportId)
   
   local respData,respCode,respHeaders = net.http.post{url=baseUrl..eachReportCall,live = true}
   
   local jsonObj = emdAuth.mapToJson(respData)
   
   return jsonObj
 
end

function emdAuth.mapToJson(xmlReports) 
  
   local pRespData = xml.parse{data = xmlReports}

   local jsonObj = {}
   
   jsonObj['ClinicalReportId'] = pRespData.RESULT.OBJECT.clinicalreport:nodeText()
   trace(jsonObj)
   for k = 1,pRespData.RESULT:childCount("OBJECT") do 
      local mimeType = pRespData.RESULT:child("OBJECT",k).mime_type:nodeText()
      local isHL7 = mimeType:find('HL7')
      if isHL7 then mimeType = 'HL7' end
      local isHtml = mimeType:find('html')
      local isHL7orHtml = isHL7 or isHtml
      trace(isHL7orHtml)
      if isHL7orHtml ~= nil then
         jsonObj[mimeType] = pRespData.RESULT:child("OBJECT",k).body_text:nodeText()
      end
   end
   
   trace(jsonObj)
   return json.serialize{data=jsonObj}
end

function emdAuth.getReportList(emdUrl,emdUser,emdPasswd,facility) 
   local baseUrl = emdUrl..'/servlet/XMLServlet?request='
   local reportListCall = emdAuth.createGetReportListCall(emdUser,emdPasswd,facility,os.ts.gmtime() - 60*60*6000,os.ts.gmtime())
 
   local respData,respCode,respHeaders = net.http.post{url=baseUrl..reportListCall,live = true}
   
   if respCode == 200 then 
      local prespData = xml.parse{data = respData}
      local listOfReports = {}
      for k = 1,prespData.RESULT:childCount("OBJECT") do 
         listOfReports[k] = prespData.RESULT:child("OBJECT", k).clinicalreport:nodeText()
      end
      return listOfReports
   else 
     return false
   end

end

function emdAuth.createGetEachReportCall(emdUser,emdPasswd,facility,clinReportId) 
   local getReportCall = xml.parse{data = emdAuth.eachReportCallTemplate}
   getReportCall.REQUEST.userid:setInner(emdUser)
   getReportCall.REQUEST.password:setInner(emdPasswd)
   getReportCall.REQUEST.facility:setInner(facility)
   getReportCall.REQUEST.OBJECT.clinicalreport:setInner(clinReportId)
   local eachReportCall = getReportCall:S():trimWS():gsub(' ','%%20'):gsub('\n','')
   return eachReportCall
end

function emdAuth.createGetReportListCall(emdUser,emdPasswd,facility,fromDate,toDate) 
   local dateTable = utils.getEmdeonSearchDates(toDate,fromDate) 
   local listCall = xml.parse{data = emdAuth.reportListCallTemplate}
   listCall.REQUEST.userid:setInner(emdUser)
   listCall.REQUEST.password:setInner(emdPasswd)
   listCall.REQUEST.facility:setInner(facility)
   listCall.REQUEST.OBJECT.receivingorganization:setInner(facility)
   listCall.REQUEST.OBJECT.creation_datetime_from:setInner(dateTable['date1'])
   listCall.REQUEST.OBJECT.creation_datetime_to:setInner(dateTable['date2'])
   local reportListCall = listCall:S():trimWS():gsub(' ','%%20'):gsub('\n','')
   return reportListCall
end

emdAuth.reportListCallTemplate = [[<REQUEST userid='dummyUserId' password='dummyPassWord' facility='dummyFacility'><OBJECT name='clinicalreport' op='search_filedelivery'><receivingorganization></receivingorganization><creation_datetime_from></creation_datetime_from><creation_datetime_to></creation_datetime_to><is_downloaded></is_downloaded></OBJECT></REQUEST>]]
emdAuth.eachReportCallTemplate = [[<REQUEST userid="dummyUserId" password="dummyPassWord" facility="dummyFacility"><OBJECT name="reportdoc" op="search"><clinicalreport>dummyClinReportId</clinicalreport><emr_ready_only></emr_ready_only></OBJECT></REQUEST>]]

return emdAuth