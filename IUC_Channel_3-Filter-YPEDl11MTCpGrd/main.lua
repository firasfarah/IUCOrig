-- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.
local mapHL7 = require('mapHL7')

function main(Data)
   -- (1) Parse the JSON string coming in from the queue
   local patientTable = json.parse{data=Data}
   
   -- (2) Create an empty HL7 ADT message to map pateint info
   local Msg,Nme = hl7.message{vmd='IUCDemo.vmd',name='ADT'}
   
   -- (3) Map the HL7 message
   mapHL7.mapMsg(Msg,patientTable)
   
   -- (4) Push the message to queue for ftp upload
   queue.push{data=tostring(Msg)}
   
end