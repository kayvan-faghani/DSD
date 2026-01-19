	component base is
		port (
			clk_clk                            : in  std_logic                    := 'X'; -- clk
			led_pio_external_connection_export : out std_logic_vector(7 downto 0)         -- export
		);
	end component base;

	u0 : component base
		port map (
			clk_clk                            => CONNECTED_TO_clk_clk,                            --                         clk.clk
			led_pio_external_connection_export => CONNECTED_TO_led_pio_external_connection_export  -- led_pio_external_connection.export
		);

