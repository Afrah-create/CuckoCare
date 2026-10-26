import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/layout/app_page.dart';
import '../../../app/layout/page_layout.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/progress_button.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/error/result.dart';
import '../../farms/domain/farm_phone.dart';
import '../domain/vet_profile.dart';
import 'vet_gps_capture_card.dart';
import 'vet_inbox_providers.dart';

class VetProfileScreen extends ConsumerWidget {
  const VetProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vetProfileProvider);
    return AppPage(
      title: 'Your profile',
      preset: PageLayout.form,
      frame: false,
      body: AsyncStateView(
        value: async,
        skeleton: const FormSkeleton(),
        onRetry: () => ref.invalidate(vetProfileProvider),
        error: (error, _) => ErrorState(
          failure: FailureMapper.mapObject(error),
          onRetry: () => ref.invalidate(vetProfileProvider),
        ),
        builder: (profile) => _VetProfileForm(profile: profile),
      ),
    );
  }
}

class _VetProfileForm extends ConsumerStatefulWidget {
  const _VetProfileForm({required this.profile});

  final VetProfile profile;

  @override
  ConsumerState<_VetProfileForm> createState() => _VetProfileFormState();
}

class _VetProfileFormState extends ConsumerState<_VetProfileForm> {
  late final TextEditingController _name;
  late final TextEditingController _org;
  late final TextEditingController _district;
  late final TextEditingController _phone;
  late bool _consultation;
  late bool _farmVisit;
  late bool _optedIn;
  late bool _isActive;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = TextEditingController(text: p.displayName ?? '');
    _org = TextEditingController(text: p.organization ?? '');
    _district = TextEditingController(text: p.district ?? '');
    _phone = TextEditingController(text: ugandaPhoneFieldText(p.phone));
    _consultation = p.offersConsultation;
    _farmVisit = p.offersFarmVisit;
    _optedIn = p.optedIn;
    _isActive = p.isActive;
  }

  @override
  void dispose() {
    _name.dispose();
    _org.dispose();
    _district.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<bool> _save() async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    final phoneText = _phone.text.trim();
    String? phone;
    if (phoneText.isNotEmpty) {
      phone = tryNormalizeUgandaPhone(phoneText);
      if (phone == null) {
        AppSnack.error(context, 'Enter a Uganda mobile number.');
        return false;
      }
    }
    final result = await ref.read(vetProfileRepositoryProvider).saveProfile(
          displayName: _name.text.trim(),
          organization: _org.text.trim(),
          district: _district.text.trim(),
          phone: phone,
          offersConsultation: _consultation,
          offersFarmVisit: _farmVisit,
          optedIn: _optedIn,
          isActive: _isActive,
        );
    if (!mounted) {
      return false;
    }
    return switch (result) {
      Success() => () {
          ref.invalidate(vetProfileProvider);
          AppSnack.success(context, 'Profile saved');
          return true;
        }(),
      Error(failure: final f) => () {
          AppSnack.error(context, FailureMapper.map(f).message);
          return false;
        }(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final verified = widget.profile.isVerified;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Material(
            color: verified
                ? context.colors.successContainer
                : context.colors.warningContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                verified
                    ? 'Visible to farmers in Find a Vet (when opted in).'
                    : 'Pending verification. Farmers will not see this profile until an administrator verifies it.',
                style: context.text.bodyMedium?.copyWith(
                  color: verified
                      ? context.colors.onSuccessContainer
                      : context.colors.onWarningContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const VetGpsCaptureCard(),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Display name'),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _org,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Organisation'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _district,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'District'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Mobile number',
              prefixText: '+256 ',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Required so farmers can contact you';
              }
              return tryNormalizeUgandaPhone(v) == null
                  ? 'Enter a Uganda mobile number'
                  : null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Offers consultation'),
            value: _consultation,
            onChanged: (v) => setState(() => _consultation = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Offers farm visits'),
            value: _farmVisit,
            onChanged: (v) => setState(() => _farmVisit = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show me in Find a Vet'),
            subtitle: const Text('Opt in after you are verified'),
            value: _optedIn,
            onChanged: (v) => setState(() => _optedIn = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Available'),
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
          ),
          const SizedBox(height: AppSpacing.lg),
          ProgressButton(
            label: 'Save profile',
            busyLabel: 'Saving…',
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
