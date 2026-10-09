import { LightningElement, api, wire } from 'lwc';
import getMemberBenefits from '@salesforce/apex/BenefitsOffersController.getMemberBenefits';

export default class BenefitsOffers extends LightningElement {
    @api member;
    benefits = [];
    isModalOpen = false;
    error;

    @wire(getMemberBenefits, { memberId: '$member.Id' })
    wiredBenefits({ data, error }) {
        if (data) {
            this.benefits = data.map(item => ({...item,formattedEndDate: item.endDate? new Intl.DateTimeFormat('en-GB', {
                day: '2-digit', month: 'short', year: 'numeric'}).format(new Date(`${item.endDate}T00:00:00`)) : '',
            expiryText: this.getExpiryText(item),
            benefitClass: item.isExpiringSoon ? 'benefitItem expiring' : 'benefitItem'
        }));
        this.error = undefined;
        } else if (error) {
        this.benefits = [];
        this.error = error;
        }
    }

    get availableBenefits() {
        return this.benefits.filter(item => {
            return item.daysRemaining === null || item.daysRemaining === undefined || item.daysRemaining > 30;
        }) .slice(0, 2);
    }

    get expiringBenefits() {
        return this.benefits.filter(item => item.isExpiringSoon).slice(0, 2);
    }

    get allBenefits() {
        return this.benefits;
    }

    get hasAvailableBenefits() {
        return this.availableBenefits.length > 0;
    }

    get hasExpiringBenefits() {
        return this.expiringBenefits.length > 0;
    }

    get hasBenefits() {
        return this.benefits.length > 0;
    }

    getExpiryText(item) {
        if (item.daysRemaining === null || item.daysRemaining === undefined) return item.formattedEndDate ? `Valid until ${item.formattedEndDate}`: 'No expiry date';
        if (item.daysRemaining === 0) return 'Expires today';
        if (item.daysRemaining === 1) return 'Expires in 1 day';
        return `Expires in ${item.daysRemaining} days`;
    }

    handleViewAll() {
        if (this.hasBenefits) this.isModalOpen = true;
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }
}