module iir_filter_tb;

    // Parameters
    parameter SAMPLES = 2881;    // Number of samples
    parameter WORD_WIDTH = 17;   // Total bits (including sign)
    parameter FRAC_WIDTH = 14;   // Fractional bits
    parameter MAX_SECTIONS = 47; // Maximum number of SOS sections
    
    // Coefficients and signals
    reg signed [WORD_WIDTH-1:0] sos[0:MAX_SECTIONS-1][0:5]; // SOS matrix (b0,b1,b2,a0,a1,a2)
    reg signed [WORD_WIDTH-1:0] g[0:MAX_SECTIONS-1];        // Gain values (per section)
    
    reg signed [WORD_WIDTH-1:0] signal[0:SAMPLES-1];
    reg signed [WORD_WIDTH-1:0] filtered[0:SAMPLES-1];
    
    // Delay elements for each section
    reg signed [4*WORD_WIDTH-1:0] w1[0:MAX_SECTIONS-1];
    reg signed [4*WORD_WIDTH-1:0] w2[0:MAX_SECTIONS-1];
    
    // File handles
    integer sos_file, g_file;
    integer sig_file, out_file;
    
    // Variables for parsing
    integer i, j, k, section_count;
    real float_val;
    
    // Variables for filter implementation
    reg signed [4*WORD_WIDTH-1:0] section_input, section_output;
    reg signed [4*WORD_WIDTH-1:0] w0_temp, y_temp, gain_output;
    reg signed [4*WORD_WIDTH-1:0] w0;
    reg signed [WORD_WIDTH-1:0] b0, b1, b2, a1, a2;

    // Main simulation
    initial begin
        // 1. Read SOS coefficients
        sos_file = $fopen("SOS.txt", "r");
        if (sos_file == 0) begin
            $display("Error: Could not open SOS.txt");
            $finish;
        end
        
        section_count = 0;
        while (!$feof(sos_file) && section_count < MAX_SECTIONS) begin
            for (j = 0; j < 6; j = j + 1) begin
                // Convert floating point to fixed point
                if ($fscanf(sos_file, "%b", float_val) == 1)
                    sos[section_count][j] = float_val;
            end
            section_count = section_count + 1;
        end
        $fclose(sos_file);
        $display("Read %d sections from SOS.txt", section_count);
        
        // 2. Read gain values (per section)
        g_file = $fopen("G.txt", "r");
        if (g_file == 0) begin
            $display("Error: Could not open G.txt");
            $finish;
        end
        
        for (i = 0; i < section_count; i = i + 1) begin
            if ($fscanf(g_file, "%b", float_val) == 1)begin
                g[i] = float_val;
            end
        end
        $fclose(g_file);
        $display("Read %d gain values from G.txt", i);
        
        // 3. Read input signal
        sig_file = $fopen("signal1_fixed.txt", "r");
        if (sig_file == 0) begin
            $display("Error: Could not open signal1_fixed.txt");
            $finish;
        end
        for (i = 0; i < SAMPLES; i = i + 1) begin
            if ($fscanf(sig_file, "%b", float_val) == 1)
                signal[i] = float_val;
        end
        $fclose(sig_file);
        $display("Read input signal");
        
        // 4. Filter the signal
        // Initialize delay elements
        for (i = 0; i < section_count; i = i + 1) begin
            w1[i] = 0;
            w2[i] = 0;
        end
        
        // Process each sample
        for (k = 0; k < SAMPLES; k = k + 1) begin
            section_input = signal[k];
            
            // Pass through each section
            for (i = 0; i < section_count; i = i + 1) begin
                // Get coefficients for current section
                b0 = sos[i][0];
                b1 = sos[i][1]; 
                b2 = sos[i][2];
                a1 = sos[i][4]; // Note: a0=1 is assumed, a1 is at index 4
                a2 = sos[i][5];
                
                // Direct Form II implementation
                // w0 = x - a1*w1 - a2*w2
                w0_temp = (section_input) - 
                         (($signed(a1) * $signed(w1[i])) >>> FRAC_WIDTH) - 
                         (($signed(a2) * $signed(w2[i])) >>> FRAC_WIDTH);
                w0 = w0_temp ;
                
                // y = b0*w0 + b1*w1 + b2*w2
                y_temp = (($signed(b0) * $signed(w0)) >>> FRAC_WIDTH) + 
                        (($signed(b1) * $signed(w1[i])) >>> FRAC_WIDTH) + 
                        (($signed(b2) * $signed(w2[i])) >>> FRAC_WIDTH);
                
                // Apply per-section gain
                gain_output = (($signed(y_temp) * $signed(g[i])) >>> FRAC_WIDTH);
                
                // Update delay elements
                w2[i] = w1[i];
                w1[i] = w0;
                
                // Output of this section becomes input to next section
                section_output = gain_output[4*WORD_WIDTH-1:0];
                section_input = section_output;
            end
            
            filtered[k] = section_output[WORD_WIDTH-1:0];
        end
        $display("Filtering complete");
        
        // 5. Write filtered output to file
        out_file = $fopen("verilog_filtered_signal1.txt", "w");
        if (out_file == 0) begin
            $display("Error: Could not open output file");
            $finish;
        end
        for (i = 0; i < SAMPLES; i = i + 1) begin
            $fdisplay(out_file, "%f", $itor(filtered[i]) / (1 << FRAC_WIDTH));
        end
        $fclose(out_file);
        
        $display("Filtering complete. Output file created.");
        $finish;
    end

endmodule