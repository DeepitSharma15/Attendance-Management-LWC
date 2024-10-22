public with sharing class AttendanceController {

    // Adding comment by LJ
    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        Id currentUserId = UserInfo.getUserId(); // Get the current user ID
        return [SELECT Id, Name FROM User WHERE Id = :currentUserId];
    }

    @AuraEnabled
    public static String punchIn(Datetime punchInTime, Boolean isWorkFromHome) {
        Id currentUserId = UserInfo.getUserId();
        System.debug('Current User ID: ' + currentUserId);

        // Find the current User (acting as Employee)
        User currentUser = [SELECT Id, Name, Email FROM User WHERE Id = :currentUserId LIMIT 1];

        // Get the current month and year
        Integer currentMonth = Date.today().month();
        Integer currentYear = Date.today().year();
        String monthAsString = getMonthAsString(currentMonth);

        // Check for the existing Employee record
        Employee__c employeeRecord;
        List<Employee__c> employeeRecords = [SELECT Id FROM Employee__c WHERE User__c = :currentUserId LIMIT 1];

        if (employeeRecords.isEmpty()) {
            // Create new Employee record
            employeeRecord = new Employee__c();
            employeeRecord.User__c = currentUserId; // Assuming User__c is a lookup to the User object
            employeeRecord.Name = currentUser.Name; // Set the name or other relevant fields
            insert employeeRecord;
        } else {
            employeeRecord = employeeRecords[0];
        }
       

        // Check for the existing Monthly Attendance record
        List<Monthly_Attendance__c> monthlyAttendances = [
            SELECT Id, Present__c 
            FROM Monthly_Attendance__c 
            WHERE Employee__c = :employeeRecord.Id  
            AND Month__c = :monthAsString 
            AND Year__c = :currentYear 
            LIMIT 1
        ];

        Monthly_Attendance__c monthlyAttendance;

        Date startDate = Date.today().toStartOfMonth();
        Date endDate = Date.today().toStartOfMonth().addDays(Date.daysInMonth(currentYear, currentMonth) - 1); 

        // Number of Holidays from holiday object
        Integer numberOfHolidays = [
                    SELECT COUNT()
                    FROM Holiday_Year_Wise__c
                    WHERE Date__c >= :startDate
                    AND Date__c <= :endDate
                    ]; 

        // Number of Weekends in a month
        Integer weekendCount = 0;
        // Loop through each day of the month
        for (Date currentDay = startDate; currentDay <= endDate; currentDay = currentDay.addDays(1)) {
            // Check if the current day is Saturday (6) or Sunday (7)
            Integer dayOfWeek = currentDay.day();
            if (dayOfWeek == 6 || dayOfWeek == 7) {
                weekendCount+=2;
            }
        }

        // Create Monthly Attendance record if it doesn't exist
        if (monthlyAttendances.isEmpty()) {
            monthlyAttendance = new Monthly_Attendance__c();
            monthlyAttendance.Employee__c = employeeRecord.Id; // Set Employee ID
            monthlyAttendance.Month__c = monthAsString; // Set month as string
            monthlyAttendance.Year__c = currentYear; // Set year directly
            monthlyAttendance.Start_Date__c = Date.today().toStartOfMonth();
            monthlyAttendance.End_Date__c = Date.today().toStartOfMonth().addDays(Date.daysInMonth(currentYear, currentMonth) - 1);
            monthlyAttendance.Total_Days__c = Decimal.valueOf(Date.daysInMonth(currentYear, currentMonth));
            monthlyAttendance.Present__c = 0; // Initialize Present count
            monthlyAttendance.Absent__c = 0; // Initialize Absent count
            monthlyAttendance.Holiday__c = numberOfHolidays;
            monthlyAttendance.Weekends__c = weekendCount;

            // Check for required fields
            if (monthlyAttendance.Employee__c == null || monthlyAttendance.Month__c == null || 
                monthlyAttendance.Year__c == null || monthlyAttendance.Start_Date__c == null || 
                monthlyAttendance.End_Date__c == null || monthlyAttendance.Total_Days__c == null) {
                return 'Error: Required fields for Monthly Attendance are not set.';
            }

            // Debugging output before insert
            System.debug('Monthly Attendance Fields Before Insert: ' + monthlyAttendance);

            // Insert the Monthly Attendance record
            try {
                insert monthlyAttendance;
            } catch (Exception e) {
                System.debug('Insert Monthly Attendance Error: ' + e.getMessage());
                return 'Failed to create monthly attendance: ' + e.getMessage();
            }
        } else {
            monthlyAttendance = monthlyAttendances[0];
        }

        // Check if the user has already punched in today
        List<Attendance__c> attendanceRecords = [
            SELECT Id, Punch_In__c 
            FROM Attendance__c 
            WHERE Employee__c = :employeeRecord.Id 
            AND DAY_ONLY(Punch_In__c) = :Date.today() 
            LIMIT 1
        ];

        if (!attendanceRecords.isEmpty()) {
            return 'You Have Punched In' + String.valueOf(attendanceRecords[0].get('Punch_In__c')) + '.';
        }

        // Create the Attendance record
        Attendance__c newAttendance = new Attendance__c();
        newAttendance.Employee__c = employeeRecord.Id; // Set Employee ID
        newAttendance.Punch_In__c = punchInTime;
        newAttendance.Work_From_Home__c = isWorkFromHome;
        newAttendance.Monthly_Attendance__c = monthlyAttendance.Id; // Set Monthly Attendance ID as master-detail reference
        
        // Increment Present count
        monthlyAttendance.Present__c += 1;
        // Updating Absence at the end of month
        Integer today = Integer.valueOf(punchInTime.day());
        if(Decimal.valueof(today) == monthlyAttendance.Total_Days__c) {
            // Set Absent count
            monthlyAttendance.Absent__c = monthlyAttendance.Total_Days__c - monthlyAttendance.Present__c - monthlyAttendance.Holiday__c;
        }

        // Debugging output before update
        System.debug('Updating Monthly Attendance: ' + monthlyAttendance);
        try {
            update monthlyAttendance;
        } catch (Exception e) {
            System.debug('Update Monthly Attendance Error: ' + e.getMessage());
            return 'Failed to update monthly attendance: ' + e.getMessage();
        }

        // Insert Attendance record
        try {
            insert newAttendance;
        } catch (Exception e) {
            System.debug('Insert Attendance Error: ' + e.getMessage());
            return 'Failed to create attendance record: ' + e.getMessage();
        }
        
        return 'Punch In successful. Attendance record created.';
    }

    // Helper method to convert month number to month string
    private static String getMonthAsString(Integer month) {
        String monthString; // Initialize the monthString variable
        switch on month {
            when 1 {
                monthString = 'January';
            }
            when 2 {
                monthString = 'February';
            }
            when 3 {
                monthString = 'March';
            }
            when 4 {
                monthString = 'April';
            }
            when 5 {
                monthString = 'May';
            }
            when 6 {
                monthString = 'June';
            }
            when 7 {
                monthString = 'July';
            }
            when 8 {
                monthString = 'August';
            }
            when 9 {
                monthString = 'September';
            }
            when 10 {
                monthString = 'October';
            }
            when 11 {
                monthString = 'November';
            }
            when 12 {
                monthString = 'December';
            }
            when else {
                monthString = 'Invalid month'; // Handle invalid month
            }
        }
        return monthString; // Return the month string
    }

    @AuraEnabled
    public static String checkPunchIn(Datetime punchIn) {

        Id currentUserId = UserInfo.getUserId();
        Employee__c employeeRecord = [SELECT Id, Name, User__c FROM Employee__c WHERE User__c = :currentUserId LIMIT 1];
        List<Attendance__c> attendanceRecords = [
            SELECT Id, Punch_In__c 
            FROM Attendance__c 
            WHERE Employee__c = :employeeRecord.Id 
            AND DAY_ONLY(Punch_In__c) = :Date.today() 
            LIMIT 1
        ];

        Datetime dt = Datetime.valueOf(attendanceRecords[0].get('Punch_In__c'));
        Date dateOnly = dt.date();
        String timeOnly = String.valueOf(dt.time()).substring(0,8);
        Integer num = Integer.valueOf(timeOnly.substring(0,2));
        if(num > 12) {
            num = num - 12;
        }

        String timeString = String.valueOf(num) + timeOnly.substring(2,8);

        
        //return Datetime.valueOf(attendanceRecords[0].get('Punch_In__c'));
        return timeString;

    }
    //Update the attendance record function 

    @AuraEnabled
    public static String punchOut(Datetime punchOut) {
        Id currentUserId = UserInfo.getUserId();
        Employee__c employeeRecord = [SELECT Id, Name, User__c FROM Employee__c WHERE User__c = :currentUserId LIMIT 1];

        List<Attendance__c> attendanceRecords = [
            SELECT Id, Punch_In__c 
            FROM Attendance__c 
            WHERE Employee__c = :employeeRecord.Id 
            AND DAY_ONLY(Punch_In__c) = :Date.today() 
            LIMIT 1];
        
        attendanceRecords[0].Punch_Out__c = punchOut;
        update attendanceRecords[0];

        return 'Punch Out successful. Attendance record updated.';
    }

    // Checking Punch Out or Not 
    @AuraEnabled
    public static String checkPuchOut(Datetime punchOutDate) {

        Id currentUserId = UserInfo.getUserId();
        Employee__c employeeRecord = [SELECT Id, Name, User__c FROM Employee__c WHERE User__c = :currentUserId LIMIT 1];
        List<Attendance__c> attendanceRecords = [
            SELECT Id, Punch_Out__c 
            FROM Attendance__c 
            WHERE Employee__c = :employeeRecord.Id 
            AND DAY_ONLY(Punch_Out__c) = :Date.today() 
            LIMIT 1
        ];


        Datetime dt = Datetime.valueOf(attendanceRecords[0].get('Punch_Out__c'));
        Date dateOnly = dt.date();
        String timeOnly = String.valueOf(dt.time()).substring(0,8);
        
        Integer num = Integer.valueOf(timeOnly.substring(0,2));
        if(num > 12) {
            num = num - 12;
        }

        String timeString = String.valueOf(num) + timeOnly.substring(2,8);

        
        //return Datetime.valueOf(attendanceRecords[0].get('Punch_Out__c'));
        return timeString;

    }



}
