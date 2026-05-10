import 'package:flutter/material.dart';
import '../models/checkpoint.dart';
import '../models/checkpoint_status.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';

class CheckpointCard extends StatelessWidget {
  final Checkpoint checkpoint;
  final CheckpointStatus? status;
  final VoidCallback onTap;
  
  const CheckpointCard({
    Key? key,
    required this.checkpoint,
    required this.status,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final entranceStatus = status?.entrance.status ?? 'OPEN';
    final exitStatus = status?.exit.status ?? 'OPEN';
    final entrancePercentage = status?.entrance.percentage ?? 0;
    final exitPercentage = status?.exit.percentage ?? 0;
    final entranceVotes = status?.entrance.totalVotes ?? 0;
    final exitVotes = status?.exit.totalVotes ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row - compact
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            checkpoint.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.place,
                                size: 10,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                checkpoint.region,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getVoteColor(entranceVotes + exitVotes),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entranceVotes + exitVotes}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),
                
                // Direction Statuses - side by side compact
                Row(
                  children: [
                    Expanded(
                      child: _buildDirectionTile(
                        title: 'للداخل',
                        status: entranceStatus,
                        percentage: entrancePercentage,
                        votes: entranceVotes,
                        icon: Icons.arrow_forward,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDirectionTile(
                        title: 'للخارج',
                        status: exitStatus,
                        percentage: exitPercentage,
                        votes: exitVotes,
                        icon: Icons.arrow_back,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Action Button - smaller
                Container(
                  width: double.infinity,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'تفاصيل',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: Colors.green.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDirectionTile({
    required String title,
    required String status,
    required double percentage,
    required int votes,
    required IconData icon,
  }) {
    final statusColor = _getStatusColor(status);
    final localizedStatus = _getLocalizedStatus(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: statusColor),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            height: 3,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            localizedStatus,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
          if (votes > 0)
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN': return Colors.green;
      case 'CROWDED': return Colors.orange;
      case 'CLOSED': return Colors.red;
      default: return Colors.green;
    }
  }
  
  String _getLocalizedStatus(String status) {
    switch (status) {
      case 'OPEN': return 'سالك';
      case 'CROWDED': return 'أزمة';
      case 'CLOSED': return 'مغلق';
      default: return status;
    }
  }
  
  Color _getVoteColor(int voteCount) {
    if (voteCount > 20) return Colors.green.shade100;
    if (voteCount > 10) return Colors.orange.shade100;
    return Colors.grey.shade100;
  }
}