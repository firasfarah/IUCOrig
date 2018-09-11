-- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.

-------------------------------------------------------------------------|
--- Lost of channel configurations (stored in IUCConfigs shared module): |
--- Database filepath                                                    |
--- Database filename                                                    |
-------------------------------------------------------------------------|

local dbUtil  = require('dbUtil')
local conn = dbUtil.init() -- Establish DB connection at channel start

function main(Data)
   
   -- (1) Parise incoming data
   local jsonTbl = json.parse{data=Data}
   
   -- (2) Insert data into database
   dbUtil.insert(jsonTbl,conn)
   
end
