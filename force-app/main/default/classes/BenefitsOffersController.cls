public with sharing class BenefitsOffersController {

    @AuraEnabled(cacheable=true)
    public static List<BenefitsOffersWrapper> getMemberBenefits(Id memberId) {
        return BenefitsOffersHelper.getMemberBenefits(memberId);
    }
}