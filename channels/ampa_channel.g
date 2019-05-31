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

function make_AMPA_channel

   str chanpath = "AMPA_channel"
//see e.g  Gotz T, et al, 1997
// here adjusted to Avramas data
// float tau1 = 1e-3   
    float tau1 = 0.67e-3

// from Gotz et al, and Angulo et al 1997
// here adjusted to Avramas data instead
//  float tau2 = 3e-3 
  float tau2 = 2e-3 
   //was 1 and 3e-3 before 

   float gmax = 0.0
   float Ek = 0.0

   create synchan {chanpath}

   setfield {chanpath} tau1 {tau1} tau2 {tau2} gmax {gmax} Ek {Ek}

end


















