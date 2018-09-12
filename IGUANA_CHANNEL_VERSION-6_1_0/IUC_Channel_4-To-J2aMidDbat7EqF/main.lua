-- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.

-------------------------------------------------------------------------|
--- Lost of channel configurations (stored in IUCConfigs shared module): |
--- csv filepath                                                         |
--- csv filename                                                         |
-------------------------------------------------------------------------|
local csvUtil = require('csvUtil')

function main(Data)
   
   -- (1) Parse incoming information
   local jsonTbl = json.parse{data=Data}
   
   -- (2) Update the csv file
   csvUtil.updateFile(jsonTbl)
   
end