local serverType = os.getenv('serverTypeOrig')

local iucConf = {}

iucConf.dev = {
   -- Configurations for patient csv File
   ['patientCsvPath'] = '/root/orig/',
   ['patientCsvFile'] = 'PatientData.txt',
	
   -- Configurations for patient DB file
   ['patientDbPath'] = '/root/orig/',
   ['patientDbFile'] = 'myDB.sqlite'
}


iucConf.prod = {
   -- Configurations for patient csv File
   ['patientCsvPath'] = '/root/iuc/orig/',
   ['patientCsvFile'] = 'PatientData.txt',
	
   -- Configurations for patient DB file
   ['patientDbPath'] = '/root/iuc/orig/',
   ['patientDbFile'] = 'PatientData.sqlite'
}


return iucConf[serverType]
