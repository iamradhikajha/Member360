import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LOYALTY_MEMBER_OBJECT from '@salesforce/schema/LoyaltyProgramMember';
import SEGMENT_FIELD from '@salesforce/schema/LoyaltyProgramMember.Segment__c';

import updateMemberSegment from '@salesforce/apex/Member360Controller.updateMemberSegment';

export default class MemberSummaryCards extends LightningElement {
    @api member;

    isModalOpen = false;
    isProfileEdit = false;
    modalTitle = '';
    editData = {};

    @wire(getObjectInfo, {
        objectApiName: LOYALTY_MEMBER_OBJECT
    })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: SEGMENT_FIELD
    })
    wiredSegmentPicklist;

    get segmentOptions() {
        return this.wiredSegmentPicklist?.data?.values || [];
    }

    get segmentClass() {
        const segment = (this.member?.Segment__c || '')
            .trim()
            .toLowerCase();

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

    handleEdit(event) {
        if (event.currentTarget.dataset.section !== 'profile') {
            return;
        }

        this.isModalOpen = true;
        this.isProfileEdit = true;
        this.modalTitle = 'Edit Member Profile';

        this.editData = {
            gamingSegment: this.member?.Segment__c || ''
        };
    }

    handleFieldChange(event) {
        const field = event.target.dataset.field;

        this.editData = {
            ...this.editData,
            [field]: event.detail.value
        };
    }

    async handleSave() {
        try {
            await updateMemberSegment({
                memberId: this.member.Id,
                segment: this.editData.gamingSegment
            });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Gaming Segment updated successfully.',
                    variant: 'success'
                })
            );

            this.dispatchEvent(
                new CustomEvent('segmentchange', {
                    detail: {
                        segment: this.editData.gamingSegment
                    },
                    bubbles: true,
                    composed: true
                })
            );

            this.closeModal();
        } catch (error) {
            let message = 'Unable to update Gaming Segment.';

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
        this.isProfileEdit = false;
        this.modalTitle = '';
        this.editData = {};
    }
}