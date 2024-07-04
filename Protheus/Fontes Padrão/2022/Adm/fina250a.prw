#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FINA250A.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE OPER_VISUALIZAR		02

Static __lFatura	:= ""
Static __cProcess	:= ""
STATIC __oQryFatC	:= NIL
STATIC __oQryFatD	:= NIL
STATIC __oQryFatB	:= NIL
STATIC __oQryFatO 	:= NIL
STATIC __oQryVMov	:= NIL
STATIC __nTamDoc 	:= 0 
STATIC __oQryLiqD	:= NIL
STATIC __oQryLqDA	:= NIL
STATIC __oQryLqDB	:= NIL
STATIC __nTotProc	:= 0
STATIC __lJnOri		:= .T.
STATIC _lFinLOTab	:= FindFunction("FinLOTab")

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA250A()
Interface p/ visualização de simulação para liquidação ou faturas a pagar
@author Pequim
@since 06/01/2022
@version P12
/*/
//-------------------------------------------------------------------
Function FINA250A(nPosArotina,nRec, cProcess, lFatura, lJnOri)

	Private aRotina		:= {}
	Private aPos   		:= {  15,  1, 70, 315 }
	Private cCadastro	:= ""

	Default nPosArotina := 0
	Default nRec		:= 0
	Default cProcess	:= ""
	Default lFatura		:= .F. 

	cCadastro	:= If(lFatura, STR0001,STR0002)	//"Fatura"###"Liquidação"
	__lFatura	:= lFatura
	__cProcess	:= cProcess
	__nTamDoc 	:= TamSx3("E5_DOCUMEN")[1]
	__lJnOri	:= lJnOri

	dbSelectArea("FI8")
		
	If nPosArotina > 0
		aRotina := MenuDef()
		dbSelectArea('SE2')
		bBlock := &( "{ || " + aRotina[ nPosArotina,2 ] + " }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Função responsavel pelo menu da rotina de simulação de liquidação a pagar

@author Pequim
@since 06/01/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina	:= {}

	ADD OPTION aRotina Title STR0003 Action 'F250AVerSim()' OPERATION 2 ACCESS 0 	//"Visualizar"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} F250VerSim() 
Rotina que realiza a visualização da simulação de liquidação FINA250A.

@author Pequim
@since 21/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function F250AVerSim()

	Local cPrograma     	:= ""
	Local nOperation 		:= MODEL_OPERATION_UPDATE
	Local aEnableButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Fechar"
	Local lRet				:= .T.
	Local cTitulo 			:= ""
	Local nRet				:= 0

	_nOper			:= OPER_VISUALIZAR
	cTitulo      	:= STR0003	//"Visualizar" 	
	cPrograma    	:= 'FINA250A'
	bCancel      	:=  { |oModel| F250NoAlt(oModel)}
	__lUserButton  	:= .T.
	nRet         	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, aEnableButtons, bCancel , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
	__lUserButton  	:= .F.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F250NoAlt() 
Rotina para inibir a pergunta se deseja salvar ou não a visualização 
da simulação.

@author Pequim
@since 06/01/2022
@version P12
/*/
//-------------------------------------------------------------------
Function F250NoAlt(oModel)
	Local oView := FWViewActive()
	oView:SetModified(.F.)
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Função responsavel pelo modelo de dados da rotina de simulação de liquidação a pagar

@author Pequim
@since 06/01/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel	:= Nil
	Local oStruFI8C	:= F250CpoCAB(1)
	Local oStruFI8O	:= F250CpoORI(1)
	Local oStruFI8D	:= F250CpoDES(1)

	lOpcAuto := Iif(lOpcAuto == Nil, .F. ,lOpcAuto)

	_nOper	:= IIf(Type("_nOper") == "U",0,_nOper)

	oModel := MPFormModel():New("FINA250A", /*PreValidacao*/,  /*PosValidacao*/, /*bCommit*/)
					
	//cabeçalho
	oModel:AddFields("MASTERFI8", /*cOwner*/, oStruFI8C, /*bPreVld*/, /*bPosVld*/, /*bLoad*/)

	oModel:SetDescription((cCadastro + " a Pagar")) // "Liquidação a Pagar" ou "Fatura a Pagar"

	oModel:AddGrid("TITORIFI8", "MASTERFI8", oStruFI8O, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, {|oModel| LoadGrdO(oModel)} /*bLoad*/ )
	oModel:AddGrid("TITGERFI8", "MASTERFI8", oStruFI8D, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, {|oModel| LoadGrdD(oModel)} )

	oModel:GetModel( 'TITORIFI8' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'TITORIFI8' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'TITGERFI8' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'TITGERFI8' ):SetNoDeleteLine( .T. )

	oModel:GetModel("TITORIFI8"):SetMaxLine(500000)
	oModel:GetModel("TITGERFI8"):SetMaxLine(500000)
	
	oModel:SetPrimaryKey({'FI8_FILIAL', "FI8_PRFORI", "FI8_NUMORI", "FI8_PARORI", "FI8_TIPORI","FI8_FILDES","FI8_PRFDES", "FI8_NUMDES", "FI8_PARDES", "FI8_TIPDES"})

	oModel:GetModel("TITORIFI8"):SetUniqueLine( { "FI8_FILIAL", "FI8_PRFORI", "FI8_NUMORI", "FI8_PARORI", "FI8_TIPORI"} )
	oModel:GetModel("TITGERFI8"):SetUniqueLine( { "FI8_FILDES","FI8_PRFDES", "FI8_NUMDES", "FI8_PARDES", "FI8_TIPDES"} )

	oModel:SetActivate( {|oModel| FA250LOAD(oModel) } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Função responsavel pela View da rotina de simulação de liquidação a pagar

@author Pequim
@since 06/01/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	:= FWLoadModel("FINA250A")
	Local oView		:= FWFormView():New()
	Local oStruFI8C	:= F250CpoCAB(2)
	Local oStruFI8O	:= F250CpoORI(2)
	Local oStruFI8D	:= F250CpoDES(2)

	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB", oStruFI8C, "MASTERFI8")
	oView:AddGrid("VIEW_ORI" , oStruFI8O, "TITORIFI8")
	oView:AddGrid("VIEW_DES" , oStruFI8D, "TITGERFI8")

	oView:CreateHorizontalBox("BOXCAB", 20)
	oView:CreateHorizontalBox("BOXORI", 40)
	oView:CreateHorizontalBox("BOXDES", 40)

	oView:SetOwnerView("VIEW_CAB", "BOXCAB")
	oView:SetOwnerView("VIEW_ORI", "BOXORI")
	oView:SetOwnerView("VIEW_DES", "BOXDES")

	oView:EnableTitleView("VIEW_ORI", STR0004 ) // "Títulos Originais"
	oView:EnableTitleView("VIEW_DES", STR0005 ) // "Títulos Gerados"

	oView:SetOnlyView("VIEW_CAB")
	oView:SetOnlyView("VIEW_ORI")
	oView:SetOnlyView("VIEW_DES")
	oView:SetNoInsertLine("VIEW_ORI")
	oView:SetNoDeleteLine("VIEW_ORI")
	oView:SetNoInsertLine("VIEW_DES")
	oView:SetNoDeleteLine("VIEW_DES")

Return oView


//-------------------------------------------------------------------
/* {Protheus.doc} F250CpoCAB

Função criar um campo virtual para montagem da field - CABEÇALHO

@author	Pequim
@since	06/01/2022

@Project P12
@aparam  nTipo, indica se é 1 = model ou 2 = view 
@Return	oStruFI8O Estrutura de campos da tabela FO1		
*/
//-------------------------------------------------------------------
Static Function F250CpoCAB(nTipo) 

	Local oStruFI8C	:= FWFormStruct(nTipo,"FI8")
	Local nTamProc	:= TamSX3("E2_FATURA")[1]
	Local aTamVlr	:= TamSX3("FI8_VALOR")

	Default nTipo := 1 

	If nTipo == 1
		oStruFI8C:AddField(cCadastro			,"","FI8_PROCES","C",nTamProc,0,,,,.F.,,,,.T.)
		oStruFI8C:AddField(STR0006 + cCadastro	,"","FI8_DATA"	,"D",8,0,,,,.F.,,,,.T.)							//"Data da " 
		oStruFI8C:AddField(STR0007 + cCadastro	,"","FI8_VALOR"	,"N",aTamVlr[1],aTamVlr[2],,,,.F.,,,,.T.)		//"Total da " 
		oStruFI8C:AddField(STR0008				,"","FI8_FORDES","C",TamSX3("E2_FORNECE")[1],0,,,,.F.,,,,.T.)	//"Fornecedor"
		oStruFI8C:AddField(STR0009	           	,"","FI8_LOJDES","C",TamSX3("E2_LOJA")[1],0,,,,.F.,,,,.T.)		//"Loja"
		oStruFI8C:AddField(STR0010	           	,"","FI8_NOMDES","C",TamSX3("A2_NOME")[1],0,,,,.F.,,,,.T.)		//"Razão Social"
		oStruFI8C:AddField(STR0011	     		,"","FI8_NATDES","C",TamSX3("ED_CODIGO")[1],0,,,,.F.,,,,.T.)	//"Natureza"
		oStruFI8C:AddField(STR0012   			,"","FI8_DSCDES","C",TamSX3("ED_DESCRIC")[1],0,,,,.F.,,,,.T.)	//"Descrição"				

	Else 
		oStruFI8C:AddField("FI8_PROCES" , "01", cCadastro, cCadastro, {}, "G", "@!")	
		oStruFI8C:AddField("FI8_DATA"   , "02", STR0006 + cCadastro, STR0006 + cCadastro, {}, "G", "")		//"Data da "
		oStruFI8C:AddField("FI8_VALOR"  , "03", STR0007 + cCadastro, STR0007 + cCadastro, {}, "G", PesqPict("SE2", "E2_VALOR"))		//"Total da "
		oStruFI8C:AddField("FI8_FORDES"	, "04", STR0008,"",{},"G","@!"	)
		oStruFI8C:AddField("FI8_LOJDES"	, "05",	STR0009,"",{},"G","@!"	)
		oStruFI8C:AddField("FI8_NOMDES"	, "06",	STR0010,"",{},"G","@!"	)
		oStruFI8C:AddField("FI8_NATDES"	, "07", STR0011,"",{},"G","@!"	)
		oStruFI8C:AddField("FI8_DSCDES"	, "08",	STR0012,"",{},"G","@!"	)

		oStruFI8C:RemoveField("FI8_CHKORI")
	Endif

Return oStruFI8C


//-------------------------------------------------------------------
/* {Protheus.doc} F250CpoORI

Função criar um campo virtual para montagem da grid - GERADORES

@author	Pequim
@since	06/01/2022

@Project P12
@aparam  nTipo, indica se é 1 = model ou 2 = view 
@Return	oStruFI8O Estrutura de campos da tabela FO1		
*/
//-------------------------------------------------------------------
Static Function F250CpoORI(nTipo) 
	Local oStruFI8O	:= FWFormStruct(nTipo,"FI8",{|x| Alltrim(x) != 'FI8_CHKORI'})
	Local aValor	:= TamSX3("E2_VALOR")
	Local nTamVal	:= aValor[1]
	Local nTamDec	:= aValor[2]

	Default nTipo := 1 

	If nTipo == 1
		oStruFI8O:AddField(STR0014 ,"","FI8_PRFORI"	,"C",TamSX3("E2_PREFIXO")[1] ,0,,,,.F.,,,,.F.) //,,.F.)	//"Prefixo"
		oStruFI8O:AddField(STR0015 ,"","FI8_NUMORI"	,"C",TamSX3("E2_NUM")[1]	 ,0,,,,.F.,,,,.F.) //,,.F.)	//"Número"
		oStruFI8O:AddField(STR0016 ,"","FI8_PARORI"	,"C",TamSX3("E2_PARCELA")[1] ,0,,,,.F.,,,,.F.) //,,.F.)	//"Parcela"
		oStruFI8O:AddField(STR0017 ,"","FI8_TIPORI"	,"C",TamSX3("E2_TIPO")[1]	 ,0,,,,.F.,,,,.F.) // ,,.F.)	//"Tipo"
		oStruFI8O:AddField(STR0008 ,"","FI8_FORORI"	,"C",TamSX3("E2_FORNECE")[1] ,0,,,,.F.,,,,.T.)	//"Fornecedor"
		oStruFI8O:AddField(STR0009 ,"","FI8_LOJORI"	,"C",TamSX3("E2_LOJA")[1]	 ,0,,,,.F.,,,,.T.)	//"Loja"
		oStruFI8O:AddField(STR0010 ,"","FI8_NOMORI"	,"C",TamSX3("A2_NOME")[1] 	 ,0,,,,.F.,,,,.T.)	//"Razão Social"
		oStruFI8O:AddField(STR0021 ,"","FI8_EMIORI" ,"D",8						 ,0,,,,.F.,,,,.T.)	//"Emissão"
		oStruFI8O:AddField(STR0018 ,"","FI8_VCTORI" ,"D",8						 ,0,,,,.F.,,,,.T.)	//"Vencimento"
		oStruFI8O:AddField(STR0019 ,"","FI8_VCRORI" ,"D",8						 ,0,,,,.F.,,,,.T.)	//"Vencto Real"
		oStruFI8O:AddField(STR0020 ,"","FI8_VALORI"	,"N",nTamVal,nTamDec,,,,.F.,,,,.T.)				//"Valor de baixa"
	Else 
		oStruFI8O:AddField("FI8_FILIAL"	, "01", STR0013	,"",{},"C","@!"	)
		oStruFI8O:AddField("FI8_PRFORI"	, "02", STR0014	,"",{},"C","@!"	)
		oStruFI8O:AddField("FI8_NUMORI"	, "03", STR0015	,"",{},"C","@!"	)
		oStruFI8O:AddField("FI8_PARORI"	, "04", STR0016	,"",{},"C","@!"	)
		oStruFI8O:AddField("FI8_TIPORI"	, "05", STR0017	,"",{},"C","@!"	)
		oStruFI8O:AddField("FI8_FORORI"	, "06", STR0008	,"",{},"C","@!"	)
		oStruFI8O:AddField("FI8_LOJORI"	, "07",	STR0009	,"",{},"C","@!"	)
		oStruFI8O:AddField("FI8_NOMORI"	, "08",	STR0010	,"",{},"C","@!"	)		
		oStruFI8O:AddField("FI8_EMIORI"	, "09", STR0021	,"",{},"D","@!"	)
		oStruFI8O:AddField("FI8_VCTORI"	, "10", STR0018	,"",{},"D","@!"	)
		oStruFI8O:AddField("FI8_VCRORI"	, "11",	STR0019	,"",{},"D","@!"	)
		oStruFI8O:AddField("FI8_VALORI"	, "12",	STR0020,"",{},"N",PesqPict("SE2", "E2_VALOR"))
	EndIf

Return oStruFI8O


//-------------------------------------------------------------------
/* {Protheus.doc} F250CpoDES

Função criar um campo virtual para montagem da grid - GERADOS

@author	Pequim
@since	06/01/2022
@Version	V12.1.8
@Project P12
@aparam  nTipo, indica se é 1 = model ou 2 = view 
@Return	oStruFI8O Estrutura de campos da tabela FO1		
*/
//-------------------------------------------------------------------
Static Function F250CpoDES(nTipo) 

	Local oStruFI8D	:= FWFormStruct(nTipo,"FI8", {|x| Alltrim(x) != 'FI8_CHKORI'})
	Local aValor	:= TamSX3("E2_VALOR")
	Local nTamVal	:= aValor[1]
	Local nTamDec	:= aValor[2]

	Default nTipo := 1 

	If nTipo == 1
		oStruFI8D:AddField(STR0013 ,"","FI8_FILDES" ,"C",TamSX3("E2_FILIAL")[1]  ,0,,,,.F.,,,,.T.)		//"Filial"
		oStruFI8D:AddField(STR0014 ,"","FI8_PRFDES" ,"C",TamSX3("E2_PREFIXO")[1] ,0,,,,.F.,,,,.T.)		//"Prefixo"
		oStruFI8D:AddField(STR0015 ,"","FI8_NUMDES" ,"C",TamSX3("E2_NUM")[1]	 ,0,,,,.F.,,,,.T.)		//"Número"
		oStruFI8D:AddField(STR0016 ,"","FI8_PARDES" ,"C",TamSX3("E2_PARCELA")[1] ,0,,,,.F.,,,,.T.)		//"Parcela"
		oStruFI8D:AddField(STR0017 ,"","FI8_TIPDES" ,"C",TamSX3("E2_TIPO")[1]	 ,0,,,,.F.,,,,.T.)		//"Tipo"
		oStruFI8D:AddField(STR0008 ,"","FI8_FORDES" ,"C",TamSX3("E2_FORNECE")[1] ,0,,,,.F.,,,,.T.)		//"Fornecedor"
		oStruFI8D:AddField(STR0009 ,"","FI8_LOJDES" ,"C",TamSX3("E2_LOJA")[1]	 ,0,,,,.F.,,,,.T.)		//"Loja"
		oStruFI8D:AddField(STR0018 ,"","FI8_VCTDES" ,"D",8						 ,0,,,,.F.,,,,.T.)		//"Vencimento"
		oStruFI8D:AddField(STR0019 ,"","FI8_VCRDES" ,"D",8						 ,0,,,,.F.,,,,.T.)		//"Vencto Real"
		oStruFI8D:AddField(STR0022 ,"","FI8_VALOR"	,"N",nTamVal ,nTamDec,,,,.F.,,,,.T.)				//"Valor"
	Else 
		oStruFI8D:AddField("FI8_FILDES"	, "01", STR0013	,"",{},"C","@!"	)
		oStruFI8D:AddField("FI8_PRFDES"	, "02", STR0014	,"",{},"C","@!"	)
		oStruFI8D:AddField("FI8_NUMDES"	, "03", STR0015	,"",{},"C","@!"	)
		oStruFI8D:AddField("FI8_PARDES"	, "04", STR0016	,"",{},"C","@!"	)
		oStruFI8D:AddField("FI8_TIPDES"	, "05", STR0017	,"",{},"C","@!"	)
		oStruFI8D:AddField("FI8_FORDES"	, "06", STR0008	,"",{},"C","@!"	)
		oStruFI8D:AddField("FI8_LOJDES"	, "07",	STR0009	,"",{},"C","@!"	)
		oStruFI8D:AddField("FI8_VCTDES"	, "08", STR0018	,"",{},"D","@!"	)
		oStruFI8D:AddField("FI8_VCRDES"	, "09",	STR0019	,"",{},"D","@!"	)
		oStruFI8D:AddField("FI8_VALOR"	, "10",	STR0022	,"",{},"N",PesqPict("SE2", "E2_VALOR"))

		oStruFI8D:RemoveField("FI8_FORDES")
		oStruFI8D:RemoveField("FI8_LOJDES")
	Endif
Return oStruFI8D

//-------------------------------------------------------------------
/*/{Protheus.doc} FA250LOAD()
Funções para a carga do modelo de consulta de processo de liquidação
ou Fatura a pagar	

@param oModel: Modelo Ativo

@author Pequim
@since 06/01/2022

/*/
//-------------------------------------------------------------------
Function FA250LOAD(oModel)

	Local nRecAnt		AS Numeric
	Local nTotProc		AS Numeric
	Local nValDes		AS Numeric
	Local oStruFI8C		AS Object
	Local oStruFI8O		AS Object
	Local oStruFI8D		AS Object
	Local aArea			AS Array
	Local aDados		AS Array
	Local aData			As Array
	Local cAliasTrb 	AS Character
	Local cAliasTrbA 	AS Character
	Local nCount		As Numeric
	Local nCountA		As Numeric

	Default oModel	:= FWLoadModel("FINA250A")

	nRecAnt		:= 0
	nTotProc	:= 0
	nValDes		:= 0
	nCount		:= 0
	nCountA		:= 0
	oStruFI8C	:= oModel:GetModel('MASTERFI8')
	oStruFI8O	:= oModel:GetModel('TITORIFI8')
	oStruFI8D	:= oModel:GetModel('TITGERFI8')
	aArea	  	:= GetArea()
	aDados		:= {}
	aData		:= {}
	cAliasTrb 	:= ""
	cAliasTrbA	:= ""

	oStruFI8O:SetNoInsertLine( .F. )
	oStruFI8D:SetNoInsertLine( .F. )

	oStruFI8C:LoadValue("FI8_PROCES", __cProcess )
	
	If __lFatura
		cAliasTrb 	:= F250FTDET()
	Else
		cAliasTrb := F250LQTDET()
	Endif
	aDados := F250Dados(1,cAliasTRB)
	oStruFI8C:LoadValue("FI8_DATA"   , SE2->E2_EMISSAO )
	oStruFI8C:LoadValue("FI8_FORDES" , SE2->E2_FORNECE )
	oStruFI8C:LoadValue("FI8_LOJDES" , SE2->E2_LOJA )
	oStruFI8C:LoadValue("FI8_NOMDES" , aDados[1,1])
	oStruFI8C:LoadValue("FI8_NATDES" , aDados[1,2])
	oStruFI8C:LoadValue("FI8_DSCDES" , aDados[1,3])
	oStruFI8C:LoadValue("FI8_VALOR"	, __nTotProc	)

	oStruFI8O:SetNoInsertLine( .T. )
	oStruFI8D:SetNoInsertLine( .T. )

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F250FTDET
Rotina para obtenção dos detalhes da Fatura na consulta

@author Pequim
@since 06/01/2022
/*/
//-------------------------------------------------------------------
STATIC Function F250FTDET()

	Local cQuery 	As Character
	Local cCampos 	As Character
	Local cJoinTit	As Character
	Local cWhere	As Character
	Local cPref		As Character
	Local cNum		As Character
	Local cTipo		As Character
	Local cForn		As Character
	Local cLoja		As Character
	Local cData		As Character
	Local cWhrORI 	As Character
	Local cWhrDES 	As Character
	Local cAliasQry	As Character
	
	cQuery 		:= ""
	cCampos 	:= ""
	cJoinTit 	:= ""
	cWhere 		:= ""
	cPref	 	:= SE2->E2_PREFIXO
	cNum		:= SE2->E2_NUM
	cTipo		:= SE2->E2_TIPO
	cForn	 	:= SE2->E2_FORNECE
	cLoja	 	:= SE2->E2_LOJA
	cData		:= Dtos(SE2->E2_EMIS1)
	cWhrORI		:= ""
	cWhrDES		:= ""
	
	If __oQryFatD == NIL
		// Clausula SELECT -----------------------------------------------------------
		cCampos := "SELECT DISTINCT SE2A.R_E_C_N_O_ RECNO, "
		cCampos	+= " FI8_FILIAL, FI8_PRFORI, FI8_NUMORI, FI8_PARORI, "
		cCampos	+= " FI8_TIPORI, FI8_FORORI, FI8_LOJORI,"
		cCampos	+= " FI8_FILDES, FI8_PRFDES, FI8_NUMDES, FI8_PARDES, "
		cCampos	+= " FI8_TIPDES, FI8_FORDES, FI8_LOJDES, FI8_DATA, FI8_VALOR,  "
		cCampos	+= " SE2A.E2_NATUREZ E2_NATORI, SE2A.E2_EMISSAO E2_EMIORI, SE2A.E2_VENCTO E2_VCTORI, SE2A.E2_VENCREA E2_VCRORI, SE2A.E2_FILORIG E2_FILOORI "

		cCampos += "FROM " + RetSqlName("FI8") + " FI8 "
		// Clausula JOIN Títulos ------------------------------------------------------
		cJoinTit := "INNER JOIN " + RetSqlName("SE2") + " SE2A ON "
		cJoinTit += "FI8.FI8_FILIAL = SE2A.E2_FILIAL "
		cJoinTit += "AND FI8.FI8_PRFORI = SE2A.E2_PREFIXO "
		cJoinTit += "AND FI8.FI8_NUMORI = SE2A.E2_NUM "
		cJoinTit += "AND FI8.FI8_PARORI = SE2A.E2_PARCELA " 
		cJoinTit += "AND (FI8.FI8_TIPORI = SE2A.E2_TIPO " 
		cJoinTit += "AND SE2A.E2_FATPREF = FI8.FI8_PRFDES AND SE2A.E2_FATURA = FI8.FI8_NUMDES " 
		cJoinTit += "AND SE2A.E2_DTFATUR = FI8.FI8_DATA AND SE2A.E2_TIPOFAT = FI8.FI8_TIPDES "
		cJoinTit += "AND SE2A.E2_FATFOR = FI8.FI8_FORDES AND SE2A.E2_FATLOJ = FI8.FI8_LOJDES ) "
		cJoinTit += "AND FI8.FI8_FORORI = SE2A.E2_FORNECE "
		cJoinTit += "AND FI8.FI8_LOJORI = SE2A.E2_LOJA "
		cJoinTit += "AND SE2A.E2_STATUS <> 'D' "
		cJoinTit += "AND SE2A.D_E_L_E_T_ = ' '  "
	
		// Clausula WHERE -------------------------------------------------------------
		cWhrORI := "WHERE "
		cWhrORI +=     "FI8.FI8_FILIAL = ? "
		cWhrORI += "AND SE2A.E2_FATURA = ? "
		cWhrORI += "AND FI8.FI8_PRFORI = ? "
		cWhrORI += "AND FI8.FI8_NUMORI = ? "
		cWhrORI += "AND FI8.FI8_TIPORI = ? "
		cWhrORI += "AND FI8.FI8_FORORI = ? "
		cWhrORI += "AND FI8.FI8_LOJORI = ? "
		cWhrORI += "AND FI8.FI8_DATA   = ? "

		cWhrORI += "AND FI8.D_E_L_E_T_ = ' '"

		// Montagem QUERY ------------------------------------------------------------
		cQuery += cCampos + cJoinTit + cWhrORI

		cQuery 		:= ChangeQuery(cQuery)
		__oQryFatD 	:= FWPreparedStatement():New(cQuery)
	endif

	//Insere parâmetros em todas as Queries separadas por UNION
	__oQryFatD:SetString(1,FWxFilial("FI8"))
	__oQryFatD:SetString(2,__cProcess )
	__oQryFatD:SetString(3,cPref )
	__oQryFatD:SetString(4,cNum	 )
	__oQryFatD:SetString(5,cTipo )
	__oQryFatD:SetString(6,cForn )
	__oQryFatD:SetString(7,cLoja )
	__oQryFatD:SetString(8,cData )
	
    cQuery := __oQryFatD:GetFixQuery()
	cAliasQry := MpSysOpenQuery(cQuery)

Return cAliasQry

//-------------------------------------------------------------------
/*/{Protheus.doc} F250FTDETA
Rotina para obtenção dos detalhes da Fatura na consulta

@author Rodrigo.Oliveira
@since 06/01/2022
/*/
//-------------------------------------------------------------------
STATIC Function F250FTDETA()

	Local cQuery 	As Character
	Local cCampos 	As Character
	Local cJoinTit	As Character
	Local cWhere	As Character
	Local cPref		As Character
	Local cNum		As Character
	Local cTipo		As Character
	Local cForn		As Character
	Local cLoja		As Character
	Local cData		As Character	
	Local cWhrORI 	As Character
	Local cWhrDES 	As Character
	Local cAliasQry1	As Character
	Local cEmpSA2	As Character
	Local cLOSA2	As Character
	Local cLOSE2	As Character
	Local cTamFilA2	As Character
	Local cOrder	As Character
	Local nTamFilA2	As Numeric
	Local aAreaSE2	As Array
	
	cQuery 		:= ""
	cCampos 	:= ""
	cJoinTit 	:= ""
	cWhere 		:= ""
	aAreaSE2	:= SE2->(GetArea())
	If __FI8->RECORI > 0 .And. !Empty(__FI8->NFATORI)
		SE2->(DbGoTo(__FI8->RECORI))
	ElseIf __FI8->RECDES > 0 .And. !Empty(__FI8->NFATDES)
		SE2->(DbGoTo(__FI8->RECDES))
	EndIf
	cPref	 	:= SE2->E2_PREFIXO
	cNum		:= SE2->E2_NUM
	cParc		:= SE2->E2_PARCELA
	cTipo		:= SE2->E2_TIPO
	cForn	 	:= SE2->E2_FORNECE
	cLoja	 	:= SE2->E2_LOJA
	cData		:= Dtos(SE2->E2_EMIS1)
	cWhrORI		:= ""
	cWhrDES		:= ""
	cAliasQry1	:= GetNextAlias()
	cOrder		:= ""
	
	If __oQryFatO == NIL

		cEmpSA2	:= FwModeAccess("SA2", 1)
		cLOSA2	:= cEmpSA2 + FwModeAccess("SA2", 2) + FwModeAccess("SA2", 3)
		cLOSE2	:= FwModeAccess("SE2", 1) + FwModeAccess("SE2", 2) + FwModeAccess("SE2", 3)

		nTamFilA2	:= Len(RTrim(FwxFilial("SA2")))
		cTamFilA2	:= AllTrim(STR(nTamFilA2))
		If _lFinLOTab
			cTamFilA2	:= FinLOTab("SA2")
		EndIf

		// Clausula SELECT -----------------------------------------------------------
		cCampos := "SELECT DISTINCT "
		cCampos	+= " FI8_FILIAL, FI8_PRFORI, FI8_NUMORI, FI8_PARORI, "
		cCampos	+= " FI8_TIPORI, FI8_FORORI, FI8_LOJORI, "
		cCampos	+= " A2_NOME FI8_NOMORI, SE2A.E2_EMISSAO FI8_EMIORI, SE2A.E2_VENCTO FI8_VCTORI,"
		cCampos	+= " SE2A.E2_VENCREA FI8_VCRORI, "
		cCampos	+= " (Select Sum(FI8_VALOR) From " + RetSqlName("FI8") + " FI8TOT "
		cCampos	+= " Where FI8TOT.FI8_FILIAL = FI8_FILIAL AND SE2A.E2_FATURA = ? "
		cCampos	+= " And FI8.FI8_NUMDES = FI8TOT.FI8_NUMDES "
		cCampos	+= " And FI8.FI8_PRFORI = FI8TOT.FI8_PRFORI And FI8.FI8_NUMORI = FI8TOT.FI8_NUMORI "
		cCampos	+= " And FI8.FI8_PARORI = FI8TOT.FI8_PARORI And FI8.FI8_TIPORI = FI8TOT.FI8_TIPORI "
		cCampos	+= " And FI8.FI8_FORORI = FI8TOT.FI8_FORORI And FI8.FI8_LOJORI = FI8TOT.FI8_LOJORI "
		cCampos	+= " And FI8.FI8_DATA = FI8TOT.FI8_DATA AND FI8TOT.D_E_L_E_T_ = ' ' ) FI8_VALORI "

		cCampos += "FROM " + RetSqlName("FI8") + " FI8 "
		// Clausula JOIN Títulos ------------------------------------------------------
		cJoinTit := "INNER JOIN " + RetSqlName("SE2") + " SE2A ON "
		cJoinTit += "FI8.FI8_FILIAL = SE2A.E2_FILIAL "
		cJoinTit += "AND FI8.FI8_PRFORI = SE2A.E2_PREFIXO "
		cJoinTit += "AND FI8.FI8_NUMORI = SE2A.E2_NUM "
		cJoinTit += "AND FI8.FI8_PARORI = SE2A.E2_PARCELA " 
		cJoinTit += "AND (FI8.FI8_TIPORI = SE2A.E2_TIPO " 
		cJoinTit += "AND SE2A.E2_FATPREF = FI8.FI8_PRFDES AND SE2A.E2_FATURA = FI8.FI8_NUMDES " 
		cJoinTit += "AND SE2A.E2_DTFATUR = FI8.FI8_DATA AND SE2A.E2_TIPOFAT = FI8.FI8_TIPDES "
		cJoinTit += "AND SE2A.E2_FATFOR = FI8.FI8_FORDES AND SE2A.E2_FATLOJ = FI8.FI8_LOJDES ) "
		cJoinTit += "AND FI8.FI8_FORORI = SE2A.E2_FORNECE "
		cJoinTit += "AND FI8.FI8_LOJORI = SE2A.E2_LOJA "
		cJoinTit += "AND SE2A.E2_STATUS <> 'D' "
		cJoinTit += "AND SE2A.D_E_L_E_T_ = ' '  "
	
		cJoinTit += "INNER JOIN " + RetSqlName("SA2") + " SA2 ON "
		If cEmpSA2 == 'C'
			cJoinTit	+= " SA2.A2_FILIAL = '" + FwxFilial("SA2") + "' "
		ElseIf cLOSA2 != cLOSE2
			cJoinTit	+= " SUBSTRING(SA2.A2_FILIAL,1, " + cTamFilA2 + ") = SUBSTRING(E2_FILORIG,1, " + cTamFilA2 + ") "
		Else
			cJoinTit	+= " SA2.A2_FILIAL = FI8_FILDES "
		EndIf
		cJoinTit += "AND SA2.A2_COD = SE2A.E2_FORNECE "
		cJoinTit += "AND SA2.A2_LOJA = SE2A.E2_LOJA "
		cJoinTit += "AND SA2.D_E_L_E_T_ = ' '  "
	
		// Clausula WHERE -------------------------------------------------------------
		cWhrORI := "WHERE "
		cWhrORI +=     "FI8.FI8_FILIAL = ? "
		cWhrORI += "AND SE2A.E2_FATURA = ? "
		cWhrORI += "AND FI8.D_E_L_E_T_ = ' ' "
		cOrder	+= "ORDER BY FI8_FILIAL, FI8_PRFORI, FI8_NUMORI, FI8_PARORI, FI8_TIPORI, FI8_FORORI, FI8_LOJORI "
		// Montagem QUERY ------------------------------------------------------------
		cQuery += cCampos + cJoinTit + cWhrORI + cOrder

		cQuery 		:= ChangeQuery(cQuery)
		__oQryFatO 	:= FWPreparedStatement():New(cQuery)
	EndIf

	//Insere parâmetros em todas as Queries separadas por UNION
	__oQryFatO:SetString(1,__cProcess )
	__oQryFatO:SetString(2,FWxFilial("FI8"))
	__oQryFatO:SetString(3,__cProcess )
	
    cQuery := __oQryFatO:GetFixQuery()

	cAliasQry1 := MpSysOpenQuery(cQuery)

	RestArea(aAreaSE2)

Return cAliasQry1

//-------------------------------------------------------------------
/*/{Protheus.doc} F250FTDETB
Rotina para obtenção dos detalhes da Fatura na consulta

@author Rodrigo.Oliveira
@since 06/01/2022
/*/
//-------------------------------------------------------------------
STATIC Function F250FTDETB()

	Local cQuery 	As Character
	Local cQryAux	As Character
	Local cCampos 	As Character
	Local cJoinTit	As Character
	Local cWhere	As Character
	Local cPref		As Character
	Local cNum		As Character
	Local cTipo		As Character
	Local cForn		As Character
	Local cLoja		As Character
	Local cData		As Character	
	Local cWhrORI 	As Character
	Local cWhrDES 	As Character
	Local cAliasQry3 As Character
	Local cOrder	As Character
	
	cQuery 		:= ""
	cQryAux		:= ""
	cCampos 	:= ""
	cJoinTit 	:= ""
	cWhere 		:= ""
	cPref	 	:= SE2->E2_PREFIXO
	cNum		:= SE2->E2_NUM
	cParc		:= SE2->E2_PARCELA
	cTipo		:= SE2->E2_TIPO
	cForn	 	:= SE2->E2_FORNECE
	cLoja	 	:= SE2->E2_LOJA
	cData		:= Dtos(SE2->E2_EMIS1)
	cWhrORI		:= ""
	cWhrDES		:= ""
	cAliasQry3	:= GetNextAlias()
	cOrder		:= ""

	__nTotProc	:= 0
	
	If __oQryFatC == NIL

		// Clausula SELECT -----------------------------------------------------------
		cCampos := "SELECT DISTINCT E2_FILIAL FI8_FILDES, E2_PREFIXO FI8_PRFDES, E2_NUM FI8_NUMDES, "
		cCampos	+= " E2_PARCELA FI8_PARDES, E2_TIPO FI8_TIPDES, ' ' AS FI8_FORDES, ' ' AS FI8_LOJDES, "
		cCampos	+= " E2_VENCTO FI8_VCTDES, E2_VENCREA FI8_VCRDES, E2_VLCRUZ FI8_VALOR, "
		cCampos	+= " SE2.R_E_C_N_O_ RECNO "

		cCampos += "FROM " + RetSqlName("SE2") + " SE2 "
		// Clausula JOIN Títulos ------------------------------------------------------
		cJoinTit := "INNER JOIN " + RetSqlName("FI8") + " FI8 ON "
		cJoinTit += "FI8.FI8_FILDES = SE2.E2_FILIAL "
		cJoinTit += "AND FI8.FI8_PRFDES = SE2.E2_PREFIXO "
		cJoinTit += "AND FI8.FI8_NUMDES = SE2.E2_NUM "
		cJoinTit += "AND FI8.FI8_PARDES = SE2.E2_PARCELA " 
		cJoinTit += "AND FI8.FI8_FORDES = SE2.E2_FORNECE "
		cJoinTit += "AND FI8.FI8_LOJDES = SE2.E2_LOJA "
		cJoinTit += "AND SE2.E2_STATUS <> 'D' "
		cJoinTit += "AND SE2.D_E_L_E_T_ = ' '  "
		
		// Clausula WHERE -------------------------------------------------------------
		cWhrORI := "WHERE "
		cWhrORI +=     "SE2.E2_FILIAL = ? "
		cWhrORI += "AND SE2.E2_NUM = ? "
			
		cWhrORI += "AND FI8.D_E_L_E_T_ = ' ' "
		cOrder	+= "ORDER BY E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO "
		// Montagem QUERY ------------------------------------------------------------
		cQuery += cCampos + cJoinTit + cWhrORI + cOrder

		cQuery 		:= ChangeQuery(cQuery)
		__oQryFatC 	:= FWPreparedStatement():New(cQuery)
	EndIf

	//Insere parâmetros em todas as Queries separadas por UNION
	__oQryFatC:SetString(1,FWxFilial("FI8"))
	__oQryFatC:SetString(2,__cProcess )
		
	cQuery 	:= __oQryFatC:GetFixQuery()

	cQryAux	:= SubStr(cQuery, 1, At("ORDER BY ", cQuery) -1 )
	cAliasQry3 := MpSysOpenQuery(cQuery)
	__nTotProc := MpSysExecScalar("Select SUM(FI8_VALOR) TOTAL From (" + ;
		cQryAux + ") A ", "TOTAL")

Return cAliasQry3

//-------------------------------------------------------------------
/*/{Protheus.doc} F250LQDETA
Rotina para obtenção dos detalhes da Liquidação na consulta

@author Pequim
@since 06/01/2022
/*/
//-------------------------------------------------------------------
STATIC Function F250LQDETA()

	Local cQuery 	As Character
	Local cCampos 	As Character
	Local cJoinLiq	As Character
	Local cJoinTit	As Character
	Local cWhere	As Character
	Local cPref		As Character
	Local cNum		As Character
	Local cTipo		As Character
	Local cForn		As Character
	Local cLoja		As Character
	Local cData		As Character	
	Local cWhrORI 	As Character
	Local cAliasQry	As Character
	Local cLOSA2	As Character
	Local cLOSE2	As Character
	Local cTamFilA2	As Character
	Local cOrder	As Character
	Local nTamFilA2	As Numeric
	Local aAreaSE2	As Array
	
	cQuery 		:= ""
	cCampos 	:= ""
	cJoinLiq 	:= ""
	cJoinTit 	:= ""
	cWhere 		:= ""
	aAreaSE2	:= SE2->(GetArea())
	If __FI8->RECORI > 0 .And. !Empty(__FI8->NLIQORI)
		SE2->(DbGoTo(__FI8->RECORI))
	ElseIf __FI8->RECDES > 0 .And. !Empty(__FI8->NLIQDES)
		SE2->(DbGoTo(__FI8->RECDES))
	EndIf
	cPref	 	:= SE2->E2_PREFIXO
	cNum		:= SE2->E2_NUM
	cTipo		:= SE2->E2_TIPO
	cForn	 	:= SE2->E2_FORNECE
	cLoja	 	:= SE2->E2_LOJA
	cData		:= Dtos(SE2->E2_EMIS1)
	cWhrORI		:= ""
	cWhrDES		:= ""

	If __oQryLiqD == NIL

		cEmpSA2	:= FwModeAccess("SA2", 1)
		cLOSA2	:= cEmpSA2 + FwModeAccess("SA2", 2) + FwModeAccess("SA2", 3)
		cLOSE2	:= FwModeAccess("SE2", 1) + FwModeAccess("SE2", 2) + FwModeAccess("SE2", 3)

		nTamFilA2	:= Len(RTrim(FwxFilial("SA2")))
		cTamFilA2	:= AllTrim(STR(nTamFilA2))
		If _lFinLOTab
			cTamFilA2	:= FinLOTab("SA2")
		EndIf

		// Clausula SELECT -----------------------------------------------------------
		cCampos := "SELECT DISTINCT SE5A.R_E_C_N_O_ RECNO, "
		cCampos	+= " FI8_FILIAL, FI8_PRFORI, FI8_NUMORI, FI8_PARORI, "
		cCampos	+= " FI8_TIPORI, FI8_FORORI, FI8_LOJORI, A2_NOME, "
		cCampos	+= " SE2A.E2_EMISSAO FI8_EMIORI, SE2A.E2_VENCTO FI8_VCTORI, SE2A.E2_VENCREA FI8_VCRORI, "
		cCampos	+= " FI8_DATA, E5_VALOR FI8_VALORI,  "
		cCampos	+= " SE5A.E5_NATUREZ E2_NATORI, SE5A.E5_FILORIG E2_FILOORI "

		cCampos += "FROM " + RetSqlName("FI8") + " FI8 "
		// Clausula JOIN Títulos ------------------------------------------------------
		cJoinTit := "INNER JOIN " + RetSqlName("SE5") + " SE5A ON "
		cJoinTit +=     "FI8.FI8_FILIAL = SE5A.E5_FILIAL "
		cJoinTit += "AND FI8.FI8_PRFORI = SE5A.E5_PREFIXO "
		cJoinTit += "AND FI8.FI8_NUMORI = SE5A.E5_NUMERO "
		cJoinTit += "AND FI8.FI8_PARORI = SE5A.E5_PARCELA " 
		cJoinTit += "AND FI8.FI8_TIPORI = SE5A.E5_TIPO " 
		cJoinTit += "AND FI8.FI8_FORORI = SE5A.E5_FORNECE "
		cJoinTit += "AND FI8.FI8_LOJORI = SE5A.E5_LOJA "
		cJoinTit += "AND SE5A.E5_DOCUMEN = ? " 
		cJoinTit += "AND SE5A.E5_DATA = FI8.FI8_DATA "
		cJoinTit += "AND SE5A.E5_MOTBX = 'LIQ' "
		cJoinTit += "AND SE5A.E5_RECPAG = 'P' "
		cJoinTit += "AND SE5A.E5_SITUACA <> 'C' "
		cJoinTit += "AND SE5A.D_E_L_E_T_ = ' '  "

		// Clausula JOIN Fatura -------------------------------------------------------
		cJoinLiq := "INNER JOIN " + RetSqlName("SE2") + " SE2A ON "
		cJoinLiq +=     "FI8.FI8_FILIAL = SE2A.E2_FILIAL "
		cJoinLiq += "AND FI8.FI8_PRFORI = SE2A.E2_PREFIXO "
		cJoinLiq += "AND FI8.FI8_NUMORI = SE2A.E2_NUM "
		cJoinLiq += "AND FI8.FI8_PARORI = SE2A.E2_PARCELA "
		cJoinLiq += "AND FI8.FI8_TIPORI = SE2A.E2_TIPO "
		cJoinLiq += "AND FI8.FI8_FORORI = SE2A.E2_FORNECE "
		cJoinLiq += "AND FI8.FI8_LOJORI = SE2A.E2_LOJA "
		cJoinLiq += "AND SE2A.E2_STATUS <> 'D' "
		cJoinLiq += "AND SE2A.D_E_L_E_T_ = ' ' "
		
		cJoinLiq += "INNER JOIN " + RetSqlName("SE2") + " SE2B ON "
		cJoinLiq +=     "FI8.FI8_FILDES = SE2B.E2_FILIAL "
		cJoinLiq += "AND FI8.FI8_PRFDES = SE2B.E2_PREFIXO "
		cJoinLiq += "AND FI8.FI8_NUMDES = SE2B.E2_NUM "
		cJoinLiq += "AND FI8.FI8_PARDES = SE2B.E2_PARCELA "
		cJoinLiq += "AND FI8.FI8_TIPDES = SE2B.E2_TIPO "
		cJoinLiq += "AND FI8.FI8_FORDES = SE2B.E2_FORNECE "
		cJoinLiq += "AND FI8.FI8_LOJDES = SE2B.E2_LOJA "
		cJoinLiq += "AND SE2B.E2_STATUS <> 'D' "
		cJoinLiq += "AND SE2B.E2_NUMLIQ = ? "
		cJoinLiq += "AND SE2B.D_E_L_E_T_ = ' ' "

		cJoinLiq += "INNER JOIN " + RetSqlName("SA2") + " SA2 ON "
		If cEmpSA2 == 'C'
			cJoinLiq	+= " SA2.A2_FILIAL = '" + FwxFilial("SA2") + "' "
		ElseIf cLOSA2 != cLOSE2
			cJoinLiq	+= " SUBSTRING(SA2.A2_FILIAL,1,"+cTamFilA2+") = SUBSTRING(SE2B.E2_FILORIG,1,"+cTamFilA2+ ") "
		Else
			cJoinLiq	+= " SA2.A2_FILIAL = FI8_FILDES "
		EndIf

		cJoinLiq += "AND SA2.A2_COD = SE2B.E2_FORNECE "
		cJoinLiq += "AND SA2.A2_LOJA = SE2B.E2_LOJA "
		cJoinLiq += "AND SA2.D_E_L_E_T_ = ' '  "

		// Clausula WHERE -------------------------------------------------------------
		cWhrORI := "WHERE "
	
		cWhrORI +=     "( ( FI8.FI8_FILDES = ? "
		cWhrORI += "AND FI8.FI8_PRFDES = ? "
		cWhrORI += "AND FI8.FI8_NUMDES = ? "
		cWhrORI += "AND FI8.FI8_TIPDES = ? "
		cWhrORI += "AND FI8.FI8_FORDES = ? "
		cWhrORI += "AND FI8.FI8_LOJDES = ? ) "
		
		cWhrORI +=     "OR (FI8.FI8_FILIAL = ? "
		cWhrORI += "AND FI8.FI8_PRFORI = ? "
		cWhrORI += "AND FI8.FI8_NUMORI = ? "
		cWhrORI += "AND FI8.FI8_TIPORI = ? "
		cWhrORI += "AND FI8.FI8_FORORI = ? "
		cWhrORI += "AND FI8.FI8_LOJORI = ? ) ) "
	
		cWhrORI += "AND FI8.FI8_DATA   = ? "
		cWhrORI += "AND FI8.D_E_L_E_T_ = ' '"

		cOrder := " ORDER BY FI8_FILIAL, FI8_PRFORI, FI8_NUMORI, FI8_PARORI, FI8_TIPORI, FI8_FORORI, FI8_LOJORI "

		// Montagem QUERY ------------------------------------------------------------
		cQuery += cCampos + cJoinTit + cJoinLiq + cWhrORI + cOrder

		cQuery 		:= ChangeQuery(cQuery)
		__oQryLiqD 	:= FWPreparedStatement():New(cQuery)
	EndIf

	//Insere parâmetros em todas as Queries separadas por UNION
	__oQryLiqD:SetString(1,PADR(__cProcess,__nTamDoc))
	__oQryLiqD:SetString(2,PADR(__cProcess,__nTamDoc))
	__oQryLiqD:SetString(3,FWxFilial("FI8"))
	__oQryLiqD:SetString(4,cPref )
	__oQryLiqD:SetString(5,cNum	 )
	__oQryLiqD:SetString(6,cTipo )
	__oQryLiqD:SetString(7,cForn )
	__oQryLiqD:SetString(8,cLoja )
	__oQryLiqD:SetString(9,FWxFilial("FI8"))
	__oQryLiqD:SetString(10,cPref )
	__oQryLiqD:SetString(11,cNum	 )
	__oQryLiqD:SetString(12,cTipo )
	__oQryLiqD:SetString(13,cForn )
	__oQryLiqD:SetString(14,cLoja )
	__oQryLiqD:SetString(15,cData )

    cQuery := __oQryLiqD:GetFixQuery()
	cAliasQry := MpSysOpenQuery(cQuery)

	RestArea(aAreaSE2)

Return cAliasQry

//-------------------------------------------------------------------
/*/{Protheus.doc} F250LQDETB
Rotina para obtenção dos detalhes da Fatura na consulta

@author Rodrigo.Oliveira
@since 06/01/2022
/*/
//-------------------------------------------------------------------
STATIC Function F250LQDETB()

	Local cQuery 	As Character
	Local cQryAux	As Character
	Local cCampos 	As Character
	Local cJoinTit	As Character
	Local cWhere	As Character
	Local cPref		As Character
	Local cNum		As Character
	Local cTipo		As Character
	Local cForn		As Character
	Local cLoja		As Character
	Local cData		As Character	
	Local cWhrORI 	As Character
	Local cWhrDES 	As Character
	Local cAliasQry4 As Character
	Local cOrder	As Character
	Local aAreaSE2	As Array
	
	cQuery 		:= ""
	cQryAux		:= ""
	cCampos 	:= ""
	cJoinTit 	:= ""
	cWhere 		:= ""
	aAreaSE2	:= SE2->(GetArea())
	If __FI8->RECORI > 0 .And. !Empty(__FI8->NLIQORI)
		SE2->(DbGoTo(__FI8->RECORI))
	ElseIf __FI8->RECDES > 0 .And. !Empty(__FI8->NLIQDES)
		SE2->(DbGoTo(__FI8->RECDES))
	EndIf
	cPref	 	:= SE2->E2_PREFIXO
	cNum		:= SE2->E2_NUM
	cParc		:= SE2->E2_PARCELA
	cTipo		:= SE2->E2_TIPO
	cForn	 	:= SE2->E2_FORNECE
	cLoja	 	:= SE2->E2_LOJA
	cData		:= Dtos(SE2->E2_EMIS1)
	cWhrORI		:= ""
	cWhrDES		:= ""
	cAliasQry3	:= GetNextAlias()
	cOrder		:= ""

	__nTotProc	:= 0
	
	If __oQryLqDB == NIL

		// Clausula SELECT -----------------------------------------------------------
		cCampos := "SELECT DISTINCT E2_FILIAL FI8_FILDES, E2_PREFIXO FI8_PRFDES, E2_NUM FI8_NUMDES, "
		cCampos	+= " E2_PARCELA FI8_PARDES, E2_TIPO FI8_TIPDES, ' ' AS FI8_FORDES, ' ' AS FI8_LOJDES, "
		cCampos	+= " E2_VENCTO FI8_VCTDES, E2_VENCREA FI8_VCRDES, E2_VLCRUZ FI8_VALOR, "
		cCampos	+= " SE2.R_E_C_N_O_ RECNO "

		cCampos += "FROM " + RetSqlName("SE2") + " SE2 "
		// Clausula JOIN Títulos ------------------------------------------------------
		cJoinTit := "INNER JOIN " + RetSqlName("FI8") + " FI8 ON "
		
		cJoinTit += "( ( FI8.FI8_FILDES = SE2.E2_FILIAL "
		cJoinTit += "AND FI8.FI8_PRFDES = SE2.E2_PREFIXO "
		cJoinTit += "AND FI8.FI8_NUMDES = SE2.E2_NUM "
		cJoinTit += "AND FI8.FI8_PARDES = SE2.E2_PARCELA " 
		cJoinTit += "AND FI8.FI8_FORDES = SE2.E2_FORNECE "
		cJoinTit += "AND FI8.FI8_LOJDES = SE2.E2_LOJA "
		cJoinTit += "AND SE2.E2_STATUS <> 'D' "
		cJoinTit += "AND SE2.D_E_L_E_T_ = ' ' ) "

		cJoinTit += "OR ( FI8.FI8_FILIAL = SE2.E2_FILIAL "
		cJoinTit += "AND FI8.FI8_PRFORI = SE2.E2_PREFIXO "
		cJoinTit += "AND FI8.FI8_NUMORI = SE2.E2_NUM "
		cJoinTit += "AND FI8.FI8_PARORI = SE2.E2_PARCELA " 
		cJoinTit += "AND FI8.FI8_FORORI = SE2.E2_FORNECE "
		cJoinTit += "AND FI8.FI8_LOJORI = SE2.E2_LOJA "
		cJoinTit += "AND SE2.E2_STATUS <> 'D' "
		cJoinTit += "AND SE2.D_E_L_E_T_ = ' ' ) ) "

		// Clausula WHERE -------------------------------------------------------------
		cWhrORI := "WHERE "
		cWhrORI +=     "SE2.E2_FILIAL = ? "
		cWhrORI += "AND SE2.E2_NUMLIQ = ? "
		cWhrORI += "AND ( ( SE2.E2_NUM = FI8_NUMDES "
		cWhrORI += "AND SE2.E2_PARCELA = FI8_PARDES ) "
		cWhrORI += "OR ( SE2.E2_NUM = FI8_NUMORI "
		cWhrORI += "AND SE2.E2_PARCELA = FI8_PARORI ) ) "
		cWhrORI += "AND ( ( SE2.E2_PREFIXO = FI8_PRFDES AND SE2.E2_TIPO = FI8_TIPDES AND SE2.E2_FORNECE = FI8_FORDES AND SE2.E2_LOJA = FI8_LOJDES ) "
		cWhrORI += "OR ( SE2.E2_PREFIXO = FI8_PRFORI AND SE2.E2_TIPO = FI8_TIPORI AND SE2.E2_FORNECE = FI8_FORORI AND SE2.E2_LOJA = FI8_LOJORI ) ) "
		cWhrORI += "AND SE2.E2_EMISSAO = FI8_DATA "
		cWhrORI += "AND SE2.D_E_L_E_T_ = ' ' "
		cWhrORI += "AND FI8.D_E_L_E_T_ = ' ' "
		cOrder	+= "ORDER BY E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO "
		// Montagem QUERY ------------------------------------------------------------
		cQuery += cCampos + cJoinTit + cWhrORI + cOrder

		cQuery 		:= ChangeQuery(cQuery)
		__oQryLqDB 	:= FWPreparedStatement():New(cQuery)
	EndIf

	//Insere parâmetros em todas as Queries separadas por UNION
	__oQryLqDB:SetString(1,FWxFilial("FI8"))
	__oQryLqDB:SetString(2,__cProcess )

    cQuery 	:= __oQryLqDB:GetFixQuery()

	cQryAux	:= SubStr(cQuery, 1, At("ORDER BY ", cQuery) -1 )
	cAliasQry4 := MpSysOpenQuery(cQuery)
	__nTotProc := MpSysExecScalar("Select SUM(FI8_VALOR) TOTAL From (" + ;
		cQryAux + ") A ", "TOTAL")

	RestArea(aAreaSE2)

Return cAliasQry4

//-------------------------------------------------------------------
/*/{Protheus.doc} F250LQTDET
Rotina para obtenção dos detalhes da Liquidação na consulta

@author Pequim
@since 06/01/2022
/*/
//-------------------------------------------------------------------
STATIC Function F250LQTDET()

	Local cQuery 	As Character
	Local cCampos 	As Character
	Local cJoinLiq	As Character
	Local cJoinTit	As Character
	Local cWhere	As Character
	Local cPref		As Character
	Local cNum		As Character
	Local cTipo		As Character
	Local cForn		As Character
	Local cLoja		As Character
	Local cData		As Character	
	Local cWhrORI 	As Character
	Local cAliasQry2 As Character

	cQuery 		:= ""
	cCampos 	:= ""
	cJoinLiq 	:= ""
	cJoinTit 	:= ""
	cWhere 		:= ""
	cPref	 	:= SE2->E2_PREFIXO
	cNum		:= SE2->E2_NUM
	cTipo		:= SE2->E2_TIPO
	cForn	 	:= SE2->E2_FORNECE
	cLoja	 	:= SE2->E2_LOJA
	cData		:= Dtos(SE2->E2_EMIS1)
	cWhrORI		:= ""
	cWhrDES		:= ""

	If __oQryLqDA == NIL
		// Clausula SELECT -----------------------------------------------------------
		cCampos := "SELECT DISTINCT SE5A.R_E_C_N_O_ RECNO, "
		cCampos	+= " FI8_FILIAL, FI8_PRFORI, FI8_NUMORI, FI8_PARORI, "
		cCampos	+= " FI8_TIPORI, FI8_FORORI, FI8_LOJORI,"
		cCampos	+= " FI8_FILDES, FI8_PRFDES, FI8_NUMDES, FI8_PARDES, "
		cCampos	+= " FI8_TIPDES, FI8_FORDES, FI8_LOJDES, FI8_DATA, FI8_VALOR,  "
		cCampos	+= " SE5A.E5_NATUREZ E2_NATORI, SE5A.E5_FILORIG E2_FILOORI "

		cCampos += "FROM " + RetSqlName("FI8") + " FI8 "
		// Clausula JOIN Títulos ------------------------------------------------------
		cJoinTit := "INNER JOIN " + RetSqlName("SE5") + " SE5A ON "
		cJoinTit +=     "FI8.FI8_FILIAL = SE5A.E5_FILIAL "
		cJoinTit += "AND FI8.FI8_PRFORI = SE5A.E5_PREFIXO "
		cJoinTit += "AND FI8.FI8_NUMORI = SE5A.E5_NUMERO "
		cJoinTit += "AND FI8.FI8_PARORI = SE5A.E5_PARCELA " 
		cJoinTit += "AND FI8.FI8_TIPORI = SE5A.E5_TIPO " 
		cJoinTit += "AND FI8.FI8_FORORI = SE5A.E5_FORNECE "
		cJoinTit += "AND FI8.FI8_LOJORI = SE5A.E5_LOJA "
		cJoinTit += "AND SE5A.E5_DOCUMEN = ? " 
		cJoinTit += "AND SE5A.E5_DATA = FI8.FI8_DATA "
		cJoinTit += "AND SE5A.E5_MOTBX = 'LIQ' "
		cJoinTit += "AND SE5A.E5_RECPAG = 'P' "
		cJoinTit += "AND SE5A.E5_SITUACA <> 'C' "
		cJoinTit += "AND SE5A.D_E_L_E_T_ = ' '  "

		// Clausula JOIN Fatura -------------------------------------------------------
		cJoinLiq := "INNER JOIN " + RetSqlName("SE2") + " SE2B ON "
		cJoinLiq +=     "FI8.FI8_FILDES = SE2B.E2_FILIAL "
		cJoinLiq += "AND FI8.FI8_PRFDES = SE2B.E2_PREFIXO "
		cJoinLiq += "AND FI8.FI8_NUMDES = SE2B.E2_NUM "
		cJoinLiq += "AND FI8.FI8_PARDES = SE2B.E2_PARCELA "
		cJoinLiq += "AND FI8.FI8_TIPDES = SE2B.E2_TIPO "
		cJoinLiq += "AND FI8.FI8_FORDES = SE2B.E2_FORNECE "
		cJoinLiq += "AND FI8.FI8_LOJDES = SE2B.E2_LOJA "
		cJoinLiq += "AND SE2B.E2_STATUS <> 'D' "
		cJoinLiq += "AND SE2B.E2_NUMLIQ = ? "
		cJoinLiq += "AND SE2B.D_E_L_E_T_ = ' ' "

		// Clausula WHERE -------------------------------------------------------------
		cWhrORI := "WHERE "
		cWhrORI +=     "FI8.FI8_FILIAL = ? "
		cWhrORI += "AND FI8.FI8_PRFORI = ? "
		cWhrORI += "AND FI8.FI8_NUMORI = ? "
		cWhrORI += "AND FI8.FI8_TIPORI = ? "
		cWhrORI += "AND FI8.FI8_FORORI = ? "
		cWhrORI += "AND FI8.FI8_LOJORI = ? "
		cWhrORI += "AND FI8.FI8_DATA   = ? "
		cWhrORI += "AND FI8.D_E_L_E_T_ = ' '"

		// Montagem QUERY ------------------------------------------------------------
		cQuery += cCampos + cJoinTit + cJoinLiq + cWhrORI

		cQuery 		:= ChangeQuery(cQuery)
		__oQryLqDA 	:= FWPreparedStatement():New(cQuery)
	endif

	//Insere parâmetros em todas as Queries separadas por UNION
	__oQryLqDA:SetString(1,PADR(__cProcess,__nTamDoc))
	__oQryLqDA:SetString(2,PADR(__cProcess,__nTamDoc))
	__oQryLqDA:SetString(3,FWxFilial("FI8"))
	__oQryLqDA:SetString(4,cPref )
	__oQryLqDA:SetString(5,cNum	 )
	__oQryLqDA:SetString(6,cTipo )
	__oQryLqDA:SetString(7,cForn )
	__oQryLqDA:SetString(8,cLoja )
	__oQryLqDA:SetString(9,cData )

    cQuery		:= __oQryLqDA:GetFixQuery()
	cAliasQry2 	:= MpSysOpenQuery(cQuery)

Return cAliasQry2

//-------------------------------------------------------------------
/*/{Protheus.doc} f250ValOri()
Função para obter o valor baixado do titulo originador do processo
de Fatura ou Liquidação

@param cAliasTrb: Alias do TRB

@author Pequim
@since 06/01/2022

/*/
//-------------------------------------------------------------------
Function f250ValOri(cAliasTrb)

	Local cChaveTit As Character
	Local cIDDOC As Character
	Local cMotBx As Character
	Local cDOC As Character
	Local cQry As Character
	Local cQryA As Character
	Local nValOri As Numeric

	Default cAliasTrb := ""

	cChaveTit	:= ""
	cIDDOC		:= ""
	cMotBx		:= ""
	cDOC		:= ""
	cQry		:= ""
	cQryA		:= ""
	nValOri 	:= 0

	If !Empty(cAliasTrb)
		cChaveTit := (cAliasTrb)->FI8_FILIAL +'|'+ (cAliasTrb)->FI8_PRFORI +'|'+ (cAliasTrb)->FI8_NUMORI +'|'+ (cAliasTrb)->FI8_PARORI +'|'+ ;
					 (cAliasTrb)->FI8_TIPORI +'|'+ (cAliasTrb)->FI8_FORORI +'|'+ (cAliasTrb)->FI8_LOJORI
		cIDDOC    := FINBuscaFK7(cChaveTit, "SE2")
		cMotBx	  := If(__lFatura, 'FAT', 'LIQ')
		cDOC	  := If(__lFatura, '', __cProcess)

		If __oQryVMov == Nil
			cQry := "SELECT SUM(FK2.FK2_VALOR) FK2VLR FROM " + RetSqlName("FK2") + " FK2 "
			cQry += "WHERE FK2.FK2_RECPAG = 'P' AND FK2.FK2_TPDOC = 'BA' "

			cQryA := "AND FK2.FK2_IDDOC = ? "
			cQryA += "AND FK2.FK2_MOTBX = ? "
			cQryA += "AND FK2.FK2_DATA = ? "
			cQryA += "AND FK2.FK2_DOC = ? "
			cQryA += "AND FK2.D_E_L_E_T_ = ' ' "

			cQry += cQryA + "AND FK2.FK2_SEQ NOT IN ("
			cQry += "SELECT EST.FK2_SEQ FROM " + RetSqlName("FK2") + " EST "
			cQry += "WHERE EST.FK2_RECPAG = 'R' AND EST.FK2_TPDOC = 'ES' AND EST.FK2_SEQ = FK2.FK2_SEQ "
			cQry += StrTran(cQryA, "FK2.", "EST.") + ") "
				
			cQry := ChangeQuery(cQry)
			__oQryVMov := FWPreparedStatement():New(cQry)
		EndIf

		__oQryVMov:SetString(1, cIDDOC)
		__oQryVMov:SetString(2, cMotBx)
		__oQryVMov:SetDate(3, STOD((cAliasTrb)->FI8_DATA))
		__oQryVMov:SetString(4, cDOC)
		__oQryVMov:SetString(5, cIDDOC)
		__oQryVMov:SetString(6, cMotBx)
		__oQryVMov:SetDate(7, STOD((cAliasTrb)->FI8_DATA))
		__oQryVMov:SetString(8, cDOC)

		cQry := __oQryVMov:GetFixQuery()
		nValOri := MpSysExecScalar(cQry,"FK2VLR")
	Endif

Return nValOri

//-------------------------------------------------------------------
/*/{Protheus.doc} F250Dados()
Função para obter o valor baixado do titulo originador do processo
de Fatura ou Liquidação

@param nOpcao	: Opção para obtenção dos valores 
						1 = Cabeçalho da consulta
						2 = Títulos originadores do processo
						3 = Títulos gerados pelo processo

@param cAliasTrb: Alias do TRB

@author Pequim
@since 10/01/2022

/*/
//-------------------------------------------------------------------
Static Function F250Dados(nOpcao As Numeric, cAliasTRB As Character) As Array

	Local aDados AS Array
	Local aAreaSA2 AS Array
	Local aAreaSE2 AS Array
	Local aAreaSED AS Array
	Local aAreaTrb AS Array
	Local cNaturez AS Character
	Local cDescNat AS Character
	Local cNomeFor AS Character
	Local dVencto AS Date
	Local dVencRea AS Date
	Local dEmissao  AS Date

	Default nOpcao := 0
	Default cAliasTrb := ""

	aDados   := {}
	aAreaSA2 := SA2->(GetArea())
	aAreaSE2 := SE2->(GetArea())
	aAreaSED := SED->(GetArea())
	aAreaTRB := (cAliasTrb)->(GetArea())
	cNaturez := ""
	cDescNat := ""
	cNomeFor := ""
	dVencto	 := STOD('')
	dVencRea := STOD('')
	dEmissao := STOD('')

	SA2->(DbSetOrder(1))
	SE2->(DbSetOrder(1))
	SED->(DbSetOrder(1))

	If nOpcao == 1		//Cabeçalho
		cNaturez := SE2->E2_NATUREZ
		If SED->(MsSeek(xFilial("SED", SE2->E2_FILORIG) + cNaturez))
			cDescNat := SED->ED_DESCRIC
		EndIf
		If SA2->(MsSeek(xFilial("SA2", SE2->E2_FILORIG) + SE2->(E2_FORNECE + E2_LOJA)))
			cNomeFor := SA2->A2_NOME
		EndIf
		AADD(aDados, {cNomeFor,cNaturez, cDescNat })

	ElseIf nOpcao == 2	//Geradores
		If SE2->(MsSeek((cAliasTrb)->(FI8_FILIAL + FI8_PRFORI + FI8_NUMORI + FI8_PARORI + FI8_TIPORI + FI8_FORORI + FI8_LOJORI)))
			dEmissao := SE2->E2_EMISSAO
			dVencto	 := SE2->E2_VENCTO
			dVencRea := SE2->E2_VENCREA
		Endif

		If SA2->(MsSeek(xFilial("SA2", (cAliasTrb)->E2_FILOORI) + (cAliasTrb)->(FI8_FORORI + FI8_LOJORI)))
			cNomeFor := SA2->A2_NOME
		Endif	
		AADD(aDados, {cNomeFor, dEmissao, dVencto, dVencRea})

	ElseIf nOpcao == 3	//Gerados
		If SE2->(MsSeek((cAliasTrb)->(FI8_FILDES + FI8_PRFDES + FI8_NUMDES + FI8_PARDES + FI8_TIPDES + FI8_FORDES + FI8_LOJDES)))
			dVencto	 := SE2->E2_VENCTO
			dVencRea := SE2->E2_VENCREA
		Endif
		AADD(aDados, {dVencto, dVencRea})

	Endif

	RestArea(aAreaSA2)
	RestArea(aAreaSE2)
	RestArea(aAreaSED)
	RestArea(aAreaTRB)
	FwFreeArray(aAreaSA2)
	FwFreeArray(aAreaSE2)
	FwFreeArray(aAreaSED)

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadGrdO()
Função estática para efetuar o load dos dados do grid

@param oModel: Modelo Ativo

@author Rodrigo Oliveira
@since 11/07/2022

/*/
//-------------------------------------------------------------------
Static Function LoadGrdO(oModel)

	Local nRecAnt		AS Numeric
	Local nTotProc		AS Numeric
	Local nValDes		AS Numeric
	Local oStruFI8O		AS Object
	Local aArea			AS Array
	Local aDados		AS Array
	Local aData			As Array
	Local cAliasTrbA 	AS Character
	Local nCount		As Numeric
	Local nCountA		As Numeric

	nRecAnt		:= 0
	nTotProc	:= 0
	nValDes		:= 0
	nCount		:= 0
	nCountA		:= 0
	oStruFI8O	:= oModel
	aArea	  	:= GetArea()
	aDados		:= {}
	aData		:= {}
	cAliasTrbA	:= ""

	If __lFatura
		cAliasTrbA	:= F250FTDETA()
	Else
		cAliasTrbA := F250LQDETA()
	Endif

	TcSetField(cAliasTrbA,"FI8_EMIORI","D", 8)
	TcSetField(cAliasTrbA,"FI8_VCTORI","D", 8)
	TcSetField(cAliasTrbA,"FI8_VCRORI","D", 8)
	
	aData := FwLoadByAlias(oStruFI8O, cAliasTrbA)

	RestArea(aArea)

Return aData

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadGrdD()
Função estática para efetuar o load dos dados do grid

@param oModel: Modelo Ativo

@author Rodrigo Oliveira
@since 11/07/2022

/*/
//-------------------------------------------------------------------
Static Function LoadGrdD(oModel)

	Local nRecAnt		AS Numeric
	Local nTotProc		AS Numeric
	Local nValDes		AS Numeric
	Local oStruFI8D		AS Object
	Local aArea			AS Array
	Local aDados		AS Array
	Local aData			As Array
	Local cAliasTrbB 	AS Character
	Local nCount		As Numeric
	Local nCountA		As Numeric

	nRecAnt		:= 0
	nTotProc	:= 0
	nValDes		:= 0
	nCount		:= 0
	nCountA		:= 0
	oStruFI8D	:= oModel
	aArea	  	:= GetArea()
	aDados		:= {}
	aData		:= {}
	cAliasTrbB	:= ""

	If __lFatura
		cAliasTrbB	:= F250FTDETB()
	Else
		cAliasTrbB 	:= F250LQDETB()
	Endif

	TcSetField(cAliasTrbB,"FI8_VCTDES","D", 8)
	TcSetField(cAliasTrbB,"FI8_VCRDES","D", 8)
	
	aData := FwLoadByAlias(oStruFI8D, cAliasTrbB)

	RestArea(aArea)

Return aData
