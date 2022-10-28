with System;
with Interfaces.C;              use Interfaces.C;

with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Text_IO;               use Ada.Text_IO;

with CUDA.Driver_Types;         use CUDA.Driver_Types;
with CUDA.Runtime_Api;          use CUDA.Runtime_Api;
with CUDA.Stddef;
with CUDA.Storage_Models;        use CUDA.Storage_Models;

with Kernel; use Kernel;

with Ada.Unchecked_Deallocation;
with Ada.Unchecked_Conversion;

with Ada.Calendar; use Ada.Calendar;
with Ada.Command_Line; use Ada.Command_Line;

procedure Main is

   type Array_Host_Access is access all Float_Array;

   procedure Free is new
     Ada.Unchecked_Deallocation (Float_Array, Array_Host_Access);

   Num_Elements : Integer := 2 ** 8;

   H_A, H_B, H_C : Array_Host_Access;

   Gen : Generator;
   Err : Error_T;

   T0 : Time;
   Lapsed : Duration;
begin
   if Ada.Command_Line.Argument_Count >= 1 then
      Num_Elements := 2 ** Integer'Value (Ada.Command_Line.Argument (1));
   end if;

   H_A := new Float_Array (1 .. Num_Elements);
   H_B := new Float_Array (1 .. Num_Elements);
   H_C := new Float_Array (1 .. Num_Elements);

   H_A.all := (others => Float (Random (Gen)));
   H_B.all := (others => Float (Random (Gen)));

   T0 := Clock;

   for I in 0 .. Num_Elements - 1 loop
      Native_Complex_Computation (H_A.all, H_B.all, H_C.all, I);
   end loop;

   Lapsed := Clock - T0;

   Put_Line ("Host processing took " & Lapsed'Img & " seconds");

   T0 := Clock;

   -- INSERT HERE DEVICE CALL

   Lapsed := Clock - T0;

   Put_Line ("Device processing took " & Lapsed'Img & " seconds");

   Free (H_A);
   Free (H_B);
   Free (H_C);
end Main;
