#Include 'PROTHEUS.CH'
#Include 'FWMBROWSE.CH'
#Include 'FWMVCDEF.CH'
#Include 'MATA967.CH' 

#Define C_CABEC 'CCF_NUMERO|CCF_TIPO|CCF_DTINI|CCF_DTFIN' 
 
/*/{Protheus.doc} MATA967
Cadastro dos processos referenciados a serem utilizados nos documentos fiscais.
@author Paulo Krüger
@since 07/02/2018
@obs 
/*/ 

Function MATA967() 
 
	Local oBrowse
	Local aDados := {}
	Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

	If lVerpesssen
		If FindFunction('EngSX3117') //Corrreção de condição de uso para "usado" no release 12.1.17
			aAdd(aDados,{{'CCF_DTINI' },{{'X3_USADO','€€€€€€€€€€€€€€','€€€€€€€€€€€€€€€'}}})
			aAdd(aDados,{{'CCF_DTFIN' },{{'X3_USADO','€€€€€€€€€€€€€€','€€€€€€€€€€€€€€€'}}})
			aAdd(aDados,{{'CCF_TRIB ' },{{'X3_USADO','€€€€€€€€€€€€€€','€€€€€€€€€€€€€€€'}}})
			EngSX3117( aDados )
		EndIf
		
		Processa({|| AJUSTMODL2()}, STR0008, STR0009,.F.) //'Aguarde!'
		
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('CCF')
		oBrowse:SetDescription(STR0001)	//Cadastro de processos referenciados
		oBrowse:Activate()
	EndIf
	
Return

/*/{Protheus.doc} MenuDef
Definicao do MenuDef para o MVC
@author Paulo Krüger
@since 07/02/2018
/*/

Static Function MenuDef()

	Local aRotina := {} 
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.MATA967' OPERATION 2 ACCESS 0	// "Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.MATA967' OPERATION 3 ACCESS 0	// "Incluir"
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.MATA967' OPERATION 4 ACCESS 0	// "Alterar"
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.MATA967' OPERATION 5 ACCESS 0	// "Excluir"
		
Return aRotina

/*/{Protheus.doc} ModelDef
Definicao do ModelDef para o MVC
@author Paulo Krüger
@since 07/02/2018
/*/ 

Static Function ModelDef()

	Local oModel := nil
	Local oStructCab := FWFormStruct(1,'CCF',{|cCampo| COMP11STRU('CAB',cCampo)})
	Local oStructIte := FWFormStruct(1,'CCF',{|cCampo| COMP11STRU('ITE',cCampo)})
	Local oStructCID := nil
	Local bLinePre	:= {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| bLinePre(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
	Local aRelaCCF := {}
	Local cRelease := GetRPORelease()
	Local lCID		:= AliasIndic("CID")
	Local aAux	:= {}
	
	//Verifica se a tabela existe
	If lCID
		oStructCID := FWFormStruct(1,'CID')

		//Adiciono gatilhos
		aAux := FwStruTrigger('CCF_NATJU','CCF_NATJU','MTA967EXSU()',,,,,)
		oStructIte:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )
		
		aAux := FwStruTrigger('CCF_TRIB' ,'CCF_TRIB' ,'MTA967EXSU()',,,,,)		
		oStructIte:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

		aAux := FwStruTrigger('CID_CST' ,'CID_CST' ,'MTA967EXSU("CST")',,,,,)		
		oStructCID:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

	EndIf

	oModel := MPFormModel():New('MATA967',,{|oModel|ValidForm(oModel,lCID)})
	
	oModel:AddFields('MATA967MOD',,oStructCab)

	// Só manipulo via MVC antes do release 25. Daqui em diante o dicionário estará OK.
	If (cRelease < "12.1.025")
    	oStructIte:SetProperty('CCF_NATJU' , MODEL_FIELD_VALID, {|| .T.})
		oStructIte:SetProperty('CCF_NATJU' , MODEL_FIELD_VALUES, X967NatJu(.T.))	
    EndIf
    
	oModel:AddGrid('MATA967ITE','MATA967MOD',oStructIte,bLinePre)
 	
	oModel:GetModel('MATA967ITE'):SetUseOldGrid()

	Aadd(aRelaCCF,{'CCF_FILIAL',"FWxFilial('CCF')"})
	Aadd(aRelaCCF,{'CCF_NUMERO','CCF_NUMERO'})
	Aadd(aRelaCCF,{'CCF_TIPO'  ,'CCF_TIPO'})
	Aadd(aRelaCCF,{'CCF_DTINI' ,'CCF_DTINI'})
	Aadd(aRelaCCF,{'CCF_DTFIN' ,'CCF_DTFIN'})

	oModel:SetRelation("MATA967ITE",aRelaCCF,CCF->(IndexKey(01)))

	If CCF->(FieldPos('CCF_IDITEM')) > 0
		oModel:SetPrimaryKey({'CCF_FILIAL'},{'CCF_NUMERO'},{'CCF_TIPO'},{'CCF_INDAUT'},{'CCF_IDITEM'})
	Else
		oModel:SetPrimaryKey({'CCF_FILIAL'},{'CCF_NUMERO'},{'CCF_TIPO'},{'CCF_INDAUT'})
	EndIf		
	oModel:SetDescription(STR0001) //'Cadastro de processos referenciados'
	oModel:GetModel('MATA967MOD'):SetDescription(STR0001) //'Cadastro de processos referenciados'
	oModel:GetModel('MATA967ITE'):SetDescription(STR0006) //'Insumos e seus respectivos valores'
	oModel:GetModel('MATA967ITE'):SetMaxLine(9999) // Maximo de linhas
	If CCF->(FieldPos('CCF_IDITEM')) > 0
		oModel:GetModel('MATA967ITE'):SetUniqueLine({'CCF_IDITEM'})
	EndIf	

	//Adiciona o grid caso a tabela CID seja criada no ambiente
	IF lCID	
		oModel:AddFields('EXIGIBILIDADE','MATA967ITE',oStructCID)		
		oModel:SetRelation("EXIGIBILIDADE",{{"CID_FILIAL", "xFilial('CID')"}, {"CID_NUMERO", "CCF_NUMERO"},{"CID_TIPO", "CCF_TIPO"},{"CID_INDAUT","CCF_INDAUT"}, {"CID_IDITEM","CCF_IDITEM"}},CID->(IndexKey(1)))		
		oStructCID:SetProperty('CID_REDUC'   , MODEL_FIELD_WHEN, {|| HabExig() })	
		oStructCID:SetProperty('CID_CST'     , MODEL_FIELD_WHEN, {|| HabExig("CST") })	
		oStructCID:SetProperty('CID_ICMS'    , MODEL_FIELD_WHEN, {|| HabExig() })	
		oStructCID:SetProperty('CID_ISS'     , MODEL_FIELD_WHEN, {|| HabExig() })	
		oStructCID:SetProperty('CID_ALIQ'    , MODEL_FIELD_WHEN, {|| HabExig() })	
		oStructCID:SetProperty('CID_CODREC'  , MODEL_FIELD_WHEN, {|| HabExig("CODREC") })			

	EndIF

Return oModel   

/*/{Protheus.doc} ViewDef
Definicao da Visualizacao para o MVC
@author Paulo Krüger
@since 07/02/2018
@return
/*/ 

Static Function ViewDef() 
	
	Local oView		:= FWFormView():New()
	Local oModel	:= FWLoadModel('MATA967')
	Local oStructCab:= FWFormStruct(2,'CCF',{|cCampo| COMP11STRU('CAB',cCampo)})
	Local oStructIte:= FWFormStruct(2,'CCF',{|cCampo| COMP11STRU('ITE',cCampo)})
	Local oStructCID:= nil
	Local cRelease := GetRPORelease()
	Local lCID		:= AliasIndic("CID")

	If lCID
		oStructCID:= FWFormStruct(2,'CID')
	EndIF
    
	oView:SetModel(oModel)
	oView:AddField('VIEW_CAB',oStructCab,'MATA967MOD')
	oView:AddGrid( 'VIEW_ITE',oStructIte,'MATA967ITE')

	If lCID
		//Adiciona os campos da CID
		oView:AddField('VIEW_EXIGIBILIDADE',oStructCID,'EXIGIBILIDADE')
		oView:CreateHorizontalBox('SUPERIOR',20)
		oView:CreateHorizontalBox('INFERIOR',60)
		oView:CreateHorizontalBox('RODAPE'  ,20)
		oView:SetOwnerView('VIEW_EXIGIBILIDADE',"RODAPE")

		oStructCID:RemoveField('CID_NUMERO')
		oStructCID:RemoveField('CID_INDAUT')
		oStructCID:RemoveField('CID_IDITEM')
		oView:EnableTitleView('VIEW_EXIGIBILIDADE',STR0011) //"Exigibilidade Suspensa de Contribuição(Sem Trânsito em Julgado)"

	Else
		oView:CreateHorizontalBox('SUPERIOR',20)
		oView:CreateHorizontalBox('INFERIOR',80)
	EndIF

	oView:SetOwnerView('VIEW_CAB',"SUPERIOR")
	oView:SetOwnerView('VIEW_ITE',"INFERIOR")	
	
	//Inclui campo incremental
	If CCF->(FieldPos('CCF_IDITEM')) > 0
		oView:AddIncrementalField('VIEW_ITE','CCF_IDITEM')
	EndIf	
	//Ajusta ordem dos campos
	
	oStructCab:SetProperty('CCF_NUMERO'	, MVC_VIEW_ORDEM	,    '01')
	If X3USO(GetSx3Cache("CCF_TIPO","X3_USADO"))
		oStructCab:SetProperty('CCF_TIPO'	, MVC_VIEW_ORDEM	,    '02')
	EndIf
	oStructCab:SetProperty('CCF_DTINI'	, MVC_VIEW_ORDEM	,    '03')
	oStructCab:SetProperty('CCF_DTFIN'	, MVC_VIEW_ORDEM	,    '04')
		
	oStructIte:SetProperty('CCF_IDITEM'	, MVC_VIEW_ORDEM	,    '01')
	oStructIte:SetProperty('CCF_TPCOMP'	, MVC_VIEW_ORDEM	,    '02')
	oStructIte:SetProperty('CCF_IDSEJU'	, MVC_VIEW_ORDEM	,    '03')
	oStructIte:SetProperty('CCF_IDVARA'	, MVC_VIEW_ORDEM	,    '04')
	oStructIte:SetProperty('CCF_NATJU'	, MVC_VIEW_ORDEM	,    '05')
	oStructIte:SetProperty('CCF_DESCJU'	, MVC_VIEW_ORDEM	,    '06')
	oStructIte:SetProperty('CCF_DTSENT'	, MVC_VIEW_ORDEM	,    '07')
	oStructIte:SetProperty('CCF_NATAC'	, MVC_VIEW_ORDEM	,    '08')
	oStructIte:SetProperty('CCF_DTADM'	, MVC_VIEW_ORDEM	,    '09')
	oStructIte:SetProperty('CCF_TIPCRE'	, MVC_VIEW_ORDEM	,    '10')
	oStructIte:SetProperty('CCF_TIPCOM'	, MVC_VIEW_ORDEM	,    '11')
	oStructIte:SetProperty('CCF_NRDCOM'	, MVC_VIEW_ORDEM	,    '12')
	oStructIte:SetProperty('CCF_UF'		, MVC_VIEW_ORDEM	,    '13')
	oStructIte:SetProperty('CCF_CODMUN'	, MVC_VIEW_ORDEM	,    '14')
	oStructIte:SetProperty('CCF_MOTSUS'	, MVC_VIEW_ORDEM	,    '15')
	oStructIte:SetProperty('CCF_CNPJ'	, MVC_VIEW_ORDEM	,    '16')
	oStructIte:SetProperty('CCF_IDDEP'	, MVC_VIEW_ORDEM	,    '17')
	oStructIte:SetProperty('CCF_PERAPU'	, MVC_VIEW_ORDEM	,    '18')
	oStructIte:SetProperty('CCF_CODREC'	, MVC_VIEW_ORDEM	,    '19')
	oStructIte:SetProperty('CCF_RESACA'	, MVC_VIEW_ORDEM	,    '20')
	oStructIte:SetProperty('CCF_INDAUT'	, MVC_VIEW_ORDEM	,    '21')
	If CCF->(FieldPos('CCF_TRIB')) > 0
		oStructIte:SetProperty('CCF_TRIB'	, MVC_VIEW_ORDEM	,    '25')
	EndIf
	If CCF->(FieldPos('CCF_INDSUS')) > 0
		oStructIte:SetProperty('CCF_INDSUS'	, MVC_VIEW_ORDEM	,    '26')
	EndIf
	If CCF->(FieldPos('CCF_SUSEXI')) > 0
		oStructIte:SetProperty('CCF_SUSEXI'	, MVC_VIEW_ORDEM	,    '27')
	EndIf
	oStructIte:SetProperty('CCF_MONINT'	, MVC_VIEW_ORDEM	,    '28')
	
	// Só manipulo via MVC antes do release 25. Daqui em diante o dicionário estará OK.
	If (cRelease < "12.1.025")		
		oStructIte:SetProperty("CCF_NATJU", MVC_VIEW_COMBOBOX, X967NatJu(.T.))
	Endif
Return oView

/*/{Protheus.doc} COMP11STRU
Função de controle dos campos de cabeçalho e itens
@author Paulo Krüger
@since 07/02/2018
@param cTipo, caracter, contem o tipo se é cabeçalho ou item
@param cCampo, caracter, contem o campo da tabela
@return logico, se o campo referencia deve ser usado ou não.
/*/

Static Function COMP11STRU(cTipo,cCampo)

	Local lRet		:= .T.
	
	Default cTipo	:= ''
	Default cCampo	:= ''
	
	If cTipo == 'CAB'		// Se for a construcao do cabecalho
		// Se o campo não estiver informado nos campos do cabeçalho retorna falso
		lRet := IIf(!(AllTrim(cCampo) $ C_CABEC),.F.,.T.)
	ElseIf cTipo == 'ITE'	// Se for a construcao do item
		// Se o campos estiver informado nos campos do cabeçalho retorna falso
		lRet := IIf((AllTrim(cCampo) $ C_CABEC),.F.,.T.)
	EndIf

Return lRet

/*/{Protheus.doc} ValidForm
Validação das informações digitadas no form
@author Paulo Krüger
@since 07/02/2018
@param oModel, objeto, contem o model
@return logico, se foi validado ou não.  
/*/

Static Function ValidForm(oModel,lCID)
	
	Local aAreaCCF	:=	CCF->(GetArea())
	Local lRet 		:=	.T.
	Local nOperation:=	oModel:GetOperation()
	Local cNumero	:=	oModel:GetValue('MATA967MOD','CCF_NUMERO') 	
	Local cTipo		:=	oModel:GetValue('MATA967MOD','CCF_TIPO'  )		

	// Inclusão de informações.
	If nOperation == 3
		DbSelectArea('CCF')
		CCF->(DbSetOrder(01))
		If CCF->(DbSeek(FWxFilial('CCF') + cNumero + cTipo))
			lRet := .F.
			Help('',1,'','HELP',STR0007,1,0)
		EndIf
	EndIf
	
	RestArea(aAreaCCF)

	//Se a tabela CID existir, se o CST estier preenchido, o código de receita será obrigatório
	If (nOperation == 3 .OR. nOperation == 4) .AND. lCID .AND. lRet .AND. !ChkCodRec(oModel)
		lRet := .F.
		Help('',1,'','HELP',"Código de Receita é obrigatório caso seja informado CST na seção da Exigibilidade Suspensa(Sem Trânsito em Julgado)",1,0)
	EndiF
	
Return lRet

/*/{Protheus.doc} bLinePre
Atribuição de valores do grid
@author	Paulo Krüger
@since 02/08/2018
@return logico, contém o tipo se é cabeçalho ou item
/*/

Static Function bLinePre(oModel,oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet	:=	.T.
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A967TIPCRD
Cria opcoes e o valid para o campo CCF_TIPCRE (X3_CBOX)
Parametro: nOpc -> 0 retorna validacao para funcao pertence
				   1 retorna as opcoes de escolha para o usuario
@author Mauro A. Goncalves
@since 16/04/2014
/*/
//-------------------------------------------------------------------
Function A967TIPCRD(nOpc)
Local nI	:= 1
Local cRet	:= ""
Local aOpc	:= {}

AADD(aOpc,"01=Ressarcimento do IPI")
AADD(aOpc,"02=IRPJ Saldo Negativo Per. Anteriores - Próprio")
AADD(aOpc,"03=IRPJ Saldo Negativo Per. Anteriores - Sucedida")
AADD(aOpc,"04=CSLL Saldo Negativo Per. Anteriores - Próprio")
AADD(aOpc,"05=CSLL Saldo Negativo Per. Anteriores - Sucedida")
AADD(aOpc,"06=IRRF Cooperativas de Trabalho")
AADD(aOpc,"07=IRRF Juros sobre o Capital Próprio")
AADD(aOpc,"11=Outros")
AADD(aOpc,"12=PIS/PASEP Não-Cumulativo - Exportação")
AADD(aOpc,"13=Cofins Não-Cumulativa - Exportação")
AADD(aOpc,"14=PIS/PASEP Não-Cumulativo - Mercado Interno")
AADD(aOpc,"15=Cofins Não-Cumulativa - Mercado Interno")
AADD(aOpc,"16=PIS/PASEP Embalagens (§4º do art. 51 da Lei nº 10.833/03)")
AADD(aOpc,"17=Cofins Embalagens (§4º do art. 51 da Lei nº 10.833/03)")
AADD(aOpc,"20=Reintegra")

For nI:=1 To Len(aOpc)
	If nOpc==0
		cRet += IIf(empty(cRet),' ',';') + StrZero(nI,2)
	Else
		cRet += IIf(empty(cRet),'',';') + aOpc[nI]
	Endif
Next

If nOpc==0
	cRet := &("Pertence('"+cRet+"')")
Endif

Return (cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} A967MOTSUS
Cria opcoes e o valid para o campo CCF_MOTSUS (X3_CBOX)
Parametro: nOpc -> 0 retorna validacao para funcao pertence
				     1 retorna as opcoes de escolha para o usuario
@author Mauro A. Goncalves
@since 26/02/2016
/*/
//-------------------------------------------------------------------
Function A967MOTSUS(nOpc)
Local nI   := 1
Local cRet := ""
Local aOpc := {}

AADD(aOpc,"01=Liminar em Mandado de Segurança")
AADD(aOpc,"02=Depósito Judicial do Montante Integral")
AADD(aOpc,"03=Antecipação de Tutela") 
AADD(aOpc,"04=Liminar em Medida Cautelar")
AADD(aOpc,"05=CSLL Saldo Negativo Per. Anteriores - Sucedida") 
AADD(aOpc,"07=Medida Judicial em que o declarante não é o autor")
AADD(aOpc,"08=Sentença em Mandado de Segurança favorável ao contribuinte")
AADD(aOpc,"09=Sentença em Ação Ordin. favorável ao contr. e conf. pelo TRF")
AADD(aOpc,"10=Acórdão do TRF favorável ao contribuinte")
AADD(aOpc,"11=Acórdão do STJ em Recurso Especial favorável ao contribuinte")
AADD(aOpc,"12=Acórdão do STF em Recurso Extraor. favorável ao contribuinte")

For nI:=1 To Len(aOpc)
	If nOpc==0
		cRet += IIf(empty(cRet),' ',';') + Left(aOpc[nI],2)
	Else
		cRet += IIf(empty(cRet),'',';') + aOpc[nI]
	Endif
Next

If nOpc==0
	cRet := &("Pertence('"+cRet+"')")
Endif

Return (cRet) 

//-------------------------------------------------------------------
/*/{Protheus.doc} A967SUSEXI
Cria opcoes e o valid para o campo CCF_SUSEXI (X3_CBOX)
Parametro: nOpc -> 0 retorna validacao para funcao pertence
				     1 retorna as opcoes de escolha para o usuario
@author Paulo Krüger
@since 09/02/2018
/*/
//-------------------------------------------------------------------

Function A967SUSEXI(nOpc)
Local nI   := 1
Local cRet := ""
Local aOpc := {}

AADD(aOpc,"01=Liminar em Mandado de Segurança")
AADD(aOpc,"02=Depósito Judicial do Montante Integral")
AADD(aOpc,"03=Deposito administrativo do montante integral")
AADD(aOpc,"04=Antecipação de tutela")
AADD(aOpc,"05=Liminar em Medida Cautelar")
AADD(aOpc,"08=Sentença em Mandado de Segurança favorável ao contribuinte")
AADD(aOpc,"09=Sentença em Ação Ordin. favorável ao contr. e conf. pelo TRF")
AADD(aOpc,"10=Acórdão do TRF favorável ao contribuinte")
AADD(aOpc,"11=Acórdão do STJ em Recurso Especial favorável ao contribuinte")
AADD(aOpc,"12=Acórdão do STF em Recurso Extraor. favorável ao contribuinte")
AADD(aOpc,"13=Sentença 1ª instância não transitada em julgado com efeito suspensivo")
AADD(aOpc,"90=Decisão Definitiva a favor do contribuinte")
AADD(aOpc,"92=Sem suspensão da exigibilidade")

For nI:=1 To Len(aOpc)
	If nOpc==0
		cRet += IIf(empty(cRet),' ',';') + Left(aOpc[nI],2)
	Else
		cRet += IIf(empty(cRet),'',';') + aOpc[nI]
	Endif
Next

If nOpc==0
	cRet := &("Pertence('"+cRet+"')")
Endif

Return (cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} A967TRIB
Cria opcoes e o valid para o campo CCF_TRIB (X3_CBOX)
Parametro: nOpc -> 0 retorna validacao para funcao pertence
				     1 retorna as opcoes de escolha para o usuario
@author Paulo Krüger
@since 09/02/2018
/*/
//-------------------------------------------------------------------

Function A967TRIB(nOpc)
Local nI   := 1
Local cRet := ""
Local aOpc := {}
 
AADD(aOpc,"1=Contribuição previdenciária (INSS)")
AADD(aOpc,"2=Contribuição previdenciária especial (INSS)")
AADD(aOpc,"3=FUNRURAL")
AADD(aOpc,"4=SENAR")
AADD(aOpc,"5=CPRB")
AADD(aOpc,"6=ICMS")
AADD(aOpc,"7=PIS")
AADD(aOpc,"8=COFINS")
AADD(aOpc,"9=IR")
AADD(aOpc,"A=CSLL")

For nI:=1 To Len(aOpc)
	If nOpc==0
		cRet += IIf(empty(cRet),' ',';') + Left(aOpc[nI],2)
	Else
		cRet += IIf(empty(cRet),'',';') + aOpc[nI]
	Endif
Next

If nOpc==0
	cRet := &("Pertence('"+cRet+"')")
Endif

Return (cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AJUSTMODL2
Ajusta base para manipulação em Modelo2.
@author Paulo Krüger
@since 15/02/2018
/*/ 
//-------------------------------------------------------------------
 
Static Function AJUSTMODL2()
 
Local cAlias00	:= ''
Local cAlias01	:= ''
Local cItem		:= ''
Local nTamItem	:= 0
Local nQtdReg	:= 0

If CCF->(FieldPos('CCF_IDITEM')) <= 0
	Return
EndIf

nTamItem := TamSX3('CCF_IDITEM')[01]

//Calcula quantidade de registros a serem compatibilizados
cAlias00 := GetNextAlias()
BeginSql Alias cAlias00
SELECT	COUNT(*) NREG
FROM	%Table:CCF% CCF
WHERE			CCF.%notDel%
		AND		CCF_IDITEM	= %Exp:cItem%
EndSql
  
(cAlias00)->(DbGoTop())

nQtdReg := (cAlias00)->(NREG)

(cAlias00)->(DbCloseArea())

If nQtdReg > 0 

	ProcRegua(nQtdReg) 

	cAlias01 := GetNextAlias()
	BeginSql Alias cAlias01
	SELECT	CCF.R_E_C_N_O_	RECNO
	FROM	%Table:CCF% CCF
	WHERE			CCF.%notDel%
			AND		CCF_IDITEM	= %Exp:cItem%
	EndSql

	(cAlias01)->(DbGoTop())

	While (cAlias01)->(!Eof())

		IncProc(STR0010) //Compatibilizando base de dados.

		CCF->(dBGoTo((cAlias01)->RECNO))

		RecLock('CCF',.F.)

		CCF->CCF_IDITEM := StrZero(1,nTamItem)  

		CCF->(MsUnLock())

		(cAlias01)->(dBSkip()) 		

	EndDo
	(cAlias01)->(DbCloseArea())

EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} X967NatJu
Ajusta base para criar as opções do campo CCF_NATJU (comboBox) 
@author Matheus G. Zelli
@since 28/02/2019
/*/ 
//-------------------------------------------------------------------
Function X967NatJu(lArray)

Local xRet := NIL
Local cOpcoes := OpcaoNatJu()

DEFAULT lArray := .F.

If lArray
	xRet := StrToKArr(cOpcoes, ';')
Else
	xRet := cOpcoes
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} OpcaoNatJu
Função que compoe a lista com as opções do indicador da Natureza da Ação Judicial.
@author Matheus G. Zelli
@since 28/02/2019
/*/ 
//-------------------------------------------------------------------
Static Function OpcaoNatJu()

Local cOpcoes	:= ""

cOpcoes	+= "01=Decisão judicial transitada em julgado, a favor da pessoa jurídica;"
cOpcoes	+= "02=Decisão judicial não transitada em julgado, a favor da pessoa jurídica;"
cOpcoes	+= "03=Decisão judicial oriunda de liminar em mandado de segurança;"
cOpcoes	+= "04=Decisão judicial oriunda de liminar em medida cautelar;"
cOpcoes	+= "05=Decisão judicial oriunda de antecipação de tutela;"
cOpcoes	+= "06=Decisão judicial vinculada a depósito administrativo ou judicial em montante integral;"
cOpcoes	+= "07=Medida judicial em que a pessoa jurídica não é o autor;"
cOpcoes	+= "08=Súmula vinculante aprovada pelo STF ou STJ;"
cOpcoes	+= "09=Decisão judicial oriunda de liminar em mandado de segurança coletivo;"
cOpcoes	+= "12=Decisão judicial não transitada em julgado, a favor da pessoa jurídica - Exigibilidade suspensa de contribuição;"
cOpcoes	+= "13=Decisão judicial oriunda de liminar em mandado de segurança - Exigibilidade suspensa de contribuição;"
cOpcoes	+= "14=Decisão judicial oriunda de liminar em medida cautelar - Exigibilidade suspensa de contribuição;"
cOpcoes	+= "15=Decisão judicial oriunda de antecipação de tutela - Exigibilidade suspensa de contribuição;"
cOpcoes	+= "16=Decisão judicial vinculada a depósito administrativo ou judicial em montante integral - Exigibilidade suspensa de contribuição;"
cOpcoes	+= "17=Medida judicial em que a pessoa jurídica não é o autor - Exigibilidade suspensa de contribuição;"
cOpcoes	+= "19=Decisão judicial oriunda de liminar em mandado de segurança coletivo - Exigibilidade suspensa de contribuição;"
cOpcoes	+= "99=Outros"

Return cOpcoes

//-------------------------------------------------------------------
/*/{Protheus.doc} HabExig
Função que habilitará os campos da exigibilidade suspensa para os tributos
de PIS e COFINS.
@author Erick G Dias
@since 22/10/2019
/*/ 
//-------------------------------------------------------------------
Static Function HabExig(cOpcao)

Local oModel    	:=	FWModelActive()
Local lNatAjutrib	:= ChkExigSusp(oModel:GetValue ('MATA967ITE',"CCF_NATJU") , oModel:GetValue ('MATA967ITE',"CCF_TRIB") ) 
Local lRet			:= lNatAjutrib .AND. !oModel:GetValue ('EXIGIBILIDADE',"CID_CST") $ "  /04/05/06/07/08/09/49"
Default cOpcao		:= ""

//Se for CST não tributável deverá edsabilitar todos os campos, menos o campo de CST
If (cOpcao == "CST" .OR. cOpcao == "CODREC") .AND. lNatAjutrib
	lRet	:= .T.
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA967EXSU
Função que trata os campos da exigibilidade suspensa.
Limpando o conteúdo deles se necessário e atualizando a View.
@author Erick G Dias
@since 22/10/2019
/*/ 
//-------------------------------------------------------------------
Function MTA967EXSU(cOpcao)

Local oView 		:= FWViewActive()
Local oModel    	:=	FWModelActive()
Local oExigibil	    := oModel:GetModel('EXIGIBILIDADE' )
Default cOpcao		:= ""

//Verifico se o tipo de processo é de exigibilidade suspensa
If !ChkExigSusp(oModel:GetValue ('MATA967ITE',"CCF_NATJU") , oModel:GetValue ('MATA967ITE',"CCF_TRIB") ) .OR. (cOpcao == "CST" .AND. oExigibil:GetValue("CID_CST") $ "04/05/06/07/08/09/49")
	//Limpar as variaveis
	If cOpcao <> "CST"
		oExigibil:LoadValue('CID_CST' , Space(2))
	EndIF
	oExigibil:LoadValue('CID_ICMS', Space(1))
	oExigibil:LoadValue('CID_ISS' , Space(1))
	oExigibil:LoadValue('CID_REDUC', 0.0)
	oExigibil:LoadValue('CID_ALIQ', 0.0 )
	If cOpcao <> "CST"
		oExigibil:LoadValue('CID_CODREC', Space(6))
	EndIF
	
EndIF

oview:Refresh( 'VIEW_EXIGIBILIDADE' )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkExigSusp
Função que receberá o tipo do processo e tributo, e retornará se 
deve ou não tratar as informações da exigibilidade suspensa.
@author Erick G Dias
@since 22/10/2019
/*/ 
//-------------------------------------------------------------------
Static Function ChkExigSusp(cNatProc, cTrib)
Local lNatAjus  := cNatProc $ "12/13/14/15/16/17/19" //Verifica os tipos de processos com exigibilidade suspensa
Local lTrib		:= cTrib $ "7/8" //Verifica se o tributo é PIS ou COFINS
Return lNatAjus .AND. lTrib


//-------------------------------------------------------------------
/*/{Protheus.doc} ChkCodRec
Função que fará validação do código de receita, deverá ser prenechido
caso tenha CST informadp
@author Erick G Dias
@since 05/11/2019
/*/ 
//-------------------------------------------------------------------
Static Function ChkCodRec(oModel)

Local lRet				:= .T.
Local nX				:= 1
Local oMATA967ITE  		:= oModel:GetModel('MATA967ITE')
Local oExigibilidade	:= oModel:GetModel('EXIGIBILIDADE')

//Validação de todas as linhas do grid do processo
For nX:=1 to oMATA967ITE:Length()
    
    //Posiciona linha do município
    oMATA967ITE:GoLine( nX )

    //Verifico se não está deletada
    IF !oMATA967ITE:IsDeleted() 
		//Obtem o modelo filho
		oExigibilidade	:= oModel:GetModel('EXIGIBILIDADE')
		
		//Se o CST estiver informado então o código de receita será obirgatório
		If !Empty(oModel:GetValue ('EXIGIBILIDADE',"CID_CST")) .AND. Empty(oModel:GetValue ('EXIGIBILIDADE',"CID_CODREC"))
			lRet	:= .F.
		EndIF
	EndIF
        
    //Se Aqui alguma informação obrigatório está faltando, não pode permitir gravação
    If !lRet
        Exit
    EndIF

Next nX

Return lRet
