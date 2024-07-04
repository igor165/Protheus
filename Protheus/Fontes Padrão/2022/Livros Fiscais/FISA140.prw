#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "FISA140.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA140
 
@author Marsaulo D. de Souza
@since 04/08/2017
@version Branch Unica

/*/
//-------------------------------------------------------------------
Function FISA140()
Local	oBrw	:= FWmBrowse():New()
Private lGrupos	:= ValidF3K()

IF AliasInDic( "F3K" )
	If !ValidF3K(.T.)
		Help("",1,"Help","Help",STR0024,1,0)//Ambiente desatualizado, favor executar o UPDDISTR com o ultimo pacote de expedição do fiscal disponivel no portal do cliente!
	EndIf
	oBrw:SetDescription(STR0001)
	oBrw:SetAlias( 'F3K')
	oBrw:SetMenuDef( 'FISA140' )
	oBrw:Activate()
Else
	Help("",1,STR0003,STR0003,STR0002,1,0)	//"Tabela F3K nao cadastrada no sistema"
Endif

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Marsaulo D. de Souza
@since 04/08/2017
@version Branch Única
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   

Local aRotina  		:= {}

ADD OPTION aRotina TITLE STR0004		ACTION 'VIEWDEF.FISA140' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0005		ACTION 'VIEWDEF.FISA140' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0006		ACTION 'VIEWDEF.FISA140' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0007		ACTION 'VIEWDEF.FISA140' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0020		ACTION 'A140Facil'       OPERATION 3 ACCESS 0 // Facilitador
			
Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marsaulo D. de Souza
@since 04/08/2017
@version Branch Única
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
local lCST		:= F3K->(FieldPos("F3K_CST")) > 0
Local lCodRef 	:= F3K->(FieldPos("F3K_CODREF")) > 0
Local lApurRS 	:= GetNewPar("MV_GIAEFD",.F.)
Local lReflex   := lCST .And. lCodRef .And. !lApurRS 
Local oStruF3K 	:= FWFormStruct( 1, 'F3K',{ |cCampo| CompStru(cCampo) })
Local oStruF3K2 := FWFormStruct( 1, 'F3K',{ |cCampo| CompStru(cCampo,1) })
Local oModel	:= Nil
Local lIndex    := At("F3K_CODLAN",F3K->(IndexKey(1))) > 0

oModel	:=	MPFormModel():New('FISA140',,{ |oModel| ValidForm(oModel) } )

//Adiciona a estrutura da F3K
oModel:AddFields( 'MODEL_F3K' , /*cOwner*/ , oStruF3K )
oModel:AddGrid( 'F3KDETAIL','MODEL_F3K', oStruF3K2)

If ValidF3K()
	oModel:SetRelation( "F3KDETAIL" , { { "F3K_FILIAL" , 'xFilial("F3K")' },{ "F3K_PROD" , "F3K_PROD" },{ "F3K_GRCLAN" , "F3K_GRCLAN" },;
										{ "F3K_GRPLAN" , "F3K_GRPLAN" },{ "F3K_GRFLAN" , "F3K_GRFLAN" }},  F3K->( IndexKey(1)) )

	oStruF3K:SetProperty('F3K_PROD'	, MODEL_FIELD_OBRIGAT	, .F. ) //Retira a obrigatoriedade do campo
	oStruF3K:SetProperty('F3K_PROD'	, MODEL_FIELD_VALID		, {|| Vazio().Or.ExistCpo('SB1') }) //Permite deixar em branco o campo
	If lIndex
		oModel:SetPrimaryKey({"F3K_FILIAL","F3K_CFOP","F3K_CST","F3K_PROD","F3K_CODAJU","F3K_GRCLAN", "F3K_GRPLAN", "F3K_GRFLAN","F3K_CODLAN"})
	Else
		oModel:SetPrimaryKey({"F3K_FILIAL","F3K_CFOP","F3K_CST","F3K_PROD","F3K_CODAJU","F3K_GRCLAN", "F3K_GRPLAN", "F3K_GRFLAN"})
	EndIF	
	
Else
	oModel:SetRelation( "F3KDETAIL" , { { "F3K_FILIAL" , 'xFilial("F3K")' },{ "F3K_PROD" , "F3K_PROD" } }, F3K->( IndexKey(1)))
	oModel:SetPrimaryKey({})
EndIf

If lCST
	If lIndex .And. ValidF3K()
		oModel:GetModel('F3KDETAIL'):SetUniqueLine({"F3K_CFOP","F3K_CODAJU","F3K_CST","F3K_CODLAN"})
	Else
		oModel:GetModel('F3KDETAIL'):SetUniqueLine({"F3K_CFOP","F3K_CODAJU","F3K_CST"})
	EndIF	
Else
	If lIndex .And. ValidF3K()
		oModel:GetModel('F3KDETAIL'):SetUniqueLine({"F3K_CFOP","F3K_CODAJU","F3K_CODLAN"})
	Else
		oModel:GetModel('F3KDETAIL'):SetUniqueLine({"F3K_CFOP","F3K_CODAJU"})
	EndIF
Endif

oModel:GetModel('MODEL_F3K'):SetDescription(STR0001)

If lReflex
	oStruF3K2:SetProperty('F3K_CODREF'	, MODEL_FIELD_OBRIGAT, .T. )
	oStruF3K2:SetProperty('F3K_CST'	, MODEL_FIELD_OBRIGAT, .T. )
Endif

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marsaulo D. Souza
@since 04/08/2017
@version Branch Unica
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FwLoadModel("FISA140") //Chama função modelDef
Local oStruF3K := FwFormStruct(2,"F3K",{ |cCampo| CompStru(cCampo) }) 
Local oStruF3K2:= FwFormStruct(2,"F3K",{ |cCampo| CompStru(cCampo,1) })
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW_F3K',oStruF3K,'MODEL_F3K')
oView:AddGrid( 'VIEW_F3K2',oStruF3K2,'F3KDETAIL' )

oView:CreateHorizontalBox( 'SUPERIOR', 15 )
oView:CreateHorizontalBox( 'INFERIOR', 85 )
 
oView:SetOwnerView( 'VIEW_F3K', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_F3K2', 'INFERIOR' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CompStru

Função que retorna os campos do cabeçalho e rodapé do MVC

@author Desconhecido
@since 04/08/2017
@version 
/*/
//-------------------------------------------------------------------
Static Function CompStru( cCampo,n)
local lCST		:= F3K->(FieldPos("F3K_CST")) > 0
Local lCodRef 	:= F3K->(FieldPos("F3K_CODREF")) > 0
Local lApurRS 	:= GetNewPar("MV_GIAEFD",.F.)
Local lReflex   := lCST .And. lCodRef .And. !lApurRS 
Local lRet 		:= .F.
Local cCampSup 	:= 'F3K_FILIAL|F3K_PROD'
Local cCampInf 	:= 'F3K_CFOP|F3K_CODAJU|F3K_VALOR"

Default n := 0

If lCST
	cCampInf 	:= 'F3K_CFOP|F3K_CODAJU|F3K_VALOR|F3K_CST'
Endif

If lReflex
	cCampInf 	:= 'F3K_CFOP|F3K_CODAJU|F3K_CST|F3K_CODREF'
Endif

If ValidF3K()
	cCampSup+= "|F3K_GRCLAN|F3K_GRPLAN|F3K_GRFLAN"
	cCampInf+= "|F3K_IFCOMP|F3K_CODLAN"
EndIf

If n == 0 .And. Alltrim(cCampo) $ cCampSup //Superior
	lRet := .T.
EndIf

If n == 1 .And. Alltrim(cCampo) $ cCampInf // Inferior
	lRet := .T.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Função para fazer validações do formulário

@author Marsaulo D. Souza
@since 25/08/2017
@version Branch Unica

@param	oModel 					
@return lRet
/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

Local lRet		:= .T.
Local nOperation:= oModel:GetOperation()
Local cProd		:= oModel:GetValue ('MODEL_F3K','F3K_PROD') 
Local cCodAju	:= "" 
Local cCFOP		:= ""
Local cCST		:= ""
Local cGrpTrbPd	:= ""
Local cGrpTrbCl := ""
Local cGrpTrbFr := ""
Local oGrid     := oModel:GetModel("F3KDETAIL")
Local aCpoCab	:= {}
Local lCab		:= .F.
Local nR,nX		:= 0
Local nRecno    := F3K->(Recno())
Local nRecnoGrd := 0
Local nRecnoVld := 0
Local aAreaF3k	:= F3K->(GetArea())
Local lIndex    := At("F3K_CODLAN",F3K->(IndexKey(1))) > 0
Local lCST		:=  F3K->(FieldPos("F3K_CST")) > 0
Local lCodRef	:= F3K->(FieldPos("F3K_CODLAN")) > 0

If ValidF3K()
	cGrpTrbPd := oModel:GetValue ('MODEL_F3K','F3K_GRPLAN')
	cGrpTrbCl := oModel:GetValue ('MODEL_F3K','F3K_GRCLAN')
	cGrpTrbFr := oModel:GetValue ('MODEL_F3K','F3K_GRFLAN')

	aCpoCab:= {"F3K_PROD","F3K_GRCLAN","F3K_GRPLAN","F3K_GRFLAN"}

	For nR:=1 to Len(aCpoCab)
		If !Empty(oModel:GetValue ('MODEL_F3K',aCpoCab[nR]))
			lCab:= .T.
		EndIf
	Next nR
	If !lCab
		Help(,,'A140',,STR0023,1,0) //Preencha pelo menos um campo do cabeçalho!
		lRet:= lCab
	EndIf
EndIf

IF (nOperation == 3) .OR. (nOperation == 4) // Inclusão ou alteracao verificarei se ja existe registro da F3K gravado
	DbSelectArea("F3K")
	F3K->(DbSetOrder(1))
	For nX := 1 To oGrid:Length()//oGrid:GetQtdLine()
		oGrid:GoLine(nX)
		If !oGrid:IsDeleted()
			nRecnoGrd 	:= oGrid:GetDataID() //Retorna o R_E_C_N_O_
		 	cCodAju		:= oGrid:GetValue ('F3K_CODAJU')
		 	cCFOP		:= oGrid:GetValue ('F3K_CFOP')
			If lCST
				cCST	:= oGrid:GetValue ('F3K_CST')
			Endif
			If lIndex .And. ValidF3K()
				If lCodRef
					cCodLan	:= oGrid:GetValue ('F3K_CODLAN')
				Endif
			Else
				cCodLan:= ""
			EndIF
			If F3K->(DbSeek(xFilial("F3K")+cProd+cCFOP+cCodAju+cCST+cGrpTrbCl+cGrpTrbPd+cGrpTrbFr+cCodLan))
				If nOperation == 4 //Alteração
					nRecnoVld := F3K->(Recno())
					If nRecnoVld <> nRecnoGrd
						Help(" ", 1, "JAGRAVADO")
						lRet := .F.
					EndIf
				Else
					Help(,,'A140',,STR0010,1,0)
					lRet := .F.
				EndIf
				//Volta Recno posicionado na tela
				F3K->(DbGoTo(nRecno))
			Endif
		Endif
	Next
EndIF

RestArea(aAreaF3k)

Return lRet 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} A140Facil
Função que irá processar o Facilitador de cadastro.

@author Marsaulo D. Souza
@since 10/08/2017
@version Branch Unica
/*/
//------------------------------------------------------------------- 
Function A140Facil( cAlias, nOpc, nPosRot, lAutomato )

Local aCmp		:= {}
//Local cCmpExcl	:= "F3K_FILIAL/F3K_PROD/" // Campos que não serão apresentados para edição
Local nAlt		:= 0
Local nInc		:= 0
Local nX,nY		:= 0	
local lCancel	:= .F.
Local lEnd		:= .F.
Local oDlg		:=	Nil
Local aRetAuto	:= {}
Local nOpca		:= 0
Local cFiltro	:= ""
Local lCodRef 	:= F3K->(FieldPos("F3K_CODREF")) > 0
Local lApurRS 	:= GetNewPar("MV_GIAEFD",.F.)
Local cTexto	:= ""
Local nOper		:= 0
//---------------------------------------------------
// Alterado o escopo para utilização na MSGetDAuto()
//---------------------------------------------------
Private aHeader	:= {}
Private aCols	:= {}
Private N

Private lCST		:= F3K->(FieldPos("F3K_CST")) > 0
Private	lReflex 	:= lCST .And. lCodRef .And. !lApurRS
Private nDel		:= 0
Private oGetD		:=	Nil
Private aFiltroF3K	:= {}

Default lAutomato := .F.

If LockByName("A140Facil",.T.,.T.)
	
	#IFDEF TOP
		lTop 	:= .T.
	#ENDIF
	#IFNDEF TOP
		lTop	:= .F.
	#ENDIF
	
	//Irá buscar campos na SX3 da tabela F3K
	//Monta a tela com os campos disponíveis para edição do usuário no facilitador.		
	MontaHeader(aHeader,aCmp,lCST)
	If !lAutomato
		//Chama pergunta para montar o filtro do facilitador
		If Pergunte("ASA140", .T.)
			nOper := MV_PAR05
			If nOper <> 3
				If nOper == 1 //Alterar
					aFiltroF3K := FiltroF3k()
					If Len(aFiltroF3K) == 0
						Return .F.
					EndIf
				EndIf
				oDlg := MSDIALOG():New(000,000,340,600,STR0008,,,,,,,,,.T.)
				nOpc := GD_INSERT+GD_DELETE+GD_UPDATE
					
				@ 155,258 Button STR0012 Size 037,012 PIXEL OF oDlg ACTION (nOpca := 1,Iif(VlFldOk("TODOS"), oDlg:End(),.F.))
				@ 155,216 Button STR0017 Size 037,012 PIXEL OF oDlg ACTION (nOpca := 0, lCancel:=.T., oDlg:End())		
				oGetD:= MsNewGetDados():New(001,001,150,300, nOpc,"VlFldOk('LINHA')","AllwaysTrue()",,,000,99,,,,oDLG,aHeader,aCols)

				ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0,.F.)
				aCols := oGetD:aCols
			EndIf
		Else
			lCancel:=.T.
		EndIf
	Else
		//-----------------------------------------------------------------------------------------
		// Preenche dinamicamente as informações da grid de acordo com a execução do caso de testes
		//-----------------------------------------------------------------------------------------
		Pergunte("ASA140", .F.) 
		If FindFunction ("GetParAuto")
			aRetAuto := GetParAuto("FISA140TESTCASE")
			If MsGetDAuto( aRetAuto, "VlFldOk('LINHA')", { || VlFldOk("LINHA") }, /*aEnchAuto*/, nOpc, /*lClear*/)
				nOper := MV_PAR05
				nOpca := 1
			EndIf
		EndIf
	EndIf
	For nY := 1 To Len(aCols)			
		IF nOpca == 1 .And. !aCols[nY] [Len(aCols[nY])] .And. (!Empty(aCols[nY][1]) .And. ;
							!Empty(aCols[nY][2]) .And. !Empty(aCols[nY][3]) )
			//Percorre o array de campos para buscar o conteúdo no array da getdados
			For nX:= 1 to Len(aCmp)
				aadd(aCmp[nX][3],aCols[nY][nX])	
			Next nX				
		Endif
	Next nY
	
	//Monta o filtro para buscar no cadastro de Produtos conforme as informações do usuário na pergunta.
	cFiltro := "B1_POSIPI >= '" + StrTran(MV_PAR01,".","") + "' " + Iif(lTop, " AND ", " .AND. ") + " B1_POSIPI <= '" + StrTran(MV_PAR02,".","") + "' "
	
	cFiltro	+= Iif(lTop, " AND ", " .AND. ") + " B1_COD >= '" + Alltrim(MV_PAR03) + "' " + Iif(lTop," AND "," .AND. " ) + " B1_COD <= '" + Alltrim(MV_PAR04) + "' "
			
	cFiltro	+= Iif(!Empty(AllTrim(MV_PAR06)), Iif(lTop, " AND ", " .AND. ") + " B1_ORIGEM = '" + AllTrim(MV_PAR06) + "' ", "")
	
	cFiltro	+= Iif(!Empty(AllTrim(MV_PAR08)), Iif(lTop, " AND ", " .AND. ") + "B1_GRUPO >= '" + AllTrim(MV_PAR07) + "' " + Iif(lTop, " AND ", " .AND. ") + " B1_GRUPO <= '" + AllTrim(MV_PAR08) + "' ","")
	
	cFiltro	+= Iif(!Empty(AllTrim(MV_PAR10)), Iif(lTop, " AND ", " .AND. ") + "B1_GRTRIB >= '" + AllTrim(MV_PAR09) + "' " + Iif(lTop, " AND ", " .AND. ") + " B1_GRTRIB <= '" + AllTrim(MV_PAR10) + "' ","")
				
	IF (nOpca == 1 .AND. Len(aCmp[1][3]) > 0 .And. Len(aCmp[2][3]) > 0 .And. Len(aCmp[3][3]) > 0) .Or. nOper == 3
		If !lAutomato .And. nOper == 3 .And. !ApMsgYesNo(STR0021) //Deseja prosseguir com a exclusão do(s) produtos(s) filtrado(s)?
			lCancel := .T.
		Else
			//-----------------------------------------------------------------------------------
			// Se a execução for efetuada via robô de testes, não exibe a tela de processamento
			//-----------------------------------------------------------------------------------
			If !lAutomato
				Processa({|lEnd| ProcFacF3K(aCmp, cFiltro,nOper,@nAlt,@nInc,@lCancel,@lEnd)},,,.T.)
			Else
				ProcFacF3K( aCmp, cFiltro, nOper, @nAlt, @nInc, .F./*lCancel*/, .F./*lEnd*/, lAutomato )
			Endif
		EndIf
	Endif
	
	If !lAutomato .and. lCancel
		Alert(STR0018)
	Else
		//---------------------------------------------------------------------
		// Se a execução for efetuada via robô de testes, encapsula a mensagem
		//---------------------------------------------------------------------
		cTexto := STR0013 +Chr(13)+Chr(10) + Chr(13)+Chr(10) 
		cTexto += STR0014 +Alltrim(str(nInc)) +Chr(13)+Chr(10) + Chr(13)+Chr(10) 
		cTexto += STR0015 +Alltrim(str(nAlt)) +Chr(13)+Chr(10) + Chr(13)+Chr(10)
		cTexto += STR0022 +Alltrim(str(nDel))

		If !lAutomato
			MsgInfo(cTexto)
		Else
			Help( ,, 'ProcOK',,cTexto, 1, 0 ) 
		Endif				
	EndIF
	F3K->(DBGOTOP())		
	UnLockByName( 'A140Facil', .T. , .T. )
Else	
	Help("",1,STR0003,STR0003,STR0019,1,0) // "Facilitador já está em processamento em outra instância"
EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcFacF3K
Função que irá realizar cadastro na tabela F3K, através do facilitador de cadastro.

@param	aCmp		-> Array com os campos e valores informados pelo usuário para o processamento
		cFiltro		-> Filtro na SB1 informado pelo usuário
		nOper		-> Indica se irá alterar, incluir ou excluir um registro.
		nAlt		-> Contador de registros alterados
		nInc		-> Contador de registros incluídos
		lCancel		-> Variável para controle de cancelamento
		lEnd		-> Variável para controle de cancelamento
														

@return lRet 

@author Marsaulo D. Souza
@since 10/08/2017
@version Branch Unica
/*/
//------------------------------------------------------------------- 
Static Function ProcFacF3K(aCmp, cFiltro, nOper,nAlt,nInc,lCancel,lEnd, lAutomato)

Local lRet		:= .T.
Local cAliasSB1	:= "SB1"
Local cWhere	:= ""
Local nY		:= 0

Default lAutomato := .F.

DbSelectArea (cAliasSB1)
(cAliasSB1)->(DbSetOrder (1))

DbSelectArea("F3K")
F3K->(DbSetOrder(1)) //F3K_FILIAL+F3K_PROD+F3K_CFOP+F3K_CODAJU+F3K_CST+F3K_GRCLAN+F3K_GRPLAN+F3K_GRFLAN+F3K_CODLAN

#IFNDEF TOP

    cIndex	:= CriaTrab(NIL,.F.)
    cWhere	:= 'SB1_FILIAL=="'+xFilial ("SB1")+'" .AND. '
    cWhere	+= cFiltro	    

    IndRegua (cAliasSB1, cIndex, SB1->(IndexKey ()),, cWhere)
    nIndex := RetIndex(cAliasSB1)

	DbSetIndex (cIndex+OrdBagExt ())
	
	DbSelectArea (cAliasSB1)
    DbSetOrder (nIndex+1)

#ELSE
	cAliasSB1	:=	GetNextAlias()    	
    cWhere := "%" + cFiltro + "%"		
    
	BeginSql Alias cAliasSB1
		
		SELECT				
			SB1.B1_COD, SB1.B1_DESC				
		FROM 
			%Table:SB1% SB1 
		WHERE 					
			SB1.B1_FILIAL=%xFilial:SB1% AND
			%Exp:cWhere% AND
			SB1.%NotDel%			
	EndSql

#ENDIF

DbSelectArea (cAliasSB1)
(cAliasSB1)->(DbGoTop ())
If !lAutomato
	ProcRegua ((cAliasSB1)->(LastRec()))
EndIf

BEGIN TRANSACTION
	Do While !(cAliasSB1)->(Eof ())	
		
		If !lAutomato
		
			If Interrupcao(lEnd)
				lCancel := lEnd
				#IFDEF TOP
					DbSelectArea (cAliasSB1)
					(cAliasSB1)->(DbCloseArea ())
				#ENDIF
				#IFNDEF TOP
					RetIndex("SB1")
					FErase(cIndex+OrdBagExt ())
				#ENDIF
				
				Return 
			EndIf
		Endif
			
		IncProc(STR0016 + (cAliasSB1)->B1_COD)

		If nOper <> 3
			If F3K->(MsSeek(xFilial("F3K")+(cAliasSB1)->B1_COD))
				For	nY:= 1 to Len(aCmp[1][3])
					//Incluir
					If nOper == 2 .AND. !F3K->(MsSeek(xFilial("F3K")+(cAliasSB1)->B1_COD+aCmp[1][3][ny]+aCmp[2][3][ny]+IIF(lCST,aCmp[4][3][ny],"")))
						GrvFac("F3K",cAliasSB1,aCmp,@nInc,@nAlt,.T.,ny,nOper,lAutomato)
					//Editar
					ElseIf nOper == 1
						GrvFac("F3K",cAliasSB1,aCmp,@nInc,@nAlt,.F.,ny,nOper,lAutomato)
					EndIf
				Next nY
			Else
				//Registro não foi encontrado e será gravado na F3K
				For nY:= 1 to Len(aCmp[1][3])
					If !F3K->(MsSeek(xFilial("F3K")+(cAliasSB1)->B1_COD+aCmp[1][3][ny]+aCmp[2][3][ny]))
						GrvFac("F3K",cAliasSB1,aCmp,@nInc,@nAlt,.T.,ny,nOper,lAutomato)
					Endif
				Next
			EndIF
		Else
			//Exclusão
			GrvFac("F3K",cAliasSB1,aCmp,@nInc,@nAlt,.F.,ny,nOper,lAutomato)
		EndIf
		(cAliasSB1)->(DbSkip ())
	EndDo
END TRANSACTION

#IFDEF TOP
		DbSelectArea (cAliasSB1)
		(cAliasSB1)->(DbCloseArea ())
#ENDIF

#IFNDEF TOP
		RetIndex("SB1")
		FErase(cIndex+OrdBagExt ())
#ENDIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvFac
Função que irá gravar a F3K para o Facilitador.

@author Marsaulo D. Souza
@since 25/08/2017
@version Branch Unica
/*/
//------------------------------------------------------------------- 
Static Function GrvFac(F3K,cAliasSB1,aCmp,nInc,nAlt,lInclui,ny,nOper,lAutomato)
Local aAreaF3k	:= F3K->(GetArea())
Local cChave	:= xFilial("F3K")+(cAliasSB1)->B1_COD
Local nX		:= 0
Local cUpd		:= ""
Local nStatus	:= 0

Default lAutomato := .F.

If lInclui //Incluir
	RecLock("F3K",.T.)
	F3K->F3K_FILIAL := xFilial ("F3K")			
	F3K->F3K_PROD := (cAliasSB1)->B1_COD
	F3K->F3K_CFOP := aCmp[1][3][ny]					
	F3K->F3K_CODAJU := aCmp[2][3][ny]
	
	If Alltrim(aCmp[3][1]) == "F3K_VALOR"
		F3K->F3K_VALOR := aCmp[3][3][ny]
	Elseif Alltrim(aCmp[3][1]) == "F3K_CODREF"
		F3K->F3K_CODREF := aCmp[3][3][ny]
	Endif

	If lCST
		F3K->F3K_CST := aCmp[4][3][ny]
	Endif	

	MsUnLock()
	nInc++
Else
	If nOper == 1 .AND. lAutomato //Editar
		RecLock("F3K",.F.)
		F3K->F3K_FILIAL := xFilial ("F3K")			
		F3K->F3K_PROD := (cAliasSB1)->B1_COD
		F3K->F3K_CFOP := aCmp[1][3][ny]					
		F3K->F3K_CODAJU := aCmp[2][3][ny]
		
		If Alltrim(aCmp[3][1]) == "F3K_VALOR"
			F3K->F3K_VALOR := aCmp[3][3][ny]
		Elseif Alltrim(aCmp[3][1]) == "F3K_CODREF"
			F3K->F3K_CODREF := aCmp[3][3][ny]
		Endif

		If lCST
			F3K->F3K_CST := aCmp[4][3][ny]
		Endif		
		MsUnLock()
		nAlt++
	ElseIf nOper == 3 //Excluir
		F3k->(DbSetOrder(1))
		If F3K->(DbSeek(cChave))
			Do While !F3K->(Eof ()) .AND. cChave == F3K->F3K_FILIAL+F3K->F3K_PROD
				RecLock("F3K",.F.)
					F3K->(DbDelete())
				F3K->(MsUnLock())
				nDel++
				F3K->(DbSkip())
			EndDo
		EndIf
	ElseIf nOper == 1 .AND. !lAutomato //Editar
		cUpd :="UPDATE "+RetSqlName("F3K")+" SET "
		cUpd +="F3K_CFOP   = '"+aCmp[1][3][ny]+"',"+CRLF
		cUpd +="F3K_CODAJU = '"+aCmp[2][3][ny]+"',"+CRLF
		cUpd +="F3K_CST    = '"+aCmp[4][3][ny]+"',"+CRLF
		cUpd +="F3K_CODREF = '"+aCmp[3][3][ny]+"',"+CRLF
		cUpd +="F3K_IFCOMP = '"+aCmp[5][3][ny]+"',"+CRLF
		cUpd +="F3K_CODLAN = '"+aCmp[6][3][ny]+"'"+CRLF

		cUpd += "WHERE F3K_FILIAL 	= '"+xFilial("F3K")+"'"+CRLF
		cUpd += "AND F3K_PROD		= '"+(cAliasSB1)->B1_COD+"'"+CRLF
		cUpd += "AND D_E_L_E_T_		= ''"+CRLF
		For nX := 1 To Len(aFiltroF3K)
			DO CASE
				CASE nX == 1 .AND. !Empty(aFiltroF3K[nX]) //CFOP
					cUpd += "AND F3K_CFOP		= '"+Alltrim(aFiltroF3K[nX])+"'"+CRLF
				CASE nX == 2 .AND. !Empty(aFiltroF3K[nX]) //Cod.Val.Decl
					cUpd += "AND F3K_CODAJU		= '"+Alltrim(aFiltroF3K[nX])+"'"+CRLF
				CASE nX == 3 .AND. !Empty(aFiltroF3K[nX]) //CST
					cUpd += "AND F3K_CST		= '"+Alltrim(aFiltroF3K[nX])+"'"+CRLF
				CASE nX == 4 .AND. !Empty(aFiltroF3K[nX]) //Cod Reflexo
					cUpd += "AND F3K_CODREF		= '"+Alltrim(aFiltroF3K[nX])+"'"+CRLF
				CASE nX == 5 .AND. !Empty(aFiltroF3K[nX]) //Obs.Lanc.Fis
					cUpd += "AND F3K_IFCOMP		= '"+Alltrim(aFiltroF3K[nX])+"'"+CRLF
				CASE nX == 6 .AND. !Empty(aFiltroF3K[nX]) //Cod Lanc
					cUpd += "AND F3K_CODLAN		= '"+Alltrim(aFiltroF3K[nX])+"'"+CRLF
			EndCase
		Next nX

		nStatus := TCSqlExec(cUpd)
	
		If !(nStatus < 0)
			nAlt++
		EndIf
	EndIf
Endif

RestArea(aAreaF3k)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VlFldOk
Função que irá validar o preenchimento dos campos no facilitador

@author Marsaulo D. Souza
@since 25/08/2017
@version Branch Unica
/*/
//-------------------------------------------------------------------
Function VlFldOk(cValid)
Local lRet	:= .F.
Local nR	:= 0
Local nDelt	:= 0

Default cValid:= ""

If cValid == "TODOS"
	nDelt:= Len(oGetD:aCols[1]) //ultima posicao do acols retorna se o registro esta deletado
	For nR := 1 to Len(oGetD:aCols)
		If !oGetD:aCols[nR][nDelt]
			If lReflex .and. !Empty(oGetD:aCols[nR][1]) .and. !Empty(oGetD:aCols[nR][2]) .And. !Empty(oGetD:aCols[nR][3]) .And. !Empty(oGetD:aCols[nR][4])	
				lRet :=	.T.
			ElseIf !lReflex .And. !Empty(oGetD:aCols[nR][1]) .and. !Empty(oGetD:aCols[nR][2]) .And. !Empty(oGetD:aCols[nR][3])
				lRet :=	.T.
			Else
				lRet	:= .F.
				Exit //Achou linha com algum campo em branco
			EndIf
		EndIf
	Next nR

ElseIf cValid == "LINHA"
	If lReflex .and. !Empty(aCols[n][1]) .and. !Empty(aCols[n][2]) .And. !Empty(aCols[n][3]) .And. !Empty(aCols[n][4])	
		lRet :=	.T.
	ElseIf !lReflex .And. !Empty(aCols[n][1]) .and. !Empty(aCols[n][2]) .And. !Empty(aCols[n][3])
		lRet :=	.T.
	Endif
EndIf

If !lRet
	Help(,,'A140',,STR0009,1,0) //Preencha todos os campos
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaHeader
Monta Header
F3K_CFOP,F3K_CODAJU,F3K_VALOR,F3K_CST,F3K_CODREF
/*/
//-------------------------------------------------------------------
Static Function MontaHeader(aHeader,aCmp,lCST)
Local nX		:= 0
Local Acampos	:= {"F3K_CFOP","F3K_CODAJU","F3K_VALOR","F3K_CST"}

If lCST
	Acampos:= {"F3K_CFOP","F3K_CODAJU","F3K_VALOR","F3K_CST"}
Endif

If lReflex
	Acampos := {"F3K_CFOP","F3K_CODAJU","F3K_CODREF","F3K_CST","F3K_IFCOMP","F3K_CODLAN"}	
Endif

dbSelectArea("SX3")
dbSetOrder(2)

For nX:=1 To Len(Acampos)
	If MsSeek(Acampos[nX])
		AADD(aHeader,{ TRIM(x3titulo()),;
		SX3->X3_CAMPO,;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		SX3->X3_VALID,;
		SX3->X3_USADO,;
		SX3->X3_TIPO,;
		SX3->X3_F3,;
		SX3->X3_CONTEXT,;
		SX3->X3_CBOX,;
		SX3->X3_RELACAO,;
		".T."})
		aAdd(aCmp,{X3_CAMPO,X3_TIPO,{}})
	Endif
Next

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidF3K
Função valida o dicionário de dados

@param lVldParam - .T. não checará o parâmetro MV_GIAEFD mas checará novamente os campos

@author Renato Rezende
@since 12/11/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function ValidF3K(lVldParam)
Local lRet			:= .F.

Default lVldParam 	:= .F.

If Type("lGrupos")=="U" .Or. lVldParam
	lRet := F3K->(FieldPos("F3K_GRCLAN")) > 0 .And. F3K->(FieldPos("F3K_GRPLAN")) > 0 .And. ;
			F3K->(FieldPos("F3K_GRFLAN")) > 0 .And. F3K->(FieldPos("F3K_IFCOMP")) > 0 .And. F3K->(FieldPos("F3K_CODLAN")) > 0 .and.;
			Iif(!lVldParam,!GetNewPar("MV_GIAEFD",.F.),.T.)
	If !lVldParam
		lGrupos:=lRet
	EndIf
EndIf

Return  Iif(lVldParam, lRet,lGrupos)


//-------------------------------------------------------------------
/*/{Protheus.doc} FiltroF3k
Função que irá filtrar os registros de interesse para edicao ou inclusao na F3k.
@return aRet

@since 29/06/2022
@version Branch Unica
/*/
//------------------------------------------------------------------- 
Static Function FiltroF3k()
Local aRet		:= {}
Local aParamBox	:= {}
Local nX		:= 0
Local nMv		:= 0
Local lFiltro	:= .F.
Local aMvPar	:= {}
Local nMaxPerg	:= 40

aAdd(aParamBox,{1,"CFOP"			,	Space(5)	,"","","13","",0,.F.})
aAdd(aParamBox,{1,"Cod Val Decl"	,	Space(8)	,"","","CDY","",0,.F.})
aAdd(aParamBox,{1,"CST"				,	Space(2)	,"","","S2","",0,.F.})
aAdd(aParamBox,{1,"Cod Reflexo"		,	Space(7)	,"","","CE0","",0,.F.})
aAdd(aParamBox,{1,"Obs.Lanc.Fis"	,	Space(6)	,"","","CCE","",0,.F.})
aAdd(aParamBox,{1,"Cod Lanc"		,	Space(10)	,"","","CC6","",0,.F.})

//Armazena os parametros MV_
For nMv := 1 To nMaxPerg
	aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
Next nMv

//Realiza pergunte
If ParamBox(aParamBox,"Filtra os registros que serão alterados",@aRet)
	For nX := 1 To Len(aRet)
		If !Empty(aRet[nX])
			lFiltro := .T.
			EXIT
		EndIf
	Next nX
EndIf

//Valida preenchimento do filtro
If !lFiltro
	aRet := {}
	MsgAlert("Nenhum Filtro foi selecionado pelo usuário.")
EndIf

//Restaura os parametros anteriores
For nMv := 1 To Len( aMvPar )
	&( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[nMv]
Next nMv

Return(aRet)
