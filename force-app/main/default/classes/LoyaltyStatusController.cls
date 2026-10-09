public with sharing class LoyaltyStatusController {

    public class LoyaltyStatusWrapper {
        @AuraEnabled
        public String currentTierName;
        @AuraEnabled
        public String nextTierName;
        @AuraEnabled
        public String currencyName;
        @AuraEnabled
        public Decimal currentPoints;
        @AuraEnabled
        public Decimal currentTierMinimum;
        @AuraEnabled
        public Decimal nextTierMinimum;
        @AuraEnabled
        public Decimal pointsToUpgrade;
        @AuraEnabled
        public Decimal progressPercentage;
        @AuraEnabled
        public Boolean hasNextTier;
    }

    @AuraEnabled(cacheable=true)
    public static LoyaltyStatusWrapper getLoyaltyStatus(Id memberId) {
        return LoyaltyStatusHelper.getLoyaltyStatus(memberId);

    }
}