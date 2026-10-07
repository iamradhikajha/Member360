import { LightningElement, api } from 'lwc';

export default class LoyaltyJourneySection extends LightningElement {
    @api memberId;
    handleViewTimeline() {
        console.log('View Timeline clicked');
    }
    handleViewInsights() {
        console.log('View Insights clicked');
    }
    handleRecommendationClick(event) {
        console.log('Recommendation selected:',event.detail.recommendationId);
    }
}