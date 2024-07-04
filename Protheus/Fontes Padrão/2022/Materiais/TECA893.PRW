#include "TECA893.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

STATIC nPosRec  := 1 // posicao do array da TFS em relacao a TFG
STATIC aDados   := {}
STATIC lMsHelpAuto 	:= .T. 			// Controle interno do ExecAuto
STATIC lMsErroAuto 	:= .F. 			// Informa a ocorrência de erros no ExecAuto
STATIC lAutoErrNoFile := .F.
STATIC cRetProd	:= ""

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Retorno Material de Implantação 

@Return 	model
@author 	Serviços
@since 		17/08/2015
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStrCab	:= FWFormStruct(1,"TFL")
Local oStrTFG := FWFormStruct(1,"TFG")
Local oStrTFS := FWFormStruct(1,"TFS")
Local bCommit 		:= {|oModel| At893Commit(oModel)}

aAux := FwStruTrigger("TFS_PRODUT","TFS_DPROD","At893DscPr()",.F.,Nil,Nil,Nil)
oStrTFS:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

oModel := MPFormModel():New("TECA893", /*bPreValidacao*/,/*{|oModel|at893pos(oModel)}*/,bCommit,/*bCancel*/ )

//Criando master falso para a alimentação dos details.
oModel:AddFields("000MASTER",/*cOwner*/,oStrCab, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:AddGrid( "TFGDETAIL", "000MASTER", oStrTFG,/*bLinePre*/,/*{|oModel| At581VlTW1(oModel)}*/,/*bPreVal*/ ,/*bPosVal*/ , {|oModel| SelecTFG(oModel) } )
oModel:SetDescription(STR0014) //"Retorno Material de Implantação"
 
oModel:AddGrid( "TFSDETAIL", "TFGDETAIL", oStrTFS,/*bLinePre*/,/*{|oModel| At581VlTW1(oModel)}*/,/*bPreVal*/ ,/*bPosVal*/ , {|oModel| SelecTFS(oModel) } )
oModel:SetRelation( "TFSDETAIL", { { "TFS_FILIAL", "xFilial('TFS')" }, { "TFG_COD", "TFS_CODTFG" } }, TFS->(IndexKey(1)) )
oModel:SetDescription(STR0014) 

oStrTFS:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
oStrTFS:SetProperty( "TFS_PRODUT", MODEL_FIELD_OBRIGAT,.T.)
oStrTFS:SetProperty( "TFS_QUANT" , MODEL_FIELD_OBRIGAT,.T.)
oStrTFS:SetProperty( "TFS_LOCAL" , MODEL_FIELD_OBRIGAT,.T.)
oStrTFS:SetProperty( "TFS_TM"    , MODEL_FIELD_OBRIGAT,.T.)


oStrTFS:SetProperty( "TFS_CODTFL", MODEL_FIELD_INIT, {|oMdl| oMdl:GetModel():GetModel("000MASTER"):GetValue("TFL_CODIGO") } )
oStrTFS:SetProperty( "TFS_CODTFG", MODEL_FIELD_INIT, {|oMdl| oMdl:GetModel():GetModel("TFGDETAIL"):GetValue("TFG_COD") } )
oStrTFS:SetProperty( "TFS_DPROD",  MODEL_FIELD_INIT, {|| "" }  )
oStrTFS:SetProperty( "TFS_MOV"  , MODEL_FIELD_INIT, {|| "2" } ) //tipo movimento de retorno

// Pré Validação de Edição
oStrTFS:SetProperty("TFS_TM", MODEL_FIELD_VALID,{ |oModel| At893TM(oModel,'TFS_TM')})
oStrTFS:SetProperty("TFS_QUANT", MODEL_FIELD_VALID,{ |oModel,cFld| at893pre(oModel, cFld)})

oStrTFG:SetProperty('TFG_PRCVEN',MODEL_FIELD_OBRIGAT,.F.)
oStrTFG:SetProperty('TFG_TES',MODEL_FIELD_OBRIGAT,.F.)

oModel:GetModel('TFGDETAIL'):SetOptional(.T.)
oModel:GetModel('TFSDETAIL'):SetOptional(.T.)

oModel:getModel('TFGDETAIL'):SetNoInsertLine()
oModel:getModel('TFGDETAIL'):SetNoDeleteLine()

//Desabilita a Gravação automatica do Model 
oModel:GetModel( '000MASTER'):SetOnlyQuery ( .T. )
oModel:SetPrimarykey({})

Return(oModel)

//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Relacionamentos - Gestão de Escalas 

@Return 	view
@author 	Serviços
@since 		17/08/2015
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel	:= FWLoadModel("TECA893")
Local oStrCab	:= FWFormStruct( 2, "TFL" , {|cCpo| AllTrim(cCpo)$'TFL_CONTRT+TFL_LOCAL' }) 
Local oStrTFG	:= FWFormStruct( 2, "TFG" , /*{|cCpo| AllTrim(cCpo)$'TFG_COD+TFG_LOCAL' }*/  )
Local oStrTFS	:= FWFormStruct( 2, "TFS" , /*{|cCpo| AllTrim(cCpo)$'TFS_COD+TFSG_CODTFG' }*/ )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddUserButton(STR0001,"",{|oView| At893Res(oModel)},,,) //"Eliminar resíduo" 
oView:AddField('FORM_FAKE',oStrCab	,'000MASTER') //Cabeçalho falso
oView:AddGrid('VIEW_TFG'	,oStrTFG ,'TFGDETAIL' ) //Retorno Material de Implantação
oView:AddGrid('VIEW_TFS'	,oStrTFS ,'TFSDETAIL' ) //Historico MI

oView:CreateHorizontalBox('BOXCABEC'	 , 0) //Cabeçalho
oView:CreateHorizontalBox ( 'SUPERIOR' , 30 )
oView:CreateHorizontalBox ( 'INFERIOR' , 70 )

oView:SetOwnerView('FORM_FAKE'	,'BOXCABEC' )	// Cabeçalho
oView:SetOwnerView( 'VIEW_TFG' , 'SUPERIOR' ) 
oView:SetOwnerView( 'VIEW_TFS' , 'INFERIOR' )

oStrTFG:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
oStrTFS:SetProperty('TFS_PRODUT',MVC_VIEW_CANCHANGE,.T.)
oStrTFS:SetProperty('TFS_CODTFG',MVC_VIEW_CANCHANGE,.F.)
oStrTFS:SetProperty('TFS_MOV',MVC_VIEW_CANCHANGE,.F.)
oStrTFS:SetProperty('TFS_PRODUT',MVC_VIEW_LOOKUP,'TFSRET' ) //consulta especifica

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} SelecTFG
	Função que realiza a carga dos dados no grid dos itens de material de implantação
@sample 	SelecTFG()
@since		18/08/2015       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function SelecTFG(oModel)
Local aRet    	:= {}
Local cTmpQry  	:= GetNextAlias()
Local cCodTFL	:= FWFLDGET("TFL_CODIGO")
Local lOrcPrc
Local aArea := GetArea()
Local cRevTFL      := FWFLDGET("TFL_CONREV")

DbSelectArea("TFJ")
DBSetOrder(1)
lOrcPrc := DbSeek(xFilial("TFJ") + FWFLDGET("TFL_CODPAI")) .AND. !EMPTY(TFJ->TFJ_CODTAB)
RestArea(aArea)

aDados:={}
nPosRec:= 1

If lOrcPrc
	BeginSql Alias cTmpQry
		
		COLUMN TFG_PERINI AS DATE
		COLUMN TFG_PERFIM AS DATE
		
		SELECT  
		(Select B1_DESC FROM %Table:SB1% SB1 WHERE B1_COD = TFG_PRODUT AND SB1.%NotDel% AND %xFilial:SB1% = B1_FILIAL	) AS TFG_DESCRI,
		TFG.* 
		FROM %Table:TFL% TFL
		inner join %Table:TFG% TFG on %xFilial:TFL% = TFG_FILIAL 
				AND TFG_CODPAI = TFL_CODIGO  
				AND TFG.%NotDel% 
		WHERE	TFL.TFL_FILIAL = %xFilial:TFL% 	
		AND TFL_CODIGO =  %Exp:cCodTFL%
		AND TFG_CONREV =  %Exp:cRevTFL%
		AND TFL.%NotDel%
		AND TFG.%NotDel%
	EndSql
Else
	BeginSql Alias cTmpQry
	
		COLUMN TFG_PERINI AS DATE
		COLUMN TFG_PERFIM AS DATE
		
		SELECT  
		(Select B1_DESC FROM %Table:SB1% SB1 WHERE B1_COD = TFG_PRODUT AND SB1.%NotDel% AND %xFilial:SB1% = B1_FILIAL	) AS TFG_DESCRI,
		TFG.* 
		FROM %Table:TFL% TFL
		inner join %Table:TFF% TFF on %xFilial:TFL% = TFF_FILIAL AND TFF_CONTRT = TFL_CONTRT AND TFF.%NotDel%
		inner join %Table:TFG% TFG on %xFilial:TFL% = TFG_FILIAL 
				AND TFG_CODPAI = TFF_COD 
				AND TFG.%NotDel% 
		WHERE	TFL.TFL_FILIAL = %xFilial:TFL% 	
		AND TFL_CODIGO = %Exp:cCodTFL%
		AND TFF_CODPAI = %Exp:cCodTFL%
		AND TFG_CONREV = %Exp:cRevTFL%
		AND TFL.%NotDel%
		AND TFG.%NotDel%
	EndSql
EndIf

aRet := FwLoadByAlias( oModel, cTmpQry )

(cTmpQry)->(DbGoTop())
(cTmpQry)->(DbEval( {|| AADD(aDados,(cTmpQry)->(R_E_C_N_O_))} ))

(cTmpQry)->(DbCloseArea())

Return aRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} SelecTFS
	Função que realiza a carga dos dados no grid dos itens de material de implantação
@sample 	SelecTFG()
@since		18/08/2015       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function SelecTFS(oModel)

Local aRet    	  := {}
Local cTmpQry     := GetNextAlias()

If Len(aDados) > 0
	DbSelectArea("TFG")
	
	TFG->(DbGoto(aDados[nPosRec]))
			
	BeginSql Alias cTmpQry
		
		COLUMN TFS_DTAPON AS DATE
		
		SELECT  
		(Select B1_DESC FROM %Table:SB1% SB1 WHERE B1_COD = TFS_PRODUT AND SB1.%NotDel% AND %xFilial:SB1% = B1_FILIAL	) AS TFS_DPROD, 
		TFS.*
		FROM %Table:TFS% TFS
		WHERE	TFS.TFS_FILIAL = %xFilial:TFS% 	
		AND TFS_CODTFG = %Exp:TFG->TFG_COD% 
		AND TFS.TFS_MOV = '2'
		AND TFS.%NotDel%
	EndSql
	
	aRet := FwLoadByAlias( oModel, cTmpQry )
	
	(cTmpQry)->(DbCloseArea())
	
	nPosRec++
EndIf
Return aRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} At893F3Cn

				A consulta padrão de produto deverá realizar um distinct dos produtos 
				apontados e enviados para o posto. 

@sample		At893F3Cn 
	
@since		20/08/2015 
@version 	P12

@param		
/*/
//-------------------------------------------------------------------------------
Function At893F3Cn()

Local aCmpTFS		:= {}
Local cCampo1		:= ""
Local lOk			:= .F.
Local oDlgTFS 		//Dialog
Local oPanel 		//Objeto Panel
Local oFooter		//Rodapé
Local oListBox		//Grid campos
Local oOk			//Objeto Confirma 
Local oCancel		//Objeto Cancel
Local tmpTFS 		:= ""
Local oModel 		:= FWModelActive()
Local oViewTFS		:= FWViewActive()
Local oMdlTFG 		:= oModel:Getmodel("TFGDETAIL")
Local oMdlTFS		:= oModel:Getmodel("TFSDETAIL")
Local cCodTFG		:= oMdlTFG:GetValue("TFG_COD")

//A consulta padrão de produto deverá realizar um distinct dos produtos apontados e 
//enviados para o posto. Para identificar estes produtos deverá ser utilizado o campo TFS_CODTFG 
//que deve ter o mesmo conteúdo do campo TFG_COD (grid superior) e o campo TFS_MOV diferente de '2'. 
//Essa consulta deverá ser específica e será a partir do campo TFS_PRODUT. 
//Os campos que devem ser exibidos para o usuário são: código do produto, 
//descrição do produto, unidade de medida e o total enviado.

//montar query
tmpTFS:=GetNextAlias()
BeginSql Alias tmpTFS
SELECT TFS_PRODUT,
    (SELECT B1_DESC FROM %table:SB1% SB1 
    	WHERE %xFilial:SB1% = B1_FILIAL 
	    	AND SB1.%NotDel%
	    	AND B1_COD = TFS_PRODUT) AS B1_DESC,
    (SELECT B1_UM FROM %table:SB1% SB1 
    	WHERE %xFilial:SB1% = B1_FILIAL 
	    	AND SB1.%NotDel% 
	    	AND B1_COD = TFS_PRODUT) AS B1_UM,
        TFS_QUANT
	FROM %Table:TFS% TFS
	INNER JOIN  %table:TFG% TFG ON %xFilial:TFG% = TFG_FILIAL
		AND TFG.TFG_COD = TFS.TFS_CODTFG
		AND TFS.TFS_CODTFG = %exp:cCodTFG%
	WHERE TFS.TFS_FILIAL = %xFilial:TFS%
	  AND TFS.TFS_MOV <> '2'
	  AND TFG.TFG_RESRET = 0
	  AND TFS.%NotDel%
EndSql

DbSelectArea(tmpTFS)
DbGoTop(tmpTFS)
While !EOF()
		AADD(aCmpTFS,{(tmpTFS)->TFS_PRODUT,; //produto
			 (tmpTFS)->B1_DESC,;        	  //descricao produto
			 (tmpTFS)->B1_UM ,; 		         // unidade de medida
			 (tmpTFS)->TFS_QUANT ,;		      //quantidade
			  })
	dBSkip()
Enddo
(tmpTFS)->(DbCloseArea())

If len(aCmpTFS) > 0
//	Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela 
	Define MsDialog oDlgTFS FROM 000, 000 To 200, 600 Pixel
		
	//Cria o panel principal
	@ 000, 000 MsPanel oPanel Of oDlgTFS Size 250, 350 // Coordenada para o panel
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
	aHeader:={STR0015,STR0016,STR0017,STR0018} // 'Produto','Descrição','UM','Qtde Enviada'
	//cCampos:=""
	// Criação do grid para o panel	
	oListBox := TWBrowse():New( 40,05,204,100, ,aHeader,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,) // Campo#Descricao	  
	oListBox:SetArray(aCmpTFS) // Atrela os dados do grid com a matriz
	oListBox:bLine := { ||{aCmpTFS[oListBox:nAT][1],aCmpTFS[oListBox:nAT][2],aCmpTFS[oListBox:nAT][3],aCmpTFS[oListBox:nAT][4]}} // Indica as linhas do grid
	oListBox:bLDblClick := { ||Eval(oOk:bAction), oDlgTFS:End()} // Duplo clique executa a ação do objeto indicado
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse
	
	// Cria o panel para os botoes	
	@ 000, 000 MsPanel oFooter Of oDlgTFS Size 000, 010 // Corrdenada para o panel dos botoes (size)
	oFooter:Align   := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
		
	// Botoes para o grid auxiliar	
	@ 000, 000 Button oCancel Prompt STR0019  Of oFooter Size 030, 000 Pixel //Cancelar 
	oCancel:bAction := { || lOk := .F., oDlgTFS:End() }
	oCancel:Align   := CONTROL_ALIGN_RIGHT
	
	@ 000, 000 Button oOk     Prompt STR0020 Of oFooter Size 030, 000 Pixel //Confirmar  
	oOk:bAction     := { || lOk := .T.,(cCampo1:=aCmpTFS[oListBox:nAT][1]),oDlgTFS:End() } // Acao ao clicar no botao
	oOk:Align       := CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel
	// Ativa a tela exibindo conforme a coordenada
	Activate MsDialog oDlgTFS Centered		
	
	If lOk
		cRetProd := cCampo1
	EndIf	
Else
	lOk := .F.	
	Aviso( STR0002, STR0003, { STR0004 }, 2 )		//"Atenção", "Não existem itens para retornar"
Endif
Return lOk 

//-------------------------------------------------------------------
/*/{Protheus.doc} At893F3Ret 

			Retornar o código do item selecionado na funacao consulta  
			itens para retorno material de implantacao

@sample		At893F3Ret
	
@since		20/08/2015 
@version 	P12

@param		
/*/
Function At893F3Ret()

Return cRetProd

//-------------------------------------------------------------------
/*/{Protheus.doc} At893DscPr 

			Retornar o descrição do produto 

@sample		At893DscPr
	
@since		21/08/2015 
@version 	P12

@param		
/*/
//-------------------------------------------------------------------
Function At893DscPr()

Local oModel		:= FWModelActive()
Local oModelTFS	:= oModel:GetModel("TFSDETAIL")
Local cDesc:= ""
Local cPRod:= ""

cProd:=  oModelTFS:GetValue("TFS_PRODUT")
cDesc := Posicione("SB1",1,xFilial("SB1") + cProd ,"SB1->B1_DESC")

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} At893TM(oModel,cCampo) 

			Validar tipo de movimento 

@sample		At893DscPr
	
@since		21/08/2015 
@version 	P12

@param		
/*/
Function At893TM(oModel,cCampo)

Local oModel		:= FWModelActive()
Local oModelTFS	:= oModel:GetModel("TFSDETAIL")
Local cCampo:=""
Local lRet:= .F.
Local:= cTipo:=""

//verificar se e tipo movimento de retorno

cTipo:=Posicione("SF5",1,xFilial("SF5")+oModelTFS:GetValue("TFS_TM"),"F5_TIPO")

If cTipo <> "D"
	lRet:= .F.
	Aviso( STR0005, STR0006,;
		 { 	STR0007 }, 2 )// "Retorno Material de Implantação", "Favor informar coódigo com tipo de movimento de Devolução " # "OK" 
Else
	lRet:= .T.
Endif

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At893Commit

Realiza a Gravação dos Dados utilizando o Model
@sample   
@author  Serviços
@since 	  24/08/15
@version P12
@param ExpO:Modelo de Dados da Tela Material de de Locais de Atendimento

@return ExpL: Retorna .T. quando houve sucesso na Gravação
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At893Commit(oModel)

Local lRetorno 	:= .T.
Local lConfirm 
Local nOperation	:= oModel:GetOperation()
//verificar se e inclusao, exclusao

At893ExcAt(oModel)


Return( lRetorno )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At893ExcAt

Realiza a Gravação dos dados utilizando a ExecAuto MATA240 para inclusão e estorno de retorno material implantação.
no Modulo Estoque
@sample  At893ExcAt() 
@author  Serviços
@since 	  24/08/15
@version P12
@param ExpO:Modelo de Dados da Tela de Retorno Material de Implantação
@return ExpL: Retorna .T. quando houve sucesso na ExecAuto
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At893ExcAt(oModel)

Local aLinha		:= {}						// array que será passado com os valores no execauto para preencher a tabela 
Local lRetorno	:= .T.						// Validador de retorno, caso ocorra algum erro, ele retorna false, evitando que seja adicionado dados na tabela ABV
Local lAlter		:= .F.						// Será quem definirá se houve ou não alteração em alguma linha do grid
Local xI			:= 1
Local xY			:= 1
Local aArea		:= GetArea()				// Pega posição GetArea()
Local aSaveLines	:= FWSaveRows()
Local aDados		:= {}
Local oModelTFS	:= oModel:GetModel("TFSDETAIL")
Local oModelTFG	:= oModel:GetModel('TFGDETAIL')
Private l185		:= .F.				 		// necessario para chamar a funcao de estorno MATA240
Private l240Auto	:= .T. 					// necessario para chamar a funcao de estorno MATA240
Private cCusMed	:= GetMv("MV_CUSMED") 	// necessario para chamar a funcao de estorno MATA240

// Verificar se é inclusao ou estorno

For xY	:= 1 To oModelTFG:Length()
	oModelTFG:GoLine(xY)
	For xI := 1 To oModelTFS:Length()			//	Percorrerá todo grid do retorno material de implantação
		aLinha:={}
		oModelTFS:GoLine(xI)				
		aSaveLines	:= FWSaveRows()
		If !oModelTFS:IsDeleted() 				//	Verifica se é uma linha deletada
			If oModelTFS:GetValue("TFS_MOV") == '2' .AND. empty(oModelTFS:GetValue("TFS_NUMMOV")) 	//	Verifica o tipo de movimento retorno = 2 e se ainda nao gerou execauto
				aadd(aLinha,{"D3_FILIAL"    ,xFilial("SD3")						,NIL})					//	aLinha array que será enviado pelo execauto MATA240
				aadd(aLinha,{"D3_TM"     	,oModelTFS:GetValue("TFS_TM")		,NIL})
				aadd(aLinha,{"D3_COD"     	,oModelTFS:GetValue("TFS_PRODUT")	,NIL})
				aadd(aLinha,{"D3_QUANT"     ,oModelTFS:GetValue("TFS_QUANT")	,NIL})
				aadd(aLinha,{"D3_LOCAL"		,oModelTFS:GetValue("TFS_LOCAL") 	,NIL})
				aadd(aLinha,{"D3_LOCALIZ"   ,oModelTFS:GetValue("TFS_LOCALI")	,NIL})
				aadd(aLinha,{"D3_CC"      	,oModelTFS:GetValue("TFS_CC")		,NIL})
				aadd(aLinha,{"D3_LOTECTL"   ,oModelTFS:GetValue("TFS_LOTECT")	,NIL})
				aadd(aLinha,{"D3_NUMLOTE"   ,oModelTFS:GetValue("TFS_NUMLOT")	,NIL})
				aadd(aLinha,{"D3_NUMSERI"   ,oModelTFS:GetValue("TFS_NUMSER")	,NIL})			
				MSEXECAUTO({|x|MATA240(x)},aLinha, 3)
				If !lMsErroAuto
					lRetorno	:=	.T.
					// Atualiza numero do movimento
					oModelTFS:LoadValue("TFS_NUMMOV",SD3->D3_NUMSEQ) 
				Else
					MostraErro()
					lRetorno	:=	.F.
				EndIf
			Endif
		Elseif oModelTFS:IsDeleted() 		//	Verifica se é uma linha deletada
				// Fazer estorno do lancamento
				// Posicionar na SD3 e atualizar campo de estorno
				DbSelectArea("SD3")
				DbSetOrder(4)
				If dbSeek(xFilial("SD3")+ oModelTFS:GetValue("TFS_NUMMOV"))
					nReg := SD3->(Recno())
					a240Estorn("SD3",nReg,5)
				Else
					MsgStop(STR0021) 		
				Endif
		Endif		
	Next xI
Next xY
FWFormCommit(oModel)

Return lRetorno

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At893Res(oModel)

Função para usuário eliminar residuo do iem selecionado
	
@sample  At893Res(oModel)
@author  Serviços
@since 	  25/08/15
@version P12
@param 
@return ExpL: Retorna .T. quando houve sucesso 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At893Res(oModel)

Local lRet				:= .F.
Local oModelTFG		:= oModel:GetModel("TFGDETAIL")
Local oModelTFS		:= oModel:GetModel("TFSDETAIL")
Local nQuant			:= oModelTFG:GetValue("TFG_QTDVEN")
Local nResiduo		:= 0
Local nQtTFS			:= 0
Local nTotQtde		:= 0
Local xI				:= 0
Local oView			:= FWViewActive()

//Para os casos em que o retorno não a
//contecerá e é necessário assumir a perda 
//pela prestadora do serviço, deve ser criada a opção para eliminar resíduo no botão outras ações. 
//Esta opção irá utilizar a linha posicionada no grid superior e questionar o usuário se 
//realmente deseja lançar o saldo não retornado como resíduo. A pergunta deve ser semelhante a: 
//"Tem certeza que deseja lançar a quantidade xx como resíduo? Esse lançamento não poderá ser desfeito.", 
//com a confirmação do usuário o valor deve ser inserido no campo "Resíduo Eliminado" e 
//posteriormente gravado na tabela TFG campo TFG_RESRET.

If oModelTFG:GetValue("TFG_RESRET") == 0
	If oModelTFG:Length() = 0
		If MsgYesNo(STR0008 + Ltrim(str(nQuant)) + STR0009,STR0010)		//"Tem certeza que deseja lançar a quantidade xx como resíduo? Esse lançamento não poderá ser desfeito." # "Confirma?" 
			lRet:= .T.
			oModelTFG:SetValue("TFG_RESRET",nQuant)
			oView:Refresh()
			MsgInfo(STR0022) // "Resíduo eliminado com sucesso"
		EndIf
	Else
		//verificar a quantidade a ser devolvida
		For xI:= 1 to oModelTFS:Length()
				oModelTFS:GoLine(xI)
				nQtTFS:=oModelTFS:GetValue("TFS_QUANT")
				nTotQtde:= nTotQtde +  nQtTFS
		Next xI
		nResiduo:= nQuant - nTotQtde
		If MsgYesNo(STR0011 + Ltrim(str(nResiduo)) + STR0012 ,STR0013)	//"Exite(m) item(ns) retornados anteriormente. Deseja mesmo assim eliminar o residuo? Esse lançamento não poderá ser desfeito." ,"Confirma?") 	
			lRet:= .T.
			//somar a quantide de retorno
			oModelTFG:SetValue("TFG_RESRET",nResiduo)
			oView:Refresh()
		Endif
	Endif	
Else 
	MsgStop(STR0023)  //"Item com resíduo ja eliminado"  
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} at893pre 

Valida a quantidade dos valores para retorno, impedindo 
que sejam retornados mais quantidade do que foi apontado
			
@sample	at893pre
@since		24/04/2018
@version 	P12

@author	Diego A. Bezerra

/*/
//-------------------------------------------------------------------
Static Function at893pre(oModelTFS,cFld)

Local nSldApt		:= 0
Local nSldGrd		:= 0
Local nY			:= 1
Local nX			:= 1
Local lRet			:= .F.		
Local cCodTFG 		:= ""
		
If cFld == "TFS_QUANT"
	nSldApt := 0
	nSldGrd := 0
	cCodTFG := oModelTFS:GetValue("TFS_CODTFG")
	
	For nx := 1 To oModelTFS:Length() 
		oModelTFS:GoLine(nX)
		If !oModelTFS:IsDeleted() 
			nSldGrd := nSldGrd + oModelTFS:GetValue("TFS_QUANT")
		EndIf
	Next nX
	
	//montar query
	tmpQry1 :=	GetNextAlias()
	BeginSql Alias tmpQry1
		SELECT  TFS.TFS_PRODUT, TFS.TFS_QUANT, TFS.TFS_MOV 
		FROM %Table:TFS% TFS
		WHERE	TFS.TFS_FILIAL = %xFilial:TFS% 	
		AND TFS_CODTFG = %Exp:cCodTFG%
		AND TFS.%NotDel%
	EndSql
	
	While (tmpQry1)->(!EOF())
		//verificar saldo
		nQuant:= (tmpQry1)->TFS_QUANT
		nTpMov:= (tmpQry1)->TFS_MOV
		If nTpMov == "1"
			nSldApt := nSldApt + nQuant
		Endif	  
		(tmpQry1)->(DbSkip())
	Enddo
	(tmpQry1)->(DbCloseArea())
	lRet	:=	nSldGrd <= nSldApt  
	If !lRet
		Help(,,"at893pre",,STR0025,1,0) // "Saldo insuficiente para esta quantidade!"
	Endif
EndIf
Return lRet