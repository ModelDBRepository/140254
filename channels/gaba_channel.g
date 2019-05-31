/* 
 * interneuron simulation
 * Copyright (C) 2000 Rory Kirchner (rory@mail.csh.rit.edu)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA
 *
 */

function make_GABA_channel

   str chanpath = "GABA_channel"
// cf Bartos et al 2001, Dunning et al 1999, Ling et al 1998
//adjust to Avramas data instead
//   float tau1 = 2e-3
//   float tau2 = 6e-3
   float tau1 = 1.33e-3
   float tau2 = 4e-3
//was 2 and 6e-3 before

   float gmax = 0.0
   float Ek = -0.060

   create synchan {chanpath}

   setfield {chanpath} tau1 {tau1} tau2 {tau2} gmax {gmax} Ek {Ek}

end


