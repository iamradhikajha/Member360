public class Member360Utility {

    public static void validateMemberId(Id memberId) {
        if (memberId == null) {
            throw new AuraHandledException(
                Member360Constants.ERROR_MEMBER_ID_NULL
            );
        }
    }

    public static void validateSegment(String segment) {
        if (String.isBlank(segment)) {
            throw new AuraHandledException(
                Member360Constants.ERROR_SEGMENT_BLANK
            );
        }
    }

    public static AuraHandledException fetchException(Exception e) {
        return new AuraHandledException(
            Member360Constants.ERROR_FETCH_MEMBER + e.getMessage()
        );
    }

    public static AuraHandledException updateException(Exception e) {
        return new AuraHandledException(
            Member360Constants.ERROR_UPDATE_SEGMENT + e.getMessage()
        );
    }
}