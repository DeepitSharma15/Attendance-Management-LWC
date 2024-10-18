import { LightningElement } from 'lwc';
import FullCalendarJS from '@salesforce/resourceUrl/fullCalendar2';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class CalendarForLeave extends LightningElement {
    connectedCallback() {
        Promise.all([
            loadStyle(this, FullCalendarJS + '/lib/main.css'),
            loadScript(this, FullCalendarJS + '/lib/main.js')
        ])
        .then(() => {
            this.initializeCalendar();
        })
        .catch(error => console.log(error))
    }
    initializeCalendar() { 
        const calendarEl = this.template.querySelector('div.fullcalendar');
        const calendar = new FullCalendar.Calendar(calendarEl, {});
        calendar.render();
    }

    openModal() {
        console.log("In Parent Function");
        const modal = this.template.querySelector('c-holiday-modal');
        modal.openModal();
    }


}