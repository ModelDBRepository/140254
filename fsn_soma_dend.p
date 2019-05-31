*relative
*cartesian
*asymmetric
*lambda_warn

*set_compt_param RM 1.2    // Ohm*m^2
*set_compt_param CM 0.007  // F/m^2
*set_compt_param RA 2.0    // Ohm*m
*set_compt_param EREST_ACT -0.065
*set_compt_param ELEAK     -0.065

*start_cell /library/tert_dend
   tert_dend   none  30    0    0    0.50  AMPA_channel  -1.0e-12
   tert_dend2  .     30    0    0    0.50  AMPA_channel  -1.0e-12
   tert_dend3  .     30    0    0    0.50  AMPA_channel  -1.0e-12
   tert_dend4  .     30    0    0    0.50  AMPA_channel  -1.0e-12
   tert_dend5  .     30    0    0    0.50  AMPA_channel  -1.0e-12
   tert_dend6  .     30    0    0    0.50  AMPA_channel  -1.0e-12
   tert_dend7  .     30    0    0    0.50  AMPA_channel  -1.0e-12
   tert_dend8  .     30    0    0    0.50  AMPA_channel  -1.0e-12
*makeproto /library/tert_dend

*start_cell /library/sec_dend
   sec_dend    none  37    0    0    0.75  AMPA_channel  -1.0e-12  GABA_channel -1.0e-12
   sec_dend2   .     37    0    0    0.75  AMPA_channel  -1.0e-12  GABA_channel -1.0e-12
   sec_dend3   .     37    0    0    0.75  AMPA_channel  -1.0e-12  GABA_channel -1.0e-12
   sec_dend4   .     37    0    0    0.75  AMPA_channel  -1.0e-12  GABA_channel -1.0e-12
*makeproto /library/sec_dend

*start_cell /library/prim_dend
   prim_dend   none  45    0    0    1.00  NaT_chan        225.0   Kdr_chan 450.0  Kd_chan 1.6  \
                                           AMPA_channel -1.0e-12   GABA_channel -1.0e-12
   prim_dend2  .     45    0    0    1.00  NaT_chan        225.0   Kdr_chan 450.0  Kd_chan 1.6  \
                                           AMPA_channel -1.0e-12   GABA_channel -1.0e-12
*makeproto /library/prim_dend

*start_cell 
  soma   none  15  0  0 15  NaT_chan         2250.0  Kdr_chan 4500.0  Kd_chan 16.0  \
                            AMPA_channel   -1.0e-12  GABA_channel   -1.0e-12

*compt /library/prim_dend
primdend1   soma                  45    0    0    1.0
primdend2   soma                  45    0    0    1.0
primdend3   soma                  45    0    0    1.0
 
*compt /library/sec_dend
secdend1    primdend1/prim_dend2  37    0    0    0.75
secdend2    primdend1/prim_dend2  37    0    0    0.75
secdend3    primdend2/prim_dend2  37    0    0    0.75 
secdend4    primdend2/prim_dend2  37    0    0    0.75
secdend5    primdend3/prim_dend2  37    0    0    0.75
secdend6    primdend3/prim_dend2  37    0    0    0.75

*compt /library/tert_dend
tertdend1   secdend1/sec_dend4    30    0    0    0.5 
tertdend2   secdend1/sec_dend4    30    0    0    0.5 
tertdend3   secdend2/sec_dend4    30    0    0    0.5 
tertdend4   secdend2/sec_dend4    30    0    0    0.5 
tertdend5   secdend3/sec_dend4    30    0    0    0.5 
tertdend6   secdend3/sec_dend4    30    0    0    0.5 
tertdend7   secdend4/sec_dend4    30    0    0    0.5
tertdend8   secdend4/sec_dend4    30    0    0    0.5
tertdend9   secdend5/sec_dend4    30    0    0    0.5 
tertdend10  secdend5/sec_dend4    30    0    0    0.5 
tertdend11  secdend6/sec_dend4    30    0    0    0.5
tertdend12  secdend6/sec_dend4    30    0    0    0.5
