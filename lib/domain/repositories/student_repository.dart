import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../entities/student.dart';

abstract class StudentRepository {
  Future<Either<Failure, Student>> createStudentProfile(Student student);
  Future<Either<Failure, Student>> getMyProfile();
  Future<Either<Failure, Student>> updateProfile(Student student);
  Future<Either<Failure, List<ApprenticeshipOffer>>> getApprenticeshipOffers({
    String? countryId,
    String? tradeId,
    int? page,
  });
  Future<Either<Failure, ApprenticeshipOffer>> getApprenticeshipOffer(String offerId);
  Future<Either<Failure, void>> applyForApprenticeshipOffer(String offerId);
}
