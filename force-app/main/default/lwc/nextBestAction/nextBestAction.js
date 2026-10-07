import { LightningElement, api } from 'lwc';

export default class NextBestAction extends LightningElement {
    @api member;

    handleViewInsights() {
        this.dispatchEvent(
            new CustomEvent('viewinsights')
        );
    }
}