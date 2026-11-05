use crate::errors::AppError;

pub fn validate_transition(current_status: &str, new_status: &str) -> Result<(), AppError> {
    let valid = match (current_status, new_status) {
        // From OPEN
        ("OPEN", "RESPONDING") => true,
        ("OPEN", "CANCELLED") => true,
        ("OPEN", "EXPIRED") => true,

        // From RESPONDING
        ("RESPONDING", "HELP_ARRIVING") => true,
        ("RESPONDING", "OPEN") => true, // If responder withdraws
        ("RESPONDING", "CANCELLED") => true,
        ("RESPONDING", "EXPIRED") => true,

        // From HELP_ARRIVING
        ("HELP_ARRIVING", "ASSISTANCE_PROVIDED") => true,
        ("HELP_ARRIVING", "RESOLVED") => true,
        ("HELP_ARRIVING", "RESPONDING") => true,
        ("HELP_ARRIVING", "CANCELLED") => true,

        // From ASSISTANCE_PROVIDED
        ("ASSISTANCE_PROVIDED", "RESOLVED") => true,

        // No transitions from terminal states
        ("RESOLVED", _) => false,
        ("CANCELLED", _) => false,
        ("EXPIRED", _) => false,

        _ => false,
    };

    if valid {
        Ok(())
    } else {
        Err(AppError::BadRequest(format!(
            "Invalid status transition from '{}' to '{}'.",
            current_status, new_status
        )))
    }
}

