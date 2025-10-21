import 'package:dailydevotion/Models/user.dart';
import 'package:dailydevotion/admin/providers/video_provider1.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/stripe/make_payment.dart';
import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:dailydevotion/widgets/community_post.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final AppLocalizations tr;
  final UserModel user;
  const Home({super.key, required this.user, required this.tr});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch all videos for normal users
      Provider.of<VideoProvider1>(context, listen: false).fetchAllVideos();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "${widget.tr.goodMorning}!";
    if (hour < 17) return "${widget.tr.goodAfternoon}!";
    return "${widget.tr.goodEvening}!";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final videoProvider = Provider.of<VideoProvider1>(context);
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;

    return SafeArea(
      child: Scaffold(
        // appBar: CustomAppBar(title: "Cherche"),
        body: RefreshIndicator(
          onRefresh: () async {
            await videoProvider.fetchAllVideos();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                left: width * 0.02,
                right: width * 0.02,
                top: height * 0.01,
                bottom: height * 0.1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //

                  // Greeting Section
                  _buildGreetingSection(height, width, themeProvider),

                  SizedBox(height: height * 0.03),

                  // Featured Devotions Header
                  _buildSectionHeader(
                    widget.tr.featuredDevotions,
                    width,
                    themeProvider,
                  ),

                  SizedBox(height: height * 0.02),

                  // Videos List
                  _buildVideosList(videoProvider, height, width, themeProvider),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(
    double height,
    double width,
    ThemeProvider themeProvider,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.01),
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[700] : Color(0xFF130E6A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.grey.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.06,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  widget.user.name,
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: themeProvider.isDarkMode
                        ? Colors.grey[300]
                        : Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: width * 0.15,
              height: width * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    widget.user.profilePic != null &&
                        widget.user.profilePic!.isNotEmpty
                    ? null
                    : LinearGradient(
                        colors: [Color(0xFF130E6A), Colors.deepPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                image:
                    widget.user.profilePic != null &&
                        widget.user.profilePic!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.user.profilePic!),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  (widget.user.profilePic == null ||
                      widget.user.profilePic!.isEmpty)
                  ? Center(
                      child: Text(
                        widget.user.name.isNotEmpty
                            ? widget.user.name[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    double width,
    ThemeProvider themeProvider,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Color(0xFF130E6A),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: width * 0.03),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: width * 0.045,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(double width, ThemeProvider themeProvider) {
    return Container(
      width: width,
      padding: EdgeInsets.all(width * 0.1),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: width * 0.15,
            color: Colors.grey,
          ),
          SizedBox(height: width * 0.04),
          Center(
            child: Text(
              // "No available videos yet",
              widget.tr.noVideo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.04,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: width * 0.02),
          Text(
            // "Check Back Later!",
            "${widget.tr.checkBack}!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: width * 0.035,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  //
  Widget _buildPremiumLockedState(double width, AppLocalizations tr) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: width * 0.05),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(Icons.lock, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              // "Premium Content Only",
              tr.premiumContentOnly,
              style: TextStyle(
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              // "Subscribe to unlock all videos and get exclusive content!",
              tr.subscribeToUnlock,
              style: TextStyle(
                fontSize: width * 0.035,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: width * 0.5,
              // height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF130E6A),
                  foregroundColor: Colors.white,
                ),
                // onPressed: () async{
                //   // Navigate to subscription page
                //   await makePayment()
                // },
                onPressed: () async {
                  await makePayment(3100, context);
                  // await makePayment(70, context); // = CHF 0.01
                },

                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    textAlign: TextAlign.center,
                    // "Subscribe Now",
                    tr.subscribeNow,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosList(
    VideoProvider1 videoProvider,
    double height,
    double width,
    ThemeProvider themeProvider,
  ) {
    //
    if (!videoProvider.hasValidSubscription) {
      // User is not premium

      // Videos exist but user can't access
      return _buildPremiumLockedState(width, widget.tr);
    }

    // Premium Users
    if (videoProvider.allVideos.isEmpty) {
      return _buildEmptyState(width, themeProvider);
    }

    return ListView.builder(
      itemCount: videoProvider.allVideos.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final video = videoProvider.allVideos[index];

        // return PostCard(videoModel: video);
        return CommunityPost(videoModel: video, tr: widget.tr);
      },
    );
  }
}
