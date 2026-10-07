import { LightningElement, api, wire } from 'lwc';
import getMemberJourney from '@salesforce/apex/LoyaltyJourneySectionController.getMemberJourney';

export default class LoyaltyMemberJourney extends LightningElement {

    @api memberId;
    journey = [];
    error;
    isLoading = true;
    showTimelineModal = false;

    @wire(getMemberJourney, { memberId: '$memberId' })
    wiredJourney({ data, error }) {
        if (!this.memberId) {
            this.journey = [];
            this.error = undefined;
            this.isLoading = true;
            return;
        }
        if (data) {
            this.error = undefined;
            this.journey = data.map((item) => {
                return {
                    id: item.id,
                    title: item.title,
                    activityDate: item.activityDate,
                    type: item.type,
                    subType: item.subType,
                    formattedDate: this.formatDate(item.activityDate),
                    iconName: this.getIconName( item.type, item.subType),
                    iconClass:this.getIconClass( item.type, item.subType)
                };
            });
            this.isLoading = false;
            return;
        }

        if (error) {
            this.error = error;
            this.journey = [];
            this.isLoading = false;
        }
    }

    get hasJourney() {
        return ( !this.isLoading && !this.error && this.journey.length > 0);
    }

    get showEmpty() {
        return ( !this.isLoading && !this.error && this.journey.length === 0);
    }

    get hasError() {
        return ( !this.isLoading && !!this.error );
    }

    get visibleJourney() {
        return this.journey.slice(0, 6);
    }

    get timelineStyle() {
        const count = this.visibleJourney.length;
        if (count <= 1) {
            return 'grid-template-columns: repeat(1, minmax(0, 1fr));';
        }
        if (count === 2) {
            return 'grid-template-columns: repeat(2, minmax(0, 1fr));';
        }
        if (count === 3) {
            return 'grid-template-columns: repeat(3, minmax(0, 1fr));';
        }
        if (count === 4) {
            return 'grid-template-columns: repeat(4, minmax(0, 1fr));';
        }
        if (count === 5) {
            return 'grid-template-columns: repeat(5, minmax(0, 1fr));';
        }
        return 'grid-template-columns: repeat(6, minmax(0, 1fr));';
    }

    formatDate(value) {
        if (!value) {
            return '';
        }
        const date = new Date(value);
        if (isNaN(date.getTime())) {
            return '';
        }
        return date.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric'});
    }

    getIconName(type, subType) {
        const value =
            `${type || ''} ${subType || ''}`.toLowerCase();
        if ( value.includes('signup') || value.includes('sign up') || value.includes('enroll') || value.includes('enrollment') || value.includes('join')) {
            return 'utility:user';
        }

        if ( value.includes('gaming') || value.includes('game') || value.includes('play') ) {
            return 'utility:success';
        }

        if ( value.includes('earn') || value.includes('accrual') || value.includes('point') || value.includes('credit')) {
            return 'utility:chart';
        }

        if ( value.includes('redeem') || value.includes('redemption') || value.includes('voucher') || value.includes('reward')
        ) {
            return 'utility:gift';
        }

        if ( value.includes('tier') || value.includes('upgrade') || value.includes('classic') || value.includes('silver') || value.includes('gold')) {
            return 'utility:favorite';
        }

        if ( value.includes('promotion') || value.includes('campaign') || value.includes('birthday')) {
            return 'utility:announcement';
        }
        return 'utility:event';
    }

    getIconClass(type, subType) {
        const value =
            `${type || ''} ${subType || ''}`.toLowerCase();
        if ( value.includes('signup') || value.includes('sign up') || value.includes('enroll') || value.includes('enrollment') || value.includes('join')) {
            return 'timeline-circle join-circle';
        }

        if ( value.includes('gaming') || value.includes('game') || value.includes('play')) {
            return 'timeline-circle gaming-circle';
        }

        if ( value.includes('earn') || value.includes('accrual') || value.includes('point') || value.includes('credit')) {
            return 'timeline-circle earn-circle';
        }

        if ( value.includes('redeem') || value.includes('redemption') || value.includes('voucher') || value.includes('reward')) {
            return 'timeline-circle reward-circle';
        }

        if ( value.includes('tier') || value.includes('upgrade') || value.includes('classic') || value.includes('silver') || value.includes('gold') ) {
            return 'timeline-circle tier-circle';
        }

        if ( value.includes('promotion') || value.includes('campaign') || value.includes('birthday')) {
            return 'timeline-circle promotion-circle';
        }
        return 'timeline-circle default-circle';
    }

    handleViewTimeline() {
        this.showTimelineModal = true;
    }

    handleCloseTimeline() {
        this.showTimelineModal = false;
    }
}