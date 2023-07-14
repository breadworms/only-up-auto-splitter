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
		new double[] { 2357.19, 6094.68, 2026.14, 190*190 }, // Pipes
		new double[] { 3537.17, 17051.4, 9916.54, 1600*1600 }, // Train station
		new double[] { -2794.33, 11254.3, 50514.1, 306*306 }, // Drone
		new double[] { 4235.71, 12152.4, 90037.1, 105*105 }, // Elevator
		new double[] { 1064.72, 3701.3, 156054, 453*453 }, // Hand
		new double[] { -12363.2, 21183.6, 189660, 984*984 }, // Ship
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
