with CUDA.Runtime_Api; use CUDA.Runtime_Api; -- Block_Dim, Block_IDx, Thread_IDx
with Interfaces.C;     use Interfaces.C; -- Operators for Block_Dim, Block_IDx, Thread_IDx

package body Kernel is

   procedure Vector_Add
     (A : Array_Device_Access;
      B : Array_Device_Access;
      C : Array_Device_Access)
   is
      I : Integer := Integer (Block_Dim.X * Block_IDx.X + Thread_IDx.X);
   begin
      if I < A'Length then
         if I mod 2 = 0 then
            declare
               Tmp : Positive;
            begin
               Tmp := Integer (A (A'First + I) + B (B'First + I));
               Tmp := @ - 1_000;

               C (C'First + I) := Float (Tmp);
            end;
         else
            C (C'First + I) := A (A'First + I) + B (B'First + I);
         end if;
      end if;
   end Vector_Add;

end Kernel;
