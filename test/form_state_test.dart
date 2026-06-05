import 'package:serverpod_tui/src/form/config.dart';
import 'package:serverpod_tui/src/form/config_option.dart';
import 'package:serverpod_tui/src/form/requirement.dart';
import 'package:serverpod_tui/src/form/state.dart';
import 'package:serverpod_tui/src/form/validating_text_controller.dart';
import 'package:test/test.dart';

enum InputConfig<T extends FormConfigOption> implements FormInputConfig {
  projectId(label: 'Project ID')
  ;

  const InputConfig({
    required this.label,
    this.maxLines = 1,
    this.width = 10,
    this.suffixText = '',
    this.requirements = const [],
    this.description,
  });

  @override
  final String label;

  @override
  final int maxLines;

  @override
  final double width;

  @override
  final String? suffixText;

  @override
  final FormDescription? description;

  @override
  final List<FormRequirement> requirements;
}

enum TestConfig<T extends FormConfigOption> implements FormSelectionConfig<T> {
  database<DatabaseConfigOption>(
    label: 'Database',
    options: DatabaseConfigOption.values,
    defaultOptions: {DatabaseConfigOption.postgres},
  ),
  auth<BoolFormConfigOption>(
    label: 'Authentication',
    options: BoolFormConfigOption.values,
    defaultOptions: {BoolFormConfigOption.enabled},
    requirements: [
      FormRequirement(
        config: TestConfig.database,
        configOption: DatabaseConfigOption.postgres,
      ),
    ],
  ),
  ide<IdeOption>(
    label: 'IDEs',
    options: IdeOption.values,
    multiSelect: true,
    defaultOptions: <IdeOption>{},
  )
  ;

  const TestConfig({
    required this.label,
    required this.options,
    required this.defaultOptions,
    this.requirements = const [],
    this.multiSelect = false,
    this.description,
  });

  @override
  final String label;

  @override
  final List<T> options;

  @override
  final Set<T> defaultOptions;

  @override
  final List<FormRequirement> requirements;

  @override
  final bool multiSelect;

  @override
  final FormDescription? description;
}

enum DatabaseConfigOption implements FormConfigOption {
  postgres('Postgres'),
  sqlite('SQLite'),
  none('None')
  ;

  const DatabaseConfigOption(this.label);

  @override
  final String label;
}

enum IdeOption implements FormConfigOption {
  antigravity('Antigravity'),
  codex('Codex'),
  claude('Claude'),
  cursor('Cursor'),
  openCode('OpenCode'),
  vsCode('VS Code')
  ;

  const IdeOption(this.label);

  @override
  final String label;
}

void main() {
  group('Given a FormState', () {
    late FormState state;
    final configurations = <FormConfig>[
      ...TestConfig.values,
      ...InputConfig.values,
    ];

    setUp(() {
      state = FormState(configurations);
    });

    test('when created then defaults are correct', () {
      expect(state.focusedConfigIndex, 0);

      expect(state.getFocusedOptionIndexFor(TestConfig.database), 0);
      expect(state.getFocusedOptionIndexFor(TestConfig.auth), 0);
      expect(state.getFocusedOptionIndexFor(TestConfig.ide), 0);
      expect(
        state.getSelectedOptionFor<DatabaseConfigOption>(TestConfig.database),
        DatabaseConfigOption.postgres,
      );
      expect(
        state.getSelectedOptionFor<BoolFormConfigOption>(TestConfig.auth),
        BoolFormConfigOption.enabled,
      );
      expect(state.getSelectedOptionsFor<IdeOption>(TestConfig.ide), isEmpty);
    });

    test('then the config values are correct', () {
      expect(
        state.configurations,
        containsAllInOrder([
          TestConfig.database,
          TestConfig.auth,
          TestConfig.ide,
        ]),
      );
    });

    test(
      'when requesting focus for a config, '
      'then the focused config index is set correctly',
      () {
        expect(state.focusedConfigIndex, 0);
        state.requestFocus(TestConfig.ide);
        expect(state.focusedConfigIndex, 2);
      },
    );

    test(
      'when updating the focused config with positive delta, '
      'then the focused config index is incremented',
      () {
        state.updateFocusedConfig(1);
        expect(state.focusedConfigIndex, 1);
      },
    );

    test(
      'when updating the focused config with positive delta '
      'and the current focused config index is the maximum index, '
      'then the focused config index wraps to 0',
      () {
        for (var i = 0; i < state.configurations.length; i++) {
          state.updateFocusedConfig(1);
        }
        expect(state.focusedConfigIndex, 0);
      },
    );

    test(
      'when updating the focused config with negative delta, '
      'then the focused config index is decremented',
      () {
        state.updateFocusedConfig(1);
        state.updateFocusedConfig(-1);
        expect(state.focusedConfigIndex, 0);
      },
    );

    test(
      'when updating the focused config with negative delta, '
      'and the current focused config index is 0, '
      'then the focused config index wraps to the max config index',
      () {
        state.updateFocusedConfig(-1);
        expect(state.focusedConfigIndex, state.maxFocusedConfigIndex);
      },
    );

    group('when selecting focused config option with positive delta', () {
      late FormSelectionConfig config;
      int initialFocusedOptionIndex = 0;

      setUp(() {
        config =
            state.configurations[state.focusedConfigIndex]
                as FormSelectionConfig;
        initialFocusedOptionIndex = state.getFocusedOptionIndexFor(config) ?? 0;

        state.updateFocusedConfigOption(1);
        state.selectConfigOption();
      });

      test('then the focused config option index is incremented', () {
        expect(
          state.getFocusedOptionIndexFor(config),
          initialFocusedOptionIndex + 1,
        );
      });

      test('then the focused config option is selected', () {
        final expectedOption = config.options[initialFocusedOptionIndex + 1];
        expect(state.getSelectedOptionFor(config), expectedOption);
      });

      test(
        'and the current focused config option index is the max, '
        'then the focused config option index wraps to 0',
        () {
          final config =
              state.configurations[state.focusedConfigIndex]
                  as FormSelectionConfig;
          final optionsCount = config.options.length - 1;

          for (var i = 0; i < optionsCount; i++) {
            state.updateFocusedConfigOption(1);
            state.selectConfigOption();
          }

          final focusedOptionIndex = state.getFocusedOptionIndexFor(config);
          expect(focusedOptionIndex, 0);
        },
      );
    });

    group('when selecting focused config option with negative delta', () {
      late FormSelectionConfig config;
      int indexAfterPositive = 0;

      setUp(() {
        config =
            state.configurations[state.focusedConfigIndex]
                as FormSelectionConfig;
        state.updateFocusedConfigOption(1);
        state.selectConfigOption();
        indexAfterPositive = state.getFocusedOptionIndexFor(config) ?? 0;
        state.updateFocusedConfigOption(-1);
        state.selectConfigOption();
      });

      test('then the focused config option index is decremented', () {
        expect(state.getFocusedOptionIndexFor(config), indexAfterPositive - 1);
      });

      test('then the focused config option is selected', () {
        final expectedOption = config.options[indexAfterPositive - 1];
        expect(state.getSelectedOptionFor(config), expectedOption);
      });

      test(
        'and the current focused config option index is 0, '
        'then the focused config option index wraps to the max config option index',
        () {
          final config =
              state.configurations[state.focusedConfigIndex]
                  as FormSelectionConfig;
          state.updateFocusedConfigOption(-1);
          state.selectConfigOption();
          expect(
            state.getFocusedOptionIndexFor(config),
            config.options.length - 1,
          );
        },
      );
    });

    group('when a multi-select option is selected', () {
      setUp(() {
        state.updateSelectedOption(TestConfig.ide, IdeOption.vsCode);
      });

      test('then getSelectedOptionsFor returns the selected option', () {
        expect(
          state.getSelectedOptionsFor(TestConfig.ide),
          contains(IdeOption.vsCode),
        );
      });

      test(
        'when selecting the same multi-select option again, '
        'then it is deselected',
        () {
          state.updateSelectedOption(TestConfig.ide, IdeOption.vsCode);
          expect(state.getSelectedOptionsFor(TestConfig.ide), isEmpty);
        },
      );
    });

    test(
      'when multiple multi-select options are selected, '
      'then getSelectedOptionsFor returns all selected options',
      () {
        state.updateSelectedOption(TestConfig.ide, IdeOption.vsCode);
        state.updateSelectedOption(TestConfig.ide, IdeOption.cursor);
        expect(
          state.getSelectedOptionsFor(TestConfig.ide),
          containsAll([IdeOption.vsCode, IdeOption.cursor]),
        );
      },
    );

    test(
      'then isOptionSelectedForConfig returns true for option that is selected for a config',
      () {
        final status = state.isOptionSelectedForConfig(
          TestConfig.database,
          DatabaseConfigOption.postgres,
        );

        expect(status, isTrue);
      },
    );

    test(
      'then isOptionSelectedForConfig returns false for option that is not selected for a config',
      () {
        final status = state.isOptionSelectedForConfig(
          TestConfig.database,
          DatabaseConfigOption.sqlite,
        );

        expect(status, isFalse);
      },
    );

    test(
      'when unselecting an option that is required by another config, '
      'then the other config is disabled and removed from the configurations list',
      () {
        // Enabled by default since required DatabaseConfigOption.postgres
        // is also enabled by default.
        expect(
          state.getSelectedOptionFor(TestConfig.auth),
          BoolFormConfigOption.enabled,
        );

        // Select DatabaseConfigOption.none
        state.updateFocusedConfigOption(2);
        state.selectConfigOption();

        // auth config should no longer be in the configurations list
        expect(state.configurations, isNot(contains(TestConfig.auth)));
        expect(state.getSelectedOptionFor(TestConfig.auth), isNull);
      },
    );

    test(
      'when updating input for a FormInputConfig, '
      'then the internal TextEditingController is updated',
      () {
        const projectId = 'my-project';

        final controller = state.getInputControllerFor(InputConfig.projectId);
        expect(controller?.text, isEmpty);

        state.updateInput(InputConfig.projectId, projectId);
        expect(controller?.text, projectId);
      },
    );

    group('when a validator is set on an input config', () {
      late ValidatingTextController controller;

      setUp(() {
        controller = state.getInputControllerFor(InputConfig.projectId)!;
        state.setValidator(
          InputConfig.projectId,
          (text) => text.isEmpty ? 'Required' : null,
        );
      });

      test(
        'then the controller error value is null when text is valid',
        () {
          controller.text = 'valid';
          expect(controller.error.value, isNull);
        },
      );

      test(
        'then the controller error value is set when text is invalid',
        () {
          controller.text = '';
          expect(controller.error.value, 'Required');
        },
      );
    });
  });
}
