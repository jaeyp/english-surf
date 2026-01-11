import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_surf/features/home/presentation/screens/home_screen.dart';
import 'package:english_surf/features/sentences/data/providers/sentence_providers.dart';
import 'package:english_surf/features/sentences/domain/entities/folder.dart';
import 'package:english_surf/features/sentences/domain/repositories/folder_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFolderRepository extends Mock implements FolderRepository {}

void main() {
  late MockFolderRepository mockFolderRepository;

  setUp(() {
    mockFolderRepository = MockFolderRepository();
    registerFallbackValue(Folder(id: '', name: '', createdAt: DateTime.now()));
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        folderRepositoryProvider.overrideWithValue(mockFolderRepository),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  final tFolders = [
    Folder(
      id: 'default_folder',
      name: 'Default',
      createdAt: DateTime(2025, 1, 1),
    ),
    Folder(
      id: 'folder1',
      name: 'Study Folder',
      createdAt: DateTime(2025, 1, 2),
    ),
  ];

  testWidgets('renders folder list correctly', (tester) async {
    // arrange
    when(
      () => mockFolderRepository.getAllFolders(),
    ).thenAnswer((_) async => tFolders);

    // act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Start fetching
    await tester.pump(); // Finish fetching

    // assert
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Study Folder'), findsOneWidget);
    // Folder icons are removed, so we shouldn't find them
    expect(find.byIcon(Icons.folder), findsNothing);
  });

  testWidgets('shows add folder dialog and calls repository on save', (
    tester,
  ) async {
    // arrange
    when(
      () => mockFolderRepository.getAllFolders(),
    ).thenAnswer((_) async => tFolders);
    when(() => mockFolderRepository.addFolder(any())).thenAnswer((_) async {});

    // act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.create_new_folder));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'New Folder');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    // assert
    verify(
      () => mockFolderRepository.addFolder(
        any(that: isA<Folder>().having((f) => f.name, 'name', 'New Folder')),
      ),
    ).called(1);
  });

  testWidgets('shows delete dialog and calls repository on delete', (
    tester,
  ) async {
    // arrange
    when(
      () => mockFolderRepository.getAllFolders(),
    ).thenAnswer((_) async => tFolders);
    when(
      () => mockFolderRepository.deleteFolder(any()),
    ).thenAnswer((_) async {});

    // act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Find the More Vert icon specifically for 'Study Folder' (folder1)
    // Since 'Default' doesn't have one, finding by Icon should invoke only one if there are 2 folders and 1 has menu.
    // However, if there are other MoreVerts (e.g. AppBar?), we need to be specific.
    // The previous test failed due to ambiguity.
    // Assuming 'Default' (index 0) has NO menu, 'Study Folder' (index 1) HAS menu.
    // Safe finder: find descendant of the row with text "Study Folder".
    final studyFolderFinder = find.widgetWithText(InkWell, 'Study Folder');
    final moreIconFinder = find.descendant(
      of: studyFolderFinder,
      matching: find.byIcon(Icons.more_vert),
    );

    await tester.tap(moreIconFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    // assert
    verify(() => mockFolderRepository.deleteFolder('folder1')).called(1);
  });
}
