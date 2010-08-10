{-# LANGUAGE DeriveDataTypeable, NamedFieldPuns #-}
module System.Console.CmdArgs.Test.Implicit.Tests where
import System.Console.CmdArgs
import System.Console.CmdArgs.Test.Implicit.Util

test = test1 >> test2 >> test3 >> test4
demos = [toDemo mode1, toDemo mode2, toDemo mode3, toDemo mode4]


-- from bug #256 and #231
data Test1
    = Test1 {maybeInt :: Maybe Int, listDouble :: [Double], maybeStr :: Maybe String, float :: Float
            ,bool :: Bool, maybeBool :: Maybe Bool, listBool :: [Bool]}
      deriving (Show,Eq,Data,Typeable)

def1 = Test1 def def def (def &= args) def def def
mode1 = cmdArgsMode $ def1 &= help "Testing various corner cases (1)"

test1 = do
    let Tester{fails,(===)} = tester "Test1" mode1
    [] === def1
    ["--maybeint=12"] === def1{maybeInt = Just 12}
    ["--maybeint=12","--maybeint=14"] === def1{maybeInt = Just 14}
    fails ["--maybeint"]
    fails ["--maybeint=test"]
    ["--listdouble=1","--listdouble=3","--listdouble=2"] === def1{listDouble=[1,3,2]}
    fails ["--maybestr"]
    ["--maybestr="] === def1{maybeStr=Just ""}
    ["--maybestr=test"] === def1{maybeStr=Just "test"}
    ["12.5"] === def1{float=12.5}
    ["12.5","18"] === def1{float=18}
    ["--bool"] === def1{bool=True}
    ["--maybebool"] === def1{maybeBool=Just True}
    ["--maybebool=off"] === def1{maybeBool=Just False}
    ["--listbool","--listbool=true","--listbool=false"] === def1{listBool=[True,True,False]}
    fails ["--listbool=fred"]


-- from bug #230
data Test2 = Cmd1 {bs :: [String]}
           | Cmd2 {bar :: Int}
             deriving (Show, Eq, Data, Typeable)

mode2 = cmdArgsMode $ modes [Cmd1 [], Cmd2 42] &= help "Testing various corner cases (2)"

test2 = do
    let Tester{fails,(===)} = tester "Test2" mode2
    fails []
    ["cmd1","-btest"] === Cmd1 ["test"]
    ["cmd2","-b14"] === Cmd2 14


-- various argument position
data Test3 = Test3 {pos1_1 :: [String], pos1_2 :: [String], pos1_rest :: [String]}
             deriving (Show, Eq, Data, Typeable)

mode3 = cmdArgsMode $ Test3 (def &= argPos 1) (def &= argPos 2 &= opt "foo") (def &= args) &= help "Testing various corner cases (3)"

test3 = do
    let Tester{fails,(===)} = tester "Test3" mode3
    fails []
    fails ["a"]
    ["a","b"] === Test3 ["b"] ["foo"] ["a"]
    ["a","b","c"] === Test3 ["b"] ["c"] ["a"]
    ["a","b","c","d"] === Test3 ["b"] ["c"] ["a","d"]


-- from bug #222
data Test4 = Test4 {test_4 :: [String]}
             deriving (Show, Eq, Data, Typeable)

mode4 = cmdArgsMode $ Test4 (def &= opt "hello") &= help "Testing various corner cases (4)"

test4 = do
    let Tester{(===)} = tester "Test4" mode4
    [] === Test4 ["hello"]
    ["a"] === Test4 ["a"]
    ["a","b"] === Test4 ["a","b"]