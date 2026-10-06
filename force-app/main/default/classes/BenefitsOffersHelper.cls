public with sharing class BenefitsOffersHelper {

    public static List<BenefitsOffersWrapper> getMemberBenefits(Id memberId) {
        if (memberId == null) {
            throw new AuraHandledException('Loyalty Program Member Id is required.');
        }

        List<MemberBenefit> memberBenefits = [
            SELECT Id,
                   MemberId,
                   BenefitId,
                   Benefit.Name,
                   Benefit.IsActive,
                   Benefit.Description,
                   Benefit.ImageUrl,
                   Benefit.BenefitType.Name,
                   Benefit.BenefitType.Category,
                   StartDate,
                   EndDate,
                   Status
            FROM MemberBenefit
            WHERE MemberId = :memberId
            AND Benefit.IsActive = true
            AND (EndDate = null OR EndDate >= TODAY)
            ORDER BY EndDate ASC NULLS LAST
        ];

        List<BenefitsOffersWrapper> response = new List<BenefitsOffersWrapper>();
        Date today = Date.today();

        for (MemberBenefit memberBenefit : memberBenefits) {
            BenefitsOffersWrapper benefitItem = new BenefitsOffersWrapper();

            benefitItem.memberBenefitId = memberBenefit.Id;
            benefitItem.benefitId = memberBenefit.BenefitId;
            benefitItem.benefitName = memberBenefit.Benefit.Name;
            benefitItem.benefitCategory = memberBenefit.Benefit.BenefitType.Category;
            benefitItem.benefitDescription = memberBenefit.Benefit.Description;
            benefitItem.imageUrl = memberBenefit.Benefit.ImageUrl;
            benefitItem.startDate = memberBenefit.StartDate;
            benefitItem.endDate = memberBenefit.EndDate;
            benefitItem.status = memberBenefit.Status;

            if (memberBenefit.EndDate != null) {
                Integer daysRemaining = today.daysBetween(memberBenefit.EndDate);
                benefitItem.daysRemaining = daysRemaining;
                benefitItem.isExpiringSoon = daysRemaining <= 30;
            } else {
                benefitItem.daysRemaining = null;
                benefitItem.isExpiringSoon = false;
            }

            response.add(benefitItem);
        }

        return response;
    }
}