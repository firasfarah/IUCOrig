local soapTemps = {}

soapTemps.fetchResultValuesId = [[
   <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="ccx_resultvalue">
       <attribute name="ccx_resultvalueid" />
         <filter type='and'><condition value="represultdescr" operator="eq" attribute="ccx_code" /> </filter>
         <filter type='and'><condition value="repsetId" operator="eq" attribute="ccx_setid" /> </filter>
         <filter type='and'><condition value="replabresultId" operator="eq" attribute="ccx_labresult" /> </filter>
     </entity>
   </fetch>]]

soapTemps.fetchProviderId =   
[[<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="ccx_useridentifiers">
     <attribute name="ccx_userid" />
     <attribute name="createdon" />
     <attribute name="ccx_name" />
     <filter type="and">
       <condition attribute="ccx_name" operator="eq" value="repLabProvider" />
     </filter>
       <link-entity name="systemuser" from="systemuserid" to="ccx_userid" visible="false" link-type="outer" alias="aliasUser">
         <attribute name="systemuserid" />
       </link-entity>
     </entity>
   </fetch>]]

soapTemps.fetchResultsId = [[
   <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="ccx_labresults">
       <attribute name="ccx_labresultsid" />
         <filter type='and'><condition value="repcontactid" operator="eq" attribute="ccx_client" /> </filter>
         <filter type='and'><condition value="replabdesc" operator="eq" attribute="ccx_code" /> </filter>
         <filter type='and'><condition value="repccxorderid" operator="eq" attribute="ccx_order" /> </filter>
     </entity>
   </fetch>]]

soapTemps.fetchResultsIdNoContact = [[<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="ccx_labresults">
       <attribute name="ccx_labresultsid" />
         <filter type='and'><condition value="replabdesc" operator="eq" attribute="ccx_code" /> </filter>
         <filter type='and'><condition value="repccxorderid" operator="eq" attribute="ccx_order" /> </filter>
     </entity>
   </fetch>]]

soapTemps.fetchOrderId = [[
   <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="ccx_clientorders">
       <attribute name="activityid" />
         <filter type='and'><condition value="repordernumber" operator="eq" attribute="ccx_ordernumber" /> </filter>
     </entity>
   </fetch>]]

soapTemps.contactByPatientId = [[
   <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="contact">
       <attribute name="contactid" />
         <filter type='and'><condition value="repPatientId" operator="eq" attribute="ccx_mpistr" /> </filter>
     </entity>
   </fetch>]]

soapTemps.contactBySSN = [[
   <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="contact">
       <attribute name="contactid" />
         <filter type='and'><condition value="repSSN" operator="eq" attribute="ccx_ssn" /> </filter>
     </entity>
   </fetch>]]

soapTemps.contactByNameDOB = [[
   <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="contact">
       <attribute name="contactid" />
         <filter type='and'><condition value="repfirstname" operator="eq" attribute="firstname" /> </filter>
         <filter type='and'><condition value="replastname" operator="eq" attribute="lastname" /> </filter>
         <filter type='and'><condition value="repbirthdate" operator="on" attribute="birthdate" /> </filter>
     </entity>
   </fetch>]]
   
soapTemps.contactByOrderNumber =  [[<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="ccx_clientorders">
     <attribute name="subject" />
     <attribute name="createdon" />
     <attribute name="activityid" />
     <attribute name="ccx_patient" />
       <order attribute="subject" descending="false" />
         <filter type="and">
           <condition attribute="ccx_ordernumber" operator="eq" value="repOrderNumber" />
         </filter>
         <link-entity name="contact" from="contactid" to="ccx_patient" visible="false" link-type="outer" alias="aliasUser">
           <attribute name="contactid" />
         </link-entity>
       </entity>
     </fetch>]]

soapTemps.fetchEmdeonSettings = [[
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

soapTemps.attributeTemplate =   "  <a:KeyValuePairOfstringanyType>"..
                           "    <b:key>attributeName</b:key>"..
                           "    <b:value i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">attributeValue</b:value>"..
                           "  </a:KeyValuePairOfstringanyType>"

soapTemps.relatedAttributeTemplate =     " <a:KeyValuePairOfstringanyType>"..
                                    "   <b:key>attributeName</b:key>"..
                                    "     <b:value i:type=\"a:EntityReference\">"..
                                    "                             <a:Id>attributeValue</a:Id>"..
                                    "                             <a:LogicalName>destEntity</a:LogicalName>"..
                                    "                             <a:Name i:nil=\"true\" />"..
                                    "                         </b:value>"..
                                    "                </a:KeyValuePairOfstringanyType>"

soapTemps.optionSetValueTemplate =    "<a:KeyValuePairOfstringanyType>"..
                                 "   <b:key>attributeName</b:key>"..
                                 "   <b:value i:type=\"a:OptionSetValue\">"..
                                 "     <a:Value>attributeCodeValue</a:Value>".. 
                                 "   </b:value>"..
                                 " </a:KeyValuePairOfstringanyType>"

soapTemps.createStart = "  <s:Body>"..
   "    <Execute xmlns=\"http://schemas.microsoft.com/xrm/2011/Contracts/Services\" xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\">"..
   "      <request i:type=\"a:CreateRequest\" xmlns:a=\"http://schemas.microsoft.com/xrm/2011/Contracts\">"..
   "        <a:Parameters xmlns:b=\"http://schemas.datacontract.org/2004/07/System.Collections.Generic\">"..
   "          <a:KeyValuePairOfstringanyType>"..
   "            <b:key>Target</b:key>"..
   "            <b:value i:type=\"a:Entity\">"..
   "              <a:Attributes>"

soapTemps.createEnd =    "              </a:Attributes>"..
   "              <a:EntityState i:nil=\"true\" />"..
   "              <a:FormattedValues />"..
   "              <a:Id>repActivityId</a:Id>"..
   "              <a:LogicalName>ccx_labresults</a:LogicalName>"..
   "              <a:RelatedEntities />"..
   "            </b:value>"..
   "          </a:KeyValuePairOfstringanyType>"..
   "        </a:Parameters>"..
   "        <a:RequestId i:nil=\"true\" />"..
   "        <a:RequestName>Create</a:RequestName>"..
   "      </request>"..
   "    </Execute>"..
   "  </s:Body>"




return soapTemps