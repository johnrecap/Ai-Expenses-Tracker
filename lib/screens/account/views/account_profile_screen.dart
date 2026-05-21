import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/account/cubit/account_profile_cubit.dart';
import 'package:expenses_tracker/screens/account/models/account_identity.dart';
import 'package:expenses_tracker/screens/account/models/reauth_request.dart';
import 'package:expenses_tracker/screens/account/services/account_deletion_service.dart';
import 'package:expenses_tracker/screens/account/services/account_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({
    required this.user,
    super.key,
  });

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final profileService = _readOrDefault<AccountProfileService>(
      context,
      DefaultAccountProfileService.instance,
    );
    return BlocProvider(
      create: (_) => AccountProfileCubit(
        user: user,
        accountProfileService: profileService,
        accountDeletionService: AccountDeletionService(
          accountProfileService: profileService,
        ),
      )..load(),
      child: const _AccountProfileView(),
    );
  }

  T _readOrDefault<T>(BuildContext context, T fallback) {
    try {
      return context.read<T>();
    } catch (_) {
      return fallback;
    }
  }
}

class _AccountProfileView extends StatelessWidget {
  const _AccountProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountProfileCubit, AccountProfileState>(
      listenWhen: (previous, current) =>
          (previous.messageKey != current.messageKey &&
              current.messageKey != null) ||
          (previous.reauthRequest != current.reauthRequest &&
              current.reauthRequest != null),
      listener: (context, state) {
        final messageKey = state.messageKey;
        if (messageKey != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(_message(context, messageKey))),
            );
        }
        if (state.status == AccountProfileStatus.deleted) {
          Navigator.of(context).maybePop();
        } else if (state.reauthRequest != null && !state.isBusy) {
          _showReauthDialog(context, state.reauthRequest!);
        }
      },
      builder: (context, state) {
        final l10n = context.l10n;
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.grey[100],
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(
              l10n.accountProfileTitle,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          body: state.status == AccountProfileStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  top: false,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _IdentityCard(state: state),
                      const SizedBox(height: 16),
                      _AccountActionsCard(state: state),
                      const SizedBox(height: 16),
                      _DeleteAccountCard(state: state),
                    ],
                  ),
                ),
        );
      },
    );
  }

  String _message(BuildContext context, AccountProfileMessageKey key) {
    final l10n = context.l10n;
    switch (key) {
      case AccountProfileMessageKey.loadFailed:
        return l10n.accountProfileLoadFailed;
      case AccountProfileMessageKey.displayNameInvalid:
        return l10n.displayNameRequired;
      case AccountProfileMessageKey.displayNameUpdated:
        return l10n.displayNameUpdated;
      case AccountProfileMessageKey.displayNameUpdateFailed:
        return l10n.displayNameUpdateFailed;
      case AccountProfileMessageKey.passwordResetSent:
        return l10n.accountPasswordResetSent;
      case AccountProfileMessageKey.passwordResetFailed:
        return l10n.accountPasswordResetFailed;
      case AccountProfileMessageKey.emailInvalid:
        return l10n.accountEmailInvalid;
      case AccountProfileMessageKey.emailUpdated:
        return l10n.accountEmailUpdated;
      case AccountProfileMessageKey.emailUpdateFailed:
        return l10n.accountEmailUpdateFailed;
      case AccountProfileMessageKey.reauthRequired:
        return l10n.accountReauthRequired;
      case AccountProfileMessageKey.reauthSucceeded:
        return l10n.accountReauthSucceeded;
      case AccountProfileMessageKey.reauthFailed:
        return l10n.accountReauthFailed;
      case AccountProfileMessageKey.reauthCanceled:
        return l10n.accountReauthCanceled;
      case AccountProfileMessageKey.reauthUnavailable:
        return l10n.accountReauthUnavailable;
      case AccountProfileMessageKey.deleteConfirmationRequired:
        return l10n.accountDeleteConfirmationRequired;
      case AccountProfileMessageKey.dataDeleteFailed:
        return l10n.accountDataDeleteFailed;
      case AccountProfileMessageKey.authDeleteFailed:
        return l10n.accountAuthDeleteFailed;
      case AccountProfileMessageKey.accountDeleted:
        return l10n.accountDeleted;
      case AccountProfileMessageKey.accountDeleteFailed:
        return l10n.accountDeleteFailed;
    }
  }

  Future<void> _showReauthDialog(
    BuildContext context,
    ReauthRequest request,
  ) async {
    final password = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ReauthDialog(request: request),
    );
    if (!context.mounted) return;
    if (password == null) {
      context.read<AccountProfileCubit>().cancelReauthentication();
      return;
    }
    context
        .read<AccountProfileCubit>()
        .completeReauthentication(password: password);
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.state});

  final AccountProfileState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = AccountIdentity.displayName(
      user: state.user,
      localDisplayName: state.localDisplayName,
      fallbackUserLabel: l10n.profileFallbackUser,
    );
    final secondary = AccountIdentity.secondaryIdentity(
      user: state.user,
      localDisplayName: state.localDisplayName,
    );
    final accountId = state.user.userId.trim();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(AccountIdentity.initials(displayName)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (secondary != null)
                        Text(
                          secondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.editProfileName,
                  onPressed: state.isBusy ||
                          !state.capabilities.canEditLocalDisplayName
                      ? null
                      : () => _showEditDisplayNameDialog(
                            context,
                            state.localDisplayName ?? displayName,
                          ),
                  icon: state.status == AccountProfileStatus.savingDisplayName
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const Divider(height: 32),
            _DetailRow(
              icon: Icons.email_outlined,
              label: l10n.accountEmail,
              value: state.user.email?.trim().isNotEmpty == true
                  ? state.user.email!.trim()
                  : l10n.accountEmailMissing,
            ),
            _DetailRow(
              icon: Icons.login_outlined,
              label: l10n.accountProvider,
              value: state.capabilities.providerLabel(l10n),
            ),
            _DetailRow(
              icon: Icons.badge_outlined,
              label: l10n.accountId,
              value: accountId.isEmpty ? l10n.profileFallbackUser : accountId,
              trailing: IconButton(
                tooltip: l10n.copyAccountId,
                onPressed:
                    accountId.isEmpty ? null : () => _copyAccountId(context),
                icon: const Icon(Icons.copy_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDisplayNameDialog(
    BuildContext context,
    String initialValue,
  ) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _TextInputDialog(
        title: context.l10n.editProfileName,
        label: context.l10n.displayNameLabel,
        hint: context.l10n.displayNameHint,
        initialValue: initialValue,
        validator: (value) {
          final trimmed = value.trim();
          if (trimmed.isEmpty) return context.l10n.displayNameRequired;
          if (trimmed.length > 60) return context.l10n.displayNameTooLong;
          return null;
        },
      ),
    );
    if (!context.mounted || value == null) return;
    context.read<AccountProfileCubit>().saveDisplayName(value);
  }

  Future<void> _copyAccountId(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: state.user.userId));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.accountIdCopied)));
  }
}

class _AccountActionsCard extends StatelessWidget {
  const _AccountActionsCard({required this.state});

  final AccountProfileState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_reset_outlined),
            title: Text(l10n.accountPasswordReset),
            subtitle: Text(
              state.capabilities.canSendPasswordReset
                  ? l10n.accountPasswordResetDescription
                  : l10n.accountActionUnavailableForProvider,
            ),
            enabled: state.capabilities.canSendPasswordReset && !state.isBusy,
            trailing: state.status == AccountProfileStatus.sendingPasswordReset
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: state.capabilities.canSendPasswordReset && !state.isBusy
                ? () => context.read<AccountProfileCubit>().sendPasswordReset()
                : null,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.alternate_email_outlined),
            title: Text(l10n.accountUpdateEmail),
            subtitle: Text(
              state.capabilities.canUpdateEmail
                  ? l10n.accountUpdateEmailDescription
                  : l10n.accountActionUnavailableForProvider,
            ),
            enabled: state.capabilities.canUpdateEmail && !state.isBusy,
            trailing: state.status == AccountProfileStatus.updatingEmail
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: state.capabilities.canUpdateEmail && !state.isBusy
                ? () => _showEmailDialog(context, state.user.email ?? '')
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _showEmailDialog(
    BuildContext context,
    String initialValue,
  ) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _TextInputDialog(
        title: context.l10n.accountUpdateEmail,
        label: context.l10n.accountNewEmail,
        hint: 'name@example.com',
        keyboardType: TextInputType.emailAddress,
        initialValue: initialValue,
        validator: (value) {
          if (!value.trim().contains('@')) {
            return context.l10n.accountEmailInvalid;
          }
          return null;
        },
      ),
    );
    if (!context.mounted || value == null) return;
    context.read<AccountProfileCubit>().updateEmail(value);
  }
}

class _DeleteAccountCard extends StatelessWidget {
  const _DeleteAccountCard({required this.state});

  final AccountProfileState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(
          Icons.delete_forever_outlined,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(
          l10n.accountDeleteTitle,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        subtitle: Text(l10n.accountDeleteShortDescription),
        enabled: state.capabilities.canDeleteAccount && !state.isBusy,
        trailing: state.status == AccountProfileStatus.deletingAccount
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
        onTap: state.capabilities.canDeleteAccount && !state.isBusy
            ? () => _showDeleteDialog(context)
            : null,
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (!context.mounted || confirmed != true) return;
    context.read<AccountProfileCubit>().deleteAccount(warningConfirmed: true);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing,
    );
  }
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.validator,
    this.keyboardType,
  });

  final String title;
  final String label;
  final String hint;
  final String initialValue;
  final TextInputType? keyboardType;
  final String? Function(String value) validator;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: widget.keyboardType,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(context.l10n.save),
        ),
      ],
    );
  }

  void _submit() {
    final error = widget.validator(_controller.text);
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }
    Navigator.of(context).pop(_controller.text.trim());
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.accountDeleteTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.accountDeleteWarning),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _confirmed,
            onChanged: (value) => setState(() => _confirmed = value ?? false),
            title: Text(l10n.accountDeleteConfirmCheckbox),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: _confirmed ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.accountDeleteButton),
        ),
      ],
    );
  }
}

class _ReauthDialog extends StatefulWidget {
  const _ReauthDialog({required this.request});

  final ReauthRequest request;

  @override
  State<_ReauthDialog> createState() => _ReauthDialogState();
}

class _ReauthDialogState extends State<_ReauthDialog> {
  late final TextEditingController _passwordController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.accountReauthTitle),
      content: widget.request.requiresPassword
          ? TextField(
              controller: _passwordController,
              autofocus: true,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.accountReauthPasswordLabel,
                helperText: l10n.accountReauthPasswordDescription,
                errorText: _errorText,
              ),
              onSubmitted: (_) => _submitPassword(),
            )
          : Text(l10n.accountReauthGoogleDescription),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: widget.request.requiresPassword
              ? _submitPassword
              : () => Navigator.of(context).pop('google'),
          child: Text(
            widget.request.requiresPassword
                ? l10n.retry
                : l10n.accountReauthGoogleButton,
          ),
        ),
      ],
    );
  }

  void _submitPassword() {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _errorText = context.l10n.accountReauthPasswordLabel);
      return;
    }
    Navigator.of(context).pop(password);
  }
}
