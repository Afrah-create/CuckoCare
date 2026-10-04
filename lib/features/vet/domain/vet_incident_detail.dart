import '../data/vet_inbox_repository.dart';
import '../data/vet_map_repository.dart';

/// Shared view model for vet incident detail + photos.
class VetIncidentDetail {
  const VetIncidentDetail({
    required this.requestId,
    required this.summary,
    required this.status,
    required this.serviceType,
    required this.priority,
    required this.createdAt,
    required this.shareLocation,
    this.farmerNotes,
    this.affectedBirdCount,
    this.symptoms = const [],
    this.photoObjectKeys = const [],
    this.farmLocationLabel = 'Farm',
    this.distanceKm,
    this.isDirectedRequest = false,
    this.assignedVetUserId,
  });

  final String requestId;
  final String summary;
  final String status;
  final String serviceType;
  final String priority;
  final DateTime createdAt;
  final bool shareLocation;
  final String? farmerNotes;
  final int? affectedBirdCount;
  final List<String> symptoms;
  final List<String> photoObjectKeys;
  final String farmLocationLabel;
  final double? distanceKm;
  final bool isDirectedRequest;
  final String? assignedVetUserId;

  factory VetIncidentDetail.fromInbox(VetInboxItem item) {
    return VetIncidentDetail(
      requestId: item.id,
      summary: item.summary ?? item.serviceType,
      status: item.status,
      serviceType: item.serviceType,
      priority: item.priority,
      createdAt: item.createdAt,
      shareLocation: item.shareLocation,
      farmerNotes: item.farmerNotes,
      affectedBirdCount: item.affectedBirdCount,
      symptoms: item.symptoms,
      photoObjectKeys: item.photoObjectKeys,
      farmLocationLabel: item.farmLocationLabel,
      distanceKm: item.distanceKm,
      isDirectedRequest: item.isDirectedRequest,
      assignedVetUserId: item.assignedVetUserId,
    );
  }

  factory VetIncidentDetail.fromMap(VetMapRequest request) {
    return VetIncidentDetail(
      requestId: request.id,
      summary: request.summary,
      status: request.status,
      serviceType: request.serviceType,
      priority: request.priority,
      createdAt: request.createdAt,
      shareLocation: request.shareLocation,
      farmerNotes: request.farmerNotes,
      affectedBirdCount: request.affectedBirdCount,
      symptoms: request.symptoms,
      photoObjectKeys: request.photoObjectKeys,
      farmLocationLabel: request.locationLabel,
      assignedVetUserId: request.assignedVetUserId,
    );
  }
}
