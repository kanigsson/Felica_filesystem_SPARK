package Tree is
  type Null_or_Index_Type is range 0..10000;
  subtype Index_Type is Null_or_Index_Type range 1..10000;

  type Element is record
    Left : Null_or_Index_Type;
    Right : Null_or_Index_Type;
      Value : Integer;
      Use_Flag : Boolean;
      -- pointer? to data
      -- security data
      -- link file?
   end record;
   No_Element : constant Element := (0, 0, 0);
  type Tree_Array is array (Index_Type) of Element;
  type Tree_Type is record
    Root : Null_or_Index_Type;
    Current : Index_type;
    Max : Index_type;
    Tree : Tree_Array;
  end record;

  function create_root (Value : Integer) return Tree_Type;
  procedure tree_image (Tree : Tree_Type );
  procedure append_left (Tree: in out Tree_Type; Value : Integer);
  --procedure append_right

end Tree;
