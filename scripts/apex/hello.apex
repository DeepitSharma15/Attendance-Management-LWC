// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

//     Integer month = Date.today().month();
//     Integer year = Date.today().year();

// Date startDate = Date.today().toStartOfMonth();
// Date endDate = Date.today().toStartOfMonth().addDays(Date.daysInMonth(year, month) - 1); 

// //         // Number of Holidays from holiday object
// //         Integer numberOfHolidays = [
// //                     SELECT COUNT()
// //                     FROM Holiday_Year_Wise__c
// //                     WHERE Date__c >= :startDate
// //                     AND Date__c <= :endDate
// //                     ]; 
// //         System.debug('Number of Holidays:'+numberOfHolidays);

//     Integer weekendCount = 0;

//         // Get the first day of the mont

//         // Loop through each day of the month
//         for (Date currentDay = startDate; currentDay <= endDate; currentDay = currentDay.addDays(1)) {
//             // Check if the current day is Saturday (6) or Sunday (7)
//             Integer dayOfWeek = currentDay.day();
//             if (dayOfWeek == 6 || dayOfWeek == 7) {
//                 weekendCount++;
//             }
//         }
        
//         System.debug('Weekend Count: '+weekendCount*2);
//         System.debug('Final Week/Weekend Count: '+weekendCount);

//         // Updating Absence at the end of month
//         Id currentUserId = UserInfo.getUserId();
//         Employee__c employeeRecord = [SELECT Id, Name, User__c FROM Employee__c WHERE User__c = :currentUserId LIMIT 1];
//         String currentMonth = 'October';
//         List<Monthly_Attendance__c> monthlyAttendances = [
//     SELECT Id, Present__c 
//     FROM Monthly_Attendance__c 
//     WHERE Employee__c = :employeeRecord.Id  
//     AND Month__c = :currentMonth
//     AND Year__c = :Date.today().year() 
//     LIMIT 1
// ];

//         Monthly_Attendance__c monthlyAttendance = monthlyAttendances[0];
//         Datetime today = Date.today();
//         Decimal absentCount = 0;
//         if(today == Datetime.valueOf(endDate)) {
//             // Set Absent count
//             Decimal absentCount = monthlyAttendance.Total_Days__c - monthlyAttendance.Present__c - monthlyAttendance.Holiday__c - weekendCount;
//             monthlyAttendance.Absent__c = absentCount;
//         }
//         System.debug('Number of Absent Count: '+ absentCount);