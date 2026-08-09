import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

// 主入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LearningStats().init();
  runApp(const OxfordWordGame());
}

class OxfordWordGame extends StatelessWidget {
  const OxfordWordGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '牛津词汇挑战',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF5F7FF),
        // 中文字体回退，确保 Web/桌面端中文正常显示
        fontFamily: 'Microsoft YaHei',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6C63FF),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Microsoft YaHei',
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// 启动屏
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 跳转到游戏选择页面
  void _navigateToGame() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const GameSelectPage(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6C63FF),
                Color(0xFF8B5CF6),
                Color(0xFFA78BFA),
              ],
            ),
          ),
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 图标
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // 文字
                    const Text(
                      '这是大双小双的',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '我爱背单词',
                      style: TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    // 两个按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 我的按钮
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '我的',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // 开始游戏按钮
                        ElevatedButton(
                          onPressed: _navigateToGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6C63FF),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            '开始游戏',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }
}

// 单词数据模型
class Word {
  final String word;
  final String meaning;

  Word({required this.word, required this.meaning});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
    );
  }
}

// 学习数据统计（全局单例，持久化存储）
class LearningStats {
  static final LearningStats _instance = LearningStats._internal();
  factory LearningStats() => _instance;
  LearningStats._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;

  int totalScore = 0;       // 总得分
  int totalQuestions = 0;   // 总答题数
  int correctCount = 0;     // 正确数
  int maxStreak = 0;        // 最高连击
  List<Word> wrongWords = []; // 错题本（去重）

  // 初始化，从本地加载数据
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    totalScore = _prefs!.getInt('totalScore') ?? 0;
    totalQuestions = _prefs!.getInt('totalQuestions') ?? 0;
    correctCount = _prefs!.getInt('correctCount') ?? 0;
    maxStreak = _prefs!.getInt('maxStreak') ?? 0;

    // 加载错题本
    final wrongWordsJson = _prefs!.getString('wrongWords');
    if (wrongWordsJson != null) {
      final List<dynamic> list = jsonDecode(wrongWordsJson);
      wrongWords = list.map((item) => Word.fromJson(item as Map<String, dynamic>)).toList();
    }

    _initialized = true;
  }

  // 保存到本地
  void _save() {
    if (_prefs == null) return;
    _prefs!.setInt('totalScore', totalScore);
    _prefs!.setInt('totalQuestions', totalQuestions);
    _prefs!.setInt('correctCount', correctCount);
    _prefs!.setInt('maxStreak', maxStreak);

    // 保存错题本
    final wrongWordsJson = jsonEncode(wrongWords.map((w) => {
      'word': w.word,
      'meaning': w.meaning,
    }).toList());
    _prefs!.setString('wrongWords', wrongWordsJson);
  }

  // 答对了
  void addCorrect(int score, int currentStreak) {
    totalQuestions++;
    correctCount++;
    totalScore += score;
    if (currentStreak > maxStreak) {
      maxStreak = currentStreak;
    }
    _save();
  }

  // 答错了
  void addWrong(Word word) {
    totalQuestions++;
    // 去重：已经在错题本里的就不加了
    if (!wrongWords.any((w) => w.word == word.word)) {
      wrongWords.add(word);
    }
    _save();
  }

  // 正确率
  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return correctCount / totalQuestions;
  }

  // 正确率字符串
  String get accuracyStr {
    if (totalQuestions == 0) return '0%';
    return '${(accuracy * 100).toStringAsFixed(0)}%';
  }

  // 清空统计
  void clear() {
    totalScore = 0;
    totalQuestions = 0;
    correctCount = 0;
    maxStreak = 0;
    wrongWords.clear();
    _save();
  }
}

// 我的页面
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 顶部个人信息区域
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 头像
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.child_care_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 昵称
                  const Text(
                    '小小学霸',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 等级
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '⭐ 词汇新星 Lv.1',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 学习统计卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 学习统计',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('总得分', '${LearningStats().totalScore}', Colors.blue),
                        _buildStatItem('答题数', '${LearningStats().totalQuestions}', Colors.green),
                        _buildStatItem('正确率', LearningStats().accuracyStr, Colors.orange),
                        _buildStatItem('最高连击', '${LearningStats().maxStreak}', Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 功能列表
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.book_rounded,
                      title: '错词本',
                      subtitle: '复习答错的单词',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WrongWordsPage(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.history_rounded,
                      title: '学习记录',
                      subtitle: '查看历史学习数据',
                      color: Colors.blue,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('学习记录功能开发中...')),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.settings_rounded,
                      title: '设置',
                      subtitle: '音效、震动等设置',
                      color: Colors.grey,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('设置功能开发中...')),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.system_update_rounded,
                      title: '检查更新',
                      subtitle: '检查最新版本',
                      color: Colors.teal,
                      onTap: () => _checkUpdate(context),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      title: '关于',
                      subtitle: '版本信息',
                      color: Colors.purple,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('关于'),
                            content: const Text(
                              '牛津词汇挑战 v1.0\n\n专为大双小双打造的背单词游戏\n沪教牛津版小学英语词汇',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('好的'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 底部文字
            const Text(
              '加油，你是最棒的！💪',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 统计项组件
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // 菜单项组件
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // 分割线
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey[100]),
    );
  }

  // 检查更新
  void _checkUpdate(BuildContext context) async {
    const String currentVersion = '1.2.1';
    const String versionUrl = 'https://gitee.com/alanfoxe/oxford-word-game/raw/master/version.json';

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('正在检查更新...'),
          ],
        ),
      ),
    );

    try {
      final response = await http.get(
        Uri.parse(versionUrl),
      ).timeout(const Duration(seconds: 10));

      Navigator.pop(context); // 关闭加载对话框

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = data['version'] as String;
        final releaseNotes = data['notes'] ?? '暂无更新说明';
        final apkUrl = data['apk_url'] as String?;

        // 比较版本号
        final hasUpdate = _compareVersions(latestVersion, currentVersion) > 0;

        if (hasUpdate && apkUrl != null) {
          // 有新版本，显示更新对话框
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('发现新版本 v$latestVersion'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('更新内容：', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(releaseNotes),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _downloadAndInstall(context, apkUrl!, latestVersion);
                  },
                  child: const Text('立即更新'),
                ),
              ],
            ),
          );
        } else {
          // 已是最新版本
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已是最新版本！')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('检查更新失败，请稍后再试')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // 关闭加载对话框
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('检查更新失败：$e')),
      );
    }
  }

  // 比较版本号：返回 1 表示 v1 > v2，-1 表示 v1 < v2，0 表示相等
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    for (int i = 0; i < 3; i++) {
      if (parts1[i] > parts2[i]) return 1;
      if (parts1[i] < parts2[i]) return -1;
    }
    return 0;
  }

  // 下载并安装 APK
  void _downloadAndInstall(BuildContext context, String url, String version) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('正在下载更新包...'),
          ],
        ),
      ),
    );

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(minutes: 5));
      Navigator.pop(context);

      if (response.statusCode == 200) {
        // 保存到临时目录
        final tempDir = await getTemporaryDirectory();
        final apkPath = '${tempDir.path}/oxford_word_game_v$version.apk';
        final file = File(apkPath);
        await file.writeAsBytes(response.bodyBytes);

        // 打开安装
        OpenFilex.open(apkPath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('下载失败，请稍后再试')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('下载失败：$e')),
      );
    }
  }
}

// 错词本页面
class WrongWordsPage extends StatelessWidget {
  const WrongWordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wrongWords = LearningStats().wrongWords;

    return Scaffold(
      appBar: AppBar(
        title: Text('错词本 (${wrongWords.length})'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
          ),
        ),
        child: wrongWords.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 80, color: Colors.white70),
                    SizedBox(height: 16),
                    Text(
                      '太棒了！还没有错题',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: wrongWords.length,
                itemBuilder: (context, index) {
                  final word = wrongWords[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                word.word,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6C63FF),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                word.meaning,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.volume_up_rounded,
                          color: Colors.grey,
                          size: 28,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// 游戏选择页面
class GameSelectPage extends StatelessWidget {
  const GameSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择游戏'),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SplashScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                '🎮 选择游戏模式',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '选一个喜欢的游戏开始背单词吧！',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              // 游戏1：选择题
              _buildGameCard(
                context,
                icon: Icons.quiz_rounded,
                title: '选择题',
                description: '四选一，选出正确的中文释义',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GamePage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // 游戏2：填空题（怪物大炮）
              _buildGameCard(
                context,
                icon: Icons.rocket_launch_rounded,
                title: '大炮填单词',
                description: '填字母开大炮，打败嚣张的怪物！',
                color: Colors.red,
                badge: 'NEW',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FillInBlankPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // 游戏3：敬请期待
              _buildGameCard(
                context,
                icon: Icons.more_horiz_rounded,
                title: '更多游戏',
                description: '敬请期待...',
                color: Colors.grey,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('更多游戏开发中...')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 32,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

// 大炮填单词游戏页面
class FillInBlankPage extends StatefulWidget {
  const FillInBlankPage({super.key});

  @override
  State<FillInBlankPage> createState() => _FillInBlankPageState();
}

class _FillInBlankPageState extends State<FillInBlankPage>
    with TickerProviderStateMixin {
  List<Word> _words = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;

  // 当前题目相关
  String _currentWord = '';
  String _currentMeaning = '';
  List<int> _blankIndices = []; // 空格的位置索引
  List<String?> _userAnswers = []; // 用户填入的答案
  List<String> _letterOptions = []; // 可选字母
  Set<int> _usedLetterIndices = {}; // 已使用的字母按钮索引
  int _currentBlankIndex = 0; // 当前要填的是第几个空格

  // 状态
  bool _showResult = false;
  bool _isCorrect = false;
  bool _allFilled = false; // 所有空格都填完了
  bool _cannonRising = false; // 大炮正在升起
  bool _projectileFlying = false; // 炮弹正在飞行
  bool _monsterHit = false; // 怪物被击中
  bool _projectileMissed = false; // 炮弹打偏了

  // 动画控制器
  late AnimationController _monsterController;
  late AnimationController _cannonController;
  late AnimationController _projectileController;
  late AnimationController _shakeController;
  late AnimationController _explosionController; // 爆炸动画

  // 嘲讽语录
  final List<String> _taunts = [
    '哼，你肯定不会！',
    '哈哈哈，太简单了？',
    '加油啊，小笨蛋~',
    '这都不会？笑死我了',
    '你能答对算我输！',
    '嘿嘿，卡住了吧？',
    '慢慢想，我不急~',
    '就这？就这水平？',
  ];

  final List<String> _moreTaunts = [
    '哈哈哈，就这？',
    '菜！太菜了！',
    '我都替你着急',
    '不行不行不行~',
    '再来一百次也没用',
    '哈哈哈，笑死我了',
  ];

  final List<String> _surrenderLines = [
    '别打了！我投降！',
    '呜呜呜，我错了...',
    '你赢了，放过我吧',
    '大哥饶命！',
    '我认输还不行吗',
  ];

  String _currentTaunt = '';

  @override
  void initState() {
    super.initState();
    _loadWords();
    _setupAnimations();
    _currentTaunt = _taunts[Random().nextInt(_taunts.length)];
  }

  void _setupAnimations() {
    // 怪物呼吸动画
    _monsterController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // 大炮升起动画（更慢更明显）
    _cannonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 炮弹飞行动画（更慢，有抛物线感）
    _projectileController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 怪物抖动动画
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 爆炸动画
    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  // 加载词库
  Future<void> _loadWords() async {
    try {
      final String response = await rootBundle.loadString('assets/words.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _words = data.map((item) => Word.fromJson(item)).toList();
        _isLoading = false;
        _generateQuestion();
      });
    } catch (e) {
      // fallback
      setState(() {
        _words = [
          Word(word: 'apple', meaning: 'n. 苹果'),
          Word(word: 'book', meaning: 'n. 书'),
          Word(word: 'cat', meaning: 'n. 猫'),
          Word(word: 'dog', meaning: 'n. 狗'),
          Word(word: 'happy', meaning: 'adj. 快乐的'),
          Word(word: 'school', meaning: 'n. 学校'),
          Word(word: 'teacher', meaning: 'n. 老师'),
          Word(word: 'student', meaning: 'n. 学生'),
        ];
        _isLoading = false;
        _generateQuestion();
      });
    }
  }

  // 生成新题目
  void _generateQuestion() {
    if (_words.isEmpty) return;

    final word = _words[_currentIndex];
    _currentWord = word.word;
    _currentMeaning = word.meaning;

    // 随机挖掉2-3个字母（单词长度要足够）
    int blankCount = _currentWord.length <= 4
        ? 1
        : _currentWord.length <= 6
            ? 2
            : 3;

    // 随机选择空格位置
    List<int> indices = List.generate(_currentWord.length, (i) => i);
    indices.shuffle();
    _blankIndices = indices.take(blankCount).toList()..sort();

    // 初始化用户答案
    _userAnswers = List.filled(blankCount, null);
    _currentBlankIndex = 0;

    // 生成可选字母（正确字母 + 干扰字母）
    List<String> letters = [];
    // 先加正确字母（保留重复，比如两个n）
    for (int idx in _blankIndices) {
      letters.add(_currentWord[idx]);
    }
    // 添加干扰字母
    final allLetters = 'abcdefghijklmnopqrstuvwxyz'.split('');
    allLetters.shuffle();
    for (String letter in allLetters) {
      if (letters.length >= 8) break;
      // 干扰字母不重复，且不是正确字母中的（避免过多正确字母）
      if (!letters.contains(letter)) {
        letters.add(letter);
      }
    }
    _letterOptions = letters..shuffle();
    _usedLetterIndices = {};

    // 重置状态
    _showResult = false;
    _isCorrect = false;
    _allFilled = false;
    _cannonRising = false;
    _projectileFlying = false;
    _monsterHit = false;
    _projectileMissed = false;
    _currentTaunt = _taunts[Random().nextInt(_taunts.length)];

    _cannonController.reset();
    _projectileController.reset();
    _shakeController.reset();
    _explosionController.reset();
  }

  // 用户点击字母
  void _onLetterSelected(int index) {
    if (_showResult) return;
    if (_allFilled) return;
    if (_currentBlankIndex >= _blankIndices.length) return;
    if (_usedLetterIndices.contains(index)) return;

    final letter = _letterOptions[index];
    setState(() {
      _userAnswers[_currentBlankIndex] = letter;
      _usedLetterIndices.add(index);
      _currentBlankIndex++;

      // 如果填完了所有空格，显示确定按钮
      if (_currentBlankIndex >= _blankIndices.length) {
        _allFilled = true;
      }
    });
  }

  // 点击确定按钮
  void _onConfirm() {
    _checkAnswer();
  }

  // 检查答案
  void _checkAnswer() {
    bool correct = true;
    for (int i = 0; i < _blankIndices.length; i++) {
      if (_userAnswers[i] != _currentWord[_blankIndices[i]]) {
        correct = false;
        break;
      }
    }

    _isCorrect = correct;

    // 更新学习统计
    final currentWordObj = Word(word: _currentWord, meaning: _currentMeaning);
    if (correct) {
      LearningStats().addCorrect(15, 0);
    } else {
      LearningStats().addWrong(currentWordObj);
    }

    // 播放大炮动画
    _playCannonAnimation();
  }

  // 播放大炮动画
  void _playCannonAnimation() {
    setState(() {
      _cannonRising = true;
    });

    // 大炮升起（更慢更有气势）
    _cannonController.forward().then((_) {
      // 延迟后发射炮弹（蓄力感）
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _projectileFlying = true;
        });
        // 炮弹飞行（更慢，抛物线感）
        _projectileController.forward().then((_) {
          // 炮弹到达，显示结果
          setState(() {
            _showResult = true;
            _monsterHit = _isCorrect;
            _projectileMissed = !_isCorrect;
            if (_isCorrect) {
              _score += 15;
              _currentTaunt = _surrenderLines[
                  Random().nextInt(_surrenderLines.length)];
              _shakeController.forward();
              _explosionController.forward();
              SystemSound.play(SystemSoundType.click);
              HapticFeedback.mediumImpact();
            } else {
              _currentTaunt =
                  _moreTaunts[Random().nextInt(_moreTaunts.length)];
              SystemSound.play(SystemSoundType.alert);
              HapticFeedback.heavyImpact();
            }
          });
        });
      });
    });
  }

  // 下一题
  void _nextQuestion() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _words.length;
      _generateQuestion();
    });
  }

  // 重玩本题
  void _retryQuestion() {
    setState(() {
      _generateQuestion();
    });
  }

  @override
  void dispose() {
    _monsterController.dispose();
    _cannonController.dispose();
    _projectileController.dispose();
    _shakeController.dispose();
    _explosionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _words.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('💥 大炮填单词'),
        backgroundColor: const Color(0xFF6C63FF),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.yellow, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 怪物区域
              _buildMonsterArea(),
              const SizedBox(height: 10),
              // 单词和大炮区域
              _buildWordArea(),
              const SizedBox(height: 20),
              // 中文释义
              Text(
                _currentMeaning,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              // 字母选项
              _buildLetterOptions(),
              const SizedBox(height: 20),
              // 确定按钮（填完所有空格后显示）
              if (_allFilled && !_showResult)
                ElevatedButton.icon(
                  onPressed: _onConfirm,
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                  label: const Text('确定开炮！',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[500],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              // 下一题按钮
              if (_showResult)
                ElevatedButton.icon(
                  onPressed: _nextQuestion,
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: const Text('下一个',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 怪物区域
  Widget _buildMonsterArea() {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 怪物和炮弹
          Positioned(
            bottom: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 怪物
                AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final shake = _monsterHit
                        ? sin(_shakeController.value * pi * 10) * 10
                        : 0.0;
                    return Transform.translate(
                      offset: Offset(shake, 0),
                      child: AnimatedBuilder(
                        animation: _monsterController,
                        builder: (context, child) {
                          final scale = 1.0 + _monsterController.value * 0.05;
                          return Transform.scale(
                            scale: scale,
                            child: _buildMonster(),
                          );
                        },
                      ),
                    );
                  },
                ),
                // 炮弹
                if (_projectileFlying)
                  AnimatedBuilder(
                    animation: _projectileController,
                    builder: (context, child) {
                      final progress = _projectileController.value;
                      // 抛物线轨迹：先上升，到达顶点后稍微下降
                      final parabola = sin(progress * pi);
                      final bottom = progress * 100 + parabola * 20;
                      
                      // 打偏时炮弹横向偏移
                      final missOffset = _projectileMissed
                          ? (progress - 0.5) * 150
                          : 0.0;
                      
                      // 炮弹大小（接近目标时变大）
                      final size = 16 + progress * 12;
                      
                      return Positioned(
                        bottom: bottom,
                        left: null,
                        right: null,
                        child: Transform.translate(
                          offset: Offset(missOffset, 0),
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.yellow,
                                  Colors.orange,
                                  Colors.red,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.8),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            // 炮弹尾焰
                            child: progress < 0.8
                                ? Transform.translate(
                                    offset: const Offset(0, 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.orange.withOpacity(0.8),
                                            Colors.red.withOpacity(0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                // 爆炸效果（击中时）
                if (_monsterHit && _showResult)
                  AnimatedBuilder(
                    animation: _explosionController,
                    builder: (context, child) {
                      final size = 60 + _explosionController.value * 80;
                      final opacity = 1.0 - _explosionController.value;
                      return Positioned(
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white,
                                  Colors.yellow,
                                  Colors.orange,
                                  Colors.red.withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.3, 0.6, 1.0],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          // 对话气泡（在怪物正上方）
          Positioned(
            top: 0,
            child: _buildSpeechBubble(_currentTaunt),
          ),
        ],
      ),
    );
  }

  // 怪物形象
  Widget _buildMonster() {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 怪物身体
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _monsterHit ? Colors.green[400] : Colors.purple[400],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _monsterHit
                      ? Colors.green.withOpacity(0.5)
                      : Colors.purple.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          // 眼睛（正常时：红眼睛；被击中时：X形）
          if (!_monsterHit) ...[
            // 左眼
            Positioned(
              top: 28,
              left: 22,
              child: Container(
                width: 22,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            // 右眼
            Positioned(
              top: 28,
              right: 22,
              child: Container(
                width: 22,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            // 被击中时：X形眼睛
            Positioned(
              top: 30,
              left: 22,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CustomPaint(
                  painter: XEyePainter(color: Colors.black),
                ),
              ),
            ),
            Positioned(
              top: 30,
              right: 22,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CustomPaint(
                  painter: XEyePainter(color: Colors.black),
                ),
              ),
            ),
          ],
          // 眉毛（嚣张时：倒八字）
          if (!_monsterHit) ...[
            Positioned(
              top: 18,
              left: 18,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  width: 20,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.purple[800],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 18,
              right: 18,
              child: Transform.rotate(
                angle: -0.3,
                child: Container(
                  width: 20,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.purple[800],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
          // 嘴巴
          Positioned(
            bottom: 22,
            left: 28,
            right: 28,
            child: Container(
              height: _monsterHit ? 18 : 24,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(_monsterHit ? 5 : 20),
                  bottomRight: Radius.circular(_monsterHit ? 5 : 20),
                  topLeft: Radius.circular(_monsterHit ? 20 : 8),
                  topRight: Radius.circular(_monsterHit ? 20 : 8),
                ),
              ),
              child: _monsterHit
                  ? const Center(
                      child: Text(
                        '😵',
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  : Center(
                      child: Container(
                        width: 20,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
            ),
          ),
          // 角
          Positioned(
            top: -2,
            left: 22,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: 10,
                height: 24,
                decoration: BoxDecoration(
                  color: _monsterHit ? Colors.green[700] : Colors.purple[700],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          Positioned(
            top: -2,
            right: 22,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 10,
                height: 24,
                decoration: BoxDecoration(
                  color: _monsterHit ? Colors.green[700] : Colors.purple[700],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          // 投降白旗
          if (_monsterHit)
            Positioned(
              top: -25,
              right: -5,
              child: Column(
                children: [
                  Container(
                    width: 35,
                    height: 25,
                    color: Colors.white,
                    child: const Center(
                      child: Text(
                        '投降',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 3,
                    height: 15,
                    color: Colors.brown,
                  ),
                ],
              ),
            ),
          // 打偏时的得意表情（汗滴）
          if (_projectileMissed && _showResult)
            Positioned(
              top: 20,
              right: 10,
              child: Container(
                width: 12,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 对话气泡
  Widget _buildSpeechBubble(String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // 气泡尾巴
        Container(
          width: 0,
          height: 0,
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.transparent, width: 8),
              right: BorderSide(color: Colors.transparent, width: 8),
              top: BorderSide(color: Colors.white, width: 10),
            ),
          ),
        ),
      ],
    );
  }

  // 单词和大炮区域
  Widget _buildWordArea() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_currentWord.length, (index) {
              final isBlank = _blankIndices.contains(index);
              final blankIndex = _blankIndices.indexOf(index);
              final userAnswer = isBlank && blankIndex < _userAnswers.length
                  ? _userAnswers[blankIndex]
                  : null;
              final isCurrentBlank = isBlank && blankIndex == _currentBlankIndex && !_showResult;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  width: 50,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // 字母/空格
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 40,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isBlank
                                ? (userAnswer != null
                                    ? (_showResult
                                        ? (_isCorrect ? Colors.green[100] : Colors.red[100])
                                        : Colors.white)
                                    : Colors.white.withOpacity(0.3))
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrentBlank ? Colors.yellow : Colors.white.withOpacity(0.5),
                              width: isCurrentBlank ? 3 : 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isBlank ? (userAnswer ?? '') : _currentWord[index],
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isBlank
                                    ? (userAnswer != null
                                        ? (_showResult
                                            ? (_isCorrect ? Colors.green : Colors.red)
                                            : Colors.deepPurple)
                                        : Colors.transparent)
                                    : Colors.deepPurple[900],
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              );
            }),
          ),
          // 大炮（在单词正中间，从底部往上升）
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _cannonController,
                builder: (context, child) {
                  final riseHeight = _cannonController.value * 55;
                  return SizedBox(
                    height: 60,
                    width: 50,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 炮管
                          Container(
                            width: 36,
                            height: riseHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.grey[800]!, Colors.grey[600]!],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                              border: Border.all(color: Colors.grey[900]!, width: 2),
                            ),
                            child: _cannonController.value > 0.7
                                ? Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      width: 28,
                                      height: 10,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          // 炮座
                          if (_cannonController.value > 0.3)
                            Container(
                              width: 50,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey[900]!, width: 2),
                              ),
                            ),
                          // 轮子
                          if (_cannonController.value > 0.5)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey[900]!, width: 2),
                                  ),
                                ),
                                const SizedBox(width: 22),
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey[900]!, width: 2),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 字母选项
  Widget _buildLetterOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: List.generate(_letterOptions.length, (index) {
          final letter = _letterOptions[index];
          final isUsed = _usedLetterIndices.contains(index);
          return SizedBox(
            width: 50,
            height: 50,
            child: ElevatedButton(
              onPressed: _showResult || isUsed ? null : () => _onLetterSelected(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: isUsed ? Colors.grey[300] : Colors.white,
                foregroundColor: isUsed ? Colors.grey : Colors.deepPurple,
                elevation: 2,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                letter.toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// X形眼睛绘制器
class XEyePainter extends CustomPainter {
  final Color color;

  XEyePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // 画 X
    canvas.drawLine(
      Offset(2, 2),
      Offset(size.width - 2, size.height - 2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 2, 2),
      Offset(2, size.height - 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 游戏页面
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  List<Word> _words = [];
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  bool _isLoading = true;
  bool _showResult = false;
  bool _correctAnswer = false;
  List<String> _options = [];
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _loadWords();
    _setupAnimations();
  }

  // 加载词库
  Future<void> _loadWords() async {
    try {
      final String response = await rootBundle.loadString('assets/words.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _words = data.map((item) => Word.fromJson(item)).toList();
        _isLoading = false;
        _generateOptions();
      });
    } catch (e) {
      // 加载失败时使用内置 fallback 词库，保证能正常运行
      setState(() {
        _words = _getFallbackWords();
        _isLoading = false;
        _generateOptions();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('使用内置词库（外部加载失败: ${e.toString().substring(0, 30)}...）')),
        );
      }
    }
  }

  // 内置 fallback 词库
  List<Word> _getFallbackWords() {
    return [
      Word(word: 'apple', meaning: 'n. 苹果'),
      Word(word: 'book', meaning: 'n. 书，书籍'),
      Word(word: 'cat', meaning: 'n. 猫'),
      Word(word: 'dog', meaning: 'n. 狗'),
      Word(word: 'elephant', meaning: 'n. 大象'),
      Word(word: 'flower', meaning: 'n. 花'),
      Word(word: 'garden', meaning: 'n. 花园'),
      Word(word: 'happy', meaning: 'adj. 快乐的'),
    ];
  }

  // 设置动画控制器
  void _setupAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 1.0, // 初始值为1，保证卡片可见，回答问题时再播放弹跳动画
    );
    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );
  }

  // 生成四个选项（一个正确 + 三个错误）
  void _generateOptions() {
    if (_words.length < 4) return;

    final currentWord = _words[_currentIndex];
    final correctMeaning = currentWord.meaning;

    // 从词库中随机选择3个错误的释义
    List<Word> wrongWords = List.from(_words)..remove(currentWord);
    wrongWords.shuffle();
    final threeWrong = wrongWords.take(3).toList();

    // 组合四个选项并打乱顺序
    _options = [correctMeaning, ...threeWrong.map((w) => w.meaning)].toList()
      ..shuffle();
  }

  // 处理用户选择
  void _onAnswerSelected(String selectedMeaning) {
    if (_showResult) return;

    final currentWord = _words[_currentIndex];
    final isCorrect = selectedMeaning == currentWord.meaning;

    setState(() {
      _showResult = true;
      _correctAnswer = isCorrect;

      if (isCorrect) {
        _score += 10 + (_streak * 5); // 基础分+连击加成
        _streak++;
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.lightImpact();
        // 更新学习统计
        LearningStats().addCorrect(10 + ((_streak - 1) * 5), _streak);
      } else {
        _streak = 0;
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.heavyImpact();
        // 更新学习统计
        LearningStats().addWrong(currentWord);
      }

      _bounceController.forward(from: 0.0);
    });
  }

  // 生成彩带粒子（答对效果）
  List<Widget> _buildConfetti() {
    final random = Random();
    final colors = [
      Colors.red, Colors.blue, Colors.green, Colors.yellow,
      Colors.purple, Colors.orange, Colors.pink, Colors.cyan
    ];
    return List.generate(30, (index) {
      final left = random.nextDouble() * 400;
      final top = random.nextDouble() * 300;
      final size = 6 + random.nextDouble() * 8;
      final color = colors[random.nextInt(colors.length)];
      return Positioned(
        left: left,
        top: top,
        child: Container(
          width: size,
          height: size * 1.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    });
  }

  // 下一个问题
  void _nextQuestion() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _words.length;
      _showResult = false;
      _correctAnswer = false;
      _generateOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _words.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentWord = _words[_currentIndex];
    final progress = _words.length > 0 ? (_currentIndex + 1) / _words.length : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 牛津词汇挑战'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SplashScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _score = 0;
                _currentIndex = 0;
                _streak = 0;
                _showResult = false;
                _correctAnswer = false;
                _generateOptions();
              });
            },
            child: const Text(
              '重新开始',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 分数和连击显示
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '得分',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '$_score',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),

                // 连击显示
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _streak >= 3 ? Colors.orange[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _streak >= 3 ? Colors.orange[200]! : Colors.green[200]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '连击',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${_streak}x',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _streak >= 3 ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 进度条
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.blueAccent],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 单词卡片（带动画效果）
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: _bounceAnimation,
                    child: Card(
                      color: _showResult
                          ? (_correctAnswer ? Colors.green[50] : Colors.red[50])
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: _showResult
                              ? (_correctAnswer
                                  ? Colors.green[400]!
                                  : Colors.red[400]!)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 结果图标（答对/答错）
                            if (_showResult)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: _correctAnswer
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _correctAnswer
                                      ? Icons.emoji_events_rounded
                                      : Icons.new_releases_rounded,
                                  size: 48,
                                  color: _correctAnswer
                                      ? Colors.green[600]
                                      : Colors.red[600],
                                ),
                              ),
                            if (!_showResult)
                              Icon(
                                Icons.school_rounded,
                                size: 64,
                                color: Colors.deepPurple[300],
                              ),
                            const SizedBox(height: 24),

                            // 单词显示
                            Text(
                              currentWord.word,
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: _showResult
                                    ? (_correctAnswer
                                        ? Colors.green[800]
                                        : Colors.red[800])
                                    : Colors.deepPurple[900],
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 提示文本/结果文本
                            Text(
                              _showResult
                                  ? (_correctAnswer ? '🎉 太棒了！答对了！' : '💥 哎呀，答错了！')
                                  : '请选择正确的释义',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: _showResult ? FontWeight.bold : FontWeight.normal,
                                color: _showResult
                                    ? (_correctAnswer
                                        ? Colors.green[700]
                                        : Colors.red[700])
                                    : Colors.grey[600],
                              ),
                            ),
                            if (_showResult && !_correctAnswer)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '正确答案：${currentWord.meaning}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 答对时的彩带效果
                  if (_showResult && _correctAnswer)
                    IgnorePointer(
                      child: Stack(
                        children: _buildConfetti(),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 四个选项按钮
            Column(
              children: List.generate(_options.length, (index) {
                final option = _options[index];
                final isCorrect = option == currentWord.meaning;
                bool isSelected = false;
                final letter = String.fromCharCode(65 + index); // A/B/C/D

                if (_showResult) {
                  if (isCorrect) {
                    isSelected = true; // 显示正确答案
                  } else if (!_correctAnswer && !_correctAnswer) {
                    isSelected = true; // 错误时高亮用户选中的答案
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: _showResult ? null : () => _onAnswerSelected(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _showResult
                            ? (isCorrect
                                ? Colors.green[500]
                                : isSelected
                                    ? Colors.red[400]
                                    : Colors.grey[200])
                            : Colors.white,
                        foregroundColor: _showResult
                            ? Colors.white
                            : Colors.black87,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: _showResult
                                ? (isCorrect
                                    ? Colors.green[700]!
                                    : isSelected
                                        ? Colors.red[700]!
                                        : Colors.grey[300]!)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // 序号圆圈
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _showResult
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.deepPurple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _showResult
                                      ? Colors.white
                                      : Colors.deepPurple,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // 选项文字
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 18,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // 下一步按钮（回答后出现）
            if (_showResult)
              ElevatedButton.icon(
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text('下一个', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }
}
