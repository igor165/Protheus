#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA042SXB.CH'

Static cCampo       := ""
Static oTmpTable
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA042SXB
Função de Consulta padrão de campos sx3
@author  jacomo.fernandes
@since   31/07/17
@version 12
/*/
//-------------------------------------------------------------------
Function GTPA042SXB(lAut)

Local lOk           := .F.
Local oDlg          := nil
Local oButtonBar    := Nil
Local bOk           := {|| lOk := .T., oDlg:End()}
Local bCancel       := {|| lOk := .F., oDlg:End() }
Local oPnlBrw       := nil
Local oBrowse       := nil
Local cAlias        := Iif(ValType(oTmpTable) <> "O",GetNextAlias(),oTmpTable:GetAlias())
// Local oTmpTable     := nil
Local aSeek         := {}

Default lAut := .F.  

CreateTable(@oTmpTable,cAlias,lAut)

    if !lAut
        DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 390,781 PIXEL //"Consulta Específica"

            oButtonBar := FWButtonBar():new()
            oButtonBar:Init( oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T. )

            oButtonBar:addBtnText( STR0002	, STR0003	, bOk	  	,,,CONTROL_ALIGN_RIGHT, .T.)//"Confirmar"##"Confirma a consulta"
            oButtonBar:addBtnText( STR0004	, STR0005	, bCancel	,,,CONTROL_ALIGN_RIGHT, .T.)//"Cancelar"##"Cancela a consulta"
                    
                                                
            oPnlBrw 		:= TPanel():New(0,0,"",oDlg,,,,,,0,0)
            oPnlBrw:Align 	:= 5
            
            oBrowse := FWBrowse():New( oPnlBrw ) 
            AddColumns( oBrowse, cAlias, bOk )
            
            oBrowse:SetDataTable(  )
            oBrowse:SetAlias( cAlias )

            aSeek := GetSeekOrder( cAlias ) 
            If len( aSeek ) > 0
                oBrowse:SetSeek( , aSeek )
            Else
                oBrowse:SetSeek()
            EndIf	
            
            oBrowse:Activate()

        ACTIVATE MSDIALOG oDlg CENTERED
    EndIf

	If lOk                  
		cCampo := (cAlias)->CAMPO
	Else
		cCampo := ""
	EndIf

    // if !lAut
   	//     oTmpTable:Delete()
    // EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA042SXB
Função de Consulta padrão de campos sx3
@author  jacomo.fernandes
@since   31/07/17
@version 12
/*/
//-------------------------------------------------------------------
Function GTPA042RET()
Return cCampo

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA042SXB
Função de Consulta padrão de campos sx3
@author  jacomo.fernandes
@since   31/07/17
@version 12
/*/
//-------------------------------------------------------------------
Static Function CreateTable(oTmpTable,cAlias,lAut, cOpTip)
Local nX        := 0
Local cTipo     := ""
Local cQuery    := ""
Local aEntidade := nil
Local cArquivo  := GetArquivo(@cTipo,lAut)
Local aSx3      := Nil

Default cOpTip  := ''

    CreateTRB(@oTmpTable,cAlias,cTipo,lAut)

    if lAut
        cTipo := cOpTip
    endif

    If lAut .or. "SX2" $ cTipo
        If cTipo == "SX21"
            aEntidade := G042GetEnt(1,FwModelActive())
        Else
            aEntidade := G042GetEnt(2)
        Endif

        For nX := 1 To Len(aEntidade)
            
            If FwSX2Util():SeekX2File( aEntidade[nX] )
                if !lAut
                    RecLock(cAlias,.T.)
                        (cAlias)->CAMPO     := aEntidade[nX]
                        (cAlias)->TITULO    := FwSX2Util():GetX2Name( aEntidade[nX] )
                    (cAlias)->(MsUnlock())
                Endif
            Endif
        Next
        
    ElseIf  cTipo == "SX3"
        If !Empty(cArquivo)
            aSx3 := FWSX3Util():GetAllFields(cArquivo,.F./*  lVirtual */ )
            For nX := 1 To Len(aSx3)
                If FWSX3Util():GetFieldType(aSx3[nX]) <> "M"
                    cQuery	:= "INSERT INTO "+ oTmpTable:GetRealName() + Chr(13)+Chr(10)
                    cQuery  += "(CAMPO,TITULO,DESCRICAO)"
                    cQuery	+= "VALUES( '" + aSx3[nX] + "','" + FWX3Titulo(aSx3[nX])  + "','" + FWSX3Util():GetDescription(aSx3[nX]) + "' " + ") " + Chr(13)+Chr(10)

                    TcSqlExec(cQuery)
                Endif
            Next
        Endif

    Endif

    if !lAut
        (cAlias)->( dbGoTop() )
    EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA042SXB
Função de Consulta padrão de campos sx3
@author  jacomo.fernandes
@since   31/07/17
@version 12
/*/
//-------------------------------------------------------------------
Static Function CreateTRB(oTmpTable,cAlias,cTipo,lAut)
Local aStru 		:= {}

    If ( Valtype(oTmpTable) <> "O" )

        oTmpTable := FWTemporaryTable():New(cAlias)
        
        If lAut .or. "SX2" $ cTipo 
        
            aAdd(aStru,{ "CAMPO"    , "C", 3,0})
            aAdd(aStru,{ "TITULO"   , "C", 30,0})
            
            oTmpTable:SetFields( aStru )
            
            oTmpTable:AddIndex("CAMPO"      , {"CAMPO"} )
            oTmpTable:AddIndex("TITULO"     , {"TITULO"} )

        ElseIf cTipo == "SX3"
        
            aAdd(aStru,{ "CAMPO"    , "C", 10,0})
            aAdd(aStru,{ "TITULO"   , "C", 12,0})
            aAdd(aStru,{ "DESCRICAO", "C", 25,0})
            
            oTmpTable:SetFields( aStru )
            
            oTmpTable:AddIndex("CAMPO"      , {"CAMPO"} )
            oTmpTable:AddIndex("TITULO"     , {"TITULO"} )
            oTmpTable:AddIndex("DESCRICAO"  , {"DESCRICAO"} )
            
        Endif

        if !lAut
            oTmpTable:Create()
        Endif
	
    Else
        TcSqlExec('TRUNCATE TABLE '+ oTmpTable:GetRealName())
    EndIf

Return
 
/*/{Protheus.doc} AddColumns
Static Function de uso interno da classe para criação das colunas do Browse

@author jacomo.fernandes
@version P12
@param oBrowse		, Objeto		, Objeto TcBrowse utilizado na tela da consulta específica
@param cAlias		, Caractere	, Variável com o Alias da tabela temporária
@param bOK			, CodeBlock	, Codeblock a ser executado no duplo-clique
/*/  
Static Function AddColumns( oBrowse, cAlias, bOK, lAut )

	Local aColumn := {}
	Local aStruct := {}
	Local nPos	  := 0
    
    Default lAut  := .F.

    if !lAut
        aStruct := ( cAlias )->( dbStruct() )
    EndIf

    For nPos := 1 to Len(aStruct)
        aColumn := {	Capital( aStruct[nPos][1] )		,;	//Título da coluna	    
                        &( '{|| ' + aStruct[nPos][1] + ' } ' )  	,;	//Code-Block de carga dos dados	
                        aStruct[nPos][2]								,;	//Tipo de dados
                                                                    ,;	//Máscara
                        Iif(aStruct[nPos][2]=="N",2,1)			,; //Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
                        aStruct[nPos][3]							,; //Tamanho
                        aStruct[nPos][4]							,; //Decimal
                        .F.											,; //Indica se permite a edição
                        {|| .T.}									,; //Code-Block de validação da coluna após a edição					
                        .F.											,; //Indica se exibe imagem
                        bOk											,; //Code-Block de execução do duplo clique
                        nil											,; //Variável a ser utilizada na edição (ReadVar)
                        {|| .T.}									,; //Code-Block de execução do clique no header
                        .F.											,; //Indica se a coluna está deletada
                        .F.											,; //Indica se a coluna será exibida nos detalhes do Browse
                                                                    ,; //Opções de carga dos dados (Ex: 1=Sim, 2=Não)
                        cValToChar(nPos)							,; //Id da coluna
                        .F.											;  //Indica se a coluna é virtual
                        }
        oBrowse:AddColumn( aColumn )	     			
    Next
    
Return

 
/*/{Protheus.doc} AddColumns
Static Function de uso interno da classe para criação das colunas do Browse
@author jacomo.fernandes
@version P12
@param oBrowse		, Objeto		, Objeto TcBrowse utilizado na tela da consulta específica
@param cAlias		, Caractere	, Variável com o Alias da tabela temporária
@param bOK			, CodeBlock	, Codeblock a ser executado no duplo-clique
/*/  
Static Function GetSeekOrder( cAlias, lAut )

	Local aAuxDetail	:= {}
	Local aDetail	:= {}
	Local aRet		:= {}
	Local aStruct	:= {}
    Local nPos		:= 0

    Default lAut    := .F.

    if !lAut
        aStruct	:= ( cAlias )->( dbStruct() )
    EndIf

    aDetail := {}
        //[n,2,n,1] LookUp
        //[n,2,n,2] Tipo de dados
        //[n,2,n,3] Tamanho
        //[n,2,n,4] Decimal
        //[n,2,n,5] Título do campo
        //[n,2,n,6] Máscara
        
    For nPos := 1 to len(aStruct )
        
        aAuxDetail := 	{ 	""											,; // LookUp
                                aStruct[nPos][2]							,; // Tipo de dados
                                aStruct[nPos][3]							,; 	// Tamanho
                                aStruct[nPos][4]							,; 	// Decimal
                                AllTrim( Capital( aStruct[nPos][1] ) )	,; 	// Título do campo
                                ""											;	// Máscara
                            }
                            
        aAdd( aDetail, aAuxDetail )					
        aAdd( aRet, {aStruct[nPos][1] , aDetail, nPos, .T. }     )
    Next
	
Return aRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetArquivo()
description
@author  jacomo.fernandes
@since   31/07/17
@version 12
/*/
//-------------------------------------------------------------------
Static Function GetArquivo(cTipo,lAut,cId)
Local cRet      := ""
Local oModel    := FwModelActive()
Local cCampo    := SubStr(ReadVar(),4)
Local cIdMod    := ''

Default cId     := ''

if lAut
    cIdMod := cId
Else
    cIdMod := oModel:GetId()
EndIf

If cIdMod == "GTPA042"
    If cCampo == "GY7_CAMPO"
        cRet := oModel:GetModel('GRIDGY7'):GetValue('GY7_ENTIDA')
        cTipo := "SX3"
    ElseIf cCampo == "GY7_ENTIDA"
        cTipo := "SX21"
    Endif

ElseIf cIdMod == "GTPA042B"
    If cCampo == "GY6_CAMPO1"
        cRet := oModel:GetModel('GY6MASTER'):GetValue('GY6_ENTID1')
        cTipo := "SX3"
    ElseIf cCampo == "GY6_CAMPO2"
        cRet := oModel:GetModel('GY6MASTER'):GetValue('GY6_ENTID2')
        cTipo := "SX3"
    ElseIf cCampo == "GY6_ENTID1" .OR. cCampo == "GY6_ENTID2"
        cTipo := "SX21"
    Endif
ElseIf cIdMod == "GTPA042C"
    If cCampo == "GY6_CAMPO1"
        cRet := oModel:GetModel('GY6MASTER'):GetValue('GY6_ENTID1')
        cTipo := "SX3"
    Endif
ElseIf cIdMod == "GTPA042D"
    If cCampo == "GY5_ENTIDA"
        cTipo := "SX22"
    Endif
Endif

Return cRet
