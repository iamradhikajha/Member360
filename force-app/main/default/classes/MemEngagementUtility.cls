public with sharing class MemEngagementUtility {
    public static Decimal calculatePercentage(Integer numerator, Integer denominator) {
        if (denominator == null || denominator == 0) return 0;
        return ((Decimal) numerator / denominator * 100).setScale(0);
    }

    public static Decimal calculateChange(Decimal currentRate, Decimal previousRate) {
        if (currentRate == null) currentRate = 0;
        if (previousRate == null) previousRate = 0;
        return (currentRate - previousRate).setScale(0);
    }

    public static Date getLatestEngagementDate(List<Marketing_Engagement__c> engagements) {
        Date latestDate;
        for (Marketing_Engagement__c engagement : engagements) {
            if (engagement.Event_Date__c == null) continue;
            if (latestDate == null || engagement.Event_Date__c > latestDate) latestDate = engagement.Event_Date__c;
        }
        return latestDate;
    }

    public static String getAppEngagement(List<Marketing_Engagement__c> engagements) {
        for (Marketing_Engagement__c engagement : engagements) {
            if (engagement.Channel__c == 'App' && engagement.Event_Type__c == 'Login') return 'Active';
        }
        return 'Inactive';
    }

    public static String getIconName(Boolean engaged) {
        return engaged ? 'utility:success' : 'utility:warning';
    }

    public static String getIconVariant(Boolean engaged) {
        return engaged ? 'success' : 'warning';
    }
}