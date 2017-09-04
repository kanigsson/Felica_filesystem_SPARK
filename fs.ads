with Ada.Containers.Formal_Vectors;

package API is

   type Id_Type is new Integer;
   type Key_Type is new Integer;
   type Name_Type is new String (1 .. 80);
   --  name = string (no structure), unique over entire file system

   package Name_Lists is new Ada.Containers.Formal_Vectors (Positive, Name_Type);
   package Key_Lists is new Ada.Containers.Formal_Vectors (Positive, Key_Type);
   subtype Name_List is Name_Lists.Vector;
   subtype Key_List is Key_Lists.Vector;

   procedure Create_Filesystem (Id : Id_Type; Root_Key : Key_Type);
   --  create root node
   --  id of card
   --  key of root system

   type Session_Id is new Integer;

   function Mutual_Authentication (Id : Id_Type;
                                   Names(full path file or directory names) : Name_List;
                                   Hash(Keys) : Key_List)
				  return Session_Id;
   --  open nodes (and directory's child nodes)
   --  need to provide all names and keys that one wants to access in this session
   -- forall argument key is right    right is hash(argument of key list) = hash(key list in file system)
   -- forall d keys is listed
   -- d is parent directory of file and parent parent directory of file and ... and root directory

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
end API;
