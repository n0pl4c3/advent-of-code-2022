program MonkeyInTheMiddle;
uses crt, RegExpr, SysUtils;
type
Monkey = record
   starting_items            : array of SizeInt;
   item_count                : SizeInt;
   operation                 : string;
   test                      : SizeInt;
   target                    : Integer;
   alternative               : Integer;
   inspection_count          : SizeInt;
end;                         

var
   input_lines   : array of string;
   line_count    : SizeInt;
   monkeys       : array of Monkey;
   monkeys_count : SizeInt;
   iterator      : Integer;
   round         : Integer;
   result_1      : SizeInt;
   result_2      : SizeInt;
   max_1         : SizeInt;
   max_2         : SizeInt;
   stage2        : boolean;
   
procedure readInput();
(* Reads the input file line by line *)
const
   filename = 'input.txt';
var
   data       : string;
   f          : text;
begin
   line_count := 0;
   
   assign(f, filename);
   reset(f);
   while not eof(f) do
   begin
      line_count := line_count + 1;
      setLength(input_lines, line_count);
      
      readln(f, data);
      input_lines[line_count - 1] := data;
   end;
end; { end of procedure readInput() }

procedure printInput();
(* Prints contents of the input file *)
var
   iterator    : SizeInt;
begin
   for iterator := 0 to line_count do
   begin
      writeLn(input_lines[iterator]);
   end;
end; { end of procedure printInput() }  

procedure initializeStartingItems(index : SizeInt; line:string );
(* Sets the starting item list of a monkey *)
var
   re          : TRegExpr;
begin
   re := TRegExpr.Create;
   re.Expression:='\d+';
   if re.Exec(line) then
      repeat
         { WriteLn('Item found: ', StrToInt(re.Match[0])); }
         monkeys[index].item_count := monkeys[index].item_count + 1;
         setLength(monkeys[index].starting_items, monkeys[index].item_count);

         monkeys[index].starting_items[monkeys[index].item_count - 1] := StrToInt(re.Match[0]);
      until not re.ExecNext;
end; { end of procedure initializeStartingItems() } 

procedure initializeTest(index : SizeInt; line:string );
(* Sets the test of a monkey *)
var
   re          : TRegExpr;
begin
   re := TRegExpr.Create;
   re.Expression:='\d+';
   if re.Exec(line) then
      repeat
         { WriteLn('Test found: ', StrToInt(re.Match[0])); }
         monkeys[index].test := StrToInt(re.Match[0]);
      until not re.ExecNext;
end; { end of procedure initializeTest() } 

procedure initializeTarget(index : SizeInt; line:string );
(* Sets the target of a monkey *)
var
   re          : TRegExpr;
begin
   re := TRegExpr.Create;
   re.Expression:='\d+';
   if re.Exec(line) then
      repeat
         { WriteLn('Target found: ', StrToInt(re.Match[0])); }
         monkeys[index].target := StrToInt(re.Match[0]);
      until not re.ExecNext;
end; { end of procedure initializeTarget() } 

procedure initializeAlternative(index : SizeInt; line:string );
(* Sets the target of a monkey *)
var
   re          : TRegExpr;
begin
   re := TRegExpr.Create;
   re.Expression:='\d+';
   if re.Exec(line) then
      repeat
         { WriteLn('Target found: ', StrToInt(re.Match[0])); }
         monkeys[index].alternative := StrToInt(re.Match[0]);
      until not re.ExecNext;
end; { end of procedure initializeAlternative() } 

procedure printMonkey(index : SizeInt );
(* Prints state of one monkey *)
var
   iterator    : SizeInt;
begin
   writeLn('');
   writeLn('Monkey ', index);
   writeLn('Items: ');
   writeLn('Item Count is ', monkeys[index].item_count);
   for iterator := 0 to monkeys[index].item_count - 1 do
   begin
      writeLn(monkeys[index].starting_items[iterator]);
   end;


   writeLn('Operation: ');
   writeLn(monkeys[index].operation);
   
   writeLn('Test: ');
   writeLn('div by ', monkeys[index].test);

   writeLn('Target: ');
   writeLn(monkeys[index].target);
   writeLn('Alternative: ');
   writeLn(monkeys[index].alternative);
   writeLn('Inspection Count');
   writeLn(monkeys[index].inspection_count);
   writeLn('');
end; { end of procedure printMonkey() }  

procedure evaluateOperation(index : SizeInt);
(* Evaluates the operation of a monkey on its first item *)
var
   re            : TRegExpr;
   cleaned_op    : string;
   operand_1     : SizeInt;
   operand_2     : SizeInt;
   operand_count :  SizeInt;
begin
   re := TRegExpr.Create;
   re.Expression:='(old|\d+) [\*\+] (old|\d+)';
   if re.Exec(monkeys[index].operation) then
      cleaned_op := re.Match[0];

   (*WriteLn('Operation found: ', cleaned_op);*)

   operand_count := 0;
   
   re.Expression := '(old|\d+)';
   if re.Exec(cleaned_op) then
   repeat
         if (operand_count = 0) then
            begin
               if (CompareStr(re.Match[0], 'old') = 0) then
                  operand_1 := monkeys[index].starting_items[0]
               else
                  operand_1 := StrToInt(re.Match[0]);
            end
         else
             begin
               if (CompareStr(re.Match[0], 'old') = 0) then
                   operand_2 := monkeys[index].starting_items[0]
               else
                   operand_2 := StrToInt(re.Match[0]);
            end;
      operand_count := operand_count + 1;
   until not re.ExecNext;

   (*WriteLn('Operand 1: ', operand_1);*)
   (*WriteLn('Operand 2: ', operand_2);*)

   re.Expression:='[\*\+]';
   if re.Exec(cleaned_op) then
   begin
      if (CompareStr(re.match[0], '*') = 0) then
         monkeys[index].starting_items[0] := operand_1 * operand_2
      else
         monkeys[index].starting_items[0] := operand_1 + operand_2;
   end;

   (*WriteLn('New Worry Level: ',  monkeys[index].starting_items[0]);*)
   monkeys[index].inspection_count := monkeys[index].inspection_count + 1;
end; { end of procedure evaluateOperation() } 

procedure passTo(index : SizeInt; item : SizeInt);
(* Passes an item to a monkey *)
begin
   monkeys[index].item_count := monkeys[index].item_count + 1;
   setLength(monkeys[index].starting_items, monkeys[index].item_count);
   monkeys[index].starting_items[monkeys[index].item_count - 1] := item;
end; { end of procedure passTo() }  

function GCD(a,b:SizeInt):SizeInt;
var
 t:SizeInt;
 result: SizeInt;
begin
   result := 0;
  while b <> 0 do
    begin
       t := b;
       b := a mod b;
       a := t;
    end;
    result := a;

   GCD := result
end;

function leastCommonMultiple(): SizeInt;
var
   (* local variable declaration *)
   result: SizeInt;
   iterator: SizeInt;
begin
   result := monkeys[0].test;
   for iterator := 1 to monkeys_count - 1 do
   begin
      result := (monkeys[iterator].test * result) div GCD(monkeys[iterator].test, result);
   end;

   leastCommonMultiple := result;
end;

procedure evaluateMonkey(index :  sizeInt );
(* Performs round operations of a single monkey *)
var
   iterator       : SizeInt;
   inner_iterator : SizeInt;
   item_count     : SizeInt;
begin
   (*writeLn('--------------------------------------');*)
   (*writeLn('Turn of Monkey ', index);*)
   (*writeLn('Current State is ');*)
   (*printMonkey(index);*)

   item_count := monkeys[index].item_count - 1;
   for iterator := 0 to item_count  do
   begin
      (*writeLn('Monkey inspects an item with a worry level of ', monkeys[index].starting_items[0]);*)
      evaluateOperation(index);

      if (not stage2) then
         monkeys[index].starting_items[0] := monkeys[index].starting_items[0] div 3
      else
         monkeys[index].starting_items[0] := monkeys[index].starting_items[0] mod leastCommonMultiple();
      
      (*writeLn('Monkey gets bored with item, worry level is now ', monkeys[index].starting_items[0]);*)

      if (monkeys[index].starting_items[0] mod monkeys[index].test = 0) then
         begin
            (*WriteLn('Current Worry Level is divisible by ', monkeys[index].test);*)
            (*WriteLn('Passing to ', monkeys[index].target);*)
            passTo(monkeys[index].target, monkeys[index].starting_items[0]);
         end
      else
         begin
            (*WriteLn('Current Worry Level is not divisible by ', monkeys[index].test);*)
            (*WriteLn('Passing to ', monkeys[index].alternative);*)
            passTo(monkeys[index].alternative, monkeys[index].starting_items[0]);
         end;
         
      for inner_iterator := 0 to monkeys[index].item_count - 2 do
      begin
         monkeys[index].starting_items[inner_iterator] := monkeys[index].starting_items[inner_iterator + 1];
      end;

      monkeys[index].item_count := monkeys[index].item_count - 1;
      setLength(monkeys[index].starting_items, monkeys[index].item_count);
   end;
end;

procedure initializeMonkeys();
(* Initializes the list of monkeys *)
var
   i        : Integer;
   iterator : Integer;
begin
   for i := 0 to (line_count div 7) - 1 do
   begin
      iterator := i * 7;
      
   monkeys_count :=  monkeys_count + 1;
   setLength(monkeys, monkeys_count);

   { writeLn('Initializing ', input_lines[iterator]); }

   initializeStartingItems(monkeys_count - 1, input_lines[iterator + 1]);

   monkeys[monkeys_count - 1].operation := input_lines[iterator + 2];

   initializeTest(monkeys_count - 1, input_lines[iterator + 3]);

   initializeTarget(monkeys_count - 1, input_lines[iterator + 4]);
   initializeAlternative(monkeys_count - 1, input_lines[iterator + 5]);

   (*printMonkey(monkeys_count - 1);*)

   monkeys[monkeys_count - 1].inspection_count := 0;
   
   end;
end; { end of procedure initializeMonkeys() }

begin
   readInput();
   printInput();

   writeLn('');
   writeLn('');

   stage2 := false;
   
   initializeMonkeys();
   for round := 0 to 19 do
   begin
      (*writeLn('=============================');*)
      (*writeLn('=============================');*)
      (*writeLn('=============================');*)
      (*writeLn('     Round ', round + 1, '      ');*)
      for iterator := 0 to monkeys_count - 1 do
      begin
         evaluateMonkey(iterator);
      end;
   end;

   result_1 := 0;
   max_1 := 0;
   max_2 := 0;
   
   for iterator := 0 to monkeys_count - 1 do
   begin
      (*printMonkey(iterator);*)

      (*writeLn('Max 1: ', max_1, ' Max 2: ', max_2, ' Current: ', monkeys[iterator].inspection_count);*)
      if (monkeys[iterator].inspection_count > max_1) then
         begin
          max_2 := max_1;
          max_1 := monkeys[iterator].inspection_count;
         end
      else if (monkeys[iterator].inspection_count > max_2) then
          max_2 := monkeys[iterator].inspection_count
   end;

   (*writeLn('Max 1: ', max_1, ' Max 2: ', max_2);*)
   result_1 := max_1 * max_2;
   writeLn('Result Part 1: ', result_1);

   writeLn('Start Part 2');
    stage2 := true;

   setLength(input_lines, 0);
   line_count := 0;
   setLength(monkeys, 0);
   monkeys_count := 0;
   max_1 := 0;
   max_2 := 0;

   readInput();
   (*printInput();*)

   writeLn('');
   writeLn('');
   
   initializeMonkeys();
   for round := 0 to 9999 do
   begin
      (* writeLn('============================='); *)
      (*writeLn('============================='); *)
      (*writeLn('============================='); *)
      (*writeLn('     Round ', round + 1, '      ');*)
      for iterator := 0 to monkeys_count - 1 do
      begin
         evaluateMonkey(iterator);
      end;
   end;

   result_1 := 0;
   max_1 := 0;
   max_2 := 0;
   
   for iterator := 0 to monkeys_count - 1 do
   begin
      (*printMonkey(iterator);*)

      (*writeLn('Max 1: ', max_1, ' Max 2: ', max_2, ' Current: ', monkeys[iterator].inspection_count);*)
      if (monkeys[iterator].inspection_count > max_1) then
         begin
          max_2 := max_1;
          max_1 := monkeys[iterator].inspection_count;
         end
      else if (monkeys[iterator].inspection_count > max_2) then
          max_2 := monkeys[iterator].inspection_count
   end;

   (*writeLn('Max 1: ', max_1, ' Max 2: ', max_2);*)
   result_2 := max_1 * max_2;
   writeLn('Result Part 2: ', result_2);

   
   readkey;
end.
