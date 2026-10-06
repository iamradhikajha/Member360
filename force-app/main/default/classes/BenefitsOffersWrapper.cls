public class BenefitsOffersWrapper {
    @AuraEnabled public Id memberBenefitId;
    @AuraEnabled public Id benefitId;
    @AuraEnabled public String benefitName;
    @AuraEnabled public String benefitCategory;
    @AuraEnabled public String benefitDescription;
    @AuraEnabled public String imageUrl;
    @AuraEnabled public Date startDate;
    @AuraEnabled public Date endDate;
    @AuraEnabled public String status;
    @AuraEnabled public Boolean isExpiringSoon;
    @AuraEnabled public Integer daysRemaining;
}