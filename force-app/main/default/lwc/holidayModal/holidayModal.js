import { LightningElement, track, api } from 'lwc';
// import { createRecord } from 'lightning/uiRecordApi';
// import HOLIDAY_OBJECT from '@salesforce/schema/Holiday__c'; // Adjust the object API name
// import NAME_FIELD from '@salesforce/schema/Holiday__c.Name';
// import HOLIDAY_TYPE_FIELD from '@salesforce/schema/Holiday__c.Type_of_Holiday__c';
// import HOLIDAY_DATE_FIELD from '@salesforce/schema/Holiday__c.Date__c';

export default class HolidayModal extends LightningElement {
    @track isOpen = false;
    @track name = '';
    @track holidayType = '';
    @track holidayDate = '';
    
    holidayTypeOptions = [
        { label: 'Public Holiday', value: 'Public Holiday' },
        { label: 'Company Holiday', value: 'Company Holiday' },
        // Add more options as needed
    ];

    @api openModal() {
        console.log("In Child Function of Open Modal");
        this.isOpen = true;
    }

    closeModal() {
        this.isOpen = false;
        this.resetForm();
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        if (field === 'name') {
            this.name = event.target.value;
        } else if (field === 'holidayType') {
            this.holidayType = event.target.value;
        } else if (field === 'holidayDate') {
            this.holidayDate = event.target.value;
        }
    }

    resetForm() {
        this.name = '';
        this.holidayType = '';
        this.holidayDate = '';
    }

    // handleCreateRecord() {
    //     const fields = {};
    //     fields[NAME_FIELD.fieldApiName] = this.name;
    //     fields[HOLIDAY_TYPE_FIELD.fieldApiName] = this.holidayType;
    //     fields[HOLIDAY_DATE_FIELD.fieldApiName] = this.holidayDate;

    //     const recordInput = { apiName: HOLIDAY_OBJECT.objectApiName, fields };

    //     createRecord(recordInput)
    //         .then(() => {
    //             this.closeModal();
    //             // Optionally, show a success message
    //             console.log('Record created successfully');
    //         })
    //         .catch(error => {
    //             console.error('Error creating record: ', error);
    //         });
    // }
}
