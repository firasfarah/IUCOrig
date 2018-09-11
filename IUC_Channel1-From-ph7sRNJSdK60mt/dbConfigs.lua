local dbConfigs = {}

local dbPath = 'C:\\TempFolder\\DB\\'
local dbName = 'Channel1.sqlite'

-- Initiate database connection
function dbConfigs.init() 
	local conn = db.connect{api=db.SQLITE,name = dbPath..dbName}
   return conn
end

-- Query the webAPI table in database to find config values
-- associated with this instance. 
-- This instance is retrieved from an environment variable 
-- 'serverType'
-- Returns webAPI URL and webAPI URL Page (webURL,webPage)
function dbConfigs.retrieve() 
   local conn = dbConfigs.init()
   local instance = os.getenv('serverType')
   local webInfo = conn:query("select * FROM 'webAPI' WHERE Instance='"..instance.."'")
   local webURL = webInfo[1].URL:nodeValue()
   local webPage = webInfo[1].ChannelName:nodeValue()
   conn:close()
   return webURL,webPage
end

return dbConfigs