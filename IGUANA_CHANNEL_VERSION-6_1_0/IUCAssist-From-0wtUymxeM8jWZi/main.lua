-- The main function is the first function called from Iguana.
local dbPath = '/root/orig/'
local dbName = 'Channel1.sqlite'

function init() 
	local conn = db.connect{api=db.SQLITE,
      name = dbPath..dbName}
  -- conn:execute{sql=[[DROP TABLE 'PatientData']],live=true}
  -- conn:execute{sql=createTable(),live=true}
 --  local x = conn:query{sql='SELECT * FROM PatientData',live=true}
   return conn
end

function createTable() 
	local sql = [[CREATE TABLE 'webAPI'
                      ('Instance' TEXT, 
                       'URL' TEXT,
                       'ChannelName' TEXT,
                        PRIMARY KEY('Instance'));]]
   
   return sql
end

function insert(jsonTbl,conn) 
    
  --local sqlStm = [[INSERT OR REPLACE INTO "webAPI" VALUES ('dev','10.211.55.44:6544','iucweb')]]
 -- local sqlStm = [[INSERT OR REPLACE INTO "webAPI" VALUES ('prod','10.211.55.45:6544','iucweb2')]]
   -- local sqlStm = [[DROP TABLE "webAPI"]]            
   trace(sqlStm)
   conn:execute{sql=sqlStm,live=true}
end

function main()
   local conn = init()
   --conn:execute{sql=createTable(),live=true}
  -- insert('',conn)
   conn:query{sql="SELECT * FROM 'webAPI'",live=true}
end