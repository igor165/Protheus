#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"
#INCLUDE "GPEA551.CH"  


//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GPEA551

@author:  Matheus Bizutti
@since:   27/12/2016
@version: V.01
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Function GPEA551()

Local xRetFilRh := ""
Local cFiltraRh := ""
Local oBrowse 	:= Nil

Private cFilPrev := ""

dbSelectArea("RCS")  
If RCS->( ColumnPos("RCS_NOMED"))== 0 
	Aviso( OemToAnsi(STR0012), OemToAnsi(STR0018),{"OK"})// "Atencao"#"Tabelas desatualizadas. Execute o atualizador"
	Return
EndIf

//------------------------------------------
//Busca o filtro a ser utilizado no Browse
//------------------------------------------
xRetFilRh := CHKRH("GPEA551","SRA","1")
If ValType(xRetFilRh) == "L"
	cFiltraRh := If(xRetFilRh,".T.",".F.")
Else
	cFiltraRh := xRetFilRh
Endif   
   
cFilPrev := cFilAnt 

oBrowse := FWMBrowse():New()

oBrowse:SetAlias('SRA')
oBrowse:SetDescription( OemToAnsi(STR0001) ) 

oBrowse:AddLegend( "RA_SITFOLH==' '"	, "GREEN"	, OemToAnsi(STR0007) ) //"Situa็ใo Normal"
oBrowse:AddLegend( "RA_RESCRAI$'30/31'"	, "PINK"	, OemToAnsi(STR0008) ) //"Transferido"
oBrowse:AddLegend( "RA_SITFOLH=='D'"	, "RED"		, OemToAnsi(STR0009) ) //"Demitido"
oBrowse:AddLegend( "RA_SITFOLH=='A'"	, "YELLOW"	, OemToAnsi(STR0010) ) //"Afastado"
oBrowse:AddLegend( "RA_SITFOLH=='F'"	, "BLUE"	, OemToAnsi(STR0011) ) //"F้rias"
oBrowse:SetmenuDef( 'GPEA551' )

//Filtro padrao do Browse 
oBrowse:SetFilterDefault(cFiltraRh)
oBrowse:SetLocate()
oBrowse:Activate()

Return NIL


//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@since:   27/12/2016
@version: V.01
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE OemToAnsi(STR0002)			ACTION 'PesqBrw'			OPERATION 1 ACCESS 0 	 //"Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi(STR0003)			ACTION 'VIEWDEF.GPEA551'	OPERATION 2 ACCESS 0	 //"Visualizar"
ADD OPTION aRotina TITLE OemToAnsi(STR0004)			ACTION 'VIEWDEF.GPEA551'	OPERATION 4 ACCESS 0	 //"Alterar"
ADD OPTION aRotina TITLE OemToAnsi(STR0005)			ACTION 'GPEM551()'			OPERATION 4 ACCESS 0	 //"Gera็ใo utomแtica"
ADD OPTION aRotina TITLE OemToAnsi(STR0019)			ACTION 'VIEWDEF.GPEA551'	OPERATION 5 ACCESS 0	 //"Excluir"


Return aRotina

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author:  Matheus Bizutti	
@since:   27/12/2016
@version: V.01 

@obs: O Campo MU_MAT ้ removido da exibi็ใo para nใo apresentar 2x a mesma informa็ใo, e internamente recebe o conte๚do SRA->RA_MAT.

/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function Modeldef()

Local oModel
Local oStructSMU := FWFormStruct(1, "SMU")
Local oStructSRA := FWFormStruct(1,"SRA",{|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"})
Local aTrigger   := SetTrigger("MU_CODFOR","MU_NOMEEMP","ALLTRIM(fDescRCC('S073',M->MU_CODFOR,1,2,17,150,.T.))")

oStructSRA:RemoveField("RA_FILIAL")
oStructSMU:RemoveField("MU_FILIAL")

// Criacao do Objeto de Modelagem de dados da tabela SMU //	
oModel	    := MpFormModel():New("GPEA551", /*Pre-Validacao*/,/*Pos-Validacao*/, { |oModel| Gp551Grav( oModel ) } /*Commit*/, /*Cancel*/)

oModel:AddFields("GPEA010_SRA", /*cOwner*/, oStructSRA , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:GetModel("GPEA010_SRA"):SetOnlyView( .T. )
oModel:GetModel("GPEA010_SRA"):SetOnlyQuery( .T. )

oModel:AddGrid("SMUDETAIL", "GPEA010_SRA"/*cOwner*/, oStructSMU , /*bLinePre*/,   { |oModel| Gp551LOk(oModel) }/* bLinePost*/, /*bPre*/,  /*{ |oModel| Gp551TOk(oModel) }*//*bPost*/,/*bLoad*/)
oModel:GetModel("SMUDETAIL"):SetOptional(.T.)

oStructSMU:AddTrigger( ;
      aTrigger[1] , ;       // [01] Id do campo de origem
      aTrigger[2] , ;       // [02] Id do campo de destino
      aTrigger[3] , ;       // [03] Bloco de codigo de valida็ใo da execu็ใo do gatilho
      aTrigger[4] ) 

oModel:GetModel("SMUDETAIL"):SetUniqueLine({"MU_CODFOR","MU_PERINI", "MU_PERFIM"})
 
oModel:SetRelation("SMUDETAIL",{{"MU_FILIAL",'xFilial("SMU")'},{"MU_MAT","RA_MAT"}},SMU->(IndexKey())) 
 
oModel:GetModel('GPEA010_SRA'):SetDescription(OemToAnsi(STR0006))
oModel:GetModel('SMUDETAIL'):SetDescription(OemToAnsi(STR0001)) 

Return oModel

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author:  Matheus Bizutti 
@since:   27/12/2016
@version: V.01
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView 
Local oModel  		:= FWLoadModel( "GPEA551" )
Local oStructSMU 	:= FWFormStruct(2, "SMU" )
Local oStructSRA 	:= FWFormStruct(2,"SRA",{|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"})

oStructSRA:AFOLDERS := {} //Zera a propriedade de folders para exibir os campos sem folder

oStructSMU := FWFormStruct(2,"SMU")
oStructSMU:RemoveField( "MU_FILIAL" )
oStructSMU:RemoveField( "MU_MAT" )

//--------------------------------------------------------------
//Montagem do View normal de Container
//--------------------------------------------------------------
oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField( "GPEA010_SRA" , oStructSRA )

oView:AddGrid(  "SMUDETAIL" ,   oStructSMU )

oView:SetViewProperty("GPEA010_SRA","OnlyView") //Somente visualizacao. Nao permite edicao dos campos do cabecalho (SRA)

oView:createHorizontalBox("FORMFIELD",10)
oView:createHorizontalBox("GRID"     ,90)

oView:SetOwnerView( "GPEA010_SRA","FORMFIELD")
oView:SetOwnerView( "SMUDETAIL","GRID")

oView:SetCloseOnOk( { |oView| Gp551ClsOk( oView ) } )

Return oView     

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}Gp551Grav(oModel)
- Responsแvel por efetuar a valida็ใo do GRID ( SMU )

@author: Matheus Bizutti 
@since:  27/12/2016
@param:  oModel - Objeto do Modelo de dados, a partir deste ้ obtido o Modelo da GRID: oModel:GetModel('SMUDETAIL')

@obs:    O campo MU_MAT tem seu valor carregado de acordo com a matrํcula escolhida no browse: oModelSMU:LoadValue( 'MU_MAT' , SRA->RA_MAT )

/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function Gp551Grav(oModel)

Local aArea      	:= GetArea()
Local aSaveLines 	:= FWSaveRows( oModel )

FWFormCommit(oModel)
FWRestRows( aSaveLines, oModel )
RestArea(aArea)
aSize(aSaveLines,0)
aSaveLines := Nil

Return(.T.)


/*/{Protheus.doc}SetTrigger()
- Fun็ใo que devolve uma Matriz com os dados para incluir um Trigger.

@author: Matheus Bizutti
@since:  28/12/2016
@param:  cDomain - Campo de Dominio. cReceptor - Campo de Contra Dominio. cRegra - Regra de preenchimento do trigger.

@return:	Matriz com as posi็๕es e valores para gravar o Trigger.
/*/
Static Function SetTrigger(cDomain,cReceptor,cRegra)

Local aTrigger :=  {}

DEFAULT cDomain 	:= ""
DEFAULT cReceptor 	:= ""
DEFAULT cRegra		:= ""

aTrigger := FwStruTrigger(;
      cDomain ,; // Campo Dominio
      cReceptor ,; // Campo de Contradominio
      cRegra,; // Regra de Preenchimento
      .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "" ,; // Alias da tabela a ser posicionada
      0 ,; // Ordem da tabela a ser posicionada
      "" ,; // Chave de busca da tabela a ser posicionada
      NIL ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
      
Return aTrigger

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGp551LOk  บAutor  ณJ๔natas A. T. Alves บ Data ณ  17/01/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento para o metodo SetCloseOnOk (fechar tela Ok)      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Gp551LOk( oGrid )

Local lRet		:= .T.
Local cCodFor 	:= ""
Local cPerIni 	:= ""
Local cPerFim 	:= ""
Local nPosCodF	:= oGrid:GetIdField( "MU_CODFOR" )
Local nPosPerI	:= oGrid:GetIdField( "MU_PERINI" )
Local nPosPerF	:= oGrid:GetIdField( "MU_PERFIM" )

cCodFor		:= If( nPosCodF > 0, oGrid:GetValue( "MU_CODFOR" ), "" )
cPerIni		:= If( nPosPerI > 0, oGrid:GetValue( "MU_PERINI" ), "" )
cPerFim		:= If( nPosPerF > 0, oGrid:GetValue( "MU_PERFIM" ), "" )

If !oGrid:IsDeleted()
	If Empty( cCodFor ) .Or. Empty( cPerIni ) .Or. Empty( cPerFim ) 	
		Help( " ", 1, "Help",, OemToAnsi(STR0013) + CRLF + OemToAnsi(STR0014) + CRLF + OemToAnsi(STR0015) + CRLF + OemToAnsi(STR0016) + CRLF + OemToAnsi(STR0017), 1, 0 ) //'Os campos:' + CRLF + " - Fornecedor" + CRLF + " - Perํodo Inicial" + CRLF + " - Perํodo Final" + CRLF + "sใo de preenchimento obrigat๓rio."
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGp55ClsOk บAutor  ณJ๔natas A. T. Alves บ Data ณ  17/01/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento para o metodo SetCloseOnOk (fechar tela Ok)      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Gp551ClsOk( oView )
Local aArea    	 := GetArea()
Local nOperation := oView:oModel:GetOperation()
Local oView   	 := oView:oModel:GetModel("SMUDETAIL")
Local nLinGrdPos := oView:GetLine() //Linha posicionada atualmente no Grid
Local lRet     	 := .F.
Local nX  		 := 0

If nOperation == MODEL_OPERATION_UPDATE
	lRet := .T.
	For nX:=1 to oView:GetQtdLine()
		oView:GoLine( nX )
		If !oView:IsDeleted()	
			lRet := .F.
			Exit
		EndIf
	Next nX
	oView:GoLine( nLinGrdPos )
EndIf

RestArea( aArea )
oView := Nil
Return lRet
