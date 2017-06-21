with Ada.Text_IO;
package body Tree with SPARK_Mode is
   function create_root (Value : Integer) return Tree_Type is
     Tree : Tree_Type;
   begin
     Tree.Tree := (others => No_Element);
     Tree.Root := 1;
     Tree.Current := 1;
     Tree.Max := 1;
     Tree.Tree(1).Left := 0;
     Tree.Tree(1).Right := 0;
     Tree.Tree(1).Value := Value;
     Return Tree;
   end create_root;

   procedure append_left (Tree: in out Tree_Type; Value : Integer) is
   begin
     Tree.Tree(Tree.Current).Left := Tree.Max + 1;
     Tree.Tree(Tree.Max + 1).Value := Value;
     Tree.Max := Tree.Max + 1;
   end append_left;

   procedure index_image(TA : Tree_Array; NIT : Null_or_Index_Type) is
   begin
      if NIT /= 0 then
         Ada.Text_IO.Put_Line(Integer'Image(TA(NIT).Value));
         index_image(TA, TA(NIT).Left);
         index_image(TA, TA(NIT).right);
      end if;
   end index_image;
   procedure tree_image (Tree : Tree_Type ) is
   begin
      index_image(Tree.Tree, 1);
   end tree_image;
end Tree;
