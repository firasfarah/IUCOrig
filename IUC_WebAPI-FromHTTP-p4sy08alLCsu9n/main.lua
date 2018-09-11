-- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.
local jsonUtil = require('makeJson')

function main(Data)
   local jsonData = jsonUtil.makeTable(10)
   local jsonSer  = json.serialize{data=jsonData} 
   net.http.respond{body=jsonSer,entity_type='application/json'}
end