import { LightningElement, api, wire } from 'lwc';
import getLoyaltyStatus from '@salesforce/apex/LoyaltyStatusController.getLoyaltyStatus';

export default class LoyaltyStatusCard extends LightningElement {
    @api member;
    loyaltyStatus;
    loyaltyLoading = true;
    loyaltyError;

    get memberId() {
        return this.member?.Id;
    }

    get memberName() {
        return this.member?.Name || '';
    }

    @wire(getLoyaltyStatus, { memberId: '$memberId' })
    wiredLoyaltyStatus({ data, error }) {
        this.loyaltyLoading = false;
        if (data) {
            this.loyaltyStatus = data;
            this.loyaltyError = undefined;
        } else if (error) {
            this.loyaltyStatus = undefined;
            this.loyaltyError = error;
        }
    }

    get formattedCurrentPoints() {
        if ( !this.loyaltyStatus || this.loyaltyStatus.currentPoints === null || this.loyaltyStatus.currentPoints === undefined) return '0';
        return Number(this.loyaltyStatus.currentPoints).toLocaleString('en-IN');
    }
    get formattedNextTierMinimum() {
        if ( !this.loyaltyStatus || !this.loyaltyStatus.hasNextTier) return '0';
        return Number(this.loyaltyStatus.nextTierMinimum).toLocaleString('en-IN');
    }

    get formattedPointsToUpgrade() {
        if ( !this.loyaltyStatus || !this.loyaltyStatus.hasNextTier) return '0';
        return Number(this.loyaltyStatus.pointsToUpgrade).toLocaleString('en-IN');
    }

    get currentTierLabel() {
        if (!this.loyaltyStatus) return '';
        return this.loyaltyStatus.currentTierName ? this.loyaltyStatus.currentTierName.toUpperCase() : '';
    }

    get nextTierLabel() {
        if ( !this.loyaltyStatus || !this.loyaltyStatus.nextTierName)return '';
        return this.loyaltyStatus.nextTierName.toUpperCase();
    }

    get progressStyle() {
        if (!this.loyaltyStatus) return 'width: 0%;';
        let percentage = Number(this.loyaltyStatus.progressPercentage);
        if (percentage < 0) percentage = 0;
        if (percentage > 100) percentage = 100;
        return `width: ${percentage}%;`;
    }
}