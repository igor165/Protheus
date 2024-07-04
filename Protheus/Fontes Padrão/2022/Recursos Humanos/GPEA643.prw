#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GPEA643.CH' 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GPEA643
	Constrói o browse para as operações relacionadas com a gestão da disciplina

@sample		GPEA643(Nil)
	
@since		12/02/2014 
@version 	P12

@param		cFilDef, Caracter, filtro padrão a ser inserido na exibição do browse

/*/
//--------------------------------------------------------------------------------------------------------------------
Function GPEA643(cFilDef)

Local oBrw := FwMBrowse():New()

DEFAULT cFilDef := ''

oBrw:SetAlias( 'TIT' )
oBrw:SetMenudef( "GPEA643" )
oBrw:SetDescription( OEmToAnsi( STR0001 ) ) //"Gestão de Disciplina"

If !Empty(cFilDef)
	oBrw:SetFilterDefault(cFilDef)
EndIf

oBrw:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
	Rotina para construção do menu
@sample 	Menudef() 
@since		06/09/2013  
@version 	P11.90
/*/
//------------------------------------------------------------------------------
Static Function Menudef()

Local aMenu := FWMVCMenu("GPEA643")

Return aMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author arthur.colado

@since 12/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel

Local oStr1		:= FWFormStruct(1,'TIT') 
Local oStr2		:= FWFormStruct(1,'TIU') 
Local xAux	:= Nil


oModel := MPFormModel():New('GPEA643',,{ |oModel| gp643TudOk(oModel) },{|oModel|AT643GRV(oModel)})
oModel:SetDescription('GPEA643')

oStr1:RemoveField( 'TIT_USUARI' )
oStr1:RemoveField( 'TIT_FILIAL' )
If nModulo == 7 
	oStr1:SetProperty( 'TIT_CODABS', MODEL_FIELD_WHEN, .F.)
	oStr1:SetProperty( 'TIT_CODRES', MODEL_FIELD_WHEN, .F.)
	oStr1:SetProperty( "TIT_CODRES", MODEL_FIELD_OBRIGAT, .F. )
	oStr1:SetProperty( "TIT_CODTEC", MODEL_FIELD_OBRIGAT, .F. )
	oStr1:SetProperty( "TIT_NOMTEC", MODEL_FIELD_OBRIGAT, .F. )
	oStr1:SetProperty( "TIT_CODABS", MODEL_FIELD_OBRIGAT, .F. )
	oStr1:SetProperty( 'TIT_TURNO' , MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , "A643Turno()" ))
	xAux := FwStruTrigger( 'TIT_MAT', 'TIT_CODTEC', 'Posicione("AA1",7,xFilial("AA1")+FWfldGet("TIT_MAT")+xFilial("SRA"), "AA1_CODTEC")', .F. ) //AA1_FILIAL+AA1_CDFUNC+AA1_FUNFIL	
			oStr1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Else
	xAux := FwStruTrigger( 'TIT_CODTEC', 'TIT_MAT', 'Posicione("AA1",1,xfilial("AA1")+FWfldGet("TIT_CODTEC"),"AA1_CDFUNC")', .F. )
		oStr1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	oStr1:SetProperty('TIT_MAT', MODEL_FIELD_WHEN, { || .F.} )
EndIf

oModel:addFields('TIT',,oStr1)
oModel:SetPrimaryKey({ 'TIT_CODIGO' })


oStr2:RemoveField( 'TIU_CODTIT' )
oStr2:RemoveField( 'TIU_FILIAL' )


oModel:addGrid('TIU','TIT',oStr2)
oModel:SetRelation('TIU', { { 'TIU_FILIAL', 'xFilial("TIU")' }, { 'TIU_CODTIT', 'TIT_CODIGO' } }, TIU->(IndexKey(1)) )

oModel:getModel('TIT'):SetDescription(STR0001)	//Gestão de Disciplina
oModel:getModel('TIU'):SetDescription(STR0002)	//Processos Relacionados
oModel:GetModel( 'TIU' ):SetOptional( .T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author arthur.colado

@since 12/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef() 
Local oStr1:= FWFormStruct(2, 'TIT')
Local oStr2:= FWFormStruct(2, 'TIU')

oView := FWFormView():New()
oView:SetModel(oModel)

oStr1:RemoveField( 'TIT_OCORR' )
oStr1:RemoveField( 'TIT_USUARI' )
oStr2:RemoveField( 'TIU_CODTIT' )

//se não tiver integração com Gestao de serviços , suprimir alguns campos
If nModulo == 7 
	oStr1:RemoveField( 'TIT_CODTEC' )
	oStr1:RemoveField( 'TIT_NOMTEC' )
	oStr1:RemoveField( 'TIT_CODRES' )
	oStr1:RemoveField( 'TIT_CODABS' )
	oStr1:RemoveField( 'TIT_NOMRES' )
	oStr1:RemoveField( 'TIT_LOCAL'  )
	oStr1:RemoveField( 'TIT_REGIAO' )
	oStr1:RemoveField( 'TIT_RESPON' )
	oStr1:RemoveField( 'TIT_PLR' )
	
	oStr1:SetProperty('TIT_MAT', MVC_VIEW_ORDEM,'10')
	oStr1:SetProperty('TIT_NOMFUN', MVC_VIEW_ORDEM,'11')
	oStr1:SetProperty('TIT_MATRES', MVC_VIEW_ORDEM,'16')
	oStr1:SetProperty('TIT_NOMRSF', MVC_VIEW_ORDEM,'17')
		
	oStr2:SetProperty( 'TIU_RELACI', MVC_VIEW_COMBOBOX, {"3=B.O.","4=Processo"})
	oStr2:RemoveField( 'TIU_OCORR' )
	oStr2:RemoveField( 'TIU_INVEST' )
Else
	oStr1:RemoveField( 'TIT_MAT' )
	oStr1:RemoveField( 'TIT_NOMFUN' )
	oStr1:RemoveField( 'TIT_MATRES' )
	oStr1:RemoveField( 'TIT_NOMRSF' )
	oStr1:RemoveField( 'TIT_MAT' )
EndIf
If TIT->(ColumnPos('TIT_CODTIV')) > 0
	oStr1:RemoveField( 'TIT_CODTIV' )
Endif
oStr1:SetProperty('TIT_RCMSUS', MVC_VIEW_ORDEM,'19')

oView:AddField(STR0001 , oStr1,'TIT' )	//'Gestão de Disciplina
oView:AddGrid(STR0002 , oStr2,'TIU')	//Processos Relacionados

oView:CreateHorizontalBox( 'BOXFORM1', 66)
oView:CreateHorizontalBox( 'BOXFORM3', 34)
oView:SetOwnerView(STR0002,'BOXFORM3')	//Processos Relacionados
oView:SetOwnerView(STR0001,'BOXFORM1')	//'Gestão de Disciplina
oView:SetFieldAction( 'TIT_MAT', { |oView, cIDView, cField, xValue| At643ValDis(oView, cIDView, cField, xValue)} )
oView:SetFieldAction( 'TIT_CODTEC', { |oView, cIDView, cField, xValue| At643ValDis(oView, cIDView, cField, xValue)} )
oView:SetFieldAction( 'TIT_QTDDIA', { |oView, cIDView, cField, xValue| At643Falta()} )
oView:AddUserButton(STR0003, 'CLIPS',{|oView| AT643VisForm()}) //Imprimir Disciplina

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} At643ValDis()
Rotina valida o histórico de punições que funcionário ja recebeu


@author arthur.colado
@since 12/02/2014
@version 1.0
/*/
//------------------------------------------------------------------------------

Static Function At643ValDis(oView, cIDView, cField, xValue, cFunc)

Local cAliasTmp	:= GetNextAlias()
Local cTec	 	:= oView:oModel:getModel("TIT"):GetValue("TIT_CODTEC")
Local cFunc 	:= oView:oModel:GetModel("TIT"):GetValue("TIT_MAT")
Local cCodDis 	:= oView:oModel:getModel("TIT"):GetValue("TIT_CODTIQ")
Local dData 	:= oView:oModel:getModel("TIT"):GetValue("TIT_DATA")
Local cMensagem := ""
Local cDescri	:= ""
Local cWhere	:= "% %"
Local oModel	:= FWModelActive()

If !Empty(cFunc)
	cWhere := "% AND TIT_MAT = '"+cFunc+"'%"
Else
	cWhere := "% AND TIT_CODTEC = '"+cTec+"'%"
EndIf

If Empty(cCodDis) .OR. Empty(dData)
	cMensagem := STR0004		// "Os campos Disciplina e Data Disc. devem ser Preenchidos"
	Help(" ",1,"GPEA643",,I18N(cMensagem,{AllTrim(RetTitle(STR0001))}),1,0)	//"Disciplina" 
	At643VldMov()	
Else
	BeginSql alias cAliasTmp  		     
	    SELECT COUNT(TIT.TIT_CODTIQ) QTD, TIT.TIT_CODTIQ, TIT.TIT_CODTEC, TIQ.TIQ_DESCR
		FROM %table:TIT% TIT 
		INNER JOIN %table:TIQ% TIQ
		ON (TIQ.TIQ_FILIAL = TIT.TIT_FILIAL AND TIT.TIT_CODTIQ = TIQ.TIQ_CODIGO)
		WHERE  TIT.TIT_TIPO = '1'
		AND TIT.%notDel% 
		AND TIQ.%notDel%
		AND TIT.TIT_FILIAL = %xfilial:TIT% 
		%exp:cWhere% 
		GROUP BY TIT.TIT_CODTIQ, TIT.TIT_CODTEC, TIQ.TIQ_DESCR		
	EndSql
		
	DbSelectArea(cAliasTmp)
			
	While (cAliasTmp)->( !Eof() )					
		cDescri += AllTrim(( cAliasTmp )-> TIQ_DESCR) + STR0005 + cValtoChar(( cAliasTmp )-> QTD) + CRLF	// total de 
		( cAliasTmp )->(DbSkip())		
	EndDo
			
	(cAliasTmp)->( DbCloseArea() )	
	
	If !Empty(cDescri)
		cMensagem := STR0006+ CRLF + cDescri //"O funcionário possui histórico de:"
	Else
		cMensagem := STR0007 + CRLF //"Não existe Histórico Disciplinar para este Atendente"
	EndIf		

	At643AplDis(cMensagem, cTec, cCodDis, dData,cFunc)	
		
EndIf

oView:Refresh()

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At643AplDis()
Rotina verifica qual a disciplina que deve ser aplicada baseada na parametrização realizada no cadastro de Disciplina


@author arthur.colado
@since 12/02/2014
@version 1.0
/*/
//------------------------------------------------------------------------------

Static Function At643AplDis(cMensagem, cTec, cCodDis, dData,cFunc)

Local cAliasTmp	:= GetNextAlias()
Local cDescri	:= ""

BeginSql alias cAliasTmp  							
	SELECT TIR.TIR_QTD, TIQ2.TIQ_DESCR DSC, TIQ.TIQ_DESCR
	FROM %table:TIR% TIR  
	INNER JOIN %table:TIQ% TIQ
	ON (TIQ.TIQ_FILIAL = TIR.TIR_FILIAL AND TIQ.TIQ_CODIGO = TIR.TIR_SUGEST)
	INNER JOIN %table:TIQ% TIQ2
	ON (TIQ2.TIQ_FILIAL = TIR.TIR_FILIAL AND TIR.TIR_CODTIQ = TIQ2.TIQ_CODIGO)
	WHERE TIR.TIR_CODTIQ = %exp:cCodDis% 
	AND TIR.TIR_SUGERI = "1"
	AND TIR.TIR_FILIAL = %xfilial:TIR% 
	AND TIR.%notDel% 
	AND TIQ.%notDel%			
EndSql
	
DbSelectArea(cAliasTmp)
		
While (cAliasTmp)->( !Eof() )	
	cDescri += AllTrim(STR0008 + cValtoChar(( cAliasTmp )-> TIR_QTD) + STR0009 + ( cAliasTmp )-> DSC + STR0010 + ( cAliasTmp )-> TIQ_DESCR) + CRLF		//"Para "  " disciplinas do tipo "   " sugere-se aplicar " 
	( cAliasTmp )->(DbSkip())		
EndDo

(cAliasTmp)->( DbCloseArea() )	

If !Empty(cDescri)
	cMensagem += + CRLF + cDescri + CRLF		
	
EndIf

At643SugDis(cMensagem,cTec, cCodDis, dData, cFunc) 

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At643SugDis()
Rotina verifica qual seria a proxima disciplina a aplicar ao funcionário baseado no histórico e disciplina selecionada

@author arthur.colado
@since 12/02/2014
@version 1.0/*/
//------------------------------------------------------------------------------

Static Function At643SugDis(cMensagem, cTec, cCodDis, dData, cFunc)

Local cAliasTmp	:= GetNextAlias()
Local cAlias2	:= GetNextAlias()
Local cCodigo	:= ""
Local nTotal	:= 0
Local nConvert	:= 0
Local cDescri	:= ""
Local cTotal	:= ""
Local oModel	:= FWModelActive()
Local cWhere	:= "% %"

If !Empty(cFunc)
	cWhere := "% AND TIT.TIT_MAT = '"+cFunc+"'%"
Else
	cWhere := "% AND TIT.TIT_CODTEC = '"+cTec+"'%"
EndIf
BeginSql alias cAliasTmp 
	SELECT COUNT(TIT.TIT_CODTIQ) QTD, TIT.TIT_CODTIQ
	FROM %table:TIT% TIT 
	INNER JOIN %table:TIQ% TIQ
	ON (TIQ.TIQ_FILIAL = TIT.TIT_FILIAL AND TIT.TIT_CODTIQ = TIQ.TIQ_CODIGO)
	WHERE TIT.TIT_CODTIQ = %exp:cCodDis% 
	AND TIT.TIT_TIPO = '1'
	AND TIT.TIT_FILIAL = %xfilial:TIT% 
	AND TIT.%notDel% 
	AND TIQ.%notDel% 
	%exp:cWhere% 
	GROUP BY TIT.TIT_CODTIQ, TIT.TIT_CODTEC, TIQ.TIQ_DESCR			
EndSql
	
DbSelectArea(cAliasTmp)
		
While (cAliasTmp)->( !Eof() )					
	nTotal := ( cAliasTmp )-> QTD
	cCodigo:= ( cAliasTmp )-> TIT_CODTIQ
								
	( cAliasTmp )->(DbSkip())		
End
(cAliasTmp)->( DbCloseArea() )	
		
If Empty(nTotal)
	cCodigo := cCodDis
	nConvert := Val(cTotal)
Else
	nConvert := Val(cTotal) + 1
EndIf
				
BeginSql alias cAlias2 //valida baseado no histórico consultado acima qual a disciplina deve aplicada  							
	SELECT TIQ.TIQ_DESCR,TIR.TIR_PONTO, TIR.TIR_PPERDA  
	FROM %table:TIR% TIR  
	INNER JOIN %table:TIQ% TIQ
	ON (TIQ.TIQ_FILIAL = TIR.TIR_FILIAL AND TIQ.TIQ_CODIGO = TIR.TIR_SUGEST)
	WHERE TIR.TIR_CODTIQ = %Exp:cCodigo%
	AND TIR.TIR_QTD =  %Exp:nConvert%
	AND TIR.TIR_FILIAL = %xfilial:TIR% 
	AND TIR.%notDel% 
	AND TIQ.%notDel%
EndSql
		
DbSelectArea(cAlias2)
	
While (cAlias2)->( !Eof() )	
	cDescri := ( cAlias2 )-> TIQ_DESCR
	oModel:SetValue("TIT","TIT_PONTOS", ( cAlias2 )-> TIR_PONTO)
	oModel:SetValue("TIT","TIT_PLR", ( cAlias2 )-> TIR_PPERDA)
	( cAlias2 )->(DbSkip())				
EndDo


(cAlias2)->( DbCloseArea() )	

If !Empty(cDescri)
	cMensagem += STR0011 + cDescri + CRLF //"Para a Disciplina Selecionada está parametrizado a aplicação de"
Else
	cMensagem += STR0012 + CRLF//"Não existe critério parametrizado para a disciplia selecionada"
EndIf
	
At643RhPrazos(cTec, cMensagem, cCodDis, dData,cFunc )			

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At643RhPrazos()
Rotina valida os prazos do funcionários como os períodos de experiencia, demitido e em dia de trabalho

@author arthur.colado
@since 12/02/2014
@version 1.0
/*/
//------------------------------------------------------------------------------

Static Function At643RhPrazos(cTec, cMensagem, cCodDis, dData,cFunc)

Local cAliasTmp	:= GetNextAlias()
Local dDiscipl	:= dData
Local lFlag		:= .T.
Local dDemissao	
Local dExper1
Local dExper2
Local cSeq		:= ""
Local lDiaTra	:= .T.
Local cTurno    := ''
If Empty(cFunc)
	BeginSql alias cAliasTmp 
		COLUMN RA_DEMISSA AS DATE
		COLUMN RA_VCTOEXP AS DATE
		COLUMN RA_VCTEXP2 AS DATE
				 							
		SELECT SRA.RA_DEMISSA,SRA.RA_VCTOEXP, SRA.RA_VCTEXP2, SRA.RA_TNOTRAB, RA_SEQTURN  
		FROM %table:AA1% AA1
		INNER JOIN %table:SRA% SRA
		ON (AA1.AA1_FILIAL = SRA.RA_FILIAL AND AA1.AA1_CDFUNC = SRA.RA_MAT)
		WHERE AA1.AA1_CODTEC = %exp:cFunc%
		AND AA1.AA1_FILIAL = %xfilial:AA1% 
		AND AA1.%notDel% 
		AND SRA.%notDel% 		
	EndSql
Else
	BeginSql alias cAliasTmp 
		COLUMN RA_DEMISSA AS DATE
		COLUMN RA_VCTOEXP AS DATE
		COLUMN RA_VCTEXP2 AS DATE
				 							
		SELECT SRA.RA_DEMISSA,SRA.RA_VCTOEXP, SRA.RA_VCTEXP2, SRA.RA_TNOTRAB, RA_SEQTURN  
		FROM %table:SRA% SRA
		WHERE SRA.RA_MAT = %exp:cFunc%
		AND SRA.RA_FILIAL = %xfilial:SRA% 
		AND SRA.%notDel% 		
	EndSql
EndIf	
DbSelectArea(cAliasTmp)
		
While (cAliasTmp)->( !Eof() )					
	dDemissao := ( cAliasTmp )-> RA_DEMISSA
	dExper1	:= ( cAliasTmp )-> RA_VCTOEXP
	dExper2	:= ( cAliasTmp )-> RA_VCTEXP2
	cTurno := ( cAliasTmp )-> RA_TNOTRAB
	cSeq := ( cAliasTmp )-> RA_SEQTURN
											
	( cAliasTmp )->(DbSkip())		
End
		
(cAliasTmp)->( DbCloseArea() )			
	
If !Empty(dDemissao)
	cMensagem := STR0013 + DToC(dDemissao) + CRLF + CRLF + cMensagem	//"O funcionário foi demitido em"
	lFlag := .F.
							
ElseIf !Empty(dExper1) .OR. !Empty(dExper2)
			
	If dDiscipl <= dExper1
		cMensagem := STR0014 +  DToC(dExper1) + CRLF + CRLF + cMensagem	//"O funcionário está em Período da Primeira Experiencia "
							
	ElseIf dDiscipl <= dExper2
		cMensagem := STR0015 + DToC(dExper2)+ CRLF + CRLF + cMensagem	//"O funcionário está em Período da Segunda Experiencia"	
	
	EndIf	
				
Else
	cMensagem := STR0016 + CRLF + CRLF + cMensagem 	// "Funcionário está ativo e não consta período de Experiência"
				
EndIf
			
lDiaTra := TxDiaTrab(dDiscipl, cTurno, cSeq)	
		
If lDiaTra

	If lFlag
		cMensagem := STR0017 + CRLF + CRLF + cMensagem	 //"Funcionário está em dia de Trabalho para a Data informada "
	
	EndIf
Else
	cMensagem := STR0018 + CRLF + CRLF + cMensagem 	//"Funcionário não está em dia de Trabalho para a Data informada "
		
EndIf
		
At643Processo(cTec, cMensagem, cCodDis, dData,cFunc)

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At643Processo()
Rotina verifica se funcionários possui investigação com processo jurídico vinculado

@author arthur.colado
@since 12/02/2014
@version 1.0
/*/
//------------------------------------------------------------------------------

Static Function At643Processo(cTec, cMensagem, cCodDis, dData,cFunc)

Local cAliasTmp	:= GetNextAlias()
Local cDescri	:= ""
Local cWhere	:= "% %"

If !Empty(cFunc)
	cWhere := "% AND TIT.TIT_MAT = '"+cFunc+"'%"
Else
	cWhere := "% AND TIT.TIT_CODTEC = '"+cTec+"'%"
EndIf
BeginSql alias cAliasTmp 			
	SELECT TIU.TIU_DESCRI
	FROM %table:TIT% TIT
	INNER JOIN %table:TIU% TIU
	ON (TIU.TIU_FILIAL = TIT.TIT_FILIAL AND TIT.TIT_CODIGO = TIU.TIU_CODTIT)
	Where TIU.TIU_RELACI = '4'
	AND TIT.TIT_FILIAL = %xfilial:TIT% 
	AND TIT.%notDel% 
	AND TIU.%notDel% 
	%exp:cWhere%
EndSql
	
DbSelectArea(cAliasTmp)
		
While (cAliasTmp)->( !Eof() )					
	cDescri := ( cAliasTmp )-> TIU_DESCRI
									
	( cAliasTmp )->(DbSkip())		
End
		
(cAliasTmp)->( DbCloseArea() )			
	
If !Empty(cDescri)
	cMensagem := CRLF + STR0019 + cDescri + CRLF + CRLF + cMensagem  	// "O funcionário possui Processo Jurídico Aberto: "
								
Else
	cMensagem := CRLF + STR0020 + CRLF + CRLF + cMensagem    //"Não Consta processo Jurídico Aberto "	
			
EndIf	
	
If !IsBlind()	
	Aviso(STR0021 , cMensagem,{STR0022},3)		//"Atenção"  "OK"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
EndIf

Return .T.

//-----------------------------------------------------------------------------
/*/{Protheus.doc} AT643Falta
Atribuição de falta baseado nos parametros código do atendente, data, quantidade de dias

@param   	AT643Falta	
@owner   	arthur.colado
@author 	arthur.colado
@version 	V119
@since   	09/10/2013 
/*/
//-----------------------------------------------------------------------------

Function AT643Falta(lRotina, dInicio, cCodTec, nQtdeDias, dFinal)

Local cAliasTmp	:= GetNextAlias()
Local aArea		:= GetArea()
Local cFunc		:= ""
Local dDtIni	:= Ctod("")
Local nDias		:= 0
Local nConta	:= 1
Local dDtFim	:= CToD("")
Local cQryABB   := ""
Local aQry540   := {}
Local cAliasABB := ""	
Local lConfirm  := .F.
Local cAlerta	:= ""
Local cCodAuse  := FwFldGet("TIT_RCMSUS") 
Local cDtIniAux := Ctod("")
Local cTpAusen 	:= "1"

Default lRotina 	:= .T.
Default dInicio 	:= Ctod("")
Default cCodTec 	:= ""
Default nQtdeDias 	:= 0
Default dFinal 		:= Ctod("")

If lRotina
	cFunc	:= FwFldGet("TIT_CODTEC")
	dDtIni	:= FwFldGet("TIT_DATA")
	nDias	:= FwFldGet("TIT_QTDDIA")
Else
	dDtIni  := dInicio
	cFunc	:= cCodTec
	nDias 	:= nQtdeDias
EndIf

If !Empty(cFunc) .AND. !Empty(dDtIni) .AND. !Empty(nDias)


	BeginSql alias cAliasTmp 					
		SELECT ABB.ABB_CODTEC, ABB.ABB_DTINI, ABB.ABB_DTFIM
		FROM %table:ABB% ABB
		Where ABB.ABB_CODTEC =  %exp:cFunc%
		AND ABB.ABB_DTINI >= %exp:dDtIni% 
		AND ABB.%notDel% 
		AND ABB.ABB_FILIAL = %xfilial:ABB% 
		GROUP BY ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_CODTEC 
	EndSql
	
	DbSelectArea(cAliasTmp)
	
	If !Empty(cCodAuse)
		DbSelectArea("RCM")
		RCM->(DbSetOrder(1))
		If RCM->(dbseek(xFilial("RCM")+cCodAuse))
			cTpAusen := RCM->RCM_TIPODI
		EndIf
	EndIf	

	cDtIniAux := dDtIni

	If  cTpAusen == "1"
		While ( cAliasTmp )->( !Eof() )				
		
			If nConta <= nDias	
				dDtFim := ( cAliasTmp )-> ABB_DTFIM 

				dDtFim := SToD(dDtFim)

				nConta++

			EndIf	

			( cAliasTmp )->(DbSkip())	

		EndDo

	ElseIf cTpAusen == "2"
			
		While nConta <= nDias

			If nConta > 1 
				dDtFim := DaySum(cDtIniAux, 1) 

				cDtIniAux := dDtFim

			Else 

				dDtFim := cDtIniAux

			EndIf	

			nConta++
		EndDo		
	
	EndIf
	
	(cAliasTmp)->( DbCloseArea() )
	
	If nConta == nDias
		cAlerta := STR0023    //"Funcionário não tem Agenda para atender a Punição de Afastamento no período desejado"
			
	Else
		If Empty(dDtFim)
			cAlerta := STR0023 	//"Funcionário não tem Agenda para atender a Punição de Afastamento no período desejado"
		Else
			
			If lRotina
				aQry540 := AT540ABBQry( cFunc, "", dDtIni, dDtFim, Nil , Nil, "", .T., ""  )
								
				If Len(aQry540) > 0
					cQryABB := aQry540[1]
					cAliasABB := GetNextAlias()
				
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryABB),cAliasABB)
					
					AT550StAls(cAliasABB)//Add Alias para o model
															
					lConfirm := ( AT550ExecView( cAliasABB, MODEL_OPERATION_INSERT, /*aAgendas*/ ) == 0 )
					
					If lConfirm
						cAlerta := STR0024 + DToC(dDtIni)+ STR0025 + DToC(dDtFim)	//"Afastamento Aplicado no Período Desejado de: "  " Até: "
					Else
						cAlerta := STR0026 	//"Não Foi Aplicado o Afastamento"
					EndIf						
				EndIf
			Else
				dInicio := dDtIni
				dFinal := dDtFim
			EndIf
		EndIf
		RestArea(aArea)		
	
	EndIf
Else
	cAlerta := STR0027 	//"Preencher os campos Obrigatórios"
EndIf

If lRotina	
	Help(" ",1,"GPEA643",,I18N(cAlerta,{AllTrim(RetTitle(STR0028))}),1,0)	//"Disciplina"
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At643VldMov()
Rotina apaga todos os dados da consulta padrão caso for alterado o critério de pesquisa do campo TIT_TIPO


@author arthur.colado
@since 12/02/2014
@version 1.0
/*/
//------------------------------------------------------------------------------

Function At643VldMov()
Local oModel	:= FWModelActive()

If 	FwFldGet("TIT_TIPO") == "1" .Or. FwFldGet("TIT_TIPO") == "2"
	
	//Limpa o codigo quando for alterado
	If !Empty(FwFldGet("TIT_CODTIQ"))
		oModel:LoadValue("TIT","TIT_CODTIQ", "")
		oModel:LoadValue("TIT","TIT_DISCIP", "")
	EndIf
	
	If !Empty(FwFldGet("TIT_CODTIS"))	
		oModel:LoadValue("TIT","TIT_CODTIS", "")
		oModel:LoadValue("TIT","TIT_MOTIVO", "")
	EndIf
	
EndIf

If Empty(FwFldGet("TIT_CODTIS")) .OR. Empty(FwFldGet("TIT_DATA"))
	oModel:LoadValue("TIT","TIT_CODTEC", "")
	oModel:LoadValue("TIT","TIT_MAT", "")
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT643Form()
Rotina cria o formulário da Disciplina aplicada que será impresso para o Atendente assinar

@author Luiz.Jesus
@since 12/03/2014
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function AT643Form(lMostra)

	Local oWF      		//Objeto TWFProcess
	Local cArqHtm		:=  STR0030	//"modelo.html"
	Local cPath			:= "\samples\documents\disciplina\disciplinas\"
	Local cPathModel	:= "\samples\documents\disciplina\"
 	Local cPathNoBar	:= "\samples\documents\disciplina\disciplinas" 
	Local cFileHTML		:= xFilial("TIT") + "_" + FwFldGet("TIT_CODIGO") + ".htm"
	Local cAfasta		:= FwFldGet("TIT_AFASTA")
	Local lRet			:= .T.
	Local lVis			:= .F.
	Local cArq			:= ""
	Local nTamArq		:= 1
	Local lIntGS		:= fIntRHGS()
	
	DEFAULT lMostra := .T.
	
	// VERIFICA A EXISTÊNCIA DO DIRETÓRIO, CASO NÃO ENCONTRE, CRIA.
	If !File(cPathNoBar)
		FWMakeDir(cPath)
	Endif

	//VALIDA A EXISTÊNCIA DO MODELO DO FORMULÁRIO DA DISCIPLINA.
	If !File(cPathModel + cArqHtm)
		
		While nTamArq < Len(cPathModel + cArqHtm)
			cArq += SubStr( cArqHtm , nTamArq , 49) + " "
	 		nTamArq += 49
		End
		
		Help( " " , 1 , "TECA643ARQ" , , OEmToAnsi(STR0043) + CRLF +  SPACE(1) + cPathModel + Alltrim(cArq) + CRLF + OEmToAnsi(STR0040) , 1 , 0 ) //cPathWF + cArqHtm + não encontrado no servidor. O arquivo é necessário para geração do formulário da disciplina.
		lRet := .F.
	EndIf
	
	If lRet

		// Inicializa a classe TWFProcess 
		oWF := TWFHTML():New(cPathModel + cArqHtm)  		
		
		// Preenche as variaveis no HTML do corpo do formulário
		oWF:ValByName("dData", FwFldGet("TIT_DATA"))                                                                                           

		If (Empty(FwFldGet("TIT_CODTEC"))) .OR. (nModulo == 7 .AND. !lIntGS)
			oWF:ValByName("cNome"	, FwFldGet("TIT_NOMFUN"))  
			oWF:ValByName("cMat"	, FwFldGet("TIT_MAT"))                                                                               
			oWF:ValByName("cPosto"	, "")                                                                                        
			oWF:ValByName("cArea"	, "")               
		Else
			oWF:ValByName("cNome"	, FwFldGet("TIT_NOMTEC"))  
			oWF:ValByName("cMat"	, FwFldGet("TIT_CODTEC"))                                                                               
			oWF:ValByName("cPosto"	, FwFldGet("TIT_CODABS") + " - " + FwFldGet("TIT_LOCAL"))                                                                                        
			oWF:ValByName("cArea"	, FwFldGet("TIT_REGIAO"))               
		EndIf

		oWF:ValByName("cTurno", FwFldGet("TIT_TURNO")) 
		 
		If  cAfasta == "1" 
		    oWF:ValByName("cRef", FwFldGet("TIT_DISCIP") + ": " + cValToChar(FwFldGet("TIT_QTDDIA")) + STR0032)      //"PUNIÇÃO DISCIPLINAR FORMAL: "     	" Dia(s)"
		Else
			oWF:ValByName("cRef", FwFldGet("TIT_DISCIP"))  	//"PUNIÇÃO DISCIPLINAR FORMAL: "
		EndIf                            
		
		oWF:ValByName("cTiqText1", FwFldGet("TIT_TEXTO1"))                                           
		oWF:ValByName("cTitDsc", FwFldGet("TIT_MOTIVO") + ": " + FwFldGet("TIT_DESCRI"))                      
		oWF:ValByName("cTiqText2", FwFldGet("TIT_TEXTO2"))

		//SALVA EM DIRETÓRIO LOCAL TEMPORÁRIO
		oWF:SaveFile(cPath + cFileHTML)	
		
		If lMostra				
			AT643VisForm()
		EndIf
	EndIf

Return (lRet)

/*/{Protheus.doc} AT643VisForm()
Rotina visualiza o formulário criado da Disciplina aplicada que será impresso para o Atendente assinar
@author Luiz.Jesus
@since 12/03/2014
@version 1.0
/*/
Function AT643VisForm()
	
	Local oDlg
	Local oWebChannel
	Local oWebEngine
	Local aSize			:=    {}
	Local aOpc			:= {STR0045, STR0046, STR0047} // "Visualizar no Navegador" ## "Visualizar no Sistema" ## "Cancelar"
	Local cPathLoc		:= GetTempPath(.T.)
	Local cFile			:= xFilial("TIT") + "_" + FwFldGet("TIT_CODIGO") + ".htm"
	Local cPath			:= "\samples\documents\disciplina\disciplinas\"+ cFile 
	Local cLogo			:= "\samples\documents\disciplina\disciplinas\logo.jpg"
	Local lConnected	:= .T.
	Local nPort			:= 00000
	Local nOpc			:= 1
	Local lRet			:= .T.
	
	If IsInCallStack("AT440Form")
		If GetRPORelease() <= "12.1.017"
			aDel( aOpc, 2) 	// Faz a exclusão da segunda opção, pois as versões anteriores não suportam o componente
			aSize( aOpc, 2) // redimensiona o array, para não ficar lacuna em branco
		EndIf
		nOpc := Aviso(STR0021, STR0044, aOpc, 2) //"Atenção" ## "Como deseja visualizar o arquivo gerado?"
	EndIf
	
	// CASO O ARQUIVO NÃO TENHA SIDO GERADO TENTA GERAR NOVAMENTE.	
	If nOpc <> Len(aOpc)
		If !File(cPath)
			lRet := AT643Form(.F.)
		EndIf
		
		If lRet
			
			// COPIA O ARQUIVO DO SERVIDOR PARA UMA PASTA LOCAL
			CPYS2T(cPath, cPathLoc)
			
			// COPIA O ARQUIVO DE LOGO DO SERVIDOR PARA UMA PASTA LOCAL
			CPYS2T(cLogo, cPathLoc)
			
			If nOpc == 1
				ShellExecute( 'Open', cPathLoc + cFile, "", "", 2 )
			ElseIf nOpc == 2
				oWebChannel := TWebChannel():New()
				nPort       := oWebChannel:connect() // Efetua conexão e retorna a porta do WebSocket
				lConnected  := oWebChannel:lConnected
				
				If lConnected
					
					aSize := FWGetDialogSize( oMainWnd )
					
					DEFINE MSDIALOG oDlg TITLE STR0036 FROM aSize[1], aSize[2] TO aSize[3], aSize[4] PIXEL 	//"Punição"
					
					oWebEngine := TWebEngine():New(oDlg, 0, 0, 100, 100,, nPort)
					oWebEngine:navigate(cPathLoc+cFile)
					oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
					
					ACTIVATE DIALOG oDlg CENTERED 
					FreeObj(oWebEngine)
					FreeObj(oWebChannel)
				Else
					AtShowLog(STR0048 + CRLF + cPathLoc + cFile,"AT440VisForm",,,,.F.) //"Erro na conexão do WebSocket, porta não encontrada, arquivo gerado. Para visualizar entre no caminho: "
					FreeObj(oWebChannel)
				EndIf
			EndIf
		Else
			Help( '', 1, "AT440VisForm", , STR0049, 1, 0) //"Arquivo não gerado. "
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AT643GRV
Grava e Cria o Formulário Disciplinar

@author arthur.colado
@since 04/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AT643GRV(oModel)

	Local lRet 			:= .T.
	Local oTIT			:= oModel:GetModel("TIT")
	Local nOperation	:= oModel:GetOperation()
	Local lIntGS		:= fIntRHGS()
	Local oModelAfa
	Local oSR8
	Local cFilBkp		:= cFilAnt
	
	Begin transaction
		If nOperation == MODEL_OPERATION_UPDATE .And. TIT->TIT_AFASTA == '1' .And. oTIT:GetValue("TIT_AFASTA") == "2"
			cChave := TIT->TIT_FILIAL + TIT->TIT_MAT
			If lRet := DelAfast(cChave)
				//se mudou a matricula tem que procurar afastamento nos dois funcionarios
				If  xFilial("SRA")+oTIT:GetValue("TIT_MAT") <> cChave
					lRet :=  DelAfast(xFilial("SRA")+oTIT:GetValue("TIT_MAT"))
				EndIf
			EndIf
		EndIf
		
		If oTIT:GetValue("TIT_AFASTA") == "1" .And. (nModulo == 7 .Or. lIntGS)
		
			Private aPerAtual := {} //variavel usada no gpea240
			Private aAutoCab	:= {}//variavel usada no gpea240
			Private aAutoItens	:= {}//variavel usada no gpea240
			Private cProcesso	:= ""//variavel usada no gpea240
			Private nColPro	 	:= 2//variavel usada no gpea240
			Private aSR8Respal  := {}//variavel usada no gpea240
			
			SRA->(DbSetOrder(1))
			If nOperation == MODEL_OPERATION_DELETE .Or. nOperation == MODEL_OPERATION_UPDATE
				cChave := TIT->TIT_FILIAL + TIT->TIT_MAT
				If lRet := DelAfast(cChave)
					//se mudou a matricula tem que procurar afastamento nos dois funcionarios
					If  xFilial("SRA")+oTIT:GetValue("TIT_MAT") <> cChave
						lRet :=  DelAfast(xFilial("SRA")+oTIT:GetValue("TIT_MAT"))
					EndIf
				EndIf
			EndIf
		
			If lRet .And. nOperation != MODEL_OPERATION_DELETE
				SRA->(dbSeek(xFilial("SRA")+oTIT:GetValue("TIT_MAT")))
				dbSelectArea("SR8")
				oModelAfa	:= FWLoadModel('GPEA240')
				oModelAfa:SetOperation( 4 )
				oModelAfa:Activate()
				
				oSR8 := oModelAfa:GetModel("GPEA240_SR8")
				If oSR8:Length() > 1 .Or. (oSR8:Length() ==  1 .And. !Empty(oSR8:GetValue("R8_TIPOAFA")) ) 
					oSR8:AddLine()
				EndIf
				
				oSR8:SetValue('R8_TIPOAFA',oTIT:GetValue("TIT_RCMSUS"))
				oSR8:SetValue('R8_DATAINI',oTIT:GetValue("TIT_DATA"))
				oSR8:SetValue('R8_DURACAO',oTIT:GetValue("TIT_QTDDIA"))
				If !IsBlind()
					lRet := FWExecView("Afastamento",'GPEA240', 4, , { || .T. },,,,,,,oModelAfa) == 0
				Else
					If oModelAfa:VldData()
					   	oModelAfa:CommitData()
					Else
						lRet := .F.
						Help( ,, 'HELP',, oModelAfa:GetErrorMessage()[6], 1, 0)	    
					EndIf
				EndIf
				
				oModelAfa:deActivate()
				
				If !lRet
					DisarmTransaction()
					Help( ,, 'HELP',,STR0041 , 1, 0) //"Afastamento não foi salvo, operação não será completada."
				EndIf
			EndIf
		EndIf
		
		If lRet
			cFilAnt := cFilBkp
			oModel:Activate()
			If !IsBlind() .And. nOperation != MODEL_OPERATION_DELETE
				MsgRun(STR0037 ,STR0038  ,{ || lRet := AT643Form() })		//"Criando Formulário...." ,"Aguarde"
			EndIf
			FwFormCommit(oModel)
		EndIf
	End Transaction

Return lRet


Static Function DelAfast(cChave)
Local lRet := .T.
Local oModelAfa	
Local oSR8

If SRA->(dbSeek(cChave))
	oModelAfa	:= FWLoadModel('GPEA240')
	oModelAfa:SetOperation( 4 )
	oModelAfa:Activate()
	oSR8 := oModelAfa:GetModel("GPEA240_SR8")
	
	//checar se existe afastamento para essa data do mesmo tipo e apagar
	If oSR8:SeekLine({{"R8_TIPOAFA",TIT->TIT_RCMSUS},{"R8_DATAINI",TIT->TIT_DATA} })
		oSR8:DeleteLine()
		If oModelAfa:VldData()
		   	oModelAfa:CommitData()
		Else
			lRet := .F.
			Help( ,, 'HELP',, oModelAfa:GetErrorMessage()[6], 1, 0) //		    
		EndIf
	EndIf
	oModelAfa:Deactivate()
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} gp643TudOk
Tudo OK
@author flavio.scalzaretto
@since 04/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function gp643TudOk(oModel)
Local oStrTIT	:= oModel:GetModel("TIT")
Local lRetorna	:= .T.

If oStrTIT:GetValue("TIT_AFASTA") == "1" .And. ( Empty(oStrTIT:GetValue("TIT_RCMSUS")) .Or. Empty(oStrTIT:GetValue("TIT_QTDDIA")) )
	lRetorna := .F.				
	Help( ,, 'HELP',,STR0042 , 1, 0) //		    	"Campos Tp. Ausência e Qtd. Dias obrigatórios"
EndIf		
			
Return( lRetorna )

//-------------------------------------------------------------------
/*/{Protheus.doc} A643Turno
Inicializador padrao turno

@author flavio.scalzaretto
@since 04/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function A643Turno()
Local cDescPD	:= ""
Local oModel    := FWModelActive()
Local nOperation:= oModel:GetOperation()

If nOperation <> MODEL_OPERATION_INSERT
	cDescPd :=POSICIONE("SRA", 1, XFILIAL("SRA")+TIT->TIT_MAT, "RA_TNOTRAB")                                                 
EndIf

Return cDescPd

//-----------------------------------------------------------------------------
/*/{Protheus.doc} At643RFlt
Componentização da rotina At643Falta

@param   	lRotina - Chamada na rotina TECA643
@param   	dInicio - Data Inicio
@param   	cCodTec - Codigo Técnico
@param   	nQtdeDias - Dias afastamento
@retun 		dFinal	 - Retorno de Data Final de Afastamento
@owner   	fabiana.silva
@author 	fabiana.silva
@version 	V119
@since   	13/03/2019
/*/
//-----------------------------------------------------------------------------
Function At643RFlt(lRotina, dInicio, cCodTec, nQtdeDias)
Local dDtFinal  := Ctod("")
Local dFinal 	:= Ctod("")

Default lRotina :=  .T.
Default dInicio := Ctod("")
Default cCodTec := ""
Default nQtdeDias := 0

At643Falta(lRotina, dInicio, cCodTec, nQtdeDias, @dFinal)
dDtFinal := dFinal

Return dDtFinal
