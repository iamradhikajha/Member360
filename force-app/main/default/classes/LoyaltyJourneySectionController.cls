public with sharing class LoyaltyJourneySectionController {

    @AuraEnabled(cacheable=true)
    public static List<LoyaltyJourneySectionHelper.MemberJourneyItem> getMemberJourney(Id memberId) {
        return LoyaltyJourneySectionHelper.getMemberJourney(memberId);
    }
}