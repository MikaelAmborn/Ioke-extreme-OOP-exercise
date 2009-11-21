use("ispec")
use("interpreter")

describe(Interpreter,

	it("should have the correct kind",
		Interpreter should have kind("Interpreter")
	)
	
	it("should give no output given an empty program",
		Interpreter input(Interpreter TextProgram fromText("")) should == ""
	)
	
	it("should output a single newling given a \"print\" statement",
		Interpreter input(Interpreter TextProgram fromText("PRINT")) should == "\n"
	)
	
	it("should output the content of a given constant string passed to print",
		Interpreter input(Interpreter TextProgram fromText("PRINT \"Hello, World!\"")) should == "Hello, World!\n"
	)
	
	it("should execute consequetive statements one after the other",
		Interpreter input(Interpreter TextProgram fromText("PRINT \"Hi\""), 
			Interpreter TextProgram fromText("PRINT \"There\""),
			Interpreter TextProgram fromText("PRINT \"!\"")) should == "Hi\nThere\n!\n"
	)
	
	it("should output numbers passed as arguments to PRINT",
		Interpreter input(Interpreter TextProgram fromText("PRINT 123"),
			Interpreter TextProgram fromText("PRINT -3")) should == "123\n-3\n"
	)
	
	it("should treat single letters as variables with 0 as default value",
		Interpreter input(Interpreter TextProgram fromText("PRINT A")) should == "0\n"
	)
	
	it("should accept an assignment statement and bind the passed in value to a variables",
		Interpreter input(Interpreter TextProgram fromText("A=12"),
			Interpreter TextProgram fromText("PRINT A")) should == "12\n"
	)
	
	it("should allow two numeric constants to be added together.",
		Interpreter input(Interpreter TextProgram fromText("PRINT 3 + 7")) should == "10\n"
	)
	
	it("should allow a numeric expression with more than two terms",
		Interpreter input(Interpreter TextProgram fromText("PRINT 4 + 4 + 12")) should == "20\n"
	)
	
	it("should allow numeric expressions built with variables and/or constants",
		Interpreter input(Interpreter TextProgram fromText("A=2"),
			Interpreter TextProgram fromText("B=7"),
			Interpreter TextProgram fromText("PRINT A + 1"),
			Interpreter TextProgram fromText("PRINT A + B"),
			Interpreter TextProgram fromText("PRINT 99 + B")) should == "3\n9\n106\n"
	)
	
	it("should allow numeric expressions to be subtracted",
		Interpreter input(Interpreter TextProgram fromText("PRINT 1 - 2")) should == "-1\n"
	)
	
	it("should allow numeric expressions to contain both subtraction and addition",
		Interpreter input(Interpreter TextProgram fromText("PRINT 2 - 2 + 3")) should == "3\n"
	)
	
	it("should allow mathematical expressions to be parenthesized",
		Interpreter input(Interpreter TextProgram fromText("PRINT 1 - (2 + 3)")) should == "-4\n"
	)
)
