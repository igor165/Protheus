
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#Include 'FWMVCDef.ch'
#Include 'FINA667.ch'

STATIC _oF667ASL1

//-------------------------------------------------------------------
/*/{Protheus.doc} F667APRVLT
Aprovacao de solicitacoes de adiantamentos (Lote)

@author pequim
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function F667APRVLT(cAlias,nReg,nOpc,lAutomato,cOpc)
Local lRet			:= .T.
Local aAlias		:= {}								
Local aColumns		:= {}								
Local oDlgMrk 		:= Nil
Local aRotOld		:=  {}
Local aArea			:= GetArea()
Local aAprv 		:= FResAprov("1")//"1" = Adiantamentos
//-- Automacao
Local aRetAuto		:= {}
Local cRecTab		:= ''
Local cChavAut		:= ''
Local cMarca		:= GetMark()
Local nX			:= 0

Default lAutomato   := .F.
Default cOpc        := "A"

PRIVATE l667ARVLT   := lAutomato .AND. !empty(cOpc)
PRIVATE aRotina	 	:= Menudef()
Private cAliasMrk	:= ""
Private cAliasMrk	:= ""

If !lAutomato
	PRIVATE aRotina	 	:= Menudef()
	aRotOld		:= aClone(aRotina)
EndIf

If ExistBlock("F667APROP")
	lRet := ExecBlock("F667APROP",.F.,.F.)
EndIf

/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Aprovação de Solicitação (.T. or .F.)
	aAprv[2] - Avaliação do Gestor (.T. or .F.)
	aAprv[3] - Lib. do Pagamento (.T. or .F.)
*/
If !aAprv[2]//Avaliação do Gestor. Se aAprv[2] == .F., Aprovação Automatica da Avaliação do Gestor está ativada. 
	lRet := .F.
	Help(" ",1,"F667APROA",,STR0120,1,0)//Processo de avaliação do gestor não habilitado
Endif

If lRet

	If F667FilApAdt (lAutomato)
	
		//----------------------------------------------------------
		//Retorna as colunas para o preenchimento da FWMarkBrowse
		//----------------------------------------------------------
		aAlias 		:= F667QryAprAdt()
		
		cAliasMrk	:= aAlias[1]
		aColumns 	:= aAlias[2]
	
		If !lAutomato
			If !(cAliasMrk)->(Eof())

				If l667ARVLT
					F667ApRp(cOpc)							
				Else				
					//------------------------------------------
					//Criação da MarkBrowse no Layer LISTA_DAC
					//------------------------------------------
					oMrkBrowse:= FWMarkBrowse():New()
					oMrkBrowse:SetFieldMark("FLD_OK")
					oMrkBrowse:AddLegend( "(cAliasMrk)->FLD_STATUS == '1'", "YELLOW"	, STR0004	)	//'Solicitado'
					oMrkBrowse:AddLegend( "(cAliasMrk)->FLD_STATUS == '6'", "ORANGE"    , STR0009	)	//'Bloqueado'				
					oMrkBrowse:SetOwner(oDlgMrk)
					oMrkBrowse:SetDataQuery(.F.)
					oMrkBrowse:SetDataTable(.T.)
					oMrkBrowse:SetAlias(cAliasMrk)
					oMrkBrowse:bMark    := {|| Fa667Mark(cAliasMrk )}
					oMrkBrowse:bAllMark := { || F667Inverte(cAliasMrk,.T. ) }
					oMrkBrowse:SetDescription("")
					oMrkBrowse:SetColumns(aColumns)
					oMrkBrowse:Activate()
				Endif
			Else
				Help(" ",1,"RECNO")
			EndIf
		Else
			If FindFunction("GetParAuto")
					aRetAuto	:= GetParAuto("FINA667TestCase")
			EndIf
				
			cRecTab := (cAliasMrk)->(RECNO())
			(cAliasMrk)->(dbGoTop())
			
			While !(cAliasMrk)->(Eof())
				cChavAut:= (cAliasMrk)->FLD_VIAGEM +'|'+ (cAliasMrk)->FLD_PARTIC +'|'+ (cAliasMrk)->FLD_ADIANT
				For nX := 1 TO Len(aRetAuto)
					If cChavAut == aRetAuto[nX][1]
						If FLD->(MsRLock()) .AND. (cAliasMrk)->(MsRLock())
							(cAliasMrk)->FLD_OK := cMarca
							(cAliasMrk)->(MsUnlock())
							FLD->(MsUnlock())
						EndIf			
					EndIf
				Next nX
				(cAliasMrk)->(DbSkip())
			EndDo
				
			F667ApRp("A",lAutomato)
			
			(cAliasMrk)->(dbGoto(cRecTab))
		EndIf
	
	EndIf

EndIf		

If !Empty (cAliasMrk)
	dbSelectArea(cAliasMrk)
	dbCloseArea()
	cAliasMrk := ""
	dbSelectArea("FLD")
	dbSetOrder(1)
	//Deleta tabela temporária no banco de dados (criada na função F667QryAprAdt)	
	If _oF667ASL1 <> Nil
		_oF667ASL1:Delete()
		_oF667ASL1 := Nil
	Endif	
Endif

RestArea(aArea)

If !lAutomato
	aRotina := aClone(aRotOld)
EndIf

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} QueryAprSol
Selecao do dados

@author pequim

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F667QryAprAdt()

Local aArea			:= GetArea()			
Local aAreaSX3		:= SX3->(GetArea())	
Local cAliasTrb		:= GetNextAlias()		
Local aStructFLD	:= FLD->(DBSTRUCT())	//Estrutura da Tabela FLM - Aprovaçoes
Local aStructFLM	:= FLM->(DBSTRUCT())	//Estrutura da Tabela FLD - Prestação
Local aColumns		:= {}					//Array com as colunas a ser apresentada 
Local nX			:= 0					
Local cTempTab		:= ""					
Local cPartIni		:= mv_par01  
Local cPartFim		:= mv_par02
Local cDataIni		:= DTOS(mv_par03)
Local cDataFim		:= DTOS(mv_par04)
Local lSolicitado	:= mv_par06
Local lBloqueado	:= mv_par07
Local nTamCpo		:= Len(SX3->X3_CAMPO)
Local cStatus		:= ""
Local cNomePartic := ""
Local cNomeSolic := ""
Local nPos		:= 0

If lSolicitado
	cStatus += "1"
Endif	
If lBloqueado
	cStatus += "6"
Endif

cStatus := "AND FLD.FLD_STATUS IN "+ FormatIN(cStatus,,1) 
cStatus := "%"+cStatus+"%"


BeginSQL alias cAliasTrb

SELECT FLD.*, '  ' FLD_OK, ' ' FLD_USED,'                                        ' FLD_DSCPAR, '                                        ' FLD_DSCSOL, FLD.R_E_C_N_O_ FLDRECNO  //FLD_OK é o campo criado para o campo de Marcação
FROM 
	%table:FLD% FLD
WHERE
	FLD.FLD_FILIAL = %xFilial:FLD%  AND
	FLD.FLD_PARTIC >= %exp:cPartIni% AND	
	FLD.FLD_PARTIC <= %exp:cPartFim% AND	
	FLD.FLD_DTPREV >= %exp:cDataIni% AND	
	FLD.FLD_DTPREV <= %exp:cDataFim% AND	
	FLD.FLD_ENCERR = ' ' AND	
	FLD.%notDel%		
	%Exp:cStatus% 
ORDER BY
	FLD_FILIAL,FLD_VIAGEM,FLD_PARTIC,FLD_ADIANT	

EndSql

//----------------------------------------------------------------------
// Cria arquivo de dados temporário
//----------------------------------------------------------------------
Aadd(aStructFLD, {'FLD_OK','C', 1,0,''})
Aadd(aStructFLD, {'FLDRECNO','N',16,2,''})
Aadd(aStructFLD, {'FLD_DSCPAR','C', 40,0,STR0132 /*Nome Participante*/})
Aadd(aStructFLD, {'FLD_DSCSOL','C', 40,0,STR0133 /*Nome Solicitante*/})

//------------------
//Criação da tabela temporaria 
//------------------
If _oF667ASL1 <> Nil
	_oF667ASL1:Delete()
	_oF667ASL1 := Nil
Endif

cTempTab := GetNextAlias()

_oF667ASL1 := FWTemporaryTable():New( cTempTab )  
_oF667ASL1:SetFields(aStructFLD) 	
_oF667ASL1:AddIndex("1", {"FLD_FILIAL","FLD_VIAGEM","FLD_PARTIC","FLD_ADIANT"})	
_oF667ASL1:Create()	

DbSetOrder(0) //Mantem a ordem natural de inserção dos registros na tabela

(cAliasTrb)->(DbGoTop())
While !(cAliasTrb)->(Eof())

	RecLock((cTempTab), .T.)	
	For nX := 1 To Len(aStructFLD)		
		nPos := (cAliasTrb)->(FieldPos(aStructFLD[nX][1]))
		If nPos > 0 .AND. !aStructFLD[nX][1] $ 'FLD_OK'
			If aStructFLD[nX][2] == 'D'
				FieldPut(FieldPos(aStructFLD[nX][1]), STOD((cAliasTrb)->(FieldGet(nPos))))  				
			Else
				FieldPut(FieldPos(aStructFLD[nX][1]), (cAliasTrb)->(FieldGet(nPos)))  	
			EndIf
			
			//Descrição do participante.
			If aStructFLD[nX][1] $ "FLD_DSCPAR"
				(cTempTab)->FLD_DSCPAR := GETADVFVAL("RD0","RD0_NOME",xFilial("RD0") + (cTempTab)->FLD_PARTIC ,1,"")
			//Descrição do solicitante.
			ElseIf aStructFLD[nX][1] $ "FLD_DSCSOL"
				(cTempTab)->FLD_DSCSOL := GETADVFVAL("RD0","RD0_NOME",xFilial("RD0") + (cTempTab)->FLD_SOLIC ,1,"")
			EndIf
			
		EndIf
	Next nX

	(cTempTab)->(MsUnlock())
	(cAliasTrb)->(DbSkip())
EndDo

If ( Select( cAliasTrb ) > 0 )
	DbSelectArea(cAliasTrb)
	DbCloseArea()
EndIf	

(cTempTab)->(DbGotop())
For nX := 1 To Len(aStructFLD)
	If	!aStructFLD[nX][1] $ "FLD_FILIAL, FLD_TIPO, FLD_ITEM, FLD_JUSTIF, FLD_NOMEAP, FLD_DSCPAR, FLD_DSCSOL, FLDRECNO"
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aStructFLD[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStructFLD[nX][1]))
		aColumns[Len(aColumns)]:SetSize(aStructFLD[nX][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStructFLD[nX][4])
		If aStructFLD[nX][1] $ "FLD_OK"
			aColumns[Len(aColumns)]:SetPicture('@!')
		Else
			aColumns[Len(aColumns)]:SetPicture(PesqPict("FLD",aStructFLD[nX][1]))
		EndIf
		If aStructFLD[nX][1] $ "FLD_PARTIC"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetTitle(STR0132)
			aColumns[Len(aColumns)]:SetData( &("{||"+aStructFLD[Len(aStructFLD)-1][1]+"}") )
		EndIf
		If aStructFLD[nX][1] $ "FLD_SOLIC"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetTitle(STR0133)
			aColumns[Len(aColumns)]:SetData( &("{||"+aStructFLD[Len(aStructFLD)][1]+"}") )
		EndIf	
	EndIf 	
Next nX 

Return({cTempTab,aColumns})


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menudef

@author pequim

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRot := {}


ADD OPTION aRot TITLE STR0026	ACTION "F667ApRp('R')"         OPERATION 2 ACCESS 0         //"Reprovar"
ADD OPTION aRot TITLE STR0019	ACTION "F667ApRp('A')"         OPERATION 4 ACCESS 0          //"Aprovar" 


Return(Aclone(aRot))


//-------------------------------------------------------------------
/*/{Protheus.doc} F667ApRp
Aprova ou reprova as solicitacoes de adiantamento

@author pequim

@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function F667ApRp (cOpcao/*A - Aprov ou R - Reprov*/,lAutomato)

Local aArea 	:= GetArea()	
Local aAreaFLD 	:= FLD->(GetArea())
Local aRegsFLD	:= {}  
Local nLenRegs 	:= 0     
Local nX		:= 0
Local cInfo		:= ""
Local aUser		:= {}
Local aAprv 		:= FResAprov("1")	//"1" = Adiantamentos

Default lAutomato	:= .F.

/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Aprovação de Solicitação (.T. or .F.)
	aAprv[2] - Avaliação do Gestor (.T. or .F.)
	aAprv[3] - Lib. do Pagamento (.T. or .F.)
*/
Default cOpcao	   := ""
Default l667ARVLT  := .F.

If cOpcao $ "AR" 

	FINXUser(__cUserId,aUser,.T.)

	(cAliasMrk)->(dbGoTop())

	BEGIN TRANSACTION

	While (cAliasMrk)->(!Eof())
			
		If !EMPTY((cAliasMrk)->(FLD_OK)) .OR. l667ARVLT
			FLD->(dbGoto((cAliasMrk)->FLDRECNO))
		
			If cOpcao=="A" //Se Aprovado
				//Atualiza adiantamento para aprovada
				RecLock("FLD",.F.)
					FLD_STATUS	:= "2" //Aprovado
					FLD_APROV	:= aUser[1]
					FLD_VALAPR	:= FLD_VALOR
					FLD_DTAPRO	:= dDatabase 	 
					FLD_OBSAPR	:= STR0106	//"Aprovação de adiantamentos de viagem para pagamento (Lote)."
				FLD->(MsUnLock())	
				//PCREQ-3829 Aprovação Automática
				//Se aAprv[3] == .F., Aprovação Automatica para Liberação de Pagamento está Acionada.
				If !aAprv[3]
					If FResAprov("4")[1]
						If !l667ARVLT
							MsgRun( STR0051,, {|| F667GeraLib(1,FLD->(RECNO()),.T.) } ) //"Processando liberação de pagamento..."
						Else
							F667GeraLib(1,FLD->(RECNO()),.T.)
						Endif
					Else
						RecLock("FLD",.F.)
							FLD->FLD_STATUS	:= "1" 	//Solicitado
							FLD->FLD_OBSAPR	:= ""
							FLD->FLD_DTAPRO	:= ctod("")
							FLD->FLD_APROV	:= ""
						FLD->(MsUnlock())	
					Endif
				Endif
				
			Else //Se Reprovado 

				//Atualiza adiantamento para Reprovado
				RecLock("FLD",.F.)
					FLD_STATUS	:= "0" //Negada
					FLD_APROV	:= ""
				FLD->(MsUnLock())	

				//Manda Email para o participante - Negado (Depto Viagens)
				F667MsgMail(3,,,,FLD->FLD_VIAGEM,FLD->FLD_ITEM,FLD->FLD_PARTIC)

			EndIf

			AADD(aRegsFLD,(cAliasMrk)->FLDRECNO)
		EndIf
		
		(cAliasMrk)->(DbSkip())

	Enddo

	END TRANSACTION

	//Destravo os registros marcados
	nLenRegs := Len(aRegsFLD)
	For nX := 1 to nLenRegs
		FLD->(dbGoTo(aRegsFLD[nX]))
		FLD->(MsRUnlock())
	Next	

	If nLenRegs > 0 .and. !l667ARVLT

		If nLenRegs == 1
			cInfo := STR0103+IIF(cOpcao == 'A',STR0104,STR0105)    //'Foi realizada 1 '###'aprovação.'###'reprovação.'
		Else
			cInfo := STR0078+Alltrim(STR(nLenregs))+IIF(cOpcao == 'A',STR0081,STR0082)    //"Foram realizadas "###' aprovações.'###' Reprovações'
		Endif

		MSGINFO(cInfo)	//"Foram realizadas "###' aprovações.'###
	
		If !lAutomato
			oMrkBrowse:GetOwner():End()
		EndIf
	
	Endif
Endif

FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()

RestArea(aAreaFLD)
RestArea(aArea)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} Fa667Mark
Marcacao de um registro

@author pequim

@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------

Static Function Fa667Mark(cAliasTRB)

Local lRet	:= .T.

FLD->(dbGoto((cAliasTRB)->FLDRECNO))

If FLD->(MsRLock()) .AND. (cAliasTRB)->(MsRLock())
	lRet := .T.
Else
	IW_MsgBox(STR0080,STR0038,"STOP")		//"Este registro está sendo utilizado em outro terminal, não podendo ser selecionado"###"Atenção"
	lRet := .F.
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F667Inverte
Marcacao de vários registros

@author pequim

@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function F667Inverte(cAliasTRB,lTudo)

Local nReg 	 := (cAliasTRB)->(Recno())
Local cMarca := oMrkBrowse:cMark

Default lTudo := .T.


dbSelectArea(cAliasTRB)
If lTudo
	dbgotop() 
	cMarca := oMrkBrowse:cMark
Endif

While !Eof()

	FLD->(dbGoto((cAliasTRB)->FLDRECNO))
	
	If FLD->(MsRLock()) .AND. (cAliasTRB)->(MsRLock())
	
		IF	(cAliasTRB)->FLD_OK == cMarca
			(cAliasTRB)->FLD_OK := "  "
			(cAliasTRB)->(MsUnlock())
			FLD->(MsUnlock())			
		Else
			(cAliasTRB)->FLD_OK := cMarca
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
/*/{Protheus.doc} F667FilApAdt
Filtro da Browse

@author pequim

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function F667FilApAdt (lAutomato)

Local cIdUser		:= __cUserId
Local cUsuarios		:= ""
Local cStatus		:= ""
Local cParticDe		:= Replicate (" ", Len(FLD->FLD_PARTIC)) // Space(Len(SE1->E1_NATUREZ))
Local cParticAte	:= Replicate ("Z", Len(FLD->FLD_PARTIC)) // Space(Len(SE1->E1_NATUREZ))
Local cViagemDe		:= Replicate (" ", Len(FLD->FLD_VIAGEM)) // Space(Len(SE1->E1_NATUREZ))
Local cViagemAte	:= Replicate ("Z", Len(FLD->FLD_VIAGEM)) // Space(Len(SE1->E1_NATUREZ))
Local cAprovador	:= Replicate (" ", Len(FLD->FLD_APROV))  // Space(Len(SE1->E1_NATUREZ))
Local nParCont		:= 0
Local lContinua 	:= .T. 
Local aPerguntas	:= {}
Local aParam		:= {}
Local dDataIni		:= FirstDay(dDataBase)
Local dDataFim		:= LastDay(dDataBase)

Default lAutomato := .F. 

aPerguntas := { { 1, STR0028	, cParticDe  ,"@!",'.T.',"RD0",".T.",60, .F.},;		//"Participante De"
				{ 1, STR0029	, cParticAte ,"@!",'.T.',"RD0",".T.",60, .F.},;		//"Participante Até"
				{ 1, STR0030	, dDataIni   ,""  ,'.T.',""   ,".T.",50, .T.},;		//"Dt. Prev. Pag De"
				{ 1, STR0031	, dDataFim   ,""  ,'.T.',""   ,".T.",50, .T.},;		//"Dt. Prev. Pag Até"
				{ 9, STR0032	, 100, 15 , .T.  },;								//"Status"
				{ 5, STR0004    , .T., 100,, .T. },;								//'Solicitado'
				{ 5, STR0009    , .T., 100,, .T. }}									//"Bloqueado"


If !lAutomato 
	lContinua := ParamBox( aPerguntas,STR0033,aParam,{||.T.},,,,,,FunName(),.T.,.T.) 		//"Parâmetros"
Else
	If FindFunction("GetParAuto")
		aParam	:= GetParAuto("FINA667TestCase")
		lContinua	:= .T.
	EndIf
EndIf

//-----------------------------------------------------------
// Garantindo que os valores do parambox estarão nas devidas variáveis MV_PARXX
//-----------------------------------------------------------
If lContinua
	For nParCont := 1 To Len(aParam)
		&("MV_PAR"+CVALTOCHAR(nParCont)) := aParam[nParCont]
	Next nParCont

	//Valida se selecionou algum Status para filtro
	//Caso contrário, sai da rotina
	If !mv_par06 .and. !mv_par07
		lContinua := .F.
	Endif
Endif

Return lContinua
