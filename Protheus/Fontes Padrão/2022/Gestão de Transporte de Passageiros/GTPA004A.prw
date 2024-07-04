#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA004A.CH'

STATIC nTamSeq 	:= TamSx3("G5I_SEQ")[1]
STATIC oMdlG004	
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA004()
Rotina para seleção dos trecho de linha
 
@sample		GTPA004A()

@param 	oModel		objeto Model utilizado na rotina GTPA004.

@return		oBrowse  Cadastro de Horários por Seção
 
@author		Inovação
@since			10/02/2017
@version		P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA004A(oModel)

Local oModelGID 	:= oModel:GetModel("GIDMASTER")
Local lRet 		:= .T.

oMdlG004 := oModel
If !Empty(oModelGID:GetValue('GID_LINHA')) .and. !Empty(oModelGID:GetValue('GID_SENTID')) .and. !Empty(oModelGID:GetValue('GID_HORCAB'))
	nRet := FWExecView( STR0001 , "VIEWDEF.GTPA004A", MODEL_OPERATION_INSERT, /*oDlg*/, ; //"Seleção de Localidade"
					{|| .T. } ,/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
Else
	Help( ,, 'Help',"GTPA004A", STR0002, 1, 0 )//"Necessario preencher os campos Linha,Sentido,Hora inicio e via"
EndIf	
Return (lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados

@sample		ModelDef()

@return		oModel - Retorna o Modelo de dados

@author		 Inovação
@since			13/02/2017
@version		P12
/*/
//------------------------------------------------------------------------------------------

Static Function ModelDef()
	
Local oStruGID	:= FWFormStruct( 1,"GID",{|cCampo| AllTrim(cCampo)+"|" $ "GID_LINHA|GID_NLINHA|GID_SENTID|"})	//Cabeçalho
Local oStruG5I	:= FWFormStruct( 1,"G5I",{|cCampo| AllTrim(cCampo)+"|" $ "G5I_SEQ|G5I_LOCALI|G5I_DESLOC|G5I_TEMPO|G5I_KM|"})	//Techo
Local oModel	
Local bPosvalid	:= {|oModel|GTP4PVld(oModel)}
Local bCommit 	:= {|oModel|GTP4AGrv(oModel)}

oStruGID:SetProperty("GID_LINHA", MODEL_FIELD_WHEN, {||.T.})

oStruG5I:SetProperty("G5I_TEMPO", MODEL_FIELD_WHEN, {||.T.})
oStruG5I:SetProperty("G5I_KM", MODEL_FIELD_WHEN, {||.T.})

oModel := MPFormModel():New('GTPA004A',/*bPreValid */,bPosValid,bCommit, /*bCancel*/)

//Criando um campo de check para selecionar o trecho	 
oStruG5I:AddField("","","G5I_CHECK","L",1,0,Nil,Nil,Nil,Nil,Nil) //"Check para selecionar o trecho"

oModel:AddFields('FIELDG5I',/*PAI*/,oStruGID,/*bPreVld*/, /*bPost*/ , /*bLoad*/  )

// Adiciona Relacionamento
oModel:addGrid('G5IDETAIL','FIELDG5I',oStruG5I,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)

oModel:SetRelation( 'G5IDETAIL', { { 'G5I_FILIAL', 'xFilial( "GID" )' }, { 'G5I_CODLIN', 'GID_LINHA ' } }, G5I->(IndexKey(1)))

oModel:SetPrimaryKey({"GID_FILIAL","GID_LINHA","GID_SENTID", "GID_HORCAB"})

oModel:GetModel( 'G5IDETAIL' ):SetMaxLine(999999)

// Adiciona Descrição
oModel:SetDescription(STR0004) // "Seleção de localidade"

oModel:SetActivate( {|oModel| InitDados(oModel) } )
	
Return (oModel)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample		ViewDef()
 
@return		oView - Objeto do interface
 
@author	Inovação
@since		13/02/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= FWFormView():New()
Local oModel		:= FWLoadModel('GTPA004A')
Local oStruCab	:= FWFormStruct(2,'GID',{|cCampo| AllTrim(cCampo)+"|" $ "GID_LINHA|GID_NLINHA|GID_SENTID|"})
Local oStruItem	:= FWFormStruct(2,'G5I',{|cCampo| AllTrim(cCampo)+"|" $ "G5I_SEQ|G5I_LOCALI|G5I_DESLOC|G5I_TEMPO|"})

oStruItem:AddField("G5I_CHECK","01",''	,''	,{''}	,"L",,Nil,Nil,.F.,Nil) //Campo check box para grid

oStruCab:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
oStruItem:SetProperty('G5I_CHECK', MVC_VIEW_CANCHANGE , .T. )
oStruItem:SetProperty("G5I_TEMPO", MVC_VIEW_CANCHANGE, .F.)
oStruItem:SetProperty("G5I_DESLOC", MVC_VIEW_CANCHANGE, .F.)
oStruItem:SetProperty("G5I_LOCALI", MVC_VIEW_CANCHANGE, .F.)
oStruItem:SetProperty("G5I_SEQ", MVC_VIEW_CANCHANGE, .F.)

oView:SetModel(oModel) 

oView:AddField('VIEW_GID',oStruCab,'FIELDG5I') 
oView:AddGrid('VIEW_GIE',oStruItem,'G5IDETAIL')

oView:CreateHorizontalBox('SUPERIOR',30) 
oView:CreateHorizontalBox('INFERIOR',70)
oView:SetOwnerView('VIEW_GID','SUPERIOR')
oView:SetOwnerView('VIEW_GIE','INFERIOR')

oView:SetDescription(STR0004) // "Seleção de localidade"

oView:SetCloseOnOk({||.T.})

Return (oView)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados()
Carrega os horários na grid com base nas informações preenchidas no cabeçalho.
@sample	InitDados()
@author	Inovação
@since		13/02/2017
@version	P12
/*/
//-----------------------------------------------------------------------------------------
Static Function InitDados(oModel)

Local oGID004	:= oMdlG004:GetModel("GIDMASTER")
Local oModelGID	:= oModel:GetModel("FIELDG5I")
Local oModelG5I	:= oModel:GetModel("G5IDETAIL")
Local cAliasTmp	:= GetNextAlias()

//Carregando o field com valor da rotina GTPA004
oModelGID:SetValue('GID_LINHA',  AllTrim(oGID004:GetValue('GID_LINHA')))
	 
//Carregando o field com valor da rotina GTPA004
oModelGID:SetValue('GID_NLINHA' , oGID004:GetValue('GID_NLINHA'))

//Carregando o field com valor da rotina GTPA004
oModelGID:SetValue('GID_SENTID' , oGID004:GetValue('GID_SENTID') )

//Realiza pesquisa para popular o grid G5I, pegando ultimor registro ativo 
BeginSql Alias cAliasTmp
	Select 
		G5I.G5I_SEQ,G5I.G5I_LOCALI,G5I.G5I_CODLIN, G5I.G5I_TEMPO, G5I.G5I_KM
	from 
		%Table:G5I% G5I
	WHERE 
		G5I.%notdel%
		AND G5I.G5I_FILIAL = %xfilial:G5I%
		AND G5I.G5I_CODLIN = %exp:oGID004:GetValue('GID_LINHA')%
		AND G5I.G5I_HIST = %exp:'2'%
		ORDER BY G5I.G5I_SEQ
EndSql
//Populando o grid com resultado da pesquisa da tabela G5I
While !(cAliasTmp)->(EOF())
	If !oModelG5I:IsEmpty()
		oModelG5I:AddLine()
	Endif
	
	oModelG5I:SetValue('G5I_SEQ',(cAliasTmp)->G5I_SEQ )
	oModelG5I:SetValue('G5I_LOCALI',(cAliasTmp)->G5I_LOCALI )
	oModelG5I:SetValue('G5I_TEMPO',(cAliasTmp)->G5I_TEMPO )
	oModelG5I:SetValue('G5I_KM',(cAliasTmp)->G5I_KM )
	//Check automatico no inicio e fim
	IIF(oModelG5I:GetValue('G5I_SEQ') == '001' .Or. oModelG5I:GetValue('G5I_SEQ') == '999',;
	oModelG5I:SetValue('G5I_CHECK',.T.),oModelG5I:SetValue('G5I_CHECK',.F.))
	
	(cAliasTmp)->(DbSkip())
EndDo
(cAliasTmp)->(DBCloseArea())
oModel:GetModel( 'G5IDETAIL' ):SetNoInsertLine(.T.)// Não permite inclusao no grid
oModel:GetModel( 'G5IDETAIL' ):SetNoDeleteLine(.T.)// Não permite deletar a linha
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP4AGrv()
Criado a lista de trecho que será carregada na rotina GTP004 no Grid GIE
@sample	InitDados()
@author	Inovação
@since		13/02/2017
@version	P12
/*/
//-----------------------------------------------------------------------------------------
Static Function GTP4AGrv(oModel)
Local lRet 		:= .T.
Local oGID004 	:= oMdlG004:GetModel("GIDMASTER")
Local oModelGIE	:= oMdlG004:GetModel("GIEDETAIL")
Local oModelG5I	:= oModel:GetModel("G5IDETAIL")
Local cHoraIni	:= oGID004:GetValue('GID_HORCAB')
Local nI 		:= 1
Local nY		:= 2
Local nZ		:= 0
Local aTrecho	:= {}
Local cLocOri	:= ''
Local cLocDes	:= ''
Local cTempo	:= ''
Local cTmpTot	:= ''
Local cItem		:= 1
Local nSomaHr	:= 0
Local nAux		:= 0
Local cHrAux	:= '' 
Local cHrOri	:= ''
Local nDiaDec	:= 0
Local nDelta	:= '0000'
Local nHrNv	:= 0
//Verifica o Sentindo da linha para geração dos trechos
If oGID004:GetValue('GID_SENTID') != '2'
	cHrOri	:= cHoraIni
	cHrAux	:= GTFormatHour( cHoraIni , "99:99")
	//Criando sequencia dos trechos para ida
	While nI <= oModelG5I:Length()
		oModelG5I:GoLine(nI)
		nY := 1
		//Verifica se foi checado a linha do grid
		If oModelG5I:GetValue('G5I_CHECK')
			cLocOri := oModelG5I:GetValue('G5I_LOCALI') // Local origem
			cTempo := GTFormatHour( oModelG5I:GetValue('G5I_TEMPO') , "99:99")
			While nY <= oModelG5I:Length() 
			 	oModelG5I:GoLine(nY)
				If nY > nI  
					
					//Adiciona em array o trecho selecionando com sequencia + origem + destino
					cLocDes := oModelG5I:GetValue('G5I_LOCALI')
					
					nSomaHr	:= SomaHoras(cHrAux,cTempo)
					
					//Verifica a somotoria do horario se ultrapassou mais de 24h
					If nSomaHr >= 24.00
						nHrNv	:= nSomaHr
						nAux := nSomaHr - 24.00
						cTmpTot :=  GTFormatHour(nAux,'9999') 
						//Calculando o tempo do trecho
						nDelta	:= SomaHoras(GTFormatHour(nDelta, "99:99"),GTFormatHour(cTempo, "99:99")) 
						nDiaDec++
					Else
						cTmpTot :=  GTFormatHour(nSomaHr,'9999')
						//Calculando o tempo do trecho
						nDelta	:= SomaHoras(GTFormatHour(nDelta, "99:99"),GTFormatHour(cTempo, "99:99")) 
					EndIf 
					
					//Verificando se foi selecionando a localidade
					If oModelG5I:GetValue('G5I_CHECK')
						
						//Adicionando valores no Array sequencia + Local Origem + Local Destino + Horario Destino +Horario Origem + Dia decorrido
						aAdd(aTrecho,{STRZERO(cItem,4),cLocOri,cLocDes,cTmpTot,cHrOri,nDiaDec,GTFormatHour(nDelta, "9999")})
						cHrOri	:= cTmpTot
						cItem++
						cHrAux	:=  GTFormatHour(cTmpTot,'99:99')
						cTempo := GTFormatHour( oModelG5I:GetValue('G5I_TEMPO') , "99:99")
						nDelta	:= '0000'
						EXIT
					Else
						cHrAux	:=  GTFormatHour(cTmpTot,'99:99')
						cTempo := GTFormatHour( oModelG5I:GetValue('G5I_TEMPO') , "99:99")
					EndIf
				EndIf
				nY++
			EndDo
		EndIf
		nI++
	EndDo 
	
Else
	//Criando sequencia dos trechos para Volta
	nI := oModelG5I:Length()
	cHrOri	:= cHoraIni
	cHrAux	:= GTFormatHour( cHoraIni , "99:99")
	While nI >= 1
		oModelG5I:GoLine(nI)
		nY := oModelG5I:Length()
		//Verifica se foi checado a linha do grid
		If oModelG5I:GetValue('G5I_CHECK')
			cLocOri := oModelG5I:GetValue('G5I_LOCALI') // Local origem
			While nY >= 1
				
			 	oModelG5I:GoLine(nY)
				If nY < nI
					cTempo := GTFormatHour( oModelG5I:GetValue('G5I_TEMPO') , "99:99")
					
					cLocDes := oModelG5I:GetValue('G5I_LOCALI')
					
					//Realizando o calculo de horario 
					nSomaHr	:= SomaHoras(cHrAux,cTempo)
					
					//Verifica a somotoria do horario se ultrapassou mais de 24h
					If nSomaHr >= 24.00
						nAux := nSomaHr - 24.00
						cTmpTot :=  GTFormatHour(nAux,'9999') 
						//Calculando o tempo do trecho
						nDelta	:= SomaHoras(GTFormatHour(nDelta, "99:99"),GTFormatHour(cTempo, "99:99")) 
						nDiaDec++
					Else
						cTmpTot :=  GTFormatHour(nSomaHr,'9999')
						//Calculando o tempo do trecho
						nDelta	:= SomaHoras(GTFormatHour(nDelta, "99:99"),GTFormatHour(cTempo, "99:99")) 
					EndIf 
					//Verificando se foi selecionando a localidade
					If oModelG5I:GetValue('G5I_CHECK')
						//Adicionando valores no Array sequencia + Local Origem + Local Destino + Horario Destino +Horario Origem + Dia decorrido
						aAdd(aTrecho,{STRZERO(cItem,4),cLocOri,cLocDes,cTmpTot,cHrOri,nDiaDec,GTFormatHour(nDelta, "9999")})
						cHrOri	:= cTmpTot
						cItem++
						cHrAux	:=  GTFormatHour(cTmpTot,'99:99')
						nDelta	:= '0000'
						EXIT
					Else
						cHrAux	:=  GTFormatHour(cTmpTot,'99:99')
					EndIf
				EndIf
				nY--
			EndDo
		EndIf
		nI--
	EndDo
EndIf

oModelGIE:SetNoUpdateLine(.F.)
oModelGIE:SetNoInsertLine(.F.)// permite inclusao no grid
oModelGIE:SetNoDeleteLine(.F.)// permite inclusao no grid
//Carregadno o a grid GIE
//Verifica se e a primeira inserção na grid
If (Empty(oModelGIE:GetValue("GIE_SEQ",1)) )
	For nZ := 1 to LEN(aTrecho)
		If !(Empty(oModelGIE:GetValue("GIE_IDLOCP")) .AND. Empty(oModelGIE:GetValue("GIE_IDLOCD"))) .AND. ;
		!oModelGIE:SeekLine({{"GIE_IDLOCP",aTrecho[nZ][2]},{"GIE_IDLOCD",aTrecho[nZ][3]}})
			oModelGIE:addLine()
		Endif
		
		oModelGIE:SetValue('GIE_SEQ', aTrecho[nZ][1])
		oModelGIE:SetValue('GIE_IDLOCP', aTrecho[nZ][2])
		oModelGIE:SetValue('GIE_IDLOCD', aTrecho[nZ][3])
		oModelGIE:SetValue('GIE_HORDES', aTrecho[nZ][4])
		oModelGIE:SetValue('GIE_HORLOC', aTrecho[nZ][5])
		oModelGIE:SetValue('GIE_DIA', aTrecho[nZ][6])
		oModelGIE:SetValue('GIE_HORCAB', cHoraIni)
		oModelGIE:SetValue('GIE_TPTR', aTrecho[nZ][7])
		If nZ = LEN(aTrecho)
			oGID004:SetValue('GID_HORFIM', aTrecho[nZ][4])
		EndIF 
	Next nZ
Else 
	For nZ := 1 to oModelGIE:Length()
		//Verifica se a linha foi deletada
		If !oModelGIE:IsDeleted(nZ)
			//Remove os registro anterior
			oModelGIE:Goline(nZ)
			oModelGIE:DeleteLine()
		EndIf
	Next nZ
	nZ := 1
	//carrega a grid com novos trechos 
	For nZ := 1 to LEN(aTrecho)
		If !oModelGIE:SeekLine({{"GIE_IDLOCP",aTrecho[nZ][2]},{"GIE_IDLOCD",aTrecho[nZ][3]}})
			oModelGIE:addLine()
		Endif
		
		oModelGIE:SetValue('GIE_SEQ', aTrecho[nZ][1])
		oModelGIE:SetValue('GIE_IDLOCP', aTrecho[nZ][2])
		oModelGIE:SetValue('GIE_IDLOCD', aTrecho[nZ][3])
		oModelGIE:SetValue('GIE_HORDES', aTrecho[nZ][4])
		oModelGIE:SetValue('GIE_HORLOC', aTrecho[nZ][5])
		oModelGIE:SetValue('GIE_DIA', aTrecho[nZ][6])
		oModelGIE:SetValue('GIE_HORCAB', cHoraIni)
		oModelGIE:SetValue('GIE_TPTR', aTrecho[nZ][7])
		If nZ = LEN(aTrecho)
			oGID004:SetValue('GID_HORFIM', aTrecho[nZ][4])
		EndIF 
	Next nZ
EndIf

oModelGIE:SetNoInsertLine(.T.)// permite inclusao no grid
oModelGIE:SetNoDeleteLine(.T.)// permite inclusao no grid
oModelGIE:Goline(1)
Return (lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP4PVld()
Verifica se foi selecionando ao menos 2 localidade para geração do trecho
@sample	GTP4PVld()
@author	Inovação
@since		24/04/2017
@version	P12
/*/
//-----------------------------------------------------------------------------------------

Static Function GTP4PVld(oModel)
Local lRet		:= .T.
Local oMdlG5I	:= 	oModel:GetModel('G5IDETAIL')
Local nI		:= 0
Local nCont	:= 0

//Verifica quantas localdiade foi selecionada
For nI:= 1 to oMdlG5I:Length()
	If (oMdlG5I:GetValue('G5I_CHECK',nI) == .T.)
		nCont++
	EndIf
Next nI
//Verifica se foi seleciona mais de 1 localidade
If nCont < 2 
	lRet	:= .F.
	Help( ,, 'Help',"GTP4PVld", STR0005, 1, 0 )//Selecione no mínimo 2 localidade para geração dos trechos!
ElseIf !(oMdlG5I:GetValue('G5I_CHECK',1) == .T. .And. oMdlG5I:GetValue('G5I_CHECK',oMdlG5I:Length())  == .T.)
	lRet	:= .F.
	Help( ,, 'Help',"GTP4PVld", STR0006, 1, 0 )//"Localidade Inicio e Localidade Final são obrigatório"
EndIf
Return (lRet)
//------------------------------------------------------------------------------
/*/{Protheus.doc} GA004SetModel

@type function
@author jacomo.fernandes
@since 06/06/2019
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GA004SetModel(oModel)
oMdlG004	:= oModel
Return
