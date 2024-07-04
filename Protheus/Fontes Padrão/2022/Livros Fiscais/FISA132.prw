#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA132.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA132 
Apuração e Consulta do Ressarcimento

@author Mauro A. Gonçalves
@since 27/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISA132()
Local oFWLayer, oPanelPRI, oPanelCDA, oPanelCD0, oBrowseCDA, oBrowseCD0, oRelacCDA, oRelacCD0
Local aCoors	:=	FWGetDialogSize( oMainWnd )
Local aColumns	:= {}  //Colunas do Browse

Static lVer12	:= SubStr( GetRpoRelease(),1,2 ) == "12"

Private oDlgPrinc
Private oBrowsePRI
Private cAliasPri

If !AnalisaCD0() //Verifica estrutura da CD0
	Return
Endif

aColumns	:= F132CpoBrw()  //Colunas do Browse

DEFINE MSDIALOG oDlgPrinc TITLE STR0001 FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4] PIXEL //"Ressarcimento de ICMS-ST"

oFWLayer	:=	FWLayer():New()
oFWLayer:Init(oDlgPrinc, .F., .T.)

oFWLayer:AddLine('PRI', 33, .F.)
oFWLayer:AddCollumn('ALLPRI', 100, .T., 'PRI')
oPanelPRI	:=	oFWLayer:GetColPanel('ALLPRI', 'PRI')

oFWLayer:AddLine('CDA', 33, .F.)
oFWLayer:AddCollumn('ALLCDA', 100, .T., 'CDA')
oPanelCDA	:=	oFWLayer:GetColPanel('ALLCDA', 'CDA')

oFWLayer:AddLine('CD0', 33, .F.)
oFWLayer:AddCollumn('ALLCD0', 100, .T., 'CD0')
oPanelCD0	:=	oFWLayer:GetColPanel('ALLCD0', 'CD0')


//Filtro SFT
oBrowsePRI	:=	FWMBrowse():New()
oBrowsePRI:SetOwner(oPanelPRI)
oBrowsePRI:SetDescription(STR0002)//"Notas Fiscais de Saída"
oBrowsePRI:SetAlias("SFT")
IF lVer12
	oBrowsePRI:SetMenuDef("FISA132")
Else
	oBrowsePRI:SetMenuDef("")
Endif
oBrowsePRI:SetProfileID('1')
oBrowsePRI:SetUseFilter(.T.)
oBrowsePRI:DisableConfig(.F.)
oBrowsePRI:DisableReport(.F.)
oBrowsePRI:DisableDetails(.T.)
oBrowsePRI:SetWalkThru(.F.)
oBrowsePRI:SetAmbiente(.F.)
oBrowsePRI:Activate()
oBrowsePRI:aDefaultColumns := {}
oBrowsePRI:aColumns := {}
oBrowsePRI:SetColumns(aColumns)
oBrowsePRI:UpdateBrowse()

oBrowseCDA	:=	FWMBrowse():New()
oBrowseCDA:SetOwner(oPanelCDA)
oBrowseCDA:SetDescription(STR0003)//"Lançamentos Documento Fiscal"
oBrowseCDA:SetMenuDef('')
oBrowseCDA:SetAlias("CDA")
oBrowseCDA:SetProfileID('2')
oBrowseCDA:DisableDetails()
oBrowseCDA:DisableConfig(.F.)
oBrowseCDA:DisableReport(.F.)
oBrowseCDA:SetWalkThru(.F.)
oBrowseCDA:SetAmbiente(.F.)
oBrowseCDA:SetUseFilter(.F.)
oBrowseCDA:Activate()

oBrowseCD0	:=	FWMBrowse():New()
oBrowseCD0:SetOwner(oPanelCD0)
oBrowseCD0:SetDescription(STR0008)//"Complemento Nota Fiscal Ressarcimento"
oBrowseCD0:SetAlias("CD0")
IF lVer12
	oBrowseCD0:SetMenuDef("")
Else
	oBrowseCD0:SetMenuDef("FISA132")
Endif
oBrowseCD0:SetProfileID('3')
oBrowseCD0:ForceQuitButton()
oBrowseCD0:DisableDetails()
oBrowseCD0:DisableConfig(.F.)
oBrowseCD0:DisableReport(.F.)
oBrowseCD0:SetWalkThru(.F.)
oBrowseCD0:SetAmbiente(.F.)
oBrowseCD0:SetUseFilter(.F.)
oBrowseCD0:Activate()


oRelacCDA	:=	FWBrwRelation():New()
oRelacCDA:AddRelation(oBrowsePRI, oBrowseCDA, {{"CDA_FILIAL","FT_FILIAL"},{"CDA_NUMERO","FT_NFISCAL"},{"CDA_SERIE","FT_SERIE"},{"CDA_CLIFOR","FT_CLIEFOR"},{"CDA_LOJA","FT_LOJA"}})
oRelacCDA:Activate()

oRelacCD0	:=	FWBrwRelation():New()
oRelacCD0:AddRelation(oBrowsePRI, oBrowseCD0, {{"CD0_FILIAL","FT_FILIAL"},{"CD0_DOC","FT_NFISCAL"},{"CD0_SERIE","FT_SERIE"},{"CD0_CLIFOR","FT_CLIEFOR"},{"CD0_LOJA","FT_LOJA"}})
oRelacCD0:Activate()

Activate MsDialog oDlgPrinc Center

Return
	
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return FWMVCMenu - Opcoes de menu
@author Mauro A. Gonçalves
@since 27/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function MenuDef()

Local aRotina	:= {}

	ADD OPTION aRotina TITLE STR0004 ACTION 'Processa({|lEnd| F132Apura()})'	OPERATION 3 ACCESS 0 //Apuração
	ADD OPTION aRotina TITLE STR0007 ACTION 'FISR132'							OPERATION 3 ACCESS 0 //Relatório	
	ADD OPTION aRotina TITLE 'Relatório de Lançamentos Fiscais' ACTION 'FISR025' OPERATION 3 ACCESS 0 //Relatório CDA

Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC
@author Mauro A. Gonçalves
@since 27/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStruPRI := FWFormStruct(1,"SFT")
Local oStruCDA := FWFormStruct(1,"CDA")
Local oStruCD0 := FWFormStruct(1,"CD0")

oModel	:=	MPFormModel():New('FISA132',,)

oStruPRI:SetProperty("*",MODEL_FIELD_VALID,{||.T.}) 

oModel:AddFields('MODEL_PRI',,oStruPRI)

oModel:AddGrid('MODEL_CDA','MODEL_PRI',oStruCDA)	
oModel:AddGrid('MODEL_CD0','MODEL_PRI',oStruCD0)	

oModel:SetRelation('MODEL_CDA',{{"CDA_FILIAL",'xFilial("CDA")'},{"CDA_NUMERO","FT_NFISCAL"},{"CDA_SERIE","FT_SERIE"},{"CDA_CLIFOR","FT_CLIEFOR"},{"CDA_LOJA","FT_LOJA"}},CDA->(IndexKey(1)))
oModel:SetRelation('MODEL_CD0',{{"CD0_FILIAL",'xFilial("CD0")'},{"CD0_DOC","FT_NFISCAL"},   {"CD0_SERIE","FT_SERIE"},{"CD0_CLIFOR","FT_CLIEFOR"},{"CD0_LOJA","FT_LOJA"}},CD0->(IndexKey(1)))

oModel:SetPrimaryKey({"FT_FILIAL","FT_NFISCAL","FT_SERIE","FT_CLIEFOR","FT_LOJA"})		
oModel:SetDescription(STR0001)//Apuração e Consulta do Ressarcimento

oModel:GetModel('MODEL_PRI'):SetDescription(STR0002)//"Notas Fiscais de Saída"

oModel:GetModel('MODEL_CDA'):SetDescription(STR0003)//"Lançamentos Documento Fiscal"
oModel:GetModel('MODEL_CDA'):SetOptional(.T.)
oModel:GetModel('MODEL_CDA'):SetUniqueLine({"CDA_FILIAL","CDA_NUMERO","CDA_SERIE","CDA_CLIFOR","CDA_LOJA"})

oModel:GetModel('MODEL_CD0'):SetDescription(STR0008)//"Complemento Nota Fiscal Ressarcimento"
oModel:GetModel('MODEL_CD0'):SetOptional(.T.)
oModel:GetModel('MODEL_CD0'):SetUniqueLine({"CD0_FILIAL","CD0_DOC","CD0_SERIE","CD0_CLIFOR","CD0_LOJA"})

Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC
@author Mauro A. Gonçalves
@since 27/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:=	FWLoadModel("FISA132")
Local oStruPRI	:=	FWFormStruct(2,"SFT")
Local oStruCDA	:=	FWFormStruct(2,"CDA")
Local oStruCD0	:=	FWFormStruct(2,"CD0")
Local oView		:=	FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_PRI', oStruPRI, 'MODEL_PRI')

oView:AddGrid('VIEW_CDA', oStruCDA, 'MODEL_CDA')
oView:AddGrid('VIEW_CD0', oStruCD0, 'MODEL_CD0')

oView:CreateHorizontalBox('BOXPRI', 33)
oView:CreateHorizontalBox('BOXCDA', 33)
oView:CreateHorizontalBox('BOXCD0', 33)

oView:SetOwnerView('VIEW_PRI', 'BOXPRI')
oView:SetOwnerView('VIEW_CDA', 'BOXCDA')
oView:SetOwnerView('VIEW_CD0', 'BOXCD0')

oView:EnableTitleView('VIEW_CDA', STR0003)	//"Lançamentos Documento Fiscal"
oView:EnableTitleView('VIEW_CD0', STR0008)	//"Complemento Nota Fiscal Ressarcimento"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} AnalisaCD0
Funcao utilizada para verificar o dicionario da tabela CD0

@return Retorna valor boleano
		.T. - Dicionario OK, prossegue com a rotina
		.F. - Dicionario com inconsistencias, apresetna mensagem e aborta rotina
		
@author Mauro A. Gonçalves
@since 27/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AnalisaCD0()
Local	nA			:= 1
Local	cMsgm		:=	''
Local	aCPOCD0	:= {'CD0_CHVNFE','CD0_ITENFE','CD0_VLUNOP','CD0_PICMSE','CD0_ALQSTE','CD0_VLUNRE','CD0_RESPRE','CD0_MOTRES',;
					'CD0_CHNFRT','CD0_PANFRT','CD0_LJPANF','CD0_SRNFRT','CD0_NRNFRT','CD0_ITNFRT','CD0_CODDA','CD0_NUMDA',;
					'CD0_ID','CD0_METINC','CD0_BSULMT','CD0_VLUNCR'}

DbSelectArea("CD0")
For nA:=1 to Len(aCPOCD0)
	If CD0->(FieldPos(aCPOCD0[nA])) == 0
		cMsgm	:=	"A estrutura da Tabela CD0 está fora do necessário para manutenção da mesma."+CRLF
		cMsgm	+=	"Por gentileza execute o compatibilizador U_UPDSIGAFIS para que o Dicionário e a Base de Dados sejam atualizados."
		MsgAlert(cMsgm)
		Return .F.
	Endif	
Next

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F132Apura
Faz a Apuração das Notas Fiscais

@author Mauro A. Goncalves
@since 27/12/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function F132Apura()
Local	nQtdReg		:= 0
Local	cQryCD0		:= ''
Local	aCODRESS	:= IIf(Empty(SuperGetMv("MV_CODRESS",,"")),{"SP10090719","SP10090721"},&(SuperGetMv("MV_CODRESS",,{"SP10090719","SP10090721"}))) //Códigos de Ressarcimento 
Local	aDEVRESS	:=	IIf(Empty(SuperGetMv("MV_DEVRESS",,"")),{"SP50000319","SP50000321"},&(SuperGetMv("MV_DEVRESS",,{"SP50000319","SP50000321"}))) //Códigos de Devolução de Ressarcimento
Local 	lTipRESS	:= SuperGetMv("MV_TPRESS",,.F.) // Tipo de Ressarcimento // .F. Busca ultima entrada / .T. Busca entradas não utilizada
Local	lCalcCred	:= SuperGetMv("MV_CALCRED",,.T.) // Não calcula credito para notas de entarda sem ICMS
Local	cMotPerd	:= SuperGetMv("MV_MOTPERD",,"")
Local	cMotRoub	:= SuperGetMv("MV_MOTROUB",,"")
Local	lCmpFcp		:= CD0->(FieldPos("CD0_FCPST")) > 0 .And. SD1->(FieldPos("D1_VFCPANT"))
Local	cChaveSFT	:= ''
Local	aValor		:= {}
Local	lDev		:= .F.
Local	nDev		:= 0
Local	cChaveNF	:= ""
Local	aChaveNF	:= {"","","",""}
Local	aDEVCOMP	:= {"","",""}
Local	cAliasCDA	:= ""


Local cSGBD := TCGetDB() //Banco de dados que esta sendo utilizado 

If !Pergunte("FISA132",.T.)
	Return 
Endif

//Verifica se parametro está preenchido
If Len(aCODRESS)==0
	MsgAlert("Verifique o conteúdo do parâmetro MV_CODRESS."+Chr(13)+"Caso não exista, execute o compatibilizador U_UPDSIGAFIS para a atualização do Dicionário.")
	Return 0
Endif

If (nQtdReg := F132SelPri(2)) == 0
	Return .F.
Endif

	ProcRegua(nQtdReg) 

	//Apaga os registro da CD0 referentes ao período selecionado	
 	IncProc(OemToAnsi('Apagando a CD0'))
	cQryCD0 := "DELETE FROM " + RetSqlName("CD0")
	cQryCD0 += " WHERE CD0_FILIAL = '"+xFilial("CD0")+"'"
	cQryCD0 += "   AND CD0_TPMOV = 'S'"
	cQryCD0 += "   AND EXISTS "
	cQryCD0 += "(SELECT DISTINCT F3_NFISCAL FROM " + RetSqlName("SF3")
	cQryCD0 += " WHERE F3_FILIAL = '"+xFilial("SF3")+"'"
	cQryCD0 += "   AND F3_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"		
	cQryCD0 += "   AND F3_NFISCAL = CD0_DOC AND F3_SERIE = CD0_SERIE AND F3_CLIEFOR = CD0_CLIFOR AND F3_LOJA = CD0_LOJA)"     		
	If TcSqlExec(cQryCD0) <> 0
		//- caso ocorra ero no SQL de exclusão, força gerar o error.log para o usuario com o erro
		//- e aborta
		UserException("Erro na exclusão da CD0"+CRLF + TCSQLError())
		Return
	EndIf
		
	While !(cAliasPri)->(EOF())
	 	IncProc(OemToAnsi(STR0001))
		
		aDEVCOMP := {"","",""}		
		//Quando for devolução de venda apenas atualiza CDA
		lDev := (cAliasPri)->FT_TIPO == "D" .And. (cAliasPri)->FT_TIPOMOV =="E"
		
		
		IF  (cAliasPri)->FT_TIPO == "D" .And. (cAliasPri)->FT_TIPOMOV =="S"
			IF !Empty((cAliasPri)->FT_NFORI) .And. !Empty((cAliasPri)->FT_SERORI) .And. !Empty((cAliasPri)->FT_ITEMORI) 
				aDEVCOMP[1] := (cAliasPri)->FT_NFORI
				aDEVCOMP[2] := (cAliasPri)->FT_SERORI
				aDEVCOMP[3] := (cAliasPri)->FT_ITEMORI			
			Else
				// Caso não encontre nota de orgem termina porocessamento.
				(cAliasPri)->(dbSkip())
				Loop
			Endif
		Endif
		
		
		Begin TransAction
		
		//Quando for devolução de Compra Cria CD0 com na nota de entrada original
		IF !lDev
			
			//Tratamento para sempre pegar ultima entrada por documento de saída
			If !lTipRESS .And. cChaveNF <> (cAliasPri)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA)
				cChaveNF := (cAliasPri)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA)
				aChaveNF[1] := (cAliasPri)->FT_NFISCAL
				aChaveNF[2] := (cAliasPri)->FT_SERIE
				aChaveNF[3] := (cAliasPri)->FT_CLIEFOR
				aChaveNF[4] := (cAliasPri)->FT_LOJA
			Endif			
			
			If (cAliasPri)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_ESPECIE+FT_TIPO+FT_PRODUTO+FT_ITEM) <> cChaveSFT
				cChaveSFT	:= (cAliasPri)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_ESPECIE+FT_TIPO+FT_PRODUTO+FT_ITEM)
				
				//Valida se processa nota de saída
				If ValdSda((cAliasPri)->FT_NFISCAL,(cAliasPri)->FT_SERIE,(cAliasPri)->FT_CLIEFOR,(cAliasPri)->FT_LOJA,(cAliasPri)->FT_ESPECIE,;
				(cAliasPri)->FT_TIPO,(cAliasPri)->FT_PRODUTO,(cAliasPri)->FT_ITEM,(cAliasPri)->FT_CFOP,(cAliasPri)->FT_TRFICM,(cAliasPri)->FT_ESTADO)
					aValor	:= CriarCD0(cAliasPri,"1",aCODRESS,lTipRESS,aChaveNF,aDEVCOMP,cSGBD,lCalcCred,cMotPerd,cMotRoub,lCmpFcp) //Cria os registros da CD0 conforme apuração
				Else
					aValor	 :=	{0,0}
				Endif				
			Endif
			
			//Atualiza a tabela CDA com os valores apurados de acordo com o código de lançamento
			CDA->(DbGoTo((cAliasPri)->RECNOCDA))
			RecLock("CDA",.F.)
			If AllTrim(CDA->CDA_CODLAN) == aCODRESS[1] // valor do ressarcimento					
				CDA->CDA_VALOR :=	aValor[1] 
			Endif	
			IF len(aCODRESS) >= 2
				//Quando codigo de ressarcimento de ST for o mesmo do codigo de credito, soma valores
				If aCODRESS[1] == aCODRESS[2]
					CDA->CDA_VALOR :=	aValor[1]+aValor[2]
				ElseIf AllTrim(CDA->CDA_CODLAN) == aCODRESS[2] // valor do crédito					
					CDA->CDA_VALOR :=	aValor[2] 
				Endif
			Endif
			
			CDA->(MsUnlock())
			
		Elseif !Empty((cAliasPri)->FT_NFORI) .and. (cAliasPri)->QUANT > 0

			cAliasCDA		:= GetNextAlias()
			BeginSql Alias cAliasCDA
				SELECT CDA_VALOR,CDA_CODLAN,CDA_NUMERO
				FROM  %Table:CDA% CDA	
				WHERE 
				CDA.CDA_FILIAL=%xFilial:CDA% AND
				CDA.CDA_TPMOVI="S" AND
				CDA.CDA_NUMERO=%Exp:(cAliasPri)->FT_NFORI% AND
				CDA.CDA_SERIE=%Exp:(cAliasPri)->FT_SERORI% AND
				CDA.CDA_NUMITE=%Exp:(cAliasPri)->FT_ITEMORI% AND
				CDA.%NotDel%
			EndSql
			
			While !(cAliasCDA)->(EOF())
				IF AllTrim((cAliasCDA)->CDA_CODLAN) ==  aCODRESS[1]				
					nDev := (cAliasCDA)->CDA_VALOR
					//Atualiza a tabela CDA
					CDA->(DbGoTo((cAliasPri)->RECNOCDA)) // se possiciona na devolução
					If AllTrim(CDA->CDA_CODLAN) == aDEVRESS[1]
						RecLock("CDA",.F.)
						nDev := nDev / (cAliasPri)->QUANT				
						CDA->CDA_VALOR :=	nDev * (cAliasPri)->FT_QUANT
						CDA->(MsUnlock())
					Endif			
				ElseIf len(aCODRESS) >= 2 .And. AllTrim((cAliasCDA)->CDA_CODLAN) ==  aCODRESS[2] .And. len(aDEVRESS) >= 2
					nDev := (cAliasCDA)->CDA_VALOR
					//Atualiza a tabela CDA
					CDA->(DbGoTo((cAliasPri)->RECNOCDA)) // se possiciona na devolução
					If AllTrim(CDA->CDA_CODLAN) == aDEVRESS[2]
						RecLock("CDA",.F.)
						nDev := nDev / (cAliasPri)->QUANT				
						CDA->CDA_VALOR :=	nDev * (cAliasPri)->FT_QUANT
						CDA->(MsUnlock())
					Endif
				Endif
				(cAliasCDA)->(dbSkip())
			Enddo
			(cAliasCDA)->(dbCloseArea())
		Endif
		
		End TransAction 
		(cAliasPri)->(dbSkip())
	Enddo
	
	(cAliasPri)->(dbCloseArea())

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CriarCD0
@description	Popula a Tabela CD0 (Ressarcimento).
				Utiliza a função UltEntPrd para localizar as Últimas Entradas do Produto.
@param cAliasSAI - Alias referente as saídas
@param cMetInc - Metodo de inclusão do registro (0-Automatico (Emissão da NF Saída) 1-Apuração)  
@param aCODRESS - Arrray com os códigos de Ressarcimento
@author Mauro A. Gonçalves
@since 10/10/2016
/*/
//-------------------------------------------------------------------
Function CriarCD0(cAliasSAI,cMetInc,aCODRESS,lTipRESS,aChaveNF,aDEVCOMP,cSGBD,lCalcCred,cMotPerd,cMotRoub,lCmpFcp)
Local nBasICMSEnt		:= 0 
Local nVlrICMSEnt		:= 0
Local nBasICMSAcum		:= 0
Local nVlrICMSAcum		:= 0
Local nQdePrdAcum		:= 0
Local nA				:= 0
Local aULTENT			:= {}
Local nVLCAMPO14		:= 0
Local nVLCAMPO15		:= 0
Local nVLCAMPO17		:= 0
Local nVlrICMS			:= 0
Local nVlrICMSPro		:= 0
Local cMotivo			:= ""

//Seleciona as ultimas entradas
aULTENT := UltEntPrd((cAliasSai)->FT_PRODUTO, (cAliasSai)->FT_QUANT, (cAliasSai)->FT_ENTRADA, .T., lTipRESS,aChaveNF,aDEVCOMP,cSGBD,lCalcCred,lCmpFcp)
//Popula a CD0
For nA:=1 To Len(aULTENT)
	
	//Determina Motivo
	cMotivo := "9" //9 – Outros	
	IF (Alltrim((cAliasSai)->FT_CFOP) $ cMotPerd)      //3 – Perda ou deterioração;– Furto ou roubo;
		cMotivo := "3"
	ElseIF (Alltrim((cAliasSai)->FT_CFOP) $ cMotRoub)  //4 – Furto ou roubo
		cMotivo := "4"	
	Elseif Substr((cAliasSai)->FT_CFOP,1,1)=="6"
		cMotivo := "1" 						  //1 – Venda para outra UF;
	Elseif Substr((cAliasSai)->FT_CFOP,1,1)=="7" .And. DTOS(mv_par02) >= "20180101"
		cMotivo := "5"						  //5 – Exportação
	Elseif ((cAliasSai)->FT_ISENICM  + (cAliasSai)->FT_OUTRICM) > 0
		cMotivo := "2"						 //2 –Saída amparada por isenção ou não incidência;
	Endif
	
	RecLock("CD0",.T.)
	CD0->CD0_FILIAL	:= xFilial("CD0")
	CD0->CD0_TPMOV	:= "S"
	CD0->CD0_DOC	:= (cAliasSai)->FT_NFISCAL
	IF lVer12
		SerieNfId("CD0",1,"CD0_SERIE",,,,(cAliasSai)->FT_SERIE)	
	Else
		CD0->CD0_SERIE	:= (cAliasSai)->FT_SERIE
	Endif
	CD0->CD0_CLIFOR	:= (cAliasSai)->FT_CLIEFOR
	CD0->CD0_LOJA	:= (cAliasSai)->FT_LOJA
	CD0->CD0_ITEM	:= (cAliasSai)->FT_ITEM
	CD0->CD0_COD	:= (cAliasSai)->FT_PRODUTO
	CD0->CD0_VALBST	:= Round(aULTENT[nA][10] / aULTENT[nA][18],2) //Valor unitario entrada 	//09-VL_UNIT_BC_ST
	CD0->CD0_VUNIT	:= aULTENT[nA][11] / aULTENT[nA][18] //Valor unitario Entrada	 		//08-VL_UNIT_ULT_E
	CD0->CD0_DOCENT	:= aULTENT[nA][01] //FT_NFISCAL    								 		//03-NUM_DOC_ULT_E
	CD0->CD0_SERENT	:= aULTENT[nA][02] //FT_SERIE       							 		//04-SER_ULT_E
	CD0->CD0_ESPECI	:= aULTENT[nA][03] //FT_ESPECIE
	CD0->CD0_FORNE	:= aULTENT[nA][04] //FT_CLIEFOR
	CD0->CD0_LOJENT	:= aULTENT[nA][05] //FT_LOJA
	CD0->CD0_EMISSA	:= aULTENT[nA][06] //FT_ENTRADA
	CD0->CD0_CHVNFE	:= aULTENT[nA][09] //FT_CHVNFE
	CD0->CD0_ITENFE	:= aULTENT[nA][08] //FT_ITEM											//11-NUM_ITEM_ULT_E	
	CD0->CD0_QUANT	:= aULTENT[nA][18] //Qtd Utilizada - 									//07-QUANT_ULT_E - quantidade da ultima entrada
	CD0->CD0_VLUNOP	:= aULTENT[nA][17] / aULTENT[nA][16] //Base ICMS Entrada      			//12-VL_UNIT_BC_ICMS_ULT_E	
	CD0->CD0_PICMSE	:= aULTENT[nA][12] //FT_ALIQICM       									//13-ALIQ_ICMS_ULT_E
	CD0->CD0_ALQSTE	:= aULTENT[nA][13] //FT_ALIQSOL		  									//16-ALIQ_ST_ULT_E	
	CD0->CD0_RESPRE	:= "1"
	CD0->CD0_MOTRES	:= cMotivo
	CD0->CD0_CHNFRT	:= ""
	CD0->CD0_PANFRT	:= ""
	CD0->CD0_LJPANF	:= ""
	CD0->CD0_SRNFRT	:= ""
	CD0->CD0_NRNFRT	:= ""
	CD0->CD0_ITNFRT	:= ""
	CD0->CD0_CODDA	:= ""
	CD0->CD0_NUMDA	:= ""
	nVLCAMPO14 		:= IIf(CD0->CD0_VALBST < CD0->CD0_VLUNOP, CD0->CD0_VALBST, CD0->CD0_VLUNOP) //14 VL_UNIT_LIMITE_BC_ICMS_ULT_E
	nVLCAMPO15		:= (nVLCAMPO14 * (CD0->CD0_PICMSE/100))										//15 VL_UNIT_ICMS_ULT_E
	nVLCAMPO17		:= (CD0->CD0_VALBST*(CD0->CD0_ALQSTE/100))- nVLCAMPO15
	CD0->CD0_VLUNRE	:= IIF(nVLCAMPO17 > 0,nVLCAMPO17,0)											//17 VL_UNIT_RES			
	CD0->CD0_BSULMT	:= nVLCAMPO14
	CD0->CD0_VLUNCR	:= nVLCAMPO15
	CD0->CD0_METINC	:= cMetInc
	If lCmpFcp
		CD0->CD0_FCPST	:= aULTENT[nA][19] / aULTENT[nA][18] //D1_VFCPANT - Valor unitario Fecp
	Endif
	CD0->CD0_ID		:= FWUUID("MATA926")
	CD0->(MsUnlock())
	CD0->(dbCommit())
	//Acumula caso precise calcular por média ponderada
	nQdePrdAcum	+= aULTENT[nA][18] //Qde utilizada 				
	nVlrICMSAcum	+= (aULTENT[nA][18] * CD0->CD0_VLUNRE) //Valor ICMS ST
	nVlrICMS		+= (aULTENT[nA][18] * nVLCAMPO15) //valor ICMS
Next
nBasICMSEnt	:= nBasICMSAcum 
nVlrICMSEnt	:= nVlrICMSAcum
nVlrICMSPro	:= nVlrICMS
//Calcula a média ponderada se necessario
If Len(aULTENT) > 1
	nVlrICMSEnt := (nVlrICMSAcum / nQdePrdAcum) * nQdePrdAcum
	nVlrICMSPro := (nVlrICMS	/ nQdePrdAcum) * nQdePrdAcum
Endif

Return {nVlrICMSEnt, nVlrICMSPro}

//-------------------------------------------------------------------
/*/{Protheus.doc} UltEntPrd
@description Seleciona as última entradas de um determinado Produto até atingir a quantidade de referência enviada por parâmetro
@param cCodPrd - Código do Produto
@param nQtdRef - Quantidade de Referência
@param dDTRef - Data de Referência para seleção das Entradas
@param lDetalhes -	.T. - Retorna informações completas no Array
						.F. - Retorna apenas a Base ICMS e o Valor no Array
@return aUltEntPrd - Array contendo as Últimas Entradas
@author Mauro A. Gonçalves
@since 10/10/2016
/*/
//-------------------------------------------------------------------
Static Function UltEntPrd(cCodPrd, nQtdRef, dDTRef, lDetalhes, lTipRESS,aChaveNF,aDEVCOMP,cSGBD,lCalcCred,lCmpFcp)
Local nQtdSdo		:= 1
Local nQtdEnt		:= 0
Local nQtdUti		:= 0
Local nVlrICMSEnt	:= 0
Local nBasICMSEnt	:= 0
Local nBasICMSAcum	:= 0
Local nVlrICMSAcum	:= 0
Local nQdePrdAcum	:= 0
Local nTotIteNF		:= 0
Local nValfecp		:= 0
Local aUltEntPrd	:= {}
Local cAliasSD1		:= GetNextAlias()
Local cJoinSF1		:= ""
Local cSelSD1		:= ""
Local cWheCD0		:= ""
Local cSelCD01		:= ""
Local cSelCD02		:= ""
Local cSelCD03		:= ""
Local nAliqST		:= 0
Local cChaveNF		:= ""
Local lDevComp		:= .F.
Local cOrderBy		:= "ORDER BY SD1.D1_DTDIGIT DESC, SD1.D1_NUMSEQ DESC"
Local cSYBASE		:= "0"
Local lFirst		:= .T.
Local dDtLimit    := Stod(AllTrim(Str((Year(dDTRef)-5)))+Substr(dtos(dDTRef),5,2)+'01') //- converte o ano limite Artigo 202 RICMS-SP
Local nPicm       := 0 //- percentual do ICMS Proprio
Local nBaseICM		:= 0
Local cCSTST		:="10|30|60|70" //CST que trata ICMS por substituição tributária.
Local cD1CFOP		:= ""

Local nMVICMPAD := SuperGetMV('MV_ICMPAD')

Default lDetalhes	:= .F.
Default lTipRESS	:= .F.
Default aChaveNF	:= {"","","",""}
Default aDEVCOMP	:= {"","",""}
Default lCalcCred	:= .T.

lDevComp := !Empty(aDEVCOMP[1]) .and. !Empty(aDEVCOMP[2]) .and. !Empty(aDEVCOMP[3])

IF cSGBD $ "MSSQL"
	cSelSD1 += "TOP 50 "
ElseIF cSGBD $ "ORACLE"
	cSelSD1 += "" //Quando ORACLE|MYSQL|POSTGRES tratamento corre no where ou order by
ElseIF cSGBD $ "MYSQL|POSTGRES"	
	cOrderBy += " LIMIT 50"	
ElseIF cSGBD $ "INFORMIX"
	cSelSD1 += "FIRST 50 "
Endif

If lDetalhes
	cSelSD1 +=	"SD1.D1_DOC, SD1.D1_SERIE, SF1.F1_ESPECIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_DTDIGIT, SD1.D1_COD, SD1.D1_ITEM, SF1.F1_CHVNFE, SD1.D1_CF, "
Endif

cSelSD1	+=	"SD1.D1_BASEICM, SD1.D1_PICM, SD1.D1_VALICM, SD1.D1_ALIQSOL, SD1.D1_BRICMS, SD1.D1_ICMSRET, SD1.D1_QUANT,SD1.D1_BASNDES,SD1.D1_ICMNDES,"
cSelSD1	+=	"SD1.D1_TOTAL, SD1.D1_VALDESC, SD1.D1_VALFRE, SD1.D1_SEGURO, SD1.D1_DESPESA, SD1.D1_CLASFIS "

If lCmpFcp
	cSelSD1	+=	" ,SD1.D1_VFCPANT "
Endif

//Devolução de compra
IF !lDevComp
	cSelSD1	+=	",SD1.D1_QUANT - "
	cSelSD1	+=	"(SELECT SUM(CD0_QUANT) "
	cSelSD1	+=	" FROM " + RetSqlName("CD0")

	IF lTipRESS
		If cSGBD $ "ORACLE"
			cSelSD1	+=	" WHERE CD0_FILIAL='"+xFilial("CD0")+"' AND CD0_ESPECI=SF1.F1_ESPECIE AND CD0_DOCENT=SD1.D1_DOC AND CD0_SERENT=SD1.D1_SERIE AND CD0_FORNE=SD1.D1_FORNECE AND CD0_LOJENT=SD1.D1_LOJA AND CD0_COD=SD1.D1_COD AND TRIM(CD0_ITENFE)=SUBSTR(SD1.D1_ITEM,-3,3) AND D_E_L_E_T_='') as Saldo"
			cWheCD0	+= "CD0_FILIAL='"+xFilial("CD0")+"' AND CD0_ESPECI=SF1.F1_ESPECIE AND CD0_DOCENT=SD1.D1_DOC AND CD0_SERENT=SD1.D1_SERIE AND CD0_FORNE=SD1.D1_FORNECE AND CD0_LOJENT=SD1.D1_LOJA AND CD0_COD=SD1.D1_COD AND TRIM(CD0_ITENFE)=SUBSTR(SD1.D1_ITEM,-3,3) AND D_E_L_E_T_='' "
		Else
			cSelSD1	+=	" WHERE CD0_FILIAL='"+xFilial("CD0")+"' AND CD0_ESPECI=SF1.F1_ESPECIE AND CD0_DOCENT=SD1.D1_DOC AND CD0_SERENT=SD1.D1_SERIE AND CD0_FORNE=SD1.D1_FORNECE AND CD0_LOJENT=SD1.D1_LOJA AND CD0_COD=SD1.D1_COD AND CD0_ITENFE=RIGHT(SD1.D1_ITEM,3) AND D_E_L_E_T_='') as Saldo"
			cWheCD0	+= "CD0_FILIAL='"+xFilial("CD0")+"' AND CD0_ESPECI=SF1.F1_ESPECIE AND CD0_DOCENT=SD1.D1_DOC AND CD0_SERENT=SD1.D1_SERIE AND CD0_FORNE=SD1.D1_FORNECE AND CD0_LOJENT=SD1.D1_LOJA AND CD0_COD=SD1.D1_COD AND CD0_ITENFE=RIGHT(SD1.D1_ITEM,3) AND D_E_L_E_T_='' "
		Endif
	Else
		//Utima entrada			
		cChaveNF := " AND CD0_TPMOV = 'S'"
		cChaveNF += " AND CD0_DOC = '"+aChaveNF[1]+"' "
		cChaveNF += " AND CD0_SERIE = '"+aChaveNF[2]+"' "		
		cChaveNF += " AND CD0_CLIFOR = '"+aChaveNF[3]+"' "
		cChaveNF += " AND CD0_LOJA = '"+aChaveNF[4]+"' "
		
		cSelSD1	+= " WHERE CD0_FILIAL='"+xFilial("CD0")+"' "
		cSelSD1	+= cChaveNF
		If cSGBD $ "ORACLE"
			cSelSD1	+= " AND CD0_ESPECI=SF1.F1_ESPECIE AND CD0_DOCENT=SD1.D1_DOC AND CD0_SERENT=SD1.D1_SERIE AND CD0_FORNE=SD1.D1_FORNECE AND CD0_LOJENT=SD1.D1_LOJA AND CD0_COD=SD1.D1_COD AND TRIM(CD0_ITENFE)=SUBSTR(SD1.D1_ITEM,-3,3) AND D_E_L_E_T_='') as Saldo"
		Else
			cSelSD1	+= " AND CD0_ESPECI=SF1.F1_ESPECIE AND CD0_DOCENT=SD1.D1_DOC AND CD0_SERENT=SD1.D1_SERIE AND CD0_FORNE=SD1.D1_FORNECE AND CD0_LOJENT=SD1.D1_LOJA AND CD0_COD=SD1.D1_COD AND CD0_ITENFE=RIGHT(SD1.D1_ITEM,3) AND D_E_L_E_T_='') as Saldo"
		Endif
		cWheCD0	+= "CD0_FILIAL='"+xFilial("CD0")+"'"
		cWheCD0	+= cChaveNF
		If cSGBD $ "ORACLE"
			cWheCD0	+= " AND CD0_ESPECI=SF1.F1_ESPECIE AND CD0_DOCENT=SD1.D1_DOC AND CD0_SERENT=SD1.D1_SERIE AND CD0_FORNE=SD1.D1_FORNECE AND CD0_LOJENT=SD1.D1_LOJA AND CD0_COD=SD1.D1_COD AND TRIM(CD0_ITENFE)=SUBSTR(SD1.D1_ITEM,-3,3) AND D_E_L_E_T_='' "
		Else
			cWheCD0	+= " AND CD0_ESPECI=SF1.F1_ESPECIE AND CD0_DOCENT=SD1.D1_DOC AND CD0_SERENT=SD1.D1_SERIE AND CD0_FORNE=SD1.D1_FORNECE AND CD0_LOJENT=SD1.D1_LOJA AND CD0_COD=SD1.D1_COD AND CD0_ITENFE=RIGHT(SD1.D1_ITEM,3) AND D_E_L_E_T_='' "
		Endif
	Endif	
		
	cSelCD01	+= "(NOT EXISTS (SELECT * FROM " + RetSqlName("CD0") + " WHERE " + cWheCD0 + ")"

	cSelCD02	+= "((SELECT SUM(CD0_QUANT) FROM "  + RetSqlName("CD0") + " WHERE " + cWheCD0 + ")<SD1.D1_QUANT)) "

	cSelCD03	:=	"AND" + cSelCD01 + "OR" + cSelCD02

//Devolução de compra
Else
	cSelCD03	:=	" AND SD1.D1_DOC = '"+aDEVCOMP[1]+"' "
	cSelCD03	+=	" AND SD1.D1_SERIE = '"+aDEVCOMP[2]+"' "
	cSelCD03	+=	" AND SD1.D1_ITEM = '"+aDEVCOMP[3]+"' "
Endif

cSelCD03 := cSelCD03+cOrderBy

cSelSD1 	:= "%" + cSelSD1 + "%"
cSelCD03	:= "%" + cSelCD03 + "%"
//cSYBASE		:= "%" + cSYBASE + "%"

cJoinSF1	:="INNER JOIN "+RetSqlName("SF1")+" SF1 ON SF1.F1_FILIAL='"+xFilial("SF1")+"' AND SF1.F1_DOC=SD1.D1_DOC AND SF1.F1_SERIE=SD1.D1_SERIE AND SF1.F1_FORNECE= SD1.D1_FORNECE AND SF1.F1_LOJA=SD1.D1_LOJA AND SF1.D_E_L_E_T_=' ' ""
cJoinSF1 	:= "%" + cJoinSF1 + "%"

IF cSGBD $ "ORACLE"
	
	BeginSql Alias cAliasSD1
	
		COLUMN D1_DTDIGIT AS DATE
		SELECT *
		FROM (
			SELECT %Exp:cSelSD1%
		
			FROM 
			%table:SD1% SD1
			%Exp:cJoinSF1%
		
			WHERE 
				SD1.D1_FILIAL = %xFilial:SD1% AND		
				(SD1.D1_TIPO NOT IN('B','D','P','I','C')) AND		
				SD1.D1_COD = %Exp:cCodPrd% AND
				SD1.D1_DTDIGIT >= %Exp:dDtLimit% AND 
				SD1.D1_DTDIGIT <= %Exp:dDTRef% AND
				SD1.D1_NFORI = ' ' AND SD1.D1_SERIORI = ' ' AND SD1.D1_ITEMORI = ' ' AND 
				SD1.%NotDel%
				%Exp:cSelCD03%
			)
		WHERE
			ROWNUM <= 50
	EndSql

else
	BeginSql Alias cAliasSD1
	
		COLUMN D1_DTDIGIT AS DATE
		
		//SET ROWCOUNT %Exp:cSYBASE%
		SELECT %Exp:cSelSD1%
	
		FROM 
		%table:SD1% SD1
		%Exp:cJoinSF1%
	
		WHERE 
			SD1.D1_FILIAL = %xFilial:SD1% AND		
			(SD1.D1_TIPO NOT IN('B','D','P','I','C')) AND		
			SD1.D1_COD = %Exp:cCodPrd% AND
			SD1.D1_DTDIGIT >= %Exp:dDtLimit% AND 
			SD1.D1_DTDIGIT <= %Exp:dDTRef% AND
			SD1.D1_NFORI = ' ' AND SD1.D1_SERIORI = ' ' AND SD1.D1_ITEMORI = ' ' AND 
			SD1.%NotDel%
			%Exp:cSelCD03%
	EndSql

endif
	
While !(cAliasSD1)->(EOF()) .And. nQtdSdo > 0 
	//Valor unitário da mercadoria constante na NF relativa a última entrada inclusive despesas acessórias
	nVlrICMSEnt	:= (cAliasSD1)->(D1_TOTAL + D1_VALFRE + D1_SEGURO + D1_DESPESA - D1_VALDESC)
	// Utilizar quando não tenho D1_BASEICM
	nBaseICM := nVlrICMSEnt
	//Valor unitário da base de cálculo do imposto pago por substituição. 
	nBasICMSEnt	:= (cAliasSD1)->(Iif(D1_BRICMS > 0, D1_BRICMS, D1_BASNDES))	
	
	//Valor unitario fecp informado pelo usuario
	If lCmpFcp
		nValfecp := (cAliasSD1)->D1_VFCPANT
	Endif

	cD1CFOP:= AllTrim((cAliasSD1)->D1_CF)
	//- venda tributada normal não gera ressarcimento e nem credito
	//- OU Verifica se exatamente a ultima entrada possui ICMS ST caso não possua deve terminar processamento.
	If (Right(cD1CFOP,3) == '102' .And. !( cD1CFOP == "3102" .And. Right((cAliasSD1)->D1_CLASFIS,2)$(cCSTST) ) ).OR. ;
	(nBasICMSEnt == 0 .And. Left(cD1CFOP,1) =='3') .Or. ; //Operações que de importação sem ST Não possui ressacimento
	(!lCalcCred .And. nBasICMSEnt == 0 .And. (cAliasSD1)->D1_BASEICM == 0)	// Operações que de não possui ICMS ST e ICMS e não ira calcular credito proprio
		//- forca a retirar todo o ressacimento e credito apurado 
		aUltEntPrd := {} 
		Exit
	EndIF
	
	lFirst := .F.	
	
	//Quando operação indireta considera aliquota do produto
	nAliqST := (cAliasSD1)->D1_ALIQSOL
	
	//- se a aliquota vir zerada busca pelos cadastros 
	IF nAliqST == 0 .And. SB1->(MsSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
		nAliqST := SB1->B1_PICM
		If nAliqST == 0 
			nAliqST := nMVICMPAD
		EndIf 
	Endif

	//- Percentual do ICMS usado 
	nPicm   := (cAliasSD1)->D1_PICM
	
	//- verifica se o ICMS esta zerado
	//- isso ocorre com fornecedor substituido, onde não há aliquota de calculo
	//- pelo fato de não existir ICMS
	If nPicm == 0 
		nPicm := nAliqST
	EndIF 

	If !lDevComp
		If !Empty((cAliasSD1)->Saldo)
			nQtdEnt := (cAliasSD1)->Saldo
		Else	
			nQtdEnt := (cAliasSD1)->D1_QUANT
		Endif
	Else
		nQtdEnt := (cAliasSD1)->D1_QUANT
	Endif

	//Verifica se a qde atende 
	nQtdSdo := nQtdRef - nQtdEnt
	If nQtdSdo = 0
		nQtdUti := nQtdEnt
	ElseIf nQtdSdo < 0
		nQtdUti := nQtdRef
		nQtdSdo := 0
	Else
		nQtdUti := nQtdEnt
		nQtdRef -= nQtdEnt
	Endif
	
	nVlrICMSEnt	:= (nVlrICMSEnt / (cAliasSD1)->D1_QUANT) * nQtdUti  
	nBasICMSEnt	:= (nBasICMSEnt / (cAliasSD1)->D1_QUANT) * nQtdUti	
	nValfecp	:= (nValfecp	/ (cAliasSD1)->D1_QUANT) * nQtdUti
	
	nBaseICM := Iif( (cAliasSD1)->D1_BASEICM > 0, (cAliasSD1)->D1_BASEICM, nBaseICM)
	
	//Quando não existir valor ST utiliza valor da mercadoria
	IF nBasICMSEnt == 0
		nBasICMSEnt := nVlrICMSEnt 
		nAliqST := 0
	Endif
	
	//Não Calcula crédito ICMS para notas que não tiveram calculo ICMS na entrada
	//Issue:http://jiraproducao.totvs.com.br/browse/DSERFIS1-1958
	//Possui direito do crédito mas não quer utilizar
	If !lCalcCred .And. (cAliasSD1)->D1_BASEICM == 0
		nPicm := 0
		nBaseICM := 0
	Endif
	
	//Popula o array com as informações da SFT
	If lDetalhes //Todas informações da NF
		(cAliasSD1)->(AADD(aUltEntPrd,{D1_DOC,;			//1
									  D1_SERIE,;			
									  F1_ESPECIE,;
									  D1_FORNECE,;
									  D1_LOJA,;			//5
									  D1_DTDIGIT,;
									  D1_COD,;
									  RIGHT(D1_ITEM,3),;
									  F1_CHVNFE,;
									  nBasICMSEnt,;		//10
									  nVlrICMSEnt,;
									  nPicm,;
									  nAliqST,; 
									  D1_BRICMS,;
									  D1_ICMSRET,;		//15
									  D1_QUANT,;
									  nBaseICM,;
									  nQtdUti,;			//18
									  nValfecp}))		//19
	Else
		//Acumula caso precise calcular por média ponderada
		nTotIteNF		++
		nQdePrdAcum	+= nQtdUti 
		nBasICMSAcum	+= (nQtdUti * nBasICMSEnt)
		nVlrICMSAcum	+= (nQtdUti * nVlrICMSEnt)
	Endif
	 						
	(cAliasSD1)->(DbSkip())
Enddo

(cAliasSD1)->(dbCloseArea())	

//Calcula a média ponderada se necessario
If !lDetalhes //Apenas os valores
	If nTotIteNF > 1
		nBasICMSEnt := nBasICMSAcum / nQdePrdAcum 
		nVlrICMSEnt := nVlrICMSAcum / nQdePrdAcum
	Endif
	AADD(aUltEntPrd, {nBasICMSEnt, nVlrICMSEnt})
Endif		
		
Return aUltEntPrd

//-------------------------------------------------------------------
/*/{Protheus.doc} F132SelPri
Seleção principal

@author Mauro A. Goncalves
@since 27/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F132SelPri(nOpc)
Local nA			:= 0
Local nQtdReg		:= 0
Local cQryCD0		:= ''
Local aCODRESS	:= IIf(Empty(SuperGetMv("MV_CODRESS",,"")),{"SP10090719","SP10090721"},&(SuperGetMv("MV_CODRESS",,{"SP10090719","SP10090721"}))) //Códigos de Ressarcimento 
Local aDEVRESS	:= IIf(Empty(SuperGetMv("MV_DEVRESS",,"")),{"SP50000319","SP50000321"},&(SuperGetMv("MV_DEVRESS",,{"SP50000319","SP50000321"}))) //Códigos de Devolução de Ressarcimento
Local cCODRESS	:= ''
Local cDEVRESS	:= ''
Local cCODDEV	:= ''
Local cSelect		:= ''
Local cFrom		:= ''
Local cWhere		:= ''
Local cGroup		:= ''
Local cAliasSAI	:= ''
Local cJoinSF1	:= ''

//Verifica se parametro está preenchido
If Len(aCODRESS)==0
	MsgAlert("Verifique o conteúdo do parâmetro MV_CODRESS."+Chr(13)+"Caso não exista, execute o compatibilizador U_UPDSIGAFIS para a atualização do Dicionário.")
	Return 0
Endif

//Define como monta a query 
cSelect += "SFT.FT_TIPOMOV,SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_ESPECIE,SFT.FT_TIPO,SFT.FT_PRODUTO,SFT.FT_CFOP,SFT.FT_TRFICM,SFT.FT_ISENICM,SFT.FT_OUTRICM, "
cSelect += "SFT.FT_ITEM,SFT.FT_QUANT,SFT.FT_ENTRADA,SFT.FT_PRCUNIT,SFT.FT_BASEICM,SFT.FT_NFORI,SFT.FT_SERORI,SFT.FT_ITEMORI,SFT.FT_ESTADO,"
cSelect += "SFT2.FT_QUANT AS QUANT,SFT2.FT_ESPECIE AS ESPECIE,SFT2.FT_CLIEFOR as CLI,SFT2.FT_LOJA as LOJ,SFT2.FT_ITEM as ITEM,"	
cSelect += "CDA.CDA_CODLAN,CDA.R_E_C_N_O_ As RECNOCDA"

//Monta váriavel para selecionar os códigos lançamento validos
For nA:=1 To Len(aCODRESS)
	cCODRESS += aCODRESS[nA] + IIf(nA<Len(aCODRESS),"/","")	
Next
cCODRESS := "CDA.CDA_CODLAN IN " + FormatIn(cCODRESS,"/")

For nA:=1 To Len(aDEVRESS)
	cDEVRESS += aDEVRESS[nA] + IIf(nA<Len(aDEVRESS),"/","")	
Next
cDEVRESS := "CDA.CDA_CODLAN IN " + FormatIn(cDEVRESS,"/")



cFrom	+=	RetSqlName("CDA") + " CDA "
cFrom	+=	"JOIN " + RetSqlName("CE0") + " CE0 ON (CE0.CE0_FILIAL='" + xFilial("CE0") + "' AND CE0.CE0_CODIGO=CDA.CDA_CODREF AND CE0.CE0_NFVALO='I' AND CE0.D_E_L_E_T_='') "
cFrom	+=	"JOIN " + RetSqlName("SFT") + " SFT ON (SFT.FT_FILIAL='"  + xFilial("SFT") + "' AND ((SFT.FT_TIPOMOV = 'S') OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO = 'D')) AND SFT.FT_SERIE=CDA.CDA_SERIE AND SFT.FT_NFISCAL=CDA.CDA_NUMERO AND "
cFrom	+=	"SFT.FT_CLIEFOR=CDA.CDA_CLIFOR AND SFT.FT_LOJA=CDA.CDA_LOJA AND SFT.FT_ITEM=CDA.CDA_NUMITE AND SFT.D_E_L_E_T_='' AND SFT.FT_DTCANC='' AND "
cFrom	+=	"SFT.FT_ENTRADA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) +"') "
cFrom	+=	"LEFT JOIN "+RetSqlName("SFT") + " SFT2 ON (SFT2.FT_FILIAL='"+xFilial("SFT")+"' AND SFT2.FT_TIPOMOV = 'S' AND SFT2.FT_NFISCAL=SFT.FT_NFORI AND SFT2.FT_SERIE=SFT.FT_SERORI AND SFT2.FT_ITEM=SFT.FT_ITEMORI AND SFT2.D_E_L_E_T_='') "

cWhere	+= "CDA.CDA_FILIAL = '" + xFilial("CDA") + "' AND "
cWhere	+= "((CDA.CDA_TPMOVI = 'S' AND "+cCODRESS+" ) OR (CDA.CDA_TPMOVI = 'E' AND "+cDEVRESS+" )) AND "
cWhere	+= "CDA.CDA_ESPECI NOT IN ('CF','ECF')  AND "
cWhere	+= "CDA.D_E_L_E_T_ = '' "

//Monta variaveis para executar a query
cSelect	:= "%" + cSelect	+ "%"
cFrom		:= "%" + cFrom	+ "%"
cWhere		:= "%" + cWhere	+ "%"

//Executa para pegar quantidade de registros
cAliasSAI	:= GetNextAlias()

BeginSql Alias cAliasSai

	SELECT COUNT(*) QTDREG
	FROM  %Exp:cFrom% 
	WHERE %Exp:cWhere%
	 
EndSQL

nQtdReg := (cAliasSai)->QTDREG

(cAliasSai)->(dbCloseArea())
    
If nQtdReg == 0 
	MsgAlert("Não Apurado!"+Chr(13)+"Período sem movimentação.")
	Return nQtdReg
Endif

//Apuração    
BeginSql Alias cAliasSai

	COLUMN FT_ENTRADA AS DATE
				
	SELECT %Exp:cSelect%
	FROM  %Exp:cFrom% 
	WHERE %Exp:cWhere%
	ORDER  BY SFT.FT_TIPOMOV DESC, SFT.FT_ENTRADA,SFT.FT_TIPO DESC,SFT.FT_NFISCAL
EndSql

If nQtdReg > 0
	cAliasPri := cAliasSai
Endif

Return nQtdReg

*/
//-------------------------------------------------------------------
/*/{Protheus.doc} ValdSda 
Função de validação das notas de saída

@author Rafael Oliveira
@since 21/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValdSda(cNfiscal, cSerie, cCliefor, cLoja, cEspecie, cTipo, cProduto, cItem, cCfop,nVTrfIcm,cEstado)
Local lRet:= .T.
Local lInscrito := .F.
Local lA1Contrib := SA1->(FieldPos(A1_CONTRIB)) == 0
Static _cKeyComp := '' 
Static _lRet     := .T.

//- usado para diminuir o I/O do procesamento
//- na exisitencia de notas de saidas grnades
If _cKeyComp == cNfiscal+cSerie+cCliefor+cLoja+cEspecie+cTipo
	Return _lRet 
EndIf

//- alimenta a variavel de memoria 
_cKeyComp := cNfiscal+cSerie+cCliefor+cLoja+cEspecie+cTipo

//Vendas Internas para consumidor final 
IF Substr(cCfop,1,1) == "5" .And. cTipo <> "D" //Se devolução de compra não valida cliente ou transferencia.
	
	//Transferencia interna entre filiais
	IF nVTrfIcm > 0		
		lRet:= .F.		
	Endif
	
	If lRet
		//Localiza cliente
		SA1->(MsSeek(xFilial("SA1")+cCliefor+cLoja))
		
		//.T. = Não contribuinte - .F. = Contribuinte
		lInscrito := IIf(Empty(SA1->A1_INSCR).Or."ISENT" $ SA1->A1_INSCR .Or. "RG" $ SA1->A1_INSCR .Or.( lA1Contrib .And. SA1->A1_CONTRIB == "2"),.T.,.F.)

		If SA1->A1_CONTRIB == "1" .and. SA1->A1_TPJ == "3" .and. ( Empty( SA1->A1_INSCR ) .or. "ISENT" $ SA1->A1_INSCR )
			lInscrito := .F.
		EndIf

		//Tratamento para considerar como contribuinte do ICMS Produtor Rural com inscrição Rural
		If (!Empty(SA1->A1_INSCRUR) .And. "L" $ SA1->A1_TIPO .And. ( lA1Contrib .And. SA1->A1_CONTRIB <> "2"))
			lInscrito := .F.
		EndIf
		
		If lInscrito // Não contribuinte
			//Verifica pedido de venda ou cliente se é consumidor final não contribuinte
			SD2->(dbSetOrder(3))
			IF SD2->(MsSeek(xFilial("SD2")+cNfiscal+cSerie+cCliefor+cLoja+cProduto+cItem))
				SC5->(dbSetOrder(1))
				If SC5->(MsSeek(xFilial("SC5")+SD2->D2_PEDIDO))
					IF SC5->C5_TIPOCLI == "F"			
						lRet:= .F.
					Else
						lRet:= .T.
					Endif
				Else
					//Caso não encontre pedido procura cliente 		
					If SA1->A1_TIPO == "F"
						lRet:= .F.
					Else
						lRet:= .T.
					Endif
				Endif
			Endif	
		Endif
	Endif
Endif 

//- alimenta o retorno para a memoria
_lRet := lRet

Return lRet

/*---------------------------
{Protheus.doc} F132CpoBrw 
Monta o array com os campos que serão exibidos
//------------------------------------------------*/
Static Function F132CpoBrw()

Local aArea		 := GetArea()            
Local aStructSFT := SFT->(DbStruct()) 
Local aColumns	 := {} 
Local nX		 := 0
Local nPos		 := 0
Local aCampoGrid := {"FT_TIPOMOV","FT_TIPO","FT_NFISCAL","FT_SERIE","FT_CLIEFOR","FT_LOJA","FT_ENTRADA","FT_ESTADO","FT_BASEICM","FT_VALICM","FT_VALCONT"}

For nX:=1 To Len(aCampoGrid)
	If (nPos:=Ascan(aStructSFT,{|x| x[1]==aCampoGrid[nX]}))>0
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStructSFT[nPos][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(RetTitle(aStructSFT[nPos][1])) 
        aColumns[Len(aColumns)]:SetSize(aStructSFT[nPos][3]) 
        aColumns[Len(aColumns)]:SetDecimal(aStructSFT[nPos][4])
        aColumns[Len(aColumns)]:SetPicture(PesqPict("SFT",aStructSFT[nPos][1]))
		aColumns[Len(aColumns)]:SetAlign(IIf(aStructSFT[nPos][2]=="N",2,0))
    EndIf     
Next nX 

Return(aColumns)
