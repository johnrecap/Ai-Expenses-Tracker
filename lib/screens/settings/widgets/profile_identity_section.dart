import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/account/account.dart';
import 'package:expenses_tracker/screens/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/screens/settings/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileIdentitySection extends StatelessWidget {
  const ProfileIdentitySection({required this.fallbackAccountId, super.key});

  final String fallbackAccountId;

  @override
  Widget build(BuildContext context) {
    AuthBloc? authBloc;
    try {
      authBloc = context.read<AuthBloc>();
    } catch (_) {
      authBloc = null;
    }
    if (authBloc == null) {
      return _buildContent(context, user: AppUser.empty);
    }

    return BlocBuilder<AuthBloc, AuthState>(
      bloc: authBloc,
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : AppUser.empty;
        final accountId = user.userId.trim().isNotEmpty
            ? user.userId.trim()
            : fallbackAccountId.trim();

        return StreamBuilder<String?>(
          stream: _accountProfileService(context).watchLocalDisplayName(user),
          builder: (context, snapshot) => _buildContent(
            context,
            user: user,
            accountIdOverride: accountId,
            localDisplayName: snapshot.data,
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required AppUser user,
    String? accountIdOverride,
    String? localDisplayName,
  }) {
    final accountId = accountIdOverride ?? fallbackAccountId.trim();
    return SettingsSection(
      title: context.l10n.profile,
      subtitle: context.l10n.profileSettingsDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(context.l10n.accountProfileTitle),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AccountIdentity.displayName(
                    user: user,
                    localDisplayName: localDisplayName,
                    fallbackUserLabel: context.l10n.profileFallbackUser,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (AccountIdentity.secondaryIdentity(
                      user: user,
                      localDisplayName: localDisplayName,
                    ) !=
                    null) ...[
                  const SizedBox(height: 2),
                  Text(
                    AccountIdentity.secondaryIdentity(
                      user: user,
                      localDisplayName: localDisplayName,
                    )!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: user.isEmpty
                ? null
                : () => _openAccountProfile(context, user),
          ),
          const Divider(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.badge_outlined),
            title: Text(context.l10n.accountId),
            subtitle: Text(
              accountId.isEmpty ? context.l10n.profileFallbackUser : accountId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              tooltip: context.l10n.copyAccountId,
              onPressed: accountId.isEmpty
                  ? null
                  : () => _copyAccountId(context, accountId),
              icon: const Icon(Icons.copy_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyAccountId(BuildContext context, String accountId) async {
    await Clipboard.setData(ClipboardData(text: accountId));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.accountIdCopied)));
  }

  AccountProfileService _accountProfileService(BuildContext context) {
    try {
      return context.read<AccountProfileService>();
    } catch (_) {
      return DefaultAccountProfileService.instance;
    }
  }

  void _openAccountProfile(BuildContext context, AppUser user) {
    final profileService = _accountProfileService(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<AccountProfileService>.value(
          value: profileService,
          child: AccountProfileScreen(user: user),
        ),
      ),
    );
  }
}
