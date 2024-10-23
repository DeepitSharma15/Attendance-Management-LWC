public with sharing class UserHolidayController {
    // comment for testing merge Rebase
    @AuraEnabled
    public static String createHolidayRecord(String name, Date holidayDate, String holidayType, Date holidayEndDate) {
        Id currentUserId = UserInfo.getUserId();
        System.debug('Current User ID: ' + currentUserId);

        // Find the current User (acting as Employee)
        User currentUser = [SELECT Id, Name, Email FROM User WHERE Id = :currentUserId LIMIT 1];

        //Checking there is Employee or not
        String employeeRecordId;
        List<Employee__c> employeeRecords = [SELECT Id FROM Employee__c WHERE User__c = :currentUserId LIMIT 1];

        if (employeeRecords.isEmpty()) {
            // Create new Employee record
            Employee__c employee = new Employee__c();
            employee.User__c = currentUserId; 
            employee.Name = currentUser.Name; // Set the name or other relevant fields
            insert employee;
            employeeRecordId = employee.Id;
          
        } else {
            employeeRecordId = String.valueOf(employeeRecords[0].get('Id'));
        }
        System.debug(holidayEndDate);

        try {
            User_Holiday__c userHoliday = new User_Holiday__c();
            userHoliday.Name = name;
            userHoliday.Employee__c = employeeRecordId;
            userHoliday.Holiday_Date__c = holidayDate;
            userHoliday.Holiday_Type__c = holidayType;
            userHoliday.Holiday_End_Date__c = holidayEndDate;
            // System.debug('User Holiday Data: ',userHoliday);
            insert userHoliday;
            return 'Created a Holiday Record of ' + name + ' with the date ' + holidayDate.day() + ' as ' + holidayType;
        } catch (Exception e) {
            System.debug('Insert Attendance Error: ' + e.getMessage());
            return 'Failed to create attendance record: ' + e.getMessage();
        }
    }

    @AuraEnabled
        public static List<User_Holiday__c> getUserHolidays() {
            List<User_Holiday__c> listOfHolidays;
            try {
                listOfHolidays = [SELECT Id, Holiday_Type__c, Holiday_Date__c, Holiday_End_Date__c, Name FROM User_Holiday__c];
            } catch(Exception e) {
                
                System.debug('Get User Holidays Error: ' + e.getMessage());
            }
            if(listOfHolidays.isEmpty()) {
                return null;
            }
            else {
                return listOfHolidays;
            }
            
        }


            

    

    
}