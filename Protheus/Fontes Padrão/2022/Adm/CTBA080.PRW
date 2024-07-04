#INCLUDE "CTBA080.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
Function CTBA080() - ALTERADA - para utilizar o mvc
Static Function BrowseDef() - CRIADA - para o  mvc
Static Function MenuDef() - CRIADA - para o  mvc
Static Function ModelDef() - CRIADA - para o  mvc
Static Function ViewDef() - CRIADA - para o  mvc
Function Ctba080Rot(cAlias,nReg,nOpc) - REMOVIDA - agora operacoes (inclui/altera/remove) sao pelo mvc
Function Ctba080Ok(oModel) - EVENTO - criada funcao para validacao de gravacao
Function CTBA080Pre(oModel) -  EVENTO - criada funcao para validacao de exclusao
Function CTBA080Grv(oModel) - EVENTO - criada funcao para gravacao da CWM
Function CTB080CDB() - MANTER - valid CT5_MOEDA
Function Ctb080Form() - MANTER - f3 diversos campos da CT5 e uso externo
STATIC FUNCTION ChecErro(e) - REMOVIDA - usada apenas em um trecho
Function Ctb080CC() - MANTER - valid CT5_CCD/CT5_CCC
Static Function ParAnalise(cTexto) - MANTER - utilizado para analista formuala digitada
Function CTBA080Sb() - REMOVER - colocado MV direto no WHEN dos campos CT5_SBLOTE/CVK_SBLOTE
Function Ctba080Sel(oModel) - ALTERADA - ajustada para mvc gravando pelo model
Function CtbAjusCT5() - REMOVER - desde 2013 esta colocando 1 no CT5_STATUS
Function CTB93CWK() - MANTER - f3 de diversos campos da CT5 (acredito que poderiam ser colocadas no f3 de cada campo)
Static Function CTB93CON(cConsul) - MANTER - utilizado pela CTB93CWK
Function CTBA080FOR() - MANTER - f3 de diversos campos da CT5
Static Function obtFormula(cGrupo,aFormula) - MANTER - utilizada pela CTBA080FOR
Function CTB93VCA() - MANTER - valid de diversos campos da CT5

Ajustado:
CTBXLOAD - removido CtbAjusCT5
RUP_CTB - colocado folder 2 para entidades adicionais
CTBA910 - criacao das entidades adicionais com folder 2

Dicionário:
CT5_MLTSLD - colocado como usado
CT5_SBLOTE - alterado o when para Empty(SuperGetMv("MV_SUBLOTE"))
CVK_SBLOTE - alterado o when para Empty(SuperGetMv("MV_SUBLOTE"))

Problemas:
Problema ao selecionar multipls saldos (nao grava sem alterar um campo)
Problema ao excluir um lançamento que foi usado no RH (a janela aparece diversas vezes)
Ajustar o campo do when CT5_SBLOTE/CVK_SBLOTE no pacote

Teste:
adicionar novos lançamentos diversos
excluir alguns lançamentos
alterar lançamentos
*/


Function CTBA080()
    Local oBrowse

	Local aLegenda	:= {}
	Private Valor 	:= 0
	Private Valor2	:= 0
	Private Valor3	:= 0
	Private Valor4	:= 0
	Private Valor5	:= 0
	Private Valor6	:= 0
	Private Valor7	:= 0
	Private Valor8	:= 0
	Private cConCWK	:= "" 
	Private cCWKCFor:= "" 
	Private VlrInStr := 0

	Private cVarOutMod := "" 											// Identifica as variaveis nao disponiveis dependendo do modulo
	Private cTpSaldos  := "" 											// Armazena os tipos de saldos selecionados pelo usuario
	Private lMltSld    := .F.

	//---------------------
	// Carga da tabela CVA
	//--------------------- 
	ChkCVA()

	//---------------------------------------------------------
	// Tratamento quanto ao modelo da tela que o usuario usara
	//---------------------------------------------------------
	Pergunte( "CTB086", .F. )	

	SetKey( VK_F12,{|| Pergunte('CTB086',.T.)})

	// chama inclusão por arvore
	If mv_par01 == 1
		If Lower(Subs(acbrowse,3,3))=="xxx"  //verifica se usuario tem acesso a inclusao/alteracao/exclusao senao entra na mbrowse
			Ctba086()
			Return
		EndIf
	EndIf


	If nModulo # 34		// Variaveis contabeis
		cVarOutMod := "LERSTR(,LERVAL(,LERDATA,"
	Endif

	If nModulo # 6	.and. nModulo # 34	// Variaveis do financeiro (6) e contabeis (34)
		cVarOutMod += "REGVALOR,STRLCTPAD,NUMCHEQUE,ORIGCHEQ,CHIST190LA,DDATAUSER,CODFORCP,LOJFORCP"
	Endif

	// Variaveis utilizadas na contabilizacao do modulo SigaFin
	// declarada neste ponto, caso o acesso seja feito via SigaAdv
	Debito  	:= ""
	Credito 	:= ""
	CustoD		:= ""
	CustoC		:= ""
	ItemD 		:= ""
	ItemC 		:= ""
	CLVLD		:= ""
	CLVLC		:= ""
	EC05DB		:= ""
	EC05CR		:= ""
	EC06DB		:= ""
	EC06CR		:= ""
	EC07DB		:= ""
	EC07CR		:= ""
	EC08DB		:= ""
	EC08CR		:= ""
	EC09DB		:= ""
	EC09CR		:= ""

	Conta		:= ""
	Custo 		:= ""	
	Historico 	:= ""
	ITEM		:= ""
	CLVL		:= ""

	IOF			:= 0
	SEST		:= 0

	Abatimento  := 0
	REGVALOR    := 0
	STRLCTPAD 	:= ""		//para contabilizar o historico do cheque
	NUMCHEQUE 	:= ""		//para contabilizar o numero do cheque
	ORIGCHEQ  	:= ""		//para contabilizar o Origem do cheque
	CODFORCP  	:= ""		//para contabilizar o Codigo do Fornecedor da Compensacao
	LOJFORCP 	:= ""		//para contabilizar o Loja Fornecedor da Compensacao
	cHist190La 	:= ""
	Variacao	:= 0
	dDataUser	:= MsDate()
	VALORMF		:= 0
	VALLIQ		:= 0

	//Não apagar variaveis utilizadas para a contabilização na integração TIN X PROTHEUS
	__nTINVCTB	:= 0
	__cTINHCTB	:= ""

	// Variaveis utilizadas na contabilizacao do modulo SigaAtf
	CTABEM		:= ""
	DESPDEPR	:= ""
	DEPREACUM	:= ""
	CORREDEPR	:= ""
	CORREBEM	:= ""
	Custo 		:= ""	

	// Variaveis para contabilizacao Centro de custo, item e classe de valor
	CUSTBEMCTB	:= ""
	CCCORRCTB	:= ""
	CCDESPCTB	:= ""
	CCCDESCTB	:= ""
	CCCDEPCTB	:= ""

	SUBCCONCTB	:= ""
	SUBCCORCTB	:= ""
	SUBCDESCTB	:= ""
	SUBCDEPCTB	:= ""
	SUBCCDECTB	:= ""

	CLVLCONCTB	:= ""
	CLVLCORCTB	:= ""
	CLVLDESCTB	:= ""
	CLVLDEPCTB	:= ""
	CLVLCDECTB	:= ""

	// Variaveis para contabilizacao Template de Gestão de Empreendimentos Imobiliários
	TPLNUM    	:= ""
	TPLDTCM   	:= CTOD("  /  /  ")
	TPLBCMP 	:= 0
	TPLBCMJ 	:= 0
	TPLCMP    	:= 0
	TPLCMJ    	:= 0
	TPLCMCUS	:= 0
	TPLCMRES    := 0

	//variaveis para contabilizacao aquisicao por transferencia LP 835/836 (ATFA251)
	nValorOr := 0
	nValorDp := 0
	nValorCo := 0
	nValorCd := 0
	nValBxOr := 0
	nValBxDp := 0
	nValBxCo := 0
	nValBxCd := 0
	//SOMENTE LP835
	nGValorOr := 0
	nGValorDp := 0
	nGValorCo := 0
	nGValorCd := 0

	FINVARCTB()

	oBrowse := BrowseDef()
	oBrowse:Activate()
Return NIL


//-------------------------------------------------------------------
Static Function BrowseDef()
	oBrowse := FWMBrowse():New()

    oBrowse:SetAlias("CT5")
    oBrowse:SetDescription(STR0006) //"Cadastro Lançamentos Padronizados"   | Se utiliza la etiquea correcta.

	oBrowse:AddLegend("CT5_STATUS=='1' .OR. Empty( CT5_STATUS )"	,"GREEN"	,STR0039) //"Ativo"
	oBrowse:AddLegend("CT5_STATUS=='2'"								,"RED"		,STR0040) //"Inativo"
Return oBrowse


//-------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.CTBA080" OPERATION 2 ACCESS 0 //"Visualizar" 
    ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.CTBA080" OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CTBA080" OPERATION 4 ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.CTBA080" OPERATION 5 ACCESS 0 //"Excluir"
    ADD OPTION aRotina TITLE STR0051 ACTION "VIEWDEF.CTBA080" OPERATION 9 ACCESS 0 //"COPIAR"
	
	ADD OPTION aRotina TITLE STR0052 ACTION "Ct080CarLP()"    OPERATION 3 ACCESS 0 //"Carga LP500...599"
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
    Local oStru  := FWFormStruct(1, "CT5", /*bSX3*/, /*lViewUsado*/)
	Local oModel := Nil

	oModel := MPFormModel():New("CTBA080",{|oModel| CTB080Ver(oModel)} /*bPre*/,{|oModel| CTBA080Pos(oModel)}/*bPos*/)

    oModel:AddFields("CT5MASTER", /*cOwner*/, oStru)
    oModel:SetDescription(STR0046) //"Cadastro de Lancamento padrão"   
    oModel:GetModel("CT5MASTER"):SetDescription(STR0046) //"Cadastro de Lancamento padrão"   
	oModel:GetModel("CT5MASTER"):SetFldNoCopy({"CT5_LANPAD","CT5_SEQUEN"})

	oModel:InstallEvent("CTBA080EVOK", /*cOwner*/, CTBA080EVOK():New())
Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
    Local oView  := Nil
	Local oStru  := FWFormStruct(2, "CT5")
    Local oModel := FWLoadModel("CTBA080")
	Local nI

    oView := FWFormView():New()
	oView:SetCloseOnOk({||.T.})

	oStru:RemoveField("CT5_MLTSLD")
	oView:AddUserButton(STR0010, "", {||Ctba080Sel(oModel)}, /*cToolTip*/, /*nShortCut*/, /*aOperation*/)

	oView:SetModel(oModel)
	oView:AddField("VIEW_CT5", oStru, "CT5MASTER")

	oView:CreateHorizontalBox("TELA", 100)
	oView:SetOwnerView("VIEW_CT5", "TELA")

Return oView


//-------------------------------------------------------------------------
/*/{Protheus.doc} CTB080CDB
Verifica se alguma das moedas é tem opcao diferente de 1,2 ou 3.

Ex1:
13211 - valido pois todos estão entre 1 e 3

Ex2:
13241 - errado pois a posicao 4 possui o numero diferente de 1,2 ou 3

Chamada a partir da CT5_MOEDA

@type function
@author Daniel Fonseca de Lira
@since 20/07/2017
@version P12.1.18

@return logico, indica se á validação passou ou não
/*/
//-------------------------------------------------------------------------
Function CTB080CDB()
	Local nCont , lRet:=.T.
	For nCont:=1 TO Len(Trim(M->CT5_MOEDAS))
		IF !SubStr(M->CT5_MOEDAS,nCont,1) $ "123"
			lRet := .F.
			Help(" ",1,"CT5_MOEDAS")
			Exit
		EndIF
	Next
Return lRet


//-------------------------------------------------------------------------
/*/{Protheus.doc} Ctb080Form
Apresenta a tala de F3 de diversos campos do alias CT5 e rotinas externas

@type function
@author Pilar S. Albaladejo
@since 17/11/1999
@version P12.1.18

@return logico, indica se á validação passou ou não
/*/
//-------------------------------------------------------------------------
Function Ctb080Form()
	Local xResult
	Local cRedVar  := ReadVar()
	Local cForm := &( cRedVar )
	Local lRet := .T. 
	Local aRetSyntax := {}
	Local cLine := "" 
	Local lExec := .T.
	Local lTxt := .F.
	Local cOutMod := ""
	Local lOptimize := GetNewPar( "MV_OPTNFE", .F. ) .OR. GetNewPar( "MV_OPTNFS", .F. )
	Local bBlock
	Local nPos := 0
	Local aAreaAnt := {}
	Local lFormula := .F.
    Local cMsg          := ""
    Local lFilter       := .F.

	//Se o valor informado existir na tabela do campo correspondente, então não valida como fórmula
	If cRedVar == "M->CT5_DEBITO" .OR. cRedVar == "M->CT5_CREDIT"
		aAreaAnt := CT1->( GetArea() )
		CT1->( dbSetOrder(1) )
		If CT1->( !MsSeek( FWxFilial("CT1") + AllTrim(cForm) ) )
			lFormula := .T.
		Endif
		CT1->( RestArea(aAreaAnt) )	
	ElseIf cRedVar == "M->CT5_CCD" .OR. cRedVar == "M->CT5_CCC"
		aAreaAnt := CTT->( GetArea() )
		CTT->( dbSetOrder(1) )
		If CTT->( !MsSeek( FWxFilial("CTT") + AllTrim(cForm) ) )
			lFormula := .T.
		Endif
		CTT->( RestArea(aAreaAnt) )
	ElseIf cRedVar == "M->CT5_ITEMD" .OR. cRedVar == "M->CT5_ITEMC"
		aAreaAnt := CTD->( GetArea() )
		CTD->( dbSetOrder(1) )
		If CTD->( !MsSeek( FWxFilial("CTD") + AllTrim(cForm) ) )
			lFormula := .T.
		Endif
		CTD->( RestArea(aAreaAnt) )
	ElseIf cRedVar == "M->CT5_CLVLDB" .OR. cRedVar == "M->CT5_CLVLCR"
		aAreaAnt := CTH->( GetArea() )
		CTH->( dbSetOrder(1) )
		If CTH->( !MsSeek( FWxFilial("CTH") + AllTrim(cForm) ) )
			lFormula := .T.
		Endif
		CTH->( RestArea(aAreaAnt) )
	Else
		lFormula := .T.
	Endif

	If lFormula
		cVarOutMod := If( Type("cVarOutMod") == "U", "", cVarOutMod )	// Prever chamadas externas
		cOutMod := cVarOutMod + If( Right( cVarOutMod, 1 ) == ",", "", "," )
		
		While !Empty( cOutMod )	// Verifico se existe digitada alguma variavel nao disponivel
			If Left( cOutMod, At(",", cOutMod) - 1 ) $ Upper( cForm ) // no modulo
				Help( " ", 1, "ERR_FORM", , STR0008 + Left( cOutMod, At( ",", cOutMod ) - 1 ) + STR0009, 3, 1 ) //"Variavel ", " nao disponivel para este modulo"
				lRet := .F.
				Exit		
			Endif
			cOutMod := Subs( cOutMod, At(",", cOutMod) + 1 )
		EndDo
		
		If lRet
			aRetSyntax := ParAnalise( cForm )	// Análise estrutural de sintaxe
			
			IF !Empty( aRetSyntax[1] )
				Help( " ", 1, "ERR_FORM", , OemToAnsi( STR0007 + aRetSyntax[1] ), 3, 0) // Estrutura Inconsistente : 
				lRet := .F.
			Endif
			
			If lRet
				For nPos := 1 to Len( aRetSyntax[2] )
					cLine	:= Upper( aRetSyntax[2][nPos] )
					
					If ( lTxt := ( "LERSTR" $ cLine .OR. "LERVAL" $ cLine .OR. "LERDATA" $ cLine ) ) .AND. M->CT5_LANPAD > "499"
						Help(" ",1,"CA010TXT")
						lRet := .F.
						Exit
					ElseIf "M->" $ Upper( cLine )
						lExec := .F.		
					Endif
					
					If "EXECBLOCK" $ cLine .OR. lTxt
						// Nao executa execblock nem Funcoes da leitura de Txt no cadastramento
						lExec := .F.
					EndIf
					
					If lOptimize .AND. ( "CTBANFS" $ cForm .OR. "CTBANFE" $ cForm )
						lExec := .F.
					EndIf
				Next nPos
				
				/*
				Retirada a função A370VerFor() na validação do cadastro de um lançamento padrão. 
				Onde a mesma estava ocasionando a não conformidade no prosseguimento do cadastro:
				"Improper Function Use"
				*/
				If lRet .AND. lExec
					bBlock := ErrorBlock( { |e| Help(" ",1,"ERR_FORM",,e:Description,3,1) } )
					BEGIN SEQUENCE
                        If IsInCallStack("CTBA080") 
                             /*
                            Função de  validação de expressoes fazem parte da syntax ADVPL
                            Essa função consideras os seguintes criterios para validar a expressão:
                            - Ser uma expressão ADVPL Valida
                            @param cExp Expressão a ser avaliada
                            @param cMsg Variavel que deve-se passar por referencia caso deseja-se saber o erro encontrado na expressao
                            @param lFilter Se .T. Suporta expressoes de filtro que extendem a ADVPL (Default .F.)
                            @return lOk .T. se a expressão é valida e se encaixa nos criterios 
                            */
						    xResult := ChkAdvplSyntax(cForm,@cMsg,lFilter)
                        Else 
                             xResult := &cForm
                        EndIf
					RECOVER
						lRet := .F.
					END SEQUENCE
					ErrorBlock(bBlock)
				Endif	
			Endif
		Endif
	Endif
Return lRet


//-------------------------------------------------------------------------
/*/{Protheus.doc} Ctb080CC
Verifica se as entidas de conta e centro de custo são diferentes

@type function
@author Pilar S. Albaladejo
@since 17/11/1999
@version P12.1.18

@return logico, retorna verdadeiro caso seja diferentes
/*/
//-------------------------------------------------------------------------
Function Ctb080CC()
	Local lRet := .T.
	If !Empty(M->CT5_CCC) .And. !Empty(M->CT5_CCD)
		If (M->CT5_CCC == M->CT5_CCD) .And. (M->CT5_DEBITO == M->CT5_CREDITO)
			Help(" ",1,"I5_IGUAIS")
			lRet := .F.
		Endif
	EndIf
Return lRet


//-------------------------------------------------------------------------
/*/{Protheus.doc} ParAnalise
Realiza análise estrutural de parâmetros / delimitadores

@type function
@author Júlio Wittwer
@since 17/12/1999
@version P12.1.18

@param caracteres, expressao advpl a ser validada

@return array, [1] indica qual caracter na estrutura não está coerente
@return array, [2] textos correspondentes dentro das estruturas
/*/
//-------------------------------------------------------------------------
Static Function ParAnalise(cTexto)
	Local cStack:=""  , cAspas:=""
	Local aSepFunc:={"()","[]","{}"}, aParam:={}
	Local nPosAt:=1 , uLastPar:=1 , cPosAtual
	Local uAbre , uFecha , cSeparador:=","

	// Arranca os caracteres da esquerda se forem 'espa‡o' ou 'TAB'
	While left(cTexto,1)==" " .or. left(cTexto,1)==chr(9)
		cTexto:=right(cTexto,len(cTexto)-1)
	EndDo

	While nPosAt<=len(cTexto)
		cPosAtual:=substr(cTexto,nPosAt,1)

		If cPosAtual==chr(34) .or. cPosAtual==chr(39)	// Achou "ASPAS"
				cAspas:=If(empty(cAspas),cPosAtual,If(cAspas == cPosAtual,"",cAspas))
		Endif

		If empty(cAspas)			// Apenas analiza a estrutura caso nao esteja entre aspas
			uAbre :=ascan(aSepFunc,{|_v|  left(_v,1) == cPosAtual})
			uFecha:=ascan(aSepFunc,{|_v| right(_v,1) == cPosAtual})
			If uAbre+uFecha>0		// Abriu ou Fechou uma estrutura
				If uAbre>0	// Abriu uma estrutura ! Acrescenta no STACK
					If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
					aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
					Endif
					uLastPar:=nPosAt+1	 ; cStack:=cStack+cPosAtual
				Else			// Fechou uma estrutura : Checa o STACK
					If right(cStack,1)==Left(aSepFunc[uFecha],1)	// Se fechou certo, tira do Stack
					cStack:=left(cStack,len(cStack)-1)
						Else	// Estrutura fechada incorretamente
							cStack:=right(aSepFunc[uFecha],1)
							EXIT
					Endif
					If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
					aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
					Endif
					uLastPar:=nPosAt+1
				Endif
			Else	// Verifica separador
					If cPosAtual==cSeparador
					aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
					uLastPar:=nPosAt+1
				Endif
			Endif
		Endif

		nPosAt++
	EndDo

	IF !empty(cTexto) .and. len(aParam) == 0
		aadd(aParam,alltrim(cTexto))
	Endif

	cStack+=if(empty(cAspas),"",cAspas)
Return {cStack,aParam}


//-------------------------------------------------------------------------
/*/{Protheus.doc} Ctba080Sel
Funcao para tratamento da multipla selecao do tipo de saldo.

@type function
@author TOTVS
@since 02/10/2008
@version P12.1.18

@param objeto, modelo de dados

@return logico, indica se a gravacao foi realizada
/*/
//-------------------------------------------------------------------------
Function Ctba080Sel(oModel)
   // Não precisa tratar multiplos saldos aqui pois esta rotina só será executada caso exista o
   // campo de multiplos saldos CT5_MLTSLD
	Local aArea		:= GetArea()
	Local aTpSaldo 	:= {}
	Local nInc		:= 0
	Local cSaldos	:= ""
	Local cPreSel	:= ""
	Local cTpSald   := FWFldGet("CT5_TPSALD")
	Local cMltSld   := FWFldGet("CT5_MLTSLD")
	Local lVisual   := .F.

	If oModel:GetOperation() == MODEL_OPERATION_VIEW .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE
		lVisual := .T.
	EndIf
	
	cPreSel := cMltSld
	If cTpSald # cPreSel
		cPreSel	+= ";" + cTpSald
	EndIf

	aTpSaldo := CtbTpSld( cPreSel, ";", lVisual )
	For nInc := 1 To Len( aTpSaldo )
		cSaldos += aTpSaldo[ nInc ]
		If nInc < Len( aTpSaldo )
			cSaldos += ";"
		EndIf
	Next

	If !lVisual
		cTpSaldos := cSaldos
		oModel:GetModel("CT5MASTER"):SetValue("CT5_MLTSLD", cTpSaldos)
	EndIf

	RestArea( aArea )
Return NIL


//-------------------------------------------------------------------------
/*/{Protheus.doc} CTB93CWK
Define las consultas a ejecutar dependiendo el campo que solicito en la 
consulta, (Cuenta contable Centro de Costo, Ítems Contables, Clase Valor)

usado f3: CT5_DEBITO/CT5_CREDIT/CT5_CCD/CT5_CCC/CT5_ITEMD/CT5_ITEMC/
          CT5_CLVLDB/CT5_CLVLCR 	

@type function
@author Alfredo Medrano
@since 13/01/2014
@version P12.1.18

@return logico, indica se o processo está válido
/*/
//-------------------------------------------------------------------------
Function CTB93CWK()
	Local cRedVar	:= ReadVar() //obtiene nombre de campo
	Local cConsult	:= ""
	Local cRet		:= ""
	Local aArea		:= GetArea()
	Local lRet 		:= .T.

	cConCWK := ""

	If cRedVar != NIL

		DbSelectArea("CT1")
		DbSelectArea("CTT")
		DbSelectArea("CTD")
		DbSelectArea("CTH")

		CT1->(DbSetOrder(1)) //CT1_FILIAL+CT1_CONTA
		CTT->(DbSetOrder(1)) //CTT_FILIAL+CTT_CUSTO
		CTD->(DbSetOrder(1)) //CTD_FILIAL+CTD_ITEM
		CTH->(DbSetOrder(1)) //CTH_FILIAL+CTH_ITEM

		DO CASE
			CASE cRedVar == "M->CT5_DEBITO" //Cuenta contable			
				cConsult := OemToAnsi(STR0029) //"1=Cuenta contable"
				cRet := CTB93CON(cConsult)
				If cRet == "1"
					CT1->(DbSeek(xFilial("CT1")+M->CT5_DEBITO))
					If CONPAD1(,,,"CT1")
						cConCWK := CT1->CT1_CONTA
					Else
						lRet := .F.
					Endif
				ElseIf cRet == "2"
					CONPAD1(,,,"CTB931")
					cConCWK := cCWKCFor
				EndIF
				
			CASE cRedVar == "M->CT5_CREDIT" 
				cConsult := OemToAnsi(STR0029) //"1=Cuenta contable"
				cRet := CTB93CON(cConsult)
				If cRet == "1"
					CT1->(DbSeek(xFilial("CT1")+M->CT5_CREDIT))
					If CONPAD1(,,,"CT1")
						cConCWK := CT1->CT1_CONTA
					Else
						lRet := .F.
					Endif
				ElseIf cRet == "2"
					CONPAD1(,,,"CTB931")
					cConCWK := cCWKCFor
				EndIF
			
			CASE cRedVar == "M->CT5_CCD" //Centro de Costo			
				cConsult := OemToAnsi(STR0030) //"1=Centro de Costo"
				cRet := CTB93CON(cConsult)
				If cRet == "1" 
					CTT->(DbSeek(xFilial("CTT")+M->CT5_CCD))
					If CONPAD1(,,,"CTT")
						cConCWK := CTT->CTT_CUSTO
					Else
						lRet := .F.
					Endif
				ElseIf cRet == "2"
					CONPAD1(,,,"CTB931") 
					cConCWK := cCWKCFor
				EndIF

			CASE cRedVar == "M->CT5_CCC"
				cConsult := OemToAnsi(STR0030) //"1=Centro de Costo"
				cRet := CTB93CON(cConsult)
				If cRet == "1" 
					CTT->(DbSeek(xFilial("CTT")+M->CT5_CCC))				
					If CONPAD1(,,,"CTT")
						cConCWK := CTT->CTT_CUSTO
					Else
						lRet := .F.
					Endif
				ElseIf cRet == "2"
					CONPAD1(,,,"CTB931") 
					cConCWK := cCWKCFor
				EndIF
			
			CASE cRedVar == "M->CT5_ITEMD"//Ítems Contables			
				cConsult := OemToAnsi(STR0031) //"1=Ítems Contables"
				cRet 	 := CTB93CON(cConsult)
				If cRet == "1" 
					CTD->(DbSeek(xFilial("CTD")+StrTran(AllTrim(M->CT5_ITEMD),'"','')))
					If CONPAD1(,,,"CTD")
						cConCWK := CTD->CTD_ITEM
					Else
						lRet := .F.
					Endif
				ElseIf cRet == "2"
					CONPAD1(,,,"CTB931") 
					cConCWK := cCWKCFor 
				EndIF
				
			CASE cRedVar == "M->CT5_ITEMC"
				cConsult := OemToAnsi(STR0031) //"1=Ítems Contables"
				cRet 	 := CTB93CON(cConsult)
				If cRet == "1" 
					CTD->(DbSeek(xFilial("CTD")+StrTran(AllTrim(M->CT5_ITEMC),'"','')))
					If CONPAD1(,,,"CTD")
						cConCWK := CTD->CTD_ITEM
					Else
						lRet := .F.
					Endif
				ElseIf cRet == "2"
					CONPAD1(,,,"CTB931") 
					cConCWK := cCWKCFor 
				EndIF

			CASE cRedVar == "M->CT5_CLVLDB" //Clase Valor			
				cConsult := OemToAnsi(STR0032) //"1=Clase Valor"
				cRet 	 := CTB93CON(cConsult)
				If cRet == "1" 
					CTH->(DbSeek(xFilial("CTH")+StrTran(AllTrim(M->CT5_CLVLDB),'"','')))
					If CONPAD1(,,,"CTH")
						cConCWK := CTH->CTH_CLVL
					Else
						lRet := .F.
					Endif
				ElseIf cRet == "2"
					CONPAD1(,,,"CTB931") 
					cConCWK := cCWKCFor 
				EndIF			

			CASE cRedVar == "M->CT5_CLVLCR"
				cConsult := OemToAnsi(STR0032) //"1=Clase Valor"
				cRet 	 := CTB93CON(cConsult)
				If cRet == "1"
					CTH->(DbSeek(xFilial("CTH")+StrTran(AllTrim(M->CT5_CLVLCR),'"','')))
					If CONPAD1(,,,"CTH")
						cConCWK := CTH->CTH_CLVL
					Else
						lRet := .F.
					Endif
				ElseIf cRet == "2"
					CONPAD1(,,,"CTB931") 
					cConCWK := cCWKCFor 
				EndIF
		ENDCASE

		//Quando for visualização
		If !INCLUI .AND. !ALTERA
			If cRedVar == "CT5->CT5_DEBITO" //Plano de Contas
				If CT1->(DbSeek(xFilial("CT1")+CT5->CT5_DEBITO))
					CONPAD1(,,,"CT1")
				Else
					CONPAD1(,,,"CTB931")
				Endif

			Elseif cRedVar == "CT5->CT5_CREDIT"
				If CT1->(DbSeek(xFilial("CT1")+CT5->CT5_CREDIT))
					CONPAD1(,,,"CT1")
				Else
					CONPAD1(,,,"CTB931")
				Endif

			Elseif cRedVar == "CT5->CT5_CCD" //Centro de Custo
				If CTT->(DbSeek(xFilial("CTT")+CT5->CT5_CCD))
					CONPAD1(,,,"CTT")
				Else
					CONPAD1(,,,"CTB931") 
				Endif

			Elseif cRedVar == "CT5->CT5_CCC"
				If CTT->(DbSeek(xFilial("CTT")+CT5->CT5_CCC))
					CONPAD1(,,,"CTT")
				Else
					CONPAD1(,,,"CTB931") 
				Endif

			Elseif cRedVar == "CT5->CT5_ITEMD" //Item Contábil
				If CTD->(DbSeek(xFilial("CTD")+StrTran(AllTrim(CT5->CT5_ITEMD),'"','')))
					CONPAD1(,,,"CTD")
				Else
					CONPAD1(,,,"CTB931")
				Endif

			Elseif cRedVar == "CT5->CT5_ITEMC"
				If CTD->(DbSeek(xFilial("CTD")+StrTran(AllTrim(CT5->CT5_ITEMC),'"','')))
					CONPAD1(,,,"CTD")
				Else
					CONPAD1(,,,"CTB931")
				Endif

			Elseif cRedVar == "CT5->CT5_CLVLDB" //Clase de Valor
				If CTH->(DbSeek(xFilial("CTH")+StrTran(AllTrim(CT5->CT5_CLVLDB),'"','')))
					CONPAD1(,,,"CTH")
				Else
					CONPAD1(,,,"CTB931")
				Endif	

			Elseif cRedVar == "CT5->CT5_CLVLCR"
				If CTH->(DbSeek(xFilial("CTH")+StrTran(AllTrim(CT5->CT5_CLVLCR),'"','')))
					CONPAD1(,,,"CTH")
				Else
					CONPAD1(,,,"CTB931")
				Endif
			Endif
		Endif

		If cRet == ""
			lRet := .F.
		Endif
	Endif

	RestArea(aArea)
Return lRet


//-------------------------------------------------------------------------
/*/{Protheus.doc} CTB93CON
Prepara el cuadro de dialogo para acceder a las consultas: Cuenta contable, 
Centro de Costo, Ítems Contables, Clase Valor Ó Formulas

@type function
@author Alfredo Medrano
@since 13/01/2014
@version P12.1.18

@return caracter, combo tipo
/*/
//-------------------------------------------------------------------------
Static Function CTB93CON(cConsul)
	Local cValor  := ""
	Local oDlg 
	Local oBtnOk 
	Local oBtnCa
	Local oCmbTip
	Local aArea		:= getArea()
	Local cCmbTip	:= ""	 
	Local aFunc		:= {}
	Default	 cConsul:= ""

	// llena los items del Combo
	aFunc := {cConsul,OemToAnsi(STR0033)} //"2=Formula"

	//Crea el cuadro de dialogo 
	DEFINE MSDIALOG oDlg FROM 0,0 TO 150,250 PIXEL TITLE OemToAnsi(STR0034) //"Seleccione el Tipo de Dato "
		oCmbTip:= tComboBox():New(18,18,{|u|if(PCount()>0,cCmbTip:=u,cCmbTip)},aFunc ,90,20,oDlg,,/*{||bloc}*/,,,,.T.,,,,,,,,,'cCmbTip')  // ComboBox Tipos
		oBtnOk	:=tButton():New(55,55,OemToAnsi(STR0021),oDlg,{|| ( cCmbTip := cCmbTip, oDlg:End()  )} ,30,12,,,,.T.) //  Ok
		oBtnCa	:=tButton():New(55,90,OemToAnsi(STR0022),oDlg,{||( cCmbTip := "",oDlg:End() )},30,12,,,,.T.)  // Anular
	ACTIVATE MSDIALOG oDlg CENTERED

	RestArea(aArea)
Return cCmbTip


//-------------------------------------------------------------------------
/*/{Protheus.doc} CTBA080FOR
Prepara el cuadro de dialogo para la consulta de Formula

Usado f3 CT5_DEBITO/CT5_CREDIT/CT5_VLR01/CT5_VLR02/CT5_VLR03/CT5_VLR04/
        CT5_VLR05/CT5_HIST/CT5_HAGLUT/CT5_CCD/CT5_CCC/CT5_ORIGEM/CT5_ITEMD/
		CT5_ITEMC/CT5_CLVLDB/CT5_CLVLCR/CT5_MOEFDB/CT5_MOEFCR/CT5_CODCLI/
		CT5_CODFOR/CT5_DIACTB/CVK_VLR02/CVK_VLR04 

@type function
@author Alfredo Medrano
@since 14/01/2014
@version P12.1.18

@return logico, Sempre .T.
/*/
//-------------------------------------------------------------------------
Function CTBA080FOR()
	Local oDlg 
	Local oBtnOk 
	Local oBtnCa
	Local oCmbFor
	Local oGetHlp
	Local cCmbFor	:= ""
	Local cGetHlp	:= ""
	Local cTabla 	:= "CZ"
	Local cGrupo	:= space(TamSX3("CWK_GRUPO")[1])
	Local iSX5     	:= RETORDEM("SX5","X5_FILIAL+X5_TABELA+X5_CHAVE") 
	Local iCWK     	:= RETORDEM("CWK","CWK_FILIAL+CWK_CODFOR") 
	Local aArea		:= getArea() 
	Local aFormula	:= {}
		
	//Crea el cuadro de dialogo 
	DEFINE MSDIALOG oDlg FROM 0,0 TO 380,410 PIXEL TITLE OemToAnsi(STR0015) + '- ' +OemToAnsi(STR0016) // Consulta Estándar - Formulas

	oSay	:= tSay():New(10,10,{||OemToAnsi(STR0017)},oDlg,,,,,,.T.) 			// Grupo
	@ 18,10   MSGET	cGrupo	  SIZE 060,10 OF oDlg  F3 cTabla VALID obtFormula(cGrupo,@oCmbFor:aitems) PIXEL HASBUTTON	
		
	oSay	:= tSay():New(10,80,{||OemToAnsi(STR0018)},oDlg,,,,,,.T.) 			// Descripción
	@ 18,80   MSGET 	IIF(cGrupo!="",POSICIONE("SX5",iSX5,XFILIAL("SX5")+cTabla+cGrupo,"X5_DESCRI"),"")  SIZE 120,10 WHEN .F. OF oDlg PIXEL

	oSay	:= tSay():New(35,10,{||OemToAnsi(STR0019)},oDlg,,,,,,.T.) // Formula
	oCmbFor := tComboBox():New(43,10,{|u|if(PCount()>0,cCmbFor:=u,cCmbFor)},/*ITEMS*/,190,20,oDlg,,/*{||}*/,,,,.T.,,,,,,,,,'cCmbFor')  // ComboBox Formula
					
	oSay	:= tSay():New(60,10,{||OemToAnsi(STR0020)},oDlg,,,,,,.T.) // Ayuda 
	@ 68,10   GET oGetHlp VAR IIF(!Empty(cCmbFor),POSICIONE("CWK", iCWK,XFILIAL("CWK") + SubStr(cCmbFor,0,15),"CWK_HELP");
	+ Chr(13)+Chr(10) +  Chr(13)+Chr(10) + POSICIONE("CWK", iCWK,XFILIAL("CWK") + SubStr(cCmbFor,0,15),"CWK_ADVPL"),"") MEMO  SIZE 100,100 WHEN .F. OF oDlg PIXEL
	oGetHlp:bRClicked := {||AllwaysTrue()}
	
	oBtnOk	:= tButton():New(170,135,OemToAnsi(STR0021),oDlg,{||( cCWKCFor := POSICIONE("CWK", iCWK,XFILIAL("CWK") + SubStr(cCmbFor,0,15),"CWK_FOREJE"), oDlg:End()  )} ,30,12,,,,.T.) //  Ok
	oBtnCa	:= tButton():New(170,170,OemToAnsi(STR0022),oDlg,{||( cCWKCFor := "",oDlg:End() )},30,12,,,,.T.)  // Anular
		
	ACTIVATE MSDIALOG oDlg CENTERED
	
	RestArea(aArea)
Return .T.


//-------------------------------------------------------------------------
/*/{Protheus.doc} obtFormula
Obtiene las Formulas de la tabla CWK de acuerdo al Grupo(CZ)

@type function
@author Alfredo Medrano
@since 14/01/2014
@version P12.1.18

@param cGrupo, código del grupo (CZ)
@param aFormula, array com as formulas

@return logico, Sempre .T.
/*/
//-------------------------------------------------------------------------
Static Function obtFormula(cGrupo,aFormula) 
	Local	 aDatos	  	:= {}   
	Local 	 aArea		:= getArea()        
	Local	 cTmpPer	:= CriaTrab(Nil,.F.)
	Local   cQuery		:= "" 
	Local   cFilCWK		:= FWCODFIL("CWK")   
	Default cGrupo		:= ""
	Default aFormula	:= {}
	
	cQuery := " SELECT CWK_CODFOR, CWK_DESC " 
	CQuery += " FROM " + RetSqlName("CWK") 
 	cQuery += " WHERE CWK_GRUPO='"+ cGrupo +"' " 	//Grupo
 	cQuery += " AND CWK_FILIAL =  '" + cFilCWK + "'"
  	cQuery += " AND D_E_L_E_T_ = ' ' "
  	cQuery := ChangeQuery(cQuery)   
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.) 
    
    AADD(aDatos,"")
	(cTmpPer)->(dbgotop())//primer registro de tabla
	While  (cTmpPer)->(!EOF())
		AADD(aDatos,(cTmpPer)-> CWK_CODFOR + " " + (cTmpPer)->CWK_DESC )		
		(cTmpPer)-> (dbskip())	 		
	EndDo
	
	(cTmpPer)->( dbCloseArea())
	restArea(aArea)
	aFormula := aDatos
	 		
Return  .T.


//-------------------------------------------------------------------------
/*/{Protheus.doc} CTB93VCA
verifica que el campo tiene la instrucción EjeFor valida la fórmula 
digitada como parámetro dentro de EjeFor debe existir en CWK. Valida los 
alias asociados a la formula (tablas cwq) y que existan en el Asiento 
estándar que se está configurando (tabla CWO)

usados em diversis valids da CT5

@type function
@author Alfredo Medrano
@since 15/01/2014
@version P12.1.18

@return logico, indica se metodo obteve sucesso
/*/
//-------------------------------------------------------------------------
Function CTB93VCA()
	Local cRedVar	:= &(ReadVar()) //obtiene el contenido del campo
	Local cCons		:= ""
	Local lRet	    := .T.
	Local nConta	:= 1
	Local cCaract	:= ""
	Local nVan		:= 0
	Local cCodFor	:= ""
	Local aArea		:= getArea()   
	Local nForm		:= TamSX3("CWK_CODFOR")[1]
	Local aArray	:= {}
	Local cLandPad 	:= M->CT5_LANPAD // Código asiento estándar 

	If Empty(cLandPad)
		Help( ,,OemToAnsi(STR0023),,OemToAnsi(STR0024), 1, 0 ) //"Aviso" //"Debe asignar el código de asiento estándar"  
		lRet := .F.
		Return lRet
	EndIf

	If cRedVar != NIL
		cRedVar := UPPER(Alltrim(cRedVar))
		If "EJEFOR" $ cRedVar
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Obtiene la fórmula digitada como parámetro dentro de   	³
			³la función EJEFOR											³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			While nConta <= len(cRedVar)
				cCaract := SubStr(cRedVar,nConta,1)
				If cCaract == ")"
					nVan := 2
				EndIf
				If nVan == 1 .And. nVan != 2 
					cCons += cCaract
				EndIf
				If cCaract == "(" 
					nVan := 1
				EndIf
				nConta++
			ENDDO

			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³La fórmula debe existir en el catálogo de formula (CWK).	³            
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			If !Empty(cCons)
				cCodFor := AllTrim(replace(cCons, '"', "")) //Elimina comillas
				cCodFor :=cCodFor+(Space(nForm-len(cCodFor))) // Asigna espacios
			
				DbSelectArea("CWK") 
				If CWK->(DBSeek(XFILIAL("CWK")+cCodFor)) //CWK_FILIAL+CWK_CODFOR

					/*/
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Obtener las tablas o alias asociados a la formula (CWQ)	³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
					DbSelectArea("CWQ")
					CWQ ->(DBSETORDER(1)) 
					If CWQ->(DBSeek(XFILIAL("CWQ")+cCodFor)) //CWQ_FILIAL+CWQ_CODFOR
						While  CWQ->(!Eof()) .And. ( CWQ_FILIAL+CWQ_CODFOR == XFILIAL("CWQ")+cCodFor )

							/*/
							ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿			
							³Tablas (CWQ)que existan en el Asiento estándar que se está ³  
							³configurando (tabla CWO), si al menos una no existe, no    ³
							³será una formula valida.                                   ³
							ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
							DbSelectArea("CWO")
							CWO ->(DBSETORDER(2))
							If !CWO->(DBSeek(XFILIAL("CWO")+cLandPad+CWQ->CWQ_TABLA)) //CWO_FILIAL+CWO_CODPTO+CWO_TABLA  
								Help( ,,OemToAnsi(STR0023),,OemToAnsi(STR0025) + CWQ->CWQ_TABLA + OemToAnsi(STR0026) + cLandPad, 1, 0 ) //"Aviso" //"La fórmula no es valida. La tabla " // " no está asignada al asiento estándar "
								lRet := .F.
								Return lRet
							EndIf
							CWQ->(dbskip())		 		
						EndDo
		
					EndIF			
				Else
					Help( ,,OemToAnsi(STR0023),,OemToAnsi(STR0028), 1, 0 ) //"Aviso" //"La fórmula no existe en el catálogo de Formulas" 
					lRet := .F.
				EndIF
								
			EndIf
		
		EndIf	
		
	EndIf
	restArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTB080Ver
 Protecao devido congelamento da 12.1.17 e necessidade de liberacao da conversao para MVC 
 Validacao por amostragem de dicionario.
 Nao deve ser replicado para Main ou outras versoes. 
 Pacote ATUSX: 003605 (será integrado na 12.1.17 - Outubro)
 Link Especificao: http://tdn.totvs.com.br/pages/releaseview.action?pageId=285667832

@author TOTVS
@since 19/09/2017

@version P12
/*/
//-------------------------------------------------------------------

Function CTB080Ver(oModel)
Local lRet		:= .T.
Local oCT5		:= oModel:GetModel("CT5MASTER")
Local oStruCT5	:= oCT5:GetStruct()

If  'CTBA080SB()' $ GetCbSource(oStruCT5:GetProperty("CT5_SBLOTE",MODEL_FIELD_WHEN) )
	lRet := .F.
	Help(" ",1,"CTBA080",,STR0041,1,0,,,,,,{STR0042}) //"Ambiente desatualizado."###"Atualize o ambiente para a versão 12.1.17 (Outubro) ou superior."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA080Pos
 Função de pós-validação dos dados do modelo de dados

@author TOTVS
@since 15/02/2018

@version P12
/*/
//-------------------------------------------------------------------
Function CTBA080Pos(oModel)
Local aAreaAtv		:= GetArea()
Local lRet			:= .T.
Local oCT5			:= oModel:GetModel("CT5MASTER")
Local nOperation	:= oModel:GetOperation()
Local cAliasTMP		:= ""

If oCT5:HasField("CT5_CTAREC")
	//----------------------------------------------------------------------------
	// Avalia se há somente uma sequência do LP com a definição de Conta Contábil
	// de Receita (como Débito ou Crédito) devido a geração do EFD-Contribuições
	//----------------------------------------------------------------------------
	If	(nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And.;
		oCT5:GetValue("CT5_STATUS") == "1" .And.;
		oCT5:GetValue("CT5_CTAREC") $ "2|3"

		cAliasTMP := GetNextAlias()

		BeginSql Alias cAliasTMP
		SELECT COUNT(CT5_SEQUEN) QTD_LP
		FROM %Table:CT5%
		WHERE	CT5_FILIAL = %Xfilial:CT5%
			AND CT5_LANPAD = %Exp:oCT5:GetValue("CT5_LANPAD")%
			AND CT5_SEQUEN <> %Exp:oCT5:GetValue("CT5_SEQUEN")%
			AND CT5_STATUS = '1'			
			AND CT5_CTAREC IN ('2','3')
			AND %NotDel%
		EndSql

		If (cAliasTMP)->(!Eof())
			If	(cAliasTMP)->QTD_LP > 0
				lRet := .F.
				Help(" ",1,"CTBA080Pos",,STR0043,1,0,,,,,,{STR0044}) //"Não é possivel indicar mais de uma sequência de lançamento como receita, campo Cta Receita (CT5_CTAREC)."###'Confira as sequências já cadastradas e altere o campo Cta Receita (CT5_CTAREC) para "Não"'
			EndIf
		EndIf

		(cAliasTMP)->(DBCloseArea())

	EndIf
EndIf

If nOperation == MODEL_OPERATION_DELETE
 	DbSelectArea("CVI")
 	DbSetOrder(2)
 	IF DbSeek(xFilial("CVI")+oCT5:GetValue("CT5_LANPAD")+oCT5:GetValue("CT5_SEQUEN"))
		Help(" ",1,"CTBA080Bld",,STR0047,1,0,,,,,,{STR0048})
		lRet := .F.
	EndIf

	If lRet
		cAliasTMP := GetNextAlias()
		BeginSQL Alias cAliasTMP
		SELECT R_E_C_N_O_ CV3RECNO
		FROM %Table:CV3%
		WHERE %NotDel% AND
			CV3_FILIAL = %xFilial:CV3% AND
			CV3_LP = %Exp:oCT5:GetValue("CT5_LANPAD")% AND
			CV3_LPSEQ = %Exp:oCT5:GetValue("CT5_SEQUEN")% 
		EndSQL

		(cAliasTMP)->(DbGotoP())
		IF !(cAliasTMP)->(EOF())
			Help(" ",1,"CTBA080CTEx",,STR0049,1,0,,,,,,{STR0050})
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea(aAreaAtv)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Ct080CarLP
Função de carga da CT5- LP faixa 500...599 baseado na CTL

@author TOTVS
@since 17/08/2022

@version P12
/*/
//-------------------------------------------------------------------
Function Ct080CarLP(lShowMsg)
Local aArea := GetArea()
Local aAreaCT5 := CT5->(GetArea())
Local nCt5Inc  := 0
Local aBindCTL 
Static _oQryCTLLP

Default lShowMsg := .T.

dbSelectArea("CT5")
dbSetOrder(1)

If _oQryCTLLP == NIL
	_oQryCTLLP := "SELECT CTL_FILIAL, CTL_LP, CTL_DESC, CTL_ALIAS, CTL_QCVLRD FROM "
	_oQryCTLLP += RetSqlName("CTL")
	_oQryCTLLP += " WHERE CTL_FILIAL = ?"
	_oQryCTLLP += " AND CTL_LP      >= ?"
	_oQryCTLLP += " AND CTL_LP      <= ?"
	_oQryCTLLP += " AND D_E_L_E_T_   = ?"
	_oQryCTLLP += " ORDER BY CTL_LP"
	_oQryCTLLP := ChangeQuery(_oQryCTLLP) 
EndIf 
aBindCTL := {}
AADD(aBindCTL, xFilial("CTL") )
AADD(aBindCTL, "500" )
AADD(aBindCTL, "599" )
AADD(aBindCTL, Space(1) )
dbUseArea(.T.,"TOPCONN",TcGenQry2(,,_oQryCTLLP,aBindCTL),'QCTL_LP')
aSize(aBindCTL,0)
aBindCTL := nil 
If QCTL_LP->(!Eof())

	While QCTL_LP->( !Eof() )
		
		// sempre com 001, se não existir inclui, se não existir 	
		If CT5->( !dbSeek(xFilial("CT5")+PadR(QCTL_LP->CTL_LP, Len(CT5->CT5_LANPAD))+StrZero(1,Len(CT5->CT5_SEQUEN)) ) )
			CT5->( RecLock("CT5", .T.) )
			CT5->CT5_FILIAL := xFilial("CT5")
			CT5->CT5_LANPAD := QCTL_LP->CTL_LP 
			CT5->CT5_SEQUEN := StrZero(1, Len(CT5->CT5_SEQUEN))   //001 ( FIXO)  
			CT5->CT5_DESC   := PadR(Alltrim(QCTL_LP->CTL_DESC),Len(CT5->CT5_DESC))
			CT5->CT5_TPSALD := '1' //( FIXO ) 
			If !Empty(QCTL_LP->CTL_ALIAS) .And. !Empty(QCTL_LP->CTL_QCVLRD)
				CT5->CT5_VLR01  := QCTL_LP->CTL_ALIAS+"->"+QCTL_LP->CTL_QCVLRD
			EndIf
			CT5->CT5_HIST   :=  '"'+Alltrim(PadR(QCTL_LP->CTL_LP+"/"+StrZero(1, Len(CT5->CT5_SEQUEN))+" " + QCTL_LP->CTL_DESC,Len(CT5->CT5_HIST)-2))+'"' //001 (FIXO)
			CT5->CT5_STATUS := '2' //( FIXO ) 
			CT5->( MsUnlock() )
			nCt5Inc++
		EndIf

		QCTL_LP->( dbSkip() )
	EndDo	
	QCTL_LP->( dbCloseArea() )	
	If nCt5Inc > 0
		If lShowMsg
			MsgInfo(STR0053+Alltrim(Str(nCt5Inc))+STR0054)   //"Processamento OK - Incluido(s) "##" Registro(s) de Lançamento Padrão."
		EndIf
	Else
		If lShowMsg 
			MsgInfo(STR0055)   //"Registros de Lançamento Padrão ja existente no cadastro."
		EndIf
	EndIf
Else
	If lShowMsg
		Alert(STR0056)   //"Nao encontrado registros na tabela CTL-Relacionamentos Contábeis LP [500-599] "
	EndIf
EndIf

RestArea(aAreaCT5)
RestArea(aArea)

Return
