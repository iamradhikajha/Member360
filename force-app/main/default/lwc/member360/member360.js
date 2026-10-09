import { LightningElement, api, wire } from 'lwc';
import getMemberDetail from '@salesforce/apex/Member360Controller.getMemberDetail';

export default class Member360 extends LightningElement {

    @api recordId;
    member;
    error;

    @wire(getMemberDetail, { memberId: '$recordId' })
    wiredMember({ data, error }) {
        if (data) {
            this.member = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.member = undefined;
        }
    }

    get memberId() {
        return this.member?.Id || null;
    }

    get memberInitials() {
        if (!this.member?.Contact?.Name) return '';
        return this.member.Contact.Name.split(' ').map(word => word[0]).join('').toUpperCase();
    }

    get memberStatus() {
        return this.member?.MemberStatus;
    }

    get isActive() {
        return this.member?.MemberStatus === 'Active';
    }
    get isInactive() {
        return this.member?.MemberStatus === 'Inactive';
    }

    get isMerged() {
        return this.member?.MemberStatus === 'Merged';
    }

    get stars() {
        const count = Math.min(Number(this.member?.Tier_Stars__c) || 0,5);
        return Array.from( { length: 5 }, (_, index) => ({ id: index, className: index < count ? 'filledStar' : 'emptyStar'}));
    }

    get gamingSpend() {
        const amount = Number(this.member?.Gaming_Spend_YTD__c);
        if (!amount) return '$0';
        return '$' + amount.toLocaleString('en-US');
    }

    get formattedLastVisit() {
        if (!this.member?.LastModifiedDate) return '';
        return new Date(this.member.LastModifiedDate).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric'});
    }

    get formattedActiveSince() {
        if (!this.member?.EnrollmentDate)  return '';
        return new Date(this.member.EnrollmentDate).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric'});
    }

    handleSegmentChange(event) {
        const {segment,preferredLanguage,preferredChannel,nationality,property,preferredGame} = event.detail;
        this.member = { ...this.member, Segment__c: segment, Preferred_Language__c: preferredLanguage, Preferred_Channel__c: preferredChannel, Nationality__c: nationality, Property__c: property, Preferred_Game__c: preferredGame};
    }
}