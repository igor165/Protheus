#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA493.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA493
Cadastro MVC do R-3010 - Receita de Espetáculo Desportivo

@author Vitor Siqueira			
@since 23/03/2018
@version 1.0

/*/
//-------------------------------------------------------------------

Function TAFA493()

If TAFAlsInDic( "V0L" )
	BrowseDef()
Else
	Aviso( STR0010, TafAmbInvMsg(), { STR0011 }, 3 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Vitor Siqueira			
@since 23/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao as array
Local aRotina as array

aFuncao := {}
aRotina := {}

aAdd( aFuncao, { "", "TAF493Xml", "1" } )
aAdd( aFuncao, { "", "xFunNewHis( 'V0L', 'TAFA493' )", "3" } )
aAdd( aFuncao, { "", "TAFXmlLote( 'V0L', 'R-3010', 'EspDesportivo', 'TAF493Xml', 5, oBrw)", "5" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )


If lMenuDif
	ADD OPTION aRotina Title "Visualizar"       				ACTION 'VIEWDEF.TAFA493' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Exibir Histórico de Alterações"   ACTION "xFunNewHis( 'V0L', 'TAFA493' )" OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Gerar Xml Reinf"					ACTION 'TAF493Xml()' 	 OPERATION 2 ACCESS 0 //"Gerar Xml Reinf"
	ADD OPTION aRotina TITLE "Gerar Xml em Lote"				ACTION "TAFXmlLote( 'V0L', 'R-3010', 'EspDesportivo', 'TAF493Xml', 5 )" 	 OPERATION 2 ACCESS 0 //"Gerar Xml em Lote"	
	
Else
	//aRotina	:=	xFunMnuTAF( "TAFA493" , , aFuncao)
	aRotina := TAFMenuReinf( "TAFA493", aFuncao )
//	ADD OPTION aRotina Title "Incluir"       Action 'VIEWDEF.TAFA493' OPERATION 3 ACCESS 0	
//	ADD OPTION aRotina Title "Alterar"       Action 'VIEWDEF.TAFA493' OPERATION 4 ACCESS 0	
EndIf

Return (aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Vitor Siqueira			
@since 23/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruV0L  as object
Local oStruV0M  as object
Local oStruV0N  as object
Local oStruV0O  as object
Local oStruV0P  as object
Local oStruV0Q  as object
Local oStruV0R  as object
Local oModel	as object

oStruV0L  :=  FWFormStruct( 1, 'V0L' )
oStruV0M  :=  FWFormStruct( 1, 'V0M' )
oStruV0N  :=  FWFormStruct( 1, 'V0N' )
oStruV0O  :=  FWFormStruct( 1, 'V0O' )
oStruV0P  :=  FWFormStruct( 1, 'V0P' )
oStruV0Q  :=  FWFormStruct( 1, 'V0Q' )
oStruV0R  :=  FWFormStruct( 1, 'V0R' )
oModel    :=  MPFormModel():New( 'TAFA493' ,,,{|oModel| SaveModel(oModel)}) 

//V0L – Receita de Espetáculo Desp.   
oModel:AddFields('MODEL_V0L', /*cOwner*/, oStruV0L)
oModel:GetModel( "MODEL_V0L" ):SetPrimaryKey( { "V0L_DTAPUR" } )

//V0M – Estabelecimentos
oModel:AddGrid('MODEL_V0M', 'MODEL_V0L', oStruV0M)
oModel:GetModel('MODEL_V0M'):SetUniqueLine({'V0M_TPINSC','V0M_NRINSC'})
oModel:GetModel('MODEL_V0M'):SetMaxLine(25)   

//V0N – Boletim Espetáculo Desportivo
oModel:AddGrid('MODEL_V0N', 'MODEL_V0M', oStruV0N)
oModel:GetModel('MODEL_V0N'):SetUniqueLine({'V0N_NRBOLE'})

//V0O – Receita Ingressos
oModel:AddGrid('MODEL_V0O', 'MODEL_V0N', oStruV0O)
oModel:GetModel('MODEL_V0O'):SetUniqueLine({'V0O_SEQUEN'})
oModel:GetModel('MODEL_V0O'):SetMaxLine(999)   

//V0P - Outras Receitas
oModel:AddGrid('MODEL_V0P', 'MODEL_V0N', oStruV0P)
oModel:GetModel('MODEL_V0P'):SetOptional(.T.)
oModel:GetModel('MODEL_V0P'):SetUniqueLine({'V0P_SEQUEN'})
oModel:GetModel('MODEL_V0P'):SetMaxLine(999)   

//V0Q - Totalização da Receita
oModel:AddGrid('MODEL_V0Q', 'MODEL_V0L', oStruV0Q)
oModel:GetModel('MODEL_V0Q'):SetUniqueLine({'V0Q_SEQUEN'})
oModel:GetModel('MODEL_V0Q'):SetMaxLine(1)   

//V0R - Processos Adm/Jud
oModel:AddGrid('MODEL_V0R', 'MODEL_V0Q', oStruV0R)
oModel:GetModel('MODEL_V0R'):SetOptional(.T.)
oModel:GetModel('MODEL_V0R'):SetUniqueLine({'V0R_TPPROC','V0R_NUMPRO','V0R_CODSUS'})
oModel:GetModel('MODEL_V0R'):SetMaxLine(50)   

oModel:SetRelation("MODEL_V0M",{ {"V0M_FILIAL","xFilial('V0M')"}, {"V0M_ID","V0L_ID"}, {"V0M_VERSAO","V0L_VERSAO"}} , V0M->(IndexKey(1)) )
oModel:SetRelation("MODEL_V0N",{ {"V0N_FILIAL","xFilial('V0N')"}, {"V0N_ID","V0L_ID"}, {"V0N_VERSAO","V0L_VERSAO"}  , {"V0N_TPINSC","V0M_TPINSC"} ,{"V0N_NRINSC","V0M_NRINSC"} } , V0N->(IndexKey(1)) )
oModel:SetRelation("MODEL_V0O",{ {"V0O_FILIAL","xFilial('V0O')"}, {"V0O_ID","V0L_ID"}, {"V0O_VERSAO","V0L_VERSAO"}  , {"V0O_TPINSC","V0M_TPINSC"} ,{"V0O_NRINSC","V0M_NRINSC"}   ,{"V0O_NRBOLE","V0N_NRBOLE"} } , V0O->(IndexKey(1)) )
oModel:SetRelation("MODEL_V0P",{ {"V0P_FILIAL","xFilial('V0P')"}, {"V0P_ID","V0L_ID"}, {"V0P_VERSAO","V0L_VERSAO"}  , {"V0P_TPINSC","V0M_TPINSC"} ,{"V0P_NRINSC","V0M_NRINSC"}   ,{"V0P_NRBOLE","V0N_NRBOLE"} } , V0P->(IndexKey(1)) )
oModel:SetRelation("MODEL_V0Q",{ {"V0Q_FILIAL","xFilial('V0Q')"}, {"V0Q_ID","V0L_ID"}, {"V0Q_VERSAO","V0L_VERSAO"}  , {"V0Q_TPINSC","V0M_TPINSC"} ,{"V0Q_NRINSC","V0M_NRINSC"} } , V0Q->(IndexKey(1)) )
oModel:SetRelation("MODEL_V0R",{ {"V0R_FILIAL","xFilial('V0R')"}, {"V0R_ID","V0L_ID"}, {"V0R_VERSAO","V0L_VERSAO"}  , {"V0R_TPINSC","V0M_TPINSC"} ,{"V0R_NRINSC","V0M_NRINSC"}   ,{"V0R_SEQUEN","V0Q_SEQUEN"}} , V0R->(IndexKey(1)) )



Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Vitor Siqueira			
@since 23/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------

Static Function ViewDef()

Local oModel   	as object
Local oStruV0La	as object
Local oStruV0Lb	as object
Local oStruV0M	as object
Local oStruV0N	as object
Local oStruV0O	as object
Local oStruV0P	as object
Local oStruV0Q	as object
Local oStruV0R	as object
Local oView		as object
Local cCmpFil  	as char
Local nI        as numeric
Local aCmpGrp   as array
Local cGrpCom1	as char
Local cGrpCom2  as char

oModel   	:= FWLoadModel( 'TAFA493' )
oStruV0La	:= Nil
oStruV0Lb	:= Nil
oStruV0M	:= FWFormStruct( 2, 'V0M' )
oStruV0N	:= FWFormStruct( 2, 'V0N' )
oStruV0O	:= FWFormStruct( 2, 'V0O' )
oStruV0P  	:= FWFormStruct( 2, 'V0P' )
oStruV0Q  	:= FWFormStruct( 2, 'V0Q' )
oStruV0R  	:= FWFormStruct( 2, 'V0R' )
oView		:= FWFormView():New()
cCmpFil  	:= ''
nI        	:= 0
aCmpGrp   	:= {}
cGrpCom1  	:= ""
cGrpCom2  	:= ""

oView:SetModel( oModel )
oView:SetContinuousForm(.T.)

//Período de apuração
cGrpCom1  := 'V0L_VERSAO|V0L_VERANT|V0L_PROTPN|V0L_EVENTO|V0L_ATIVO|V0L_DTAPUR|'

cCmpFil   := cGrpCom1 
oStruV0La := FwFormStruct( 2, 'V0L', {|x| AllTrim( x ) + "|" $ cCmpFil } )

//"Protocolo de Transmissão"
cGrpCom2 := 'V0L_PROTUL|'
cCmpFil   := cGrpCom2
oStruV0Lb := FwFormStruct( 2, 'V0L', {|x| AllTrim( x ) + "|" $ cCmpFil } )

/*--------------------------------------------------------------------------------------------
			      					Grupo de campos 	
---------------------------------------------------------------------------------------------*/

oStruV0La:AddGroup( "GRP_COMERCIALIZACAO_01", STR0012, "", 1 ) //Informações de Identificação do Evento

aCmpGrp := StrToKArr(cGrpCom1,"|")
For nI := 1 to Len(aCmpGrp)
	oStruV0La:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_COMERCIALIZACAO_01")
Next nI

	
/*--------------------------------------------------------------------------------------------
									Estrutura da View
---------------------------------------------------------------------------------------------*/

oView:AddField( "VIEW_V0La", oStruV0La, "MODEL_V0L" )
oView:AddField( "VIEW_V0Lb", oStruV0Lb, "MODEL_V0L" )

oView:AddGrid ( "VIEW_V0M", oStruV0M, "MODEL_V0M" )
oView:AddGrid ( "VIEW_V0N", oStruV0N, "MODEL_V0N" )
oView:AddGrid ( "VIEW_V0O", oStruV0O, 'MODEL_V0O' )
oView:AddGrid ( "VIEW_V0P", oStruV0P, 'MODEL_V0P' )
oView:AddGrid ( "VIEW_V0Q", oStruV0Q, 'MODEL_V0Q' )
oView:AddGrid ( "VIEW_V0R", oStruV0R, 'MODEL_V0R' )

oView:AddIncrementField( 'VIEW_V0N', 'V0N_SEQUEN' )
oView:AddIncrementField( 'VIEW_V0O', 'V0O_SEQUEN' )
oView:AddIncrementField( 'VIEW_V0P', 'V0P_SEQUEN' ) 
oView:AddIncrementField( 'VIEW_V0Q', 'V0Q_SEQUEN' ) 

oView:EnableTitleView("MODEL_V0R",STR0007) //"Processos Administrativos/Judiciais"


/*-----------------------------------------------------------------------------------
								Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

//////////////////////////////////////////////////////////////////////////////////

oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0001) //"Receita de Espetáculo Desportivo"
oView:CreateHorizontalBox("V0La",15,,,"FOLDER_PRINCIPAL","ABA01") 

oView:CreateHorizontalBox("PAINEL_TPCOM",03,,,"FOLDER_PRINCIPAL","ABA01")
oView:CreateFolder( 'FOLDER_TPCOM', 'PAINEL_TPCOM' )

oView:AddSheet( 'FOLDER_TPCOM', 'ABA01', STR0002 ) //"Estabelecimentos"
oView:CreateHorizontalBox ( 'V0M', 30,,, 'FOLDER_TPCOM'  , 'ABA01' )

oView:CreateHorizontalBox("PAINEL_PRINCIPAL2",40,,,"FOLDER_TPCOM","ABA01")
oView:CreateFolder("FOLDER_PRINCIPAL2","PAINEL_PRINCIPAL2")

oView:AddSheet("FOLDER_PRINCIPAL2","ABA01",STR0003) //"Boletim do Espetáculo Desportivo" 
oView:CreateHorizontalBox("V0N",50,,,"FOLDER_PRINCIPAL2","ABA01") 

oView:CreateHorizontalBox("PAINEL_PRINCIPAL3",50,,,"FOLDER_PRINCIPAL2","ABA01")
oView:CreateFolder("FOLDER_PRINCIPAL3","PAINEL_PRINCIPAL3")

oView:AddSheet( 'FOLDER_PRINCIPAL3', 'ABA01', STR0004 ) //"Receita de Venda de Ingressos" 
oView:CreateHorizontalBox ( 'V0O', 100,,, 'FOLDER_PRINCIPAL3'  , 'ABA01' )

oView:AddSheet( 'FOLDER_PRINCIPAL3', 'ABA02', STR0005 ) //"Outras Receitas do Espetáculo"
oView:CreateHorizontalBox ( 'V0P', 100,,, 'FOLDER_PRINCIPAL3'  , 'ABA02' )

oView:AddSheet("FOLDER_PRINCIPAL2","ABA02",STR0006) //"Totalização da receita" 
oView:CreateHorizontalBox('V0Q', 50,,, 'FOLDER_PRINCIPAL2'  , 'ABA02' )
oView:CreateHorizontalBox('V0R', 50,,, 'FOLDER_PRINCIPAL2'  , 'ABA02' )


oView:AddSheet("FOLDER_PRINCIPAL","ABA02",STR0008)//"Recibo de Transmissão" 
oView:CreateHorizontalBox("V0Lb",100,,,'FOLDER_PRINCIPAL',"ABA02")

//////////////////////////////////////////////////////////////////////////////////

/*-----------------------------------------------------------------------------------
							Amarração para exibição das informações
-------------------------------------------------------------------------------------*/

oView:SetOwnerView( "VIEW_V0La", "V0La")
oView:SetOwnerView( "VIEW_V0Lb", "V0Lb")
oView:SetOwnerView( "VIEW_V0M",  "V0M" )
oView:SetOwnerView( "VIEW_V0N",  "V0N" )
oView:SetOwnerView( "VIEW_V0O",  "V0O" )
oView:SetOwnerView( "VIEW_V0P",  "V0P" )
oView:SetOwnerView( "VIEW_V0Q",  "V0Q" )
oView:SetOwnerView( "VIEW_V0R",  "V0R" )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruV0La,"V0L")
EndIf

oStruV0R:RemoveField('V0R_IDSUSP')

Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Vitor Siqueira			
@since 23/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local nOperation	as numeric
	Local lRetorno		as logical

	nOperation	:= oModel:GetOperation()
	lRetorno	:= .T.

	FWFormCommit( oModel )
     
Return (lRetorno)

//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF493Xml
Retorna o Xml do Registro Posicionado 
	
@author Vitor Siqueira			
@since 23/03/2018
@version 1.0

@Param:
lJob - Informa se foi chamado por Job

@return
cXml - Estrutura do Xml do Layout S-3010
/*/
//-------------------------------------------------------------------
Function TAF493Xml(cAlias,nRecno,nOpc,lJob)
Local cXml    	as char
Local cLayout 	as char
Local cReg    	as char
Local cPeriodo	as char
Local xPeriodo	as char
Local cNumDoc	as char
Local cNameXSD  as char

Default lJob 	:= .F.
Default cAlias 	:= "V0L"
Default nRecno	:= 1
Default nOpc	:= 1

cLayout 	:= "3010"
cXml    	:= ""
cReg    	:= "EspDesportivo" 
cPeriodo	:= ""//Substr(V0L->V0L_PERAPU,3) + "-" + Substr(V0L->V0L_PERAPU,1,2) 
If TafColumnPos("V0L_DTAPUR")
	xPeriodo	:= DTos( V0L->V0L_DTAPUR)
	xPeriodo 	:= Substr(xPeriodo,1,4)+"-"+Substr(xPeriodo,5,2)+"-"+Substr(xPeriodo,7,5)
Else
	xPeriodo	:= cPeriodo
EndIf
cNumDoc		:= ""
cNameXSD	:= "EspDesportivo"

DBSelectArea("V0M")  
V0M->(DBSetOrder(1))

DBSelectArea("V0N")  
V0N->(DBSetOrder(1))

DBSelectArea("V0O") 
V0O->(DBSetOrder(1))

DBSelectArea("V0P")  
V0P->(DBSetOrder(1))

DBSelectArea("V0Q")  
V0Q->(DBSetOrder(1))

DBSelectArea("V0R")  
V0R->(DBSetOrder(1))

If V0M->( MsSeek( xFilial( "V0M" ) + V0L->( V0L_ID + V0L_VERSAO) ) )	
	While V0M->(!Eof()) .And. V0M->( V0M_FILIAL + V0M_ID + V0M_VERSAO) == V0L->( V0L_FILIAL + V0L_ID + V0L_VERSAO)
		cXml +=		"<ideEstab>"
		cXml +=				xTafTag("tpInscEstab"  ,V0M->V0M_TPINSC)
		cXml +=				xTafTag("nrInscEstab"  ,V0M->V0M_NRINSC)

		If V0N->( MsSeek( xFilial( "V0N" ) + V0M->( V0M_ID + V0M_VERSAO + V0M_TPINSC + V0M_NRINSC) ) )	
			While V0N->(!Eof()) .And. V0N->( V0N_FILIAL + V0N_ID + V0N_VERSAO + V0N_TPINSC + V0N_NRINSC) == V0M->( V0M_FILIAL + V0M_ID + V0M_VERSAO + V0M_TPINSC + V0M_NRINSC)
				cUfEv := Posicione("C09",3,xFilial("C09")+V0N->V0N_IDUF,"C09_CODIGO")
				cXml +=		"<boletim>"
				cXml +=			xTafTag("nrBoletim"			,V0N->V0N_NRBOLE)
				cXml +=			xTafTag("tpCompeticao"		,V0N->V0N_TPCOMP)
				cXml +=			xTafTag("categEvento"		,V0N->V0N_CATEVT)
				cXml +=			xTafTag("modDesportiva"		,V0N->V0N_MODDES)
				cXml +=			xTafTag("nomeCompeticao"	,V0N->V0N_NOMCOM)
				cXml +=			xTafTag("cnpjMandante"		,V0N->V0N_CNPJMA)
				cXml +=			xTafTag("cnpjVisitante"		,V0N->V0N_CNPJVI ,,.T.)
				cXml +=			xTafTag("nomeVisitante"		,V0N->V0N_NOMVIS ,,.T.)
				cXml +=			xTafTag("pracaDesportiva"	,V0N->V0N_PRACAD)
				cXml +=			xTafTag("codMunic"			,cUfEv+V0N->V0N_CODMUN ,,.T.)
				cXml +=			xTafTag("uf"				,V0N->V0N_UF)
				cXml +=			xTafTag("qtdePagantes"		,V0N->V0N_QTDPAG)
				cXml +=			xTafTag("qtdeNaoPagantes"	,V0N->V0N_QTDNPA)
				
				If V0O->( MsSeek( xFilial( "V0O" ) + V0N->( V0N_ID + V0N_VERSAO + V0N_TPINSC + V0N_NRINSC + V0N_NRBOLE) ) )	
					While V0O->(!Eof()) .And. V0N->( V0N_FILIAL + V0N_ID + V0N_VERSAO + V0N_TPINSC + V0N_NRINSC + V0N_NRBOLE) == V0O->( V0O_FILIAL + V0O_ID + V0O_VERSAO + V0O_TPINSC + V0O_NRINSC + V0O_NRBOLE)
						cXml +=		"<receitaIngressos>"
						cXml +=			xTafTag("tpIngresso"		,V0O->V0O_TPINGR)
						cXml +=			xTafTag("descIngr"			,V0O->V0O_DESCIN)
						cXml +=			xTafTag("qtdeIngrVenda"		,V0O->V0O_QTDING)
						cXml +=			xTafTag("qtdeIngrVendidos"	,V0O->V0O_QTDIVE)
						cXml +=			xTafTag("qtdeIngrDev"		,V0O->V0O_QTDIDE)
						cXml +=			xTafTag("precoIndiv"		,TafFReinfNum(V0O->V0O_PRECOI))
						cXml +=			xTafTag("vlrTotal"			,TafFReinfNum(V0O->V0O_VLRTOT))
						cXml +=		"</receitaIngressos>"
						
						V0O->( DbSkip() )								
					EndDo
				EndIf
				
				
				If V0P->( MsSeek( xFilial( "V0P" ) + V0N->( V0N_ID + V0N_VERSAO + V0N_TPINSC + V0N_NRINSC + V0N_NRBOLE) ) )	
					While V0P->(!Eof()) .And. V0N->( V0N_FILIAL + V0N_ID + V0N_VERSAO + V0N_TPINSC + V0N_NRINSC + V0N_NRBOLE) == V0P->( V0P_FILIAL + V0P_ID + V0P_VERSAO + V0P_TPINSC + V0P_NRINSC + V0P_NRBOLE)
						
						xTafTagGroup("outrasReceitas"   ,{ { "tpReceita"		,V0P->V0P_TPRECE				    ,,.F. }; 
										 		 		,  { "vlrReceita"		,TafFReinfNum(V0P->V0P_VLRREC)		,,.F. };
										 		 		,  { "descReceita"		,V0P->V0P_DESREC 					,,.F. }};	
				   	  		 			 		 		,  @cXml)
						
						V0P->( DbSkip() )								
					EndDo
				EndIf

				cXml +=		"</boletim>"			
				V0N->( DbSkip() )								
			EndDo
		EndIf
		
		If V0Q->( MsSeek( xFilial( "V0Q" ) + V0M->( V0M_ID + V0M_VERSAO + V0M_TPINSC + V0M_NRINSC) ) )	
			While V0Q->(!Eof()) .And. V0Q->( V0Q_FILIAL + V0Q_ID + V0Q_VERSAO + V0Q_TPINSC + V0Q_NRINSC) == V0M->( V0M_FILIAL + V0M_ID + V0M_VERSAO + V0M_TPINSC + V0M_NRINSC)
				cXml +=		"<receitaTotal>"
				cXml +=			xTafTag("vlrReceitaTotal"	,TafFReinfNum(V0Q->V0Q_VLRTOT ))
				cXml +=			xTafTag("vlrCP"				,TafFReinfNum(V0Q->V0Q_VLRCP  ))
				cXml +=			xTafTag("vlrCPSuspTotal"	,TafFReinfNum(V0Q->V0Q_VLRCPS ) ,,.T.)
				cXml +=			xTafTag("vlrReceitaClubes"	,TafFReinfNum(V0Q->V0Q_VLRRCL ))
				cXml +=			xTafTag("vlrRetParc"		,TafFReinfNum(V0Q->V0Q_VLRRET ))												
				
				If V0R->( MsSeek( xFilial( "V0R" ) + V0Q->( V0Q_ID + V0Q_VERSAO + V0Q_TPINSC + V0Q_NRINSC + V0Q_SEQUEN) ) )	
					While V0R->(!Eof()) .And. V0R->( V0R_FILIAL + V0R_ID + V0R_VERSAO + V0R_TPINSC + V0R_NRINSC + V0R_SEQUEN) == V0Q->( V0Q_FILIAL + V0Q_ID + V0Q_VERSAO + V0Q_TPINSC + V0Q_NRINSC + V0Q_SEQUEN)
						
						xTafTagGroup("infoProc"  ,{ { "tpProc"		,V0R->V0R_TPPROC				    ,,.F. }; 
										 		 ,  { "nrProc"		,V0R->V0R_NUMPRO				    ,,.F. };
										 		 ,	{ "codSusp"		,V0R->V0R_CODSUS 					,,.T. };
				   	  		 			 		 ,  { "vlrCPSusp"	,TafFReinfNum(V0R->V0R_VLRSUS)  	,,.F. }};	
				   	  		 			 		 ,  @cXml)
						
						V0R->( DbSkip() )								
					EndDo
				EndIf
				
				
				cXml +=		"</receitaTotal>"	
				V0Q->( DbSkip() )								
			EndDo
		EndIf
	
	cXml +=		"</ideEstab>"	
	V0M->( DbSkip() )								
	EndDo
EndIf


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Estrutura do cabecalho³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cXml := TAFXmlReinf( cXml, "V0L", cLayout, cReg, xPeriodo,, cNameXSD)


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Executa gravacao do registro³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lJob
	xTafGerXml(cXml,cLayout,,,,,,"R-" )
EndIf

	
Return(cXml)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF493Vld

@author Vitor Siqueira			
@since 23/03/2018
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF493Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro   as array
Local aDadosUtil as array
Local lValida    as logical   

Default lJob := .F.

aLogErro   := {}
aDadosUtil := {}
lValida    := V0L->V0L_STATUS $ ( " |1" )

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := V0L->( Recno() )

If !lValida
	aAdd( aLogErro, { "V0L_ID", "000305", "V0L", nRecno } ) //Registros que já foram transmitidos ao Fisco, não podem ser validados
Else
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	Begin Transaction 
		If RecLock( "V0L", .F. )
			V0L->V0L_STATUS := cStatus
			V0L->( MsUnlock() )
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
/*/{Protheus.doc} GerarEvtExc
@type			function
@description	Função com o objetivo de gerar o Evento de Exclusão.
@author			Vitor Henrique Ferreira
@since			27/03/2018
@version		1.0
@param			oModel	-	Modelo de dados
@param			nRecno	-	Número do registro
@param			lRotExc	-	Variável que controla se a function é chamada pelo TafIntegraESocial
/*/
//---------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

Local oModelV0L		as object
Local oModelV0M		as object
Local oModelV0N		as object
Local oModelV0O		as object
Local oModelV0P		as object
Local oModelV0Q		as object
Local oModelV0R		as object
Local cVerAnt		as char
Local cRecibo		as char
Local cVersao		as char
Local nI			as numeric
Local nV0M			as numeric
Local nV0N			as numeric
Local nV0O			as numeric
Local nV0P			as numeric
Local nV0Q			as numeric
Local nV0R			as numeric
Local nV0NAdd		as numeric
Local nV0OAdd		as numeric
Local nV0PAdd		as numeric
Local nV0QAdd		as numeric
Local nV0RAdd		as numeric
Local aGravaV0L		as array
Local aGravaV0M		as array
Local aGravaV0N		as array
Local aGravaV0O		as array
Local aGravaV0P		as array
Local aGravaV0Q		as array
Local aGravaV0R		as array

oModelV0L	:=	Nil
oModelV0M	:=	Nil
oModelV0N	:=	Nil
oModelV0O	:=	Nil
oModelV0P	:=	Nil
oModelV0Q	:=	Nil
oModelV0R	:=	Nil
cVerAnt		:=	""
cRecibo		:=	""
cVersao		:=	""
nI			:=	0
nV0M		:=	0
nV0N		:=	0
nV0O		:=	0
nV0P		:=	0
nV0Q		:=	0
nV0R		:=	0
nV0NAdd		:=	0
nV0OAdd		:=	0
nV0PAdd		:=	0
nV0QAdd		:=	0
nV0RAdd		:=	0
aGravaV0L	:=	{}
aGravaV0M	:=	{}
aGravaV0N	:=	{}
aGravaV0O	:=	{}
aGravaV0P	:=	{}
aGravaV0Q	:=	{}
aGravaV0R	:=	{}


Begin Transaction

	DBSelectArea( "V0L" )
	V0L->( DBGoTo( nRecno ) )

	oModelV0L := oModel:GetModel( "MODEL_V0L" )
	oModelV0M := oModel:GetModel( "MODEL_V0M" )
	oModelV0N := oModel:GetModel( "MODEL_V0N" )
	oModelV0O := oModel:GetModel( "MODEL_V0O" )
	oModelV0P := oModel:GetModel( "MODEL_V0P" )
	oModelV0Q := oModel:GetModel( "MODEL_V0Q" )
	oModelV0R := oModel:GetModel( "MODEL_V0R" )

	//************************************
	//Informações para gravação do rastro
	//************************************
	cVerAnt := oModelV0L:GetValue( "V0L_VERSAO" )
	cRecibo := oModelV0L:GetValue( "V0L_PROTUL" )

	//****************************************************************************************************************
	//Armazeno as informações que foram modificadas na tela, para utilização em operação de inclusão de novo registro
	//****************************************************************************************************************
	For nI := 1 to Len( oModelV0L:aDataModel[1] )
		aAdd( aGravaV0L, { oModelV0L:aDataModel[1,nI,1], oModelV0L:aDataModel[1,nI,2] } )
	Next nI

	//V0M
	If V0M->( MsSeek( xFilial( "V0M" ) + V0L->( V0L_ID + V0L_VERSAO ) ) )

		For nV0M := 1 to oModel:GetModel( "MODEL_V0M" ):Length()
			oModel:GetModel( "MODEL_V0M" ):GoLine( nV0M )

			If !oModel:GetModel( "MODEL_V0M" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V0M" ):IsDeleted()
				aAdd( aGravaV0M, {	oModelV0M:GetValue( "V0M_TPINSC"  ),;
									oModelV0M:GetValue( "V0M_NRINSC" )} )

				//V0N
				For nV0N := 1 to oModel:GetModel( "MODEL_V0N" ):Length()
					oModel:GetModel( "MODEL_V0N" ):GoLine( nV0N )
					If !oModel:GetModel( "MODEL_V0N" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V0N" ):IsDeleted()
						aAdd( aGravaV0N, {	oModelV0M:GetValue( "V0M_TPINSC" ),; 
											oModelV0M:GetValue( "V0M_NRINSC" ),;
											oModelV0N:GetValue( "V0N_NRBOLE" ),; 
											oModelV0N:GetValue( "V0N_TPCOMP" ),;
											oModelV0N:GetValue( "V0N_CATEVT" ),;
											oModelV0N:GetValue( "V0N_MODDES" ),;
											oModelV0N:GetValue( "V0N_NOMCOM" ),;
											oModelV0N:GetValue( "V0N_CNPJMA" ),;
											oModelV0N:GetValue( "V0N_CNPJVI" ),;
											oModelV0N:GetValue( "V0N_NOMVIS" ),;
											oModelV0N:GetValue( "V0N_PRACAD" ),;
											oModelV0N:GetValue( "V0N_IDCMUN" ),;
											oModelV0N:GetValue( "V0N_CODMUN" ),;
											oModelV0N:GetValue( "V0N_IDUF" 	 ),;
											oModelV0N:GetValue( "V0N_UF" 	 ),;
											oModelV0N:GetValue( "V0N_QTDPAG" ),;
											oModelV0N:GetValue( "V0N_QTDNPA" ) } )
											
											
						//V0O
						For nV0O := 1 to oModel:GetModel( "MODEL_V0O" ):Length()
							oModel:GetModel( "MODEL_V0O" ):GoLine( nV0O )
							If !oModel:GetModel( "MODEL_V0O" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V0O" ):IsDeleted()
								aAdd( aGravaV0O, {	oModelV0M:GetValue( "V0M_TPINSC" ),; 
													oModelV0M:GetValue( "V0M_NRINSC" ),;
													oModelV0N:GetValue( "V0N_NRBOLE" ),; 
													oModelV0O:GetValue( "V0O_SEQUEN" ),;
													oModelV0O:GetValue( "V0O_TPINGR" ),;
													oModelV0O:GetValue( "V0O_DESCIN" ),;
													oModelV0O:GetValue( "V0O_QTDING" ),;
													oModelV0O:GetValue( "V0O_QTDIVE" ),;
													oModelV0O:GetValue( "V0O_QTDIDE" ),;
													oModelV0O:GetValue( "V0O_PRECOI" ),;
													oModelV0O:GetValue( "V0O_VLRTOT" ) } )
							EndIf
						Next nV0O	
						
						//V0P
						For nV0P := 1 to oModel:GetModel( "MODEL_V0P" ):Length()
							oModel:GetModel( "MODEL_V0P" ):GoLine( nV0P )
							If !oModel:GetModel( "MODEL_V0P" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V0P" ):IsDeleted()
								aAdd( aGravaV0P, {	oModelV0M:GetValue( "V0M_TPINSC" ),; 
													oModelV0M:GetValue( "V0M_NRINSC" ),;
													oModelV0N:GetValue( "V0N_NRBOLE" ),; 
													oModelV0P:GetValue( "V0P_SEQUEN" ),;
													oModelV0P:GetValue( "V0P_TPRECE" ),;
													oModelV0P:GetValue( "V0P_VLRREC" ),;
													oModelV0P:GetValue( "V0P_DESREC" ) } )
							EndIf
						Next nV0P															
					EndIf
				Next nV0N
				
				
				//V0Q	
				For nV0Q := 1 to oModel:GetModel( "MODEL_V0Q" ):Length()
					oModel:GetModel( "MODEL_V0Q" ):GoLine( nV0Q )
					If !oModel:GetModel( "MODEL_V0Q" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V0Q" ):IsDeleted()
						aAdd( aGravaV0Q, {	oModelV0M:GetValue( "V0M_TPINSC" ),; 
											oModelV0M:GetValue( "V0M_NRINSC" ),;
											oModelV0Q:GetValue( "V0Q_SEQUEN" ),; 
											oModelV0Q:GetValue( "V0Q_VLRTOT" ),;
											oModelV0Q:GetValue( "V0Q_VLRCP"  ),;
											oModelV0Q:GetValue( "V0Q_VLRCPS" ),;
											oModelV0Q:GetValue( "V0Q_VLRRCL" ),;
											oModelV0Q:GetValue( "V0Q_VLRRET" ) } )
											
				
						//V0R
						For nV0R := 1 to oModel:GetModel( "MODEL_V0R" ):Length()
							oModel:GetModel( "MODEL_V0R" ):GoLine( nV0R )
							If !oModel:GetModel( "MODEL_V0R" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V0R" ):IsDeleted()
								aAdd( aGravaV0R, {	oModelV0M:GetValue( "V0M_TPINSC" ),; 
													oModelV0M:GetValue( "V0M_NRINSC" ),;
													oModelV0Q:GetValue( "V0Q_SEQUEN" ),; 
													oModelV0R:GetValue( "V0R_IDPROC" ),;
													oModelV0R:GetValue( "V0R_TPPROC" ),;
													oModelV0R:GetValue( "V0R_NUMPRO" ),;
													oModelV0R:GetValue( "V0R_CODSUS" ),;
													oModelV0R:GetValue( "V0R_IDSUSP" ),;
													oModelV0R:GetValue( "V0R_VLRSUS" ) } )
							EndIf
						Next nV0R	
		
					EndIf
				Next nV0Q			
				
			EndIf
		Next nV0M
	EndIf
	
	//*****************************
	//Seto o registro como Inativo
	//*****************************
	FAltRegAnt( "V0L", "2" )

	//**************************************
	//Operação de Inclusão de novo registro
	//**************************************
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	//********************************************************************************
	//Inclusão do novo registro já considerando as informações alteradas pelo usuário
	//********************************************************************************
	For nI := 1 to Len( aGravaV0L )
		oModel:LoadValue( "MODEL_V0L", aGravaV0L[nI,1], aGravaV0L[nI,2] )
	Next nI

	//V0M
	For nV0M := 1 to Len( aGravaV0M )

		oModel:GetModel( "MODEL_V0M" ):LVALID := .T.

		If nV0M > 1
			oModel:GetModel( "MODEL_V0M" ):AddLine()
		EndIf	

		oModel:LoadValue( "MODEL_V0M", "V0M_TPINSC" , aGravaV0M[nV0M][1] )
		oModel:LoadValue( "MODEL_V0M", "V0M_NRINSC" , aGravaV0M[nV0M][2] )		
		
		//V0N
		nV0NAdd := 1
		For nV0N := 1 to Len( aGravaV0N )
			If aGravaV0M[nV0M][1] == aGravaV0N[nV0N][1]  .And. aGravaV0M[nV0M][2] == aGravaV0N[nV0N][2] 

				oModel:GetModel( "MODEL_V0N" ):LVALID := .T.

				If nV0NAdd > 1
					oModel:GetModel( "MODEL_V0N" ):AddLine()
				EndIf
				
				
				oModel:LoadValue( "MODEL_V0N", "V0N_NRBOLE" , aGravaV0N[nV0N][3] )
				oModel:LoadValue( "MODEL_V0N", "V0N_TPCOMP" , aGravaV0N[nV0N][4] )
				oModel:LoadValue( "MODEL_V0N", "V0N_CATEVT" , aGravaV0N[nV0N][5] )
				oModel:LoadValue( "MODEL_V0N", "V0N_MODDES" , aGravaV0N[nV0N][6] )
				oModel:LoadValue( "MODEL_V0N", "V0N_NOMCOM" , aGravaV0N[nV0N][7] )
				oModel:LoadValue( "MODEL_V0N", "V0N_CNPJMA" , aGravaV0N[nV0N][8] )
				oModel:LoadValue( "MODEL_V0N", "V0N_CNPJVI" , aGravaV0N[nV0N][9] )
				oModel:LoadValue( "MODEL_V0N", "V0N_NOMVIS" , aGravaV0N[nV0N][10] )
				oModel:LoadValue( "MODEL_V0N", "V0N_PRACAD" , aGravaV0N[nV0N][11] )
				oModel:LoadValue( "MODEL_V0N", "V0N_IDCMUN" , aGravaV0N[nV0N][12] )
				oModel:LoadValue( "MODEL_V0N", "V0N_CODMUN" , aGravaV0N[nV0N][13] )
				oModel:LoadValue( "MODEL_V0N", "V0N_IDUF" 	, aGravaV0N[nV0N][14] )
				oModel:LoadValue( "MODEL_V0N", "V0N_UF" 	, aGravaV0N[nV0N][15] )
				oModel:LoadValue( "MODEL_V0N", "V0N_QTDPAG" , aGravaV0N[nV0N][16] )
				oModel:LoadValue( "MODEL_V0N", "V0N_QTDNPA" , aGravaV0N[nV0N][17] )
				
				//V0O
				nV0OAdd := 1
				For nV0O := 1 to Len( aGravaV0O )
					If aGravaV0O[nV0O][1] == aGravaV0N[nV0N][1]  .And. aGravaV0O[nV0O][2] == aGravaV0N[nV0N][2] .And. aGravaV0O[nV0O][3] == aGravaV0N[nV0N][3]
		
						oModel:GetModel( "MODEL_V0O" ):LVALID := .T.
		
						If nV0OAdd > 1
							oModel:GetModel( "MODEL_V0O" ):AddLine()
						EndIf
															
						oModel:LoadValue( "MODEL_V0O", "V0O_SEQUEN" , aGravaV0O[nV0O][4] )
						oModel:LoadValue( "MODEL_V0O", "V0O_TPINGR" , aGravaV0O[nV0O][5] )
						oModel:LoadValue( "MODEL_V0O", "V0O_DESCIN" , aGravaV0O[nV0O][6] )
						oModel:LoadValue( "MODEL_V0O", "V0O_QTDING" , aGravaV0O[nV0O][7] )
						oModel:LoadValue( "MODEL_V0O", "V0O_QTDIVE" , aGravaV0O[nV0O][8] )
						oModel:LoadValue( "MODEL_V0O", "V0O_QTDIDE" , aGravaV0O[nV0O][9] )
						oModel:LoadValue( "MODEL_V0O", "V0O_PRECOI" , aGravaV0O[nV0O][10] )
						oModel:LoadValue( "MODEL_V0O", "V0O_VLRTOT" , aGravaV0O[nV0O][11] )
	
		
						nV0OAdd ++
					EndIf
				Next nV0O
				
				
				//V0P
				nV0PAdd := 1
				For nV0P := 1 to Len( aGravaV0P )
					If aGravaV0P[nV0P][1] == aGravaV0N[nV0N][1]  .And. aGravaV0P[nV0P][2] == aGravaV0N[nV0N][2] .And. aGravaV0P[nV0P][3] == aGravaV0N[nV0N][3]
		
						oModel:GetModel( "MODEL_V0P" ):LVALID := .T.
		
						If nV0PAdd > 1
							oModel:GetModel( "MODEL_V0P" ):AddLine()
						EndIf
						
															
						oModel:LoadValue( "MODEL_V0P", "V0P_SEQUEN" , aGravaV0P[nV0P][4] )
						oModel:LoadValue( "MODEL_V0P", "V0P_TPRECE" , aGravaV0P[nV0P][5] )
						oModel:LoadValue( "MODEL_V0P", "V0P_VLRREC" , aGravaV0P[nV0P][6] )
						oModel:LoadValue( "MODEL_V0P", "V0P_DESREC" , aGravaV0P[nV0P][7] )

	
		
						nV0PAdd ++
					EndIf
				Next nV0P
				
				nV0NAdd ++
			EndIf
		Next nV0N
			
		//V0Q
		nV0QAdd := 1
		For nV0Q := 1 to Len( aGravaV0Q )
			If aGravaV0M[nV0M][1] == aGravaV0Q[nV0Q][1]  .And. aGravaV0M[nV0M][2] == aGravaV0Q[nV0Q][2] 

				oModel:GetModel( "MODEL_V0Q" ):LVALID := .T.

				If nV0QAdd > 1
					oModel:GetModel( "MODEL_V0Q" ):AddLine()
				EndIf								
				
				oModel:LoadValue( "MODEL_V0Q", "V0Q_SEQUEN" , aGravaV0Q[nV0Q][3] )
				oModel:LoadValue( "MODEL_V0Q", "V0Q_VLRTOT" , aGravaV0Q[nV0Q][4] )
				oModel:LoadValue( "MODEL_V0Q", "V0Q_VLRCP"  , aGravaV0Q[nV0Q][5] )
				oModel:LoadValue( "MODEL_V0Q", "V0Q_VLRCPS" , aGravaV0Q[nV0Q][6] )
				oModel:LoadValue( "MODEL_V0Q", "V0Q_VLRRCL" , aGravaV0Q[nV0Q][7] )
				oModel:LoadValue( "MODEL_V0Q", "V0Q_VLRRET" , aGravaV0Q[nV0Q][8] )
	
				
				//V0R
				nV0RAdd := 1
				For nV0R := 1 to Len( aGravaV0R )
					If aGravaV0R[nV0R][1] == aGravaV0Q[nV0Q][1]  .And. aGravaV0R[nV0R][2] == aGravaV0Q[nV0Q][2] .And. aGravaV0R[nV0R][3] == aGravaV0Q[nV0Q][3]
		
						oModel:GetModel( "MODEL_V0R" ):LVALID := .T.
		
						If nV0RAdd > 1
							oModel:GetModel( "MODEL_V0R" ):AddLine()
						EndIf				
															
						oModel:LoadValue( "MODEL_V0R", "V0R_IDPROC" , aGravaV0R[nV0R][4] )
						oModel:LoadValue( "MODEL_V0R", "V0R_TPPROC" , aGravaV0R[nV0R][5] )
						oModel:LoadValue( "MODEL_V0R", "V0R_NUMPRO" , aGravaV0R[nV0R][6] )
						oModel:LoadValue( "MODEL_V0R", "V0R_CODSUS" , aGravaV0R[nV0R][7] )
						oModel:LoadValue( "MODEL_V0R", "V0R_IDSUSP" , aGravaV0R[nV0R][8] )
						oModel:LoadValue( "MODEL_V0R", "V0R_VLRSUS" , aGravaV0R[nV0R][9] )
		
						nV0RAdd ++
					EndIf
				Next nV0R
		
				nV0QAdd ++
			EndIf
		Next nV0Q
	Next nV0M
		

	//*****************************************
	//Versão que será gravada no novo registro
	//*****************************************
	cVersao := xFunGetVer()

	//********************************************************************
	//ATENÇÃO
	//A alteração destes campos devem sempre estar abaixo do loop do For,
	//pois devem substituir as informações que foram armazenadas acima
	//********************************************************************
	oModel:LoadValue( "MODEL_V0L", "V0L_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_V0L", "V0L_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_V0L", "V0L_PROTPN", cRecibo )
	oModel:LoadValue( "MODEL_V0L", "V0L_PROTUL", "" )

	oModel:LoadValue( "MODEL_V0L", "V0L_EVENTO", "E" )
	oModel:LoadValue( "MODEL_V0L", "V0L_ATIVO", "1" )

	FWFormCommit( oModel )
	TAFAltStat("V0L", "6") 
End Transaction

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Roberto Souza
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
	Private oBrw  as object

	If FunName() == "TAFXREINF"
		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .T., lMenuDif ) 
	EndIf

    oBrw := FWmBrowse():New()	
	oBrw:SetDescription( "R-3010 - "+STR0001 )	//"Receita de Espetáculo Desportivo"
	oBrw:SetAlias( 'V0L')
	oBrw:SetMenuDef( 'TAFA493' )	
	oBrw:SetFilterDefault( "V0L_ATIVO == '1'" )

	//DbSelectArea("V0L")
	//Set Filter TO &("V0L_ATIVO == '1'")
		
	If FindFunction("TAFLegReinf")
		TAFLegReinf( "V0L", oBrw)
	Else
		TafLegend(2,"V0L",@oBrw)
	EndIf
	
	oBrw:Activate()
	
Return( oBrw )
