import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:buzz/features/channels/channel.dart';
import 'package:buzz/features/channels/channels_page.dart';
import 'package:buzz/features/channels/channels_provider.dart';
import 'package:buzz/features/profile/profile_provider.dart';
import 'package:buzz/features/profile/user_profile_sheet.dart';
import 'package:buzz/features/profile/user_profile.dart';
import 'package:buzz/shared/mentions/agent_identity_provider.dart';
import 'package:buzz/shared/theme/theme.dart';

/// An agent's presence can only ever read `offline` — the relay clears it when
/// the agent's one-shot socket closes — so agent pubkeys render no dot at all.
/// Humans are untouched. See DIVE-3624.
const _agentPubkey =
    'a11ce0000000000000000000000000000000000000000000000000000000agen';
const _humanPubkey =
    'b0b0000000000000000000000000000000000000000000000000000000human';
const _selfPubkey =
    '5e1f0000000000000000000000000000000000000000000000000000000005e1';

void main() {
  group('showsPresenceDot', () {
    test('suppresses the dot for a known agent pubkey', () {
      expect(
        showsPresenceDot(agentPubkeys: {_agentPubkey}, pubkey: _agentPubkey),
        isFalse,
      );
    });

    test('matches case-insensitively', () {
      expect(
        showsPresenceDot(
          agentPubkeys: {_agentPubkey},
          pubkey: _agentPubkey.toUpperCase(),
        ),
        isFalse,
      );
    });

    test('keeps the dot for a human pubkey', () {
      expect(
        showsPresenceDot(agentPubkeys: {_agentPubkey}, pubkey: _humanPubkey),
        isTrue,
      );
    });

    test('keeps the dot when the agent directory has not loaded', () {
      expect(
        showsPresenceDot(agentPubkeys: const {}, pubkey: _agentPubkey),
        isTrue,
      );
    });

    test('keeps the dot when there is no pubkey to classify', () {
      expect(
        showsPresenceDot(agentPubkeys: {_agentPubkey}, pubkey: null),
        isTrue,
      );
    });

    test(
      'suppresses on a verified NIP-OA profile the directory has not seen',
      () {
        expect(
          showsPresenceDot(
            agentPubkeys: const {},
            pubkey: _agentPubkey,
            profileIdentifiesAgent: true,
          ),
          isFalse,
        );
      },
    );
  });

  group('DM list tile', () {
    Channel dm(String id, String name, String otherPubkey) => Channel(
      id: id,
      name: name,
      channelType: 'dm',
      visibility: 'open',
      description: 'Direct message',
      createdBy: _selfPubkey,
      createdAt: DateTime(2025),
      memberCount: 2,
      participants: const ['Me', 'Them'],
      participantPubkeys: [_selfPubkey, otherPubkey],
      isMember: true,
    );

    Widget buildPage(List<Channel> channels) => ProviderScope(
      overrides: [
        channelsProvider.overrideWith(() => _FakeChannelsNotifier(channels)),
        profileProvider.overrideWith(() => _FakeProfileNotifier()),
        knownAgentPubkeysProvider.overrideWithValue({_agentPubkey}),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: ChannelsPage(
          settingsPageBuilder: (_) => const SizedBox.shrink(),
          onSettingsTransitionProgress: (_) {},
        ),
      ),
    );

    testWidgets('renders no presence dot for an agent DM', (tester) async {
      await tester.pumpWidget(buildPage([dm('1', 'agent', _agentPubkey)]));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('dm-tile-presence-dot')), findsNothing);
    });

    testWidgets('still renders a presence dot for a human DM', (tester) async {
      await tester.pumpWidget(buildPage([dm('1', 'human', _humanPubkey)]));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('dm-tile-presence-dot')),
        findsOneWidget,
      );
    });

    testWidgets('suppresses only the agent row when both are listed', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildPage([
          dm('1', 'agent', _agentPubkey),
          dm('2', 'human', _humanPubkey),
        ]),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('dm-tile-presence-dot')),
        findsOneWidget,
      );
    });
  });

  group('user profile sheet', () {
    Widget buildSheet(String pubkey) => ProviderScope(
      overrides: [
        knownAgentPubkeysProvider.overrideWithValue({_agentPubkey}),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: UserProfileSheet(pubkey: pubkey)),
      ),
    );

    testWidgets('renders no presence chip for an agent', (tester) async {
      await tester.pumpWidget(buildSheet(_agentPubkey));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('profile-sheet-presence-chip')),
        findsNothing,
      );
    });

    testWidgets('still renders the presence chip for a human', (tester) async {
      await tester.pumpWidget(buildSheet(_humanPubkey));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('profile-sheet-presence-chip')),
        findsOneWidget,
      );
    });
  });
}

class _FakeChannelsNotifier extends ChannelsNotifier {
  _FakeChannelsNotifier(this.channels);

  final List<Channel> channels;

  @override
  Future<List<Channel>> build() async => channels;
}

class _FakeProfileNotifier extends ProfileNotifier {
  @override
  Future<UserProfile?> build() async =>
      const UserProfile(pubkey: _selfPubkey, displayName: 'Me');
}
