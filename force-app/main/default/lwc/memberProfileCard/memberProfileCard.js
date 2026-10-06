import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LOYALTY_MEMBER_OBJECT from '@salesforce/schema/LoyaltyProgramMember';
import SEGMENT_FIELD from '@salesforce/schema/LoyaltyProgramMember.Segment__c';
import LANGUAGE_FIELD from '@salesforce/schema/LoyaltyProgramMember.Preferred_Language__c';
import CHANNEL_FIELD from '@salesforce/schema/LoyaltyProgramMember.Preferred_Channel__c';
import NATIONALITY_FIELD from '@salesforce/schema/LoyaltyProgramMember.Nationality__c';
import PROPERTY_FIELD from '@salesforce/schema/LoyaltyProgramMember.Property__c';
import PREFERRED_GAME_FIELD from '@salesforce/schema/LoyaltyProgramMember.Preferred_Game__c';
import updateMemberProfile from '@salesforce/apex/Member360Controller.updateMemberProfile';

export default class MemberProfileCard extends LightningElement {
    @api member;

    isModalOpen = false;
    modalTitle = '';

    @wire(getObjectInfo, {
        objectApiName: LOYALTY_MEMBER_OBJECT
    })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: PREFERRED_GAME_FIELD
    })
    wiredPreferredGamePicklist;

    get preferredGameOptions() {
        return this.wiredPreferredGamePicklist?.data?.values || [];
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: SEGMENT_FIELD
    })
    wiredSegmentPicklist;

    get segmentOptions() {
        return this.wiredSegmentPicklist?.data?.values || [];
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: LANGUAGE_FIELD
    })
    wiredLanguagePicklist;

    get languageOptions() {
        return this.wiredLanguagePicklist?.data?.values || [];
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: CHANNEL_FIELD
    })
    wiredChannelPicklist;

    get channelOptions() {
        return this.wiredChannelPicklist?.data?.values || [];
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: NATIONALITY_FIELD
    })
    wiredNationalityPicklist;

    get nationalityOptions() {
        return this.wiredNationalityPicklist?.data?.values || [];
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: PROPERTY_FIELD
    })
    wiredPropertyPicklist;

    get propertyOptions() {
        return this.wiredPropertyPicklist?.data?.values || [];
    }

    get segmentClass() {
        const segment = (this.member?.Segment__c || '').trim().toLowerCase();

        switch (segment) {
            case 'basic':
                return 'segmentBadge Basic';

            case 'premium':
                return 'segmentBadge Premium';

            case 'vvip':
                return 'segmentBadge VVIP';

            case 'business':
                return 'segmentBadge Business';

            default:
                return 'segmentBadge default';
        }
    }

    handleEdit() {
        this.isModalOpen = true;
        this.modalTitle = 'Edit Member Profile';

        const preferredChannel = this.member?.Preferred_Channel__c
            ? this.member.Preferred_Channel__c
                  .split(';')
                  .map(value => value.trim())
                  .filter(value => value)
            : [];

        this.editData = {
            gamingSegment: this.member?.Segment__c || '',
            preferredLanguage: this.member?.Preferred_Language__c || '',
            preferredChannel,
            nationality: this.member?.Nationality__c || '',
            property: this.member?.Property__c || '',
            preferredGame: this.member?.Preferred_Game__c || ''
        };
    }

    handleFieldChange(event) {
        const field = event.target.dataset.field;

        this.editData = {
            ...this.editData,
            [field]: event.detail?.value ?? event.target.value
        };
    }

    handleChannelChange(event) {
        this.editData = {
            ...this.editData,
            preferredChannel: event.detail.value
        };
    }

    async handleSave() {
        try {
            const preferredChannel = Array.isArray(this.editData.preferredChannel)
                ? this.editData.preferredChannel.join(';')
                : this.editData.preferredChannel || '';

            const updatedData = {
                segment: this.editData.gamingSegment,
                preferredLanguage: this.editData.preferredLanguage,
                preferredChannel,
                nationality: this.editData.nationality,
                property: this.editData.property,
                preferredGame: this.editData.preferredGame
            };

            await updateMemberProfile({
                memberId: this.member.Id,
                segment: updatedData.segment,
                preferredLanguage: updatedData.preferredLanguage,
                preferredChannel: updatedData.preferredChannel,
                nationality: updatedData.nationality,
                property: updatedData.property,
                preferredGame: updatedData.preferredGame
            });

            this.dispatchEvent(
                new CustomEvent('segmentchange', {
                    detail: updatedData,
                    bubbles: true,
                    composed: true
                })
            );

            this.closeModal();

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Member Profile updated successfully.',
                    variant: 'success'
                })
            );
        } catch (error) {
            let message = 'Unable to update Member Profile.';

            if (error?.body?.message) {
                message = error.body.message;
            } else if (error?.message) {
                message = error.message;
            }

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Update Failed',
                    message,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        }
    }

    handleCancel() {
        this.closeModal();
    }

    closeModal() {
        this.isModalOpen = false;
        this.modalTitle = '';
        this.editData = {};
    }

    handleModalOutsideClick(event) {
        if (event.target === event.currentTarget) {
            this.closeModal();
        }
    }
}