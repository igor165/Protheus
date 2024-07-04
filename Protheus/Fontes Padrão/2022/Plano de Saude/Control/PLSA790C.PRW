#INCLUDE "PLSA790C.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#DEFINE PLS_ADMINITRADOR '2'

STATIC lEvo := .F.

/*/{Protheus.doc} PLSA790C

Controle da class auditoria

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
CLASS PLSA790C FROM PLSCONTR

DATA cAudito			AS STRING
DATA cDirFax   	 	AS STRING
DATA cPerfil   	 	AS STRING
DATA cDesPerf  	 	AS STRING
DATA cCodDep	 		AS STRING
DATA cOperad			AS STRING
DATA cACab				AS STRING
DATA cAIte				AS STRING
DATA cACri				AS STRING
DATA nIdxIte			AS NUMERIC
DATA nIdxCri			AS NUMERIC
DATA cOwner			AS STRING
DATA cAllPerfil     	AS STRING
DATA cNumGuia       	AS STRING
DATA cCoddepa			AS STRING 
DATA lLibGuia			AS LOGIC  
DATA lIncProc			AS LOGIC 
DATA lVldRot			AS LOGIC
DATA lIncDem   	 	AS LOGIC
DATA lIncPar   	 	AS LOGIC
DATA lIncEnc   	 	AS LOGIC
DATA lMonFax   	 	AS LOGIC
DATA lNegPar  	 		AS LOGIC
DATA lIncAno 	 		AS LOGIC
DATA lDemanda  	 	AS LOGIC
DATA lInconsistente 	AS LOGIC
DATA lIncoRes			AS LOGIC
DATA lNotInRes			AS LOGIC
DATA lParticipativa	AS LOGIC
DATA lAgendada			AS LOGIC
DATA lOpAudi   	 	AS LOGIC
DATA lIntSau   	 	AS LOGIC
DATA lVisAud   	 	AS LOGIC
DATA lEmAnalise	 	AS LOGIC
DATA lEspera  	 		AS LOGIC
DATA lAnalisada  		AS LOGIC
DATA lAutorizada 		AS LOGIC
DATA lOwner		 	AS LOGIC
DATA lThisDep       	AS LOGIC
DATA lVisible	 		AS LOGIC
DATA lHaveOwner	 	AS LOGIC
DATA lHaveGuia			AS LOGIC
DATA lConsulta			AS LOGIC
DATA lSadt				AS LOGIC
DATA lInternacao		AS LOGIC
DATA lEvolucao			AS LOGIC
DATA lOdonto			AS LOGIC
DATA lReembolso		AS LOGIC
DATA lOPME				AS LOGIC
DATA lRotinaGen		AS LOGIC
DATA lProrrog			AS LOGIC
DATA lCriDia 			AS LOGIC

METHOD New() Constructor
METHOD GetRotiAtu(aDad,cPerfil)
METHOD GetFiles(cDirPerf,aFiles) 
METHOD GetDocBC(nAt,aFiles,cAlias,cUnico)
METHOD SetPerfil(cPerfil)
METHOD SetPrioridade(cPrio)
METHOD SetSituac(cSituac)
METHOD SetNegPar(lNegPar)
METHOD SetOnlyVisible(lVisible)
METHOD SetAuditoria(lAuditoria,lIntern,lEvolu,lReembolso,lPartic,aDadCri,aCabCri,cCodCri,cRegInt,cAliasCri,aColsITE,aHeaderITE,cAliasIte)
METHOD SetAuditoGen(lRotGen, cAliOrig, cAliasIte, cAliasCri, cCodOpe, cNumCont, cMatric, cNomUsr, aAtuAItens, aAtuFil, cCpRelac, cTipGui ) 
METHOD SetDemanda()
METHOD EMail()
METHOD BancoCon(cAlias,nOpc,lLog,cTipo)
METHOD VldAplication()
METHOD NegComp()
METHOD VldFLD(nFolder,oTFolder,cAlias)
METHOD VldAcessoGui(lEmAnlise,lIncons,lAutori, lAudit, cAlias)
METHOD MarkAll(oMark,lMarcar)
METHOD DelDocBC(nAt,aFiles) 
METHOD SetAtuPClass()
METHOD SetFieldGui( oSelf )
METHOD ProcPart() 
METHOD Destroy()

EndClass     
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

@param   cOperad Operadora do sistema registro da BX4

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD New(lInclusao) CLASS PLSA790C
::cOperad := RETCODUSR()
DEFAULT ::cPerfil	:= PLS_ADMINITRADOR
DEFAULT ::cCodDep	:= ""
DEFAULT ::lVisible	:= .F.
DEFAULT ::lVldRot	:= .T.
DEFAULT ::lNegPar	:= .F.
DEFAULT lInclusao   := .F.
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁVerifica se e possivel utilizar esta rotina
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !PLSALIASEXI("B53")                                       
	::lVldRot := .F.
	MSGALERT(STR0001 ) //"NЦo И possМvel utilizar esta rotina!"
	Return Self
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza informacoes da classe
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

if !lInclusao 
	::SetAtuPClass()
else
	oSelf := Self
	//Operador Corrente
	oSelf:cOperad := RETCODUSR()
	//Dados do operador
	RetDadOpe(oSelf)
endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se for interna-saude
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If ::lIntSau
	::SetOnlyVisible(.T.)
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim do Metodo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return Self
//-------------------------------------------------------------------
/*/{Protheus.doc} BancoCon
Banco de conhecimento

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
METHOD BancoCon(cAlias,lChkDeman,nOpc,lLog,cTipo) Class PLSA790C
LOCAL aArea      := GetArea()      
LOCAL nHoraBase  := Seconds()
LOCAL cCodUsuDef := "XXXXXX"
LOCAL lRet		 := .T.
LOCAL oPADC 	 := NIL
LOCAL cChaveIn  	:= B53->B53_NUMGUI
LOCAL cChaveAC9 := If(Alltrim(B53->B53_TIPO) == "6", xfilial('B4A')+cChaveIn, xfilial('BE4')+cChaveIn)
Local nsoma := 1
Local nI	:= 0
Local cChv := "-"
PRIVATE aRotina  := {}
DEFAULT nOpc 	 := 1  
DEFAULT lLog	 := .T.        
DEFAULT lChkDeman:= .F.

aRotina := {{STR0003,'MsDocument',0,3},{"InclusЦo RАpida",'PLSDOcs',0,3}} //"Conhecimento"

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza informacoes da classe
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
::SetAtuPClass()
B53->( DbSetOrder(1) )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se nao for interna-saude e a guia И de demanda
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If lChkDeman .And. !::lIntSau
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Verifica se foi selecionada a opcao de b. conhecimento da demanda.
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oPADC := PLSPADRC():New(cAlias) 
	
	If oPADC:lMDDemanda .And. ::lDemanda
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verifica se o registro de demanda (processo) pode ser editado se nao for 
		//Ё o owner especifico do registro lOwnerEsp
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If !oPADC:lOwnerEsp .And. !oPADC:lEditaProcesso
			MSGALERT(STR0002) //"Acesso negado ao processo"
			Return
		EndIf	
	EndIf    
	
	oPADC:Destroy(oPADC)
EndIf	
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se o acesso foi permitido exibi banco de conhecimento
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If AllTrim(B53->B53_TIPO) == "11" .and. (B53->B53_ALIMOV == "B4Q")
//ProrrogaГЦo
	
	cAlias := "B4Q"
	
	B4Q->( DbSetOrder(1) ) //B4Q_FILIAL + B4Q_OPEMOV + B4Q_ANOAUT + B4Q_MESAUT + B4Q_NUMAUT + DTOS(B4Q_DATPRO) + B4Q_HORPRO
	B4Q->( MsSeek( xFilial("B4Q") + cChaveIn ) )
	
	If cTipo == "I" // inclusЦo nos itens
		DbSelectArea("BQV")
		cIndex := CriaTrab(NIL,.F.)
		cQuery := "BQV_FILIAL == '" + xFilial("BQV") + "' "
		cQuery += " .And. BQV_CODOPE == '" + B4Q->B4Q_OPEMOV + "'"
		cQuery += " .And. BQV_ANOINT == '" + B4Q->B4Q_ANOAUT + "'"
		cQuery += " .And. BQV_MESINT == '" + B4Q->B4Q_MESAUT + "'"
		cQuery += " .And. BQV_NUMINT == '" + B4Q->B4Q_NUMAUT + "'"
		IndRegua("BQV",cIndex,BQV->(IndexKey()),,cQuery)
		
		If BQV->(!Eof())
			MaWndBrowse(0,0,300,600,"Retorno de Doctos. de Saida","BQV",,aRotina,,,,.T.,,,,,,.F.) //"Retorno de Doctos. de Saida"
		EndIf	
		
		BQV->(DbCloseArea())
	Else
		DbSelectArea("B4Q")
		cIndex := CriaTrab(NIL,.F.)
		MsDocument( "B4Q", B4Q->( RecNo() ), 2 )
	EndIf

ElseIf AllTrim(B53->B53_TIPO) != "6"

	BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
	BEA->( MsSeek( xFilial("BEA") + cChaveIn ) )
	
	if cTipo == "I" 
	
		DbSelectArea("BE2")
		cIndex := CriaTrab(NIL,.F.)
		cQuery := "BE2_FILIAL == '" + xFilial("BE2") + "' "
		cQuery += " .And. BE2_OPEMOV == '" + BEA->BEA_OPEMOV + "'"
		cQuery += " .And. BE2_ANOAUT == '" + BEA->BEA_ANOAUT + "'"
		cQuery += " .And. BE2_MESAUT == '" + BEA->BEA_MESAUT + "'"
		cQuery += " .And. BE2_NUMAUT == '" + BEA->BEA_NUMAUT + "'"
		
		IndRegua("BE2",cIndex,BE2->(IndexKey()),,cQuery)
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Ativa o banco de conhecimento
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		
		If BE2->(!Eof())
			lRet := MaWndBrowse(0,0,300,600,"UsuАrio","BE2",,aRotina,,,,.T.,,,,,,.F.) //"Retorno de Doctos. de Saida"
		EndIf

		BE2->(DbCloseArea())
	else
	
		DbSelectArea("BEA")
		cIndex := CriaTrab(NIL,.F.)
		MsDocument( "BEA", BEA->( RecNo() ), 2 )
	
	endif

Else

	B4A->( DbSetOrder(1) ) //B4A_FILIAL + B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT + DTOS(B4A_DATPRO) + B4A_HORPRO
	B4A->( MsSeek( xFilial("B4A") + cChaveIn ) )
	
	if cTipo == "I"

		DbSelectArea("B4C")
		cIndex := CriaTrab(NIL,.F.)
		cQuery := "B4C_FILIAL == '" + xFilial("B4C") + "' "
		cQuery += " .And. B4C_OPEMOV == '" + B4A->B4A_OPEMOV + "'"
		cQuery += " .And. B4C_ANOAUT == '" + B4A->B4A_ANOAUT + "'"
		cQuery += " .And. B4C_MESAUT == '" + B4A->B4A_MESAUT + "'"
		cQuery += " .And. B4C_NUMAUT == '" + B4A->B4A_NUMAUT + "'"
		
		IndRegua("B4C",cIndex,B4C->(IndexKey()),,cQuery)
		
		If B4C->(!Eof())
			MaWndBrowse(0,0,300,600,"Retorno de Doctos. de Saida","B4C",,aRotina,,,,.T.,,,,,,.F.) //"Retorno de Doctos. de Saida"
		EndIf

		B4C->(DbCloseArea())		
	else
	
		DbSelectArea("B4A")
		cIndex := CriaTrab(NIL,.F.)
		MsDocument( "B4A", B4A->( RecNo() ), 2 )
	
	endif
	
endif

IF ::lRotinaGen
   //Por ser genИrica, nЦo sei qual chave И da tabela cabeГalho. Pego o indice do item e tento procurar as semelhantes
   	(::cACab)->(DbSelectArea(::cACab))
   cInd := PLSVerInd(1, .T.)
   cInd2 := SUBSTR(StrTran(cInd, ::cAIte, ::cACab),0,Len(cInd)-1) 
   While !(Empty(cChv))
     IF (cInd2 == SubStr( (::cACab)->(indexkey(nsoma)), 0, Len(cInd2)) )
        (::cACab)->(DbSelectArea(nsoma))
        EXIT
       ELSE
         cChv := (::cACab)->(indexkey(nsoma))
         nSoma++
     ENDIF  
   ENDDO 
   
   cInd2 := SEPARA(cInd, "+", .F.)
	(::cACab)->( MsSeek( xFilial(::cACab) + cChaveIn ) )
	cIndex := CriaTrab(NIL,.F.)
	cQuery := (::cACab)+"_FILIAL == '" + xFilial(::cACab) + "' "
	
	For nI := 1 TO LEN(cInd2)
 	  cQuery += "'"+cInd2[nI]+"' == '"+(cACab)->cInd2[nI]+"'"
 	Next  
	
	IndRegua((::cACab),cIndex,(::cACab)->(IndexKey()),,cQuery)
	
	If (::cACab)->(!Eof())
		MaWndBrowse(0,0,300,600,"Retorno de Doctos. de Saida","B4C",,aRotina,,,,.T.,,,,,,.F.) //"Retorno de Doctos. de Saida"
	EndIf

	(::cACab)->(DbCloseArea())
ENDIF

AC9->(DbSetOrder(2))//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ, R_E_C_N_O_, D_E_L_E_T_

If AC9->(dbSeek( xFilial("AC9") + cAlias + xfilial(cAlias) + cChaveAC9))
    dbSelectArea("B53")
    If B53->(dbSeek(xFilial("B53")+cChaveIn))
      	If B53->B53_BANCON != '1' 
	      	B53->(Reclock("B53",.F.))
			B53->B53_BANCON := '1'
			B53->(MsUnlock())
		EndIf
	EndIf
else
		 dbSelectArea("B53")
    If B53->(dbSeek(xFilial("B53")+cChaveIn))
      If B53->B53_BANCON != '0' 
	      	B53->(Reclock("B53",.F.))
			B53->B53_BANCON := '0'
			B53->(MsUnlock())
		EndIf
	EndIf
EndIf

RetIndex( cAlias )    
dbClearFilter()
FErase( cIndex+OrdBagExt() )

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se cancelou 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !lRet
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Deleta registro da acb de lixo
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	DelAcbAc9()
Else
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Inclusao ou exclusao de banco de conhecimento na guia
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If cAlias == 'BE2'
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Autaliza guia
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		B53 := PLSSTRUC():New( "B53",MODEL_OPERATION_UPDATE,,B53->( Recno() ) )
		B53:SetValue("B53_BANCON",'1' )
		B53:CRUD()
		B53:Destroy()
	EndIf
EndIf               
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Registro de log da rotina
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If lLog
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Grava registro de alteracao da aplicacao ou tabela
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oBX3 := PLSSTRUC():New("BX3")
	oBX3:SetlAltera(.T.)
	oBX3:SetValue("BX3_FILIAL", xFilial("BX3") )
	oBX3:SetValue("BX3_ALIAS", cAlias )
	oBX3:SetValue("BX3_DATA", Date() )
	oBX3:SetValue("BX3_HORA", Time() )
	oBX3:SetValue("BX3_ESTTRB", GetComputerName() )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Se incluiu alguma coisa no banco de conhecimento
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If lRet
		oBX3:SetValue("BX3_OPERAD", cCodUsuDef )
		oBX3:SetValue("BX3_TIPO", '1' )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Grava dados na base de dados
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If !oBX3:CRUD()
			oBX3:ExbMHelp( oBX3:GetErrorMessage(.T.) )
		EndIf
	EndIf	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Atualiza registro de acesso do usuario corrente
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oBX3:SetValue("BX3_OPERAD", ::cOperad )
	oBX3:SetValue("BX3_TIPO", '0' )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Grava dados na base de dados
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If !oBX3:CRUD()
		oBX3:ExbMHelp( oBX3:GetErrorMessage(.T.) )
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Destroy o modelo
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oBX3:Destroy()
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Rest nas linhas do browse e na area
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
RestArea( aArea )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё DuraГЦo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
_Super:SetLog(nHoraBase)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(lRet)
/*/{Protheus.doc} GetRotiAtu
Retorna se uma rotina foi ou nao atualizada

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
METHOD GetRotiAtu(aDad,cPerfil) Class PLSA790C
LOCAL aRet		 := {}
LOCAL nI		 := 1
LOCAL oGEN		 := NIL
LOCAL cTipoRe	 := '1'
LOCAL cTipoAc	 := '0'
LOCAL cCodUsuDef := "XXXXXX"
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Dados do Operador
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
For nI:=1 To Len(aDad)
	If nI > Len(aDad)
		Exit
	EndIf	           
	
	If ("XXX" == aDad[nI,1] .And. !::lMonFax) .Or. ("B69" == aDad[nI,1] .And. !::lIncAno) .Or.;
	   ("B68" == aDad[nI,1] .And. !::lIncDem) .Or. ("B72" == aDad[nI,1] .And. !::lIntSau) .Or.;
	   ("B70" == aDad[nI,1] .And. !::lIncPar) .Or. ("B71" == aDad[nI,1] .And. !::lIncEnc)
		aDel(aDad,nI)
		aSize(aDad,Len(aDad)-1) 
		nI--
	EndIf
Next	           
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Selecion todos os acesso deste usuario 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oGEN := PLSREGIC():New()
oGEN:GetDadBx3(aDad,::cOperad,cTipoAc,cCodUsuDef,cTipoRe)
oGEN:Destroy()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Retorna Matriz Ajustada
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
aRet := _Super:GetVal(aDad,,.T.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da funcao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(aRet)
//-------------------------------------------------------------------
/*/ { Protheus.doc } VldFLD
Validacao ao entrar no folder

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD VldFLD(nFolder,oTFolder,cAlias) Class PLSA790C   
LOCAL lRet := .T.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Instancia o modelo de dados												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oBX3 := PLSSTRUC():New("BX3")       
oBX3:SetValue("BX3_FILIAL", xFilial("BX3") )
oBX3:SetValue("BX3_OPERAD", ::cOperad )
oBX3:SetValue("BX3_ALIAS", cAlias )
oBX3:SetValue("BX3_DATA", Date() ) 
oBX3:SetValue("BX3_HORA", Time() )
oBX3:SetValue("BX3_TIPO", '0' )
oBX3:SetValue("BX3_ESTTRB", GetComputerName() )
oBX3:SetlAltera(.T.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava dados na base de dados											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !oBX3:CRUD() 
	oBX3:ExbMHelp( oBX3:GetErrorMessage(.T.) )
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Destroy o modelo														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oBX3:Destroy() 
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza a descricao do folder
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oTFolder:ADIALOGS[nFolder]:cTitle := AllTrim(StrTran(oTFolder:ADIALOGS[nFolder]:cTitle,'*',''))  
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da rotina
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(lRet)
//-------------------------------------------------------------------
/*/ { Protheus.doc } MarkAll
Marca e desmarca linhas do browse

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MarkAll(oMark,lMarcar) Class PLSA790C
LOCAL aArea   := GetArea()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Restaura area
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
RestArea( aArea )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da rotina
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return NIL
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetPerfil
Seta o perfil desejado

@author Alexander Santos
@since 09/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetPerfil(cPerfil) Class PLSA790C
::cPerfil := cPerfil
Return
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetPrioridade
Seta prioridade da guia

@author Alexander Santos
@since 09/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetPrioridade(cPrio) Class PLSA790C
LOCAL B53 := NIL
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Seta nova prioridade
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !Empty(X3COMBO("B53_PRIORI",cPrio))
	B53 := PLSSTRUC():New( "B53",MODEL_OPERATION_UPDATE,,B53->( Recno() ) )
	B53:SetValue("B53_PRIORI", cPrio)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Grava dados na base de dados											 
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If !B53:CRUD() 
		B53:ExbMHelp( B53:GetErrorMessage(.T.) )
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Destroy
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	B53:Destroy()
Else
	MSGALERT(STR0005) //"OpГЦo BOX do campo invalida"
EndIf	
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim do Metodo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return 
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetNegPar
Seta a opcao negar participacao

@author Alexander Santos
@since 09/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetNegPar(lNegPar) Class PLSA790C
::lNegPar := lNegPar
Return 
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetSituac
Seta situac da guia

@author Alexander Santos
@since 09/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetSituac(cSituac) Class PLSA790C
LOCAL oB53   := NIL         
LOCAL oGEN   := NIL
LOCAL aChave := {}
LOCAL aChaveB4A	:= {}
LOCAL aChaveBE2	:= {}
LOCAL aChaveBEJ	:= {}
LOCAL aChaveBQV 	:= {}
LOCAL aChaveB45 	:= {}
LOCAL nPosit := 0
LOCAL nNegat := 0
LOCAL oBEL   := NIL
LOCAL cOperad := If (GetNewPar("MV_PLFLUIG", .F.) == .T.,GetNewPar("MV_OPERFLG","0000"),::cOperad)
LOCAL cTipo
LOCAL aDadUsr := PLSDADUSR(B53->B53_MATUSU,'1',.F.,dDatabase,,,"NAO_VALIDAR_CARTAO")
Local lForLib := .F.   
LOCAL lFamYes	:= 	.F.
 
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza informacoes da classe
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

::SetAtuPClass()

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se tem guia selecionada
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !::lHaveGuia

	MSGALERT(STR0006) //"NЦo existe guia para analise"
	Return
EndIf	       
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se a guia tem o mesmo perfil do auditor
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If ::cPerfil <> PLS_ADMINITRADOR .And. !(::cPerfil $ ::cAllPerfil)
	MSGALERT(STR0007) //"O seu perfil nЦo esta autorizado a analisar esta guia!"
	Return
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se a guia estiver cancelada nЦo podera auditar.
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If B53->B53_STATUS = "6" 
	MSGALERT(STR0042)//"Esta guia foi cancelada."
	Return
EndIf

If AllTrim(B53->B53_TIPO) = "2"
	BEA->(dbSetOrder(1))
	
	If BEA->(dbSeek(xFilial("BEA")+B53->B53_NUMGUI))
		If BEA->BEA_CANCEL == "1"
			MSGALERT(STR0042)//"Esta guia foi cancelada."
			Return
		EndIf
	EndIf
EndIf	

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se o beneficiАrio foi desligado ou familia bloqueada
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
BA3->(dbSetOrder(1))
IF (Len(aDadUsr) > 5)  //Se vier da rotina genИrica e nЦo possuir matrМcula, pula essa parte da verificaГЦo
If BA3->(dbSeek(xFilial("BA3") + SUBSTR(B53->B53_MATUSU,1,14)+aDadUsr[9]+aDadUsr[12]+aDadUsr[41]+aDadUsr[42])) .And. B53->B53_PROINT <> '1' 
	
	If !EMPTY(BA3->BA3_DATBLO) .AND. BA3->BA3_DATBLO <= dDataBase
		BDS->(dbSetOrder(1))
		If BDS->(dbSeek(xFilial("BDS") + B53->B53_NUMGUI)) .And. B53->B53_SITUAC == '0' .And. Empty(BDS->(BDS_CODPAD+BDS_SEQUEN+BDS_CODPRO))
			nOk:= 	Aviso(STR0041 ,;//"UsuАrio Bloqueado" 
					STR0036 + STR0037 + CRLF + ;//"Problemas com o contrato do beneficiАrio no perМodo do atendimento, porИm a crМtica de bloqueio foi forГada com a seguinte justificativa:"
					STR0038 + AllTrim(BDS->BDS_OBSMOT) + CRLF +;//"ObservaГЦo: "
					STR0039 + AllTrim(BDS->BDS_OPESIS) + " - " + AllTrim(BDS->BDS_NOMOPE) + CRLF + "Deseja Prosseguir?",;//"Operador: " ## "Deseja Prosseguir?"
					{STR0049,STR0050},3) //"Sim" "NЦo"
			If nOk == 2
		Return
			Else
				lFamYes := .T.
			EndIf
		ElseIf B53->B53_SITUAC == '0'
			If !MsgYesNo("FamМlia bloqueada, deseja continuar?")
				MSGALERT(STR0043)//"FamМlia bloqueada, nЦo serА possМvel auditar a guia."
				Return
			EndIf
		EndIf
	ElseIf !EMPTY(BA3->BA3_DESLIG).AND. !EMPTY(BA3->BA3_LIMITE) .AND. BA3->BA3_LIMITE < dDataBase
			
		MSGALERT(STR0044)//"BeneficiАrio desligado, nЦo serА possМvel auditar a guia."
		Return
	EndIf
EndIf
ENDIF
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se o beneficiАrio esta bloqueado
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
BA1->(dbSetOrder(2))
If BA1->(dbSeek(xFilial("BA1") + B53->B53_MATUSU)) .And. B53->B53_PROINT <> '1'
	
	If !EMPTY(BA1->BA1_DATBLO) .AND. BA1->BA1_DATBLO <= dDataBase .And. !lFamYes
		
		BDS->(dbSetOrder(1))
		If BDS->(dbSeek(xFilial("BDS") + B53->B53_NUMGUI)) .And. B53->B53_SITUAC == '0' .And. Empty(BDS->(BDS_CODPAD+BDS_SEQUEN+BDS_CODPRO))
			nOk:= 	Aviso(STR0041 ,;//"UsuАrio Bloqueado"
			STR0036 + STR0037 + CRLF + ;//"Problemas com o contrato do beneficiАrio no perМodo do atendimento, porИm a crМtica de bloqueio foi forГada com a seguinte justificativa:"
			STR0038 + AllTrim(BDS->BDS_OBSMOT) + CRLF +;//"ObservaГЦo: "
			STR0039 + AllTrim(BDS->BDS_OPESIS) + " - " + AllTrim(BDS->BDS_NOMOPE) + CRLF + "Deseja Prosseguir?",;//"Operador: " ## "Deseja Prosseguir?"
			{STR0049,STR0050},3)//"Sim" "NЦo"
			If nOk == 2
				Return
			EndIf
		ElseIf B53->B53_SITUAC == '0' .and. !( PLSUSRINTE(B53->B53_MATUSU,B53->B53_DATMOV)[1] )
			If !MsgYesNo("UsuАrio bloqueado, deseja continuar?")	
				MSGALERT(STR0045)//"UsuАrio bloqueado, nЦo serА possМvel auditar a guia."
				Return
			EndIf
		EndIf
		
	EndIf
EndIf


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se a RDA esta bloqueada
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
BAU->(dbSetOrder(1))
If BAU->(dbSeek(xFilial("BAU") + B53->B53_CODRDA))
	
	//se a data do bloqueio for menor que a data atual, exibe a mensagem.
	If !EMPTY(BAU->BAU_CODBLO) .AND. BAU->BAU_DATBLO < dDataBase
			
		MSGALERT(STR0046)//"RDA bloqueada, nЦo serА possМvel auditar a guia."
		Return
	
	//Se a data do bloqueio for igual a data atual, verifica ba BC4 se a RDA esta bloqueada de acordo com a hora incluida.
	ElseIf BAU->BAU_DATBLO == dDataBase
		
		BC4->(dbSetOrder(1))
		
		If BC4->(dbSeek(xFilial("BC4") + B53->B53_CODRDA + DTOS(dDataBase)))
			
			//verifica os registros de bloqueio e desbloqueio.
			While !BC4->(EOF()) .AND. BC4->(BC4_FILIAL + BC4_CODCRE + DTOS(BC4_DATA)) == xFilial("BC4") + B53->B53_CODRDA + DTOS(dDataBase)
				
				//verificar se o ultimo registro И de bloqueio e se o horАrio do bloqueio ja foi ultrapassado.
				If BC4->BC4_TIPO == "0" .AND. BC4->BC4_HORA <= SUBSTR(STRTRAN(TIME(), ":", ""),1,4)
					cTipo := BC4->BC4_TIPO
				Else
					cTipo := "1"
				EndIf
				
				BC4->(dbSkip())
			EndDo
			
			// exibe a mensagem de bloquieo da RDA.
			If cTipo == "0"
				MSGALERT(STR0046)//"RDA bloqueada, nЦo serА possМvel auditar a guia."
				Return
			EndIf
		EndIf
	EndIf
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Tratamento do Situac
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Do Case
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё A guia vai ficar em espera
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Case cSituac == "3"
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verifica se tem acesso a guia
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If !::VldAcessoGui()
		Return
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Retira guia do monitor
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Case cSituac == "1"
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verifica se tem acesso a guia
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If !::VldAcessoGui()
		Return
	EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Guia autorizada e procedimento da auditoria participativa
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If !::lParticipativa .And. ::lAutorizada
		MSGALERT(STR0008) //"Somente guia Autorizada e Participativa"
		Return
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Liberar ou Pegar guia
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Case cSituac == "2"
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Ja foi analisada e tem inconsistencia
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If ::lInconsistente
		MSGALERT(STR0009 ) //"Esta guia jА foi analisada, utilize a opГЦo InconsistЙncia"
		Return
	EndIf
	If ::lAnalisada 
		MsgAlert(STR0026)//"Esta guia jА foi analisada."
		Return
	EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Se esta reservada para outro operador
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If ::lHaveOwner .And. !::lOwner
		IF (::lLibGuia ) //Verifica se o usuАrio tem autorizaГЦo para liberar guias bloqueadas por outros usuАrios (08/07/16 - retirado obrigatoriedade de ser do mesmo setor)
			lForLib := MsgNoYes(STR0028 + UPPER(USRRETNAME(B53->B53_OPERAD)) + STR0029, STR0030) //A guia esta bloqueada para:/Deseja mesmo liberar esta Guia?
		Endif
		IF (!lForLib)
			MSGALERT(STR0010 ) //"Guia reservada para outro Operador"
			Return
		EndIf
	EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Se e do mesmo departamento
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If !::lHaveOwner .And. !::lThisDep
		MSGALERT(STR0015 ) //"Somente o operador deste departamento tem acesso"
		Return
	EndIf
	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verifica status atual da guia
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

	If ::cACri == "BEG"
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Se a guia foi analisada por completo, nЦo serА possМvel reservar a guia
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

		If B53->b53_SITUAC == "1"

			Return
		EndIf
	
		If B53->B53_ALIMOV == "B4A"
		
			B4A->(dbSetOrder(1))
			If B4A->(dbSeek(xFilial("BA4")+B53->B53_NUMGUI))
	
				While !B4A->(EOF()) .AND. xFilial("B4A")+B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) ==;
						xFilial("B4A")+B53->B53_NUMGUI
	
					If B4A->B4A_STATUS == '1'
						nPosit++
					Else
						nNegat++
					EndIf
					B4A->(dbSkip())
				EndDo
			EndIf
		Else
	
			BE2->(dbSetOrder(1))
			If BE2->(dbSeek(xFilial("BE2")+B53->B53_NUMGUI))
	
				While !BE2->(EOF()) .AND. xFilial("BE2")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) ==;
						xFilial("BE2")+B53->B53_NUMGUI
	
					If BE2->BE2_STATUS == '1'
						nPosit++
					Else
						nNegat++
					EndIf
					BE2->(dbSkip())
				EndDo
			EndIf
		EndIf
	
		oB53 := PLSSTRUC():New( "B53",MODEL_OPERATION_UPDATE,,B53->( Recno() ) )

		if nPosit == 0 .AND. nNegat > 0
			oB53:SetValue("B53_STATUS", "3")
		ElseIf nPosit > 0 .AND. nNegat > 0
			oB53:SetValue("B53_STATUS", "2")
		ElseIf nPosit > 0 .AND. nNegat == 0
			oB53:SetValue("B53_STATUS", "1")
		EndIf

		If !oB53:CRUD()
			oB53:ExbMHelp( oB53:GetErrorMessage(.T.) )
		EndIf
	Else

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Se a guia foi analisada por completo, nЦo serА possМvel reservar a guia
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

		If B53->b53_SITUAC == "1"
			MSGALERT(STR0026) //"Esta guia jА foi analisada."
			Return
		EndIf
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё se aguia nao foi analisada por completo a guia podera ser reservada
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		BEJ->(dbSetOrder(1))
		If BEJ->(dbSeek(xFilial("BEJ")+B53->B53_NUMGUI))

			While !BEJ->(EOF()) .AND. xFilial("BEJ")+BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT) ==;
					xFilial("BEJ")+B53->B53_NUMGUI

				If BEJ->BEJ_STATUS == '1'
					nPosit++
				Else
					nNegat++
				EndIf
				BEJ->(dbSkip())
			EndDo

			BQV->(dbSetOrder(1))
			If BQV->(dbSeek(xFilial("BQV")+B53->B53_NUMGUI))

				While !BQV->(EOF()) .AND. xFilial("BQV")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) ==;
						xFilial("BQV")+B53->B53_NUMGUI

					If BQV->BQV_STATUS == '1'
						nPosit++
					Else
						nNegat++
					EndIf
					BQV->(dbSkip())
				EndDo
			EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Cria o objeto para a atualizacao
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			oB53 := PLSSTRUC():New( "B53",MODEL_OPERATION_UPDATE,,B53->( Recno() ) )

			if nPosit == 0 .AND. nNegat > 0
				oB53:SetValue("B53_STATUS", "3")
			ElseIf nPosit > 0 .AND. nNegat > 0
				oB53:SetValue("B53_STATUS", "2")
			ElseIf nPosit > 0 .AND. nNegat == 0
				oB53:SetValue("B53_STATUS", "1")
			EndIf

			If !oB53:CRUD()
				oB53:ExbMHelp( oB53:GetErrorMessage(.T.) )
			EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Destroy
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			oB53:Destroy()
		EndIf

	EndIf
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Chave
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	IF (B53->B53_ROTGEN <> "1")
		aChave := {}
		AaDd(aChave, { ::SetFieldGui(::cACri+"_OPEMOV"), '=', Left(B53->B53_NUMGUI,4) } )
		AaDd(aChave, { ::SetFieldGui(::cACri+"_ANOAUT"), '=', SubStr(B53->B53_NUMGUI,5,4) } )
		AaDd(aChave, { ::SetFieldGui(::cACri+"_MESAUT"), '=', SubStr(B53->B53_NUMGUI,9,2)} )
		AaDd(aChave, { ::SetFieldGui(::cACri+"_NUMAUT"), '=', Right(B53->B53_NUMGUI,8)} )
		If (::cACri)->( FieldPos(::cACri+"_PENDEN") ) > 0
			AaDd(aChave, { ::cACri+"_PENDEN", '<>', '0'} )
		Endif
		If (::cACri)->( FieldPos(::cACri+"_CODGLO") ) > 0
			AaDd(aChave, { ::cACri+"_CODGLO", '<>', ''} )
		Endif
	ENDIF
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё verifica se a guia foi totalmente analisada 
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		
	IF (B53->B53_ROTGEN <> "1")  //Se for diferente de rotina genИrica
		If B53->b53_SITUAC == "2"
				
			If ::cACri == "BEG"
				
				If B53->B53_ALIMOV == "B4A"
					B4A->(dbSetOrder(1))
					B4A->(dbGoTop())
			
					IF B4A->(dbSeek( xFilial("B4A")+B53->B53_NUMGUI))
					
						aChaveB4A := {}
						AaDd(aChaveB4A, { "B4A_OPEMOV", '=', Left(B53->B53_NUMGUI,4) 		} )
						AaDd(aChaveB4A, { "B4A_ANOAUT", '=', SubStr(B53->B53_NUMGUI,5,4) 	} )
						AaDd(aChaveB4A, { "B4A_MESAUT", '=', SubStr(B53->B53_NUMGUI,9,2) 	} )
						AaDd(aChaveB4A, { "B4A_NUMAUT", '=', Right(B53->B53_NUMGUI,8) 		} )
												
						oGEN := PLSREGIC():New()
						
						If oGEN:GetCountReg("B4A",aChaveB4A ) == 0
							cSituac := "1"
						Else
							cSituac := "0"
						EndIf
						
						oGEN:Destroy()
					EndIf
				Else
				
					BE2->(dbSetOrder(1))
					BE2->(dbGoTop())
			
					IF BE2->(dbSeek( xFilial("BE2")+B53->B53_NUMGUI))
					
						aChaveBE2 := {}
						AaDd(aChaveBE2, { "BE2_OPEMOV", '=', Left(B53->B53_NUMGUI,4) 		} )
						AaDd(aChaveBE2, { "BE2_ANOAUT", '=', SubStr(B53->B53_NUMGUI,5,4) 	} )
						AaDd(aChaveBE2, { "BE2_MESAUT", '=', SubStr(B53->B53_NUMGUI,9,2) 	} )
						AaDd(aChaveBE2, { "BE2_NUMAUT", '=', Right(B53->B53_NUMGUI,8) 		} )
												
						oGEN := PLSREGIC():New()
						
						If oGEN:GetCountReg("BE2",aChaveBE2 ) == 0
							cSituac := "1"
						Else
							cSituac := "0"
						EndIf
						
						oGEN:Destroy()
					EndIf
				EndIf
			Else
				BEJ->(dbSetOrder(1))
				BEJ->(dbGoTop())
		
				IF BEJ->(dbSeek( xFilial("BEJ")+B53->B53_NUMGUI))
				
					aChaveBEJ := {}
					AaDd(aChaveBEJ, { "BEJ_CODOPE", '=', Left(B53->B53_NUMGUI,4) 		} )
					AaDd(aChaveBEJ, { "BEJ_ANOINT", '=', SubStr(B53->B53_NUMGUI,5,4) 	} )
					AaDd(aChaveBEJ, { "BEJ_MESINT", '=', SubStr(B53->B53_NUMGUI,9,2) 	} )
					AaDd(aChaveBEJ, { "BEJ_NUMINT", '=', Right(B53->B53_NUMGUI,8) 		} )
											
					oGEN := PLSREGIC():New()
					
					If oGEN:GetCountReg("BEJ",aChaveBEJ ) == 0
						cSituac := "1"
					Else
						cSituac := "0"
					EndIf
					
					oGEN:Destroy()
						
				EndIf
							
				IF BQV->(dbSeek( xFilial("BQV")+B53->B53_NUMGUI))
					
					aChaveBQV := {}
					AaDd(aChaveBQV, { "BQV_CODOPE", '=', Left(B53->B53_NUMGUI,4) 		} )
					AaDd(aChaveBQV, { "BQV_ANOINT", '=', SubStr(B53->B53_NUMGUI,5,4) 	} )
					AaDd(aChaveBQV, { "BQV_MESINT", '=', SubStr(B53->B53_NUMGUI,9,2) 	} )
					AaDd(aChaveBQV, { "BQV_NUMINT", '=', Right(B53->B53_NUMGUI,8) 		} )
					AaDd(aChaveBQV, { "BQV_AUDITO", '=', "1" 		} )
						
					oGEN := PLSREGIC():New()
					
					If oGEN:GetCountReg("BQV",aChaveBQV ) == 0
						cSituac := "1"
					Else
						cSituac := "0"
					EndIf
					
					oGEN:Destroy()
				
				EndIf
				 
				IF B45->(dbSeek( xFilial("B45")+B53->B53_NUMGUI))
					
					aChaveB45 := {}
					AaDd(aChaveB45, { "B45_OPEMOV", '=', Left(B53->B53_NUMGUI,4) 		} )
					AaDd(aChaveB45, { "B45_ANOAUT", '=', SubStr(B53->B53_NUMGUI,5,4) 	} )
					AaDd(aChaveB45, { "B45_MESAUT", '=', SubStr(B53->B53_NUMGUI,9,2) 	} )
					AaDd(aChaveB45, { "B45_NUMAUT", '=', Right(B53->B53_NUMGUI,8) 		} )
											
					oGEN := PLSREGIC():New()
					
					If oGEN:GetCountReg("B45",aChaveB45 ) == 0
						cSituac := "1"
					Else
						cSituac := "0"
					EndIf
					
					oGEN:Destroy()
					
						
				EndIf
			EndIf
		EndIf	
	ELSE // Se for rotina GenИrica
		IF ( B53->B53_SITUAC <> "1" )	//Verifico se a guia jА estА analisada
			IF ( B53->B53_SITUAC == "2" )
				cSituac := "0"
			ELSEIF ( B53->B53_SITUAC == "0")
				cSituac := "2"
			ENDIF
		ENDIF
	ENDIF
OtherWise
EndCase
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se e situac valido
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !Empty(X3COMBO("B53_SITUAC",cSituac)) //0=NЦo;1=Sim;2=Em Analise;3=Em Espera;4=InconsistЙncia
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Seta nova prioridade
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oB53 := PLSSTRUC():New( "B53",MODEL_OPERATION_UPDATE,,B53->( Recno() ) )
	oB53:SetValue("B53_SITUAC", cSituac)  
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Atualiza informacoes da guia data e hora
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	Do Case 
		Case cSituac == '1'
			oB53:SetValue("B53_DATFIM", dDataBase )
			oB53:SetValue("B53_HORFIM", Left(Time(),5) )
			
		Case cSituac == '2' .AND. EMPTY(B53->B53_DATINI)
			oB53:SetValue("B53_DATINI", dDataBase )
			oB53:SetValue("B53_HORINI", Left(Time(),5) )
	EndCase
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Atribui operador da guia
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	 If !::lHaveOwner .OR. cSituac == '3' .OR. cSituac == '2'
	 	oB53:SetValue("B53_OPERAD",cOperad)
	 	IIF(Empty(B53->B53_CODDEP),oB53:SetValue("B53_CODDEP", ::cCodDepa),)  //-
	 Else
	 	oB53:SetValue("B53_OPERAD",'')
	 	//Aqui, verifico se existe encaminhamento na B71. Se nЦo houver, significa que MV_SETORAT
	 	//estА vazio e o auditor nЦo encaminhou para departamento algum, logo, deve ficar como default
	 	oB71 := PLSREGIC():New()
		oB71:GetDadReg("B71",1, xFilial("B71") + B53->B53_ALIMOV + B53->B53_RECMOV,,,.F. )
	   		If !oB71:lFound
			  oB53:SetValue("B53_CODDEP", '')
   			ENDIF 
   		oB71:Destroy()
	 EndIf
	 
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Grava dados na base de dados
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If !oB53:CRUD()
		oB53:ExbMHelp( oB53:GetErrorMessage(.T.) )
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Destroy
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oB53:Destroy()
Else
	MSGALERT(STR0005) //"OpГЦo BOX do campo invalida"
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim do Metodo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return 
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetFiles
Retorna todos os arquivo de uma pasta e subpastas

@author Alexander Santos
@since 09/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetFiles(cDirPerf,aFiles) Class PLSA790C
LOCAL nI		:= 1
LOCAL aFilDir	:= {}
DEFAULT aFiles 	:= {}  
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Retira espacos desnecessario
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cDirPerf := PLSMUDSIS( MsDocRmvBar(AllTrim(cDirPerf)) )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Arquivos e diretorio da pasta informada
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
aFilDir := Directory( cDirPerf + PLSMUDSIS("\*.*"), "D")
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se tem somente arquivo ou subpastas
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
For nI:=1 To Len(aFilDir)
	
	If Left(aFilDir[nI,1],1) <> '.'
		If aFilDir[nI,5] == 'D'
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Processando a subpasta
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			::GetFiles(cDirPerf + "\" + aFilDir[nI,1] + "\",aFiles)
			
	    ElseIf At('excluido_',Lower(aFilDir[nI,1])) == 0
	    
	    	AaDd(aFiles, { aFilDir[nI,1] , PLSMUDSIS( cDirPerf + "\" ) } )
	    	
	    EndIf
	EndIf    
	
Next   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Para ter um linha 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If Len(aFiles)==0
	aFiles := { { "" , "" } } 
EndIf  
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim do Metodo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(aFiles)
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetDocBC
Alimenta e mostra registro selecionado no banco de conhecimento

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetDocBC(nAt,aFiles,cAlias,cUnico) Class PLSA790C
LOCAL aArea 	:= GetArea() 
LOCAL lRet		:= .T.
LOCAL nH		:= 0
LOCAL cDescri	:= ""
LOCAL cChvUni	:= ""
LOCAL cCodUsuDef:= "XXXXXX"                   
LOCAL cFile		:= SubStr(aFiles[nAt,1],1,At('.',aFiles[nAt,1])-1 )
LOCAL cDirFile 	:= aFiles[nAt,2]+aFiles[nAt,1]
PRIVATE aRotina := {}

If EMPTY(cFile)
	MSGALERT(STR0047)//"NЦo existe arquivos no monitor de documentos."
	Return	
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Abre controle de semafoto
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If ( nH := PLSAbreSem("GetDocBC" + cFile + ".SMF",.F.) ) > 0
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁColoca banco de conhecimento na memoria 
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	RegToMemory("ACB",.T.)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁRetorna o nome do arquivo
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	SplitPath( cDirFile,,,@cDescri)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁPreenchimento do wizard
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	lRet := MsDocWzGrv( cDirFile, cDescri, {}, {} )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁMonta Chave Unica
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If lRet
		If !Empty(cUnico)
			cChvUni := (cAlias)->&(cUnico)
			If Empty(cChvUni)                                  
				MSGALERT(STR0011 ) //"Chave informada para registro do banco de conhecimento invalida"
				lRet := .F.	
			EndIf
		Else
			MSGALERT(STR0012 ) //"Informe chave unica para registro do banco de conhecimento"
			lRet := .F.	
		EndIf
	EndIf	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁSe tudo ok monta registro do banco de conhecimento
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

	If lRet  
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Grava registro de alteracao da aplicacao ou tabela
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		oBX3 := PLSSTRUC():New("BX3")
		oBX3:SetlAltera(.T.)
		oBX3:SetValue("BX3_FILIAL", xFilial("BX3") )
		oBX3:SetValue("BX3_OPERAD", cCodUsuDef )
		oBX3:SetValue("BX3_ALIAS", cAlias )
		oBX3:SetValue("BX3_DATA", Date() )
		oBX3:SetValue("BX3_HORA", Time() )
		oBX3:SetValue("BX3_TIPO", '1' )
		oBX3:SetValue("BX3_ESTTRB", GetComputerName() )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Grava dados na base de dados
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If !oBX3:CRUD()
			oBX3:ExbMHelp( oBX3:GetErrorMessage(.T.) )
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Atualiza registro de acesso do usuario corrente
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		oBX3:SetValue("BX3_OPERAD", ::cOperad )
		oBX3:SetValue("BX3_TIPO", '0' )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Grava dados na base de dados
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If !oBX3:CRUD()
			oBX3:ExbMHelp( oBX3:GetErrorMessage(.T.) )
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Destroy o modelo
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		oBX3:Destroy()
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Gravacao do registro caso nao existe
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		oAC9 := PLSSTRUC():New("AC9",MODEL_OPERATION_INSERT,1)
		oAC9:SetValue("AC9_FILIAL", xFilial( "AC9") )
		oAC9:SetValue("AC9_FILENT", xFilial( cAlias ) )
		oAC9:SetValue("AC9_ENTIDA", cAlias )
		oAC9:SetValue("AC9_CODENT", cChvUni )
		oAC9:SetValue("AC9_CODOBJ", M->ACB_CODOBJ )
		oAC9:CRUD() 
		oAC9:Destroy()
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Se o acesso foi permitido exibi banco de conhecimento
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		Aadd(aRotina,{STR0003,"MsDocument", 0 , 4}) //"Conhecimento"
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁBanco de conhecimento
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		lRet := MsDocument( cAlias, (cAlias)->( Recno() ),1)
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁExclui documento da lista
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If lRet
		    ::DelDocBC(nAt,aFiles)	
		Else
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Deleta registro da acb de lixo
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			DelAcbAc9(.T.)
		EndIf    
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Fecha Semaforo
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	PLSFechaSem(nH,"GetDocBC" + cFile + ".SMF")
Else
	MSGALERT(STR0048)//"Arquivo sendo usado por outro Monitor"
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁRestaura area
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

RestArea( aArea )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return NIL                   
//-------------------------------------------------------------------
/*/ { Protheus.doc } DelDocBC
Deleta arquivo da pasta de monitor de fax

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD DelDocBC(nAt,aFiles) Class PLSA790C
LOCAL nRenOk  := -1
LOCAL cRename := aFiles[nAt,2] + 'excluido_' + aFiles[nAt,1]
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Retomeia pois a GetFiles nao pega arquivos com excluido_
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
nRenOk := FRename(aFiles[nAt,2]+aFiles[nAt,1] , cRename )
If nRenOk == -1   
	MSGALERT(STR0013 ) //"NЦo foi possivel excluir arquivo da lista"
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return NIL                        
//-------------------------------------------------------------------
/*/ { Protheus.doc } VldAplication
Retorna dados da guia posicionada

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD VldAplication() Class PLSA790C
LOCAL lRet := .T.
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se o operador tem acesso a rotina
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !::lMonFax .And. !::lIncAno .And. !::lIncDem .And. !::lIntSau .And. !::lIncPar .And. !::lIncEnc
	MSGALERT(STR0014) //"Rotina disponМvel apenas para operador autorizado"
	lRet:= .F.     
EndIf
If !::lOpAudi		// Verifica se operador estА autorizado - campo (BX4_AUDITO)
	MSGALERT(STR0014) //"Rotina disponМvel apenas para operador autorizado"
	lRet:= .F.     
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(lRet)
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetOnlyVisible
Set se a rotina serА somente em modo visual

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetOnlyVisible(lVisible) Class PLSA790C
::lVisible := lVisible
Return 
//-------------------------------------------------------------------
/*/ { Protheus.doc } VldAcessoGui
Valida acesso a guia se o operador tem direito

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD VldAcessoGui(lEmAnlise,lIncons,lAutori, lAudit, cAlias, lEvol) Class PLSA790C
LOCAL lRet			:= .T.                                     
DEFAULT lEmAnlise	:= .T.     
DEFAULT lIncons	:= .F.             
DEFAULT lAutori	:= .F.
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza informacoes da classe
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
::SetAtuPClass(lEvol)


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se tem guia para ser analisada
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !::lHaveGuia  
	Help( ,, 'PLSA790C',, STR0015, 1, 0) //"NЦo existe guia para analise" 
	lRet := .F.
	
EndIf 

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se nao for da interna-saude
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !::lIntSau .And. !::lInconsistente
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Verifica se foi encaminhada e se o operador e do mesmo departamento
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If lRet .And. !::lHaveOwner .And. !::lThisDep
	
		Help( ,, 'PLSA790C',, STR0015, 1, 0)//"Somente o operador deste departamento tem acesso" 
		lRet := .F.
		
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Verifica se a guia tem dono 
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If lRet .And. ::lHaveOwner .And. !::lOwner
	
		Help( ,, 'PLSA790C',, STR0016, 1, 0) //"Somente o operador desta guia tem acesso" 
		lRet := .F.
		
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Se esta ok 
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If lRet .And. lEmAnlise
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verfica se a guia esta em analise
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If !::lEmAnalise
		
			Help( ,, 'PLSA790C',, STR0017, 1, 0) //"A guia deve estar em analise" 
			lRet := .F.
			
		EndIf
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Verifica se a guia esta autorizada
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If lRet .And. lAutori .And. ::lAutorizada .And. !::lEvolucao
		Help( ,, 'PLSA790C',, STR0019, 1, 0) //"Esta guia jА esta autorizada!" 
		lRet := .F.
    EndIf                
EndIf	

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se o procedimento selecionado И de auditoria
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !EMPTY(lAudit) .AND. lAudit
	If !::lRotinaGen .AND. TYPE("cAudito")<>"U" .AND. cAudito == "0"
		Help( ,, 'PLSA790C',, STR0025, 1, 0) //Este procedimento nЦo possui critica para auditoria
		lRet := .F.
	EndIf
EndIf

//дддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim do Metodo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(lRet)
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetAtuPClass
Seta valor nas proprioedades da classe

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetAtuPClass(lEvol) CLASS PLSA790C

DEFAULT lEvol := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza propriedades
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

AtuPClass(Self, lEvol)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetFieldGui
Ajusta campos conforme a guia

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetFieldGui(cCampo) Class PLSA790C
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁSe for internacao ajusta campos
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Do Case
	Case ::lInternacao .Or. ::lEvolucao .OR. ::lProrrog
		cCampo := StrTran(cCampo,'AUT','INT')
		cCampo := StrTran(cCampo,'OPEMOV','CODOPE')
	Case ::lOdonto
	Case ::lReembolso
EndCase
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim do Metodo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(cCampo)
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetAuditoria
Cria o registro para auditoria por guia

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetAuditoria(lAuditoria,lIntern,lEvolu,lReembolso,lPartic,aDadCri,aCabCri,cCodCri,cRegInt,cAliasCri,;
					aColsITE,aHeaderITE,cAliasIte,lOPME, lProrrog, cOriMovHAT) Class PLSA790C
					
LOCAL nI			:= 1
LOCAL cAlias 	 	:= "BEA"
LOCAL cOpeMov   	:= ""
LOCAL cCarInt   	:= ""
LOCAL cNumAut		:= ""
LOCAL cTipo		 	:= ""
LOCAL cTpGuia	 	:= ""
LOCAL cPerAud 		:= ""
LOCAL cTipAdm		:= ""
LOCAL cPriori		:= ""
LOCAL cOriMov		:= ""
LOCAL cCodDep		:= ""
LOCAL cCodMun 		:= ""
LOCAL cCRda         := ""
LOCAL lAutorizacao 	:= .F.
LOCAL lFutura		:= .F.
LOCAL lDemand		:= .F.
LOCAL aMat			:= {}
LOCAL oGEN			:= NIL
LOCAL oB53			:= NIL
LOCAL nPosit 		:= 0
LOCAL nNegat 		:= 0
LOCAL oBE4			:= NIL
LOCAL lGui			:= .F.
LOCAL cChave		:= ""
Local cEncGui		:= getNewPar("MV_SETORAT","")
Local aTabPes		:= {{"BEA",1}, {"BE4",2}, {"B44",1}}  //Tabelas de Pesquisa e Indice, para pegar RDA em caso de Anexo
local lExPLSDEPTO	:= Existblock("PLSDEPTO")
Local dDtPrazoAten 	:= CToD(" / / ")
Local oDadosPrazo := Nil

DEFAULT aColsITE	:= {}
DEFAULT aHeaderITE	:= {}
DEFAULT cAliasIte	:= {}
DEFAULT lOPME		:= .F.
DEFAULT lProrrog		:= .F.
DEFAULT cOriMovHAT  := ""

cPriori  :=&(GetSx3Cache("B53_PRIORI","X3_RELACAO"))

If  Valtype(cPriori) <> "U"  
	cPriori :=SubStr(cPriori,1,1)
Endif
	
cPriori := Iif(Empty(cPriori),"0",cPriori)

// Verifica se o inicializador do campo B53_PRIORI esta preenchido
cPriori := Iif(Empty(cPriori),"0",cPriori)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se esta habilitada a nova auditoria
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If GetNewPar("MV_PL790NE","0") == "0"
	Return
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Define Alias
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If lIntern .Or. lEvolu
	cAlias := "BE4"                       
ElseIf lReembolso
	cAlias := "B44"
ElseIf lOPME
	cAlias := "B4A"
ElseIf lProrrog
	cAlias := "B4Q"
EndIf	
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Variaveis
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cOpeMov := Iif( lIntern .Or. lEvolu,(cAlias)->&(cAlias+"_CODOPE"),(cAlias)->&(cAlias+"_OPEMOV") )
cNumAut := cOpeMov + Iif( !lIntern .And. !lEvolu,(cAlias)->( &(cAlias+"_ANOAUT")+&(cAlias+"_MESAUT")+&(cAlias+"_NUMAUT") ),(cAlias)->( &(cAlias+"_ANOINT")+&(cAlias+"_MESINT")+&(cAlias+"_NUMINT") ) )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Municipio do local de atendimento
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

If lOPME

	dbSelectArea("BID")
	BEA->(dbSetOrder(1) )
	BEA->( MsSeek( xFilial("BEA")+B4A->B4A_GUIREF))
	If BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == B4A->B4A_GUIREF
		If BB8->( MsSeek( xFilial("BB8")+ BEA->BEA_CODRDA+cOpeMov+ BEA->BEA_CODLOC+BEA->BEA_LOCAL) ) 
			cCodMun := BB8->BB8_CODMUN
		Else
			cCodMun := BID->BID_CODMUN   
		Endif	
	Else
		cCodMun := BID->BID_CODMUN	
	Endif

ElseIf lProrrog

	dbSelectArea("BID")
	BE4->(dbSetOrder(2) )
	BE4->( MsSeek( xFilial("BE4")+B4Q->B4Q_GUIREF))
	If BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) == B4Q->B4Q_GUIREF
		If BB8->( MsSeek( xFilial("BB8")+ BE4->BE4_CODRDA+cOpeMov+ BE4->BE4_CODLOC+BE4->BE4_LOCAL) ) 
			cCodMun := BB8->BB8_CODMUN
		Else
			cCodMun := BID->BID_CODMUN   
		Endif	
	Else
		cCodMun := BID->BID_CODMUN	
	Endif

Else

	If BB8->( MsSeek( xFilial("BB8") + (cAlias)->&(cAlias+"_CODRDA") + cOpeMov + (cAlias)->&(cAlias+"_CODLOC") + (cAlias)->&(cAlias+"_LOCAL") ) )
		cCodMun := BB8->BB8_CODMUN
	EndIf
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Quando nao e reembolso
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If lEvolu .Or. lIntern
	cOriMov := BE4->BE4_ORIMOV
	cTpGuia := '3'
ElseIf !lReembolso .And. !lOPME .AND. !lProrrog .And. (!lEvolu .Or. !lIntern)
	cOriMov := (cAlias)->&(cAlias+"_ORIMOV")
	cTpGuia := BEA->BEA_TIPO
ElseIf lOPME
	cOriMov := '3'
	cTpGuia	:= '6'
ElseIf lProrrog
	cOriMov := BE4->BE4_ORIMOV
	cTpGuia	:= '11'
Else
	cOriMov := '3'
	cTpGuia	:= '5'
EndIf
cOriMov := iif(!Empty(cOriMovHAT),cOriMovHAT,cOriMov)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Tipo de admissao
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If (cAlias)->( FieldPos(cAlias+"_TIPADM") ) > 0                                                                                       
	cTipAdm := (cAlias)->&(cAlias+"_TIPADM")
Else
	cTipAdm := GetNewPar("MV_PLSTPAD","1")
EndIf
cCarInt := Posicione("BDR",1,xFilial("BDR") + cOpeMov + cTipAdm,"BDR_CARINT")

lDemand := Ascan( aDadCri,{|x| x[ PLRETPOS( cAliasCri + "_CODGLO",aCabCri ) ] == cCodCri } ) > 0
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Alimenta o perfil de auditoria com base na critica						 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
For nI := 1 To Len(aDadCri) 
	If !Empty( aDadCri[ nI,PLRETPOS( cAliasCri+"_CODGLO",aCabCri ) ] ) 

		cTipo := Posicione("BCT",1,xFilial("BCT") + cOpeMov + aDadCri[ nI,PLRETPOS( cAliasCri+"_CODGLO",aCabCri ) ],"BCT_TIPO")

		If At(cTipo,cPerAud) == 0
			cPerAud += cTipo+";"
		EndIf
	EndIF
Next
cPerAud := Iif(Empty(cPerAud) .OR. ALLTRIM(cPerAud) == ";","0;1;2;",cPerAud) 
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Classificacao da prioridade
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

If ExistBlock("PLSAUDPR") .And. lAuditoria
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Dados enviado ao ponto de entrada 0=Baixa,1=Media,2=Alta
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд    
	lAutorizacao :=	Iif(BEA->BEA_ORIGEM == "1" .And. (!lEvolu .Or. !lIntern),.T.,.F. )

	If lIntern .Or. lEvolu
		lFutura := (cAlias)->&(cAlias+"_PRVINT") > (cAlias)->&(cAlias+"_DTDIGI")
	ElseIf 	lReembolso
		lFutura := (cAlias)->&(cAlias+"_DATPRO") > (cAlias)->&(cAlias+"_DTDIGI")
	ElseIf 	lOPME .or. lProrrog
		lFutura := (cAlias)->&(cAlias+"_DATPRO") > (cAlias)->&(cAlias+"_DATSOL")
	Else
		lFutura := (cAlias)->&(cAlias+"_DATSOL") > (cAlias)->&(cAlias+"_DTDIGI")
	EndIf	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Avaliacao do ponto de entrada
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	cPriori := ExecBlock("PLSAUDPR",.F.,.F.,{cOriMov,cTipo,lAutorizacao,cCarInt,lFutura,lReembolso,lEvolu,lIntern } )
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Instancia o modelo de dados		//r7										 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд 
oB53 := PLSSTRUC():New("B53")


If Existblock("PL790INIP")
	oB53 := ExecBlock("PL790INIP", .F., .F., {oB53} ) 
Endif

oB53:SetValue("B53_NUMGUI", cNumAut )             
oB53:SetValue("B53_ORIMOV", cOriMov )
oB53:SetValue("B53_CODMUN", cCodMun )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Tem que verificar se ja nao existe pois a evolucao vai inserir varios procedimento na mesma guia
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oGEN := PLSREGIC():New()
oGEN:GetDadReg("B53",1, xFilial("B53") + cNumAut + cOriMov )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se nao existir inseri
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !oGEN:lFound
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Chaves																	 
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oB53:SetValue("B53_FILIAL", xFilial(cAlias) )
	oB53:SetValue("B53_ALIMOV", cAlias )
	oB53:SetValue("B53_RECMOV", cValToChar( (cAlias)->( Recno() ) ) )
	oB53:SetValue("B53_CODOPE", cOpeMov )
	oB53:SetValue("B53_CODLDP", IIf(lOPME .or. lProrrog, "0000",(cAlias)->&(cAlias+"_CODLDP") ))
	oB53:SetValue("B53_CODPEG", IIf(lOPME .or. lProrrog,"00000000",(cAlias)->&(cAlias+"_CODPEG") ))
	oB53:SetValue("B53_NUMERO", Iif(lIntern .Or. lEvolu,(cAlias)->&(cAlias+"_NUMERO"), Iif(lOPME .or. lProrrog, (cAlias)->&(cAlias+"_NUMAUT"),(cAlias)->&(cAlias+"_NUMGUI") ) ))
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Campos restantes														 
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oB53:SetValue("B53_DATMOV", dDataBase )
	oB53:SetValue("B53_HORMOV", Left(Time(),5) )
	oB53:SetValue("B53_MATUSU", (cAlias)->( &(cAlias+"_OPEUSR")+&(cAlias+"_CODEMP")+&(cAlias+"_MATRIC")+&(cAlias+"_TIPREG")+&(cAlias+"_DIGITO") ) )
	oB53:SetValue("B53_NOMUSR", Posicione( "BA1",2,xFilial("BA1") + (cAlias)->( &(cAlias+"_OPEUSR")+&(cAlias+"_CODEMP")+&(cAlias+"_MATRIC")+&(cAlias+"_TIPREG")+&(cAlias+"_DIGITO") ) ,"BA1_NOMUSR" ) )
	
	If (B53->(FieldPos('B53_NOMSOC')) > 0)
		oB53:SetValue("B53_NOMSOC", Posicione( "BA1",2,xFilial("BA1") + (cAlias)->( &(cAlias+"_OPEUSR")+&(cAlias+"_CODEMP")+&(cAlias+"_MATRIC")+&(cAlias+"_TIPREG")+&(cAlias+"_DIGITO") ) ,"BA1_NOMSOC" ) )
	EndIf 

	oB53:SetValue("B53_DEMAND", Iif(lDemand,"1","0") )
	oB53:SetValue("B53_PARTIC", Iif(lPartic,"1","0") )
	oB53:SetValue("B53_STATUS", Iif((cAlias)->&(cAlias+"_STATUS") == "6", "3",(cAlias)->&(cAlias+"_STATUS")))
	oB53:SetValue("B53_CARINT", cCarInt )
	oB53:SetValue("B53_PERAUD", If(EMPTY(cPerAud),'1;',cPerAud)   )
	oB53:SetValue("B53_TIPO", cTpGuia )
	oB53:SetValue("B53_AGEPAR", "0" )             
	oB53:SetValue("B53_SITUAC", "0" )                                                              
	oB53:SetValue("B53_BANCON", "0" )
	oB53:SetValue("B53_ENCAMI", IIF(!Empty(cEncGui), "1", "0"))  
	oB53:SetValue("B53_CODDEP", cEncGui) //r7
	oB53:SetValue("B53_ROTGEN", "0") //rotina genИrica igual a nЦo

	// Calcula o Prazo do Atendimento
	If B53->(FieldPos("B53_DATPRZ")) > 0 .And. FindFunction("PLPrazoAtend")	.And. !lReembolso	

		oDadosPrazo := JsonObject():New()

		If lIntern .Or. lProrrog
			oDadosPrazo["cTipAdmissao"] := BE4->BE4_TIPADM
			oDadosPrazo["lAtendInternacao"] := .T.			
			oDadosPrazo["lHospitalDia"] := IIf(BE4->BE4_REGINT == "2", .T., .F.)
			oDadosPrazo["lOdonto"] := .F.
			oDadosPrazo["lLaboratorio"] := Alltrim(BE4->BE4_TIPPRE) == "LAB"
			oDadosPrazo["lRegAmbulatorio"] := .F.
			oDadosPrazo["cEspecialidade"] := BE4->BE4_CODESP
		Else
			oDadosPrazo["cTipAdmissao"] := BEA->BEA_TIPADM
			oDadosPrazo["lAtendInternacao"] := .F.
			oDadosPrazo["lHospitalDia"] := .F.
			oDadosPrazo["lOdonto"] := IIf(Alltrim(cTpGuia) == "4", .T., .F.)
			oDadosPrazo["lLaboratorio"] := Alltrim(BEA->BEA_TIPPRE) == "LAB"
			oDadosPrazo["lRegAmbulatorio"] := Alltrim(BEA->BEA_ATEAMB) == "1"
			oDadosPrazo["cEspecialidade"] := BEA->BEA_CODESP
		EndIf

		oDadosPrazo["cAliasItens"] := cAliasIte
		oDadosPrazo["aHeaderItens"] := aHeaderITE
		oDadosPrazo["aColsItens"] := aColsITE

		dDtPrazoAten := PLPrazoAtend(oDadosPrazo)

		oB53:SetValue("B53_DATPRZ", dDtPrazoAten)

		FreeObj(oDadosPrazo)
    	oDadosPrazo := Nil

	EndIf 

	If lProrrog .Or. lOPME  
		oB53:SetValue("B53_NMGORI",(cAlias)->&(cAlias+"_GUIREF"))
	Else
		oB53:SetValue("B53_NMGORI",cNumAut)
	EndIf
	
	if lExPLSDEPTO
		cCodDep := Execblock("PLSDEPTO", .f., .f., {cOriMov,cTipo,lAutorizacao,cCarInt,lFutura,lReembolso,lEvolu,lIntern,aDadCri,aCabCri,aColsITE,aHeaderITE,cAliasIte,cAliasCri,cRegInt,lPartic} )
	endif

	IF !Empty(cEncGui) .or. (lExPLSDEPTO .and. !lDemand) 
		PLSICB71(cAlias, cValToChar((cAlias)->(Recno())), iif(!lExPLSDEPTO, cEncGui, cCodDep))
	ENDIF   

	If lOPME

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Se for guia de anexos clinicos, o sistema busca a RDA da guia usada como
		//	referencia na guia de anexos.														 
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

		If !lGui
			FOR nI := 1 TO Len(aTabPes)
				(aTabPes[nI][1])->( DbSetOrder(aTabPes[nI][2]) )
				lGui := (aTabPes[nI][1])->( MsSeek(xFilial(aTabPes[nI][1])+B4A->B4A_GUIREF) )
				IF lGui
					cCRda := (aTabPes[nI][1])->&((aTabPes[nI][1])+"_CODRDA")
				EndIf
				If BB8->( MsSeek( xFilial("BB8") + (aTabPes[nI][1])->&(aTabPes[nI][1]+"_CODRDA") + cOpeMov + (aTabPes[nI][1])->&(aTabPes[nI][1]+"_CODLOC") + (aTabPes[nI][1])->&(aTabPes[nI][1]+"_LOCAL") ) )
					cCodMun := BB8->BB8_CODMUN
					Exit
				EndIf
			Next
		EndIf

		oB53:SetValue("B53_CODRDA", cCRda )
		oB53:SetValue("B53_CODMUN", cCodMun )

	Else
		oB53:SetValue("B53_CODRDA", (cAlias)->&(cAlias+"_CODRDA") )
		oB53:SetValue("B53_CODMUN", cCodMun )
	EndIf

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Grava o departamento quando for de demanda
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If lDemand

		oBX4 := PLSREGIC():New()
		oBX4:GetDadReg("BX4" ,1, ( xFilial("BX4") + RETCODUSR() + PlsIntPad() ) )

		If oBX4:lFound
			cCodDep := oBX4:GetValue("BX4_CODDEP")
			oB53:SetValue("B53_CODDEP", cCodDep )
		EndIf        

		oBX4:Destroy()
	// Ponto de entrada para personalizar a gravaГЦo do departamento. Valido somente se nao for demanda.
	Elseif lExPLSDEPTO 
		oB53:SetValue("B53_CODDEP", cCodDep)	
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё NЦo tenha sido informado pega do parametro XML POR EXEMPLO.
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If Empty(cCodDep)
		cCodDep := GetNewPar("MV_PL790DP","001")
	EndIf	                                 
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Evolucao de Internacao
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oB53:SetValue("B53_PROINT", Iif(lEvolu .or. lProrrog,"1","0") )             
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Na internacao
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oB53:SetValue("B53_REGINT", cRegInt )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё 0=Baixa;1=Media;2=Alta
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oB53:SetValue("B53_PRIORI", cPriori )         

	If lEvolu

		cChave := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

		BEJ->(dbSetOrder(1))
		If BEJ->(dbSeek(xFilial("BEJ") + cChave))

			While !BEJ->(EOF()) .AND. xFilial("BEJ")+BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT) ==;
			xFilial("BEJ") + cChave

				If BEJ->BEJ_STATUS == '1'
					nPosit++
				Else
					nNegat++
				EndIf
				BEJ->(dbSkip())
			EndDo
		EndIf

		BQV->(dbSetOrder(1))
		If BQV->(dbSeek(xFilial("BQV") + cChave))

			While !BQV->(EOF()) .AND. xFilial("BQV")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) ==;
			xFilial("BQV") + cChave

				If BQV->BQV_STATUS == '1'
					nPosit++
				Else
					nNegat++
				EndIf
				BQV->(dbSkip())
			EndDo
		EndIf

		oBE4 := PLSSTRUC():New( "BE4",MODEL_OPERATION_UPDATE,,BE4->( Recno() ) )
		oBE4:SetValue("BE4_STATUS", "6") //status de auditoria (remote) 
		oBE4:SetValue("BE4_STTISS", "2") //status en anАlise (portal) 
		
		If nPosit == 0 .AND. nNegat > 0
			oB53:SetValue("B53_STATUS", "3") 
			lAudEvo := .T.
		
		ElseIf nPosit > 0 .AND. nNegat > 0
			oB53:SetValue("B53_STATUS", "2") 
			lAudEvo := .T.
		
		ElseIf nPosit > 0 .AND. nNegat == 0
			oB53:SetValue("B53_STATUS", "1") 
		EndIf

		If !oBE4:CRUD() 
			oBE4:ExbMHelp( oBE4:GetErrorMessage(.T.) )
		EndIf

		oBE4:Destroy()	
	EndIf
Else     
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Complementa o perfil
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	aMat := _Super:Split(";", oGEN:GetValue("B53_PERAUD") )
	For nI:=1 To Len(aMat)
		If !Empty(aMat[nI]) .And. !(aMat[nI] $ cPerAud)
			cPerAud += aMat[nI]+";"
		EndIf
	Next                                  
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Se a guia ja foi analisada limpa o operador
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If oGEN:GetValue("B53_SITUAC") == "1"
		oB53:SetValue("B53_OPERAD", "" )   
		oB53:SetValue("B53_SITUAC", "0" )   
		oB53:SetValue("B53_DATINI", CToD("") )   
		oB53:SetValue("B53_HORINI", "" )   
		oB53:SetValue("B53_DATFIM", CToD("") )   
		oB53:SetValue("B53_HORFIM", "" )   
	EndIf	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Campos que devem ser alterados
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oB53:SetlAltera(.T.)
	oB53:SetValue("B53_PERAUD", cPerAud )
	oB53:SetValue("B53_DEMAND", Iif(lDemand,"1","0") )
	oB53:SetValue("B53_PARTIC", Iif(lPartic,"1","0") )
	oB53:SetValue("B53_CARINT", cCarInt )
	oB53:SetValue("B53_PRIORI", cPriori )
	oB53:SetValue("B53_PROINT", Iif(lEvolu .or. lProrrog,"1","0") )
	oB53:SetValue("B53_SITUAC", "0" )

	If !EMPTY(oGEN:getValue("B53_DATFIM"))
		oB53:SetValue("B53_DATMOV", date() )  
		oB53:SetValue("B53_HORMOV", SUBSTR(Time(), 1, 5) )
	EndIf  

	If lEvolu

		BEJ->(dbSetOrder(1))
		If BEJ->(dbSeek(xFilial("BEJ")+B53->B53_NUMGUI))

			While !BEJ->(EOF()) .AND. xFilial("BEJ")+BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT) ==;
			xFilial("BEJ")+B53->B53_NUMGUI

				If BEJ->BEJ_STATUS == '1'
					nPosit++
				Else
					nNegat++
				EndIf
				BEJ->(dbSkip())
			EndDo
		EndIf

		BQV->(dbSetOrder(1))
		If BQV->(dbSeek(xFilial("BQV")+B53->B53_NUMGUI))

			While !BQV->(EOF()) .AND. xFilial("BQV")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) ==;
			xFilial("BQV")+B53->B53_NUMGUI

				If BQV->BQV_STATUS == '1'
					nPosit++
				Else
					nNegat++
				EndIf
				BQV->(dbSkip())
			EndDo
		EndIf
	EndIf

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Cria o objeto para a atualizacao
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

	if nPosit == 0 .AND. nNegat > 0
		oB53:SetValue("B53_STATUS", "3")
	ElseIf nPosit > 0 .AND. nNegat > 0
		oB53:SetValue("B53_STATUS", "2")
	ElseIf nPosit > 0 .AND. nNegat == 0
		oB53:SetValue("B53_STATUS", "1")
	EndIf

	If lEvolu
		
		oBE4 := PLSSTRUC():New( "BE4",MODEL_OPERATION_UPDATE,,BE4->( Recno() ) )
		oBE4:SetValue("BE4_STATUS", "6") //status de auditoria (remote) 
		oBE4:SetValue("BE4_STTISS", "2") //status en anАlise (portal) 
		
		If nPosit == 0 .AND. nNegat > 0 .OR. nPosit > 0 .AND. nNegat > 0 
			lAudEvo := .T.
		EndIf
	EndIf	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Grava dados na base de dados											 
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

	If lEvolu
		If !oBE4:CRUD() 
			oBE4:ExbMHelp( oBE4:GetErrorMessage(.T.) )
		EndIf
		oBE4:Destroy()	
	EndIf
EndIf

If !oB53:CRUD() 
	oB53:ExbMHelp( oB53:GetErrorMessage(.T.) )
EndIf	

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Destroy a Classe
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oB53:Destroy() 
oGEN:Destroy() 
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim do Metodo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return
//-------------------------------------------------------------------
/*/ { Protheus.doc } EMail
Envia email

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD EMail() Class PLSA790C
LOCAL aArea	:= GetArea()
LOCAL lRet		:= .F.
LOCAL cTo		:= ""
LOCAL cFrom 	:= ""
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica dados do usuario de envio
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд 
PswOrder(2)
	cFrom := UsrRetMail(RetCodUsr())//AllTrim(PswRet(1)[1][14])

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica dados do usuario destinatario
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд 
	cTo := UsrRetMail(B70->B70_COPAGE)//AllTrim(PswRet(1)[1][14])

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se tem e-mail
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд 
If Empty(cFrom)
	MSGALERT(STR0021 ) //"E-MAIL nЦo informado para o Remetente"
	Return
EndIf

If Empty(cTo)
	MSGALERT(STR0022 ) //"E-MAIL nЦo informado para o DestinatАrio"
	Return
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Dados enviado ao destinatario
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд 
cBeneficiario 	:= AllTrim(B53->B53_MATUSU + " - " + Posicione("BA1",2,xFilial("BA1")+B53->B53_MATUSU,"BA1->BA1_NOMUSR"))
cNumGui			:= AllTrim(B53->B53_NUMGUI)
cRda			:= AllTrim(B53->B53_CODRDA + " - " + Posicione("BAU",1,xFilial("BAU")+B53->B53_CODRDA,"BAU->BAU_NOME"))
cDHRea			:= AllTrim(DToC(B70->B70_DATREA) + " - " + B70->B70_HORREA)
cDHAge			:= AllTrim(DToC(B70->B70_DATAGE) + " - " + B70->B70_HORAGE)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se o usuario de e para tem email
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд 
If !Empty(cFrom) .And. !Empty(cTo)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
    //ЁMonta o corpo do e-mail												   
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	cBody := "<html>"
	cBody += "<style type='text/css'><!--"
	cBody += ".texto {"
	cBody += "	font-family: Arial, Helvetica, sans-serif;font-size: 12px;"
	cBody += "	color: #333333;text-decoration: none;font-weight: normal;"
	cBody += "}"
	cBody += ".titulo {"
	cBody += "	font-family: Arial, Helvetica, sans-serif;font-size: 16px;"
	cBody += "	color: #19167D;text-decoration: none;font-weight: bold;"
	cBody += "}"
	cBody += "--></style>"

	cBody += "<body>"
	cBody += "<table width='400' height='60' border='0' cellpadding='0' cellspacing='0'>"
	cBody += "<tr class='titulo'>"
	cBody += "<td height='10'>"
	cBody += "	<strong><font size='4'>Auditoria Participativa - Agendamento</font></strong>"
	cBody += "<td>"
	cBody += "</tr>"
	cBody += "<tr><td><br></td></tr>"
	cBody += "<tr>"
	cBody += "<td height='30'>"
	cBody += "<table>"
	cBody += "	<tr class='texto'>"
	cBody += "		<td width='130' align='Right'><strong>Beneficiario:</strong></td>"
	cBody += "		<td>"+cBeneficiario+"</td>"
	cBody += "	</tr>"

	cBody += "	<tr class='texto'>"
	cBody += "		<td width='130' align='Right'><strong>Rede de Atendimento:</strong></td>"
	cBody += "		<td>"+cRda+"</td>"
	cBody += "	</tr>"
	 
	cBody += "	<tr class='texto'>"
	cBody += "		<td width='130' align='Right'><strong>Numero da Guia:</strong></td>"
	cBody += "		<td>"+cNumGui+"</td>"
	cBody += "	</tr>"
	
	cBody += "	<tr class='texto'>"
	cBody += "		<td width='130' align='Right'><strong>RealizaГЦo:</strong></td>"
	cBody += "		<td>"+cDHRea+"</td>"
	cBody += "	</tr>"
	
	cBody += "	<tr class='texto'>"
	cBody += "		<td width='130' align='Right'><strong>Agendamento:</strong></td>"
	cBody += "		<td>"+cDHAge+"</td>"
	cBody += "	</tr>"
	cBody += "</table>"
	cBody += "</td>"
	cBody += "</tr>"
	cBody += "</table>"
	cBody += "</body>"
	cBody += "</html>"
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
    //ЁEnvia email
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	::SendEmail(cFrom,cTo,,,STR0023,cBody) //"Agendamento de Visita"
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
    //ЁVerifica se teve erro
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	MSGALERT( ::cErro )
	lRet := .T.
Else
	MSGALERT(STR0024 ) //"E-MAIL nЦo encontrado"
	lRet := .F.
EndIf 
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Rest nas linhas do browse e na area										 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
RestArea( aArea )                   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim do Metodo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(lRet)                         
//-------------------------------------------------------------------
/*/ { Protheus.doc } NegComp
Nega participacao do item

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD NegComp() Class PLSA790C
LOCAL cSequen := (::cAIte)->&(::cAIte + "_SEQUEN")
LOCAL cCodPad := (::cAIte)->&(::cAIte + "_CODPAD")
LOCAL cCodPro := (::cAIte)->&(::cAIte + "_CODPRO")
LOCAL cStatus := (::cAIte)->&(::cAIte + "_STATUS")
LOCAL dDatPro := (::cAIte)->&(::cAIte + "_DATPRO")
LOCAL cCodRda := B53->B53_CODRDA
LOCAL cMatric := B53->B53_MATUSU
LOCAL cChave  := xFilial("B53") + B53->( B53_CODOPE + B53_CODLDP + B53_CODPEG + B53_NUMERO + B53_ORIMOV ) + cSequen
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Nega ou autoriza a participacao
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PLSNACOM(cSequen,cCodPad,cCodPro,cStatus,dDatPro,,cChave,cCodRDA,.T.,cMatric)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return        
//-------------------------------------------------------------------
/*/ { Protheus.doc } NegComp
Nega participacao do item

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetDemanda() Class PLSA790C
LOCAL B53 := NIL
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza para demanda
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
B53 := PLSSTRUC():New( "B53",MODEL_OPERATION_UPDATE,,B53->( Recno() ) )
B53:SetValue("B53_DEMAND",'1' )
B53:CRUD()
B53:Destroy()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return        
//-------------------------------------------------------------------
/*/ { Protheus.doc } Destroy
Libera da memoria o obj (Destroy)

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Destroy() Class PLSA790C
FreeObj(Self:self)
Return



//-------------------------------------------------------------------
/*/ { Protheus.doc } SetAuditoGen
InclusЦo da chamada de auditoria genИrica

@author Renan Martins	 @since 08/2015     @version 1.0
* lRotGen - Quando rotina genИrica, passar como .T. (true)
* cAliorig - Alias do movimento (alias do cabeГalho)
* cAliasIte - Alias dos itens, referentes ao cabeГalho mais o Мndice de pesquisa que deve ser usado para busca os itens do cabeГalho.
EXEMPLO: Se o Alias de item И ZZZ e o indice para buscar И o 2, deve ser passado "ZZZ2"
* cAliasCri - Alias de crМtica da tabela de itens 
* cCodOpe - CСdigo da operadora
* cNumCont - NЗmero de controle, ou seja, nЗmero da guia que servirА para busca no mСdulo e resgatar os itens
* cMatric - MatrМcula do usuАrio 
* cNomUsr - Nome do usuАrio
* aAtuAItens - Array com os dados para atualizar os itens que estЦo em auditoria. Deve ser usado quando desejamos
que todos os itens relacionado ao cabeГalho serЦo mandados para auditoria, pois ele atualiza todos os itens. Deve ser usado
quando mandamos o cabeГalho direto para auditoria. Por exemplo, tenho um processo com dois itens para auditoria. Passo os dados
solicitados deste array, que a rotina jА atualiza os dois itens, indicando que os dois estЦo em auditoria
FORMA do ARRAY: Tabela de Itens/Nome do campo que indica auditoria (apenas nome - atИ 6 caracteres)/Valor que indica que estА em 
  auditoria/Chave de Pesquisa dos itens(o index utilizado para buscar o item, mas sem o xfilial)/indice utilizado para a pesquisa 
  nЗmero do Мndice descrito
  EXEMPLO: {"BDD", "Audito", "1", "BDD_INTERC+BDD_CODOPE+BDD_NUMERO", 1}
* nAtuFil - NЗmero do item que deseja atualizar, quando queremos atualizar apenas um item que estА em auditoria. Aqui, deve-se passar
o RECNO do registro que deve ser atualizado.
OBS: Nunca se deve passar aAtuAItens e nAtuFil juntos, pois sЦo para fins diferentes. Enquanto o aAtuAItens atualiza todos os itens,
o nAtuFil serve para mandar apenas um item para auditoria. Ou seja, caso tenhamos um processo com 5 itens e todos devem ser auditados,
utilize o aAtuAItens. Caso destes 5 apenas um deve ir para auditoria, passar o nЗmero do RECNO desse registro para o nAtuFil.
* cCpRelac - Campo com os valores que serЦo utilizados para relacionar crМticas, indicar campo que mostra que determinado cabeГalho/item 
estА em auditoria e oturas opГУes - separados por VмRGULA. и obrigatСrio o preenchimento das 5 primeiras posiГУes, que serЦo salvas no campo B53_CVLAUD (tamanho: 30):
diversas opГУes, para tornar a rotina mais prАtica. 
FORMA do ARRAY: 1)Nome do campo que diz que estА em auditoria (sem o alias- obrigatСrio) /  2)Valor do campo quando em auditoria (obrigatСrio) / 
  3) Campo de sequencia   ou localizador de itens e crМticas (opcional)/ 4) Valor do campo quando nЦo estА em auditoria (obrigatСrio) / 5) Nome 
  do campo que diz se registro aprovado ou negado auditoria (sem alias - opcional) / 6) Valor do campo quando item negado pela auditoria / 
  7) Valor do campo quando aprovado 3
  EXEMPLO: "AUDITO,SIM,SEQUEN,NAO,APRVAD,SIM,NAO" 
  Quando o auditor for dar o seu parecer, o sistema irА localizar o campo que identifica que determinado item e cabeГalho estА em auditoria, atualizando este campo com o valor
  desejado. Logo, baseado no exmplo acima, se a tabela fosse a "BBB", o sistema ia procurar o campo BBB_AUDITO (1╙posiГЦo) e colocar neste campo o valor NAO (4╙ posiГЦo).
  E caso na tabela de itens ainda tenha campos para indicar a decisЦo da auditoria (Negado - Aprovado), de acordo com o valor da 5╙ posiГЦo (nome do campo), o sistema irА 
  procurar na Tabela o campo BBB_APRVAD e caso tenha sido aprovado, irА inserir neste campo o valor SIM. Se negado, NAO.
* cTpGuia - Tipo da guia, de acordo com o campo B53_TIPO. O default do campo И Outros, mas caso haja necessidade, pode-se alterar este campo e passar aqui o valor criado.     
*/
//-------------------------------------------------------------------
METHOD SetAuditoGen(lRotGen, cAliOrig, cAliasIte, cAliasCri, cCodOpe, cNumCont, cMatric, cNomUsr, aAtuAItens, nAtuFil, cCpRelac, cTpGuia ) Class PLSA790C
LOCAL nI				:= 1
LOCAL cOpeMov   		:= IIF( !(Empty(cCodope)), cCodOpe, PLSIntPad() )	//Se param. preenchido, fica do parametro, se nЦo, pega do operador logado
LOCAL cCarInt   		:= "N"
LOCAL cNumAut			:= ""
LOCAL cTipo		 		:= ""
LOCAL cPerAud 			:= ""
LOCAL cTipAdm			:= ""
LOCAL cPriori			:= SubStr(&(GetSx3Cache("B53_PRIORI","X3_RELACAO")),1,1)
LOCAL cOriMov			:= "3"
LOCAL cCodDep			:= ""
LOCAL cRegInt			:= "0"
LOCAL lAutorizacao 		:= .F.
LOCAL lFutura			:= .F.
LOCAL lDemand			:= .F.
LOCAL cTempCont			:= ""
LOCAL oGEN				:= NIL
LOCAL oB53				:= NIL
LOCAL nPosit 			:= 0
LOCAL nNegat 			:= 0
LOCAL oBE4				:= NIL
LOCAL lGui				:= .F.
Local cEncGui			:= getNewPar("MV_SETORAT","")
Local nCodIndx			:= 0
Local lCont				:= .T.
LOCAL aMat				:= {}
Local aResItem			:= {}	
Local aRetRes			:= {}
DEFAULT aColsITE		:= {}
DEFAULT aHeaderITE		:= {}
DEFAULT cAliasIte		:= {}
DEFAULT lRotGen			:= .F. //PadrЦo Falso quando nЦo for via rotina genИrica
DEFAULT cAliasCri		:= ""  //ALIAS DE CRмTICA QUANDO ROTINA GENиRICA
DEFAULT cAliasIte		:= ""	//ALIAS DE ITEM QUANDO ROTINA GENиRICA
DEFAULT cAliOrig		:= ""	//ALIAS DE cabeГalho quando rotina genИrica
DEFAULT cNumCont		:= "" 
Default cMatric			:= "N/D"
Default cCRda			:= "000"
Default cCodMun 		:= "000"
Default cNomUsr			:= "NЦo Definido"
Default aAtuAItens		:= {}	//Campo com valores para atualizar cabeГalho e itens (opcional)
Default nAtuFil			:= 0	//Campo informando quais itens filhos serЦo atualizados
Default cTpGuia			:= "7"

// Verifica se o inicializador do campo B53_PRIORI esta preenchido
cPriori := Iif(Empty(cPriori),"0",cPriori)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se esta habilitada a nova auditoria
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If GetNewPar("MV_PL790NE","0") == "0"
	Return
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se nЗmero de controle (chave de relacionamento) estА preenchida. Se nЦo estiver,
//o sistema nЦo irА gerar a auditoria, pois И a chave de relacionamento
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
IF ( Empty(cNumCont) .OR. Empty(cAliasCri) .OR. Empty(cAliasIte) .OR. Empty(cAliOrig) .OR. Empty(cCpRelac) )	  //ALIAS DE CRмTICA QUANDO ROTINA GENиRICA
   Alert(STR0031) // NЦo foi possМvel gravar na Auditoria, pois nЦo foi informado um ou mais campos obrigatСrios do registro desejado.
   Return
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verificar se o registro jА nЦo existe na base. Se sim, nЦo pode inserir de novo!
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oGEN := PLSREGIC():New()
cTempCont := Padr(cNumCont, (TamSX3("B53_NUMGUI")[1]))
oGEN:GetDadReg("B53",1, xFilial("B53") + cTempCont + cOriMov )

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё verifica se o registro jА existe na B53. AlИm disso, verifica se o campo aAtuFil estА vazio,
// pois se estiver, significa que estА tentando incluir de novo um cabeГalho jА existente na B53.
// Se aAtuFil estiver preenchido, significa que estА incluindo apenas item filho
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If oGEN:lFound .AND. Empty(nAtuFil) 
  MsgAlert(STR0032)
  Return
ENDIF
oGen:Destroy()

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifico se Atualiza Itens estА preenchido. Se sim, significa que a rotina irА tambИm gravar, de acordo
// com as informaГУes do array, o valor definido pelo desenvolvedor nas tabelas, indicando
// que aquele cabeГalho/item estА em auditoria (opcional). A chave serА a mesma cNumCont
//Preciso passar na sequЙncia: Tabela, Nome Campo A ser Atualizado, Valor, Campos Indice
//{Tabela, Nome do campo, Valor, Campos Indice, Indice} = {"YYY","Audito", "1", "YYY_COD+YYYY_RUA", 1}
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
IF (Len(aAtuAItens) > 0 .AND. nAtuFil > 0)
   MsgAlert(STR0033)
   Return
ENDIF
     
IF (Len(aAtuAItens) > 0)
   PLSAtuCGen(aAtuAItens, cNumCont)
ENDIF

IF ((nAtuFil) > 0)
	aVetTmp := {Left(cAliasIte,3)}
	aResItem := PLSVerAdAb(cTempCont, cOriMov) //cTempCont por causa dos espaГos faltantes, caso haja
	IF ( aResItem[1] )  //Guia jА foi auditada e nЦo И possМvel inserir mais itens nela
	   MsgAlert(STR0034)
	   Return
	ELSEIF (!aResItem[2])  //Guia estА em aberto e jА existe na auditoria - apenas atualizo item e saio da rotina
	   PLSAtuCGen(aVetTmp, Nil, 1, nAtuFil, cCpRelac)
	   Return
	ELSEIF (aResItem[2]) //Significa a inclusЦo de nova guia com apenas 1 registro para ser atualizado   
	   PLSAtuCGen(aVetTmp, Nil, 1, nAtuFil, cCpRelac)
	ENDIF
ENDIF

cPerAud := Iif(Empty(cPerAud),"0;1;2;",cPerAud)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Instancia o modelo de dados												 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд 
oB53 := PLSSTRUC():New("B53")
oB53:SetValue("B53_NUMGUI", cNumCont )             
oB53:SetValue("B53_ORIMOV", cOriMov )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Tem que verificar se ja nao existe pois a evolucao vai inserir varios procedimento na mesma guia
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oGEN := PLSREGIC():New()
oGEN:GetDadReg("B53",1, xFilial("B53") + cNumCont + cOriMov )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se nao existir, proceder com a inclusЦo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !oGEN:lFound
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Chaves																	 
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oB53:SetValue("B53_FILIAL", xFilial(cAliOrig) )
	oB53:SetValue("B53_ALIMOV", cAliOrig )
	oB53:SetValue("B53_RECMOV", cValToChar( (cAliOrig)->( Recno() ) ) )
	oB53:SetValue("B53_CODOPE", cOpeMov )
	oB53:SetValue("B53_CODLDP", "0000" )
	oB53:SetValue("B53_CODPEG", "00000000")
	oB53:SetValue("B53_NUMERO", "00000000") 
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Campos restantes														 
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oB53:SetValue("B53_DATMOV", dDataBase )
	oB53:SetValue("B53_HORMOV", Left(Time(),5) )
	oB53:SetValue("B53_MATUSU", cMatric )
	oB53:SetValue("B53_NOMUSR", cNomUsr )

	If (B53->(FieldPos('B53_NOMSOC')) > 0)
		oB53:SetValue("B53_NOMSOC", Posicione( "BA1",2,xFilial("BA1") + ("B53")->( &("B53_OPEUSR")+&("B53_CODEMP")+&("B53_MATRIC")+&("B53_TIPREG")+&("B53_DIGITO") ) ,"BA1_NOMSOC" ) )
	EndIf
	
	oB53:SetValue("B53_DEMAND", "0" )
	oB53:SetValue("B53_PARTIC", "0" )
	oB53:SetValue("B53_STATUS", "7" )  //Rotina GenИrica
	oB53:SetValue("B53_CARINT", cCarInt )
	oB53:SetValue("B53_PERAUD", If(cPerAud == ';', '1;',cPerAud))
	oB53:SetValue("B53_TIPO", cTpGuia )
	oB53:SetValue("B53_AGEPAR", "0" )             
	oB53:SetValue("B53_SITUAC", "0" )      //NЦo                                                       
	oB53:SetValue("B53_BANCON", "0" )
	oB53:SetValue("B53_ENCAMI", IIF(!Empty(cEncGui), "1", "0"))  
	oB53:SetValue("B53_CODDEP", cEncGui) //r7
	oB53:SetValue("B53_ROTGEN", "1" )             
	oB53:SetValue("B53_ALIITE", cAliasIte )      //Em anАlise                                                        
	oB53:SetValue("B53_ALICRI", cAliasCri )
	oB53:SetValue("B53_CVLAUD", cCpRelac )
	
	IF !Empty(cEncGui)
	   PLSICB71(cAliOrig, cValToChar((cAliOrig)->(Recno())), cEncGui )
	ENDIF   
	   
	oB53:SetValue("B53_CODRDA", cCRda )
	oB53:SetValue("B53_CODMUN", cCodMun )
	oB53:SetValue("B53_PROINT", "0" )             
	oB53:SetValue("B53_REGINT", cRegInt )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё 0=Baixa;1=Media;2=Alta
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oB53:SetValue("B53_PRIORI", cPriori )         
Else     
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Complementa o perfil
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	aMat := _Super:Split(";", oGEN:GetValue("B53_PERAUD") )
	For nI:=1 To Len(aMat)
		If !Empty(aMat[nI]) .And. !(aMat[nI] $ cPerAud)
			cPerAud += aMat[nI]+";"
		EndIf
	Next                                  
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Se a guia ja foi analisada limpa o operador
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If oGEN:GetValue("B53_SITUAC") == "1"
		oB53:SetValue("B53_OPERAD", "" )   
		oB53:SetValue("B53_SITUAC", "0" )   
		oB53:SetValue("B53_DATINI", CToD("") )   
		oB53:SetValue("B53_HORINI", "" )   
		oB53:SetValue("B53_DATFIM", CToD("") )   
		oB53:SetValue("B53_HORFIM", "" )   
	EndIf	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Campos que devem ser alterados
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oB53:SetlAltera(.T.)
	oB53:SetValue("B53_PERAUD", If(cPerAud == ';', '1;',cPerAud) )
	oB53:SetValue("B53_DEMAND", "0" )
	oB53:SetValue("B53_PARTIC", "0" )
	oB53:SetValue("B53_CARINT", cCarInt )
	oB53:SetValue("B53_PRIORI", cPriori )
	oB53:SetValue("B53_PROINT", "0" )
	oB53:SetValue("B53_SITUAC", "0" )
	
	If !EMPTY(oGEN:getValue("B53_DATFIM"))
		oB53:SetValue("B53_DATMOV", date() )  
		oB53:SetValue("B53_HORMOV", SUBSTR(Time(), 1, 5) )
	EndIf  
	

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Cria o objeto para a atualizacao
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		
	if nPosit == 0 .AND. nNegat > 0
		oB53:SetValue("B53_STATUS", "3")
	ElseIf nPosit > 0 .AND. nNegat > 0
		oB53:SetValue("B53_STATUS", "2")
	ElseIf nPosit > 0 .AND. nNegat == 0
		oB53:SetValue("B53_STATUS", "1")
	EndIf
EndIf	
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Grava dados na base de dados											 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

If !oB53:CRUD() 
	oB53:ExbMHelp( oB53:GetErrorMessage(.T.) )
EndIf	

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Destroy a Classe
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oB53:Destroy() 
oGEN:Destroy() 
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim do Metodo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return


//-------------------------------------------------------------------
/*/ { Protheus.doc } PLSAtuCGen
Atualiza campos de auditoria, caso seja chamada a funГЦo

@author Renan Martins
@since 08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PLSAtuCGen(aVetor, cChave, nTipUnq, nRecReg, cCmpRel)
Local nI 			:= 0
Local lRte			:= .T.
Local aTmp			:= {}
Default nTipUnq	:= 0

IF (nTipUnq <> 1)
  For nI := 1 TO Len(aVetor)
    (aVetor[nI][1])->(DbselectArea(aVetor[nI][1]))
    (aVetor[nI][1])->(DBSetOrder(aVetor[nI][5]))
	 IF ( (aVetor[nI][1])->( DbSeek( xFilial(aVetor[nI][1]) + cChave)) )
	    While ( !(aVetor[nI][1])->(Eof()) .And. (aVetor[nI][1])->&(aVetor[nI][4]) == cChave )
		 (aVetor[nI][1])->(Reclock(aVetor[nI][1],.F.))
		 (aVetor[nI][1])->&(aVetor[nI][1]+"_"+aVetor[nI][2]) := aVetor[nI][3]
		 (aVetor[nI][1])->( MsUnlock() )
		 (aVetor[nI][1])->(dbSkip())
	    ENDDO	 
	 ENDIF
  Next

ELSE  //Quer dizer que estou apenas atualizando apenas um item
  IF ( Valtype(nRecReg) == "N" )
  	  aTmp := SEPARA(cCmpRel,",",.F.)
  	  IF ( (aVetor[1])->&(aVetor[1]+"_"+aTmp[1]) == aTmp[2] )
  	     MsgAlert(STR0035)
  	     Return
	  ENDIF
	  (aVetor[1])->(DbselectArea(aVetor[1]))  
	  (aVetor[1])->(DBGoTo(nRecReg))
	  (aVetor[1])->(Reclock(aVetor[1],.F.))
	  (aVetor[1])->&(aVetor[1]+"_"+aTmp[1]) := aTmp[2]
	  (aVetor[1])->( MsUnlock() )
  ELSE
	  lRte := .F.
  ENDIF  	  
ENDIF  
Return (lRte)


//-------------------------------------------------------------------
/*/ { Protheus.doc } PLSAtuCGen
Verifica se durante a inclusЦo de um item, se o cabeГalho deste item jА  nЦo foi auditado, pois se sim, 
nЦo И possМvel incluir um novo item. 

@author Renan Martins
@since 08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PLSVerAdAb(cChave, cOriMov)
Local lItemFec 	:= .F.
Local oGEN			:= Nil
Local lCbcNInc	:= .F.
oGEN := PLSREGIC():New()
oGEN:GetDadReg("B53",1, xFilial("B53") + cChave + cOriMov )
If oGEN:lFound 
  IF (B53->B53_SITUAC == "1") // Guia Analisada nЦo И possivel incluir de novo 
    lItemFec := .T. // Significa que a guia jА foi analisada
  ENDIF
ELSE
  lCbcNInc := .T.   //Significa que o cabeГalho ainda nЦo foi incluМdo    
ENDIF
oGen:Destroy()

Return({lItemFec, lCbcNInc})



/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁAtuPClass Ё Autor Ё Totvs				    Ё Data Ё 17/03/11 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Atualiza propriedades da Classe	  						  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function AtuPClass(oSelf, lEvol)
LOCAL aRet := {}                        

Iif(lEvol,lEvo := .T.,Nil)

//Operador Corrente
oSelf:cOperad := RETCODUSR()

//Dados do operador
RetDadOpe(oSelf)

//Informacoes da guia
oSelf:lEmAnalise		:= B53->B53_SITUAC=='2'
oSelf:lEspera  	 		:= B53->B53_SITUAC=='3'
oSelf:lAnalisada 		:= Iif(B53->B53_SITUAC=='1',.T.,.F.)
oSelf:lInconsistente	:= Iif(B53->B53_SITUAC=='4',.T.,.F.)
oSelf:lIncoRes			:= Iif(B53->B53_SITUAC=='4' .And. B72->B72_INCONS == '1',.T.,.F.)
oSelf:lNotInRes			:= Iif(B53->B53_SITUAC=='4' .And. B72->( Eof() ),.T.,.F.)
oSelf:lAutorizada   	:= Iif(B53->B53_STATUS=='1',.T.,.F.)
oSelf:lParticipativa	:= Iif(B53->B53_PARTIC=='1',.T.,.F.)
oSelf:lAgendada     	:= Iif(B53->B53_AGEPAR=='1',.T.,.F.)
oSelf:lDemanda			:= Iif(B53->B53_DEMAND=='1',.T.,.F.)
oSelf:lHaveOwner 		:= !Empty(B53->B53_OPERAD)
oSelf:lOwner 			:= B53->B53_OPERAD==oSelf:cOperad
oSelf:cOwner			:= B53->B53_OPERAD
oSelf:lHaveGuia  		:= !Empty(B53->B53_NUMGUI)
oSelf:cNumGuia  		:= B53->B53_NUMGUI
oSelf:lRotinaGen		:= IIF(B53->B53_ROTGEN == "1", .T., .F.)
oSelf:cAllPerfil		:= B53->B53_PERAUD
oSelf:lConsulta     	:= AllTrim(B53->B53_TIPO)=='1'
oSelf:lSadt				:= AllTrim(B53->B53_TIPO)=='2'
oSelf:lInternacao		:= AllTrim(B53->B53_TIPO)=='3'
oSelf:lOdonto			:= AllTrim(B53->B53_TIPO)=='4'
oSelf:lReembolso		:= AllTrim(B53->B53_TIPO)=='5'
oSelf:lOPME				:= AllTrim(B53->B53_TIPO)=='6'
oSelf:lProrrog			:= AllTrim(B53->B53_TIPO)=='11'
oSelf:lEvolucao 		:= lEvo
oSelf:lCriDia			:= (AllTrim(B53->B53_TIPO)=='3' .or. AllTrim(B53->B53_TIPO)=='11') .and. PPL790VDIB(B53->B53_NUMGUI, AllTrim(B53->B53_TIPO))
oSelf:cACab				:= B53->B53_ALIMOV
aRet 					:= RetAliRel(oSelf)
oSelf:cAIte				:= aRet[1]
oSelf:cACri				:= aRet[2]
oSelf:nIdxIte			:= aRet[3]
oSelf:nIdxCri  			:= aRet[4]
oSelf:cAudito 			:= RetAudito(oSelf)

//Dados do departamento de acordo com a Guia sendo auditada
aRetDep := {}
aRetDep := RetDepart(oSelf)
oSelf:lThisDep 			:= aRetDep[1]
oSelf:cCodDepa			:= aRetDep[2]

Return

/*/{Protheus.doc} RetDepart
	Retorna o Departamento do Operador em que a Guia se encontra caso ela pertenГa a algum dos departamentos do operador.
	O De/Para Operador x Departamento fica na tabela B6P e seu cadastro na Aba Departamentos do cadastro de Operadores do Sistema.

	@author Thiago Paris
	@since 14/07/2020
	@version 1.0
	@param oSelf, object, self
	@return aRet, array, {bRet, cCodDep}, onde bRet И .T. caso encontre, .F. caso nЦo encontre,
		e cCodDep И o cСdigo do Departamento encontrado, ou BX4_CODDEP caso contrАrio.
	/*/
Static Function RetDepart(oSelf)
LOCAL bRet := .F.
LOCAL cCodDep := ""
bRet := (Empty(B53->B53_CODDEP) .Or. B53->B53_CODDEP==oSelf:cCodDep)
cCodDep := oSelf:cCodDep
If PLSALIASEXI("B6P") .And. !bRet
	B6P->(DbSetOrder(1))
	If  B6P->(msSeek(xFilial("B6P") + oSelf:cOperad + PlsIntPad() + B53->B53_CODDEP))
		bRet := .T.
		cCodDep := B6P->B6P_CODDEP
	Endif
EndIf
Return {bRet, cCodDep}
/*/        
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁRetDadOpe Ё Autor Ё Totvs			    	Ё Data Ё 17/03/11 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Atualiza propriedades da Classe	  						  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function RetDadOpe(oSelf)
LOCAL nPos := 0
LOCAL aRet := {}
LOCAL oBX4 := PLSREGIC():New()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Acesso ao registro
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oBX4:GetDadReg("BX4" ,1, ( xFilial("BX4") + oSelf:cOperad + PlsIntPad() ) ) 
oSelf:cDesPerf := ""
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se existe
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If oBX4:lFound
	oSelf:cCodDep := oBX4:GetValue("BX4_CODDEP")
	oSelf:cDirFax := oBX4:GetValue("BX4_DIRDOC")
	
	aRet := RetSx3Box( X3CBox( Posicione('SX3',2,"BX4_PERAUD",'X3_CBOX') ),,,1 )
	
	If (nPos := AsCan( aRet , {|x| AllTrim(x[2]) == oBX4:GetValue("BX4_PERAUD")} ) ) > 0
		oSelf:cDesPerf := aRet[nPos,3]
  	EndIf	
EndIf         
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se pode incluir processo de demanda
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oSelf:lOpAudi 	:= oBX4:GetValue("BX4_AUDITO") == "1"		//Ё╧╡Ё
oSelf:lLibGuia	:= oBX4:GetValue("BX4_LIBGUI") == "1"  //r7
oSelf:lIncDem 	:= oBX4:GetValue("BX4_PROCES") == "1"
oSelf:lIncPar 	:= oBX4:GetValue("BX4_PARTIC") == "1"
oSelf:lIncEnc 	:= oBX4:GetValue("BX4_ENCMIN") == "1"
oSelf:lIntSau 	:= oBX4:GetValue("BX4_INTSAU") == "1"
oSelf:lIncAno	:= oBX4:GetValue("BX4_ANOTAC") == "1"
oSelf:lMonFax 	:= oBX4:GetValue("BX4_MOTDOC") == "1"
oSelf:lVisAud 	:= oBX4:GetValue("BX4_VISAUD") == "1"
oSelf:lIncProc	:= oBX4:GetValue("BX4_PROAUD") == "1"
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da rotina
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oBX4:Destroy()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da rotina
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁRetAliRel Ё Autor Ё Totvs			    	Ё Data Ё 17/03/11 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Retorna os alias relacionado como alias informado          Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function RetAliRel(oSelf)
LOCAL aRet := {"","",1,1}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica o alias selecionado {Item,Critica,IdxItem,IdxCritica}
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
IF ( Empty(B53->B53_ROTGEN) .OR. B53->B53_ROTGEN == "0" )
Do Case 
	Case oSelf:lSadt .Or. oSelf:lConsulta
		aRet := {"BE2","BEG",1,1}
	Case oSelf:lInternacao .And. !oSelf:lEvolucao
		aRet := {"BEJ","BEL",1,1}
	Case oSelf:lEvolucao .OR. oSelf:lProrrog
		aRet := {"BQV","BQZ",1,1}
	Case oSelf:lOdonto
		aRet := {"BE2","BEG",1,1}
	Case oSelf:lReembolso
		aRet := {"B45","B46",1,1}
	Case oSelf:lOPME
		aRet := {"B4C","BEG",1,1}
EndCase	    
ELSE
	aRet := {Left(B53->B53_ALIITE,3),Left(B53->B53_ALICRI,3), Val(Right(B53->B53_ALIITE,3)),Val(Right(B53->B53_ALICRI,3))}
	
ENDIF    
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim do Rotina
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(aRet)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁDelAcbAc9 Ё Autor Ё Totvs			    	Ё Data Ё 17/03/11 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Verifica se ficou alguma sujeito na acb quando fecha a telaЁ╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function DelAcbAc9(lExcAC9)
LOCAL oAC9 		:= NIL
LOCAL oACB 		:= NIL        
DEFAULT lExcAC9 := .F.
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Elimina lixo da acb
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !lExcAC9
	If !ACB->( Eof() )
	 	oAC9 := PLSREGIC():New()
		oAC9:GetDadReg( "AC9",1, xFilial("AC9") + ACB->ACB_CODOBJ,,,.F. )
	
		If !oAC9:lFound
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Deleta arquivo movido para pasta do banco de conhecimento
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If FErase(MsDocPath()+"\"+ACB->ACB_OBJETO) == -1
				
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0020+MsDocPath()+"\"+ACB->ACB_OBJETO+"]" , 0, 0, {}) //"Impossivel deletar arquivo gerado no banco de conhecimento ["
				
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Delete o lixo que foi gravado na acb
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			oACB := PLSSTRUC():New( "ACB",MODEL_OPERATION_DELETE,,ACB->(Recno()))
			oACB:CRUD()   
			
			oACB:Destroy()                                               
			oAC9:Destroy()
		EndIf
	EndIf
Else 
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Deleta arquivo movido para pasta do banco de conhecimento
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If FErase(MsDocPath()+"\"+ACB->ACB_OBJETO) == -1

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0020+MsDocPath()+"\"+ACB->ACB_OBJETO+"]" , 0, 0, {}) //"Impossivel deletar arquivo gerado no banco de conhecimento ["
		
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Delete o lixo que foi gravado na acb
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oACB := PLSSTRUC():New( "ACB",MODEL_OPERATION_DELETE,,ACB->( Recno() ) )
	oACB:CRUD()
	oACB:Destroy()                
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Delete o lixo que foi gravado na acb
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oAC9 := PLSSTRUC():New( "AC9",MODEL_OPERATION_DELETE,,AC9->( Recno() ) )
	oAC9:CRUD()
	oAC9:Destroy()
EndIf	
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim do Rotina
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return

/*/ { Protheus.doc } ProcPart
Informa para o auditor que o procedimento И participativo, 
caso exista registro criado no folder participativo

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD ProcPart() Class PLSA790C 

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Objeto que verifica e retorna se existe alguma participativa criada no folder
//  participativa
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oB70 := PLSREGIC():New()
oB70:GetDadReg("B70",1, xFilial("B70") + B53->(B53_ALIMOV+B53_RECMOV),,,.T. )

If AllTrim(B53->B53_TIPO) == "2" // LiberaГЦo/ Lib. Odonto/ AurotizaГЦo SADT e Odonto. 

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se o procedimento que esta sendo auditado И participativo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If BE2->BE2_PARTIC == "1"
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Se existir registro na pasta participativa relacionado ao procedimento e
		//  ainda nЦo foi realizado a confirmaГЦo
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If oB70:lFound .AND. oB70:GetValue("B70_RELCON") == "0"
			MSGALERT(STR0027)
		EndIf
	EndIf

ElseIf AllTrim(B53->B53_TIPO) == "3" // InternaГЦo

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se o procedimento que esta sendo auditado И participativo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд	
	If BEJ->BEJ_PARTIC == "1"
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Se existir registro na pasta participativa relacionado ao procedimento e
		//  ainda nЦo foi realizado a confirmaГЦo
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If oB70:lFound .AND. oB70:GetValue("B70_RELCON") == "0"
			MSGALERT(STR0027)
		EndIf
	EndIf
	
ElseIf AllTrim(B53->B53_TIPO) == "5" // Reembolso

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se o procedimento que esta sendo auditado И participativo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд	
	If B45->B45_PARTIC == "1"
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Se existir registro na pasta participativa relacionado ao procedimento e
		//  ainda nЦo foi realizado a confirmaГЦo
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If oB70:lFound .AND. oB70:GetValue("B70_RELCON") == "0"
			MSGALERT(STR0027)
		EndIf
	EndIf
EndIf

Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLSA790C  Ё Autor Ё Totvs				    Ё Data Ё 30/03/10 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Somente para compilar a class							  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA790C
Return


/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLSA790C  Ё Autor Ё Totvs				    Ё Data Ё 30/03/10 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Somente para compilar a class							  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSADESV

lEvo := .F.

Return


/*/
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLSICB71 Ё Autor Ё Renan Martins	    Ё Data Ё 23.032015   ╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддаддддддддд╢╠╠╠
╠╠ЁDescricao Ё FunГЦo para incluir na B71 (encaminhamentos) o setor para  ╠╠╠
╠╠ qual a guia foi encaminhada  de forma automАtica, de acordo com o      ╠╠╠
╠╠ parБmetro MV_SETORAT						  		                         ╠╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
/*/
Function PLSICB71(cAlias, cRecNO, cDept,cObsMotPad,lSx3)
Local oB71 	:= NIL	
Local cSeq 	:= ""
Local aArea   := GetArea()
Local cSQL := "SELECT MAX(B71_SEQUEN) AS MAIOR FROM "+B71->(RetSQLName("B71"))+" WHERE "
	  cSQL += " B71_FILIAL = '"+xFilial("B71")+"' AND "
	  cSQL += " B71_ALIMOV = '"+cAlias+"' AND "
	  cSQL += " B71_RECMOV = '"+cRecNO+"' AND "
	  cSQL += " D_E_L_E_T_ = ' '"

PLSQuery(cSQL,"TrbB71")

Default lSx3  := .F.

If ! TrbB71->(Eof()) .AND. ! Empty(TrbB71->MAIOR)
	cseq := Soma1(TrbB71->MAIOR)
Else
	cseq := "001"
EndIf

TrbB71->(DbCloseArea())

RestArea( aArea )

If !lSx3	  

	oB71 := PLSSTRUC():New("B71",MODEL_OPERATION_INSERT,1)
	oB71:SetValue("B71_FILIAL", xFilial( "B71") )
	oB71:SetValue("B71_ALIMOV", cAlias )
	oB71:SetValue("B71_RECMOV", cRecNO )
	oB71:SetValue("B71_DATMOV", dDataBase )
	oB71:SetValue("B71_OPERAD", RETCODUSR() )
	oB71:SetValue("B71_CODDEP", cDept )
	oB71:SetValue("B71_SEQUEN", cSeq )
	ConfirmSX8()
	oB71:CRUD() 
	oB71:Destroy()
	cseq:=B71->B71_SEQUEN
	PLS71MM(cAlias,cRecNO,cseq, cObsMotPad) 
Else
	Return cseq
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PLS71MM
FunГЦo para incluir campo Memo rotinas Auditoria
@author Sigapls
@since 24/09/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLS71MM(cAlias,cRecNO,cseq,cResposta)
LOCAL aArea      := GetArea()  
 
B71->(DbSetOrder(1))
If  B71->(msSeek(xFilial("B71")+cAlias+cRecNO+cseq))
	B71->(RecLock("B71",.F.))
	B71->B71_OBS:=cResposta 
	B71->( MsUnLock() )	
Endif


RestArea( aArea )	
return()

/*/{Protheus.doc} RetAudito
Retorna se a guia esta em auditoria.
@author victor.silva
@since 17/10/2016
@return caracter, Status da guia
/*/
static function RetAudito(oSelf) 
local cAliGui	:= oSelf:cACab
local cAliEve	:= oSelf:cAIte
local cNumGuia	:= oSelf:cNumGuia
local cChave	:= ""
local cAudito	:= "0"
local aArea		:= {}
local oReg 		:= PLSREGIC():New()
local nIdx		:= 1

//Verifica se o alias esta preenchido
if Empty(cAliGui)
	return cAudito
endif

//Inicializa a chave
cChave	:= xFilial(cAliGui) + cNumGuia

//Salva area
aArea	:= (cAliGui)->(GetArea())

//Se o item nao estiver posicionado, procura no cabecalho da guia
if !lEvo

	//Se for internacao utiliza o indice 2
	if oSelf:lInternacao
		nIdx := 2
	endif
	
	oReg:GetDadReg(cAliGui,nIdx,cChave,,,.T.)

	//Retorna o valor
	if oReg:lFound
		cAudito := oReg:GetValue(cAliGui + "_AUDITO")
	endif

//Senao, pega direto do item
else

	//Salva area
	aArea	:= (cAliEve)->(GetArea())
	
	//Monta a estrutura do registro 
	oReg:GetDadReg(cAliEve,,,(cAliEve)->(RecNo()),,.T.)
	
	//Retorna o valor
	if oReg:lFound
		cAudito := oReg:GetValue(cAliEve + "_AUDITO")
	endif
	
endif

//Destroi o objeto
oReg:Destroy()

//Restaura a area
RestArea(aArea)

return cAudito

//
