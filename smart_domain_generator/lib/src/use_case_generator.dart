import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:smart_domain/smart_domain.dart';
import 'package:source_gen/source_gen.dart';

final class UseCaseGenerator extends GeneratorForAnnotation<GenerateUseCases> {
  const UseCaseGenerator();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! InterfaceElement) {
      throw InvalidGenerationSource(
        '@GenerateUseCases() can only annotate a class or interface.',
        element: element,
      );
    }
    if (element.typeParameters.isNotEmpty) {
      throw InvalidGenerationSource(
        '@GenerateUseCases() does not support generic repositories.',
        element: element,
      );
    }

    final repositoryName = element.name!;
    final methods = element.methods.where((method) => !method.isStatic);
    final output = StringBuffer();

    for (final method in methods) {
      output.writeln(_generateMethod(repositoryName, method));
    }

    return output.toString();
  }

  String _generateMethod(String repositoryName, MethodElement method) {
    if (method.typeParameters.isNotEmpty) {
      throw InvalidGenerationSource(
        '${method.displayName} cannot be generic.',
        element: method,
      );
    }
    if (method.formalParameters.any((parameter) => parameter.isOptional)) {
      throw InvalidGenerationSource(
        '${method.displayName} cannot declare optional parameters.',
        element: method,
      );
    }

    final methodName = method.name!;
    final outputType = _resultOutputType(method);
    final useCaseName = '${_pascalCase(methodName)}UseCase';
    final parameters = method.formalParameters;

    if (parameters.isEmpty) {
      return '''
final class $useCaseName extends NoParamsUseCase<$outputType> {
  const $useCaseName(this.repository);

  final $repositoryName repository;

  @override
  Future<Result<$outputType, Failure>> execute() => repository.$methodName();
}
''';
    }

    final reusesParams =
        parameters.length == 1 &&
        parameters.single.type.element?.name?.endsWith('Params') == true;
    final paramsName = reusesParams
        ? parameters.single.type.getDisplayString()
        : '${_pascalCase(methodName)}Params';
    final paramsClass = reusesParams
        ? ''
        : '${_generateParamsClass(paramsName, parameters)}\n';
    final arguments = parameters
        .map((parameter) => _repositoryArgument(parameter, reusesParams))
        .join(', ');

    return '''
$paramsClass${_generatedUseCase(useCaseName: useCaseName, outputType: outputType, paramsName: paramsName, repositoryName: repositoryName, methodName: methodName, arguments: arguments)}
''';
  }

  String _generatedUseCase({
    required String useCaseName,
    required String outputType,
    required String paramsName,
    required String repositoryName,
    required String methodName,
    required String arguments,
  }) =>
      '''
final class $useCaseName extends UseCase<$outputType, $paramsName> {
  const $useCaseName(this.repository);

  final $repositoryName repository;

  @override
  Future<Result<$outputType, Failure>> execute($paramsName params) =>
      repository.$methodName($arguments);
}
''';

  String _generateParamsClass(
    String paramsName,
    List<FormalParameterElement> parameters,
  ) {
    final constructorParameters = parameters
        .map((parameter) {
          final name = parameter.name;
          if (parameter.isRequiredNamed) return 'required this.$name';
          if (parameter.isNamed) return 'this.$name';
          return 'required this.$name';
        })
        .join(', ');
    final fields = parameters
        .map((parameter) {
          return '  final ${parameter.type.getDisplayString()} ${parameter.name};';
        })
        .join('\n');

    return '''
final class $paramsName {
  const $paramsName({$constructorParameters});

$fields
}
''';
  }

  String _repositoryArgument(
    FormalParameterElement parameter,
    bool reusesParams,
  ) {
    final value = reusesParams ? 'params' : 'params.${parameter.name}';
    return parameter.isNamed ? '${parameter.name}: $value' : value;
  }

  String _resultOutputType(MethodElement method) {
    final returnType = method.returnType;
    if (returnType is! InterfaceType ||
        returnType.element.name != 'Future' ||
        returnType.typeArguments.length != 1) {
      throw InvalidGenerationSource(
        '${method.displayName} must return Future<Result<T, Failure>>.',
        element: method,
      );
    }

    final resultType = returnType.typeArguments.single;
    if (resultType is! InterfaceType ||
        resultType.element.name != 'Result' ||
        resultType.typeArguments.length != 2 ||
        resultType.typeArguments[1].element?.name != 'Failure') {
      throw InvalidGenerationSource(
        '${method.displayName} must return Future<Result<T, Failure>>.',
        element: method,
      );
    }

    return resultType.typeArguments.first.getDisplayString();
  }

  String _pascalCase(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}
