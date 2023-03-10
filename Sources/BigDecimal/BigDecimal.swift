//
//  BigDecimal.swift
//  BigDecimal
//
//  Created by Leif Ibsen on 10/11/2022.
//

import Foundation
import BigInt

precedencegroup ExponentiationPrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
    lowerThan: BitwiseShiftPrecedence
}

infix operator ** : ExponentiationPrecedence

/// A signed decimal value of unbounded precision.
/// A BigDecimal value is represented as a signed *BInt* significand and a signed *Int* exponent.
/// The value of a BigDecimal is *significand* \* 10^*exponent*</br>
/// There are three special BigDecimal values: *NaN* designating Not a Number,</br>
/// *InfinityP* deignating +Infinity and *InfinityN* designating -Infinity.
public struct BigDecimal: LosslessStringConvertible, Comparable, Equatable, Hashable {
    
    // Conversion table from 3 decimal digits to 10 bits
    static let encodeDPD = [
        0x000, 0x001, 0x002, 0x003, 0x004, 0x005, 0x006, 0x007, 0x008, 0x009,
        0x010, 0x011, 0x012, 0x013, 0x014, 0x015, 0x016, 0x017, 0x018, 0x019,
        0x020, 0x021, 0x022, 0x023, 0x024, 0x025, 0x026, 0x027, 0x028, 0x029,
        0x030, 0x031, 0x032, 0x033, 0x034, 0x035, 0x036, 0x037, 0x038, 0x039,
        0x040, 0x041, 0x042, 0x043, 0x044, 0x045, 0x046, 0x047, 0x048, 0x049,
        0x050, 0x051, 0x052, 0x053, 0x054, 0x055, 0x056, 0x057, 0x058, 0x059,
        0x060, 0x061, 0x062, 0x063, 0x064, 0x065, 0x066, 0x067, 0x068, 0x069,
        0x070, 0x071, 0x072, 0x073, 0x074, 0x075, 0x076, 0x077, 0x078, 0x079,
        0x00a, 0x00b, 0x02a, 0x02b, 0x04a, 0x04b, 0x06a, 0x06b, 0x04e, 0x04f,
        0x01a, 0x01b, 0x03a, 0x03b, 0x05a, 0x05b, 0x07a, 0x07b, 0x05e, 0x05f,
        0x080, 0x081, 0x082, 0x083, 0x084, 0x085, 0x086, 0x087, 0x088, 0x089,
        0x090, 0x091, 0x092, 0x093, 0x094, 0x095, 0x096, 0x097, 0x098, 0x099,
        0x0a0, 0x0a1, 0x0a2, 0x0a3, 0x0a4, 0x0a5, 0x0a6, 0x0a7, 0x0a8, 0x0a9,
        0x0b0, 0x0b1, 0x0b2, 0x0b3, 0x0b4, 0x0b5, 0x0b6, 0x0b7, 0x0b8, 0x0b9,
        0x0c0, 0x0c1, 0x0c2, 0x0c3, 0x0c4, 0x0c5, 0x0c6, 0x0c7, 0x0c8, 0x0c9,
        0x0d0, 0x0d1, 0x0d2, 0x0d3, 0x0d4, 0x0d5, 0x0d6, 0x0d7, 0x0d8, 0x0d9,
        0x0e0, 0x0e1, 0x0e2, 0x0e3, 0x0e4, 0x0e5, 0x0e6, 0x0e7, 0x0e8, 0x0e9,
        0x0f0, 0x0f1, 0x0f2, 0x0f3, 0x0f4, 0x0f5, 0x0f6, 0x0f7, 0x0f8, 0x0f9,
        0x08a, 0x08b, 0x0aa, 0x0ab, 0x0ca, 0x0cb, 0x0ea, 0x0eb, 0x0ce, 0x0cf,
        0x09a, 0x09b, 0x0ba, 0x0bb, 0x0da, 0x0db, 0x0fa, 0x0fb, 0x0de, 0x0df,
        0x100, 0x101, 0x102, 0x103, 0x104, 0x105, 0x106, 0x107, 0x108, 0x109,
        0x110, 0x111, 0x112, 0x113, 0x114, 0x115, 0x116, 0x117, 0x118, 0x119,
        0x120, 0x121, 0x122, 0x123, 0x124, 0x125, 0x126, 0x127, 0x128, 0x129,
        0x130, 0x131, 0x132, 0x133, 0x134, 0x135, 0x136, 0x137, 0x138, 0x139,
        0x140, 0x141, 0x142, 0x143, 0x144, 0x145, 0x146, 0x147, 0x148, 0x149,
        0x150, 0x151, 0x152, 0x153, 0x154, 0x155, 0x156, 0x157, 0x158, 0x159,
        0x160, 0x161, 0x162, 0x163, 0x164, 0x165, 0x166, 0x167, 0x168, 0x169,
        0x170, 0x171, 0x172, 0x173, 0x174, 0x175, 0x176, 0x177, 0x178, 0x179,
        0x10a, 0x10b, 0x12a, 0x12b, 0x14a, 0x14b, 0x16a, 0x16b, 0x14e, 0x14f,
        0x11a, 0x11b, 0x13a, 0x13b, 0x15a, 0x15b, 0x17a, 0x17b, 0x15e, 0x15f,
        0x180, 0x181, 0x182, 0x183, 0x184, 0x185, 0x186, 0x187, 0x188, 0x189,
        0x190, 0x191, 0x192, 0x193, 0x194, 0x195, 0x196, 0x197, 0x198, 0x199,
        0x1a0, 0x1a1, 0x1a2, 0x1a3, 0x1a4, 0x1a5, 0x1a6, 0x1a7, 0x1a8, 0x1a9,
        0x1b0, 0x1b1, 0x1b2, 0x1b3, 0x1b4, 0x1b5, 0x1b6, 0x1b7, 0x1b8, 0x1b9,
        0x1c0, 0x1c1, 0x1c2, 0x1c3, 0x1c4, 0x1c5, 0x1c6, 0x1c7, 0x1c8, 0x1c9,
        0x1d0, 0x1d1, 0x1d2, 0x1d3, 0x1d4, 0x1d5, 0x1d6, 0x1d7, 0x1d8, 0x1d9,
        0x1e0, 0x1e1, 0x1e2, 0x1e3, 0x1e4, 0x1e5, 0x1e6, 0x1e7, 0x1e8, 0x1e9,
        0x1f0, 0x1f1, 0x1f2, 0x1f3, 0x1f4, 0x1f5, 0x1f6, 0x1f7, 0x1f8, 0x1f9,
        0x18a, 0x18b, 0x1aa, 0x1ab, 0x1ca, 0x1cb, 0x1ea, 0x1eb, 0x1ce, 0x1cf,
        0x19a, 0x19b, 0x1ba, 0x1bb, 0x1da, 0x1db, 0x1fa, 0x1fb, 0x1de, 0x1df,
        0x200, 0x201, 0x202, 0x203, 0x204, 0x205, 0x206, 0x207, 0x208, 0x209,
        0x210, 0x211, 0x212, 0x213, 0x214, 0x215, 0x216, 0x217, 0x218, 0x219,
        0x220, 0x221, 0x222, 0x223, 0x224, 0x225, 0x226, 0x227, 0x228, 0x229,
        0x230, 0x231, 0x232, 0x233, 0x234, 0x235, 0x236, 0x237, 0x238, 0x239,
        0x240, 0x241, 0x242, 0x243, 0x244, 0x245, 0x246, 0x247, 0x248, 0x249,
        0x250, 0x251, 0x252, 0x253, 0x254, 0x255, 0x256, 0x257, 0x258, 0x259,
        0x260, 0x261, 0x262, 0x263, 0x264, 0x265, 0x266, 0x267, 0x268, 0x269,
        0x270, 0x271, 0x272, 0x273, 0x274, 0x275, 0x276, 0x277, 0x278, 0x279,
        0x20a, 0x20b, 0x22a, 0x22b, 0x24a, 0x24b, 0x26a, 0x26b, 0x24e, 0x24f,
        0x21a, 0x21b, 0x23a, 0x23b, 0x25a, 0x25b, 0x27a, 0x27b, 0x25e, 0x25f,
        0x280, 0x281, 0x282, 0x283, 0x284, 0x285, 0x286, 0x287, 0x288, 0x289,
        0x290, 0x291, 0x292, 0x293, 0x294, 0x295, 0x296, 0x297, 0x298, 0x299,
        0x2a0, 0x2a1, 0x2a2, 0x2a3, 0x2a4, 0x2a5, 0x2a6, 0x2a7, 0x2a8, 0x2a9,
        0x2b0, 0x2b1, 0x2b2, 0x2b3, 0x2b4, 0x2b5, 0x2b6, 0x2b7, 0x2b8, 0x2b9,
        0x2c0, 0x2c1, 0x2c2, 0x2c3, 0x2c4, 0x2c5, 0x2c6, 0x2c7, 0x2c8, 0x2c9,
        0x2d0, 0x2d1, 0x2d2, 0x2d3, 0x2d4, 0x2d5, 0x2d6, 0x2d7, 0x2d8, 0x2d9,
        0x2e0, 0x2e1, 0x2e2, 0x2e3, 0x2e4, 0x2e5, 0x2e6, 0x2e7, 0x2e8, 0x2e9,
        0x2f0, 0x2f1, 0x2f2, 0x2f3, 0x2f4, 0x2f5, 0x2f6, 0x2f7, 0x2f8, 0x2f9,
        0x28a, 0x28b, 0x2aa, 0x2ab, 0x2ca, 0x2cb, 0x2ea, 0x2eb, 0x2ce, 0x2cf,
        0x29a, 0x29b, 0x2ba, 0x2bb, 0x2da, 0x2db, 0x2fa, 0x2fb, 0x2de, 0x2df,
        0x300, 0x301, 0x302, 0x303, 0x304, 0x305, 0x306, 0x307, 0x308, 0x309,
        0x310, 0x311, 0x312, 0x313, 0x314, 0x315, 0x316, 0x317, 0x318, 0x319,
        0x320, 0x321, 0x322, 0x323, 0x324, 0x325, 0x326, 0x327, 0x328, 0x329,
        0x330, 0x331, 0x332, 0x333, 0x334, 0x335, 0x336, 0x337, 0x338, 0x339,
        0x340, 0x341, 0x342, 0x343, 0x344, 0x345, 0x346, 0x347, 0x348, 0x349,
        0x350, 0x351, 0x352, 0x353, 0x354, 0x355, 0x356, 0x357, 0x358, 0x359,
        0x360, 0x361, 0x362, 0x363, 0x364, 0x365, 0x366, 0x367, 0x368, 0x369,
        0x370, 0x371, 0x372, 0x373, 0x374, 0x375, 0x376, 0x377, 0x378, 0x379,
        0x30a, 0x30b, 0x32a, 0x32b, 0x34a, 0x34b, 0x36a, 0x36b, 0x34e, 0x34f,
        0x31a, 0x31b, 0x33a, 0x33b, 0x35a, 0x35b, 0x37a, 0x37b, 0x35e, 0x35f,
        0x380, 0x381, 0x382, 0x383, 0x384, 0x385, 0x386, 0x387, 0x388, 0x389,
        0x390, 0x391, 0x392, 0x393, 0x394, 0x395, 0x396, 0x397, 0x398, 0x399,
        0x3a0, 0x3a1, 0x3a2, 0x3a3, 0x3a4, 0x3a5, 0x3a6, 0x3a7, 0x3a8, 0x3a9,
        0x3b0, 0x3b1, 0x3b2, 0x3b3, 0x3b4, 0x3b5, 0x3b6, 0x3b7, 0x3b8, 0x3b9,
        0x3c0, 0x3c1, 0x3c2, 0x3c3, 0x3c4, 0x3c5, 0x3c6, 0x3c7, 0x3c8, 0x3c9,
        0x3d0, 0x3d1, 0x3d2, 0x3d3, 0x3d4, 0x3d5, 0x3d6, 0x3d7, 0x3d8, 0x3d9,
        0x3e0, 0x3e1, 0x3e2, 0x3e3, 0x3e4, 0x3e5, 0x3e6, 0x3e7, 0x3e8, 0x3e9,
        0x3f0, 0x3f1, 0x3f2, 0x3f3, 0x3f4, 0x3f5, 0x3f6, 0x3f7, 0x3f8, 0x3f9,
        0x38a, 0x38b, 0x3aa, 0x3ab, 0x3ca, 0x3cb, 0x3ea, 0x3eb, 0x3ce, 0x3cf,
        0x39a, 0x39b, 0x3ba, 0x3bb, 0x3da, 0x3db, 0x3fa, 0x3fb, 0x3de, 0x3df,
        0x00c, 0x00d, 0x10c, 0x10d, 0x20c, 0x20d, 0x30c, 0x30d, 0x02e, 0x02f,
        0x01c, 0x01d, 0x11c, 0x11d, 0x21c, 0x21d, 0x31c, 0x31d, 0x03e, 0x03f,
        0x02c, 0x02d, 0x12c, 0x12d, 0x22c, 0x22d, 0x32c, 0x32d, 0x12e, 0x12f,
        0x03c, 0x03d, 0x13c, 0x13d, 0x23c, 0x23d, 0x33c, 0x33d, 0x13e, 0x13f,
        0x04c, 0x04d, 0x14c, 0x14d, 0x24c, 0x24d, 0x34c, 0x34d, 0x22e, 0x22f,
        0x05c, 0x05d, 0x15c, 0x15d, 0x25c, 0x25d, 0x35c, 0x35d, 0x23e, 0x23f,
        0x06c, 0x06d, 0x16c, 0x16d, 0x26c, 0x26d, 0x36c, 0x36d, 0x32e, 0x32f,
        0x07c, 0x07d, 0x17c, 0x17d, 0x27c, 0x27d, 0x37c, 0x37d, 0x33e, 0x33f,
        0x00e, 0x00f, 0x10e, 0x10f, 0x20e, 0x20f, 0x30e, 0x30f, 0x06e, 0x06f,
        0x01e, 0x01f, 0x11e, 0x11f, 0x21e, 0x21f, 0x31e, 0x31f, 0x07e, 0x07f,
        0x08c, 0x08d, 0x18c, 0x18d, 0x28c, 0x28d, 0x38c, 0x38d, 0x0ae, 0x0af,
        0x09c, 0x09d, 0x19c, 0x19d, 0x29c, 0x29d, 0x39c, 0x39d, 0x0be, 0x0bf,
        0x0ac, 0x0ad, 0x1ac, 0x1ad, 0x2ac, 0x2ad, 0x3ac, 0x3ad, 0x1ae, 0x1af,
        0x0bc, 0x0bd, 0x1bc, 0x1bd, 0x2bc, 0x2bd, 0x3bc, 0x3bd, 0x1be, 0x1bf,
        0x0cc, 0x0cd, 0x1cc, 0x1cd, 0x2cc, 0x2cd, 0x3cc, 0x3cd, 0x2ae, 0x2af,
        0x0dc, 0x0dd, 0x1dc, 0x1dd, 0x2dc, 0x2dd, 0x3dc, 0x3dd, 0x2be, 0x2bf,
        0x0ec, 0x0ed, 0x1ec, 0x1ed, 0x2ec, 0x2ed, 0x3ec, 0x3ed, 0x3ae, 0x3af,
        0x0fc, 0x0fd, 0x1fc, 0x1fd, 0x2fc, 0x2fd, 0x3fc, 0x3fd, 0x3be, 0x3bf,
        0x08e, 0x08f, 0x18e, 0x18f, 0x28e, 0x28f, 0x38e, 0x38f, 0x0ee, 0x0ef,
        0x09e, 0x09f, 0x19e, 0x19f, 0x29e, 0x29f, 0x39e, 0x39f, 0x0fe, 0x0ff]
    
    // Conversion table from 10 bits to 3 decimal digits
    static let decodeDPD = [
        000, 001, 002, 003, 004, 005, 006, 007, 008, 009, 080, 081, 800, 801, 880, 881,
        010, 011, 012, 013, 014, 015, 016, 017, 018, 019, 090, 091, 810, 811, 890, 891,
        020, 021, 022, 023, 024, 025, 026, 027, 028, 029, 082, 083, 820, 821, 808, 809,
        030, 031, 032, 033, 034, 035, 036, 037, 038, 039, 092, 093, 830, 831, 818, 819,
        040, 041, 042, 043, 044, 045, 046, 047, 048, 049, 084, 085, 840, 841, 088, 089,
        050, 051, 052, 053, 054, 055, 056, 057, 058, 059, 094, 095, 850, 851, 098, 099,
        060, 061, 062, 063, 064, 065, 066, 067, 068, 069, 086, 087, 860, 861, 888, 889,
        070, 071, 072, 073, 074, 075, 076, 077, 078, 079, 096, 097, 870, 871, 898, 899,
        100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 180, 181, 900, 901, 980, 981,
        110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 190, 191, 910, 911, 990, 991,
        120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 182, 183, 920, 921, 908, 909,
        130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 192, 193, 930, 931, 918, 919,
        140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 184, 185, 940, 941, 188, 189,
        150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 194, 195, 950, 951, 198, 199,
        160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 186, 187, 960, 961, 988, 989,
        170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 196, 197, 970, 971, 998, 999,
        200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 280, 281, 802, 803, 882, 883,
        210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 290, 291, 812, 813, 892, 893,
        220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 282, 283, 822, 823, 828, 829,
        230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 292, 293, 832, 833, 838, 839,
        240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 284, 285, 842, 843, 288, 289,
        250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 294, 295, 852, 853, 298, 299,
        260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 286, 287, 862, 863, 888, 889,
        270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 296, 297, 872, 873, 898, 899,
        300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 380, 381, 902, 903, 982, 983,
        310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 390, 391, 912, 913, 992, 993,
        320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 382, 383, 922, 923, 928, 929,
        330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 392, 393, 932, 933, 938, 939,
        340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 384, 385, 942, 943, 388, 389,
        350, 351, 352, 353, 354, 355, 356, 357, 358, 359, 394, 395, 952, 953, 398, 399,
        360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 386, 387, 962, 963, 988, 989,
        370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 396, 397, 972, 973, 998, 999,
        400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 480, 481, 804, 805, 884, 885,
        410, 411, 412, 413, 414, 415, 416, 417, 418, 419, 490, 491, 814, 815, 894, 895,
        420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 482, 483, 824, 825, 848, 849,
        430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 492, 493, 834, 835, 858, 859,
        440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 484, 485, 844, 845, 488, 489,
        450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 494, 495, 854, 855, 498, 499,
        460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 486, 487, 864, 865, 888, 889,
        470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 496, 497, 874, 875, 898, 899,
        500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 580, 581, 904, 905, 984, 985,
        510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 590, 591, 914, 915, 994, 995,
        520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 582, 583, 924, 925, 948, 949,
        530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 592, 593, 934, 935, 958, 959,
        540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 584, 585, 944, 945, 588, 589,
        550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 594, 595, 954, 955, 598, 599,
        560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 586, 587, 964, 965, 988, 989,
        570, 571, 572, 573, 574, 575, 576, 577, 578, 579, 596, 597, 974, 975, 998, 999,
        600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 680, 681, 806, 807, 886, 887,
        610, 611, 612, 613, 614, 615, 616, 617, 618, 619, 690, 691, 816, 817, 896, 897,
        620, 621, 622, 623, 624, 625, 626, 627, 628, 629, 682, 683, 826, 827, 868, 869,
        630, 631, 632, 633, 634, 635, 636, 637, 638, 639, 692, 693, 836, 837, 878, 879,
        640, 641, 642, 643, 644, 645, 646, 647, 648, 649, 684, 685, 846, 847, 688, 689,
        650, 651, 652, 653, 654, 655, 656, 657, 658, 659, 694, 695, 856, 857, 698, 699,
        660, 661, 662, 663, 664, 665, 666, 667, 668, 669, 686, 687, 866, 867, 888, 889,
        670, 671, 672, 673, 674, 675, 676, 677, 678, 679, 696, 697, 876, 877, 898, 899,
        700, 701, 702, 703, 704, 705, 706, 707, 708, 709, 780, 781, 906, 907, 986, 987,
        710, 711, 712, 713, 714, 715, 716, 717, 718, 719, 790, 791, 916, 917, 996, 997,
        720, 721, 722, 723, 724, 725, 726, 727, 728, 729, 782, 783, 926, 927, 968, 969,
        730, 731, 732, 733, 734, 735, 736, 737, 738, 739, 792, 793, 936, 937, 978, 979,
        740, 741, 742, 743, 744, 745, 746, 747, 748, 749, 784, 785, 946, 947, 788, 789,
        750, 751, 752, 753, 754, 755, 756, 757, 758, 759, 794, 795, 956, 957, 798, 799,
        760, 761, 762, 763, 764, 765, 766, 767, 768, 769, 786, 787, 966, 967, 988, 989,
        770, 771, 772, 773, 774, 775, 776, 777, 778, 779, 796, 797, 976, 977, 998, 999]
    
    // Max and min Decimal32 / 64 / 128 values
    
    static let MAXDecimal = BigDecimal(BInt([0xffffffffffffffff, 0xffffffffffffffff]), 127)
    static let MAX32 = BigDecimal(9999999, 90)
    static let MIN32 = BigDecimal(1, -101)
    static let MAX64 = BigDecimal(9999999999999999, 369)
    static let MIN64 = BigDecimal(1, -398)
    static let MAX128 = BigDecimal(BInt("9999999999999999999999999999999999")!, 6111)
    static let MIN128 = BigDecimal(1, -6176)

    /// Decimal32, Decimal64, and Decimal128 encodings
    public enum Encoding: CustomStringConvertible {

        public var description: String {
            switch self {
            case .BID:
                return "Binary Integer Decimal encoding"
            case .DPD:
                return "Densely Packed Decimal encoding"
            }
        }

        
        // MARK: Enum Values
        
        /// Binary Integer Decimal encoding
        case BID
        
        /// Densely Packed Decimal encoding
        case DPD
    }

    /// The BigDecimal display modes
    public enum DisplayMode: CustomStringConvertible {

        public var description: String {
            switch self {
            case .SCIENTIFIC:
                return "Display possibly using exponential notation"
            case .ENGINEERING:
                return "Display possibly using exponential notation - exponents divisible by 3"
            case .PLAIN:
                return "Plain display without exponential notation"
            }
        }


        // MARK: - Enum values

        /// Display value possibly using exponential notation
        case SCIENTIFIC
        
        /// Display value possibly using exponential notation - exponents divisible by 3
        case ENGINEERING
        
        /// Display value without exponential notation
        case PLAIN
    }

    static func parseString(_ s: String) -> BigDecimal {
        if s == "NaN" {
            return BigDecimal.flagNaN()
        } else if s == "+Infinity" {
            return BigDecimal.InfinityP
        } else if s == "-Infinity" {
            return BigDecimal.InfinityN
        }
        enum State {
            case start
            case inInteger
            case inFraction
            case startExponent
            case inExponent
        }
        var state: State = .start
        var digits = 0
        var expDigits = 0
        var exp = ""
        var scale = 0
        var val = ""
        var negValue = false
        var negExponent = false
        for c in s {
            switch c {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                if state == .start {
                    state = .inInteger
                    digits += 1
                    val.append(c)
                } else if state == .inInteger {
                    digits += 1
                    val.append(c)
                } else if state == .inFraction {
                    digits += 1
                    scale += 1
                    val.append(c)
                } else if state == .inExponent {
                    expDigits += 1
                    exp.append(c)
                } else if state == .startExponent {
                    state = .inExponent
                    expDigits += 1
                    exp.append(c)
                }
                break
            case ".":
                if state == .start || state == .inInteger {
                    state = .inFraction
                } else {
                    return BigDecimal.flagNaN()
                }
                break
            case "E", "e":
                if state == .inInteger || state == .inFraction {
                    state = .startExponent
                } else {
                    return BigDecimal.flagNaN()
                }
                break
            case "+":
                if state == .start {
                    state = .inInteger
                } else if state == .startExponent {
                    state = .inExponent
                } else {
                    return BigDecimal.flagNaN()
                }
                break
            case "-":
                if state == .start {
                    state = .inInteger
                    negValue = true
                } else if state == .startExponent {
                    state = .inExponent
                    negExponent = true
                } else {
                    return BigDecimal.flagNaN()
                }
                break
            default:
                return BigDecimal.flagNaN()
            }
        }
        if digits == 0 {
            return BigDecimal.flagNaN()
        }
        if (state == .startExponent || state == .inExponent) && expDigits == 0 {
            return BigDecimal.flagNaN()
        }
        let w = negValue ? -BInt(val)! : BInt(val)!
        let E = Int(exp)
        if E == nil && expDigits > 0 {
            return BigDecimal.flagNaN()
        }
        let e = expDigits == 0 ? 0 : (negExponent ? -E! : E!)
        return BigDecimal(w, e - scale)
    }
    
    static func flagNaN() -> BigDecimal {
        BigDecimal.NaNFlag = true
        return BigDecimal.NaN
    }

    
    // MARK: - Constants
    
    /// BigDecimal(0)
    public static let ZERO = BigDecimal(0)
    /// BigDecimal(1)
    public static let ONE = BigDecimal(1)
    /// BigDecimal(10)
    public static let TEN = BigDecimal(10)
    /// BigDecimal('NaN')
    public static let NaN = BigDecimal(false, false, true)
    /// BigDecimal('+Infinity')
    public static let InfinityP = BigDecimal(true, false, false)
    /// BigDecimal('-Infinity')
    public static let InfinityN = BigDecimal(false, true, false)

    
    // MARK: - Initializers

    private init(_ plusInf: Bool, _ minusInf: Bool, _ nan: Bool) {
        self.isInfinite = plusInf || minusInf
        self.isNaN = nan
        self.significand = nan ? BInt.ZERO : (plusInf ? BInt.ONE : -BInt.ONE)
        self.exponent = 0
        self.precision = 1
    }

    /// Constructs a BigDecimal from its significand and exponent
    ///
    /// - Parameters:
    ///   - significand: The significand
    ///   - exponent: The exponent, default is 0
    public init(_ significand: Int, _ exponent: Int = 0) {
        self.init(BInt(significand), exponent)
    }

    /// Constructs a BigDecimal from its significand and exponent
    ///
    /// - Parameters:
    ///   - significand: The significand
    ///   - exponent: The exponent, default is 0
    public init(_ significand: BInt, _ exponent: Int = 0) {
        self.isNaN = false
        self.isInfinite = false
        self.significand = significand
        self.exponent = exponent
        self.precision = significand.abs.asString().count
    }

    /// Constructs a BigDecimal from its String encoding - NaN if the string does not designate a decimal number
    ///
    /// - Parameters:
    ///   - s: The String encoding
    public init(_ s: String) {
        self = BigDecimal.parseString(s)
    }
    
    /// Constructs a BigDecimal from its Data encoding - NaN if the encoding is wrong
    ///
    /// - Parameters:
    ///   - d: The Data encoding
    public init(_ d: Data) {
        switch d.count {
        case 1:
            if d[0] == 1 {
                self = BigDecimal.InfinityP
            } else if d[0] == 2 {
                self = BigDecimal.InfinityN
            } else {
                self = BigDecimal.flagNaN()
            }
        case 0, 2 ..< 9:
            self = BigDecimal.flagNaN()
        default:
            var exp = Int(d[0])
            exp <<= 8
            exp += Int(d[1])
            exp <<= 8
            exp += Int(d[2])
            exp <<= 8
            exp += Int(d[3])
            exp <<= 8
            exp += Int(d[4])
            exp <<= 8
            exp += Int(d[5])
            exp <<= 8
            exp += Int(d[6])
            exp <<= 8
            exp += Int(d[7])
            let sig = BInt(signed: Bytes(d[8 ..< d.count]))
            self.init(sig, exp)
        }
    }

    /// Constructs a BigDecimal from a Double value
    ///
    /// - Parameters:
    ///   - d: The Double value
    public init(_ d: Double) {
        if d.isNaN {
            self = BigDecimal.flagNaN()
        } else if d.isInfinite {
            self = d > 0.0 ? BigDecimal.InfinityP : BigDecimal.InfinityN
        } else {
            let bits = d.bitPattern
            var exponent = Int((bits >> 52) & 0x7ff)
            var significand = exponent == 0 ? Int((bits & 0xfffffffffffff) << 1) : Int((bits & 0xfffffffffffff) | 0x10000000000000)
            exponent -= 1075
            if significand == 0 {
                self.init(BInt.ZERO)
            } else {
                while significand & 1 == 0 {
                    significand >>= 1
                    exponent += 1
                }
                let s = BInt(d.sign == .minus ? -significand : significand)
                if exponent < 0 {
                    self.init(BInt.FIVE ** (-exponent) * s, exponent)
                } else if exponent > 0 {
                    self.init(BInt.TWO ** exponent * s, 0)
                } else {
                    self.init(s, 0)
                }
            }
        }
    }

    /// Constructs a BigDecimal from a Decimal (the Swift Foundation type)
    ///
    /// - Parameters:
    ///   - value: The Decimal value
    public init(_ value: Decimal) {
        if value.isNaN {
            self = BigDecimal.flagNaN()
        } else {
            let length = value._length
            var m = BInt(0)
            if length > 0 {
                m += Int(value._mantissa.0)
                if length > 1 {
                    m += BInt(Int(value._mantissa.1)) << 16
                    if length > 2 {
                        m += BInt(Int(value._mantissa.2)) << 32
                        if length > 3 {
                            m += BInt(Int(value._mantissa.3)) << 48
                            if length > 4 {
                                m += BInt(Int(value._mantissa.4)) << 64
                                if length > 5 {
                                    m += BInt(Int(value._mantissa.5)) << 80
                                    if length > 6 {
                                        m += BInt(Int(value._mantissa.6)) << 96
                                        if length > 7 {
                                            m += BInt(Int(value._mantissa.7)) << 112
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self = BigDecimal(value < 0 ? -m : m, Int(value._exponent))
        }
    }

    /// Constructs a BigDecimal from an encoded Decimal32 value
    ///
    /// - Parameters:
    ///   - value: The encoded value
    ///   - encoding: The encoding, default is .DPD
    public init(_ value: UInt32, _ encoding: BigDecimal.Encoding = .DPD) {
        self = Decimal32(value, encoding).asBigDecimal()
    }

    /// Constructs a BigDecimal from an encoded Decimal64 value
    ///
    /// - Parameters:
    ///   - value: The encoded value
    ///   - encoding: The encoding, default is .DPD
    public init(_ value: UInt64, _ encoding: BigDecimal.Encoding = .DPD) {
        self = Decimal64(value, encoding).asBigDecimal()
    }

    /// Constructs a BigDecimal from an encoded Decimal128 value
    ///
    /// - Parameters:
    ///   - value: The encoded value
    ///   - encoding: The encoding, default is .DPD
    public init(_ value: UInt128, _ encoding: BigDecimal.Encoding = .DPD) {
        self = Decimal128(value, encoding).asBigDecimal()
    }


    // MARK: Stored properties

    /// The signed BInt significand
    public internal(set) var significand: BInt

    /// The signed exponent - the value of *self* is *self.significand* * 10^*self.exponent*
    public internal(set) var exponent: Int
    
    /// The number of decimal digits in *significand*
    public internal(set) var precision: Int
    
    /// Is *true* if *self* is infinite
    public internal(set) var isInfinite: Bool
    
    /// Is *true* if *self* is NaN
    public internal(set) var isNaN: Bool

    
    // MARK: Computed properties

    /// The absolute value of *self*
    public var abs: BigDecimal {
        if self.isNaN {
            return BigDecimal.flagNaN()
        } else if self.isInfinite {
            return BigDecimal.InfinityP
        } else {
            return BigDecimal(self.significand.abs, self.exponent)
        }
    }
    
    /// String encoding of *self*
    public var description: String {
        return self.asString()
    }

    /// Is *true* if *self* is a finite number
    public var isFinite: Bool {
        return !self.isNaN && !self.isInfinite
    }

    /// Is *true* if *self* < 0, *false* otherwise
    public var isNegative: Bool {
        return self.isNaN ? false : self.signum < 0
    }

    /// Is *true* if *self* > 0, *false* otherwise
    public var isPositive: Bool {
        return self.isNaN ? false : self.signum > 0
    }

    /// Is *true* if *self* = 0, *false* otherwise
    public var isZero: Bool {
        return self.isNaN ? false : self.signum == 0
    }

    /// Is 0 if *self* = 0 or *self* is NaN, 1 if *self* > 0, and -1 if *self* < 0
    public var signum: Int {
        return self.significand.signum
    }
    
    /// The same value as *self* with any trailing zeros removed from its significand
    public var trim: BigDecimal {
        if self.isNaN {
            return BigDecimal.flagNaN()
        } else if self.isInfinite {
            return self
        } else if self.significand.isZero {
            return BigDecimal(0)
        }
        var q = self.significand
        var n = 0
        while true {
            let (q1, r) = q.quotientAndRemainder(dividingBy: BInt.TEN)
            if !r.isZero {
                break
            }
            q = q1
            n += 1
        }
        return BigDecimal(q, self.exponent + n)
    }
    
    /// Unit in last place = BigDecimal(1, self.exponent)
    public var ulp: BigDecimal {
        return self.isFinite ? BigDecimal(BInt.ONE, self.exponent) : BigDecimal.flagNaN()
    }

    
    // MARK: Static variables

    /// NaN flag - set to *true* whenever a NaN value is generated</br>
    /// Can be set to *false* by application code
    public static var NaNFlag = false
 

    // MARK: Conversion functions
    
    /// *self* as a string
    ///
    /// - Parameters:
    ///   - mode: The display mode - *SCIENTIFIC* is default
    /// - Returns: *self* encoded as a string in accordance with the display mode
    public func asString(_ mode: DisplayMode = .SCIENTIFIC) -> String {
        if self.isNaN {
            return "NaN"
        } else if self.isInfinite {
            return self.significand.isNegative ? "-Infinity" : "+Infinity"
        }
        var exp = self.precision + self.exponent - 1
        var s = self.significand.abs.asString()
        if mode == .PLAIN || (self.exponent <= 0 && exp >= -6) {

            // .PLAIN notation
            
            if self.exponent > 0 {
                if !self.significand.isZero {
                    for _ in 0 ..< self.exponent {
                        s.append("0")
                    }
                }
            } else if self.exponent < 0 {
                if -self.exponent < self.precision {
                    s.insert(".", at: s.index(s.startIndex, offsetBy: self.precision + self.exponent))
                } else {
                    for _ in 0 ..< -(self.exponent + self.precision) {
                        s.insert("0", at: s.startIndex)
                    }
                    s.insert(".", at: s.startIndex)
                    s.insert("0", at: s.startIndex)
                }
            }
        } else if mode == .SCIENTIFIC {
            
            // .SCIENTIFIC notation
            
            if s.count > 1 {
                s.insert(".", at: s.index(s.startIndex, offsetBy: 1))
            }
            s.append("E")
            if exp > 0 {
                s.append("+")
            }
            s.append(exp.description)
        } else {

            // .ENGINEERING notation
            
            switch exp % 3 {
            case 1, -2:
                if self.isZero {
                    s.append(".00")
                    exp += 2
                } else {
                    let sc = s.count
                    if sc > 2 {
                        s.insert(".", at: s.index(s.startIndex, offsetBy: 2))
                    } else {
                        for _ in 0 ..< 2 - sc {
                            s.append("0")
                        }
                    }
                    exp -= 1
                }
                break
            case -1, 2:
                if self.isZero {
                    s.append(".0")
                    exp += 1
                } else {
                    let sc = s.count
                    if sc > 3 {
                        s.insert(".", at: s.index(s.startIndex, offsetBy: 3))
                    } else {
                        for _ in 0 ..< 3 - sc {
                            s.append("0")
                        }
                    }
                    exp -= 2
                }
                break
            default:
                if !self.isZero && s.count > 1 {
                    s.insert(".", at: s.index(s.startIndex, offsetBy: 1))
                }
                break
            }
            if exp > 0 {
                s.append("E+")
                s.append(exp.description)
            } else if exp < 0 {
                s.append("E")
                s.append(exp.description)
            }
        }
        if self.significand.isNegative {
            s.insert("-", at: s.startIndex)
        }
        return s
    }
    
    /// *self* as Data
    ///
    /// - Returns: *self* encoded as Data
    public func asData() -> Data {
        if self.isNaN {
            return Data([0])
        } else if self.isInfinite {
            return self.isPositive ? Data([1]) : Data([2])
        }
        var expBytes = [UInt8](repeating: 0, count: 8)
        var exp = self.exponent
        expBytes[7] = UInt8(exp & 0xff)
        exp >>= 8
        expBytes[6] = UInt8(exp & 0xff)
        exp >>= 8
        expBytes[5] = UInt8(exp & 0xff)
        exp >>= 8
        expBytes[4] = UInt8(exp & 0xff)
        exp >>= 8
        expBytes[3] = UInt8(exp & 0xff)
        exp >>= 8
        expBytes[2] = UInt8(exp & 0xff)
        exp >>= 8
        expBytes[1] = UInt8(exp & 0xff)
        exp >>= 8
        expBytes[0] = UInt8(exp & 0xff)
        return Data(expBytes + self.significand.asSignedBytes())
    }

    /// *self* as a Double
    ///
    /// - Returns: *self* encoded as a Double, possibly *Infinity* or NaN
    public func asDouble() -> Double {
        return Double(self.asString())!
    }

    /// *self* as a Decimal (the Swift Foundation type)
    ///
    /// - Returns: *self* as a Decimal value
    public func asDecimal() -> Decimal {
        if self.isNaN || self.abs > BigDecimal.MAXDecimal {
            return Decimal.nan
        }
        var exp = self.exponent
        var sig = self.significand.abs
        while sig.magnitude.count > 2 {
            sig /= 10
            exp += 1
        }
        if exp > 127 {
            sig *= Rounding.pow10(exp - 127)
            exp = 127
        }
        if exp < -128 {
            sig /= Rounding.pow10(-128 - exp)
            exp = -128
        }
        if sig == 0 {
            return Decimal(0)
        }
        assert(sig.magnitude.count < 3)
        assert(-128 <= exp && exp < 128)
        var s0 = UInt16(0)
        var s1 = UInt16(0)
        var s2 = UInt16(0)
        var s3 = UInt16(0)
        var s4 = UInt16(0)
        var s5 = UInt16(0)
        var s6 = UInt16(0)
        var s7 = UInt16(0)
        var length = UInt32(1)
        var r: Int
        (sig, r) = sig.quotientAndRemainder(dividingBy: 0x10000)
        s0 = UInt16(r)
        if sig > 0 {
            (sig, r) = sig.quotientAndRemainder(dividingBy: 0x10000)
            s1 = UInt16(r)
            length += 1
            if sig > 0 {
                (sig, r) = sig.quotientAndRemainder(dividingBy: 0x10000)
                s2 = UInt16(r)
                length += 1
                if sig > 0 {
                    (sig, r) = sig.quotientAndRemainder(dividingBy: 0x10000)
                    s3 = UInt16(r)
                    length += 1
                    if sig > 0 {
                        (sig, r) = sig.quotientAndRemainder(dividingBy: 0x10000)
                        s4 = UInt16(r)
                        length += 1
                        if sig > 0 {
                            (sig, r) = sig.quotientAndRemainder(dividingBy: 0x10000)
                            s5 = UInt16(r)
                            length += 1
                            if sig > 0 {
                                (sig, r) = sig.quotientAndRemainder(dividingBy: 0x10000)
                                s6 = UInt16(r)
                                length += 1
                                if sig > 0 {
                                    (sig, r) = sig.quotientAndRemainder(dividingBy: 0x10000)
                                    s7 = UInt16(r)
                                    length += 1
                                }
                            }
                        }
                    }
                }
            }
        }
        assert(sig < 0x10000)
        return Decimal(_exponent: Int32(exp), _length: length, _isNegative: self < 0 ? 1 : 0, _isCompact: 0, _reserved: 0, _mantissa: (s0, s1, s2, s3, s4, s5, s6, s7))
    }
    
    /// *self* as a Decimal32 value
    ///
    /// - Parameters:
    ///   - encoding: The encoding of the result - DPD is the default
    /// - Returns: *self* encoded as a Decimal32 value
    public func asDecimal32(_ encoding: BigDecimal.Encoding = .DPD) -> UInt32 {
        return Decimal32(self).asUInt32(encoding)
    }
    
    /// *self* as a Decimal64 value
    ///
    /// - Parameters:
    ///   - encoding: The encoding of the result - DPD is the default
    /// - Returns: *self* encoded as a Decimal64 value
    public func asDecimal64(_ encoding: BigDecimal.Encoding = .DPD) -> UInt64 {
        return Decimal64(self).asUInt64(encoding)
    }
    
    /// *self* as a Decimal128 value
    ///
    /// - Parameters:
    ///   - encoding: The encoding of the result - DPD is the default
    /// - Returns: *self* encoded as a Decimal128 value
    public func asDecimal128(_ encoding: BigDecimal.Encoding = .DPD) -> UInt128 {
        return Decimal128(self).asUInt128(encoding)
    }


    // MARK: Rounded arithmetic
    
    /// Addition and rounding
    ///
    /// - Parameters:
    ///   - x: Addend
    ///   - rnd: Rounding object
    /// - Returns: *self* + x rounded according to *rnd*
    public func add(_ x: BigDecimal, _ rnd: Rounding) -> BigDecimal {
        return rnd.round(self + x)
    }

    /// Addition and rounding
    ///
    /// - Parameters:
    ///   - x: Addend
    ///   - rnd: Rounding object
    /// - Returns: *self* + x rounded according to *rnd*
    public func add(_ x: Int, _ rnd: Rounding) -> BigDecimal {
        return rnd.round(self + x)
    }

    /// Subtraction and rounding
    ///
    /// - Parameters:
    ///   - x: Subtrahend
    ///   - rnd: Rounding object
    /// - Returns: *self* - x rounded according to *rnd*
    public func subtract(_ x: BigDecimal, _ rnd: Rounding) -> BigDecimal {
        return rnd.round(self - x)
    }
    
    /// Subtraction and rounding
    ///
    /// - Parameters:
    ///   - x: Subtrahend
    ///   - rnd: Rounding object
    /// - Returns: *self* - x rounded according to *rnd*
    public func subtract(_ x: Int, _ rnd: Rounding) -> BigDecimal {
        return rnd.round(self - x)
    }

    /// Multiplication and rounding
    ///
    /// - Parameters:
    ///   - x: Multiplicand
    ///   - rnd: Rounding object
    /// - Returns: *self* \* x rounded according to *rnd*
    public func multiply(_ x: BigDecimal, _ rnd: Rounding) -> BigDecimal {
        return rnd.round(self * x)
    }

    /// Multiplication and rounding
    ///
    /// - Parameters:
    ///   - x: Multiplicand
    ///   - rnd: Rounding object
    /// - Returns: *self* \* x rounded according to *rnd*
    public func multiply(_ x: Int, _ rnd: Rounding) -> BigDecimal {
        return rnd.round(self * x)
    }

    /// Division and rounding
    ///
    /// - Parameters:
    ///   - d: Divisor
    ///   - rnd: Optional rounding object
    /// - Returns: *self* / *d* optionally rounded according to *rnd*, NaN if *rnd* = *nil* and the quotient has infinite decimal expansion
    public func divide(_ d: BigDecimal, _ rnd: Rounding? = nil) -> BigDecimal {
        let (error, quotient, _) = self.checkDivision(d)
        if error {
            return quotient
        }
        let gcd = self.significand.gcd(d.significand)
        var d1 = d.significand.quotientExact(dividingBy: gcd)
        let count2 = d1.trailingZeroBitCount
        d1 >>= count2
        var count5 = 0
        while true {
            let (q, r) = d1.quotientAndRemainder(dividingBy: BInt.FIVE)
            if !r.isZero {
                break
            }
            d1 = q
            count5 += 1
        }
        if d1.abs.isOne {
            
            // Quotient has finite decimal expansion
            
            let m = max(count2, count5)
            let x = BigDecimal((self.significand * Rounding.pow10(m)) / d.significand, self.exponent - d.exponent - m)
            return rnd == nil ? x : rnd!.round(x)
        }
        guard let ctx = rnd else {
            return BigDecimal.flagNaN()
        }

        // Quotient has infinite decimal expansion

        var m = max(ctx.precision - self.precision + d.precision + 1, 0)
        var q = (self.significand * Rounding.pow10(m)) / d.significand
        let z = Rounding.pow10(ctx.precision)
        var r = BInt.ZERO
        while q.abs >= z {
            (q, r) = q.quotientAndRemainder(dividingBy: BInt.TEN)
            m -= 1
        }
        switch ctx.mode {
        case .CEILING:
            q = q.isNegative ? q : q + 1
            break
        case .DOWN:
            break
        case .FLOOR:
            q = q.isNegative ? q - 1 : q
            break
        case .HALF_DOWN, .HALF_EVEN, .HALF_UP:
            if r >= 5 || r <= -5 {
                q = q.isNegative ? q - 1 : q + 1
            }
            break
        case .UP:
            q = q.isNegative ? q - 1 : q + 1
            break
        }
        return BigDecimal(q, self.exponent - d.exponent - m)
    }

    /// Division and rounding
    ///
    /// - Parameters:
    ///   - d: Divisor
    ///   - rnd: Optional rounding object
    /// - Returns: *self* / *d* optionally rounded according to *rnd*, NaN if *rnd* = *nil* and the quotient has infinite decimal expansion
    public func divide(_ d: Int, _ rnd: Rounding? = nil) -> BigDecimal {
        return self.divide(BigDecimal(d), rnd)
    }

    /// Fused multiply / add
    ///
    /// - Parameters:
    ///   - x: Multiplier
    ///   - y: Multiplicand
    ///   - rnd: Rounding object
    /// - Returns: *self* + x \* y rounded according to *rnd*
    public func fma(_ x: BigDecimal, _ y: BigDecimal, _ rnd: Rounding) -> BigDecimal {
        return rnd.round(self + x * y)
    }

    /// Exponentiation and rounding
    ///
    /// - Parameters:
    ///   - n: Exponent
    ///   - rnd: Optional rounding object
    /// - Returns: *self*^*n* if *n* >= 0, 1 / *self*^(-*n*) if *n* < 0, optionally rounded according to *rnd*, NaN if *rnd* = *nil* and the result has infinite decimal expansion
    public func pow(_ n: Int, _ rnd: Rounding? = nil) -> BigDecimal {
        if self.isNaN {
            return BigDecimal.flagNaN()
        } else if self.isInfinite {
            if n < 0 {
                return BigDecimal.ZERO
            } else {
                return n == 0 ? BigDecimal.ONE : (self.isPositive || n & 1 == 0 ? BigDecimal.InfinityP : BigDecimal.InfinityN)
            }
        }
        if n < 0 {
            return self.isZero ? BigDecimal.InfinityP : BigDecimal.ONE.divide(BigDecimal(self.significand ** (-n), self.exponent * (-n)), rnd)
        } else {
            let x = BigDecimal(self.significand ** n, self.exponent * n)
            return rnd == nil ? x : rnd!.round(x)
        }
    }


    // MARK: Addition functions

    /// Prefix plus
    ///
    /// - Parameter x: BigDecimal value
    /// - Returns: x
    public prefix static func +(x: BigDecimal) -> BigDecimal {
        return x
    }

    /// Addition
    ///
    /// - Parameters:
    ///   - x: First addend
    ///   - y: Second addend
    /// - Returns: x + y
    public static func +(x: BigDecimal, y: BigDecimal) -> BigDecimal {
        if x.isNaN || y.isNaN {
            return BigDecimal.flagNaN()
        } else if x.isInfinite {
            if x.signum == y.signum {
                return x
            } else {
                return y.isFinite ? x : BigDecimal.flagNaN()
            }
        } else if y.isInfinite {
            return y
        }
        if x.exponent > y.exponent {
            return BigDecimal(x.significand * Rounding.pow10(x.exponent - y.exponent) + y.significand, y.exponent)
        } else if x.exponent < y.exponent {
            return BigDecimal(x.significand + y.significand * Rounding.pow10(y.exponent - x.exponent), x.exponent)
        } else {
            return BigDecimal(x.significand + y.significand, x.exponent)
        }
    }
    
    /// Addition
    ///
    /// - Parameters:
    ///   - x: First addend
    ///   - y: Second addend
    /// - Returns: x + y
    public static func +(x: BigDecimal, y: Int) -> BigDecimal {
        return x + BigDecimal(y)
    }

    /// Addition
    ///
    /// - Parameters:
    ///   - x: First addend
    ///   - y: Second addend
    /// - Returns: x + y
    public static func +(x: Int, y: BigDecimal) -> BigDecimal {
        return BigDecimal(x) + y
    }

    /// x = x + y
    ///
    /// - Parameters:
    ///   - x: Left hand addend
    ///   - y: Right hand addend
    public static func +=(x: inout BigDecimal, y: BigDecimal) {
        x = x + y
    }

    /// x = x + y
    ///
    /// - Parameters:
    ///   - x: Left hand addend
    ///   - y: Right hand addend
    public static func +=(x: inout BigDecimal, y: Int) {
        x = x + y
    }


    // MARK: Subtraction functions

    /// Prefix minus
    ///
    /// - Parameter x: BigDecimal value
    /// - Returns: -x
    public prefix static func -(x: BigDecimal) -> BigDecimal {
        if x.isNaN {
            return BigDecimal.flagNaN()
        } else if x.isInfinite {
            return x.isNegative ? BigDecimal.InfinityP : BigDecimal.InfinityN
        } else {
            return BigDecimal(-x.significand, x.exponent)
        }
    }

    /// Subtraction
    ///
    /// - Parameters:
    ///   - x: Minuend
    ///   - y: Subtrahend
    /// - Returns: x - y
    public static func -(x: BigDecimal, y: BigDecimal) -> BigDecimal {
        if x.isNaN || y.isNaN {
            return BigDecimal.flagNaN()
        } else if x.isInfinite {
            if x.signum != y.signum {
                return x
            } else {
                return y.isFinite ? x : BigDecimal.flagNaN()
            }
        } else if y.isInfinite {
            return -y
        }
        if x.exponent > y.exponent {
            return BigDecimal(x.significand * Rounding.pow10(x.exponent - y.exponent) - y.significand, y.exponent)
        } else if x.exponent < y.exponent {
            return BigDecimal(x.significand - y.significand * Rounding.pow10(y.exponent - x.exponent), x.exponent)
        } else {
            return BigDecimal(x.significand - y.significand, x.exponent)
        }
    }

    /// Subtraction
    ///
    /// - Parameters:
    ///   - x: Minuend
    ///   - y: Subtrahend
    /// - Returns: x - y
    public static func -(x: BigDecimal, y: Int) -> BigDecimal {
        return x - BigDecimal(y)
    }

    /// x = x - y
    ///
    /// - Parameters:
    ///   - x: Left hand minuend
    ///   - y: Right hand subtrahend
    public static func -=(x: inout BigDecimal, y: BigDecimal) {
        x = x - y
    }

    /// x = x - y
    ///
    /// - Parameters:
    ///   - x: Left hand minuend
    ///   - y: Right hand subtrahend
    public static func -=(x: inout BigDecimal, y: Int) {
        x = x - y
    }


    // MARK: Multiplication functions

    /// Multiplication
    ///
    /// - Parameters:
    ///   - x: Multiplier
    ///   - y: Multiplicand
    /// - Returns: x \* y
    public static func *(x: BigDecimal, y: BigDecimal) -> BigDecimal {
        if x.isNaN || y.isNaN {
            return BigDecimal.flagNaN()
        } else if x.isInfinite || y.isInfinite {
            if x.isZero || y.isZero {
                return BigDecimal.flagNaN()
            } else {
                return x.signum == y.signum ? BigDecimal.InfinityP : BigDecimal.InfinityN
            }
        }
        return BigDecimal(x.significand * y.significand, x.exponent + y.exponent)
    }

    /// Multiplication
    ///
    /// - Parameters:
    ///   - x: Multiplier
    ///   - y: Multiplicand
    /// - Returns: x \* y
    public static func *(x: BigDecimal, y: Int) -> BigDecimal {
        return x * BigDecimal(y)
    }

    /// Multiplication
    ///
    /// - Parameters:
    ///   - x: Multiplier
    ///   - y: Multiplicand
    /// - Returns: x \* y
    public static func *(x: Int, y: BigDecimal) -> BigDecimal {
        return BigDecimal(x) * y
    }

    /// x = x \* y
    ///
    /// - Parameters:
    ///   - x: Left hand multiplier
    ///   - y: Right hand multiplicand
    public static func *=(x: inout BigDecimal, y: BigDecimal) {
        x = x * y
    }

    /// x = x \* y
    ///
    /// - Parameters:
    ///   - x: Left hand multiplier
    ///   - y: Right hand multiplicand
    public static func *=(x: inout BigDecimal, y: Int) {
        x = x * y
    }


    // MARK: Division functions

    /// Division
    ///
    /// - Parameters:
    ///   - x: Dividend
    ///   - y: Divisor
    /// - Returns: x / y truncated to an integer
    public static func /(x: BigDecimal, y: BigDecimal) -> BigDecimal {
        return x.quotientAndRemainder(y).quotient
    }

    /// Division
    ///
    /// - Parameters:
    ///   - x: Dividend
    ///   - y: Divisor
    /// - Returns: x / y truncated to an integer
    public static func /(x: BigDecimal, y: Int) -> BigDecimal {
        return x / BigDecimal(y)
    }

    /// Division
    ///
    /// - Parameters:
    ///   - x: Dividend
    ///   - y: Divisor
    /// - Returns: x / y truncated to an integer
    public static func /(x: Int, y: BigDecimal) -> BigDecimal {
        return BigDecimal(x) / y
    }

    /// x = x / y
    ///
    /// - Parameters:
    ///   - x: Left hand dividend
    ///   - y: Right hand divisor
    public static func /=(x: inout BigDecimal, y: BigDecimal) {
        x = x.quotientAndRemainder(y).quotient
    }

    /// x = x / y
    ///
    /// - Parameters:
    ///   - x: Left hand dividend
    ///   - y: Right hand divisor
    public static func /=(x: inout BigDecimal, y: Int) {
        x = x / BigDecimal(y)
    }

    func checkDivision(_ d: BigDecimal) -> (failure: Bool, q: BigDecimal, r: BigDecimal) {
        if self.isNaN || d.isNaN {
            return (true, BigDecimal.flagNaN(), BigDecimal.flagNaN())
        } else if self.isInfinite {
            if d.isInfinite {
                return (true, BigDecimal.flagNaN(), BigDecimal.flagNaN())
            } else if d.isNegative {
                return (true, (self.isPositive ? BigDecimal.InfinityN : BigDecimal.InfinityP), BigDecimal.flagNaN())
            } else {
                return (true, (self.isNegative ? BigDecimal.InfinityN : BigDecimal.InfinityP), BigDecimal.flagNaN())
            }
        } else if d.isInfinite {
            return (true, BigDecimal.ZERO, self)
        } else if d.isZero {
            return self.isZero ? (true, BigDecimal.flagNaN(), BigDecimal.flagNaN()) : (self.isPositive ? (true, BigDecimal.InfinityP, BigDecimal.flagNaN()) : (true, BigDecimal.InfinityN, BigDecimal.flagNaN()))
        } else {
            return (false, BigDecimal.ZERO, BigDecimal.ZERO)
        }
    }

    /// Quotient and remainder
    ///
    /// - Parameters:
    ///   - d: Divisor
    /// - Returns: Quotient and remainder of the division *self* / d
    public func quotientAndRemainder(_ d: BigDecimal) -> (quotient: BigDecimal, remainder: BigDecimal) {
        let (error, q, r) = self.checkDivision(d)
        if error {
            return (q, r)
        }
        if self.exponent > d.exponent {
            let q = BigDecimal((self.significand * Rounding.pow10(self.exponent - d.exponent)) / d.significand, 0)
            return (q, self - q * d)
        } else {
            let q = BigDecimal(self.significand / (d.significand * Rounding.pow10(d.exponent - self.exponent)), 0)
            return (q, self - q * d)
        }
    }

    /// Quotient and remainder
    ///
    /// - Parameters:
    ///   - d: Divisor
    /// - Returns: Quotient and remainder of the division *self* / d
    public func quotientAndRemainder(_ d: Int) -> (quotient: BigDecimal, remainder: BigDecimal) {
        return self.quotientAndRemainder(BigDecimal(d))
    }


    // MARK: Remainder functions

    /// Remainder
    ///
    /// - Parameters:
    ///   - x: Dividend
    ///   - y: Divisor
    /// - Returns: x % y
    public static func %(x: BigDecimal, y: BigDecimal) -> BigDecimal {
        return x.quotientAndRemainder(y).remainder
    }

    /// Remainder
    ///
    /// - Parameters:
    ///   - x: Dividend
    ///   - y: Divisor
    /// - Returns: x % y
    public static func %(x: BigDecimal, y: Int) -> BigDecimal {
        return x % BigDecimal(y)
    }

    /// Remainder
    ///
    /// - Parameters:
    ///   - x: Dividend
    ///   - y: Divisor
    /// - Returns: x % y
    public static func %(x: Int, y: BigDecimal) -> BigDecimal {
        return BigDecimal(x) % y
    }

    /// x = x % y
    ///
    /// - Parameters:
    ///   - x: Dividend
    ///   - y: Divisor
    public static func %=(x: inout BigDecimal, y: BigDecimal) {
        x = x.quotientAndRemainder(y).remainder
    }

    /// x = x % y
    ///
    /// - Parameters:
    ///   - x: Dividend
    ///   - y: Divisor
    public static func %=(x: inout BigDecimal, y: Int) {
        x = x % y
    }

    
    // MARK: Comparison functions

    // Returns -1 if self < x, 1 if self > x and 0 if self = x
    func compare(_ x: BigDecimal) -> Int {
        assert(!self.isNaN && !x.isNaN)
        if self.isInfinite {
            if self.isPositive {
                return x.isInfinite && x.isPositive ? 0 : 1
            } else {
                return x.isInfinite && x.isNegative ? 0 : -1
            }
        } else if x.isInfinite {
            return x.isPositive ? -1 : 1
        }
        let ssignum = self.signum
        let xsignum = x.signum
        if ssignum != xsignum {
            return ssignum > xsignum ? 1 : -1
        } else if ssignum == 0 {
            return 0
        } else if self.exponent == x.exponent {
            return self.significand.comparedTo(x.significand)
        } else {
            var cmp: Int
            let sae = self.precision + self.exponent
            let xae = x.precision + x.exponent
            if sae < xae {
                cmp = -1
            } else if sae > xae {
                cmp = 1
            } else if self.exponent > x.exponent {
                cmp = (self.significand.abs * Rounding.pow10(self.exponent - x.exponent)).comparedTo(x.significand.abs)
            } else {
                cmp = self.significand.abs.comparedTo(x.significand.abs * Rounding.pow10(x.exponent - self.exponent))
            }
            return ssignum > 0 ? cmp : -cmp
        }
    }

    /// Maximum
    ///
    /// - Parameters:
    ///    - x: First operand
    ///    - y: Second operand
    /// - Returns: The larger of *x* and *y*, NaN if either is NaN
    public static func maximum(_ x: BigDecimal, _ y: BigDecimal) -> BigDecimal {
        return (x.isNaN || y.isNaN) ? BigDecimal.flagNaN() : (x > y ? x : y)
    }

    /// Minimum
    ///
    /// - Parameters:
    ///    - x: First operand
    ///    - y: Second operand
    /// - Returns: The smaller of *x* and *y*, NaN if either is NaN
    public static func minimum(_ x: BigDecimal, _ y: BigDecimal) -> BigDecimal {
        return (x.isNaN || y.isNaN) ? BigDecimal.flagNaN() : (x < y ? x : y)
    }

    /// Equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x = y, *false* otherwise
    public static func ==(x: BigDecimal, y: BigDecimal) -> Bool {
        return x.isNaN || y.isNaN ? false : x.compare(y) == 0
    }

    /// Equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x = y, *false* otherwise
    public static func ==(x: BigDecimal, y: Int) -> Bool {
        return x == BigDecimal(y)
    }

    /// Equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x = y, *false* otherwise
    public static func ==(x: Int, y: BigDecimal) -> Bool {
        return BigDecimal(x) == y
    }

    /// Not equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x != y, *false* otherwise
    public static func !=(x: BigDecimal, y: BigDecimal) -> Bool {
        return x.isNaN || y.isNaN ? true : x.compare(y) != 0
    }

    /// Not equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x != y, *false* otherwise
    public static func !=(x: BigDecimal, y: Int) -> Bool {
        return x != BigDecimal(y)
    }

    /// Not equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x != y, *false* otherwise
    public static func !=(x: Int, y: BigDecimal) -> Bool {
        return BigDecimal(x) != y
    }

    /// Less than
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x < y, *false* otherwise
    public static func <(x: BigDecimal, y: BigDecimal) -> Bool {
        return x.isNaN || y.isNaN ? false : x.compare(y) < 0
    }

    /// Less than
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x < y, *false* otherwise
    public static func <(x: BigDecimal, y: Int) -> Bool {
        return x < BigDecimal(y)
    }

    /// Less than
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x < y, *false* otherwise
    public static func <(x: Int, y: BigDecimal) -> Bool {
        return BigDecimal(x) < y
    }

    /// Greater than
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x > y, *false* otherwise
    public static func >(x: BigDecimal, y: BigDecimal) -> Bool {
        return x.isNaN || y.isNaN ? false : x.compare(y) > 0
    }

    /// Greater than
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x > y, *false* otherwise
    public static func >(x: BigDecimal, y: Int) -> Bool {
        return x > BigDecimal(y)
    }

    /// Greater than
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x > y, *false* otherwise
    public static func >(x: Int, y: BigDecimal) -> Bool {
        return BigDecimal(x) > y
    }

    /// Less than or equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x <= y, *false* otherwise
    public static func <=(x: BigDecimal, y: BigDecimal) -> Bool {
        return x.isNaN || y.isNaN ? false : x.compare(y) <= 0
    }

    /// Less than or equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x <= y, *false* otherwise
    public static func <=(x: BigDecimal, y: Int) -> Bool {
        return x <= BigDecimal(y)
    }

    /// Less than or equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x <= y, *false* otherwise
    public static func <=(x: Int, y: BigDecimal) -> Bool {
        return BigDecimal(x) <= y
    }

    /// Greater than or equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x >= y, *false* otherwise
    public static func >=(x: BigDecimal, y: BigDecimal) -> Bool {
        return x.isNaN || y.isNaN ? false : x.compare(y) >= 0
    }

    /// Greater than or equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x >= y, *false* otherwise
    public static func >=(x: BigDecimal, y: Int) -> Bool {
        return x >= BigDecimal(y)
    }

    /// Greater than or equal
    ///
    /// - Parameters:
    ///   - x: First operand
    ///   - y: Second operand
    /// - Returns: *true* if x >= y, *false* otherwise
    public static func >=(x: Int, y: BigDecimal) -> Bool {
        return BigDecimal(x) >= y
    }


    // MARK: Rounding and scaling functions

    /// Round
    ///
    /// - Parameters:
    ///   - rnd: Rounding object
    /// - Returns: The value of *self* rounded according to *rnd*
    public func round(_ rnd: Rounding) -> BigDecimal {
        return rnd.round(self)
    }

    /// Scale by power of ten
    ///
    /// - Parameters:
    ///   - n: Power of ten exponent
    /// - Returns: *self* \* 10^n
    public func scale(_ n: Int) -> BigDecimal {
        if self.isNaN {
            return BigDecimal.flagNaN()
        } else if self.isInfinite {
            return self
        } else {
            return BigDecimal(self.significand, self.exponent + n)
        }
    }

    /// With Exponent
    ///
    /// - Parameters:
    ///    - exp: The required exponent
    ///    - mode: Rounding mode
    /// - Returns: Same value as *self* possibly rounded, with exponent = exp
    public func withExponent(_ exp: Int, _ mode: Rounding.Mode) -> BigDecimal {
        if self.isNaN || self.isInfinite {
            return BigDecimal.flagNaN()
        } else if self.exponent > exp {
            return BigDecimal(self.significand * Rounding.pow10(self.exponent - exp), exp)
        } else if self.exponent < exp {
            let (q, r) = self.significand.quotientAndRemainder(dividingBy: Rounding.pow10(exp - self.exponent))
            if r.isZero {
                return BigDecimal(q, exp)
            }
            return BigDecimal(Rounding(mode, self.precision - self.exponent + exp).roundBInt(self.significand, exp - self.exponent), exp)
        } else {
            return self
        }
    }
    
    /// Quantize
    ///
    /// - Parameters:
    ///   - other: a BigDecimal
    ///   - mode: Rounding mode
    /// - Returns: Same value as *self* possibly rounded, with same exponent as *other*
    public func quantize(_ other: BigDecimal, _ mode: Rounding.Mode) -> BigDecimal {
        if self.isInfinite && other.isInfinite {
            return self.isPositive ? BigDecimal.InfinityP : BigDecimal.InfinityN
        } else if other.isInfinite {
            return BigDecimal.flagNaN()
        } else {
            return self.withExponent(other.exponent, mode)
        }
    }

}

extension BInt {
    
    func comparedTo(_ x: BInt) -> Int {
        if self < x {
            return -1
        } else if self > x {
            return 1
        } else {
            return 0
        }
    }
    
}

extension Array where Element == Int {

    subscript(i: UInt64) -> UInt64 {
        get {
            return UInt64(self[Int(i)])
        }
    }

    subscript(i: UInt32) -> UInt32 {
        get {
            return UInt32(self[Int(i)])
        }
    }

}
