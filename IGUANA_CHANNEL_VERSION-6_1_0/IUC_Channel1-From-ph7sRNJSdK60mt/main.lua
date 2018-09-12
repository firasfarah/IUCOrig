-- The main function is the first function called from Iguana.
-------------------------------------------------------------------------|
--- Lost of channel configurations (stored in external database):        |
--- Web API URL                                                              |
--- Web API URL page                                                         |
-------------------------------------------------------------------------|

local dbConfigs = require('dbConfigs')
local webURL,webPage = dbConfigs.retrieve() -- Retrieve the configs stored in external system

function main()
  
   -- (1) Constuct webAPI complete URL  
   local webAPIurl = 'http://'..webURL..'/'..webPage
  
   -- (2) Make API call to retrieve patient data from web API
   local Res,Code,Headers = net.http.get{url=webAPIurl,live=true}
   
   -- (3) Parse the resulting json data
   local apiTable = json.parse{data=Res}
   
   -- (4) Loop through the json table and push each to queue
   for k=1,#apiTable do 
      trace(apiTable[1])
      queue.push{data=json.serialize{data=apiTable[k]}}
   end
   
end