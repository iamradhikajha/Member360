public with sharing class Member360Controller {

    @AuraEnabled(cacheable=true)
    public static LoyaltyProgramMember getMemberDetail(Id memberId) {
        return Member360Helper.getMemberDetail(memberId);
    }

    @AuraEnabled
    public static void updateMemberSegment(Id memberId, String segment) {
        Member360Helper.updateMemberSegment(memberId, segment);
    }

    @AuraEnabled
    public static void updateMemberProfile(Id memberId, String segment, String preferredLanguage, String preferredChannel, String nationality, String property, String preferredGame) {
        Member360Helper.updateMemberProfile(memberId, segment, preferredLanguage, preferredChannel, nationality, property, preferredGame);
    }
}