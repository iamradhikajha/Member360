import { LightningElement,api,wire } from 'lwc';
import getMemberDetail from '@salesforce/apex/Member360Controller.getMemberDetail';

export default class NextBestAction extends LightningElement {

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
    
    get handleNameSegment() {
        return this.member?.Contact?.Name || '';
    }

    handleInsights() {
        console.log('View Insights clicked');
    }
}