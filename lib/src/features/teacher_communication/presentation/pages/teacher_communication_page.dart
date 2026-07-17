import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../school_event/domain/entities/school_event.dart';
import '../../domain/entities/teacher_communication.dart';
import '../controllers/teacher_communication_controller.dart';

class TeacherCommunicationPage extends StatefulWidget {
  const TeacherCommunicationPage({required this.controller, super.key});

  final TeacherCommunicationController controller;

  @override
  State<TeacherCommunicationPage> createState() =>
      _TeacherCommunicationPageState();
}

class _TeacherCommunicationPageState extends State<TeacherCommunicationPage> {
  final _notificationFormKey = GlobalKey<FormState>();
  final _eventFormKey = GlobalKey<FormState>();
  final _notificationTitleController = TextEditingController();
  final _notificationContentController = TextEditingController();
  final _eventTitleController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventLocationController = TextEditingController();

  ClassNotificationAudience _audience =
      ClassNotificationAudience.parentAndStudent;
  SchoolEventParticipationType _participationType =
      SchoolEventParticipationType.required;
  late DateTime _eventDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isAllDay = false;
  String? _localEventError;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _eventDate = DateTime(today.year, today.month, today.day);
    widget.controller.addListener(_handleControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.loadInitial();
      }
    });
  }

  @override
  void didUpdateWidget(covariant TeacherCommunicationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.loadInitial();
      }
    });
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _notificationTitleController.dispose();
    _notificationContentController.dispose();
    _eventTitleController.dispose();
    _eventDescriptionController.dispose();
    _eventLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        surfaceTintColor: AppTheme.primaryColor,
        elevation: 1,
        toolbarHeight: 66,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Quay lại',
          iconSize: 28,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Gửi thông báo',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildContent(widget.controller),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TeacherCommunicationController controller) {
    if ((controller.status == TeacherCommunicationPageStatus.idle ||
            controller.status == TeacherCommunicationPageStatus.loading) &&
        controller.classes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }
    if (controller.status == TeacherCommunicationPageStatus.error &&
        controller.classes.isEmpty) {
      return _ErrorState(
        message: controller.errorMessage ?? 'Không thể tải lớp chủ nhiệm.',
        onRetry: controller.retry,
      );
    }
    if (controller.hasNoClasses || controller.selectedClass == null) {
      return const _NoActiveHomeroomClass();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: _ClassSelector(
            classes: controller.classes,
            selectedClass: controller.selectedClass!,
            onSelected: controller.selectClass,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _TabSelector(
            selectedTab: controller.selectedTab,
            onSelected: controller.selectTab,
          ),
        ),
        if (controller.successMessage != null ||
            controller.actionErrorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _FeedbackBanner(
              message:
                  controller.successMessage ?? controller.actionErrorMessage!,
              isSuccess: controller.successMessage != null,
              onClose: controller.clearFeedback,
            ),
          ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child:
                controller.selectedTab == TeacherCommunicationTab.notification
                ? _buildNotificationForm(controller)
                : _buildEventForm(controller),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationForm(TeacherCommunicationController controller) {
    return SingleChildScrollView(
      key: const ValueKey('notification-form-scroll'),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
      child: Form(
        key: _notificationFormKey,
        child: _FormCard(
          title: 'Thông báo lớp',
          subtitle: 'Gửi nội dung trực tiếp đến phụ huynh hoặc học sinh.',
          icon: Icons.campaign_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const ValueKey('notification-title-field'),
                controller: _notificationTitleController,
                maxLength: 255,
                textCapitalization: TextCapitalization.sentences,
                decoration: _fieldDecoration(
                  label: 'Tiêu đề',
                  hint: 'Ví dụ: Nhắc lịch kiểm tra',
                ),
                validator: _requiredValidator('Vui lòng nhập tiêu đề'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('notification-content-field'),
                controller: _notificationContentController,
                minLines: 5,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: _fieldDecoration(
                  label: 'Nội dung',
                  hint: 'Nhập nội dung cần gửi',
                  alignLabelWithHint: true,
                ),
                validator: _requiredValidator('Vui lòng nhập nội dung'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ClassNotificationAudience>(
                key: const ValueKey('notification-audience-field'),
                initialValue: _audience,
                isExpanded: true,
                decoration: _fieldDecoration(label: 'Người nhận'),
                items: ClassNotificationAudience.values
                    .map(
                      (audience) => DropdownMenuItem(
                        value: audience,
                        child: Text(_audienceLabel(audience)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: controller.isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _audience = value);
                        }
                      },
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  key: const ValueKey('send-class-notification-button'),
                  onPressed: controller.isSubmitting ? null : _sendNotification,
                  style: _primaryButtonStyle(),
                  icon: controller.isSubmitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    controller.isSubmitting ? 'Đang gửi...' : 'Gửi thông báo',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventForm(TeacherCommunicationController controller) {
    return SingleChildScrollView(
      key: const ValueKey('event-form-scroll'),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
      child: Form(
        key: _eventFormKey,
        child: _FormCard(
          title: 'Sự kiện lớp',
          subtitle: 'Lưu bản nháp hoặc phát hành đến phụ huynh và học sinh.',
          icon: Icons.event_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const ValueKey('event-title-field'),
                controller: _eventTitleController,
                maxLength: 255,
                textCapitalization: TextCapitalization.sentences,
                decoration: _fieldDecoration(
                  label: 'Tên sự kiện',
                  hint: 'Ví dụ: Họp phụ huynh đầu năm',
                ),
                validator: _requiredValidator('Vui lòng nhập tên sự kiện'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('event-description-field'),
                controller: _eventDescriptionController,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: _fieldDecoration(
                  label: 'Mô tả (không bắt buộc)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              _PickerField(
                key: const ValueKey('event-date-field'),
                label: 'Ngày diễn ra',
                value: _formatDate(_eventDate),
                icon: Icons.calendar_month_rounded,
                onTap: controller.isSubmitting ? null : _selectEventDate,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: _outlinedDecoration(),
                child: SwitchListTile.adaptive(
                  key: const ValueKey('event-all-day-switch'),
                  title: const Text(
                    'Sự kiện cả ngày',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  value: _isAllDay,
                  activeTrackColor: AppTheme.primaryColor,
                  onChanged: controller.isSubmitting
                      ? null
                      : (value) => setState(() {
                          _isAllDay = value;
                          _localEventError = null;
                        }),
                ),
              ),
              if (!_isAllDay) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _PickerField(
                        key: const ValueKey('event-start-time-field'),
                        label: 'Bắt đầu',
                        value: _startTime.format(context),
                        icon: Icons.schedule_rounded,
                        onTap: controller.isSubmitting
                            ? null
                            : () => _selectTime(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PickerField(
                        key: const ValueKey('event-end-time-field'),
                        label: 'Kết thúc',
                        value: _endTime.format(context),
                        icon: Icons.schedule_rounded,
                        onTap: controller.isSubmitting
                            ? null
                            : () => _selectTime(isStart: false),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('event-location-field'),
                controller: _eventLocationController,
                maxLength: 255,
                decoration: _fieldDecoration(
                  label: 'Địa điểm (không bắt buộc)',
                  hint: 'Ví dụ: Phòng A101',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SchoolEventParticipationType>(
                key: const ValueKey('event-participation-field'),
                initialValue: _participationType,
                isExpanded: true,
                decoration: _fieldDecoration(label: 'Hình thức tham gia'),
                items: SchoolEventParticipationType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type == SchoolEventParticipationType.required
                              ? 'Bắt buộc'
                              : 'Tự nguyện',
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: controller.isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _participationType = value);
                        }
                      },
              ),
              if (_localEventError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _localEventError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final buttons = <Widget>[
                    SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        key: const ValueKey('save-draft-event-button'),
                        onPressed: controller.isSubmitting
                            ? null
                            : () => _submitEvent(publishNow: false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.save_outlined),
                        label: const Text(
                          'Lưu nháp',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        key: const ValueKey('publish-class-event-button'),
                        onPressed: controller.isSubmitting
                            ? null
                            : () => _submitEvent(publishNow: true),
                        style: _primaryButtonStyle(),
                        icon: const Icon(Icons.publish_rounded),
                        label: const Text(
                          'Phát hành',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ];
                  if (constraints.maxWidth < 350) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buttons.first,
                        const SizedBox(height: 10),
                        buttons.last,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: buttons.first),
                      const SizedBox(width: 10),
                      Expanded(child: buttons.last),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendNotification() async {
    if (!_notificationFormKey.currentState!.validate()) {
      return;
    }
    final success = await widget.controller.sendClassNotification(
      title: _notificationTitleController.text,
      content: _notificationContentController.text,
      audience: _audience,
    );
    if (success && mounted) {
      _notificationTitleController.clear();
      _notificationContentController.clear();
    }
  }

  Future<void> _submitEvent({required bool publishNow}) async {
    if (!_eventFormKey.currentState!.validate()) {
      return;
    }
    if (!_isAllDay && _timeInMinutes(_endTime) <= _timeInMinutes(_startTime)) {
      setState(() => _localEventError = 'Giờ kết thúc phải sau giờ bắt đầu.');
      return;
    }
    setState(() => _localEventError = null);

    await widget.controller.createClassEvent(
      CreateTeacherClassEvent(
        title: _eventTitleController.text.trim(),
        description: _normalizedText(_eventDescriptionController.text),
        eventDate: _eventDate,
        isAllDay: _isAllDay,
        startTime: _isAllDay ? null : _asDuration(_startTime),
        endTime: _isAllDay ? null : _asDuration(_endTime),
        location: _normalizedText(_eventLocationController.text),
        participationType: _participationType,
        publishNow: publishNow,
      ),
    );
  }

  Future<void> _selectEventDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Chọn ngày diễn ra sự kiện',
    );
    if (selected != null && mounted) {
      setState(() => _eventDate = selected);
    }
  }

  Future<void> _selectTime({required bool isStart}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      helpText: isStart ? 'Chọn giờ bắt đầu' : 'Chọn giờ kết thúc',
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      if (isStart) {
        _startTime = selected;
      } else {
        _endTime = selected;
      }
      _localEventError = null;
    });
  }
}

class _ClassSelector extends StatelessWidget {
  const _ClassSelector({
    required this.classes,
    required this.selectedClass,
    required this.onSelected,
  });

  final List<ActiveHomeroomClass> classes;
  final ActiveHomeroomClass selectedClass;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 23,
            backgroundColor: Color(0xFFFFEEE5),
            foregroundColor: AppTheme.primaryColor,
            child: Icon(Icons.groups_2_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lớp nhận thông tin',
                  style: TextStyle(color: Color(0xFF6A6A6A), fontSize: 12),
                ),
                const SizedBox(height: 3),
                if (classes.length == 1)
                  Text(
                    '${selectedClass.className} • ${selectedClass.academicYearName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                else
                  DropdownButton<int>(
                    key: const ValueKey('communication-class-selector'),
                    value: selectedClass.classId,
                    isExpanded: true,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    onChanged: (value) {
                      if (value != null) {
                        onSelected(value);
                      }
                    },
                    items: classes
                        .map(
                          (schoolClass) => DropdownMenuItem<int>(
                            value: schoolClass.classId,
                            child: Text(
                              '${schoolClass.className} • ${schoolClass.academicYearName}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.selectedTab, required this.onSelected});

  final TeacherCommunicationTab selectedTab;
  final ValueChanged<TeacherCommunicationTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            key: const ValueKey('communication-notification-tab'),
            label: 'Thông báo',
            icon: Icons.campaign_outlined,
            selected: selectedTab == TeacherCommunicationTab.notification,
            onTap: () => onSelected(TeacherCommunicationTab.notification),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TabButton(
            key: const ValueKey('communication-event-tab'),
            label: 'Sự kiện',
            icon: Icons.event_outlined,
            selected: selectedTab == TeacherCommunicationTab.event,
            onTap: () => onSelected(TeacherCommunicationTab.event),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: selected ? Colors.white : AppTheme.primaryColor,
          backgroundColor: selected ? AppTheme.primaryColor : Colors.white,
          side: const BorderSide(color: AppTheme.primaryColor),
          shape: const StadiumBorder(),
        ),
        icon: Icon(icon, size: 19),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFFFEEE5),
                foregroundColor: AppTheme.primaryColor,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _fieldDecoration(
          label: label,
          suffixIcon: Icon(icon, color: AppTheme.primaryColor),
        ),
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    required this.message,
    required this.isSuccess,
    required this.onClose,
  });

  final String message;
  final bool isSuccess;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? const Color(0xFF128C62) : const Color(0xFFC8452D);
    return Container(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: color,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: color,
            tooltip: 'Đóng',
          ),
        ],
      ),
    );
  }
}

class _NoActiveHomeroomClass extends StatelessWidget {
  const _NoActiveHomeroomClass();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_2_outlined, size: 72, color: Color(0xFFAAAAAA)),
            SizedBox(height: 16),
            Text(
              TeacherCommunicationController.noClassMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Color(0xFF999999),
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  required String label,
  String? hint,
  bool alignLabelWithHint = false,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    alignLabelWithHint: alignLabelWithHint,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
    ),
  );
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFE2E2E2)),
  );
}

BoxDecoration _outlinedDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFF777777)),
  );
}

ButtonStyle _primaryButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}

FormFieldValidator<String> _requiredValidator(String message) {
  return (value) => value == null || value.trim().isEmpty ? message : null;
}

String _audienceLabel(ClassNotificationAudience audience) {
  return switch (audience) {
    ClassNotificationAudience.parentOnly => 'Chỉ phụ huynh',
    ClassNotificationAudience.studentOnly => 'Chỉ học sinh',
    ClassNotificationAudience.parentAndStudent => 'Phụ huynh và học sinh',
  };
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

int _timeInMinutes(TimeOfDay value) => value.hour * 60 + value.minute;

Duration _asDuration(TimeOfDay value) {
  return Duration(hours: value.hour, minutes: value.minute);
}

String? _normalizedText(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
