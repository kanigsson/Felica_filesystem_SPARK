package FS is

   type Id_Type is new Integer;
   type Key_Type is new Integer;

   type Key_Array is array (Natural range <>) of Key;

   subtype String_Length is Natural range 1 .. 20;
   subtype Path_Length is Natural range 1 .. 10;

   type Name_Type (Len : String_Length := 10) is record
      Name : String (1 .. Len);
   end record;

   type Name_Array is array (Natural range <>) of Name_Type;

   type Path_Type (Len : Path_Length := 2) is record
      Path : Name_Array (1 .. Len);
   end record;

   type Path_Array is array (Natural range <>) of Path_Type;

   type Hash_Type is mod 2 ** 32;

   procedure Create_Filesystem (Id : Id_Type; Root_Key : Key_Type);
   --  create root node
   --  id of card
   --  key of root system

   type Session_Id is new Integer;

   function Parent (P : Path_Type) return Path_Type;

   function Contains (A : Path_Array, P : Path_Type) is
     (for some P2 of A => P = P2);

   funtion Hash_Keys (A : Key_Array) return Hash_Type;

   package Internals with Ghost is
      function Key (P : Path_Type) return Key_Type;
   end Internals;

   function Mutual_Authentication (Id : Id_Type;
                                   Paths : Path_Array;
                                   Hash : Hash_Type)
                                   return Session_Id
     with Pre =>
        (for all P of Paths => Contains (Paths, Parent P)) and then
          Hash_Keys (



   --  open nodes (and directory's child nodes)
   --  need to provide all names and keys that one wants to access in this session
   -- forall argument key is right    right is hash(argument of key list) = hash(key list in file system)
   -- forall d keys is listed
   -- d is parent directory of file and parent parent directory of file and ... and root directory

--  Example: if access to file_a and file_b is desired, keys 1 to 5 must be requested
--  root (key1)
--    |
--    +  dir_a/ (key2)
--    |         |
--    |         |
--    |        + file_a (key3)
--    +  dir_b/ (key4)
--              |
--            |
--          + file_b (key5)




   procedure Create_Directory (ID : Session_Id;
			       Parent_Dir_Name : Name_Type;
			       Name : Name_Type;
			       Key : Key_Type);
   --  create new directory
   --  pre condition: opened parent directory of new directory
   --                 name is new name in parent directory
   --                       or
   --                 full_path_directory_name is new name

   procedure Delete_Directory (Id : Session_Id;
			       Name : Name_Type);
   --  pre condition: opened parent directory
   --                 exist directory
   --                 directory is empty

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
   --                 name is new name in directory
   --                       or
   --                 full_path_file_name is new name

   procedure Delete_File (Id : Session_Id;
			  Name : Name_Type);
   --  pre condition: opened parent directory
   --                 exist file

   function Read_File (Id : Session_Id;
		       Name : Name_Type)
		      return Data_Type;
   --  pre condition: opened file
   --  first possibility: can return Data'Length > 4K
   --  second possibility: returns max 4K, user has to call several times, with flag

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
end FS;
