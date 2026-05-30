import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../entities/social.dart';
import '../repositories/social_repository.dart';

// Donation Use Cases
class CreateDonationUseCase {
  final SocialRepository repository;

  CreateDonationUseCase(this.repository);

  Future<Either<Failure, Donation>> call(Donation donation) {
    return repository.createDonation(donation);
  }
}

class GetMyDonationsUseCase {
  final SocialRepository repository;

  GetMyDonationsUseCase(this.repository);

  Future<Either<Failure, List<Donation>>> call({int? page}) {
    return repository.getMyDonations(page: page);
  }
}

class GetDonationsReceivedUseCase {
  final SocialRepository repository;

  GetDonationsReceivedUseCase(this.repository);

  Future<Either<Failure, List<Donation>>> call({String? recipientId, int? page}) {
    return repository.getDonationsReceived(recipientId: recipientId, page: page);
  }
}

// Referral Use Cases
class GenerateReferralCodeUseCase {
  final SocialRepository repository;

  GenerateReferralCodeUseCase(this.repository);

  Future<Either<Failure, ReferralCode>> call() {
    return repository.generateReferralCode();
  }
}

class GetReferralStatsUseCase {
  final SocialRepository repository;

  GetReferralStatsUseCase(this.repository);

  Future<Either<Failure, ReferralCode>> call() {
    return repository.getReferralStats();
  }
}

class ValidateReferralCodeUseCase {
  final SocialRepository repository;

  ValidateReferralCodeUseCase(this.repository);

  Future<Either<Failure, bool>> call(String code) {
    return repository.validateReferralCode(code);
  }
}

// Notification Use Cases
class GetNotificationsUseCase {
  final SocialRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<Notification>>> call({int? page}) {
    return repository.getNotifications(page: page);
  }
}

class MarkNotificationAsReadUseCase {
  final SocialRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String notificationId) {
    return repository.markNotificationAsRead(notificationId);
  }
}

class DeleteNotificationUseCase {
  final SocialRepository repository;

  DeleteNotificationUseCase(this.repository);

  Future<Either<Failure, void>> call(String notificationId) {
    return repository.deleteNotification(notificationId);
  }
}

// Advertisement Use Cases
class GetCarouselAdsUseCase {
  final SocialRepository repository;

  GetCarouselAdsUseCase(this.repository);

  Future<Either<Failure, List<Advertisement>>> call() {
    return repository.getCarouselAds();
  }
}

class GetAdvertisementUseCase {
  final SocialRepository repository;

  GetAdvertisementUseCase(this.repository);

  Future<Either<Failure, Advertisement>> call(String adId) {
    return repository.getAdvertisement(adId);
  }
}

class RecordAdViewUseCase {
  final SocialRepository repository;

  RecordAdViewUseCase(this.repository);

  Future<Either<Failure, void>> call(String adId) {
    return repository.recordAdView(adId);
  }
}

class RecordAdClickUseCase {
  final SocialRepository repository;

  RecordAdClickUseCase(this.repository);

  Future<Either<Failure, void>> call(String adId) {
    return repository.recordAdClick(adId);
  }
}
