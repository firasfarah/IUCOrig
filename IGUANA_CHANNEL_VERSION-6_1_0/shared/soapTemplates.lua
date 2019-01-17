-- This module contains templates used in the building of
-- of the SOAP requests. They are either fetchXml queries
-- or building blocks of the SOAP request


local soapTemps = {}

------------------------------
----- Fetch XML Requests -----
------------------------------

-- fetch request to obtain the ccx_resultvalueid based on the ccx_code, ccx_setid, and ccx_labresult
soapTemps.fetchResultValuesId = [[
   <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="ccx_resultvalue">
       <attribute name="ccx_resultvalueid" />
         <filter type='and'><condition value="represultdescr" operator="eq" attribute="ccx_code" /> </filter>
         <filter type='and'><condition value="repsetId" operator="eq" attribute="ccx_setid" /> </filter>
         <filter type='and'><condition value="replabresultId" operator="eq" attribute="ccx_labresult" /> </filter>
     </entity>
   </fetch>]]

-- fetch request to obtain the providerId of a lab provider
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

-- fetch request to obtain the ccx_labresultsid based on the ccx_client, ccx_code, and ccx_order
soapTemps.fetchResultsId = [[
   <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="ccx_labresults">
       <attribute name="ccx_labresultsid" />
         <filter type='and'><condition value="repcontactid" operator="eq" attribute="ccx_client" /> </filter>
         <filter type='and'><condition value="replabdesc" operator="eq" attribute="ccx_code" /> </filter>
         <filter type='and'><condition value="repccxorderid" operator="eq" attribute="ccx_order" /> </filter>
     </entity>
   </fetch>]]

-- fetch request to obtain the ccx_labresultsid based on the ccx_code and ccx_order
soapTemps.fetchResultsIdNoContact = [[<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="ccx_labresults">
       <attribute name="ccx_labresultsid" />
         <filter type='and'><condition value="replabdesc" operator="eq" attribute="ccx_code" /> </filter>
         <filter type='and'><condition value="repccxorderid" operator="eq" attribute="ccx_order" /> </filter>
     </entity>
   </fetch>]]

-- fetch request to obtain the activity id of an order based on the ccx_ordernumber
soapTemps.fetchOrderId = [[
   <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="ccx_clientorders">
       <attribute name="activityid" />
         <filter type='and'><condition value="repordernumber" operator="eq" attribute="ccx_ordernumber" /> </filter>
     </entity>
   </fetch>]]

-- fetchrequest to obtain the contactid based on the patient Id 
soapTemps.contactByPatientId = [[
   <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="contact">
       <attribute name="contactid" />
         <filter type='and'><condition value="repPatientId" operator="eq" attribute="ccx_mpistr" /> </filter>
     </entity>
   </fetch>]]

-- fetchrequest to obtain the contactid by patient ssn
soapTemps.contactBySSN = [[
   <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="contact">
       <attribute name="contactid" />
         <filter type='and'><condition value="repSSN" operator="eq" attribute="ccx_ssn" /> </filter>
     </entity>
   </fetch>]]

-- fetchrequest to obtain the contactid by patient firstname, lastname, and birthdate
soapTemps.contactByNameDOB = [[
   <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
     <entity name="contact">
       <attribute name="contactid" />
         <filter type='and'><condition value="repfirstname" operator="eq" attribute="firstname" /> </filter>
         <filter type='and'><condition value="replastname" operator="eq" attribute="lastname" /> </filter>
         <filter type='and'><condition value="repbirthdate" operator="on" attribute="birthdate" /> </filter>
     </entity>
   </fetch>]]

-- fetchrequest to obtain the contactId by the ordernumber
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

-- fetchrequest to obtain Emdeon Settings
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

----------------------------------------
----- SOAP request building blocks -----
----------------------------------------

-- This building block is for a regular attribute
soapTemps.attributeTemplate =   "  <a:KeyValuePairOfstringanyType>"..
                           "    <b:key>attributeName</b:key>"..
                           "    <b:value i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">attributeValue</b:value>"..
                           "  </a:KeyValuePairOfstringanyType>"

-- This building block is for a related attribute (ie. an entity reference)
soapTemps.relatedAttributeTemplate =     " <a:KeyValuePairOfstringanyType>"..
                                    "   <b:key>attributeName</b:key>"..
                                    "     <b:value i:type=\"a:EntityReference\">"..
                                    "                             <a:Id>attributeValue</a:Id>"..
                                    "                             <a:LogicalName>destEntity</a:LogicalName>"..
                                    "                             <a:Name i:nil=\"true\" />"..
                                    "                         </b:value>"..
                                    "                </a:KeyValuePairOfstringanyType>"

-- This building block is for an OptionSetValue attribute
soapTemps.optionSetValueTemplate =    "<a:KeyValuePairOfstringanyType>"..
                                 "   <b:key>attributeName</b:key>"..
                                 "   <b:value i:type=\"a:OptionSetValue\">"..
                                 "     <a:Value>attributeCodeValue</a:Value>".. 
                                 "   </b:value>"..
                                 " </a:KeyValuePairOfstringanyType>"

-- This building blocks is the starting portion of create and update requests
soapTemps.createStart = "  <s:Body>"..
   "    <Execute xmlns=\"http://schemas.microsoft.com/xrm/2011/Contracts/Services\" xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\">"..
   "      <request i:type=\"a:CreateRequest\" xmlns:a=\"http://schemas.microsoft.com/xrm/2011/Contracts\">"..
   "        <a:Parameters xmlns:b=\"http://schemas.datacontract.org/2004/07/System.Collections.Generic\">"..
   "          <a:KeyValuePairOfstringanyType>"..
   "            <b:key>Target</b:key>"..
   "            <b:value i:type=\"a:Entity\">"..
   "              <a:Attributes>"

-- This building block is the ending portion of create and update requests
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