<?php
/**
 * Adds strict_types declaration to all PHP files in a directory, excluding specified directories.
 *
 * @package Modig_Scripts
 */

// phpcs:disable WordPress.WP.AlternativeFunctions.file_get_contents_file_get_contents
// phpcs:disable WordPress.WP.AlternativeFunctions.file_system_operations_file_put_contents
// phpcs:disable WordPress.Security.EscapeOutput.OutputNotEscaped

/**
 * Adds strict_types declaration to all PHP files in a directory, excluding specified directories.
 *
 * @param string $dir           The directory path.
 * @param array  $excluded_dirs An array of excluded directory names.
 *
 * @return void
 */
function add_strict_types_to_directory( string $dir, array $excluded_dirs ): void {
	$iterator = new RecursiveIteratorIterator( new RecursiveDirectoryIterator( $dir ) );
	foreach ( $iterator as $file ) {
		if ( $file->isDir() ) {
			continue;
		}
		$relative_path = str_replace( $dir, '', $file->getPathname() );
		foreach ( $excluded_dirs as $excluded_dir ) {
			if ( str_contains( $relative_path, $excluded_dir ) ) {
				continue 2;
			}
		}
		if ( pathinfo( $file->getFilename(), PATHINFO_EXTENSION ) === 'php' ) {
			add_strict_types_to_file( $file->getPathname() );
		}
	}
}

/**
 * Adds strict_types declaration to a PHP file if it doesn't exist.
 *
 * @param string $file_path The path to the PHP file.
 *
 * @return void
 */
function add_strict_types_to_file( string $file_path ): void {
	$content = file_get_contents( $file_path );
	if ( ! str_contains( $content, 'declare(strict_types=1);' ) ) {
		$updated_content = add_strict_types_after_docblock( $content );
		file_put_contents( $file_path, $updated_content );
		echo "Added strict_types to: $file_path\n";
	}
}

/**
 * Adds the strict_types declaration after the file docblock.
 *
 * @param string $content The content of the PHP file.
 *
 * @return string The updated content with strict_types declaration.
 */
function add_strict_types_after_docblock( string $content ): string {
	$docblock_pattern = '/(<\?php\s*\/\*\*.*?\*\/\s*)/s';
	if ( preg_match( $docblock_pattern, $content, $matches ) ) {
		$docblock        = $matches[1];
		$rest_of_content = substr( $content, strlen( $docblock ) );
		return $docblock . "declare(strict_types=1);\n\n" . $rest_of_content;
	} else {
		return "<?php\ndeclare(strict_types=1);\n\n" . ltrim( $content, "<?php\n" );
	}
}

// Set the path to your project directory.
$project_path  = '/app';
$excluded_dirs = array( 'wordpress', 'vendor', 'node_modules', 'deploy', 'testsuite' );
add_strict_types_to_directory( $project_path, $excluded_dirs );
