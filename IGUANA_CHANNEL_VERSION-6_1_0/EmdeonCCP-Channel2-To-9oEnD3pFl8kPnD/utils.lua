require('dateparse')
local utils = {}

function utils.formatDate(date)
   if date == nil or date == '' then 
      date = os.date('%x') 
   end
   
   local dob = date:D():split(' ')[1]:split('-')
   return date:D():split(' ')[1]
end

function utils.guid() 
   local id = util.guid(128):lower()
   local guid = id:sub(1,8)..'-'..id:sub(9,12)..'-'..id:sub(13,16)..'-'..id:sub(17,20)..'-'..id:sub(21,32)
   return guid
end

function utils.processGender(PID)
   local gender = PID[8]:nodeValue()
   local genderCodeMap = {['M'] = '100000000',['F'] = '100000001'}
   local code = genderCodeMap[gender]
   if code == nil then code = '111110000' end -- By default, set to Transgender
   return code
end

function utils.readFile(fileName) 
   local fHandle = io.open(fileName)
   local contents = fHandle:read('*a')
   fHandle:close()
   return contents
end

function utils.readBinaryFile(fileName) 
   local fHandle = io.open(fileName,'rb')
   local contents = fHandle:read('*a')
   fHandle:close()
   return contents
end

return utils 