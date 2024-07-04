#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'DPRXINTEG.CH'
#DEFINE PULALINHA CHR(13)+CHR(10)
//--------------------------------------------------------------------
/*/{Protheus.doc} ValidaDPR()
Retorna se o programa DPR pode ser aberto.

@param			cParam		Valor do MV_INTDPR
@return		aRet 		Retorna um vetor com:
						[1] = Lógico informando se o programa será abortado
						[2] = Mensagem de erro

@author 	Ana Carolina Tomé Klock
@since 		30/05/2013
@version 	P12
/*/
//--------------------------------------------------------------------
Function ValidaDPR( cParam )
Local aRet 		:= { .T., '' }
Local aTabelas  := {}
Local nI
Default cParam := cValToChar(DPRIntegra())

dbSelectArea('SX3')
SX3->(dbSetOrder(2))
if !SX3->(dbSeek('DG3_CDFATD'))
	aRet[1] := .F.
	aRet[2] := 'DPR_UPDATE001' // Caso não exista o campo, deve executar update
Elseif !SX3->(dbSeek('DG0_CDRTDE'))
	aRet[1] := .F.
	aRet[2] := 'DPR_UPDATE003' // Caso não exista o campo, deve executar update
Endif

// Valida se esta integrado
If AllTrim(cParam) == '0'
	aRet[1] := .F.
	aRet[2] := 'DPR_SEM_INTEG'

// Se estiver integrado com o Protheus
ElseIf AllTrim(cParam) == '1'
	aTabelas := DPRCompPCP()
	For nI := 1 to len(aTabelas)
    	If FwAliasInDic(aTabelas[nI,2])
    		If FwModeAccess(aTabelas[nI,2],3) != aTabelas[nI,3] .Or. ;
				FwModeAccess(aTabelas[nI,2],2) != aTabelas[nI,4] .Or. ;
				FwModeAccess(aTabelas[nI,2],1) != aTabelas[nI,5]
				aRet[1] := .F.
				aRet[2] := 'DPR_PARAM_1'
				Exit
			EndIf
		EndIf
	Next nI
EndIf

Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} ValidFATDP()
Valida se o há diferença de exclusividade/compartilhamento das tabelas

@return Retorna .F. se estão diferentes e .T. se estão iguais
@author 	Ezequiel Ramos
@since 		04/11/2013
@version 	P12
/*/
//--------------------------------------------------------------------
Function ValidFATDP()
	Local aSC5 := {}
	Local aSCK := {}
	Local aSC2 := {}
	
	aadd(aSC5,{ FwModeAccess("SC5",3), FwModeAccess("SC5",2), FwModeAccess("SC5",1) })
	aadd(aSC5,{ FwModeAccess("DGC",3), FwModeAccess("DGC",2), FwModeAccess("DGC",1) })
	
	IF aSC5[1][1] != aSC5[2][1] .OR.;
	   aSC5[1][2] != aSC5[2][2] .OR.;
	   aSC5[1][3] != aSC5[2][3]
	   	DPRXError( 'DPRXINTEG', STR0036, 1 ) // 'Há diferença de exclusividade/compartilhamento entre as tabelas SC5 e DGC'
		Return .F.
	Endif
		
	aadd(aSCK,{ FwModeAccess("SCK",3), FwModeAccess("SCK",2), FwModeAccess("SCK",1) })
	aadd(aSCK,{ FwModeAccess("DGC",3), FwModeAccess("DGC",2), FwModeAccess("DGC",1) })
	
	IF aSCK[1][1] != aSCK[2][1] .OR.;
	   aSCK[1][2] != aSCK[2][2] .OR.;
	   aSCK[1][3] != aSCK[2][3]
	   	DPRXError( 'DPRXINTEG', STR0037, 1 ) // 'Há diferença de exclusividade/compartilhamento entre as tabelas SCK e DGC'
		Return .F.
	Endif
	
	aadd(aSC2,{ FwModeAccess("SC2",3), FwModeAccess("SC2",2), FwModeAccess("SC2",1) })
	aadd(aSC2,{ FwModeAccess("DGH",3), FwModeAccess("DGH",2), FwModeAccess("DGH",1) })
	
	IF aSC2[1][1] != aSC2[2][1] .OR.;
	   aSC2[1][2] != aSC2[2][2] .OR.;
	   aSC2[1][3] != aSC2[2][3]
	   	DPRXError( 'DPRXINTEG', STR0038, 1 ) // 'Há diferença de exclusividade/compartilhamento entre as tabelas SC2 e DGH'
		Return .F.
	Endif
	
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} INTEGERROR
Retorna o erro gerado durante a integração com o Datasul

@param 	oModel		Model a ser utilizado

@return	aArray		{ Boolean, String }

@author Ana Carolina Tomé Klock
@since 03/05/2012
@version P12
/*/
//--------------------------------------------------------------------
Function INTEGERROR( oModel )
Local aArray       := {}
Default lAutoMacao := .F.

IF !lAutoMacao
	aErro := oModel:GetErrorMessage()
ENDIF

aAdd( aArray, .F.)
aAdd( aArray, INTEGXTOS(aErro[6]) + ' (' + INTEGXTOS(aErro[4]) + ' = "' + INTEGXTOS(aErro[9]) + '") - INTEGERROR' )

Return aArray

//--------------------------------------------------------------------
/*/{Protheus.doc} INTEGXTOS()
Converte o valor passado para caracter durante a integração com o Datasul

@param	xValue 	Valor a ser transformado

@return cValue	Valor transformado em caracter

@author Ana Carolina Tomé Klock
@since 03/05/2012
@version P12
/*/
//--------------------------------------------------------------------
Function INTEGXTOS( xValue )
Local cValue   := ""
Default xValue := ""

Do case
	// Data
 	Case ValType(xValue) == 'D'
  		cValue := DTOS(xValue)

    //Lógico
    Case ValType(xValue) == 'L'
    	If xValue
     		cValue := 'true'
     	Else
     		cValue := 'false'
     	EndIf

    // Numérico
    Case ValType(xValue) == 'N'
     	cValue := cValToChar(xValue)

    // Caracter
    Case ValType(xValue) == 'C'
    	cValue := xValue

    // Array, Bloco de código, objeto ou não definido
  	Otherwise
  		cValue := ""
	EndCase

Return cValue
//--------------------------------------------------------------------
/*/{Protheus.doc} INTEGSTOX()
Converte uma string para qualquer valor durante a integração com Datasul

@param 	cValue 	Valor a ser transformado
@param		cType  	Em que tipo será transformado

@return xValue 	Valor convertido

@author Ana Carolina Tomé Klock
@since 01/07/2011
@version 1.0
/*/
//--------------------------------------------------------------------
Function INTEGSTOX( cValue, cType )
Local xValue   := ""
Default cValue := ""
Default cType  := 'C'

Do case
	// Data
	Case cType == 'D'
		cValue := StrTran(INTEGXTOS(cValue), "-", "")
		xValue := STOD(cValue)

	// Datetime pra Data
	Case cType == 'DTD'
		xValue := STOD(INTEGXTOS(INTEGDTTOA(cValue)[1]))

	// Datetime pra Data (Str)
	Case cType == 'DTDS'
		xValue := INTEGXTOS(INTEGDTTOA(cValue)[1])

	// Datetime pra Data (Str)
	Case cType == 'DTTS'
		xValue := INTEGXTOS(INTEGDTTOA(cValue)[2])

	// Datetime pra Data
	Case cType == 'DTT'
		xValue := INTEGDTTOA(cValue)[2]

    //Lógico
    Case cType == 'L'
    	If cValue == 'true' .Or. cValue == 'yes'
    		xValue := .T.
     	Else
     		xValue := .F.
     	EndIf

   	// Numérico
   	Case cType == 'N'
   		xValue := Val(cValue)

   	// Array
   	Case ValType(cValue) == 'A'
   		xValue := cValue

   	// Caracter
   	Case cType == 'C'
   	    xValue := cValToChar(cValue)

   	// Bloco de código, objeto e não definido
  	Otherwise
	 	xValue := ""
	EndCase

Return xValue

//--------------------------------------------------------------------
/*/{Protheus.doc} INTEGDTTOA()
Converte um valor AAAA-MM-DDTHH:MM:SS.000 para um array durante a integração Datasul

@param 	cString		(Obrigatorio) Valor recebido no formado DateTime
@return	aArray		{ Date, Time }

@author Ana Carolina Tome Klock
@since 13/01/2012
@version 1.0
/*/
//--------------------------------------------------------------------
Function INTEGDTTOA( cString )
    Local aArray := {}
    Default cString := "9999-12-31T00:00:00.000"

	cData := SubStr(cString, 9, 2) + "/" + SubStr(cString, 6, 2) + "/" + SubStr(cString, 1, 4)
    aAdd( aArray, INTEGXTOS(CTOD(cData)))
	aAdd( aArray, Substr(cString, 12, 8))

Return aArray
//--------------------------------------------------------------------
//Tabelas DPR - Retorna lista de tabelas que é usada pelo DPR
//--------------------------------------------------------------------
Static Function TabelasDPR()
	//Tabelas Manufatura(Usado pelo SFC também)
	Local aTabelasM := MANTabelas()
	Local nI
	
	Local aTabelas	:= {;
		{'SG1','DG0','C','C','C'},;		//-- Versão Produto
		{'SG1','DG1','C','C','C'},;		//-- Estrutura
		{'SG1','DG2','C','C','C'},;		//-- Ferramenta Operação
		{'SB1','DG3','C','C','C'},;		//-- Produto Desenvolvido
		{'SG1','DG4','C','C','C'},;		//-- Componente Alternativo
		{'SG1','DG5','C','C','C'},;		//-- Custo de Versão
		{'SG1','DG6','C','C','C'},;		//-- Narrativa Desenvolvedor Produto
		{'SG1','DG7','C','C','C'},;		//-- Operação Alternativa Versão
		{'SG1','DG8','C','C','C'},;		//-- Consumível Operação
		{'SG1','DG9','C','C','C'},;		//-- Operação Produto
		{'SG1','DGA','C','C','C'},;		//-- Preço do Produto Concorrente
		{'SG1','DGB','C','C','C'},;		//-- Atributo Extra
		{'SC5','DGC','C','C','C'},;		//-- Pendência Desenvolvimento
		{'SG1','DGD','C','C','C'},;		//-- Rede Pert de Atividades
		{'SG1','DGE','C','C','C'},;		//-- Critério de Qualidade
		{'SG1','DGF','C','C','C'},;		//-- Peso do Critério no Valor do Produto
		{'SG1','DGG','C','C','C'},;		//-- Lista de Atributos Extras Versão
		{'SC2','DGH','C','C','C'},;		//-- Ordem Protótipo
		{'SG1','DGI','C','C','C'},;		//-- Valor Critério Concorrente
		{'SG1','DGJ','C','C','C'},;		//-- Valor Critério Produto
		{'SG1','DGK','C','C','C'},;		//-- Lista de Atributos Produto
		{'SG1','DGL','C','C','C'},;		//-- Histórico de Mudança da Situação
		{'SG1','DGM','C','C','C'},;		//-- Desenho Produto Desenvolvido
		{'SG1','DGN','C','C','C'},;		//-- Ficha Técnica
		{'SG1','DGO','C','C','C'},;		//-- Atributos Ficha Técnica
		{'SC5','DGP','C','C','C'};		//-- Versões Associadas a Pendência
	}

	//Merge nas listas
	For nI := 1 To Len(aTabelasM)
		aAdd(aTabelas,aTabelasM[nI])
	Next
	//Remove tabelas que não existem no SX2
	ValSX2Tabs(@aTabelas)
Return aTabelas
//--------------------------------------------------------------------
/*/{Protheus.doc} DPRCompPCP()
Compara as tabelas cadastradas para o DPR com o legado PCP

@return		aTabelas	Estrutura das tabelas

@author 	Ana Carolina Tome Klock
@since 		30/05/2013
@version 	P12
/*/
//--------------------------------------------------------------------
Static Function DPRCompPCP()
	Local nI
	Local aTabelas := TabelasDPR()

	For nI := 1 to len(aTabelas)
		If FwAliasInDic(aTabelas[nI,1])
			aTabelas[nI,3] := FwModeAccess(aTabelas[nI,1],3)
			aTabelas[nI,4] := FwModeAccess(aTabelas[nI,1],2)
			aTabelas[nI,5] := FwModeAccess(aTabelas[nI,1],1)
		Else
			Return {}
		EndIf
	Next nI
Return aTabelas
//-------------------------------------------------------------
//TabCompDPR - Tabelas para fazer a validação de campos do DPR
//-------------------------------------------------------------
Static Function TabCompDPR()
	Local aTabComp :=	{;
		"DG1","DG3","DG9","DG0","DG3",;
		"SD4","SG1","SCK","SC6","SB1","SG2","AF8","AFC";
	}
	//Campos das Tabelas Manufatura(Usado pelo SFC também)
	Local aTabelasM := TabCompMAN()
	Local nI
	//Se a versão for maior que 11 ou versão 11 release maior ou igual a 9
		aAdd(aTabComp, "DGC")	 //-- Pendência Desenvolvimento
	//Merge nas listas
	For nI := 1 To Len(aTabelasM)
		aAdd(aTabComp,aTabelasM[nI])
	Next
Return aTabComp
//-------------------------------------------------------------
//FldCompDPR - Campos para fazer a validação do DPR
//-------------------------------------------------------------
Static Function FldCompDPR()
	//1 - Campo Destino, 2 - Campo Origem
	Local aFldComp :=	{;
		{"DG0_DTULRO","B1_UCALSTD"}	,;
		{"DG0_VLPRRO","B1_CUSTD"}	,;
		{"DG0_DTULEN","B1_UCOM"}		,;
		{"DG0_VLULEN","B1_UPRC"}		,;
		{"DG0_CDPJ","AF8_PROJET"}	,;
		{"DG0_CDEDT","AFC_EDT"}		,;
		{"DG0_DSPJ","AF8_DESCRI"}	,;
		{"DG1_NRSQ","D4_TRT"}		,;
		{"DG1_NRSQ","G1_TRT"}		,;
		{"DG1_CDMT","D4_COD"}		,;
		{"DG1_CDMT","G1_COMP"}		,;
		{"DG1_CDMTDV","G1_COMP"}		,;
		{"DG1_DTBG","G1_INI"}		,;
		{"DG1_DTBG","G1_INI"}		,;
		{"DG1_TPVV","G1_FIXVAR"}		,;
		{"DG1_VLPNLS","G1_PERDA"}	,;
		{"DG3_CDACDE","B1_COD"}		,;
		{"DG3_DSACDE","B1_DESC"}		,;
		{"DG3_CDUN","B1_UM"}			,;
		{"DG3_CDGE","B1_GRUPO"}		,;
		{"DG3_CDFA","B1_TIPO"}		,;
		{"DG3_CDUNDE","B1_UM"}		,;
		{"DG3_CDUN2","B1_SEGUM"}		,;
		{"DG3_VLPNUN","B1_CONV"}		,;
		{"DG3_TPPNUN","B1_TIPCONV"}	,;
		{"DG3_DTULEN","B1_UCOM"}		,;
		{"DG3_DTULRO","B1_UCALSTD"}	,;
		{"DG3_CDDPPA","B1_LOCPAD"}	,;
		{"DG9_DSAT","G2_DESCRI"}		,;
		{"DG9_CDMQ","G2_RECURSO"}	,;
		{"DG9_NRUNAC","G2_LOTEPAD"}	,;
		{"DG9_QTTESU","G2_SETUP"}	,;
		{"DG9_QTTEMQ","G2_TEMPAD"}	,;
		{"DG9_QTRC","G2_MAOOBRA"}	,;
		{"DG9_TPTEAT","G2_TPOPER"}	,;
		{"DG9_TPALFE","G2_TPALOCF"}	,;
		{"DG9_CDFE","G2_FERRAM"}		,;
		{"DG9_TPTEOV","G2_TPSOBRE"}	,;
		{"DG9_QTTEOV","G2_TEMPSOB"}	,;
		{"DG9_QTTEPP","G2_TEMPEND"}	;
	}
	/*{"DG1_QTMT","G1_QUANT"},;*/
	//Campos Manufatura(Usado pelo SFC também)
	Local aCamposM := FldCompMAN()
	Local nI
	//Se a versão for maior que 11 ou versão 11 release maior ou igual a 9
		aAdd(aFldComp, {"DG0_QTACEA","B1_QB"})
		aAdd(aFldComp, {"DGC_NRBU","CK_NUM"})
		aAdd(aFldComp, {"DGC_NRSQBU","CK_ITEM"})
		aAdd(aFldComp, {"DGC_CDACBU","CK_PRODUTO"})
		aAdd(aFldComp, {"DGC_NRPD","C6_NUM"})
		aAdd(aFldComp, {"DGC_NRSQPD","C6_ITEM"})
		aAdd(aFldComp, {"DGC_CDACPD","C6_PRODUTO"})
	//Merge nas listas
	For nI := 1 To Len(aCamposM)
		aAdd(aFldComp,aCamposM[nI])
	Next	
Return aFldComp
//-------------------------------------------------------------
//ValidCampos - Valida os campos 
//-------------------------------------------------------------
Static Function ValidCampos( cEmp, cFil, lInconf, nHandle )	
	Local aTabComp 	:= TabCompDPR() //Tabelas para fazer a validação de campos
	Local aFldComp 	:= FldCompDPR() //Campos para fazer a validação
	Local aFldStruct	:= {}
	//Indica o numero de espaços para deixar o arquivo organizado(parecido com uma tabela)
	Local nSpace		:= 0
	Local nI
	Local nJ
	Local nK

	//Destino
	Local cTipoDes
	Local nTamIntDes
	Local nTamDecDes
	//Origem
	Local cTipoOri
	Local nTamIntOri
	Local nTamDecOri
	//Indica se o retorno será verdadeiro
	Local lRet 	:= .T.

	//Indica quanto será o espaço da maior string 
	If Len(STR0031) > nSpace
		nSpace := Len(STR0031)
	EndIf
	If Len(STR0032) > nSpace
		nSpace := Len(STR0032)
	EndIf
	If Len(STR0033) > nSpace
		nSpace := Len(STR0033)
	EndIf

	//Atribui todos os structs
	For nI := 1 To Len(aTabComp)
		dbSelectArea(aTabComp[nI])
		aAdd(aFldStruct,dbStruct())
	Next
	
	//Verifica todos os campos
	For nI := 1 To Len(aFldComp)
		cTipoDes	:= ""
		cTipoOri	:= ""
		For nJ := 1 To Len(aFldStruct)
			//Se o prefixo do primeiro campo da  tabela for igual a um dos campos a serem validados indica que é a tabela correta
			If SubStr(aFldStruct[nJ][1][1],1,3) == SubStr(aFldComp[nI][1],1,3) .OR. SubStr(aFldStruct[nJ][1][1],1,3) == SubStr(aFldComp[nI][2],1,3)
				For nK := 1 To Len(aFldStruct[nJ])
					//Atribui as informações do campo destino
					If aFldStruct[nJ][nK][1] == aFldComp[nI][1]
						cTipoDes	:= aFldStruct[nJ][nK][2]
						nTamIntDes	:= aFldStruct[nJ][nK][3]
						nTamDecDes	:= aFldStruct[nJ][nK][4]
					EndIf
					//Atribui as informações do campo origem
					If aFldStruct[nJ][nK][1] == aFldComp[nI][2]
						cTipoOri	:= aFldStruct[nJ][nK][2]
						nTamIntOri	:= aFldStruct[nJ][nK][3]
						nTamDecOri	:= aFldStruct[nJ][nK][4]
					EndIf
				Next			
			EndIf
		Next
		//Verifica se encontrou o campo Destino
		If AllTrim(cTipoDes) == ""
			FWrite(nHandle, STR0023 + aFldComp[nI][1] + STR0024 + '"' + cEmp + '"' + STR0019 + '"' + cFil + '"' + STR0025 + PULALINHA + PULALINHA)
			lRet		:= .F.
			lInconf	:= .T.
		EndIf
		//Verifica se encontrou o campo Origem
		If AllTrim(cTipoOri) == ""
			FWrite(nHandle, STR0023 + aFldComp[nI][2] + STR0024 + '"' + cEmp + '"' + STR0019 + '"' + cFil + '"' + STR0025 + PULALINHA + PULALINHA)
			lRet		:= .F.
			lInconf	:= .T.
		EndIf
		If AllTrim(cTipoOri) != AllTrim(cTipoDes) .OR. nTamIntOri != nTamIntDes .OR. nTamDecOri != nTamDecDes
			FWrite(nHandle, STR0027 + cEmp + STR0019 + cFil + STR0028 + AllTrim(aFldComp[nI][2])  + STR0029 + AllTrim(aFldComp[nI][1]) + STR0030 + PULALINHA)
			FWrite(nHandle, STR0031 + Space(nSpace - Len(STR0031) ) + ": " + AllTrim(cTipoOri) + " -> " + AllTrim(cTipoDes))
			If AllTrim(cTipoOri) != AllTrim(cTipoDes)
				FWrite(nHandle, STR0026 ) //*** I M P E D I T I V O ***
				lRet := .F.
			EndIf
			FWrite(nHandle, PULALINHA)
			FWrite(nHandle, STR0032 + Space(nSpace - Len(STR0032) ) + ": " + AllTrim(Str(nTamIntOri)) + " -> " + AllTrim(Str(nTamIntDes)))
			If nTamIntOri > nTamIntDes
				FWrite(nHandle, STR0026) //*** I M P E D I T I V O ***
				lRet := .F.
			EndIf
			FWrite(nHandle, PULALINHA)
			FWrite(nHandle, STR0033 + Space(nSpace - Len(STR0033) ) + ": " + AllTrim(Str(nTamDecOri)) + " -> " + AllTrim(Str(nTamDecDes)))
			If nTamDecOri > nTamDecDes
				FWrite(nHandle, STR0026) //*** I M P E D I T I V O ***
				lRet := .F.
			EndIf
			FWrite(nHandle, PULALINHA + PULALINHA)
			lInconf := .T.
		EndIf
	Next
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} DPREXCLUSI()
Converte as tabelas do DPR para Exclusivo durante a integração Protheus

@author Ana Carolina Tome Klock
@since 24/05/2012
@version 1.0
/*/
//--------------------------------------------------------------------
Function DPREXCLUSI( lBlind, cEmp, cFil )
	Local nI			:= 0
	Local cConvert		:= STR0007 + CRLF // Alterações feitas:
	Local cValidTab	:= ""
	Local lRet			:= .T.
	Local nHandle
	Local aTabelas
	//Array com informações sobre o retorno
	Local aRet
	//Indica se houve inconformidades na validação dos campos
	Local lInconf		:= .F.
	//Indica se houve inconformidade na estrutura dos campos
	Default lBlind		:= .F.
	Default cEmp		:= ""
	Default cFil		:= ""
	//Indica se falta alguma tabela do módulo DPR no dicionário. Será preenchida pela função ValSX2Tabs
	Private lErroTab	:= .F.
	Default lAutoMacao  := .F.
	
	aTabelas := DPRCompPCP()
	//Cria um arquivo de log de erros para normalização de tabelas
	nHandle := FCreate("\cargadpr-emp" + cEmp + ".log")
	
	//Verifica se faktou alguma tabela do módulo DPR
	If lErroTab
		lRet := .F.
	//Verifica se houve algum erro impeditivo na validação dos campos das tabelas
	ElseIf !ValidCampos(cEmp, cFil, @lInconf, nHandle)
		cValidTab := STR0018 + '"' + cEmp + '"' + STR0020 + "(cargadpr-emp" + cEmp + ".log)" + STR0034 + PULALINHA //**Foi encontrado um problema impeditivo na estrutura nos campos, da empresa "x" e filial "x", e a carga não pode ser efetuada. Foi gerado um arquivo de log(CARGADPR-Empx.log) na pasta raiz do Protheus com as diferenças.
		
		IF !lAutoMacao
			Define MsDialog oDlg Title STR0005 From 3, 0 to 340, 417 Pixel
			@ 5, 5 Get oMemo Var cValidTab Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel
			Activate MsDialog oDlg Center
		ENDIF

		lRet := .F.
	EndIf
	//Se houveram inconformidades
	If lInconf .AND. AllTrim(cValidTab) == ""
		cValidTab := STR0021 + '"' + cEmp + '"' + STR0022 + "(cargadpr-emp" + cEmp +  ".log)" + STR0035 //Foram encontrado diferenças entre a estrutura nos campos, da empresa "x" e filial "x", da carga e foi gerado um arquivo de log(CARGADPR-Empx.log) na pasta raiz do Protheus, porém os mesmos não impactaram na carga.
		
		IF !lAutoMacao
			Define MsDialog oDlg Title STR0005 From 3, 0 to 340, 417 Pixel
			@ 5, 5 Get oMemo Var cValidTab Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel
			Activate MsDialog oDlg Center
		ENDIF
	EndIf

	For nI := 1 to len(aTabelas)
    	If FwAliasInDic(aTabelas[nI,2])
    		If FwModeAccess(aTabelas[nI,2],3) != aTabelas[nI,3] .Or. ;
			   FwModeAccess(aTabelas[nI,2],2) != aTabelas[nI,4] .Or. ;
			   FwModeAccess(aTabelas[nI,2],1) != aTabelas[nI,5]
			   
				lRet := .F.
				
				cConvert += 'Erro: Tabela ' + aTabelas[nI,2] + ' e tabela ' + aTabelas[nI,1] + ;
								  ' possuem compartilhamento diferente. ' + aTabelas[nI,1] + ': ' + ;
								  aTabelas[nI,3] + aTabelas[nI,4] + aTabelas[nI,5] + '. ' + aTabelas[nI,2] +;
								  ': ' + FwModeAccess(aTabelas[nI,2],3) + ;
								   FwModeAccess(aTabelas[nI,2],2) + ;
								   FwModeAccess(aTabelas[nI,2],1) + PULALINHA
			EndIf
		EndIf
	Next nI
		
	FWrite(nHandle,PULALINHA + cConvert)
	
	//Fecha o arquivo criado
	FClose(nHandle)
	
	//Preenche array com retorno da função
	If lRet
		aRet := {.T.,cConvert}
	Else
		aRet := {.F.,cConvert}
	EndIf
Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} DPRXMREAD()
Faz a leitura de arquivo com mais que 65535 bytes

@param 	cFile		Arquivo a ser utilizado
@return	cRet		Conteudo do Arquivo

@author Bruno Candido Volpato da Cunha
@since 13/03/2012
@version 1.0
/*/
//--------------------------------------------------------------------
Function DPRXMREAD( cFile, nBlockSize )
Local cBuffer     := ''
Local cCRLF       := Chr( 13 ) + Chr( 10 )
Local cRet        := ''
Local nBack       := 0
Local nHandleRead := 0
Local nLenght     := 0
Local nPointer    := 0
Local nPosCRLF    := 0
Local nTotal      := 0

Default nBlockSize := 1024

nHandleRead := FOpen( cFile )

//  Abertura do arquivo
If nHandleRead < 0
     Return cRet
EndIf

//  Tamanho maximo do arquivo
nLenght := FSeek( nHandleRead, 0, 2 )
nTotal  := nLenght

If nTotal > 1048575
     //ConOut( STR0006 + cFile ) // arquivo nao pode ser maior que 1048575 bytes
     Return cRet
Endif

//  Retorna o ponteiro a posicao inicial
FSeek( nHandleRead, 0 )

nPointer := 0

If nLenght > nBlockSize
     nLenght := nBlockSize
EndIf

While nPointer < nTotal
     //  Faz a leitura em blocos de nBlockSize bytes
     cBuffer := FReadStr( nHandleRead, nLenght )

     //  Se nao conseguiu ler nada, sai do loop
     If Empty( Len( cBuffer ) )
          Exit
     EndIf

     //  Verifica a posicao do ultimo CRLF para ajustar o tamanho da linha
     If cCRLF $ cBuffer
          nPosCRLF := AT( cCRLF, cBuffer )
          nBack    := Len( cBuffer ) - nPosCRLF
          cBuffer  := Left( cBuffer, nPosCRLF )

          //  Retrocede a posicao do ponteiro de leitura
          FSeek( nHandleRead, -nBack, 1 )
     EndIf

     //  Atualiza a variavel de ponteiro
     nPointer := FSeek( nHandleRead, 0, 1 )

     //  Monta Retorno
     cRet     += cBuffer
End

FClose( nHandleRead )

Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} DPRXINTREE
Realiza o preenchimento dos vetores das tabelas para montagem da árvore

@param 	oBusinessContent 		Objeto recebido via EAI2

@author Ana Carolina Tomé Klock
@since 12/12/2012
@version P12
/*/
//--------------------------------------------------------------------
Function DPRXINTREE( oBusinessContent )
Local aProducts	:= {}
Local nI, nJ
Default lAutoMacao := .F.

IF !lAutoMacao
	// Tabela DG3 - Produto Desenvolvido
	If XmlChildEx(oBusinessContent, "_LISTOFDEVELOPEDITENS") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfDevelopedItens) > 0
		aProducts := oBusinessContent:_ListOfDevelopedItens:_DevelopedItem

		If ValType( aProducts ) == 'O'
			AddItem( aProducts )
		Else
			For nI := 1 to Len( aProducts )
				AddItem( aProducts[nI] )
			Next
		EndIf
	EndIf

	// Tabela DG0 - Versão Produto
	If XmlChildEx(oBusinessContent, "_LISTOFITEMVERSIONS") != NIL .And. XmlChildCount(oBusinessContent:_ListOfItemVersions) > 0
		aProducts := oBusinessContent:_ListOfItemVersions:_ItemVersion
		If ValType( aProducts ) == 'O'
			aProducts := { aProducts }
		EndIf

		For nI := 1 To Len( aProducts )
			AddVersion( aProducts[nI] )

			// Tabela DGD - Rede Pert
			If XmlChildEx(aProducts[nI], "_LISTOFPERT") != NIL .AND. XmlChildCount(aProducts[nI]:_ListOfPert) > 0
				aPert := aProducts[nI]:_ListOfPert:_Pert
				If ValType( aPert ) == 'O'
					aPert := { aPert }
				EndIf

				For nJ := 1 To Len( aPert )
					oPert := aPert[nJ]
					aAdd( aDGD, { nI   													, ;
									UPPER(ALLTRIM(aProducts[nI]:_Code:TEXT))				, ;
									If (nOrigem==3, aProducts[nI]:_ReferenceCode:TEXT, ''), ;
									oPert:_SequenceNumber:TEXT							, ;
									oPert:_PreviousActivityID:TEXT						, ;
									oPert:_PreviousActivityCode:TEXT					, ;
									oPert:_NextActivityID:TEXT							, ;
									oPert:_NextActivityCode:TEXT						, ;
									oPert:_PercentageOverlapValue:TEXT					, ;
									oPert:_TransportTimeQuantity:TEXT					, ;
									oPert:_TimeType:TEXT									} )
				Next
			EndIf
		Next
	EndIf
ENDIF

For nI := 1 to len( aDG0 )
	nK := 0
	For nJ := 1 to len( aDG1 )
		If aDG0[nI][1] == aDG1[nJ][5]
			nK++
			If nK > 1
				AddVersion( aDG0[nI][len(aDG0[nI])-4] )
			EndIf
		EndIf
	Next
	aDG0[nI][len(aDG0[nI])-4] := ''
Next

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} DPRXCOMP
Verifica o compartilhamento das tabelas do DPR. Compara a DG0 com as
tabelas de faturamento ou ordem de produção. Caso sejam diferentes, 
é preciso analisar os registros sem a filial.

@param  nTipo   Tipo de verificação: 1=Faturamento;2=Ordem Produção

@return lRet	Caso o DPR seja compartilhado e a movimentação exclusiva
            	retorna true

@author Samantha Preima
@since 04/02/2015
@version P11
/*/
//--------------------------------------------------------------------
Function DPRXCOMP(nTipo)
Local lRet  := .F.
Local cComp := ''

// Verificar tabelas faturamento
if nTipo == 1
	cComp := FwModeAccess("DGC",3)+FwModeAccess("DGC",2)+FwModeAccess("DGC",1)
ElseIf nTipo == 2 // Verificar tabelas ordem de produção
	cComp := FwModeAccess("DGH",3)+FwModeAccess("DGH",2)+FwModeAccess("DGH",1) 
Endif

IF cComp != FwModeAccess("DG0",3)+FwModeAccess("DG0",2)+FwModeAccess("DG0",1)
	lRet := .T.
Endif

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} AddItem
Adiciona um produto desenvolvido no array aDG3

@param 	oItem 		Objeto do produto desenvolvido recebido via EAI2

@author Ana Carolina Tomé Klock
@since 12/12/2012
@version P12
/*/
//--------------------------------------------------------------------
Static Function AddItem( oItem )

aAdd( aDG3, { oItem:_Code:TEXT  						, ;
				oItem:_Description:TEXT 					, ;
				oItem:_UnitOfMeasureCode:TEXT 			, ;
				oItem:_Code:TEXT 							, ;
				/* Item Destino */						, ;
				/* Código Unidade Medida Destino */	, ;
				/* Fator Conversão Unidade Medida*/	, ;
				oItem:_StockGroupCode:TEXT 				, ;
				oItem:_FamilyCode:TEXT 					, ;
				oItem:_CommercialFamilyCode:TEXT 		, ;
				oItem:_BranchID:TEXT 					, ;
				oItem:_StandardWarehouseCode:TEXT 		, ;
				oItem:_BusinessUnitCode:TEXT 			, ;
				/* Item Protótipo */						, ;
				oItem:_StatusType:TEXT 					, ;
				oItem:_LastEntryPriceDate:TEXT 			, ;
				oItem:_LastEntryPriceValue:TEXT 		, ;
				oItem:_LastReplacementPriceDate:TEXT 	, ;
				oItem:_LastReplacementPriceValue:TEXT 	, ;
				oItem:_PercentageScrapValue:TEXT		, ;
				oItem:_Narrative:TEXT					, ;
				oItem:_ListOfAttributes, .F.			} )

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} AddItem
Adiciona uma versão de produto desenvolvido no array aDG0 e desce nível

@param 	oVersion 		Objeto do produto desenvolvido recebido via EAI2

@author Ana Carolina Tomé Klock
@since 12/12/2012
@version P12
/*/
//--------------------------------------------------------------------
Static Function AddVersion( oVersion )
Local aMaterial	:= {}
Local aAltMater 	:= {}
Local aActivity	:= {}
Local aAltActiv	:= {}
Local nI, nJ, nK

aAdd( aDG0, { UPPER(ALLTRIM(oVersion:_Code:TEXT))				, ;
				If (nOrigem==3, oVersion:_ReferenceCode:TEXT, ''), ;
				oVersion:_Description:TEXT							, ;
				Date()													, ;
				Time()													, ;
				len(aDG0)+1											, ;
				oVersion:_ComponentListCode:TEXT					, ;
				oVersion:_RoutingCode:TEXT							, ;
				oVersion:_ReferenceCode:TEXT						, ;
				/* Data Preço Base */								, ;
				/* Valor Preço Base */								, ;
				/* Data Preço Fiscal	*/								, ;
				/* Valor Preço Fiscal */								, ;
				/* Data Última Reposição */							, ;
				/* Valor Última Reposição */ 						, ;
				/* Data Última Entrada */							, ;
				/* Valor Última Entrada */							, ;
				/* Fator Refugo */									, ;
				/* Valor Custo Fabricação */						, ;
				/* Código Projeto */									, ;
				/* Estrutura Decomposição Trabalho */				, ;
				/* Descrição Projeto */								, ;
				/* Valor Projeto */									, ;
				/* Valor Custos Diversos */							, ;
				/* Valor Retorno Esperado */						, ;
				/* Valor Preço-Teto */								, ;
				/* Valor Investimento */								, ;
				/* Fórmula Projeto */								, ;
				/* Fórmula Custos Diversos */						, ;
				/* Fórmula Investimento */							, ;
				RetCodUsr(),	'1', oVersion							, ;
				.F., DPRXCOUNT( 5, 0 ), 'FOLDER13'					, ;
				UPPER(AllTrim(oVersion:_Code:TEXT) + ' - ' + oVersion:_Description:TEXT + If(nOrigem==3, STR0008 + AllTRim(oVersion:_ReferenceCode:TEXT), '')) } )	 // ' - CF: '

// Tabela DG1 - Estrutura
If XmlChildEx( oVersion, "_LISTOFMATERIALS") != NIL .And. XmlChildCount(oVersion:_ListOfMaterials) > 0
	aMaterial := oVersion:_ListOfMaterials:_Material
	If ValType( aMaterial ) == 'O'
		aMaterial := { aMaterial }
	EndIf

	For nI := 1 To Len( aMaterial )
	   	AddMaterial( len(aDG0), aMaterial[nI] )

		// Tabela DG4 - Estrutura Alternativa
		If XmlChildEx(aMaterial[nI], "_LISTOFALTERNATIVEMATERIALS") != NIL .AND. XmlChildCount(aMaterial[nI]:_ListOfAlternativeMaterials) > 0
			aAltMater := aMaterial[nI]:_ListOfAlternativeMaterials:_AlternativeMaterial
			If ValType( aAltMater ) == 'O'
				AddAltMat( len(aDG0), nI, aAltMater )
			Else
				For nJ := 1 To Len( aAltMater )
					AddAltMat( len(aDG0), nI, aAltMater[nJ] )
				Next
			EndIf
		EndIf
	Next
EndIf

// Tabela DG9 - Operação
If XmlChildEx(oVersion, "_LISTOFACTIVITIES") != NIL .AND. XmlChildCount(oVersion:_ListOfActivities) > 0
	aActivity := oVersion:_ListOfActivities:_Activity
	If ValType( aActivity ) == 'O'
		aActivity := { aActivity }
	EndIf

	For nI := 1 To Len( aActivity )
		AddActivity( len(aDG0), aActivity[nI] )

		// Tabela DG2 - Ferramenta
		If XmlChildEx(aActivity[nI], "_LISTOFACTIVITYTOOLS") != NIL .AND. XmlChildCount(aActivity[nI]:_ListOfActivityTools) > 0
		aTools := aActivity[nI]:_ListOfActivityTools:_ActivityTool
			If ValType( aTools ) == 'O'
				AddTool( len(aDG0), nI, 'DG9', aTools )
			Else
				For nJ:= 1 To Len( aTools )
				  	AddTool( len(aDG0), nI, 'DG9', aTools[nJ] )
				Next
			EndIf
		EndIf

		// Tabela DG8 - Consumiveis
		If XmlChildEx(aActivity[nI], "_LISTOFACTIVITYITENS") != NIL .AND. XmlChildCount(aActivity[nI]:_ListOfActivityItens) > 0
			aItens := aActivity[nI]:_ListOfActivityItens:_ActivityItem
			If ValType( aItens ) == 'O'
				AddActItem( len(aDG0), nI, 'DG9', aItens )
			Else
				For nJ:= 1 To Len( aItens )
				 	AddActItem( len(aDG0), nI, 'DG9', aItens[nJ] )
				Next
			EndIf
		EndIf

		// Tabela DG7 - Operação Alternativa
		If XmlChildEx(aActivity[nI], "_LISTOFALTERNATIVEACTIVITIES") != NIL .AND. XmlChildCount(aActivity[nI]:_ListOfAlternativeActivities) > 0
			aAltActiv := aActivity[nI]:_ListOfAlternativeActivities:_AlternativeActivity
			If ValType( aAltActiv ) == 'O'
				aAltActiv := { aAltActiv }
			EndIf

			For nJ:= 1 To Len( aAltActiv )
			  	AddAltAct( len(aDG0), nI, aAltActiv[nJ] )

				// Tabela DG2 - Ferramenta
				If XmlChildEx(aAltActiv[nJ], "_LISTOFACTIVITYTOOLS") != NIL .AND. XmlChildCount(aAltActiv[nJ]:_ListOfActivityTools) > 0
					aTools := aAltActiv[nJ]:_ListOfActivityTools:_ActivityTool
					If ValType( aTools ) == 'O'
						AddTool( len(aDG0), nI, 'DG7', aTools )
					Else
						For nK:= 1 To Len( aTools )
						  	AddTool( len(aDG0), nI, 'DG7', aTools[nK] )
					   	Next
				   	EndIf
				EndIf

				// Tabela DG8 - Consumiveis
				If XmlChildEx(aAltActiv[nJ], "_LISTOFACTIVITYITENS") != NIL .AND. XmlChildCount(aAltActiv[nJ]:_ListOfActivityItens) > 0
					aItens := aAltActiv[nJ]:_ListOfActivityItens:_ActivityItem
					If ValType( aItens ) == 'O'
						AddActItem( len(aDG0), nI, 'DG7', aItens )
					Else
						For nK:= 1 To Len( aItens )
						  	AddActItem( len(aDG0), nI, 'DG7', aItens[nK] )
						Next
					EndIf
				EndIf
			Next
		EndIf
	Next
EndIf

Return Nil
//-------------------------------------------------------------------
Static Function AddMaterial( nVersion, oMaterial )

aAdd( aDG1, { nVersion												, ;
				aDG0[ len(aDG0) ][1]									, ;
				aDG0[ len(aDG0) ][2] 								, ;
				/* Sequencia Componente */							, ;
				UPPER(ALLTRIM(oMaterial:_MaterialCode:TEXT)) 		, ;
				''	/* Componente Desenvolvido */					, ;
				If (nOrigem==3,oMaterial:_ReferenceCode:TEXT, ''), ;
				oMaterial:_StartDate:TEXT							, ;
				oMaterial:_EndDate:TEXT								, ;
				oMaterial:_IsVirtual:TEXT							, ;
				oMaterial:_StartSeriesNumber:TEXT					, ;
				oMaterial:_EndSeriesNumber:TEXT						, ;
				oMaterial:_ItemQuantity:TEXT						, ;
				oMaterial:_MaterialQuantity:TEXT					, ;
				/* Tipo Quantidade */								, ;
				oMaterial:_UsedQuantity:TEXT						, ;
				oMaterial:_NetQuantity:TEXT							, ;
				oMaterial:_ProportionValue:TEXT						, ;
				oMaterial:_ScrapType:TEXT							, ;
				oMaterial:_ReferenceCode:TEXT						, ;
				oMaterial:_PercentageLossValue:TEXT				, ;
				oMaterial:_Narrative:TEXT							, ;
				.F., aDG0[ len(aDG0) ][ len(aDG0[nVersion])-2 ]	, ;
				/* cCargo */ 											, ;
				DPRATYPE( UPPER(ALLTRIM(oMaterial:_MaterialCode:TEXT)) ), ;
				UPPER(STR0009 + AllTrim(oMaterial:_MaterialCode:TEXT) + ' - ' + AllTrim(Posicione( 'CZ3', 1, xFilial('CZ3')+oMaterial:_MaterialCode:TEXT, 'CZ3_DSAC' )) + If ((!Empty(oMaterial:_ComponentListCode:TEXT)), STR0011 + AllTrim(oMaterial:_ComponentListCode:TEXT), '') + ; // 'Componente - ' ### ' - Lista de Componentes: '
				If(nOrigem==3 .And. !Empty(oMaterial:_ReferenceCode:TEXT), STR0008 + AllTRim(oMaterial:_ReferenceCode:TEXT), '') + STR0010 + cValToChar(oMaterial:_MaterialQuantity:TEXT) + ' ' + UPPER( AllTrim(Posicione( 'CZ3', 1, xFilial('CZ3')+oMaterial:_MaterialCode:TEXT, 'CZ3_CDUN' )))) } ) // ' - CF: ' ### ' - Qtd: '

Return Nil

//-------------------------------------------------------------------
Static Function AddAltMat( nVersion, nMaterial, oAltMat )

aAdd( aDG4, { nVersion, nMaterial									, ;
				aDG0[ len(aDG0) ][1]									, ;
				aDG0[ len(aDG0) ][2] 								, ;
				aDG1[ len(aDG1) ][5]									, ;
				/* Sequência Componente	*/							, ;
			  	oAltMat:_AlternativeMaterialCode:TEXT				, ;
			 	oAltMat:_ItemQuantity:TEXT							, ;
			   	oAltMat:_MaterialQuantity:TEXT						, ;
			   	oAltMat:_UsedQuantity:TEXT							, ;
			   	oAltMat:_PercentageLossValue:TEXT					, ;
			   	oAltMat:_Narrative:TEXT								, ;
			   	.F., aDG1[ len(aDG1) ][ len(aDG1[nMaterial])-2 ]	, ;
				/* cCargo */, 'DESTINOS'								, ;
				UPPER(STR0012 + AllTrim(oAltMat:_AlternativeMaterialCode:TEXT) + ' - ' + AllTrim(Posicione( 'CZ3', 1, xFilial('CZ3')+oAltMat:_AlternativeMaterialCode:TEXT, 'CZ3_DSAC' )) + STR0010 + cValToChar(oAltMat:_MaterialQuantity:TEXT) + ' ' + UPPER( AllTrim(Posicione( 'CZ3', 1, xFilial('CZ3')+oAltMat:_AlternativeMaterialCode:TEXT, 'CZ3_CDUN' )))) } ) //  'Alternativo - ' ### ' - Qtd: '

Return Nil

//-------------------------------------------------------------------
Static Function AddActivity( nVersion, oActivity )

aAdd( aDG9, { nVersion												, ;
				aDG0[ len(aDG0) ][1]									, ;
				aDG0[ len(aDG0) ][2] 								, ;
				oActivity:_ActivityID:TEXT							, ;
				oActivity:_ActivityCode:TEXT						, ;
				oActivity:_ActivityDescription:TEXT				, ;
				oActivity:_ActivityType:TEXT						, ;
				oActivity:_ProportionValue:TEXT						, ;
				oActivity:_StartDate:TEXT							, ;
				oActivity:_EndDate:TEXT								, ;
				oActivity:_WorkCenterCode:TEXT						, ;
				oActivity:_RoutingCode:TEXT							, ;
				oActivity:_IsActivityControl:TEXT					, ;
				oActivity:_ActivityControlCode:TEXT				, ;
				oActivity:_LaborCode:TEXT							, ;
				oActivity:_UnitQuantity:TEXT						, ;
				oActivity:_TimeType:TEXT								, ;
				oActivity:_SetupTimeQuantity:TEXT					, ;
				oActivity:_MachineTimeQuantity:TEXT				, ;
				oActivity:_ResourceTimeQuantity:TEXT				, ;
				oActivity:_ActivityUnitOfMeasureCode:TEXT			, ;
				oActivity:_IsFirstActivity:TEXT						, ;
				oActivity:_IsLastActivity:TEXT						, ;
				oActivity:_SimultaneousActivityQuantity:TEXT		, ;
				oActivity:_ResourceQuantity:TEXT					, ;
				oActivity:_ReferenceCode:TEXT						, ;
				oActivity:_TimeTreatmentType:TEXT					, ;
				/* Tipo Alocação Ferramenta */ 						, ;
				/* Código Ferramenta */ 								, ;
				/* Tipo Sobreposição */ 								, ;
				/* Tempo Sobreposição */ 							, ;
			  	oActivity:_Tutorial:TEXT								, ;
				' ' /*oActivity:_Narrative:TEXT*/					, ;
			  	.F., aDG0[ len(aDG0) ][ len(aDG0[nVersion])-2 ]	, ;
				/* cCargo */, 'CLOCK01'									, ;
				UPPER(STR0013 + AllTrim(oActivity:_ActivityCode:TEXT) + ' - ' + AllTrim(oActivity:_ActivityDescription:TEXT) + If (!Empty(oActivity:_RoutingCode:TEXT), STR0014 + oActivity:_RoutingCode:TEXT, '') + STR0015 + cValToChar(oActivity:_SetupTimeQuantity:TEXT) + ' ' + X3Combo( 'DG9_TPUNTE', oActivity:_TimeType:TEXT) ) } )   // 'Operação - ' ### ' - Roteiro: ' ### ' - Preparação'

Return Nil

//-------------------------------------------------------------------
Static Function AddTool( nVersion, nActivity, cTable, oTool )

aAdd( aDG2, { nVersion, nActivity, cTable							, ;
				aDG9[ len(aDG9) ][4]									, ;
				If (cTable == 'DG9', '', aDG7[ len(aDG7) ][4]	)	, ;
	  	       oTool:_ToolCode:TEXT									, ;
	  	       oTool:_IsToolUsed:TEXT								, ;
	  	       oTool:_ProportionValue:TEXT							, ;
	  	       oTool:_UnitCycleQuantity:TEXT						, ;
	  	       oTool:_Narrative:TEXT						 , .T. } )
Return Nil

//-------------------------------------------------------------------
Static Function AddActItem( nVersion, nActivity, cTable, oItem )

aAdd( aDG8, { nVersion, nActivity, cTable							, ;
				aDG9[ len(aDG9) ][4]									, ;
				If (cTable == 'DG9', '', aDG7[ len(aDG7) ][4]	)	, ;
				oItem:_ItemCode:TEXT									, ;
				oItem:_ProportionValue:TEXT							, ;
				oItem:_UsedQuantity:TEXT								, ;
				oItem:_ActivityQuantity:TEXT						, ;
				oItem:_Narrative:TEXT, .T.							} )

Return Nil

//-------------------------------------------------------------------
Static Function AddAltAct( nVersion, nActivity, oAltActiv )

aAdd( aDG7, { nVersion, nActivity									, ;
				aDG9[ len(aDG9) ][4]									, ;
				oAltActiv:_AlternativeActivityCode:TEXT			, ;
				oAltActiv:_AlternativeActivityDescription:TEXT	, ;
				oAltActiv:_AlternativeActivityType:TEXT			, ;
				oAltActiv:_WorkCenterCode:TEXT						, ;
				oAltActiv:_LaborCode:TEXT							, ;
				oAltActiv:_UnitQuantity:TEXT						, ;
				oAltActiv:_TimeType:TEXT								, ;
				oAltActiv:_SetupTimeQuantity:TEXT					, ;
				oAltActiv:_MachineTimeQuantity:TEXT				, ;
				oAltActiv:_ResourceTimeQuantity:TEXT				, ;
				oAltActiv:_ActivityUnitOfMeasureCode:TEXT			, ;
				oAltActiv:_SimultaneousActivityQuantity:TEXT		, ;
				oAltActiv:_ResourceQuantity:TEXT					, ;
				oAltActiv:_Tutorial:TEXT								, ;
				oAltActiv:_Narrative:TEXT							, ;
				.F., aDG9[ len(aDG9) ][ len(aDG9[nActivity])-2 ] , ;
				/* cCargo */, 'DESTINOS', ;
				UPPER(STR0016 + oAltActiv:_AlternativeActivityCode:TEXT + ' - ' + AllTrim(oAltActiv:_AlternativeActivityDescription:TEXT) + STR0015 + cValToChar(oAltActiv:_SetupTimeQuantity:TEXT) + ' ' + X3Combo( 'DG7_TPUNTE', oAltActiv:_TimeType:TEXT )) } )  // 'Alternativa - ' ### ' - Preparação: '

Return Nil
