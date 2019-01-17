-- This module contains some helpful utility function

local conf = require('siteConfig')
require('dateparse')

local utils = {}

-- Description: Takes pdf contents and saves it in a binary file
--              with a new guid name and a '.pdf' extension
-- Parameter(s): 
--         - contents: base64 encoded pdf
-- Return(s):
--         - fileName: the name of the saved pdf file
function utils.savePDF(contents) 
   local fileName = conf.pdfFolder..util.guid(128)..'.pdf'
   local fHandle = io.open(fileName,'wb')
   fHandle:write(contents)
   fHandle:close()
   return fileName
end

-- Description: Takes html contents and saves it in a file
--              with a new guid name and a '.html' extension
-- Parameter(s): 
--         - contents: html
-- Return(s):
--         - fileName: the name of the saved html file
function utils.saveHtml(contents) 
   local fileName = conf.htmlFolder..util.guid(128)..'.html'
   local fHandle = io.open(fileName,'w')
   fHandle:write(contents)
   fHandle:close()
   return fileName
end

-- Description: Formats any dates for entry into CRM
--              If no date is provided or it is empty, 
--                 the current date is used
-- Parameter(s): 
--         - date: The incoming date as extracted
-- Return(s):
--         - date: The formatted date
function utils.formatDate(date)
   if date == nil or date == '' then 
      date = os.date('%x') 
   end
   
   if date:len() > 8 then 
      local tme = date:sub(9,date:len())
      tme = tme:sub(1,2)..':'..tme:sub(3,4)..':00'
      return date:D():split(' ')[1]..'T'..tme
   end
   
   return date:D():split(' ')[1]
end

-- Description: Returns a valid guid compatible with CRM
-- Parameter(s): NONE
-- Return(s):
--         - guid: the GUID
function utils.guid() 
   local id = util.guid(128):lower()
   local guid = id:sub(1,8)..'-'..id:sub(9,12)..'-'..id:sub(13,16)..'-'..id:sub(17,20)..'-'..id:sub(21,32)
   return guid
end

-- Description: Extracts the gender value from PID[8] 
--                 and maps it to a code for CCP optionset.
--                 Default is transgender
-- Parameter(s): 
--         - PID: The PID segment of the HL7 message
-- Return(s):
--         - code: The optionset code 
function utils.processGender(PID)
   local gender = PID[8]:nodeValue()
   local genderCodeMap = {['M'] = '100000000',['F'] = '100000001'}
   local code = genderCodeMap[gender]
   if code == nil then code = '111110000' end -- By default, set to Transgender
   return code
end

-- Description: Reads contents of provided filename
-- Parameter(s): 
--         - fileName: The full path to the file to be read
-- Return(s):
--         - contents: The complete contents of the file
function utils.readFile(fileName) 
   local fHandle = io.open(fileName)
   local contents = fHandle:read('*a')
   fHandle:close()
   return contents
end

-- Description: Reads contents of provided binary filename
-- Parameter(s): 
--         - fileName: The full path to the binary file to be read
-- Return(s):
--         - contents: The complete contents of the binary file
function utils.readBinaryFile(fileName) 
   local fHandle = io.open(fileName,'rb')
   local contents = fHandle:read('*a')
   fHandle:close()
   return contents
end

return utils 