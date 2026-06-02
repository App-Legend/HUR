//  ————————————————————————————————
//  |          프로필 설정           |
//  ————————————————————————————————

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  String _nickname = '';
  String _bio = '';
  String? _aestheticTag;
  String? _profileImageUrl;
  String? _backgroundImageUrl;

  static const _aestheticOptions = ['청순', '섹시', '차분', '시크', '큐티'];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final token = prefs.getString('auth_token');
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        setState(() {
          _user = data;
          _nickname = data['nickname'] ?? '';
          _bio = data['bio'] ?? '';
          _aestheticTag = data['aesthetic_tag'];
          _profileImageUrl = data['profile_image'];
          _backgroundImageUrl = data['background_image'];
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final token = prefs.getString('auth_token');
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nickname': _nickname,
          'bio': _bio,
          'aesthetic_tag': _aestheticTag,
          'profile_image': _profileImageUrl,
          'background_image': _backgroundImageUrl,
        }),
      );
      final data = jsonDecode(response.body);
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 저장됐어요')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? '저장 실패')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 연결 실패')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<String?> _uploadImage(XFile file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/upload'),
    );

    request.files.add(await http.MultipartFile.fromPath('image', file.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      return jsonDecode(body)['url'] as String;
    }
    return null;
  }

  Future<void> _pickProfileImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    final url = await _uploadImage(file);
    if (url != null && mounted) setState(() => _profileImageUrl = url);
  }

  Future<void> _pickBackgroundImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    final url = await _uploadImage(file);
    if (url != null && mounted) setState(() => _backgroundImageUrl = url);
  }

  void _selectTag() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('추구미 태그 선택'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _aestheticOptions.map((tag) {
            final selected = _aestheticTag == tag;
            return GestureDetector(
              onTap: () {
                setState(() => _aestheticTag = tag);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF6B1F8A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? const Color(0xFF6B1F8A) : Colors.black26,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
        ],
      ),
    );
  }

  void _editField(String label, String current, void Function(String) onSaved) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: label),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              onSaved(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('확인', style: TextStyle(color: Color(0xFF6B1F8A))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '프로필 편집',
          style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text(
                    '변경',
                    style: TextStyle(color: Color(0xFF6B1F8A), fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  _ProfileImageSection(
                    profileImageUrl: _profileImageUrl,
                    backgroundImageUrl: _backgroundImageUrl,
                    onPickProfile: _pickProfileImage,
                    onPickBackground: _pickBackgroundImage,
                  ),
                  const SizedBox(height: 54),
                  _EditCard(
                    items: [
                      _EditRow(
                        label: '이름',
                        value: _user?['name'] ?? '',
                        editable: false,
                      ),
                      _EditRow(
                        label: '닉네임',
                        value: _nickname,
                        onTap: () => _editField('닉네임', _nickname, (v) => setState(() => _nickname = v)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _EditCard(
                    items: [
                      _EditRow(
                        label: '소개',
                        value: _bio.isEmpty ? '소개를 입력해주세요' : _bio,
                        onTap: () => _editField('소개', _bio, (v) => setState(() => _bio = v)),
                      ),
                      _EditRow(
                        label: '태그',
                        value: _aestheticTag ?? '선택 안 됨',
                        onTap: _selectTag,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _EditCard(
                    items: [
                      _EditRow(label: '성별', value: _user?['gender'] ?? '', editable: false),
                      _EditRow(
                        label: '생일',
                        value: _user?['birth_date']?.toString().substring(0, 10) ?? '',
                        editable: false,
                      ),
                      _EditRow(label: '퍼스널컬러', value: '가을 웜톤', editable: false),
                      _EditRow(label: '피부톤', value: '21호', editable: false),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileImageSection extends StatelessWidget {
  final String? profileImageUrl;
  final String? backgroundImageUrl;
  final VoidCallback onPickProfile;
  final VoidCallback onPickBackground;

  const _ProfileImageSection({
    required this.profileImageUrl,
    required this.backgroundImageUrl,
    required this.onPickProfile,
    required this.onPickBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 배경 이미지
        GestureDetector(
          onTap: onPickBackground,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFB0B0B0),
              borderRadius: BorderRadius.circular(14),
              image: backgroundImageUrl != null
                  ? DecorationImage(image: NetworkImage(backgroundImageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: backgroundImageUrl == null
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: Colors.white70, size: 28),
                        SizedBox(height: 4),
                        Text('배경 사진 추가', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  )
                : Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
          ),
        ),
        // 프로필 이미지
        Positioned(
          bottom: -36,
          left: 20,
          child: GestureDetector(
            onTap: onPickProfile,
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9E9E9E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    image: profileImageUrl != null
                        ? DecorationImage(image: NetworkImage(profileImageUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 36)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EditCard extends StatelessWidget {
  final List<Widget> items;
  const _EditCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              items[i],
              if (i < items.length - 1)
                const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20, color: Color(0xFFF0F0F0)),
            ],
          );
        }),
      ),
    );
  }
}

class _EditRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool editable;

  const _EditRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.trailing,
    this.onTap,
    this.editable = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: editable ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 15)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: trailing != null
                  ? Align(alignment: Alignment.centerLeft, child: trailing)
                  : valueWidget ??
                      Text(
                        value ?? '',
                        style: TextStyle(
                          color: editable ? Colors.black87 : Colors.black45,
                          fontSize: 15,
                          fontWeight: editable ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
            ),
            if (editable)
              const Icon(Icons.chevron_right, color: Colors.black26, size: 20),
          ],
        ),
      ),
    );
  }
}
