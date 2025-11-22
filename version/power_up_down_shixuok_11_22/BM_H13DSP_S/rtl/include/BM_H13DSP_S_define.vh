//=================================================================================================
// Copyright(c) 
// Filename   : AS03MB08_Define.vh
// Project    : AS03MB08
// Author     : 
// Date       : 2021-10-08
// Email      : chenweihua@cloudnineinfo.com
// Company    : 
// Description: AS03MB08 Top Code
// History    :
// Date      By          Revision  Change Description

// 20211008  jixudong  V001       Project created
//=================================================================================================
// Timescale
  `timescale 1ns / 1ns
  
//Device Number 
  `define NUM_CPU 1'h01		//L00289 2'h02
  `define NUM_PSU 2'h02
  
  
  
//ASCII CODE
  `define ASCII_0 8'h30
  `define ASCII_1 8'h31
  `define ASCII_2 8'h32
  `define ASCII_3 8'h33
  `define ASCII_4 8'h34
  `define ASCII_5 8'h35
  `define ASCII_6 8'h36
  `define ASCII_7 8'h37
  `define ASCII_8 8'h38
  `define ASCII_9 8'h39
  `define ASCII_A 8'h41
  `define ASCII_B 8'h42
  `define ASCII_C 8'h43
  `define ASCII_D 8'h44
  `define ASCII_E 8'h45
  `define ASCII_F 8'h46
  `define ASCII_G 8'h47
  `define ASCII_H 8'h48
  `define ASCII_I 8'h49
  `define ASCII_J 8'h4A
  `define ASCII_K 8'h4B
  `define ASCII_L 8'h4C
  `define ASCII_M 8'h4D
  `define ASCII_N 8'h4E
  `define ASCII_O 8'h4F
  `define ASCII_P 8'h50
  `define ASCII_Q 8'h51
  `define ASCII_R 8'h52
  `define ASCII_S 8'h53
  `define ASCII_T 8'h54
  `define ASCII_U 8'h55
  `define ASCII_V 8'h56
  `define ASCII_W 8'h57
  `define ASCII_X 8'h58
  `define ASCII_Y 8'h59
  `define ASCII_Z 8'h5A

//VA&VB  
  `define VERSION_A 3'b000 //20220226 d50092 rdc:3725674
  `define VERSION_B 3'b010 //20220226 d50092 rdc:3725674

  `define genvar i;
