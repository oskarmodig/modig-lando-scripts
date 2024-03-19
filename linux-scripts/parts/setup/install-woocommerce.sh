echo_progress "Installing WooCommerce"
call_wp plugin install woocommerce --activate

echo_progress "Setting up WooCommerce"

call_wp option patch insert woocommerce_onboarding_profile skipped 1
call_wp option update woocommerce_show_marketplace_suggestions 'no'
call_wp option update woocommerce_allow_tracking 'no'
call_wp option update woocommerce_task_list_hidden 'yes'
call_wp option update woocommerce_task_list_complete 'yes'
call_wp option update woocommerce_task_list_welcome_modal_dismissed 'yes'

call_wp option update woocommerce_store_address "Kungsgatan 1"
call_wp option update woocommerce_store_address_2 "Box 123"
call_wp option update woocommerce_store_city "Stockholm"
call_wp option update woocommerce_default_country "SE"
call_wp option update woocommerce_currency "SEK"
call_wp option update woocommerce_price_thousand_sep " "
call_wp option update woocommerce_price_decimal_sep ","
call_wp option update woocommerce_price_num_decimals 2
call_wp option update woocommerce_currency_pos right_space
call_wp option update woocommerce_calc_taxes yes
call_wp option update woocommerce_prices_include_tax yes
call_wp option update woocommerce_tax_display_cart incl
call_wp option update woocommerce_tax_display_shop incl
call_wp option update woocommerce_custom_orders_table_enabled no # Disables HPOS
