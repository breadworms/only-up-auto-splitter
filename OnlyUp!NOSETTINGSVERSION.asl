/*
 * NO SETTINGS VERSION by breadworms
 *
 * This is a modified version of the original script that is identical
 * in execution but removes all settings and is manually maintained by
 * me instead.
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
	double velocX  : 0x07356580, 0x0, 0x30, 0xA8, 0x50, 0xAB8, 0x20, 0x320, 0xB8;
	double velocY  : 0x07356580, 0x0, 0x30, 0xA8, 0x50, 0xAB8, 0x20, 0x320, 0xC0;
}

startup
{
	// central point coords x/y/z and radius for each sphere
	vars.splits = new double[][] {
		new double[] { 2433.23, 5994.06, 1943.62, 106 }, // Pipes
		new double[] { 3537.17, 17051.4, 9916.54, 1600 }, // Train station
		new double[] { -2794.33, 11254.3, 50514.1, 306 }, // Drone
		new double[] { 4235.71, 12152.4, 90037.1, 105 }, // Elevator
		new double[] { 1064.72, 3701.3, 156054, 453 }, // Hand
		new double[] { -12363.2, 21183.6, 189660, 984 }, // Ship
	};
	vars.currSplit = 0;

	Func<double, double, double, double, double, double, double> GetDistance = (x1, y1, z1, x2, y2, z2) => {
		double dx = x2 - x1;
		double dy = y2 - y1;
		double dz = z2 - z1;

		return Math.Sqrt(dx * dx + dy * dy + dz * dz);
	};
	vars.GetDistance = GetDistance;

	timer.OnUndoSplit += (s, e) => {
		if (vars.currSplit > 0)
			vars.currSplit--;
	};
	timer.OnSkipSplit += (s, e) => {
		if (vars.currSplit < vars.splits.Length)
			vars.currSplit++;
	};

	refreshRate = 30;
}

init
{
	vars.softReset = false;

	// Endgame cutscene start detection
	IntPtr DisableInputPtr = modules.First().BaseAddress + 0x191FE80;
	if (game != null && memory.ReadValue<ulong>(DisableInputPtr) == 0x74894810245C8948) // Check we're at the right place
	{
		vars.endSeqPtr = game.AllocateMemory(4+6+15+14);
		vars.injCodePtr = vars.endSeqPtr + 4;

		List<byte> codetoinj = new List<byte>();
		byte[] incSeq = { 0xFF, 0x05, 0xF6, 0xFF, 0xFF, 0xFF };
		codetoinj.AddRange(incSeq);
		codetoinj.AddRange(memory.ReadBytes((IntPtr)(modules.First().BaseAddress + 0x191FE80), 0xF));
		byte[] jmpback = { 0xFF, 0x25, 0, 0, 0, 0 };  // jmp DisableInput+0xF
		codetoinj.AddRange(jmpback);
		codetoinj.AddRange(BitConverter.GetBytes((long)(DisableInputPtr+0xF)));
		memory.WriteBytes((IntPtr)vars.injCodePtr, codetoinj.ToArray());

		byte[] overwrjmp = { 0xFF, 0x25, 0, 0, 0, 0 };  // jmp to injected code
		memory.WriteBytes((IntPtr)(modules.First().BaseAddress + 0x191FE80), overwrjmp);
		memory.WriteBytes((IntPtr)(modules.First().BaseAddress + 0x191FE86), BitConverter.GetBytes((long)vars.injCodePtr));
		memory.WriteValue<byte>((IntPtr)(modules.First().BaseAddress + 0x191FE86 + 8), 0x90); // add a nop in that 1 byte gap

		vars.sigPtr = IntPtr.Zero;
	}
}

update
{
	if (vars.sigPtr != IntPtr.Zero)
	{
		if (memory.ReadValue<ulong>((IntPtr)vars.sigPtr) == 0x10002080C21)
		{
			return true;
		}
		else
		{
			vars.sigPtr = IntPtr.Zero;    // sig lost
		}
	}

	if (current.coordX == 0 && current.coordY == 0 && current.coordZ == 0)
	{
		vars.softReset = true;
		return false;
	}
	else if (vars.sigPtr == IntPtr.Zero) // Game running, initialize sig
	{
		IntPtr sig;
		new DeepPointer(0x073C5ED8, 0x180, 0xA0, 0x98, 0xA8, 0x60, 0x328, 0x188).DerefOffsets(game, out sig);
		vars.sigPtr = sig;
	}
}

reset
{
	if (vars.softReset && current.velocX == 0 && current.velocY == 0)
	{
		vars.softReset = false;
		return true;
	}
}

start
{
	if (current.velocX != 0 || current.velocY != 0)
	{
		vars.softReset = false;
		return true;
	}
}

split
{
	if (vars.currSplit < vars.splits.Length)
	{
		var seg = vars.splits[vars.currSplit];

		double dist = vars.GetDistance(current.coordX, current.coordY, current.coordZ, seg[0], seg[1], seg[2]);
		double radius = seg[3];

		if (dist <= radius)
			return true;
	}
	else if (memory.ReadValue<int>((IntPtr)vars.endSeqPtr) > 0) // End Split
	{
		memory.WriteValue<int>((IntPtr)vars.endSeqPtr, 0); // Reset flag for next time
		return true;
	}
}

onSplit
{
	if (vars.currSplit < vars.splits.Length)
		vars.currSplit++;
}

onReset
{
	vars.currSplit = 0;
}

shutdown
{
	if (game != null) // Remove our hook and free mem
	{
		var origcode = memory.ReadBytes((IntPtr)(vars.injCodePtr + 6), 0xF);
		memory.WriteBytes((IntPtr)(modules.First().BaseAddress + 0x191FE80), origcode);
		memory.FreeMemory((IntPtr)vars.endSeqPtr);
	}
}
