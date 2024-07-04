#INCLUDE "JURA101.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"      
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA101_MVC
Tela de consulta MVC

@author Clóvis Eduardo Teixeira
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
Function JURA101(cCForne, cLForne, cCodNota, nVlrNota, cTipo)
Local oMdlAtual := FWModelActive()   

CHKFile('NSU')

Private c101CForne := cCForne
Private c101LForne := cLForne     
Private c101CodNot := cCodNota
Private n101VlrNot := nVlrNota 
Private c101Tipo   := cTipo
Private c101CClien := ''
Private c101LClien := ''
Private c101NumCas := ''
Private c101NumPro := ''      
Private aJ101Desd  := {}

FWExecView(STR0001,"JURA101", 4,, { || .T. },,20 )	                 
FWModelActive(oMdlAtual)

Return aJ101Desd
                       
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados Desdobramento de Notas Correspondente
@author Clovis E. Teixeira dos Santos
@since 12/05/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados  

Local oStrFiltro := FWFormStruct(1, 'NSZ',{|x| ALLTRIM(x) $ 'NSZ_CCLIEN, NSZ_LCLIEN, NSZ_NUMCAS, NSZ_NUMPRO' } )
Local oStrDesdob := FWFormStruct(1, 'NU6',{|x| ALLTRIM(x) $ 'NU6_NUMCAS, NU6_VALOR, NU6_CCLIEN, NU6_LCLIEN, NU6_NUMPRO, NU6_CAJURI, NU6_CCONTR, NU6_CTCONT, NU6_DTCONT, NU6_INIVGN, NU6_FIMVGN'} )
Local oModel    

oStrDesdob:AddField( ;
""                             , ;               // [01] Titulo do campo
"Check"                        , ;               // [02] ToolTip do campo
"NSZ__TICK"                    , ;               // [03] Id do Field
"L"                            , ;               // [04] Tipo do campo
1                              , ;               // [05] Tamanho do campo
0					           , ;               // [06] Decimal do campo
{ |oMdl| JA101AtuVlr(oMdl), .T. } , ; 			 // [07] Code-block de validação do campo
, ;                                              // [08] Code-block de validação When do campo
, ;                                              // [09] Lista de valores permitido do campo
.F.                            )                 // [10] Indica se o campo tem preenchimento obrigatório   ]
              
oStrFiltro:AddField( ;
"Filtrar"                      , ;               // [01] Titulo do campo
"Carregar"                     , ;               // [02] ToolTip do campo
'BOTAO'                        , ;               // [03] Id do Field
'BT'                           , ;               // [04] Tipo do campo
1                              , ;               // [05] Tamanho do campo
0                              , ;               // [06] Decimal do campo
{ |oMdl| JA101Filtro(oMdl), .T. } )              // [07] Code-block de validação do campo                                                                    

oStrFiltro:AddField( ;
STR0011                        , ;               // [01] Titulo do campo
STR0011                        , ;               // [02] ToolTip do campo
"NSZ__TOTAL"                   , ;               // [03] Id do Field
"N"                            , ;               // [04] Tipo do campo
16                             , ;               // [05] Tamanho do campo
2					           , ;               // [06] Decimal do campo
, ;   											 // [07] Code-block de validação do campo
{||.F.}, ;                                       // [08] Code-block de validação When do campo
, ;                                              // [09] Lista de valores permitido do campo
.F.                              )               // [10] Indica se o campo tem preenchimento obrigatório   

oModel := MPFormModel():New('JURA101' , ,{ | oMdl | JURA101TOk(oMdl) } /*Pos-Validacao*/, { | oMdl | .T. },/*Cancel*/)     

oModel:AddFields('NSZMASTER', NIL, oStrFiltro)
oModel:AddGrid(  'NU6DETAIL', 'NSZMASTER', oStrDesdob,,,,,{|oGrid| LoadNU6( oGrid ) } )   

oModel:SetDescription(STR0002)

oModel:GetModel( 'NSZMASTER' ):SetDescription( STR0003 )
oModel:GetModel( 'NU6DETAIL' ):SetDescription( STR0004 )    
oModel:GetModel( 'NU6DETAIL' ):SetNoInsertLine( .T. )   
oModel:GetModel( 'NU6DETAIL' ):SetNoDeleteLine( .T. )

oStrFiltro:SetProperty('NSZ_CCLIEN', MODEL_FIELD_OBRIGAT,.F.) 
oStrFiltro:SetProperty('NSZ_LCLIEN', MODEL_FIELD_OBRIGAT,.F.)
oStrFiltro:SetProperty('NSZ_NUMCAS', MODEL_FIELD_OBRIGAT,.F.)
oStrFiltro:SetProperty('NSZ_NUMPRO', MODEL_FIELD_OBRIGAT,.F.)   

oModel:SetPrimaryKey( {} )   

oModel:SetActivate( { |o| teste(o) , JA101AtuVlr(o)} )      

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Desdobramento da nota
@author Clovis E. Teixeira dos Santos
@since 15/05/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStrFiltro := FWFormStruct(2, 'NSZ', { |x| ALLTRIM(x) $ 'NSZ_CCLIEN, NSZ_LCLIEN, NSZ_NUMCAS, NSZ_NUMPRO' } )
Local oStrDesdob := FWFormStruct(2, 'NU6', { |x| ALLTRIM(x) $ 'NU6_NUMCAS, NU6_VALOR, NU6_CCLIEN, NU6_LCLIEN, NU6_NUMPRO, NU6_CAJURI, NU6_CCONTR, NU6_CTCONT, NU6_DTCONT, NU6_INIVGN, NU6_FIMVGN' } )
Local oModel     := FWLoadModel( 'JURA101' )
Local oView 
Local aAux       := {}
Local bIntPad    :=  FWBuildFeature( 3 , "{|xCont| xCont := '' }")// STRUCT_FEATURE_INIPAD => Inicializador Padrão em branco, não será SX3,


aAux := oStrDesdob:GetFields()
aEval( aAux, { |ax| aX[MVC_VIEW_ORDEM] := Soma1( aX[MVC_VIEW_ORDEM] ) } ) 

oStrDesdob:AddField( ;
"NSZ__TICK"      , ;             // [01] Campo
'01'             , ;             // [02] Ordem
''               , ;             // [03] Titulo
''               , ;             // [04] Descricao
, ;                              // [05] Help
'CHECK'          , ;             // [06] Tipo do campo   COMBO, Get ou CHECK
''               , ;             // [07] Picture
                 , ;             // [08] PictVar
''               )               // [09] F3
                       
oStrFiltro:AddField( ;
'BOTAO'          , ;             // [01] Campo
"XX"             , ;             // [02] Ordem
"Filtrar "       , ;             // [03] Titulo
"Carregar"       , ;             // [04] Descricao
NIL              , ;             // [05] Help
'BT'             )               // [06] Tipo do campo   COMBO, Get ou CHECK

oStrFiltro:AddField( ;
"NSZ__TOTAL"    , ;             // [01] Campo
'ZZ'            , ;             // [02] Ordem
STR0011         , ;             // [03] Titulo
STR0011         , ;             // [04] Descricao
, ;                             // [05] Help
'GET'          , ;             // [06] Tipo do campo   COMBO, Get ou CHECK
'@E 9,999,999,999,999.99', ;   // [07] Picture
	           , ;             // [08] PictVar
''               )             // [09] F3

oStrFiltro:SetNoFolder()

oView := FWFormView():New()
oView:SetModel( oModel )       

oView:AddField( 'VIEW_PROC' , oStrFiltro, 'NSZMASTER' )
oView:AddGrid(  'VIEW_DESD' , oStrDesdob, 'NU6DETAIL' )

oView:CreateHorizontalBox( "BOX1",  30 )
oView:CreateHorizontalBox( "BOX2",  70 )

oView:SetOwnerView( 'VIEW_PROC' , "BOX1" )
oView:SetOwnerView( 'VIEW_DESD' , "BOX2" ) 

oView:EnableTitleView('VIEW_PROC',STR0003)
oView:EnableTitleView('VIEW_DESD',STR0004) 

oStrFiltro:SetProperty('NSZ_CCLIEN', MVC_VIEW_LOOKUP,'SA1')	//X3_F3 = SA1
//oStrFiltro:SetProperty('NSZ_NUMPRO', MVC_VIEW_CANCHANGE,.T.)

//oStrFiltro:SetProperty('NSZ_LCLIEN', MODEL_FIELD_VALID,'')	//Retira o Valid de todos os campos da NSZ para uso na tela de Desdobramento
//oStrFiltro:SetProperty('NSZ_LCLIEN', MODEL_FIELD_INIT , '')

If c101Tipo == 'D'
	oStrDesdob:SetProperty('NU6_VALOR' , MVC_VIEW_CANCHANGE,.T.)
Endif	

oView:AddUserButton( STR0010,"CTBREPLA", { | oMdl | JA101ALL(oMdl) } ) //#Marca/Desmarca todos

Return oView   

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadNU6(oGrid)
Cria um array com todos contratos vinculados a nota do correspondente
@param 	oModel  	Model a ser verificado
@Return Nil
@author Clóvis Eduardo Teixeira
@since 13/05/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadNU6(oGrid)
Local aCampos   := oGrid:GetStruct():GetFields()   
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()
Local aRet      := {}
Local aAux			:= {}
Local nI        := 0

cQuery := JA101Query()
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery) , cAliasQry, .T., .F.)    

dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())

While !(cAliasQry)->( EOF())
	
	For nI := 1 To Len( aCampos )
		If aCampos[nI][MVC_MODEL_IDFIELD]  == "NSZ__TICK"
			aAdd( aAux, .T. )
		Else
			If aCampos[nI][MVC_MODEL_IDFIELD]  == "NU6_INIVGN" .Or.	aCampos[nI][MVC_MODEL_IDFIELD]  == "NU6_FIMVGN"				
				TcSetField( cAliasQry, aCampos[nI][MVC_MODEL_IDFIELD], 'D', TamSX3(aCampos[nI][MVC_MODEL_IDFIELD])[1], 0)								
			EndIf
			
			aAdd( aAux, (cAliasQry)->(FieldGet(FieldPos(aCampos[nI][MVC_MODEL_IDFIELD] ))))
		EndIf
	Next  

	aAdd( aRet, { 0, aAux })
	aAux := {}
	(cAliasQry)->( dbSkip())
End

(cAliasQry)->( dbCloseArea())
//cAliasQry := GetNextAlias()
RestArea( aArea )

Return aRet  
            
//-------------------------------------------------------------------
/*/{Protheus.doc} JA132Desd(cInstancia)
Rotina que realiza o desdobramento da nota pelos processos ligados
ao correspondente
@param 	oModel  	Model a ser verificado
@Return lRet
@author Clóvis Eduardo Teixeira
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA101Filtro(oMdl)    
Local oModel := FWModelActive()
Local oGrid  := oModel:GetModel("NU6DETAIL")
Local oView  := FWViewActive()
Local lRet   := .T.

c101CClien := FwFldGet('NSZ_CCLIEN')
c101LClien := FwFldGet('NSZ_LCLIEN')
c101NumCas := FwFldGet('NSZ_NUMCAS')
c101NumPro := FwFldGet('NSZ_NUMPRO')

oGrid:DeActivate(.T.)
oGrid:Activate()

JA101AtuVlr(oMdl)

oView:DeActivate(.T.)
oView:Activate()

Return lRet   

//-------------------------------------------------------------------
/*/{Protheus.doc} JA101Query(cCliente, cLojaCli, cNumCaso, cNumProc)            
Montagem da query de localização dos desdobramentos
Uso no cadastro de Correspondente.
@param cCliente  Campo de código do cliente
@param cLojaCli	 Campo de loja do cliente 
@param cNumCaso  Campo de Numero do caso
@param cNumPro   Campo de Numero do processo
@Return cQuery	 	Query montada
@author Clóvis Eduardo Teixeira
@since 13/05/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA101Query()
Local aArea			 := GetArea()
Local cToday     := dTos(Date())
Local cNullDt    := ''
Local cQuery     := ""

cQuery :=	"SELECT NSZ.NSZ_NUMCAS NU6_NUMCAS, NSZ.NSZ_CCLIEN NU6_CCLIEN, "
cQuery += "   		NSZ.NSZ_LCLIEN NU6_LCLIEN, NUQ.NUQ_NUMPRO NU6_NUMPRO, NSU_CAJURI NU6_CAJURI, NSU.NSU_COD NU6_CCONTR, "
cQuery += "   		NSU.NSU_CTCONT NU6_CTCONT, NSQ.NSQ_DESC NU6_DTCONT, NSU.NSU_INIVGN NU6_INIVGN, NSU.NSU_FIMVGN NU6_FIMVGN, "

If c101Tipo == 'H'
	cQuery += "NSU.NSU_VALOR NU6_VALOR"
Else
	cQuery += "0 NU6_VALOR"
Endif

cQuery += "	 FROM "+RetSqlName("NSU")+" NSU, "
cQuery += "			  "+RetSqlName("NUQ")+" NUQ, "
cQuery += " 		  "+RetSqlName("NSQ")+" NSQ, "
cQuery += "			  "+RetSqlName("NSZ")+" NSZ  "
cQuery += " WHERE NUQ.NUQ_CAJURI  = NSU.NSU_CAJURI "
cQuery += "   AND NSU.NSU_CTCONT  = NSQ.NSQ_COD    "
cQuery += "   AND NUQ.NUQ_CAJURI  = NSZ.NSZ_COD    "
cQuery += "   AND NSU.NSU_CAJURI  = NSZ.NSZ_COD	 	 "
cQuery += " 	AND NUQ.NUQ_INSTAN  = NSU.NSU_INSTAN "
cQuery += "	  AND NUQ.NUQ_CCORRE  = NSU.NSU_CFORNE "
cQuery += "	  AND NUQ.NUQ_LCORRE  = NSU.NSU_LFORNE "
cQuery += "	  AND NSU.NSU_CFORNE  = '"+c101CForne+"'"
cQuery += "	  AND NSU.NSU_LFORNE  = '"+c101LForne+"'"
cQuery += "   AND (NSU.NSU_FIMVGN > '"+cToday+"'  OR NSU.NSU_FIMVGN = '"+cNullDt+"' OR NSU.NSU_DCAREN > '"+cToday+"') "
cQuery += "	  AND NSU.NSU_FILIAL  = '"+xFilial("NSU")+"'"
cQuery += "	  AND NUQ.NUQ_FILIAL  = '"+xFilial("NUQ")+"'"
cQuery += "	  AND NSQ.NSQ_FILIAL  = '"+xFilial("NSQ")+"'"
cQuery += "	  AND NSZ.NSZ_FILIAL  = '"+xFilial("NSZ")+"'"
cQuery += "	  AND NSU.NSU_DESAUT  = '1' "
cQuery += "   AND NSU.D_E_L_E_T_  = ' ' "
cQuery += "   AND NUQ.D_E_L_E_T_  = ' ' "
cQuery += "   AND NSQ.D_E_L_E_T_  = ' ' "
cQuery += "   AND NSZ.D_E_L_E_T_  = ' ' "

if !Empty(c101NumPro)
	cQuery += " AND NUQ.NUQ_NUMPRO = '"+c101NumPro+"'"
Endif

If !Empty(c101CClien) //.And. !Empty(c101LClien)
	cQuery += " AND NSZ.NSZ_CCLIEN = '"+c101CClien+"'"
EndIf
If !Empty(c101LClien)
	cQuery += " AND NSZ.NSZ_LCLIEN = '"+c101LClien+"'"
Endif

If !Empty(c101NumCas)
	cQuery += " AND NSZ.NSZ_NUMCAS = '"+c101NumCas+"'"
Endif

  cQuery += " ORDER BY NSZ.NSZ_NUMCAS "

RestArea( aArea )

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA101TOk(oModel)
Valida informações ao salvar

@param 	oModel Model a ser verificado
@Return lRet	 .T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 17/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA101TOk(oModel)
Local oMdlGrid  := oModel:GetModel( "NU6DETAIL")
Local nTtlDesb  := 0
Local lRet      := .T.
Local nI        := 1
Local aDesd     := {}

For nI := 1 To oMdlGrid:GetQtdLine()
	
	If !oMdlGrid:IsDeleted(nI) .And. !oMdlGrid:IsEmpty(nI) .And. oMdlGrid:GetValue('NSZ__TICK', nI)
		aAdd(aDesd,{ oMdlGrid:GetValue('NU6_CAJURI', nI ), oMdlGrid:GetValue('NU6_VALOR', nI ), ;
					 oMdlGrid:GetValue('NU6_CCONTR', nI ), oMdlGrid:GetValue('NU6_CTCONT', nI),;
					 oMdlGrid:GetValue('NU6_INIVGN', nI ), oMdlGrid:GetValue('NU6_FIMVGN', nI) })
		nTtlDesb += oMdlGrid:GetValue('NU6_VALOR', nI )
	EndIf
	
Next

If  Len(aDesd) > 0
	
	If nTtlDesb > n101VlrNot
		
		If SuperGetMV( 'MV_JGEDBMA',,.T.)
			If !ApMsgYesNo(STR0005+CRLF+STR0006) //O valor total dos desdobramentos selecionadas supera o valor da nota. Deseja continuar assim mesmo?
				JurMsgErro('Operação Cancelada')
				lRet := .F.
			EndIf
		Else
			JurMsgErro(STR0005+CRLF+STR0007) //O valor total dos desdobramentos selecionadas supera o valor da nota. Corrigir!
			lRet := .F.
		EndIf
		
	Elseif nTtlDesb < n101VlrNot
		
		If SuperGetMV( 'MV_JGEDBME',,.T.)
			If !ApMsgYesNo(STR0008+CRLF+STR0006) //O valor total das despesas selecionadas é inferior ao valor da nota. Deseja continuar assim mesmo?
				JurMsgErro('Operação Cancelada')
				lRet := .F.
			EndIf
		Else
			JurMsgErro(STR0008+CRLF+STR0007) //O valor total das despesas selecionadas é inferior ao valor da nota. Corrigir!
			lRet := .F.
		EndIf
		
	Endif
	
Else
	JurMsgErro(STR0009) //Selecione ao menos um contrato para realizar o desdobramento!
	lRet := .F.
Endif

If lRet .AND. ExistBlock('JA101DDM') .AND. C101TIPO == 'H'
   lRet := ExecBlock('JA101DDM',.F.,.F.,{aDesd})
EndIf


If lRet
	aJ101Desd := aClone(aDesd)
Endif                                                            

Return lRet
  
//-------------------------------------------------------------------
/*/{Protheus.doc} Teste(oModel)
Função para setar valor no model para que tenha algum dado alterado.

@param 	oModel Model a ser verificado
@author Clóvis Eduardo Teixeira
@since 17/05/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function teste(oModel)

oModel:SetValue( 'NSZMASTER', 'NSZ_NUMPRO', '0' )
oModel:SetValue( 'NSZMASTER', 'NSZ_NUMPRO', '' )


Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MrkUnk( oFoco, aBase, nCol, lAll )
Função para marcar todos os registros

@param 	oModel Model a ser verificado
@Return lRet	 .T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 17/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MrkUnk( oFoco, aBase, nCol, lAll )                                                
Default lAll 	:= .F.
Default nCol 	:= 1
Default aBase := {}

if Valtype( oFoco ) == "O"
	aeval( aBase, { | _x | _x[ nCol ] := ! _x[ nCol ] }, if( lAll, 1, oFoco:nAt ), if( lAll, len( aBase ), 1 ) )
	oFoco:Refresh()
endif

Return .T.  

//-------------------------------------------------------------------
/*/{Protheus.doc} JA101ALL()
Marca e Desmarca Todas as linhas

@author Tiago Martins	
@since 07/03/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA101ALL(oModel)
Local	aArea     := GetArea()
Local	oMdlGrid  := oModel:GetModel( "NU6DETAIL")
Local	nCheck    := 0 //Controle se coloca ou tira o Check
Local	nI        := 0
Local	nLine     := oMdlGrid:nLine
Local	nQtdNU6   := oMdlGrid:GetQtdLine()

//Verifico se há algum Checado
For nI := 1 To nQtdNU6
	oMdlGrid:GoLine(nI)
	If !oMdlGrid:IsDeleted() .And. !oMdlGrid:IsEmpty() .And. FwFldGet('NSZ__TICK')
		nCheck++
	EndIf
Next

If nCheck == nQtdNU6
	For nI := 1 To nQtdNU6
		oMdlGrid:GoLine(nI)
		If !oMdlGrid:IsDeleted()
			oMdlGrid:LoadValue('NSZ__TICK', .F.)
		EndIf
	Next
Else
	For nI := 1 To nQtdNU6
		oMdlGrid:GoLine(nI)
		If !oMdlGrid:IsDeleted()
			oMdlGrid:LoadValue('NSZ__TICK', .T.)
		EndIf
	Next
EndIf     

JA101AtuVlr(oModel)

RestArea(aArea)
oMdlGrid:GoLine(nLine)
oModel:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA101AtuVlr
Verifica os desdobramentos selecionados, para totalizar o valor dos 
contratos

@author Juliana Iwayama Velho
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA101AtuVlr(oMdl)
Local oModel    := FWModelActive()   
Local aArea     := GetArea()
Local oMdlGrid  := oModel:GetModel( "NU6DETAIL")
Local oMdlMaster:= oModel:GetModel( "NSZMASTER")
Local nLine     := oMdlGrid:nLine
Local nQtdNU6   := oMdlGrid:GetQtdLine()
Local nI        := 0
Local nTotal    := 0

If !oMdlGrid:IsEmpty() 

	For nI := 1 To nQtdNU6
		If !oMdlGrid:IsDeleted(nI) .And. oMdlGrid:GetValue('NSZ__TICK', nI)
			nTotal := nTotal + oMdlGrid:GetValue('NU6_VALOR', nI)
		EndIf
	Next nI

EndIf

If nTotal >= 0
	If oMdlMaster <> Nil
		oMdlMaster:LoadValue('NSZ__TOTAL',nTotal)
	Else
		oMdl:LoadValue('NSZMASTER','NSZ__TOTAL',nTotal)
	EndIf
EndIf

RestArea(aArea)
oMdlGrid:GoLine(nLine)

Return .T.
