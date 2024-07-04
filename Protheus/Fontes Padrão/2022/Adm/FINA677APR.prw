#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#Include 'FWMVCDef.ch'
#Include 'FINA677.ch'

Static aUserLogado 	:= {}
Static cAliasMrk	:= ""
Static cTpAprov		:= ""
Static _oF677APR1

//-------------------------------------------------------------------
/*/{Protheus.doc} F677APROVA
Aprovação do gestor

@author Jose Domingos
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function F677APROVA(cAlias,nReg,nOpc,lAutomato,cOpc)

Local aAlias	:= {}				//Array para o retorno da função TK600QueryDAC
Local aColumns	:= {}				//Colunas do Browse			
Local oDlgMrk 	:= Nil
Local aRotOld	:= Nil
Local aArea		:= GetArea()
Local aAreaFLF	:= FLF->(GetArea())
Local aColsEdit	:= {}
Local aAprv 	:= FResAprov("2")	//2 - Prestação de Contas

Local aRetAuto	:= {}
Local cRecTab	:= ''
Local cChavAut	:= ''
Local cMarca	:= GetMark()
Local nX		:= 0

Private aRotina	  := Menudef()

Default lAutomato := .F.
Default cOpc      := "A"

PRIVATE l667Auto  := lAutomato .AND. !empty(cOpc)

If !lAutomato
	aRotOld := aClone(aRotina)
EndIf

/*
	PCREQ-3829 Aprovação Automática
	aAprv[1] - Conferência (.T. or .F.)
	aAprv[2] - Aprovação Gestor (.T. or .F.)
	aAprv[3] - Lib. Financeiro (.T. or .F.)
*/
If aAprv[2]

	If F677FilAprov(lAutomato)
	
		//----------------------------------------------------------
		//Retorna as colunas para o preenchimento da FWMarkBrowse
		//----------------------------------------------------------
		aAlias 		:= F677QryAprSol()
		
		cAliasMrk	:= aAlias[1]
		aColumns 	:= aAlias[2]
		aColsEdit	:= aAlias[3]

		If !lAutomato
			If !(cAliasMrk)->(Eof())
				//------------------------------------------
				//Criação da MarkBrowse no Layer LISTA_DAC
				//------------------------------------------
				oMrkBrowse:= FWMarkBrowse():New()
				oMrkBrowse:SetFieldMark("FLN_OK")
				oMrkBrowse:SetOwner(oDlgMrk)
				oMrkBrowse:SetDataQuery(.F.)
				oMrkBrowse:SetDataTable(.T.)
				oMrkBrowse:SetAlias(cAliasMrk)
				oMrkBrowse:SetCustomMarkRec({||EditaCell(oMrkBrowse,aColsEdit)})			
				oMrkBrowse:oBrowse:SetEditCell(.T.)			
				oMrkBrowse:bMark    := {|| Fa677Mark(cAliasMrk )}
				oMrkBrowse:bAllMark := { || F677Inverte(cAliasMrk,.T. ) }
				oMrkBrowse:SetDescription("")
				oMrkBrowse:SetColumns(aColumns)
				oMrkBrowse:SetTemporary(.T.)
				oMrkBrowse:Activate()
		
			Else
				Help(" ",1,"RECNO")
			EndIf
		Else
			If FindFunction("GetParAuto")
				aRetAuto	:= GetParAuto("FINA677TestCase")
			EndIf
				
			cRecTab := (cAliasMrk)->(RECNO())
			(cAliasMrk)->(dbGoTop())
			
			While !(cAliasMrk)->(Eof())
				For nX := 1 TO Len(aRetAuto)
					cChavAut:= (cAliasMrk)->FLF_PRESTA +'|'+ (cAliasMrk)->FLF_PARTIC
					If cChavAut == aRetAuto[nX][1]
						Fa677Mark(cAliasMrk)
					EndIf
					(cAliasMrk)->(DbSkip())
				Next nX
			EndDo
			F677ArvRpv('A',lAutomato)
			(cAliasMrk)->(dbGoto(cRecTab))
		EndIf
		
	Endif	
	
	If !Empty (cAliasMrk)
		dbSelectArea(cAliasMrk)
		dbCloseArea()
		cAliasMrk := ""
		dbSelectArea("FLF")
		dbSetOrder(1)
		//Deleta tabela temporaria no banco de dados (criada na funcao F677QryAprSol)	
		If _oF677APR1 <> Nil
			_oF677APR1:Delete()
			_oF677APR1 := Nil
		Endif
	Endif
	
Else
	Help(" ",1,"F677APROA",,STR0146,1,0) //"Processo de aprovação não está habilitado!"
Endif
	
RestArea(aArea)
RestArea(aAreaFLF)

If !lAutomato
	aRotina := aClone(aRotOld)
EndIf

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} F677QryAprSol
Selecao do dados

@author Jose Domingos

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F677QryAprSol()

Local aArea			:= GetArea()			
Local aAreaSX3		:= SX3->(GetArea())	
Local cAliasTrb		:= CriaTrab(,.F.)	
Local cTempTab		:= CriaTrab(,.F.)
Local aStructFLF	:= FLF->(DBSTRUCT())	//Estrutura da Tabela FLN - Aprovaçoes
Local aStructFLN	:= FLN->(DBSTRUCT())	//Estrutura da Tabela FLF - Prestação
Local aColumns		:= {}					//Array com as colunas a ser apresentada 
Local nX			:= 0					
Local nPos			:= 0
Local cPartIni		:= mv_par01  
Local cPartFim		:= mv_par02
Local cDataIni		:= DTOS(mv_par03)
Local cDataFim		:= DTOS(mv_par04)
Local cPrestIni		:= mv_par05
Local cPrestFim		:= mv_par06
Local cAprovador	:= mv_par07
Local nCols			:= 1
Local aColsEdit		:= {}  
Local nTamRej		:= TamSX3("FLN_MOTREJ")[1]
Local nTamCpo		:= Len(SX3->X3_CAMPO)
Local aCamposFLF 	:= {'FLF_PRESTA', 'FLF_PARTIC', 'FLF_EMISSA', 'FLF_DTINI', 'FLF_DTFIM',;
						'FLF_CLIENT', 'FLF_LOJA', 'FLF_FATCLI', 'FLF_FATEMP', 'FLF_TDESP1',;
						'FLF_TDESP2', 'FLF_TDESP3', 'FLF_TVLRE1', 'FLF_TVLRE2', 'FLF_TVLRE3',; 
						'FLF_TDESC1', 'FLF_TDESC2', 'FLF_TDESC3', 'FLF_TADIA1', 'FLF_TADIA2',;
						'FLF_TADIA3','FLNMOTREJ'}

Aadd(aStructFLF, {"FLN_OK","C",1,0})
Aadd(aStructFLF, {"FLFRECNO","N",16,2})
Aadd(aStructFLF, {"FLNRECNO","N",16,2})
Aadd(aStructFLF, {"FLNMOTREJ","C",nTamRej,0})

dbSelectArea("RD0")
RD0->( dbSetOrder(1) )

For nX := 1 To Len(aStructFLN)
	
	If aStructFLN[nX][1] $ "FLN_FILIAL|FLN_SEQ|FLN_APROV|FLN_OK|FLN_TIPO|FLN_PRESTA|FLN_PARTIC"
		aAdd(aStructFLF, aStructFLN[nX] )
	EndIf	

Next nX	

//------------------
//Criacao da tabela temporaria 
//------------------
If _oF677APR1 <> Nil
	_oF677APR1:Delete()
	_oF677APR1 := Nil
Endif

_oF677APR1 := FWTemporaryTable():New( cTempTab )  
_oF677APR1:SetFields(aStructFLF) 	
_oF677APR1:AddIndex("1", {"FLF_FILIAL","FLF_TIPO","FLF_PRESTA","FLF_PARTIC"})	

_oF677APR1:Create()	

//-----------------------SELECT-----------------------
cQuery := "SELECT FLF.FLF_PRESTA, FLF.FLF_PARTIC, FLF.FLF_EMISSA, "
cQuery += "FLF.FLF_DTINI, FLF.FLF_DTFIM, FLF.FLF_CLIENT, FLF.FLF_LOJA, "
cQuery += "FLF.FLF_FATCLI, FLF.FLF_FATEMP, FLF.FLF_TDESP1, FLF.FLF_TDESP2, "
cQuery += "FLF_TDESP3, FLF_TVLRE1, FLF_TVLRE2, FLF_TVLRE3, FLF_TDESC1, "
cQuery += "FLF_TDESC2, FLF_TDESC3, FLF_TADIA1, FLF_TADIA2, FLF_TADIA3, "
cQuery += "FLN.FLN_FILIAL, FLN.FLN_TIPO, FLN.FLN_PRESTA, FLN.FLN_PARTIC, " 
cQuery += "FLN.FLN_SEQ, FLN.FLN_TPAPR, FLN.FLN_APROV, FLN.FLN_STATUS, "
cQuery += "FLN.FLN_DTAPRO, '  ' FLN_OK, ' ' FLN_USED, '" + Space(nTamRej) + "' FLNMOTREJ, FLF.R_E_C_N_O_ FLFRECNO, FLN.R_E_C_N_O_ FLNRECNO "  
//Obs.: FLN_OK é o campo criado para o campo de Marcação
//-----------------------FROM-----------------------
cQuery += "FROM " + RetSqlName("FLF") + " FLF INNER JOIN " + RetSqlName("FLN") + " FLN "
cQuery += "ON FLN.FLN_FILIAL = FLF.FLF_FILIAL AND FLN.FLN_TIPO = FLF.FLF_TIPO AND FLN.FLN_PRESTA = FLF.FLF_PRESTA "
cQuery += "AND FLN.FLN_PARTIC = FLF.FLF_PARTIC AND FLN.FLN_STATUS = '1' AND FLN.FLN_TPAPR = '1' "
cQuery += "AND FLN.FLN_APROV = '" + cAprovador + "' AND FLN.D_E_L_E_T_ = ' ' "
//-----------------------WHERE-----------------------
cQuery += "WHERE FLF.FLF_FILIAL = '" + xFilial("FLF") + "' AND FLF.FLF_PRESTA >= '" + cPrestIni + "' AND "
cQuery += "FLF.FLF_PRESTA <= '" + cPrestFim + "' AND FLF.FLF_PARTIC >= '" + cPartIni + "' AND "
cQuery += "FLF.FLF_PARTIC <= '" + cPartFim + "' AND FLF.FLF_DTINI >= '" + cDataIni + "' AND "
cQuery += "FLF.FLF_DTINI <= '" + cDataFim + "' AND FLF.FLF_STATUS = '4' AND FLF.D_E_L_E_T_ = ' ' "
//-----------------------ORDER BY-----------------------
cQuery += "ORDER BY FLN_FILIAL,FLN_TIPO,FLN_PRESTA,FLN_PARTIC " 

cQuery := ChangeQuery(cQuery)
 
MPSysOpenQuery(cQuery, cAliasTrb, aStructFLF)

(cAliasTrb)->(DbGoTop())
While !(cAliasTrb)->(Eof())
	If !( FINXUser(__cUserId,@aUserLogado,.T.) )
		Exit
	EndIf

	// Filtra aprovacoes para o usuario logado
	If RD0->( dbSeek(xFilial("RD0")+(cAliasTrb)->FLF_PARTIC) )
		If (cAliasTrb)->FLN_APROV <> aUserLogado[1]	// Verifica se usuario logado e o aprovador			
				If RD0->RD0_APSUBS <> aUserLogado[1] // Verifica se usuario logado e aprovador substituto
					(cAliasTrb)->( dbSkip() )
					Loop
				Else
					cTpAprov := "S"
				EndIf 			
		Else
			cTpAprov := "O"
		EndIf
	EndIf

	RecLock(cTempTab, .T.)	
	For nX := 1 To Len(aStructFLF)		
		nPos := (cAliasTrb)->(FieldPos(aStructFLF[nX][1]))
		If nPos > 0 
			If aStructFLF[nX][2] == 'D'
				FieldPut(FieldPos(aStructFLF[nX][1]), DTOS((cAliasTrb)->(FieldGet(nPos))))  				
			Else
				FieldPut(FieldPos(aStructFLF[nX][1]), (cAliasTrb)->(FieldGet(nPos)))  	
			EndIf
		EndIf
	Next nX
	For nX := 1 To Len(aStructFLN)		
		nPos := (cAliasTrb)->(FieldPos(aStructFLN[nX][1]))
		If nPos > 0 
			FieldPut(FieldPos(aStructFLN[nX][1]), (cAliasTrb)->(FieldGet(nPos)))  	
		EndIf
	Next nX

	(cTempTab)->(MsUnlock())
	(cAliasTrb)->(DbSkip())
EndDo	

For nX := 1 To Len(aStructFLN)
	If	aStructFLN[nX][1] $ "FLN_FILIAL|FLN_SEQ|FLN_APROV"
		nCols++
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStructFLN[nX][1])) 
		aColumns[Len(aColumns)]:SetData( &("{||"+aStructFLN[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetSize(aStructFLN[nX][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStructFLN[nX][4])
		aColumns[Len(aColumns)]:SetPicture(PesqPict("FLN",aStructFLN[nX][1]))
	EndIf 	
Next nX 

nCols++
AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData(&("{|| FLNMOTREJ }"))
aColumns[Len(aColumns)]:SetSize(nTamRej)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetEdit(.T.)
aColumns[Len(aColumns)]:SetReadVar((cAliasTrb)->FLNMOTREJ)
aColumns[Len(aColumns)]:SetPicture("@N")			
aColumns[Len(aColumns)]:SetTitle( RetTitle("FLN_MOTREJ") )
aAdd(aColsEdit, nCols )

For nX := 1 To Len(aStructFLF)	
	If aScan(aCamposFLF, {|x| AllTrim(x) == aStructFLF[nX][1] } ) > 0 .And. aStructFLF[nX][1] != "FLNMOTREJ" 
		nCols++
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aStructFLF[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetSize(aStructFLF[nX][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStructFLF[nX][4])		
		aColumns[Len(aColumns)]:SetPicture(PesqPict("FLF",aStructFLF[nX][1]))
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStructFLF[nX][1]))
	EndIf 	
Next nX 

aSize(aCamposFLF, 0)	

If ( Select( cAliasTrb ) > 0 )
	DbSelectArea(cAliasTrb)
	DbCloseArea()
EndIf	

RestArea(aArea)

Return({cTempTab,aColumns,aColsEdit})


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menudef

@author Jose Domingos

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRot := {}


ADD OPTION aRot TITLE STR0033	ACTION "F677ArvRpv('R')"	OPERATION 2 ACCESS 0	//"Reprovar" 
ADD OPTION aRot TITLE STR0091	ACTION "F677ArvRpv('A')"	OPERATION 4 ACCESS 0	//'Aprovar'

Return(Aclone(aRot))


//-------------------------------------------------------------------
/*/{Protheus.doc} F677ArvRpv
Aprova ou reprova as prestaçãoes de contas

@author Jose Domingos

@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function F677ArvRpv(cOpcao/*A - Aprov ou R - Reprov*/,lAutomato)

Local nX			:= 0
Local aArea			:= GetArea()
Local nLenRegs 		:= 0
Local aRegsFLF		:= {}
Local lMotivo		:= .F.
Local cMotivo		:= ""
Local cMotRej		:= ""  

Private lExecTit	:= .F. //Variável para controlar se houve erro na execauto de inclusão dos títulos gerados

Default lAutomato	:= .F.
	
If !Empty(cTpAprov)

	(cAliasMrk)->(dbGoTop())	

	While (cAliasMrk)->(!Eof())
		If !Empty((cAliasMrk)->FLN_OK)
			lMotivo := Empty((cAliasMrk)->FLNMOTREJ)
		EndIf
		(cAliasMrk)->(DbSkip())
	EndDo 
	
	If cOpcao == "R" .And. lMotivo
		cMotivo := FN677Mot()
	EndIf
	
	(cAliasMrk)->(dbGoTop())

	While (cAliasMrk)->(!Eof())
		
		If Empty((cAliasMrk)->FLNMOTREJ)
			cMotRej := cMotivo
		Else 
			cMotRej := (cAliasMrk)->FLNMOTREJ
		EndIf
		
		If !EMPTY((cAliasMrk)->(FLN_OK)) .or. l667Auto

			FLN->(dbGoto((cAliasMrk)->FLNRECNO))

			BEGIN TRANSACTION

			F677APRGRV(cOpcao, cTpAprov, aUserLogado, FLN->FLN_TIPO, FLN->FLN_PRESTA, FLN->FLN_PARTIC, FLN->FLN_SEQ,cMotRej,'1',)
		
			AADD(aRegsFLF,(cAliasMrk)->FLFRECNO)

			END TRANSACTION

		EndIf

		(cAliasMrk)->(DbSkip())
	EndDo
Else
	Help(" ",1,"F677NOTAPR",,STR0092,1,0)	//"Usuário não tem permissão para aprovar ou reprovar as prestações selecionadas."
EndIf

//Destravo os registros marcados
nLenRegs := Len(aRegsFLF)
For nX := 1 to nLenRegs
	FLF->(dbGoTo(aRegsFLF[nX]))
	FLF->(MsRUnlock())
Next	

If !lAutomato .And. nLenRegs > 0
	If lExecTit
		MsgInfo(STR0172)
	Else
		MSGINFO(Alltrim(STR(nLenregs))+IIF(cOpcao == 'A',STR0093,STR0094))	//"Foram realizadas "###' aprovações.'###
	EndIf
	oMrkBrowse:GetOwner():End()

Endif

FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()

RestArea(aArea)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} Fa677Mark
Marcacao de um registro

@author Jose Domingos

@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------

Function Fa677Mark(cAliasTRB)

Local lRet	:= .T.

FLF->(dbGoto((cAliasTRB)->FLFRECNO))

If FLF->(MsRLock()) .AND. (cAliasTRB)->(MsRLock())
	lRet := .t. //F677Inverte(cAliasTRB,.F.)
Else
	IW_MsgBox(STR0088,STR0089,"STOP")	//"Este registro está sendo utilizado em outro terminal, não podendo ser selecionado"###"Atenção"
	lRet := .F.
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F677Inverte
Marcacao de vários registros

@author Jose Domingos

@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function F677Inverte(cAliasTRB,lTudo)

Local nReg 		:= (cAliasTRB)->(Recno())
Local cMarca 		:= oMrkBrowse:cMark

Default lTudo := .T.


dbSelectArea(cAliasTRB)
If lTudo
	dbgotop() 
	cMarca := oMrkBrowse:cMark
Endif

While (cAliasTRB)->(!Eof())

	FLF->(dbGoto((cAliasTRB)->FLFRECNO))
	
	If FLF->(MsRLock()) .AND. (cAliasTRB)->(MsRLock())
	
		IF	(cAliasTRB)->FLN_OK == cMarca
			(cAliasTRB)->FLN_OK := "  "
			(cAliasTRB)->(MsUnlock())
			FLF->(MsUnlock())			
		Else
			(cAliasTRB)->FLN_OK := cMarca
		Endif

		If !lTudo
			Exit
		Endif
	Endif
	(cAliasTRB)->(dbSkip())
Enddo

(cAliasTRB)->(dbGoto(nReg))

oMrkBrowse:oBrowse:Refresh(.t.)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} F677FilAprov
Filtro da Browse

@author Jose Domingos

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function F677FilAprov(lAutomato)

Local cIdUser		:= __cUserId
Local cUsuarios	:= ""
Local cStatus		:= ""
Local cParticDe	:= Replicate (" ", Len(FLF->FLF_PARTIC)) 
Local cParticAte	:= Replicate ("Z", Len(FLF->FLF_PARTIC)) 
Local cPrestDe	:= Replicate (" ", Len(FLF->FLF_PRESTA)) 
Local cPrestAte	:= Replicate ("Z", Len(FLF->FLF_PRESTA))
Local cAprovador	:= Replicate (" ", Len(FLF->FLF_PARTIC))  
Local nParCont	:= 0
Local lContinua 	:= .T. 
Local aPerguntas	:= {}
Local aParam		:= {}
Local dDataIni	:= FirstDay(dDataBase)
Local dDataFim	:= LastDay(dDataBase)

Default cFiltro := ""
Default lAutomato := .F.

If lContinua
	// Caso a rotina tenha sido chamada atraves da automacao de testes, nao apresenta a interface.
	If l667Auto	.AND. FindFunction("GetParAuto")
		aParam 	   := GetParAuto("FINA677TESTCASE")	
		mv_par01 	:= aParam[1]
		mv_par02 	:= aParam[2]
		mv_par03	:= aParam[3]
		mv_par04	:= aParam[4]
		mv_par05	:= aParam[5]
		mv_par06	:= aParam[6]
		mv_par07	:= aParam[7]
	Else
		aPerguntas := { { 1, STR0035 , cParticDe  ,"@!",'.T.',"RD0",".T.",60, .F.},;	//"Participante De"
						{ 1, STR0036 , cParticAte ,"@!",'.T.',"RD0",".T.",60, .F.},;		//"Participante Ate"
						{ 1, STR0037 , dDataIni   ,""  ,'.T.',""   ,".T.",50, .T.},;		//"Dt. Chegada De"
						{ 1, STR0038 , dDataFim   ,""  ,'.T.',""   ,".T.",50, .T.},;		//"Dt. Chegada Ate"								 		
						{ 1, STR0095 , cPrestDe  ,"@!",'.T.',"FLF",".T.",60, .F.},;		//"Prestacao De"
						{ 1, STR0096 , cPrestAte ,"@!",'.T.',"FLF",".T.",60, .F.},;		//"Prestacao Ate"
						{ 1, STR0097 , cAprovador ,"@!",'.T.',"RD0",".T.",60, .F.}}		//"Aprovador"

	
		lContinua := ParamBox( aPerguntas,STR0039,aParam,{||.T.},,,,,,FunName(),.T.,.T.) 		//"Parƒmetros"
	Endif

	//-----------------------------------------------------------
	// Garantindo que os valores do parambox estarão nas devidas variáveis MV_PARXX
	//-----------------------------------------------------------
	If lContinua
		For nParCont := 1 To Len(aParam)
			&("MV_PAR"+CVALTOCHAR(nParCont)) := aParam[nParCont]
		Next nParCont
	Endif		
Endif

Return lContinua


//-------------------------------------------------------------------
/*/{Protheus.doc} F677APRGRV
Atualiza a estrutura de aprovacao da prestação de contas

@author Jose Domingos

@since 28/10/2013
@version 1.0
@Param	cOrigem 1=Protheus;2=Fluig
@Param	oMdlFluig Objeto do Modelo de Dados do Fluig quando a aprovação/reprovação é via portal Fluig
/*/
//-------------------------------------------------------------------

Function F677APRGRV(cOpcao, cTpAprov, aSubist, cTpPrest, cPresta, cPartic, cSeq, cMotv, cOrigem, oMdlFluig)

Local aArea			:= GetArea()	
Local aAreaFLN		:= FLN->(GetArea())
Local aAreaFLF		:= FLF->(GetArea())
Local lTemSaldo		:= .F.
Local cCodAprov		:= ""
Local aAprv 		:= FResAprov("2")//2 - Prestação de Contas
Local cWfId			:= ""
Local cUserFluig	:= ""
Local cCodUsrApv	:= ""
Local lUseFluig		:= FWIsInCallStack("WFF677Grv")
Local lRet			:= .T.

/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Conferência (.T. or .F.)
	aAprv[2] - Aprovação Gestor (.T. or .F.)
	aAprv[3] - Lib. Financeiro (.T. or .F.)
*/

Default cOpcao		:= ""
Default cTpAprov	:= ""	
Default aSubist		:= {}
Default cTpPrest	:= ""
Default cPresta		:= ""
Default cPartic		:= ""
Default cSeq		:= ""
Default cMotv		:= " "

/*
 * Tratamento das informações quando são do Fluig
 */
If cOrigem == '2'
	cTpFLF		:= oMdlFluig:GetValue('FLFMASTER','FLF_TIPO')
	cPrtaFLF	:= oMdlFluig:GetValue('FLFMASTER','FLF_PRESTA')
	cParTFLF	:= oMdlFluig:GetValue('FLFMASTER','FLF_PARTIC')
	cMotv		:= oMdlFluig:GetValue('FLFMASTER','FLF_MOTVFL')
	
	dbSelectArea("FLN")
	FLN->(dbSetOrder(1)) // Filial + Tipo de Prestação de Contas + Identificação da Prestação de Contas + Participante da Prestação de Contas
	If FLN->(DbSeek(xFilial("FLN") + cTpFLF + cPrtaFLF + cParTFLF))
		If FLN->FLN_APROV == __cUserID 
			cTpAprov := 'O'
		EndIf
	EndIf
	
	If Empty(cTpAprov)
		RD0->(DbSetOrder(1)) // Filial + Participante
		If RD0->(DbSeek( xFilial("RD0") + cParTFLF ))
			If __cUserID == RD0->RD0_APROPC
				cTpAprov := 'O'
			ElseIf __cUserID == AllTrim(RD0->RD0_APSUBS)
				cTpAprov := 'S'
			EndIf
		EndIf 
	EndIf
EndIf

If AllTrim(cOpcao) $ "AR" ;
	.And. ( (cTpAprov == "S" .And. Len(aSubist)>0 ) .Or. cTpAprov == "O") ;
	.And. !Empty(cTpPrest) ;
	.And. !Empty(cPresta) ;
	.And. !Empty(cPartic) ;
	.And. !Empty(cSeq) ;
	
	DbSelectArea("FLN")
	FLN->(DbSetOrder(1))
	If FLN->(DbSeek(xFilial("FLN")+cTpPrest+cPresta+cPartic+cSeq+"1"))

		If cTpAprov == "S" //Se Substituto
			//Cancela aprovação atual
			RecLock("FLN",.F.)
				FLN->FLN_STATUS	 := "4" //Cancelada
				FLN->FLN_DTAPRO	 := dDatabase
			FLN->(MsUnLock())
			
			//Cria nova aprovação para o substituto
			RecLock("FLN",.T.)
				FLN->FLN_FILIAL	:= xFilial("FLN")
				FLN->FLN_TIPO	:= cTpPrest
				FLN->FLN_PRESTA	:= cPresta
				FLN->FLN_PARTIC	:= cPartic
				FLN->FLN_SEQ	:= cSeq
				FLN->FLN_TPAPR	:= "2"
				FLN->FLN_APROV	:= aSubist[1]
				FLN->FLN_STATUS	:= IIF(cOpcao=="A","2","3")
				FLN->FLN_DTAPRO	:= dDatabase
				FLN->FLN_MOTREJ	:= cMotv	
			FLN->(MsUnLock())
		Else
			RecLock("FLN",.F.)
				FLN->FLN_STATUS	:= IIF(cOpcao=="A","2","3")
				FLN->FLN_DTAPRO	:= dDatabase
				FLN->FLN_MOTREJ	:= cMotv
			FLN->(MsUnLock())
		EndIf
		cCodAprov := FLN->FLN_APROV

		If cOpcao == 'A' //Se Aprovado
			F677PushNotification( 102, NIL, STR0001 + " - " + STR0007, STR0207 ) //"Prestação de Contas"###'Aprovada'###'Prestação aprovada pelo gestor.'
		EndIf

		FLN->(DbSkip())
			
		If cOpcao=="A" //Se Aprovado
			//Atualiza proximo registro para Ag. Aprovação
			If FLN->(!Eof()) .And. xFilial("FLN")+cTpPrest+cPresta+cPartic == FLN->(FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC)
				RecLock("FLN",.F.)
				FLN->FLN_STATUS	 := "1" //Ag. Aprovação
				FLN->(MsUnLock())
			
				F677MsgMail(1, FLN->FLN_APROV,,cOrigem)
			Else
				//Atualiza prestação para aprovada
				DbSelectArea("FLF")
				FLF->(DbSetOrder(1))
				
				If FLF->(DbSeek(xFilial("FLF")+cTpPrest+cPresta+cPartic))
					If (FLF->FLF_TVLRE2 - (FLF->FLF_TADIA2 + FLF->FLF_TDESC2)) <> 0 .Or.;
					   (FLF->FLF_TVLRE3 - (FLF->FLF_TADIA3 + FLF->FLF_TDESC3)) <> 0 .Or.;    
					   (FLF->FLF_TVLRE1 - (FLF->FLF_TADIA1 + FLF->FLF_TDESC1)) <> 0
						lTemSaldo := .T.
					EndIf
					
					RecLock("FLF",.F.)
					FLF->FLF_STATUS := IIF(lTemSaldo, "6", "8")
					
					If FLF->FLF_STATUS == "8" 
						FLF->FLF_DTFECH := dDataBase
					EndIf
					
					FLF->(MsUnLock())					
					
					If lUseFluig
						cPCStatus := IIF(lTemSaldo,"6","8")
					Else						
						//Grupo de perguntes
						Pergunte("F677REC",.F.)
						
						//Contabilização on-line         
						If mv_par02 == 1 .And. !lTemSaldo
							F6778BLCt(.F.)
						EndIf
					EndIf
					
					If !(aAprv[3]) .And. lTemSaldo 
						MsgRun( STR0085,, {|| lRet := F677PreLib(.F.) } ) //"Processando liberação finaceiro..."
						
						If lRet
							If lUseFluig
								cPCStatus := "7"
							Else
								RecLock("FLF",.F.)
								FLF->FLF_STATUS := "7"
								FLF->(MsUnlock())						
							EndIf
						Else
							DisarmTransaction()
						EndIf				
					EndIf
					
					If lRet
						cWfId := FLF->FLF_WFKID
						//Realiza o Cancelamento da Solicitação de Aprovação no FLUIG.
						If !Empty(cWFID) .AND. !lUseFluig
							DbSelectArea("RD0")
							RD0->(DbSetOrder(1))
							RD0->(DbSeek(xFilial("RD0")+cPartic))
							cCodUsrApv := RD0->RD0_USER
							If cCodUsrApv <> ""
								cUserFluig := FWWFColleagueId(cCodUsrApv)
								CancelProcess(Val(cWfId),cUserFluig,STR0160)//"Excluido pelo sistema Protheus"
							Endif
						Endif		
					EndIf			
				EndIf
			EndIf
		Else //Se Reprovado 
			//Atualiza proximo registro para Cancelados
			While	FLN->(!Eof()) .And. xFilial("FLN")+cTpPrest+cPresta+cPartic == FLN->(FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC)
				RecLock("FLN",.F.)
				FLN_STATUS	:= "4" //Cancelada
				FLN_DTAPRO	:= dDatabase
				FLN_APROV	:= __cUserID
				FLN_NOMEAP	:= cUsername
				FLN->(MsUnLock())
				FLN->(DbSkip())
			EndDo
			
			//Atualiza prestação para Reprovada
			DbSelectArea("FLF")
			FLF->(DbSetOrder(1))
			If FLF->(DbSeek(xFilial("FLF")+cTpPrest+cPresta+cPartic))
				
				If lUseFluig
					cPCStatus := "5" //Reprovada
				Else
					RecLock("FLF",.F.)
					FLF->FLF_STATUS := "5" //Reprovada
					FLF->FLF_MOTVFL := cMotv 				
					FLF->(MsUnLock())
					F677MsgMail(2, cCodAprov,,cOrigem)
				EndIf
				
				cWfId := FLF_WFKID
				
				//Realiza o Cancelamento da Solicitação de Aprovação no FLUIG.
				If !Empty(cWFID) .AND. !lUseFluig
					DbSelectArea("RD0")
					RD0->(DbSetOrder(1))
					RD0->(DbSeek(xFilial("RD0")+cPartic))
					cCodUsrApv := RD0->RD0_USER
					If cCodUsrApv <> ""
						cUserFluig := FWWFColleagueId(cCodUsrApv)
						CancelProcess(Val(cWfId),cUserFluig,STR0160)//"Excluido pelo sistema Protheus"
					Endif
				Endif
			EndIf					
		EndIf
	EndIf
EndIf

//Só invoco a geração do título para processo via Fluig caso tenha havido aprovação
If cOrigem == '2' .And. cOpcao == "A"
	F677PreLib(.F.)
EndIf

RestArea(aAreaFLF)
RestArea(aAreaFLN) 
RestArea(aArea)	
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FN677Mot
Abre Tela para digitar motivo de aprovação/rejeição
@author Pedro P. Lima
@since 10/06/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function FN677Mot()
Local aSize		:= {}
Local oPanel	:= Nil
Local oGet		:= Nil
Local cObs		:= Space(TamSX3("FLN_MOTREJ")[1])

aSize	:= FwGetDialogSize(oMainWnd)          
oPanel	:= TDialog():New(003,010,900,975,STR0001,,,,,,,,,.T.,,,,600,300) //Motivo 
TSay():New(15,03,{||STR0164 + ": "},oPanel,,,,,,.T.) //"Motivo"
@ 015,035 GET oGet VAR cObs MEMO SIZE 248,93 PIXEL OF oPanel 
oButton	:= TButton():New(120,243,STR0165,oPanel,{||IIf(!Empty(cObs),lRet := .T.,lRet := .F.),;
												IIf(lRet,oPanel:End(),)}, 37,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Confirma"
oPanel:Activate(,,,.T.,,,)
oPanel	:= Nil
aSize	:= {}
oGet	:= Nil

Return AllTrim(cObs)

//-------------------------------------------------------------------
/*/{Protheus.doc}EditaCell
Posiciona nas colunas que poderão ser editadas e faz o tratamento para a edição
@author Pedro Pereira Lima
@since 14/06/2016
@param oMark	- objeto mark
@param aColsEdit- com as colunas que podem ser editadas
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function EditaCell(oMark,aColsEdit)
Default oMark := Nil
Default aColsEdit := {}

If aScan(aColsEdit,oMark:oBrowse:ColPos()) > 0

	RecLock(oMark:Alias(),.F.)
	oMark:oBrowse:EditCell(oMark:oBrowse:ColPos())
	(oMark:Alias())->(MsUnLock())
	
Else

	RecLock(oMark:Alias(),.F.)
	If (oMark:Alias())->FLN_OK != oMark:Mark()
		(oMark:Alias())->FLN_OK  := oMark:Mark()
	Else
		(oMark:Alias())->FLN_OK  := "  "
	Endif
	(oMark:Alias())->(MsUnLock())	

Endif

Return .T.
