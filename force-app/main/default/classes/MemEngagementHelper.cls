public class MemEngagementHelper {
    public static Map<String, Object> getMarketingEngagement(Id memberId) {
        Map<String, Object> response = new Map<String, Object>();
        List<Map<String, Object>> campaignData = new List<Map<String, Object>>();
        Map<String, Object> metrics = new Map<String, Object>();

        if (memberId == null) {
            response.put('campaigns', campaignData);
            response.put('metrics', metrics);
            return response;
        }

        Date today = Date.today();
        Date currentStartDate = today.addDays(-90);
        Date previousStartDate = today.addDays(-180);

        List<Marketing_Campaign__c> campaigns = [
            SELECT Id, Name, Channel__c, Start_Date__c, Status__c
            FROM Marketing_Campaign__c
            ORDER BY Start_Date__c DESC NULLS LAST
        ];

        List<Marketing_Engagement__c> currentEngagements = [
            SELECT Id, Loyalty_Program_Member__c, Marketing_Campaign__c, Marketing_Campaign__r.Name, Channel__c, Event_Type__c, Event_Date__c
            FROM Marketing_Engagement__c
            WHERE Loyalty_Program_Member__c = :memberId AND Event_Date__c >= :currentStartDate AND Event_Date__c <= :today
            ORDER BY Event_Date__c DESC
        ];

        List<Marketing_Engagement__c> previousEngagements = [
            SELECT Id, Loyalty_Program_Member__c, Marketing_Campaign__c, Channel__c, Event_Type__c, Event_Date__c
            FROM Marketing_Engagement__c
            WHERE Loyalty_Program_Member__c = :memberId AND Event_Date__c >= :previousStartDate AND Event_Date__c < :currentStartDate
        ];

        Map<Id, Marketing_Engagement__c> latestEngagementByCampaign = new Map<Id, Marketing_Engagement__c>();

        for (Marketing_Engagement__c engagement : currentEngagements) {
            if (engagement.Marketing_Campaign__c == null) continue;
            if (!latestEngagementByCampaign.containsKey(engagement.Marketing_Campaign__c)) latestEngagementByCampaign.put(engagement.Marketing_Campaign__c, engagement);
        }

        for (Marketing_Campaign__c campaign : campaigns) {
            Map<String, Object> campaignMap = new Map<String, Object>();
            Marketing_Engagement__c engagement = latestEngagementByCampaign.get(campaign.Id);
            Boolean engaged = engagement != null;

            campaignMap.put('campaignId', campaign.Id);
            campaignMap.put('campaignName', campaign.Name);
            campaignMap.put('channel', campaign.Channel__c);
            campaignMap.put('status', campaign.Status__c);
            campaignMap.put('engaged', engaged);
            campaignMap.put('engagementDate', engaged ? engagement.Event_Date__c : null);
            campaignMap.put('eventType', engaged ? engagement.Event_Type__c : null);
            campaignMap.put('displayStatus', engaged ? 'Engaged' : 'Not engaged');
            campaignMap.put('iconName', MemEngagementUtility.getIconName(engaged));
            campaignMap.put('iconVariant', MemEngagementUtility.getIconVariant(engaged));
            campaignData.add(campaignMap);
        }

        Integer currentEmailSent = 0, currentEmailOpened = 0, previousEmailSent = 0, previousEmailOpened = 0;
        Integer currentSmsSent = 0, currentSmsClicked = 0, previousSmsSent = 0, previousSmsClicked = 0;

        for (Marketing_Engagement__c engagement : currentEngagements) {
            if (engagement.Channel__c == 'Email') {
                if (engagement.Event_Type__c == 'Sent') currentEmailSent++;
                if (engagement.Event_Type__c == 'Opened') currentEmailOpened++;
            } else if (engagement.Channel__c == 'SMS') {
                if (engagement.Event_Type__c == 'Sent') currentSmsSent++;
                if (engagement.Event_Type__c == 'Clicked') currentSmsClicked++;
            }
        }

        for (Marketing_Engagement__c engagement : previousEngagements) {
            if (engagement.Channel__c == 'Email') {
                if (engagement.Event_Type__c == 'Sent') previousEmailSent++;
                if (engagement.Event_Type__c == 'Opened') previousEmailOpened++;
            } else if (engagement.Channel__c == 'SMS') {
                if (engagement.Event_Type__c == 'Sent') previousSmsSent++;
                if (engagement.Event_Type__c == 'Clicked') previousSmsClicked++;
            }
        }

        Decimal emailOpenRate = MemEngagementUtility.calculatePercentage(currentEmailOpened, currentEmailSent);
        Decimal previousEmailOpenRate = MemEngagementUtility.calculatePercentage(previousEmailOpened, previousEmailSent);
        Decimal emailOpenChange = MemEngagementUtility.calculateChange(emailOpenRate, previousEmailOpenRate);
        Decimal smsClickRate = MemEngagementUtility.calculatePercentage(currentSmsClicked, currentSmsSent);
        Decimal previousSmsClickRate = MemEngagementUtility.calculatePercentage(previousSmsClicked, previousSmsSent);
        Decimal smsClickChange = MemEngagementUtility.calculateChange(smsClickRate, previousSmsClickRate);

        Date lastEngagement = MemEngagementUtility.getLatestEngagementDate(currentEngagements);
        String appEngagement = MemEngagementUtility.getAppEngagement(currentEngagements);

        metrics.put('emailOpenRate', emailOpenRate);
        metrics.put('emailOpenChange', emailOpenChange);
        metrics.put('smsClickRate', smsClickRate);
        metrics.put('smsClickChange', smsClickChange);
        metrics.put('appEngagement', appEngagement);
        metrics.put('lastEngagement', lastEngagement);

        response.put('campaigns', campaignData);
        response.put('metrics', metrics);
        return response;
    }
}