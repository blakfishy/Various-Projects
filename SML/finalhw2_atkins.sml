(* Authored by: Collin Atkins
   Due on: 2/9/2016
   Class: Programming Languages
   Programming Assignment 2
   Worked alongside Ryan Tackett on this assignment
   
   Reduced Ordered Binary Decision Diagrams (ROBDD)
   Program with many functions to manipulate datatype ROBDD that
     represents a decision tree. Functions here like conjunction
     and implies to make decisions but also some like bddEvalToTrue
     which evaluates a tree with all decisions set to True.

     *)

datatype ROBDD = True
 | False
 | IfThenElse of string * ROBDD * ROBDD;

(*Input: string Output: ROBDD
Creates a BDD with given propLetter*)
fun bddAssert propLetter = IfThenElse (propLetter, True, False);

(*Input: BDD Output: string
Returns propLetter of BDD input*)
fun pullVar True = ""
 |  pullVar False = ""
 |  pullVar (IfThenElse(str, _, _)) = str;

(*Input: BDD Output: BDD
Returns second element of BDD input*)
fun pullBDDThen True = True
 |  pullBDDThen False = False
 |  pullBDDThen (IfThenElse(_, bdd, _)) = bdd;

(*Input: BDD Output: BDD
Returns third element of BDD input*)
fun pullBDDElse True = True
 |  pullBDDElse False = False
 |  pullBDDElse (IfThenElse(_, _, bdd)) = bdd;

(*Input: BDD Output: bool
Returns true if BDD input is simply True or False*)
fun isConstantBDD True = true
 |  isConstantBDD False = true
 |  isConstantBDD (IfThenElse(_,_,_)) = false;

(*Input: BDD Output: ROBDD
  Reduces down a tree of inputed BDD all it can*)
fun reducedRoot True = True
 |  reducedRoot False = False
 |  reducedRoot (IfThenElse(str, trueCase, (IfThenElse(str2, trueCase2, falseCase)))) =
    if ((str = str2) andalso (trueCase = trueCase2)) then
      reducedRoot (IfThenElse(str, trueCase, falseCase))
    else
      let
        val reducedTrue = (reducedRoot trueCase)
        val reducedFalse = (reducedRoot (IfThenElse(str2, trueCase2, falseCase)))
        val root = (IfThenElse(str, reducedTrue, reducedFalse))
        val input = (IfThenElse(str, trueCase, (IfThenElse(str2, trueCase2, falseCase))))
      in
        if (reducedTrue = reducedFalse)
          then (reducedRoot reducedTrue)
        else if (root = input)
          then input
        else
          reducedRoot root
      end
 | reducedRoot (IfThenElse(str, (IfThenElse(str2, trueCase, falseCase)), falseCase2)) =
   if (str = str2) then
     reducedRoot (IfThenElse(str, trueCase, falseCase2))
   else
     let
       val reducedTrue = (IfThenElse(str2, trueCase, falseCase))
       val reducedFalse = (reducedRoot falseCase2)
       val root = (IfThenElse(str, reducedTrue, reducedFalse))
       val input = (IfThenElse(str, (IfThenElse(str2, trueCase, falseCase)), falseCase2))
     in
       if (reducedTrue = reducedFalse)
         then (reducedRoot reducedTrue)
       else if (root = input)
         then input
       else
         reducedRoot root
     end
 | reducedRoot (IfThenElse(str, trueCase, falseCase)) =
   if trueCase = falseCase
    then trueCase
   else
    let
      val reducedTrue = (reducedRoot trueCase)
      val reducedFalse = (reducedRoot falseCase)
      val root = (IfThenElse(str, reducedTrue, reducedFalse))
      val input = (IfThenElse(str, trueCase, falseCase))
    in
      if (reducedTrue = reducedFalse)
        then (reducedRoot reducedTrue)
      else if (root = input)
        then input
      else
        reducedRoot root
    end;

fun replaceArg (IfThenElse(str, trueCase, falseCase)) bdd True =
    (IfThenElse(str, bdd, falseCase))
 |  replaceArg (IfThenElse(str, trueCase, falseCase)) bdd False =
    (IfThenElse(str, trueCase, bdd));

(*Input: BDD Output: BDD
Given a BDD, returns the negation of the BDD function*)
fun bddNot True = False
 |  bddNot False = True
 |  bddNot (IfThenElse(str, trueCase, falseCase)) =
    (IfThenElse(str, falseCase, trueCase));

(*Input: BDD BDD Output: ROBDD
Given two BDDs, it returns the ROBDD of their conjunction*)
infix bddAnd;
fun True bddAnd True = True
 |  False bddAnd bdd = False
 |  bdd bddAnd False = False
 |  bdd bddAnd True = bdd
 |  True bddAnd bdd = bdd
 |  (IfThenElse(str, trueCase, falseCase)) bddAnd (IfThenElse(str2, trueCase2, falseCase2)) =
    if ((IfThenElse(str, (reducedRoot trueCase), (reducedRoot falseCase))) = (IfThenElse(str2, (reducedRoot trueCase2), (reducedRoot falseCase2))))
       then True
    else if (str2 >= str) then
       (replaceArg
         (reducedRoot (IfThenElse(str, trueCase, falseCase)))
         (reducedRoot (IfThenElse(str2, trueCase2, falseCase2)))
         True)
    else
       (replaceArg
         (reducedRoot (IfThenElse(str2, trueCase2, falseCase2)))
         (reducedRoot (IfThenElse(str, trueCase, falseCase)))
         True);

(*Input: BDD BDD Output: ROBDD
Given two BDDs, it returns the ROBDD of their disjunction*)
infix bddOr;
fun False bddOr False = False
 |  True bddOr bdd = True
 |  bdd bddOr True = True
 |  False bddOr bdd = bdd
 |  bdd bddOr False = bdd
 |  (IfThenElse(str, trueCase, falseCase)) bddOr (IfThenElse(str2, trueCase2, falseCase2)) =
    if ((IfThenElse(str, (reducedRoot trueCase), (reducedRoot falseCase))) = (bddNot (IfThenElse(str2, (reducedRoot trueCase2), (reducedRoot falseCase2)))))
       then True
    else if (str2 >= str) then
       (replaceArg
         (reducedRoot (IfThenElse(str, trueCase, falseCase)))
         (reducedRoot (IfThenElse(str2, trueCase2, falseCase2)))
         False)
    else
       (replaceArg
         (reducedRoot (IfThenElse(str2, trueCase2, falseCase2)))
         (reducedRoot (IfThenElse(str, trueCase, falseCase)))
         False);

(*Input: BDD BDD Output: ROBDD
Given two BDDs, it returns ROBDD: bddOne -> bddTwo*)
fun bddImplies (True, False) = False
 |  bddImplies (bdd, True) = True
 |  bddImplies (False, bdd) = True
 |  bddImplies (bdd, False) = (bddNot bdd)
 |  bddImplies (True, bdd) = bdd
 |  bddImplies ((IfThenElse(str, trueCase, falseCase)), (IfThenElse(str2, trueCase2, falseCase2))) =
    if (str2 >= str) then
       (replaceArg
         (reducedRoot (IfThenElse(str, falseCase, trueCase)))
         (reducedRoot (IfThenElse(str2, trueCase2, falseCase2)))
         True)
    else
       (replaceArg
         (reducedRoot (IfThenElse(str2, falseCase2, trueCase2)))
         (reducedRoot (IfThenElse(str, trueCase, falseCase)))
         True);

(*Input: BDD BDD BDD Output: ROBDD
Given three BDDs, returns ROBDD of if-then-else func of three args
Reduces and orders the three BDDs, and changes propBDD to a string*)
fun bddIfThenElse ((IfThenElse(str, bddOne, bddTwo)), trueBDD, falseBDD) =
    let val redbddOne = reducedRoot bddOne
    	val redbddTwo = reducedRoot bddTwo
    	val redtrueBDD = reducedRoot trueBDD
	val redfalseBDD = reducedRoot falseBDD
    in if ((isConstantBDD redbddOne) andalso (isConstantBDD redbddTwo))
         then (IfThenElse(str, redbddOne, redbddTwo))
       else if (((not (isConstantBDD redbddOne))) andalso (isConstantBDD redbddTwo))
       	 then (IfThenElse(str, (IfThenElse((pullVar redbddOne), redtrueBDD, redfalseBDD)), redbddTwo))
       else if ((isConstantBDD redbddOne) andalso ((not (isConstantBDD redbddTwo))))
       	 then (IfThenElse(str, redbddOne, (IfThenElse((pullVar redbddTwo), redtrueBDD, redfalseBDD))))
       else
       	 (IfThenElse(str,
		(IfThenElse((pullVar redbddOne), redtrueBDD, redfalseBDD)),
	 	(IfThenElse((pullVar redbddTwo), redtrueBDD, redfalseBDD))))
    end;

(*Input: BDD string Output: ROBDD
Changes ROBDD given so that every propLetter is evaluated to True*)
fun bddEvalToTrue(True, propLetter) = True
 |  bddEvalToTrue(False, propLetter) = False
 |  bddEvalToTrue((IfThenElse(str, trueCase, falseCase)), propLetter) =
    if (str = propLetter) then
       (reducedRoot trueCase)
    else
       (reducedRoot(IfThenElse(
           str,
           (bddEvalToTrue(trueCase, propLetter)),
           (bddEvalToTrue(falseCase, propLetter)))));

(*Input: BDD Output: ROBDD
Changes ROBDD given so that every propLetter is evaluated to False*)
fun bddEvalToFalse(False, propLetter) = False
 |  bddEvalToFalse(True, propLetter) = True
 |  bddEvalToFalse((IfThenElse(str, trueCase, falseCase)), propLetter) =
    if (str = propLetter) then
       (reducedRoot falseCase)
    else
       (bddNot(reducedRoot (IfThenElse(
           str,
           (bddEvalToFalse(falseCase, propLetter)),
           (bddEvalToFalse(trueCase, propLetter))))));