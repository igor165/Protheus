#INCLUDE "TMSAR05.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
Static lTmsRdpU  := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho

//===========================================================================================================
/* Redespachante X Documentos
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		24/09/2013
@return	
//===========================================================================================================
*/
Function TMSAR05()

Local oMBrowse	:= Nil
Local aSetKey		:= {}
    
AAdd(aSetKey, { VK_F12 , { || Pergunte("TMSAR05",.T.) } } )

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Private aRotina := MenuDef()

If ExistBlock("TMR05MNU")
	aRotinaNew := ExecBlock("TMR05MNU",.F.,.F.,aRotina)
	If (ValType(aRotinaNew) == "A")
		aRotina := aClone(aRotinaNew)
	EndIf
EndIf

//===========================================================================================================
// Funcao de BROWSE
//===========================================================================================================
oMBrowse:= FwMBrowse():New()
oMBrowse:SetAlias( "DFT" )
oMBrowse:SetDescription( STR0001 )

ADD LEGEND DATA 'DFT->DFT_STATUS=="1"' COLOR "GREEN"  TITLE STR0016 OF oMBrowse //"Redespacho em aberto"
ADD LEGEND DATA 'DFT->DFT_STATUS=="2"' COLOR "RED" 	  TITLE STR0017 OF oMBrowse //"Redespacho indicado para entrega"
ADD LEGEND DATA 'DFT->DFT_STATUS=="3"' COLOR "BLUE"   TITLE STR0018 OF oMBrowse //"Redespacho encerrado"
ADD LEGEND DATA 'DFT->DFT_STATUS=="9"' COLOR "BLACK"  TITLE STR0019 OF oMBrowse //"Redespacho cancelado"
                                                             
oMBrowse:SetCacheView( .F. )
oMBrowse:Activate()

TmsKeyOff(aSetKey)

Return

//===========================================================================================================
/* Retorna o modelo de Dados 
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		24/09/2013
@return 	oModel - Modelo de Dados */                                                                                                         
//===========================================================================================================
Static Function ModelDef()

Local oModel := Nil
Local oStruCDFT := FwFormStruct( 1, 'DFT') 
Local oStruGDFV := FwFormStruct( 1, 'DFV')
Local oStruGDJO := Iif(lTmsRdpU,FwFormStruct( 1, 'DJO'),Nil)
Local lCmpDFV   := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0
                                              
oModel := MpFormModel():New( 'TMSAR05', /*bPreValidacao*/ , { |oMdl| TMSAR05TOk( oModel ) } /*bPosValid*/, { |oMdl| TMSAR05Grv( oModel ) } /*bCommit*/, /*bCancel*/ )  
oModel:SetDescription( STR0002 )

oModel:AddFields( 'MdFieldDFT', Nil, oStruCDFT )

oStruCDFT:SetProperty( "DFT_CODFOR"  , MODEL_FIELD_KEY ,.T.)
oStruCDFT:SetProperty( "DFT_LOJFOR"  , MODEL_FIELD_KEY ,.T.)
oStruCDFT:SetProperty( "DFT_TIPTRA"  , MODEL_FIELD_KEY ,.T.)
Iif(lCmpDFV, oStruCDFT:SetProperty("DFT_FILORI"  , MODEL_FIELD_INIT ,{|| cFilAnt}), )
Iif(lCmpDFV, oStruGDFV:SetProperty("DFV_FILORI"  , MODEL_FIELD_INIT ,{|| cFilAnt}), )

oModel:AddGrid( 'MdGridDFV', 'MdFieldDFT', oStruGDFV, { | oMdlGrid | PreVldDFV(oModel) },{ |oMdlGrid| TMSAR05LOk(oModel) },  /*bPreVal*/,/*bPosValid*/,  /*BLoad*/   )
If lTmsRdpU 
	oModel:AddGrid( 'MdGridDJO', 'MdGridDFV', oStruGDJO, /*bLinePre*/ , /*bLnPostDJO*/, /*bPre*/, /*bPost*/,  /*bLoad*/) 
EndIf	
If lCmpDFV .And. lTmsRdpU
	oModel:SetRelation( 'MdGridDFV', { {'DFV_FILIAL','xFilial("DFV")'},{'DFV_FILORI','DFT_FILORI'},{'DFV_NUMRED','DFT_NUMRED'}, {'DFV_CODFOR','DFT_CODFOR'},{'DFV_LOJFOR','DFT_LOJFOR'}},  DFV->( IndexKey(4) ) )
Else	
	oModel:SetRelation( 'MdGridDFV', { {'DFV_FILIAL','xFilial("DFV")'},{'DFV_NUMRED','DFT_NUMRED'}, {'DFV_CODFOR','DFT_CODFOR'},{'DFV_LOJFOR','DFT_LOJFOR'}},  DFV->( IndexKey(1) ) )
EndIf

If lTmsRdpU
	oModel:SetRelation( 'MdGridDJO', { {'DJO_FILIAL','xFilial("DJO")'},{'DJO_FILORI','DFT_FILORI'},{'DJO_NUMRED','DFT_NUMRED'},{'DJO_FILDOC','DFV_FILDOC'},;
    	                               {'DJO_DOC','DFV_DOC'},{'DJO_SERIE','DFV_SERIE'}},  DJO->( IndexKey(1) ) )
    	                               
	oModel:GetModel( 'MdGridDJO' ):SetUniqueLine( { 'DJO_CODFOR' , 'DJO_LOJFOR' } )
	oModel:SetOptional( 'MdGridDJO', .T. )
EndIf

oModel:GetModel( 'MdGridDFV' ):SetUniqueLine( { 'DFV_FILDOC' , 'DFV_DOC' , 'DFV_SERIE' } )
               
oModel:AddCalc( 'MdTotal_DFV', 'MdFieldDFT', 'MdGridDFV', 'DFV_QTDVOL', 'Volumes'	 , 'SUM') //Volume
oModel:AddCalc( 'MdTotal_DFV', 'MdFieldDFT', 'MdGridDFV', 'DFV_PESO'  , 'Peso Real'	 , 'SUM') //Peso Real
oModel:AddCalc( 'MdTotal_DFV', 'MdFieldDFT', 'MdGridDFV', 'DFV_PESOM3', 'Peso Cubado', 'SUM') // Peso Cubado
oModel:AddCalc( 'MdTotal_DFV', 'MdFieldDFT', 'MdGridDFV', 'DFV_VALMER', 'Vlr.Merc.'  , 'SUM') //Vlr.Merc.
oModel:AddCalc( 'MdTotal_DFV', 'MdFieldDFT', 'MdGridDFV', 'DFV_QTDVOL', 'Qtd.Doc.'   , 'COUNT', { | oMld | oModel:GetValue('MdGridDFV','DFV_QTDVOL') > 0 } ) //Qtd.Doc 
If lCmpDFV
	oModel:SetPrimaryKey({"DFV_FILIAL","DFV_FILORI","DFV_NUMRED","DFV_CODFOR","DFV_LOJFOR"})
Else
	oModel:SetPrimaryKey({"DFV_FILIAL","DFV_NUMRED","DFV_CODFOR","DFV_LOJFOR"})
EndIf

oModel:SetVldActive( { |oModel| VldActMdl( oModel ) } )
 
Return( oModel ) 

//===========================================================================================================
/* Retorna a View (tela) da rotina 
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		25/09/2013
@return 	aRotina - Array com as opçoes de Menu */                                                                                                          
//===========================================================================================================
Static Function ViewDef()

Local oView     := Nil
Local oModel    := FwLoadModel( 'TMSAR05' )
Local oStruCDFT := FwFormStruct( 2, 'DFT')
Local oStruGDFV := FwFormStruct( 2, 'DFV')
Local oStruGDJO := Iif(lTmsRdpU,FwFormStruct( 2, 'DJO'),Nil)
Local oTotal    := Nil
Local lTMSGFE   := SuperGetMV( 'MV_TMSGFE',, .F. )
Local lCmpDFV   := DFV->(ColumnPos("DFV_FILORI")) > 0 
                     
oStruCDFT:RemoveField("DFT_QTDDOC") 
oStruGDFV:RemoveField("DFV_CODFOR")
oStruGDFV:RemoveField("DFV_LOJFOR")
oStruGDFV:RemoveField("DFV_NUMRED")
// Estes campos serao apresentados apenas no browse
oStruCDFT:RemoveField("DFT_DATGER") // Data geracao
oStruCDFT:RemoveField("DFT_HORGER") // Hora geracao

If !lTMSGFE 
	oStruGDFV:RemoveField('DFV_CDTPOP')
	oStruGDFV:RemoveField('DFV_CDCLFR')	
	oStruGDFV:RemoveField('DFV_UFORI')     
	oStruGDFV:RemoveField('DFV_CDMUNO')     
	oStruGDFV:RemoveField('DFV_MUNORI') 
	oStruGDFV:RemoveField('DFV_UFDES')     
	oStruGDFV:RemoveField('DFV_CDMUND')     
	oStruGDFV:RemoveField('DFV_MUNDES')         	
	oStruGDFV:RemoveField('DFV_CHVEXT')         
EndIf

// Nao apresenta os campos quando o parametro MV_TMSRDPU estiver inativo
If !lTmsRdpU .And. !lCmpDFV
	oStruCDFT:RemoveField("DFT_UFORI")  // UF origem
	oStruCDFT:RemoveField("DFT_UFDES")  // UF destino
	oStruCDFT:RemoveField("DFT_CDMUNO") // Municipio origem
	oStruCDFT:RemoveField("DFT_MUNORI") // Desc. municipio origem
	oStruCDFT:RemoveField("DFT_CDMUND") // Municipio destino
	oStruCDFT:RemoveField("DFT_MUNDES") // Desc. municipio destino
	oStruCDFT:RemoveField("DFT_TIPVEI") // Tipo veiculo
	oStruCDFT:RemoveField("DFT_DESTIP") // Desc. tipo veiculo
	oStruCDFT:RemoveField("DFT_CDTPOP") // Tipo operacao
	oStruCDFT:RemoveField("DFT_DSTPOP") // Desc. tipo operacao
	oStruCDFT:RemoveField("DFT_CDCLFR") // Classificacao frete
	oStruCDFT:RemoveField("DFT_DSCLFR") // Desc. classificacao frete
	oStruCDFT:RemoveField("DFT_CEPORI") // CEP origem
	oStruCDFT:RemoveField("DFT_CEPDES") // CEP destino
	oStruGDFV:RemoveField("DFV_CEPORI") // CEP origem
	oStruGDFV:RemoveField("DFV_CEPDES") // CEP destino
EndIf

If lTmsRdpU
	oStruGDJO:RemoveField('DJO_FILORI')
	oStruGDJO:RemoveField('DJO_NUMRED')
	oStruGDJO:RemoveField('DJO_FILDOC')
	oStruGDJO:RemoveField('DJO_DOC')
	oStruGDJO:RemoveField('DJO_SERIE')
EndIf
oView := FwFormView():New()
oView:SetModel( oModel )

oTotal := FWCalcStruct( oModel:GetModel ('MdTotal_DFV') )

If lTmsRdpU
	oView:CreateHorizontalBox( 'Field', 030 )
	oView:CreateHorizontalBox( 'Grid1', 040 )
	oView:CreateHorizontalBox( 'Grid2', 020 )
	oView:CreateHorizontalBox( 'Grid3', 010 )
Else	
	oView:CreateHorizontalBox( 'Field', 030 )
	oView:CreateHorizontalBox( 'Grid1', 060 )
	oView:CreateHorizontalBox( 'Grid3', 010 )
EndIf	

oView:AddField(	'VwFieldDFT', oStruCDFT, 'MdFieldDFT' )
oView:AddGrid( 'VwGridDFV', oStruGDFV, 'MdGridDFV' )
If lTmsRdpU
	oView:AddGrid( 'VwGridDJO', oStruGDJO, 'MdGridDJO' )
EndIf	
oView:AddField(	'VwTotalDFV', oTotal, 'MdTotal_DFV')

oView:SetOwnerView( 'VwFieldDFT', 'Field' )
oView:SetOwnerView( 'VwGridDFV' , 'Grid1' )
oView:SetOwnerView( 'VwTotalDFV', 'Grid3' )

If lTmsRdpU
	oView:SetOwnerView( 'VwGridDJO' , 'Grid2' )
	oView:EnableTitleView( 'VwGridDJO'  , STR0038)
	oView:AddIncrementField('VwGridDJO','DJO_SEQRDP')
EndIf
                                                             
oView:EnableTitleView( 'VwFieldDFT' , STR0031)  
oView:EnableTitleView( 'VwGridDFV'  , STR0032)                
oView:EnableTitleView( 'VwTotalDFV' , STR0034)    

oView:AddIncrementField('VwGridDFV','DFV_ITEM') 
oView:AddUserButton( STR0039, "BMPUSER", {|| TM144DcGFE(FwFldGet('DFV_FILDOC'),FwFldGet('DFV_DOC'),FwFldGet('DFV_SERIE') ) } 		,NIL,, { MODEL_OPERATION_VIEW } )  //Docto de Carga
	
Return( oView )
                       
//===========================================================================================================
/* Validacao da Ativacao do Model
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		24/09/2013
@return		lRet
//===========================================================================================================
*/
Static Function VldActMdl(oModel)
Local aGetArea	:= GetArea()
Local lRet 		:= .T.                  
Local nOperation:= oModel:GetOperation()
Local aAreaDUD  := DUD->(GetArea())
               
If nOperation == 4 .Or. nOperation == 5
	If DFT->DFT_STATUS <> StrZero( 1, Len( DFT->DFT_STATUS ) ) 
		Help('',1,'TMSAR0501') //--Manutenções permitidas apenas para redespachos com status - Em aberto.
		lRet:= .F.
	EndIf	
	If !Empty(DUD->(IndexKey(17))) //DUD_FILIAL+DUD_NUMRED
		DUD->(DbSetOrder(17))
		DUD->(MsSeek(xFilial("DUD")+DFT->DFT_NUMRED))
		While DUD->(!EOF()) .And. DUD->(DUD_FILIAL+DUD_NUMRED) == xFilial("DUD")+DFT->DFT_NUMRED
			If !Empty(DUD->DUD_VIAGEM) 
				Help('',1,'TMSAR0511') //--Existe viagem relacionada a este documento de redespacho !
				lRet:= .F.
				Exit
			EndIf
			DUD->(dBSkip())
		EndDo
	Else
		Aviso("SIGATMS", STR0041, {STR0040}, 3 ) //"Necessário executar a atualização de dicionário de dados da tabela DUD. Pacote 008920"	
		lRet:= .F.
	EndIf
EndIf	  

RestArea( aAreaDUD )
RestArea( aGetArea )
Return( lRet )


//===========================================================================================================
/* Retorna as operações disponiveis 
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		24/09/2013
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()
                 
Local  aRotina :=	{{ STR0025 , 'AxPesqui'        ,0 ,1},;
					{  STR0026 , 'VIEWDEF.TMSAR05' ,0 ,2},;
					{  STR0027 , 'VIEWDEF.TMSAR05' ,0 ,3},;
					{  STR0028 , 'VIEWDEF.TMSAR05' ,0 ,4},;
					{  STR0029 , 'VIEWDEF.TMSAR05' ,0 ,5},;
					{  STR0030 , 'TMSAR05Bax'      ,0 ,6}}	           

Return( aRotina )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSAR05TOk
Pós-validação do modelo
@type function
@version 12
@since 21/05/2008
@param [oModel], Objeto, Modelo de dados
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSAR05TOk(oModel)

Local lTMR05TOK   := ExistBlock('TMR05TOK')
Local lRetPE      := .T.                                
Local lRet        := .T.
Local nCount      := 0
Local oMdGridDFV  := oModel:GetModel( 'MdGridDFV' )   
Local oMdlFldDFT  := oModel:GetModel( 'MdFieldDFT' )                           
Local nOperation  := oModel:GetOperation()
Local aSaveLines  := FWSaveRows()
Local cCdrOri     := SuperGetMv( 'MV_CDRORI',, '' )
          
If nOperation == 3 .Or. nOperation == 4
	
	// Existindo a regiao de origem da filial e executando com interface
	If lTmsRdpU .And. ! Empty(cCdrOri) .And. ! IsBlind() 
		If !Empty(M->DFT_UFORI) .And. !Empty(M->DFT_CDMUNO)
			DUY->(DbSetOrder(1))
			// Caso a UF origem ou Municipio esteja diferente do cadastrado
			// para a regiao de origem (MV_CDRORI), questiona o usuario se
			// deve permanecer desta forma
			If DUY->(MsSeek(xFilial("DUY")+cCdrOri))                .And.;
			   (oMdlFldDFT:GetValue("DFT_UFORI")  != DUY->DUY_EST     .Or.;
			    oMdlFldDFT:GetValue("DFT_CDMUNO") != DUY->DUY_CODMUN) .And.;
			   ! MsgYesNo(STR0035 + chr(10) + STR0036 + chr(10) + STR0037, STR0004)
				oMdlFldDFT:SetValue("DFT_UFORI", DUY->DUY_EST)
				oMdlFldDFT:SetValue("DFT_UFORI", DUY->DUY_CODMUN)
			EndIf
		EndIf	
	EndIf
EndIf
                 
If nOperation == 5
	For nCount := 1 To oMdGridDFV:Length()              	                                              
		oMdGridDFV:GoLine( nCount )                    
		If oMdGridDFV:GetValue( "DFV_STATUS" ) <> StrZero( 1, Len( DFV->DFV_STATUS ) )
			Help('',1,'TMSAR0504') //--Registro não pode ser Excluído. Existe documentos com Status diferente de aberto.			
			lRet:= .F.
		EndIf         		
	Next nCount       
EndIf
FWRestRows( aSaveLines )
          
If lTMR05TOK	
	lRetPE := ExecBlock('TMR05TOK',.F.,.F.)
	If ValType(lRetPE) == "L"
		lRet := lRetPE
	EndIf
EndIf                  

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAR05LOk ³Autor  ³ Totvs                ³ Data ³21.05.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da linha da getdados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAR05LOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSAR05                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSAR05LOk(oModel)
Local lRet      := .T.
Local aArea     := GetArea()
Local lTMR05LOK := ExistBlock('TMR05LOK')
Local lRetPE    := .T. 
Local oMdlStru 	:= oModel:GetModel( "MdGridDFV" )   
Local cCodFor   := oModel:GETValue('MdFieldDFT','DFT_CODFOR')
Local cLojFor   := oModel:GETValue('MdFieldDFT','DFT_LOJFOR')
Local cPagGFE   := Posicione('SA2',1,xFilial('SA2')+cCodFor+cLojFor,'A2_PAGGFE')
Local nLine 	:= oMdlStru:GetLine()      
Local lTmsGfe := SuperGetMV( 'MV_TMSGFE',, .F. ) 

If !oMdlStru:IsDeleted(nLine) .And. lTMSGFE .And. cPagGFE == "1" 
	If Empty(FwFldGet("DFV_CDTPOP"))
		Help('',1,"OBRIGAT2",,RetTitle('DFV_CDTPOP'),04,01) 
	   	lRet := .F. 			   	
	ElseIf Empty(FwFldGet("DFV_CDCLFR"))
		Help('',1,"OBRIGAT2",,RetTitle('DFV_CDCLFR'),04,01) 
	   	lRet := .F. 	
	ElseIf Empty(FwFldGet("DFV_UFORI"))
		Help('',1,"OBRIGAT2",,RetTitle('DFV_UFORI'),04,01) 
	   	lRet := .F. 	
	ElseIf Empty(FwFldGet("DFV_CDMUNO"))
		Help('',1,"OBRIGAT2",,RetTitle('DFV_CDMUNO'),04,01) 
	   	lRet := .F. 	
	ElseIf Empty(FwFldGet("DFV_UFDES"))
		Help('',1,"OBRIGAT2",,RetTitle('DFV_UFDES'),04,01) 
	   	lRet := .F. 	
	ElseIf Empty(FwFldGet("DFV_CDMUND"))
		Help('',1,"OBRIGAT2",,RetTitle('DFV_CDMUND'),04,01) 
	   	lRet := .F. 	
	EndIf
EndIf	

If lTMR05LOK	
	lRetPE := ExecBlock('TMR05LOK',.F.,.F.)
	If ValType(lRetPE) == "L"
		lRet := lRetPE
	EndIf
EndIf

RestArea(aArea)
Return( lRet )                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAR05Grv ³ Autor ³ Totvs                ³ Data ³21.05.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava o redespacho e os documentos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAR05Grv(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSAR05Grv( oModel )

Local lRet      	:= .T.
Local cAliasQry 	:= ""
Local cQuery    	:= ""     
Local nCount    	:= 0   
Local nOperation	:= oModel:GetOperation()              
Local oMdGridDFV := oModel:GetModel( "MdGridDFV" )     
Local oMdlTotal  := oModel:GetModel( "MdTotal_DFV" )     
Local aSaveLine  :=	{}
Local cFilRed    := ""
Local cNumRed    := oModel:GetValue('MdFieldDFT','DFT_NUMRED')
Local lTMR05FIM  := ExistBlock('TMR05FIM')
Local lCmpDFV    := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0

If lCmpDFV
	cFilRed:= (oModel:GetValue('MdFieldDFT','DFT_FILORI'))
EndIf

If nOperation <> 5 
	oModel:LoadValue('MdFieldDFT','DFT_QTDDOC',oMdlTotal:GETVALUE("Qtd.Doc."))
EndIf

If nOperation == 3 .And. DFV->(ColumnPos('DFV_TIPVEI')) > 0 // Gravacao data e hora de geracao
	oModel:SetValue("MdFieldDFT", "DFT_DATGER", dDataBase)
	oModel:SetValue("MdFieldDFT", "DFT_HORGER", Substr(Time(),1,2) + Substr(Time(),4,2))
EndIf

FwFormCommit(oModel)
	
If nOperation == 5  //-- Excluir
	nCount:= 0                       
				
	If lRet                
		For nCount := 1 To oMdGridDFV:Length()              	                                              
			oMdGridDFV:GoLine( nCount )                    
					
			cAliasQry := GetNextAlias()	
			cQuery := " SELECT MAX(DUD.R_E_C_N_O_) REC "
			cQuery += " FROM " + RetSqlName("DUD")  + " DUD "
			cQuery += " WHERE "
			cQuery += "     DUD.DUD_FILIAL ='" + xFilial("DUD")  +	"' "
			cQuery += " AND DUD.DUD_FILDOC ='" + oMdGridDFV:GetValue( "DFV_FILDOC" )  + "' "
			cQuery += " AND DUD.DUD_DOC    ='" + oMdGridDFV:GetValue( "DFV_DOC" )   + "' "
			cQuery += " AND DUD.DUD_SERIE  ='" + oMdGridDFV:GetValue( "DFV_SERIE" )  + "' "
			If lCmpDFV
				cQuery += " AND DUD.DUD_FILORI ='" + oMdGridDFV:GetValue( "DFV_FILORI" )  + "'"
			EndIf	
			cQuery += " AND DUD.DUD_NUMRED ='" + oMdGridDFV:GetValue( "DFV_NUMRED" )  + "'"
			cQuery += " AND DUD.DUD_SERTMS ='" + StrZero( 3, Len( DUD->DUD_SERTMS ) ) + "'"
			cQuery += " AND DUD.DUD_STATUS ='" + StrZero( 1, Len( DUD->DUD_STATUS ) ) + "'"
			cQuery += " AND DUD.D_E_L_E_T_ <>'*' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			If (cAliasQry)->(!Eof()) .And. (cAliasQry)->REC > 0
				DUD->( DbGoto( (cAliasQry)->REC ) )
				RecLock('DUD',.F.)
				DUD->DUD_NUMRED	:= Space(Len(DUD->DUD_NUMRED))
				DUD->(MsUnLock())
			EndIf
			(cAliasQry)->( dbCloseArea() )        
							
		Next nCount        
	EndIf                                      
Else
	If lRet                         				 
        aSaveLine:= FWSaveRows()
		For nCount := 1 To oMdGridDFV:Length()              	                                              
			oMdGridDFV:GoLine( nCount )                    

			//--  Seleciona o DUD de Redespacho, "Entrega", "Aberto".
			cAliasQry := GetNextAlias()
			cQuery := " SELECT DUD.R_E_C_N_O_ "
			cQuery += " FROM " + RetSqlName("DUD")  + " DUD "
			cQuery += " WHERE "
			cQuery += " 	 DUD.DUD_FILIAL ='" + xFilial("DUD") +	"' "
			cQuery += " AND DUD.DUD_FILDOC ='" + oMdGridDFV:GetValue( "DFV_FILDOC" ) + "' "
			cQuery += " AND DUD.DUD_DOC    ='" + oMdGridDFV:GetValue( "DFV_DOC" ) + "' "
			cQuery += " AND DUD.DUD_SERIE  ='" + oMdGridDFV:GetValue( "DFV_SERIE" ) + "' "
			cQuery += " AND DUD.DUD_STATUS ='" + StrZero( 1, Len( DUD->DUD_STATUS ) ) + "'"				
			cQuery += " AND DUD.DUD_SERTMS ='" + StrZero( 3, Len( DUD->DUD_SERTMS ) ) + "'"				
			cQuery += " AND DUD.D_E_L_E_T_ <>'*' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			If (cAliasQry)->(!Eof()) 
				DUD->(DbGoto((cAliasQry)->R_E_C_N_O_))
				RecLock('DUD',.F.)
            	If oMdGridDFV:IsDeleted(nCount)
	          		DUD->DUD_NUMRED    := Space(Len(DUD->DUD_NUMRED))
              Else  
                DUD->DUD_NUMRED  := cNumRed
            EndIf
                DUD->(MsUnLock())
			EndIf	
			  (cAliasQry)->( dbCloseArea() )			

		Next nCount                     
		FwRestRows( aSaveLine )			
			
		If lTMR05FIM						  
			ExecBlock("TMR05FIM",.F.,.F.) 
		EndIf
					
		TMSRA05DFT( cNumRed, cFilRed)
	EndIf
EndIf	 

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSAR05Gat³ Autor ³ Totvs                 ³ Data ³ 22.07.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilha a tela com os documentos selecionados.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAR05Gat(cCampo,cFilDoc,cDoc,cSerie)
Local cRet     := ""             
Local oModel   := FWModelActive()
Local oMdlStru := oModel:GetModel( "MdGridDFV" )  
Local cUFOri   := ""
Local cUFDes   := ""
Local cCdMunO  := ""
Local cCdMunD  := ""   
Local nOperation:= oModel:GetOperation()      
Local lTmsGfe   := SuperGetMV( 'MV_TMSGFE',, .F. )     
Local nLine     := oMdlStru:GetLine()

Default cFilDoc   := FwFldGet("DFV_FILDOC")
Default cDoc      := FwFldGet("DFV_DOC")
Default cSerie    := FwFldGet("DFV_SERIE")

DT6->( dbSetOrder( 1 ) )
If DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )    
	
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial('SA1')+DT6->DT6_CLIREM+DT6->DT6_LOJREM))
		If cCampo $ "DFV_NOMREM"  //Cliente Remetente       
			cRet  	:= Padr( SA1->A1_NOME, TamSX3('DFV_NOMREM')[1] ) 
		EndIf	
		cUFOri	:= SA1->A1_EST
		cCdMunO	:= SA1->A1_COD_MUN
	EndIf
	
	If SA1->(DbSeek(xFilial('SA1')+DT6->DT6_CLIDES+DT6->DT6_LOJDES))
		If cCampo $ "DFV_NOMDES"
			cRet  	:= Padr( SA1->A1_NOME, TamSX3('DFV_NOMDES')[1] ) 
		EndIf	
		cUFDes	:= SA1->A1_EST
		cCdMunD	:= SA1->A1_COD_MUN	
	EndIf	
	
	If lTMSGFE .And. (nOperation == 3 .Or. (nOperation == 4 .And. nLine > 0 .And. Empty(FwFldGet('DFV_CDMUNO')) ))   
		oMdlStru:SetValue("DFV_UFORI"   , cUFOri)
		oMdlStru:SetValue("DFV_CDMUNO"  , cCdMunO)		
		oMdlStru:SetValue("DFV_UFDES"   , cUFDes)
		oMdlStru:SetValue("DFV_CDMUND"  , cCdMunD)
	EndIf 
EndIf              
		
Return cRet

//===========================================================================================================
/* Inicializador do Campo
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		24/09/2013
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Function TMSAR05INI(cCampo)

Local aAreaSav := GetArea()
Local cRet     := ""

Default cCampo := ""

RestArea(aAreaSav)
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSAR05Bax³ Autor ³ Totvs                 ³ Data ³ 22.07.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a Baixa, gerando ocorrencias informativa para os		³±±
±±³			 ³	 docs. selecionados                                    		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAR05Bax( cAlias, nReg, nOpcx, lChgVge, cFilOri, cViagem )
Local lRet      := .T. 
Local cOcorBx   := PadR(SuperGetMv('MV_OCORRDP',,""), TamSx3('DUA_CODOCO')[1])
Local cAliasQry := ""
Local aAreaDFV  := {}      
Local aArea     := GetArea()
Local cPagGFE   := Posicione('SA2',1,xFilial('SA2')+DFT->DFT_CODFOR+DFT->DFT_LOJFOR,'A2_PAGGFE')
Local lTmsGfe 	:= SuperGetMV( 'MV_TMSGFE',, .F. ) 
Local lIntGFE 	:= .F.
Local lCmpDFV		:= DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0
Local aAreaDFT  := {}

//---- Variaveis que são passados pela rotina de Operaçao de Viagem de Redespacho para integração do TMS x GFE
Default lChgVge	:= .F.
Default cFilOri 	:= ''
Default cViagem 	:= ''  

If Type("lMsErroAuto") == "U"	
	Private lMsErroAuto := .F.
EndIf	

If !lChgVge
	//-- Verifica se existe Doc. relacionada a viagem
	//-- Em caso de positivo so' pode efetuar o apontamento via Viagem.
	//-- Desta forma evita do Usuario burlar o sistema incluindo o dc. de Reespacho em viagens e pagar indevidamente qdo o redespachante entregar.
	cAliasQry := GetNextAlias()
	cQuery := " SELECT COUNT(*) DUDVIAG "
	cQuery += " FROM "
	cQuery += + RetSqlName('DFT') + " DFT, " + RetSqlName('DFV') + " DFV," + RetSqlName('DUD') + " DUD, " + RetSqlName('DTQ') + " DTQ "
	cQuery += " WHERE "
	cQuery += "     DFT.DFT_FILIAL = '" + xFilial("DFT") + "'"
	If lCmpDFV
		cQuery += " AND DFT.DFT_FILORI = '" + DFT->DFT_FILORI + "'"
	EndIf
	cQuery += " AND DFT.DFT_NUMRED = '" + DFT->DFT_NUMRED + "'"
	cQuery += " AND DFT.DFT_CODFOR = '" + DFT->DFT_CODFOR + "'"
	cQuery += " AND DFT.DFT_LOJFOR = '" + DFT->DFT_LOJFOR + "'"
	
	cQuery += " AND DFV.DFV_FILIAL = '" + xFilial("DFV") + "'"
	If lCmpDFV
		cQuery += " AND DFV.DFV_FILORI = '" + DFT->DFT_FILORI + "'"
	EndIf
	cQuery += " AND DFV.DFV_NUMRED = '" + DFT->DFT_NUMRED + "'"
	cQuery += " AND DFV.DFV_CODFOR = DFT.DFT_CODFOR" 
	cQuery += " AND DFV.DFV_LOJFOR = DFT.DFT_LOJFOR" 
	
	cQuery += " AND DUD.DUD_FILIAL = '" + xFilial("DUD") +"'"
	cQuery += " AND DUD.DUD_FILDOC = DFV.DFV_FILDOC"
	cQuery += " AND DUD.DUD_DOC    = DFV.DFV_DOC"
	cQuery += " AND DUD.DUD_SERIE  = DFV.DFV_SERIE"
	cQuery += " AND DUD.DUD_VIAGEM <> ' '"
	cQuery += " AND DUD.DUD_STATUS <> '" + StrZero( 9, Len( DUD->DUD_STATUS ) ) + "'"
	
	cQuery += " AND DTQ.DTQ_FILIAL = '" + xFilial("DTQ") +"'"
	cQuery += " AND DTQ.DTQ_VIAGEM = DUD.DUD_VIAGEM "
	cQuery += " AND DTQ.DTQ_FILORI = DUD.DUD_FILORI "
	cQuery += " AND DTQ.DTQ_SERTMS ='" + StrZero(3, Len(DTQ->DTQ_SERTMS)) + "'" 
	
	cQuery += " AND DFT.D_E_L_E_T_ <> '*'"
	cQuery += " AND DFV.D_E_L_E_T_ <> '*'"
	cQuery += " AND DUD.D_E_L_E_T_ <> '*'"
	cQuery += " AND DTQ.D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
	If (cAliasQry)->DUDVIAG >= 1
		Help('',1,'TMSAR0507') //--Existem Documento(s) relacionado a Viagem. Efetuar o apontamento via Viagem !
		(cAliasQry)->( dbCloseArea() )
		Return Nil
	EndIf	
	(cAliasQry)->( dbCloseArea() )
Else
	If cAlias == "DFT" .And. nReg > 0
		DFT->(DbGoto(nReg))
	EndIf
	
	If nReg == 0 
		lRet:= .F.
	EndIf	
EndIf

If lRet

	//-- Verifica se existe Doc. com status diferente de Aberto na viagem.
	cAliasQry := GetNextAlias()
	cQuery := " SELECT DFV_FILDOC, DFV_DOC, DFV_SERIE, DFV_QTDVOL "
	cQuery += " FROM " + RetSqlName('DFV')  + " DFV "
	
	If !Empty(cFilOri) .And. !Empty(cViagem)
		cQuery += " INNER JOIN " + RetSqlName('DUD') + " DUD "
		cQuery	+= "   ON DUD.DUD_FILIAL	= '" + xFilial("DUD")  + "' "
		cQuery	+= "   AND DUD.DUD_FILDOC 	= DFV.DFV_FILDOC "
		cQuery	+= "   AND DUD.DUD_DOC    	= DFV.DFV_DOC "
		cQuery	+= "   AND DUD.DUD_SERIE   	= DFV.DFV_SERIE "
		cQuery	+= "   AND DUD.DUD_FILORI 	= '" + cFilOri + "' "
		cQuery	+= "   AND DUD.DUD_VIAGEM 	= '" + cViagem + "' "
		cQuery	+= "   AND DUD.DUD_STATUS 	<>'" + StrZero(9,Len(DUD->DUD_STATUS)) + "'"
		cQuery	+= "   AND DUD.D_E_L_E_T_ = ' '"
	EndIf
	
	cQuery += " WHERE DFV_FILIAL ='" + xFilial('DFV') + "' "
	If lCmpDFV
		cQuery += " AND DFV.DFV_FILORI = '" + DFT->DFT_FILORI + "'"
	EndIf
	cQuery += "   AND	DFV_NUMRED ='" + DFT->DFT_NUMRED + "' "
	cQuery += "   AND	DFV_CODFOR ='" + DFT->DFT_CODFOR + "' "
	cQuery += "   AND	DFV_LOJFOR ='" + DFT->DFT_LOJFOR + "' "
	cQuery += "   AND DFV_STATUS ='" + StrZero( 1, Len( DFV->DFV_STATUS ) ) + "'"
	cQuery += "   AND DFV.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
	If (cAliasQry)->(Eof())
		Help('',1,'TMSAR0515') 							//--Registro(s) com status diferente de aberto, neste lote !.
		(cAliasQry)->( dbCloseArea() )
		Return Nil
	ELse
		If !lChgVge .And. !( MsgNoYes( STR0011,  ) )		//-- "Confirma a baixa do registro ?"
			(cAliasQry)->( dbCloseArea() )
			Return Nil
		EndIF
		aItens	:= {}
		aCab		:= {}
	
		//-- Cabecalho da Ocorrencia
		Aadd(aCab,{'DUA_FILORI',Iif(lChgVge,cFilOri,''),NIL})
		Aadd(aCab,{'DUA_VIAGEM',Iif(lChgVge,cViagem,''),NIL})
	   
		While (cAliasQry)->(!Eof())
			//-- Itens da Ocorrencia
			aAdd(aItens,{;
				{'DUA_DATOCO', dDataBase								, NIL},;
				{'DUA_HOROCO', Strtran(Left(Time()	,5),":","")	, NIL},;
				{'DUA_CODOCO', cOcorBx									, NIL},;
				{'DUA_SERTMS', StrZero(3,Len(DUA->DUA_SERTMS))	, NIL},;
				{'DUA_FILDOC', (cAliasQry)->DFV_FILDOC				, NIL},;
				{'DUA_DOC'   , (cAliasQry)->DFV_DOC					, NIL},;
				{'DUA_SERIE' , (cAliasQry)->DFV_SERIE				, NIL},;
				{'DUA_QTDOCO', (cAliasQry)->DFV_QTDVOL				, NIL}})
		
			(cAliasQry)->(dbSkip())
		EndDo
	
	EndIf	
	(cAliasQry)->( dbCloseArea() )
EndIf	

If lRet
	aAreaDFV := DFV->( GetArea() )
	aAreaDFT := DFT->( GetArea() )
	
	Begin Transaction
		If lRet
			//-- Inclusao da Ocorrencia
			MsExecAuto({|x,y,z|Tmsa360(x,y,z)},aCab,aItens,{},3)
			RestArea( aAreaDFV )  
			RestArea( aAreaDFT )
		
			If lMsErroAuto
				MostraErro()
				lRet := .F.
				lMsErroAuto := .F.
			EndIf	      
			   			
			If lRet .And. ((lTmsGfe .And. cPagGFE <> '1') .Or. (!lTmsGfe) )
				Help('',1,'TMSAR0509') //--Ocorrências geradas com sucesso !.
			EndIf					
		EndIf
		
		If lRet       
			//Parametro MV_TMSRDPU = "N" considera o padrao antigo (pela baixa ou chegada da viagem), Ou se parametro ativo e somente pela BAIXA
			If lTmsGfe .And. cPagGFE == '1' .And. (!lTmsRDPU .Or. !lChgVge)   
				//-- Integração Protheus x GFE (INCLUSAO)		
				lRet:= TMSAR05IPG(DFT->DFT_NUMRED,DFT->DFT_CODFOR,DFT->DFT_LOJFOR,cFilOri,cViagem,Iif(lCmpDFV,DFT->DFT_FILORI,''))					
				lIntGFE:= lRet
			EndIf            
		EndIf
		
		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction
	RestArea(aArea)                            
	                          
	If lIntGFE
		Help('',1,'TMSAR0520') 
	EndIf
EndIf

Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSRA05DFT³ Autor ³ Alex Egydio           ³ Data ³28.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o Status da DFT, apos alguma alteracao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSRA05DFT()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSRA05DFT( cNumRed, cFilRed )
Local nQtdDoc   := 0
Local cQuery    := ""
Local cAliasDFV := GetNextAlias()
Local lRet      := .F.
Local cArea     := "DFV"
Local lCmpDFV   := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0
Local cSeekRed  := ""
Local nIndRed   := 1

Default cNumRed := ""
Default cFilRed := ""

//-- Se for redespacho, altera o documento p/ "Indicado p/ Entrega".
cQuery := "SELECT COUNT(*) QTDDOC FROM " + RetSqlName("DFV")
cQuery += " WHERE DFV_FILIAL = '" + xFilial("DFV") + "' AND"
If lCmpDFV
	cQuery += " DFV_FILORI = '" + cFilRed + "' AND"
EndIf	
cQuery += " DFV_NUMRED = '" + cNumRed + "' AND"
cQuery += " DFV_STATUS = '" + StrZero( 2, Len( DFV->DFV_STATUS ) ) + "' AND"
cQuery += " D_E_L_E_T_ = ' '"
cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDFV, .F., .T.)

If (cAliasDFV)->(!Eof())		
	nQtdDoc := (cAliasDFV)->QTDDOC
	(cAliasDFV)->( dbCloseArea() )
EndIf
dBSelectArea(cArea)

cSeekRed:= TMSRetInd('DFT',cNumRed,cFilRed,@nIndRed)
If !Empty(cSeekRed)
	//-- Qtd de Doc da DFV "Indicado p/ Entrega" = qtd da DFT, altera o status da DFT p/ "Indicado p/ Entrega".
	DFT->(DbSetOrder(nIndRed))
	If DFT->(DbSeek( xFilial('DFT') + cSeekRed ) .And. ( DFT->DFT_QTDDOC == nQtdDoc ) )
		RecLock('DFT', .F.)
		DFT->DFT_STATUS := StrZero( 2, Len( DFT->DFT_STATUS ) )
		MsUnLock()
	EndIf
Else
	lRet:= .F.
EndIf		
	
Return ( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAR05VLD³ Autor ³ Totvs      	        ³ Data ³25.10.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se o registro da DFV esta com Status ='1'           ³±±
±±³			 ³ Caso contrario, nao permite alteracao			  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 						                            		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAR05VLD(cCampo)
Local lRet      := .T.
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cFilDoc   := ""
Local cDoc      := ""
Local cSerie    := ""     
Local lSeekDFV  := .F.
Local lExibeErro:= .T.                                                                                         
Local aSaveLines := FWSaveRows()
Local cCdTpOp    := ""
Local cCdClFr	   := ""
Local oModel    := FwModelActive()     // Recebe o Model Ativo
Default cCampo := ReadVar()                            
           
If cCampo $ "M->DFV_FILDOC/M->DFV_DOC/M->DFV_SERIE"

	cFilDoc	:= FwFldGet("DFV_FILDOC")
	cDoc	:= FwFldGet("DFV_DOC")
	cSerie	:= FwFldGet("DFV_SERIE")  
	
	If Empty( cFilDoc ) .Or. Empty( cDoc ) .Or. Empty( cSerie )
		Return( .T. )
	EndIf    

	If lRet  
		DT6->( dbSetOrder( 1 ) )
		If !DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ))
			Help("",1,"REGNOIS")
			lRet:= .F.
		EndIf 
		DTP->(dbSetOrder(2))
		If DTP->(MsSeek(xFilial("DTP") + DT6->DT6_FILORI + DT6->DT6_LOTNFC)) .And. (DTP->DTP_TIPLOT == StrZero(3,Len(DTP->DTP_TIPLOT)))
			lRet:= Iif( DT6->(FieldPos("DT6_CHVCTG")) > 0,  Alltrim(DT6->DT6_IDRCTE) == "100" .Or. Alltrim(DT6->DT6_IDRCTE) == "136" .Or. !Empty(DT6->DT6_CHVCTG) , Alltrim(DT6->DT6_IDRCTE) == "100" .Or. Alltrim(DT6->DT6_IDRCTE) == "136"  .Or. DT6->DT6_SITCTE<>"2")
    	    // Documento Nao estando com alguma das Nao Conformidades Validadas acima		//
    	    // mas Eh um dos seguintes tipos, o processo sera Autorizado a dar continuidade //
    	    If !lRet .And. ( Alltrim(DT6->DT6_DOCTMS) == StrZero( 5, Len( DT6->DT6_DOCTMS ) ) .Or.;    //--Nota Fiscal de Serv. de Transp.
                             Alltrim(DT6->DT6_DOCTMS) == Replicate('D', Len( DT6->DT6_DOCTMS ) ) .Or.; //--Nota Fiscal de Reentrega
                             Alltrim(DT6->DT6_DOCTMS) == Replicate('F', Len( DT6->DT6_DOCTMS ) ) .Or.; //--Nota Fiscal de Armazenagem
                             Alltrim(DT6->DT6_DOCTMS) == Replicate('G', Len( DT6->DT6_DOCTMS ) ) )     //--Nota Fiscal de Complemento
				lRet := .T.
    	    EndIf
    	    If !lRet
				Help('',1,'TMSAR0521') //--" Documento informado não autorizado pela Sefaz!"
				Return(.F.)
			EndIf
		EndIf                  
		              
		If lRet			
			DFV->( dbSetOrder( 2 ) )
			lSeekDFV := DFV->( MsSeek( xFilial('DFV') + FwFldGet("DFV_FILDOC")+ FwFldGet("DFV_DOC") + FwFldGet("DFV_SERIE") ) ) .And.;
								DFV->DFV_STATUS<>StrZero( 9, Len( DFV->DFV_STATUS ) )
			
			If lSeekDFV
				Help('',1,'TMSAR0505') //--Documento já esta relacionado a algum redespachante !.
				lRet:= .F.
			EndIf	
			
			If lRet	
				cQuery := " SELECT 1 QTD "
				cQuery += " FROM " + RetSqlName("DFV") + " DFV "
				cQuery += " WHERE "
				cQuery += " 	 DFV.DFV_FILIAL 	='" + xFilial("DFV") +	"' "
				cQuery += " AND DFV.DFV_FILDOC	='" + cFilDoc + "'"
				cQuery += " AND DFV.DFV_DOC 	 	='" + cDoc + "'"
				cQuery += " AND DFV.DFV_SERIE	 	='" + cSerie + "'"
				cQuery += " AND DFV.DFV_STATUS 	<>'" + StrZero( 9, Len( DFV->DFV_STATUS ) ) + "'"
				cQuery += " AND DFV.D_E_L_E_T_<>'*' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				
				If (cAliasQry)->(!Eof()) .And. (cAliasQry)->QTD==1
					Help('',1,'TMSAR0510') //--Este documento esta relacionado a um lote de Redespacho !.
					lRet := .F.
				EndIf	
				(cAliasQry)->( dbCloseArea() )
				dBSelectArea('DUD')
				
				DUD->( DbSetOrder( 1 ) )
				If lRet .And. DUD->( MsSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt ) )
					If !Empty(DUD->DUD_VIAGEM)
						Help('',1,'TMSAR0511') //--Existe vaigem relacionada a este documento de redespacho !.
						lRet := .F.
					ElseIf DUD->DUD_SERTMS <> '3'
						Help('',1,'TMSAR0512') //--Serviço do documento não é de entrega.
						lRet := .F.
					EndIf
				Else           
					HELP('',1,'TMSAR0517') //-- Este documento nao encontra-se na filial logada.
					lRet := .F.
				EndIf
			EndIf	
		EndIf
			
		If lRet 
			If !(DT6->DT6_STATUS == StrZero( 1, Len( DT6->DT6_STATUS ) ) .Or. DT6->DT6_STATUS == StrZero( 5, Len( DT6->DT6_STATUS ) ))
				
				//Caso exista ocorrencia do tipo 'CHEGADA EVENTUAL' apontada.
				If  DT6->DT6_STATUS == StrZero( 6, Len( DT6->DT6_STATUS ) )
				  	cQuery := " SELECT (COUNT(*)) TOTREG FROM "
				  	cQuery += RetSqlName("DUA") + " DUA "
				  	cQuery += " INNER JOIN " + RetSqlName("DT2") + " DT2 ON ("
				  	cQuery += " DT2.DT2_FILIAL = '" + xFilial("DT2") + "' AND "
				  	cQuery += " DT2.DT2_TIPOCO = '" + StrZero(13, Len( DT2->DT2_TIPOCO ) ) + "' AND "
				  	cQuery += " DT2.DT2_CODOCO = DUA.DUA_CODOCO ) "
				  	cQuery += " WHERE "
				  	cQuery += " DUA.DUA_FILIAL = '" + xFilial("DUA") + "' AND "
					cQuery += " DUA.DUA_FILDOC = '" + cFilDoc + "' AND "
					cQuery += " DUA.DUA_DOC = '" + cDoc + "' AND "
					cQuery += " DUA.DUA_SERIE = '" + cSerie + "' AND "
					cQuery += " (DT2.DT2_SERTMS =  '' OR DT2.DT2_SERTMS = '" + StrZero( 3, Len( DT2->DT2_SERTMS ) ) + "' ) AND "
					cQuery += " DUA.D_E_L_E_T_ =  '' AND "
					cQuery += " DT2.D_E_L_E_T_ = '' "
				  	
					cQuery := ChangeQuery( cQuery )
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)	  	
					
					If (cAliasQry)->TOTREG > 0
						lExibeErro := .F.
					EndIf                                                   
				ElseIf  DT6->DT6_STATUS == StrZero( 4, Len( DT6->DT6_STATUS ) ) 
					lExibeErro := .F.
				EndIf
				If lExibeErro	
					Help('',1,'TMSAR0513') //--Registro não pode ser Alterado, Existe Documentos com Status diferente de Aberto
					lRet := .F.           
				EndIf
			ElseIf DT6->DT6_BLQDOC == StrZero( 1, Len( DT6->DT6_BLQDOC ) )
				Help('',1,'TMSAR0514') //--Registro não pode ser Alterado, Existe Documentos com Status Bloqueado
				lRet := .F.           
			EndIf
		EndIf	
	EndIf                                 
ElseIf cCampo $ "M->DFV_CDTPOP|M->DFT_CDTPOP"
	If cCampo == "M->DFV_CDTPOP"
		cCdTpOp:= FwFldGet("DFV_CDTPOP")
	Else
		cCdTpOp:= M->DFT_CDTPOP
	EndIf
	                 
    If !Empty(cCdTpOp)
		GV4->(dbSetOrder(1))
		If GV4->(!MsSeek(xFilial("GV4")+cCdTpOp))  
			Help(" ",1,"REGNOIS")
			lRet:= .F.
		Else
			If GV4->GV4_SIT <> '1'   //Ativo
				Help('',1,'TMSAR0519') 
				lRet:= .F.
			EndIf			
		EndIf
	EndIf

ElseIf cCampo $ "M->DFV_CDCLFR|M->DFT_CDCLFR"
	If cCampo == "M->DFV_CDCLFR"
		cCdClFr:= FwFldGet("DFV_CDCLFR")
	Else
		cCdClFr:= M->DFT_CDCLFR
	EndIf
	
    If !Empty(cCdClFr)
		GUB->(dbSetOrder(1))
		If GUB->(!MsSeek(xFilial("GUB")+cCdClFr)) 
			Help(" ",1,"REGNOIS")                                			
			lRet:= .F.			
		Else
			If GUB->GUB_SIT <> '1'   //Ativo
				Help('',1,'TMSAR0519') 
				lRet:= .F.
			EndIf	
		EndIf         
	EndIf	            
ElseIf cCampo $ "M->DJO_CODFOR|M->DJO_LOJFOR"
	If !Empty(FwFldGet("DJO_CODFOR")) .AND. !Empty(FwFldGet("DJO_LOJFOR"))
		SA2->(dbSetOrder(1))
		lRet := SA2->( dbSeek( xFilial("SA2")+FwFldGet("DJO_CODFOR")+FwFldGet("DJO_LOJFOR") ) )
		If lRet .And. SA2->A2_PAGGFE <> StrZero(1,Len(SA2->A2_PAGGFE)) //Sim
			HELP('',1,'TMSAR0522') //"Permitido informar somente os Fornecedores configurados com Pagamento pelo SIGAGFE.
			lRet:= .F.
		EndIf   
	EndIf       
EndIf                   

RestArea(aArea)
FWRestRows( aSaveLines )
Return lRet           

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAR05DEL³ Autor ³ Totvs      	        ³ Data ³22.10.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a Exclusao do Lote								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 						                           			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSAR05DEL(nOpc)
Local cAliasQry := GetNextAlias()
Local cQuery := ""
Local lRet	 := .T.

If nOpc == 5 	//-- Valida a Exclusao
	//-- Verifica se existe Doc. relacionada a viagem
	//-- Em caso de positivo so' pode efetuar o apontamento via Viagem.
	//-- Desta forma evita do Usuario burlar o sistema incluindo odc. de Reespacho em viagens e pagar indevidamente qdo o redespachante entregar.
	cQuery := " SELECT DUD.DUD_FILORI, DUD.DUD_VIAGEM "
	cQuery += " FROM "
	cQuery += + RetSqlName('DFT') + " DFT, " + RetSqlName('DFV') + " DFV," + RetSqlName('DUD') + " DUD, " + RetSqlName('DTQ') + " DTQ "
	cQuery += " WHERE "
	cQuery += "     DFT.DFT_FILIAL = '" + xFilial("DFT") + "'"
	cQuery += " AND DFT.DFT_NUMRED = '" + DFT->DFT_NUMRED + "'"   
	cQuery += " AND DFT.DFT_CODFOR = '" + DFT->DFT_CODFOR + "'"   
	cQuery += " AND DFT.DFT_LOJFOR = '" + DFT->DFT_LOJFOR + "'"   
	
	cQuery += " AND DFV.DFV_FILIAL = '" + xFilial("DFV") + "'"
	cQuery += " AND DFV.DFV_NUMRED = DFT.DFT_NUMRED"
	cQuery += " AND DFV.DFV_NUMRED = '" + DFT->DFT_NUMRED + "'"   
	cQuery += " AND DFV.DFV_CODFOR = DFT.DFT_CODFOR "
	cQuery += " AND DFV.DFV_LOJFOR = DFT.DFT_LOJFOR "

	cQuery += " AND DUD.DUD_FILIAL = '" + xFilial("DUD") +"'"
	cQuery += " AND DUD.DUD_FILDOC = DFV.DFV_FILDOC"
	cQuery += " AND DUD.DUD_DOC    = DFV.DFV_DOC"
	cQuery += " AND DUD.DUD_SERIE  = DFV.DFV_SERIE"
	cQuery += " AND DUD.DUD_VIAGEM <> ' '"
	cQuery += " AND DUD.DUD_STATUS ='" + StrZero( 1, Len( DUD->DUD_STATUS ) ) + "'"
	
	cQuery += " AND DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "'"
	cQuery += " AND DTQ.DTQ_FILORI = DUD.DUD_FILORI "
	cQuery += " AND DTQ.DTQ_VIAGEM = DUD.DUD_VIAGEM "
	cQuery += " AND DTQ.DTQ_TIPVIA = '7' "

	cQuery += " AND DFT.D_E_L_E_T_ <> '*'"
	cQuery += " AND DFV.D_E_L_E_T_ <> '*'"
	cQuery += " AND DUD.D_E_L_E_T_ <> '*'"
	cQuery += " AND DTQ.D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
	If (cAliasQry)->(!Eof())
		Help('',1,'TMSAR0518',,(cAliasQry)->DUD_FILORI + " - " +  (cAliasQry)->DUD_VIAGEM) //-- "Existem documento(s) relacionados a viagem"
		lRet := .F.
	EndIf	
	(cAliasQry)->( dbCloseArea() )
			
EndIf

Return ( lRet ) 

//======================================================================================
/* Pre Validacao do Model DFV
@author  	Katia
@version 	P11 R11.80
@build		700120420A
@since 		
@return 	Logico*/
//======================================================================================
Static Function PreVldDFV()

Local lRet       := .T.    
LOcal oModel     := FwModelActive() 
Local oMdGridDFV := oModel:GetModel('MdGridDFV')
Local nLine      := oMdGridDFV:GetLine()            
Local cAliasQry  := GetNextAlias()
Local cQuery     := ""
Local nRegistro  := oMdGridDFV:Length()
Local nOperation := oModel:GetOperation()      
Local aArea      := GetArea()                                       

If nOperation == MODEL_OPERATION_UPDATE 
   	If !oMdGridDFV:IsDeleted(nLine) .And. nLine <= nRegistro
		If FwFldGet("DFV_STATUS") <> StrZero( 1, Len( DFV->DFV_STATUS ) )	// Em aberto
			Help('',1,'TMSAR0503') //--Registro não pode ser excluido.
   			lRet := .F. 	
		Else    
			If !Empty(FwFldGet("DFV_FILDOC")+FwFldGet("DFV_DOC")+FwFldGet("DFV_SERIE") )
			//-- Verifica se o Documento a ser deletado esta em alguam viagem.	
				cQuery := " SELECT DUD.DUD_FILORI, DUD.DUD_VIAGEM "
				cQuery += " FROM " + RetSqlName("DUD")  + " DUD "
				cQuery += " WHERE "
				cQuery += "     DUD.DUD_FILIAL ='" + xFilial("DUD") +	"' "
				cQuery += " AND DUD.DUD_FILDOC ='" + FwFldGet("DFV_FILDOC") + "' "
				cQuery += " AND DUD.DUD_DOC    ='" + FwFldGet("DFV_DOC") + "' "
				cQuery += " AND DUD.DUD_SERIE  ='" + FwFldGet("DFV_SERIE") + "' "
				cQuery += " AND DUD.DUD_NUMRED ='" + DFT->DFT_NUMRED+ "'"
				cQuery += " AND DUD.DUD_SERTMS ='" + StrZero( 3, Len( DUD->DUD_SERTMS ) ) + "'"				
				cQuery += " AND DUD.DUD_STATUS ='" + StrZero( 1, Len( DUD->DUD_STATUS ) ) + "'"
				cQuery += " AND DUD.DUD_VIAGEM <>' '"
				cQuery += " AND DUD.D_E_L_E_T_ <>'*' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				If (cAliasQry)->(!Eof())		
					Help('',1,'TMSAR0518',,(cAliasQry)->DUD_FILORI + " - " +  (cAliasQry)->DUD_VIAGEM) //-- "Existem documento(s) relacionados a viagem"
					lRet := .F.
				EndIf	
				(cAliasQry)->( dbCloseArea() )				
			EndIf
		EndIf
	EndIf	
EndIf

RestArea(aArea)			
Return lRet

//-----------------------------------------------------
/*/	Integra o TMS com o SIGAGFE
@author Katia
@param cNumNFS = Numero do Redespacho que será enviada como parametro chave da função GFEM011NFS
@param cCodFor = Fornecedor do Redespacho que será enviada como parametro chave da função GFEM011NFS
@param cLojFor = Loja Fornecedor do Redespacho que será enviada como parametro chave da função GFEM011NFS
@version P11
@since 04/10/2013
/*/
//------------------------------------------------------
Function TMSAR05IPG(cNumRed,cCodFor,cLojFor,cFilOri,cViagem,cFilRed)
Local lRet     := .T.
Local lIntGFE  := SuperGetMv("MV_INTGFE",.F.,.F.)
Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")

Default cNumRed := ""
Default cCodFor := ""
Default cLojFor := ""
Default cFilOri := ""
Default cViagem := ""
Default cFilRed := "" //Filial de Origem do Redespacho

//Integração Protheus com SIGAGFE
If lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. FindFunction( "GFEM011RED")
	If !GFEM011RED('UNICO',cNumRed,cCodFor,cLojFor,,,,,cFilOri,cViagem,cFilRed)   //Romaneio
		lRet := .F.
	Else
		lRet:= .T.	
	EndIf	
EndIf

Return lRet

//===========================================================================================================
/* Condição do campo
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 	18/04/2016
@return 	lRet - True ou False */                                                                                                         
//===========================================================================================================
Function TMSAR05WHN(cCampo)
Local lRet   := .T.
Local lTmsGfe:= SuperGetMV( 'MV_TMSGFE',, .F. ) 

Default cCampo := ReadVar()

If cCampo $ "M->DFT_SEPROM" .And. ( !lTmsGfe  .Or. lTmsRdpU )  //Lote por Redespacho Unico nao habilita o campo 
	lRet:= .F.	
EndIf
	
If !lTmsRdpU .And. cCampo $ "M->DFT_UFORI|M->DFT_CDMUNO"
	lRet:= .F.
EndIf 
Return lRet
/*/-----------------------------------------------------------
{Protheus.doc} TMSRetInd()
Retorna Indice da Tabela DFV ou DFT 
O Campo Filial de Origem (DFV_FILORI e DFT_FILORI) foram criados
em Agosto/2107, quando já existia as tabelas.

Uso: TMSAR05

@sample
//TMSAR05()

@author Katia
@since 29/08/2017
@version 1.0
-----------------------------------------------------------/*/
Function TMSRetInd(cTabela,cNumRed,cFilRed,nIndRed)  
Local lCmpDFV:= DFV->(ColumnPos('DFV_FILORI')) > 0 .And. DFV->(ColumnPos('DFV_TIPVEI')) > 0
Local cRet   := ""
 
Default cTabela := ""
Default cNumRed := ""
Default cFilRed := ""
Default nIndRed := 1   //Indice original das tabelas DFT e DFV

If cTabela == 'DFV'
	If lCmpDFV
		nIndRed := 4
		cRet:= cFilRed + cNumRed
		 
		DFV->(DbSetOrder(nIndRed))
		If !DFV->( DbSeek( xFilial("DFV") + cRet ) )  //Se nao achar pelo novo indice, procura pelo antigo sem a Filial de Origem
			nIndRed := 1
			cRet:= cNumRed 	
		EndIf
	Else
		cRet:= cNumRed
	EndIf
ElseIf cTabela == 'DFT'
	If lCmpDFV
		nIndRed:= 2
		cRet:= cFilRed + cNumRed 
		
		DFT->(DbSetOrder(nIndRed))
		If !DFT->( DbSeek( xFilial("DFT") + cRet ) ) //Se nao achar pelo novo indice, procura pelo antigo sem a Filial de Origem
			nIndRed:= 1
			cRet:= cNumRed
		EndIf
	Else	 
		cRet:= cNumRed
	EndIf
EndIf

Return cRet

//-----------------------------------------------------------
/*/{Protheus.doc} TMSAR05Leg
//Status da Viagem - DTQ
@author Katia
@since 17/05/2021
@version 12.1.33
Utilizado na Viagem Modelo 3 (TMSAF60)
/*/
//-----------------------------------------------------------
Function TMSAR05Leg()
Local aLegenda := {}

	aAdd(aLegenda, {"Posicione('DFT',2,xFilial('DFT')+DFV->DFV_FILORI+DFV->DFV_NUMRED,'DFT_STATUS')=='1'", "GREEN"	, STR0016} 	) //"Redespacho em aberto" 
	aAdd(aLegenda, {"Posicione('DFT',2,xFilial('DFT')+DFV->DFV_FILORI+DFV->DFV_NUMRED,'DFT_STATUS')=='2'", "RED"	, STR0017} 	) //"Redespacho indicado para entrega"
	aAdd(aLegenda, {"Posicione('DFT',2,xFilial('DFT')+DFV->DFV_FILORI+DFV->DFV_NUMRED,'DFT_STATUS')=='3'", "BLUE"	, STR0018} 	) //"Redespacho encerrado"  
	aAdd(aLegenda, {"Posicione('DFT',2,xFilial('DFT')+DFV->DFV_FILORI+DFV->DFV_NUMRED,'DFT_STATUS')=='9'", "BLACK"	, STR0019} 	) //"Redespacho cancelado"
	
Return aLegenda
