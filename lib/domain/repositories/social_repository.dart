import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../entities/social.dart';

abstract class SocialRepository {
  // Donations
  Future<Either<Failure, Donation>> createDonation(Donation donation);
  Future<Either<Failure, List<Donation>>> getMyDonations({int? page});
  Future<Either<Failure, List<Donation>>> getDonationsReceived({String? recipientId, int? page});
  
  // Referrals
  Future<Either<Failure, ReferralCode>> generateReferralCode();
  Future<Either<Failure, ReferralCode>> getReferralStats();
  Future<Either<Failure, bool>> validateReferralCode(String code);
  
  // Notifications
  Future<Either<Failure, List<Notification>>> getNotifications({int? page});
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId);
  Future<Either<Failure, void>> deleteNotification(String notificationId);
  
  // Advertisements
  Future<Either<Failure, List<Advertisement>>> getCarouselAds();
  Future<Either<Failure, Advertisement>> getAdvertisement(String adId);
  Future<Either<Failure, void>> recordAdView(String adId);
  Future<Either<Failure, void>> recordAdClick(String adId);
}
