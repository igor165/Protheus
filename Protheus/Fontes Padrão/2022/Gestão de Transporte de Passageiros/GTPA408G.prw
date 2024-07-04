#INCLUDE "PROTHEUS.CH"  
#INCLUDE 'FWMVCDEF.CH'

Static oMdlG52
Static oTempTable
//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GTPA408G


@author Inovação

@since 24/01/2018
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Function GTPA408G(oModel,nLine)

Local lRet 		:= .T.

oMdlG52	:= oModel:GetModel("G52DETAIL")
oMdlG52:GoLine(nLine)

DbSelectArea("GZC")
GZQ->(DbSetOrder(1))

If GZQ->(DbSeek(xFilial("GZQ")+oMdlG52:GetValue("G52_CODIGO")+oMdlG52:GetValue("G52_SEQUEN")+oMdlG52:GetValue("G52_SERVIC")))	
	FWExecView( "Seccionamento" , "VIEWDEF.GTPA408G", MODEL_OPERATION_VIEW, /*oDlg*/, ; //"Seleção de Localidade"
						{|| .T. } ,/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
Else
	Help( ,, 'Help',"GTPA408G","Escala " + oMdlG52:GetValue("G52_CODIGO") + " Sequência " + Str(nLine) + " não possui nenhum seccionamento", 1, 0 ) //"Tipo de Documento já cadastrado."
	lRet	:= .F.
EndIF

Return (lRet)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ModelDef


@author Inovação

@since 24/01/2018
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStrGIE	:= FWFormStruct(1, 'GIE')
Local oStrG52	:= FWFormStruct(1, 'G52')
Local aRelation	:= {}

G408GStruct(oStrG52,oStrGIE)

oModel := MPFormModel():New("GTPA408G")

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("G52MASTER", , oStrG52)

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid("GIEDETAIL", "G52MASTER", oStrGIE,,,,,{|oGrid| TP408GLoad(oGrid)})

aAdd(aRelation, {"GIE_FILIAL","XFILIAL('GIE')"})
aAdd(aRelation, {"GIE_CODGID","G52_SERVIC"})

oModel:SetRelation('GIEDETAIL', aRelation, GIE->(IndexKey(1)) )


oModel:SetDescription("TESTE")						//"Histórico Manutenção Operacional"
oModel:GetModel("G52MASTER"):SetDescription("TESTE")//"Histórico Operacional - Master"
oModel:GetModel("GIEDETAIL"):SetDescription("TESTE")//"Histórico Operacional - Detalhes"


oModel:GetModel("GIEDETAIL"):SetOnlyQuery(.t.)
oModel:SetPrimaryKey({})

oModel:SetActivate( {|oModel| InitDados(oModel) } )

Return(oModel)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ViewDef


@author Inovação

@since 24/01/2018
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Static Function ViewDef()
Local oModel	:= ModelDef()
Local oView		:= Nil
Local oStrG52	:= FwFormStruct(2, "G52", {|cCampo| AllTrim(cCampo)+"|" $ "G52_CODIGO|G52_SERVIC|G52_SEQUEN|G52_LINHA|G52NLIN|"})
Local oStrGIE	:= FwFormStruct(2, "GIE", {|cCampo| AllTrim(cCampo)+"|" $ "GIE_CODGID|GIE_SENTID|GIE_SEQ|GIE_HORLOC|GIE_IDLOCP|GIE_DESCLP|GIE_HORDES|GIE_IDLOCD|GIE_DESCLD|GIE_NUMSRV|"})

G408GStruct(oStrG52,oStrGIE,"V")

oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VW_G52MASTER', oStrG52, 'G52MASTER')
oView:AddGrid('VW_GIEDETAIL', oStrGIE, 'GIEDETAIL')

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("SUPERIOR" , 25) // cabeçalho
oView:CreateHorizontalBox("INFERIOR" , 75) // montagem da escala

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VW_G52MASTER', 'SUPERIOR')
oView:SetOwnerView('VW_GIEDETAIL', 'INFERIOR')


Return(oView)



//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} TP408GLoad

Realiza a carga da grid GIE dos trechos seccionado

@author Inovação

@since 25/08/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function TP408GLoad(oGrid)

Local aFldConv	:= {}
Local aRet		:= {}
Local cSeqIni	:= "0001"
Local cCodGID	:= oMdlG52:GetValue("G52_SERVIC")
Local cEscala	:= oMdlG52:GetValue("G52_CODIGO")
Local cQry		:= ""
Local cField	:= GTPFld2Str(oGrid:GetStruct(),.t.,aFldConv)
Local cAliasGZQ	:= GetNextAlias()
// Local oTempTable

BeginSQL alias cAliasGZQ
								
 SELECT MAX(GZQ.GZQ_SEQSER) as SeqFim
	FROM %Table:GZQ% GZQ
	WHERE 
		GZQ.GZQ_FILIAL = %xFilial:GZQ%
		AND GZQ.GZQ_SERVIC = %Exp:cCodGID%
		AND GZQ.GZQ_ESCALA = %Exp:cEscala%
		AND GZQ.%NotDel%
			 
EndSQL


cField += ",GI1ORI.GI1_DESCRI AS GIE_DESCLP "
cField += ",GI1DES.GI1_DESCRI AS GIE_DESCLD "

cQry := "SELECT " + chr(13)
cQry += "	" +	cField  + space(1) + chr(13)
cQry += "FROM " + chr(13)
cQry += "	" + RetSQLName("GIE") + " GIE " + chr(13)

cQry += " 	INNER JOIN " + RetSQLName("GI1") +" GI1ORI " 		+ Chr(13)
cQry += "			ON GI1ORI.GI1_FILIAL = '"+xFilial('GI1')+"' 	" 	+ Chr(13)
cQry += "			AND GI1ORI.GI1_COD = GIE.GIE_IDLOCP	" 	+ Chr(13)
cQry += "			AND GI1ORI.D_E_L_E_T_=' '	" 			+ Chr(13)

cQry += " 	INNER JOIN " + RetSQLName("GI1") +" GI1DES " 		+ Chr(13)
cQry += "			ON GI1DES.GI1_FILIAL = '"+xFilial('GI1')+"' 	" 	+ Chr(13)
cQry += "			AND GI1DES.GI1_COD = GIE.GIE_IDLOCD	" 	+ Chr(13)
cQry += "			AND GI1DES.D_E_L_E_T_=' '	" 			+ Chr(13)

cQry += "WHERE " + chr(13)
cQry += "	GIE_FILIAL = '" + xFilial("GIE") + "' " + chr(13)
cQry += "	AND GIE.D_E_L_E_T_ = ' ' " + chr(13)
cQry += "	AND GIE_SEQ Between '" + cSeqIni + "' " + " AND " + "'" +  (cAliasGZQ)->SeqFim + "'" + chr(13) 
cQry += "	AND GIE.GIE_CODGID =  " + "'" + cCodGID + "'" + chr(13)
//RADU: PROJETO JCA -DSERGTP-8012
GTPNewTempTable(cQry,"SEC",{{"INDEX1",{"GIE_CODGID"}}},aFldConv,@oTempTable) //GTPTemporaryTable(cQry,"SEC",{{"INDEX1",{"GIE_CODGID"}}},aFldConv,@oTempTable)

(oTempTable:GetAlias())->(DbGoTop())

aRet := FWLoadByAlias(oGrid, oTempTable:GetAlias())//, oTempTable:GetRealName())

// oTempTable:Delete()
(cAliasGZQ)->(DbCloseArea())	

Return(aRet)


/*/{Protheus.doc} InitDados
    Função responsável para inicializar o cabeçalho 
    @type  Static Function
    @author(s) Yuki Shiroma
    @since 24/01/2018
    @version 1

    @param 	aStrGID, objeto, instância da Classe FWFormModelStruct ou FWFormViewStruct (GIDMASTER)
			aStrGIE, objeto, instância da Classe FWFormModelStruct ou FWFormViewStruct (GIEDETAIL)
			
	@return nil, nulo, Sem retorno
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function InitDados(oModel)

Local oMdlG52A	:= oModel:GetModel("G52MASTER")

oMdlG52A:LoadValue('G52_CODIGO',  oMdlG52:GetValue("G52_CODIGO"))

oMdlG52A:LoadValue('G52_SERVIC',  oMdlG52:GetValue("G52_SERVIC"))

oMdlG52A:LoadValue('G52_SEQUEN',  oMdlG52:GetValue("G52_SEQUEN"))

oMdlG52A:LoadValue('G52_LINHA',  oMdlG52:GetValue("G52_LINHA"))

oMdlG52A:LoadValue('G52NLIN',  TPNomeLinho(oMdlG52:GetValue("G52_LINHA"), ,oMdlG52:GetValue("G52_SENTID"), ))

Return



/*/{Protheus.doc} G408GStruct
    Função responsável por criar a estrutura dos submodelos, tanto para o model quanto view,
	utilizados pelo MVC. 
    @type  Static Function
    @author(s) 	Yuki Shiroma
    @since 24/01/2018
    @version 1

    @param 	aStrGID, objeto, instância da Classe FWFormModelStruct ou FWFormViewStruct (GIDMASTER)
			aStrGIE, objeto, instância da Classe FWFormModelStruct ou FWFormViewStruct (GIEDETAIL)
			
	@return nil, nulo, Sem retorno
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G408GStruct(oStrG52,oStrGIE,cTipo)
Local aOrdem		:= {}

Default cTipo   := "M"

If ( cTipo == "M" )

	oStrG52:AddField( 	"Desc. Linha",; 			// cTitle
						"Desc. Linha",; 		// cToolTip
						'G52NLIN',; 	// cIdField
						'C', ; 			// cTipo
						80, ; 			// nTamanho
						0, ;		 	// nDecimal
						Nil, ; 		// bValid
						Nil,; 		// bWhen
						Nil, ; 			// aValues/
						Nil, ; 			// lObrigat
						Nil , ; 	// bInit ant. ->{|oModel| G408FSetChecked(oModel,"GIE_CHECK") } 
						Nil, ; 			// lKey
						.F., ; 			// lNoUpd
						.T. ) 			// lVirtual	
						
											
						
Else

						
    
	
	oStrG52:AddField( 	'G52NLIN',; 			// cIdField
						'01',;	 				// cOrdem
						'Desc. Linha',;			 		// cTitulo
						"Desc. Linha",; 	// cDescric 
						{"Desc. Linha"},; 	// aHelp    
						'Get',; 					// cType
						'@!',; 					// cPicture
						Nil,; 					// nPictVar
						Nil,; 					// Consulta F3
						.t.,; 					// lCanChange
						'' ,; 					// cFolder
						Nil,; 					// cGroup
						Nil,; 					// aComboValues
						Nil,; 					// nMaxLenCombo
						Nil,; 					// cIniBrow
						.T.,; 					// lVirtual
						Nil ) 					// cPictVar
						
					
	aAdd(aOrdem,{"G52_CODIGO","G52_SERVIC"})
    aAdd(aOrdem,{"G52_SERVIC","G52_LINHA"})
	aAdd(aOrdem,{"G52_LINHA","G52NLIN"})
	aAdd(aOrdem,{"G52NLIN","G52_SEQUEN"})

	GTPOrdVwStruct(oStrG52,aOrdem)	
	
EndIf

Return()
