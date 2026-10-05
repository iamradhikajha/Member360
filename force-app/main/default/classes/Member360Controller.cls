public with sharing class Member360Controller {

    @AuraEnabled(cacheable=true)
    public static LoyaltyProgramMember getMemberDetail(Id memberId) {
        Member360Utility.validateMemberId(memberId);
        try {
            return Member360Helper.getMemberDetail(memberId);
        } catch (Exception e) {
            throw Member360Utility.fetchException(e);
        }
    }

    @AuraEnabled
    public static void updateMemberSegment(Id memberId, String segment) {
        Member360Utility.validateMemberId(memberId);
        Member360Utility.validateSegment(segment);
        try {
            Member360Helper.updateMemberSegment(memberId, segment);
        } catch (Exception e) {
            throw Member360Utility.updateException(e);
        }
    }
}