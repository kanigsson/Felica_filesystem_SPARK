package FS is

   type Id_Type is new Integer;
   type Byte is mod 2 ** 8;
   --  Byte is type from 0 to 255 (= 2 ** 8 - 1)

   --  type Key_Type is mod 2 ** 64;
   --  OK on 64bit system - already 8 byte

   type Key_Type is array (1 .. 8) of Byte;
   --  represents a single key

   type Key_Array is array (Natural range <>) of Key_Type;
   --  key list

   subtype String_Length is Natural range 1 .. 20;
   subtype Path_Length is Natural range 1 .. 10;

   type Name_Type (Len : String_Length := 10)
   is record
      Name : String (1 .. Len);
   end record;
   --  type for a component of a name

   --  technique to allow string of variable length (but maximal size of 20)
   --  allows to write:
   --  My_Name : Name_Type (15); -- string of size 15
   --  My_Name : Name_Type := Get_Name (...);
   --  also, objects of type Name_Type are of fixed size in memory (20 byte)
   --  can create arrays/records of such objects

   type Name_Array is array (Natural range <>) of Name_Type;

   type Path_Type (Len : Path_Length := 2) is record
      Path : Name_Array (1 .. Len);
   end record;
   --  type for full path string

   type Path_Array is array (Natural range <>) of Path_Type;
   --  list of paths

   type Hash_Type is mod 2 ** 32;
   --  4 byte hash

   procedure Create_Filesystem (Id : Id_Type; Root_Key : Key_Type);
   --  create root node
   --  id of card
   --  key of root system

   type Session_Id is new Integer;

   function Parent (P : Path_Type) return Path_Type;

   function Contains (A : Path_Array; P : Path_Type) return Boolean is
     (for some P2 of A => P = P2);

   function Hash_Keys (A : Key_Array) return Hash_Type;

   -- to iterate over indices of array: for all Index in Array => condition
   -- to iterate over elements of array: for all Element of Array => cond

   package Internals with Ghost is
      --  ghost package
      --  when compiled with assertions enabled -> can be executed
      --  when compiled with assertions disabled -> not present in executable

      function Path_To_Key (P : Path_Type) return Key_Type;
      --  do not want users to have access to this function

      function Paths_To_Keys (PA : Path_Array) return Key_Array
        with Post =>
          Paths_To_Keys'Result'Length = PA'Length
          and
            (for all Index in Paths_To_Keys'Result'Range =>
               Paths_To_Keys'Result (Index) = Path_To_Key (PA (Index)));

   end Internals;

   function Mutual_Authentication (Id : Id_Type;
                                   Paths : Path_Array;
                                   Hash : Hash_Type)
                                   return Session_Id
     with Pre =>
       --  we requested all parent directories
     (for all P of Paths => Contains (Paths, Parent (P))) and
     --  hash of keys is correct
     Hash = Hash_Keys ( Internals.Paths_To_Keys (Paths) );

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
