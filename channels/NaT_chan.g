/**
 * Activation
 */
function NaT_minf(Vm)
    float Vm
    float v = 1.0e3 * {Vm} /* Volt to Millivolt. */
    return {1.0 / {1.0 + {exp {{{-22.0} - {v}} / {11.5}}}}}
end

/**
 * Inactivation.
 */
function NaT_hinf(Vm)
    float Vm
    float v = 1.0e3 * {Vm} /* Volt to Millivolt. */
    return {1.0 / {1.0 + {exp {{{-58.3} - {v}} / {-6.7}}}}}
end

function NaT_tauh(Vm)
    float Vm
    float v = 1.0e3 * {Vm} /* Volt to Millivolt. */
    float tauh
    tauh = 0.5 + 14.0 / {1.0 + {exp {{{-60.0} - {v}} / {-12.0}}}}
    return {1.0e-3 * {tauh}}
end

function make_NaT_chan

    str path = "NaT_chan"
    float Erev = 0.050  /* reversal potential of sodium */

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
        setfield {path} X_A->table[{i}] {NaT_minf   {{xmin} + {i * {step}}}}
        setfield {path} X_B->table[{i}] {1.0}
        setfield {path} Y_A->table[{i}] {NaT_tauh   {{xmin} + {i * {step}}}}
        setfield {path} Y_B->table[{i}] {NaT_hinf   {{xmin} + {i * {step}}}}
    end

    /* Set X to instant: m_inf = A/B. */
    setfield {path} Ek {Erev} Xpower 3 Ypower 1 instant {INSTANTX}

    /* Calculate alpha (A), and alpha + beta (B). */
    tweaktau {path} Y

    call {path} TABFILL X 3000 0
    call {path} TABFILL Y 3000 0

    setfield {path} X_A->calc_mode 0 X_B->calc_mode 0
    setfield {path} Y_A->calc_mode 0 Y_B->calc_mode 0
end

