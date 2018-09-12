local iucConf = require('IUCConfigs')
local mapDB = {}


function mapDB.init() 
	local conn = db.connect{api=db.SQLITE,
      name = iucConf.patientDbPath..iucConf.patientDbFile}
 -- conn:execute{sql=[[DROP TABLE 'PatientData']],live=true}
  -- conn:execute{sql=mapDB.createTable(),live=true}
 --  local x = conn:query{sql='SELECT * FROM PatientData',live=true}
   return conn
end

function mapDB.createTable() 
	local sql = [[CREATE TABLE 'PatientData'
                      ('PatientId' INTEGER, 
                       'sex' TEXT,
                       'FirstName' TEXT,
                       'LastName'  TEXT,
                       'DateOfBirth'  TEXT,
                       'SSN' INTEGER,
                        PRIMARY KEY(PatientId));]]
   
   return sql
end

function mapDB.insert(jsonTbl,conn) 
    local sqlStm = [[INSERT OR REPLACE INTO PatientData VALUES (']]..
                      jsonTbl['patientId'].."','" ..jsonTbl['sex'].."','"..jsonTbl['firstName']..
                 "','"..jsonTbl['lastName'].."','"..jsonTbl['dob'].."','"..jsonTbl['ssn'].."')"
   trace(sqlStm)
   conn:execute{sql=sqlStm,live=true}
end

return mapDB