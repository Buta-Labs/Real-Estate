/// Calculates the number of stay days based on the user's investment balance.
///
/// Rule: $5,000 USD investment = 7 days of stay rights per year.
/// This function assumes a linear relationship for now.
///
/// [usdBalance] The user's total investment balance in USD for a specific property (or portfolio).
/// Returns the number of days (can be fractional).
double calculateStayRights(double usdBalance) {
  const double threshold = 5000.0;
  const double daysPerThreshold = 7.0;

  if (usdBalance <= 0) return 0.0;

  // Linear calculation: (Balance / 5000) * 7
  return (usdBalance / threshold) * daysPerThreshold;
}
