#Include 'Protheus.ch'
#Include "ApWizard.ch"
#Include 'FWMVCDef.ch'
#INCLUDE "FWBROWSE.CH"
#Include "ATFA385.ch"

Static _lAuto 		:= .F.
Static _lParam 		:= .T.
Static _lCarga 		:= .T.
Static _lConfMrkBr 	:= .F.
Static _cArqImp 	:= ""
Static _lVldLinOK 	:= .F.
Static _cAliasQry 	:= NIL
Static _cAliasMark 	:= NIL
Static _oMrkBrowse 	:= NIL 
Static _cMark	 	:= NIL 
Static _aCpos_CSV   := NIL
Static _aDadosCSV   := NIL
Static _aStruSN3   	:= NIL
Static _aCamposFNZ 	:= NIL
Static _oATFA3851

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location
//-------------------------------------------------------------------
/*{Protheus.doc}ATFA385
Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function ATFA385(xCab,xItens,nOpcAuto,aParam)

Local oBrowse  		:= FWmBrowse():New()
Local aLegenda 		:= {}
Local nX		 	:= 1
Local lRet		  	:= .T.

Local cFilter   	:= Nil
Local lA385BrwF 	:= ExistBlock("A385BRWF")
Local aArray 		:= {'1'}
//
Private lCriaAuto 	:= .F.     //Se .t. permitir a copia
Private cCadastro 	:= STR0001 //"Processo de Ajuste a Valor Positivo/Negativo Societario"

Private aParamAuto	:= {}
Private INCLUI    := .F.
Private ALTERA    := .F.

//
Default xCab 			:= Nil
Default xItens	  	:= Nil
Default nOpcAuto 	  	:= 0
Default aParam		:= {}

//Carrega valor do xParam
aParamAuto := If(aParam <> Nil,aParam,)

_lAuto := !Empty(aParamAuto)

//F12 - Ativa grupo de perguntas.
SetKey( VK_F12, { || Pergunte("AFA385",.T.) } )

pergunte("AFA385",.F.)
AF385PerAut()

///Ponto de Entrada - MBROWSE //ACRESCENTAR FILTRO NA BROWSE
If lA385BrwF
	cFilter := ExecBlock( "A385BRWF", .F., .F. )
	cFilter := If(ValType(cFilter) == "C", cFilter, Nil )
Endif
//
If cFilter <> Nil 	
	oBrowse:SetFilterDefault(cFilter)	
EndIf	
oBrowse:SetAlias('FNY')
oBrowse:SetDescription(cCadastro) //Atualização de Ativos Imobilizados.
aLegenda := Atf385Leg()
For nX := 1 To Len(aLegenda)
	oBrowse:AddLegend( aLegenda[nX,1],aLegenda[nX,2],aLegenda[nX,3])	
Next	

oBrowse:SetCacheView(.F.)// Não realiza o cache da viewdef
oBrowse:Activate()

	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Menu de Ativos Imobilizados
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local lAf385rot 	:= ExistBlock('AF385ROT')
Local aRotina 	:= { }	
Default _lMarkBrw	:= .F.

If _lMarkBrw
	ADD OPTION aRotina TITLE STR0002		ACTION "AF385Conf"			OPERATION 4 ACCESS 0	//'Confirmar'
Else
	ADD OPTION aRotina TITLE STR0003		ACTION 'PesqBrw'            OPERATION 1 ACCESS 0 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0004		ACTION 'VIEWDEF.ATFA385'   	OPERATION 2 ACCESS 0 	//'Visualizar'
	ADD OPTION aRotina TITLE STR0005		ACTION 'VIEWDEF.ATFA385'		OPERATION 3 ACCESS 0 	//'Incluir'
	ADD OPTION aRotina TITLE STR0006		ACTION 'VIEWDEF.ATFA385'   	OPERATION 4 ACCESS 0 	//'Alterar'
	ADD OPTION aRotina TITLE STR0007		ACTION 'VIEWDEF.ATFA385'   	OPERATION 5 ACCESS 0 	//'Excluir'
	ADD OPTION aRotina TITLE STR0008		ACTION 'AF385Efet'   	  	OPERATION 9 ACCESS 0 	//'Efetivar'
	ADD OPTION aRotina TITLE STR0009		ACTION 'AF385IMPCSV'  		OPERATION 3 ACCESS 0 	//'Importar'  
	ADD OPTION aRotina TITLE STR0010		ACTION 'AF385EXPCSV'  		OPERATION 2 ACCESS 0 	//'Exportar'  
	ADD OPTION aRotina TITLE STR0011		ACTION 'AF385Print'	  		OPERATION 2 ACCESS 0 	//'Imprimir'  
EndIf
If lAf385rot
	aRotina := ExecBlock("AF385ROT",.F.,.F.,{aRotina})
Endif	
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Interface do cadastro de Ativos
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
/*/	
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 		:= FWLoadModel('ATFA385')
Local oView 		:= FWFormView():New()
Local oFNY  		:= FWFormStruct(2, 'FNY')
Local oFNZ  		:= FWFormStruct(2, 'FNZ')

Local aUsButtons 	:= {} 
Local oButtonBar	:= FWButtonBar():new()

//remove campo Id Processo pois esta no cabecalho FNY
oFNZ:RemoveField('FNZ_PROCID')
oView:SetModel(oModel)

oView:AddField('VIEW_FNY', oFNY,'FNYMASTER' )
oView:AddGrid ('VIEW_FNZ', oFNZ,'FNZDETAIL')

oView:CreateHorizontalBox( 'BOXFNY', 025)
oView:CreateHorizontalBox( 'BOXFNZ', 075)

oView:SetOwnerView('VIEW_FNY','BOXFNY')
oView:SetOwnerView('VIEW_FNZ','BOXFNZ') 

oView:AddIncrementField( 'VIEW_FNZ', 'FNZ_ITEM' )
oView:SetViewAction( "BUTTONCANCEL", {|| AF385Cancel() } )
oView:SetCloseOnOK({|| .T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc}ModelDef
Modelo de dados do cadastro de ativos
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oFNY		:= FWFormStruct( 1, 'FNY')
Local oFNZ		:= FWFormStruct( 1, 'FNZ')
Local oModel 	:=  MPFormModel():New('ATFA385',{|oModel| AF385PREVAL(oModel)}/*PreValidacao*/,{ |oModel| AF385ATDOK(oModel)}/*PosValidacao*/,{|oModel| AF385AGRV(oModel)})
Local aRelac 	:= {}
Local nMax 		:= Val( Replicate( "9",TamSX3("FNZ_ITEM")[1]) )

AFA385CriaGat(oFNZ) //Função para criar gatilhos do model.	
//
oModel:SetDescription(STR0012)//"Itens do Processo de Ajuste a Valor Positivo/Negativo Societario"
oModel:AddFields('FNYMASTER',/**/,oFNY)
oModel:AddGrid('FNZDETAIL','FNYMASTER',oFNZ, , {|oModel| AF385ALNOK(oModel)})

aAdd(aRelac,{'FNZ_FILIAL','xFilial("FNZ")'})
aAdd(aRelac,{'FNZ_PROCID' ,'FNY_PROCID'})

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'FNZDETAIL', aRelac , FNZ->(IndexKey(1)))

oModel:SetPrimarykey({'FNY_FILIAL','FNY_PROCID'})

oModel:GetModel("FNZDETAIL"):SetUniqueLine({ 'FNZ_BEM', 'FNZ_ITBEM', 'FNZ_TIPO', 'FNZ_TPSALD'})		
oModel:GetModel("FNZDETAIL"):SetMaxLine( nMax )		

oModel:GetModel('FNYMASTER'):SetDescription(STR0001) //"Processo de Ajuste a Valor Positivo/Negativo Societario"

oModel:SetVldActivate( {|oModel| AF385PRE_FORM(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc}AFA385CriaGat
Função para criação dos gatilhos
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
/*/
//-------------------------------------------------------------------
Function AFA385CriaGat(oFNZ)
Local aCampos := {}
Local nX := 1
Local aAux := {}

//Relação de campos com gatilhos.
//Estrutura do array aAux
//aAux[1] - [01] identificador (ID) do campo de origem
//aAux[2] - [02] identificador (ID) do campo de destino
//aAux[3] - [03] Bloco de código de validação da execução do gatilho
//aAux[4] - [04] Bloco de código de execução do gatilho

//MOEDA 2
aAux := FwStruTrigger("FNZ_VLAJS1" ,"FNZ_VLAJS2" ,'AF385GATL( 2,"2")',.F.,,,)
aAdd(aCampos, { aAux[1], aAux[2], aAux[3],aAux[4] } )
aAux := FwStruTrigger("FNZ_VLTAX1" ,"FNZ_TXDEP2" ,'AF385GATL( 3,"2")',.F.,,,)
aAdd(aCampos, { aAux[1], aAux[2], aAux[3],aAux[4] } )
aAux := FwStruTrigger("FNZ_VLACM1" ,"FNZ_VRDAC2" ,'AF385GATL( 4,"2")',.F.,,,)
aAdd(aCampos, { aAux[1], aAux[2], aAux[3],aAux[4] } )
//MOEDA 3
aAux := FwStruTrigger("FNZ_VLAJS1" ,"FNZ_VLAJS3" ,'AF385GATL( 2,"3")',.F.,,,)
aAdd(aCampos, { aAux[1], aAux[2], aAux[3],aAux[4] } )
aAux := FwStruTrigger("FNZ_VLTAX1" ,"FNZ_TXDEP3" ,'AF385GATL( 3,"3")',.F.,,,)
aAdd(aCampos, { aAux[1], aAux[2], aAux[3],aAux[4] } )
aAux := FwStruTrigger("FNZ_VLACM1" ,"FNZ_VRDAC3" ,'AF385GATL( 4,"3")',.F.,,,)
aAdd(aCampos, { aAux[1], aAux[2], aAux[3],aAux[4] } )
//MOEDA 4
aAux := FwStruTrigger("FNZ_VLAJS1" ,"FNZ_VLAJS4" ,'AF385GATL( 2,"4")',.F.,,,)
aAdd(aCampos, { aAux[1], aAux[2], aAux[3],aAux[4] } )
aAux := FwStruTrigger("FNZ_VLTAX1" ,"FNZ_TXDEP4" ,'AF385GATL( 3,"4")',.F.,,,)
aAdd(aCampos, { aAux[1], aAux[2], aAux[3],aAux[4] } )
aAux := FwStruTrigger("FNZ_VLACM1" ,"FNZ_VRDAC4" ,'AF385GATL( 4,"4")',.F.,,,)
aAdd(aCampos, { aAux[1], aAux[2], aAux[3],aAux[4] } )
//MOEDA 5
aAux := FwStruTrigger("FNZ_VLAJS1" ,"FNZ_VLAJS5" ,'AF385GATL( 2,"5")',.F.,,,)
aAdd(aCampos, { aAux[1], aAux[2], aAux[3],aAux[4] } )
aAux := FwStruTrigger("FNZ_VLTAX1" ,"FNZ_TXDEP5" ,'AF385GATL( 3,"5")',.F.,,,)
aAdd(aCampos, { aAux[1], aAux[2], aAux[3],aAux[4] } )
aAux := FwStruTrigger("FNZ_VLACM1" ,"FNZ_VRDAC5" ,'AF385GATL( 4,"5")',.F.,,,)
aAdd(aCampos, { aAux[1], aAux[2], aAux[3],aAux[4] } )

/* Criação de Gatilhos */
For nX := 1 To Len(aCampos)
	oFNZ:AddTrigger( aCampos[nX,1], aCampos[nX,2], aCampos[nX,3], aCampos[nX,4] )
Next nX

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc}Atf385Leg()
Função para legenda da browse
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
/*/
//-------------------------------------------------------------------
Static Function Atf385Leg()
Local aRet 		:= {}
Aadd(aRet, { 'FNY->FNY_STATUS == "1"', "BR_VERDE"		, STR0013 	} )  //"Simulação"
Aadd(aRet, { 'FNY->FNY_STATUS == "2"', "BR_VERMELHO"	, STR0014 	} )  //"Efetivação"
Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc}AF385Cancel()
Evento Cancela no Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function AF385Cancel()

If __lSX8 .And. lCancel
	RollBackSX8()
EndIf

AF385Reset()

Return

//-------------------------------------------------------------------
/*{Protheus.doc}AF385Conf()
Confirma MarkBrowse no Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function AF385Conf()

If !_lConfMrkBr
	If MsgYesNo(STR0015,STR0016)	//"Confirma Selecao ?"##"SELECAO DE ATIVOS PARA AJUSTE"
		_lConfMrkBr 	:= .T.
	EndIf
Else
	MsgInfo(STR0017)  //"Ja Confirmado. Pressione Sair para continuar operacao."
EndIf

Return 


//-------------------------------------------------------------------
/*{Protheus.doc}AF385Efet()
Efetivar Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function AF385Efet()
Local lRet := .T.

//valida se todos os registros do processo 
//estao com valor de ajuste e nao possuem 
//tipo 16 ou 17
//e classificacao contabil minima 
// conta do bem / conta desp deprec / conta deprec acumulada

lRet := Atfa385_VLEF()

If lRet
	Atfa385_EF()
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc}AF385IMPCSV()
Importar de Arquivo Texto para Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function AF385IMPCSV()
Local lRet := .T.
Local aRet := Array(1)
Local aPerg := {}

aRet[1]:= PadR( "\SYSTEM\AF_385_.CSV", 150 )
aAdd(aPerg,{ 6,STR0018,aRet[1],"","","",100,.T.,STR0019 + " (*.CSV) |*.CSV ", "",GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE}) //"Diretório de Gravação"###"Todos os arquivos (*.*) |*.*"

lRet := ParamBox(aPerg,STR0020, aRet) //"Parâmetros Exportação..."

If lRet .And. ! File(Alltrim(aRet[1]))
	MsgStop(STR0021)  //"Arquivo nao encontrado. Verifique!"
	lRet := .F.
EndIf

If lRet
	_cArqImp := Alltrim(aRet[1])
	MsgRun( STR0022, STR0023 , {|| lRet := AF385Imp( Alltrim(aRet[1]) ) } ) //"Processando Importação"##"Processando ..."
EndIf

If !lRet

	Help( ,, 'HELP',, STR0024, 1, 0)  //"Erro na importacao do arquivo. Verifique!"
	AF385Reset()	

EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc}AF385Imp()
Importar de Arquivo Texto para Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function AF385Imp( cArquivo )
Local lRet		:= .T.
Local nX
Local nPosFil
Local nPosBem
Local nPosItem
Local nPosTip
Local nPosVlr

Local aStruct	:=	{}
Local aArea		:= GetArea()
Local aAreaAux  := FNZ->(GetArea())
Local cLinha 	:= ""
Local aCpoObrig := {}
Local nMax      := Val( Replicate( "9",TamSX3("FNZ_ITEM")[1]) )
Local nNumLin	:= 0        
Local nHandle
Local nCpo
Local nAt
Local cToken
		
Private aErros	:= {}  //esta variavel tem que ser private pq .....

_aCpos_CSV	:= {}
_aDadosCSV := {}

// Campos Obrigatorio
aAdd( aCpoObrig, "FNZ_FILIAL"	)
aAdd( aCpoObrig, "FNZ_BEM"		)
aAdd( aCpoObrig, "FNZ_ITBEM"	)
aAdd( aCpoObrig, "FNZ_TIPO" 	)
aAdd( aCpoObrig, "FNZ_VLORI1" 	)

SaveInter()

DbSelectArea("FNZ")

If At('.',cArquivo) == 0
	cArquivo	:=	AllTrim(cArquivo)+'.CSV'
EndIf

If lRet .And. (nHandle := FT_FUse(AllTrim(cArquivo)))== -1   //abertura do arquivo texto
	aAdd(aErros,STR0025+AllTrim(cArquivo)+STR0026)   //"Erro de Arquivo: "##" Não é possivel abrir arquivo"
	lRet := .F.
EndIf

If lRet

	nNumLin := FT_FLASTREC()

	If lRet .And.  nNumLin < 2
		aAdd(aErros,STR0027) //"Erro de Arquivo: Arquivo Vazio"
		lRet := .F.
	EndIf
	
	If lRet .And.  nNumLin > nMax
		aAdd(aErros,STR0025 + STR0028 + cValToChar(nMax) + STR0029 ) //"Erro de Arquivo: "##"Tamanho máximo é de "## " linhas."
		lRet := .F.
	EndIf

EndIf

//primeira linha do arquivo CSV onde esta definido os campos FNZ_FILIAL;FNZ_PROCID;FNZ_ITEM;FNZ_BEM;FNZ_ITBEM;FNZ_TIPO;etc
If lRet

	FT_FGOTOP()   
	 
	//Monta a strutura do arquivo
	clinha 	:= ft_freadln()
	nAt		:=	1
	Do While nAt > 0
		nAt	:=	AT(";",cLinha)
		If nAt > 0
			cToken	:=	Substr(cLinha,1,nAt-1)
		Else
			cToken	:=	Alltrim(cLinha)
		EndIf
		If FNZ->(FieldPos(cToken)) > 0
			AADD( _aCpos_CSV, Alltrim(Upper(cToken)) )
		Else
			lRet := .F.
			aAdd(aErros,STR0030+cValToChar (1)+" - "+ STR0031 +cToken )//"Erro de Estrutura na Linha :"##"Campos Inválido "
		EndIf
		cLinha	:=	Substr(cLinha,nAt+1)
	EndDo
	
	If Len(_aCpos_CSV) > 0
		For nX := 1 to Len(aCpoObrig)
			If aScan(_aCpos_CSV,{|x| Alltrim(x) == Alltrim(aCpoObrig[nX]) }) <= 0
				aAdd(aErros,STR0030+cValToChar (1)+" - "+ STR0032 +aCpoObrig[nX] + STR0033 )//"Erro de Estrutura na Linha :"##"Campo: "##" não está na estrutura"
				lRet := .F.
			EndIf
		Next nX
	EndIf

EndIf

If lRet
	//Leitura do arquivo CSV a partir da segunda linha
	FT_FSKIP()
	Do While !FT_FEOF()

		clinha 	:= ft_freadln()
		aAdd(_aDadosCSV,Array(Len(_aCpos_CSV)))
		nLin := Len(_aDadosCSV)

		nCpo := 1
		nAt		:=	1
		Do While nAt > 0
			nAt	:=	AT(";",cLinha)
			If nAt > 0
				cToken	:=	Substr(cLinha,1,nAt-1)
			Else
				cToken	:=	Alltrim(cLinha)
			EndIf
			_aDadosCSV[nLin][nCpo] := cToken
			cLinha	:=	Substr(cLinha,nAt+1)
			nCpo++
		EndDo
		
		FT_FSKIP()
		
	EndDo

EndIf

nPosFil 	:= aScan( _aCpos_CSV, {|x| Alltrim(x) == "FNZ_FILIAL" 	})
nPosBem 	:= aScan( _aCpos_CSV, {|x| Alltrim(x) == "FNZ_BEM" 		})
nPosItem 	:= aScan( _aCpos_CSV, {|x| Alltrim(x) == "FNZ_ITBEM"		})
nPosTip 	:= aScan( _aCpos_CSV, {|x| Alltrim(x) == "FNZ_TIPO" 		})
nPosVlr 	:= aScan( _aCpos_CSV, {|x| Alltrim(x) == "FNZ_VLORI1"	})

// valida linha para 
For nX := 1 To Len( _aDadosCSV )

	lRet := ValidLiCSV( nX, _aDadosCSV[nX], _aCpos_CSV , nPosFil, nPosBem, nPosItem, nPosTip, nPosVlr)

	If !lRet
		Exit
	EndIf

Next nX

If lRet

	_lParam := .F.

	//abre formulario inclusao de dados e carrega os dados importados
	lRet := ( FWExecView(STR0034,"ATFA385", MODEL_OPERATION_INSERT,, { || .T. } ) == 0 )  //"Inclusão por FWExecView"

	If lRet
		Help( ,, "Help",, STR0035, 1, 0 )  //"Confirmada a operação de importação de arquivo CSV."
	Else
		Help( ,, "Help",, STR0036, 1, 0 )  //"Foi cancelada a operação"
	EndIf

else

	MsgStop( STR0037+Str(nX) )  //"Erro na validacao da linha : "
	
EndIf

RestArea(aAreaAux)
RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc}ValidLiCSV()
Exportar para Arquivo o Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function ValidLiCSV( nLinha, aDados, aCpos, nPosFil, nPosBem, nPosItem, nPosTip, nPosVlr )
LOcal lRet := .T.
Local cTipo

If Len(aDados) > Len(aCpos) 
	aAdd(aErros,STR0030 + cValToChar(nLinha) + " - " + STR0038 ) //"Erro de Estrutura na Linha :"##"Estrura incorreta na linha "
	lRet := .F.	
EndIf
//Valida os campos
If aDados[nPosFil] !=  xFilial("FNZ") // cFilAnt
	aAdd(aErros, STR0030 + cValToChar(nLinha) + " - " + STR0039 ) //"Erro de Estrutura na Linha :"##"Filial inválida "
	lRet := .F.
EndIf

If lRet

	If nPosTip > 0 .And. !Empty( aDados[nPosTip] )
		cTipo := aDados[nPosTip]
	Else
		cTipo := "10"
	EndIf
	
	If SN3->( ! MsSeek(xFilial("SN3") + aDados[nPosBem] + aDados[nPosItem] + cTipo ))
		aAdd(aErros,STR0030 + cValToChar(nLinha) + " - " + STR0040 ) //"Erro de Estrutura na Linha :"##"Bem não encontrado "
		lRet := .F.
	EndIf
	
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc}AF385EXPCSV()
Exportar para Arquivo o Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function AF385EXPCSV()
Local lRet := .T.
Local aRet := {}
Local aPerg := {}

aRet := Array(2)
aRet[1] 	:= PadR( "AF_385_", 50 )
aRet[2] 	:= PadR( "\SYSTEM\", 100 )
aAdd(aPerg,{ 1,STR0041		,aRet[1],"","","","",50,	.T.})           //"Nome do arquivo"
aAdd(aPerg,{ 6,STR0018		,aRet[2],"","","",100,.T.,STR0019 + " (*.*) |*.* ", "",GETF_LOCALHARD + GETF_RETDIRECTORY }) //"Diretório de Gravação"###"Todos os arquivos (*.*) |*.*"

lRet := ParamBox(aPerg,STR0020, aRet) //"Parâmetros Exportação..."

If lRet
	If File(Alltrim(aRet[2])+Alltrim(aRet[1])+".CSV")
		MsgInfo(STR0042)  //"Arquivo ja existente no diretorio. Verifique!"
		lRet := .F.
	Else
		MsgRun( STR0043, STR0023 , {|| lRet := AF385Exp(Alltrim(aRet[2])+Alltrim(aRet[1]), FNY->FNY_PROCID ) } ) //"Processando Exportação"##"Processando ..."
	EndIf
EndIf

If !lRet
	Help( ,, 'HELP',, STR0044, 1, 0)  //"Erro na exportacao do arquivo. Verifique!"
EndIf

Return
//-------------------------------------------------------------------
/*{Protheus.doc}AF385EXPCSV()
Exportar para Arquivo o Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function AF385EXP(cArquivo, cProcId)
Local aStruct	:=	{}
Local cLin		:=	""
Local aArea		:= GetArea()
Local aAreaAux  := FNZ->(GetArea())
Local nX
Local nHandle

DbSelectArea("FNZ")

SAVEINTER()

If At('.',cArquivo) == 0
	cArquivo	:=	AllTrim(cArquivo)+'.CSV'
EndIf
If (nHandle := FCreate(cArquivo))== -1
	Alert(STR0045)  //"Erro na criacao do arquivo!"
	RestInter()
	Return .F.
EndIf

aStruct	:=FNZ->(DbStruct())
For nX:=1 To Len(aStruct)
	cLin	+=	aStruct[nX,1] + ';'
Next
cLin := Left(cLin,Len(cLin)-1)
cLin += CRLF
FWrite(nHandle,cLin,Len(cLin))

FNZ->(DbSetOrder(1)) //FNZ_FILIAL+FNZ_PROC+FNZ_ITEM
FNZ->(DbSeek(xFilial("FNZ") + cProcId ))

While  FNZ->( !Eof() .And. FNZ_FILIAL + FNZ_PROCID == xFilial("FNZ") + cProcId  )
	cLin := ""
	For nX := 1 To Len(aStruct)
		Do Case
			Case aStruct[nX,2] == "C"
				cLin +=  FieldGet(FieldPos(aStruct[nX,1])) + ';'
			Case aStruct[nX,2] == "L"
				cLin += IIf(FieldGet(FieldPos(aStruct[nX,1])),"T","F") + ';'
			Case aStruct[nX,2] == "D"
				cLin += Dtos(FieldGet(FieldPos(aStruct[nX,1]))) + ';'
			Case aStruct[nX,2] == "N"
				cLin += Str(FieldGet(FieldPos(aStruct[nX,1]))) + ';'
			Otherwise
				cLin += ';'
		EndCase
	Next
	cLin := Left(cLin,Len(cLin)-1)
	cLin += CRLF
	FWrite(nHandle,cLin,Len(cLin))
	FNZ->(DbSkip())
EndDo
RestArea(aAreaAux)

FClose(nHandle)

Aviso( STR0046 , STR0047 ,{"Ok"}) //"Finalizado"###"Exportacao gerada com sucesso" //"Ok"

RestInter()

RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc}AF385ALNOK()
Validacao LinhaOK Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function AF385ALNOK(oModel,nLine)
Local lRet := .T.
Local oGdFNY := oModel:GetModel("FNZDETAIL")

Local lTerreno := AtfChkTerreno(oModel, nLine)

Default nLine := 1

If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. ;//Incluir
	oModel:GetOperation() == MODEL_OPERATION_UPDATE //Alterar

	If _lVldLinOK
		If Empty( FWFldGet("FNZ_BEM", nLine) ) //oModel:GetValue("FNZDETAIL",nLine,"FNZ_BEM") )  //CODIGO DO BEM NAO PODE ESTAR VAZIO
			Help( ,, 'HELP',, STR0048, 1, 0)  //"Codigo do Bem nao informado."
			lRet := .F.
		ElseIf Empty( FWFldGet("FNZ_VLAJS1", nLine) ) //oModel:GetValue("FNZDETAIL",nLine,"FNZ_VLAJS1") )  //valor de ajuste na moeda 1 nao pode ser zero
			Help( ,, 'HELP',, STR0049, 1, 0)  //"Nao digitado valor na Moeda 1."
			lRet := .F.
		Else
			if !lTerreno //Somente validar taxa para bens/ativos <> terrenos
				If Empty( FWFldGet("FNZ_VLTAX1", nLine) )//oModel:GetValue("FNZDETAIL",nLine,"FNZ_VLTAX1") )  //valor de ajuste na moeda 1 taxa nao pode ser zero
					Help( ,, 'HELP',, STR0050, 1, 0)  //"Nao digitado taxa para Moeda 1."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	
ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE //Excluir
	
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc}AF385ATDOK()
Validacao TudoOk Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function AF385ATDOK(oModel)
Local nI
Local nLinAtu
Local oGdFNY := oModel:GetModel("FNZDETAIL")
Local lRet := .T.

//laco para linhas da grade
For nI := 1 To oGdFNY:Length()

	oGdFNY:GoLine( nI )
	If ! oGdFNY:IsDeleted()
	    lRet := AF385ALNOK(oModel,nI)
	    If !lRet
	    	Exit
	    EndIf
    EndIf
	
Next nI

Return(lRet)  

//-------------------------------------------------------------------
/*{Protheus.doc}AF385GATL
Retorno do Gatilho - Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function AF385GATL(nCampo, cMoeda)
Local cCampo := ""
Local nRetorno := 0 

Default nCampo := 2
Default cMoeda := "1"

If 		nCampo == 1  //valor origem (nao vai ser necessario pq ja carrega da tabela de dados)
		nRetorno := M->FNZ_VORIG1
		nRetorno := 0
		
ElseIf 	nCampo == 2  //valor ajuste
		nRetorno := M->FNZ_VLAJS1
		nRetorno := nRetorno / RecMoeda( M->FNY_DTEMIS,VAL(cMoeda) )// Converte para moeda do parametro

ElseIf 	nCampo == 3  //taxa do ajuste
		nRetorno := M->FNZ_VLTAX1  //replica para todos os campos de taxa a mesma informada na moeda 1

ElseIf 	nCampo == 4  //deprec acumul. ajuste
		nRetorno := M->FNZ_VLACM1
		nRetorno := nRetorno / RecMoeda( M->FNY_DTEMIS,VAL(cMoeda) )// Converte para moeda do parametro
EndIf
	
Return(nRetorno)

//-------------------------------------------------------------------
/*{Protheus.doc}AF385VlAj()
Validacao Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function AF385VlAj()
Local lRet := .T.
lRet := Vazio() .Or. Positivo()
Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc}AF385Memo()
Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function AF385Memo()
Local aArea := GetArea()
Local aAreaSX1 := SX1->(GetArea())
Local cRetorno := ""
Local oModel   := FWLoadModel( 'ATFA385' )

If INCLUI .And. Empty( _cArqImp )

	Pergunte("AFA385", .F.)
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	dbSeek("AFA385")
	While SX1->( !Eof() .And. X1_GRUPO == "AFA385    " )
		If 		ValType( &("MV_PAR"+SX1->X1_ORDEM) ) == "C"
				cRetorno += PadR( SX1->X1_PERGUNT, 30 ) + " : " + &("MV_PAR"+SX1->X1_ORDEM) + CRLF
		ElseIf 	ValType( &("MV_PAR"+SX1->X1_ORDEM) ) == "D"
				cRetorno += PadR( SX1->X1_PERGUNT, 30 ) + " : " + DtoC( &("MV_PAR"+SX1->X1_ORDEM) ) + CRLF
		ElseIf 	ValType( &("MV_PAR"+SX1->X1_ORDEM) ) == "N"
				cRetorno += PadR( SX1->X1_PERGUNT, 30 ) + " : " + Str( &("MV_PAR"+SX1->X1_ORDEM) ) +CRLF
		EndIf
		SX1->( dbSkip() )
	Enddo

ElseIf INCLUI .And. !Empty( _cArqImp )

	cRetorno += STR0051 + " : " + _cArqImp + CRLF  //"Importacao Arquivo para Proc. do Ajuste"

EndIf
	
RestArea(aAreaSX1)
RestArea(aArea)
Return(cRetorno)

//-------------------------------------------------------------------
/*{Protheus.doc}AF385Rot()
Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function AF385Rot()
Local cRetorno := ""
Local oModel   := FWLoadModel( 'ATFA385' )

If INCLUI .And. Empty( _cArqImp )
	
	cRetorno := "1" 
	
ElseIf INCLUI .And. !Empty( _cArqImp )

	cRetorno := "2" //importacao

EndIf
	
Return(cRetorno)

//-------------------------------------------------------------------
/*{Protheus.doc}ATFA385
Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------


Static Function AF385AGRV(oModel)

If oModel:GetOperation() == MODEL_OPERATION_INSERT //Incluir
	fwformcommit(oModel)
	If __lSX8
		ConfirmSX8()
	EndIf
	
	AF385Reset() 
	
ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE //Alterar
	fwformcommit(oModel)

	AF385Reset() 

ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE //Excluir
	fwformcommit(oModel)

	AF385Reset() 
	
EndIf

RETURN .T.
//-------------------------------------------------------------------
/*{Protheus.doc}ATFA385
Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function AF385PREVAL(oModel)
Local lRet := .T. 

If oModel:GetOperation() == MODEL_OPERATION_INSERT //Incluir
	INCLUI    := .T.
	ALTERA    := .F.
	If _lCarga
		lRet := AF385Carga(oModel) //carrega os dados na grid
		_lCarga := .F.
	EndIf

ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE //Alterar
	INCLUI    := .F.
	ALTERA    := .T.
	_lVldLinOK 	:= .T.
	
ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE //Excluir
	INCLUI    := .F.
	ALTERA    := .F.

EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc}AF385PerAut
Carrega o valor das variaveis da rotina automatica
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
/*/
//-------------------------------------------------------------------
Static Function AF385PerAut()
Local nX 		:= 0
Local cVarParam := ""

If ValType(aParamAuto) != "U"
	For nX := 1 to Len(aParamAuto)
		cVarParam := Alltrim(Upper(aParamAuto[nX][1]))
		If "MV_PAR" $ cVarParam
			&(cVarParam) := aParamAuto[nX][2]
		EndIf
	Next nX
EndIf

Return
//-------------------------------------------------------------------
/*{Protheus.doc}ATFA385
Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function AF385SelMark(oModel) 
Local nI
Local cChave
Local cArqTrab
Local cQuery
Local cAlias
Local oDlgMrk 
Local nRecTmp
Local nX
Local aStruSN1 		:= SN1->(DBSTRUCT())	//Estrutura da Tabela SN1 - Ativos
Local aColumns		:= {}
Local bOk 			:= {||((_lConfMrkBr 	:= .T., CloseBrowse()))}
Local bCancel		:= {||((_lConfMrkBr 	:= .F., CloseBrowse()))}

_cAliasQry 			:= GetNextAlias()
_cAliasMark 			:= GetNextAlias()
cArqTrab            	:= GetNextAlias()

//query para extrair dados da SN1/SN3
cQuery := AF385QrySN3(aStruSN1) 

//chave para IndRegua 
Aadd(aStruSN1, {"RECNOSN1","N",10,0})
Aadd(aStruSN1, {"RECNOSN3","N",10,0})

//copia para arquivo local a ser utilizado na MarkBrowse

If _oATFA3851 <> Nil
	_oATFA3851:Delete()
	_oATFA3851 := Nil
Endif

_oATFA3851 := FWTemporaryTable():New( cArqTrab )  
_oATFA3851:SetFields(aStruSN1) 
_oATFA3851:AddIndex("1", {"N1_FILIAL","N1_CBASE","N1_ITEM"})

//------------------
//Criação da tabela temporaria
//------------------
_oATFA3851:Create()  

DbSetOrder(0) 															

Processa( {|| nRecTmp := MySqlToTrb(cQuery, _cAliasQry, aStruSN1, cArqTrab) } )						// Copia result query para arquivo temporario

_cAliasMark := cArqTrab

//markBrowse
If nRecTmp > 0  //se tem dados para selecionar
	//----------------------------------------------------
	//Define as colunas a serem apresentadas na markbrowse
	//----------------------------------------------------
	For nX := 1 To Len(aStruSN1)
		If	aStruSN1[nX][1] $ "N1_CBASE|N1_ITEM|N1_QUANTD|N1_AQUISIC|N1_DESCRIC"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aStruSN1[nX][1]+"}") )
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruSN1[nX][1])) 
			aColumns[Len(aColumns)]:SetSize(aStruSN1[nX][3]) 
			aColumns[Len(aColumns)]:SetDecimal(aStruSN1[nX][4])
			aColumns[Len(aColumns)]:SetPicture(PesqPict("SN1",aStruSN1[nX][1])) 
		EndIf 	
	Next nX 
	//------------------------------------------
	//Criação da MarkBrowse no Layer LISTA_DAC
	//------------------------------------------
	_oMrkBrowse:= FWMarkBrowse():New()
	_oMrkBrowse:SetAlias(_cAliasMark)
	_oMrkBrowse:SetDescription(STR0053)  //"Selecao dos Bens a Ajustar"
	_oMrkBrowse:SetFieldMark("N1_OK")
	 
	_oMrkBrowse:AllMark() //marca todos os registros na markbrowse
	_oMrkBrowse:SetOwner(oDlgMrk)
	
	//marca do campo N1_OK
	_cMark := _oMrkBrowse:Mark()
	
	_oMrkBrowse:SetMenuDef("ATFA385") 
	_oMrkBrowse:bMark    := {|| AF385Mark( _cAliasMark, _cMark ) 		}
	_oMrkBrowse:bAllMark := {|| AF385Inverte( _cAliasMark, _cMark ) 	}
	
	_oMrkBrowse:SetColumns(aColumns)
		
	_oMrkBrowse:SetMenuDef("")
	_oMrkBrowse:AddButton(STR0069, bOk,, 4) //"Confirmar"
	_oMrkBrowse:AddButton(STR0070, bCancel,, 2) //"Cancelar"
		
	_oMrkBrowse:Activate()
Else
	Help(" ",1,"RECNO")
EndIf

Return(_lConfMrkBr)

//-------------------------------------------------------------------
/*{Protheus.doc}ATFA385
Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function AF385Carga(oModel)
Local oGdFNY		:= oModel:GetModel("FNZDETAIL")
Local nLinGrid 		:= 1
Local aCamposFNZ 	:= {}
Local nCtdMark      := 0
Local nX
Local nZ
Local cCampo
Local xValue		
Local nPosHead
 
//Relação de campos
aAdd(aCamposFNZ, { "FNZ_BEM"	, {|| SN1->N1_CBASE} } )
aAdd(aCamposFNZ, { "FNZ_ITBEM"	, {|| SN1->N1_ITEM } } )
aAdd(aCamposFNZ, { "FNZ_TIPO"	, {|| SN3->N3_TIPO } } )
aAdd(aCamposFNZ, { 'FNZ_VLORI1', {|| SN3->N3_VORIG1-SN3->N3_VRDACM1 } } )
aAdd(aCamposFNZ, { 'FNZ_VORIG2', {|| SN3->N3_VORIG2-SN3->N3_VRDACM2 } } )
aAdd(aCamposFNZ, { 'FNZ_VORIG3', {|| SN3->N3_VORIG3-SN3->N3_VRDACM3 } } )
aAdd(aCamposFNZ, { 'FNZ_VORIG4', {|| SN3->N3_VORIG4-SN3->N3_VRDACM4 } } )
aAdd(aCamposFNZ, { 'FNZ_VORIG5', {|| SN3->N3_VORIG5-SN3->N3_VRDACM5 } } )

_lVldLinOK := .F.

If ! Empty( _cArqImp )  //se for por importacao de arquivo

	_lConfMrkBr := .T.
	nLinGrid := 1
	
	For nZ := 1 TO Len(_aDadosCSV)

		//primeira linha nao precisa incluir pois o componente ja inclui uma linha em branco 
    	//a partir da segunda linha tenho que utilizar o addline() para os que estao marcados
		If nLinGrid > 1 
			If oGdFNY:AddLine() != nLinGrid    //SOMENTE SE NAO BATER O CONTADOR COM RETORNO DO ADDLINE = ERROR
				Help( ,, 'HELP',, 'Error insert line...Grid' + CRLF + oModel:getErrorMessage()[6], 1, 0)
				Loop
			EndIf
		EndIf
	
		//seta os valores na linha adicionada na grade 
		//ou na linha 1 adicionada ao criar objeto grid
		For nX := 1 TO Len(_aDadosCSV[nZ])

			cCampo := Alltrim(_aCpos_CSV[nX])
			
			If !( cCampo $ "FNZ_FILIAL|FNZ_PROCID|FNZ_ITEM" )
			
			 	nPosHead := Ascan( oGdFNY:aHeader, {|x| AllTrim(x[2]) == cCampo })
			 	
				If nPosHead > 0
				
					xValue := Alltrim( _aDadosCSV[nZ][nX] )
					
					If 		oGdFNY:aHeader[nPosHead, 8] == "C"  //posicao 8 eh o tipo do dado - Caracter
							xValue := PadR( xValue, oGdFNY:aHeader[nPosHead, 4] )  //posicao 4 eh o tamanho
					
					ElseIf 	oGdFNY:aHeader[nPosHead, 8] == "L"  //posicao 8 eh o tipo do dado - Logico
							xValue := If(xValue=="1", .T., .F.)
												
					ElseIf 	oGdFNY:aHeader[nPosHead, 8] == "D"  //posicao 8 eh o tipo do dado - Data
							xValue := CTOD( xValue )
					
					ElseIf 	oGdFNY:aHeader[nPosHead, 8] == "N"  //posicao 8 eh o tipo do dado - Numerico
							xValue := Val( xValue ) 
												
					Else
							xValue := CriaVar( cCampo, .T. )
					EndIf
				
					oGdFNY:LoadValue( cCampo, xValue )
					
				EndIf
				
			EndIf
			
		Next
			
		nLinGrid++		
			
	Next	

Else

	If _lConfMrkBr
		//carrega os dados na grid de acordo a selecao da markbrowse
		nLinGrid := 1  					//primeira linha em branco ja esta na grade
		(_cAliasQry)->( dbGoTop() )		//result da query e temporario para mark sao iguais
		(_cAliasMark)->( dbGoTop() )
		While (_cAliasMark)->(! Eof())  //se tem dados para selecionar
		
			//incluir na getdados modelo MVC os registros marcados 
			If _oMrkBrowse:IsMark(_cMark)
			
				nCtdMark++
				
		        //posiciona em SN1 e SN3 com os registros retorno da query
				SN1->( dbGoto( (_cAliasQry)->RECNOSN1 ) )		
				SN3->( dbGoto( (_cAliasQry)->RECNOSN3 ) )
				//primeira linha nao precisa incluir pois o componente ja inclui uma linha em branco 
		    	//a partir da segunda linha tenho que utilizar o addline() para os que estao marcados
				If nLinGrid > 1 
					If oGdFNY:AddLine() != nLinGrid    //SOMENTE SE NAO BATER O CONTADOR COM RETORNO DO ADDLINE = ERROR
						Help( ,, 'HELP',, 'Error insert line...Grid' + CRLF + oModel:getErrorMessage()[6], 1, 0)
						(_cAliasQry)->( dbSkip() )
						(_cAliasMark)->( dbSkip() )
						Loop
					EndIf
				EndIf
			
				//seta os valores na linha adicionada na grade 
				//ou na linha 1 adicionada ao criar objeto grid
				For nX := 1 TO Len(aCamposFNZ)
					oGdFNY:LoadValue( aCamposFNZ[nX,1], Eval( aCamposFNZ[nX,2] ) )
				Next
					
				nLinGrid++		
			
			EndIf
			
			(_cAliasQry)->( dbSkip() )   //o alias da query tem que andar em conjunto com markbrowse
			(_cAliasMark)->( dbSkip() )
			
		EndDo
		
	EndIf
	
	_lVldLinOK := .T.
	
	If _lConfMrkBr .And. nCtdMark == 0 //confirmei mark browse mas nao adicionei nenhuma linha na grade
		_lConfMrkBr := .F.
	EndIf
	//fecha a query
	dbSelectArea(_cAliasQry)
	dbCloseArea()
	
	//fecha arquivo da mark
	If _cAliasMark != NIL
		dbSelectArea(_cAliasMark)
		dbCloseArea()
	Else
		_lConfMrkBr := .F.
	EndIf

	//Apaga tabela temporaria no banco de dados
	If _oATFA3851 <> Nil
		_oATFA3851:Delete()
		_oATFA3851 := Nil
	Endif

EndIf
//APOS CARGA NAO PERMITE INCLUIR NOVAS LINHAS NA GRID
oGdFNY:SetNoInsertLine( .T. )

dbSelectArea("FNY")

Return(_lConfMrkBr)

//-------------------------------------------------------------------
/*{Protheus.doc}ATFA385
Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function AF385QrySN3(aStru)
Local cQuery := ""
Local cFilSN3 := xFilial("SN3")
Local nX

Local cTypes10		:= IIF(lIsRussia,AtfNValMod({1}, "|"),"") // CAZARINI - 28/03/2017 - If is Russia, add new valuations models - main models
Local aTypes10		:= {}
Local nTypes10		:= 0
Local cTypesNM		:= IIF(lIsRussia,AtfNValMod({3,4}, "|"),"") // CAZARINI - 28/03/2017 - If is Russia, add new valuations models - 17 and 16 models
Local aTypesNM		:= {}
Local nTypesNM		:= 0
cQuery += "SELECT "
For nX:= 1 to Len(aStru)
	If Alltrim(aStru[nX,1]) $ "N1_OK|N1_CBASE|N1_ITEM|N1_QUANTD|N1_AQUISIC|N1_DESCRIC"
		cQuery += Alltrim(aStru[nX,1])+", "    
	EndIf
Next
cQuery += " SN3.R_E_C_N_O_ RECNOSN3, SN1.R_E_C_N_O_ RECNOSN1 "
cQuery += " FROM "+RetSqlName("SN3")+" SN3, "+RetSqlName("SN1")+ " SN1 "
cQuery += " WHERE "
cQuery += "	     SN3.N3_FILIAL = '"+cFilSN3+"' "
cQuery += "  AND SN3.N3_CBASE BETWEEN '"+ mv_par01 +"' AND '"+ mv_par02 +"' " 
cQuery += "  AND SN3.N3_ITEM BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04 +"' " 
cQuery += "  AND SN3.N3_CUSTBEM >= '" + mv_par07  + "' "
cQuery += "  AND SN3.N3_CUSTBEM <= '" + mv_par08  + "' "
cQuery += "  AND SN3.N3_CCONTAB >= '" + mv_par09  + "' "
cQuery += "  AND SN3.N3_CCONTAB <= '" + mv_par10  + "' "
If !lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cQuery += "  AND SN3.N3_TIPO = '10' "
Else
	aTypes10 := Separa(cTypes10, '|', .f.)
		
	If len(aTypes10) = 0
		cQuery += "  AND SN3.N3_TIPO = '10' "
	Else
		cQuery += " 	AND SN3.N3_TIPO IN( '10'"
					
		For nTypes10 := 1 to len(aTypes10)
			cQuery += ",'" + aTypes10[nTypes10] + "')"
		Next nTypes10
			
		cQuery += "			) "
	Endif
Endif
cQuery += "  AND SN3.N3_BAIXA = '0' "
cQuery += "  AND SN3.D_E_L_E_T_ = ' ' 
cQuery += "  AND N3_TIPO NOT IN "
cQuery += "                 (  SELECT N3_TIPO "
cQuery += "                    FROM "+RetSqlName("SN3")+" SN3NOT " 
cQuery += "                    WHERE "

If !lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cQuery += "                    SN3NOT.N3_TIPO IN ('16','17') "
Else
	aTypesNM := Separa(cTypesNM, '|', .f.)
		
	If len(aTypesNM) = 0
		cQuery += "                SN3NOT.N3_TIPO IN ('16','17') "
	Else
		cQuery += "                SN3NOT.N3_TIPO IN ('16','17'"
					
		For nTypesNM := 1 to len(aTypesNM)
			cQuery +=              ",'" + aTypesNM[nTypesNM] + "')"
		Next nTypesNM
			
		cQuery +=                  " ) "
	Endif
Endif

cQuery += "                      AND SN3NOT.N3_CBASE = SN3.N3_CBASE "
cQuery += "                      AND SN3NOT.N3_ITEM = SN3.N3_ITEM "
cQuery += "                      AND SN3NOT.N3_BAIXA = '0' "
cQuery += "                      AND SN3NOT.D_E_L_E_T_ = ' ' "
cQuery += "                  ) "
cQuery += "  AND SN1.N1_FILIAL = '"+cFilSN3+"' "
cQuery += "  AND SN1.N1_CBASE = SN3.N3_CBASE "
cQuery += "  AND SN1.N1_ITEM = SN3.N3_ITEM "
cQuery += "  AND SN1.N1_GRUPO BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04 +"' " 
cQuery += "  AND SN1.N1_AQUISIC BETWEEN '"+ DtoS( mv_par11 )+"' AND '"+ DtoS( mv_par12 )+"' "
cQuery += "  AND SN1.D_E_L_E_T_ = ' '

Return(cQuery)
//-------------------------------------------------------------------
/*{Protheus.doc}ATFA385
Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function AF385Mark( cAliasMark, cMark )

If cMark == (cAliasMark)->N1_OK
	If (cAliasMark)->(MsRLock())
		(cAliasMark)->N1_OK := " "
	Else
		Help( ,, 'HELP',, STR0054, 1, 0)   //"Erro ao desmarcar registro."
	EndIf	
Else
	If (cAliasMark)->(MsRLock())
		(cAliasMark)->N1_OK := cMark
	Else
		Help( ,, 'HELP',, STR0055, 1, 0)  //"Erro ao marcar registro."
	EndIf	
EndIf

Return
//-------------------------------------------------------------------
/*{Protheus.doc}ATFA385
Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function AF385Inverte( cAliasMark, cMark )
Local nRecAnt := (cAliasMark)->( Recno() )

(cAliasMark)->( dbGoTop() )
While (cAliasMark)->(! Eof())  //se tem dados para selecionar
	AF385Mark( _cAliasMark, cMark )
	(cAliasMark)->( dbSkip() )
EndDo
//retornar para registro pois o _cAliasQry tem que estar no mesmo registro (andam em conjunto)
(cAliasMark)->( dbGoTo(nRecAnt) )

Return
//-------------------------------------------------------------------
/*{Protheus.doc}ATFA385
Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function MySqlToTrb( cQuery, _cAliasQry, aStruTmp, cAliasTmp )
Local nI		:= 0
Local nJ        := 0
Local nF        := 0
Local nTotalRec := 0
Local aStruQry 	:= {}

cQuery := ChangeQuery(cQuery)
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), _cAliasQry, .F., .T.)},"Aguarde..")
For nJ := 1 to Len(aStruTmp)
	If !(aStruTmp[nJ,2] $ 'CM') .And. Alltrim(aStruTmp[nJ,1]) $ "N1_OK|N1_CBASE|N1_ITEM|N1_QUANTD|N1_AQUISIC|N1_DESCRIC"
		TCSetField(_cAliasQry, aStruTmp[nJ,1], aStruTmp[nJ,2],aStruTmp[nJ,3],aStruTmp[nJ,4])
	EndIf
Next nJ

aStruQry 	:= (_cAliasQry)->(DbStruct())
nF			:= Len(aStruQry)

(_cAliasQry)->(DbGoTop())
While (_cAliasQry)->( ! Eof())

	(cAliasTmp)->(DbAppend())
	nTotalRec++
	For nI := 1 To nF
		If (cAliasTmp)->(FieldPos(aStruQry[nI,1])) > 0	 .And. aStruQry[nI,2] <> 'M'
			(cAliasTmp)->(FieldPut(FieldPos(aStruQry[nI,1]),(_cAliasQry)->(FieldGet((_cAliasQry)->(FieldPos(aStruQry[nI,1]))))))
		Endif
	Next nI
	(_cAliasQry)->(DbSkip())

End

DbSelectArea(cAliasTmp)

Return(nTotalRec)

//-------------------------------------------------------------------
/*{Protheus.doc}AF385PRE_FORM()
Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------


Static Function AF385PRE_FORM(oModel)
Local lRet := .T.

If oModel:GetOperation() == MODEL_OPERATION_INSERT //Incluir

	If _lParam
		If _lAuto //rotina automatica

			AF385PerAut()
			AF385Carga(oModel) //carrega os dados na grid
			_lParam := .F.

		Else

			lRet := pergunte("AFA385",.T.)
			lRet := lRet .And. AF385SelMark(oModel) //carrega os dados na grid 
	
			If !lRet
				Help( ,, 'HELP',, STR0036, 1, 0)  //"Operacao Cancelada."
				AF385Reset()
			Else
				_lParam := .F.
			EndIf
			
		EndIf
	EndIf

ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE //Alterar

	If FNY->FNY_STATUS == "2"
		Help( ,, 'HELP',, STR0057, 1, 0)  //"Nao permitido a operacao apos efetivacao."
		lRet := .F.
	EndIf
		
ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE //Excluir

	If FNY->FNY_STATUS == "2"
		Help( ,, 'HELP',, STR0057, 1, 0)  //"Nao permitido a operacao apos efetivacao."
		lRet := .F.
	EndIf
	
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc}AF385Reset()
Processo de Ajuste a Valor Positivo / Negativo Societario
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function AF385Reset()

//INICIALIZA VARIAVEIS STATICAS
_lAuto 			:= .F.
_lParam 		:= .T.
_lCarga 		:= .T.
_lMarkBrw 		:= .F.
_lConfMrkBr 	:= .F.
_cArqImp 		:= ""
_lVldLinOK 		:= .F.
_cAliasQry 		:= NIL
_cAliasMark 	:= NIL

If ValType(_oMrkBrowse) == "O"
	_oMrkBrowse:DeActivate()
EndIf
_oMrkBrowse 	:= NIL
_cMark			:= NIL

Return

//-------------------------------------------------------------------
/*{Protheus.doc}Atfa385_VLEF()
Processo de Ajuste a Valor Positivo / Negativo Societario
Validacao do processo para adicionar tipo 16 ou 17 por rotina automatica no ativo
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function Atfa385_VLEF()
Local lRet 		:= .T.
Local aArea 	:= GetArea()
Local aAreaSN1 	:= SN1->( GetArea() )
Local aAreaSN3 	:= SN3->( GetArea() )
Local aAreaFNZ 	:= FNZ->( GetArea() )

Local aTypeProc	:= {} // types already processed
Local cType10	:= ""
Local cType17	:= "" 
Local cType16	:= ""
Local aTypesNM	:= {}
Local lTerreno  := .F.

dbSelectArea("FNY")  //devera estar posicionado
nRecFNY := Recno()

dbSelectArea("SN3")
dbSetOrder(1)

dbSelectArea("SN1")
dbSetOrder(1)

dbSelectArea("FNZ")  	//posicionar de acordo com FNY
dbSetOrder(2)   		//"FNZ_FILIAL+FNZ_PROCID+FNZ_BEM+FNZ_ITBEM+FNZ_TPSALD",;


If dbSeek( 	xFilial("FNZ") + FNY->FNY_PROCID )

	If FNY->FNY_STATUS == "2"
		MsgInfo(STR0058)   //"Processo de ajuste ja efetivado."
		lRet := .F.
	EndIf


	While FNZ->( !Eof() .And. FNZ_FILIAL+FNZ_PROCID == xFilial("FNZ") + FNY->FNY_PROCID )

		cCodBem := FNZ->FNZ_BEM
		cItemBem := FNZ->FNZ_ITBEM
				
		If SN1->( ! dbSeek( xFilial("SN1") + FNZ->FNZ_BEM + FNZ->FNZ_ITBEM ) )
			MsgInfo(STR0059 + " " + FNZ->FNZ_BEM + FNZ->FNZ_ITBEM)  //"Nao encontrado ativo para ajuste."
			lRet := .F.
	        Exit
		EndIf
		//APOS POSICIONAR NA SN1 - VERIFICA SE Eh TERRENO
		//FICOU DEFINIDO COM PO PARA SER CONSIDERADO TERRENO E NAO VALIDAR A TAXA EM 19/05/2021.
		//VERIFICAR CAMPOS DA PASTA IMOVEIS COD RGI / LOGRADOURO IMOV / MUNICIPIO
		If !Empty(SN1->N1_CODRGI) .Or. !Empty(SN1->N1_LOGIMOV) .Or. !Empty(SN1->N1_MUNIMOV)
			lTerreno := .T.
		EndIf		
	
		//posicionar em SN3 e carregar os dados ja existentes
		If SN3->( !dbSeek( xFilial("SN3") + cCodBem + cItemBem ) )
			MsgInfo(STR0059)  //"Nao encontrado ativo para ajuste."
			lRet := .F.
	        Exit
		EndIf
		
		//posicionar em SN3 e carregar os dados ja existentes
		If SN3->( dbSeek( xFilial("SN3") + cCodBem + cItemBem + "16" ) )
			MsgInfo(STR0060)  //"Encontrado ativo com tipo 16."
			lRet := .F.
	        Exit
		EndIf
		
		//posicionar em SN3 e carregar os dados ja existentes
		If SN3->( dbSeek( xFilial("SN3") + cCodBem + cItemBem + "17" ) )
			MsgInfo(STR0061)  //"Encontrado ativo com tipo 17."
			lRet := .F.
	        Exit
		EndIf
		
		//laco na tabela SNZ para incluir os tipos 16 ou 17 do ativo de acorodo com a digitacao na grade
		While FNZ->( !Eof() .And. FNZ_FILIAL+FNZ_PROCID+FNZ_BEM+FNZ_ITBEM == xFilial("FNZ")+FNY->FNY_PROCID+cCodBem+cItemBem )

			If Empty(FNZ->FNZ_VLAJS1) 
				MsgInfo(STR0062)  //"Valor ou taxa para ajuste não digitado."
				lRet := .F.
	    	    Exit
			EndIf

			If !lTerreno   //somente se nao for terreno verifica a taxa
				If Empty(FNZ->FNZ_VLTAX1) 
					MsgInfo(STR0062)  //"Valor ou taxa para ajuste não digitado."
					lRet := .F.
					Exit
				EndIf
			EndIf

			If Empty(FNZ->FNZ_CCONTA)
				MsgInfo(STR0063)  //"Entidades contabeis obrigatoria - Conta do Bem / Desp. Depreciação / Depreciação Acumulada nao informada."
				lRet := .F.
	    	    Exit
			EndIf

			If !lTerreno   //somente se nao for terreno verifica se tem conta de depreciacao acum / desp depreciacao
				If Empty(FNZ->FNZ_CDEPRE) .OR.  Empty(FNZ->FNZ_CCDEPR)
					MsgInfo(STR0063)  //"Entidades contabeis obrigatoria - Conta do Bem / Desp. Depreciação / Depreciação Acumulada nao informada."
					lRet := .F.
					Exit
				EndIf
			EndIf

			FNZ->( dbSkip() )
		EndDo

        If ! lRet
        	Exit
        EndIf
        
		//nao avancao registro da FNZ pois ja avancou no laco FNZ_FILIAL+FNZ_PROCID+FNZ_BEM+FNZ->FNZ_ITBEM
	EndDo
	
	dbSelectArea("FNY")
	dbGoto( nRecFNY )

Else
	MsgInfo(STR0064)  //"Nao encontrado itens para ajuste."
	lRet := .F.
EndIf

RestArea(aAreaSN1)
RestArea(aAreaSN3)
RestArea(aAreaFNZ)
RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc}Atfa385_EF()
Processo de Ajuste a Valor Positivo / Negativo Societario
Efetiva processo adicionando tipo 16 ou 17 por rotina automatica no ativo
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function Atfa385_EF()
Local aCab 		:= {}
Local aItens 	:= {}
Local cTipo 	:= ""
Local nX
Local nRecFNY
Local nPos			
Local cCampo
Local nPosCpo
Local cCodBem
Local cItemBem
Local lInclAuto := .F.
Local aArea 	:= GetArea()
Local aAreaSN1 	:= SN1->( GetArea() )
Local aAreaSN3 	:= SN3->( GetArea() )
Local aAreaFNZ 	:= FNZ->( GetArea() )
Local aParam 	:= { 	{"MV_PAR01", 2}, ;   //nao mostra lancto - Nao
						{"MV_PAR02", 1}, ;	 //repete chapa - Sim
						{"MV_PAR03", 2} }    //descricao estendida - Nao
Local aTypesNM	:= {}

Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .F.
Private lAutoErrNoFile	:= .T.

dbSelectArea("FNY")  //devera estar posicionado
nRecFNY := Recno()

dbSelectArea("SN3")
dbSetOrder(1)

dbSelectArea("SN1")
dbSetOrder(1)

dbSelectArea("FNZ")  	//posicionar de acordo com FNY
dbSetOrder(2)   		//"FNZ_FILIAL+FNZ_PROCID+FNZ_BEM+FNZ_ITBEM+FNZ_TPSALD",;


If dbSeek( 	xFilial("FNZ") + FNY->FNY_PROCID )

	If _aCamposFNZ == NIL
		_aCamposFNZ := AF385CpoNZ()
	EndIf

	If _aStruSN3 == NIL
		_aStruSN3 := CarregStru("SN3")
	EndIf

	While FNZ->( !Eof() .And. FNZ_FILIAL+FNZ_PROCID == xFilial("FNZ") + FNY->FNY_PROCID )

		lInclAuto := .F.
		cCodBem := FNZ->FNZ_BEM
		cItemBem := FNZ->FNZ_ITBEM
		aCab := {}
				
		If SN1->( dbSeek( xFilial("SN1") + FNZ->FNZ_BEM + FNZ->FNZ_ITBEM ) )

			aCab := 	{ 	{'N1_FILIAL' 	,PADR(SN1->N1_FILIAL,Len(SN1->N1_FILIAL)," ") 	, NIL},; 
							{'N1_CBASE' 	,PADR(SN1->N1_CBASE,Len(SN1->N1_CBASE)," ") 	, NIL},; 
							{'N1_ITEM' 		,PADR(SN1->N1_ITEM,Len(SN1->N1_ITEM)," ") 		, NIL},; 
							{'N1_DESCRIC' 	,SN1->N1_DESCRIC 								, NIL},; 
							{'N1_CHAPA' 	,SN1->N1_CHAPA 									, NIL} } 
		Else
			dbSelectArea("FNZ")
			dbSkip()
			Loop
		EndIf
		
		aItens := {}
	
		//posicionar em SN3 e carregar os dados ja existentes
		SN3->( dbSeek( xFilial("SN3") + cCodBem + cItemBem ) )

		While SN3->( !Eof() .And. N3_FILIAL + N3_CBASE + N3_ITEM == xFilial("SN3") + cCodBem + cItemBem ) 
		
			// Array com os dados a serem enviados pela MsExecAuto() para gravacao 
			aAdd(aItens,{} )
			nPos := Len(aItens)

			For nX := 1 TO Len(_aStruSN3)
				cCampo := Alltrim(_aStruSN3[nX,2])
				nPosCpo := AF385PosNZ( "SN3", cCampo, _aCamposFNZ )
				
				If nPosCpo > 0 .OR. cCampo $ "N3_HISTOR|N3_DINDEPR|N3_SEQ"
					aAdd( aItens[nPos], { _aStruSN3[nX,2]	, &("SN3->"+_aStruSN3[nX,2])	, NIL 			} )
				EndIf
				
			Next
			
			SN3->( dbSkip() )
			
		EndDo

		//laco na tabela SNZ para incluir os tipos 16 ou 17 do ativo de acorodo com a digitacao na grade
		While FNZ->( !Eof() .And. FNZ_FILIAL+FNZ_PROCID+FNZ_BEM+FNZ_ITBEM == xFilial("FNZ")+FNY->FNY_PROCID+cCodBem+cItemBem )
			If lIsRussia .And. FNZ->FNZ_TIPO <> '10'
				aTypesNM := ATFNValNM( FNZ->FNZ_TIPO )

				If FNZ->FNZ_VLAJS1 >= FNZ->FNZ_VLORI1
					cTipo := aTypesNM[4]   // Type 16 (similar) - VALOR JUSTO POSITIVO SOCIETARIA                        
				Else
					cTipo := aTypesNM[3]   // Type 17 (similar) - VALOR JUSTO NEGATIVO SOCIETARIA                        
				EndIf		
			Else
				If FNZ->FNZ_VLAJS1 >= FNZ->FNZ_VLORI1
					cTipo := "16"   //VALOR JUSTO POSITIVO SOCIETARIA                        
				Else
					cTipo := "17"   //VALOR JUSTO NEGATIVO SOCIETARIA                        
				EndIf		
			Endif

			aAdd(aItens,{} )
			nPos := Len(aItens)

			//array com os dados a serem enviados pela MsExecAuto() para gravacao automatica do item tipo 16 ou 17
			For nX := 1 TO Len(_aStruSN3)
				cCampo := Alltrim(_aStruSN3[nX,2])
				nPosCpo := AF385PosNZ( "SN3", cCampo, _aCamposFNZ )
				
				If nPosCpo > 0 //.And. _aCamposFNZ != NIL
					If 		cCampo == "N3_TIPO"
						aAdd( aItens[nPos], { cCampo	, cTipo								, NIL 			} )
					ElseIf 	cCampo == "N3_DINDEPR"
						aAdd( aItens[nPos], { cCampo	, dDataBase							, NIL 			} )
					Else
						aAdd( aItens[nPos], { cCampo	, &("FNZ->"+_aCamposFNZ[nPosCpo,1])	, NIL 			} )
					EndIf
				EndIf
				
				//historico monta de acordo com o tipo				
				If cCampo == "N3_HISTOR"
					aAdd( aItens[nPos], { cCampo	, STR0065+If(cTipo=="16",STR0066,STR0067)+STR0068, NIL } )  //"VALOR JUSTO "##"POSITIVO"##"NEGATIVO"##" SOCIETARIO"
				EndIf
				
			Next
			
			lInclAuto := .T.
		
			FNZ->( dbSkip() )
			
		EndDo

		If lInclAuto

			MSExecAuto( {|x,y,z,p| ATFA012(x,y,z,p) }, aCab , aItens, 4, aParam ) 
		
			If lMsErroAuto
				lRetorno := .F. 
				MostraErro()
			Else
				lRetorno:=.T.
			EndIf
		
		EndIf

		//nao avancao registro da FNZ pois ja avancou no laco FNZ_FILIAL+FNZ_PROCID+FNZ_BEM+FNZ->FNZ_ITBEM
	EndDo
	
	dbSelectArea("FNY")
	dbGoto( nRecFNY )
	
	RecLock("FNY",.F.)

	FNY->FNY_DTAJST := dDataBase
	FNY->FNY_STATUS := "2"
	MsUnLock()
		
EndIf

RestArea(aAreaSN1)
RestArea(aAreaSN3)
RestArea(aAreaFNZ)
RestArea(aArea)

Return


//-------------------------------------------------------------------
/*{Protheus.doc}CarregStru
Processo de Ajuste a Valor Positivo / Negativo Societario
Monta o a Header especifico para a rotina automatica.  
@author Ramon Neves
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------
Static Function CarregStru(cAlias,aStru)
Local aAreaAnt		:= GetArea()
Local cCampoZero	:= "Zero"

Default cAlias      := "SN3"
Default aStru		:= {}

dbSelectArea("SX3")
dbSetOrder(1)
SX3->(dbSeek(cAlias))

While ! SX3->(Eof()) .And. (SX3->X3_ARQUIVO == cAlias)
	If  X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .Or.;
		Rtrim(X3_CAMPO) == "N3_SEQ" .Or. Rtrim(X3_CAMPO) == "N3_CBASE" .Or. Rtrim(X3_CAMPO) == "N3_ITEM".Or. Rtrim(X3_CAMPO) == "N3_TIPREAV" .Or. Rtrim(X3_CAMPO) == "N3_SEQREAV"
		If cAlias == "SN1"
			If Alltrim(X3_CAMPO) == "N1_CBASE" .Or. Alltrim(X3_CAMPO) == "N1_ITEM"
				AADD(aStru,{TRIM(X3TITULO()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID ,SX3->X3_USADO ,SX3->X3_TIPO ,SX3->X3_ARQUIVO ,SX3->X3_CONTEXT})
			EndIF
		Else
			// Alterado para conter parte do nome do campo "N3_VORIG" ou nome do arquivo "SN3" .Procura se o nome finaliza com numeros
			If !( SX3->X3_CAMPO $ "N3_CRIDEPR/N3_CALDEPR")
				cCampoZero := SX3->X3_ARQUIVO
				if Subs(X3_CAMPO, Len(Trim(X3_CAMPO)),1) $ "0123456789"
					cCampoZero := "Zero"
				Endif
				AADD(aStru,{TRIM(X3TITULO()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID ,SX3->X3_USADO ,SX3->X3_TIPO ,cCampoZero ,SX3->X3_CONTEXT})
			EndIf
		EndIf
	EndIf
	SX3->(dbSkip())
EndDo

RestArea(aAreaAnt)

Return aStru

//-------------------------------------------------------------------
/*{Protheus.doc}AF385CpoNZ
Processo de Ajuste a Valor Positivo / Negativo Societario
Retorna array com campos da FNZ e correspondente SN3
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function AF385CpoNZ()
Local aRet := {}

aAdd( aRet, { "FNZ_FILIAL" 	, "N3_FILIAL" 	})
aAdd( aRet, { "FNZ_PROCID"	, NIL 			})
aAdd( aRet, { "FNZ_ITEM"	, NIL 			})
aAdd( aRet, { "FNZ_BEM"		, "N3_CBASE" 	})
aAdd( aRet, { "FNZ_ITBEM"	, "N3_ITEM" 	})
aAdd( aRet, { "FNZ_TIPO"	, "N3_TIPO" 	})
aAdd( aRet, { "FNZ_VLORI1"	, NIL        	})
aAdd( aRet, { "FNZ_TPSALD"	, "N3_TPSALDO" 	})
aAdd( aRet, { "FNZ_TPDEPR"	, "N3_TPDEPR " 	})
aAdd( aRet, { "FNZ_CCONTA"	, "N3_CCONTAB" 	})
aAdd( aRet, { "FNZ_CUSTBE"	, "N3_CUSTBEM" 	})
aAdd( aRet, { "FNZ_CDEPRE"	, "N3_CDEPREC" 	})
aAdd( aRet, { "FNZ_CCUSTO"	, "N3_CCUSTO" 	})
aAdd( aRet, { "FNZ_CCDEPR"	, "N3_CCDEPR" 	})
aAdd( aRet, { "FNZ_CDESP"	, "N3_CDESP" 	})
aAdd( aRet, { "FNZ_CCORRE"	, "N3_CCORREC" 	})
aAdd( aRet, { "FNZ_VLAJS1"	, "N3_VORIG1" 	})
aAdd( aRet, { "FNZ_VLTAX1"	, "N3_TXDEPR1" 	})
aAdd( aRet, { "FNZ_VLACM1"	, "N3_VRDACM1" 	})
aAdd( aRet, { "FNZ_VORIG2"	, NIL 			})
aAdd( aRet, { "FNZ_VLAJS2"	, "N3_VORIG2" 	})
aAdd( aRet, { "FNZ_TXDEP2"	, "N3_TXDEPR2" 	})
aAdd( aRet, { "FNZ_VRDAC2"	, "N3_VRDACM2" 	})
aAdd( aRet, { "FNZ_VORIG3"	, NIL 			})
aAdd( aRet, { "FNZ_VLAJS3"	, "N3_VORIG3" 	})
aAdd( aRet, { "FNZ_TXDEP3"	, "N3_TXDEPR3" 	})
aAdd( aRet, { "FNZ_VRDAC3"	, "N3_VRDACM3" 	})
aAdd( aRet, { "FNZ_VORIG4"	, NIL 			})
aAdd( aRet, { "FNZ_VLAJS4"	, "N3_VORIG4" 	})
aAdd( aRet, { "FNZ_TXDEP4"	, "N3_TXDEPR4" 	})
aAdd( aRet, { "FNZ_VRDAC4"	, "N3_VRDACM4" 	})
aAdd( aRet, { "FNZ_VORIG5"	, NIL 			})
aAdd( aRet, { "FNZ_VLAJS5"	, "N3_VORIG5" 	})
aAdd( aRet, { "FNZ_TXDEP5"	, "N3_TXDEPR5" 	})
aAdd( aRet, { "FNZ_VRDAC5"	, "N3_VRDACM5" 	})
aAdd( aRet, { "FNZ_CCDESP"	, "N3_CCDESP" 	})
aAdd( aRet, { "FNZ_CCCDEP"	, "N3_CCCDEP" 	})
aAdd( aRet, { "FNZ_CCCDES"	, "N3_CCCDES" 	})
aAdd( aRet, { "FNZ_CCCORR"	, "N3_CCCORR" 	})
aAdd( aRet, { "FNZ_SUBCTA"	, "N3_SUBCTA" 	})
aAdd( aRet, { "FNZ_SUBCCO"	, "N3_SUBCCON" 	})
aAdd( aRet, { "FNZ_SUBCDS"	, "N3_SUBCDEP" 	})
aAdd( aRet, { "FNZ_SUBCCD"	, "N3_SUBCCDE" 	})
aAdd( aRet, { "FNZ_SUBCDE"	, "N3_SUBCDES" 	})
aAdd( aRet, { "FNZ_SUBCOR"	, "N3_SUBCCOR" 	})
aAdd( aRet, { "FNZ_CLVL"	, "N3_CLVL" 	})
aAdd( aRet, { "FNZ_CLVLCN"	, "N3_CLVLCON" 	})
aAdd( aRet, { "FNZ_CLVLDP"	, "N3_CLVLDEP" 	})
aAdd( aRet, { "FNZ_CLVLCE"	, "N3_CLVLCDE" 	})
aAdd( aRet, { "FNZ_CLVLDS"	, "N3_CLVLDES" 	})
aAdd( aRet, { "FNZ_CLVLCR"	, "N3_CLVLCOR" 	})
aAdd( aRet, { "FNZ_PERDEP"	, "N3_PERDEPR" 	})
aAdd( aRet, { "FNZ_VSALV1"	, "N3_VLSALV1" 	})
aAdd( aRet, { "FNZ_PRDANO"	, "N3_PRODANO" 	})
aAdd( aRet, { "FNZ_PRDMES"	, "N3_PRODMES" 	})
aAdd( aRet, { "FNZ_PRDACM"	, "N3_PRODACM" 	})
aAdd( aRet, { "FNZ_VMXDEP"	, "N3_VMXDEPR" 	})

Return(aRet)

//-------------------------------------------------------------------
/*{Protheus.doc}AF385PosNZ
Processo de Ajuste a Valor Positivo / Negativo Societario
Retorna posicao do campo 
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function AF385PosNZ( cAlias, cCampo, aCampos )
Local nPos 	:= 0
Local nPVet := 0

Default cAlias := "FNZ"

nPVet := If( cAlias == "FNZ", 1, 2)

nPos := aScan( aCampos, {|x| Alltrim(x[nPVet]) == Alltrim(cCampo) } )

Return(nPos)

//-------------------------------------------------------------------
/*{Protheus.doc}AF385PosNZ
Processo de Ajuste a Valor Positivo / Negativo Societario
Imprime o relatorio com processo posicionado
@author Paulo Carnelossi - Totvs
@since  21/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function AF385Print()
Local aParam := {} 

aAdd(aParam, {"MV_PAR01", FNY->FNY_PROCID	})
aAdd(aParam, {"MV_PAR02", FNY->FNY_PROCID	})
aAdd(aParam, {"MV_PAR03", FNY->FNY_DTEMIS	})
aAdd(aParam, {"MV_PAR04", FNY->FNY_DTEMIS	})
aAdd(aParam, {"MV_PAR05", 1					})
aAdd(aParam, {"MV_PAR06", 1					})
aAdd(aParam, {"MV_PAR07", 2					})
aAdd(aParam, {"MV_PAR08", 2					})

ATFR385(aParam)

Return


//-------------------------------------------------------------------
/*{Protheus.doc}AtfChkTerreno()
Utilizado na Validacao LinhaOK Processo de Ajuste a Valor Positivo / Negativo Societario para bens tipo terreno, 
sendo que neste caso a taxa de depreciacao não é requerida
@author Paulo Carnelossi - Totvs
@since  22/05/2021
@version 11.8
*/
//-------------------------------------------------------------------

Function AtfChkTerreno(oModel, nLine)
Local lTerreno   := .F.
Local cCodRGI    := ""
Local cLogrImov  := ""
Local cMunicIMov := ""
Local cCodBase   := ""
Local cItemAtf   := ""
Local aAreaSN1   := {}
Local oModFNZ    := oModel:GetModel("FNZDETAIL")

Default nLine := 1

If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. ;//Incluir
	oModel:GetOperation() == MODEL_OPERATION_UPDATE //Alterar

	cCodBase   := FWFldGet("FNZ_BEM", nLine)
	cItemAtf   := FWFldGet("FNZ_ITBEM", nLine)
	aAreaSN1   := SN1->( GetArea() )
	SN1->( dbSetOrder(1) )
	If SN1->( dbSeek( xFilial("SN1")+cCodBase+cItemAtf ) )
		//Definicao do PO para ativo tipo terreno
		//nao validar somente se nao tem conta deprecicacao acumulada / desp depreciacao pois bens que nao estao classificados podem estar em branco tb

		//FICOU DEFINIDO COM PO PARA SER CONSIDERADO TERRENO E NAO VALIDAR A TAXA EM 19/05/2021.
		//VERIFICAR CAMPOS DA PASTA IMOVEIS COD RGI / LOGRADOURO IMOV / MUNICIPIO
		//NAO PODE SER CONSIDERADO N1_CBASE = 'TERRENO'

		cCodRGI    := SN1->N1_CODRGI
		cLogrImov  := SN1->N1_LOGIMOV
		cMunicIMov := SN1->N1_MUNIMOV

		If !Empty(cCodRGI) .Or. !Empty(cLogrImov) .Or. !Empty(cMunicIMov)
			lTerreno := .T.
		EndIf
	EndIf
	RestArea(aAreaSN1)
EndIf

Return(lTerreno)