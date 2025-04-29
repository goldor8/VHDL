-- Définition du process permettant de faire évoluer les signaux d'entrée du composant à tester	
MyStimulus_Proc2 : process -- pas de liste de sensibilité 	
begin
    
    for i in 0 to (2**N)-1 loop	
        for j in 0 to (2**N)-1 loop
            for k in 0 to 1 loop
                c_in_sim <= to_unsigned(k,1)(0); 
                e1_sim <= std_logic_vector(to_unsigned(i,N));
                e2_sim <= std_logic_vector(to_unsigned(j,N));
                wait for 100 us;
                report "c_in=" & integer'image(k) & " | e1=" & integer'image(i) & " | e2=" & integer'image(j) & " || s1 = " & integer'image(to_integer(unsigned(s1_sim))) & " | c_out=" & std_logic'image(c_out_sim);
                assert s1_sim = (e1_sim + e2_sim + c_in_sim) report "Failure" severity failure;
            end loop;
        end loop;
    end loop;        
    report "Test ok (no assert...)";
    wait;
end process;