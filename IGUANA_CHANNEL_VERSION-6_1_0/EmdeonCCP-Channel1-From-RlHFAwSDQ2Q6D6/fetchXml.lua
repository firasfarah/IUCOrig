local fetch = {}

function fetch.getEmdeonSettings(header) 
   
   local template = [[
   <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="ccx_sequence">
       <attribute name="ccx_name" />
       <attribute name="ccx_sequenceid" />
       <attribute name="ccx_key5value" />
       <attribute name="ccx_key5description" />
       <attribute name="ccx_key4value" />
       <attribute name="ccx_key4description" />
       <attribute name="ccx_key3value" />
       <attribute name="ccx_key3description" />
       <attribute name="ccx_key2value" />
       <attribute name="ccx_key2description" />
       <attribute name="ccx_key1value" />
       <attribute name="ccx_key1description" />
         <filter type='and'><condition value="Emdeon Settings" operator="eq" attribute="ccx_name" /> </filter>
     </entity>
   </fetch>]]
   
   local contactIdSoap = fetch.createFetchXML(header,template)
   
   return contactIdSoap

end

function fetch.createFetchXML(header,fetchBody) 

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

return fetch
