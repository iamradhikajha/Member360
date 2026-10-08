import { LightningElement, api, wire } from 'lwc';

import getLoyaltyStatus
    from '@salesforce/apex/LoyaltyStatusController.getLoyaltyStatus';


export default class LoyaltyStatusCard extends LightningElement {

    @api member;

    loyaltyStatus;
    loyaltyLoading = true;
    loyaltyError;


    /*
     * Current opened Loyalty Member Id
     */
    get memberId() {

        return this.member?.Id;

    }


    /*
     * Member Name
     *
     * This comes from the member record passed
     * to this component.
     */
    get memberName() {

        return this.member?.Name || '';

    }


    /*
     * Get Loyalty Status from Apex
     */
    @wire(getLoyaltyStatus, { memberId: '$memberId' })
    wiredLoyaltyStatus({ data, error }) {

        this.loyaltyLoading = false;


        if (data) {

            this.loyaltyStatus = data;

            this.loyaltyError = undefined;

            console.log(
                'Loyalty Status:',
                JSON.stringify(data)
            );

        }

        else if (error) {

            this.loyaltyStatus = undefined;

            this.loyaltyError = error;

            console.error(
                'Loyalty Status Error:',
                error
            );

        }

    }


    /*
     * Current Points
     */
    get formattedCurrentPoints() {

        if (
            !this.loyaltyStatus ||
            this.loyaltyStatus.currentPoints === null ||
            this.loyaltyStatus.currentPoints === undefined
        ) {

            return '0';

        }


        return Number(
            this.loyaltyStatus.currentPoints
        ).toLocaleString('en-IN');

    }


    /*
     * Next Tier Minimum
     */
    get formattedNextTierMinimum() {

        if (
            !this.loyaltyStatus ||
            !this.loyaltyStatus.hasNextTier
        ) {

            return '0';

        }


        return Number(
            this.loyaltyStatus.nextTierMinimum
        ).toLocaleString('en-IN');

    }


    /*
     * Points required for upgrade
     */
    get formattedPointsToUpgrade() {

        if (
            !this.loyaltyStatus ||
            !this.loyaltyStatus.hasNextTier
        ) {

            return '0';

        }


        return Number(
            this.loyaltyStatus.pointsToUpgrade
        ).toLocaleString('en-IN');

    }


    /*
     * Current Tier
     */
    get currentTierLabel() {

        if (!this.loyaltyStatus) {

            return '';

        }


        return this.loyaltyStatus.currentTierName
            ? this.loyaltyStatus.currentTierName.toUpperCase()
            : '';

    }


    /*
     * NEXT TIER
     *
     * This is the dynamic tier name coming
     * from LoyaltyTier.Name in Apex.
     */
    get nextTierLabel() {

        if (
            !this.loyaltyStatus ||
            !this.loyaltyStatus.nextTierName
        ) {

            return '';

        }


        return this.loyaltyStatus.nextTierName.toUpperCase();

    }


    /*
     * Progress Bar
     */
    get progressStyle() {

        if (!this.loyaltyStatus) {

            return 'width: 0%;';

        }


        let percentage =
            Number(
                this.loyaltyStatus.progressPercentage
            );


        if (percentage < 0) {

            percentage = 0;

        }


        if (percentage > 100) {

            percentage = 100;

        }


        return `width: ${percentage}%;`;

    }

}