import { LightningElement, api, wire } from 'lwc';
import getMarketingEngagement from '@salesforce/apex/MemEngagementController.getMarketingEngagement';

export default class MarketingEngagement extends LightningElement {

    @api member;
    campaigns = [];
    metrics = {};
    showViewAll = false;
    error;

    get memberId() {
        return this.member?.Id;
    }

    @wire(getMarketingEngagement, {memberId: '$memberId'})
    wiredMarketingEngagement({ data, error }) {
        if (data) {
            this.error = undefined;
            this.campaigns = data.campaigns || [];
            this.metrics = data.metrics || {};

        } else if (error) {
            this.error = error;
            this.campaigns = [];
            this.metrics = {};
        }
    }

    get formattedCampaigns() {
        return this.campaigns.map(campaign => {
            return {...campaign,formattedDate: this.formatDate(campaign.engagementDate),
                statusClass: campaign.engaged ? 'engaged-text' : 'not-engaged-text'
            };
        });
    }

    get displayedCampaigns() {
        return this.formattedCampaigns.slice(0, 4);
    }

    get hasCampaigns() {
        return this.campaigns.length > 0;
    }

    get emailOpenRate() {
        return this.metrics.emailOpenRate ?? 0;
    }


    get emailOpenChange() {
        return this.metrics.emailOpenChange ?? 0;
    }

    get smsClickRate() {
        return this.metrics.smsClickRate ?? 0;
    }


    get smsClickChange() {
        return this.metrics.smsClickChange ?? 0;
    }

    get appEngagement() {
        return this.metrics.appEngagement || 'Inactive';
    }

    get lastEngagement() {
        return this.formatDate(this.metrics.lastEngagement);
    }

    get showEmailChange() {
        return this.metrics.emailOpenChange !== undefined && this.metrics.emailOpenChange !== null && this.metrics.emailOpenChange !== 0;
    }

    get showSmsChange() {
        return this.metrics.smsClickChange !== undefined &&  this.metrics.smsClickChange !== null &&  this.metrics.smsClickChange !== 0;
    }

    get emailChangeClass() {
        return this.emailOpenChange >= 0 ? 'metric-change positive' : 'metric-change negative';
    }

    get smsChangeClass() {
        return this.smsClickChange >= 0 ? 'metric-change positive' : 'metric-change negative';
    }


    get emailChangeArrow() {
        return this.emailOpenChange >= 0  ? '↑'  : '↓';
    }

    get smsChangeArrow() {
        return this.smsClickChange >= 0 ? '↑' : '↓';
    }

    formatDate(value) {
        if (!value) return '';
        const date = new Date(value);
        if (Number.isNaN(date.getTime())) return '';
        return new Intl.DateTimeFormat('en-GB', { day: 'numeric', month: 'short', year: 'numeric'}).format(date);
    }

    handleViewAll() {
        this.showViewAll = true;
    }


    handleCloseViewAll() {
        this.showViewAll = false;
    }
}