#INCLUDE "QADA250A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
 

//-----------------------------------------------------------------------
/*/{Protheus.doc} QADA250A
Cadastro de Reuniões
@author Leonardo Bratti
@since 26/07/2017
@version 1.0
@return NIL
/*/
//------------------------------------------------------------------------
FUNCTION QADA250A()
	Local aArea   := GetArea()
	Local oBrowse
	
	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias("QUK")
	oBrowse:SetDescription(STR0001) // Reunião
	oBrowse:Activate()
	
	RestArea(aArea)
	
RETURN Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Bratti
@since 26/07/2017
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
STATIC FUNCTION MenuDef()
	Private aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.QADA250A' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.QADA250A' OPERATION MODEL_OPERATION_INSERT ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.QADA250A' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.QADA250A' OPERATION MODEL_OPERATION_DELETE ACCESS 0 // Excluir
RETURN aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Bratti
@since 26/07/2017
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
STATIC FUNCTION ModelDef()
	Local oStruAud := FWFormModelStruct():New() 
	Local oStruQUK := FWFormStruct(1,'QUK')	
	Local oModel   := NIL
	Local nX
	
	oStruAud:AddTable("   ",{" "}," ")
	
	oStruAud:AddField( ;                      // Ord. Tipo Desc.
	                   "NUMAUD", ;            // [01] C Titulo do campo
	                   "NUMAUD", ;            // [02] C ToolTip do campo
	                   "NUMAUD", ;            // [03] C identificador (ID) do Field
	                   'C' , ;                // [04] C Tipo do campo
	                   6, ;                   // [05] N Tamanho do campo
	                   0 , ;                  // [06] N Decimal do campo
	                   NIL, ;                 // [07] B Code-block de validação do campo
	                   NIL, ;                 // [08] B Code-block de validação When do campo
	                   , ;                    // [09] A Lista de valores permitido do campo
	                   .T., ;                 // [10] L Indica se o campo tem preenchimento obrigatório
	                   {||Q250AInit()}, ;     // [11] B Code-block de inicializacao do campo
	                   .T., ;                 // [12] L Indica se trata de um campo chave
	                   .T., ;                 // [13] L Indica se o campo pode receber valor em uma operação de update.
	                   .T. )                  // [14] L Indica se o campo é virtual
	
	// Alterações de dicionário necessárias para que a tela normal e a MVC rodem ao mesmo tempo.
	// Removendo o X3_RELACAO do campo QUK_CODREU
	for nX:=1 To Len(oStruQUK:aFields)
		If oStruQUK:aFields[nX][3] == "QUK_CODREU"
			oStruQUK:aFields[nX][11] := Nil
		EndIf
	Next nX
	
	oStruQUK:SetProperty("QUK_CODREU", MODEL_FIELD_OBRIGAT, .T.)
	oStruQUK:SetProperty("QUK_DESCR" , MODEL_FIELD_OBRIGAT, .T.)
	oStruQUK:SetProperty("QUK_ORIGEM", MODEL_FIELD_OBRIGAT, .T.)
	oStruQUK:SetProperty("QUK_DATARE", MODEL_FIELD_OBRIGAT, .T.)
	oStruQUK:SetProperty("QUK_HORARE", MODEL_FIELD_OBRIGAT, .T.)
	oStruQUK:SetProperty("QUK_LOCAL" , MODEL_FIELD_OBRIGAT, .T.)
	//-----------------------------
			
	oModel := MPFormModel():New( 'QADA250A', , ,{|oModel|Q250AGRV(oModel)})
	
	FWMemoVirtual(oStruQUK, {{'QUK_CODOBS','QUK_MEMO1'}})
		
	oModel:AddFields( 'QUBMASTER2', /*cOwner*/, oStruAud , , , {||Q250ALoad()} )	
	oModel:AddGrid( 'QUKDETAIL'  ,'QUBMASTER2' , oStruQUK , ,{|| QAD250APOS()} )
	oModel:SetPrimaryKey( {} ) 
	oModel:SetRelation("QUKDETAIL",{{"QUK_FILIAL",'xFilial("QUK")'},{"QUK_NUMAUD","NUMAUD"}},QUK->(IndexKey(1)))
	
	oModel:SetDescription(STR0001)
	oModel:GetModel( 'QUBMASTER2' ):SetDescription('Auditoria')
	oModel:GetModel( 'QUKDETAIL' ):SetDescription(STR0001)	
	 			
		
RETURN oModel


//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Leonardo Bratti
@since 26/07/2017
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
STATIC FUNCTION ViewDef()
	Local oModel   := FWLoadModel('QADA250A')
	Local oStruQUK := FWFormStruct(2,'QUK')
	Local oView
			
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddGrid( 'VIEW_QUK', oStruQUK, 'QUKDETAIL' )	
	oView:CreateHorizontalBox( 'TELA', 100 )	
	oView:SetOwnerView( 'VIEW_QUK', 'TELA' )
	oView:AddIncrementField( 'VIEW_QUK', 'QUK_CODREU' )
	oView:AddUserButton( STR0006 ,'MAGIC_BMP', {|| Q250ANEXO() } )	
	
	oStruQUK:RemoveField("QUK_FILIAL")
	oStruQUK:RemoveField("QUK_NUMAUD")
	oStruQUK:RemoveField("QUK_CODOBS")
	
RETURN oView


//--------------------------------------------------------------------
/*/{Protheus.doc} QAD250APOS(oModel)
Pos valid da grid
@author Geovani.Figueira
@since 22/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
STATIC FUNCTION QAD250APOS()
	Local oModel    := FWModelActive()
	LOCAL oModelGrid := oModel:GetModel('QUKDETAIL')	 
	
	oModel:LoadValue('QUBMASTER2','NUMAUD',oModel:GetValue('QUBMASTER2','NUMAUD'))
	
	IF EMPTY(oModelGrid:GetValue('QUK_HORARE')) .OR. oModelGrid:GetValue('QUK_HORARE') == "  :  " .OR. ;
	   SUBSTR(oModelGrid:GetValue('QUK_HORARE'),1,2) > '23' .OR. SUBSTR(oModelGrid:GetValue('QUK_HORARE'),4,2) > '59' .OR. ;
	   LEN(ALLTRIM(SUBSTR(oModelGrid:GetValue('QUK_HORARE'),1,2))) # 2 .OR. LEN(ALLTRIM(SUBSTR(oModelGrid:GetValue('QUK_HORARE'),4,2))) # 2
		Help(" ",1,"Q_HORAINVA")  // Formato da Hora informada invalido
        RETURN .F.
    ENDIF
    	
RETURN .T.


//--------------------------------------------------------------------
/*/{Protheus.doc} Q250ANEXO()
Anexar Ata
@author Geovani.Figueira
@since 26/07/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
STATIC FUNCTION Q250ANEXO()
	LOCAL oModel    := FWModelActive()
	LOCAL oModelQUK := oModel:GetModel('QUKDETAIL')
	LOCAL cQPathQAD := ALLTRIM(GETMV("MV_QADPDOC"))
	LOCAL cArquivo  := oModelQUK:GetValue('QUK_ANEXO')
	LOCAL nOpcx     := oModelQUK:GetOperation()
	LOCAL cNewArq   := ""
	LOCAL nHandle   := 0
	
	cNewArq   := ALLTRIM(oModel:GetValue('QUBMASTER2','NUMAUD'))+"REU"+ ALLTRIM(oModelQUK:GetValue('QUK_CODREU'))+".xxx"
	cQPathQAD := ALLTRIM(GETMV("MV_QADPDOC"))
	cArquivo  := oModelQUK:GetValue('QUK_ANEXO')
	nOpcx     := oModelQUK:GetOperation()
	
	// Consistencia do parametro de Anexos
	IF EMPTY(cQPathQAD)  
		Help(" ",1,"QADNAOANEX")	
		RETURN(cArquivo) 
	ENDIF
	
	IF !Right( cQPathQAD,1 ) == "\"
		cQPathQAD := cQPathQAD + "\"
	ENDIF
	
	nHandle := fCreate(cQPathQAD+"SIGATST.CEL")
	IF nHandle <> -1
		fClose(nHandle)
		fErase(cQPathQAD+"SIGATST.CEL")
	ELSE
		Help(" ",1,"QADNAOANEX")	
		RETURN(cArquivo) 
	ENDIF
	
	IF EMPTY(cArquivo)
		cArquivo:=FQADDrive(IIF(nOpcx==1,2,nOpcx),,cNewArq)
	ELSE
		FQADDrive(IIF(nOpcx==1,2,nOpcx),cArquivo)
	ENDIF
	
	IF nOpcx == 3 .OR. nOpcx == 4 // Incluir / Alterar
		oModelQUK:SetValue('QUK_ANEXO',cArquivo)
	ENDIF	      

RETURN .T.


STATIC FUNCTION Q250AGRV(oModel)
	LOCAL lOk := .T.
	LOCAL nx  := 1
	LOCAL cQPathQAD  := Alltrim(GetMv("MV_QADPDOC"))
	LOCAL aQPath     := QDOPATH()
	LOCAL cQPathTrm  := aQPath[3] 
	LOCAL oModelGrid := oModel:GetModel('QUKDETAIL')
		
    IF !Right( cQPathQAD,1 ) == "\"
		cQPathQAD := cQPathQAD + "\"
	ENDIF
	IF !Right( cQPathTrm,1 ) == "\"
		cQPathTrm := cQPathTrm + "\"
	ENDIF
	
	FOR nx := 1 TO oModelGrid:Length()
		oModelGrid:GoLine(nx)
		IF oModel:GetOperation() == 5 .OR. oModelGrid:IsDeleted()	
			IF FILE(cQPathQAD+Alltrim(oModelGrid:GetValue('QUK_ANEXO')))
				FERASE(cQPathQAD +Alltrim(oModelGrid:GetValue('QUK_ANEXO')))
			ENDIF
	
			IF FILE(cQPathTrm+Alltrim(oModelGrid:GetValue('QUK_ANEXO')))
				FERASE(cQPathTrm +Alltrim(oModelGrid:GetValue('QUK_ANEXO')))
			ENDIF
		ENDIF
	NEXT nx    
	
	FWFormCommit(oModel)
	
RETURN .T.
