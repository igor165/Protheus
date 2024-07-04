#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSA270.CH' 
#INCLUDE "FWMVCDEF.CH" 
//===========================================================================================================
/* Rotina de Composicao de Tipo de Veiculo
@author  	Katia
@version 	P11 
@build		700120420A
@since 		18/06/2013
@return	*/
//===========================================================================================================
Function TMSA270()

Local oMBrowse := Nil

Private aRotina:= MenuDef()

oMBrowse:= FwMBrowse():New()
oMBrowse:SetAlias('DU0')
oMBrowse:SetDescription(STR0001)

oMBrowse:Activate()

Return

//===========================================================================================================
/* Retorna o Modelo de dados
@author  	Katia
@version 	P11 
@build		700120420A
@since 		18/06/2013
@return	*/
//===========================================================================================================

Static Function ModelDef()

Local oModel:= Nil

Local oStruCDU0:= FwFormStruct( 1, 'DU0',,)
Local oStruGDYP:= FwFormStruct( 1, 'DYP',,)

oModel:= MpFormModel():New( 'TMSA270', /*bPre*/,{ |oModel| PosVldMdl( oModel ) },/*bCommit*/, /*bCancel*/ )

oModel:SetDescription( STR0001 )

oModel:AddFields('MdFieldDU0', Nil, oStruCDU0)    
                                
oModel:AddGrid('MdGridDYP','MdFieldDU0',oStruGDYP)

oModel:SetRelation('MdGridDYP',{{'DYP_FILIAL', "xFilial('DYP')"},{'DYP_CODROD','DU0_CODROD'},{'DYP_SEQPDG','DU0_SEQPDG'}}, DYP->(IndexKey(1)) )

oModel:SetPrimaryKey({'DU0_FILIAL','DU0_CODROD','DU0_SEQPDG'})

oModel:GetModel("MdFieldDU0"):SetDescription(STR0001)	   

oModel:GetModel('MdGridDYP'):SetOptional(.T.)             

oModel:GetModel('MdGridDYP'):SetUniqueLine( { "DYP_TIPVEI" } )	 //Nao permite informar o mesmo Tipo de Veiculo


Return(oModel)

//===========================================================================================================
/* Retorna a View
@author  	Katia
@version 	P11
@build		700120420A
@since 		18/06/2013
@return	*/
//===========================================================================================================

Static Function ViewDef()

Local oView    := Nil
Local oModel   := FwLoadModel('TMSA270')
Local oStruCDU0:= FwFormStruct( 2, 'DU0' )
Local oStruGDYP:= FwFormStruct( 2, 'DYP' )

oStruGDYP:RemoveField( 'DYP_CODROD' )
oStruGDYP:RemoveField( 'DYP_SEQPDG' )

oView:= FwFormView():New()
oView:SetModel( oModel )

oView:CreateHorizontalBox('Field',030)
oView:CreateHorizontalBox('Grid' ,070)

oView:AddField('VwFieldDU0',oStruCDU0, 'MdFieldDU0')
oView:AddGrid('VwGridDYP'  ,oStruGDYP, 'MdGridDYP')

oView:SetOwnerView('VwFieldDU0', 'Field')
oView:SetOwnerView('VwGridDYP' , 'Grid')

oView:SetCloseOnOk({|| .T. })

oView:AddIncrementField('VwGridDYP','DYP_ITEM')

Return( oView)

//===========================================================================================================
/* Retorna as operações disponiveis 
@author  	Katia
@version 	P11 
@build		700120420A
@since 		07/02/2013
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()

Private aRotina	:= {	{ STR0002 ,'AxPesqui'  ,0,1,0,.F.},;			//'Pesquisar'
						{ STR0003 ,'VIEWDEF.TMSA270' ,0 ,2 ,0 ,NIL},;	//'Visualizar'
						{ STR0004 ,'VIEWDEF.TMSA270' ,0 ,3 ,0 ,NIL},;	//'Incluir'
						{ STR0005 ,'VIEWDEF.TMSA270' ,0 ,4 ,0 ,NIL},;	//'Alterar'
						{ STR0006 ,'VIEWDEF.TMSA270' ,0 ,5 ,0 ,NIL} }	//'Excluir'


If ExistBlock("TMA270MNU")
	ExecBlock("TMA270MNU",.F.,.F.)
EndIf
 
Return( aRotina )

//===========================================================================================================
/* PÓS validacao do Model
/* Rotina de Composicao de Tipo de Veiculo
@author  	Katia
@version 	P11 
@build		700120420A
@since 		18/06/2013
@return	    lRet */  
//===========================================================================================================
Static Function PosVldMdl( oMdl )

Local lRet  :=.T.  
Local aArea := GetArea()
Local nOpcx	:= oMdl:GetOperation()

If  nOpcx == MODEL_OPERATION_DELETE 
	DU2->( DbSetOrder( 2 ) )
	If	DU2->( MsSeek( xFilial('DU2') + M->DU0_CODROD + M->DU0_SEQPDG, .F. ) )
		Help(' ', 1, 'TMSA27001',,STR0007 + DU2->DU2_ROTA,2,7) //"Praca de pedagio relacionada a rota (DU2)." ### "Rota : "
		lRet:= .F.
	EndIf         
Endif	

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA270Seq³ Autor ³ Nava                 ³ Data ³25.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar dados                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA270Seq()

Local cNextSeqPdg
Local nRecno := DU0->( Recno() )

If DU0->( MsSeek( xFilial( "DU0") + M->DU0_CODROD ) )
	DU0->( MsSeek( xFilial( "DU0") + M->DU0_CODROD + 'zz', .T. ) )                                                                   
	DU0->( DbSkip( -1 ) )
	cNextSeqPdg := DU0->( Soma1( DU0->DU0_SEQPDG ) )
Else
	cNextSeqPdg := "01"
Endif

DU0->( DbGoto( nRecno ) )

Return( cNextSeqPdg )

