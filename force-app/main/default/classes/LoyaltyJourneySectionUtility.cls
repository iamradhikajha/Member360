public class LoyaltyJourneySectionUtility {
    public static void validateMemberId(Id memberId) {
        if (memberId == null) throw new AuraHandledException(Member360Constants.ERROR_LOYALTY_MEMBER_ID_REQUIRED);
    }

    public static String getJourneyTitle( String typeName, String subTypeName) {
        String typeValue = typeName != null ? typeName.trim() : '';
        String subTypeValue = subTypeName != null ? subTypeName.trim() : '';
        if (subTypeValue != '') return subTypeValue;
        if (typeValue != '') return typeValue;
        return 'Member Activity';
    }
}