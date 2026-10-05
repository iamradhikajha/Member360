public with sharing class Member360Helper {

    public static LoyaltyProgramMember getMemberDetail(Id memberId) {
        return [
            SELECT Id, ContactId, Contact.Name, ProgramId, MemberStatus, MembershipNumber, EnrollmentDate, Tier_Stars__c, Player_Card_Number__c, Segment__c, Owner.Name, LastModifiedDate FROM LoyaltyProgramMember WHERE Id = :memberId LIMIT :Member360Constants.QUERY_LIMIT];
    }

    public static void updateMemberSegment(Id memberId, String segment) {
        LoyaltyProgramMember member = [ SELECT Id, Segment__c FROM LoyaltyProgramMember WHERE Id = :memberId LIMIT :Member360Constants.QUERY_LIMIT];
        member.Segment__c = segment;
        update member;
    }
}