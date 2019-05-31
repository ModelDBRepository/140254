/**
 * Activation
 */
function Kd_ainf(Vm)
    float Vm
    float v = 1.0e3 * {Vm} /* Volt to Millivolt. */
    return {1.0 / {1.0 + {exp {{{-50.0} - {v}} / {20.0}}}}}
end

/**
 * Inactivation.
 */
function Kd_binf(Vm)
    float Vm
    float v = 1.0e3 * {Vm} /* Volt to Millivolt. */
    return {1.0 / {1.0 + {exp {{{-70.0} - {v}} / {-6.0}}}}}
end

function make_Kd_chan

    str path = "Kd_chan"
    float Erev = -0.090  /* reversal potential of sodium */

    float xmin = -0.100   /* minimum voltage we will see in the simulation */
    float xmax =  0.050   /* maximum voltage we will see in the simulation */
    float step =  0.005   /* use a 5mV step size */
    int xdivs  =  30      /* the number of divisions between -0.1 and 0.05 */
    int i

    create tabchannel {path}

    /* make the table for the activation with a range of -100mV - +50mV
     * with an entry for ever 5mV
     */
    call {path} TABCREATE X {xdivs} {xmin} {xmax}
    call {path} TABCREATE Y {xdivs} {xmin} {xmax}

    /* set the tau and m_inf for the activation and inactivation */
    for(i = 0; i < {xdivs} + 1; i = i + 1)
        setfield {path} X_A->table[{i}] {0.002}
        setfield {path} X_B->table[{i}] {Kd_ainf   {{xmin} + {i * {step}}}}
        setfield {path} Y_A->table[{i}] {0.150}
        setfield {path} Y_B->table[{i}] {Kd_binf   {{xmin} + {i * {step}}}}
    end

    setfield {path} Ek {Erev} Xpower 3 Ypower 1

    tweaktau {path} X
    tweaktau {path} Y

    call {path} TABFILL X 3000 0
    call {path} TABFILL Y 3000 0

    setfield {path} X_A->calc_mode 0 X_B->calc_mode 0
    setfield {path} Y_A->calc_mode 0 Y_B->calc_mode 0
end

