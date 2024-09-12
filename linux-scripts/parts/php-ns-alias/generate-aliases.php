<?php
/**
 * Generates a namespace map alias file,
 * helping with loading Northmill Online Shared with different versions for different plugins/themes.
 *
 * @package Modig_Scripts
 */

/**
 * Check if the script has the required number of arguments (3 arguments).
 *
 * @noinspection PhpConditionAlreadyCheckedInspection
 */
if ( 4 !== $argc ) {
	echo "Usage: php generate_aliases.php <directory> <original_namespace> <package_namespace>\n";
	exit( 1 ); // Exit with an error code.
}

// Get the input arguments from the terminal.
$directory          = $argv[1]; // The first argument is the directory.
$original_namespace = $argv[2]; // The second argument is the original namespace.
$package_namespace  = $argv[3]; // The third argument is the package namespace.

/**
 * Function to recursively scan the directory for PHP files.
 *
 * @param string $directory          Path to dir to search for classes.
 * @param string $original_namespace Namespace to look for.
 * @param string $package_namespace  Namespace to create an alias with.
 *                                       Being used in the package loading Northmill Online Shared.
 */
function scan_directory( string $directory, string $original_namespace, string $package_namespace ): string {
	$alias_statements = '';
	$iterator         = new RecursiveIteratorIterator( new RecursiveDirectoryIterator( $directory ) );

	foreach ( $iterator as $file ) {
		if ( $file->isFile() && $file->getExtension() === 'php' ) {
			// Get the class name relative to the base directory.
			$relative_path = str_replace( array( $directory . '/', '.php' ), '', $file->getRealPath() );

			// Convert the path to the class name with namespace.
			$class_path = str_replace( '/', '\\', $relative_path );

			// Create the alias statement.
			$alias_statements .= "namespace $package_namespace\\{$class_path} {\n";
			$alias_statements .= "   class_alias('$original_namespace\\{$class_path}', '$package_namespace\\{$class_path}');\n";
			$alias_statements .= "}\n\n";
		}
	}

	return $alias_statements;
}

// Generate the alias statements.
$alias_content = scan_directory( $directory, $original_namespace, $package_namespace );

// Write the alias statements to ide_helper.php.
file_put_contents( __DIR__ . '/modlan_ns_alias_helper.php', "<?php\n//phpcs:disable\n" . $alias_content ); // phpcs:ignore WordPress.WP.AlternativeFunctions.file_system_operations_file_put_contents

echo "Class alias file generated successfully.\n";
