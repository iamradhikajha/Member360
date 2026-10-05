public with sharing class Member360Helper {

    public static LoyaltyProgramMember getMemberDetail(Id memberId) {
        return [
            SELECT Id, ContactId, Contact.Name, ProgramId, MemberStatus, MembershipNumber,
                   EnrollmentDate, Tier_Stars__c, Player_Card_Number__c, Segment__c,
                   Preferred_Language__c, Preferred_Channel__c, Nationality__c,
                   Property__c, Preferred_Game__c, Owner.Name, LastModifiedDate
            FROM LoyaltyProgramMember
            WHERE Id = :memberId
            LIMIT :Member360Constants.QUERY_LIMIT
        ];
    }

    public static void updateMemberSegment(Id memberId, String segment) {
        LoyaltyProgramMember member = [
            SELECT Id, Segment__c
            FROM LoyaltyProgramMember
            WHERE Id = :memberId
            LIMIT :Member360Constants.QUERY_LIMIT
        ];

        member.Segment__c = segment;
        update member;
    }

    public static void updateMemberProfile(Id memberId, String segment, String preferredLanguage, String preferredChannel, String nationality, String property, String preferredGame) {
        LoyaltyProgramMember member = [
            SELECT Id, Segment__c, Preferred_Language__c, Preferred_Channel__c,
                   Nationality__c, Property__c, Preferred_Game__c
            FROM LoyaltyProgramMember
            WHERE Id = :memberId
            LIMIT :Member360Constants.QUERY_LIMIT
        ];

        member.Segment__c = segment;
        member.Preferred_Language__c = preferredLanguage;
        member.Preferred_Channel__c = preferredChannel;
        member.Nationality__c = nationality;
        member.Property__c = property;
        member.Preferred_Game__c = preferredGame;

        update member;
    }
}