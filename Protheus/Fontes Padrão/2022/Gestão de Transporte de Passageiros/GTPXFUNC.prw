#INCLUDE "PROTHEUS.CH"
#INCLUDE "GTPXFUNC.CH"
#INCLUDE 'FWMVCDEF.CH'
#include 'totvs.ch'

Static aGTPTmpTab	:= {}
Static oTableTmp 
Static aStructTmp
Static cQryTmp		:= ""
Static cSelectAnt	:= ""

//-------------------------------------------------------------------
/*/{Protheus.doc} TPNomeLinh(cCodLinha)
Recebe o código da Linha e retorna o nome da Linha

@sample GANomeLinh(cCodLinha)

@return cLinha  Nome da Linha

@param  cCodLinha Codigo da linha
 
@author Hilton T. Brandão - Consultir
@since 14/03/2014
@version P12
/*/
//-------------------------------------------------------------------
Function  TPNomeLinh(cCodLinha,aLinha,cSentido,lReset)
                             
Local cLinha 		:= ""
Local cLocalIni		:= ""
Local cLocalFim		:= ""
Local cIni			:= ""
Local cFim			:= ""

Local nP			:= 0

Local aAux			:= {}

Default cCodLinha 	:= ""
Default aLinha		:= {}	
Default cSentido	:= "1"	//ida
Default lReset		:= .t.

GI2->(DbSetOrder(1)) //GI2_FILIAL+GI2_COD

If ( lReset )
	aLinha := {}
EndIf	

If GI2->(DbSeek(xFilial("GI2") + cCodLinha))
	// Recebe o código da Localidade de Início e Fim dos campos GI2_LOCINI e GI2_LOCFIM	
	cLocalIni	:= POSICIONE("GI2",1,XFILIAL("GI2")+cCodLinha,"GI2_LOCINI")
	cLocalFim	:= POSICIONE("GI2",1,XFILIAL("GI2")+cCodLinha,"GI2_LOCFIM")
		
	// Recebe o Nome da Localidade Início e Fim	
	cIni		:= POSICIONE("GI1",1,XFILIAL("GI1")+cLocalIni,"GI1_DESCRI")
	cFim		:= POSICIONE("GI1",1,XFILIAL("GI1")+cLocalFim,"GI1_DESCRI")

	nP := aScan(aLinha, {|x| Alltrim(x[1]) == cCodLinha})

	If ( nP == 0 )
		
		If ( cSentido == "1" )		
			aAdd(aAux,{cLocalIni,cIni})
			aAdd(aAux,{cLocalFim,cFim})			
		Else
			aAdd(aAux,{cLocalFim,cFim})
			aAdd(aAux,{cLocalIni,cIni})
		EndIf
		
		aAdd(aLinha,{cCodLinha,aClone(aAux)})
	
	Else
		
		If ( cSentido == "1" )
			aLinha[nP,2][1,1] := cLocalIni
			aLinha[nP,2][1,2] := cIni
			aLinha[nP,2][2,1] := cLocalFim
			aLinha[nP,2][2,2] := cFim
		Else
			aLinha[nP,2][1,1] := cLocalFim
			aLinha[nP,2][1,2] := cFim
			aLinha[nP,2][2,1] := cLocalIni
			aLinha[nP,2][2,2] := cIni
		EndIf
		
	EndIf

	If ( cSentido == "1" )
		// Concatena a Descrição da Localidade Inicial + Final
		cLinha := ALLTRIM(cIni) + "/" + ALLTRIM(cFim)
	Else
		cLinha := ALLTRIM(cFim) + "/" + ALLTRIM(cIni)
	EndIf
	
Endif
	
Return(cLinha)

//-----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPGetRules()
Função para buscar parametro cadastrado na Tabela de Parametros GTP (GYF)
  
@params 
	cIdRule: caractere. Código do parâmetro
	lStrToArray: Lógico. .T. - indica que será convertida a string retornada para array
	cToken: caractere. Se o Parâmetro lStrToArray for .t., então um token deverá ser informado (por exemplo ";")
	 	
@return cRet - Conteudo do parametro informado por nIdRule 

@author Fernando Radu Muscalu
@since 10/04/2015
@updated 06/01/2016
	Criado retorno formatado caso o tipo do parâmetro do módulo seja caractere.
@version P12
/*/
//-----------------------------------------------------------------------------------------------------------------
Function GTPGetRules(cIdRule, lStrToArray, cToken, xDefault)

Local cStringTokens := ""
Local aAreaGYF		:= GYF->(GetArea())
Local xRet			:= nil
Local nI			:= 0
Local cPicture		:= ""

Default lStrToArray := .f.
Default cToken		:= ""

If !(Empty(cIdRule))

	GYF->(DbSetOrder(1))
	
	If ( GYF->(DbSeek(xFilial('GYF') + PadR(cIdRule,TamSX3('GYF_PARAME')[01] ))) )
	
		If GYF->GYF_TIPO == '1' //caractere
			xRet := ALLTRIM(GYF->GYF_CONTEU)
		ElseIf GYF->GYF_TIPO == '2' //númerico
			xRet := Val(ALLTRIM(GYF->GYF_CONTEU))
		ElseIf GYF->GYF_TIPO == '3' // lógico
			xRet := IIF(ALLTRIM(GYF->GYF_CONTEU)=='.T.',.T.,.F.)
		EndIf
		
		If !Empty(GYF->GYF_PICTUR)
			cPicture	:= Alltrim(GYF->GYF_PICTUR)
		Endif
		
	Else
		xRet := nil
	EndIf

EndIf

If ValType(xRet) == 'U' .and. ValType(xDefault) <> 'U'
	xRet := xDefault
Endif
//converte cadeia de caracteres em array
If ( (ValType(xRet) == "C" .and. GYF->GYF_TIPO == '1') .and. lStrToArray )
	
	If ( Empty(cToken) )
		
		cStringTokens := ";:/|\#$%&"
		
		For nI := 1 to Len(cStringTokens)
			
			cToken := Substr(cStringTokens, nI, 1)
			
			If ( At(cToken, xRet) > 0)
				Exit
			Endif
			
		Next nI
	
	Endif
	
	xRet := Separa(xRet, cToken)
		
Endif

//Caso seja uma string, então será colocado a formatação no retorno do dado.
If ( ValType(xRet) == "C" )
	xRet := Transform(xRet, cPicture)
Endif

RestArea(aAreaGYF)

Return(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GridToArray
Função utilizada carregar array com base no grid


@author Lucas.Brustolin
@since 15/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function GridToArray( oGrid, aCampos)

Local nQtdLin := oGrid:Length()
Local nQtdCol	:= Len(aCampos)

Local aLinha	:= Array(nQtdLin,nQtdCol)

Local nI,nJ	:= 0

	For nI := 1 To oGrid:Length()
		oGrid:GoLine(nI)
		
		For nJ := 1 To Len(aCampos)
		
			aLinha[nI][nJ] := oGrid:GetValue(aCampos[nJ])
			
		Next nJ
	Next nI
	
Return(aLinha)



//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTTimeNextDay
Função responsável por retornar um array com a data e hora (hh:mm:ss)  

@param 	nHoras: Numérico. Qtd. de Horas que compõe o período 
	
@return aRotina: Array. Vetor multidimensional contendo as informações de menu do programa.
@sample aRotina := MenuDef()

@author Administrador

@since 23/06/2015
@version 1.0
/*/
//----------------------------------------------------------------------------------------------

Function GTTimeNextDay(cHora, dDate, cTime)

Local cTimeAfter	:= ""

Local nHrsSoma		:= 0

Local aAux			:= {}
Local aPerAfter		:= {}

nHrsSoma := cValToChar(SomaHoras(cTime, cHora))

aAux := Separa(cValToChar(nHrsSoma), ".")

If ( Len(aAux) > 1 )
	cTimeAfter := PadL(aAux[1],2,"0") + ":" + PadR(aAux[2],2,"0") + ":00"
ElseIf (Len(aAux) == 1)	 
	cTimeAfter := PadL(aAux[1],2,"0") + ":00:00"
Else	
	cTimeAfter := "00:00:00"
Endif	 

aPerAfter := Time2NextDay(cTimeAfter, dDate)

Return(aPerAfter)


//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTTimeValid
Retorna a Data e hora do 

@param 	nHoras: Numérico. Qtd. de Horas que compõe o período 
	
@return aRotina: Array. Vetor multidimensional contendo as informações de menu do programa.
@sample aRotina := MenuDef()

@author Administrador

@since 23/06/2015
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function GTTimeValid(cTime, lHrReal, lShowMsg, cMsgProb, cMsgSolu)

Local cHora	:= ""

Local lRet	:= .t.
Local nI	:= 1
Local aHora	:= {}

Default lHrReal 	:= .f.
Default lShowMsg	:= .t.
Default cMsgProb	:= ""
Default cMsgSolu	:= ""

cHora := Alltrim(cTime)

If ( At(":", cHora) == 0)
	
	If ( Len(cHora) < 4 .or. Len(cHora) > 6 .or. Len(cHora) == 5)
	
		lRet := .f.
	
	Else
	
		If (Len(cHora) == 4)
			cHora := Substr(cHora,1,2) + ":" + Substr(cHora,3)
		Else
			cHora := Substr(cHora,1,2) + ":" + Substr(cHora,3,2) + ":" + Substr(cHora,5,2)
		Endif
	
	Endif

Endif	

aHora := Separa(cHora, ":")

For nI := 1 to len(aHora)
	
	If ( nI == 1 )
		If ( Val(aHora[nI]) < 0 )
			lRet := .f.
			Exit
		ElseIf (lHrReal)
			
			If ( Val(aHora[nI]) > 23 )
				lRet := .f.
				Exit
			Endif
								
		Endif	
	Endif
	
	If (lRet .and. nI > 1)
		
		If ( Val(aHora[nI]) > 59  .or. Val(aHora[nI]) < 0 )
			lRet := .f.
			Exit
		Endif
		
	Endif
	
Next nI

If ( !lRet )

	cMsgProb := STR0061	//"Formato do horário é inválido."
	cMsgSolu := STR0062	//"Permitido apenas como horários válidos: hora entre 00 e 23 e minutos entre 00 e 59."
	
	If ( lShowMsg )
		FwAlertHelp(cMsgProb, cMsgSolu, "Horário incorreto")
	EndIf
		
Endif

Return(lRet)

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTDeltaTime
Retorna a Data e hora do 

@param 	nHoras: Numérico. Qtd. de Horas que compõe o período 
	
@return aRotina: Array. Vetor multidimensional contendo as informações de menu do programa.
@sample aRotina := MenuDef()

@author Administrador

@since 23/06/2015
@version 1.0
/*/
//----------------------------------------------------------------------------------------------

Function GTDeltaTime(dDtIni, cHoraIni, dDtFim, cHoraFim)

Local nHoras	:= 0

Local cHorasRet := ""

Local aTime		:= {}

Default dDtIni := dDatabase 
Default dDtFim := dDatabase

nHoras := DataHora2Val(dDtIni,cHoraIni,dDtFim,cHoraFim,"H")
cHorasRet := cValToChar(nHoras)

aTime := Separa(cHorasRet,".")

If Len(aTime) > 1
	cHorasRet := PadL(aTime[1],2,"0") + ":" + PadR(aTime[2],2,"0")
Else
	cHorasRet := PadL(aTime[1],2,"0") + ":00"
Endif	 

Return(cHorasRet)


/*/{Protheus.doc} GTPxHr2Str
(long_description)
@type function
@author jacomo.fernandes
@since 24/01/2019
@version 1.0
@param xVal, variável, (Descrição do parâmetro)
@param cFormat, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPxHr2Str(xVal,cFormat)
Local cRet			:= ""
Local aFormatHr		:= Separa(cFormat,":") 
Local cSeparador	:= ":" 
Local aHour			:= nil
Local n1			:= 0
Local cRetFormat	:= ""

If ValType(xVal) == 'N'
	xVal := cValToChar(xVal)
Endif

If ( At(".",xVal) > 0 )
	cSeparador := "."	
ElseIf ( At(":",xVal) > 0 )
	cSeparador := ":"
Endif

aHour := Separa(xVal, cSeparador)

For n1	:= 1 To Len(aFormatHr)
	If n1 <= Len(aHour)
		If "H" $ aFormatHr[n1] 
			cRet += PadL(aHour[n1],Len(aFormatHr[n1]),"0")
		Else
			cRet += PadR(aHour[n1],Len(aFormatHr[n1]),"0")
		Endif   
	Else
		If "H" $ aFormatHr[n1] 
			cRet += PadL("",Len(aFormatHr[n1]),"0")
		Else
			cRet += PadR("",Len(aFormatHr[n1]),"0")
		Endif
	Endif
	If n1 > 1
		cRetFormat += ":"
	Endif
	cRetFormat += Replicate('9',Len(aFormatHr[n1]))
	
Next

cRet := Transform(cRet, "@R " + cRetFormat )

Return cRet

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GTFormatHour

Esta função efetua a formação de horas no formato passado por parâmetro (cFormat). As máscaras aceitas 
pela função são:

cFormat 
	- 9999
	- 99999
	- 99:99
	- 99:99:99
	- 99.99
	- 99.99.99
	- 99h
	- 99h99
	- 99h99m99s

@params:
	xHour:		Undefined. A hora poderá ser passada como tipo string ou tipo numérico.
	cFormat:	String. Objeto de classe FormModelStruct
	 
@return: 
	cHour:	String. Retorno da hora formata de acordo com a máscara. 

@sample: cHour := GTFormatHour(xHour, cFormat)

@author Fernando Radu Muscalu/Lucas Brustolin

@since 18/08/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function GTFormatHour(xHour, cFormat)

Local cHour			:= ""	
Local cPureForm		:= "" 
Local cSeparator	:= ""
Local cSignal		:= ""

Local nI			:= 1
Local nLenAux		:= 2
Local nPSignal		:= 0

Default cFormat := "99:99:99"

If ( Valtype(xHour) == "N" )
	cHour := cValToChar(xHour)
Else
	cHour := xHour
Endif 

If ( At(".",cHour) > 0 )
	cSeparator := "."	
ElseIf ( At(":",cHour) > 0 )
	cSeparator := ":"
Endif

nPSignal := At("-",cHour)

If ( nPSignal > 0 )
	cSignal = "-"
	cHour := Substr(cHour,nPSignal+1)
EndIf

If ( !Empty(cSeparator) )
	
	aHour := Separa(cHour, cSeparator)
	
	cHour := ""
	
	For nI := 1 to Len(aHour)
	
		If ( Len(Alltrim(aHour[nI])) == 1 .and. nI == 1 )
			aHour[nI] := "0" + Alltrim(aHour[nI])
		ElseIf Len(Alltrim(aHour[nI])) == 1 .and. nI <> 1
			aHour[nI] := Alltrim(aHour[nI]) + "0" 	 
		Endif
		If  nI == 1
			nLenAux := Len(aHour[nI])
		Endif
		cHour += aHour[nI]
		
	Next nI

Endif

For nI := 1 to Len(cFormat)
	
	If ( IsDigit(Substr(cFormat, nI, 1)) )
		cPureForm += Substr(cFormat, nI, 1)
	Endif

Next nI

If ( Len(cHour) <= 2)
	cHour := PadL(cHour,nLenAux,"0")+"00"
Else
	cHour := PadL(cHour,nLenAux,"0")+ PadR(Substr(cHour,nLenAux+1),2,"0")
EndIf

cHour := cSignal + Transform(cHour, "@R " + cFormat )

Return(cHour)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TPSXBGI1FIL()
Função generica para aplicar filtros a consulta padrão GI1 - (Localidades)
@sample	TPSXBGI1FIL()
@author	Lucas.Brustolin
@since		12/01/2016
@version	P12
/*/
//-----------------------------------------------------------------------------------------

Function TPSXBGI1FIL()         

Local oModel	:= FwModelActive()
Local oGrid	:= Nil
Local lRet 	:= .F.

	// ---------------------------------------------------------+
	// Filtra as localidades para a tela de Trechos x Horários  |
	// ---------------------------------------------------------+ 	
	If FwIsInCallStack("GTPA302B") 
	
		If oModel:GetId() == "GTPA302B" 
		
			oGrid := oModel:GetModel("ITEM")
			
			If oGrid <> Nil .And. ( oGrid:SeekLine( {{"GIE_IDLOCP", GI1->GI1_COD}} ) .Or. ;
									   oGrid:SeekLine( {{"GIE_IDLOCD", GI1->GI1_COD}} )	 )    
			
				lRet := .T.
			EndIf
		
		EndIf
	ElseIf FwIsInCallStack("GTPA408") 
	
		If oModel:GetId() == "GTPA408" 
		
			oGrid := oModel:GetModel("GIEDETAIL")
			
			If oGrid <> Nil .And. ( oGrid:SeekLine( {{"GIE_IDLOCP", GI1->GI1_COD}} ) .Or. ;
									   oGrid:SeekLine( {{"GIE_IDLOCD", GI1->GI1_COD}} )	 )    
			
				lRet := .T.
			EndIf
		
		EndIf
	
	EndIf	


Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TPStrZeroCp()
Acrescenta zeros a esquerda com base no tamanho do campo.
 
@sample	TPStrZeroCp(oView, cIDView, cField, xValue)
@Param  oView - Objeto: Objeto View
@Param	cIDView - String : ID do submodelo View
@Param	cField	- String : Nome do Campo
@Param	xValue	- Valor a ser inserido no campo
@author	Lucas.Brustolin
@since	09/03/2017
@version P12
/*/
//------------------------------------------------------------------------------------------
Function TPStrZeroCp(oView, cIDView, cField, xValue)

Local oSubMdl	:= oView:GetModel():GetModel(oView:GetSubMldId(cIDView))
Local nTamanho	:= TamSx3(cField)[1]

//-- Acresenta zeros a esquerda
oSubMdl:SetValue(cField, StrZero(Val(xValue), nTamanho) )
//-- Refresh na tela
oView:Refresh(cIDView)

Return 

/*/{Protheus.doc} GTPCastType
	Função de conversão de tipos de dados
	@type  Function
	@author Fernando Radu Muscalu
	@since 27/03/2017
	@version 1
	@param xValue, qualquer, Tipo de Dado a ser convertido
			cConvType, caractere, para qual tipo será convertido: 
				"C" - Caractere;
				"N" - Numérico;
				"D" - Data;
				"L" - Lógico
	@return xRet, qualquer, Tipo de Dado que foi convertida
	@example
	(examples)
	@see (links_or_references)
/*/
Function GTPCastType(xValue,cConvType,cFormat)

Local xRet

Default cFormat := ""

Do Case
Case ( ValType(xValue) == "C" )

	If ( cConvType == "C" )

		If ( At(":",cFormat) > 0 )	//vamos considerar que seja hora
			xRet := GTFormatHour(xValue, cFormat)
		ElseIf ( !Empty(cFormat) )	
			xRet := Transform(xValue,cFormat)
		Else
			xRet := xValue
		EndIf

	ElseIf ( cConvType == "N" )
		xRet := Val(xValue)
	ElseIf ( cConvType == "D" )
		
		If ( At("/",xValue) > 0 )
			xRet := CToD(xValue)
		ElseIf ( At("-",xValue) = 5 )
			xRet := STOD( StrTran(xValue,'-','') )
		Else
			xRet := STOD(xValue)
		EndIf

	ElseIf ( cConvType == "L" )
		
		If ( At("T",xValue) > 0 )
			xRet := .t.
		Else
			xRet := .f.
		Endif

	EndIf

Case ( ValType(xValue) == "N" )

	If ( cConvType == "C" )
		
		If ( Empty(cFormat) )
			xRet := cValToChar(xValue)
		Else
			xRet := Transform(xValue,cFormat)	
		EndIf	

	ElseIf ( cConvType == "N" )
		xRet := xValue
	ElseIf ( cConvType == "D" )
		xRet := xValue
	ElseIf ( cConvType == "L" )
		
		If ( xValue <= 0 )
			xRet := .f.
		Else
			xRet := .T.
		Endif

	EndIf

Case ( ValType(xValue) == "D" )

	If ( cConvType == "C" )
		
		If ( Empty(cFormat) .or. Alltrim(Lower(cFormat)) $ "dd/mm/yyyy|dd/mm/aaaa" )
			xRet := DToC(xValue)
		ElseIf ( Alltrim(Lower(cFormat)) $ "yyyymmdd|aaaammdd" )
			xRet := DToS(xValue)
		EndIf

	ElseIf ( cConvType == "N" )
		xRet := xValue
	ElseIf ( cConvType == "D" )
		xRet := xValue
	ElseIf ( cConvType == "L" )
		xRet := xValue
	EndIf

Case ( ValType(xValue) == "L" )

	If ( cConvType == "C" )
		xRet := IIf(xValue,"T","F")
	ElseIf ( cConvType == "N" )
		xRet := IIf(xValue,1,0)
	ElseIf ( cConvType == "D" )
		xRet := xValue
	ElseIf ( cConvType == "L" )
		xRet := xValue
	EndIf

Case (  Valtype(xValue) == "U" )

	If ( cConvType == "C" )
		xRet := ""
	ElseIf ( cConvType == "N" )
		xRet := 0
	ElseIf ( cConvType == "D" )
		xRet := dDatabase
	ElseIf ( cConvType == "L" )
		xRet := .f.
	ElseIf ( cConvType == "M" )
		xRet := ""	
	EndIf
	
End Case

Return(xRet)

/*/{Protheus.doc} GTPOrdVwStruct
	Organiza a ordem de campos de acordo com o array aNewOrder. Neste array é esperado um array multidimensional
	que possua em cada elemento, um subarray com o campo que antecede e campo que precede. 
	Por Exemplo: {{"CAMPO A", "CAMPO B"},{"CAMPO B", "CAMPO C"},{"CAMPO C","CAMPO D"},...}
	@type  Function
	@author Fernando Radu Muscalu
	@since 06/04/2017
	@version 1
	@param	oStruct, objeto, instância da classe FWFormViewStruct()
			aNewOrder, array, array com os campos que deverão ser ordenados (veja a descrição acima)
	@return nil, nulo, sem retorno
	@example
	(examples)
	@see (links_or_references)
/*/
Function GTPOrdVwStruct(oStruct,aNewOrder)

Local nI	:= 0

For nI := 1 to Len(aNewOrder)
	
	If ( oStruct:HasField(aNewOrder[nI,1]) .And. oStruct:HasField(aNewOrder[nI,2]) )  
	
		cOrdem := oStruct:GetProperty(aNewOrder[nI,1], MVC_VIEW_ORDEM)
	
		GTPOrdStruct(oStruct,StrZero(++Val(cOrdem),2),aNewOrder[nI,2])
	
	EndIf
	
Next nI

Return()

/*/{Protheus.doc} GTPOrdStruct
	Função para Ordenação de Campos da Estrutura de um submodelo da view (FWFormView)
	@type  Function
	@author Fernando Radu Muscalu
	@since 06/04/2017
	@version 1
	@param	oStrView, Objeto, Obj instanciado da classe FwFormStruct
			cNewOrder, Caractere, Nova Ordem definida
			cField, Caractere, Campo que passa a ter a nova ordem
	@return nil, nulo, sem retorno
	@example
	(examples)
	@see (links_or_references)
/*/
Function GTPOrdStruct(oStrView,cNewOrder,cField)

Local cNext		:= ""

Local nI		:= 0

Local aFldStr	:= oStrView:GetFields()

nI := aScan(aFldStr,{|x| Alltrim(x[2]) == Alltrim(cNewOrder) })

If ( nI > 0 )
	
	oStrView:SetProperty(cField, MVC_VIEW_ORDEM, cNewOrder)
	
	cNext := StrZero(++Val(aFldStr[nI,2]),2)
	GTPOrdStruct(oStrView,cNext,aFldStr[nI,1])	

Else
	oStrView:SetProperty(cField, MVC_VIEW_ORDEM, cNewOrder)
Endif

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TPDISPRANGE
Verifica a disponibilidade do range informado nos parametros.
@sample		TPDISPRANGE()
@author		Inovação - Serviços
@since		27/03/17
@version	P12
/*/
//-------------------------------------------------------------------
Function GTPDISPRANGE(cTpDoc, cComple, cTipPas, cSerie, cSubSer, cNumCom, cNumIni, cNumFim,cStatus,cLote)

Local cAliasTemp	:= GetNextAlias()
Local cWhere		:= "%"
Local lRet 			:= .F.

Default cLote 		:= ""

cWhere += " AND GII_STATUS IN " + FormatIn(cStatus,",")   
If !Empty(cLote)
	
	If IsInCallStack("GTPA106C") //-- Se for chamado pela Baixa Alocação
		cWhere += " AND GII_LOTALO = '"+ cLote +"' "
	Else
		cWhere += " AND GII_LOTREM = '"+ cLote +"' "
	EndIf
	
EndIf
cWhere += "%" 

	BeginSql Alias cAliasTemp
	
		SELECT Count(*) TOTAL
			FROM %Table:GII% GII
			WHERE 
				GII_FILIAL 		= %xFilial:GII% 
			 	AND GII_TIPO  	= %Exp:cTpDoc%
			 	AND GII_COMPLE  = %Exp:cComple%
			 	AND GII_TIPPAS  = %Exp:cTipPas%
			 	AND GII_SERIE  	= %Exp:cSerie%
			 	AND GII_SUBSER  = %Exp:cSubSer%
			 	AND GII_NUMCOM  = %Exp:cNumCom%
			 	AND GII_BILHET  Between %Exp:cNumIni% AND %Exp:cNumFim% 
			 	AND GII_UTILIZ = 'F'
			 	AND %NotDel%
			 	%Exp:cWhere%
	EndSql

	DbSelectArea(cAliasTemp)
	
	If (cAliasTemp)->TOTAL  == ( ( Val(cNumFim) - Val(cNumIni) ) + 1 ) 
		lRet := .T.
	EndIf
		
	(cAliasTemp)->(DbCloseArea())

Return(lRet) 
//-------------------------------------------------------------------
/*/{Protheus.doc} GtpxValHr
Valida o Formato da hora informado
@sample	GtpxValHr(.F.,.T.)
@author	Inovação - Serviços
@since		19/04/17
@version	P12
/*/
//-------------------------------------------------------------------
Function GtpxValHr(lDia,lPositivo)
Local lRet		:= .T.
Local cDelim	:= "" 
Local aHora	:= {}
Local nI		:= 0
Local cCampo	:= ReadVar()
Local cHora	:= &(cCampo)
Default lDia	:= .T.
Default lPositivo	:= .T.

cCampo		:= SubStr(cCampo,At('>',cCampo)+1)
cPicture	:= AllTrim(X3Picture('GI2_HRIDA'))

If Empty(cHora)
	cHora := "00:00"
Endif

If !Empty(cPicture)
	cHora	:= Transform(cHora,cPicture)
Endif
If ( At(":",cHora) > 0 )
	cDelim := ":"
Endif

If ( !Empty(cDelim) )
	
	aHora := Separa(cHora, cDelim)
	
	cHora := ""
	
	For nI := 1 to Len(aHora)
		If Len(Alltrim(aHora[nI])) == 1 
			lRet := .F.
			Exit
		ElseIf lPositivo .and. At("-",aHora[nI])
			lRet := .F.
		ElseIf Alltrim(aHora[nI]) < "00" 
			lRet := .F. 	 
		ElseIf nI == 1 .and. lDia .and. Alltrim(aHora[nI]) > "23" 
			lRet := .F.
		ElseIf nI > 1 .and. Alltrim(aHora[nI]) > "59"
			lRet := .F.
		Endif
		
		If !lRet
			Help(,,,"GtpxValHr",STR0048, 1, 0 ) //'Formato da Hora invalida'
			Exit
		Endif
	Next nI

Endif

Return lRet

/*/{Protheus.doc} GTPXRmvFld
Função gernerica que valida se o campo existe, se existir remove o campo da estrutura
@type function
@author jacomo.fernandes
@since 30/03/2017
@version 12.0
@param oStruct, Object , Estrutura do modelo
@param cField, Char, Campo a ser removido
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)

/*/
Function GTPXRmvFld(oStruct,cField)
If oStruct:HasField(cField)
	oStruct:RemoveField(cField)
Endif

Return

/*/{Protheus.doc} G408AExistTable()
    Define as estruturas do MVC - View e Model
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 13/06/2017
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPExistTable(cAlias)

Local lRet  	:= .f.

Default cAlias := aTail(aGTPTmpTab)[1]

If ( lRet := aScan(aGTPTmpTab,{|x| Alltrim(x[1]) == Alltrim(cAlias)}) > 0 ) 

	If ( lRet := !Empty(cAlias) )
		
		(cAlias)->(DbGoTop())
		
		lRet := (cAlias)->(!Eof()) 

	EndIf

EndIf

Return(lRet)

/*/{Protheus.doc} GTPFld2Str()
    Converte campos das estruturas do MVC para string
    @type  Function
    @author Fernando Radu Muscalu
    @since 14/06/2017
    @version version
    @param	oStructMVC, objeto, instância ou da classe FwFormModelStruct ou da FWFormViewStruct
			lStr4Qry, lógico, .t. - Os campos carregados são para utilização em query (devem existir 
			no banco de dados)
    @return cFldStr, caractere, cadeia de campos separados por vírgula.
    @example
    cFldStr := GTPFld2Str(oStructMVC,.t.) -> Ex: "CAMPO1, CAMPO2, ..., CAMPON"
    @see (links_or_references)
/*/
Function GTPFld2Str(oStruct,lStr4Qry,aFldConv,lReset,lSetDefault,lQuebra,cTabAlias)

Local cFldStr 	:= ""
Local cAliasTab	:= ""

Local nI		:= 0	
Local nInd		:= 0

Local aFldStruct:= {}

Default lStr4Qry	:= .f.	//Consversão para Query
Default aFldConv	:= {}
Default lReset		:= .t.
Default lSetDefault	:= .f.
Default lQuebra		:= .f.
Default cTabAlias	:= ""	//JCA: DSERGTP-8012

If ( Upper(Alltrim(oStruct:ClassName())) == "FWFORMMODELSTRUCT" )	

	nInd 		:= 3
	nIndTipo	:= 4
	nIndTam		:= 5
	cAliasTab 	:= oStruct:GetTable()[1]
	aFldStruct	:= oStruct:GetFields()
	
ElseIf (Upper(Alltrim(oStruct:ClassName())) == "TABLESTRUCT" )

	nInd		:= 1
	nIndTipo 	:= 2
	nIndTam		:= 3
	cAliasTab	:= oStruct:cAlias
	aFldStruct	:= oStruct:aFields
	
EndIf

If ( lReset )
	aFldConv := {}
EndIf	

For nI := 1 to Len(aFldStruct)

	If ( lStr4Qry )
		lOk := (cAliasTab)->(FieldPos(aFldStruct[nI,nInd])) > 0
		aAdd(aFldConv,{aFldStruct[nI,nInd],aFldStruct[nI,nIndTipo],aFldStruct[nI,nIndTam]})
	Else
		lOk := .t.
	EndIf

	If ( lOk )
	
		If ( lSetDefault .and. lStr4Qry )
			
			If ( aFldConv[Len(aFldConv),2] $ "C|D|L" )
				cFldStr += "'" + Space(aFldConv[Len(aFldConv),3]) + "'"
			ElseIf ( aFldConv[Len(aFldConv),2] == "N" )
				cFldStr += GtpCastType(0,"C")
			EndIf
			//JCA: DSERGTP-8012
			cFldStr += Space(1) + Iif(!Empty(cTabAlias),cTabAlias + ".","") + aFldConv[Len(aFldConv),1] + ", " + Iif(lQuebra,chr(13),"")
			 
		Else
			//JCA: DSERGTP-8012
			cFldStr += Iif(!Empty(cTabAlias),cTabAlias + ".","") + aFldStruct[nI,nInd] + ", " + Iif(lQuebra,chr(13),"")
		EndIf				
	EndIf

Next nI

cFldStr := SubStr(cFldStr,1,Rat(",",cFldStr)-1)

Return(cFldStr)

/*/{Protheus.doc} GTPRndNextInt()
    Arredonda para o próximo nro inteiro
    @type  Function
    @author Fernando Radu Muscalu
    @since 20/06/2017
    @version version
    @param nNumber, numérico, valor a ser arredondado
    @return ,numérico, valor arredondado para o próximo inteiro
	
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPRndNextInt(nNumber)

Local nNxtNro	:= 0
Local nCalcDec	:= nNumber - int(nNumber) 

If (nCalcDec > 0)
	nNxtNro := nNumber + ( 1 - (nNumber - int(nNumber)) )
Else
	nNxtNro := nNumber
EndIf	

Return(nNxtNro)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPGetErrorMsg

Função responsável para retornar em string o erro que ocorre no MVC, validações 
dentro do Modelo de dados.

@sample	GTPGetErrorMsg()
@author    Fernando Radu Muscalu
@since     26/06/2017
@version 	12.1.016
/*/
//------------------------------------------------------------------------------
Function GTPGetErrorMsg(oModel)

Local cErrorMessage	:= ""
Local aErro 			:= oModel:GetErrorMessage()

If !Empty(aErro[1])
	cErrorMessage += STR0052 + " [" + AllToChar( aErro[1] ) + "]" + chr(13)+ chr(10)	//"Id do formulário de origem: "
Endif
If !Empty(aErro[2])	
	cErrorMessage += STR0053 + " [" + AllToChar( aErro[2] ) + "]" + chr(13)+ chr(10)	//"Id do campo de origem: "
Endif
If !Empty(aErro[3])	
	cErrorMessage += STR0054 + " [" + AllToChar( aErro[3] ) + "]" + chr(13)+ chr(10)	//"Id do formulário de erro: "
Endif
If !Empty(aErro[4])	
	cErrorMessage += STR0055 + " [" + AllToChar( aErro[4] ) + "]" + chr(13)+ chr(10)	//"Id do campo de erro: "
Endif
If !Empty(aErro[5])	
	cErrorMessage += STR0056 + " [" + AllToChar( aErro[5] ) + "]" + chr(13)+ chr(10)	//"Id do erro: "
Endif
If !Empty(aErro[6])	
	cErrorMessage += STR0057 + " [" + AllToChar( aErro[6] ) + "]" + chr(13)+ chr(10)	//"Mensagem do erro: "
Endif
If !Empty(aErro[7])	
	cErrorMessage += STR0058 + " [" + AllToChar( aErro[7] ) + "]" + chr(13)+ chr(10)	//"Mensagem da solução: "
Endif
If !Empty(aErro[8])	
	cErrorMessage += STR0059 + " [" + AllToChar( aErro[8] ) + "]" + chr(13)+ chr(10)	//"Valor atribuído: "
Endif
If !Empty(aErro[9])	
	cErrorMessage += STR0060 + " [" + AllToChar( aErro[9] ) + "]"			//"Valor anterior: "
Endif

Return(cErrorMessage)

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPXGerViag
Função utilizada para Componentização da geração das viagens baseado nos parametros informados:
Somente para viagens do tipo 'NORMAL'

@sample		GTPXGerViag()
@return		lRet
@author		Mick William da Silva
@since		28/07/2017
@version	P12
@param	cCodLin		->	Código da Linha (F3 = GI2) 	Ex.: "TESTE"
@param	cSentido	->	Sentido 1-IDA e 2-Volta		Ex.: "1"
@param	cCodHor		->	Código Horário (F3 = GID) 	Ex.: "12" 
@param	dDtIni		->	Data Incial da Viagem.	Ex.: "20170701"
@param	dDtFim		->	Data Final da Viagem.	Ex.: "20170730"
@param	aRecurso	-> Passar a Seguencia(G55_SEQ),Tipo(1-Colaborador) e Tipo de Colaborador(F3 = GYK). Ex.: aAdd(aRecurso,{"002",'1','01'})
@param	cCodExcl	->	Código da Viagem para Exclusão.Se o mesmo for informado o sistema saberá que é uma exclusão. Ex.: "000048"

/*/
//--------------------------------------------------------------------------------------------------------

Function GTPXGerViag(cCodLin,cSentido,cCodHor,dDtIni,dDtFim,aRecurso,cCodExcl,cTipo, cCodContr, cKmProvavel)

// VARIAVEIS SISTEMA
	Local oMdlViagem	:= Nil
	Local oSubMdlGYN	:= Nil
	Local oSubMdlG55	:= Nil
	Local oSubMdlGQE	:= Nil
	Local cAliasQry		:= ""
	Local lRet			:= .T.
	Local n1			:= 0
	Local nR			:= 0
	Local cExclui		:= .F.
// ATRIBUIÇÃO DEFAULT 
	DEFAULT cCodHor		:= ""
	DEFAULT dDtIni		:= dDatabase
	DEFAULT dDtFim 		:= dDatabase
	DEFAULT aRecurso	:= {}
	DEFAULT	cSentido	:= "1"
	DEFAULT cTipo		:= "1"
	DEFAULT cCodContr	:= ""
	DEFAULT cKmProvavel := "0"

//Constante
	#Define NORMAL 		'1'
	#Define NAOBLOQ		'2'


	IF valtype(cCodExcl) <> "U"
		IF !( Empty(cCodExcl) )
			cExclui := .T.
		EndIf
	EndIf


// --------------------------------------------------+
// QUERY BUSCA OS HORARIOS ORDENADO PELA SEQUENCIA.  |
// --------------------------------------------------+
	IF !( cExclui )
		cAliasQry := GetNextAlias()

		BeginSql Alias cAliasQry
			SELECT 	GIE_CODGID,
			GIE.GIE_SEQ,
			GIE.GIE_LINHA,
			GIE.GIE_SENTID,
			GIE.GIE_HORLOC,
			GIE.GIE_IDLOCP,
			GIE.GIE_HORDES,
			GIE.GIE_IDLOCD
			FROM %TABLE:GIE% GIE
			WHERE  GIE.GIE_FILIAL =  %xfilial:GIE%
			AND  GIE.GIE_CODGID = %Exp:cCodHor%
			AND GIE.GIE_HIST = '2'
			AND GIE.%NotDel%
			Order by GIE.GIE_SEQ
		EndSql


		If (cAliasQry)->( !Eof() )
					
			INCLUI := .T.
	 	
			oMdlViagem := FwLoadModel("GTPA300")
			oMdlViagem:SetOperation(MODEL_OPERATION_INSERT)
			oMdlViagem:Activate()
		 
			If oMdlViagem:IsActive()

				oSubMdlGYN := oMdlViagem:GetModel('GYNMASTER')
				oSubMdlG55 := oMdlViagem:GetModel('G55DETAIL')
				oSubMdlGQE := oMdlViagem:GetModel('GQEDETAIL')
		
				oSubMdlGYN:SetValue('GYN_TIPO'	, cTipo )
				oSubMdlGYN:SetValue('GYN_LINCOD', (cAliasQry)->GIE_LINHA )
				oSubMdlGYN:SetValue('GYN_LINSEN', (cAliasQry)->GIE_SENTID )
			// Atribuindo o código do horário os trechos são inseridos via gatilho.	
				oSubMdlGYN:SetValue('GYN_CODGID', (cAliasQry)->GIE_CODGID )
				oSubMdlGYN:SetValue('GYN_DTINI'	, StoD(dDtIni) )
				oSubMdlGYN:SetValue('GYN_DTGER' , DDATABASE )
				oSubMdlGYN:SetValue('GYN_HRGER'	, SubStr(TIME(),1,2) + SubStr(TIME(),4,2) )
				oSubMdlGYN:SetValue('GYN_MSBLQL', NAOBLOQ )
				oSubMdlGYN:SetValue('GYN_KMPROV', val(cKmProvavel) )
				
				If GYN->(FieldPos('GYN_CODGY0')) > 0
					oSubMdlGYN:SetValue('GYN_CODGY0', cCodContr)
				Endif

				For n1 := 1 To Len(aRecurso)

				//-- 	Atribui os recursos para os trechos
					IF 	oSubMdlG55:SeekLine({ {'G55_SEQ', aRecurso[n1][1] } } )
						oSubMdlGQE:LoadValue("GQE_SEQ"		, aRecurso[n1][1])
						oSubMdlGQE:LoadValue("GQE_TRECUR"	, aRecurso[n1][2])
						oSubMdlGQE:LoadValue("GQE_TCOLAB"	, aRecurso[n1][3])
						oSubMdlGQE:LoadValue("GQE_RECURS"	, aRecurso[n1][4])
					Else
						If  ( !Empty(aRecurso[n1][2]) .Or. !Empty(aRecurso[n1][3]) )
							For nR := 1 To oSubMdlG55:Length()
								oSubMdlG55:GoLine(nR)
								If Empty (oSubMdlGQE:GetValue('GQE_SEQ'))
									oSubMdlGQE:LoadValue("GQE_SEQ"		, oSubMdlG55:GetValue('G55_SEQ') )
									oSubMdlGQE:LoadValue("GQE_TRECUR"	, aRecurso[nR][2])
									oSubMdlGQE:LoadValue("GQE_TCOLAB"	, aRecurso[nR][3])
									oSubMdlGQE:LoadValue("GQE_RECURS"	, aRecurso[nR][4])
								EndIf
			
							Next nR
						EndIf
					EndIF


				Next n1
			
				(cAliasQry)->( DbSkip() )
						

				If oMdlViagem:VldData()
					oMdlViagem:CommitData(oMdlViagem)
				Else
					lRet := .F.
				//	JurShowErro( oMdlViagem:GetModel():GetErrormessage() )
				EndIf
				
				oMdlViagem:DeActivate()

			EndIf
	
		EndIf
		(cAliasQry)->(DbCloseArea())
	Else
		INCLUI := .F.
		oMdlViagem := FwLoadModel("GTPA300")
		oMdlViagem:SetOperation(MODEL_OPERATION_DELETE)
	 	
		BEGIN TRANSACTION
			DbSelectArea("GYN")
			GYN->(DbSetOrder(1))
		     
			If GYN->( DbSeek(xFilial("GYN") + cCodExcl ) )
		    
				oMdlViagem:Activate()
				If oMdlViagem:IsActive()
					If oMdlViagem:VldData()
						oMdlViagem:CommitData()
					Else
						JurShowErro( oMdlViagem:GetErrorMessage() )
						DisarmTransaction()
						lRet := .F.
					EndIf
		 		
				EndIf
			EndIf
		
		END TRANSACTION

	EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPXCBox(cCampo)
Busca o ComboBox do Campo
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function GTPXCBox(cCampo,nResult,lTodos)
Local xRet		:= nil
Local aArea		:= GetArea()
Default nResult	:= 0
Default lTodos	:= .F.
SX3->(DbSetOrder(2)) //X3_COMBO
If SX3->(DbSeek(cCampo)) .and. !Empty(X3CBOX())
	If nResult == 0 
		xRet := Separa(ALLTRIM(X3CBOX()),";")
		If lTodos
			aAdd(xRet,cValToChar(Len(xRet))+'=Todos' )
		Endif
	Else
		xRet := SubStr(Separa(X3CBOX(),";")[nResult],At("=",Separa(X3CBOX(),";")[nResult])+1 )
	Endif
Endif

RestArea(aArea)

Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPXCBox(cCampo)
Busca o ComboBox do Campo
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function GTPX3TIT(cCampo)
Local cRet	:= ""
Local aArea	:= GetArea()

SX3->(DbSetOrder(2)) //X3_COMBO
If SX3->(DbSeek(cCampo))
	cRet := X3TITULO()
Endif

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPXChgKey(cQuery)
Substitui uma expressão "[|exp|]" por seu conteúdo executado. 
E.g. [|dDataBase|] retornará a data atual
@author  Renan Ribeiro Brando   
@since   03/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPXChgKey(cQuery,cErro)
    
    Local nFirst := AT("[|", cQuery)
    Local nLast := 0
    Local cTemp := ""
    
    If (nFirst>0)
        nLast :=  AT("|]", cQuery) 
        cTemp := SubStr( cQuery, nFirst, nLast+2-nFirst)
        cQuery := StrTran( cQuery, cTemp, GTPXGetKey(cTemp,@cErro), 1, 1)
		If Empty(cErro)
        	return GTPXChgKey(cQuery,@cErro)
		Endif
    EndIf
    
return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPXGetKey(cKey)
Função auxiliar de GTPXChgKey(cQuery) que extrai o conteúdo da tag [||]
e retorna o valor de seu conteúdo executado
@author  Renan Ribeiro Brando   
@since   03/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPXGetKey(cKey,cError)
Local cMacro	:= (SubStr(cKey, 3, Len(cKey)-4))
Local cRet 		:= ""
Local bError	:= ErrorBlock({|e| cError := e:Description,Break(e)})
	BEGIN SEQUENCE
		cRet := alltochar( &( cMacro )  )
		// Tratamento para trasnformar datas corretamente
    	If (ValType(CtoD(DTOS(&cMacro))) == "D")
        	Return DTOS(&cMacro)
    	EndIf
	END SEQUENCE 
	ErrorBlock(bError)
return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GxVldMvEmail()

@author  jacomo.fernandes
@since   10/08/17
@version 12
/*/
//-------------------------------------------------------------------
Function GxVldMvEmail()
Local lRet	:= .T.
If	Empty(SuperGetMV("MV_RELSERV",.F.,'')) .or. ; 	// ENDERECO SMTP
	Empty(SuperGetMV("MV_RELACNT",.F.,'')) .or. ; 	// USUARIO PARA AUTENTICACAO SMTP
	Empty(SuperGetMV("MV_RELPSW" ,.F.,'')) .or. ; 	// SENHA PARA AUTENTICA SMTP
	Empty(SuperGetMV("MV_RELAUSR",.F.,''))			// USUARIO PARA AUTENTICACAO da conta
	lRet := .F.
Endif
Return lRet 

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA3CON
Rotina responsavel por avaliar os conflitos entre Os Horarios X viagens geradas, ou seja
caso uma viagem gerada/importada estiver com sua data de geração inferior a data de atualização 
do trecho correspondente (Horários/Serviços) a mesma deverá ser atualizada.

@sample		GTPA3CON()
@return		Gerar Serviços
@author		Lucas.brustolin
@since		19/05/2015
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GTPX3CON(cIniLin, cFimlin, cIniHor, cFimHor,dDtRef, lShow,cEscala)

Local cAliasQry 	:= GetNextAlias()
Local nI			:= 0
Local oGtpLog		:= Nil
Local cErroMsg		:= ""
Local cErroG55Cab	:= "" 
Local cErroG55		:= "" 
Local cErroFin		:= ""
Local cErroCab		:= ""
Local cWhereDt		:= ""
Local cWhereLn		:= ""
Local aMsgLog		:= {}
Local lErro			:= .F.
Local cInner		:= "%%"
Local cWhere		:= ""

Default cIniLin		:= ""
Default cFimlin		:= ""
Default cIniHor		:= ""
Default cFimHor		:= ""
Default dDtRef		:= CTOD("  /  /    ")
Default lShow		:= .F.
Default cEscala		:= ""
// -----------------------------------------------------+
// RETORNA AS VIAGENS QUE POSSUEM INCOSITENCIA ENTRE	|
// G55 x GIE e GYN X GID						       	|
// -----------------------------------------------------+

If !Empty(dDtRef)  
	cWhereDt := " '"+  DTOS(dDtRef) + "' BETWEEN GYN.GYN_DTINI AND  GYN.GYN_DTFIM  AND   "
EndIf 

If !Empty(cEscala)
	cInner := "%"
	cInner += '	INNER JOIN '+RetSqlName('GYP')+' GYP ON '
	cInner += "		GYP.GYP_FILIAL = '"+xFilial('GYP') +"' AND "
	cInner += "		GYP.D_E_L_E_T_ = '' AND "
	cInner += "		GYP.GYP_TIPO = '1' AND "
	cInner += "		GYN.GYN_LINCOD = GYP.GYP_LINCOD AND "
	cInner += "		GYN.GYN_CODGID = GYP.GYP_CODGID AND "
	cInner += "		G55.G55_SEQ = GYP.GYP_SEQ AND "
	cInner += "		GYP.GYP_ESCALA = '"+cEscala+"' "
	cInner += "%"
Else
	cWhereLn := " GIE.GIE_LINHA BETWEEN '"+cIniLin+"' AND '"+cFimlin+"'  AND"
	cWhereLn += " GID.GID_COD BETWEEN '"+cIniHor+"' AND '"+cFimHor+"' AND "
Endif 


cWhere := "% "+cWhereDt + " " + cWhereLn + " %"
BeginSql Alias cAliasQry
	SELECT 
		G55.G55_CODVIA, 
		G55.G55_CODGID,
		GIE.GIE_CODGID, 
		G55.G55_SEQ,
		GIE.GIE_SEQ, 
		G55.G55_LOCORI, 
		GIE.GIE_IDLOCP,
		G55.G55_LOCDES, 
		GIE.GIE_IDLOCD, 
		G55.G55_HRINI,
		GIE.GIE_HORLOC, 
		G55.G55_HRFIM, 
		GIE.GIE_HORDES,
		GID.GID_HORCAB,
		GID.GID_FINVIG,
		GYN.GYN_HRINI,
		GID.GID_HORFIM,
		GYN.GYN_HRFIM,
		GYN.GYN_DTINI,
		GYN.GYN_CODGID,
		GID.GID_SEG,
		GID.GID_TER,
		GID.GID_QUA,
		GID.GID_QUI,
		GID.GID_SEX,
		GID.GID_SAB,
		GID.GID_DOM
	FROM %TABLE:GYN% GYN
		INNER JOIN %TABLE:GID% GID ON
			GID.GID_FILIAL = %xFilial:GID% AND
			GID.%NotDel% AND
			GID.GID_HIST = '2' AND
			GYN.GYN_CODGID = GID.GID_COD
		INNER JOIN %TABLE:GIE% GIE ON
			GIE.GIE_FILIAL = %xFilial:GIE% AND
			GIE.%NotDel% AND
			GIE.GIE_HIST = '2' AND
			GID.GID_COD = GIE.GIE_CODGID
		INNER JOIN %TABLE:G55% G55 ON
			G55.G55_FILIAL = %xFilial:G55% AND
			G55.%NotDel% AND
			G55.G55_CODVIA = GYN.GYN_CODIGO AND
			G55.G55_SEQ = GIE.GIE_SEQ
		%Exp:cInner%

	WHERE 
		GYN.GYN_FILIAL = %xFilial:GYN% AND
		GYN.%NotDel% AND
		
		%EXP:cWhere%
		
		(
			(	(G55.G55_LOCORI <> GIE.GIE_IDLOCP) OR 
				(G55.G55_LOCDES <> GIE.GIE_IDLOCD) 
			) OR
	        (GID.GID_FINVIG < GYN.GYN_DTINI) OR 
			(
				(G55.G55_HRINI <> GIE.GIE_HORLOC) OR 
				(G55.G55_HRFIM <> GIE.GIE_HORDES)
			) OR 
			(
				(GID.GID_HORCAB <> GYN.GYN_HRINI) OR 
				(GID.GID_HORFIM <> GYN.GYN_HRFIM)
			) OR
	        (
				SELECT DISTINCT COUNT (GIE2.GIE_SEQ)
				FROM %TABLE:GIE% GIE2
				WHERE 
					GIE2.GIE_FILIAL = '       ' AND 
					GIE2.D_E_L_E_T_= ' 'AND 
					GIE2.GIE_CODGID = G55.G55_CODGID AND 
					GIE2.GIE_HIST = '2'
			) <>
	        (
				SELECT COUNT (G552.G55_SEQ)
				FROM %TABLE:G55% G552
				WHERE G552.G55_FILIAL = '       ' AND
					G552.D_E_L_E_T_= ' ' AND 
					G552.G55_CODGID = G55.G55_CODGID AND 
					G552.G55_CODVIA = G55.G55_CODVIA
			)
		)
				
EndSql
	
	
TcSetField(cAliasQry,"GYN_DTINI","D", 8)	
TcSetField(cAliasQry,"GYN_DTFIM","D", 8)	
	
// --------------------------------------------------------------------------+
// BLOCO P/ ATUALIZAR AS VIAGENS QUE POSSUEM HORARIOS/SERVIÇOS MAIS RECENTE. |
// --------------------------------------------------------------------------+				
If (cAliasQry)->( !Eof() ) 	
	While (cAliasQry)->( !Eof() ) 	
		cErroCab	:=	STR0063 + ": " + (cAliasQry)->G55_CODVIA //"Viagem "
		If (cAliasQry)->G55_SEQ == "001 " .AND. (cAliasQry)->GIE_SEQ == "001 "
			cErroMsg := ""
			If ((cAliasQry)->GID_HORCAB <> (cAliasQry)->GYN_HRINI) .OR. ((cAliasQry)->GID_HORFIM <> (cAliasQry)->GYN_HRFIM)
				cErroMsg	:= CRLF + STR0064  //""-Possui conflito no Horário de Inicio e Final da Viagem""
				lErro := .T.
			EndIf
			
			cDiaSemana := UPPER(SubStr(DIASEMANA( (cAliasQry)->GYN_DTINI),1,3) )  			
			cDiaSemana := "GID_" + cDiaSemana			
			cDiaSemana := (cAliasQry)->&(cDiaSemana)
			
			//-- Verifica se a freq. de (dias) continua valida comparada aos horarios.
			If cDiaSemana != "T"
				cErroMsg	+= CRLF + STR0065 + DtoC((cAliasQry)->GYN_DTINI) + STR0066 ; //"-Data de início" " é "
				+ DIASEMANA( (cAliasQry)->GYN_DTINI) + STR0067 + STR0068 //"Feira " "não está batendo com frequência do horário"
				lErro := .T.
			EndIf	
			If STOD((cAliasQry)->GID_FINVIG) < (cAliasQry)->GYN_DTINI
				cErroMsg	+= CRLF + STR0069 + DtoC((cAliasQry)->GYN_DTINI) + STR0070 + DtoC(STOD((cAliasQry)->GID_FINVIG)) //"-Data de Início:"  " está fora da vigência: "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
				lErro := .T.
			EndIf
		EndIf
		//Verificar trechos
		If AllTrim((cAliasQry)->GIE_CODGID) == AllTrim((cAliasQry)->G55_CODGID) .AND. (cAliasQry)->G55_SEQ == (cAliasQry)->GIE_SEQ 
			cErroG55	:= ""
			cErroG55Cab	:= ""
			
			cErroG55Cab	:= STR0071 + (cAliasQry)->G55_SEQ //"A Sequência:"
			
			//Verifica se possui conflitos de localidade inicio e localidade de fim
			If (((cAliasQry)->G55_LOCORI <> (cAliasQry)->GIE_IDLOCP) .OR. ((cAliasQry)->G55_LOCDES <> (cAliasQry)->GIE_IDLOCD))
				cErroG55	+= CRLF + STR0072 //"-possui um conflito na localidade"
				lErro := .T.
			EndIf
			// Verifica se possui conflito de horarios no trecho G55 com a GIE
			If (((cAliasQry)->G55_HRINI <> (cAliasQry)->GIE_HORLOC) .OR. ((cAliasQry)->G55_HRFIM <> (cAliasQry)->GIE_HORDES))
				cErroG55	+= CRLF + STR0073 //"-Possui um conflito de horário"
				lErro := .T.
			EndIf 
		EndIf 
		
		//Aramazena o Log de conflitos
		If !cErroG55 == ""
			cErroFin	:= cErroCab + cErroMsg + CRLF + cErroG55Cab + cErroG55
			aAdd(aMsgLog, cErroFin)
		ElseIf !cErroMsg == "" 
			cErroFin	:= cErroCab + cErroMsg
			aAdd(aMsgLog, cErroFin)
		EndIF	
		cErroFin	:= ""
		cErroMsg	:= ""
		cErroG55	:= ""
		cErroCab	:= ""
		(cAliasQry)->( DbSkip() )
	EndDo
		
	// Encerra a tabela temporaria.
	(cAliasQry)->( DBCloseArea() )
	If Len(aMsgLog)
		oGtpLog :=  GTPLog():New(STR0074 + CRLF)// 'Avaliação de Conflitos.'
		For nI := 1 To Len(aMsgLog)
			oGtpLog:SetText(aMsgLog[nI] + CRLF) 												
		Next
		IF lShow .And. oGtpLog:HasInfo() 
			oGtpLog:ShowLog()
		EndIf 
		oGtpLog:Destroy()	
	EndIf 	
Else
	If IsInCallStack("GTPA3CON")
		Help(,,'GTPA300',, STR0075,1,0) //"Nenhum conflito encontrado." 	
	EndIf
EndIf 
Return()

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPAddHist
Rotina responsavel por avaliar os conflitos entre Os Horarios X viagens geradas, ou seja
caso uma viagem gerada/importada estiver com sua data de geração inferior a data de atualização 
do trecho correspondente (Horários/Serviços) a mesma deverá ser atualizada.

@Param		cViagem - Codigo da viagem
@Param		cSeq 	- Sequencia do trecho 
@Param		cItem	- Item do recurso
@Param		nTipo	- Tipo da operação 
@Param		xContent - Valor anterior 

@sample		GTPA3CON()
@return		Gerar Serviços
@author		Lucas.brustolin
@since		19/05/2015
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Function GTPAddHist(aData,nTipo,xContent)

Local oModel := GCC300GetModel()

Local lRet		:= .f.
Local lFound	:= .f.
Local cRevisa	:= ""
Local cField	:= ""

If ( ValType(oModel) == "U" )
	oModel := FwLoadModel("GTPC300C")	
EndIf

If ( !oModel:IsActive() )
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
EndIf

oModel:GetModel("GQFMASTER"):LoadValue("CODIGO",cValToChar(Randomize(1,99999)))

oModel:GetModel("GQFDETAIL"):GoLine(1)

lFound := !Empty(oModel:GetModel("GQFDETAIL"):GetValue("GQF_VIACOD")) .And. oModel:GetModel("GQFDETAIL"):SeekLine({{"GQF_VIACOD",aData[1]},{"GQF_SEQ",aData[2]},{"GQF_ITEM",aData[3]}}) 

If ( !lFound )	
	
	If ( !Empty(oModel:GetModel("GQFDETAIL"):GetValue("GQF_VIACOD")) )
		lRet := oModel:GetModel("GQFDETAIL"):Length() == oModel:GetModel("GQFDETAIL"):AddLine(.t.,.t.)
	EndIf
	
	lRet := oModel:GetModel("GQFDETAIL"):LoadValue("GQF_VIACOD", aData[1]) .And.;
			oModel:GetModel("GQFDETAIL"):LoadValue("GQF_SEQ", aData[2]) .And.;
			oModel:GetModel("GQFDETAIL"):LoadValue("GQF_ITEM", aData[3]) .And.;
			oModel:GetModel("GQFDETAIL"):LoadValue("GQF_TRECUR", aData[4]) .And.;
			oModel:GetModel("GQFDETAIL"):LoadValue("GQF_TCOLAB", aData[5]) .And.;
			oModel:GetModel("GQFDETAIL"):LoadValue("GQF_RECURS", aData[6]) .And.;
			oModel:GetModel("GQFDETAIL"):LoadValue("GQF_JUSTIF", aData[7]) .And.;
			oModel:GetModel("GQFDETAIL"):LoadValue("GQF_USRREG", PswID()) .And.;
			oModel:GetModel("GQFDETAIL"):LoadValue("GQF_DTAREG", Date()) .And.;
			oModel:GetModel("GQFDETAIL"):LoadValue("GQF_HRAREG", StrTran(Time(),":",""))
Else
	lRet := .t.			
EndIf

If ( lRet )

	If ( Empty(oModel:GetModel("GQFDETAIL"):GetValue("GQF_REVISA")) )
		cRevisa := GTPHistRevis(aData[1],aData[2],aData[3]) //função que busca a próxima revisão
	Else
		cRevisa := oModel:GetModel("GQFDETAIL"):GetValue("GQF_REVISA")
	EndIf

	Do Case
	Case ( nTipo == 1 )	//Substituição - grava os dados em GQF_RECURS (novo recurso) e GQF_RECANT (recurso original)
		cField := "GQF_RECURS"
	Case ( nTipo == 2 )	//Confirmação - grava Status do Recurso como Confirmado
		cField := "GQF_STATUS"
	Case ( nTipo == 3 ) //Cancelamento - grava o Status Seção como Cancelado
		cField := "GQF_CANCEL"		
	End Case
	
	lRet := oModel:GetModel("GQFDETAIL"):LoadValue("GQF_REVISA",cRevisa) .and.;
			oModel:GetModel("GQFDETAIL"):LoadValue(cField,AllTrim(xContent))
	
EndIf 

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPHistRevis
Gera o próximo número de revisão para a alocação do recursos no Monitor
 
@sample	TP409Revis()
 
@param	cViaCod - Códido da viagem
@param	cSeq - Sequencia do Recurso
@param	cItem - Item do Recurso 		

@return nRet

@author	Yuki Shiroma
@since	 24/08/2017
@version P12
/*/
//------------------------------------------------------------------------------------------
Function GTPHistRevis(cViaCod,cSeq,cItem)

Local cAlias   := GetNextAlias() 
Local aArea    := GetArea() 
Local aAreaGQF := GQF->(GetArea()) 
Local cRevisao := ""	// Revisao

//Query para buscar ultima revisao				
BeginSql Alias cAlias
	SELECT 
		MAX(GQF_REVISA) AS REVISAO 
	FROM 
		%Table:GQF% GQF 
	WHERE 
		GQF.GQF_VIACOD = %Exp:cViaCod%
		AND GQF.GQF_SEQ = %Exp:cSeq%
		AND GQF.GQF_ITEM = %Exp:cItem%
		AND GQF.%NotDel% 
EndSql
//Verifica se possui a ultima revisão					
If ! Empty((cAlias)->REVISAO)
//Incrementa + 1 a revisão				
	cRevisao := SOMA1((cAlias)->REVISAO)
Else
	//Caso nao tiver revisão cria nova revisão 
	cRevisao := StrZero(1,TamSx3("GQF_REVISA")[1])
EndIf

					
(cAlias)->(DbCloseArea())		

RestArea(aArea)
RestArea(aAreaGQF)

Return(cRevisao)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPTemporaryTable
Gera tabela temporaria 
 
@sample	TP409Revis()
 
@param	cQuery - 	
@param	cAlias - 
@param	aIndex - 
@param	aFldConv - 
	
@return nRet

@author	Inovaçaõ
@since	 24/08/2017
@version P12
/*/
//------------------------------------------------------------------------------------------
Function GTPTemporaryTable(cQuery,cAlias,aIndex,aFldConv,oTable)

Local cAliasResSet	:= GetNextAlias()
Local cInternalQry	:= "%" + Substr(Alltrim(cQuery),At("SELECT",UPPER(cQuery))+Len("SELECT")) + "%"
Local nI			:= 0

Default cAlias		:= GetNextAlias()
Default aIndex		:= {}
Default aFldConv	:= {}

BeginSQL Alias cAliasResSet	

	SELECT	%Exp:cInternalQry%

EndSQL

//Monta o ResultSet
//MPSysOpenQuery(cQuery, cAliasResSet)

For nI := 1 to Len(aFldConv)	
	
	If ( Len(aFldConv[nI]) == 3 )
		TCSetField(cAliasResSet,aFldConv[nI,1],aFldConv[nI,2],aFldConv[nI,3])
	ElseIf ( Len(aFldConv[nI]) == 4 )
		TCSetField(cAliasResSet,aFldConv[nI,1],aFldConv[nI,2],aFldConv[nI,3],aFldConv[nI,4])
	EndIf
		
Next nI

lRemake := ValType(oTable) <> "O" 

If ( !lRemake .And. cQryTmp <> cQuery)
	oTable:Delete()
	lRemake := .t.
EndIf

If ( lRemake )
	
	cQryTmp := cQuery
	
	oTable := FWTemporaryTable():New(cAlias)

	oTable:SetFields((cAliasResSet)->(DbStruct()))

	For nI := 1 to Len(aIndex)
		oTable:AddIndex(aIndex[nI,1],aClone(aIndex[nI,2]))
	Next nI

	oTable:Create()

	If ( !InTransaction() )
		(oTable:GetAlias())->( __dbZap() )
	EndIf	

Else
	TcSqlExec('TRUNCATE TABLE '+ oTable:GetRealName())
EndIf

(cAliasResSet)->(DbGoTop())

Begin Transaction	

	While ( (cAliasResSet)->(!Eof()) )
		
		RecLock(oTable:GetAlias(),.t.)	
		
			For nI := 1 to (cAliasResSet)->(FCount())
				(oTable:GetAlias())->&(FieldName(nI)) := (cAliasResSet)->&(FieldName(nI))	
			Next nI
		
		(oTable:GetAlias())->(MsUnlock())
		
		(cAliasResSet)->(DbSkip())
		
	EndDo

End Transaction

(cAliasResSet)->(DbCloseArea())

(oTable:GetAlias())->(DbGoTop())

Return()
//JCA: DSERGTP-8012
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPTemporaryTable
Gera tabela temporaria 
 
@sample	GTPTemporaryTable(cQuery,cAlias,aIndex,aFldConv,oTable,lForceRemake)
 
@param	cQuery - caracter. Query que será convertida em tabela temporária 	
		cAlias - caracter. Nome do alias da tabela temporária para se trabalhar
		aIndex - array. Array para a montagem dos índices da tabela temporária
		aFldConv - array. Contem os campos que devem constituir a tabela temporária
		oTable - objeto. Instância da classe FWTemporaryTable (passado por referência)
		lForceRemake - lógico. Força a criação da tabela temporária? .t. Sim
	
@return nRet

@author	Inovaçaõ
@since	 24/08/2017
@version P12
/*/
//------------------------------------------------------------------------------------------
/*
	Implementar, trocar a GTPTemporaryTable por
	GTPNewTempTable em:
		[X] GTPA408G.PRW
		[X] GTPA418A.PRW
		[X] GTPC300.PRW
		[X] GTPC300C.PRW
		[X] GTPC300M.PRW
		-
*/
Function GTPNewTempTable(cQuery,cAlias,aIndex,aFldConv,oTable,lForceRemake)

	Local nI		:= 0

	Local cFields	:= ""
	Local cQryIn	:= ""

	Local aDivQry	:= {}
	Local aFields	:= {}

	Local lRemake	:= .F.

	Default cAlias		:= GetNextAlias()
	Default aIndex		:= {}
	Default aFldConv	:= {}
	Default lForceRemake:= .f.

	aDivQry := Separa(Upper(cQuery),"FROM")
	
	lRemake := lForceRemake .Or. Len(aDivQry) > 0 .And. ValType(oTable) <> "O" .Or. cSelectAnt <> aDivQry[1]
	
	If ( lRemake .And. ValType(oTable) == "O" )
		oTable:Delete()
	EndIf

	If ( lRemake )
		
		cSelectAnt := aDivQry[1]

		cFields := SubStr(aDivQry[1], At("SELECT",Upper(aDivQry[1])) +Len("SELECT") + 1)
		cFields := SetFields(cFields,aFields,aFldConv)
			
		// cQryTmp := cQuery
		
		oTable := FWTemporaryTable():New(cAlias)

		oTable:SetFields(aFields)

		For nI := 1 to Len(aIndex)
			oTable:AddIndex(aIndex[nI,1],aClone(aIndex[nI,2]))
		Next nI

		oTable:Create()

		If ( !InTransaction() )
			(oTable:GetAlias())->( __dbZap() )
		EndIf	

	Else
		
		cFields := SubStr(cSelectAnt, At("SELECT",Upper(cSelectAnt)) +Len("SELECT") + 1)
		cFields := SetFields(cFields,aFields,aFldConv)

		TcSqlExec('TRUNCATE TABLE '+ oTable:GetRealName())
	EndIf

	cQryIn := " INSERT INTO " + oTable:GetRealName() + Iif( !("*" $ cFields), "(" + cFields + ") ","")
	cQryIn += cQuery	
	
	lRet := TcSQLExec(cQryIn) >= 0

	If ( !lRet )
		MsgAlert(TCSQLError())
	EndIf
	
	(oTable:GetAlias())->(DbGoTop())	

Return()

Static Function SetFields(cFields,aFields,aFldConv)

	Local aAuxFld		:= {}
	
	Local nI			:= 0
	Local nP			:= 0
	Local nTam			:= 255

	Local cCompoFld		:= ""
	Local cListOfFields	:= ""
	Local cFldToStruct	:= ""

	aAuxFld := Separa(cFields,",")

	For nI := 1 to Len(aAuxFld)
		
		cCompoFld		:= CleanField(aAuxFld[nI])					//Alltrim(Substr(Alltrim(aAuxFld[nI]),RAt(space(1),aAuxFld[nI]) + 1 ))
		cFldToStruct	:= SubStr(cCompoFld,At(".",cCompoFld)+1)

		If ( !Empty(cCompoFld) )
			
			nP := aScan(aFldConv,{|x| Upper(Alltrim(x[1])) == Upper(Alltrim(cFldToStruct))})
			
			If ( nP > 0 )
			
				aAdd(aFields,{	cFldToStruct,;
								aFldConv[nP,2],;
								aFldConv[nP,3],;
								IIf(Len(aFldConv[nP]) > 3 ,aFldConv[nP,4],0);
							})
			Else
				aAdd(aFields,{cFldToStruct,"C",nTam,0})				
			EndIf

			cListOfFields += cCompoFld 
			
			If ( nI < Len(aAuxFld) )
				cListOfFields += ", "
			EndIf

		EndIf

	Next nI

Return(cListOfFields)

//RADU - TODO: Tratamnento para buscar campos de tabela
//A tabela pode ser uma tabela física real, uma tabela física temporária ou um subselect
//Não pode ter * na seleção de campos, por enquanto,
	//Função GetFldSelect() em construção. A função GetFldSelect
	//será responsável por converter * em listacampos
Static Function GetFldSelect(cTable,aFields)

	Local cListOfFields	:= ""

	If ( Select(cTable) > 0 )
		// aAuxFld := DbStruct()
	EndIf

Return(cListOfFields)

Static Function CleanField(cText)

	Local cRet	:= ""
	Local cAux	:= ""

	Local nPosIni := 0
	
	cAux := Alltrim(cText)
	cAux := StrTran(cAux,chr(13),"")
	cAux := StrTran(cAux,chr(10),"")
	cAux := StrTran(cAux,chr(09),"")

	nPosIni := RAt(chr(32),Alltrim(cAux))

	cRet := Alltrim(Substr(Alltrim(cAux),nPosIni))
	cRet := StrTran(cRet,chr(13),"")
	cRet := StrTran(cRet,chr(10),"")
	cRet := StrTran(cRet,chr(09),"")

Return(cRet)
//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPxTmpTbl

@type Function
@author jacomo.fernandes
@since 03/09/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Function GTPxTmpTbl(cAliasAux,aIndex)
Local cNewAlias := ""//GetNextAlias()
Local nI        := 0
Local aStruct	:= (cAliasAux)->(DbStruct())

Local lRemake := .f.

Default aIndex  := {}

lRemake := Valtype(oTableTmp) <> "O" 

If ( !lRemake .and. AdmDiffArray(aStruct,aStructTmp) )
	oTableTmp:Delete()
	lRemake := .t.
EndIf

oTableTmp := FWTemporaryTable():New()
oTableTmp:SetFields(aStruct)

aStructTmp := aClone(aStruct)

For nI := 1 to Len(aIndex)
	oTableTmp:AddIndex(aIndex[nI,1],aClone(aIndex[nI,2]))
Next nI

oTableTmp:Create()

(cAliasAux)->(DbGoTop())

cNewAlias := oTableTmp:GetAlias()

TcSqlExec('TRUNCATE TABLE '+ oTableTmp:GetRealName())

Begin Transaction

	While ( (cAliasAux)->(!Eof()) )
		
		RecLock(cNewAlias,.t.)	
		
			For nI := 1 to (cAliasAux)->(FCount())
				(cNewAlias)->&(FieldName(nI)) := (cAliasAux)->&(FieldName(nI))	
			Next nI
		
		(cNewAlias)->(MsUnlock())
		
		(cAliasAux)->(DbSkip())
		
	EndDo

End Transaction

(cAliasAux)->(DbCloseArea())

(oTableTmp:GetAlias())->(DbGoTop())

Return oTableTmp

/*/{Protheus.doc} GTPSetRules
(long_description)
@type function
@author 
@since 
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPSetRules(cParameter, cDataType, cPicture, cContent, cGroupFunc, cDescription, cF3, cSeekFil, nOperation)

Local lRet		:= .t.
Local oModel	:= nil
Default cSeekFil	:= XFilial("GYF")
Default nOperation	:= MODEL_OPERATION_INSERT
Default cContent	:= GTPCastType(GTPCastType(,cDataType),"C")
Default cF3			:= ""

GYF->(DbSetOrder(1))

If ( !GYF->(DbSeek(cSeekFil + PadR(cParameter,TamSx3("GYF_PARAME")[1]))) )
	
	oModel	:= FwLoadModel("GTPA281")

	oModel:SetOperation(nOperation)
	oModel:Activate()

	lRet := oModel:GetModel("GYFMASTER"):LoadValue("GYF_FILIAL",cSeekFil) .And.;
			oModel:GetModel("GYFMASTER"):LoadValue("GYF_PARAME",cParameter) .And.; 
			oModel:GetModel("GYFMASTER"):LoadValue("GYF_TIPO",cDataType) .And.;
			oModel:GetModel("GYFMASTER"):LoadValue("GYF_PICTUR",cPicture) .And.;
			oModel:GetModel("GYFMASTER"):LoadValue("GYF_CPX3",cF3) .And.;
			oModel:GetModel("GYFMASTER"):LoadValue("GYF_CONTEU",cContent) .And.;
			oModel:GetModel("GYFMASTER"):LoadValue("GYF_GRUPO",cGroupFunc) .And.;
			oModel:GetModel("GYFMASTER"):LoadValue("GYF_DESCRI",SUBSTR(cDescription,0,TamSX3("GYF_DESCRI")[1]))

	If ( lRet .And. oModel:VldData() )
		oModel:CommitData()
	EndIf

	oModel:DeActivate()
	oModel:Destroy()
	
EndIf	

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPFechPeri(cAgenci)
Pega o período da última ficha de remessa, verificando se ela está no
mês corrente. 
Retorna se a ficha está no mês corrente, seu status, data de inicio 
e fim
@author  Renan Ribeiro Brando
@since   25/10/2017	
@version P12
/*/
//-------------------------------------------------------------------
//Function GTPFechPeri(cAgenci)
//
//Local dIni
//Local dEnd
//Local cStatus
//Local lCurrent := .F.
//Local cFicha	 := ""
//Local cAliasTemp := GetNextAlias()
//
//	BeginSql alias cAliasTemp
//		SELECT 
//			G6X.G6X_DTINI, 
//			G6X.G6X_DTFIN, 
//			G6X.G6X_STATUS,
//			G6X.G6X_NUMFCH
//		FROM 
//			%TABLE:G6X% G6X
//		WHERE 
//			G6X.G6X_FILIAL = %xFilial:G6X%
//            AND G6X.%NotDel%
//			AND G6X.G6X_AGENCI = %Exp:cAgenci%
//		ORDER BY
//			G6X.G6X_DTFIN DESC
//	EndSql
//
//	// Caso exista ficha de remessa
//	If (cAliasTemp)->(!EOF())
//		dIni 		:= Stod((cAliasTemp)->G6X_DTINI)
//		dEnd 		:= Stod((cAliasTemp)->G6X_DTFIN)
//		cStatus	:= (cAliasTemp)->G6X_STATUS
//		cFicha  	:= (cAliasTemp)->G6X_NUMFCH
//		
//		// retorna se a ficha é do mês corrente
//		If Year(dEnd) == Year(dDatabase)
//			If Month(dEnd) == Month(dDataBase)
//				lCurrent := .T.
//			EndIf
//		EndIf
//	// Caso não exista, o status será 0
//	Else
//		cStatus := "0" 
//	EndIf
//
//	(cAliasTemp)->(DbCloseArea())
//
//Return ACLONE({lCurrent, cStatus, dIni, dEnd, cFicha})

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPFirstPeri(cAgenci)
Pega o período da última ficha de remessa, verificando se ela está no
mês corrente. 
Retorna se a ficha está no mês corrente, se existem fichas em aberto, data de inicio 
e fim
@author  Renan Ribeiro Brando
@since   20/10/2017	
@version P12
/*/
//-------------------------------------------------------------------
Function GTPFirstPeri(cAgenci)

Local dIni
Local dEnd
Local cStatus
Local lCurrent := .F.
Local cFicha	 := ""
Local cAliasTemp := GetNextAlias()

	BeginSql alias cAliasTemp
		SELECT 
			G6X.G6X_DTINI, 
			G6X.G6X_DTFIN, 
			G6X.G6X_STATUS,
			G6X.G6X_NUMFCH
		FROM 
			%TABLE:G6X% G6X
		WHERE 
			G6X.G6X_FILIAL = %xFilial:G6X%
            AND G6X.%NotDel%
			AND G6X.G6X_AGENCI = %Exp:cAgenci%
			AND (G6X.G6X_STATUS = '1' OR G6X.G6X_STATUS = '2' OR G6X.G6X_STATUS = '5') //RADU: Ajustado para ficha Reaberta - 25/11/21
		ORDER BY
			G6X.G6X_DTFIN 
	EndSql

	// Caso exista ficha de remessa
	If (cAliasTemp)->(!EOF())
		dIni 		:= Stod((cAliasTemp)->G6X_DTINI)
		dEnd 		:= Stod((cAliasTemp)->G6X_DTFIN)
		cStatus	:= (cAliasTemp)->G6X_STATUS
		cFicha  	:= (cAliasTemp)->G6X_NUMFCH
		
		// retorna se a ficha é do mês corrente
		If Year(dEnd) == Year(dDatabase)
			If Month(dEnd) == Month(dDataBase)
				lCurrent := .T.
			EndIf
		EndIf
	// Caso não exista, o status será 0
	Else
		cStatus := "0" 
	EndIf

	(cAliasTemp)->(DbCloseArea())

Return ACLONE({lCurrent, cStatus, dIni, dEnd, cFicha})


/*/{Protheus.doc} GTPxGetFer
(long_description)
@type function
@author jacomo.fernandes
@since 08/11/2017
@version 1.0
@param dDtIni, date, Data inicial da busca, default dDataBase
@param dDtFim, date, Data Final da busca, default dDtIni
@param cSetor, character, Código do Setor da busca, caso não informado retorna apenas os feriados do RH
@return aRet, Caso encontrado, retorna a lista de feriados no seguinte formato [nlin][1] = data, [nlin][2] = mesdia, [nlin][3] = se é fixo ou não  
@example
(examples)
@see (links_or_references)
/*/
Function GTPxGetFer(dDtIni, dDtFim, cSetor, cFilFunc,lRetLogico)
Local xRet			:= nil
Local aRet			:= {}
Local cNewAlias		:= GetNextAlias()


Default dDtIni		:= dDataBase
Default dDtFim		:= dDtIni
Default cSetor		:= Space(TamSx3('GYT_CODIGO')[1])
Default cFilFunc	:= XFilial("SP3")
Default lRetLogico	:= .F.


BeginSql Alias cNewAlias
	Select 
		P3_DATA AS DATAFERIADO, 
		P3_MESDIA AS MESDIA, 
		P3_FIXO AS FIXO 
	From 
		%Table:SP3% SP3 
	Where
		SP3.P3_FILIAL = %Exp:cFilFunc% 
		AND SP3.%NotDel% 
		AND (
				(
					(CASE 
						WHEN SP3.P3_FIXO = 'S' 
							THEN %Exp:cValToChar(Year(dDtIni))% || SP3.P3_MESDIA
						ELSE P3_DATA 
					END) BETWEEN %Exp:dToS(dDtIni)% AND %Exp:dToS(dDtFim)% 
				) Or (
					(CASE 
						WHEN SP3.P3_FIXO = 'S' 
							THEN %Exp:cValToChar(Year(dDtFim))% || SP3.P3_MESDIA
						ELSE P3_DATA 
					END) BETWEEN %Exp:dToS(dDtIni)% AND %Exp:dToS(dDtFim)% 
				)
			) 
	
	Union

	SELECT
		RR0_DATA AS DATAFERIADO,
		RR0_MESDIA AS MESDIA,
		RR0_FIXO AS FIXO
	FROM %Table:GYL% GYL
		INNER JOIN %Table:RR0% RR0 ON 
			RR0.RR0_CODCAL = GYL.GYL_IDCAL
			AND RR0.RR0_FILIAL = %Exp:cFilFunc% 
			AND (
					(
						(CASE
							WHEN RR0.RR0_FIXO = 'S' 
								THEN  %Exp:cValToChar(Year(dDtIni))% || RR0_MESDIA
							ELSE RR0_DATA
						END) BETWEEN %Exp:dToS(dDtIni)% AND %Exp:dToS(dDtFim)%
					) OR (
						(CASE
							WHEN RR0.RR0_FIXO = 'S' 
								THEN %Exp:cValToChar(Year(dDtFim))% || RR0_MESDIA
							ELSE RR0_DATA
						END) BETWEEN %Exp:dToS(dDtIni)% AND %Exp:dToS(dDtFim)%
					)
				)
	WHERE 
		GYL.GYL_FILIAL = %xFilial:GYL%
		AND GYL.%NotDel% 
		AND GYL.GYL_CODGYT = %Exp:cSetor%


EndSql  

(cNewAlias)->(DbGoTop())
DbEval({||aAdd(aRet,{(cNewAlias)->DATAFERIADO,(cNewAlias)->MESDIA,(cNewAlias)->FIXO}) })
(cNewAlias)->(DbCloseArea())

If !lRetLogico
	xRet := aRet
Else
	xRet := Len(aRet) > 0
Endif

Return xRet


Function GTPSeekTemp(oTableTemp,aSeek,aResultSet,lReset,cOrderBy,lOrderBy)

Local aStruct	:= nil

Local cAlias	:= GetNextAlias()
Local cWhere	:= ""
Local cCompare	:= ""
Local cFields	:= ""
Local cFldOrd	:= ""

Local nI		:= 0
Local nP		:= 0

Local aHeaderSet 	:= {}
Local aCellSet		:= {}
	
Local lRet	:= .f.

Default aResultSet 	:= {}
Default lReset 		:= .t.
Default cOrderBy	:= ""
Default lOrderBy	:= .f.

If (ValType(oTableTemp) == "O" .and. ValType(oTableTemp:oStruct) == "O" .and. oTableTemp:oStruct:ClassName() == "TABLESTRUCT")
	aStruct	:= (oTableTemp:GetAlias())->(DbStruct())
	If ( Valtype(oTableTemp) == "O" )
	
		cFields := "%"
		
		If ( Len(aResultSet) > 0 )
			aEval(aResultSet[1],{|x| cFields += x + ", "})
		Else
			aEval(oTableTemp:GetStruct():aFields,{|x| cFields += x[1] + ", ", aAdd(aHeaderSet,x[1])})
			aAdd(aResultSet,aClone(aHeaderSet))
		EndIf
		
		If ( !Empty(cOrderBy) .And. lOrderBy )
			cFldOrd := cOrderBy
		ElseIf ( lOrderBy )
			cFldOrd := SubStr(cFields,1,Rat(",",cFields)-1)	
		EndIf
			
		cFields += " R_E_C_N_O_ RECNO %" 
		
		
		If ( Len(aResultSet) > 0 ) .And. aScan(aResultSet[1],"R_E_C_N_O_") == 0
			
			aAdd(aResultSet[1],"R_E_C_N_O_")
			
		EndIF	
		
		
		If ( Len(aSeek) > 0 )
			
			cWhere := "% " + oTableTemp:GetRealName() + " WHERE "
			
			For nI := 1 to Len(aSeek)
				
				nP := aScan(aStruct,{|x| Upper(Alltrim(x[1])) == Upper(Alltrim(aSeek[nI,1]))})
				
				If ( nP > 0 )	
				
					If ( aStruct[nP,2] == "C" )
						cCompare := "'" + aSeek[nI,2] + "'"
					ElseIf ( aStruct[nP,2] == "N" )
						cCompare := GtpCastType(aSeek[nI,2],"C")
					ElseIf ( aStruct[nP,2] == "D" )
						cCompare := "'" + GtpCastType(aSeek[nI,2],"C","AAAAMMDD") + "'"
					ElseIf ( aStruct[nP,2] == "L" )
						cCompare := "'" + GtpCastType(aSeek[nI,2],"C") + "'"	
					EndIf
				
				EndIf
				
				If ( nI == Len(aSeek) ) 
					cWhere += aSeek[nI,1] + " = " + cCompare
				Else
					cWhere += aSeek[nI,1] + " = " + cCompare + " AND "
				EndIf
					  
			Next nI
			
			If ( !Empty(cFldOrd) )
				cWhere += " ORDER BY " + cFldOrd 
			EndIf
			
			cWhere += "%"
			
			BeginSQL Alias cAlias
			
				SELECT
					%Exp:cFields%
				FROM
					%Exp:cWhere%
										
			EndSQL
		
			lRet := (cAlias)->(!Eof())
		
			If ( lRet )
			
				If ( Len(aResultSet) > 0 )
					
					aHeaderSet := aClone(aResultSet[1])
					
					If ( lReset )
						aResultSet := {aClone(aHeaderSet)}
					EndIf
					
					
					While ( (cAlias)->(!EoF()) )
						
						(oTableTemp:GetAlias())->(DbGoTo((cAlias)->RECNO))
						
						For nI := 1 to Len(aHeaderSet)
						
							If ( aHeaderSet[nI] <> "R_E_C_N_O_" )
								aAdd(aCellSet,(oTableTemp:GetAlias())->&(aHeaderSet[nI]))
							Else
								aAdd(aCellSet,(cAlias)->RECNO)
							EndIf
							
						Next nI
						
						aAdd(aResultSet,aClone(aCellSet))
						
						aCellSet := {}
						
						(cAlias)->(DbSkip())
						
					End While	
					 
				EndIf
				
				(cAlias)->(DbGoTop())
				
				(oTableTemp:GetAlias())->(DbGoTo((cAlias)->RECNO))
				
			EndIf
			
			(cAlias)->(DbCloseArea())
				
		Else
			lRet := .f.
		EndIf
	
	EndIf
Else
	lRet	:= .F.
Endif

Return(lRet)


Function GTPSeekTable(cAliasTable,aSeek,aResultSet,lReset,cOrderBy,lOrderBy)

Local cAlias		:= GetNextAlias()
Local cWhere		:= ""
Local cOperator		:= ""
Local cFldOrd		:= ""
Local cCompare      := ""

Local nI			:= 0
	
Local lRet			:= .f.

Local aHeaderSet 	:= {}
Local aCellSet		:= {}
Local aFields		:= {}

Default aResultSet 	:= {}
Default lReset 		:= .t.
Default cOrderBy	:= ""
Default lOrderBy	:= .f.

cFields := "%"

If ( Len(aResultSet) > 0 )
	aEval(aResultSet[1],{|x| cFields += x + ", "})
Else
	aFields := (cAliasTable)->(DbStruct())

	aEval(aFields,{|x| cFields += x[1] + ", ",aAdd(aHeaderSet,x[1])})
	aAdd(aResultSet,aClone(aHeaderSet))

EndIf

If ( !Empty(cOrderBy) .And. lOrderBy )
	cFldOrd := cOrderBy
ElseIf ( lOrderBy )
	cFldOrd := SubStr(cFields,1,Rat(",",cFields)-1)	
EndIf

cFields += " R_E_C_N_O_ RECNO %" 

If ( Len(aSeek) > 0 )
	
	cWhere := "% " + RetSQLName(cAliasTable) + " " + cAliasTable + " WHERE "
	
	For nI := 1 to Len(aSeek)
	
		If ( GetSx3Cache(aSeek[nI,1],"X3_TIPO") == "C" )
			cCompare := "'" + aSeek[nI,2] + "'"
		ElseIf ( GetSx3Cache(aSeek[nI,1],"X3_TIPO") == "N" )
			cCompare := GtpCastType(aSeek[nI,2],"C")
		ElseIf ( GetSx3Cache(aSeek[nI,1],"X3_TIPO") == "D" )
			cCompare := "'" + GtpCastType(aSeek[nI,2],"C","AAAAMMDD") + "'"
		ElseIf ( GetSx3Cache(aSeek[nI,1],"X3_TIPO") == "L" )
			cCompare := "'" + GtpCastType(aSeek[nI,2],"C") + "'"	
		EndIf
		
		If ( Len(aSeek[nI]) == 3 )
			cOperator := aSeek[nI,3]
		Else
			cOperator := "="
		EndIf
		
		cWhere += aSeek[nI,1] + " " + cOperator + " " + cCompare + " AND "		
			  
	Next nI
	
	cWhere += cAliasTable + ".D_E_L_E_T_ = ' ' "
	
	If ( !Empty(cFldOrd) )
		cWhere += " ORDER BY " + cFldOrd 
	EndIf
	
	cWhere += "%"
	
	BeginSQL Alias cAlias
	
		SELECT
			%Exp:cFields%
		FROM
			%Exp:cWhere%	
	EndSQL
	
	lRet := (cAlias)->(!Eof())

	If ( lRet )
	
		If ( Len(aResultSet) > 0 )
			
			aHeaderSet := aClone(aResultSet[1])
			
			If ( lReset )
				aResultSet := {aClone(aHeaderSet)}
			EndIf
			
			aAdd(aHeaderSet,"RECNO")
			
			While ( (cAlias)->(!EoF()) )
				
				(cAliasTable)->(DbGoTo((cAlias)->RECNO))
				
				For nI := 1 to Len(aHeaderSet)
					
					If ( aHeaderSet[nI] <> "RECNO" )
						aAdd(aCellSet,(cAliasTable)->&(aHeaderSet[nI]))
					EndIf
						
				Next nI
				
				aAdd(aCellSet,(cAlias)->RECNO)
				
				aAdd(aResultSet,aClone(aCellSet))
				
				aCellSet := {}
				
				(cAlias)->(DbSkip())
				
			End While	
			 
		EndIf
		
		(cAlias)->(DbGoTop())
		
		(cAliasTable)->(DbGoTo((cAlias)->RECNO))
		
	EndIf
	
	(cAlias)->(DbCloseArea())
	
Else
	lRet := .f.
EndIf

Return(lRet)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TPSXBGYNFIL()
Função generica para aplicar filtros a consulta padrão GYN - (Horários)
@sample	TPSXBGYNFIL()
@author	Yuki Shiroma		
@since		18/12/2017
@version	P12
/*/
//-----------------------------------------------------------------------------------------
Function TPSXBGYNFIL()         

Local oModel		:= FwModelActive()
Local cRet			:= "@#"
	// ------------------------------------------------------+
	// Filtra os horários para a tela de Horários x Viagem  |
	// ------------------------------------------------------+ 	
	If FwIsInCallStack("GTPA115") .And. oModel:GetId() == "GTPA115"
	 	cRet += " GYN->GYN_CODGID = '"+FwFldGet("GIC_CODGID")+"'"
	ElseIf FwIsInCallStack("GTPA116") .And. oModel:GetId() == "GTPA116"
		cRet += " GYN->GYN_CODGID = '"+FwFldGet("G9Z_CODHOR")+"'" 	
	EndIf
		
	cRet+= "@#"

Return(cRet)
//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPXUnq
Retorna o próximo número e o reserva antes de comitar.
@type function
@author crisf
@since 28/12/2017
@version 1.0
@param cTab, character, (Descrição do parâmetro)
@param cCpo, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///-----------------------------------------------------------------------------------------
Function GTPXUnq( cTab, nIndice, cCpo, lShow, nMAttempt )

	Local cChvRet	:= ''
	Local lExcMAx	:= .F.
	Local nMaxTent	:= 1
	Local nMax		:= 0
	
	Default lShow		:= .T.
	Default nMAttempt	:= 30

	nMax := nMAttempt
	
	cChvRet	:= GetSxeNum( cTab, cCpo )
	
	dbSelectArea(cTab)
	(cTab)->(dbSetOrder(nIndice))
	
	//Caso o controle de numeração esteja desatualizado tenta por nMax carregar um número disponivel
	While (cTab)->(dbSeek(xFilial(cTab)+cChvRet)) .AND. !lExcMAx
		
		if nMaxTent <= nMax
		
			ConfirmSX8()
			cChvRet	:= GetSxeNum( cTab, cCpo )
			nMaxTent	:= nMaxTent + 1
		
		Else
		
			lExcMAx	:= .T.
		
		EndIf
		
	EndDo
	
	While !lExcMAx .AND. !LockByName(cChvRet,.T.) .and. nMaxTent <= nMax
		
		ConfirmSX8()
		cChvRet	:= GetSxeNum( cTab, cCpo )
		nMaxTent	:= nMaxTent + 1

		if nMaxTent == nMax
			
			If ( lShow )
				Alert(" Não foi possível reservar o número, contate o Administrador do sistema")
			EndIf
				
		EndIf
		
	EndDo
	
	IF lExcMAx
		If ( lShow )
			Alert(" Não foi possível reservar o número, contate o Administrador do sistema")
		EndIf
	EndIf
				
Return cChvRet

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidUserAg
Valida se o usuário logado está vinculado a agencia
@type function
@author Flavio Martins
@since 28/12/2017
@version 1.0
@param cTab, character, (Descrição do parâmetro)
@param cCpo, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///-----------------------------------------------------------------------------------------

Function ValidUserAg(oMdl,cField,cNewValue,cOldValue)
Local lRet 		:= .T.
Local cAgenci	:= cNewValue
Local cMsgErro	:= ""
Local cMsgSoluc	:= ""
Default oMdl	:= nil
Default cField	:= ReadVar()
Default cNewValue:= &(ReadVar())
Default cOldValue:= ''

	GI6->(DbSetOrder(1))
	G9X->(DbSetOrder(1))
	If !GI6->(DbSeek(xFilial('GI6')+cAgenci))
		cMsgErro	:= "Agência informada não encontrada"
		cMsgSoluc	:= "Informe uma Agência valida"
		//oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"ValidUserAg","Agência informada não encontrada","Informe uma Agência valida")  
		lRet := .F.
	//Se usuário for administrador, ignora a validação de usuário (apenas para o usuário adm e não o grupo)
	ElseIf !(FwIsInCallStack("GTPI115")) .And. !G9X->(DbSeek(xFilial("G9X")+AllTrim(__cUserID)+cAgenci))
		cMsgErro	:= "Não há vínculo do usuário " + UsrRetName(__cUserID) + " com a agência selecionada"
		cMsgSoluc	:= "Informe uma Agência vinculada ao Usuário logado"
		//oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"ValidUserAg","Não há vínculo do usuário " + UsrRetName(__cUserID) + " com a agência selecionada","Informe uma Agência vinculada ao Usuário logado")  
		lRet := .F.
	EndIf
	If !lRet
		If ValType(oMdl) == "O"
			oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"ValidUserAg",cMsgErro,cMsgSoluc)  
		Else
			FWAlertHelp(cMsgErro,cMsgSoluc,"ValidUserAg")
		Endif
	Endif

Return lRet

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPXENUM
(long_description)
@type function
@author jacomo.fernandes
@since 30/03/2018
@version 1.0
@param cAlias, character, Informa o Alias a ser considerado
@param cField, character, Informa o Campo a ser buscado o Código
@param nIndex, numérico, Indice de pesquisa de chave
@return ${cCodigo}, ${Proximo numero valid}
@example GTPXENUM('G6X','G6X_CODIGO',2)
@see (links_or_references)
/*///-----------------------------------------------------------------------------------------
Function GTPXENUM(cAlias,cField,nIndex,lChkInSQL)

	Local cCodigo	:= GetSxeNum(cAlias,cField)

	Local aSeek		:= {}
	Local aResult	:= {{PrefixoCpo(cAlias)+"_FILIAL",cField}}

	Default	cAlias	:= Alias()
	Default cField	:= ReadVar()
	Default nIndex	:= 1
	Default lChkInSQL	:= .F.

	If ( !lChkInSQL )

		DbSelectArea(cAlias)

		(cAlias)->(DbSetOrder(nIndex))

		While (cAlias)->(DbSeek(xFilial(cAlias)+cCodigo))

			ConfirmSx8()
			cCodigo	:= GetSxeNum(cAlias,cField)
		
		End While
	
	Else
		
		AAdd(aSeek,{PrefixoCpo(cAlias)+"_FILIAL",FwXFilial(cAlias)})
		AAdd(aSeek,{cField,cCodigo,">="})

		While ( GTPSeekTable(cAlias,aSeek,aResult) .And. Len(aResult) > 1 )
			
			ConfirmSx8()
			
			cCodigo		:= GetSxeNum(cAlias,cField)
			aSeek[2,2]	:= cCodigo 

		End While

	EndIf
	
Return(cCodigo)

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} GtpxDoW
(long_description)
@type function
@author jacomo.fernandes
@since 09/05/2018
@version 1.0
@param xDow, , Informa a Data ou o Dia da Semana
@return ${cCodigo}, ${Proximo numero valid}
@example GTPXENUM('G6X','G6X_CODIGO',2)
@see (links_or_references)
/*/
//-----------------------------------------------------------------------------------------
Function GtpxDoW(xDow,nLen,lUpper,lCapital)
Local cRet			:= ""
Local nDiaSemana	:= 0
Default xDow		:= DoW(dDataBase)
Default nLen		:= 0
Default lUpper		:= .T.
Default lCapital	:= .F.

If ValType(xDow) == "D"
	nDiaSemana := Dow(xDow)
Else
	nDiaSemana := xDow
Endif

Do Case
Case nDiaSemana == 1
	cRet := "domingo"
Case nDiaSemana == 2
	cRet := "segunda-feira"
Case nDiaSemana == 3
	cRet := "terça-feira"
Case nDiaSemana == 4
	cRet := "quarta-feira"
Case nDiaSemana == 5
	cRet := "quinta-feira"
Case nDiaSemana == 6
	cRet := "sexta-feira"
Case nDiaSemana == 7
	cRet := "sabado"
EndCase

If lUpper
	cRet := Upper(cRet)
ElseIf lCapital
	cRet := Capital(cRet)
Endif

If nLen > 0
	cRet := SubStr(cRet,1,nLen)
Endif

Return cRet

/*/{Protheus.doc} GTPRmvChar
Remove Pares de character  
@type function
@author jacomo.fernandes
@since 30/07/2018
@version 1.0
@param cString, character, String a ser alterada
@param aPares, array, Array contendo os pares a serem alterados, sendo x[1] = Char a ser procurado, x[2] = Char a ser alterado (Ex.: { {'(','['} , {')',']'}} )
@return cRet, String alterada conforme parametros definidos
@example
(examples)
@see (links_or_references)
/*/
Function GTPRmvChar(cString,aPares)
Local n1		:= 0
Local cRet		:= cString
Default cString	:= ""
Default aPares	:= {} 

For n1	:= 1 To Len(aPares)
	cRet	:= StrTran(cRet,aPares[n1][1],aPares[n1][2])
Next

Return cRet

/*/{Protheus.doc} GTPxCriaCpo
Função responsavel pela criação de campos na strutura do modelo/view conforme o SX3
@type function
@author jacomo.fernandes
@since 24/01/2019
@version 1.0
@param oStruct, objeto, (Descrição do parâmetro)
@param aFields, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPxCriaCpo(oStruct,aFields,lModel)
Local aSx3Area	:= SX3->(GetArea())
Local aCBox		:= nil
Local n1		:= 0
Local aTamSx3	:= {}
Default lModel	:= .F.

If lModel .and. oStruct:IsEmpty()
	oStruct:AddTable("   ",{" "}," ")//Cria tabela temporaria
Endif

SX3->(DbSetOrder(2))

For n1 := 1 to Len(aFields)
	
	If SX3->(DbSeek(aFields[n1]))
		If !Empty(X3CBOX())
			aCBox := Separa(X3CBOX(),";")
		Else
			aCBox := nil
		Endif
		
		aTamSx3	:= TamSx3(aFields[n1])
		
		If lModel
			oStruct:AddField( 								  ; // Ord. Tipo Desc.
								FWX3Titulo(aFields[n1]) 				  	, ; // [01] C Titulo do campo
								""     					  	, ; // [02] C ToolTip do campo
								AllTrim(aFields[n1]) 		, ; // [03] C identificador (ID) do Field
								aTamSx3[3]  				, ; // [04] C Tipo do campo
								aTamSx3[1]  			, ; // [05] N Tamanho do campo
								aTamSx3[2]  			, ; // [06] N Decimal do campo
								FwBuildFeature(STRUCT_FEATURE_VALID,GetSx3Cache(aFields[n1],"X3_VALID") )	, ; // [07] B Code-block de validação do campo
								NIL    						, ; // [08] B Code-block de validação When do campoz
								aCBox  						, ; // [09] A Lista de valores permitido do campo
								.F.    						, ; // [10] L Indica se o campo tem preenchimento obrigatório
								NIL    						, ; // [11] B Code-block de inicializacao do campo
								.F.    						, ; // [12] L Indica se trata de um campo chave
								.F.    						, ; // [13] L Indica se o campo pode receber valor em uma operação de update.
								.T.							  ; // [14] L Indica se o campo é virtual
							)
				
		Else
			oStruct:AddField( 								  ; // Ord. Tipo Desc.
								AllTrim(aFields[n1])  	, ; // [01] C Nome do Campo
								StrZero(Len(oStruct:GetFields())+1, 2)   			, ; // [02] C Ordem
								FWX3Titulo(aFields[n1]) 					, ; // [03] C Titulo do campo
								FWX3Titulo(aFields[n1]) 					, ; // [04] C Descrição do campo
								NIL   						, ; // [05] A Array com Help
								aTamSx3[3]   				, ; // [06] C Tipo do campo
								GetSX3Cache(aFields[n1], "X3_PICTURE"), ; // [07] C Picture								
								NIL    						, ; // [08] B Bloco de Picture Var
								GetSX3Cache(aFields[n1], "X3_F3")					, ; // [09] C Consulta F3
								.T.    						, ; // [10] L Indica se o campo é editável
								NIL    						, ; // [11] C Pasta do campo
								NIL    						, ; // [12] C Agrupamento do campo
								aCBox   					, ; // [13] A Lista de valores permitido do campo (Combo)
								NIL    						, ; // [14] N Tamanho Máximo da maior opção do combo
								NIL    						, ; // [15] C Inicializador de Browse
								.T.							, ; // [16] L Indica se o campo é virtual
								NIL    						  ; // [17] C Picture Variável
							)
		Endif
	Endif

Next

RestArea(aSx3Area)

Return


/*/{Protheus.doc} GTPxFldRpt
(long_description)
@type function
@author jacomo.fernandes
@since 19/03/2019
@version 1.0
@param oStruView, objeto, (Descrição do parâmetro)
@param cMdlId, character, (Descrição do parâmetro)
@param aNoFld, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPxFldRpt(oStruView,cMdlId,aNoFld,aRetorno)
Local aRet		:= {}
Local aFld		:= oStruView:GetFields()
Local n1		:= 0
Default aRetorno:= {}

aRet := aClone(aRetorno)

For n1 := 1 To Len(aFld)
	If aScan(aNoFld,aFld[n1]) == 0
		aAdd(aRet,{cMdlId,aFld[n1][1],aFld[n1][7],aFld[n1][13]})
	Endif
Next

Return aRet

/*/{Protheus.doc} GTPxAr2Txt
(long_description)
@type function
@author jacomo.fernandes.
@since 19/03/2019
@version 1.0
@param aArray, array, (Descrição do parâmetro)
@param cToken, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPxAr2Txt(aArray,cToken)
Local cRet		:= ""
Local n1		:= 0
Default aArray	:= {}
Default cToken	:= ";"

For n1 := 1 To Len(aArray)
	cRet += AllTrim(aArray[n1])+cToken
Next

cRet := SubStr(cRet,1, Len(cRet)-Len(cToken))

Return cRet


/*/{Protheus.doc} GTPXTmpFld
(long_description)
@type function
@author jacomo.fernandes
@since 04/05/2019
@version 1.0
@param aListFld, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPXTmpFld(aListFld)
Local aRet		:= {}
Local aFldAux	:= {}
Local n1		:= 0

For n1 := 1 to Len(aListFld)
	If AllTrim(GetSx3Cache(aListFld[n1],"X3_CAMPO")) == AllTrim(aListFld[n1]) 
		aFldAux := {}
		aAdd(aFldAux,aListFld[n1])//Nome
		aAdd(aFldAux,GetSx3Cache(aListFld[n1],"X3_TIPO"))//Tipo
		aAdd(aFldAux,GetSx3Cache(aListFld[n1],"X3_TAMANHO"))//Tamanho
		aAdd(aFldAux,GetSx3Cache(aListFld[n1],"X3_DECIMAL"))//Decimal
		aAdd(aRet,aClone(aFldAux))
	Else
		aFldAux := {}
		aAdd(aFldAux,aListFld[n1])//Nome
		aAdd(aFldAux,'C')//Tipo
		aAdd(aFldAux,1)//Tamanho
		aAdd(aFldAux,0)//Decimal
		aAdd(aRet,aClone(aFldAux))
	
	Endif
Next

GTPDestroy(aFldAux)

Return aRet


/*/{Protheus.doc} GTPxSeekLine
(long_description)
@type function
@author jacomo.fernandes
@since 09/05/2019
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cSeek, character, (Descrição do parâmetro)
@param aFlds, array, (Descrição do parâmetro)
@param lDelete, ${param_type}, (Descrição do parâmetro)
@param lPosiciona, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPxSeekLine(oMdl,cSeek,aFlds,lDelete,lPosiciona)
Local lRet		:= .T.
Local aMdlFld	:= oMdl:GetStruct():GetFields()
Local aDataModel:= oMdl:GetData()
Local nPosReg	:= 0
Local nPosFld	:= 0
Local n1		:= 0
Local cEval		:= "{|x| "

Default lDelete		:= .F.
Default lPosiciona	:= .T.

For n1 := 1 To Len(aFlds)
	cField		:= aFlds[n1] // Ex: "A1_COD"
	If (nPosFld := aScan(aMdlFld,{|x| x[3] == cField }) ) > 0
		aFlds[n1] := ' x[1,1,'+cValToChar(nPosFld)+']'
	Else
		lRet := .F.
	Endif
Next

cEval += I18n(cSeek,aFlds)

If !lDelete
	cEval += ' .and.  !x[3] ' //Não Busca os Deletados
Endif

cEval		+= "}"
If lRet 
	If (nPosReg := aScan(aDataModel,&(cEval))) > 0
		lRet := .T.
	Else
		lRet := .F.
	Endif
	
	If lRet  .and. lPosiciona
		lRet := oMdl:GoLine(nPosReg) == nPosReg 
	Endif
Endif
Return lRet


/*/{Protheus.doc} GTPxClearData
(long_description)
@type function
@author jacomo.fernandes
@since 10/05/2019
@version 1.0
@param oGrid, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPxClearData(oGrid,lAddLine,lRealDel,lForce)
Local n1            := 0
Local nNewLine      := 0
Local lInsLine      := !oGrid:CanInsertLine()
Local lUpdLine      := !oGrid:CanUpdateLine()
Local lDelLine      := !oGrid:CanDeleteLine()

Default lAddLine    := .T.
Default lRealDel    := .T.
Default lForce      := .T.

oGrid:SetNoUpdateLine(.F.)// NÃO Bloquea atualização da grid
oGrid:SetNoInsertLine(.F.)// NÃO Bloquea inserção de nova linha no grid
oGrid:SetNoDeleteLine(.F.)// NÃO Bloquea deleção da linha

If lAddLine
    nNewLine := oGrid:AddLine(.T.)
    oGrid:LineShift(1,nNewLine)
Endif

For n1 := oGrid:Length() To 1 step -1
	oGrid:Goline(n1)
	oGrid:DeleteLine(lRealDel,lForce)
Next n1

oGrid:Goline(1)

If lAddLine
    oGrid:UnDeleteLine()
Endif


oGrid:SetNoInsertLine(lInsLine)// Bloquea inserção de nova linha no grid
oGrid:SetNoUpdateLine(lUpdLine)// Bloquea atualização da grid
oGrid:SetNoDeleteLine(lDelLine)// Bloquea deleção da linha


Return


/*/{Protheus.doc} GxVlCliFor
Função responsavel para validar Cliente ou Fornecedor
@type function
@author jacomo.fernandes
@since 21/05/2019
@version 1.0
@param cAliCliFor, character, Informa qual alias deseja validar, sendo SA1 para cliente SA2 para fornecedor
@param cCodigo, character, Código do Cliente/Fornecedor
@param cLoja, character, Loja do Cliente/Fornecedor
@return lRet, Retorna verdadeiro se encontrar o registro
@example
(examples)
@see (links_or_references)
/*/
Function GxVlCliFor(cAliCliFor,cCodigo,cLoja,lVldBloq)
Local lRet		:= .T.
Local cSeek		:= PadR(cCodigo,TamSx3("A1_COD")[1])

Default lVldBloq:= .T.

If !Empty(cLoja)
	cSeek += PadR(cLoja,TamSx3("A1_LOJA")[1])
Endif

lRet := GTPExistCpo(cAliCliFor,cSeek,1,lVldBloq)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPExistCpo

@type function
@author jacomo.fernandes
@since 11/06/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return lRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPExistCpo(cAliAux,cChave,nIndice,lBloq,cFilAux,cNickName,cErro)
Local lRet			:= .F.
Local aArea			:= nil
Default cAliAux		:= cAlias
Default cChave		:= ""
Default nIndice		:= 1
Default lBloq		:= .T.
Default cFilAux		:= FwxFilial(cAliAux)
Default cNickName	:= ""
Default cErro		:= ""

If !Empty(cChave)
	aArea := (cAliAux)->(GetArea())

	If !Empty(cNickName)
		(cAliAux)->(DbOrderNickname(cNickName))
	Else
		(cAliAux)->(DbSetOrder(nIndice))
	Endif

	If (cAliAux)->(DbSeek(cFilAux+cChave))
		lRet	:= .T.
	Else
		cErro	:= "Registro não encontrado"
	Endif

	If lRet .and. lBloq .and. !RegistroOk(cAliAux)
		lRet := .F.
		cErro	:= "Registro se encontra bloqueado"
	Endif	

	RestArea(aArea)
Endif

GTPDestroy(aArea)

Return lRet

/*/{Protheus.doc} GxVldHora
(long_description)
@type function
@author jacomo.fernandes
@since 21/05/2019
@version 1.0
@param cHorario, character, (Descrição do parâmetro)
@param lVldOnlyMin, ${param_type}, (Descrição do parâmetro)
@param lShowMsg, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GxVldHora(cHorario,lVldOnlyMin,lShowMsg)
Local lRet		:= .T.
Local nPosToken := At( ":", cHorario )
Local cHora		:= ""
Local cMinuto	:= ""

Default	cHorario	:= "0000"
Default lVldOnlyMin	:= .F.
Default lShowMsg	:= .T.

If nPosToken > 0
	cHora	:= SubStr(cHorario,1,nPosToken)
	cMinuto	:= SubStr(cHorario,nPosToken+1)
Else
	// Se o horario informado for um totalizador por Exemplo: 122:59
	// a variavel cHora vai pegar da posição 1 até a posição do minuto 
	cHora	:= SubStr(cHorario,1,Len(cHorario)-2)
	cMinuto	:= SubStr(cHorario,Len(cHorario)-1)
Endif

If Len(cHora) > 2
	lVldOnlyMin := .T.
Endif


If !lVldOnlyMin 
	lRet := ( cHora >= "00" .AND. cHora < "24" ) .and. (cMinuto >= "00" .AND. cMinuto < "60" )
Else
	lRet := (cMinuto >= "00" .AND. cMinuto < "60" )
Endif

If !lRet .and. lShowMsg
	If !lVldOnlyMin
		Help(NIL, NIL, "VLDHORA")
	Else
		Help(NIL, NIL, "VLDMIN")
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GtpTitNum()
 
Retorna o próximo número de documento da tabela SE1/SE2

@sample	GTPA700()
 
@return	
 
@author	SIGAGTP 
@since		
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GtpTitNum(cAlias, cPrefixo, cParcela, cTipo)
Local cField		:= Iif(cAlias == 'SE1','E1_NUM', 'E2_NUM')
Local cNum 			:= GetSxEnum(cAlias, cField, cEmpAnt+xFilial(cAlias)+cPrefixo+cParcela+cTipo) 

Default cPrefixo	:= ""
Default cParcela	:= ""
Default cTipo		:= ""
	
	(cAlias)->(dbSetOrder(1))

	While (cAlias)->(dbSeek(xFilial(cAlias)+cPrefixo+cNum+cParcela+cTipo))
		ConfirmSX8()
		cNum := GetSxEnum(cAlias, cField, cEmpAnt+xFilial(cAlias)+cPrefixo+cParcela+cTipo)		
	End
	
	ConfirmSX8()
	
Return cNum

/*/{Protheus.doc} GTPxIsDigit
(long_description)
@type function
@author jacomo.fernandes
@since 03/10/2019
@version 1.0
@param cString, character, (Descrição do parâmetro)
/*/
Function GTPxIsDigit(cString)
Local lRet	    := .T.
Local nI	    := 0
Default cString := ""

cString := AllTrim(cString)

For nI := 1 to Len(cString)
	
	If  !IsDigit( Substr(cString, nI, 1) ) 
		lRet := .F.
		Exit
	Endif

Next nI

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} GtpIsInMsg
Função responsavel para retornar se no momento se encontra em uma rotina de mensagem do FW
@type Function
@author jacomo.fernandes
@since 06/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return lRet, Retorno logico
/*/
//------------------------------------------------------------------------------
Function GtpIsInMsg()
Local lRet  :=  FwIsInCallStack("FWALERTYESNO")  ;
                .AND. FwIsInCallStack("FWALERTSUCCESS") ;
                .AND. FwIsInCallStack("FWALERTERROR") ;
                .AND. FwIsInCallStack("FWALERTHELP") ;
                .AND. FwIsInCallStack("FWALERTEXITPAGE") 
Return lRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} GtpBtnView()

@type Function
@author jacomo.fernandes
@since 18/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Function GtpBtnView(lConf,cTitConf,lClose,cTitClose)
Local aEnableButtons := NIL

Default lConf       := .T.
Default cTitConf    := "Confirmar"
Default lClose      := .T.
Default cTitClose   := "Fechar"

aEnableButtons := {;
                        {.F.,Nil},{.F.,Nil},{.F.,Nil},;
                        {.F.,Nil},{.F.,Nil},{.F.,Nil},;
                        {lConf, cTitConf },; //Botão Confirmar
                        {lClose, cTitClose},;//Botão Fechar
                        {.F.,Nil},{.F.,Nil},{.F.,Nil},;
                        {.F.,Nil},{.F.,Nil},{.F.,Nil};
                    }	//"Confirmar"###"Fechar"

Return aEnableButtons

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TPSXBGIDFIL()
Função generica para aplicar filtros a consulta padrão GID - (Horários)
@sample	TPSXBGIDFIL()
@author	Lucas.Brustolin
@since		12/01/2016
@version	P12
/*/
//-----------------------------------------------------------------------------------------
Function TPSXBGIDFIL()         

Local oModel		:= FwModelActive()
Local lRet 			:= .F.

	// ------------------------------------------------------+
	// Filtra os horários para a tela de Trechos x Horários  |
	// ------------------------------------------------------+ 	
	If FwIsInCallStack("GTPA300") .And. oModel:GetId() == "GTPA300"
	 	If GID->GID_LINHA == FwFldGet("GYN_LINCOD") .And. GID->GID_SENTID == FwFldGet("GYN_LINSEN") .And. GID->GID_HIST == "2"
	 		lRet := .T.
	     EndIf
	ElseIf FwIsInCallStack("GTPA116") .And. oModel:GetId() == "GTPA116" 	
		If GID->GID_LINHA == FwFldGet("G9Z_CODLIN") .And. GID->GID_SENTID == FwFldGet("G9Z_SENTID") .And. GID->GID_HIST == "2"
	 		lRet := .T.
	     EndIf
	EndIf	


Return(lRet)

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPLabelCo
Alguns campos que não existem no dicionário de dados, mas que são utilizados no relatório
possuem um título identificador. Esta função retorna tal título.

@type 		Function
@author 	GTP
@since 		25/08/2020
@version 	12.1.30
/*/
//+----------------------------------------------------------------------------------------

Function GTPLabelCo(cField)

Local cRet		:= ""
Local nP		:= 0
Local nIdioma   :=1

Local aLabels 	:= { 	{"LBL_FILIAL","Filial:"},;									
						{"LBL_ENDER",GTPGetTitle("Endereço:",nIdioma)},;//"Endereço:"
						{"LBL_CEP",GTPGetTitle("CEP:",nIdioma)},;//"CEP:"
						{"LBL_CIDADE",GTPGetTitle("Cidade:",nIdioma)},;//"Cidade:"
						{"LBL_TEL",GTPGetTitle("Telefone:",nIdioma)},;//"Telefone:"
						{"LBL_NOME",GTPGetTitle("Fornecedor:",nIdioma)},;//"Fornecedor:"
						{"LBL_BAIRRO",GTPGetTitle("Bairro:",nIdioma)},;//"Bairro:"
						{"LBL_UF",GTPGetTitle("UF:",nIdioma)}}//"UF:"
				
nP := aScan(aLabels,{|x| Alltrim(x[1]) == Alltrim(cField)})

If ( nP > 0 )
	cRet := aLabels[nP,2]
Endif

Return(cRet)

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPGetTitle
Retorna o titulo com base no STR e idioma informado no parametro.
@author 	GTP
@since 		25/08/2020
@version 	12.1.30
/*/
//+----------------------------------------------------------------------------------------
Static Function GTPGetTitle(cStr,nIdioma)

Local cTitle	:= ""
Local nPos		:= 0
	
	If ( nPos := aScan( aTitle, { |X|  X[3] == cStr } ) ) > 0	
		//-- Idioma = 1 (Portugues), Idioma = 2 (Inglês) ;
		cTitle := aTitle[nPos][nIdioma]
	EndIf
	
	
Return(cTitle)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GtpIsInPoui
Função generica de validação para as paginas web
@type Function
@author 
@since 03/02/2021
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GtpIsInPoui()
Local lRet := .T.

If FWISINCALLSTACK("POST")
	lRet := .F.
EndIf

If FWISINCALLSTACK("PUT")
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} GTPXOrigem
função utilizada em outro modulo
@type function
@author jacomo.fernandes
@since 12/12/2018
@version 1.0
@param cTypo, character, (Descrição do parâmetro)
@param cOrigem, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPXOrigem(cType,cOrigem)
Local lRet	:= .T.

If (cOrigem == "GTPA284" .OR. cOrigem == "GTPA600")
	If FwIsInCall('GTPA284') .OR. FwIsInCall('GTPA600')
		Return lRet
	Endif

	lRet	:= .F.	
	
	If cType = "A410Altera"
		Help(,,'GTPXOrigem',, "Este Pedido não pode ser alterado pois foi gerado pelo módulo GTP.",1,0)
	Else
		Help(,,'GTPXOrigem',, "Este Pedido não pode ser excluído pois foi gerado pelo módulo GTP.",1,0)
	Endif
	
Endif

Return lRet

/*/{Protheus.doc} GTPEXCNF
Função utilizada em outro módulo.
@author GTP
@since 30/12/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTPEXCNF(cF2_FILIAL,cF2_CLIENTE,cF2_LOJA,cF2_DOC,cF2_SERIE,cF2_ESPECIE,cF2_EMISSAO)
Local lRet := .F.
Local cAliasTmp	:= GetNextAlias()


BeginSql Alias cAliasTmp

	Select R_E_C_N_O_
	From %Table:GIC%
	WHERE
		GIC_FILNF = %Exp:cF2_FILIAL%
		AND GIC_CLIENT = %Exp:cF2_CLIENTE%
		AND GIC_LOJA = %Exp:cF2_LOJA%		
		AND GIC_NOTA = %Exp:cF2_DOC%
		AND GIC_SERINF = %Exp:cF2_SERIE%		
		AND %NotDel%
			
EndSql
 
If (cAliasTmp)->R_E_C_N_O_ > 0
	DbSelectArea("GIC")		
	GIC->(DbGoTo((cAliasTmp)->R_E_C_N_O_))
	RecLock("GIC",.F.)
	GIC->GIC_FILNF := ''
	GIC->GIC_CLIENT := ''
	GIC->GIC_LOJA := ''
	GIC->GIC_NOTA := ''
	GIC->GIC_SERINF := ''
	GIC->GIC_VLBICM := 0
	GIC->GIC_VLICMS := 0
	GIC->GIC_VLPIS := 0
	GIC->GIC_VLCOF := 0
	GIC->GIC_STAPRO= '0'
	GIC->(MsUnLock())
	lRet := .T.	
Endif

(cAliasTmp)->(DbCloseArea())

Return lRet
  
/*/{Protheus.doc} GTPFUNCRET
	(Retorna funções que fazem parte do contexto do parâmetro enviado, 
	por regra padrão ao passar a função ativa terá o retorno de funções que fazem parte do contexto)
	@type  Function
	@author marcelo.adente
	@since 27/04/2022
	@version 1.0
	@param cOrigExt, string, Origem que irá chamar a verificação de funcionalidades por regra
	@param cOperExt, string, Tipo de Operação 0=visualiza/1=inclui/2=altera/3=exclui/4=copia 
	@param cTabExt, string, Tabela de comparação do campo de Origem

	@return cFuncoes, string, Retorna funções que fazem parte do escopo
	@example ( 
		 		GTPFUNCRET('FINXAPI','3', 'SE1')
				Return 'GTPA421|GTPA700|GTPA700A|GTPA700L|GTAP819|'
			)
	@see (https://tdn.totvs.com.br/pages/viewpage.action?pageId=683363061)
	/*/
Function GTPFUNCRET(cOrigExt,cOperExt,cTabExt)
	Local cFuncoes := ''
	Default cOrigExt := ''
	Default cOperExt := ''
	Default cTabExt := ''

	// Agrupamento relacionado a manipulação de títulos no financeiro
	if cOrigExt $ 'FINA040|FINA050|FINA060|FINA070|FINA080|FINXAPI'
		cFuncoes := 'GTPA421|GTPA700|GTPA700A|GTPA700L|GTPA819|'
	endif

Return cFuncoes

/*/{Protheus.doc} GTPSumTime(cHr1,cHr2,nCountDays,cFormatHr)
	Função que efetua soma de horas
	@type  Function
	@author Fernando Radu Muscalu
	@since 05/05/2022
	@version 1.0
	@params 
		cHr1, string, Hora para somar
		cHr1, string, Hora a ser somada
		nCountDays, numeric, quantidade de dias, de acordo com somas
		maiores de que 24h
		cFormatHr, string, formatação do horário

	@return cSumHrs, string, Horário calculado na soma
	@example
	@see 
/*/
Function GTPSumTime(cHr1,cHr2,nCountDays,cFormatHr)

	Local cHour1	:= GTFormatHour(cHr1,"99:99")
	Local cHour2	:= GTFormatHour(cHr2,"99:99")
	Local cSumHrs	:= "00:00"
	Local cSubHrs	:= "00:00"
	
	Default nCountDays := 0
	Default cFormatHr := "99:99"
	
	cSumHrs := SomaHoras(cHour1,cHour2)
	
	If ( cSumHrs > 23.59 )
		nCountDays++
		cSubHrs := SubHoras(GTFormatHour(cSumHrs,"99:99"),"24:00")
		cSumHrs := GTPSumTime(0,cSubHrs,@nCountDays)
	ElseIf ( cSumHrs < 0 )
		nCountDays--
		cSumHrs := GTPSumTime(24,cSumHrs,@nCountDays)
	EndIf	
	
	cSumHrs := GTFormatHour(cSumHrs,cFormatHr)

Return(cSumHrs)
/*/{Protheus.doc} GTPSubTime(cHr1,cHr2,cFormatHr)
	Função que efetua subtração de horas
	@type  Function
	@author Fernando Radu Muscalu
	@since 05/05/2022
	@version 1.0
	@params 
		cHr1, string, Hora que sofrerá subtração
		cHr1, string, Hora a ser subtraída
		cFormatHr, string, formatação do horário

	@return cSubHrs, string, Horário calculado na subtração
	@example
	@see 
/*/
Function GTPSubTime(cHr1,cHr2,cFormatHr)

	Local cHour1	:= GTFormatHour(cHr1,"99:99")
	Local cHour2	:= GTFormatHour(cHr2,"99:99")
	Local cSubHrs	:= "00:00"
	
	Default cFormatHr := "99:99"
	
	cSubHrs :=  GTFormatHour(SubHoras(cHour1,cHour2),cFormatHr)

Return(cSubHrs)
