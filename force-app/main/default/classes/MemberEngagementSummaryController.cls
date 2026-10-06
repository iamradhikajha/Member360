public with sharing class MemberEngagementSummaryController {
    public class WalletCurrencyWrapper {
        @AuraEnabled
        public String currencyName;
        @AuraEnabled
        public String currencyType;
        @AuraEnabled
        public Decimal pointsBalance;
    }
    @AuraEnabled(cacheable=true)
    public static List<WalletCurrencyWrapper> getGamingWallet( Id memberId) {
        return MemberEngagementSummaryHelper.getGamingWallet(
            memberId
        );
    }
}