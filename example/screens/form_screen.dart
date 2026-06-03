import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/serverpod_tui.dart';

class FormScreen extends StatefulComponent {
  @override
  State<StatefulComponent> createState() => FormScreenState();
}

class FormScreenState extends State<FormScreen> {
  final scrollController = ScrollController();
  final formState = FormState([
    InputConfig.projectId,
    ...SelectionConfig.values,
  ]);

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return Form(
      state: formState,
      scrollController: scrollController,
      rebuild: () => setState(() {}),
    );
  }
}

enum InputConfig<T extends FormConfigOption> implements FormInputConfig {
  projectId(
    label: 'Project ID',
    description: 'A unique identifier for your project',
    suffixText: '.serverpod',
  )
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
  final String? description;

  @override
  final List<FormRequirement> requirements;
}

enum SelectionConfig<T extends FormConfigOption>
    implements FormSelectionConfig<T> {
  database<DatabaseConfigOption>(
    label: 'Database',
    options: DatabaseConfigOption.values,
    defaultOptions: {DatabaseConfigOption.postgres},
  ),
  auth<BoolFormConfigOption>(
    label: 'Authentication',
    options: BoolFormConfigOption.values,
    defaultOptions: {BoolFormConfigOption.enabled},
    description:
        'Enable authentication if you want your users to be able to sign in with email or social logins.',
    requirements: [
      FormRequirement(
        config: SelectionConfig.database,
        configOption: DatabaseConfigOption.postgres,
      ),
    ],
  ),
  ide<IdeOption>(
    label: 'IDEs',
    options: IdeOption.values,
    multiSelect: true,
    defaultOptions: <IdeOption>{},
    description: 'Select the editors and agents you are planning to use',
  )
  ;

  const SelectionConfig({
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
  final String? description;
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
