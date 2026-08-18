import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/use_case_generator.dart';

/// Creates the builder that writes generated use cases into `.g.dart` parts.
Builder generateUseCasesBuilder(BuilderOptions options) =>
    SharedPartBuilder(const [UseCaseGenerator()], 'generate_use_cases');
