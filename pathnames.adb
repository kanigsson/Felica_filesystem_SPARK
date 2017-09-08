package body Pathnames is

   function Find_Latest_Dir_Sep (P : Path) return Positive
     with Post =>
       Find_Latest_Dir_Sep'Result in Path'Range and then
       P (Find_Latest_Dir_Sep'Result) = Dir_Sep and then
     (for all Index in Positive range
        Find_Latest_Dir_Sep'Result + 1 .. P'Last =>
        P (Index) /= Dir_Sep);

   -------------------------
   -- Find_Latest_Dir_Sep --
   -------------------------

   function Find_Latest_Dir_Sep (P : Path) return Positive is
   begin
      for Index in reverse P'Range loop
         if P (Index) = Dir_Sep then
            return Index;
         end if;
      end loop;
      pragma Assert (False);
   end Find_Latest_Dir_Sep;

   ---------------
   -- Is_Prefix --
   ---------------

   function Is_Prefix (P1, P2 : Path) return Boolean is
     (P1'Length <= P2'Length and then
      P1 = P2 (P2'First .. P2'First + P1'Last - P1'First));

   ----------
   -- Join --
   ----------

   function Join (P : Dir; E : String) return Path is
   begin
      return P & Dir;
   end Join;

   -------------
   -- Dirname --
   -------------

   function Dirname (P : Path) return Path is
   begin
      if P in Dir then
         if P = Root then
            return Root;
         end if;
         declare
            Index : constant Positive :=
              Find_Latest_Dir_Sep (P (P'First .. P'Last - 1));
         begin
            return P (P'First .. Index - 1);
         end;
      else
         return P (P'First .. Find_Latest_Dir_Sep (P) - 1);
      end if;
   end Dirname;

   function Join (P : Dir; E : String) return Path
   function Filename (P : Path) return Element is
   begin
      return P (Find_Latest_Dir_Sep (P) + 1 .. P'Last);
   end Filename;

   function Is_Prefix (P1, P2 : Path) return Boolean;

   function Join (P : Path; E : Element) return Path;

   procedure Lemma_Join_Dir_File (P : Path)
     with Pre => P /= Root,
          Post =>
       Join (Dirname (P), Filename (P)) = P;
end Pathnames;
