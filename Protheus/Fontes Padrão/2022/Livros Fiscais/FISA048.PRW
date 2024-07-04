#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA048.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA048
Rotina de Demais Documentos - Pis e Cofins

@author Luccas Curcio
@since 24/09/2012
@version 1.0

/*/

//-------------------------------------------------------------------
Function FISA048()

//Verifica se o dicionario e a base de dados precisam de ajustes
If AjustaCF8()
	FISA048A()
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA048A
Rotina de Demais Documentos - Pis e Cofins
	
@author Luccas Curcio
@since 24/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FISA048A()
Local aCoors	:=	FWGetDialogSize( oMainWnd )
Local oPanelUp, oFWLayer, oPanelDown, oBrowseUp, oBrowseDown, oRelacCF0

Private oDlgPrinc
Private lCtbOn		:= .F. 
Private lAglut 		:= .F. 
Private lDigita 		:= .F.
Private cCredPis 	:= ""
Private cCredCof 	:= ""
Private cDebPis  	:= ""
Private cDebCof  	:= ""

Pergunte("FISA048",.F.)

lCtbOn		:= MV_PAR01==1
lAglut 	:= MV_PAR02==1
lDigita 	:= MV_PAR03==1

cCredPis 	:= MV_PAR04
cCredCof 	:= MV_PAR05
cDebPis  	:= MV_PAR06
cDebCof  	:= MV_PAR07


DEFINE MSDIALOG oDlgPrinc TITLE STR0001 FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4] PIXEL //"Demais Documentos PIS COFINS"

oFWLayer	:=	FWLayer():New()
oFWLayer:Init(oDlgPrinc, .F., .T.)

oFWLayer:AddLine('UP', 60, .F.)
oFWLayer:AddCollumn('ALLUP', 100, .T., 'UP')
oPanelUp	:=	oFWLayer:GetColPanel('ALLUP', 'UP')

oFWLayer:AddLine('DOWN', 40, .F.)
oFWLayer:AddCollumn('ALLDOWN', 100, .T., 'DOWN')
oPanelDown	:=	oFWLayer:GetColPanel('ALLDOWN', 'DOWN')

oBrowseUp	:=	FWMBrowse():New()
oBrowseUp:SetOwner(oPanelUp)
oBrowseUp:SetDescription(STR0001)//"Demais Documentos PIS COFINS"
oBrowseUp:SetAlias("CF8")
oBrowseUp:SetMenuDef("FISA048")
oBrowseUp:DisableDetails()
oBrowseUp:SetProfileID( '1' )
oBrowseUp:ForceQuitButton()
oBrowseUp:Activate()

oBrowseDown	:=	FWMBrowse():New()
oBrowseDown:SetOwner(oPanelDown)
oBrowseDown:SetDescription("Movimentação Demais Documentos")//"Movimentacao Demais Documentos"
oBrowseDown:SetMenuDef('')
oBrowseDown:DisableDetails()
oBrowseDown:SetAlias("CF0")
oBrowseDown:SetProfileID( '2' )
oBrowseDown:Activate()

oRelacCF0	:=	FWBrwRelation():New()
oRelacCF0:AddRelation (oBrowseUp, oBrowseDown, { {"CF0_FILIAL","CF8_FILIAL"}, {"CF0_CODIGO","CF8_CODIGO"} } )
oRelacCF0:Activate()

Activate MsDialog oDlgPrinc Center

Return
	
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return FWMVCMenu - Opcoes de menu

@author Gustavo G. Rueda
@since 24/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

aFuncao := { { "" , "Contab048",  "1" }}
aRotina	:=	Menu048( "FISA048" ,aFuncao)

Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Luccas Curcio
@since 24/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStruCab := FWFormStruct(1, "CF8")
Local oStruIte := FWFormStruct(1, "CF0")
Local cFunction := "MethIsMemberOf"  

oModel	:=	MPFormModel():New('FISA048',,{ |oModel| PosCtbModel() }, { |oModel| FWFORMCOMMIT(oModel), PosCtbModel(.T.) } )

If FindFunction(cFunction)
	If &cFunction.(oStruCab, "SETNOSUM")
		oStruCab:SetNoSum({"CF8_ALQPIS", "CF8_ALQCOF"})
	EndIf
EndIf

oModel:AddFields( 'MODEL_CF8' ,, oStruCab )
oModel:AddGrid( 'MODEL_CF0', 'MODEL_CF8', oStruIte, , {|oModel| PosValGrid(oModel)} )	
oModel:SetRelation('MODEL_CF0',{{"CF0_FILIAL",'xFilial("CF0")'},{"CF0_CODIGO","CF8_CODIGO"}},CF0->(IndexKey(1)))
oModel:SetPrimaryKey({"CF8_FILIAL","CF8_CODIGO"})		
oModel:SetDescription(STR0001)//"Demais Documentos PIS COFINS"
//Validação para consistir a informação do campo CF8_CLIFOR que pode ser cliente ou fornecedor.
oStruCab:SetProperty('CF8_CLIFOR' , MODEL_FIELD_VALID, {||( VldCliFor('CF8_PART',  'MODEL_CF8'))})
oModel:GetModel( 'MODEL_CF8' ):SetDescription(STR0001)//"Demais Documentos PIS COFINS"
oModel:GetModel( 'MODEL_CF0' ):SetDescription("Movimentação Demais Documentos")//"Movimentacao Demais Documentos"
oModel:GetModel( 'MODEL_CF0' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_CF0' ):SetUniqueLine( { 'CF0_SEQ' } )

Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Luccas Curcio
@since 24/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local	oModel		:=	FWLoadModel( "FISA048" )
Local	oStruCab	:=	FWFormStruct(2, "CF8")
Local	oStruIte	:=	FWFormStruct(2, "CF0")
Local	oView

oView	:=	FWFormView():New()
oView:SetModel(oModel)
oView:AddField( 'VIEW_CF8', oStruCab, 'MODEL_CF8')
oView:AddGrid( 'VIEW_CF0', oStruIte, 'MODEL_CF0' )
oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )
oView:SetOwnerView( 'VIEW_CF8', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CF0', 'INFERIOR' )
oView:EnableTitleView( 'VIEW_CF0', "Movimentação Demais Documentos" )	//"Movimentação Demais Documentos"

//Consulta F3
oStruCab:SetProperty( 'CF8_CLIFOR' , MVC_VIEW_LOOKUP  , { || A048ChgF3("CF8_INDOPE",'MODEL_CF8') } )

//Incrementa campo
oView:AddIncrementField( 'VIEW_CF0', 'CF0_SEQ' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A048ChgF3
Funcao utilizada para trocar a consulta F3 em momento de execucao dependendo
da opcao informada

@param 	cCmpF3 - Nomde do campo para fazer a validacao, o conteudo eh retornado pela classe GetValue( cModel , cCmpF3 )
		cModel - Id do modelo para passar na funcao GetValue( cModel , cCmpF3 )
		
@return cF3 - Retorna o nome da consulta F3 a ser utilizada
			
@author Luccas Curcio
@since 24/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A048ChgF3 (cCmpF3,cModel)
Local	oModel	:= 	FWModelActive()
Local	cF3		:=	""
Local	cGet	:=	oModel:GetValue( cModel , cCmpF3 )
Local lPart	:= CF8->(FieldPos("CF8_PART")) > 0
Local cPart	:= ""

If lPart
	cPart:=oModel:GetValue(cModel,'CF8_PART')
EndiF 

If lPart .AND. !Empty(cPart)
	IF cPart == "1"
		cF3			:=	"CF8A1"	
	ElseIF cpart == "2"
		cF3			:=	"CF8A2"	
	EndIF	
Else
	If cGet == "0"
		cF3			:=	"CF8A2"
	Else
		cF3			:=	"CF8A1"
	Endif	
EndIF 

Return cF3

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaCF8
Funcao utilizada para verificar o dicionario e base de dados referente a tabela CF8

@return lRet - Retorna valor boleano
				.T. - Dicionario OK, prossegue com a rotina
				.F. - Dicionario com inconsistencias, apresetna mensagem e aborta rotina
			
@author Luccas Curcio
@since 24/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AjustaCF8()
Local	lRet	:=	.T.
Local	cMsgm	:=	""

DbSelectArea("CF8")
If CF8->(FieldPos("CF8_CODIGO")) == 0

	cMsgm	:=	"A estrutura da tabela CF8 está fora do necessário para manutenção da mesma."
	cMsgm	+=	CRLF+"Por gentileza execute o compatibilizador U_UPDSIGAFIS para que o Dicionário e a base de dados sejam atualizados."
	Alert(cMsgm)
	lRet	:=	.F.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PosValGrid
Funcao utilizada na troca de linhas do grid, para validar as informacoes de cada linha

@param  oModel  - Modelo de dados a ser processado
		
@return lRet - Retorna valor boleano
				.T. - Informacoes da linha OK
				.F. - Informacoes da linha com problemas, apresenta Help do problema
			
@author Luccas Curcio
@since 24/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PosValGrid(oModel)
Local	lRet		:=	.T.
Local	nVlrOper	:=	0
Local	nVlrBase	:=	0	
Local	nRecOper	:=	0
Local	nRecBase	:=	0	
Local	nX			:=	0
Local	oModelCF8	:=	oModel:GetModel('MODEL_CF8')
Local	dDataEmi	:=	oModelCF8:GetValue('MODEL_CF8','CF8_DTOPER')

nVlrOper	:=	oModelCF8:GetValue('MODEL_CF8','CF8_VLOPER')
nVlrBase	:=	oModelCF8:GetValue('MODEL_CF8','CF8_BASPIS')

For nX := 1 To oModel:Length()

	oModel:GoLine( nX )
	
	If !oModel:IsDeleted()	//Nao considera linhas deletadas
	
		If oModel:GetValue ('CF0_DATA') < dDataEmi
			Help(,,"A048DTABX",,"A Data do Recebimento não pode ser anterior a Data de Emissão do Documento",1,0)//"O Valor da Baixa não pode ser maior que o Valor Total"
			lRet	:= 	.F.
			Exit
		Endif 
        	
		nRecOper	+=	oModel:GetValue ('CF0_RECVLR')
		nRecBase	+=	oModel:GetValue ('CF0_RECBAS')	
		
		If nRecOper > nVlrOper
			Help(,,"A048VLREC",,"O Valor de Recebimentos não pode ser maior que o Valor de Operação do Documento",1,0)//"O Valor da Baixa não pode ser maior que o Valor Total"
			lRet	:= 	.F.
			Exit
		Endif
		
		If nRecBase > nVlrBase
			Help(,,"A048VLBAS",,"O Valor Total de Recebimento da Base de Cálculo não pode ser maior que o Valor da Base de Cálculo da Operação",1,0)//"O Valor da Baixa não pode ser maior que o Valor Total"
			lRet	:= 	.F.
			Exit
		Endif
		
	Endif
	
Next nX

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} PosCtbModel
Funcao utilizada para validar o modelo de dados

@return lRet - Retorna valor boleano
				.T. - Informacoes do modelo OK
				.F. - Informacoes do modelo com problemas, apresenta Help do problema
			
@author Luccas Curcio
@since 24/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PosCtbModel(lSave)
	Local	oModel			:=	FWModelActive()
	Local	oModelCF8		:=	oModel:GetModel('MODEL_CF8')
	Local	oModelCF0		:=	oModel:GetModel('MODEL_CF0')
	Local	lRet			:=	.T.
	Local 	nOperation		:=	oModel:GetOperation()
	Local	nX				:=	0
	Local	nTotRec		:=	0
	Local	nSaldo			:=	0
	Local	cCodigo		:=	oModelCF8:GetValue('CF8_CODIGO' )

	Local cLoteCtb  		:= ""
	Local cArqCtb   		:= ""
	Local nTotalCtb 		:= 0
	Local aCT5      	:= {}
	Local bCtbOnLine		:= {||.T.}
	Local cFunName		:= FunName()

	Local lCtbOn			:= .F.
	Local lAglut 			:= .F.
	Local lDigita 		:= .F.

	Local cCodLan			:= ""

	Local aMVF100Lp     :=Separa("609|6A9","|")
	Local lEditfor		:= .F.
	Local nEstor			:= 1
	Local nA				:= 0
	Default lSave			:= .F.



	Pergunte("FISA048",.F.)

	lCtbOn		:= MV_PAR01==1 //VerPadrao("652")
	lAglut 	:= MV_PAR02==1
	lDigita 	:= MV_PAR03==1

	Begin Transaction
		If (nOperation == 5 .OR. nOperation == 4) .And. !lSave 

			If CF0->(MsSeek(xFilial("CF8")+cCodigo))
				If cFunName == "FISA048"
					If MsgYesNo("Você possui movimentação de baixa para este documento. Deseja excluir todas as movimentações?","Atenção!")
						Do While !CF0->(Eof()) .And. CF0->(CF0_FILIAL+CF0_CODIGO) == xFilial("CF8")+cCodigo
							RecLock("CF0",.F.)
							CF0->(DbDelete())
							MsUnLock()
							CF0->(DbSkip())
						Enddo
					Else
						Help(,,"A048MOVBX",,"Existem movimentações de baixa para este documento. Você deve deletá-las antes de prosseguir com a exclusão do documento",1,0)//"O Valor da Baixa não pode ser maior que o Valor Total"
						lRet	:= 	.F.
					Endif
				Else
					Do While !CF0->(Eof()) .And. CF0->(CF0_FILIAL+CF0_CODIGO) == xFilial("CF8")+cCodigo
						RecLock("CF0",.F.)
						CF0->(DbDelete())
						MsUnLock()
						CF0->(DbSkip())
					Enddo
				EndIf
			Endif
			If Len(aMVF100Lp) >= 2
				cCodLan := aMVF100Lp[2]
			EndIF
			ElseIf lSave .And. !(nOperation == 5)
			If Len(aMVF100Lp) >= 1
				cCodLan := aMVF100Lp[1]
			EndIF
		Else

			For nX := 1 To oModelCF0:Length()
				oModelCF0:GoLine( nX )
				If !oModelCF0:IsDeleted()	//Nao considera linhas deletadas
					nTotRec	+=	oModelCF0:GetValue('CF0_RECVLR')
				Endif
			Next nX

			nSaldo	:=	oModelCF8:GetValue('CF8_BASPIS') - nTotRec
			
		Endif

		If lRet
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Prepara a contabilizacao On-Line                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCtbOn .And. !Empty(cCodLan)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o numero do lote contabil                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SX5")
					dbSetOrder(1)
					If MsSeek(xFilial("SX5")+"09FIS")
						cLoteCtb := AllTrim(X5Descri())
					Else
						cLoteCtb := "FIS "
					EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa um execblock                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If At(UPPER("EXEC"),X5Descri()) > 0
						cLoteCtb := &(X5Descri())
					EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa o arquivo de contabilizacao                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nHdlPrv:=HeadProva(cLoteCtb,"FISA048",Subs(cUsuario,7,6),@cArqCtb)
					IF nHdlPrv <= 0
						HELP(" ",1,"SEM_LANC")
						lCtbOn := .F.
					EndIf
					If lCtbOn
						nTotalCtb += DetProva(nHdlPrv,cCodLan,"FISA048",cLoteCtb)
					EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia os dados para o modulo contabil                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lCtbOn
						RodaProva(nHdlPrv,nTotalCtb)
						If nTotalCtb > 0
							cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglut)
						EndIf
					EndIf
			
				EndIf
			
		Endif
	End Transaction
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A048Trg
Funcao utilizada nos Gatilhos

@return nValor- Retorna o Valor de retorno para o gatilho.

@author Luccas Curcio
@since 09/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function A048Trg(nX)
Local	cCmpM	:=	ReadVar()
Local 	cCmp	:= 	SubStr( cCmpM , 4 )
Local	cStrAux	:=	""
Local	nValor	:=	0

If cCmp $ "CF8_VLOPER"
	cStrAux	:=	'FWFLDGET("CF8_VLOPER")'

Elseif cCmp $ "CF8_ALQPIS|CF8_BASPIS" 
	cStrAux	:=	'Round(( FWFLDGET("CF8_ALQPIS") * FWFLDGET("CF8_BASPIS") ) / 100,2) '
	
Elseif cCmp $ "CF8_ALQCOF|CF8_BASCOF"
	cStrAux	:=	'Round(( FWFLDGET("CF8_ALQCOF") * FWFLDGET("CF8_BASCOF") ) / 100,2)'
	
Elseif cCmp $ "CF8_TPREG"
	
	If nX == 1 //Gatilho para CF8_ALQPIS
		cStrAux	:=	'Iif ( FWFLDGET("CF8_TPREG") == "1", 0.65, 1.65 )
		
	Else //Gatilho para CF8_ALQCOF
		cStrAux	:=	'Iif ( FWFLDGET("CF8_TPREG") == "1", 3, 7.6 )
	
	Endif
Endif

nValor	:=	&( cStrAux )

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Mensagem Unica

@return aRet

@author Fabio V. Santana
@since 23/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage, cVersion)

Local aRet

// Chama a rotina que trata a parte principal
aRet := FISI048( cXML, nTypeTrans, cTypeMessage, cVersion )
//
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Menu048
Funcao responsavel por retornar o MENU
					
@param 	cMenu   - Nome da Rotina
        aFuncao - Array com rotinas adicionais. Posicoes do Array:
                  1 - C - Titulo da Rotina (Caso nao esteja disponibilizado no TAFXFUN)
                  2 - C - Nome da Funcao a ser executada
                  3 - C - Titulo da rotina (Disponibilizado no TAFXFUN)
        lMenPadrao - Indica se deve caregar os botões padrões do Menu

@return	aRotina - Array com as opcoes de MENU

@author Fabio V. Santana
@since 04/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function Menu048( cMenu , aFuncao, lMenPadrao )
Local aRotina := {} 	
Local nI      := 0
Local nCont   := 8 //Parametro nOpc do aRotina

Default aFuncao := {}
Default lMenPadrao := .T.

If lMenPadrao
	aRotina := FwMVCMenu( cMenu )
EndIf      

If !Empty(aFuncao)

	For nI := 1 to Len(aFuncao)

		If Len(aFuncao[nI]) > 2
			If aFuncao[nI,3] == "1"
				aFuncao[nI,1] := "Contabiliza On-Line"				
			EndIf
		EndIf

		aAdd( aRotina, { aFuncao[nI,1], aFuncao[nI,2], 0, nCont, 0, Nil } )

		nCont += 1
	Next nI
EndIf

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} Contab048
Funcao responsavel por retornar as perguntas da contabilização On-line
					
@param 	
@return	Opcoes escolhidas

@author Fabio V. Santana
@since 04/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Contab048()	

Pergunte("FISA048",.T.)

lCtbOn		:= MV_PAR01==1
lAglut 	:= MV_PAR02==1
lDigita 	:= MV_PAR03==1

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} VldCliFor
Funcao responsavel pela validação do campo CF8_CLIFOR
					
@author Vogas Júnior
@since 26/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldCliFor( cCmpPart, cModel )

Local oModel	:= FWModelActive()
Local cGet		:= oModel:GetValue( cModel, cCmpPart )
Local cPart		:= oModel:GetValue( cModel,'CF8_CLIFOR')
Local lRetorno 	:= .T. 

If !Empty( cPart )
	IF cGet == '1'
		lRetorno := ExistCpo( 'SA1', cPart )
	ElseIF cGet == '2'
		lRetorno := ExistCpo( 'SA2', cPart )	
	EndIF	
EndIF 

Return lRetorno 