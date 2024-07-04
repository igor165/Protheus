#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#include "TOPCONN.CH"
#INCLUDE "FINA687.CH"
STATIC _oFINA6871
STATIC _oFINA6872
STATIC cRetLocal  :=""
STATIC cRetDescri :=""

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA687
Amarração Despesas x Localização

@author Antonio Florêncio Domingos Filho
@since 24/04/2015
@version 12.1.5
/*/
//-------------------------------------------------------------------
Function FINA687()

If FunName() == "FINA687"
	HELP(' ',1,'FINA687' ,,STR0021,2,0,,,,,,{STR0022})//"Essa rotina não pode ser utiliza via menu"###"Acesse através da FINA679(Tipos de despesa) ou FINA681(Grupo de despesa)."
EndIf

Return 

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002  Action 'VIEWDEF.FINA687' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title STR0003     Action 'VIEWDEF.FINA687' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title STR0004     Action 'VIEWDEF.FINA687' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title STR0005     Action 'VIEWDEF.FINA687' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title STR0006    Action 'VIEWDEF.FINA687' OPERATION 8 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFWC := FWFormStruct( 1, 'FWC', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruFWD := FWFormStruct( 1, 'FWD', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel     := nil
Local aAuxFWCGat := {}
Local aAuxFWDGat := {}
Local aGetArea   := GetArea()
Local cTabela    := ""
Local nTipo      := 1


aAuxFWCGat := FwStruTrigger('FWC_DESPES','FWC_DESCDP','FLG->FLG_DESCRI',.T.,'FLG',1,'xFilial("FLG")+M->FWC_DESPES')
oStruFWC:AddTrigger(aAuxFWCGat[1],aAuxFWCGat[2],aAuxFWCGat[3],aAuxFWCGat[4])
oStruFWD:SetProperty("FWD_LOCAL",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FN687VlCpo()' ) )

nTipo := MV_PAR01

If nTipo == 1  
	aAuxFWDGat := FwStruTrigger('FWD_LOCAL','FWD_DESCLC','SUBS(SX5->X5_DESCRI,1,40)',.T.,'SX5',1,'xFilial("SX5")+"12"+M->FWD_LOCAL')
	oStruFWD:AddTrigger(aAuxFWDGat[1],aAuxFWDGat[2],aAuxFWDGat[3],aAuxFWDGat[4])
ElseIf nTipo == 2
	aAuxFWDGat := FwStruTrigger('FWD_LOCAL','FWD_DESCLC','SUBS(SX5->X5_DESCRI,1,40)',.T.,'SX5',1,'xFilial("SX5")+"BH"+M->FWD_LOCAL')
	oStruFWD:AddTrigger(aAuxFWDGat[1],aAuxFWDGat[2],aAuxFWDGat[3],aAuxFWDGat[4])
Else
	aAuxFWDGat := FwStruTrigger('FWD_LOCAL','FWD_DESCLC','SUBS(SX5->X5_DESCRI,1,40)',.T.,'SX5',1,'xFilial("SX5")+If(M->FDW_NACION="1","12","BH")+M->FWD_LOCAL')
	oStruFWD:AddTrigger(aAuxFWDGat[1],aAuxFWDGat[2],aAuxFWDGat[3],aAuxFWDGat[4])
EndIf

oStruFWD:SetProperty('FWD_DESCLC',MODEL_FIELD_INIT,{|o,u|f687SX5(nTipo,oModel)})
If nTipo <> 3
	oStruFWD:SetProperty('FWD_NACION',MODEL_FIELD_INIT,{||AllTrim(Str(nTipo))})
EndIf
oModel := MPFormModel():New( 'FINA687M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
oModel:SetActivate ({|oModel| FN687ACT(oModel)})
oModel:AddFields( 'FWCMASTER', /*cOwner*/, oStruFWC )
oModel:AddGrid( 'FWDDETAIL', 'FWCMASTER', oStruFWD, /*bLinePre*/,  { | oMdlG | FINA687LPOS( oMdlG ) } , /*bPreVal*/, /*bPosVal*/ )
oModel:SetRelation( 'FWDDETAIL', { { 'FWD_FILIAL', 'xFilial( "FWD" )' }, { 'FWD_CODIGO', 'FWC_CODIGO' } }, FWD->( IndexKey( 1 ) ) )
oModel:GetModel( 'FWDDETAIL' ):SetUniqueLine( { 'FWD_LOCAL','FWD_NACION' })
oModel:SetDescription( 'Despesas x Localização' )
oModel:GetModel( 'FWCMASTER' ):SetDescription( STR0001 )
oModel:GetModel( 'FWDDETAIL' ):SetDescription( STR0001  )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruFWC := FWFormStruct( 2, 'FWC', {|cCampo| !( AllTrim(cCampo) $ "FWC_CODIGO/FWC_CLASS/FWC_ORIGEM") } )
Local oStruFWD
Local oModel := FWLoadModel( 'FINA687' )
Local oView


nTipo:=mv_par01

If nTipo == 3 
	oStruFWD := FWFormStruct( 2, 'FWD', {|cCampo| !( AllTrim(cCampo) $ "FWD_CODIGO/FWD_REPLOC") } )
	oStruFWD:setProperty("FWD_LOCAL",MVC_VIEW_LOOKUP , "FWDEXP")
Else
	oStruFWD := FWFormStruct( 2, 'FWD', {|cCampo| !( AllTrim(cCampo) $ "FWD_CODIGO/FWD_NACION/FWD_REPLOC") } )
	If mv_par01 == 1
		oStruFWD:SetProperty("FWD_LOCAL",MVC_VIEW_LOOKUP,"12")
    Else
		oStruFWD:SetProperty("FWD_LOCAL",MVC_VIEW_LOOKUP,"BH")    
    EndIf
EndIf

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_FWC', oStruFWC, 'FWCMASTER' )
oView:AddGrid(  'VIEW_FWD', oStruFWD, 'FWDDETAIL' )
oView:CreateHorizontalBox( 'SUPERIOR', 10 )
oView:CreateHorizontalBox( 'INFERIOR', 74 )
oView:CreateHorizontalBox( 'LOCAL', 16 )
oView:SetOwnerView( 'VIEW_FWC', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_FWD', 'INFERIOR' )
oView:AddIncrementField( 'VIEW_FWD', 'FWD_ITEM')
oView:EnableTitleView('VIEW_FWD',STR0007)
oView:AddOtherObject("OTHER_LOCAL", {|oPanel,oView| FINA687BUT(oPanel,oView:GetModel())})
oView:SetOwnerView("OTHER_LOCAL",'LOCAL')
oView:SetViewAction( 'ASKONCANCELSHOW' , { |oView| FIN687CanS( oView ) } )
oStruFWC:SetProperty("FWC_DESPES" , MVC_VIEW_CANCHANGE , .F.)

Return oView


//-------------------------------------------------------------------
Static Function FINA687LPOS( oModelGrid )
Local lRet       := .T.
Local oModel     := oModelGrid:GetModel( 'FWDDETAIL' )
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
	
	If Empty(FwFldGet( 'FWD_LOCAL' )) 
		Help( ,, 'Help',, STR0008, 1, 0 )
		lRet := .F.
	EndIf
	
EndIf

Return lRet


//-------------------------------------------------------------------
Static Function FINA687POS( oModel )
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaFWC   := FWC->( GetArea() )
Local nOperation := oModel:GetOperation()
Local oModelFWD  := oModel:GetModel( 'FWDDETAIL' )
Local nI         := 0
Local nCt        := 0
Local lAchou     := .F.
Local aSaveLines := FWSaveRows()

FWC->( dbSetOrder( 1 ) )

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
	
	For nI := 1 To  oModelFWD:Length()
		
		oModelFWD:GoLine( nI )
		
		If !oModelFWD:IsDeleted()
			If FWC->( dbSeek( xFilial( 'FWD' ) + oModelFWC:GetValue( 'FWD_CODIGO' ) ) ) .AND. FWC->FWD_CODIGO == '001'
				lAchou := .T.	
				Exit
			EndIf
		EndIf
		
	Next nI
	
	If lRet
		
		For nI := 1 To oModelFWD:Length()
			
			oModelFWD:GoLine( nI )
			
			If oModelFWD:IsInserted() .AND. !oModelFWD:IsDeleted() // Verifica se é uma linha nova
				nCt++
			EndIf
			
		Next nI
				
	EndIf
	
EndIf

FWRestRows( aSaveLines )

RestArea( aAreaFWC )
RestArea( aArea )

Return lRet

/*/{Protheus.doc} FN687ACT
Ativação do modelo de dados.
@author William Gundim	
@since 20/10/15	
@version 12
@param Modelo de Dados 
@return lRet 
/*/
Function FN687ACT(oModel)
Local cCodigo := oModel:GetValue('FWCMASTER','FWC_CODIGO')

	If oModel:GetOperation() != MODEL_OPERATION_DELETE 
		oModel:LoadValue('FWCMASTER','FWC_DESPES',FLG->FLG_CODIGO)
		oModel:LoadValue('FWCMASTER','FWC_CLASS',Str(mv_par01,1))
		oModel:LoadValue('FWCMASTER','FWC_ORIGEM',If(Alltrim(FUNNAME())="FINA681","1","2"))
		oModel:LoadValue( 'FWCMASTER','FWC_DESCDP',FLG->FLG_DESCRI)
		oModel:LoadValue( 'FWDDETAIL','FWD_CODIGO',cCodigo )
	EndIf
		
Return (.T.)

//-------------------------------------------------------------------
Static Function FINA687BUT(oPanel)

Local lCheck1 := .F.
Local cLocal  := STR0009

cLocal  := If(mv_par01==1,STR0010,STR0011)

@  15, 4  BUTTON oButton PROMPT STR0012 + ' ' + cLocal SIZE 100,012 FONT oPanel:oFont ACTION FINA687L() OF oPanel PIXEL     // "Campos Variáveis"


Return NIL

//-------------------------------------------------------------------
Static Function FINA687L()

Local aArea			:= GetArea()
Local aAreaFWD		:= FWD->( GetArea() )
Local oModel		:= FwModelActive()
Local oModelFWD		:= NIL
Local cQuery		:= ""
Local cCadastro		:= IF(MV_PAR01==1,STR0010,IF(MV_PAR01==2,STR0011,STR0009))
Local cAliasTrb		:= "TMPSX5"
Local cVazio		:= ''
Local cTabela		:= "12"
Local aColunas		:= {}
Local aStru			:= SX5->(dbStruct())
Local cMarca		:= GetMark(,"SX5","X5_OK")					
Local oDlg			:= Nil
Local nX			:= 0
Local cChave		:= ""
Local lConfirma		:= .F.
Local oMrkBrowse	:= Nil
Local cQry 			:= ""
Local nRet 			:= 0
Local bOk 			:= {||((nRet := 1, oMark:Deactivate(), oDlg:End()))}
Local oView 		:= FwViewActive()
Local aMarkAnt 		:= {} 
Local bAfterMark 	:= {|| GuardaMark( @aMarkAnt,"TMPSX5" ) }
Local oSize			:= Nil
Local nOper			:= oModel:GetOperation()
Private oMark		:= Nil

If nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE 
	
	cChave := SX5->(IndexKey())
	
	If SELECT(cAliasTrb) <> 0
		(cAliasTrb)->(dbCloseArea())
	EndIf
	
	//Seleciono os registros que serão exibidos na MarkBrowse
	cQry += " SELECT "
	For nX:= 1 to Len(aStru)
		cQry += aStru[nX,1]+", "
	Next
	cQry += " R_E_C_N_O_ RECNO "
	cQry += " FROM " + RetSqlName("SX5") + " SX5 WHERE "
	If mv_par01 == 1
		cQry += " SX5.X5_TABELA = '12' " 
	ElseIf mv_par01 == 2
		cQry += " SX5.X5_TABELA = 'BH' "
	Else
		cQry += " SX5.X5_TABELA IN('12','BH') "
	EndIf
	
	cQry += " AND SX5.D_E_L_E_T_ = ' ' "  
	
	Aadd(aStru,{"X5_OK","C",1,0})
	
//------------------
//Criação da tabela temporaria 
//------------------
If _oFINA6871 <> Nil
	_oFINA6871:Delete()
	_oFINA6871 := Nil
Endif

cArqTrab:="TMPSX5"

_oFINA6871 := FWTemporaryTable():New( "TMPSX5" )  
_oFINA6871:SetFields(aStru) 	
_oFINA6871:AddIndex("1", {"X5_FILIAL","X5_TABELA","X5_CHAVE"})	
_oFINA6871:Create()	

	Processa({||SqlToTrb(cQry, aStru, "TMPSX5")})	// Cria arquivo temporario
	DbSetOrder(0) // Fica na ordem da query
	
	//define as colunas para o browse
	aColunas:={;
	{"Codigo" ,"X5_CHAVE" ,"C",5,0,"@!"},;
	{"Nome" ,"X5_DESCRI" ,"C",20,0,"@!"}}
	
	f687FAllMark(oMark,"TMPSX5",@aMarkAnt,nRet)
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject("MASTER",100,100,.T.,.T.)
	oSize:lLateral := .F.				
	oSize:lProp := .T.
	oSize:Process()
	
	// Instanciamento do classe
	DEFINE MSDIALOG oDlg TITLE OemTOAnsi(STR0014) PIXEL FROM 0,0 To oSize:aWindSize[3] * 0.7,oSize:aWindSize[4]/3 OF oMainWnd
	oMark:= FWMarkBrowse():New()
	oMark:SetFieldMark( "X5_OK" )
	oMark:SetOwner( oDlg )
	oMark:SetAlias( "TMPSX5" )
	oMark:AddButton( OemTOAnsi(STR0015), bOk,, 2 ) //"Confirmar"
	oMark:bAllMark := {|| f687FMark( oMark, "TMPSX5", @aMarkAnt ) }
	oMark:SetMark( 'X', cArqTrab, "X5_OK" )
	oMark:SetAfterMark( bAfterMark ) 
	oMark:SetDescription(cCadastro)
	oMark:SetFields(aColunas)
	oMark:SetMenuDef("")
	oMark:Activate()
	ACTIVATE MSDIALOg oDlg CENTERED
	
	cArqTrab:="TMPSX5"
	oModelFWD:= oModel:GetModel( "FWDDETAIL" )
	
	If nRet == 1
	 	oModelFWD:= oModel:GetModel( "FWDDETAIL" )
	 
		TMPSX5->(dbGotop())
		
		While !TMPSX5->( EOF() )
			
			If !Empty(TMPSX5->X5_OK)
	
				If !oModelFWD:SeekLine({{'FWD_LOCAL',Padl(TMPSX5->X5_CHAVE,4)}})
			        If !Empty(oModelFWD:GetValue("FWD_LOCAL"))
			            oModelFWD:AddLine() 
					EndIf
	            	oModelFWD:SetValue('FWD_LOCAL',Padl(TMPSX5->X5_CHAVE,4))	
					oModelFWD:SetValue('FWD_DESCLC',SUBSTR(TMPSX5->X5_DESCRI,1,40))
				EndIf
			EndIf
			
			TMPSX5->( dbSkip() )
			
		EndDo
	
	Endif
	
	(cAliasTrb)->(dbCloseArea())
	
	nRet:=0
	RestArea( aAreaFWD )
	RestArea( aArea )
	oModelFWD:GoLine(1)
	oView:Refresh()
Else
	Help(,,"VLDLOCALOP",,OemToANSI(STR0020), 1, 0 )//'Essa função não está disponível para essa opção.'
EndIf

Return 

Function F687SX5(nTipo,oModel)
Local nOper	:= oModel:GetOperation()
Local aGetArea := GetArea()
Local cDesc := ''

If !(nOper == MODEL_OPERATION_INSERT)
	If nTipo <> 3
		If nTipo == 1
			cDesc := SUBSTR(Posicione("SX5",1,xFilial('SX5')+"12"+FWD->FWD_LOCAL,"X5_DESCRI"),1,40)
	    Else
			cDesc := SUBSTR(Posicione("SX5",1,xFilial('SX5')+"BH"+FWD->FWD_LOCAL,"X5_DESCRI"),1,40)
	    EndIf
	Else
		cDesc := SUBSTR(Posicione("SX5",1,xFilial('SX5')+"12"+FWD->FWD_LOCAL,"X5_DESCRI"),1,40)	
		If Empty(cDesc)
			cDesc := SUBSTR(Posicione("SX5",1,xFilial('SX5')+"BH"+FWD->FWD_LOCAL,"X5_DESCRI"),1,40)
		EndIf
	EndIf
EndIf	
RestArea(aGetArea)
Return cDesc

/*/{Protheus.doc} F687FLG()
Função Posicionar a Descrição da Despesa,
com o proposito de recuperá-la quando carregar as despesas existentes

@author Antonio Florêncio Domingos Filho
@since  07/05/2015
@version 12.1.5
/*/
Function F687FLG()
Local aGetArea := GetArea()
Local cDesc := ''
cDesc := Posicione("FLG",1,xFilial('FLG')+FWC->FWC_DESPES,"FLG_DESCRI")
RestArea(aGetArea)
Return cDesc

/*/{Protheus.doc} GuardaMark()
Função para guardar as marcações, antes de serem alteradas,
com o proposito de recuperá-las caso a tela não seja confirmada
@param aMarkAnt, Vetor que guardará o recno e a marcação inicial

@author Antonio Florêncio Domingos Filho
@since  07/05/2015
@version 12.1.5
/*/
Static Function GuardaMark( aMarkAnt,cArqTrab)
	Local lRet := .T.
	Local nRecno := 0
	Local lMarcado := .F.  
	
	If cArqTrab != "" 
		nRecno := (cArqTrab)->(recno())
		If aScan( aMarkAnt, { |aVet| aVet[1] == nRecno } ) <= 0
			//Se está marcado, então guarda o estado anterior que era desmarcado e vice-versa 
			lMarcado := Iif( (cArqTrab)->X5_OK == "X", .T., .F. )
			aAdd( aMarkAnt, { nRecno, Iif( lMarcado, " ", "X" ) } )		
		Endif
	Endif
Return lRet

/*/{Protheus.doc} f687Mark
Função para marcar todos os itens da markbrowse.
@author Antonio Florêncio Domingos Filho
@since 07/05/2015
@version 12.1.5
/*/
Function f687FMark(oMark,cArqTrab,aMarkAnt,nRet)
Local nRecno := 0

(cArqTrab)->(dbGoTop())
While !(cArqTrab)->(Eof())
	nRecno := (cArqTrab)->(recno())
	RecLock(cArqTrab, .F.)
	If (cArqTrab)->&("X5_OK") = oMark:Mark()		
		(cArqTrab)->&("X5_OK") := ' '		
		//Guarda o estado da marcação para desfazer caso a tela não seja confirmada		
		If aScan( aMarkAnt, { |aVet| aVet[1] == nRecno } ) <= 0			
			aAdd( aMarkAnt, { nRecno, "X" } )		
		Endif		
	Else
		(cArqTrab)->&("X5_OK") := oMark:Mark()
		//Guarda o estado da marcação para desfazer caso a tela não seja confirmada		
		If aScan( aMarkAnt, { |aVet| aVet[1] == nRecno } ) <= 0			
			aAdd( aMarkAnt, { nRecno, " " } )		
		Endif
	EndIf
	MsUnlock()
	(cArqTrab)->(DbSkip())	
End

oMark:oBrowse:Refresh(.T.)
Return .T.

/*/{Protheus.doc} f687Mark
Função para marcar todos os itens da markbrowse antes da MSDIALOG.
@author Antonio Florêncio Domingos Filho
@since 07/05/2015
@version 12.1.5
/*/
Function f687FAllMark(oMark,cArqTrab,aMarkAnt,nRet)
Local nRecno := 0

dbSelectArea(cArqTrab)
(cArqTrab)->(dbGoTop())
While !(cArqTrab)->(Eof())
	nRecno := (cArqTrab)->(recno())
	RecLock(cArqTrab, .F.)
	If (cArqTrab)->&("X5_OK") == "X" 		
		(cArqTrab)->&("X5_OK") := ' '		
		//Guarda o estado da marcação para desfazer caso a tela não seja confirmada		
		If aScan( aMarkAnt, { |aVet| aVet[1] == nRecno } ) <= 0			
			aAdd( aMarkAnt, { nRecno, "X" } )		
		Endif		
	Else
		(cArqTrab)->&("X5_OK") := If(nRet=0,"X",oMark:Mark())
		//Guarda o estado da marcação para desfazer caso a tela não seja confirmada		
		If aScan( aMarkAnt, { |aVet| aVet[1] == nRecno } ) <= 0			
			aAdd( aMarkAnt, { nRecno, " " } )		
		Endif
	EndIf
	MsUnlock()
	(cArqTrab)->(DbSkip())	
End

Return .T.

/*/{Protheus.doc} f687Seek
Função para Retornar Seek de Pesquisa em gatilho dinamico
@author Antonio Florêncio Domingos Filho
@since 07/05/2015
@version 12.1.5
/*/

Function f687Seek(cNacion,cLocal)
Local cSeek := ' '

If cNacion == '1'
	cSeek:='xFilial("SX5")+"12"+cLOCAL'
Else
	cSeek:='xFilial("SX5")+"BH"+cLOCAL'
EndIf

Return(cSeek)


//-------------------------------------------------------------------
/*/{Protheus.doc} F687FWDSX5
Consulta Especifica de Locais FWDLOC - SX5³

@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.5
/*/
Function F687FWDSX5()
Local oModel := FWModelActive() //Modelo de dados ativo.
Local cNacion := oModel:Getvalue('FWDDETAIL','FWD_NACION')
Local bRet := .F.

_bRet := FiltraSX5(cNacion)

Return _bRet

Static Function FiltraSX5(cNacion)

Local cQry:=""
Local oLstSX5 := nil
Local nX		:= 0
Private oDlgSX5 := nil
Private _bRet := .F.
Private aDadosSX5 := {}
Private aStru     := SX5->(dbStruct())
Private cLocal := If(cNacion="1","12","BH")

//Query de marca x produto x referencia
cQry += " SELECT "
For nX:= 1 to Len(aStru)
	cQry += aStru[nX,1]+", "
Next
cQry += " R_E_C_N_O_ RECNO "
cQry += " FROM " + RetSqlName("SX5") + " SX5 WHERE "
If cNacion == "1"
	cQry += " SX5.X5_TABELA = '12' " 
Else
	cQry += " SX5.X5_TABELA = 'BH' "
EndIf

cQry += " AND SX5.D_E_L_E_T_ = ' ' " 

//------------------
//Criação da tabela temporaria 
//------------------
If _oFINA6872 <> Nil
	_oFINA6872:Delete()
	_oFINA6872 := Nil
Endif

cAlias1 := GetNextAlias()

_oFINA6872 := FWTemporaryTable():New( cAlias1 )  
_oFINA6872:SetFields(aStru) 	
_oFINA6872:AddIndex("1", {"X5_FILIAL","X5_TABELA","X5_CHAVE"})	
_oFINA6872:Create()	

Processa({||SqlToTrb(cQry, aStru, cAlias1)})	// Cria arquivo temporario


Do While (cAlias1)->(!Eof())

aAdd( aDadosSX5, { (cAlias1)->X5_CHAVE, (cAlias1)->X5_DESCRI } )

(cAlias1)->(DbSkip())

Enddo

(cAlias1)->(DbCloseArea())

//Deleta tabela temporária no banco de dados
If _oFINA6872 <> Nil
	_oFINA6872:Delete()
	_oFINA6872 := Nil
Endif

nList := aScan(aDadosSX5, {|x| Alltrim(x[1]) == cLocal })

iif(nList = 0,nList := 1,nList)

//--Montagem da Tela
Define MsDialog oDlgSX5 Title STR0016 From 0,0 To 280, 500 Of oMainWnd Pixel

@ 5,5 LISTBOX oLstSX5 ;
VAR lVarMat ;
Fields HEADER STR0017, STR0018;
SIZE 245,110 On DblClick ( ConfSX5(oLstSX5:nAt, @aDadosSX5, @_bRet) ) ;
OF oDlgSX5 PIXEL

oLstSX5:SetArray(aDadosSX5)
oLstSX5:nAt := nList
oLstSX5:bLine := { || {aDadosSX5[oLstSX5:nAt,1], aDadosSX5[oLstSX5:nAt,2]}}

DEFINE SBUTTON FROM 122,5 TYPE 1 ACTION ConfSX5(oLstSX5:nAt, @aDadosSX5, @_bRet) ENABLE OF oDlgSX5
DEFINE SBUTTON FROM 122,40 TYPE 2 ACTION oDlgSX5:End() ENABLE OF oDlgSX5

Activate MSDialog oDlgSX5 Centered

Return _bRet 

Static Function ConfSX5(_nPos, aDadosSX5, _bRet)

cRetLocal  := aDadosSX5[_nPos,1]
cRetDescri := aDadosSX5[_nPos,2]

_bRet := .T.

oDlgSX5:End()

Return _bRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F687RLOCAL
Retorno da Consulta Especifica de Locais FWDLOC - SX5³
Retorna o codigo Estado ou do Pais
@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.5
/*/
FUNCTION F687RLOCAL()
	 	
RETURN cRetLocal

//-------------------------------------------------------------------
/*/{Protheus.doc} F687RDESCRI
Retorno da Consulta Especifica de Locais FWDLOC - SX5³
Retorna a Descrição do Estado ou do Pais
@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.5
/*/
FUNCTION F687RDESCRI()
	 	
RETURN cRetDescri

/*/{Protheus.doc} FN687VlCpo()
Valida o código informado pelo usuário para origem/destino.
@author William Matos
@since 10/07/2015
@version 1.0
/*/
Function FN687VlCpo()
Local oModel	:= FWModelActive() 
Local cValor	:= oModel:GetValue("FWDDETAIL","FWD_LOCAL") 
Local lRet		:= .T.

lRet := ExistCPO("SX5", "12" + cValor ) .OR. ExistCPO("SX5", "BH" + cValor )

If !lRet
	Help(,,"VLDLOCAL",,OemToANSI(STR0019), 1, 0 )//'Local inválido'
EndIf

Return lRet

/*/{Protheus.doc} FN687EXP()
Retorna a pesquisa padrão do campo local
@author Rodolfo Sousa
@since 23/07/2015
@version 1.0
/*/
Function FN687EXP()
Local cRet			:= " " //nacional
local oModel		:= FWModelActive()

If mv_par01== 3

	If oModel:GetValue('FWDDETAIL','FWD_NACION') == '1' 
		cRet := '12'
	Else
		cRet := 'BH'
	Endif
	
EndIf


Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} FIN687CanS()
Valida pergunta se deseja salvar
@author William Matos
@since 10/07/2015
@version 1.0
/*/
Function FIN687CanS( oView )
Local oModel := oView:GetModel()
Local lRet := oModel:GetOperation() != MODEL_OPERATION_VIEW

Return lRet



