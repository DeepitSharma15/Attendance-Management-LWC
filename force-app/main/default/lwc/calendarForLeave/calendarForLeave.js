import { LightningElement, track } from 'lwc';
import FullCalendarJS from '@salesforce/resourceUrl/fullCalendar2';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from "lightning/navigation";
import {showToastEvent} from 'lightning/platformShowToastEvent';
import getUserHolidays from '@salesforce/apex/UserHolidayController.getUserHolidays';

export default class CalendarForLeave extends LightningElement {
    @track showModal = false;
    @track modalTitle = '';
    @track modalDetails = '';

    connectedCallback() {
        this.fetchingHolidayRecord();
        Promise.all([
            loadStyle(this, FullCalendarJS + '/lib/main.css'),
            loadScript(this, FullCalendarJS + '/lib/main.js')
        ])
        .then(() => {
            this.initializeCalendar();
        })
        .catch(error => console.log(error))
    }
    holidayList = [];

    fetchingHolidayRecord() {
        getUserHolidays()
            .then(result => {
                console.log(result);

                for(let holiday of result) {    
                    console.log("In for:")
                    let holidayEvent = {
                    id: holiday.Name,
                    editable: true, 
                    allDay : false,
                    start: holiday.Holiday_Date__c,
                    end: holiday.Holiday_End_Date__c,
                    title: holiday.Holiday_Type__c
                }     
                this.holidayList.push(holidayEvent);

        }
        console.log('this is Outer for and list is:',JSON.stringify(this.holidayList));
        this.initializeCalendar();
            })
            .catch(error => console.log(error))
    }
    
           
    initializeCalendar() { 
        //console.log('Intialize Calendar and list is: '+this.holidayList);
        //list = this.holidayList;
        console.log('Intialize Calendar and list is:',JSON.stringify(this.holidayList));

        if(1) {
        const calendarEl = this.template.querySelector('div.fullcalendar');
        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialDate: new Date(),
            showNonCurrentDates: false,
            fixedWeekCount: false,
            allDaySlot: false,
            navLinks: false,
            events: this.holidayList,
            eventClick: this.handleEventClick.bind(this),
        });
        calendar.render();
        }


    }
    

    
    
    openModal() {
        console.log("In Parent Function");
        const modal = this.template.querySelector('c-holiday-modal');
        modal.openModal();
    }

    handleEventClick(info) {
        console.log("Event Clicked!",info.event.title);
        this.modalTitle = info.event.title;
        this.modalDetails = info.event.id;
        this.showModal = true;
    }

    closeUserDetailModal() {
        this.showModal = false;
    }


}