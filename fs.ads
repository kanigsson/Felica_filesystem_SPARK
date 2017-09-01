with Ada.Containers.Formal_Vectors;
with Ada.Containers.Formal_Ordered_Maps;
with Ada.Containers.Functional_Sets;
with Ada.Containers.Functional_Maps;

package FS is

   type Id_Type is new Integer;
   type Key_Type is new Integer;
   type Name_Type is new String (1 .. 80);
   --  currently the Ordered_Map below requires a definite subtype, so using a
   --  fixed size string

   package Name_Key_Maps is new Ada.Containers.Formal_Ordered_Maps
     (Key_Type => Name_Type,
      Element_Type => Key_Type,
      "<" => "<");
   use type Name_Key_Maps.Map;

   subtype Name_Key_Map is Name_Key_Maps.Map;

   type Session_Id is private;

   package M with Ghost is
      --  This package is used to access certain private information of the
      --  file system, for use in contracts.

      function Get_Session_Map (S : Session_Id) return Name_Key_Map;
      --  the file system needs to maintain a mapping from session ID to
      --  allowed Keys/Names. We can access this in contracts using this
      --  function.

      type Entry_Kind is (File, Dir);
      type Children_Key is new Integer;
      type Data_Key is new Integer;

      package Name_Sets is new Ada.Containers.Functional_Sets
        (Element_Type => Name_Type,
         Equivalent_Elements => "=",
         Enable_Handling_Of_Equivalence => False);
      subtype Name_Set is Name_Sets.Set;

      Empty_Name_Set : Name_Set;

      type Entry_Type (Kind : Entry_Kind) is record
         Key : Key_Type;
         case Kind is
            when Dir =>
               Children : Name_Set;
            when File =>
               Data : Data_Key;
         end case;
      end record;

      package Key_Maps is new Ada.Containers.Functional_Maps
        (Key_Type => Name_Type,
         Element_Type => Entry_Type,
         Equivalent_Keys => "=",
         Enable_Handling_Of_Equivalence => False);

      subtype Functional_FS is Key_Maps.Map;

      function Model return Functional_FS;
      --  This function takes a snapshot of the current "real" filesystem and
      --  returns a model of it.

   end M;

   use M;

   procedure Create_Filesystem (Id : Id_Type; Root_Key : Key_Type);
   --  create root node
   --  id of card
   --  key of root system

   function Mutual_Authentication (Id : Id_Type;
                                   Keys : Name_Key_Map)
                                   return Session_Id
   --  open nodes (and directory's child nodes)
   --  need to provide all names and keys that one wants to access in this
   --  session
     with Post =>
       M.Get_Session_Map (Mutual_Authentication'Result) = Keys;
   --  This postcondition is probably too strong - what happens if the user
   --  provides invalid input?

   procedure Create_Directory (ID : Session_Id;
			       Parent_Dir_Name : Name_Type;
			       Name : Name_Type;
                               Key : Key_Type)
   --  create new directory
   --  pre condition: opened parent directory of new directory
   --                 name is new name
   --  ??? should the Key/Name pair be part of the session?
     with Pre  =>
       --  user has the right to access the dir
     Name_Key_Maps.Contains (Get_Session_Map (ID), Parent_Dir_Name)
     --  the name doesn't exist
     and then
       not Key_Maps.Has_Key (Model, Name)
     --  the parent dir exists ...
     and then
       Key_Maps.Has_Key (Model, Parent_Dir_Name)
     --  ... and is a directory
     and then
       Key_Maps.Get (Model, Parent_Dir_Name).Kind = Dir,
     Post =>
       --  file system unchanged except for new element and parent dir
       M.Key_Maps.Elements_Equal_Except (Model, Model'old,
                                         Name,
                                         Parent_Dir_Name)
     and then
   --  parent dir has a new child, otherwise unchanged
     Key_Maps.Get (Model, Parent_Dir_Name) =
     Key_Maps.Get (Model'Old, Parent_Dir_Name)'Update
     (Children =>
        Name_Sets.Add (Key_Maps.Get (Model'Old, Parent_Dir_Name).Children,
                       Name))
     and then
       Key_Maps.Get (Model, Name) =
         Entry_Type'(Kind => Dir,
                       Key => Key,
                       Children => Empty_Name_Set);


   procedure Delete_Directory (Id : Session_Id;
			       Name : Name_Type);
   --  pre condition: opened parent directory
   --                 directory is empty
   --  ??? no key required?

   type Byte is mod 2 ** 8;

   type Data_Type is array (Integer range <>) of Byte;
   --  in Ada, an array contains its length
   --  max length is 2 ** 32;

   procedure Create_File (Id : Session_Id;
			  Paren_Dir_Name : Name_Type;
			  Name : Name_Type;
			  Key : Key_Type;
			  Initial_Data : Data_Type);
   --  create new file
   --  pre condition: opened parent directory
   --                 name is new name


   procedure Delete_File (Id : Session_Id;
			  Name : Name_Type);
   --  pre condition: opened parent directory

   function Read_File (Id : Session_Id;
		       Name : Name_Type)
		      return Data_Type;
   --  pre condition: opened file
   --  first possibility: can return Data'Length > 4K
   --  second possibility: returns max 4K, user has to call several times, with
   --  flag

   procedure Write_File (Id : Session_Id; Name : Name_Type; Data : Data_Type);
   --  pre condition: opened file
   --  internally, block size 4K
   --  if Data'Length > 4K, Write_File will distribute data over blocks
   --
   --  for example, Data'Length 4K + 1 -> 2 blocks used


   procedure Change_Key (Id : Session_Id; Name : Name_Type; Key : Key_Type);
   --  pre condition: opened parent directory



   --  simple *implementation* proposal
   --  datablocks
   --  inode array (1 inode = file or directory)
   --  bitmaps for used/unused information

   --  specification
   --  tree structure/sets and maps

   --  pre/post conditions expressed using specification types

private
   type Session_Id is new Integer;
end FS;
