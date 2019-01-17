-- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.

local help         = require('generalHelper')
local orders       = require('orders')
local ccpAuth      = require('ccpAuth')
local results      = require('labresults')
local resultValues = require('resultValues')
local emdAuth      = require('emdeonAuth')

function main(Data)
   -- (1) Get CCP authentication header
   local crmUrn,crmHeader = ccpAuth.prepHeader()
   
   -- (2) Get global variables 
   local getGlobalsSuccess,globs = pcall(help.getGlobals,json.parse{data = Data},crmUrn,crmHeader)
   if getGlobalsSuccess == false then iguana.logError(globs) return end
   
   -- (3) Create order
   local orderSuccess,orderId = pcall(orders.processOrder,crmUrn,crmHeader,globs)
   if orderSuccess == false then iguana.logError(orderId) return end
   
   -- (4) Create results
   local resultSuccess,resultId = pcall(results.processResults,crmUrn,crmHeader,globs,orderId)
   if resultSuccess == false then iguana.logError(resultId) return end
   
   -- (5) Update result values
   local resultvaluesSuccess,resultValuesId = pcall(resultValues.processResultValues,crmUrn,crmHeader,globs,resultId) 
   if resultvaluesSuccess == false then iguana.logError(resultValuesId) return end
      
   -- (6) Update Emdeon that the report was pulled
   local emdUrl,emdUser,emdPasswd,facility = emdAuth.getEmdeonCredentials(crmUrn,crmHeader)
   emdAuth.updateReportPull(emdUrl,emdUser,emdPasswd,facility,globs.general.ClinicalReportId)
end

