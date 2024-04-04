<?php
/**
 * Plugin Name: Modig Ngrok Local
 * Description: Handle ngrok configurations and replace the site URL with the ngrok URL. Should never be used in production, and preferably only enabled when using ngrok.
 * Version: 0.1.0
 * Author: Oskar Modig
 * Author URI: http://modigmedia.se
 * License: GPLv2+
 *
 * Inspired by:
 * - https://github.com/jonathanbardo/WP-Ngrok-Local
 * - https://ngrok.com/docs/using-ngrok-with/wordpress/
 */

/**
 * Class Ngrok_Local
 *
 * The Ngrok_Local class is responsible for handling ngrok configurations and replacing
 * the site URL with the ngrok URL.
 */
class Ngrok_Local {

	/**
	 * Local site url, that ngrok will forward to
	 *
	 * @var string
	 */
	private string $local_url;

	/**
	 * The protocol of the local site.
	 *
	 * @var string
	 */
	private string $local_protocol;

	/**
	 * The remote ngrok URL of the site.
	 *
	 * @var string
	 */
	private string $remote_url;

	/**
	 * The remote domain of the site.
	 *
	 * @var string
	 */
	private string $remote_domain;

	/**
	 * Construct ngrok local.
	 */
	public function __construct() {
		// Abort if CRON or WP CLI.
		if (
			( defined( 'DOING_CRON' ) && DOING_CRON ) ||
			( defined( 'WP_CLI' ) && WP_CLI )
		) {
			return;
		}

		$this->local_url   = site_url();
		$remote_url_loaded = $this->load_remote_url();

		if ( $remote_url_loaded ) {
			$constants_to_set = array(
				'WP_SITEURL'     => $this->remote_url,
				'WP_HOME'        => $this->remote_url,
				'COOKIE_DOMAIN'  => $this->remote_domain,
				'SITECOOKIEPATH' => '.',
			);

			foreach ( $constants_to_set as $constant => $value ) {
				if ( ! defined( $constant ) ) {
					define( $constant, $value );
				}
			}
		}

		if ( isset( $_SERVER['HTTP_X_FORWARDED_FOR'] ) ) {
			$list = explode( ',', $_SERVER['HTTP_X_FORWARDED_FOR'] );

			$_SERVER['REMOTE_ADDR'] = $list[0];
		}

		add_action( 'template_redirect', array( $this, 'template_redirect' ) );
	}

	/**
	 * Get the content of the page and replace the site url with the ngrok url.
	 *
	 * @return void
	 */
	public function template_redirect(): void {
		if (
			// phpcs:ignore WordPress.Security.NonceVerification.Recommended
			! isset( $_GET['wp_ngrok_autoload'] ) &&
			isset( $this->remote_url )
		) {
			$local_url_with_request       = $this->local_protocol . $_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI'];
			$local_url_with_ngrok_request = add_query_arg( 'wp_ngrok_autoload', 1, $local_url_with_request );

			$request  = wp_remote_get( $local_url_with_ngrok_request );
			$response = wp_remote_retrieve_body( $request );

			// phpcs:ignore WordPress.Security.EscapeOutput.OutputNotEscaped
			echo str_replace(
				$this->local_url,
				$this->remote_url,
				$response
			);
			exit;
		}
	}

	/**
	 * Tries to load the ngrok remote URL.
	 *
	 * @return bool True if the remote URL was successfully loaded, false otherwise.
	 */
	private function load_remote_url(): bool {
		$this->local_protocol = is_ssl() ? 'https://' : 'http://';

		if ( defined( 'WP_NGROK_REMOTE_URL' ) ) {
			$this->remote_url = WP_NGROK_REMOTE_URL;

		} elseif ( ! empty( $_SERVER['HTTP_HOST'] ) ) {
			$this->remote_domain = $_SERVER['HTTP_HOST'];
			$this->remote_url    = $this->local_protocol . $_SERVER['HTTP_HOST'];

		} elseif ( ! empty( $_SERVER['HTTP_REFERER'] ) ) {
			$parsed_ngrok_url    = wp_parse_url( $_SERVER['HTTP_REFERER'] );
			$this->remote_url    = $parsed_ngrok_url['scheme'] . '://' . $parsed_ngrok_url['host'];
			$this->remote_domain = $parsed_ngrok_url['host'];
		} else {
			return false;
		}

		return true;
	}
}

new Ngrok_Local();
