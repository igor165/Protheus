#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA300.CH" 

//------------------------------------------------------------------
/*/{Protheus.doc} FISA300

Rotina para realizar apuração de ISS para o bloco B da EFD ICMS/IPI
Esta rotina processará as informações com base no guia prático da EFD
Esta rotina não manterá o legado da apuração de ISS MATA954.

@author Erick G. Dias
@since 11/06/2019
@version 12.1.23

/*/
//------------------------------------------------------------------
Function FISA300()

	Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
	Private oBrowse
	Private oPanelBrw

    If lVerpesssen
		//Verifica se as tabelas da apuração foram criadas
		If AliasIndic("F1P")
			DbSelectArea ("F1P")
			DbSelectArea ("F1N")
			DbSelectArea ("F1O")
			DbSelectArea ("F1Q")
			DbSelectArea ("F1R")
			DbSelectArea ("F1S")
			DbSelectArea ("F1U")		
			FWExecView(STR0001,'FISA300', MODEL_OPERATION_INSERT,, { || .T. } ,{ || .T. }  ) //"Apuração de ISS"
		Else
			Alert("Dicionário desatualizado, favor verificar atualizações da apuração de ISS referente ao Bloco B da EFD ICMS/IPI.")
		EndIf
	EndIf 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Erick G. Dias
@since 11/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
 
Local aRotina := {}	

ADD OPTION aRotina TITLE STR0002  ACTION 'FSA300APU()' OPERATION 3/*MODEL_OPERATION_INSERT*/   ACCESS 0 //"Apurar"
ADD OPTION aRotina TITLE STR0003  ACTION 'FSA300VSL()' OPERATION 2/*MODEL_OPERATION_VIEW*/   ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004  ACTION 'FSA300EDT()' OPERATION 4/*MODEL_OPERATION_UPDATE*/ ACCESS 0 //"Editar"
ADD OPTION aRotina TITLE STR0005  ACTION 'FSA300TIT()' OPERATION 4/*MODEL_OPERATION_UPDATE*/ ACCESS 0 //"Gerar Títulos"
ADD OPTION aRotina TITLE STR0006  ACTION 'FSA300CON()' OPERATION 4/*MODEL_OPERATION_UPDATE*/ ACCESS 0 //"Gerar Títulos e Contabiliza"
ADD OPTION aRotina TITLE STR0007  ACTION 'FSA300SCON()' OPERATION 4/*MODEL_OPERATION_UPDATE*/ ACCESS 0 //"Contabiliza"
ADD OPTION aRotina TITLE STR0008  ACTION 'FSA300EXC()' OPERATION MODEL_OPERATION_DELETE   ACCESS 0 //"Excluir"

Return ( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author Erick G. Dias
@since 11/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStructABA := FWFormStruct( 1, 'F1P')

oModel	:=	MPFormModel():New('MODEL_ABA',,{|oModel| .T. },{|oModel| .T. })
oModel:AddFields( 'MODEL_ABA' ,, oStructABA )
oModel:SetPrimaryKey( { 'ABA_CMP1'} )
oModel:SetDescription( STR0009) //'TOTVS'

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author Erick G. Dias
@since 11/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel    := FWLoadModel( 'FISA300' )
Local oView     := FWFormView():New()
Local oStruABA   := FWFormStruct( 2, 'F1P' )

oView:SetModel( oModel )

oView:AddField( 'VIEW_ABA', oStruABA, 'MODEL_ABA' )

//Retiro o ID da view
oStruABA:RemoveField('F1P_ID')

oView:AddOtherObject( 'PANEL_TREE',  { |oPanel| MontaTree( oPanel ) } )
oView:AddOtherObject( 'PANEL_EMPTY', { |oPanel| } )
oView:AddOtherObject( 'PANEL_BROWSE',{ |oPanel| oPanelBrw := oPanel, FBrowseMon( oPanel ) } )

oView:EnableTitleView('PANEL_TREE',STR0010) //"Rotinas Disponíveis"

oView:CreateHorizontalBox( 'INFO_FUNC'	  	,00 )
oView:CreateHorizontalBox( 'EVENTO_FUNC'	,98 )
oView:CreateHorizontalBox( 'FIM_TELA'   	,02 )

oView:CreateVerticalBox( 'INFO_FUNC_ESQ'		, 100	,'INFO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_ESQ'		, 27	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_CENTER'	, 01	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_DIR'		, 72	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'FIM_TELA_EMPTY'		, 100	, 'FIM_TELA' )

oView:SetOwnerView( 'VIEW_ABA'		, 'INFO_FUNC_ESQ' )
oView:SetOwnerView( 'PANEL_TREE'	, 'EVENTO_FUNC_ESQ' )
oView:SetOwnerView( 'PANEL_EMPTY'	, 'EVENTO_FUNC_CENTER' )
oView:SetOwnerView( 'PANEL_BROWSE'	, 'EVENTO_FUNC_DIR' )
oView:SetOwnerView( 'PANEL_EMPTY'	, 'FIM_TELA_EMPTY' )

Return oView     

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaTree
Função que cria tree com as rotinas disponíveis

@author Erick G. Dias
@since 11/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
STATIC FUNCTION MontaTree(oPanel)

Local oTree
Local aCoors := FWGetDialogSize( oPanel )
Local bChange := { || FChgTree( oTree )  }
Local aNodes	:= {}
Local IMAGE1 := "FOLDER5"
Local IMAGE2 := "FOLDER6"
Local Icon	 := "PMSEDT3"

aadd(aNodes,{'00',"000","",STR0011,IMAGE1,IMAGE2}) //"Apuração de ISS (Bloco B EFD ICMS/IPI)"
aadd(aNodes,{'01',"001","",STR0012 + Space(10),Icon,Icon}) //"Apuração"
aadd(aNodes,{'01',"002","",STR0013,Icon,Icon}) //"Movimentação de Instituição Financeira"
aadd(aNodes,{'01',"003","",STR0014,Icon,Icon}) //"Cadastro Sociedade Uniprofissional"
aadd(aNodes,{'01',"004","",STR0015,Icon,Icon}) //"Cadastro de Valores Mensais de ISS Uniprofissional"
aadd(aNodes,{'01',"005","",STR0016,Icon,Icon}) //"Cadastro de Municípios"

oTree := DbTree():New( aCoors[1] + 20 ,aCoors[2] +5,aCoors[3]-10,aCoors[4]-10, oPanel,bChange , , .T. )
oTree:PTSendTree( aNodes )
oTree:CurrentNodeId := "000" 
oTree:TreeSeek("000")
oTree:PTRefresh()

Return ()

//-------------------------------------------------------------------
/*/{Protheus.doc} FChgTree 

@author Erick G. Dias
@since 11/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function FChgTree(oTree) 

Local cIdTreePos := ""

Local aInfTree := {}

//Busco a identificação de qual item da Tree estamos posicionadoss
oTree:PTRefresh()
cIdTreePos := oTree:CurrentNodeId
oPanelBrw:FreeChildren()
oBrowse:DeActivate()
aInfTree := FSA300FUNC( cIdTreePos )
FBrowseMon( oPanelBrw, aInfTree[1], aInfTree[2], aInfTree[3], aInfTree[4])
oBrowse:Refresh()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon

@author Erick G. Dias
@since 07/03/2018
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function FBrowseMon( oPanel, cFonteTree, cAliasTree, cFiltroBrw, cDescBrw )

Local cFunc 	:= "MethIsMemberOf"

Default cFonteTree := ""
Default cAliasTree := ""
Default cFiltroBrw := ""
Default cDescBrw   := ""

oBrowse := FWmBrowse():New()

If &cFunc.(oBrowse,"SetMainProc")
	oBrowse:SetMainProc(cFonteTree)
EndIf

If Empty( cFonteTree ) .And. Empty( cAliasTree ) 
	aInf := FSA300FUNC("")

	cFonteTree := aInf[1]
	cAliasTree := aInf[2]
	cFiltroBrw := aInf[3]
	cDescBrw   := aInf[4]
EndIf
If !Empty(cAliasTree)
	oBrowse:SetOwner( oPanel )
	oBrowse:SetDescription( cDescBrw )
	oBrowse:SetAlias( cAliasTree )
	oBrowse:SetMenuDef( cFonteTree )
	oBrowse:DisableDetails()
	oBrowse:SetFilterDefault( cFiltroBrw )

	oBrowse:Activate()  
EndIF

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300FUNC
Função que identifica a opção selecionada pelo usuário e abre a rotina
pertinente a opção selecionada.

@author Erick G. Dias
@since 11/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300FUNC( cIdTreePos )

Local aRet   := Array( 04 )
Do Case

	Case cIdTreePos == "001" //Apuração
		aRet[1] 	:= "FISA300"
		aRet[2] 	:= "F1P"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0012 //"Apuração"
	Case cIdTreePos == "002" //Movimentação Instituições Financeiras
		aRet[1] 	:= "FISA093"
		aRet[2] 	:= "CLL"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0017 //"Movimentação Instituições Financeiras"
	Case cIdTreePos == "003" //Sociedade Uniprofissional
        aRet[1] 	:= "FISA300D"
		aRet[2] 	:= "F1S"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0018 //"Sociedade Uniprofissional"
	Case cIdTreePos == "004" //Cadastro de Valores Mensais de ISS Uniprofissional
		aRet[1] 	:= "FISA300H"
		aRet[2] 	:= "F1U"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0015 //"Cadastro de Valores Mensais de ISS Uniprofissional"
	Case cIdTreePos == "005" //Cadastro de Município
		aRet[1] 	:= "FISA010"
		aRet[2] 	:= "CC2"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0016 //"Cadastro de Municípios"
    OtherWise
		aRet[1] 	:= ""
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	:= ""		      
EndCase

Return ( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300APU
Função para realizar apuração

@author Erick G. Dias
@since 18/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300APU()

//Chama função para realizar apuração
FSA300PROC()

//Desabilita o loop de inclusão
MbrChgLoop(.F.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300VSL
Função para realizar visualização da apuração.

@author Erick G. Dias
@since 17/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300VSL()

FISA300A("VSL")
dbSelectArea("F1P")
F1P->(dbSetOrder(2))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300EDT
Função para realizar editar apuração.

@author Erick G. Dias
@since 17/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300EDT()

FISA300A("EDT")
dbSelectArea("F1P")
F1P->(dbSetOrder(2))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300EXC
Função para realizar exclusão apuração.

@author Erick G. Dias
@since 17/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300EXC()

Local oSay	:= Nil

IF ApMsgYesNo(STR0019) //"Deseja realmente excluir a apuração selecionada?"
	
	FwMsgRun(,{|oSay| FSA300EXL(F1P->F1P_ID) },STR0020,"") //"Excluindo Apuração..."
	
EndIF

dbSelectArea("F1P")
F1P->(dbSetOrder(2))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300EXL
Função para realizar exclusão apuração.

@author Erick G. Dias
@since 26/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300EXL(cIdApur, lRefaz)

Local oApurIss 		:= APURISS():New()
Local aProcDel		:= {}
Local lProc			:= .F.
Local lTemTit		:= .F.
Local CanDelTit		:= .F.
Local lDeletou		:= .F.
Local lOk 			:= .F.

DEFAULT lRefaz := .F.

If oApurIss:loadApur(cIdApur)

	//Verifica se existem títulos gerados e se estes podem ser excluídos
	//Chamo a ProcDelTit passando opção de verificação de deleção
	aProcDel	:= ProcDelTit(oApurISS, "1")

	CanDelTit	:= aProcDel[1]
	lTemTit		:= aProcDel[4]	

	//Verifica se existem títulos a serem excluídos
	IF lTemTit
		If CanDelTit			
			//Aqui todos os títulos poderão ser deletados, exige confirmação do cliente antes prosseguir		
			lProc	:= lRefaz .Or. ApMsgYesNo( STR0021 +CHR(13) + CHR(10) + CHR(13) + CHR(10) + aProcDel[2])		 //"Deseja prosseguir com a exclusão do(s) título(s) financeiro(s)?"
		Else
			MsgAlert(STR0022 +CHR(13) + CHR(10) + CHR(13) + CHR(10) + aProcDel[3] ) //"Títulos não poderão ser excluídos!"
			lProc	:= .F.
		EndIF
	Else		
		//Se não tem título excluirá a apuração diretamente
		lProc	:= .T.
	EndIF
	
	If lProc 

		BEGIN TRANSACTION
		
		If lTemTit			
			//Deleta os títulos se houver antes de depetar a apuração			
			//Chamo a ProcDelTit passando opção de exclusão
			aProcDel	:= ProcDelTit(oApurISS, "2")
			lDeletou	:= aProcDel[1]
			
			If lDeletou 
				//Consegui deletar todos os títulos
				lOk	:= oApurIss:deleteApur()				
			Else
				//Não conseguiu deletar os títulos
				DisarmTransaction()	
			EndIF

		Else
			//Se não tem título excluirá direto a apuração
			lOk	:= oApurIss:deleteApur()

		EndIf		

		END TRANSACTION

		//Deixei as mensagens fora da transação
		If lTemTit
			//Mensagens do processamento com títulos
			If lOk
				If !lRefaz
					MsgInfo(STR0023) //"Apuração Excluída com Sucesso"
				EndIf
			ElseIf !lDeletou
				//Mensagem quando não conseguiu excluir os títulos
				Alert(STR0024 +CHR(13) + CHR(10) + CHR(13) + CHR(10) + aProcDel[3]) //"Erro ao tentar excluír os título(s) abaixo:"
			Else
				Alert(STR0025) //"Não foi possível excluir a apuração"
			EndIF

		Else
			//Mensagens do processamento sem nenhum título
			If lOk
				If !lRefaz
					MsgInfo(STR0023) //"Apuração Excluída com Sucesso"
				EndIf
			Else
				Alert(STR0025) //"Não foi possível excluir a apuração"
			EndIF

		EndIF		
		
	EndIF
EndIF

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300TIT
Função para geração dos títulos

@author Erick G. Dias
@since 19/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300TIT()

//Chamará modelo para exibir tela com os títulos a serem gerados.
FISA300F(F1P->F1P_ID, dDataBase, "1")
dbSelectArea("F1P")
F1P->(dbSetOrder(2))

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300CON
Função para geração dos títulos e contabilização

@author Erick G. Dias
@since 27/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300CON()

//Chamará modelo para exibir tela com os títulos a serem gerados.
FISA300F(F1P->F1P_ID, F1P->F1P_DTINI, "2")
dbSelectArea("F1P")
F1P->(dbSetOrder(2))

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300SCON
Função para somente contabilização dos títulos

@author Erick G. Dias
@since 27/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300SCON()

//Chamará modelo para exibir tela com os títulos a serem gerados.
FISA300F(F1P->F1P_ID, F1P->F1P_DTINI, "3")
dbSelectArea("F1P")
F1P->(dbSetOrder(2))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcDelTit
Função que verificará se os títulos podem ou não ser excluídos, retornando
a lista dos títulos para exibir quais títulos serão excluídos, ou quais
títulos não podem ser excluídos.

@author Erick G. Dias
@since 27/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function ProcDelTit(oApurISS, cOpcao)

Local aApurMun	:= {}
Local aTitulos	:= {}
Local nX		:= 0
Local nY		:= 0
Local cTitOk	:= ""
Local cTitNotOk	:= ""
Local cNumTit	:= ""
Local cChaveTit	:= ""
Local lRet		:= .T.
Local lTemTit	:= .F.
Local lExibeCon	:= .F.

//Obtem a informação se deseja exibir a contabilização
Pergunte("FISA300F",.F.)

lExibeCon	:= MV_PAR01 == 1

//Faz carga dos valores por município
aApurMun := oApurISS:getApurMun()

//Laço nos municípios
For nX  := 1 to Len(aApurMun)

	//Obtenho a lista de títulos gerados para o município
	aTitulos    := aApurMun[nX]:getTitulos()

	//Laço nos títulos
	For nY:= 1 to Len(aTitulos)
		
		//Verifico se o título foi gerado
		If aTitulos[nY]:getStatus() $ "2/3"
			//Monto a chave do título da SE2 para utiliza o primeiro índice da tabela
			cChaveTit	:= xFilial("SE2") + ;
						aTitulos[nY]:getPrefixo() + ;
						aTitulos[nY]:getNumTit() + ;
						aTitulos[nY]:getParcela() + ;
						aTitulos[nY]:getTipo() + ;
						aTitulos[nY]:getFornec() + ;
						aTitulos[nY]:getLoja()

			//Verifico se posso deletar
			If DelTit(cChaveTit, cOpcao, @cNumTit, aTitulos[nY]:getStatus()=="3", lExibeCon)
				//Montar lista de títulos por tributo que podem ser excluídos
				cTitOk += cNumTit + CHR(13) + CHR(10)
			Else
				//Montar lista de títulos por tributo que NÂO podem ser excluídos
				cTitNotOk += cNumTit + CHR(13) + CHR(10)
				lRet	:= .F.
			EndIF
			
			lTemTit	:= .T.
		
		EndIf

	Next nY //Próximo título do município

Next nX //Próximo município

Return {lRet, cTitOk, cTitNotOk,lTemTit}
 
//-------------------------------------------------------------------
/*/{Protheus.doc} DelTit
Funçãoq que faz verificação de título pode ou não ser deletadp bem como
sua deleção

@author Erick G. Dias
@since 27/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function DelTit(cChaveTit, cOpcao, cNumTit, lContabilz, lExibeCon)

Local lRet 			:= .F.
Local aArea 		:= GetArea()
Local cOrigem		:= "FISA300"
Local cCodLp		:= "751"

//Posiciono o título
If !Empty(cChaveTit) .And.  SE2->(MsSeek(cChaveTit))

	//Verifico se posso deletar
	If cOpcao == "1"				
		lRet := FaCanDelCP("SE2", cOrigem, .F.)
		cNumTit := SE2->E2_NUM + "/" + SE2->E2_PREFIXO

	//Exclusão do título
	ElseIf cOpcao == "2"		
		
		cNumTit := SE2->E2_NUM + "/" + SE2->E2_PREFIXO
		
		//Faz contabolização do título excluído caso tenha sido contabilizado
    	If lContabilz
			FSA300TCONT(cCodLp, SE2->(RECNO()), lExibeCon)
		EndIF

		RecLock("SE2",.F.)
		SE2->(dbDelete())
		FaAvalSE2(2, cOrigem)
		FaAvalSE2(3, cOrigem)
		MsUnLock()
		lRet	:= .T.

	EndIF	
EndIF

RestArea(aArea)

Return lRet

//------------------------------------------------------------
/*/{Protheus.doc} FSA300TCONT

Função que realiza a FSA300TCONTação do título

@author Erick G. Dias
@since 27/06/2019
@version 12.1.23
/*/
//------------------------------------------------------------------
Function FSA300TCONT(cCodLP, nRecnoTit, lExibeCon)
  
Local cLoteCtb		:= ''
Local cArqCtb		:= ''
Local cAuxCod		:= ''
Local nHdlPrv		:= 0
Local nTotalCtb		:= 0
local lCtbOnLine	:= .F.
Local aCT5			:= {}

// Verifica o numero do lote contabil.³
dbSelectArea("SX5")
dbSetOrder(1)
If MsSeek(xFilial()+"09FIS")
	cLoteCtb := AllTrim(X5Descri())
Else
	cLoteCtb := "FIS "
EndIf		

// Executa um execblock
If At(UPPER("EXEC"),X5Descri()) > 0
	cLoteCtb := &(X5Descri())
EndIf				

//Inicializa o arquivo de Contabacao
nHdlPrv := HeadProva(cLoteCtb,"FISA300",Subs(cUsuario,7,6),@cArqCtb)
IF nHdlPrv <= 0
	HELP(" ",1,"SEM_LANC")
	lCtbOnLine := .F.
EndIf

Begin Transaction
	
	//Contabacao dos Lancamentos de ISS
	nTotalCtb += DetProva(nHdlPrv,cCodLP,"FISA300",cLoteCtb,,,,,@cAuxCod,@aCT5,,,{"SE2",nRecnoTit})

	RodaProva(nHdlPrv,nTotalCtb)
	If nTotalCtb > 0
		cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lExibeCon,.F.)
	EndIf
	
End Transaction

Return (nTotalCtb > 0)

//------------------------------------------------------------
/*/{Protheus.doc} FSA300LEG

Função que receberá status e retornara a legenda

@author Erick G. Dias
@since 27/06/2019
@version 12.1.23
/*/
//------------------------------------------------------------------
Function FSA300LEG(cStatus)

Local cRet := ""

If cStatus == "1"
	//Apurado
	cRet	:= "BR_VERMELHO"
ElseIf cStatus == "2"
	//Tìtulo gerado
	cRet	:= "BR_VERDE"
ElseIf cStatus == "3"
	//Título gerado e contabilizado
	cRet	:= "BR_AZUL"
ElseIf cStatus == "4"
	//Títulos/Contabilização Parcial
	cRet	:= "BR_AMARELO"
EndIF

Return cRet
