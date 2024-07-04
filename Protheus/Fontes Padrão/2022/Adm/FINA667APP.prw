#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#Include 'FWMVCDef.ch'
#Include 'FINA667.ch'

Static cAliasMrk		:= ""
STATIC _oF667APP1

//-------------------------------------------------------------------
/*/{Protheus.doc} F667LIBPGLT
Aprovacao de pagamentos de adiantamentos (Lote)

@author pequim

@since 05/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function F667LIBPGLT(cAlias,nReg,nOpc,lAutomato)

Local aAlias		:= {}								
Local aColumns		:= {}								
Local oDlgMrk 		:= Nil
Local aRotOld		:= {}
Local aArea			:= GetArea()
Local aAprv 		:= FResAprov("1")//"1" = Adiantamentos
Local cChavAut := ''
Local aRetAuto	:= ''
Local nX	:= 0
Local cMarca := GetMark()

Default lAutomato   := .F.

PRIVATE l667LbPGL   := lAutomato

If !lAutomato
	aRotOld		:= aClone(aRotina)
EndIf

/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Aprovação de Solicitação (.T. or .F.)
	aAprv[2] - Avaliação do Gestor (.T. or .F.)
	aAprv[3] - Lib. do Pagamento (.T. or .F.)
*/
If !lAutomato
	PRIVATE aRotina	 	:= Menudef()
EndIf
 
If !aAprv[3]//Liberação do Pagamento. Se aAprv[3] == .F., Aprovação Automatica da Liberação do Pagamento está ativada.
	Help(" ",1,"F667APROA",,STR0121,1,0)//Processo de liberação não habilitado
Else
	If F667FilApAdt (lAutomato)

		//----------------------------------------------------------
		//Retorna as colunas para o preenchimento da FWMarkBrowse
		//----------------------------------------------------------
		aAlias 		:= F667QryAprPgt()		
		cAliasMrk	:= aAlias[1]
		aColumns 	:= aAlias[2]
	
		If !lAutomato
			If !(cAliasMrk)->(Eof())
				If l667LbPGL
					F667LibPag()						
				Else
					//------------------------------------------
					//Criação da MarkBrowse no Layer LISTA_DAC
					//------------------------------------------
					oMrkBrowse:= FWMarkBrowse():New()
					oMrkBrowse:SetFieldMark("FLD_OK")
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
			
			F667LibPag(lAutomato)
			
			(cAliasMrk)->(dbGoto(cRecTab))
		EndIf
	
	Endif	
	
	If !Empty (cAliasMrk)
		dbSelectArea(cAliasMrk)
		dbCloseArea()
		cAliasMrk := ""
		dbSelectArea("FLD")
		dbSetOrder(1)
		//Deleta tabela temporária no banco de dados (criada na função F667QryAprPgt)		
		If _oF667APP1 <> Nil
			_oF667APP1:Delete()
			_oF667APP1 := Nil
		Endif
	Endif

Endif

RestArea(aArea)
	
If !lAutomato
	aRotina := aClone(aRotOld)
EndIf

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} F667QryAprPgt
Selecao do dados

@author pequim

@since 05/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F667QryAprPgt()

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
Local cNomePartic := ""
Local cNomeSolic  := ""
Local cNomeAprov  := ""
Local cNomeForn   := ""
Local cWhere  		:= ""	
Local nAdiTxMe		:= SuperGetMV("MV_ADITXME",.T.,1)
Local nPos			:= 0
						
If nAdiTxMe == 1
	cWhere +=  " (( FLD.FLD_MOEDA = '1' ) OR " 
	cWhere +=  "  (FLD.FLD_MOEDA <> '1' AND FLD.FLD_TAXA > 0) ) AND "
Endif

cWhere += " FLD.FLD_STATUS = '2' "
cWhere := "%"+cWhere+"%"

BeginSQL alias cAliasTrb

SELECT FLD.*, '  ' FLD_OK, ' ' FLD_USED, '                                        ' FLD_DSCPAR, '                                        ' FLD_DSCSOL,'                                        ' FLD_DSCAPR,'                                        ' FLD_DSCFOR, FLD.R_E_C_N_O_ FLDRECNO  //FLD_OK é o campo criado para o campo de Marcação
FROM 
	%table:FLD% FLD
WHERE
	FLD.FLD_FILIAL = %xFilial:FLD%  AND
	FLD.FLD_PARTIC >= %exp:cPartIni% AND	
	FLD.FLD_PARTIC <= %exp:cPartFim% AND	
	FLD.FLD_DTPREV >= %exp:cDataIni% AND	
	FLD.FLD_DTPREV <= %exp:cDataFim% AND	
	FLD.FLD_ENCERR = ' ' AND	
	%Exp:cWhere% AND
	FLD.%notDel%		

ORDER BY
	FLD_FILIAL,FLD_VIAGEM,FLD_PARTIC,FLD_ADIANT	

EndSql

//----------------------------------------------------------------------
// Cria arquivo de dados temporário
//----------------------------------------------------------------------
Aadd(aStructFLD, {'FLD_OK','C', 1,0,''})
Aadd(aStructFLD, {'FLDRECNO','N',16,2,''})
Aadd(aStructFLD, {'FLD_DSCPAR','C', 40,0,'Nome Participante'})
Aadd(aStructFLD, {'FLD_DSCSOL','C', 40,0,'Nome Solicitante'})
Aadd(aStructFLD, {'FLD_DSCAPR','C', 40,0,'Nome Aprovador'})
Aadd(aStructFLD, {'FLD_DSCFOR','C', 40,0,'Nome Fornecedor'})

//------------------
//Criação da tabela temporaria 
//------------------
If _oF667APP1 <> Nil
	_oF667APP1:Delete()
	_oF667APP1 := Nil
Endif

cTempTab := GetNextAlias()

_oF667APP1 := FWTemporaryTable():New( cTempTab )  
_oF667APP1:SetFields(aStructFLD) 	
_oF667APP1:AddIndex("1", {"FLD_FILIAL","FLD_VIAGEM","FLD_PARTIC","FLD_ADIANT"})	
_oF667APP1:Create()	

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
			//Descrição do fornecedor
			ElseIf aStructFLD[nX][1] $ "FLD_DSCFOR"
				(cTempTab)->FLD_DSCFOR := GETADVFVAL("RD0","RD0_NOME",xFilial("RD0") + (cTempTab)->FLD_FORNEC ,1,"")			
			//Descrição do aprovador.
			ElseIf aStructFLD[nX][1] $ "FLD_DSCAPR" 
				(cTempTab)->FLD_DSCAPR := GETADVFVAL("RD0","RD0_NOME",xFilial("RD0") + (cTempTab)->FLD_APROV ,1,"")
			EndIf
			
		EndIf
	Next nX

	(cTempTab)->(MsUnlock())
	(cAliasTrb)->(DbSkip())
EndDo

(cTempTab)->(DbGotop())
For nX := 1 To Len(aStructFLD)
	If	!aStructFLD[nX][1] $ "FLD_FILIAL, FLD_TIPO, FLD_ITEM, FLD_JUSTIF, FLD_NOMEAP, FLD_DSCPAR, FLD_DSCSOL, FLD_DSCAPR, FLD_DSCFOR, FLDRECNO"
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
			aColumns[Len(aColumns)]:SetTitle('Nome Participante')
			aColumns[Len(aColumns)]:SetData( &("{||"+aStructFLD[Len(aStructFLD)-3][1]+"}") )
		EndIf
		If aStructFLD[nX][1] $ "FLD_SOLIC"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetTitle('Nome Solicitante')
			aColumns[Len(aColumns)]:SetData( &("{||"+aStructFLD[Len(aStructFLD)-2][1]+"}") )
		EndIf
		If aStructFLD[nX][1] $ "FLD_APROV"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetTitle('Nome Aprovador')
			aColumns[Len(aColumns)]:SetData( &("{||"+aStructFLD[Len(aStructFLD)-1][1]+"}") )
		EndIf	
		If aStructFLD[nX][1] $ "FLD_LOJA"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetTitle('Nome Fornecedor')
			aColumns[Len(aColumns)]:SetData( &("{||"+aStructFLD[Len(aStructFLD)][1]+"}") )
		EndIf
	EndIf 	
Next nX 

Return({cTempTab,aColumns})


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menudef

@author pequim

@since 05/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRot := {}

ADD OPTION aRot TITLE STR0076  ACTION "F667LibPag()"         OPERATION 4 ACCESS 0          //"Liberar Pagamento"

Return(Aclone(aRot))


//-------------------------------------------------------------------
/*/{Protheus.doc} F667ApRp
Aprova ou reprova as solicitacoes de adiantamento

@author pequim

@since 05/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function F667LibPag(lAutomato)

Local aArea 	:= GetArea()	
Local aAreaFLD 	:= FLD->(GetArea())
Local aRegsFLD	:= {}  
Local nLenRegs 	:= 0     
Local nX		:= 0
Local lRet		:= .T.
Local cInfo		:= ""

Default lAutomato := .F.

(cAliasMrk)->(dbGoTop())

BEGIN TRANSACTION

While (cAliasMrk)->(!Eof())
			
	If !EMPTY((cAliasMrk)->(FLD_OK)) .OR. l667LbPGL
		FLD->(dbGoto((cAliasMrk)->FLDRECNO))

		If !l667LbPGL
			MsgRun( STR0077,, {||	lRet := F667GeraLib(1 , (cAliasMrk)->FLDRECNO , .T.) } ) 		//"Processando liberação de pagamento..."
		Else
			lRet := F667GeraLib(1 , (cAliasMrk)->FLDRECNO , .T.)
		Endif	
			
		If lRet
			AADD(aRegsFLD,(cAliasMrk)->FLDRECNO)
		Else
			If !l667LbPGL
				Exit
			Endif
		EndIf
	Endif	

	(cAliasMrk)->(DbSkip())
	
Enddo

END TRANSACTION

//Destravo os registros marcados
nLenRegs := Len(aRegsFLD)
For nX := 1 to nLenRegs
	FLD->(dbGoTo(aRegsFLD[nX]))
	FLD->(MsRUnlock())
Next	

If nLenRegs > 0

	If nLenRegs == 1
		cInfo := STR0103+STR0104    //'Foi realizada 1 '###'aprovação.'
	Else
		cInfo := STR0078+Alltrim(STR(nLenregs))+STR0081    //"Foram realizadas "###' aprovações.'
	Endif

	MSGINFO(cInfo)	//"Foram realizadas "###' aprovações.'###

	If !lAutomato
		oMrkBrowse:GetOwner():End()
	EndIf

Endif

FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
RestArea(aAreaFLD)
RestArea(aArea)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} Fa667Mark
Marcacao de um registro

@author pequim

@since 05/11/2013
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

@since 05/11/2013
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

@since 05/11/2013
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

Default lAutomato	:= .F.

aPerguntas := { { 1, STR0028	, cParticDe  ,"@!",'.T.',"RD0",".T.",60, .F.},;		//"Participante De"
				{ 1, STR0029	, cParticAte ,"@!",'.T.',"RD0",".T.",60, .F.},;		//"Participante Até"
				{ 1, STR0030	, dDataIni   ,""  ,'.T.',""   ,".T.",50, .T.},;		//"Dt. Prev. Pag De"
				{ 1, STR0031	, dDataFim   ,""  ,'.T.',""   ,".T.",50, .T.}}		//"Dt. Prev. Pag Até"

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
Endif

Return lContinua
