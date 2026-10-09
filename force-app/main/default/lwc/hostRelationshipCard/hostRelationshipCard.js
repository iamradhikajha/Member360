import { LightningElement, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import USER_NAME from '@salesforce/schema/User.Name';
import USER_PHOTO from '@salesforce/schema/User.SmallPhotoUrl';
import USER_LAST_CONTACT from '@salesforce/schema/User.Last_Contact__c';
import USER_PREFERRED_CONTACT from '@salesforce/schema/User.Preferred_Contact__c';
import USER_NEXT_FOLLOW_UP from '@salesforce/schema/User.Next_Follow_up__c';
import USER_NOTES from '@salesforce/schema/User.Notes__c';
import updateHostRelationship from '@salesforce/apex/Member360Controller.updateHostRelationship';

export default class HostRelationshipCard extends LightningElement {
    isHostEditOpen = false;
    hostSaving = false;
    currentUserId = USER_ID;
    currentUserName;
    currentUserPhoto;
    currentUserLastContact;
    currentUserPreferredContact;
    currentUserNextFollowUp;
    currentUserNotes;
    hostPreferredContactOptions = [];
    hostEditData = { hostUserId: '', lastContact: null, preferredContact: '', nextFollowUp: null, notes: ''};

    @wire(getRecord, {
        recordId: '$currentUserId',
        fields: [
            USER_NAME,
            USER_PHOTO,
            USER_LAST_CONTACT,
            USER_PREFERRED_CONTACT,
            USER_NEXT_FOLLOW_UP,
            USER_NOTES
        ]
    })
    wiredCurrentUser({ data, error }) {
        if (data) {
            this.currentUserName = data.fields.Name?.value || '';
            this.currentUserPhoto = data.fields.SmallPhotoUrl?.value || '';
            this.currentUserLastContact = data.fields.Last_Contact__c?.value || null;
            this.currentUserPreferredContact = data.fields.Preferred_Contact__c?.value || '';
            this.currentUserNextFollowUp = data.fields.Next_Follow_up__c?.value || null;
            this.currentUserNotes = data.fields.Notes__c?.value || '';
        } else if (error) {
            console.error('Current User Error:', error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: USER_PREFERRED_CONTACT
    })
    wiredHostPreferredContactPicklist({ data, error }) {
        if (data) {
            this.hostPreferredContactOptions = data.values || [];
        } else if (error) {
            console.error('User Preferred Contact Picklist Error:', JSON.stringify(error));
            this.hostPreferredContactOptions = [];
        }
    }

    get hostName() {
        return this.currentUserName || 'Current User';
    }

    get hostPhotoUrl() {
        return this.currentUserPhoto || '/img/icon/profile32.png';
    }

    get hostLastContact() {
        return this.currentUserLastContact;
    }

    get hostNextFollowUp() {
        return this.currentUserNextFollowUp;
    }

    get hostNotes() {
        return this.currentUserNotes || '';
    }

    get preferredContactOptions() {
        const contactValue = this.currentUserPreferredContact;
        if (!contactValue) {
            return [];
        }
        const lowerValue = contactValue.toLowerCase();
        let icon = '•';
        let iconClass = 'contactIcon defaultIcon';
        switch (lowerValue) {
            case 'whatsapp':
                icon = '◉';
                iconClass = 'contactIcon whatsappIcon';
                break;
            case 'instagram':
                icon = '◎';
                iconClass = 'contactIcon instagramIcon';
                break;
            case 'email':
                icon = '✉';
                iconClass = 'contactIcon emailIcon';
                break;
            case 'sms':
                icon = '▣';
                iconClass = 'contactIcon smsIcon';
                break;
            case 'phone call':
                icon = '☎';
                iconClass = 'contactIcon phoneIcon';
                break;
            case 'website':
                icon = '🌐';
                iconClass = 'contactIcon websiteIcon';
                break;
            case 'push notification':
                icon = '🔔';
                iconClass = 'contactIcon notificationIcon';
                break;
            case 'web chat':
                icon = '💻';
                iconClass = 'contactIcon webChatIcon';
                break;
            case 'mobile app':
                icon = '📱';
                iconClass = 'contactIcon mobileAppIcon';
                break;
            case 'facebook':
                icon = 'f';
                iconClass = 'contactIcon facebookIcon';
                break;
            case 'x':
                icon = '𝕏';
                iconClass = 'contactIcon xIcon';
                break;
            case 'youtube':
                icon = '▶';
                iconClass = 'contactIcon youtubeIcon';
                break;
            default:
                icon = '•';
                iconClass = 'contactIcon defaultIcon';
        }
        return [{ value: contactValue, label: contactValue, icon, iconClass}];
    }

    handleHostEdit() {
        this.isHostEditOpen = true;
        this.hostEditData = {
            hostUserId: this.currentUserId,
            lastContact: this.currentUserLastContact || null,
            preferredContact: this.currentUserPreferredContact || '',
            nextFollowUp: this.currentUserNextFollowUp || null,
            notes: this.currentUserNotes || ''
        };
    }

    handleHostFieldChange(event) {
        const field = event.target.dataset.field;
        this.hostEditData = {...this.hostEditData,[field]: event.detail?.value ?? event.target.value};
    }

    handleHostContactChange(event) {
        this.hostEditData = {...this.hostEditData,preferredContact: event.detail.value};
    }

    closeHostEdit() {
        if (this.hostSaving) return;
        this.isHostEditOpen = false;
        this.hostEditData = { hostUserId: '', lastContact: null, preferredContact: '', nextFollowUp: null, notes: ''};
    }

    handleHostModalOutsideClick(event) {
        if (event.target === event.currentTarget) this.closeHostEdit();
    }

    async saveHostRelationship() {
        if (this.hostSaving) return;
        this.hostSaving = true;
        try {
            const preferredContact = this.hostEditData.preferredContact || '';
            const updatedHostData = { lastContact: this.hostEditData.lastContact, preferredContact, nextFollowUp: this.hostEditData.nextFollowUp, notes: this.hostEditData.notes};
            await updateHostRelationship({
                hostUserId: this.hostEditData.hostUserId,
                lastContact: updatedHostData.lastContact,
                preferredContact: updatedHostData.preferredContact,
                nextFollowUp: updatedHostData.nextFollowUp,
                notes: updatedHostData.notes
            });
            this.currentUserLastContact = updatedHostData.lastContact;
            this.currentUserPreferredContact = updatedHostData.preferredContact;
            this.currentUserNextFollowUp = updatedHostData.nextFollowUp;
            this.currentUserNotes = updatedHostData.notes;
            this.isHostEditOpen = false;
            this.hostEditData = { hostUserId: '', lastContact: null, preferredContact: '', nextFollowUp: null, notes: ''};
            this.dispatchEvent(
                new ShowToastEvent({ title: 'Success', message: 'Host & Relationship updated successfully.', variant: 'success'}));
        } catch (error) {
            let message = 'Unable to update Host & Relationship.';
            if (error?.body?.message)message = error.body.message;
            else if (error?.message) message = error.message;
            this.dispatchEvent(
                new ShowToastEvent({ title: 'Update Failed', message, variant: 'error', mode: 'sticky'}));
        } finally {
            this.hostSaving = false;
        }
    }
}