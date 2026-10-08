public with sharing class MemEngagementController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMarketingEngagement(Id memberId) {

        return MemEngagementHelper.getMarketingEngagement(memberId);
    }
}