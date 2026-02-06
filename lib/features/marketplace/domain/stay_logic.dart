/// Calculates the number of stay days based on the user's investment balance.
///
/// Rule: $5,000 USD investment = 7 days of stay rights per year.
/// This function assumes a linear relationship for now.
///
/// [usdBalance] The user's total investment balance in USD for a specific property (or portfolio).
/// Returns the number of days (can be fractional).
/// Calculates the number of stay days based on the user's investment and property price.
///
/// Formula: Floor((UserInvestment / TotalPropertyPrice) * 365)
/// [usdBalance] The user's total investment balance in USD for a specific property.
/// [propertyPrice] The total price/valuation of the property.
/// Returns the number of days allowed.
int calculateStayRights(double usdBalance, double propertyPrice) {
  if (usdBalance < 5000.0 || propertyPrice <= 0) return 0;

  // New Formula: (UserInvestment / TotalPropertyPrice) * 365
  return ((usdBalance / propertyPrice) * 365).floor();
}
