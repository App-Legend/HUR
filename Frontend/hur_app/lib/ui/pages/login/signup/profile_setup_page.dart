import 'package:flutter/material.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  final _tagController = TextEditingController();

  String? _selectedGender;
  String? _selectedSeason;
  DateTime? _birthDate;
  final List<String> _tags = [];

  static const _purple = Color(0xFF6B1F8A);
  static const _lightGray = Color(0xFFF0F0F0);

  final _seasons = ['가을 웜톤', '봄 웜톤', '여름 쿨톤', '겨울 쿨톤'];

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && !_tags.contains(trimmed)) {
      setState(() => _tags.add(trimmed));
    }
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _complete() {
    // TODO: 프로필 저장 로직 연결
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildTopBar(context),
                    const SizedBox(height: 20),
                    const Text(
                      '프로필 작성',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildPhotoSection(),
                    const SizedBox(height: 24),
                    _buildFieldLabel('닉네임'),
                    const SizedBox(height: 8),
                    _buildNicknameField(),
                    const SizedBox(height: 20),
                    _buildGenderAndBirthRow(),
                    const SizedBox(height: 20),
                    _buildFieldLabel('퍼스널 컬러'),
                    const SizedBox(height: 10),
                    _buildSeasonSelector(),
                    const SizedBox(height: 20),
                    _buildFieldLabel('자기소개'),
                    const SizedBox(height: 8),
                    _buildBioField(),
                    const SizedBox(height: 20),
                    _buildFieldLabel('태그'),
                    const SizedBox(height: 8),
                    _buildTagField(),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildTagChips(),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildCompleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/icons/app_icon.png',
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE8D5F5),
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            size: 30,
            color: _purple,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '프로필 사진',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '내 분위기가 잘 드러나는 사진으로 골라주세요',
              style: TextStyle(fontSize: 11, color: Colors.black45),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '사진 선택',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNicknameField() {
    return TextField(
      controller: _nicknameController,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: '홍길동',
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
        prefixIcon: const Icon(Icons.person_outline, color: Colors.black38, size: 20),
        filled: true,
        fillColor: _lightGray,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _purple, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildGenderAndBirthRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('성별'),
              const SizedBox(height: 8),
              _buildGenderSelector(),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('생년월일'),
              const SizedBox(height: 8),
              _buildBirthField(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    final genders = ['여성', '남성', '기타'];
    return Row(
      children: genders.map((g) {
        final selected = _selectedGender == g;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () => setState(() => _selectedGender = g),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _purple : Colors.black26,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                g,
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? _purple : Colors.black54,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBirthField() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _birthDate ?? DateTime(1999, 1, 1),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: _purple),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _birthDate = picked);
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _lightGray,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 17, color: Colors.black38),
            SizedBox(width: 8),
            Text(
              _birthDate != null
                  ? '${_birthDate!.year}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.day.toString().padLeft(2, '0')}'
                  : '1999.01.01',
              style: TextStyle(
                fontSize: 14,
                color: _birthDate != null ? Colors.black87 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _seasons.map((season) {
        final selected = _selectedSeason == season;
        return GestureDetector(
          onTap: () => setState(() => _selectedSeason = season),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? _purple : Colors.black26,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              season,
              style: TextStyle(
                fontSize: 13,
                color: selected ? _purple : Colors.black54,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBioField() {
    return TextField(
      controller: _bioController,
      maxLines: 5,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: _lightGray,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _purple, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTagField() {
    return TextField(
      controller: _tagController,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      onSubmitted: _addTag,
      decoration: InputDecoration(
        filled: true,
        fillColor: _lightGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _purple, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add, color: Colors.black38, size: 20),
          onPressed: () => _addTag(_tagController.text),
        ),
      ),
    );
  }

  Widget _buildTagChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _lightGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tag,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _removeTag(tag),
                child: const Icon(Icons.close, size: 14, color: Colors.black54),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: Colors.black54),
    );
  }

  Widget _buildCompleteButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _complete,
          style: ElevatedButton.styleFrom(
            backgroundColor: _purple,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            '프로필 완료',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
