public class MemEngagementHelper {

    public static Map<String, Object> getMarketingEngagement(
        Id memberId
    ) {

        Map<String, Object> response =
            new Map<String, Object>();


        List<Map<String, Object>> campaignData =
            new List<Map<String, Object>>();


        Map<String, Object> metrics =
            new Map<String, Object>();


        /*
         * ----------------------------------------------------
         * Validate Member Id
         * ----------------------------------------------------
         */

        if (memberId == null) {

            response.put(
                'campaigns',
                campaignData
            );

            response.put(
                'metrics',
                metrics
            );

            return response;
        }


        /*
         * ----------------------------------------------------
         * Date ranges
         * ----------------------------------------------------
         */

        Date today = Date.today();


        Date currentStartDate =
            today.addDays(-90);


        Date previousStartDate =
            today.addDays(-180);



        /*
         * ====================================================
         * 1. GET CAMPAIGNS
         * ====================================================
         */

        List<Marketing_Campaign__c> campaigns = [

            SELECT
                Id,
                Name,
                Channel__c,
                Start_Date__c,
                Status__c

            FROM Marketing_Campaign__c

            ORDER BY Start_Date__c DESC NULLS LAST
        ];



        /*
         * ====================================================
         * 2. CURRENT 90 DAYS ENGAGEMENT
         * ====================================================
         */

        List<Marketing_Engagement__c> currentEngagements = [

            SELECT
                Id,
                Loyalty_Program_Member__c,
                Marketing_Campaign__c,
                Marketing_Campaign__r.Name,
                Channel__c,
                Event_Type__c,
                Event_Date__c

            FROM Marketing_Engagement__c

            WHERE Loyalty_Program_Member__c = :memberId

            AND Event_Date__c >= :currentStartDate

            AND Event_Date__c <= :today

            ORDER BY Event_Date__c DESC
        ];



        /*
         * ====================================================
         * 3. PREVIOUS 90 DAYS ENGAGEMENT
         * ====================================================
         */

        List<Marketing_Engagement__c> previousEngagements = [

            SELECT
                Id,
                Loyalty_Program_Member__c,
                Marketing_Campaign__c,
                Channel__c,
                Event_Type__c,
                Event_Date__c

            FROM Marketing_Engagement__c

            WHERE Loyalty_Program_Member__c = :memberId

            AND Event_Date__c >= :previousStartDate

            AND Event_Date__c < :currentStartDate
        ];



        /*
         * ====================================================
         * 4. LATEST ENGAGEMENT PER CAMPAIGN
         * ====================================================
         */

        Map<Id, Marketing_Engagement__c>
            latestEngagementByCampaign =
            new Map<Id, Marketing_Engagement__c>();


        for (
            Marketing_Engagement__c engagement :
            currentEngagements
        ) {

            if (
                engagement.Marketing_Campaign__c == null
            ) {
                continue;
            }


            /*
             * Because records are ordered DESC,
             * first record = latest engagement.
             */

            if (
                !latestEngagementByCampaign.containsKey(
                    engagement.Marketing_Campaign__c
                )
            ) {

                latestEngagementByCampaign.put(
                    engagement.Marketing_Campaign__c,
                    engagement
                );
            }
        }



        /*
         * ====================================================
         * 5. BUILD CAMPAIGN DATA
         * ====================================================
         */

        for (
            Marketing_Campaign__c campaign :
            campaigns
        ) {

            Map<String, Object> campaignMap =
                new Map<String, Object>();


            Marketing_Engagement__c engagement =
                latestEngagementByCampaign.get(
                    campaign.Id
                );


            Boolean engaged =
                engagement != null;



            campaignMap.put(
                'campaignId',
                campaign.Id
            );


            campaignMap.put(
                'campaignName',
                campaign.Name
            );


            campaignMap.put(
                'channel',
                campaign.Channel__c
            );


            campaignMap.put(
                'status',
                campaign.Status__c
            );


            campaignMap.put(
                'engaged',
                engaged
            );


            if (engaged) {

                campaignMap.put(
                    'engagementDate',
                    engagement.Event_Date__c
                );


                campaignMap.put(
                    'eventType',
                    engagement.Event_Type__c
                );


                campaignMap.put(
                    'displayStatus',
                    'Engaged'
                );

            } else {

                campaignMap.put(
                    'engagementDate',
                    null
                );


                campaignMap.put(
                    'eventType',
                    null
                );


                campaignMap.put(
                    'displayStatus',
                    'Not engaged'
                );
            }


            campaignMap.put(
                'iconName',
                MemEngagementUtility.getIconName(
                    engaged
                )
            );


            campaignMap.put(
                'iconVariant',
                MemEngagementUtility.getIconVariant(
                    engaged
                )
            );


            campaignData.add(
                campaignMap
            );
        }



        /*
         * ====================================================
         * 6. EMAIL METRICS
         * ====================================================
         */

        Integer currentEmailSent = 0;
        Integer currentEmailOpened = 0;

        Integer previousEmailSent = 0;
        Integer previousEmailOpened = 0;


        for (
            Marketing_Engagement__c engagement :
            currentEngagements
        ) {

            if (
                engagement.Channel__c != 'Email'
            ) {
                continue;
            }


            if (
                engagement.Event_Type__c == 'Sent'
            ) {

                currentEmailSent++;
            }


            if (
                engagement.Event_Type__c == 'Opened'
            ) {

                currentEmailOpened++;
            }
        }


        for (
            Marketing_Engagement__c engagement :
            previousEngagements
        ) {

            if (
                engagement.Channel__c != 'Email'
            ) {
                continue;
            }


            if (
                engagement.Event_Type__c == 'Sent'
            ) {

                previousEmailSent++;
            }


            if (
                engagement.Event_Type__c == 'Opened'
            ) {

                previousEmailOpened++;
            }
        }


        Decimal emailOpenRate =
            MemEngagementUtility.calculatePercentage(
                currentEmailOpened,
                currentEmailSent
            );


        Decimal previousEmailOpenRate =
            MemEngagementUtility.calculatePercentage(
                previousEmailOpened,
                previousEmailSent
            );


        Decimal emailOpenChange =
            MemEngagementUtility.calculateChange(
                emailOpenRate,
                previousEmailOpenRate
            );



        /*
         * ====================================================
         * 7. SMS METRICS
         * ====================================================
         */

        Integer currentSmsSent = 0;
        Integer currentSmsClicked = 0;

        Integer previousSmsSent = 0;
        Integer previousSmsClicked = 0;


        for (
            Marketing_Engagement__c engagement :
            currentEngagements
        ) {

            if (
                engagement.Channel__c != 'SMS'
            ) {
                continue;
            }


            if (
                engagement.Event_Type__c == 'Sent'
            ) {

                currentSmsSent++;
            }


            if (
                engagement.Event_Type__c == 'Clicked'
            ) {

                currentSmsClicked++;
            }
        }


        for (
            Marketing_Engagement__c engagement :
            previousEngagements
        ) {

            if (
                engagement.Channel__c != 'SMS'
            ) {
                continue;
            }


            if (
                engagement.Event_Type__c == 'Sent'
            ) {

                previousSmsSent++;
            }


            if (
                engagement.Event_Type__c == 'Clicked'
            ) {

                previousSmsClicked++;
            }
        }


        Decimal smsClickRate =
            MemEngagementUtility.calculatePercentage(
                currentSmsClicked,
                currentSmsSent
            );


        Decimal previousSmsClickRate =
            MemEngagementUtility.calculatePercentage(
                previousSmsClicked,
                previousSmsSent
            );


        Decimal smsClickChange =
            MemEngagementUtility.calculateChange(
                smsClickRate,
                previousSmsClickRate
            );



        /*
         * ====================================================
         * 8. OTHER METRICS
         * ==================================================== */

        Date lastEngagement =
            MemEngagementUtility.getLatestEngagementDate(
                currentEngagements
            );


        String appEngagement =
            MemEngagementUtility.getAppEngagement(
                currentEngagements
            );



        /*
         * ====================================================
         * 9. BUILD METRICS MAP
         * ====================================================
         */

        metrics.put(
            'emailOpenRate',
            emailOpenRate
        );


        metrics.put(
            'emailOpenChange',
            emailOpenChange
        );


        metrics.put(
            'smsClickRate',
            smsClickRate
        );


        metrics.put(
            'smsClickChange',
            smsClickChange
        );


        metrics.put(
            'appEngagement',
            appEngagement
        );


        metrics.put(
            'lastEngagement',
            lastEngagement
        );



        /*
         * ====================================================
         * 10. FINAL RESPONSE
         * ====================================================
         */

        response.put(
            'campaigns',
            campaignData
        );


        response.put(
            'metrics',
            metrics
        );


        return response;
    }
}