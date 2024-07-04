#INCLUDE 'Protheus.ch'
#INCLUDE "Totvs.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "topconn.ch"
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE "fwbrowse.ch"
#INCLUDE "AGRA960.CH"

static __oArqTemp
static aCol := {}	//Campo  - Tipo  - Tamanho - Decimal - picture
/*/
aCol Dados da Grid.
[1] Titulo.
[2] Nome do Campo.
[3] Tipo do campo
[4] Tamanho do campo.
[5] Decimais do campo.
[6] Picture do campo.
[7] bWhen
/*/
Static aQry := {}	//Campo  - Name Colu - Tipo
/*/
aQry Dados para montar a Query.
[1] Nome do Campo ou SubSelect.
[2] Nome do Campo.
[3] Tipo do campo
/*/
Static aArq := {}	//Nome do campo  - Tipo  - Tamanho - Decimal - picture
/*/
aArq Dados da Arquivo.
[1] Nome do Campo.
[2] Tipo do campo
[3] Tamanho do campo.
[4] Decimais do campo.
[5] Picture do campo.
/*/
static cArqInd
// Alteracoa 11/07/2015
//Parametro que indica se pode ou não Editar a Analise  proviniente do layout oFicial deve conter (.t.) ou (.f.)
static lEditResul := SuperGetMV( "MV_AGRARES",.F., .T. )  //Se o parametro n. Existir Ele Considera .f.

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA960
Resultado de análise de lote
Tela onde é possivel visualizar os resultado de analise(NPX), conforme o layout cadastrado(NPW)
@author Maicol Lange
@since 06/01/2014
/*/
//-------------------------------------------------------------------
Function AGRA960()
	Local lErro			:= .F.
	//Local aDadSIX		:= {{"NPU_FILIAL+NPU_CODVA",Alltrim(AGRTITULO("NPU_CODVA")), , ,"S","N"}}

	Private aCoors  	:= FWGetDialogSize( oMainWnd )
	Private oGetLayout, oGetSafra
	Private cGetLayout 	:= Space(TAMSX3("NPV_CODIGO")[1])
	Private cGetSafra	:= Space(TAMSX3("NJU_CODSAF")[1])
	private carqTRBL    :=  GetNextAlias()
	Private oBrwLayout,oDlg,oBrwP2
	Private vVetRet,cAlia2
	Private aMatD 		:= {} // Usado na fórmula
	Private aSeek 		:= {}
	private aTrbIndex 	:= {}
	private cArqTMP		:= ""

	/*----------------------- RETIRADO. CRIADO PELO UPDATE: UPDNPU
	// Verifica se existe e/ou cria o índice 4
	If !AGRIFDICIONA("SIX","NPU2",1,.f.)
	AGRCRIASIX("NPU",aDadSIX)
	EndIf
	-----------------------*/
	If !AGRIFDICIONA("SX3","NKV",1,.F.)	//*Verifica se o registro existe no dicionário de dados
		AGRINCOMDIC("UPAGR001",,.T.)	//*Mensagem de incompatibilidade do dicionário de dados
		lErro := .T.
	EndIf

	If !AGRIFDICIONA("SX3","NP9_FORMUL",2,.F.) .Or. !AGRIFDICIONA("SX3","NP9_FORMUV",2,.F.)	//*Verifica se o registro existe no dicionário de dados
		AGRINCOMDIC("U_AGRUPD e Marcar U_UPDNP9",,.T.)										//*Mensagem de incompatibilidade do dicionário de dados
		lErro := .T.
	EndIf

	If (lErro)
		return()
	Else
		oSize := FWDefSize():New(.T.)
		oSize:AddObject('DLG',100,100,.T.,.T.)
		oSize:SetWindowSize(aCoors)
		oSize:aMargins := {3,3,3,3}
		oSize:lProp    := .T.
		oSize:Process()
		Define MsDialog oDlg Title STR0013  From aCoors[1]/2, aCoors[2]/2 To aCoors[3]/2, aCoors[4]/2 Pixel
		//Campo para informar o layout
		@04, 02 Say STR0020      Size 53, 07 Of oDlg  Pixel
		@13, 02 MSGET oGetLayout VAR cGetLayout  SIZE 40, 10  Valid AGRA960LA() F3 "NPV" VALID NAOVAZIO() .AND. EXISTCPO("NPV") OF oDlg PIXEL
		//campo para informar a safra
		@04, 50 Say STR0010       Size 53, 07 Of oDlg  Pixel
		@13, 50 MSGET oGetSafra  VAR cGetSafra   SIZE 60, 10  F3 "NJU" VALID NAOVAZIO() .AND. EXISTCPO("NJU") OF oDlg PIXEL
		//botao
		@13, 120 BUTTON STR0011   SIZE 43, 13 PIXEL OF oDlg  ACTION FindLayout(cGetLayout)
		Activate MsDialog oDlg Center
	endif
	AGRDLTPTB(__oArqTemp)
Return()


Static Function ModelDef()
	Local oModel  := Nil
	Local oStruct := FWFormModelStruct():New()
	Local nCont
	local bWhen
	local npos
	
	//Cria estrutura de dados
	For nCont := 1 To Len(aArq)
		cCampox := Alltrim(aArq[nCont,1])
		npos := Ascan(aCol,{|x| Alltrim(x[2]) = cCampox})

		Iif (npos > 0,bWhen := aCol[npos,7], bWhen :=  Iif( (Alltrim(aArq[nCont][1]) $ "XXX_FORMUL|XXX_IR|XXX_CLASS"),.T.,.F.))


		oStruct:AddField(/*cTitulo*/aArq[nCont][1],;
		/*cTooltip*/ "",;
		/*cIdField*/Alltrim(aArq[nCont][1]),;
		/*cTipo*/aArq[nCont][2],;
		/*nTamanho*/aArq[nCont][3],;
		/*nDecimal*/aArq[nCont][4],;
		/*bValid*/ IIf( bWhen .and. !Alltrim(aArq[nCont][1]) $ "XXX_FORMUL|XXX_IR|XXX_CLASS" ,{||AGRA960IR()},nil) ,;
		/*bWhen*/ &("{|| "+CVALTOCHAR(bWhen)+" }"),;
		/*aValues*/,;
		/*lObrigat*/.F.,;
		/*bInit*/ IIF(AGRSEEKDIC("SX3",Alltrim(aArq[nCont][1]),2,"X3_CONTEXT") == "V",&("{|| "+StrTran(AGRSEEKDIC("SX3",Alltrim(aArq[nCont][1]),2,"X3_INIBRW"),"NP9->",carqTRBL+"->")+" }"),nil),;
		/*lKey*/,;
		/*lNoUpd */,;
		/*lVirtual */IIF(AGRSEEKDIC("SX3",Alltrim(aArq[nCont][1]),2,"X3_CONTEXT") == "V",.T.,.F.))
	Next

	// Instancia o modelo de dados
	oModel := MpFormModel():New( 'AGRA960', /*bPRe*/,/*bPost*/,{| oModel | GrvModelo( oModel ) },/*{| oModel | AGR960DELT(  ) }*/ )
	
	oStruct:AddTable(carqTRBL,{" "},carqTRBL)
	oModel:AddFields( 'NPXMASTER', /*cOwner*/, oStruct,/*bPre*/, /*bPos*/, /* */, /*bCancel*/ )
	oModel:SetDescription( STR0013 )
	// Seta chave primaria
	oModel:SetPrimaryKey( {"NP9_LOTE","NP9_PROD"} )
Return oModel

static function GrvModelo (oModel)
	Local lRet := .T.
	Local nOperation:= oModel:GetOperation()
	Local nI
	Local oSubModel:= oModel:GetModel("NPXMASTER")
	local bInsert:= .F.

	Local cCodSaf:= oSubModel:GetValue("XXX_CODSAF")
	Local cCodPro:= oSubModel:GetValue("NP9_PROD")
	LOCAL cLote:= oSubModel:GetValue("NP9_LOTE")

	If (oModel:lModify)
		If  (nOperation == MODEL_OPERATION_UPDATE)
			AGRA960IR(.T.)
			//GRAVA DADOS DA NP9
			if ( AGRIFDBSEEK("NP9",oSubModel:GetValue("XXX_CODSAF")+;
			oSubModel:GetValue("NP9_PROD")+;
			oSubModel:GetValue("NP9_LOTE"),1,.f.) )
				AGRTRAVAREG(,.F.)
				NP9->NP9_FORMUL := oSubModel:GetValue("XXX_FORMUL")
				NP9->NP9_IR     := oSubModel:GetValue("XXX_IR")
				NP9->NP9_CLASS  := oSubModel:GetValue("XXX_CLASS")
				AGRDESTRAREG()
			Endif

			//Busca Layout
			DbSelectArea("NPW")
			dbSetOrder(1)
			NPW->( dbSeek( xFilial( "NPW" ) + cGetLayout ) )
			while (xFilial("NPW") =  NPW->NPW_FILIAL  .and. NPW->NPW_LAYOUT = cGetLayout )
				ni := 1
				bInsert := .F.
				If !Empty(NPW->NPW_CODTA) .AND. lEditResul  .or. AGRSEEKDIC("NPT",xfilial("NPT")+NPW->NPW_CODTA,1,"NPT_ANAOFI") = '1'
					NPU->( dbSetOrder( 1 ) )
					if NPU->(dbseek(xFilial( "NPU" )+NPW->NPW_CODTA+NPW->NPW_CAMPO))
						while !bInsert
							DbSelectArea("NPX")
							dbSetOrder(1)
							if (NPX->( dbSeek( xFilial( "NPX" )+oSubModel:GetValue("XXX_CODSAF")+oSubModel:GetValue("NP9_PROD")+;
							oSubModel:GetValue("NP9_LOTE")+NPW->NPW_CODTA+NPW->NPW_CAMPO+ CVALTOCHAR(nI) )))
								AGRTRAVAREG("NPX",.f.)
								NPX->NPX_ATIVO  := "2"
								NPX->NPX_USUATU := SubStr(cusuario,7,15)
								AGRDESTRAREG("NPX")
								nI++
							else
								AGRTRAVAREG("NPX",.t.)
								NPX->NPX_FILIAL := Xfilial("NPX")
								NPX->NPX_CODSAF:= oSubModel:GetValue("XXX_CODSAF")
								NPX->NPX_LOTE:= oSubModel:GetValue("NP9_LOTE")
								NPX->NPX_ATIVO:= '1'
								NPX->NPX_DESVA  :=  Posicione("NPU",1,xFilial("NPU")+NPW->NPW_CODTA+NPW->NPW_CAMPO,"NPU_DESVA")
								NPX->NPX_SEQ    :=  CVALTOCHAR(nI)
								NPX->NPX_CODPRO := oSubModel:GetValue("NP9_PROD")
								NPX->NPX_CODTA  := NPW->NPW_CODTA
								NPX->NPX_CODVA  := NPW->NPW_CAMPO

								If NPU->NPU_TIPOVA = "1"
									NPX->NPX_TIPOVA := NPU->NPU_TIPOVA
									NPX->NPX_RESNUM := oSubModel:GetValue(NPW->NPW_CAMPO)
								ElseIf NPU->NPU_TIPOVA = "2"
									NPX->NPX_TIPOVA := NPU->NPU_TIPOVA
									NPX->NPX_RESTXT := oSubModel:GetValue(NPW->NPW_CAMPO)
								Else
									NPX->NPX_TIPOVA := "3"
									NPX->NPX_RESDTA := oSubModel:GetValue(NPW->NPW_CAMPO)
								EndIf

								NPX->NPX_DTATU  := DdataBase
								NPX->NPX_USUATU := SubStr(cusuario,7,15)
								NPX->NPX_OFI  	:= Posicione("NPT",1,xFilial("NPT")+NPW->NPW_CODTA,"NPT_ANAOFI")
								NPX->NPX_IR 	:= NPU->NPU_IR
								AGRDESTRAREG("NPX")
								bInsert := .T.
							Endif
						EndDo
					Endif
				Endif
				NPW->( dbSkip() )
			EndDo
		Endif
		FWFormCommit( oModel )

		// --Vou Colocar fora da Transação senao o SQL, ira Falhar, pois os dados ref. ao resultado de analise ainda
		// --nao foram comitados.
		fAprvLote( cLote ,cCodSaf, cCodPro )

	Endif

Return(lRet)

Static Function ViewDef()
	Local oView   := Nil
	Local oStruct := FWFormViewStruct():New()
	Local oModel  := FWLoadModel("AGRA960")
	Local nCont

	For nCont := 1 To Len(aCol)
		oStruct:AddField(/*cIdField*/Alltrim(aCol[nCont][2]),;
		/*cOrdem*/NTOC(nCont,32,2),;
		/*cTitulo*/aCol[nCont][1] ,;
		/*cDescric*/aCol[nCont][1] ,;
		/*aHelp*/,;
		/*cType*/aCol[nCont][3],;
		/*cPicture*/aCol[nCont][6],;
		/*bPictVar*/,;
		/*cLookUp*/,;
		/*lCanChange*/,;
		/*cFolder*/,;
		/*cGroup*/,;
		/*aComboValues*/ Iif(Iif(AGRIFDICIONA("SX3",Alltrim(aCol[nCont,2]),2,.f.),!Empty(X3CBox()),.F.),Separa(X3CBox(),";"),nil),;
		/*nMaxLenCombo*/,;
		/*cIniBrow*/,;
		/*lVirtual*/,;
		/*cPictVar*/,;
		/*lInsertLine*/,;
		/*nWidth*/)
	Next

	// Instancia modelo de visualização
	oView := FwFormView():New()
	// Seta o modelo de dados
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NPX', oStruct, 'NPXMASTER' )
	oView:addUserButton(STR0008 ,"",{||AGRA960FOR()},STR0008,,{MODEL_OPERATION_UPDATE})
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FindLayout
Através do Layout informado é montado toda a estrutura da tela
@author Maicol Lange
@since 06/01/2014
/*/
//-------------------------------------------------------------------
Static Function FindLayout(cLayout)

	Local aNP9Struct := NP9->(DBSTRUCT())
	Local nI := 1

	aArq  := {}
	aCol  := {}
	aQry  := {}
	bWhen := .F.

	If Empty(cGetSafra)
		oGetSafra:SetFocus()
		Return
	endif

	//Busca Layout
	DbSelectArea("NPW")
	("NPW")->(dbGotop())
	dbSetOrder(1)
	NPW->( dbSeek( xFilial( "NPW" ) + cLayout ) )
	while (xFilial("NPW") =  NPW->NPW_FILIAL  .and. NPW->NPW_LAYOUT = cLayout )
		//Verifica se é analise -  se for monta subquery
		bWhen := .F.
		If !Empty(NPW->NPW_CODTA)
			NPU->( dbSetOrder( 1 ) )
			if NPU->(dbseek(xFilial( "NPU" )+NPW->NPW_CODTA+NPW->NPW_CAMPO))
				/*[1] Campo,[2] Titulo do campo,[3] Tipo do campo,[4] Tamanho do campo,[5] Decimais do campo,[6] Picture do campo, [7]bwhen.*/
				//Verificar se campo pode ser editado, se existir  SX3 e tipo de análise é  oficila,  não pode
				/* bWhen :=   IIf(AGRIFDICIONA("SX3",Alltrim(NPW->NPW_CAMPO),2) .Or.;
				(AGRSEEKDIC("NPT",xfilial("NPT")+NPW->NPW_CODTA,1,"NPT_ANAOFI") = '2'),.F.,.T.)
				*/
				// Alteração em 11/07/2015 para permitir Editar os Cpos, qdo o Parametro MV_AGRARES , Estiver com Verdadeiro
				bWhen:=IIf( AGRIFDICIONA("SX3",Alltrim(NPW->NPW_CAMPO),2) .Or.(AGRSEEKDIC("NPT",xfilial("NPT")+NPW->NPW_CODTA,1,"NPT_ANAOFI") = '2' .and. !lEditResul ),.F.,.T.)

				//CONOUT( IIF(BWHEN == .T. , 'VERDADE', 'FALSO'))

				Do Case
					Case NPU->NPU_TIPOVA = '1' // Numerico
					aDadosCmp := DadosCampo("NPX_RESNUM")
					aAdd(aArq,{AllTrim(NPW->NPW_CAMPO),aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6]})//{Nome, Tipo, Tamanho, Decimal,picture}
					aAdd(aQry,{SubQuery("NPX_RESNUM",AllTrim(NPW->NPW_CODTA),AllTrim(NPU->NPU_CODVA)),AllTrim(NPW->NPW_CAMPO),aDadosCmp[3]})
					aAdd(aCol,{ NPW->NPW_NOME ,AllTrim(NPW->NPW_CAMPO),aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6],bWhen})
					Case NPU->NPU_TIPOVA = '2'
					aDadosCmp := DadosCampo("NPX_RESTXT")
					aAdd(aArq,{AllTrim(NPW->NPW_CAMPO),aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6]})//{Nome, Tipo, Tamanho, Decimal,picture}
					aAdd(aQry,{SubQuery("NPX_RESTXT",AllTrim(NPW->NPW_CODTA),AllTrim(NPU->NPU_CODVA)),AllTrim(NPW->NPW_CAMPO),aDadosCmp[3]})
					aAdd(aCol,{ NPW->NPW_NOME  ,AllTrim(NPW->NPW_CAMPO),aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6],bWhen})
					Case NPU->NPU_TIPOVA = '3'
					aDadosCmp := DadosCampo("NPX_RESDTA")
					aAdd(aArq,{AllTrim(NPW->NPW_CAMPO),aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6]})//{Nome, Tipo, Tamanho, Decimal,picture}
					aAdd(aQry,{SubQuery("NPX_RESDTA",AllTrim(NPW->NPW_CODTA),AllTrim(NPU->NPU_CODVA)),AllTrim(NPW->NPW_CAMPO),aDadosCmp[3]})
					aAdd(aCol,{ NPW->NPW_NOME  ,AllTrim(NPW->NPW_CAMPO),aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6],bWhen})
				EndCase
			endif
		else
			aDadosCmp := DadosCampo(NPW->NPW_CAMPO)
			If (AT("B8", (SUBSTR(NPW->NPW_CAMPO,1,3))) >0)//verifica se é saldo do lote tabela SB8
				aAdd(aArq,{AllTrim(NPW->NPW_CAMPO),aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6]})
				aAdd(aQry,{SubQSB8(),AllTrim(NPW->NPW_CAMPO),aDadosCmp[3]})
				aAdd(aCol,{NPW->NPW_NOME,AllTrim(NPW->NPW_CAMPO),aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6],bWhen})
			elseif (AGRSEEKDIC("SX3",NPW->NPW_CAMPO,2,"X3_CONTEXT") == "V")
				aAdd(aArq,{AllTrim(NPW->NPW_CAMPO),aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6]})
				aAdd(aCol,{NPW->NPW_NOME ,AllTrim(NPW->NPW_CAMPO),aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6],bWhen})
			else
				aAdd(aArq,{aDadosCmp[1],aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6]})
				aAdd(aQry,{AllTrim(NPW->NPW_CAMPO),AllTrim(NPW->NPW_CAMPO),aDadosCmp[3]})
				aAdd(aCol,{NPW->NPW_NOME ,aDadosCmp[1],aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6],bWhen})
			endif
		endif
		aDadosCmp := {}
		NPW->( dbSkip() )
	EndDo

	aDadosCmp := DadosCampo("NP9_CODSAF")
	aAdd(aArq,{"XXX_CODSAF",aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6]})//{Nome, Tipo, Tamanho, Decimal,picute}
	aAdd(aQry,{"NP9_CODSAF","XXX_CODSAF",aDadosCmp[3]})

	aDadosCmp := DadosCampo("NP9_FORMUL")
	aAdd(aArq,{"XXX_FORMUL",aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6]})//{Nome, Tipo, Tamanho, Decimal,picute}
	aAdd(aQry,{"NP9_FORMUL","XXX_FORMUL",aDadosCmp[3]})

	aDadosCmp := DadosCampo("NP9_IR")
	aAdd(aArq,{"XXX_IR",aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6]})//{Nome, Tipo, Tamanho, Decimal,picute}
	aAdd(aQry,{"NP9_IR","XXX_IR",aDadosCmp[3]})

	aDadosCmp := DadosCampo("NP9_CLASS")
	aAdd(aArq,{"XXX_CLASS",aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6]})//{Nome, Tipo, Tamanho, Decimal,picute}
	aAdd(aQry,{"NP9_CLASS","XXX_CLASS",aDadosCmp[3]})

	For nI := 1 to Len(aNP9Struct)
		If (AGRRETCTXT("NP9",aNP9Struct[nI][1]) <> "V") .and. (aNP9Struct[nI][2] $ "C|N|D") .and.;
		 	Ascan(aArq,{|x| Alltrim(x[1]) = Alltrim(aNP9Struct[nI][1])}) == 0
			
			//C-Tipo Caracter; N - Numérico; D - Data ; M - Memo; L - Lógico
			aDadosCmp := DadosCampo(aNP9Struct[nI][1])
			aAdd(aArq,{aDadosCmp[1],aDadosCmp[3],aDadosCmp[4],aDadosCmp[5],aDadosCmp[6]})
			aAdd(aQry,{aDadosCmp[1],aDadosCmp[1],aDadosCmp[3]})
		Endif

	Next

	//Cria tabela temporária
	If !Empty(aArq)
		CreaTable()
		//Inseri os dados na  tabela temporária
		Processa({|| InsertDados()},STR0012,STR0015 ,.T.)
		//Cria a Grid
		CreatGrid()//aCol,aArq
	Else
		Alert(STR0016)
	EndIf
Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} InsertDados
@author Maicol Lange
@since 06/01/2014
/*/
//-------------------------------------------------------------------
Static Function InsertDados()//aQry
	Local  cQuery := ''
	Local nX,nI,nQtdl,nRegl   := 0

	cQuery := CreaQuery()

	If Select("TEMP") > 0//Retorna a área de trabalho, do alias especificado, na forma de um valor numérico inteiro.
		ARGCLOSEAREA("TEMP")
	EndIf

	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	TCQUERY cQuery NEW ALIAS "TEMP"

	DbSelectArea(carqTRBL)
	aEstTRB := Dbstruct()

	DbSelectArea('TEMP')
	Count To nQtdl
	ProcRegua(nQtdl)
	aEstTRB2 := Dbstruct()

	Dbgotop()
	While !Eof()
		nRegl ++
		IncProc() //"Processando registro -> "

		Reclock(carqTRBL, .T.)
		For nX := 1 to Len(aEstTRB2)
			nI := Ascan(aEstTRB,{|x| x[1] == aEstTRB2[nX,1]})
			if aEstTRB[nI,2] == aEstTRB2[nX,2]
//				if aEstTRB[nI,2] = "D"  Se em aEstTRB[nI,2] == 'D', em aEstTRB2[nI,2] será igual a C, pois o Protheus salva data como caracter, logo essa condição nunca será satisfeita 
//					(carqTRBL)->&(aEstTRB[nI,1]) :=  STOD(CVALTOCHAR(TEMP->&(aEstTRB2[nX,1])))
//				else
					(carqTRBL)->&(aEstTRB[nI,1]) := If(aEstTRB[nI,1] = "NP9_FORMUL",AGR960MFOR(TEMP->&(aEstTRB2[nX,1])),TEMP->&(aEstTRB2[nX,1]))
//				endif 
			Elseif aEstTRB[nI,2] == "D" //Se for tipo data
				(carqTRBL)->&(aEstTRB[nI,1]) :=  STOD(CVALTOCHAR(TEMP->&(aEstTRB2[nX,1])))
			EndIf
		next nX
		MsUnlock(carqTRBL)
		dbselectarea('TEMP')
		dbskip()
	EndDo
	ARGCLOSEAREA("TEMP")
return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} DadosCampo
Função auxiliar que retorna dados de um campo no SX3.
@sample     DadosCampo( cCampo )

@param        cCampo    Nome do campo que deseja obter informações.

@return    aDados Dados do campo.
[1] Campo.
[2] Titulo do campo.
[3] Tipo do campo
[4] Tamanho do campo.
[5] Decimais do campo.
[6] Picture do campo.

@author    Maicol Lange
@since     04/02/2014
/*/
//------------------------------------------------------------------------------
Static Function DadosCampo( cCampo )

	Local aArea    := GetArea()
	Local aDados    := {}

	DbSelectArea('SX3')        //Campos da tabela
	SX3->( DbSetOrder(2) )    //X3_CAMPO
	SX3->( DbGoTop() )

	If ( SX3->( MsSeek( cCampo ) ) )

		AAdd( aDados,AlLTRIM(SX3->(X3_CAMPO)) )       //1 -Retorna título do campo no X3
		AAdd( aDados,X3Titulo() )            //2 -Retorna descrição do campo no X3
		AAdd( aDados,SX3->(X3_TIPO))  //3 -Retorna o tipo do campo
		AAdd( aDados, TamSX3(cCampo)[1] )    //4 -Retorna tamanho do campo
		AAdd( aDados, TamSX3(cCampo)[2] )    //5 -Retorna quantidade de casas decimais do campo
		AAdd( aDados, X3Picture(cCampo) )    //6 -Retorna a picture do campo

	EndIf

	RestArea( aArea )

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} SubQSB8
Monta sub query para somar e retornar o saldo dos lotes
@author Maicol Lange
@since 06/01/2014
/*/
//-------------------------------------------------------------------
Static Function SubQSB8()
	Local cQuery := ""
	cQuery := " (SELECT  SUM(B8_SALDO) FROM "+RetSqlName("SB8")
	cQuery += "  WHERE   B8_LOTECTL = NP9_LOTE And "
	cQuery += "          B8_PRODUTO = NP9_PROD And "
	cQuery += "          B8_FILIAL =  '"+xFilial( "SB8" ) +"' And "
	cQuery += "          D_E_L_E_T_ <> '*') "
return (cQuery)
//-------------------------------------------------------------------
/*/{Protheus.doc} SubQuery
Monta  a subQuery retornando os dados da importação de análise.
@author Maicol Lange
@since 06/01/2014
/*/
//-------------------------------------------------------------------
Static Function SubQuery(cCampo,CodAnalise,CodTipoAnalise)
	Local cQuery := ""

	cQuery := " (SELECT  "+cCampo+" FROM "+RetSqlName("NPX")
	cQuery += " WHERE    NPX_CODTA  = '"+AllTrim(CodAnalise)+"' And "
	cQuery += "          NPX_CODVA  = '"+AllTrim(CodTipoAnalise)+"' And "
	cQuery += "          NPX_LOTE   = "+RetSqlName("NP9")+".NP9_LOTE    And "
	cQuery += "          NPX_CODPRO   = "+RetSqlName("NP9")+".NP9_PROD    And "
	if !Empty(cGEtSafra)
		cQuery += "          NPX_CODSAF  = "+RetSqlName("NP9")+".NP9_CODSAF   And "
	endif
	cQuery += "          NPX_ATIVO  = '1'         And "
	cQuery += "          NPX_FILIAL = '"+xFilial( "NPX" ) +"' And "
	cQuery += "          D_E_L_E_T_ <> '*') "
return (cQuery)

//-------------------------------------------------------------------
/*/{Protheus.doc} CreaQuery
Cria a query para retornar os dados da analise e ser inserido na tabela tempóraria
@author Maicol Lange
@since 06/01/2014
@parameters
AQry
/*/
//-------------------------------------------------------------------
Static Function CreaQuery()//aQry
	Local nX:= 0
	Local cQuery := "SELECT "
	Local cOrder := ""
	Local cColQuery :=""
	Local cTabela := "NP9"
	Local cJoin := ""

	For nX := 1 to Len(aQry)
		cTabela := SubStr(aQry[nX,1],1,3) //
		IF (AT("_",cTabela) > 0)
			cTabela := "S"+SubStr(cTabela,1,2)
			IF !(AT(cTabela,cJoin) > 0)
				cJoin +=  Creat_relationship(cTabela)
			endif
		endif

		IF (Len(aQry[nX,1]) > 10)// verifica se é subquery
			cColQuery += IIf (!empty(cColQuery),","+aQry[nX,1]+" "+aQry[nX,2],aQry[nX,1]+" "+aQry[nX,2])
			IF !(AT("NPX",cJoin) > 0)
				cJoin +=  Creat_relationship("NPX")
			ENDIF
			IF (AT("SB8",aQry[nX,1]) > 0)
				cOrder+= IIf (!empty(cOrder),","+"NP9_PROD","NP9_PROD")
			ENDIF
		ELSE
			cColQuery += IIf (!empty(cColQuery),","+aQry[nX,1]+" "+aQry[nX,2],aQry[nX,1]+" "+aQry[nX,2])
			cOrder+= IIf (!empty(cOrder),","+aQry[nX,1],aQry[nX,1])
		ENDIF
	NEXT nX

	cQuery += cColQuery
	cQuery  += " FROM "+RetSqlName("NP9")+" "
	cQuery += cJoin
	cQuery += "  WHERE "+RetSqlName("NP9")+".NP9_FILIAL = '"+xFilial( "NP9" ) +"' And "
	//verifica filtro de safra
	if !Empty(cGEtSafra)
		cQuery += RetSqlName("NP9")+".NP9_CODSAF = '"+cGEtSafra+"'  And "
		cOrder+= IIf (!empty(cOrder),","+RetSqlName("NP9")+".NP9_CODSAF",""+RetSqlName("NP9")+".NP9_CODSAF")
	endif
	cQuery += "  "+RetSqlName("NP9")+".D_E_L_E_T_ <> '*' "

	IF !Empty(cOrder)
		cQuery  += " GROUP BY "+cOrder
	ENDIF

return ChangeQuery(cQuery)

Static function Creat_relationship (cTabela)
	local cJoin :=""
	Do Case
		Case  cTabela = "NPX"
		cJoin :=  " left JOIN "+RetSqlName("NPX")+" ON  NPX_LOTE     = NP9_LOTE "
	EndCase
return (cJoin)

//-------------------------------------------------------------------
/*/{Protheus.doc} CreaTable
Cria tabela tempóraria para receber o resultado da Query
@author Maicol Lange
@since 06/01/2014
/*/
//-------------------------------------------------------------------
Static Function CreaTable()//aArq
	Local __oArqTemp
	Local aIndices := {}
	If Select(carqTRBL) > 0
		dbSelectArea ( carqTRBL )
		(carqTRBL)->(DbCloseArea())
	EndIf

	__oArqTemp  := AGRCRTPTB(carqTRBL, {aArq, aIndices })
	
return()

/*
+=================================================================================================+
| Função    : AGRA960FOR                                                                          |
| Descrição : Geração e gravação da fórmula                                                       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 23/02/2015                                                                          |
+=================================================================================================+                                                                                                 |
*/
static Function AGRA960FOR()
	Local vVetRet,nv
	Local oModel:= FwModelActive()
	Local oView := FwViewActive()
	Local oSubModel:= oModel:GetModel("NPXMASTER")

	// Monta consulta
	aMatD := {}
	For nv := 1 To Len(aCol)
		If !AGRIFDICIONA("SX3",aCol[nv,2],2) .And. aCol[nv,3] = "N" .And. Alltrim(aCol[nv,2]) <> "NP9_FORMUL"
			Aadd(aMatD,{aCol[nv,1],oSubModel:GetValue(aCol[nv,2]),aCol[nv,2]})
		Endif
	Next nv

	vVetRet := AGR960FORM(AGRTITULO('NP9_IR'),oSubModel:GetValue("XXX_FORMUL"),"F3FOR1","AGRA960VF()",AGRSEEKDIC("SX3","NPU_DESVA ",2,"X3_TAMANHO"))

	If vVetRet[1] = 1
		AGRTRAVAREG(,.F.)
		If oSubModel:HasField("NP9_FORMUL")
			FWFldPut("NP9_FORMUL", AGR960MFOR(vVetRet[2]),0/*nLinha */, oModel,.T. , .T.)
		EndIf
		oSubModel:SetValue("XXX_FORMUL",  vVetRet[2])
		oView:lModify := .T.
		AGRA960IR(.T.)
	EndIf
Return .t.


Function AGRA960F3()
	Local aResul := {}
	aResul :=  AGR960F3MA(aMatD,{STR0002+Space(20),STR0003,"field"},{1,3},STR0004,.f.)
	if !Empty(aResul)
		cCampCC 	:= aResul[1]
		cVariavel 	:= aResul[2]
	else
		cCampCC 	:= ""
		cVariavel 	:= ""
	end
Return .T.

Function AGRA960VF()
	Local lRet := .t.
	If Ascan(aMatD,{|x| x[1] == cCampCC}) = 0
		Alert(STR0002+" "+STR0005)
		lRet := .f.
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CreatGrid
Atribui as coluna  da grid
@author Maicol Lange
@since 06/01/2014
/*/
//-------------------------------------------------------------------
Static Function CreatGrid()//aCol,aArq
	Local aFldsFilt  := {}
	local nx,ny
	local aColumns := {}
	local cData
	// Verifica se o usuário pode alterar os resultado
	lAltRes := AGRIFDBSEEK("NKV",__CUSERID+cGetLayout,1,.f.) // colocar aqui
	// Monta estrutura para pode  usar o filter
	for nX :=1  to Len(aCol)
		aAdd(aFldsFilt,{})
		aIns(aFldsFilt,nX)
		aFldsFilt[nX] := Array( Len(aCol[nX]))
		for nY := 1 to Len(aCol[nX])-1
			aFldsFilt[nX][nY]:= aCol[nX][nY]
		next nY
		aFldsFilt[nX][1]:= aCol[nX][2]
		aFldsFilt[nX][2]:= aCol[nX][1]
	next nX

	For nx := 1 to Len(aCol)
		DO CASE
			CASE AGRSEEKDIC("SX3",Alltrim(aCol[nx,2]),2,"X3_CONTEXT") == "V"
			cData:=StrTran(AGRSEEKDIC("SX3",Alltrim(aCol[nx,2]),2,"X3_INIBRW"),"NP9->",carqTRBL+"->")
			CASE!Empty(X3CBox())
			cData:="X3Combo('"+Alltrim(aCol[nx,2])+"',"+carqTRBL+"->"+Alltrim(aCol[nx,2])+")"
			OTHERWISE
			cData:= Alltrim(aCol[nx,2])
		ENDCASE

		AAdd(aColumns,FWBrwColumn():New())
		aColumns[nx]:SetData(&("{||"+cData+"}"))
		aColumns[nx]:SetTitle( Alltrim(aCol[nx,1]))
		aColumns[nx]:SetPicture(Alltrim(aCol[nx,6]))
		aColumns[nx]:SetType(Alltrim(aCol[nx,3]))
		aColumns[nx]:SetSize(aCol[nx,4])
		aColumns[nx]:SetReadVar(cData)
		//aColumns[nx]:SetOrder(nx)
	Next nx

	DEFINE MSDIALOG oDlgX FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL
	DEFINE FWFormBrowse oBrowse DATA TABLE ALIAS carqTRBL DESCRIPTION STR0013  OF oDlgX
	oBrowse:SetProfileID(AllTrim(cGetLayout))
	oBrowse:SetColumns(aColumns)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetAlias(carqTRBL)
	oBrowse:DisableDetails()
	oBrowse:SetFieldFilter(@aFldsFilt)
	oBrowse:SetDoubleClick( IIF(lAltRes, {|| AGRA960DC()}, {||.F.} ))
	oBrowse:bHeaderClick := {|| AGRA960ORDB() }
	oBrowse:SetdbFFilter(.T.)
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetSeek(,aSeek)
	ADD BUTTON oButton TITLE "Historico" ACTION { || AGR960HIS() } OF oBrowse	//HISTORICO
	ADD BUTTON oButton TITLE "Aprovar"   ACTION { || AGR960APR() } OF oBrowse	//APROVAR
	ADD BUTTON oButton TITLE "Reprovar"  ACTION { || AGR960REJ() } OF oBrowse	//REPROVAR
	oBrowse:AddButton(STR0006,{|| oDlgX:end()},,9,0)
	ACTIVATE FWFormBrowse oBrowse
	ACTIVATE MSDIALOG oDlgX CENTER
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA960DC
@author Maicol Lange
@since 09/04/2015
Função  para ativação da edição dos dados valida se o lote é TSI, caso for não habilita
/*/
//-------------------------------------------------------------------
Static function AGRA960DC
	Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil}/*Salvar*/,{.T.,Nil/*"Cancelar"*/},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	Local cCodLay 	:= cGetLayout
	Local cCodUsu 	:= RetCodUsr()

	AGRIFDBSEEK("NP9",cGetSafra+(carqTRBL)->NP9_PROD+(carqTRBL)->NP9_LOTE,1,.T.)
	If NP9->NP9_TRATO <> '1'
		DBSELECTAREA("NKV")
		DBSETORDER(1)
		If DBSEEK(xFilial("NKV")+cCodUsu+cCodLay)
			If NKV->NKV_TIPO = '1' 		//Visualiza
				FWExecView(STR0051, 'AGRA960', MODEL_OPERATION_VIEW	 , , {|| .F. }, , ,aButtons )
			ElseIf NKV->NKV_TIPO = '2'  //Altera
				FWExecView(STR0014, 'AGRA960', MODEL_OPERATION_UPDATE, , {|| .T. }, , ,aButtons )
			EndIf
		EndIf
	else
		ApMsgInfo(STR0021)
	end
return

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA960IR
@author Maicol Lange
@since 28/03/2015
/*/
//-------------------------------------------------------------------
static Function AGRA960IR(lvShow)
	Local lShow := If(lvShow = Nil,.f.,lvShow)
	Local nx
	Local cMemoTmp
	local oModel:= FwModelActive()
	Local oSubModel:= oModel:GetModel("NPXMASTER")
	Local oView := FwViewActive()
	Local bErro:= .F.
	Local aErros:= {}


	cForm := oSubModel:GetValue("XXX_FORMUL")
	cMemoTmp:= StrTran(cForm,'#','')

	If !Empty(cMemoTmp)
		While .t.
			nPos1 := At("@",cMemoTmp)
			If nPos1 > 0
				nPos2 := At("@", Substr(cMemoTmp,nPos1+1) )
				If nPos2 > 0
					cCampo := Alltrim(SubStr(cMemoTmp,nPos1+1,nPos2-1))
					nPosHe := aScan(aCol,{|x| AllTrim(x[2]) == SubStr(cCampo,At(";",cCampo)+1)})
					If nPosHe > 0
						cMemoTmp  := StrTran(AllTrim(cMemoTmp),"@"+ ALLtrim(cCampo) +"@", ("oSubModel:GetValue('"+ Alltrim(aCol[nPosHe,2]))+"')")
					else
						bErro := .t.
						cMemoTmp := StrTran(cMemoTmp,"@"+cCampo+"@","")
						If (lShow)
							cVari:=SubStr(cCampo,At(";",cCampo)+1)
							cTipoA:=SubStr(cCampo,0,At(";",cCampo)-1)
							aadd(aErros,STR0017+": ['" + Alltrim(Posicione("NPU",1,xFilial("NPU")+cTipoA+cVari,"NPU_DESVA"))+ "']" )
						endif
					EndIf
				Else
					aadd(aErros,STR0019)
					EXIT
				Endif
			Else
				EXIT
			EndIf
		End

		If bErro
			If (lShow)
				AutoGrLog(STR0018)
				For nx := 1 to Len(aErros)
					AutoGrLog(aErros[nx])
				end nx
				MostraErro()
			endif
		else
			oSubModel:SetValue("XXX_IR" , Eval(&("{||"+cMemoTmp+"}")))
			oSubModel:SetValue("XXX_CLASS",AGRCLASSELOTE(AGRSEEKDIC("NP9",;
			xfilial("NP9")+oSubModel:GetValue("XXX_CODSAF")+;
			oSubModel:GetValue("NP9_PROD")+;
			oSubModel:GetValue("NP9_LOTE"),1,"NP9_CTVAR"),oSubModel:GetValue("XXX_IR")))

			If oSubModel:HasField("NP9_IR")
				FWFldPut("NP9_IR", oSubModel:GetValue("XXX_IR"),0/*nLinha */, oModel,.T. , .T.)
			Endif

			If oSubModel:HasField("NP9_CLASS")
				FWFldPut("NP9_CLASS", oSubModel:GetValue("XXX_CLASS"),0/*nLinha */, oModel,.T. , .T.)
			Endif
			oView:lModify := .T.
		EndIf
	Endif
Return(.t.)

/*
+=================================================================================================+
| Programa  : AGRCLASSELOTE                                                                       |
| Descrição : Busca a classe do lote                                                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/03/2015                                                                          |
+=================================================================================================+
| Retorna   : cClasse - Classe do lote                                                 Obrigatório|
+=================================================================================================+
*/
static Function AGRCLASSELOTE(cCtVar,nIR)
	Local aAreaL := GetArea()
	Local cClasse := AGRINICIAVAR("NP0_CLASS",.T.)
	If AGRIFDBSEEK("NP0",cCtVar,1,.f.)
		While !Eof() .And. NP0->NP0_FILIAL = Xfilial("NP0") .And. NP0->NP0_CTVAR = cCtVar
			If NP0->NP0_IRINI <= nIR .And. NP0->NP0_IRFIM >= nIR
				cClasse := NP0->NP0_CLASS
				Exit
			EndIf
			DbSkip()
		End
	EndIf
	RestArea(aAreaL)
Return cClasse


Static function AGR960F3MA(aMatrDa,vVetCab,vVetRca,cTitulo,lOrde1C)
	Local cMensa   := Space(1),nOpc := 0,nx,ni
	Local aListPad := {}, aHeaCam := {}, aCampos := {}, vVetRe := {}
	Local lOrd1Co  := If(lOrde1C = NIL,.T.,lOrde1C)
	Local aMatDad  := If(lOrd1Co,aSort(aMatrDa,,,{|x,y| x[1] < y[1]}),Aclone(aMatrDa))

	If Empty(aMatDad)
		cMensa := STR0006
	ElseIf Empty(vVetCab)
		cMensa := STR0007
	ElseIf Empty(vVetRca)
		cMensa := STR0008
	ElseIf Len(vVetCab) <> Len(aMatDad[1])
		cMensa :=STR0009
	ElseIf Len(vVetRca) > Len(aMatDad[1])
		cMensa := STR0010
	Else
		For nx := 1 To Len(vVetRca)
			If vVetRca[nx] > Len(aMatDad[1])
				cMensa := STR0011
				Exit
			EndIf
		Next nx
	EndIf

	If !Empty(cMensa)
		Alert(cMensa)
		Return .f.
	EndIf

	For nx := 1 To Len(vVetCab)
		Aadd(aCampos,{vVetCab[nx],aMatDad[1,nx]})
	Next nx

	Aeval(aCampos,{|aElem|Aadd(aHeaCam,aElem[1])})

	For nx := 1 To Len(aMatDad)
		Aadd(aListPad,aMatDad[nx])
	Next nx

	DEFINE DIALOG oDlgF TITLE cTitulo From 12,60 To 36,122 OF oMainWnd
	oLBrowse := TWBrowse():New(0,1,230,160,,aHeaCam,,oDlgF,,,,,,,,,,,,.T.)
	oLBrowse:SetArray(aListPad)
	cBloco := "{|| { "
	For nI := 1 To (Len(aListPad[1])-1)
		If nI > 1
			cBloco += ","
		EndIf
		cBloco += "aListPad[oLBrowse:nAt,"+StrZero(nI,2)+"]"
	Next

	cBloco += " }}"
	oLBrowse:bLine := &(cBloco)
	oLBrowse:bLDblClick := {||(nOpc := 1,nReg := oLbrowse:nAt,oDlgF:End())}

	DEFINE SBUTTON oBtn1 FROM 165,10 TYPE 1 ACTION (nOpc := 1,nReg := oLbrowse:nAt,oDlgF:End()) ENABLE OF oDlgF
	DEFINE SBUTTON oBtn2 FROM 165,40 TYPE 2 ACTION (nOpc := 0,oDlgF:End()) ENABLE OF oDlgF
	ACTIVATE MSDIALOG oDlgF

	If nOpc = 1
		If Len(vVetRca) = 1
			cRetor := aListPad[nReg,vVetRca[1]]
		Else
			For nx := 1 To Len(vVetRca)
				Aadd(vVetRe,aListPad[nReg,vVetRca[nx]])
			Next nx
		EndIf
	Else
		Return cMensa
	EndIf
Return If(Len(vVetRca) = 1,cRetor,vVetRe)


static Function AGR960FORM(cTitF,cFormu,cF3,cFuncV,nTamV)
	Local oDlg
	Private oForMemo,oCampC,oExpres,oBtn01,oBtn02,oBtn03,oBtn04,oBtn05,oBtn06,oBtnAd,oBtnLi,oBtnDe
	Private aSize    := MsAdvSize(,.f.,430),aObjects := {}
	Private cFormula := Space(Len(cFormu))
	Private cCampCC  := Space(nTamV)
	Private cVariavel := Space(nTamV)
	Private cForMemo := If(cFormu <> Nil .And. !Empty(cFormu),Alltrim(cFormu),'')
	Private nTamC    := nTamV
	Private cExpres  := 0
	Private nOperac  := 1
	Private nTamco   := 13
	Private nTamde   := 3
	Private aForMemo := {}
	Private lAltera  := .t.
	Private aForMemV := {},oForMemV
	Private cForMemA := If(cFormu <> Nil .And. !Empty(cFormu),cFormu,'')
	Private cForMemV := AGR960MFOR(cForMemA)

	Aadd(aObjects,{200,200,.t.,.f.})
	aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)
	nOpca   := 0
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0022+" - "+cTitF) From aSize[7]+250,350 To aSize[6]-80,aSize[5]-200 COLOR CLR_BLACK,CLR_WHITE OF oMainWnd PIXEL
	//-400
	@ 08,008 Say OemToAnsi(STR0023)                   Of oDlg Pixel
	@ 08,050 MSGET oCampC Var cCampCC      Size 100,09 Valid If(Empty(cCampCC),.t.,&(cFuncV)) Picture "@!" F3 cF3 Of oDlg Pixel When lAltera
	@ 20,008 Say OemToAnsi(STR0024)Of oDlg Pixel
	@ 20,050 MSGET oExpres Var cExpres     Size 100,09 Valid AGRRETTRUE() Picture "@E 999,999,999.999" Of oDlg Pixel When lAltera

	@ 008,160 Button oBtn01 Prompt "+"     Size 10,10 Of oDlg Pixel Action AGR960FADD("+",1);oBtn01:cToolTip := STR0025
	@ 008,171 Button oBtn02 Prompt "-"    Size 10,10 Of oDlg Pixel Action AGR960FADD("-",1);oBtn02:cToolTip := STR0026
	@ 019,160 Button oBtn03 Prompt "*"     Size 10,10 Of oDlg Pixel Action AGR960FADD("*",1);oBtn03:cToolTip := STR0027
	@ 019,171 Button oBtn04 Prompt "/"     Size 10,10 Of oDlg Pixel Action AGR960FADD("/",1);oBtn04:cToolTip := STR0028
	@ 008,182 Button oBtn05 Prompt "("     Size 10,10 Of oDlg Pixel Action AGR960FADD("(",2);oBtn05:cToolTip := STR0029
	@ 019,182 Button oBtn06 Prompt ")"     Size 10,10 Of oDlg Pixel Action AGR960FADD(")",3);oBtn06:cToolTip := STR0030
	@ 034,008 Button oBtnAd Prompt STR0031 Size 40,11 Of oDlg Pixel Action AGR960FADD(,4) ;oBtnAd:cToolTip := STR0032
	@ 034,058 Button oBtnLi Prompt STR0034 Size 40,11 Of oDlg Pixel Action AGR960LIMP() ;oBtnLi:cToolTip := STR0033
	@ 034,108 Button oBtnDe Prompt STR0035 Size 40,11 Of oDlg Pixel Action AGR960FDES() ;oBtnDe:cToolTip := STR0036

	@ 048,008 Get oForMemV Var cForMemV Of oDlg Memo Size 285,55 Pixel Font oDlg:oFont Color CLR_BLACK,CLR_HGRAY When .f.

	AGR960DBTN(.t.)
	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{||nOpca:=1,If(!AGR960CHK(cForMemo),nOpca := 0,oDlg:End())},{||oDlg:End()}) CENTERED
Return {nOpca,cForMemo}


static Function AGR960FADD(cOper,nTipo)
	Local cMsg := STR0037
	Local cCodta := ""

	If cOper == Nil
		If !Empty(cCampCC)
			If Len(cForMemo+'@'+Alltrim(cVariavel)+'@') > 250
				MsgInfo(cMsg)
				Return .f.
			Endif
			cCodta :=  Posicione("NPU",2,xFilial("NPU")+cVariavel,"NPU_CODTA")
			cForMemo += '@'+Alltrim(cCodta+';'+cVariavel)+'@ '
			cForMemV += Alltrim(cCampCC)
			cCampCC  := Space(nTamC)
			aAdd(aForMemo,{cForMemo,nOperac})
			aAdd(aForMemV,{cForMemV,nOperac})

		ElseIf !Empty(cExpres)
			If Len(cForMemo+'#'+Alltrim(Str(cExpres,nTamco,nTamde))+'#') > 250
				MsgInfo(cMsg)
				Return .f.
			Endif
			aAdd(aForMemo,{cForMemo,nOperac})
			cForMemo += '#'+Alltrim(Str(cExpres,nTamco,nTamde))+'# '
			cForMemV += Alltrim(Str(cExpres,nTamco,nTamde))
			cExpres  := 0
		Else
			Return .t.
		Endif
	Else
		If Len(cForMemo+cOper) > 250
			MsgInfo(cMsg)
			Return .f.
		Endif
		aAdd(aForMemo,{cForMemo,nOperac})
		aAdd(aForMemV,{cForMemV,nOperac})

		cForMemo += cOper +" "
		cForMemV += cOper +" "
	Endif

	nOperac := nTipo
	AGR960DBTN(.f.)
	oForMemV:Refresh()
Return .t.

static Function AGR960FDES()
	If Len(aForMemo) > 0
		cForMemo := aForMemo[Len(aForMemo),1]
		nOperac  := aForMemo[Len(aForMemo),2]
		aDel(aForMemo,Len(aForMemo))
		aSize(aForMemo,Len(aForMemo)-1)

		cForMemV := aForMemV[Len(aForMemV),1]
		nOperac  := aForMemV[Len(aForMemV),2]
		aDel(aForMemV,Len(aForMemV))
		aSize(aForMemV,Len(aForMemV)-1)
		AGR960DBTN(.f.)
	Endif
	oForMemV:Refresh()
Return .t.

static Function AGR960LIMP()
	aForMemo := {}
	aForMemV := {}
	cForMemo := ""
	cForMemV := ""
	nOperac  := 1
	AGR960DBTN(.f.)
	oForMemV:Refresh()
Return .t.


Function AGR960MFOR(cFormul)
	local cForm, cTipoA, cVari
	local nPos1 := 0

	cFormul:=StrTran(cFormul,'#','')
	While .t.
		nPos1 := At("@",cFormul)
		If nPos1 > 0
			nPos2 := At("@", Substr(cFormul,nPos1+1) )
			If nPos2 > 0
				cForm:=Alltrim(SubStr(cFormul,nPos1+1,nPos2-1))
				cVari:=SubStr(cForm,At(";",cForm)+1)
				cTipoA:=SubStr(cForm,0,At(";",cForm)-1)
				cFormul:=StrTran(AllTrim(cFormul),"@"+ ALLtrim(cForm) +"@", Alltrim(Posicione("NPU",1,xFilial("NPU")+cTipoA+cVari,"NPU_DESVA")))
			end
		Else
			EXIT
		EndIf
	end
Return cFormul


/*
+=================================================================================================+
| Programa  : AGR960DBTN                                                                        |
| Descrição : Habilitação dos botões                                                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 26/02/2015                                                                          |
+=================================================================================================+
| Retorna   : lLoad - Habilita/Desabilita                                              Obrigatório|
|=================================================================================================+
|Referências : AGRFORMULA                                                                         |
+=================================================================================================+
*/
static Function AGR960DBTN(lLoad)
	Local cComp
	oBtn01:Disable()
	oBtn02:Disable()
	oBtn03:Disable()
	oBtn04:Disable()
	oBtn05:Disable()
	oBtn06:Disable()
	oBtnAd:Disable()
	oBtnLi:Disable()
	oBtnDe:Disable()

	If !lAltera
		Return
	Endif

	If !Empty(cForMemo)
		oBtnLi:Enable()
	Endif
	If Len(aForMemo) > 0
		oBtnDe:Enable()
	Endif

	If lLoad
		cComp := Alltrim(cForMemo)
		cComp := Substr(Alltrim(cForMemo),Len(cComp),1)
		If cComp $ "-+/*"
			nOperac:= 1
		ElseIf cComp == "("
			nOperac:= 2
		ElseIf cComp == ")"
			nOperac:= 3
		ElseIf cComp $ "#@"
			nOperac:= 4
		Endif
	Endif

	//Verifica a operacao e habilita os botoes
	If nOperac < 3 //= 1,2
		oBtn05:Enable()
		oBtnAd:Enable()
	ElseIf nOperac > 2 //3 f. paren.. 4 Adiciona
		oBtn01:Enable()
		oBtn02:Enable()
		oBtn03:Enable()
		oBtn04:Enable()
		If AGR960CORP("(") > AGR960CORP(")")
			oBtn06:Enable()
		Endif
	EndIf
Return

/*
+=================================================================================================+
| Programa  : AGR960CORP                                                                          |
| Descrição : Contador de parenteses                                                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 26/02/2015                                                                          |
+=================================================================================================+
| Retorna   : cSimb - Símbolo (  )                                                     Obrigatório|
|=================================================================================================+
|Referências : AGRFORMULA                                                                         |
+=================================================================================================+
*/
Static Function AGR960CORP(cSimb)
	Local nPos,nCont := 0,cTexto := Alltrim(cForMemo)
	While !Empty(cTexto)
		nPos := AT(cSimb,cTexto)
		If nPos == 0
			cTexto := ""
			exit
		Else
			nCont++
			cTexto := Substr(cTexto,nPos+1)
		Endif
	End
Return nCont

/*
+=================================================================================================+
| Programa  : AGRFOCHK                                                                            |
| Descrição : Validação final da composição da fórmula                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 26/02/2015                                                                          |
+=================================================================================================+
| Retorna   : cForMemo - Composição da fórmula                                         Obrigatório|
+=================================================================================================+
|Referências : AGRFORMULA                                                                         |
+=================================================================================================+
*/
static Function AGR960CHK(cForMemo)
	Local cMemoC := StrTran(cForMemo,Chr(10),""),cRmemo := ""
	Local nPos1,nPos2,nx,nQtdeA := 0,nQtdeB := 0,nCol := 1
	Local aForCalc := {},lRet := .t.

	//separa os campos/colunas
	While !Empty(cMemoC)
		nPos1 := AT("@",cMemoC)
		If nPos1 > 0
			nPos2 := AT("@",Substr(cMemoC,nPos1+1))
			If nPos2 > 0
				cRmemo += Substr(cMemoC,1,nPos1-1)+'1'
				cMemoC := Substr(cMemoC,nPos1+nPos2+1)
			Else
				Exit
			Endif
		Else
			cRmemo += cMemoC
			Exit
		EndIf
	End

	// separa os valores fixos
	cMemoC := cRmemo
	cRmemo := ""
	While !Empty(cMemoC)
		nPos1 := AT("#",cMemoC)
		If nPos1 > 0
			nPos2 := AT("#",Substr(cMemoC,nPos1+1))
			If nPos2 > 0
				cRmemo += Substr(cMemoC,1,nPos1-1)+'2'
				cMemoC := Substr(cMemoC,nPos1+nPos2+1)
			Else
				Exit
			Endif
		Else
			cRmemo += cMemoC
			Exit
		EndIf
	End

	// Quantidade de abre e fecha parenteses
	For nx := 1 to Len(cRmemo)
		If(Substr(cRmemo,nx,1) = "(",nQtdeA++,If(Substr(cRmemo,nx,1) = ")",nQtdeB++,""))
	Next nx

	If nQtdeA <> nQtdeB
		MsgInfo(STR0039 +_CRLF+" ( ...: "+Alltrim(Str(nQtdeA))+"   ) ...: "+Alltrim(Str(nQtdeB)))
		Return .f.
	EndIf

	//Sintaxe da fórmula
	aForCalc := {}
	cMemoC   := cRmemo
	nCol     := 1
	While !Empty(cMemoC)
		nPosA := AT("(",Substr(cMemoC,nCol))
		nPosB := AT(")",Substr(cMemoC,nCol))
		If nPosA > 0 .and. nPosB > 0
			nPosC := AT("(",Substr(cMemoC,nCol+nPosA))
			If nPosA+nPosC >= nPosB .or. nPosC = 0
				aAdd(aForCalc,Substr(cMemoC,nCol+nPosA,nPosB-nPosA-2))
				cMemoC := Substr(cMemoC,1,nCol+nPosA-2)+"1"+Substr(cMemoC,nCol+nPosB)
				nCol   := 1
			Else
				nCol := nCol+nPos2a
				Loop
			Endif
		Else
			aAdd(aForCalc,cMemoC)
			cMemoC := ""
			Exit
		Endif
	End

	For nx := 1 To Len(aForCalc)
		cMemoC := aForCalc[nx]
		nPosCh := 1
		nOpUlt := 0 //1 = Valor, 2 = Operador
		cMensa := " "
		While nPosCh <= Len(cMemoC)
			If Empty(Substr(cMemoC,nPosCh,1))
				nPosCh++
				Loop
			Endif
			If nOpUlt = 0
				If Substr(cMemoC,nPosCh,1) $ "12"
					nOpUlt := 1
				Else
					cMensa :=  STR0040+" "+STR0041+" "+STR0042
					Exit
				Endif
			ElseIf nOpUlt = 2
				If Substr(cMemoC,nPosCh,1) $ "12"
					nOpUlt := 1
				Else
					cMensa := STR0043+_CRLF+STR0044
					Exit
				Endif
			ElseIf nOpUlt = 1
				If Substr(cMemoC,nPosCh,1) $ "+-/*"
					nOpUlt := 2
				Else
					cMensa := STR0045+_CRLF+STR0046
					Exit
				Endif
			Endif
			nPosCh++
		End

		If !Empty(cMensa)
			MsgInfo(cMensa,STR0047)
			lRet := .f.
			Exit
		EndIf

		If nOpUlt == 2
			MsgInfo(STR0040+" "+STR0048+" "+STR0042,STR0047)
			Return .f.
		Endif
	Next nx

Return lRet
/*
+=================================================================================================+
| Programa  : AGRA960ORDB                                                                         |
| Descrição : Ordena colunas do Browse                                                            |
| Autor     : Joaquim Burjack                                                                     |
| Data      : 16/07/2015                                                                          |
+=================================================================================================+
*/
Static Function AGRA960ORDB( )
	Local nColuna   := oBrowse:ColPos()
	local nIndice
	dbSelectArea(carqTRBL)
	For nIndice := 1 to len(aCol)
		if nIndice = nColuna
			cArqInd:=CriaTrab(Nil,.F.)
			cChave:=aCol[nIndice][2]
			IndRegua(carqTRBL,cArqInd,cChave,,,"Ordenando Registros")
			#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF
			(carqTRBL)->(dbGotop())
			oBrowse:Refresh()
		endif
	Next nIndice
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA960
Funçao que Verifica se deve ou não aprovar o lote de acordo com
os vrs. cadastrados nas Variaves do tipo de analise, quando for um
Layout Oficial
@author Emerson Coelho
@since 29/04/2013
/*/
//-------------------------------------------------------------------

Static Function fAprvLote( cLote ,cCodSaf, cCodPro )
	Local aAreaAtu:= GetArea()
	Local aAreaSB8:= SB8->( Getarea() )
	Local aAreaNP9:= NP9->( GetArea() )
	local cQuery:= GetNextAlias()
	//-- Vars. Faz Parte SQl
	Local cNPX_OFI:= '2'//Indica que Layout é Oficial
	Local cNPX_ATIVO:= '1'//Indica que Res.Analise Está Ativo
	Local cNPX_IR:= '2'//Indica que a Variavel da Analise compoe o Calculo de aprovacao

	//Var Auxiliares
	Local cCond:=''
	Local dDtVlidade:= ctod('//')
	Local nResultado:=''
	Local lAprovLote:= .f.//Identifica se devo Aprovar ou Reprovar o Lote
	Local lAProva:= .t.//Indica se Lote está Aprovado ou Reprovado


	// Este select retorna todas as variaveis do resultado de analise, que stão ativas, que são
	// de um Layout Oficial e  que fazem parte da regra de aprovação do lote;

	BeginSql Alias cQuery
	SELECT NPX.*,
	NPU.NPU_TIPOVA,
	NPU.NPU_COND,
	NPU.NPU_EXPR
	FROM %table:NPX% NPX
	INNER JOIN %table:NPU% NPU
	ON NPU.NPU_FILIAL = %exp:fWXfilial('NPU')%
	AND NPU.NPU_CODTA  = NPX.NPX_CODTA
	AND NPU.NPU_CODVA  = NPX.NPX_CODVA
	AND NPU.%NotDel%
	WHERE NPX.NPX_FILIAL 	= %exp:fWXfilial('NPX')%
	AND NPX.NPX_LOTE  	= %exp:cLote%
	AND NPX.NPX_CODSAF 	= %exp:cCodSaf%
	AND NPX.NPX_CODPRO 	= %exp:cCodPro%
	AND NPX.NPX_OFI 		= %exp:cNPX_OFI%
	AND NPX.NPX_ATIVO 	= %exp:cNPX_ATIVO%
	AND NPX.NPX_IR 		= %exp:cNPX_IR%
	AND NPX.%NotDel%
	EndSQL


	( cQuery )->( DbGoTop() )

	While ( cQuery )->(! Eof() )

		//Logica Baseada na função que já existe no AGRA930()

		IF ( cQuery )->NPU_TIPOVA == '3'  //Indica que eh a Data de validade do Lote
			dDtVlidade := sToD( ( cQuery )->NPX_RESDTA ) + ( cQuery )->NPU_EXPR
			/*Case ( cQuery )->NPU_TIPOVA == '2'         Segundo Maicol até esse momento uma var texto nao pode dizer se aprova ou nao
			cResultado:= ( cQuery )->NPX_RESTXT*/
		ElseIF ( cQuery )->NPU_TIPOVA == '1'// Tipo Numerica
			nResultado:=  ( cQuery )->NPX_RESNUM
			lAprovLote := .t.
			nPadrao :=  ( cQuery )->NPU_EXPR
			// condição matematica
			Do Case
				Case ( cQuery )->NPU_COND = '1' //1=Igual a;
				cCOnd:= '=='
				Case ( cQuery )->NPU_COND = '2' //2=Diferente de;
				cCOnd:= '<>'
				Case ( cQuery )->NPU_COND = '3' //3=Menor que;
				cCOnd:= '<'
				Case ( cQuery )->NPU_COND = '4' //4=Menor ou igual que;
				cCOnd:= '<='
				Case ( cQuery )->NPU_COND = '5' //5=Maior que;
				cCOnd:= '>'
				Case ( cQuery )->NPU_COND = '6' //6=Maior ou igual que
				cCOnd:= '>='
			EndCase

			//Verifica se o Resultado da Variavel está dentro de esperado
			IF !&( alltrim(str( nResultado ) ) +@cCond + alltrim( str(nPadrao) ) )
				lAprova := .F.
			Else
				lAprova := .T.
			Endif

			IF lAprova == .f.// Se uma das Vars. que aprova Falhar ele reprova o Lote (Maicol disse q hj stah assim)
				Exit
			EndIF
		EndIF

		( cQuery )->( DbSkip() )
	EndDo

	( cQuery )->( DbCloseArea() )

	IF !Empty( dDtVlidade ) .or. lAprovLote   // Indica que tenho que Atualizar ou Dt.Validade do lote ou se Devo aprovar/Reprovar

		Begin Transaction

			DbselectArea("NP9")
			NP9->(dbSetOrder(1))
			IF NP9->( DbSeek(xFilial("NP9") + cCodSaf + cCodPro + cLote) )
				RecLock("NP9",.F.)
				IF !Empty( dDtVlidade )// Indica que Atualiza a Data de Validade
					NP9->NP9_DTVAL := dDtVlidade
				EndIF

				IF lAprovLote // Indica que deve Aprovar ou Reprovar o Lote
					Do Case
						Case lAprova//Indica que Lote Foi Aprovado
						NP9->NP9_STATUS :='2'// Status 2 - Disponivel
						AGRGRAVAHIS(,,,,{"NP9",xFilial("NP9")+NP9->NP9_CODSAF+NP9->NP9_PROD+NP9->NP9_LOTE,"A",'Aprovado via Boletim Oficial'})
						OtherWise//Indica que Reprova
						NP9->NP9_STATUS :='3'// Status 3 - Rejeitado CQ
						AGRGRAVAHIS(,,,,{"NP9",xFilial("NP9")+NP9->NP9_CODSAF+NP9->NP9_PROD+NP9->NP9_LOTE,"C",'Reprovado via Boletim Oficial'})
					EndCase
				EndIF

				NP9->( MsUnlock() )

				IF !Empty( dDtVlidade ) // Indica que Atualiza a Data de Validade
					DbselectArea("SB8")
					SB8->(dbSetOrder(5))
					IF SB8->( DbSeek(xFilial("SB8") + cCodPro + cLote) )
						RecLock("SB8",.F.)
						SB8->B8_DTVALID := dDtVlidade
						SB8->( MsUnlock() )
					EndIF
				EndIF
			EndIF
		End Transaction
	EndIF

	Restarea( aAreaNP9 )
	RestArea( aAreaSB8 )
	RestArea( aAreaAtu )

Return( lAprovLote )

/*
+=================================================================================================+
| Programa  : AGRA960LA                                                                           |
| Descrição : Validação se usuario tem permissão para Alterar/Visualizar o Resultado Laboratorial |
| Autor     : Ana Laura Olegini                                                                   |
| Data      : 18/08/2015                                                                          |
+=================================================================================================+
*/
Function AGRA960LA()
	Local cCodLay := cGetLayout
	Local cCodUsu := RetCodUsr()
	Local lRet   := .F.

	DBSELECTAREA("NKV")
	DBSETORDER(1)
	If !DBSEEK(xFilial("NKV")+cCodUsu+cCodLay)
		AGRHELPNC(STR0049,STR0050) //"Usuário sem permissão para alterar/visualizar layout."###"Cadastrar usuário para o layout."
		lRet := .F.
	ElseIf !Empty(NKV->NKV_TIPO)
		lRet := .T.
	Else
		AGRHELPNC(STR0049,STR0050) //"Usuário sem permissão para alterar/visualizar layout."###"Cadastrar usuário para o layout."
		lRet := .F.
	EndIf

Return(lRet)

/*
############################################################################
# Função   : AGR960APR                                                     #
# Descrição: Aprovação dos Lotes                                           #
# Autor    : Ana Laura Olegini    Refeito Inácio Luiz Kolling 23/09/15     #
# Data     : 24/08/2015                                                    #
############################################################################
*/
Function AGR960APR()
	AGRIFDBSEEK("NP9",cGetSafra+(carqTRBL)->NP9_PROD+(carqTRBL)->NP9_LOTE,1,.T.)
	If NP9->NP9_STATUS = "1" .Or. NP9->NP9_STATUS = "3" //AGUARDANDO RESULTADO LABORATORIAL OU REJEITADO CQ
		If AGRGRAVAHIS(STR0052,"NP9",xFilial("NP9")+cGetSafra+(carqTRBL)->NP9_PROD+(carqTRBL)->NP9_LOTE,"A") = 1  //"Aprovar"
			//NP9_FILIAL+NP9_CODSAF+NP9_PROD+NP9_LOTE
			AGRTRAVAREG("NP9",.F.)
			NP9->NP9_STATUS := "2"
			AGRDESTRAREG()
		EndIf
	Else
		MSGINFO(STR0055)	//"Resultado já aprovado!"
		Return
	EndIf
Return

/*
############################################################################
# Função   : AGR960REJ                                                     #
# Descrição: Rejeição dos Lotes                                            #
# Autor    : Ana Laura Olegini     Inácio Luiz Kolling - 23/09/2015        #
# Data     : 24/08/2015                                                    #
############################################################################
*/
Function AGR960REJ()
	AGRIFDBSEEK("NP9",cGetSafra+(carqTRBL)->NP9_PROD+(carqTRBL)->NP9_LOTE,1,.T.)
	If NP9->NP9_STATUS $ "3" //= 3 REJEITADO
		Alert(STR0056) //"Resultado já rejeitado!"###"Não é possível rejeitar pois o resultado já foi descartado."###"Finalizado"
	Else
		If AGRGRAVAHIS(STR0053,"NP9",xFilial("NP9")+cGetSafra+(carqTRBL)->NP9_PROD+(carqTRBL)->NP9_LOTE,"R") = 1 //"Rejeitar"
			AGRTRAVAREG("NP9",.F.)
			NP9->NP9_STATUS := "3"
			AGRDESTRAREG()
			AGRATSTAFILHO()
		EndIf
	EndIf
Return

/*
############################################################################
# Função   : AGR960HIS                                                     #
# Descrição: Mostra em tela o Historico de aprovações e rejeições          #
# Autor    : Ana Laura Olegini   Inácio Luiz Kolling 18/02/2015            #
# Data     : 24/08/2015                                                    #
############################################################################
*/
Function AGR960HIS()
	Local nChaTam	:= TAMSX3("NK9_CHAVE")[1]
	Local cChaveI 	:= Alltrim(xFilial('NP9')+cGetSafra+(carqTRBL)->NP9_PROD+(carqTRBL)->NP9_LOTE)
	Local cChaveA 	:= cChaveI+Space(nChaTam-Len(cChaveI))

	AGRHISTTABE("NP9",cChaveA)
Return
