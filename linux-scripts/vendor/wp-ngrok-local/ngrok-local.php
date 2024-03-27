<?php
/**
 * Plugin Name: Ngrok Local
 * Plugin URI: https://wp-stream.com/
 * Description: Translate host on the fly to expose local server to the web using ngrok.
 * Version: 0.0.1
 * Author: Jonathan Bardo
 * Author URI: http://jonathanbardo.com
 * License: GPLv2+
 */

class Ngrok_Local {

	private string $site_url;

	public function __construct(){
		$this->site_url = site_url() . '/';;

		if (
			! defined( 'WP_SITEURL' ) &&
			! defined( 'WP_HOME' ) &&
			isset( $_SERVER['HTTP_HOST'] )
		) {
			$protocol = is_ssl() ? 'https://' : 'http://';

			define( 'WP_SITEURL', $protocol . $_SERVER['HTTP_HOST'] );
			define( 'WP_HOME', $protocol . $_SERVER['HTTP_HOST'] );
		} else {
			// Bail if those constants are already defined.
			return false;
		}

		add_action( 'template_redirect', array( $this, 'template_redirect' ) );
	}

	public function template_redirect() {
		if ( ! isset( $_GET['wp_ngrok_autoload'] ) ) {
			$protocol = is_ssl() ? 'https://' : 'http://';

			$request  = wp_remote_get(
				add_query_arg(
					'wp_ngrok_autoload',
					1,
					$protocol . $_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI']
				)
			);
			$response = wp_remote_retrieve_body( $request );

			echo str_replace(
				$this->site_url,
				wp_make_link_relative( $this->site_url ),
				$response
			);
			exit;
		}
	}
}

new Ngrok_Local;
