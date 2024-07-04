#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA496.CH"

static cVerReinf := StrTran( SuperGetMv('MV_TAFVLRE',.F.,'') ,'_','')

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA496
Cadastro MVC do R-2099 - Fechamento dos Eventos Periódicos

@author Vitor Siqueira			
@since 15/02/2018
@version 1.0

/*/
//-------------------------------------------------------------------

Function TAFA496()

If TAFAlsInDic( "V0B" )
	BrowseDef()
Else
	Aviso( STR0005, TafAmbInvMsg(), { STR0006 }, 3 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Vitor Siqueira			
@since 15/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao as array
Local aRotina as array

aFuncao := {}
aRotina := {}

aAdd( aFuncao, { "", "TAF496Xml", "1" } )
aAdd( aFuncao, { "", "xFunNewHis( 'V0B', 'TAFA496' )", "3" } )
aAdd( aFuncao, { "", "TAFXmlLote( 'V0B', 'R-2099', 'FechaEvPer', 'TAF496Xml', 5, oBrw)", "5" } )
aAdd( aFuncao, { "", "TafViewLog( '' , 'R-2099', V0B->V0B_PERAPU )", "7" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar"       				ACTION 'VIEWDEF.TAFA496' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Exibir Histórico de Alterações"   ACTION "xFunNewHis( 'V0B', 'TAFA496' )" OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Gerar Xml Reinf"					ACTION 'TAF496Xml()' 	 OPERATION 2 ACCESS 0 //"Gerar Xml Reinf"
	ADD OPTION aRotina TITLE "Gerar Xml em Lote"				ACTION "TAFXmlLote( 'V0B', 'R-2099', 'FechaEvPer', 'TAF496Xml', 5 )" 	 OPERATION 2 ACCESS 0 //"Gerar Xml em Lote"	
Else
	//aRotina	:=	xFunMnuTAF( "TAFA496" , , aFuncao)
	aRotina := TAFMenuReinf( "TAFA496", aFuncao )
//	ADD OPTION aRotina Title "Incluir"       Action 'VIEWDEF.TAFA496' OPERATION 3 ACCESS 0
EndIf


Return (aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Vitor Siqueira			
@since 15/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruV0B  as object
Local oModel	as object

oStruV0B  :=  FWFormStruct( 1, 'V0B' )
oModel    :=  MPFormModel():New( 'TAFA496' ,,,{|oModel| SaveModel(oModel)}) 

//V0B – Ret. Contrib. Prev. - Serviços Tomados
oModel:AddFields('MODEL_V0B', /*cOwner*/, oStruV0B)
oModel:GetModel( "MODEL_V0B" ):SetPrimaryKey( { "V0B_PERAPU" } )


Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Vitor Siqueira			
@since 15/02/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel	as object
Local oStruV0B	as object
Local oStruV0Bp	as object
Local oView		as object

Local cCmpIden	as char
Local cCmpIden2	as char
Local cCmpIden3	as char
Local cCmpIden4	as char
Local cCmpIden5 as char

Local aCmpGrp	as array
Local nI		as numeric
Local cCpoAquis as char

oModel		:= FWLoadModel( 'TAFA496' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
oStruV0B	:= nil
oStruV0Bp	:= Nil
oView		:= FWFormView():New()

cCmpIden	:= ""
cCmpIden2	:= ""
cCmpIden3	:= ""
cCmpIden4	:= ""
cCmpIden5 	:= ""

aCmpGrp		:= {}
nI			:= 0
cCpoAquis	:= iif( alltrim(cVerReinf) >= '10500' .and. TAFColumnPos('V0B_AQUIRU'),'|V0B_AQUIRU','')

oView:SetModel( oModel )

/*-----------------------------------------------------------------------------------
							Estrutura da View do Contato
-------------------------------------------------------------------------------------*/
cCmpIden	:= "V0B_PERAPU|"
cCmpIden2	:= "V0B_NOMCNT|V0B_CPFCNT|V0B_DDDFON|V0B_FONCNT|V0B_EMAIL|"
cCmpIden4	:= "V0B_SERTOM|V0B_SERPRE|V0B_ASSDES|V0B_ASSREP|V0B_COMPRO|V0B_CPRB" + cCpoAquis + "|V0B_PGTOS|V0B_COMMVT|"
cCmpIden5	:= "V0B_PROTUL|" 

cCmpFil		:= cCmpIden+cCmpIden2+cCmpIden3+cCmpIden4
oStruV0B 	:= FwFormStruct( 2, "V0B", { |x| AllTrim( x ) + "|" $ cCmpFil } )
oStruV0Bp	:= FwFormStruct( 2, "V0B", { |x| AllTrim( x ) + "|" $ cCmpIden5 } )

/*-----------------------------------------------------------------
							Grupo de campos
------------------------------------------------------------------*/
//"Fechamento dos Eventos Periódicos"
oStruV0B:AddGroup( "GRP_FECHA_PERIODICOS", STR0001, "", 1 )//"Fechamento dos Eventos Periódicos" 

aCmpGrp := StrToKarr( cCmpIden, "|" )
For nI := 1 to Len( aCmpGrp )
	oStruV0B:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_FECHA_PERIODICOS" )
Next nI

//"Responsável pelas informações"
oStruV0B:AddGroup( "GRP_RESP_INFORMAÇÕES", STR0002, "", 1 )//"Responsável pelas informações" 

aCmpGrp := StrToKarr( cCmpIden2, "|" )
For nI := 1 to Len( aCmpGrp )
	oStruV0B:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_RESP_INFORMAÇÕES" )
Next nI

//"Informações do Fechamento"
oStruV0B:AddGroup( "GRP_INFO_FECHAMENTO", STR0003, "", 1 ) 

aCmpGrp := StrToKarr( cCmpIden4, "|" )
For nI := 1 to Len( aCmpGrp )
	oStruV0B:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_INFO_FECHAMENTO" )
Next nI

oView:AddField( 'VIEW_V0B', oStruV0B , 'MODEL_V0B' )
oView:AddField( 'VIEW_V0Bp', oStruV0Bp, 'MODEL_V0B' )

oView:CreateHorizontalBox( 'PAINEL', 100 )
oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL' )
oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0001 ) //"Fechamento dos Eventos Periódicos" 
oView:CreateHorizontalBox( 'PAINEL_01', 100,,, 'FOLDER_SUPERIOR', 'ABA01' )

oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0004 ) //"Protocolo de Transmissão"
oView:CreateHorizontalBox( 'PAINEL_02', 100,,, 'FOLDER_SUPERIOR', 'ABA02' )


oView:SetOwnerView( 'VIEW_V0B' , 'PAINEL_01')
oView:SetOwnerView( 'VIEW_V0Bp', 'PAINEL_02')


lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruV0B, 'V0B')	
EndIf


Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Vitor Siqueira			
@since 15/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
Local nOperation	as numeric
Local lRetorno		as logical
Local cChvRegAnt	as character
Local lExcPer 		as character 

nOperation	:= oModel:GetOperation()
lExcPer		:= IsInCallStack("TAFExcReg2") 
lRetorno	:= .T.
cChvRegAnt 	:= ""

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_INSERT
		oModel:LoadValue( 'MODEL_V0B', 'V0B_VERSAO', xFunGetVer() ) 
		FwFormCommit( oModel )  
		
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( 'V0B', " " ) 
		FwFormCommit( oModel )	
					
	ElseIf nOperation == MODEL_OPERATION_DELETE 
		//Se o registro ja foi transmitido não permite excluir
		If V0B->V0B_STATUS == "4" .And. !lExcPer
			TAFMsgVldOp(oModel,"4")
			lRetorno := .F.
		Elseif V0B->V0B_STATUS == "2" .And. !lExcPer
			//Não é possível excluir um registro com aguardando validação
			TAFMsgVldOp(oModel,"2")
			lRetorno := .F. 
		Else
			If !Empty(V0B->V0B_VERANT)
				cChvRegAnt := V0B->( V0B_ID + V0B_VERANT )
			EndIf	
			oModel:DeActivate()
			oModel:SetOperation( 5 ) 	
			oModel:Activate()
	
			FwFormCommit( oModel )
			
			If !Empty( cChvRegAnt )
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso a operacao seja uma exclusao...³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nOperation == MODEL_OPERATION_DELETE
					//Funcao para setar o registro anterior como Ativo
					TAFRastro( "V0B", 1, cChvRegAnt, .T. )
				EndIf
		
			EndIf
		EndIf			
	EndIf
End Transaction   
     
Return (lRetorno)

//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF496Xml
Retorna o Xml do Registro Posicionado 
	
@author Vitor Siqueira			
@since 15/02/2018
@version 1.0

@Param:
lJob - Informa se foi chamado por Job

@return
cXml - Estrutura do Xml do Layout S-2099
/*/
//-------------------------------------------------------------------
Function TAF496Xml(cAlias,nRecno,nOpc,lJob, lApi)
Local cXml    	as char
Local cLayout 	as char
Local cReg    	as char
Local cPeriodo	as char
Local lLGPDperm as logical
Local lReinf15	as logical
Local cNameXSD  as char

Default lJob 	:= .F.
Default cAlias 	:= "V0B"
Default nRecno	:= 1
Default nOpc	:= 1
Default lApi 	:= .F.

lLGPDperm	:= TafFisLGPD( "TAFA496" ) 
lReinf15	:= cVerReinf >= '10500' .and. TAFColumnPos('V0B_AQUIRU')
cNameXSD	:= 'Fechamento'

If lLGPDperm .or. lApi

	cLayout 	:= "2099"
	cXml    	:= ""
	cReg    	:= "FechaEvPer" 
	cPeriodo	:= Substr(V0B->V0B_PERAPU,3) +"-"+ Substr(V0B->V0B_PERAPU,1,2) 



	xTafTagGroup("ideRespInf" ,{ { "nmResp"   ,V0B->V0B_NOMCNT	,,.F. }; 
							,  { "cpfResp"  ,V0B->V0B_CPFCNT	,,.F. };
							,  { "telefone" ,AllTrim(V0B->V0B_DDDFON) + StrTran(V0B->V0B_FONCNT,"-","")  ,,.T. };
							,  { "email"    ,V0B->V0B_EMAIL  ,,.T. }};				  	 	 	 
							,  @cXml)
	cXml +=		"<infoFech>"	
	cXml +=			xTafTag("evtServTm"		 ,xFunTrcSN(V0B->V0B_SERTOM,1))
	cXml +=			xTafTag("evtServPr"		 ,xFunTrcSN(V0B->V0B_SERPRE,1))
	cXml +=			xTafTag("evtAssDespRec"	 ,xFunTrcSN(V0B->V0B_ASSDES,1))
	cXml +=			xTafTag("evtAssDespRep"	 ,xFunTrcSN(V0B->V0B_ASSREP,1))
	cXml +=			xTafTag("evtComProd"	 ,xFunTrcSN(V0B->V0B_COMPRO,1))
	cXml +=			xTafTag("evtCPRB"	     ,xFunTrcSN(V0B->V0B_CPRB,1))
	IF lReinf15
		cXml +=			xTafTag("evtAquis"	     ,xFunTrcSN(V0B->V0B_AQUIRU,1)) // R-2055 evtAquis
	endif	
	cXml +=			xTafTag("evtPgtos"	     ,xFunTrcSN(V0B->V0B_PGTOS,1),,.t.)

	If !Empty(V0B->V0B_COMMVT) 
		cXml +=		xTafTag("compSemMovto"	 ,V0B->V0B_COMMVT)
	Endif 

	cXml +=		"</infoFech>"	


	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Estrutura do cabecalho³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cXml := TAFXmlReinf( cXml, "V0B", cLayout, cReg, cPeriodo,, cNameXSD )


	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Executa gravacao do registro³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If !lJob
		xTafGerXml(cXml,cLayout,,,,,,"R-" )
	EndIf

EndIf
	
Return(cXml)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF496Vld
Valida os registros conforme leiaute

@author Vitor Siqueira			
@since 15/02/2018
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF496Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro   as array
Local aDadosUtil as array
Local lValida    as logical   

Default lJob := .F.

aLogErro   := {}
aDadosUtil := {}
lValida    := V0B->V0B_STATUS $ ( " |1" )

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := V0B->( Recno() )

If !lValida
	aAdd( aLogErro, { "V0B_ID", "000305", "V0B", nRecno } ) //Registros que já foram transmitidos ao Fisco, não podem ser validados
Else
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	Begin Transaction 
		If RecLock( "V0B", .F. )
			V0B->V0B_STATUS := cStatus
			V0B->( MsUnlock() )
		EndIf
	End Transaction 
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	xValLogEr( aLogErro )
EndIf

Return(aLogErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Roberto Souza
@since 23/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

	Private	oBrw 	as object 	

	If FunName() == "TAFXREINF"
		lMenuDif 	:= Iif( Type( "lMenuDif" ) == "U", .T., lMenuDif ) 
		cPerAReinf	:= Iif( Type( "cPerAReinf" ) == "U", "", cPerAReinf )

		cFiltro := "V0B_ATIVO == '1'"  + IIf( !Empty(cPerAReinf) ," .AND. V0B_PERAPU =='"+cPerAReinf+"'","" )
	Else
		cFiltro := "V0B_ATIVO == '1'"
	EndIf
	
	oBrw	:= FWmBrowse():New()

	oBrw:SetDescription( "R-2099 - "+STR0001 )	//"Fechamento dos Eventos Periódicos"
	oBrw:SetAlias( 'V0B')
	oBrw:SetMenuDef( 'TAFA496' )	
	oBrw:SetFilterDefault( "V0B_ATIVO == '1'" )

	//DbSelectArea("V0B")
	//Set Filter TO &(cFiltro)
	
	
	If FindFunction("TAFLegReinf")
		TAFLegReinf( "V0B", oBrw)
	Else
		TafLegend(2,"V0B",@oBrw)
	EndIf
	
	oBrw:Activate()

Return( oBrw )
