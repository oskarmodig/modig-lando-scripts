echo_progress "Setting up WooCommerce"

call_wp wp option update woocommerce_store_address "Kungsgatan 1"
call_wp wp option update woocommerce_store_address_2 "Box 123"
call_wp wp option update woocommerce_store_city "Stockholm"
call_wp wp option update woocommerce_default_country "SE"
call_wp wp option update woocommerce_currency "SEK"
call_wp wp option update woocommerce_price_thousand_sep " "
call_wp wp option update woocommerce_price_decimal_sep ","
call_wp wp option update woocommerce_price_num_decimals 2
call_wp wp option update woocommerce_currency_pos right_space
call_wp wp option update woocommerce_calc_taxes yes
call_wp wp option update woocommerce_prices_include_tax yes
call_wp wp option update woocommerce_tax_display_cart incl
call_wp wp option update woocommerce_tax_display_shop incl
call_wp wp option update woocommerce_custom_orders_table_enabled no # Disables HPOS
