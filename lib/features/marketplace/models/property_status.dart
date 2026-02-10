enum PropertyStatus {
  active, // Open for Investment
  comingSoon, // Visible but Locked (Marketing Mode)
  soldOut, // Fully Funded
  hidden, // Draft / Invisible
}

extension PropertyStatusExtension on PropertyStatus {
  String get name {
    switch (this) {
      case PropertyStatus.active:
        return 'active';
      case PropertyStatus.comingSoon:
        return 'comingSoon';
      case PropertyStatus.soldOut:
        return 'soldOut';
      case PropertyStatus.hidden:
        return 'hidden';
    }
  }

  String get displayName {
    switch (this) {
      case PropertyStatus.active:
        return 'Active';
      case PropertyStatus.comingSoon:
        return 'Coming Soon';
      case PropertyStatus.soldOut:
        return 'Sold Out';
      case PropertyStatus.hidden:
        return 'Hidden';
    }
  }

  static PropertyStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'on sale':
        return PropertyStatus.active;
      case 'comingsoon':
      case 'coming soon':
        return PropertyStatus.comingSoon;
      case 'soldout':
      case 'sold out':
      case 'completed':
        return PropertyStatus.soldOut;
      case 'hidden':
      case 'draft':
      default:
        return PropertyStatus.hidden;
    }
  }
}
