public with sharing class MemberEngagementSummaryHelper {
    public static List<MemberEngagementSummaryController.WalletCurrencyWrapper>
        getGamingWallet(Id memberId) {
        Member360Utility.validateLoyaltyMemberId(memberId);
        List<LoyaltyMemberCurrency> memberCurrencies = [SELECT Id, PointsBalance, LoyaltyProgramCurrency.Name, LoyaltyProgramCurrency.CurrencyType FROM LoyaltyMemberCurrency WHERE LoyaltyMemberId = :memberId ORDER BY CreatedDate ASC];
        List<MemberEngagementSummaryController.WalletCurrencyWrapper> response = new List<MemberEngagementSummaryController.WalletCurrencyWrapper>();
        for (LoyaltyMemberCurrency memberCurrency : memberCurrencies) {
            MemberEngagementSummaryController.WalletCurrencyWrapper item = new MemberEngagementSummaryController.WalletCurrencyWrapper();
            item.currencyName = memberCurrency.LoyaltyProgramCurrency.Name;
            item.currencyType = memberCurrency.LoyaltyProgramCurrency.CurrencyType;
            item.pointsBalance = memberCurrency.PointsBalance == null ? 0 : memberCurrency.PointsBalance;
            response.add(item);
        }
        return response;
    }
}