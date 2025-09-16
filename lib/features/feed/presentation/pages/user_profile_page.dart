import 'package:flutter/material.dart';
import '../../../../core/consts/color_manager.dart';
import '../../domain/entities/user.dart';

class UserProfilePage extends StatefulWidget {
  final User user;

  const UserProfilePage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorManager.backgroundPrimary,
              ColorManager.backgroundSecondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 30),
                          _buildUserInfo(),
                          const SizedBox(height: 30),
                          _buildStatsSection(),
                          const SizedBox(height: 30),
                          _buildActionButtons(),
                          const SizedBox(height: 30),
                          _buildComingSoonSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: ColorManager.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: ColorManager.textPrimary,
              ),
            ),
          ),
          const Spacer(),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: ColorManager.primaryGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: ColorManager.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: ColorManager.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                // TODO: More options
              },
              icon: Icon(
                Icons.more_vert_rounded,
                color: ColorManager.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: ColorManager.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: ColorManager.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.transparent,
            child: Text(
              widget.user.name.isNotEmpty
                  ? widget.user.name.substring(0, 1).toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: ColorManager.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.user.name,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: ColorManager.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ColorManager.verified.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ColorManager.verified.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: ColorManager.verified,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Verified User',
                    style: TextStyle(
                      color: ColorManager.verified,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ColorManager.cardGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorManager.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: ColorManager.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'User Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email_outlined, 'Email', widget.user.email),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.alternate_email_rounded, 'Username', widget.user.username),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_outlined, 'Phone', widget.user.phone ?? 'Not provided'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.language_rounded, 'Website', widget.user.website ?? 'Not provided'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: ColorManager.textSecondary,
          size: 18,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorManager.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: ColorManager.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.primary.withOpacity(0.1),
            ColorManager.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorManager.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('Posts', '42', Icons.article_rounded)),
          Expanded(child: _buildStatItem('Likes', '1.2K', Icons.favorite_rounded)),
          Expanded(child: _buildStatItem('Comments', '256', Icons.chat_bubble_rounded)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: ColorManager.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: ColorManager.textPrimary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ColorManager.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ColorManager.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ColorManager.primaryGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Follow functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Follow functionality coming soon!'),
                    backgroundColor: ColorManager.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.person_add_rounded,
                color: ColorManager.textPrimary,
              ),
              label: Text(
                'Follow',
                style: TextStyle(
                  color: ColorManager.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: ColorManager.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: () {
              // TODO: Message functionality
            },
            icon: Icon(
              Icons.message_rounded,
              color: ColorManager.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComingSoonSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.gold.withOpacity(0.1),
            ColorManager.premium.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorManager.gold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.stars_rounded,
            color: ColorManager.gold,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ColorManager.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'User posts, followers, and more profile features will be available in the next update!',
            style: TextStyle(
              fontSize: 14,
              color: ColorManager.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}