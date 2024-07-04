#INCLUDE "TMSA541.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"           

Static nRecAtual:= 0 

//===========================================================================================================
/* Rotina de Conciliação de Sobras e Faltas
@author  	Jefferson
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return	
//===========================================================================================================
*/
Function TMSA541(cAlias,nReg,nOpcx,cFilPndOco,cNumPndOco)
Local oMBrowse	:= Nil       
Local aSetKey   := {}

Private aRotina := MenuDef()
Private cFilPnd1:= ""
Private cNumPnd1:= ""
Private cNumNfc1:= ""
Private cSerNfc1:= ""                                   

Default cAlias     := ""
Default nReg       := 0
Default nOpcx      := 4    
Default cFilPndOco := ""
Default cNumPndOco := ""

AAdd(aSetKey, { VK_F12 , { || Pergunte("TMA541",.T.) } } )     
TmsKeyOn(aSetKey)

//===========================================================================================================
// Funcao de BROWSE
//===========================================================================================================
oMBrowse:= FwMBrowse():New()
oMBrowse:SetAlias( "DYZ" )
oMBrowse:SetDescription( STR0001 )

ADD LEGEND DATA 'DYZ->DYZ_STACON=="1"' COLOR "GREEN"  TITLE STR0003 OF oMBrowse // "Pendente"
ADD LEGEND DATA 'DYZ->DYZ_STACON=="2"' COLOR "YELLOW" TITLE STR0015 OF oMBrowse // "Localizado"
ADD LEGEND DATA 'DYZ->DYZ_STACON=="3"' COLOR "RED"    TITLE STR0020 OF oMBrowse // "Conciliado"
ADD LEGEND DATA 'DYZ->DYZ_STACON=="4"' COLOR "BLUE"   TITLE STR0021 OF oMBrowse // "Conciliado Item"
ADD LEGEND DATA 'DYZ->DYZ_STACON=="5"' COLOR "WHITE"  TITLE STR0004 OF oMBrowse // "Encerrado"

If !Empty(cFilPndOco) .And. !Empty(cNumPndOco)
	oMBrowse:SetFilterDefault( "DYZ_FILPND == " + "'" + cFilPndOco + "'" + " .And. DYZ_NUMPND $ " + "'" + cNumPndOco + "'"  )  
EndIf	


oMBrowse:SetCacheView( .F. )
oMBrowse:Activate()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

Return

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Conciliação de Sobras e Faltas
@author  	Jefferson Tomaz
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return 	oModel - Modelo de Dados */                                                                                                         
//===========================================================================================================
Static Function ModelDef()       

Local oModel      := Nil
Local oStruCDYZ   := FwFormStruct( 1, 'DYZ' , {|cCampo| AllTrim(cCampo)+"|" $ "DYZ_DATPND|DYZ_HORPND|DYZ_TIPPND|DYZ_DESPND|DYZ_FILDOC|DYZ_DOC|DYZ_SERIE|DYZ_FILORI|DYZ_VIAGEM|DYZ_CODOCO|DYZ_DESOCO|DYZ_QTDOCO|DYZ_MOTIVO|DYZ_QTDVOL|DYZ_FILCON|DYZ_NUMCON|DYZ_QTDCON|DYZ_CODMTC|DYZ_DESMTC|"} )
Local oStruGDYZ   := FWFormStruct( 1, 'DYZ' , {|cCampo2| AllTrim(cCampo2)+"|" $ "|DYZ_FILIAL|DYZ_FILPND|DYZ_NUMPND|DYZ_NUMNFC|DYZ_SERNFC|DYZ_DATPND|DYZ_HORPND|DYZ_CODCLI|DYZ_LOJCLI|DYZ_QTDOCO|DYZ_QTDVOL|DYZ_QTDCON|DYZ_CODMTC|DYZ_DESMTC|"}) 
Local oStruDYM_FL := FwFormStruct( 1, 'DYM',  {|cCampo3| AllTrim(cCampo3)+"|" $ "|DYM_TPIDPD|DYM_DESCRI|DYM_DETALH|"})   //Identificacao do produto - Field
Local oStruDYM    := FwFormStruct( 1, 'DYM',  {|cCampo4| AllTrim(cCampo4)+"|" $ "|DYM_TPIDPD|DYM_DESCRI|DYM_DETALH|"})   //Identificacao do produto - Grid
Local oStruGDYZ_FL1:= FWFormStruct( 1, 'DYZ' )   //Historico Field 
Local oStruGDYZ_FL2:= FWFormStruct( 1, 'DYZ' )   //Historico Grid
        
Private aRelDYM_FL := {{ 'DYM_FILIAL', 'xFilial("DYM")' }, { 'DYM_FILPND', "'"+DYZ->DYZ_FILPND+"'" }, { 'DYM_NUMPND', "'"+DYZ->DYZ_NUMPND+"'" }, { 'DYM_NUMNFC', "'"+DYZ->DYZ_NUMNFC+"'" }, { 'DYM_SERNFC', "'"+DYZ->DYZ_SERNFC+"'" }}
Private aRelDYZ_FL1:= {{ 'DYZ_FILIAL', 'xFilial("DYZ")' }, { 'DYZ_FILPND', "'"+DYZ->DYZ_FILPND+"'" }, { 'DYZ_NUMPND', "'"+DYZ->DYZ_NUMPND+"'" }, { 'DYZ_NUMNFC', "'"+DYZ->DYZ_NUMNFC+"'" }, { 'DYZ_SERNFC', "'"+DYZ->DYZ_SERNFC+"'" }}
Private nRecnoDYZ  := DYZ->(RECNO())

oStruGDYZ:SetProperty( 'DYZ_QTDCON' , MODEL_FIELD_VALID,{|oMdl| A541VLDQTD(oModel)} )

oModel := MpFormModel():New( 'TMSA541', /*bPreValidacao*/, { |oMdl| PosVldMdl( oModel ) } /*bPosValid*/, { |oMdl| CommitMdl( oModel ) } /*bCommit*/, /*bCancel*/ )  

oModel:SetDescription( STR0002 )

TMSA541Mod('M',@oStruCDYZ)

oModel:AddFields( 'MdFieldDYZ', Nil, oStruCDYZ )

oModel:SetPrimaryKey( { 'DYZ_FILIAL', 'DYZ_FILPND', 'DYZ_NUMPND', 'DYZ_NUMNFC', 'DYZ_SERNFC', 'DYZ_STACON'} )
  
oModel:AddGrid( 'MdGridDYZ'    , 'MdFieldDYZ', oStruGDYZ , /*bLinePre*/ , { |oMdlGrid| PosLinGrd(oModel) },/*bPreVal*/, /*bPosValid*/,  &("{ |oModel| LdGridDYZ( oModel, DYZ->DYZ_FILPND, DYZ->DYZ_NUMPND, DYZ->DYZ_TIPPND, DYZ->DYZ_NUMNFC, DYZ->DYZ_SERNFC )}") /*BLoad*/   )  

oModel:AddGrid( 'MdGridDYM_FL' , 'MdFieldDYZ', oStruDYM_FL, /*bLinePre*/ ,                               ,/*bPreVal*/, /*bPosValid*/,  &("{ |oModel| LdGridDYM( oModel, nRecAtual, 1)}") /*BLoad*/    )
oModel:AddGrid( 'MdGridDYZ_FL1', 'MdFieldDYZ', oStruGDYZ_FL1 )
oModel:AddGrid( 'MdGridDYZ_FL2', 'MdGridDYZ' , oStruGDYZ_FL2) 
oModel:AddGrid( 'MdGridDYM'    , 'MdGridDYZ' , oStruDYM  , /*bLinePre*/ ,                               ,/*bPreVal*/, /*bPosValid*/,  &("{ |oModel| LdGridDYM( oModel, DYZ->(RECNO()), 2 )}") /*BLoad*/    )

oModel:SetRelation( 'MdGridDYZ', { { 'DYZ_FILIAL', 'xFilial("DYZ")' }, { 'DYZ_FILPND', 'DYZ_FILPND' }, { 'DYZ_NUMPND', 'DYZ_NUMPND' } ,{ 'DYZ_NUMNFC', 'DYZ_NUMNFC' }, { 'DYZ_SERNFC', 'DYZ_SERNFC' } }, DYZ->( IndexKey(1) ) )
oModel:SetRelation( 'MdGridDYM_FL',  aRelDYM_FL , DYM->( IndexKey(1) ) )  //Folder Identicacao do Produto com SetRelation da Field DYZ
oModel:SetRelation( 'MdGridDYZ_FL1', aRelDYZ_FL1, DYZ->( IndexKey(1) ) )  //Folder Historico com SetRelation da Field DYZ
oModel:SetRelation( 'MdGridDYZ_FL2', { { 'DYZ_FILIAL', 'xFilial("DYZ")' }, { 'DYZ_FILPND', 'DYZ_FILPND' }, { 'DYZ_NUMPND', 'DYZ_NUMPND' } ,{ 'DYZ_NUMNFC', 'DYZ_NUMNFC' }, { 'DYZ_SERNFC', 'DYZ_SERNFC' } }, DYZ->( IndexKey(1) ) )
oModel:SetRelation( 'MdGridDYM'    , { { 'DYM_FILIAL', 'xFilial("DYM")' }, { 'DYM_FILPND', 'DYZ_FILPND' }, { 'DYM_NUMPND', 'DYZ_NUMPND' }, { 'DYM_NUMNFC', 'DYZ_NUMNFC' }, { 'DYM_SERNFC', 'DYZ_SERNFC' } }, DYM->( IndexKey(1) ) )

oModel:GetModel( 'MdGridDYZ' ):SetOptional( .T. )
oModel:GetModel( 'MdGridDYM' ):SetOptional( .T. )  
oModel:GetModel( 'MdGridDYM_FL'):SetOptional( .T. )  
oModel:GetModel( 'MdGridDYZ_FL1'):SetOptional( .T. )
oModel:GetModel( 'MdGridDYZ_FL2'):SetOptional( .T. )

oModel:GetModel( 'MdGridDYZ' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridDYZ' ):SetNoDeleteLine( .T. )                                                                         

oModel:GetModel( 'MdGridDYM' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridDYM' ):SetNoUpdateLine( .T. )
oModel:GetModel( 'MdGridDYM' ):SetNoDeleteLine( .T. ) 

oModel:GetModel( 'MdGridDYM_FL' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridDYM_FL' ):SetNoUpdateLine( .T. )
oModel:GetModel( 'MdGridDYM_FL' ):SetNoDeleteLine( .T. )
                                                     
oModel:GetModel( 'MdGridDYZ_FL1' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridDYZ_FL1' ):SetNoUpdateLine( .T. )
oModel:GetModel( 'MdGridDYZ_FL1' ):SetNoDeleteLine( .T. )

oModel:GetModel( 'MdGridDYZ_FL2' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridDYZ_FL2' ):SetNoUpdateLine( .T. )
oModel:GetModel( 'MdGridDYZ_FL2' ):SetNoDeleteLine( .T. )
                                           '
//-- Nao altera dados da grid
oModel:GetModel( 'MdGridDYZ' ):SetOnlyQuery ( .T. )
oModel:GetModel( 'MdGridDYM' ):SetOnlyQuery ( .T. )   
oModel:GetModel( 'MdGridDYM' ):SetOnlyQuery ( .T. )   
oModel:GetModel( 'MdGridDYM_FL' ):SetOnlyQuery ( .T. )   
oModel:GetModel( 'MdGridDYZ_FL1'):SetOnlyQuery ( .T. )   
oModel:GetModel( 'MdGridDYZ_FL2'):SetOnlyQuery ( .T. )   

oModel:GetModel( 'MdGridDYZ_FL1' ):SetLoadFilter( { { 'DYZ_STACON', "'1'", MVC_LOADFILTER_NOT_EQUAL } } )
oModel:GetModel( 'MdGridDYZ_FL2' ):SetLoadFilter( { { 'DYZ_STACON', "'1'", MVC_LOADFILTER_NOT_EQUAL } } )

oModel:SetVldActivate( { |oModel| VldActMdl( oModel ) } )
  
Return( oModel ) 


//===========================================================================================================
/* Retorna a View (tela) da rotina Conciliação de Sobras e Faltas
@author  	Jefferson Tomaz
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return 	aRotina - Array com as opçoes de Menu */                                                                                                          
//===========================================================================================================
Static Function ViewDef()

Local oView        := Nil
Local oModel       := FwLoadModel( 'TMSA541' )
Local oStruCDYZ    := FwFormStruct( 2, 'DYZ' , {|cCampo| AllTrim(cCampo)+"|" $ "DYZ_DATPND|DYZ_HORPND|DYZ_TIPPND|DYZ_DESPND|DYZ_FILDOC|DYZ_DOC|DYZ_SERIE|DYZ_FILORI|DYZ_VIAGEM|DYZ_CODOCO|DYZ_DESOCO|DYZ_QTDOCO|DYZ_MOTIVO|DYZ_QTDVOL|DYZ_FILCON|DYZ_NUMCON|DYZ_QTDCON|DYZ_CODMTC|DYZ_DESMTC|"} )
Local oStruGDYZ    := FWFormStruct( 2, 'DYZ' , {|cCampo2| AllTrim(cCampo2)+"|" $ "|DYZ_FILIAL|DYZ_FILPND|DYZ_NUMPND|DYZ_NUMNFC|DYZ_SERNFC|DYZ_DATPND|DYZ_HORPND|DYZ_CODCLI|DYZ_LOJCLI|DYZ_QTDOCO|DYZ_QTDVOL|DYZ_QTDCON|DYZ_CODMTC|DYZ_DESMTC|"})
Local oStruDYM     := FwFormStruct( 2, 'DYM' ,{|cCampo4| AllTrim(cCampo4)+"|" $ "|DYM_TPIDPD|DYM_DESCRI|DYM_DETALH|"}) 
Local oStruDYM_FL  := FwFormStruct( 2, 'DYM',{|cCampo3| AllTrim(cCampo3)+"|" $ "|DYM_TPIDPD|DYM_DESCRI|DYM_DETALH|"})  
Local oStruGDYZ_FL1:= FwFormStruct( 2, 'DYZ')
Local oStruGDYZ_FL2:= FwFormStruct( 2, 'DYZ')

Private cTipPnd  := ""

cTipPnd := Iif(DYZ->DYZ_TIPPND == '01', '03' , '01')   

TMSA541Mod('V',@oStruCDYZ)

oView := FwFormView():New()
oView:SetModel( oModel )

oView:CreateHorizontalBox( 'Field', 030 )
oView:CreateHorizontalBox( 'Grid1', 040 )
oView:CreateHorizontalBox( 'Grid2', 030 )

oView:CreateFolder("IDFOLDER","Field")
oView:AddSheet("IDFOLDER","IDSHEET01",STR0009)   //Pendencia Principal
oView:AddSheet("IDFOLDER","IDSHEET02",STR0012)   //Identificacao do Produto
oView:AddSheet("IDFOLDER","IDSHEET03",STR0013)   //Historico

oView:CreateHorizontalBox( "DETAIL_1", 100,,,"IDFOLDER","IDSHEET01" )
oView:CreateHorizontalBox( "DETAIL_2", 100,,,"IDFOLDER","IDSHEET02" )
oView:CreateHorizontalBox( "DETAIL_3", 100,,,"IDFOLDER","IDSHEET03" )

oView:CreateFolder("IDFOLDER1","Grid2")
oView:AddSheet("IDFOLDER1","IDSHEET04",STR0012) //Pendencias do Tipo (Sobra ou Falta)
oView:AddSheet("IDFOLDER1","IDSHEET05",STR0013) //Historico        

oView:CreateHorizontalBox( "DETAIL_4"  , 100,,,"IDFOLDER1","IDSHEET04" )
oView:CreateHorizontalBox( "DETAIL_5"  , 100,,,"IDFOLDER1","IDSHEET05" )


oView:CreateFolder("IDFOLDER2","Grid1")
oView:AddSheet("IDFOLDER2","IDSHEET06",STR0010 + TmsValField("cTipPnd",.F.) )   //Pendencias do Tipo (Sobra ou Falta)

oView:CreateHorizontalBox( "DETAIL_6"  , 100,,,"IDFOLDER2","IDSHEET06" )

oView:AddField( 'VwFieldDYZ'  , oStruCDYZ   , 'MdFieldDYZ')
oView:AddGrid( 'VwGridDYZ'    , oStruGDYZ   , 'MdGridDYZ' )
oView:AddGrid( 'VwGridDYM'    , oStruDYM    , 'MdGridDYM' )
oView:AddGrid( 'VwGridDYM_FL' , oStruDYM_FL , 'MdGridDYM_FL' )
oView:AddGrid( 'VwGridDYZ_FL1', oStruGDYZ_FL1, 'MdGridDYZ_FL1' )
oView:AddGrid( 'VwGridDYZ_FL2', oStruGDYZ_FL2, 'MdGridDYZ_FL2' )

oView:SetOwnerView( 'VwFieldDYZ'    ,'DETAIL_1' )
oView:SetOwnerView( 'VwGridDYM_FL'  ,'DETAIL_2' )
oView:SetOwnerView( 'VwGridDYZ_FL1' ,'DETAIL_3' )
oView:SetOwnerView( 'VwGridDYZ' 	,'DETAIL_6' )
oView:SetOwnerView( 'VwGridDYM'    , 'DETAIL_4' )
oView:SetOwnerView( 'VwGridDYZ_FL2', 'DETAIL_5' )
                                                                       
oView:EnableTitleView( 'VwFieldDYZ' , STR0009 + DYZ->DYZ_FILPND + " - " + DYZ->DYZ_NUMPND + (Iif(!Empty(DYZ->DYZ_NUMNFC), " / " +  DYZ->DYZ_NUMNFC + " - " + DYZ->DYZ_SERNFC,'')))  //Pendencia Principal

oView:SetOnlyView('VwFieldDYZ')
                                              
//--- Inclusao de Filtro na Grid
oView:SetViewProperty("VwGridDYZ", "ENABLENEWGRID")
oView:SetViewProperty("VwGridDYZ", "GRIDFILTER", {.T.}) 
oView:SetViewProperty("VwGridDYZ", "GRIDSEEK", {.T.}) 
//---

oView:SetCloseOnOk({|| .T. })

Return( oView )

//===========================================================================================================
/* Retorna as operações disponiveis para a Conciliação de Sobras e Faltas
@author  	Jefferson Tomaz
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()
                       
Local aRotina := {{ STR0005 ,"AxPesqui"         ,0 , 1,,.F. },;         //"Pesquisar"
                  { STR0006 ,"TMSA541Mnt(,,2)"  ,0 , 2 },;               //"Visualizar" 
                  { STR0007 ,"VIEWDEF.TMSA541"  ,0 , 4 },;               //"Conciliar"
                  { STR0017 ,"TMSA541Mnt()"     ,0 , 5 },;               //"Estornar"
                  { STR0015 ,"TMSA541Loc()"     ,0,  6 },;               //"Localizado" 
                  { STR0022 ,"TMSA541Doc()"     ,0,  7 },;               //"Consulta Docto"
                  { STR0023 ,"TMSR541"          ,0,  8 }}                //"Rel.Conciliação
                   
Return( aRotina )

//===========================================================================================================
/* Selecao dos registros para exibicao - DYZ
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@param	oMdl      Modelo de dados completo para carga
@return	aResult   Array no formato para utilizacao no grid
//===========================================================================================================
*/
Function LdGridDYZ( oModel, cFilPnd, cNumPnd, cTipoPnd, cNumNfc, cSerNfc)

Local aRet		:= {}
Local cAliasDYZ	:= GetNextAlias()
Local cQuery	:= ""
Local cFilPndR  := ""
Local cNumPndR  := ""
Local nOpc      := oModel:GetOperation()

Default cFilPnd := ""
Default cNumPnd := ""
Default cTipoPnd:= ""
Default cNumNfc := ""
Default cSerNfc := ""           
                  
If nOpc == MODEL_OPERATION_UPDATE	
	nRecAtual:= DYZ->(Recno())

	TMSA541IdP(cFilPnd, cNumPnd, cTipoPnd, @cFilPndR, @cNumPndR, cNumNfc, cSerNfc)

	cTipoPnd  := Iif(cTipoPnd == '01', '03' , '01') 	
	
	cAliasDYZ := GetNextAlias()      
	cQuery := " SELECT DYZ_FILIAL, DYZ_FILPND, DYZ_NUMPND, DYZ_NUMNFC, DYZ_SERNFC, DYZ_DATPND, DYZ_HORPND, DYZ_CODCLI, DYZ_LOJCLI, DYZ_QTDOCO, DYZ_QTDVOL, DYZ_QTDCON, DYZ_CODMTC "
	cQuery += "   FROM  " + RetSqlName("DYZ") + " DYZ "
	cQuery += "    WHERE DYZ_FILPND IN " + FormatIn(cFilPndR,"|")
	cQuery += "    AND DYZ.DYZ_NUMPND IN " + FormatIn(cNumPndR,"|")
	cQuery += "    AND DYZ.DYZ_TIPPND = '" + cTipoPnd +"'"
	cQuery += "    AND DYZ.DYZ_STACON =  '" + StrZero(1, Len(DYZ->DYZ_STACON)) + "'"      //Pendente
	cQuery += "    AND DYZ.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDYZ, .T., .F.)	
	TcSetField(cAliasDYZ,"DYZ_DATPND", "D", 8, 0)
	
	aRet := FWLoadByAlias( oModel, cAliasDYZ )
			
	(cAliasDYZ)->( dbCloseArea() )
	
Else
	If DYZ->DYZ_STACON == '3'
		nRecAtual:= DYZ->(Recno())
	    //-- Pendencias Itens                
		cAliasDYZ := GetNextAlias()
		cQuery := " SELECT DYZ_FILIAL, DYZ_FILPND, DYZ_NUMPND, DYZ_NUMNFC, DYZ_SERNFC, DYZ_DATPND, DYZ_HORPND, DYZ_TIPPND, DYZ_CODCLI, DYZ_LOJCLI, DYZ_QTDOCO, DYZ_QTDVOL, DYZ_QTDCON, DYZ_CODMTC "
		cQuery += "   FROM  " + RetSqlName("DYZ") + " DYZ "
		cQuery += "    WHERE DYZ_FILIAL = '"+xFilial('DYZ')+"'"
		cQuery += "    AND DYZ.DYZ_NUMCON = '" + DYZ->DYZ_NUMCON + "'"
		cQuery += "    AND DYZ.DYZ_STACON =  '" + StrZero(4, Len(DYZ->DYZ_STACON)) + "'"    
		cQuery += "    AND DYZ.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDYZ, .T., .F.)	
		TcSetField(cAliasDYZ,"DYZ_DATPND", "D", 8, 0)
		
		aRet := FWLoadByAlias( oModel, cAliasDYZ )
					
		(cAliasDYZ)->( dbCloseArea() )
	EndIf	
EndIf
	
Return( aRet )

//===========================================================================================================
/* Selecao dos registros de Pendencia para conciliacao - DYZ
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return	cResult   Filial da Pendencia, Numero da Pendencia para utilização na seleção da montagem da Grid
//===========================================================================================================
*/
Function TMSA541IdP(cFilPnd, cNumPnd, cTpPnd, cFilPndR, cNumPndR, cNumNfc, cSerNfc)

Local aRet		:= {}
Local cAliasDYM := ""
Local cQuery    := ""       
Local aDYMOrig  := {}                           
Local aDYMPesq  := {}                           
Local aDYMRet   := {}                           
Local cTpIdPd   := ""
Local nSeek     := 0
Local nX        := 0
Local nY        := 0
Local nI        := 0
Local aArea     := GetArea()
Local cTipId    := ""
Local cDetId    := ""
Local nQtdOco   := 0    
Local lPesq     := .F.   
Local lFiltro   := .F.
Local cAliasDYM1:= ""
Local cQuery1   := ""       
Local cPendAnt  := ""

Local lmvpar02  := If(AliasInDic("DYZ"), .T.,.F.)

Default cFilPnd   := ""
Default cNumPnd   := ""                      
Default cTpPnd    := ""                    
Default cFilPndR  := ""
Default cNumPndR  := ""                                                                    
Default cNumNfc   := ""
Default cSerNfc   := ""

Pergunte("TMA541",.F.)

//01- Falta ou 03 - Sobra
cTpPnd   := Iif(cTpPnd == '01', '03' , '01')   

//--- Itens da Identificacao do Produto da Pendencia Selecionada   
//-- Formato do vetor aDYMOrig
//-- [01] = Tipo Identificacao    (DTW_TPIDPD)
//-- [02] = Detalhe Identificacao (DTW_DETALHE)

cAliasDYM := GetNextAlias()
cQuery := " SELECT DYM.DYM_FILPND, DYM.DYM_NUMPND, DYM.DYM_NUMNFC, DYM.DYM_SERNFC, DYM.DYM_TPIDPD, DYM.DYM_DETALH "
cQuery += "   FROM  " + RetSqlName("DYM") + " DYM "
cQuery += "  WHERE DYM.DYM_FILIAL = '" + xFilial("DYM") + "' "
cQuery += "    AND DYM.DYM_FILPND = '" + cFilPnd + "' "
cQuery += "    AND DYM.DYM_NUMPND = '" + cNumPnd + "' "
cQuery += "    AND DYM.DYM_NUMNFC = '" + cNumNfc + "' "
cQuery += "    AND DYM.DYM_SERNFC = '" + cSerNfc + "' "
cQuery += "    AND DYM.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDYM, .F., .T.)

While (cAliasDYM)->(!Eof())
	AAdd( aDYMOrig, { (cAliasDYM)->DYM_TPIDPD,(cAliasDYM)->DYM_DETALH }) 
	cTpIdPd += (cAliasDYM)->DYM_TPIDPD + "|"
	(cAliasDYM)->(DbSkip())
EndDo                                                  
If !Empty(cTpIdPd)
	cTpIdPd := SubStr(cTpIdPd,1,Len(cTpIdPd)-1)
EndIf
(cAliasDYM)->(DbCloseArea())          

//--- Pesquisa na DYM/DYZ registros com os mesmos tipos de identificacao
//-- Formato do vetor aDYMPesq
//-- [01] = Filial Pendencia
//-- [02] = Numero Pendencia
//-- [03] = Numero Nota
//-- [04] = Serie Nota
//-- [05] = Qtde Volumes Pendencia
//-- [06] = Qtde de Itens relacionados com a DYM (aDYMOrig)
//-- [07] = Array Dados da Identificacao do Produto
//-- [07][01] = Tipo Identificacao    (DTW_TPIDPD)
//-- [07][02] = Detalhe Identificacao (DTW_DETALHE)

cAliasDYM := GetNextAlias()
cQuery := " SELECT DYM.DYM_FILPND, DYM.DYM_NUMPND, DYM.DYM_NUMNFC, DYM.DYM_SERNFC, DYM.DYM_TPIDPD, DYM.DYM_DETALH, DYZ.DYZ_QTDOCO "
cQuery += "   FROM  " + RetSqlName("DYM") + " DYM "
cQuery += " INNER JOIN " + RetSqlName("DYZ") + " DYZ "
cQuery += "     ON DYZ.DYZ_FILIAL = '"+xFilial('DYZ')+"'"
cQuery += "    AND DYZ.DYZ_FILPND = DYM.DYM_FILPND "
cQuery += "    AND DYZ.DYZ_NUMPND = DYM.DYM_NUMPND "
cQuery += "    AND DYZ.DYZ_NUMNFC = DYM.DYM_NUMNFC "
cQuery += "    AND DYZ.DYZ_SERNFC = DYM.DYM_SERNFC "
cQuery += "    AND DYZ.DYZ_STACON = '1' "   //Pendente
cQuery += "    AND DYZ.DYZ_TIPPND = '" + cTpPnd + "' "
cQuery += "    AND DYZ.D_E_L_E_T_ = ' ' "
cQuery += "  WHERE DYM.DYM_FILIAL = '" + xFilial("DYM") + "' "
cQuery += "    AND DYM.DYM_TPIDPD IN " + FormatIn(cTpIdPd,"|")
cQuery += "    AND DYM.D_E_L_E_T_ = ' ' "    
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDYM, .F., .T.)

While (cAliasDYM)->(!Eof())                                              
	lFiltro:= .F.                                                        
                            
    //--- Verifica as pendencias que possuem o tipo de identificacao de produto com Filtro Obrigatorio    
	If mv_par01 <> 3 .And. (cAliasDYM)->(DYM_FILPND+DYM_NUMPND+DYM_NUMNFC+DYM_SERNFC) <> cPendAnt 
		cAliasDYM1 := GetNextAlias()
		cQuery1 := " SELECT COUNT(*) NTOTREG"
		cQuery1 += "   FROM  " + RetSqlName("DYM") + " DYM "
		cQuery1 += " INNER JOIN " + RetSqlName("DYL") + " DYL "
		cQuery1 += "     ON DYL.DYL_FILIAL = '"+xFilial('DYL')+"'"
		cQuery1 += "    AND DYL.DYL_TPIDPD = DYM.DYM_TPIDPD
		If mv_par01 == 1  //Obrigatorio
			cQuery1 += "    AND DYL.DYL_FLTOBR = '1' "
		Else                                          
			cQuery1 += "    AND (DYL.DYL_FLTOBR = '2' OR DYL.DYL_FLTOBR = ' ') "
		EndIf	
		cQuery1 += "    AND DYL.D_E_L_E_T_ = ' ' "
		cQuery1 += "  WHERE DYM.DYM_FILIAL = '" + xFilial("DYM") + "' "
		cQuery1 += "    AND DYM.DYM_FILPND = '"+ (cAliasDYM)->DYM_FILPND + "' "
		cQuery1 += "    AND DYM.DYM_NUMPND = '"+ (cAliasDYM)->DYM_NUMPND + "' "
		cQuery1 += "    AND DYM.DYM_NUMNFC = '"+ (cAliasDYM)->DYM_NUMNFC + "' "
		cQuery1 += "    AND DYM.DYM_SERNFC = '"+ (cAliasDYM)->DYM_SERNFC + "' "
		cQuery1 += "    AND DYM.D_E_L_E_T_ = ' ' "
		cQuery1 := ChangeQuery(cQuery1)		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1),cAliasDYM1, .F., .T.)
		If (cAliasDYM1)->NTOTREG > 0
			lFiltro:= .T.
		EndIf
	Else
		lFiltro:= .T.
	EndIf
		
	If lFiltro
		nSeek := AScan(aDYMPesq,{|x|x[1]+x[2]+x[3]+x[4]== (cAliasDYM)->DYM_FILPND+(cAliasDYM)->DYM_NUMPND+(cAliasDYM)->DYM_NUMNFC+(cAliasDYM)->DYM_SERNFC })	
		If	nSeek == 0
		   	AAdd( aDYMPesq, { (cAliasDYM)->DYM_FILPND,(cAliasDYM)->DYM_NUMPND,(cAliasDYM)->DYM_NUMNFC,(cAliasDYM)->DYM_SERNFC,(cAliasDYM)->DYZ_QTDOCO,0, {{(cAliasDYM)->DYM_TPIDPD,(cAliasDYM)->DYM_DETALH} } } )
		Else
			AAdd( aDYMPesq[nSeek,7], {(cAliasDYM)->DYM_TPIDPD,(cAliasDYM)->DYM_DETALH } )		
		EndIf
	EndIf
	
	cPendAnt:= (cAliasDYM)->(DYM_FILPND+DYM_NUMPND+DYM_NUMNFC+DYM_SERNFC)
			
   	(cAliasDYM)->(DbSkip())
EndDo
(cAliasDYM)->(DbCloseArea())          

//--- Comparacao dos Itens aDYMOrig x aDYMPesq
For nX := 1 to Len(aDYMPesq)
	For nY:= 1 to Len(aDYMPesq[nX][7])
      	cTipId:= aDYMPesq[nX][7][nY][1]
    	cDetId:= aDYMPesq[nX][7][nY][2]    	
		
    	nPos := Ascan(aDYMOrig, {|x| x[1] == cTipId})
    	If nPos > 0 
    		If lmvpar02 .and. MV_PAR02 == 1   
	   			If Alltrim(cDetId) $ AllTrim(aDYMOrig[nPos, 2])
					aDYMPesq[nX][6]++
				EndIf
			Else				
				aDYMPesq[nX][6]++							
			Endif				
    	EndIf
	Next
Next

//--- Selecao dos registros que possuem maiores 'combinacoes' (Ordem Decrescente)
If !Empty(aDYMPesq)
	aDYMRet:= ASort(aDYMPesq,,,{|x,y| x[6] > y[6] })
EndIf              

If !Empty(aDYMRet)
	nI:= 0
	For nI := 1 to Len(aDYMRet)
		If aDYMRET[nI][6] > 0
			cFilPndR+= aDYMRet[nI][1] + "|"      	                                          	
			cNumPndR+= aDYMRet[nI][2] + "|"
		Endif      	                                          	
	Next       
	cFilPndR := SubStr(cFilPndR,1,Len(cFilPndR)-1)
	cNumPndR := SubStr(cNumPndR,1,Len(cNumPndR)-1)
EndIf        
                          
RestArea( aArea )

Return (cFilPndR,cNumPndR)   


//===========================================================================================================
/* Retorna a Estrutura do Modelo de Dados (ModelDef ou ViewDef)
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return	oResult  oModel - Modelo de Dados 
//===========================================================================================================
*/
Function TMSA541Mod(cTpModel,oStruCDYZ)

Local aAux:=  {}

Default cTpModel := 'M'
Default oStruCDYZ:= Nil
                                    
If cTpModel == 'M' 
	oStruCDYZ:AddField( ;                    // Ord. Tipo Desc.
	"Qtd.Saldo"                      , ;      // [01]  C   Titulo do campo
	"Qtd.Saldo"                      , ;      // [02]  C   ToolTip do campo
	"DYZ_SALDO"                      , ;      // [03]  C   Id do Field
	'N'                              , ;      // [04]  C   Tipo do campo
	5                                , ;      // [05]  N   Tamanho do campo
	0                                , ;      // [06]  N   Decimal do campo
	NIL                              , ;      // [07]  B   Code-block de validação do campo
	NIL                              , ;      // [08]  B   Code-block de validação When do campo
	NIL                              , ;      // [09]  A   Lista de valores permitido do campo
	NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
	{ || (DYZ->DYZ_QTDVOL - DYZ->DYZ_QTDCON)  }    , ;      // [11]  B   Code-block de inicializacao do campo
	NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
	NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.                              )        // [14]  L   Indica se o campo é virtual

Else      
	oStruCDYZ:AddField( ;
	"DYZ_SALDO"    				 , ;                // [01] Campo
	'33'                         , ;                // [02] Ordem
	"Qtd.Saldo" 				 , ;                // [03] Titulo
	"Qtd.Saldo"     			 , ;                // [04] Descricao
	{"Qtde de Saldo Conciliação"}                   , ;                // [05] Help
	'G'             	         , ;                // [06] Tipo do campo   COMBO, Get ou CHECK
	NIL                          , ;                // [07] Picture
	NIL                          , ;                // [08] PictVar
	NIL                          , ;                // [09] F3
	NIL                          ,;                 // [10] Editavel
	NIL                          , ;                // [11] Folder
	NIL                          , ;                // [12] Group
	NIL                          , ;                // [13] Lista Combo
	NIL                          , ;                // [14] Tam Max Combo  
	NIL							 , ;                // [15] Inic. Browse
	.T.                            )                // [16] Virtual

EndIf	

Return (oStruCDYZ)


//===========================================================================================================
/* Pos Validacao do Formulario
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return		lRet
//===========================================================================================================
*/
Static Function PosVldMdl(oModel)

Local aGetArea	:= GetArea()
Local lRet 		:= .T.
Local nOperation:= oModel:GetOperation()  
Local oMdlStru 	:= oModel:GetModel( "MdGridDYZ" )     
Local nQtdTotCon:= 0  
Local nCount    := 0                                      
Local aSaveLine	:= FWSaveRows()
    
If nOperation == MODEL_OPERATION_UPDATE

	For nCount := 1 To oMdlStru:Length()              	                                              
		oMdlStru:GoLine( nCount )                    	
		If oMdlStru:GetValue( "DYZ_QTDCON" ) > 0
			nQtdTotCon+= oMdlStru:GetValue( "DYZ_QTDCON" )
			
			If Empty(oMdlStru:GetValue( "DYZ_CODMTC"))
				lRet:= .F.
				Exit
			EndIf
		EndIf    
	Next nCount                   
	
	If lRet
		If nQtdTotCon > M->DYZ_QTDVOL    				
			lRet:= .F.	  				
			Help( " ", 1, "TMSA54102" ) // A somatoria da Qtd.Conciliada nao pode ser Maior que a Qtd. de Saldo de Volumes da Pendencia selecionada.
		EndIf  
	Else
		lRet:= .F.
		Help( " ", 1, "TMSA54104" ) // Obrigatorio informar o motivo da conciliacao
	EndIf	
	
	If lRet .And. nQtdTotCon == 0
		lRet:= .F.
		Help( " ", 1, "TMSA54108" ) // Obrigatorio informar a quantidade da conciliação
	EndIf
EndIf	   
FwRestRows( aSaveLine )
RestArea( aGetArea )
Return( lRet )

//===========================================================================================================
/* Gravacao do Formulario
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return		lRet
//===========================================================================================================
*/
Function CommitMdl(oModel)
Local aGetArea	 := GetArea()
Local lRet		 := .T.
Local nCount 	 := 0
Local oMdlStru 	 := oModel:GetModel( "MdGridDYZ" )
Local nOperation := oModel:GetOperation()            
Local cNumCon    := ""
Local nQtdTotCon := 0 
Local nQtdConDel := 0           
Local nRecDYZ    := 0
Local aAreaDYZ   := {}           
Local aSaveLine	 := FWSaveRows()
Local cStaCon    := ""  
Local cCodMtc    := ""
Local cAliasTab  := ""
Local cAliasTab1 := ""
Local cQuery	 := ""
Local cQuery1	 := ""

If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE
	If !Empty(nRecAtual) 
		If Empty(DYZ->DYZ_NUMPND)		                                                            
			DYZ->(DbGoTo(nRecAtual))
		EndIf
	Else 
		lRet:= .F.
	EndIf		  
EndIf
                  
//-- Pendencia Principal	
If nOperation == MODEL_OPERATION_UPDATE
	//--- Posiciona no registro pai DYZ porque neste momento a tabela DYZ esta vindo vazia)	         
	If lRet
		cNumCon:= TMSA541NUM()
		
		nQtdTotCon:= 0
		aAreaDYZ:= DYZ->(GetArea())	
		nRecDYZ := DYZ->( Recno() )
		
		//-- Pendencia Itens
		For nCount := 1 To oMdlStru:Length()              	                                              
			oMdlStru:GoLine( nCount )                    
					
			If oMdlStru:GetValue( "DYZ_QTDCON" ) > 0
				DYZ->( DbSetOrder( 1 ) )  
				If DYZ->( DbSeek( xFilial( "DYZ" ) + oMdlStru:GetValue( "DYZ_FILPND" ) + oMdlStru:GetValue( "DYZ_NUMPND" ) + oMdlStru:GetValue( "DYZ_NUMNFC" ) + oMdlStru:GetValue( "DYZ_SERNFC" ) ) ) 
														
					RecLock( "DYZ", .F. )	  
					DYZ->DYZ_FILCON := cFilAnt
					DYZ->DYZ_NUMCON := cNumCon
					DYZ->DYZ_STACON := StrZero( 4, Len( DYZ->DYZ_STACON ) ) // Conciliado Item
					DYZ->DYZ_QTDCON := oMdlStru:GetValue( "DYZ_QTDCON" )
					DYZ->DYZ_CODMTC := oMdlStru:GetValue( "DYZ_CODMTC" )
					DYZ->DYZ_DATCON := dDataBase
					MsUnLock()
					
					TMS541DUU(DYZ->DYZ_FILPND, DYZ->DYZ_NUMPND, DYZ->DYZ_QTDCON,.F.)
					
					nQtdTotCon+= DYZ->DYZ_QTDCON
					If Empty(cCodMtc)
						cCodMtc   := DYZ->DYZ_CODMTC
					EndIf	
					
	                //-- Se sobrar Saldo, gera um novo registro na DYZ com o saldo restante para conciliacao
					If DYZ->DYZ_QTDVOL > DYZ->DYZ_QTDCON
						TmsCriaDYZ(DYZ->(Recno()))
					EndIf 
											             
				Endif				                      	    
			EndIf     
		Next nCount         	
		RestArea(aAreaDYZ)
		
		DYZ->(DbGoTo(nRecDYZ))
		
		RecLock( "DYZ", .F. )	
		DYZ->DYZ_FILCON := cFilAnt
		DYZ->DYZ_NUMCON := cNumCon
		DYZ->DYZ_CODMTC := cCodMtc    //Primeiro Codigo de Motivo informado na Grid
		DYZ->DYZ_STACON := StrZero( 3, Len( DYZ->DYZ_STACON ) ) // Conciliado
		DYZ->DYZ_QTDCON := nQtdTotCon
		DYZ->DYZ_DATCON := dDataBase
		MsUnLock()                                                               
		
		TMS541DUU(DYZ->DYZ_FILPND, DYZ->DYZ_NUMPND, DYZ->DYZ_QTDCON,.F.)
		
		//-- Gera o registro na DYZ com saldo restante para conciliacao
		If (DYZ->DYZ_QTDVOL - DYZ->DYZ_QTDCON) > 0		
			TmsCriaDYZ(DYZ->(Recno()))
		EndIf
	EndIf	
	
ElseIf nOperation == MODEL_OPERATION_DELETE
	If lRet
		If DYZ->DYZ_STACON == '2'  //Localizado         
			cStaCon:= "'2'"
		Else      
			cStaCon:= "'3','4'"
		EndIf	                                                                                   
		
		//-- Se existir registro de pendencia com Saldo em Aberto, somar no Saldo a quantidade do estorno da conciliação e excluir o registro da conciliacao
		//-- caso contrario, altera o saldo para Zero.
		cAliasTab := GetNextAlias()
		cQuery := " SELECT DYZ_FILCON, DYZ_NUMCON, DYZ_FILPND, DYZ_NUMPND, DYZ_NUMNFC, DYZ_SERNFC, DYZ_QTDCON, R_E_C_N_O_ NRECNO"
		cQuery += "   FROM  " + RetSqlName("DYZ") + " DYZ "
		cQuery += "  WHERE DYZ.DYZ_FILIAL = '" + xFilial("DYZ") + "' "
		cQuery += "    AND DYZ.DYZ_FILCON = '" + DYZ->DYZ_FILCON + "' "
		cQuery += "    AND DYZ.DYZ_NUMCON = '" + DYZ->DYZ_NUMCON + "' "		
		cQuery += "   AND DYZ_STACON IN (" + cStaCon + ") " + CRLF
		cQuery += "    AND DYZ.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)                              
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTab, .F., .T.)
		While (cAliasTab)->(!Eof())                                                 
			lDelCon:= .F.
			
			//--- Verifica se existe item com status 'pendente' de conciliacao para a Pendencia/Nota
			cAliasTab1 := GetNextAlias()
			cQuery1 := " SELECT R_E_C_N_O_ NRECNO1 "
			cQuery1 += "   FROM  " + RetSqlName("DYZ") + " DYZ "
			cQuery1 += "  WHERE DYZ.DYZ_FILIAL = '" + xFilial("DYZ") + "' "
			cQuery1 += "    AND DYZ.DYZ_FILPND = '" + (cAliasTab)->DYZ_FILPND + "' "
			cQuery1 += "    AND DYZ.DYZ_NUMPND = '" + (cAliasTab)->DYZ_NUMPND + "' "		
			cQuery1 += "    AND DYZ.DYZ_NUMNFC = '" + (cAliasTab)->DYZ_NUMNFC + "' "
			cQuery1 += "    AND DYZ.DYZ_SERNFC = '" + (cAliasTab)->DYZ_SERNFC + "' "		
			cQuery1 += "    AND DYZ_STACON = '1' " + CRLF
			cQuery1 += "    AND DYZ.D_E_L_E_T_ = ' ' "
			cQuery1 := ChangeQuery(cQuery1)                              
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1),cAliasTab1, .F., .T.)
			If (cAliasTab1)->(!Eof()) 
				DYZ->( DbGoTo((cAliasTab1)->NRECNO1) )
				RecLock('DYZ',.F.) 
				DYZ->DYZ_QTDVOL+= (cAliasTab)->DYZ_QTDCON              
				DYZ->DYZ_CODMTC:= ""				
				MsUnLock()				
				
				TMS541DUU(DYZ->DYZ_FILPND, DYZ->DYZ_NUMPND, DYZ->DYZ_QTDCON, .T.)
				         
				lDelCon:= .T.				
			EndIf
			(cAliasTab1)->(DbCloseArea())
			
			DYZ->( DbGoTo((cAliasTab)->NRECNO) )						         
			
			RecLock('DYZ',.F.)
			If lDelCon
				nQtdConDel := DYZ->DYZ_QTDVOL
				DYZ->(dbDelete())
			Else 				
				DYZ->DYZ_FILCON	:= ""
				DYZ->DYZ_NUMCON	:= ""
				nQtdConDel			:= DYZ->DYZ_QTDCON
				DYZ->DYZ_QTDCON	-= DYZ->DYZ_QTDCON 
				DYZ->DYZ_STACON	:= "1"
				DYZ->DYZ_CODMTC	:= ""
			Endif									
			DYZ->(MsUnLock())				
			
			TMS541DUU(DYZ->DYZ_FILPND, DYZ->DYZ_NUMPND, nQtdConDel, .T.,.T.)
			
			(cAliasTab)->(DbSkip())
		EndDo                                                  
		(cAliasTab)->(DbCloseArea())          
	EndIf	
EndIf                  

FwRestRows( aSaveLine )
RestArea( aGetArea )
Return( lRet )


//===========================================================================================================
/* Manutencao da Conciliacao de Sobras e Faltas
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return		lRet
//===========================================================================================================
*/
Function TMSA541Mnt(cAlias,nReg,nOpc)

Local aGetArea	:= GetArea()
Local lRet 		:= .T.
Local cQuery    := ""              
Local cStaCon   := ""  

If DYZ->DYZ_STACON == '4'              //Conciliado Item
	cStaCon:= '3'                      //Conciliado
Else
	cStaCon:= DYZ->DYZ_STACON
EndIf    

If cStaCon == '3'    ////Posiciona no registro principal 
	DYZ->(DbSetOrder(2))  
	If !DYZ->(DbSeek(xFilial("DYZ")+ DYZ->DYZ_FILCON + DYZ->DYZ_NUMCON + cStaCon ))   	
		lRet:= .F.
	EndIf
EndIf	

If lRet            
	nRecAtual:= DYZ->(Recno())

	If nOpc = 2   //Visualizar
		FWExecView (, "TMSA541" , MODEL_OPERATION_VIEW , ,{|| .T. }, , , , , , , )
	Else           		        
		If Empty(DYZ->DYZ_NUMCON)
    		lRet:= .F.                                    
		Else
			FWExecView (, "TMSA541" , MODEL_OPERATION_DELETE , ,{|| .T. }, , , , , , , ) 
		EndIf	
	EndIf	
EndIf		
		
RestArea( aGetArea )
Return( lRet )
                       
//===========================================================================================================
/* Validacao da Ativacao do Model
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return		lRet
//===========================================================================================================
*/
Static Function VldActMdl(oModel)
Local aGetArea	:= GetArea()
Local lRet 		:= .T.       
Local nOperation:= oModel:GetOperation()
                
If nOperation == MODEL_OPERATION_UPDATE   
	If DYZ->DYZ_STACON $ ('2|3|4|5|6') 
		Help( "", 1, "TMSA54101" ) // A conciliacao ja esta efetuada!
		lRet:= .F.
	EndIf	
EndIf	

If nOperation == MODEL_OPERATION_DELETE
	If(	Posicione( "DUU", 1, xFilial("DUU")+DYZ->DYZ_FILPND+DYZ->DYZ_NUMPND, "DUU_STATUS") != "1")	
		Help( "", 1, "TMSA54107" )  // A pendência está encerrada											
		lRet := .F.
	Endif
Endif

RestArea( aGetArea )
Return( lRet )

//===========================================================================================================
/* Validacao de campos
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return		lRet
//===========================================================================================================
*/
Function TMSA541Vld(cCampo,lLocaliz)
Local aArea    := GetArea()    
Local lRet     := .T.    
Local oModel   := {}

If !lLocaliz    
	oModel := FWModelActive()
	oModel := oModel:GetModel("MdGridDYZ")        
EndIf	

Default cCampo  := ReadVar()                               
Default lLocaliz:= .F.                   

If lLocaliz
	If cCampo == 'DYZ->DYZ_QTDCON'
		If nQtdCon == 0
			Help( " ", 1, "TMSA54108" ) // Obrigatorio informar a quantidade da conciliação
			lRet:= .F.
			oQtdCon:SetFocus()
		ElseIf nQtdCon > DYZ->DYZ_QTDVOL
			Help( "", 1, "TMSA54103" ) // Quantidade informada é maior que a","Quantidade de Volumes.
			lRet:= .F.
		EndIf
	EndIf
Else
	If 	cCampo == 'M->DYZ_QTDCON'
		If FwFldGet('DYZ_QTDCON') > oModel:GetValue( "DYZ_QTDVOL" ) 
			Help( "", 1, "TMSA54103" ) // Quantidade informada é maior que a","Quantidade de Volumes.
			lRet:= .F.			 
		ElseIf FwFldGet('DYZ_QTDCON') > M->DYZ_SALDO
			Help( "", 1, "TMSA54106" ) // Quantidade informada é maior que a","Quantidade de Saldo da Pendencia Principal
			lRet:= .F.			  
		EndIf
	EndIf	
EndIf	

RestArea(aArea)
Return( lRet )

//===========================================================================================================
/* Validacao de campos
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return		lRet
//===========================================================================================================
*/
Function TMSA541Whe() 

Local lRet   := .T. 
Local cCampo := AllTrim( ReadVar() )

If cCampo == "M->DYZ_CODMTC"
	lRet := M->DYZ_QTDCON > 0  
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PosLinGrd
Rotina de Pos Validacao da Linha 
@author Katia
@since 03/07/14
/*/
//-------------------------------------------------------------------
Static Function PosLinGrd(oModel)
Local aArea    := GetArea()
Local lRet     := .T.
Local oMdlStru := oModel:GetModel( "MdGridDYZ" )     
                                                   
If FwFldGet('DYZ_QTDCON') > 0  
	If Empty(oMdlStru:GetValue( "DYZ_CODMTC" )) 
		Help( "", 1, "TMSA54104" )  // Obrigatorio informar o motivo da conciliacao
		lRet:= .F.	
	EndIf	
EndIf                 

RestArea(aArea)
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA541LOC
Rotina de Localizacao de Pendencia

@author Katia
@since 03/07/14
/*/
//-------------------------------------------------------------------
Function TMSA541LOC()
	Local oDlg         := {}
	Local lRet         := .T.
	Local nOpcao       := 0

	Private oDscDes    := {}
	Private cCodMtc    := IIf (!Empty(DYZ->DYZ_CODMTC), DYY->DYY_CODMTC, CriaVar( "DYY_CODMTC",.F. ) )
	Private cDescricao := CriaVar( "DYY_DESCRI",.F. )  
	Private oQtdCon    := {}
	Private nQtdCon    := 0

	If DYZ->DYZ_STACON <> '1'
		Help( "", 1, "TMSA54105",,STR0003,03,17 ) // Esta opção somente é permitida para Pendencias com status 'Pendente.
		lRet:= .F.
	EndIf	
		
	If lRet
		DEFINE MSDIALOG oDlg TITLE STR0019 From 4,0 To 20,80 OF oMainWnd //Localizacao da Pendencia
	                                                                 
		@  6, 006  SAY RetTitle('DYZ_FILPND')+ ": " SIZE 70,7 PIXEL OF oDlg 
		@  6, 100  SAY RetTitle('DYZ_NUMPND')+ ": " SIZE 70,7 PIXEL OF oDlg 
		@ 21, 006  SAY RetTitle('DYZ_FILDOC')+ ": " SIZE 70,7 PIXEL OF oDlg 
		@ 21, 100  SAY RetTitle('DYZ_DOC')+ ": "    SIZE 70,7 PIXEL OF oDlg 
		@ 21, 200  SAY RetTitle('DYZ_SERIE')+": "   SIZE 70,7 PIXEL OF oDlg 
		@ 36, 006  SAY RetTitle('DYZ_NUMNFC')+':'   SIZE 70,7 PIXEL OF oDlg 
		@ 36, 100  SAY RetTitle('DYZ_SERNFC')+':'   SIZE 70,7 PIXEL OF oDlg 
		@ 36, 200  SAY RetTitle('DYZ_QTDVOL')+':'   SIZE 70,7 PIXEL OF oDlg 
		@ 52, 006  SAY RetTitle('DYZ_CODMTC')+':'   SIZE 70,7 PIXEL OF oDlg 
		@ 52, 100  SAY RetTitle('DYZ_DESMTC')+':'   SIZE 70,7 PIXEL OF oDlg 				
		@ 66, 006  SAY RetTitle('DYZ_QTDCON')+':'   SIZE 70,7 PIXEL OF oDlg 				

		@  5, 045 MSGET DYZ->DYZ_FILPND When .F. SIZE 40,7 PIXEL OF oDlg 
		@  5, 150 MSGET DYZ->DYZ_NUMPND When .F. SIZE 40,7 PIXEL OF oDlg 
		@ 20, 045 MSGET DYZ->DYZ_FILDOC When .F. SIZE 40,7 PIXEL OF oDlg 
		@ 20, 150 MSGET DYZ->DYZ_DOC    When .F. SIZE 40,7 PIXEL OF oDlg 				
		@ 20, 240 MSGET DYZ->DYZ_SERIE  When .F. SIZE 40,7 PIXEL OF oDlg 				
		@ 35, 045 MSGET DYZ->DYZ_NUMNFC When .F. SIZE 40,7 PIXEL OF oDlg 				
		@ 35, 150 MSGET DYZ->DYZ_SERNFC When .F. SIZE 40,7 PIXEL OF oDlg 				
		@ 35, 240 MSGET DYZ->DYZ_QTDVOL When .F. SIZE 40,7 PIXEL OF oDlg 
				
		@ 51, 045 MSGET cCodMtc SIZE 40,7 PIXEL OF oDlg  PIXEL PICTURE "@!" F3 "DYY" VALID TMSA541VlB('CCODMTC') 
	   	@ 51, 150 MSGET oDscDes Var cDescricao When .F. SIZE 80,7 PIXEL OF oDlg 								
                                                                                                 
		@ 65, 045 MSGET oQtdCon Var nQtdcon When !Empty(cDescricao) PIXEL PICTURE "@E 99,999"  VALID nQtdCon > 0 .And. TmsA541Vld('DYZ->DYZ_QTDCON',.T.) SIZE 40,7 OF oDlg PIXEL
		
       DEFINE SBUTTON FROM 090,170 TYPE 1 ACTION (If(TmsA541Vld('DYZ->DYZ_QTDCON',.T.),(nOpcao := 1,oDlg:End()) ,oDlg:End())) ENABLE OF oDlg
		
		DEFINE SBUTTON FROM 090,210 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg

		ACTIVATE MSDIALOG oDlg CENTERED

		If nOpcao == 1
			Begin Transaction
				lRet:= TMSA541GRL()
				
			   If !lRet
    			 DisarmTransaction()
			   EndIf

			End Transaction
		EndIf
    EndIf
    
Return lRet                                                                      

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA541GRL
Rotina para gravar a pendencia Localizada sem Conciliacao
@author Katia
@since 03/07/14
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function TMSA541GRL() 
Local lRet    := .T.
Local cNumDYZ := ""

cNumDYZ:= TMSA541NUM()

RecLock( "DYZ", .F. )	          
DYZ->DYZ_FILCON := cFilAnt
DYZ->DYZ_NUMCON := cNumDYZ
DYZ->DYZ_STACON := StrZero( 2, Len( DYZ->DYZ_STACON ) ) // Localizado
DYZ->DYZ_CODMTC := cCodMtc
DYZ->DYZ_QTDCON := nQtdCon
DYZ->DYZ_DATCON := dDataBase
MsUnLock() 

TMS541DUU(DYZ->DYZ_FILPND, DYZ->DYZ_NUMPND, DYZ->DYZ_QTDCON, .F., .T.)

If DYZ->DYZ_QTDVOL > DYZ->DYZ_QTDCON   //Inclui um novo registro com o saldo de volumes a serem conciliados
	TmsCriaDYZ(DYZ->(Recno()))
EndIf              

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA541VlB
Validacao do registro na tabela selecionada
@author Katia
@since 03/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TMSA541VlB(cCampo)
Local lRet := .T.
Local aArea := GetArea()

Default cCampo:= AllTrim( Upper( ReadVar() ) )

If "CCODMTC" $ cCampo
	lRet := ExistCpo('DYY',CCODMTC)        
	If lRet
		cDescricao:= Posicione( "DYY", 1, xFilial( "DYY" ) + cCodMtc, "DYY_DESCRI" )
		oDscDes:Refresh()
	EndIf		
EndIf	

RestArea( aArea )
Return lRet

       
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA541Doc
Rotina para consultar o Documento
@author Katia
@since 03/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSA541DOC()
Local aArea:= GetArea()

DT6->(DbSetOrder(1))
If DT6->(dBSeek(xFilial("DT6")+DYZ->(DYZ_FILDOC+DYZ_DOC+DYZ_SERIE)))
	cCadastro := "Manutencao de Documentos - Visualizar"
	TMSA500Mnt("DT6",DT6->(Recno()),2)
EndIf

RestArea(aArea)
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSCriaDYZ
Rotina para criar um registro na tabela DYZ
@author Katia
@since 03/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TMSCriaDYZ(nRecDYZ)

Local aCampos:= {}

If Empty(nRecDYZ)
	Return .F.
EndIf

Aadd( aCampos, { "DYZ_FILCON", ''			} )
Aadd( aCampos, { "DYZ_NUMCON",	''			} )	
Aadd( aCampos, { "DYZ_CODMTC", ''			} )
Aadd( aCampos, { "DYZ_DATCON", Ctod("")	} )						
Aadd( aCampos, { "DYZ_QTDCON",  0      	} )
Aadd( aCampos, { "DYZ_STACON", '1'     	} )
Aadd( aCampos, { "DYZ_QTDVOL", DYZ->(DYZ_QTDVOL - DYZ_QTDCON) } )

//copia DYZ						
DYZ->(TmsCopyReg(aCampos))

DYZ->(DbGoTo(nRecDYZ)) //volta para o recno anterior da DYZ

//altera a quantidade de volumes
Reclock("DYZ", .F.)
DYZ->DYZ_QTDVOL := DYZ->DYZ_QTDCON
MsUnlock()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TMS541DUU
Rotina para atualizar quantidades da pendencia 
@author Katia
@since 03/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMS541DUU(cFilPnd, cNumPnd, nQtdCon, lDeleta, lLocaliz,lAtuQtdVol)

Default cFilPnd:= ""
Default cNumPnd:= ""
Default nQtdCon:= 0                                  
Default lDeleta:= .F.                                          
Default lLocaliz:= .F.
Default lAtuQtdVol := .F.

DUU->(DbSetOrder(1))
If DUU->(DbSeek(xFilial("DUU") + cFilPnd + cNumPnd ))
	Reclock("DUU", .F.)
	
	If lDeleta
		If !lAtuQtdVol
			DUU->DUU_QTDCON-= nQtdCon
		EndIf
		If DUU->DUU_QTDCON > 0
			DUU->DUU_QTDSLD+= nQtdCon
		Else
			DUU->DUU_QTDSLD:= 0
		EndIf	
	Else
		DUU->DUU_QTDCON+= nQtdCon
		DUU->DUU_QTDSLD := (DUU->DUU_QTDOCO - DUU->DUU_QTDCON)
	EndIf	                                                  
	If DUU->DUU_QTDCON > 0
		If lLocaliz
			DUU->DUU_STACON:= '4'  //Localizado
		Else	                               
			DUU->DUU_STACON:= '3'  //Conciliado
		EndIf	
	Else
		DUU->DUU_STACON:= '2'  //Pendente
	EndIf	
	MsUnlock()
EndIf	   

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A541VLDQTD
Rotina para validar quantidade de conciliação digitada no campo DYZ_QTDCON
na linha da grid posicionada
@author Ramon Neves
@since 13/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A541VLDQTD(oModel)
Local aArea := getArea()
Local lRet := .T.
Local oModelDYZ := oModel:GetModel("MdGridDYZ")
Local nQtdCon	:= oModelDYZ:GetValue("DYZ_QTDCON")
Local nQtdVol	:= oModelDYZ:GetValue("DYZ_QTDVOL")

If nQtdCon > nQtdVol	 	 
	oModel:SetErrorMessage (,,,,,STR0024,STR0026)  //Quantidade informada é maior que a quantidade de Volumes, "Informe uma quantidade conforme saldo disponível para conciliação"
	lRet := .F.	
Endif

If nQtdCon < 0
	oModel:SetErrorMessage (,,,,,STR0025,STR0027)	 //Valor Inválido, Informe um valor que seja válido	
	lRet := .F.	
Endif

RestArea(aArea)
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA541NUM
Rotina para gerar o Numero da Conciliação
@author Katia
@since 07/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSA541NUM()
Local cRet   := ""
Local aArea  := GetArea()

cRet := GetSx8Num("DYZ","DYZ_NUMCON")
If __lSX8
    ConfirmSX8()
EndIf 

RestArea(aArea)		
Return cRet		

//-------------------------------------------------------------------
/*/{Protheus.doc} LdGridDYM
Rotina para carregar dados da Grid DYM
@author Katia
@since 02/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LdGridDYM( oModel, nRecDYZ, nGridDYM)
Local oStructDYM := oModel:GetStruct()
Local aCamposDYM := aClone(oStructDYM:GetFields())
Local aRet			:= {}
Local cAliasDYM	:= ""
Local cQuery		:= ""
Local cFilPndd	:= ""
Local cNumPnd		:= ""
Local cNumNfc		:= ""
Local cSerNfc		:= ""
Local aArea		:= GetArea()
Local nY			:=0
Local nLinha		:=0 

Default nRecDYZ	:= 0
Default nGridDYM	:= 2 
          
If nGridDYM== 1
	DYZ->(DbGoTo(nRecDYZ))
	cFilPnd:= DYZ->DYZ_FILPND
	cNumPnd:= DYZ->DYZ_NUMPND
	cNumNfc:= DYZ->DYZ_NUMNFC
	cSerNfc:= DYZ->DYZ_SERNFC
Else
	cFilPnd:= FwFldGet("DYZ_FILPND")
	cNumPnd:= FwFldGet("DYZ_NUMPND")
	cNumNfc:= FwFldGet("DYZ_NUMNFC")
	cSerNfc:= FwFldGet("DYZ_SERNFC")
EndIf	
 
cAliasDYM := GetNextAlias()
cQuery := " SELECT DYM.DYM_TPIDPD,  DYM.DYM_DETALH, DYM_TPIDPD "
cQuery += "   FROM  " + RetSqlName("DYM") + " DYM "
cQuery += "  WHERE DYM.DYM_FILIAL = '" + xFilial("DYM") + "' "
cQuery += "    AND DYM.DYM_FILPND = '" + cFilPnd + "' "
cQuery += "    AND DYM.DYM_NUMPND = '" + cNumPnd + "' "
cQuery += "    AND DYM.DYM_NUMNFC = '" + cNumNfc + "' "
cQuery += "    AND DYM.DYM_SERNFC = '" + cSerNfc + "' "
cQuery += "    AND DYM.D_E_L_E_T_ = ' ' "    
cQuery := ChangeQuery(cQuery)
	
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDYM, .F., .T.)
While (cAliasDYM)->(!Eof()) 
	nLinha++
	aAdd(aRet,{nLinha,Array(Len(aCamposDYM))})
	
	cMasc:= ""
	DYL->( DbSetOrder( 1 ) )
	If DYL->( DbSeek( xFilial('DYL') + (cAliasDYM)->DYM_TPIDPD ) )
		cMasc := AllTrim(Tabela("ET",DYL->DYL_CODPIC,.F.))  
	EndIf	
	
	For nY := 1 To lEN(aCamposDYM)
		If !aCamposDYM[nY][MODEL_FIELD_VIRTUAL]
			If (aCamposDYM[nY][MODEL_FIELD_IDFIELD] $ ("DYM_DETALH"))
				aRet[nLinha][2][nY]	:= TRANSFORM((cAliasDYM)->DYM_DETALH,CMASC)
			Else
				aRet[nLinha][2][nY]	:= (cAliasDYM)->&(aCamposDYM[nY][MODEL_FIELD_IDFIELD])
			EndIf					
		Else
			If (aCamposDYM[nY][MODEL_FIELD_IDFIELD] $ ("DYM_DESCRI"))
				aRet[nLinha][2][nY]	:= DYL->DYL_DESCRI
			EndIf

		EndIf
	Next nY
   	(cAliasDYM)->(DbSkip())
EndDo
(cAliasDYM)->(DbCloseArea()) 

RestArea( aArea )
         
Return aRet
