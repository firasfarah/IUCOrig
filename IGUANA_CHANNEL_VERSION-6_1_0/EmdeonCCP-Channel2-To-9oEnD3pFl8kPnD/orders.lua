-- This module deals with the processing of the ccx_clientorders entity
local requests = require('requestCreators')
local retry    = require('retry')

local orders = {}

-- Description: This function deals with the high level processing of
--                the ccx_clientorders entity. It queries for it, and 
--                if it does not find it, then it creates it. Otherwise
--                it updates it.
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - globs: The global variables table
-- Return(s):
--         - activityId: The activity Id of the order
function orders.processOrder(urn,header,globs)
    
   -- (1) Query for order
   local activityId = orders.queryOrder(urn,header,globs.general.LabOrder,globs)
     
   if activityId == nil then 
   -- (2a) if order does not exist, create
       activityId = orders.createOrder(urn,header,globs)
   else 
   -- (2b) if order does exist update it
       orders.updateOrder(urn,header,globs,activityId)
   end
   
   if activityId == nil or activityId == '' then 
      error('Something went wrong while processing order for ClinicalReportId '
                 ..globs['general']['ClinicalReportId'])
   else
      return activityId
   end
   
end

-- Description: This function is responsible for querying for the order                
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - globs: The global variables table
--         - LabOrder: The order number
-- Return(s):
--         - activityId: The activity Id of the order, if found
--         - nil, if not found
function orders.queryOrder(urn,header,LabOrder,globs) 

   local fetchOrdersRequest = requests.getOrderIdSoap(header,LabOrder)
   local fetchOrdersResponse,fetchCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = fetchOrdersRequest,
      timeout=100,
      live=true},pause=30,retry=3}
   
   if fetchCode == 200 then
      local listOrders = xml.parse{data = fetchOrdersResponse}

      local entity = listOrders["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult["b:Results"]
      ["b:KeyValuePairOfstringanyType"]["c:value"]["b:Entities"]

      local activityId = ''

      if entity["b:Entity"] ~= nil then 
         activityId = entity:child("b:Entity",1)["b:Attributes"]
         ["b:KeyValuePairOfstringanyType"]["c:value"]:nodeText()
      else activityId = nil 
      end

      return activityId
   else
      error('Order Query associated with Clinical Report ID '..globs['general']['ClinicalReportId']..
         ' was unsuccessful.\nResponse Code: '..fetchCode..'\n'..
         'Server Response:\n'..fetchOrdersResponse)
   end
end

-- Description: This function is responsible for creating a ccx_clientorders
--                  entity with the report information. 
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - globs: The global variables table
-- Return(s):
--         - activityId: The activity Id of the created order
function orders.createOrder(urn,header,globs)
   local createOrderRequest = requests.createOrderRequestSoap(header,globs.orders)
   local createOrderResponse,createOrderCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = createOrderRequest,
      timeout=100,
      live=true},pause=30,retry=3}
    
   if createOrderCode == 200 then
      local createOrderResponse = xml.parse{data=createOrderResponse}
      local activityId = createOrderResponse["s:Envelope"]["s:Body"].ExecuteResponse.ExecuteResult
                         ["b:Results"]["b:KeyValuePairOfstringanyType"]["c:value"]:nodeText()
      return activityId
   else
      error('Order create associated with Clinical Report ID '..globs['general']['ClinicalReportId']..
            ' was unsuccessful.\nResponse Code: '..createOrderCode..'\n'..
            'Server Response:\n'..createOrderResponse)
   end
end

-- Description: This function is responsible for updating a ccx_clientorders
--                  entity with the report information. 
-- Parameter(s): 
--         - urn: The urn for ccp
--         - header: The header required for all CCP interactions
--         - globs: The global variables table
--         - activityId: The activity Id of the order to be updated
-- Return(s): NONE
function orders.updateOrder(urn,header,globs,activityId) 
   local updateOrderRequest = requests.updateOrderRequestSoap(header,globs.orders,activityId)
   local updateOrderResponse,updateOrderCode = retry.call{func=net.http.post,arg1={url = urn,
      headers= {['content-type'] = 'application/soap+xml; charset=UTF-8'}, 
      body = updateOrderRequest,
      timeout=100,
      live=true},pause=30,retry=3}
   
   if updateOrderCode ~= 200 then 
      error('Order update associated with Clinical Report ID '..globs['general']['ClinicalReportId']..
            ' was unsuccessful.\nResponse Code: '..updateOrderCode..'\n'..
            'Server Response:\n'..updateOrderResponse)
   end
   
end

return orders