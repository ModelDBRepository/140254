/**
 * Activation.
 */
function Kdr_ninf(Vm)
    float Vm
    float v = 1.0e3 * {Vm} /* Volt to Millivolt. */
    float ninf
    ninf = 1.0 / {1.0 + {exp {{{-12.4} - {v}} / {6.8}}}}
    return ninf
end

function Kdr_taun(Vm)
    float Vm
    float v = 1.0e3 * {Vm} /* Volt to Millivolt. */
    float taun
    taun = {1}*{0.087 + 11.4 / {1.0 + {exp {{{-14.6} - {v}} / {-8.6}}}}} * \
           {0.087 + 11.4 / {1.0 + {exp {{{  1.3} - {v}} / {18.7}}}}}
    return {1.0e-3 * {taun}}
end

function make_Kdr_chan

    str path = "Kdr_chan"
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
        setfield {path} X_A->table[{i}] {Kdr_taun   {{xmin} + {i * {step}}}}
        setfield {path} X_B->table[{i}] {Kdr_ninf   {{xmin} + {i * {step}}}}
    end

    setfield {path} Ek {Erev} Xpower 2

    tweaktau {path} X

    call {path} TABFILL X 3000 0 
    call {path} TABFILL Y 3000 0

    setfield {path} X_A->calc_mode 0 X_B->calc_mode 0
    setfield {path} Y_A->calc_mode 0 Y_B->calc_mode 0
end

