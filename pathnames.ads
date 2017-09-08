package Pathnames is

   Dir_Sep : constant Character := '/';

   subtype Path is String
     with Predicate => (Path'Length > 0 and then Path (Path'First) = Dir_Sep);

   subtype Dir is Path
     with Predicate => (Path (Path'Last) = Dir_Sep);

   subtype File is Path
     with Predicate => (Path (Path'Last) /= Dir_Sep);

   Root : constant Path;

   function Dirname (P : Path) return Dir;

   function Filename (P : File) return String;

   function Is_Prefix (P1, P2 : Path) return Boolean;

   function Join (P : Dir; E : String) return Path
     with Pre => (for all C of E => C /= Dir_Sep);

--     procedure Lemma_Join_Dir_File (P : Path)
--       with Pre => P /= Root,
--            Post =>
--         Join (Dirname (P), Filename (P)) = P;

private

   Root : constant Path := "/";

end Pathnames;
