
with tree; use tree;

procedure Main is
   Initial_Root_Value : Integer;
   Tree : Tree_Type;
begin
   Initial_Root_Value := 10;
   Tree := create_root(Initial_Root_Value);
   append_left(Tree, 20);
   tree_image(Tree);
end Main;
