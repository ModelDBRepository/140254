/*
 * This model includes a transient (fast) sodium channel, and two potassium
 * channels: a delayed rectifier (Kv3.1-3.2) and the d-type potassium current
 * with fast activation and slow inactivation.
 * The conductances were taken from:
 *      Golomb, Donner, Shacham, Shlosberg, Amitai Y, et al. (2007)
 *      Mechanisms of Firing Patterns in Fast-Spiking Cortical Interneurons.
 *      PLoS Comput Biol 3(8): e156. doi:10.1371/journal.pcbi.0030156.
 */

include ./channels/NaT_chan
include ./channels/Kdr_chan
include ./channels/Kd_chan

include ./channels/ampa_channel
include ./channels/gaba_channel

