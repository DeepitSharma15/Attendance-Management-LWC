import { LightningElement } from 'lwc';
import getUsers from '@salesforce/apex/AttendanceController.getUsers';
import punchIn from '@salesforce/apex/AttendanceController.punchIn';
import checkPunchIn from '@salesforce/apex/AttendanceController.checkPunchIn';
import punchOut from '@salesforce/apex/AttendanceController.punchOut';
import checkPuchOut from '@salesforce/apex/AttendanceController.checkPuchOut';


export default class PunchInOut extends LightningElement {
    currentDateTime; // Holds current date and time
    punchInTime;     // Holds punch in time
    punchOutTime;    // Holds punch out time
    totalTime;       
    isPunchedIn = false;  // Used to disable punch in button after punched in
    isPunchedOut = true;  // Used to disable punch out button before punching in
    isWorkFromHome = false; // Tracks if the user clicked "Work From Home"

    // To update current date and time every second
    connectedCallback() {
        this.checkPuncInStatus();
        this.checkPunchOutStatus();
        this.updateDateTime();
        this.intervalId = setInterval(() => {
            this.updateDateTime();
        }, 1000);
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
    }


    // Check Punch out Status when component is Connected
    checkPuncInStatus() {
        console.log("Inside Check Punch In Status: "+new Date());
        checkPunchIn({punchIn: new Date()} ).then(result => {
            console.log("Result: " + result);
            if(result == null) {
                console.log("Punch In result NUll");
                this.isPunchedIn = false;
            }
            else if(result){
                console.log("Getting... Result Wait...");
                //time = result.toISOString();
                //time = result.toLocaleTimeString();
                
                //console.log(time);
                console.log("Setting... the punchIn Time: "+result);
                this.punchInTime = result; 
                this.isPunchedIn = true;
                this.isPunchedOut = false;
                this.isWorkFromHome = true;  
            }
        }).catch(error => {
            console.log(error);
        })
    }

    checkPunchOutStatus() {
        console.log("Inside Check Punch Out Status: "+new Date());
        checkPuchOut({punchOutDate: new Date()} ).then(result => {
            console.log("Result for Punch Out: " + result);
            if(result == null) {
                console.log("Punch Out result Null");
                this.isPunchedOut = false;
            }
            else if(result){
                console.log("Getting... Result for Punch out Wait...");
                //time = result.toISOString();
                //time = result.toLocaleTimeString();
                
                //console.log(time);
                console.log("Setting... the punch out Time: "+result);
                this.punchOutTime = result;  
                this.isPunchedOut = true;
                this.totalTime = this.getTimeDifference(this.punchOutTime,this.punchInTime);

            }
        }).catch(error => {
            console.log(error);
        })
    }

    formatDateToHHMM(date) {
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        return `${hours}:${minutes}`;
    }

    // Function to update current date and time
    updateDateTime() {
        const now = new Date();
        this.currentDateTime = now.toISOString();
    }

    // Handle Punch In button click
    handlePunchIn() {
        console.log("Handle punchin")
        this.punchInTime = new Date().toLocaleTimeString();
        if (this.isPunchedIn) {
            this.error = 'You have already punched in for today.';
            return;
        }
        console.log("Punch In time in HandlePunchIN: " + this.punchInTime);


        punchIn({punchInTime: new Date(), isWorkFromHome:this.isWorkFromHome})
            .then(result => {
                
                this.isPunchedIn = true; 
                this.isPunchedOut = false;
                this.isWorkFromHome = true;
                this.error = ''; 
                alert(result);
            })
            .catch(error => {
                console.log("Error in Punch In" + error.body.message);
                alert(error.body.message);
                this.error = error.body.message; 
            });
    }

    

    // Handle Punch Out button click
    handlePunchOut() {
        console.log("punch out handle");
        this.punchOutTime = new Date().toLocaleTimeString();
        
        //this.punchOutTime = now.toLocaleTimeString();
        //this.isPunchedIn = false;
        // Imperative Method for updating the attendance record to punchout time
        console.log("Punch out Time: "+ this.punchOutTime);

        punchOut({punchOut: new Date()})
            .then(result => {

                //this.isPunchedIn = false;
                this.isPunchedOut = true;

                alert(result);
            })
            .catch(error => {
                console.log("Error in Punch Out" + error.body.message);
                alert(error.body.message);
                this.error = error.body.message;
            });


        // Calculate total time worked
        const punchInDate = new Date();
        const punchOutDate = new Date();

        const timeDifferenceMs = punchOutDate - punchInDate; // In milliseconds
        const totalHours = Math.floor(timeDifferenceMs / (1000 * 60 * 60)); // Convert to hours
        const totalMinutes = Math.floor((timeDifferenceMs % (1000 * 60 * 60)) / (1000 * 60)); // Convert to minutes

        this.totalTime = `${totalHours}h ${totalMinutes}m`;
    }

    // Handle Work From Home button click
    handleWorkFromHome() {

        this.punchInTime = new Date().toLocaleString();

        punchIn({punchInTime: new Date(), isWorkFromHome:this.isWorkFromHome})
            .then(result => {
                
                this.isPunchedIn = true; 
                this.isPunchedOut = true;
                this.isWorkFromHome = true;
                this.error = ''; 
                alert(result);
            })
            .catch(error => {
                console.log("Error in Punch In" + error.body.message);
                alert(error.body.message);
                this.error = error.body.message; 
            });
        
    }

    calculateTimeDifference() {
        const diff = this.getTimeDifference(this.time1, this.time2);
        this.difference = diff;
    }

    getTimeDifference(time1, time2) {
        const [h1, m1, s1] = time1.split(':').map(Number);
        const [h2, m2, s2] = time2.split(':').map(Number);

        // Convert times to total seconds
        const totalSeconds1 = h1 * 3600 + m1 * 60 + s1;
        const totalSeconds2 = h2 * 3600 + m2 * 60 + s2;

        // Calculate the difference in seconds
        const differenceInSeconds = Math.abs(totalSeconds1 - totalSeconds2);

        // Convert back to hh:mm:ss
        const hours = Math.floor(differenceInSeconds / 3600);
        const minutes = Math.floor((differenceInSeconds % 3600) / 60);
        const seconds = differenceInSeconds % 60;

        // Return formatted string
        return `${this.padNumber(hours)}:${this.padNumber(minutes)}:${this.padNumber(seconds)}`;
    }

    padNumber(num) {
        return String(num).padStart(2, '0'); // Ensure two digits
    }
}
