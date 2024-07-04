#INCLUDE "JURA153.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA153
Inclusão de Lançamentos

@author André Spirigoni Pinto
@since 18/07/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA153(cAssJur, nOperacao, cFilBrw)
Private aGaran     := {}
Private cDefFiltro
Private oBrw153
Private lMarcar    := .F. 
Private cFiltBkp   := cDefFiltro
Private nOper
Private cFilialBrw := cFilBrw

Default cAssJur    := ''
Default nOperacao  := 3
Default cFilBrw    := xFilial("NT2")

nOper := nOperacao

If nOperacao == 3
	cDefFiltro := "NT2_MOVFIN == '1'"
ElseIf nOperacao == 5
	cDefFiltro := "NT2_MOVFIN == '2'"
Endif 

If !Empty(cAssJur) .And. IsInCallStack( 'JURA098' )   
  cDefFiltro := cDefFiltro + " .AND. NT2_FILIAL == '"+cFilBrw +"' .AND. NT2_CAJURI == '" + cAssJur + "' "
EndIf 

oBrw153 := FWMarkBrowse():New()

If nOperacao == 3
	oBrw153:SetDescription( STR0007 ) //"Garantias
ElseIf nOperacao == 5
	oBrw153:SetDescription( STR0015 ) //"Levantamentos"
Endif

oBrw153:SetAlias( 'NT2' )
oBrw153:SetMenuDef( "JURA153" ) // Redefine o menu a ser utilizado                   
oBrw153:SetLocate()

If nOperacao == 3
	JA153FInc(cAssJur, cFilBrw) //carrega os filtros adicionais da tela
ElseIf nOperacao == 5
	JA153FExc(cAssJur , cFilBrw) //carrega os filtros adicionais da tela
Endif

oBrw153:SetFieldMark( 'NT2_OK' )
oBrw153:bAllMark := { ||  JurMarkALL(oBrw153, "NT2", 'NT2_OK', lMarcar := !lMarcar ), oBrw153:Refresh()  }

JurSetBSize( oBrw153 )

oBrw153:Activate()
	
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author André Spirigoni Pinto
@since 18/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA153", 0, 2, 0, NIL } ) // "Visualizar"

If Type("nOper") == "N"

	If nOper == 3
		aAdd( aRotina, { STR0008, "Processa( { || JA153Inc() }, '" + STR0013 + "','" + STR0014 +"' ,.F.) " , 0, 6, 0, NIL } ) 	// "Confirmar"
	ElseIf nOper == 5
		aAdd( aRotina, { STR0005, "Processa( { || JA153Del() },'" + STR0013 + "','"+STR0016+"',.F.) " , 0, 6, 0, NIL } )		// "Excluir"
	Endif
	
Else
	
	aAdd( aRotina, { STR0008, "Processa( { || JA153Inc() }, '" + STR0013 + "','" + STR0014 +"' ,.F.) " , 0, 6, 0, NIL } ) // "Confirmar"
	aAdd( aRotina, { STR0005, "Processa( { || JA153Del() },'" + STR0013 + "','"+STR0016+"',.F.) " , 0, 6, 0, NIL } ) 	  // "Excluir"
EndIf

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Time Sheets dos Profissionais

@author André Spirigoni Pinto
@since 19/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA153" )
Local oStructNT2 := FWFormStruct( 2, "NT2" )


JurSetAgrp( 'NT2',, oStructNT2 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA153_NT2", oStructNT2, "NT2MASTER"  )
oView:CreateHorizontalBox( "NT2FIELDS", 100 )
oView:SetOwnerView( "JURA153_NT2", "NT2FIELDS" )

If ( IsInCallStack('JURA098') .AND. IsInCallStack('JURA162') )
	oView:SetDescription( STR0007 ) // "Garantias"
Else
	If nOperacao == 3
		oView:SetDescription( STR0007 ) // "Garantias"
	ElseIf nOperacao == 5
		oView:SetDescription( STR0015 ) // "Levantamentos"
	Endif
EndIf

oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Operações Lote Levantamento

@author André Spirigoni Pinto
@since 18/07/13
@version 1.0


/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNT2    := FWFormStruct( 1, "NT2" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA153", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NT2MASTER", NIL, oStructNT2, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Time Sheets dos Profissionais"
oModel:GetModel( "NT2MASTER" ):SetDescription( STR0009 ) // "Dados de Time Sheets dos Profissionais"
JurSetRules( oModel, "NT2MASTER",, "NT2",,  )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA153Inc
Rotina que realiza o levantamento automático das garantias selecionadas

@author André Spirigoni Pinto
@since 19/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA153Inc(  )
Local aArea      := GetArea()
Local cMarca     := oBrw153:Mark()
Local lInvert    := oBrw153:IsInvert()
Local cFiltro    := cDefFiltro
Local nQtdNT2    := 0
Local nCt        := 0
Local lErro      := .F.
Local lRet       := .T.
Local cFilialBrw := Xfilial("NT2")
Local aDadosFin  := {}
Local cAssJur    
Local cCod       := ""
Local cFilDest   := ""
Local lIntFinc   := (SuperGetMV('MV_JINTVAL',, '2') == '1')

If Empty(cFiltro)
	cFiltro += "(NT2_OK "+Iif(lInvert, "<>", "==" )+" '" + cMarca + "')" + " .AND. (NT2_FILIAL = '" + cFilialBrw + "')"
Else
	cFiltro += " .And. (NT2_OK "+Iif(lInvert, "<>", "==" )+" '" + cMarca + "')" + " .AND. (NT2_FILIAL = '" + cFilialBrw + "')"
EndIf    

cAux := &( '{|| ' + cFiltro + ' }')
NT2->(dbSetFilter( cAux, cFiltro ))
NT2->(dbSetOrder(1))

NT2->(dbgotop())
NT2->(dbEVal({||nQtdNT2++},, {||!EOF()} ))
If nQtdNT2 == 0
	JurMsgErro(STR0009) //"Não há dados marcados para execução em lote!"
	lRet := .F.
EndIF

If (lRet)

	ProcRegua( nQtdNT2 )

	NT2->(dbgotop())
	
	aStruct := NT2->( dbStruct() )
	
	If lIntFinc
		If !(NT2->(EOF()))
			aDadosFin := JURA221(NT2->NT2_FILDES)
			cFilDest  := NT2->NT2_FILDES
		EndIf
	Endif	
	
	While !(NT2->(EOF()))
		cAssJur := NT2->NT2_CAJURI
		cCod    := NT2->(RECNO())
			
		If lIntFinc .And. (cFilDest <> NT2->NT2_FILDES)
			aSize(aDadosFin,0)
			cFilDest  := NT2->NT2_FILDES				
			aDadosFin := JURA221(NT2->NT2_FILDES)
		EndIf
		
		If lIntFinc .And. Empty(aDadosFin)
			lErro := .T.
		ElseIf (J98SELLEI(cAssJur, NT2->NT2_COD, aDadosFin))
			NT2->(dbGoTo(cCod))
			nCt++
			RecLock("NT2",.F.)
			NT2->NT2_OK := " "
			MsUnlock()
			IncProc( STR0021 + AllTrim(str(nCt)) + STR0022 + AllTrim(str(nQtdNT2)) ) //"Gerando" / " de "
		Else
			lErro := .F.		
		Endif
		
		NT2->( dbSkip())                            
	
	EndDo
	
	If lErro
		JurMsgErro( STR0010 + AllTrim( Str( nCt ) ) + STR0011 ) //"Houve erro na geracao de um dos levantamentos. Foram gerados até o momento apenas "###" novos levantamentos."
	Else
		MsgAlert( STR0012 + AllTrim( Str( nCt ) ) + STR0011 ) //"Foram gerados "###" novos levantamentos."
		JURCORVLRS('NT2')
	EndIf
	
	cAux := &( "{|| "+cDefFiltro+" }")  //Retorna o Filtro padrão 
	NT2->( dbSetFilter( cAux, cDefFiltro ) )
	
	If !Empty(cAssJur)
		JA153FInc(cAssJur, cFilialBrw)
	Endif	

Endif	

RestArea( aArea )

aSize(aDadosFin,0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA153FInc (cAssJur )
Rotina que faz o filtro da tela, para evitar que sejam exibidas
garantias que já tenham levantamento vinculado.

@author André Spirigoni Pinto
@since 19/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA153FInc( cAssJur , cFilBrw )
Local aArea := GetArea()
Local cAlias   := GetNextAlias()
Local lRet := .T.

BeginSql Alias cAlias	    		 
  	SELECT NT2_COD
    	FROM %Table:NT2% NT2
    	   WHERE NT2.NT2_CAJURI  = %Exp:cAssJur%  	       
     		 AND NT2.NT2_FILIAL  = %Exp:cFilBrw%    
     		 AND NT2.NT2_MOVFIN = '1'
    		 AND NT2.%notDEL%
    		AND NOT EXISTS (
    			SELECT 1 FROM %Table:NT2% NT2B
    			WHERE
    			NT2B.NT2_CGARAN = NT2.NT2_COD 
    			AND NT2B.NT2_FILIAL  = %Exp:cFilBrw%    
     		  AND NT2B.NT2_MOVFIN = '2'
     		  AND NT2B.NT2_CAJURI = NT2.NT2_CAJURI
     		  AND NT2B.%notDEL%
     		)		  	
EndSql
dbSelectArea(cAlias)

aGaran := {}

While !(cAlias)->(Eof())
	aAdd(aGaran,(cAlias)->NT2_COD)
	(cAlias)->(DbSkip())
End

If len(aGaran) > 0
	oBrw153:SetFilterDefault(cDefFiltro + " .AND. VAL(NT2_MOVFIN)==1 " + " .AND. JurIn(NT2_COD,aGaran)" )
Else
	oBrw153:SetFilterDefault(cDefFiltro + " .AND. VAL(NT2_MOVFIN)==2 " )
Endif

(cAlias)->(dbCloseArea())			
RestArea(aArea)
		
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA153FExc (cAssJur )
Rotina que faz o filtro da tela, para evitar que sejam exibidas
garantias que já tenham levantamento vinculado.

@author André Spirigoni Pinto
@since 19/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA153FExc( cAssJur, cFilBrw )

Local lRet := .T.
//Não existe filro para os levantamentos. Todos serão exibidos, sem exceção.
oBrw153:SetFilterDefault(cDefFiltro)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA153Del
Rotina que realiza o levantamento automático das garantias selecionadas

@author André Spirigoni Pinto
@since 19/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA153Del(  )
Local aArea       := GetArea()
Local cMarca     := oBrw153:Mark()
Local lInvert    := oBrw153:IsInvert()
Local cFiltro    := cDefFiltro
Local nQtdNT2    := 0
Local nCt         := 0
Local lErro       := .F.
Local lRet        := .T.
Local cAssJur
Local cFilBrw

If Empty(cFiltro)
	cFiltro += "(NT2_OK "+Iif(lInvert, "<>", "==" )+" '" + cMarca + "')" + " .AND. (NT2_FILIAL = '" + cFilialBrw + "')"
Else
	cFiltro += " .And. (NT2_OK "+Iif(lInvert, "<>", "==" )+" '" + cMarca + "')" + " .AND. (NT2_FILIAL = '" + cFilialBrw + "')"
EndIf    

cAux := &( '{|| ' + cFiltro + ' }')
NT2->(dbSetFilter( cAux, cFiltro ))
NT2->(dbSetOrder(1))

NT2->(dbgotop())
NT2->(dbEVal({||nQtdNT2++},, {||!EOF()} ))
If nQtdNT2 == 0
	JurMsgErro(STR0009) //"Não há dados marcados para execução em lote!"
	lRet := .F.
EndIF

If lRet
	lRet := ApMsgYesNo(STR0020)
Endif

If (lRet)

	ProcRegua( nQtdNT2 )

	NT2->(dbgotop())
	
	aStruct := NT2->( dbStruct() )
	
	While !(NT2->(EOF()))
	
	cAssJur := NT2->NT2_CAJURI
	cFilBrw := NT2->NT2_FILIAL
	
	if (J98DELEV(cAssJur,NT2->NT2_COD, cFilBrw))
		nCt++
		IncProc( STR0023 + AllTrim(str(nCt)) + STR0022 + AllTrim(str(nQtdNT2)) ) //"Excluindo "/" de "
	Else
		lErro := .F.		
	Endif
	
	NT2->( dbSkip())                            
	EndDo	

	If lErro
		JurMsgErro( STR0019 + AllTrim( Str( nCt ) ) + STR0018 ) //"Houve erro na geracao de um dos levantamentos. Foram gerados até o momento apenas "###" novos levantamentos."
	Else
		MsgAlert( STR0017 + AllTrim( Str( nCt ) ) + STR0018 ) //"Foram gerados "###" levantamentos."
	EndIf
	
	JA153FExc(cAssJur , cFilBrw)

Endif	

RestArea( aArea )

Return lRet