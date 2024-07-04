#include "protheus.ch"
#include "parmtype.ch"

STATIC aPosRest  := {}

//Compatibilização de fontes 30/05/2018
    
CLASS CtbTXT FROM LongClassName

	DATA cDescricao     AS CHARACTER
	DATA cDestino       AS CHARACTER
	DATA cObjetivo      AS CHARACTER
	DATA cPrazo	        AS CHARACTER
	DATA cAplicativo	AS CHARACTER
	DATA cComentario    AS CHARACTER
	DATA cLayOut        AS CHARACTER
	DATA cSaveFile      AS CHARACTER
	DATA cTempFile      AS CHARACTER
	DATA cMsgOutPutFile AS CHARACTER
	DATA cClassName     AS CHARACTER HIDDEN
	                            
	DATA aMsgStatus     AS ARRAY HIDDEN
	DATA aTables        AS ARRAY HIDDEN
	DATA aInit          AS ARRAY HIDDEN
	DATA aClose         AS ARRAY HIDDEN
	DATA aFormul        AS ARRAY
	
	DATA nHandle        AS NUMERIC HIDDEN
	
	DATA oLayOutCtb     AS OBJECT HIDDEN
	
	METHOD New()       
	METHOD Init()      
	METHOD ReadLayOut()
	METHOD SaveLayOut()
	METHOD Execute()
	METHOD AddTables()
	METHOD AddOnInit()
	METHOD AddOnClose()
	METHOD AddFormul()
	METHOD ClassName()
	METHOD FindID()
	
ENDCLASS

CLASS CtbTXTTable FROM CtbTXT

	DATA cID          AS CHARACTER HIDDEN
	DATA cDescription AS CHARACTER HIDDEN
	DATA cAlias       AS CHARACTER READONLY
	
	DATA aWhile       AS ARRAY HIDDEN
	DATA aEnd         AS ARRAY HIDDEN
	DATA aCount       AS ARRAY HIDDEN
	DATA aRecord      AS ARRAY HIDDEN
	
	DATA oParent      AS OBJECT READONLY

	METHOD Init()		            
	METHOD New()
	METHOD AddRecord()
	METHOD AddOnInit()
	METHOD AddOnWhile()
	METHOD AddOnEnd()
	METHOD AddOnClose()
	METHOD Execute()
	
ENDCLASS

CLASS CtbTXTRecord FROM CtbTXTTable

	DATA aValid           AS ARRAY HIDDEN
	DATA aEstrutura       AS ARRAY HIDDEN
	DATA aConteudo        AS ARRAY HIDDEN
	DATA aCount           AS ARRAY HIDDEN
	
	DATA cDelimited       AS CHARACTER
	DATA lNumericNull     AS LOGICAL
	DATA lDateNull        AS LOGICAL
	DATA lStringNull      AS LOGICAL
	DATA cDecimalPoint    AS CHARACTER
	DATA cDateFormat      AS CHARACTER
	            
	METHOD Init()
	METHOD New()
	METHOD Execute()
	METHOD AddOnValid()
	METHOD AddOnCount()
	METHOD AddOnStruct()
	METHOD AddOnInstruction()
	
ENDCLASS
//--------------------------------------------------------------------------------
METHOD New(cLayOut) CLASS CtbTXT

PARAMTYPE 0  VAR cLayOut      AS CHARACTER

::Init()
::cLayOut      := cLayOut

Return Self
//--------------------------------------------------------------------------------
METHOD Init()  CLASS CtbTXT

DEFAULT ::aMsgStatus    := {}
DEFAULT ::aTables       := {}
DEFAULT ::aInit         := {}
DEFAULT ::aClose        := {}
DEFAULT ::aFormul       := {}

DEFAULT ::cDescricao    := ""
DEFAULT ::cDestino      := ""
DEFAULT ::cObjetivo     := ""
DEFAULT ::cPrazo        := ""
DEFAULT ::cAplicativo   := ""
DEFAULT ::cComentario   := ""
DEFAULT ::cClassName    := "CtbTXT"
DEFAULT ::oLayOutCtb    := Self
DEFAULT ::cLayOut       := ""
DEFAULT ::cSaveFile     := ""
DEFAULT ::cMsgOutPutFile:= ""
DEFAULT ::cTempFile     := ""

Return
//--------------------------------------------------------------------------------
METHOD New(oParent,cID,cDescricao) CLASS CtbTXTTable
                   
PARAMTYPE 0  VAR oParent      AS OBJECT CLASS CtbTXT,CtbTXTTable
DEFAULT cID        := ""
DEFAULT cDescricao := ""

::Init()
         
::cID           := cID
::cDescription  := cDescricao

oParent:AddTables(Self)

Return Self
//--------------------------------------------------------------------------------
METHOD Init()  CLASS CtbTXTTable

DEFAULT ::cID         := ""
DEFAULT ::cDescription:= ""
DEFAULT ::cAlias      := ""
DEFAULT ::cClassName  := "CtbTXTTABLE"
DEFAULT ::aTables   := {}
DEFAULT ::aInit     := {}
DEFAULT ::aClose    := {}
DEFAULT ::aWhile    := {}
DEFAULT ::aEnd      := {}
DEFAULT ::aRecord   := {}

Return
//--------------------------------------------------------------------------------
METHOD New(oParent) CLASS CtbTXTRecord
                   
PARAMTYPE 0  VAR oParent      AS OBJECT CLASS CtbTXTTable

::Init()
         
oParent:AddRecord(Self)

Return Self
//--------------------------------------------------------------------------------
METHOD Init()  CLASS CtbTXTRecord

DEFAULT ::aTables       := {}
DEFAULT ::aValid        := {}
DEFAULT ::aEstrutura    := {}
DEFAULT ::aConteudo     := {}
DEFAULT ::aCount        := {}

DEFAULT ::cDelimited    := ""
DEFAULT ::cDateFormat   := "YYYYMMDD"
DEFAULT ::cClassName    := "CtbTXTRECORD"

DEFAULT ::lNumericNull  := .F.
DEFAULT ::lDateNull     := .F.
DEFAULT ::lStringNull   := .F.
DEFAULT ::cDecimalPoint := ""

Return
//--------------------------------------------------------------------------------
METHOD AddTables(oTable) CLASS CtbTXT

PARAMTYPE 0 VAR oTable AS OBJECT CLASS CtbTXTTable

Aadd(::aTables,oTable)

oTable:oParent    := Self
oTable:oLayOutCtb := Self:oLayOutCtb
Return
//--------------------------------------------------------------------------------
METHOD AddRecord(oRecord) CLASS CtbTXTTable

PARAMTYPE 0 VAR oRecord AS OBJECT CLASS CtbTXTRecord

Aadd(::aRecord,oRecord)

oRecord:oParent    := Self
oRecord:oLayOutCtb := Self:oLayOutCtb
Return
//--------------------------------------------------------------------------------
METHOD AddOnInit(cInstruction) CLASS CtbTXT

aadd(::aInit,cInstruction)
Return
//--------------------------------------------------------------------------------
METHOD AddOnClose(cInstruction) CLASS CtbTXT

aadd(::aClose,cInstruction)
Return
//--------------------------------------------------------------------------------
METHOD AddFormul(cInstruction) CLASS CtbTXT

aadd(::aFormul,cInstruction)
Return
//--------------------------------------------------------------------------------
METHOD AddOnInit(cInstruction) CLASS CtbTXTTable

aadd(::aInit,cInstruction)
Return
//--------------------------------------------------------------------------------
METHOD AddOnClose(cInstruction) CLASS CtbTXTTable

aadd(::aClose,cInstruction)
Return
//--------------------------------------------------------------------------------
METHOD AddOnWhile(cInstruction) CLASS CtbTXTTable

aadd(::aWhile,cInstruction)
Return
//--------------------------------------------------------------------------------
METHOD AddOnEnd(cInstruction) CLASS CtbTXTTable

aadd(::aEnd,cInstruction)
Return
//--------------------------------------------------------------------------------
METHOD AddOnValid(cInstruction) CLASS CtbTXTRecord

aadd(::aValid,cInstruction)
Return
//--------------------------------------------------------------------------------
METHOD AddOnCount(cInstruction) CLASS CtbTXTRecord

aadd(::aCount,cInstruction)
Return
//--------------------------------------------------------------------------------
METHOD AddOnStruct(aStruct) CLASS CtbTXTRecord

aadd(::aEstrutura,aStruct)
Return
//--------------------------------------------------------------------------------
METHOD AddOnInstruction(cInstrucao) CLASS CtbTXTRecord

aadd(::aConteudo,cInstrucao)
Return
//--------------------------------------------------------------------------------
METHOD ClassName() CLASS CtbTXT
Return ::cClassName
//--------------------------------------------------------------------------------
METHOD FindID(oObjeto,cID) CLASS CtbTXT
Local oFind
Local nX := 1

PARAMTYPE 0  VAR oObjeto      AS OBJECT CLASS CtbTXT,CtbTXTTable

If oObjeto:ClassName() == "CtbTXTTABLE" .And. oObjeto:cID == cID
	oFind := oObjeto
Else
	For nX := 1 To Len(oObjeto:aTables)
		oFind := oObjeto:FindID(oObjeto:aTables[nX],cID)
		If oFind <> Nil
			Exit
		EndIf	
	Next nX
EndIf
Return oFind
//--------------------------------------------------------------------------------
METHOD ReadLayOut(cVersion,cErro,cAviso,bAddField) CLASS CtbTXT

Local aAux     := {}
Local aAux2    := {}
Local cAviso   := ""
Local nX       := 0
Local nY       := 0
Local lXml     := .T.
Local oTable
Local oRecord
Local oSuperior
Local bError

PRIVATE oXml
DEFAULT cErro := ""
DEFAULT cAviso:= ""
DEFAULT bAddField := {|a|.T.}
DEFAULT cAviso:= ""



oXML := XmlParserFile(::cLayOut,"_",@cErro,@cAviso)
If ( Empty(cErro) .And. Empty(cAviso) .And. oXml <> Nil)

	// -----> Verifica se e um xml de layout
	bError := ErrorBlock({|| lXml := .F.})
	Begin Sequence	
		::cDescricao   := oXml:_LayOutCtb:_description:_name:TEXT
		::cDestino     := oXml:_LayOutCtb:_description:_destination:TEXT
		::cObjetivo    := oXml:_LayOutCtb:_description:_object:TEXT
		::cPrazo       := oXml:_LayOutCtb:_description:_delivery:TEXT
		::cAplicativo  := oXml:_LayOutCtb:_description:_LayOutSystem:TEXT
		::cComentario  := oXml:_LayOutCtb:_description:_comment:TEXT
		
		If ValType(oXml:_LayOutCtb:_layout)=="A"
			aAux := oXml:_LayOutCtb:_layout
		Else
			aAux := { oXml:_LayOutCtb:_layout }
		EndIf		
		
		For nX := 1 To Len(aAux)
			If !Empty(cVersion) .And. AllTrim(aAux[nX]:_version:TEXT) == AllTrim(cVersion)
				oXml := aAux[nX]
				Exit
			ElseIf nX == Len(aAux)
				oXml := aAux[nX]
			EndIf
		Next nX
	End Sequence	
	ErrorBlock(bError)

	If lXml 		
		// -----> Verifica os bloco de inicializacao e encerramento do layout
		If Type("oXml:_initiating:_instruction")<>"U"
			If ValType(oXml:_initiating:_instruction)=="A"
				aAux2 := oXml:_initiating:_instruction
			Else
				aAux2 := { oXml:_initiating:_instruction }
			EndIf		  				  		  		
	  		For nY := 1 To Len(aAux2)
	  			::AddOnInit(aAux2[nY]:TEXT)
	  	    Next nY
	  	EndIf
		If Type("oXml:_finishing:_instruction")<>"U"
			If ValType(oXml:_finishing:_instruction)=="A"
				aAux2 := oXml:_finishing:_instruction
			Else
				aAux2 := { oXml:_finishing:_instruction }
			EndIf		  				  		  		
	  		For nY := 1 To Len(aAux2)
	  			::AddOnClose(aAux2[nY]:TEXT)
	  	    Next nY
	  	EndIf
		// -----> Pesquisa os registros do layout
		If ValType(oXml:_Registers:_Register)=="A"
			aAux := oXml:_Registers:_Register
		Else
			aAux := { oXml:_Registers:_Register }
		EndIf
		For nX := 1 To Len(aAux)
	  		oXml:= aAux[nX]
			// -----> Pesquisa o registro pai do registro, se houver
	  		If Type("oXml:_superior")<>"U"
	  			oSuperior := ::FindID(Self,oXml:_superior:TEXT)
	  		Else
		  		oSuperior := Self
		  	EndIf
			// -----> Inicializa o registro na classe
	  		oTable := CtbTXTTable():New(oSuperior,oXml:_id:TEXT,oXml:_description:TEXT)
			// -----> Verifica os bloco de inicializacao e encerramento do registro
	  		If Type("oXml:_initiating:_instruction")<>"U"
	  			If ValType(oXml:_initiating:_instruction)=="A"
					aAux2 := oXml:_initiating:_instruction
				Else
					aAux2 := { oXml:_initiating:_instruction }
				EndIf		  				  		  		
		  		For nY := 1 To Len(aAux2)
		  			oTable:AddOnInit(aAux2[nY]:TEXT)
	  		    Next nY
	  		EndIf
	  		If Type("oXml:_finishing:_instruction")<>"U"
	  			If ValType(oXml:_finishing:_instruction)=="A"
					aAux2 := oXml:_finishing:_instruction
				Else
					aAux2 := { oXml:_finishing:_instruction }
				EndIf		  				  		  		
		  		For nY := 1 To Len(aAux2)
		  			oTable:AddOnClose(aAux2[nY]:TEXT)
	  		    Next nY
	  		EndIf
			// -----> Verifica a tabela do registro se houver
	  		If Type("oXml:_Table")<>"U"
	  			oTable:cAlias := oXml:_Table:TEXT
	  		EndIf
			// -----> Verifica os campos do registro
	  		oRecord := CtbTXTRecord():New(oTable) 
			// -----> Verifica as propriedades dos campos
	  		If Type("oXml:_lines:_Delimited")<>"U"
	  			oRecord:cDelimited := oXml:_lines:_Delimited:TEXT
	  		EndIf
	  		If Type("oXml:_lines:_NumericNull")<>"U"
	  			oRecord:lNumericNull := IIF(oXml:_lines:_NumericNull:TEXT=="T",.T.,.F.)
	  		EndIf
	  		If Type("oXml:_lines:_DecimalPoint")<>"U"
	  			oRecord:cDecimalPoint := oXml:_lines:_DecimalPoint:TEXT
	  		EndIf
	  		If Type("oXml:_lines:_DateFormat")<>"U"
	  			oRecord:cDateFormat := oXml:_lines:_DateFormat:TEXT
	  		EndIf
	  		If Type("oXml:_lines:_DateNull")<>"U"
	  			oRecord:lDateNull := IIF(oXml:_lines:_DateNull:TEXT=="T",.T.,.F.)
	  		EndIf
	  		If Type("oXml:_lines:_StringNull")<>"U"
	  			oRecord:lStringNull := IIF(oXml:_lines:_StringNull:TEXT=="T",.T.,.F.)
	  		EndIf	  		
			// -----> Verifica os bloco de inicializacao e encerramento dos campos
	  		If Type("oXml:_lines:_initiating:_instruction")<>"U"
	  			If ValType(oXml:_lines:_initiating:_instruction)=="A"
					aAux2 := oXml:_lines:_initiating:_instruction
				Else
					aAux2 := { oXml:_lines:_initiating:_instruction }
				EndIf		  				  		  		
		  		For nY := 1 To Len(aAux2)
		  			oTable:AddOnWhile(aAux2[nY]:TEXT)
	  		    Next nY
	  		EndIf
	  		If Type("oXml:_lines:_finishing:_instruction")<>"U"
	  			If ValType(oXml:_lines:_finishing:_instruction)=="A"
					aAux2 := oXml:_lines:_finishing:_instruction
				Else
					aAux2 := { oXml:_lines:_finishing:_instruction }
				EndIf		  				  		  		
		  		For nY := 1 To Len(aAux2)
		  			oTable:AddOnEnd(aAux2[nY]:TEXT)
	  		    Next nY
	  		EndIf
	  		If Type("oXml:_lines:_validline:_instruction")<>"U"
	  			If ValType(oXml:_lines:_validline:_instruction)=="A"
					aAux2 := oXml:_lines:_validline:_instruction
				Else
					aAux2 := { oXml:_lines:_validline:_instruction }
				EndIf
		  		For nY := 1 To Len(aAux2)
		  			oRecord:AddOnValid(aAux2[nY]:TEXT)
	  		    Next nY
	  		EndIf 
	  		If Type("oXml:_lines:_count:_instruction")<>"U"
	  			If ValType(oXml:_lines:_count:_instruction)=="A"
					aAux2 := oXml:_lines:_count:_instruction
				Else
					aAux2 := { oXml:_lines:_count:_instruction }
				EndIf		  				  		  		
		  		For nY := 1 To Len(aAux2)
		  			oRecord:AddOnCount(aAux2[nY]:TEXT)
	  		    Next nY
	  		EndIf 
			// -----> Atualiza a classe com as definicoes dos campos
			If ValType(oXml:_lines:_fields:_field)=="A"
				aAux2 := oXml:_lines:_fields:_field
			Else
				aAux2 := { oXml:_lines:_fields:_field }
			EndIf				
			For nY := 1 To Len(aAux2)
				oXml := aAux2[nY]
				If Eval(bAddField,oXml:_name:TEXT)  //passa como argumento o nome do campo do leiaute xml  
					oRecord:AddOnStruct({oXml:_name:TEXT,oXml:_type:TEXT,Val(oXml:_size:TEXT),Val(oXml:_dec:TEXT)})
					oRecord:AddOnInstrution(oXml:_instruction:TEXT)
				EndIf

			
			Next nY		  		
	    Next nX
	  EndIf
Else
	lXml := .F.
EndIf

Return(lXml)

//--------------------------------------------------------------------------------
METHOD Execute(bBlock) CLASS CtbTXT

Local bError
Local nX			:= 0
Local lExecutado	:= .T.
Local cLinha		:= ""
Local cVar			:= ""
Local cArqECD		:= "CTBSARQ.TXT"
Local nPos          := 0
Local oFile			:= Nil
Local oWrite2		:= Nil

PRIVATE oWrite		:= Nil


DEFAULT bBlock := {|| .T.}

If File(cArqECD)
	FErase(cArqECD)
Endif

// -----> Cria arquivo temporario      
::cTempFile := CriaTrab(,.F.)    
oWrite:=FWFileWriter():New(::cTempFile+".TMP",.F.,/*<nBuffer>*/)


if oWrite:Create(::cTempFile+".TMP")	
	
	// Limpa array do cache
	asize(aPosRest,0)
	
	If oWrite:Exists()
		aEval(::aInit,{|x| &(x) })

		For nX := 1 To Len(::aTables)
			Eval(bBlock,::aTables[nX]:cID,::aTables[nX]:cDescription)
			::aTables[nX]:Execute()	
		Next nX
		
		// Faz a gravacao do arquivo texto dos arquivos que sobraram no cache
		If len(aPosRest) > 0
			For nPos := 1 To Len(aPosRest)
				oWrite:Write(aPosRest[nPos]+CRLF)			
			Next nPos
			
		EndIf
		
		aEval(::aClose,{|x| &(x) })
	Else
		lExecutado := .F.
	EndIf
	oWrite:Close()

EndIf
	
oWrite2 :=FWFileWriter():New(::cTempFile+".TXT",.F.,/*<nBuffer>*/)
	
oFile :=FWFileReader():New(::cTempFile+".TMP",CRLF)

if oWrite2:Create(::cTempFile+".TXT")

	if (oFile:Open()) .and. oWrite2:Exists()
		While (oFile:hasLine())
			cLinha := oFile:GetLine()
			If "@@@" $ cLinha
				For nX := 1 To Len(::aFormul)
					bError     := ErrorBlock({|e| Aviso("Erro","Erro de formula -> "+::aFormul[nX],{"Ok"}) })
					Begin Sequence
						cVar := &(::aFormul[nX])
					End Sequence
					ErrorBlock(bError)
					cLinha := StrTran(cLinha,"@@@"+::aFormul[nX]+"@@@",cVar)
				Next nX
			EndIf
			If  ( ("|I157|" $ cLinha  .And. CS0->CS0_MUDPC != '1')  .or. ("|I157|||0,00||" $ cLinha) )
				/*Condição mantida para pular as linhas de I157 que estão indo vazias, para cada I155 
				é gerado um I157 mesmo não havendo mudança para aquela conta*/
				cLinha :=" "
			ElseIf ("|J800|" $ cLinha .And. !("|9900|" $ cLinha)) .Or. ("|J801|" $ cLinha .And. !("|9900|" $ cLinha))                     
				oWrite2:Write(cLinha)
			Else
				oWrite2:Write(cLinha+CRLF)
			EndIf
			
		EndDo
	
		oWrite2:Close()
        oFile:Close()

	EndIf										
EndIf
	// gero o arquivo no SYSTEM do TSS
	If !Empty(cArqECD)
		Ferase(cArqECD)
		FRename(::cTempFile+".TXT",cArqECD)
	EndIf

	FErase(::cMsgOutPutFile)
	FErase(::cTempFile+".TMP")
	
Return lExecutado

//--------------------------------------------------------------------------------
METHOD Execute() CLASS CtbTXTTable

Local aArea      := GetArea()
Local nX         := 0
Local lValido    := .T.
Local bWhile     :={|| lValido }


aEval(::aInit,{|x| &(x) })

If !Empty(::cAlias)
	If  ::cAlias != "TMPCSBSAL" 
		dbSelectArea(::cAlias)
		bWhile := {|| !Eof() .And. lValido }
	Else
		If Select(::cAlias) > 0
			dbSelectArea(::cAlias)
			bWhile := {|| !Eof() .And. lValido }
			
		Else 
			::cAlias := ""
		EndIf	
	EndIf	
EndIf

While Eval(bWhile)
	If !Empty(::cAlias)
		dbSelectArea(::cAlias)
	EndIf	

	aEval(::aWhile,{|x| lValido := IIf(lValido,&(x),.F.) })

	If lValido 
		ProcRegua( Len(::aTables) )	
		For nX := 1 To Len(::aRecord)
			
			::aRecord[nX]:Execute()
		   	For nX := 1 To Len(::aTables)
				::aTables[nX]:Execute()
				nCont := nX	
					
		    	IncProc( "Registro: " + ::aTables[nX]:cID+":"+::aTables[nX]:cDescription )
				
		   Next nX
		Next nX	

		If !Empty(::cAlias)
			dbSelectArea(::cAlias)
		EndIf
	EndIf	

	aEval(::aEnd,{|x| lValido := IIf(lValido,&(x),.F.) })

	If !Empty(::cAlias) .And. lValido 
		dbSelectArea(::cAlias)
		dbSkip()
	Else
		lValido := .F.
	EndIf
EndDo

aEval(::aClose,{|x| &(x) })

RestArea( aArea )

Return 

//--------------------------------------------------------------------------------
METHOD Execute() CLASS CtbTXTRecord

Local aArea      := GetArea()
Local lValido    := .T.
Local nX         := 0
Local cRecord    := ""
Local bError
Local uConteudo
Local nPos       := 0
Local lPECache 	 := ExistBlock("CTBTXCACHE")
Local nCache	 := 100

aEval(::aValid,{|x| lValido := IIf(lValido,&(x),.F.) })

If lValido
	cRecord += ::cDelimited
	For nX := 1 To Len(::aEstrutura)
		bError     := ErrorBlock({|e| Aviso("Erro","Erro de formula -> "+::oParent:cID+":"+::oParent:cDescription+"/"+::aEstrutura[nX][1],{"Ok"}) })
		If ::aEstrutura[nX][2] <> "F"
			Begin Sequence           
				uConteudo := &(::aConteudo[nX])
			End Sequence
		Else
			uConteudo := ::aConteudo[nX]
		EndIf
		ErrorBlock(bError)
		Do Case
			Case ::aEstrutura[nX][2] == "C"
				If ::aEstrutura[nX][3] == 0 .Or. (Empty(uConteudo) .And. Self:lStringNull)
					cRecord += AllTrim(uConteudo)
				Else
					cRecord += PadR(uConteudo,Self:aEstrutura[nX][3])
				EndIf
			Case ::aEstrutura[nX][2] == "F"
				cRecord += "@@@"+AllTrim(uConteudo)+"@@@"
				::oLayOutCtb:AddFormul(AllTrim(uConteudo))
			Case Self:aEstrutura[nX][2] == "N"
				If ValType(uConteudo) == "C"
					uConteudo := Val(uConteudo)
				EndIf
				If Self:aEstrutura[nX][3]==0
					Self:aEstrutura[nX][3] := 18
				EndIf
				Do Case
					Case Self:lNumericNull .And. uConteudo == 0 .And. !Empty(Self:cDelimited)
						cRecord += ""
					Case Self:lNumericNull .And. uConteudo == 0 .And. Empty(Self:cDelimited)
						cRecord += Space(Self:aEstrutura[nX][3])
					Case !Empty(Self:cDecimalPoint) .And. !Empty(Self:cDelimited)
						cRecord += AllTrim(StrTran(Str(uConteudo,Self:aEstrutura[nX][3],Self:aEstrutura[nX][4]),".",Self:cDecimalPoint))
					Case !Empty(Self:cDecimalPoint) .And. Empty(Self:cDelimited)
						cRecord += StrTran(StrZero(uConteudo,Self:aEstrutura[nX][3],Self:aEstrutura[nX][4]),".",Self:cDecimalPoint)
					Case Empty(Self:cDecimalPoint) .And. !Empty(Self:cDelimited)
						uConteudo := NoRound(uConteudo*(10**(Self:aEstrutura[nX][4])),Self:aEstrutura[nX][4])
						cRecord += AllTrim(Str(uConteudo,Self:aEstrutura[nX][3]))
					Case Empty(Self:lDecimalPoint) .And. Empty(Self:cDelimited)
						uConteudo := NoRound(uConteudo*(10**(Self:aEstrutura[nX][4])),Self:aEstrutura[nX][4])
						cRecord += StrZero(uConteudo,Self:aEstrutura[nX][3])
				EndCase
			Case Self:aEstrutura[nX][2] == "D"
				Do Case
					Case Self:lDateNull .And. Empty(uConteudo)
						cRecord += ""
					Case Empty(Self:cDateFormat)
						cRecord += ECDDateConv(uConteudo)
					OtherWise
						cRecord += ECDDateConv(uConteudo,Self:cDateFormat)
				EndCase
		EndCase
		cRecord += ::cDelimited
	Next nX
	aEval(::aCount,{|x| &(x) })
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto Entrada para alterar valor do cache de gravacao do arquivo texto 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPECache
	nCache := Execblock("CTBTXCACHE",.F.,.F.,)
Endif

If len(aPosRest) <= nCache .and. !Empty(cRecord)
	// Acrescenta o resultado no cache
	aadd(aPosRest,cRecord)
Endif
 			 					
// Faz a gravacao do arquivo texto
If len(aPosRest) == nCache
	
	For nPos := 1 To Len(aPosRest)
		oWrite:Write(aPosRest[nPos]+CRLF)
	Next nPos
	
	asize(aPosRest,0)
EndIf

RestArea(aArea)
Return(lValido)

Function ___CtbTXT()
Return
