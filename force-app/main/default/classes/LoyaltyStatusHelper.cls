public with sharing class LoyaltyStatusHelper {
    public static LoyaltyStatusController.LoyaltyStatusWrapper getLoyaltyStatus(Id memberId) {
        Member360Utility.validateLoyaltyMemberId(memberId);
        List<LoyaltyMemberCurrency> memberCurrencies = [SELECT Id, LoyaltyMemberId, PointsBalance, LoyaltyProgramCurrencyId, LoyaltyProgramCurrency.Name, LoyaltyProgramCurrency.CurrencyType, LoyaltyProgramCurrency.LoyaltyTierGroupId
            FROM LoyaltyMemberCurrency
            WHERE LoyaltyMemberId = :memberId
            AND LoyaltyProgramCurrency.CurrencyType = :Member360Constants.CURRENCY_TYPE_QUALIFYING
            ORDER BY CreatedDate ASC
            LIMIT 1
        ];

        if (memberCurrencies.isEmpty()) throw new AuraHandledException(Member360Constants.ERROR_NO_MEMBER_CURRENCY);
        LoyaltyMemberCurrency memberCurrency = memberCurrencies[0];
        Decimal currentPoints = memberCurrency.PointsBalance == null ? 0 : memberCurrency.PointsBalance;
        String currencyName = memberCurrency.LoyaltyProgramCurrency.Name;
        Id tierGroupId = memberCurrency.LoyaltyProgramCurrency.LoyaltyTierGroupId;
        List<LoyaltyTier> tiers = [SELECT Id, Name, SequenceNumber, MinimumEligibleBalance, LoyaltyTierGroupId FROM LoyaltyTier WHERE LoyaltyTierGroupId = :tierGroupId ORDER BY SequenceNumber ASC];
        if (tiers.isEmpty()) throw new AuraHandledException(Member360Constants.ERROR_NO_LOYALTY_TIERS);
        LoyaltyTier currentTier;
        for (LoyaltyTier tier : tiers) {
            Decimal minimumBalance = tier.MinimumEligibleBalance == null? 0: tier.MinimumEligibleBalance;
            if (currentPoints >= minimumBalance) currentTier = tier;
            else break;
        }

        if (currentTier == null) currentTier = tiers[0];
        LoyaltyTier nextTier;
        for (Integer i = 0; i < tiers.size(); i++) {
            if (tiers[i].Id == currentTier.Id) {
                if (i + 1 < tiers.size()) nextTier = tiers[i + 1];
                break;
            }
        }

        LoyaltyStatusController.LoyaltyStatusWrapper response = new LoyaltyStatusController.LoyaltyStatusWrapper();
        response.currentTierName = currentTier.Name;
        response.currencyName = currencyName;
        response.currentPoints = currentPoints;
        response.currentTierMinimum = currentTier.MinimumEligibleBalance;
        if (nextTier != null) {
            response.hasNextTier = true;
            response.nextTierName = nextTier.Name;
            Decimal nextMinimum = nextTier.MinimumEligibleBalance == null ? 0 : nextTier.MinimumEligibleBalance;
            response.nextTierMinimum =nextMinimum;
            Decimal currentMinimum = currentTier.MinimumEligibleBalance == null ? 0 : currentTier.MinimumEligibleBalance;
            Decimal pointsRemaining = nextMinimum - currentPoints;
            if (pointsRemaining < 0) pointsRemaining = 0;
            response.pointsToUpgrade = pointsRemaining;
            Decimal tierRange = nextMinimum - currentMinimum;
            Decimal progress;
            if (tierRange <= 0) progress = 0;
            else  progress =((currentPoints - currentMinimum)/ tierRange) * 100;
            if (progress < 0)  progress = 0;
            if (progress > 100) progress = 100;
            response.progressPercentage = progress.setScale(0);
        }
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