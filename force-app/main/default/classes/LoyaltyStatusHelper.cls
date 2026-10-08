public with sharing class LoyaltyStatusHelper {

    public static LoyaltyStatusController.LoyaltyStatusWrapper
        getLoyaltyStatus(Id memberId) {

        /*
         * Validate Member Id
         */
        Member360Utility.validateLoyaltyMemberId(memberId);


        /*
         * Get Member Currency
         */
        List<LoyaltyMemberCurrency> memberCurrencies = [
            SELECT
                Id,
                LoyaltyMemberId,
                PointsBalance,
                LoyaltyProgramCurrencyId,
                LoyaltyProgramCurrency.Name,
                LoyaltyProgramCurrency.CurrencyType,
                LoyaltyProgramCurrency.LoyaltyTierGroupId
            FROM LoyaltyMemberCurrency
            WHERE LoyaltyMemberId = :memberId
            AND LoyaltyProgramCurrency.CurrencyType =
                :Member360Constants.CURRENCY_TYPE_QUALIFYING
            ORDER BY CreatedDate ASC
            LIMIT 1
        ];


        if (memberCurrencies.isEmpty()) {

            throw new AuraHandledException(
                Member360Constants.ERROR_NO_MEMBER_CURRENCY
            );

        }


        LoyaltyMemberCurrency memberCurrency =
            memberCurrencies[0];


        /*
         * Current Points
         */
        Decimal currentPoints =
            memberCurrency.PointsBalance == null
                ? 0
                : memberCurrency.PointsBalance;


        /*
         * Currency Name
         */
        String currencyName =
            memberCurrency.LoyaltyProgramCurrency.Name;


        /*
         * Tier Group
         */
        Id tierGroupId =
            memberCurrency.LoyaltyProgramCurrency.LoyaltyTierGroupId;


        /*
         * Get all tiers belonging to the same Tier Group
         */
        List<LoyaltyTier> tiers = [
            SELECT
                Id,
                Name,
                SequenceNumber,
                MinimumEligibleBalance,
                LoyaltyTierGroupId
            FROM LoyaltyTier
            WHERE LoyaltyTierGroupId = :tierGroupId
            ORDER BY SequenceNumber ASC
        ];


        if (tiers.isEmpty()) {

            throw new AuraHandledException(
                Member360Constants.ERROR_NO_LOYALTY_TIERS
            );

        }


        /*
         * Find CURRENT tier based on current points.
         *
         * We are NOT hardcoding Bronze/Silver/Gold etc.
         *
         * Salesforce tiers are ordered by SequenceNumber.
         */
        LoyaltyTier currentTier;


        for (LoyaltyTier tier : tiers) {

            Decimal minimumBalance =
                tier.MinimumEligibleBalance == null
                    ? 0
                    : tier.MinimumEligibleBalance;


            if (currentPoints >= minimumBalance) {

                currentTier = tier;

            } else {

                break;

            }
        }


        /*
         * If points are below the first tier,
         * use the first tier.
         */
        if (currentTier == null) {

            currentTier = tiers[0];

        }


        /*
         * Find NEXT tier.
         *
         * The next tier is simply the tier
         * immediately after the current tier
         * according to SequenceNumber.
         */
        LoyaltyTier nextTier;


        for (Integer i = 0; i < tiers.size(); i++) {

            if (tiers[i].Id == currentTier.Id) {

                if (i + 1 < tiers.size()) {

                    nextTier = tiers[i + 1];

                }

                break;

            }
        }


        /*
         * Create response
         */
        LoyaltyStatusController.LoyaltyStatusWrapper response =
            new LoyaltyStatusController.LoyaltyStatusWrapper();


        /*
         * Current Tier
         */
        response.currentTierName =
            currentTier.Name;


        /*
         * Currency
         */
        response.currencyName =
            currencyName;


        /*
         * Current Points
         */
        response.currentPoints =
            currentPoints;


        /*
         * Current Tier Minimum
         */
        response.currentTierMinimum =
            currentTier.MinimumEligibleBalance;


        /*
         * NEXT TIER EXISTS
         */
        if (nextTier != null) {

            response.hasNextTier = true;


            /*
             * This is the value you want:
             *
             * Next Tier: XXXXX
             */
            response.nextTierName =
                nextTier.Name;


            /*
             * Next Tier Minimum
             */
            Decimal nextMinimum =
                nextTier.MinimumEligibleBalance == null
                    ? 0
                    : nextTier.MinimumEligibleBalance;


            response.nextTierMinimum =
                nextMinimum;


            /*
             * Current Tier Minimum
             */
            Decimal currentMinimum =
                currentTier.MinimumEligibleBalance == null
                    ? 0
                    : currentTier.MinimumEligibleBalance;


            /*
             * Points required to reach next tier
             */
            Decimal pointsRemaining =
                nextMinimum - currentPoints;


            if (pointsRemaining < 0) {

                pointsRemaining = 0;

            }


            response.pointsToUpgrade =
                pointsRemaining;


            /*
             * Calculate progress
             */
            Decimal tierRange =
                nextMinimum - currentMinimum;


            Decimal progress;


            if (tierRange <= 0) {

                progress = 0;

            } else {

                progress =
                    (
                        (currentPoints - currentMinimum)
                        / tierRange
                    ) * 100;

            }


            /*
             * Keep progress between 0 and 100
             */
            if (progress < 0) {

                progress = 0;

            }


            if (progress > 100) {

                progress = 100;

            }


            response.progressPercentage =
                progress.setScale(0);

        }

        /*
         * NO NEXT TIER
         */
        else {

            response.hasNextTier = false;

            response.nextTierName = null;

            response.nextTierMinimum = null;

            response.pointsToUpgrade = 0;

            response.progressPercentage = 100;

        }


        return response;
    }
}