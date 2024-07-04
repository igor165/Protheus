#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#Include 'FWMVCDef.ch'
#Include 'FINA667.ch'

Static cAliasMrk	:= ""
STATIC _oF667LIB1

//-------------------------------------------------------------------
/*/{Protheus.doc} F667LIBERA
Liberacao do gestor

@author pequim

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function F667LIBERA(cAlias,nReg,nOpc,lAutomato)

Local aAlias		:= {}								//Array para o retorno da função TK600QueryDAC
Local aColumns		:= {}								//Colunas do Browse			
Local oDlgMrk 		:= Nil
Local aRotOld		:= {} //Tratamento para chamada direta da função (execauto)
Local aArea			:= GetArea()
Local aAprv 		:= FResAprov("1")	//"1" = Adiantamentos
Local aRetAuto 		:= {}
Local cRecTab		:= ''
Local cChavAut		:= ''
Local cOpc			:= ""
Local nX			:= 0

Default lAutomato   := .F.
Default nOpc        := 5

cOpc := If(nOpc == 2 .or. nOpc == 5,"A","R")

PRIVATE l667LbAut   := lAutomato .AND. !empty(cOpc)

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
	aRotOld	:= aClone(aRotina)
EndIf

If !aAprv[1]//Aprovação de Solicitação. Se aAprv[1] == .F., Aprovação Automatica da Solicitação está ativada. 
	Help(" ",1,"F667APROA",,STR0125,1,0)//Processo de aprovação da solicitação não habilitado
Else
	If F667FilLibera (lAutomato)
	
		//----------------------------------------------------------
		//Retorna as colunas para o preenchimento da FWMarkBrowse
		//----------------------------------------------------------
		aAlias 		:= F667QryAprSol()
		
		cAliasMrk	:= aAlias[1]
		aColumns 	:= aAlias[2]
	
		If !lAutomato
			If !(cAliasMrk)->(Eof()) 
				If l667LbAut
					F667ArvRpv(cOpc)						
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
				For nX := 1 TO Len(aRetAuto)
					cChavAut:= (cAliasMrk)->FLD_VIAGEM +'|'+ (cAliasMrk)->FLD_PARTIC +'|'+ (cAliasMrk)->FLD_ADIANT
					If cChavAut == aRetAuto[nX][1]
						F667Inverte(cAliasMrk,.T.,lAutomato)
					EndIf
				(cAliasMrk)->(DbSkip())
				Next nX
			EndDo
			
			F667ArvRpv("A",lAutomato)
			
			(cAliasMrk)->(dbGoto(cRecTab))
		EndIf
	
	Endif	
	
	If !Empty (cAliasMrk)
		dbSelectArea(cAliasMrk)
		dbCloseArea()	
		cAliasMrk := ""
		dbSelectArea("FLD")
		dbSetOrder(1)		
		//Deleta tabela temporária no banco de dados (criada na função F667QryAprSol)
		If _oF667LIB1 <> Nil
			_oF667LIB1:Delete()
			_oF667LIB1 := Nil
		Endif				
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
Static Function F667QryAprSol()

Local aArea			:= GetArea()			
Local aAreaSX3		:= SX3->(GetArea())	
Local cAliasTrb		:= GetNextAlias()		
Local aStructFLD	:= FLD->(DBSTRUCT())	//Estrutura da Tabela FLM - Aprovaçoes
Local aStructFLM	:= FLM->(DBSTRUCT())	//Estrutura da Tabela FLD - Prestação
Local aColumns		:= {}					//Array com as colunas a ser apresentada 
Local nX			:= 0
Local nPos			:= 0					
Local cTempTab		:= ""					
Local cPartIni		:= mv_par01  
Local cPartFim		:= mv_par02
Local cDataIni		:= DTOS(mv_par03)
Local cDataFim		:= DTOS(mv_par04)
Local cViagIni		:= mv_par05
Local cViagFim		:= mv_par06
Local cAprovador	:= mv_par07  
Local nTamCpo		:= Len(SX3->X3_CAMPO)

Aadd(aStructFLD, {"FLD_OK","C",1,0})
Aadd(aStructFLD, {"FLDRECNO","N",16,2})
Aadd(aStructFLD, {"FLMRECNO","N",16,2})
//
For nX := 1 To Len(aStructFLM)
	
	If aStructFLM[nX][1] $ "FLM_FILIAL, FLM_SEQ, FLM_APROV"
		aAdd(aStructFLD, aStructFLM[nX] )
	EndIf	

Next nX	

BeginSQL alias cAliasTrb

SELECT FLD.*, FLM.*, '  ' FLD_OK, ' ' FLD_USED, FLD.R_E_C_N_O_ FLDRECNO, FLM.R_E_C_N_O_ FLMRECNO  //FLD_OK é o campo criado para o campo de Marcação
FROM 
	%table:FLD% FLD
INNER JOIN %table:FLM% FLM 
	ON FLD.FLD_FILIAL = FLM.FLM_FILIAL
	AND FLD.FLD_VIAGEM = FLM.FLM_VIAGEM 
	AND FLD.FLD_PARTIC = FLM.FLM_PARTIC
	AND FLD.FLD_ADIANT = FLM.FLM_ADIANT 
	AND FLD.D_E_L_E_T_= ' '  
	AND FLD.%notDel%
WHERE
	FLM.FLM_FILIAL = %xFilial:FLM%  AND
	FLM.FLM_STATUS = '1' AND
	FLM.FLM_TIPO = '1' AND
	FLM.FLM_APROV = %exp:cAprovador% AND
	FLM.FLM_VIAGEM >= %exp:cViagIni% AND	
	FLM.FLM_VIAGEM <= %exp:cViagFim% AND	
	FLD.FLD_FILIAL = %xFilial:FLD%  AND
	FLD.FLD_PARTIC >= %exp:cPartIni% AND	
	FLD.FLD_PARTIC <= %exp:cPartFim% AND	
	FLD.FLD_DTPREV >= %exp:cDataIni% AND	
	FLD.FLD_DTPREV <= %exp:cDataFim% AND	
	FLD.FLD_STATUS = '8' AND
	FLD.FLD_ENCERR = ' ' AND	
	FLM.%notDel%		
ORDER BY
	FLD_FILIAL,FLD_VIAGEM,FLD_PARTIC,FLD_ADIANT	
EndSql

//------------------
//Criação da tabela temporaria 
//------------------
If _oF667LIB1 <> Nil
	_oF667LIB1:Delete()
	_oF667LIB1 := Nil
Endif

cTempTab := GetNextAlias()

_oF667LIB1 := FWTemporaryTable():New( cTempTab )  
_oF667LIB1:SetFields(aStructFLD) 	
_oF667LIB1:AddIndex("1", {"FLD_FILIAL","FLD_VIAGEM","FLD_PARTIC","FLD_ADIANT"})	
_oF667LIB1:Create()	

DbSetOrder(0) //Mantem a ordem natural de inserção dos registros na tabela

(cAliasTrb)->(DbGoTop())
While !(cAliasTrb)->(Eof())

	RecLock((cTempTab), .T.)	
	For nX := 1 To Len(aStructFLD)		
		nPos := (cAliasTrb)->(FieldPos(aStructFLD[nX][1]))
		If nPos > 0 
			If aStructFLD[nX][2] == 'D'
				FieldPut(FieldPos(aStructFLD[nX][1]), STOD((cAliasTrb)->(FieldGet(nPos))))  				
			Else
				FieldPut(FieldPos(aStructFLD[nX][1]), (cAliasTrb)->(FieldGet(nPos)))  	
			EndIf
		EndIf
	Next nX
	For nX := 1 To Len(aStructFLM)		
		nPos := (cAliasTrb)->(FieldPos(aStructFLM[nX][1]))
		If nPos > 0 
			FieldPut(FieldPos(aStructFLM[nX][1]), (cAliasTrb)->(FieldGet(nPos)))  	
		EndIf
	Next nX

	(cTempTab)->(MsUnlock())
	(cAliasTrb)->(DbSkip())
EndDo

If ( Select( cAliasTrb ) > 0 )
	DbSelectArea(cAliasTrb)
	DbCloseArea()
EndIf


For nX := 1 To Len(aStructFLM) 
	If	!aStructFLM[nX][1] == "FLD_OK" .And. !aStructFLM[nX][1] == "FLD_USED" .and. aStructFLM[nX][1] $ "FLM_FILIAL, FLM_SEQ, FLM_APROV"
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aStructFLM[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStructFLM[nX][1])) 
		aColumns[Len(aColumns)]:SetSize(aStructFLM[nX][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStructFLM[nX][4])
		aColumns[Len(aColumns)]:SetPicture(PesqPict("FLM",aStructFLM[nX][1]))  
	EndIf 	
Next nX 

For nX := 1 To Len(aStructFLD)
	If	!aStructFLD[nX][1] $ "FLD_FILIAL, FLD_TIPO, FLD_ITEM, FLD_JUSTIF, FLD_NOMEAP"
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aStructFLD[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStructFLD[nX][1])) 
		aColumns[Len(aColumns)]:SetSize(aStructFLD[nX][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStructFLD[nX][4])
		If !aStructFLD[nX][1] $ "FLD_OK, FLDRECNO, FLMRECNO"
			aColumns[Len(aColumns)]:SetPicture(PesqPict("FLD",aStructFLD[nX][1])) 
		EndIf
	EndIf 	
Next nX 

Return({cTempTab,aColumns})


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryAprSol
Menudef

@author pequim

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRot := {}

ADD OPTION aRot TITLE STR0026      	ACTION "F667ArvRpv('R')"         OPERATION 2 ACCESS 0          //"Reprovar" 
ADD OPTION aRot TITLE STR0019     	ACTION "F667ArvRpv('A')"         OPERATION 4 ACCESS 0          //'Aprovar'

Return(Aclone(aRot))


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryAprSol
Aprova ou reprova as solicitacoes de viagem

@author pequim

@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function F667ArvRpv(cOpcao/*A - Aprov ou R - Reprov*/,lAutomato)

Local aUserLogado 	:= {}
Local cTpAprov 		:= ""    
Local nX			:= 0
Local aArea			:= GetArea()
Local nLenRegs 		:= 0
Local aRegsFLD		:= {}   
Local cInfo			:= ""
Local cPedido		:= ""

Default l667LbAut   := .F.

If FINXUser(__cUserId,@aUserLogado,.T.) 
	
	If MV_PAR07 == aUserLogado[1] //Verifica se usuário é aprovador original
		cTpAprov := "O"
	Else //Verifica se usuário é aprovador substituto
		DbSelectArea("RD0")
		RD0->(DbSetOrder(1))
		If RD0->(DbSeek(xFilial("RD0")+MV_PAR07))
			If RD0->RD0_APSUBS == aUserLogado[1]	
				cTpAprov := "S"
			EndIf
		EndIf		
	EndIf
	
	If !Empty(cTpAprov)         
	
		(cAliasMrk)->(dbGoTop())	

    	BEGIN TRANSACTION

		While (cAliasMrk)->(!Eof())
		
			If !EMPTY((cAliasMrk)->(FLD_OK)) .OR. l667LbAut

				cPedido := (cAliasMrk)->(FLD_ITEM)

				FLM->(dbGoto((cAliasMrk)->FLMRECNO))

				//Realiza o Cancelamento da Solicitação de Aprovação no FLUIG.
				F667CanFlu(FLM->FLM_VIAGEM,FLM->FLM_PARTIC,FLM->FLM_ADIANT)
				//
				F667APROV(cOpcao, cTpAprov, aUserLogado, FLM->FLM_VIAGEM, FLM->FLM_PARTIC, FLM->FLM_ADIANT, FLM->FLM_SEQ,cPedido)			

				AADD(aRegsFLD,(cAliasMrk)->FLDRECNO)

			EndIf

			(cAliasMrk)->(DbSkip())
		EndDo 

		END TRANSACTION

	Else
		Help(" ",1,"F677NOTAPR",,STR0083,1,0)	//"Usuário não tem permissão para aprovar ou reprovar as prestações selecionadas."
	EndIf

EndIf

//Destravo os registros marcados
nLenRegs := Len(aRegsFLD)
For nX := 1 to nLenRegs
	FLD->(dbGoTo(aRegsFLD[nX]))
	FLD->(MsRUnlock())
Next	

If nLenRegs > 0

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

FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()

RestArea(aArea)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryAprSol
Marcacao de um registro

@author pequim

@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------

Function Fa667Mark(cAliasTRB)

Local lRet	:= .T.

FLD->(dbGoto((cAliasTRB)->FLDRECNO))

If FLD->(MsRLock()) .AND. (cAliasTRB)->(MsRLock())
	lRet := .t. //F667Inverte(cAliasTRB,.F.)
Else
	IW_MsgBox(STR0080,STR0038,"STOP")	//"Este registro está sendo utilizado em outro terminal, não podendo ser selecionado"###"Atenção"
	lRet := .F.
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryAprSol
Marcacao de vários registros

@author pequim

@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function F667Inverte(cAliasTRB,lTudo,lAutomato)

Local nReg 	 := (cAliasTRB)->(Recno())
Local cMarca := oMrkBrowse:cMark

Default lTudo := .T.
Default lAutomato	 := .F.

If !lAutomato
	cMarca := oMrkBrowse:cMark
Else
	cMarca := GetMark()
EndIf

dbSelectArea(cAliasTRB)
If lTudo
	If !lAutomato
		cMarca := oMrkBrowse:cMark
	Else
		cMarca := GetMark()
	EndIf
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

If !lAutomato
	oMrkBrowse:oBrowse:Refresh(.t.)
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F667FilBrowse
Filtro da Browse

@author pequim

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function F667FilLibera (lAutomato)

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

If lContinua
	aPerguntas := { { 1, STR0028 , cParticDe  ,"@!",'.T.',"RD0",".T.",60, .F.},;		//"Participante De"
					{ 1, STR0029 , cParticAte ,"@!",'.T.',"RD0",".T.",60, .F.},;		//"Participante Até"
					{ 1, STR0030 , dDataIni   ,""  ,'.T.',""   ,".T.",50, .T.},;		//"Dt. Prev. Pag De"
					{ 1, STR0031 , dDataFim   ,""  ,'.T.',""   ,".T.",50, .T.},;		//"Dt. Prev. Pag Até"								 		
					{ 1, STR0084 , cViagemDe  ,"@!",'.T.',"FL5",".T.",60, .F.},;		//"Viagem De"
					{ 1, STR0085 , cViagemAte ,"@!",'.T.',"FL5",".T.",60, .F.},;		//"Viagem Até"
					{ 1, STR0102 , cAprovador ,"@!",'.T.',"RD0",".T.",60, .F.}}			//"Aprovador"

 
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
Endif

Return lContinua


//-------------------------------------------------------------------
/*/{Protheus.doc} F667APROV
Atualiza a estrutura de aprovacao da solicitação de adiantamento

@author pequim

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function F667APROV(cOpcao, cTpAprov, aSubst, cViagem, cPartic, cAdiant, cSeq, cPedido)

Local aArea 	:= GetArea()	
Local aAreaFLM 	:= FLM->(GetArea())
Local aAreaFLD 	:= FLD->(GetArea())
Local aAprv 		:= FResAprov("1")//"1" = Adiantamentos
/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Aprovação de Solicitação (.T. or .F.)
	aAprv[2] - Avaliação do Gestor (.T. or .F.)
	aAprv[3] - Lib. do Pagamento (.T. or .F.)
*/

Default cOpcao	:= ""
Default cTpAprov:= ""	
Default aSubst	:= {}
Default cViagem	:= ""
Default cAdiant	:= ""
Default cPartic	:= ""
Default cSeq	:= ""
Default cPedido := "01"

If cOpcao $ "AR" ;
	.And. ( (cTpAprov == "S" .And. Len(aSubst)>0 ) .Or. cTpAprov == "O") ;
	.And. !Empty(cViagem) ;
	.And. !Empty(cAdiant) ;
	.And. !Empty(cPartic) ;
	.And. !Empty(cSeq) ;
	
	DbSelectArea("FLM")
	FLM->(DbSetOrder(1))
	If FLM->(DbSeek(xFilial("FLM")+cViagem+cPartic+cAdiant+cSeq+"1"))

		If cTpAprov == "S" //Se Substituto
			//Cancela aprovação atual
			RecLock("FLM",.F.)
				FLM_STATUS	 := "4" //Cancelada
				FLM_DTLIB	 := dDatabase
			FLM->(MsUnLock())
			
			//Cria nova aprovação para o substituto
			RecLock("FLM",.T.)
				FLM_FILIAL	:= xFilial("FLM")
				FLM_VIAGEM	:= cViagem
				FLM_PARTIC	:= cPartic
				FLM_ADIANT	:= cAdiant				
				FLM_SEQ		:= cSeq
				FLM_TIPO	:= "2"
				FLM_APROV	:= aSubst[1]
				FLM_NOMEAP	:= aSubst[2]
				FLM_STATUS	:= IIF(cOpcao=="A","2","3")
				FLM_DTLIB	:= dDatabase
			FLM->(MsUnLock())
		Else
			RecLock("FLM",.F.)
				FLM_STATUS	 := IIF(cOpcao=="A","2","3")
				FLM_DTLIB	 := dDatabase
			FLM->(MsUnLock())
		EndIf
				
		FLM->(DbSkip())
			
		If cOpcao=="A" //Se Aprovado
			//Atualiza proximo registro para Ag. Aprovação
			If FLM->(!Eof()) .And. xFilial("FLM")+cViagem+cPartic+cAdiant == FLM->(FLM_FILIAL+FLM_VIAGEM+FLM_PARTIC+FLM_ADIANT)
				RecLock("FLM",.F.)
					FLM_STATUS	 := "1" //Ag. Aprovação
				FLM->(MsUnLock())

				//Mandar email para o proximo aprovador (Gestor)
				F667MsgMail(1,,,FLM->FLM_APROV,FLM->FLM_VIAGEM,cPedido,cPartic)  
			Else				
				//Atualiza adiantamento para aprovada
				DbSelectArea("FLD")
				FLD->(DbSetOrder(1))
				If FLD->(DbSeek(xFilial("FLD")+cViagem+cPartic+cAdiant))
					RecLock("FLD",.F.)
					FLD->FLD_STATUS	:= "2" 		//Aprovada
					FLD->FLD_VALAPR	:= FLD_VALOR //Aprova o valor informado
					FLD->FLD_APROV  := aSubst[1]
					FLD->FLD_DTAPRO := dDataBase
					FLD->(MsUnLock())
					//PCREQ-3829 Aprovação Automática
					If aAprv[2]//Avaliação do Gestor
						RecLock("FLD",.F.)
						FLD->FLD_STATUS	:= "1"//Solicitado 		
						FLD->(MsUnLock())
					Elseif !(aAprv[3])//Liberação Pagamento
						If FResAprov("4")[1]
							MsgRun( STR0051,, {|| F667GeraLib(1,FLD->(RECNO()),.T.) } ) //"Processando liberação de pagamento..."
						Else
							RecLock("FLD",.F.)
								FLD->FLD_STATUS	:= "1" 	//Solicitado							
								FLD->FLD_DTAPRO	:= ctod("")
								FLD->FLD_APROV	:= ""
							FLD->(MsUnlock())	
						Endif
					Endif		
				EndIf				
			EndIf
		Else //Se Reprovado 
			//Atualiza proximo registro para Cancelados
			While	FLM->(!Eof()) .And. xFilial("FLM")+cViagem+cPartic+cAdiant == FLM->(FLM_FILIAL+FLM_VIAGEM+FLM_PARTIC+FLM_ADIANT)
				RecLock("FLM",.F.)
					FLM_STATUS	 := "4" //Cancelada
					FLM_DTLIB	 := dDatabase
				FLM->(MsUnLock())
				FLM->(DbSkip())
			EndDo
					
			//Atualiza adiantamento para Reprovado
			DbSelectArea("FLD")
			FLD->(DbSetOrder(1))
			If FLD->(DbSeek(xFilial("FLD")+cViagem+cPartic+cAdiant))
				RecLock("FLD",.F.)
					FLD_STATUS	 := "0" //Negada
				FLD->(MsUnLock())	

				//Mandar email para o participante - Negado adto
				F667MsgMail(2,,,FLM->FLM_APROV,FLM->FLM_VIAGEM,cPedido,cPartic)
			EndIf					
		EndIf
	EndIf
EndIf

RestArea(aAreaFLD)
RestArea(aAreaFLM) 
RestArea(aArea)	
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F667EXCAPR
Exclui aprovacao da liberacao de adiantamento

@author pequim

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function F667EXCAPR(cViagem, cPartic, cAdiant)

Local aArea		:= GetArea()
Local lRet 		:= .F.

If !Empty(cViagem) .And.  !Empty(cPartic) .And. !Empty(cAdiant) 

	DbSelectArea("FLM")
	FLM->(DbSetOrder(1))
	If FLM->(MSSeek(xFilial("FLM")+cViagem+cPartic+cAdiant))
		While	FLM->(!Eof()) .And. xFilial("FLM")+cViagem+cPartic+cAdiant == FLM->(FLM_FILIAL+FLM_VIAGEM+FLM_PARTIC+FLM_ADIANT)
			RecLock("FLM",.F.)
			FLM->(DbDelete())
			FLM->(MsUnLock())
			FLM->(DbSkip())
		EndDo
	Endif
	//Atualiza prestação para Em aberto
	DbSelectArea("FLD")
	FLD->(DbSetOrder(1))
	If FLD->(DbSeek(xFilial("FLD")+cViagem+cPartic+cAdiant))
		RecLock("FLD",.F.)
			FLD_STATUS	 := "1" //Em Aberto
		FLD->(MsUnLock())
		lRet := .T.	
	EndIf		
		
Else
	Help(" ",1,"FINA667PAR",,STR0075,1,0) //Parâmetros inválidos.
EndIf

RestArea(aArea)

Return lRet
