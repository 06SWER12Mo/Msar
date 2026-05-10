// vote_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/checkpoint.dart';
import '../models/vote.dart';
import '../services/checkpoint_service.dart';
import '../services/auth_service.dart';
import '../utils/localization.dart';

class VoteScreen extends StatefulWidget {
  final Checkpoint checkpoint;
  final Position? userPosition;
  
  const VoteScreen({
    Key? key,
    required this.checkpoint,
    this.userPosition,
  }) : super(key: key);
  
  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final CheckpointService _checkpointService = CheckpointService();
  final AuthService _authService = AuthService();
  
  String? _entranceStatus;
  String? _exitStatus;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasVotedOnce = false;
  
  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 'OPEN', 'label': 'سالك', 'icon': Icons.check_circle, 'color': Colors.green},
    {'value': 'CROWDED', 'label': 'أزمة', 'icon': Icons.warning_amber, 'color': Colors.orange},
    {'value': 'CLOSED', 'label': 'مغلق', 'icon': Icons.block, 'color': Colors.red},
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade800, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade800.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.how_to_vote, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'تسجيل تصويت جديد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Checkpoint Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.green.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 32,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.checkpoint.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.checkpoint.region,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'يمكنك التصويت للحاجز من أي مكان. صوتك يساعد المجتمع في معرفة الحالة الحقيقية.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Entrance Vote Card
            _buildDirectionVoteCard(
              title: 'للداخل',
              subtitle: 'من الطريق الخارجة دخولا بالمنطقة',
              icon: Icons.arrow_forward,
              selectedStatus: _entranceStatus,
              backgroundColor: Colors.blue.shade50,
              onStatusSelected: (status) {
                setState(() {
                  _entranceStatus = status;
                  _hasVotedOnce = true;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Exit Vote Card
            _buildDirectionVoteCard(
              title: 'للخارج',
              subtitle: 'خارج من المنطقة باتجاه شارع رئيسي أو خط سريع',
              icon: Icons.arrow_back,
              selectedStatus: _exitStatus,
              backgroundColor: Colors.orange.shade50,
              onStatusSelected: (status) {
                setState(() {
                  _exitStatus = status;
                  _hasVotedOnce = true;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Comment Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.comment, size: 20, color: Colors.purple.shade700),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'تعليق إضافي',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'اختياري',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _commentController,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'مثال: الحاجز مزدحم جداً بسبب التفتيش الدقيق...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.green.shade500, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting || !_hasVotedOnce ? null : _submitVote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            'إرسال التصويت',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _hasVotedOnce ? Colors.white : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDirectionVoteCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String? selectedStatus,
    required Color backgroundColor,
    required Function(String) onStatusSelected,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.grey.shade800, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedStatus != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(selectedStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(selectedStatus).withOpacity(0.3)),
                  ),
                  child: Text(
                    _getLocalizedStatus(selectedStatus),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(selectedStatus),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          
          // Status Options
          Row(
            children: _statusOptions.map((option) {
              final isSelected = selectedStatus == option['value'];
              final color = option['color'] as Color;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => onStatusSelected(option['value']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      left: option == _statusOptions.first ? 0 : 6,
                      right: option == _statusOptions.last ? 0 : 6,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          option['icon'],
                          color: isSelected ? color : Colors.grey.shade500,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option['label'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? color : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
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
      default: return Colors.grey;
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
  
  Future<void> _submitVote() async {
    setState(() => _isSubmitting = true);
    
    try {
      final userId = _authService.currentUser!.uid;
      final List<Future> votes = [];
      
      if (_entranceStatus != null) {
        votes.add(_checkpointService.submitVote(Vote(
          id: '',
          checkpointId: widget.checkpoint.id,
          userId: userId,
          direction: 'ENTRANCE',
          status: _entranceStatus!,
          comment: _commentController.text.isNotEmpty ? _commentController.text : null,
          timestamp: DateTime.now(),
          userLatitude: widget.userPosition?.latitude,
          userLongitude: widget.userPosition?.longitude,
        )));
      }
      
      if (_exitStatus != null) {
        votes.add(_checkpointService.submitVote(Vote(
          id: '',
          checkpointId: widget.checkpoint.id,
          userId: userId,
          direction: 'EXIT',
          status: _exitStatus!,
          comment: _commentController.text.isNotEmpty ? _commentController.text : null,
          timestamp: DateTime.now(),
          userLatitude: widget.userPosition?.latitude,
          userLongitude: widget.userPosition?.longitude,
        )));
      }
      
      await Future.wait(votes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('✓ تم تسجيل تصويتك بنجاح! شكراً لمشاركتك')),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('🔴 Vote submission error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}