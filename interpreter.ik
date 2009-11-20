Interpreter = Origin mimic
Interpreter do (

  input = method(+textPrograms,
    textPrograms map(text, handleLine(text)) join
  )
    
  handleLine = method(textProgram,
    programTypeMatcher = TypeMatcher withTypeDict(programTypeDict) 
    programType = programTypeMatcher match(textProgram asText)
    program = programType fromTextProgram(textProgram)
    program execute
  ) 
      
  
   ; setValue och getValue bryter mot reglerna
   Variables = Origin mimic do (
     variableDict = Dict withDefault(0)
     setValue = method(variable, value,
       variableDict[variable] = value
     )
     getValue = method(variable,
       variableDict[variable]
     )
   )
  
  Argument = Origin mimic do (
    initialize = method(value, @value = value)
  )
      
  TextArgument = Argument mimic("") do(
    evaluate = method(@value[1...-1])
  )
      
  VariableArgument = Argument mimic("") do(
    evaluate = method(
      Interpreter Variables getValue(@value) asText
    )
  )
      
  NumberArgument = Argument mimic("")
      
  OperatorArgument = Argument mimic("")
      
  MathArgument = Argument mimic("") 
      
  Argument do(
    argumentTypeDict = {}(
      #/^$/ => Interpreter Argument mimic(""), 
      #/^"[^"]+"$/ => Interpreter TextArgument mimic(""), ;" to trip emacs
      #/^[-+]?\d+$/ => Interpreter NumberArgument mimic(""),
      #/^\w$/ => Interpreter VariableArgument mimic(""),
      #/^[-+]$/ => Interpreter OperatorArgument mimic(""),
      #/^.+[-+]\s*(\d+|\w)\)?$/ => Interpreter MathArgument mimic("")
    )
    evaluate = method(value asText)
    fromText = method(text,
      argumentTypeMatcher = Interpreter TypeMatcher withTypeDict(argumentTypeDict)
      argumentType = argumentTypeMatcher match(text)
      argumentType mimic(text)
    )
  )
  ;      ""Creates a new MathArgument by spliting the input text into a left hand side, an operator and a right hand side. If the text contains parenthesis the grouping of text into left hand and right hand side changes. Constructing the ast for the expression as leaning to the left ensures propper evaluation of the expression.",
  MathArgument do (
    initialize = method(text,
      regexp = #/^({lhs}.+?)\s*({op}[-+])\s*({rhs}[-+]?\d+|\w)$/
      if (text chars[-1] == ")",
	regexp = #/^({lhs}.+?)\s*({op}[-+])\s*\(({rhs}.+)\)$/
      )
      match = regexp =~ text
      @leftHandSide = Interpreter Argument fromText(match lhs)
      @rightHandSide = Interpreter Argument fromText(match rhs)
      @operation = Interpreter Argument fromText(match op)
    )
    
    evaluate = method(
      message = Message fromText(@leftHandSide evaluate + @operation evaluate + @rightHandSide evaluate)
      message evaluateOn(Origin mimic) asText
    )
  )  
  
  TextProgram = Origin mimic do (
    initialize = method(text, 
      @text = text
    )
    fromText = method(text, 
      Interpreter TextProgram mimic(text)
    )
    first = method(
      @text split[0]
    )
    rest = method(
      @text split rest join(" ")
    )
    asText = method(
      @text
    )
  )
	 	
  Program = Origin mimic do (
    fromTextProgram = method(textProgram, 
      self
    )
    execute = method("")
  )

  Print = Interpreter Program mimic do (
    initialize = method(argument,
      @argument = argument
    )
    fromTextProgram = method(textProgram,
      self mimic(Interpreter Argument fromText(textProgram rest))
    )
    execute = method(
      @argument evaluate asText + "\n"
    )
  )
    
  Assignment = Origin mimic do (
    initialize = method(variable, value,
      @variable = variable
      @value = value		
    )
    fromTextProgram = method(textProgram,
      match = #/^({variable}\w)=({value}[-+]?\d+)$/ =~ (textProgram asText)
      self mimic(match variable, match value)
    )
    execute = method(
      Interpreter Variables setValue(@variable, @value)
      ""
    )
  )
    
  programTypeDict = {}(#/^PRINT.*$/ => Interpreter Print mimic(""),
    #/^\w=[-+]?\d+$/ => Interpreter Assignment mimic("", ""),
    #/^$/ => Interpreter Program mimic("")
  )
  
  TypeMatcher = Origin mimic do (
    initialize = method(typeDict,
      @typeDict = typeDict
    )

    withTypeDict = method(typeDict,
      self mimic(typeDict)
    )
    match = method(text,
      entryMatch = @typeDict find(entry,
	entry key =~ text 
      ) 
      entryMatch value
    )
  )
)