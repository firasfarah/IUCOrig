local jsonR = {}

local data = {}
data.Sex = {'M', 'F'}
data.LastNames = {'Muir','Smith','Adams','Garland', 'Meade', 'Fitzgerald', 'WHITE'}
data.MaleNames = {'Fred','Jim','Gary','John'}
data.FemaleNames = {'Mary','Sabrina','Tracy'}
data.Race = {'AI', 'EU', 'Mixed', 'Martian', 'Unknown'}
data.Street = {'Delphi Cres.', 'Miller Lane', 'Yonge St.', 'Main Rd.'}
data.Relation = {'Grandchild', 'Second Cousin', 'Sibling', 'Parent'}
data.Event = {'A01', 'A03', 'A04', 'A05', 'A06', 'A07', 'A08'}
data.Facility = {'Lab', 'E&R'}
data.Application = { 'AcmeMed', 'MedPoke', 'CowZing' }
data.Locations = { {'Chicago', 'IL'}, {'Toronto', 'ON'}, {'ST. LOUIS', 'MO'}, {'LA', 'CA'} }
local a = 2
local function rand(In, Max, Size)
   local Result = tostring((In + math.random(Max)) % Max)
   if '0' == Result then
      Result = '1'
   end
   
   while Size > Result:len() do
      Result = '0'..Result
   end
   return Result
end

local function ranChoose(T)
   return T[math.random(#T)]
end

local function ranPID() 
   local pid = math.random(100,10000)
   return pid
end

local function ranTimeStamp()
   local T = os.date('*t')
   
   local newDate = '20'..rand(T.year,tostring(T.year):sub(-2),2)..
   rand(T.month,12,2)..
   rand(T.day,29,2)..
   rand(T.hour,12,2)..
   rand(T.min,60,2)..
   rand(T.sec,60,2)
   
   return newDate
end


local function ranLastName() return ranChoose(data.LastNames) end

local function ranDate()
   local T = os.date('*t')
  
   local newDate = '19'..rand(T.year,99,2)..
   rand(T.month,12,2)..
   rand(T.day,29,2)
   
   return newDate
end

local function ranAcctNo()
   return math.random(99)..'-'..math.random(999)..'-'..math.random(999)
end

local function ranLocation()
   local R = ranChoose(data.Locations)
   return R[1], R[2]
end

local function ranSSN()
   return math.random(999)..'-'
          ..math.random(999)..'-'
          ..math.random(999)
end

local function ranFirstName()
   if math.random(2) == 1 then
      return ranChoose(data.MaleNames)
   else   
      return ranChoose(data.FemaleNames)      
   end
end

function jsonR.makeTable(n) 
   local jsonTable = {}
   for k = 1,n do 
      jsonTable[k] = {}
      jsonTable[k].patientId = ranPID()
      jsonTable[k].firstName = ranFirstName()
      jsonTable[k].lastName = ranLastName()
      jsonTable[k].sex = data.Sex[math.random(2)]
      jsonTable[k].ssn = ranSSN()
      jsonTable[k].dob = ranDate()
   end
   return jsonTable 
end

return jsonR