public with sharing class LoyaltyJourneySectionHelper {

    public static List<MemberJourneyItem> getMemberJourney(Id memberId) {
        LoyaltyJourneySectionUtility.validateMemberId(memberId);
        List<MemberJourneyItem> result = new List<MemberJourneyItem>();
        for (TransactionJournal journal :[SELECT Id, Name, ActivityDate, JournalDate, JournalTypeId, JournalType.Name, JournalSubtypeId, JournalSubtype.Name, MemberId, LoyaltyProgramId FROM TransactionJournal WHERE MemberId = :memberId ORDER BY ActivityDate ASC LIMIT 20]) {
            String typeName = journal.JournalType != null ? journal.JournalType.Name : '';
            String subTypeName = journal.JournalSubtype != null ? journal.JournalSubtype.Name : '';
            MemberJourneyItem item = new MemberJourneyItem();
            item.id = String.valueOf(journal.Id);
            item.title = LoyaltyJourneySectionUtility.getJourneyTitle( typeName, subTypeName);
            item.activityDate = journal.ActivityDate != null ? journal.ActivityDate : journal.JournalDate;
            item.type = typeName;
            item.subType = subTypeName;
            result.add(item);
        }
        return result;
    }

    public class MemberJourneyItem {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public Datetime activityDate;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String subType;
    }
}