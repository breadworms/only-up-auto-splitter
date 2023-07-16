/*
 * This is a modified version of the original script that is identical
 * in execution but removes all user settings and is manually
 * maintained by me instead.
 *
 *
 * Only Up! Autosplitter
 *
 * Made by/with the help of:
 *  - wRadion
 *  - MkLoM
 *  - traumvogel
 *  - t0mz3r
 *  - NeKRooZz
 *
 * https://github.com/Edgarflc/autosplitter_only_up
 *
 * MIT License
 *
 * Copyright (c) 2023 Edgarflc
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

state("OnlyUP-Win64-Shipping")    // pointer paths
{
	double coordX  : 0x073C5ED8, 0x180, 0xA0, 0x98, 0xA8, 0x60, 0x328, 0x260;
	double coordY  : 0x073C5ED8, 0x180, 0xA0, 0x98, 0xA8, 0x60, 0x328, 0x268;
	double coordZ  : 0x073C5ED8, 0x180, 0xA0, 0x98, 0xA8, 0x60, 0x328, 0x270;
	ulong GObjects : 0x07356580, 0x0, 0x30, 0xA8, 0x50, 0xAB8, 0x20, 0x0;
	bool bIsMoving : 0x07356580, 0x0, 0x30, 0xA8, 0x50, 0xAB8, 0x20, 0x678;
	bool bLocView  : 0x07356580, 0x0, 0x30, 0xA8, 0x50, 0xAB8, 0x20, 0x298;
}

startup
{
	// central point coords x/y/z and radius for each sphere
	vars.splits = new double[][] {
		//new double[] { 1675.95, 4147.05, -3111.73, 132*132 }, // Favelas Elevator
		//new double[] { 2357.19, 6094.68, 2026.14, 190*190 }, // Pipe Maze Start
		new double[] { 3537.17, 17051.4, 9916.54, 1600*1600 }, // Train Station
		//new double[] { 4276.85, 13362.6, 9386.93, 313*313 }, // Rails Start
		new double[] { 4623.09, 4867.59, 33884.4, 170*170 }, // Oil Refinery
		//new double[] { 1140.69, 5483.92, 43327.6, 250*250 }, // Factory
		//new double[] { 2257.24, 18548.2, 48138.5, 1254*1254 }, // Subway
		new double[] { -2794.33, 11254.3, 50514.1, 306*306 }, // Drone
		//new double[] { 5434.17, 8707.72, 83707.9, 814*814 }, // Highway
		new double[] { 4235.71, 12152.4, 90037.1, 105*105 }, // Elevator
		//new double[] { 2936, 8172.93, 105057, 2921*2921 }, // Fake Winner Platform
		//new double[] { 3094.08, 8919.15, 105688, 462*462 }, // Elevator to Heaven
		//new double[] { -417.533, 15277.4, 138394, 1101*1101 }, // Heaven
		new double[] { 1064.72, 3701.3, 156054, 453*453 }, // Hand
		//new double[] { -1537.41, 3881.58, 171863, 1392*1392 }, // After Chess
		new double[] { -12363.2, 21183.6, 189660, 984*984 }, // Ship
		//new double[] { -1209.93, 9218.39, 198943, 50*50 }, // Cannon
		//new double[] { 1005.6, 24691.5, 244610, 97*97 }, // Golden Apple Elevator
		//new double[] { 2279.77, 18551, 260399, 291*291 }, // Dragon Maze
		//new double[] { -2243.08, 9062.34, 270368, 120*120 }, // Hoverboard
		//new double[] { 1353.83, 15993, 283501, 3000*3000 }, // Space Start
		//new double[] { 2380.47, 16558.2, 283679, 295*295 }, // Space First Bumper
	};

	refreshRate = 30;
}

init
{
	vars.softReset = false;
}

update
{
	if (current.GObjects == 0)
	{
		vars.softReset = true;
		return false;
	}
}

reset
{
	if (vars.softReset && !current.bIsMoving)
	{
		vars.softReset = false;
		return true;
	}
}

start
{
	if (current.bIsMoving)
	{
		vars.softReset = false;
		return true;
	}
}

split
{
	if (timer.CurrentSplitIndex < vars.splits.Length)
	{
		var seg = vars.splits[timer.CurrentSplitIndex];

		double dx = current.coordX - seg[0];
		double dy = current.coordY - seg[1];
		double dz = current.coordZ - seg[2];

		if (dx * dx + dy * dy + dz * dz <= seg[3])
			return true;
	}
	else if (!current.bLocView) // End Split
		return true;
}
