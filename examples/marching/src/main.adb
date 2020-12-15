------------------------------------------------------------------------------
--                    Copyright (C) 2017-2020, AdaCore                      --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.  You should have  received  a copy of the GNU --
-- General  Public  License  distributed  with  this  software;   see  file --
-- COPYING3.  If not, go to http://www.gnu.org/licenses for a complete copy --
-- of the license.                                                          --
------------------------------------------------------------------------------

with Ada.Command_Line;         use Ada.Command_Line;
with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Calendar;             use Ada.Calendar;
with Ada.Directories;          use Ada.Directories;
with Ada.Numerics.Elementary_Functions; 
use Ada.Numerics.Elementary_Functions;
with Interfaces.C;             use Interfaces.C;
with Interfaces;               use Interfaces;

with CUDA.Runtime_Api; use CUDA.Runtime_Api;
with Interfaces.C.Pointers;

with Maths;                    use Maths.Single_Math_Functions;
with Program_Loader;           use Program_Loader;
with Utilities;                use Utilities;

with Volumes;                  use Volumes;
with Geometry;                 use Geometry;
with Marching_Cubes;           use Marching_Cubes;
with Data;                     use Data;
with System; use System;
with CUDA.Driver_Types; use CUDA.Driver_Types;
with CUDA.Vector_Types; use CUDA.Vector_Types;

with UI; use UI;
with Shape_Management; use Shape_Management;

procedure Main is        
   Interpolation_Steps : constant Positive := 128;
   Shape               : Volume;
      
   Last_Triangle     : aliased Interfaces.C.int;
   Last_Vertex       : aliased Interfaces.C.int;
   
   Last_Time         : Ada.Calendar.Time;
   
   FPS               : Integer := 0;
   
   Running           : Boolean := True;

   D_Balls : System.Address;
   D_Triangles : System.Address;
   D_Vertices  : System.Address;      
   Threads_Per_Block : constant Dim3 := (8, 4, 4); 
   Blocks_Per_Grid : constant Dim3 :=
     (unsigned (Samples) / Threads_Per_Block.X, 
      unsigned (Samples) / Threads_Per_Block.Y,
      unsigned (Samples) / Threads_Per_Block.Z);  

   D_Last_Triangle : System.Address;
   D_Last_Vertex : System.Address;
   D_Debug_Value : System.Address;
   
   Debug_Value : aliased Interfaces.C.int;  
      
   task type Compute is
      entry Set_And_Go (X1, X2, Y1, Y2, Z1, Z2 : Integer);
      entry Exit_Loop;
      entry Finished;
   end Compute;
   
   task body Compute is
      X1r, X2r, Y1r, Y2r, Z1r, Z2r : Integer;
      Do_Exit : Boolean := False;
   begin
      loop
         select
            accept Set_And_Go (X1, X2, Y1, Y2, Z1, Z2 : Integer) do
               X1r := X1;
               X2r := X2;
               Y1r := Y1;
               Y2r := Y2;
               Z1r := Z1;
               Z2r := Z2;
            end;
         or
            accept Exit_Loop do
               Do_Exit := True;
            end;
         end select;
      
         exit when Do_Exit;
         
         begin
            for XI in X1r .. X2r loop
               for YI in Y1r .. Y2r loop
                  for ZI in Z1r .. Z2r loop
                     Mesh
                       (Balls               => Balls,
                        Triangles           => Tris,
                        Vertices            => Verts,
                        Start               => Start,
                        Stop                => Stop,
                        Lattice_Size        => (Samples, Samples, Samples),
                        Last_Triangle       => Last_Triangle'Access,
                        Last_Vertex         => Last_Vertex'Access,
                        Interpolation_Steps => Interpolation_Steps,
                        XI                  => XI, 
                        YI                  => YI,
                        ZI                  => ZI,
                        Debug_Value         => Debug_Value'Access);
                  end loop;
               end loop;
            end loop;
         exception
            when others =>
               Put_Line ("ERROR IN TASK");
         end;
         
         accept Finished;
      end loop;
   end Compute;
   
   Compute_Tasks : array (0 .. Samples - 1) of Compute;
   
   type Mode_Type is (Mode_CUDA, Mode_Tasking, Mode_Sequential);
   
   Mode : Mode_Type := Mode_CUDA;
   
begin      
   if Argument_Count >= 1 then
      if Ada.Command_Line.Argument (1) = "1" then
         Mode := Mode_CUDA;
      elsif Ada.Command_Line.Argument (1) = "2" then
         Mode := Mode_Tasking;
      elsif Ada.Command_Line.Argument (1) = "3" then
         Mode := Mode_Sequential;
      end if;
   end if;        
        
   UI.Initialize;
      
   Last_Time := Clock;
   
   if Mode = Mode_CUDA then
      D_Balls := Malloc (Balls'Size / 8);
      D_Triangles := Malloc (Tris'Size / 8);
      D_Vertices := Malloc (Verts'Size / 8);
      D_Last_Triangle := Malloc (Interfaces.C.int'size / 8);
      D_Last_Vertex := Malloc (Interfaces.C.int'size / 8);
      D_Debug_Value := Malloc (Interfaces.C.int'size / 8);      
   end if;
   
   while Running loop            
      Last_Triangle := Interfaces.C.int (Tris'First) - 1;
      Last_Vertex := Interfaces.C.int (Verts'First) - 1;
      
      if Mode = Mode_CUDA then
         Cuda.Runtime_Api.Memcpy
           (Dst   => D_Balls,
            Src   => Balls'Address,
            Count => Balls'Size / 8,
            Kind  => Memcpy_Host_To_Device);     
      
         Cuda.Runtime_Api.Memcpy
           (Dst   => D_Last_Triangle,
            Src   => Last_Triangle'Address,
            Count => Last_Triangle'Size / 8,
            Kind  => Memcpy_Host_To_Device);
      
         Cuda.Runtime_Api.Memcpy
           (Dst   => D_Last_Vertex,
            Src   => Last_Vertex'Address,
            Count => Last_Vertex'Size / 8,
            Kind  => Memcpy_Host_To_Device);
      
         Debug_Value := 0;
      
         Cuda.Runtime_Api.Memcpy
           (Dst   => D_Debug_Value,
            Src   => Debug_Value'Address,
            Count => Debug_Value'Size / 8,
            Kind  => Memcpy_Host_To_Device);      
      
         pragma CUDA_Execute
           (Mesh_CUDA
              (A_Balls             => D_Balls,
               A_Triangles         => D_Triangles,
               A_Vertices          => D_Vertices,
               Ball_Size           => Balls'Length,
               Triangles_Size      => Tris'Length,
               Vertices_Size       => Verts'Length,
               Start               => Start,
               Stop                => Stop,
               Lattice_Size        => (Samples, Samples, Samples),
               Last_Triangle       => D_Last_Triangle,
               Last_Vertex         => D_Last_Vertex,
               Interpolation_Steps => Interpolation_Steps, 
               Debug_Value         => D_Debug_Value),
            Blocks_Per_Grid,
            Threads_Per_Block
           );
      
         Cuda.Runtime_Api.Memcpy
           (Dst   => Debug_Value'Address,
            Src   => D_Debug_Value,
            Count => Debug_Value'Size / 8,
            Kind  => Memcpy_Device_To_Host);
            
         Cuda.Runtime_Api.Memcpy
           (Dst   => Last_Triangle'Address,
            Src   => D_Last_Triangle,
            Count => Last_Triangle'Size / 8,
            Kind  => Memcpy_Device_To_Host);
      
         Cuda.Runtime_Api.Memcpy
           (Dst   => Last_Vertex'Address,
            Src   => D_Last_Vertex,
            Count => Last_Vertex'Size / 8,
            Kind  => Memcpy_Device_To_Host);               
      
         Cuda.Runtime_Api.Memcpy
           (Dst   => Tris'Address,
            Src   => D_Triangles,
            Count => unsigned_long ((Last_Triangle + 1) * Tris (1)'Size / 8),
            Kind  => Memcpy_Device_To_Host);

         Cuda.Runtime_Api.Memcpy
           (Dst   => Verts'Address,
            Src   => D_Vertices,
            Count => unsigned_long ((Last_Vertex + 1) * Verts (1)'Size / 8),
            Kind  => Memcpy_Device_To_Host);     
      elsif Mode = Mode_Sequential then
         for XI in 0 .. Samples - 1 loop
            for YI in 0 .. Samples - 1 loop
               for ZI in 0 .. Samples - 1 loop
                  Mesh
                    (Balls               => Balls,
                     Triangles           => Tris,
                     Vertices            => Verts,
                     Start               => Start,
                     Stop                => Stop,
                     Lattice_Size        => (Samples, Samples, Samples),
                     Last_Triangle       => Last_Triangle'Access,
                     Last_Vertex         => Last_Vertex'Access,
                     Interpolation_Steps => Interpolation_Steps,
                     XI                  => XI, 
                     YI                  => YI,
                     ZI                  => ZI,
                     Debug_Value         => Debug_Value'Access);
               end loop;
            end loop;
         end loop;
      elsif Mode = Mode_Tasking then         
         for XI in 0 .. Samples - 1 loop
            Compute_Tasks (XI).Set_And_Go 
              (XI, XI, 
               0, Samples - 1,
               0, Samples - 1);
         end loop;         
         
         for XI in 0 .. Samples - 1 loop
            Compute_Tasks (XI).Finished;
         end loop;    
      end if;
      
      Shape_Management.Create_Volume 
        (Shape,
         Verts (0 .. Integer (Last_Vertex)), 
         Tris (0 .. Integer (Last_Triangle)));
      
      --  Build result data        
      
      UI.Draw (Shape, Running);      
      
      --  Move the balls
   
      for I in Balls'Range loop
         declare
            New_Position : Point_Real := Balls (I);
         begin
            New_Position.X := Balls (I).X + Speeds (I).X;
            New_Position.Y := Balls (I).Y + Speeds (I).Y;
            New_Position.Z := Balls (I).Z + Speeds (I).Z;
               
            if Sqrt 
              (New_Position.X * New_Position.X + 
                 New_Position.Y * New_Position.Y +
                   New_Position.Z * New_Position.Z) > 1.0 
            then
               Speeds (I).X := -@;
               Speeds (I).Y := -@;
               Speeds (I).Z := -@;
                  
               New_Position.X := Balls (I).X + Speeds (I).X;
               New_Position.Y := Balls (I).Y + Speeds (I).Y;
               New_Position.Z := Balls (I).Z + Speeds (I).Z;
            end if;
               
            Balls (I) := New_Position;
         end;
      end loop;                  
                     
      --  Display FPS timing
   
      FPS := @ + 1;
      if Clock - Last_Time >= 1.0 then
         Put_Line (FPS'Image & " FPS");
         FPS       := 0;
         Last_Time := Clock;
      end if;
             
      Clear (Shape);
   end loop;
   
   --  Finalize
   
   UI.Finalize;
   
   for XI in 0 .. Samples - 1 loop
      Compute_Tasks (XI).Exit_Loop;
   end loop;  
exception
   when others =>
      for XI in 0 .. Samples - 1 loop
         Compute_Tasks (XI).Exit_Loop;
      end loop;  
      
      raise;
end Main;


