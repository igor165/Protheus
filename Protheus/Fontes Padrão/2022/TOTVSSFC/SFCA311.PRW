#INCLUDE "SFCA311.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

#DEFINE PULALINHA CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA311
Tela de cadastro de Apontamento de Parada
@author Samantha Preima
@since 16/09/2010                                                       
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA311(xRotAuto, nAcao)
Local   oBrowse
Local lRet := .T.

SFCValInt() // Verifica integração ligada

if xRotAuto == nil
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'CYX' )
	oBrowse:SetDescription( STR0001 ) // 'Apontamento de Parada'
	oBrowse:Activate()
Else
	lHlpDark := HelpInDark(.T.)

	// nAcao -> 3=Inclusão, 4=Estorno
	aRotina := MenuDef()	
	lRet := FWMVCRotAuto(FwLoadModel('SFCA311'),"CYX",nAcao,{{"CYXMASTER",xRotAuto}})
	HelpInDark(lHlpDark)
Endif
Return lRet 

//-------------------------------------------------------------------
// Menu de Apontamento de Parada
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0015 ACTION 'VIEWDEF.SFCA311' OPERATION 3 ACCESS 0     // 'Incluir'
ADD OPTION aRotina TITLE STR0016 ACTION 'VIEWDEF.SFCA311' OPERATION 4 ACCESS 0     // 'Alterar'
ADD OPTION aRotina TITLE STR0017 ACTION 'VIEWDEF.SFCA311' OPERATION 5 ACCESS 0     // 'Eliminar'
ADD OPTION aRotina TITLE STR0018 ACTION 'VIEWDEF.SFCA311' OPERATION 2 ACCESS 0     // 'Visualizar'

Return aRotina  

//-------------------------------------------------------------------
// SFCA311PER
//-------------------------------------------------------------------
Function SFCA311PER()
	If IsInCallStack("SFCA316") .Or. IsInCallStack("SFCA310")
		SFCA310F12()
	EndIf
Return .T.

//-------------------------------------------------------------------
// Model de Apontamento de Parada
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCYX := FWFormStruct( 1, 'CYX', /*bAvalCampo*/,/*lViewUsado*/ ) // Apontamento de Parada
Local oStruCZ6 := FWFormStruct( 1, 'CZ6', /*bAvalCampo*/,/*lViewUsado*/ ) // Reporte Parada MOD
Local oModel         

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'SFCA311', /*{ | oModel | SFCA311PRE ( oModel ) }*/ , { | oMdlG | SFCA311POS ( oMdlG ) },{ | oMdl | SFCA311CMM ( oMdl ), SFCA311PER() } , {|| SFCA311PER() } ) 

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYXMASTER', /*cOwner*/, oStruCYX, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )       
         
// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CZ6DETAIL', 'CYXMASTER', oStruCZ6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 

// Define a chave primaria utilizada pelo modelo
oModel:SetPrimaryKey({"CYX_FILIAL","CYX_CDMQ","CYX_DTBGSP","CYX_HRBGSP"})     

// Faz relaciomaneto entre os compomentes do model -- 
//oModel:SetRelation( 'CZ6DETAIL', { { 'CZ6_FILIAL', 'xFilial( "CZ6" )' }, { 'CZ6_DTBGSP', 'CYX_DTBGSP' }, { 'CZ6_HRBGSP', 'CYX_HRBGSP' } }, CZ6->(IndexKey(1)) )
oModel:SetRelation( 'CZ6DETAIL', { { 'CZ6_FILIAL', 'xFilial( "CZ6" )' },  { 'CZ6_CDMQ', 'CYX_CDMQ' },{ 'CZ6_DTBGSP', 'CYX_DTBGSP' }, { 'CZ6_HRBGSP', 'CYX_HRBGSP' } }, CZ6->(IndexKey(3)) )

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'CZ6DETAIL' ):SetOptional(.T.)    
                                                           
// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 )    //'Apontamento de Parada'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYXMASTER' ):SetDescription( STR0001 )  //'Apontamento de Parada'

// Valida se a data e hora final foram informados
oModel:SetVldActivate( { |oModel| SFCA311VLD( oModel ) } ) 
oModel:SetActivate( { |oModel| SFCA311PRE( oModel ) } )  

Return oModel
//-------------------------------------------------------------------
// View de Apontamento de Parada
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCYX := FWFormStruct( 2, 'CYX' ) // Pai - Apontamento de Parada
Local oStruCZ6 := FWFormStruct( 2, 'CZ6' ) // Filho - Reporte Parada MOD
Local oModel   := FWLoadModel( 'SFCA311' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )    

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYX', oStruCYX, 'CYXMASTER' )

// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CZ6', oStruCZ6, 'CZ6DETAIL' ) 

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYX', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CZ6', 'INFERIOR' )

// Remove o campo repetido em tela
oStruCZ6:RemoveField("CZ6_CDMQ")
oStruCZ6:RemoveField("CZ6_QTTEUT")
oStruCZ6:RemoveField("CZ6_QTTEEX")

// Bloqueia o grid inferior
oStruCZ6:SetProperty( '*' , MVC_VIEW_CANCHANGE, .F.)

If GetMv("MV_SFCTPRE") == '2'
	oStruCYX:RemoveField('CYX_HRBGSP')
	oStruCYX:RemoveField('CYX_HREDSP')
	oStruCYX:RemoveField('CYX_HRRP')
	oStruCZ6:RemoveField('CZ6_HRBGSP')
	oStruCZ6:RemoveField('CZ6_HREDSP')
Else
	oStruCYX:RemoveField('CYX_HCBGSP')	
	oStruCYX:RemoveField('CYX_HCEDSP')	
	oStruCYX:RemoveField('CYX_HCRP')	
	oStruCZ6:RemoveField('CZ6_HCBGSP')
	oStruCZ6:RemoveField('CZ6_HCEDSP')
EndIf

// Para nao reabrir a tela, após salvar registro
oView:SetCloseOnOk({||.T.})  

Return oView  
//-------------------------------------------------------------------
// - Validações ao editar registro
// Input: Model
// Retorno: Se a tela pode ser aberta
//-------------------------------------------------------------------
Static Function SFCA311PRE( oModel ) 
Local nOpc     := oModel:GetOperation()
Local aArea    := GetArea()
Local aAreaCYB := CYB->(GetArea())

If nOpc == 4 .And. VAL(oModel:GetValue('CYXMASTER','CYX_NRORMN')) == 0  
	If !Empty(oModel:GetValue('CYXMASTER','CYX_NRSS')) .And. SuperGetMV('MV_NGMNSFC', .F., 1 ) != 1 
		dbSelectArea('TQB')
		oModel:SetValue('CYXMASTER','CYX_NRORMN', POSICIONE('TQB',1,xFilial('TQB')+AllTrim(oModel:GetValue('CYXMASTER','CYX_NRSS')),'TQB_ORDEM') )
  	EndIf
EndIf

if nOpc == 3 .AND. IsInCallStack('SFCA310')
	IF _MaqSFC310 != nil
		oModel:SetValue('CYXMASTER','CYX_CDMQ', _MaqSFC310)
	Endif
Endif

RestArea(aArea)
RestArea(aAreaCYB)

Return .T.

//-------------------------------------------------------------------
//Divide apontamento de produção conforme paradas
//-------------------------------------------------------------------
Function SFCA311DAP(cAptProd,dDTBGSP,dDTEDSP,cHRBGSP,cHREDSP,oMdlOrigem)
	Local oMdlDest1 //Model com apontamento destino 1
	Local oMdlDest2 //Model com apontamento destino 1
	Local oMdlMOB1, oMdlMOB2
	Local oMdlCYWOrigem
	Local oMdlCZ6Origem
	Local oMdlCY0Origem
	Local nI, nSeqRpOri, iCont
	Local nQtdSegundos, nQSegundos
	Local tmpOperac1, tmpOperac2
	Local nQtd       := 0
	Local nQtdRp1    := 0
	Local nQtdRp2    := 0
	Local cQtRpt     := 0
	Local nQtRefugo  := 0
	Local nDifQtd    := 0
	Local nDifQtd2   := 0 
	Local lRet       := .T.
	Local lCommit1   := .F.
	Local lCommit2   := .F.
	Local lGGFEdit   := .F.
	Local lQbrRefRet := .F.
	Local aComponentes	:= {}
	Local aGGF			:= {}
	Local aMOB			:= {}
	Local aRefRet		:= {}
	Local nTempo
	Local dDataAnt
	Local dDataRdy
	Local cHoraRdy
	Local aAreaCYV  := CYV->( GetArea() )
	Local aAreaCYY  := CYY->( GetArea() )
	Local aOAreCY0
	Local aOAreCZW
	Local aOAreCZ0
	Local aOAreCZP
	Local aOAreCYW
	Local lGGF1InsLn := .F.
	Local lGGF1UpdLn := .F.
	Local lGGF1DelLn := .F.
	Local lGGF2InsLn := .F.
	Local lGGF2UpdLn := .F.
	Local lGGF2DelLn := .F.
	Local aCY0 := {}
	Local aCZW := {}
	Local aCZ0 := {}
	Local aCZP := {}
	Local aCYW := {}
	Local dDtIni := ""
	Local dDtFim := ""
	Local cHrIni := ""
	Local cHrFim := ""

	Private lSpltEnc := .F.
	Default oMdlOrigem := "" //Model com apontamento origem

	//cAptProd - Apontamento a ser dividido

	dbSelectArea("CYV")
	CYV->(dbSetOrder(1))
	CYV->(dbSeek(xFilial("CYV")+cAptProd))

	dbSelectArea("CYY")
	CYY->(dbSetOrder(1))
	CYY->( dbSeek(xFilial("CYY") + CYV->(CYV_NRORPO+CYV_IDAT+CYV_IDATQO) ))

	If CYY->CYY_TPSTAT == "5"
		lSpltEnc := .T.
	EndIf

	CYV->(RestArea(aAreaCYV))
	
	If ValType(oMdlOrigem) == "C"
		oMdlOrigem := FWLoadModel("SFCA314")
		oMdlOrigem:SetOperation(4)//Alteracao    
		
		dbSelectArea("CYV")
		CYV->(dbSetOrder(1))
		CYV->(dbSeek(xFilial("CYV")+cAptProd))

		oMdlOrigem:Activate()  
		
		oMdlDest1:= FwLoadModel( 'SFCA314' )
		oMdlDest2:= FwLoadModel( 'SFCA314' ) 

	Else
		oMdlDest1:= FwLoadModel(oMdlOrigem:cId)
		oMdlDest2:= FwLoadModel(oMdlOrigem:cId)
	EndIf  

	oMdlDest1:SetOperation(3)//Inclusao
	If !oMdlDest1:Activate()
		lRet := .F.
	EndIf

	If lRet

		oMdlDest2:SetOperation(3)//Inclusao
		If !oMdlDest2:Activate()
			oMdlDest2:DeActivate()
			lRet := .F.
		EndIf
	EndIf

	CYY->(RestArea(aAreaCYY))

	If lRet
		
		//Salva os códigos de sequencia numa variavel temporaria
		nNRSQRP1 := oMdlDest1:GetValue("CYVMASTER","CYV_NRSQRP")
		nNRSQRP2 := oMdlDest2:GetValue("CYVMASTER","CYV_NRSQRP")

		//Copia todas informações do model origem para Dest1
		oMdlDest1:aModelStruct[1][3]:aDataModel := aClone(oMdlOrigem:aModelStruct[1][3]:aDataModel)
		
		For nI := 1 To Len(oMdlOrigem:aModelStruct[1][4])
			oMdlDest1:aModelStruct[1][4][nI][3]:aDataModel := aClone(oMdlOrigem:aModelStruct[1][4][nI][3]:aDataModel)
		Next

		//Copia todas informações do contida em aCols origem para Dest1
		For nI := 1 To Len(oMdlOrigem:aModelStruct[1][4])
			oMdlDest1:aModelStruct[1][4][nI][3]:aCols := aClone(oMdlOrigem:aModelStruct[1][4][nI][3]:aCols)
		Next

		//Copia todas informações do model origem para Dest2
		oMdlDest2:aModelStruct[1][3]:aDataModel := aClone(oMdlOrigem:aModelStruct[1][3]:aDataModel)
		
		For nI := 1 To Len(oMdlOrigem:aModelStruct[1][4])
			oMdlDest2:aModelStruct[1][4][nI][3]:aDataModel := aClone(oMdlOrigem:aModelStruct[1][4][nI][3]:aDataModel)
		Next

		//Copia todas informações do contida em aCols origem para Dest2
		For nI := 1 To Len(oMdlOrigem:aModelStruct[1][4])
			oMdlDest2:aModelStruct[1][4][nI][3]:aCols := aClone(oMdlOrigem:aModelStruct[1][4][nI][3]:aCols)
		Next

		oMdlDest1:GetModel("CYVMASTER"):LoadValue("GER_PARADA","")
		oMdlDest2:GetModel("CYVMASTER"):LoadValue("GER_PARADA","")
		
		//Volta os códigos de sequencia
		oMdlDest1:GetModel("CYVMASTER"):LoadValue("CYV_NRSQRP",nNRSQRP1)
		oMdlDest2:GetModel("CYVMASTER"):LoadValue("CYV_NRSQRP",nNRSQRP2)

		//Começo - Origem
		oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_DTRPBG",oMdlOrigem:GetValue("CYVMASTER","CYV_DTRPBG"))
		oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_HRRPBG",oMdlOrigem:GetValue("CYVMASTER","CYV_HRRPBG"))
		//Começo - Parada
		oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_DTRPED",dDTBGSP)
		oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_HRRPED",cHRBGSP)

		oMdlDest1:GetModel("CYVMASTER"):LoadValue("GER_PARANT","")
		oMdlDest2:GetModel("CYVMASTER"):LoadValue("GER_PARANT","")

		//Final - Parada
		oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_DTRPBG",dDTEDSP)
		oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_HRRPBG",cHREDSP)
		//Final - Origem
		oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_DTRPED",oMdlOrigem:GetValue("CYVMASTER","CYV_DTRPED"))
		oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_HRRPED",oMdlOrigem:GetValue("CYVMASTER","CYV_HRRPED"))

		tmpOperac1 := oMdlDest1:GetValue("CYVMASTER","CYV_HRTERP")
		tmpOperac2 := oMdlDest2:GetValue("CYVMASTER","CYV_HRTERP")

		nQtd := oMdlOrigem:GetValue("CYVMASTER","CYV_QTATRP")

		oMdlCZ6Origem := oMdlOrigem:GetModel("CZPDETAIL")
		oMdlCYWOrigem := oMdlOrigem:GetModel("CYWDETAIL")
		oMdlCZWOrigem := oMdlOrigem:GetModel("CZWDETAIL")
		oMdlCY0Origem := oMdlOrigem:GetModel("CY0DETAIL")

		nTempo := oMdlOrigem:GetValue("CYVMASTER","CYV_HRTERP")

		If oMdlCYWOrigem:GetQtdLine() != 1 .Or. ( !Empty(oMdlCYWOrigem:GetValue("CYW_CDOE")) .Or. !Empty(oMdlCYWOrigem:GetValue("CYW_CDGROE")) )
			//Armazena informações de MOB do ModelOrigem
			For iCont := 1 To oMdlCYWOrigem:GetQtdLine()

				oMdlCYWOrigem:GoLine(iCont)
				aAdd( aMOB, {;
					oMdlCYWOrigem:GetValue("CYW_DTBGRP"),;
					oMdlCYWOrigem:GetValue("CYW_HRBGRP"),;
					oMdlCYWOrigem:GetValue("CYW_DTEDRP"),;
					oMdlCYWOrigem:GetValue("CYW_HREDRP"),;
				})

			Next

		EndIf

		//Armazena informações de GGF do ModelOrigem
		For iCont := 1 To oMdlCZWOrigem:GetQtdLine()

			oMdlCZWOrigem:GoLine(iCont)
			aAdd( aGGF, oMdlCZWOrigem:GetValue("CZW_HRTEGF") )

			If aGGF[iCont] != nTempo
				lGGFEdit := .T.
			EndIf

		Next

		//Armazena informações de Refugo e Retrabalho do ModelOrigem
		For iCont := 1 To oMdlCY0Origem:GetQtdLine()

			oMdlCY0Origem:GoLine(iCont)
			aAdd( aRefRet, {oMdlCY0Origem:GetValue("CY0_QTRF"),oMdlCY0Origem:GetValue("CY0_QTRT")} )

			If aRefRet[iCont][1] > 0 .Or. aRefRet[iCont][2] > 0
				lQbrRefRet := .T.
			EndIf

		Next

		//Armazena informações de Componentes do ModelOrigem
		For iCont := 1 To oMdlCZ6Origem:GetQtdLine()

			oMdlCZ6Origem:GoLine(iCont)
			aAdd( aComponentes, oMdlCZ6Origem:GetValue("CZP_QTRPPO") )

		Next

		If tmpOperac1 > 0 .And. tmpOperac2 > 0

			If nQtd > 0
				//Quantidades
				nRdOri := nQtd/nTempo //Rendimento de produção por hora

				nAumProd := nTempo/(tmpOperac1+tmpOperac2) //Aumento do rendimento em porcentagem devido a divisão

				nQtdRp1 := Round(tmpOperac1*nRdOri*nAumProd,0)

				If nQtdRp1 == 0
					nQtdRp1 := 1
				EndIf

				nQtdRp2 := nQtd - nQtdRp1
				If nQtdRp2 == 0
					nQtdRp2 := nQtdRp1
					nQtdRp1 := 0
				EndIf
			Else
				nQtdRp1 := 0
				nQtdRp2 := 0
			EndIf

			oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_QTATRP", nQtdRp1)
			oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_QTATRP", nQtdRp2)

			//Começo - Origem
			oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_DTRPBG",oMdlOrigem:GetValue("CYVMASTER","CYV_DTRPBG"))
			oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_HRRPBG",oMdlOrigem:GetValue("CYVMASTER","CYV_HRRPBG"))
			//Começo - Parada
			oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_DTRPED",dDTBGSP)
			oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_HRRPED",cHRBGSP)

			//Final - Parada
			oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_DTRPBG",dDTEDSP)
			oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_HRRPBG",cHREDSP)
			//Final - Origem
			oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_DTRPED",oMdlOrigem:GetValue("CYVMASTER","CYV_DTRPED"))
			oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_HRRPED",oMdlOrigem:GetValue("CYVMASTER","CYV_HRRPED"))

			//Tratamento de Componentes
			If aComponentes[1] != 0

				oMdlComp1 := oMdlDest1:GetModel("CZPDETAIL")
				oMdlComp2 := oMdlDest2:GetModel("CZPDETAIL")

				For iCont := 1 To Len(aComponentes)

					nQtdRp1 := Round(tmpOperac1*aComponentes[iCont]/nTempo*nAumProd,0)

					If nQtdRp1 == 0
						nQtdRp1 := 1
					EndIf

					nQtdRp2 := aComponentes[iCont] - nQtdRp1
					If nQtdRp2 == 0
						nQtdRp2 := nQtdRp1
						nQtdRp1 := 0
					EndIf

					oMdlComp1:SetNoInsertLine(.F.)
					oMdlComp1:SetNoUpdateLine(.F.)

					oMdlComp2:SetNoInsertLine(.F.)
					oMdlComp2:SetNoUpdateLine(.F.)

					oMdlComp1:GoLine(iCont)
					oMdlComp1:SetValue("CZP_QTRPPO",nQtdRp1)

					oMdlComp2:GoLine(iCont)
					oMdlComp2:SetValue("CZP_QTRPPO",nQtdRp2)

					oMdlComp1:SetNoInsertLine(.T.)
					oMdlComp1:SetNoUpdateLine(.T.)

					oMdlComp2:SetNoInsertLine(.T.)
					oMdlComp2:SetNoUpdateLine(.T.)

				Next

			EndIf

			Pergunte('SFCA310A',.F.)

			//Tratamento MOB
			If Len(aMOB) > 0

				oMdlMOB1 := oMdlDest1:GetModel("CYWDETAIL")
				oMdlMOB2 := oMdlDest2:GetModel("CYWDETAIL")

				If MV_PAR02 == 1

					For iCont := 1 To Len(aMOB)

						oMdlMOB1:GoLine(iCont)

						oMdlMOB1:SetValue("CYW_DTBGRP",aMOB[iCont][1])
						oMdlMOB1:SetValue("CYW_HRBGRP",aMOB[iCont][2])

						oMdlMOB1:SetValue("CYW_DTEDRP",aMOB[iCont][3])
						oMdlMOB1:SetValue("CYW_HREDRP",aMOB[iCont][4])

						oMdlMOB2:GoLine(iCont)
						oMdlMOB2:DeleteLine() //Error: Se houver mais de uma linha o MVC apresenta erro

					Next

				ElseIf MV_PAR02 == 2

					//copiar isso [iCont]
					For iCont := 1 To Len(aMOB)

						oMdlMOB1:GoLine(iCont)

						lDtIniDent := ( ;
							aMOB[iCont][1] < dDTEDSP .Or. ( ;
								aMOB[iCont][1] == dDTEDSP .And. aMOB[iCont][2] <= cHREDSP ;
							) ;
						) .And. ( ;
							aMOB[iCont][1] > dDTBGSP .Or. ( ;
								aMOB[iCont][1] == dDTBGSP .And. aMOB[iCont][2] >= cHRBGSP ;
							) ;
						)

						lDtFimDent := ( ;
							aMOB[iCont][3] < dDTEDSP .Or. ( ;
								aMOB[iCont][3] == dDTEDSP .And. aMOB[iCont][4] <= cHREDSP ;
							) ;
						) .And. ( ;
							aMOB[iCont][3] > dDTBGSP .Or. ( ;
								aMOB[iCont][3] == dDTBGSP .And. aMOB[iCont][4] >= cHRBGSP ;
							) ;
						)

						If lDtFimDent .And. !lDtIniDent

							oMdlMOB2:DeleteLine()

							//INICIO - Calculo de quanto tempo foi removido em segundos
							dDataAnt := aMOB[iCont][3]

							If dDTBGSP < dDataAnt

								nQtdSegundos := SFCXHourToSeg(aMOB[iCont][4]) //Qtd Resto do dia
								dDataAnt := dDataAnt - 1

								While dDTBGSP < dDataAnt

									nQtdSegundos := nQtdSegundos + 86400 //Soma um dia em segundos
									dDataAnt := dDataAnt - 1

								End

								nQtdSegundos := nQtdSegundos + ( 86400 - SFCXHourToSeg(cHRBGSP) )

							Else

								nQtdSegundos := SFCXHourToSeg(aMOB[iCont][4]) - SFCXHourToSeg(cHRBGSP)

							EndIf
							//FIM - Calculo de quanto foi removido

							//INICIO - Calcula a data a ser colocada pra repor o tempo removido
							dDataRdy := aMOB[iCont][1]
							cHoraRdy := aMOB[iCont][2]

							While nQtdSegundos > 86400
								dDataRdy := dDataRdy - 1
								nQtdSegundos := nQtdSegundos - 86400
							End

							If (SFCXHourToSeg(aMOB[iCont][2]) - nQtdSegundos) < 0

								dDataRdy := dDataRdy - 1
								nQtdSegundos := nQtdSegundos - SFCXHourToSeg(aMOB[iCont][2])
								cHoraRdy := SFCXSegtoHour( 86400 - nQtdSegundos )

							Else
								cHoraRdy := SFCXSegtoHour( SFCXHourToSeg(aMOB[iCont][2]) - nQtdSegundos )
							EndIf
							//FIM - Calcula a data a ser colocada pra repor o tempo removido

							oMdlMOB1:SetValue("CYW_DTBGRP",dDataRdy)
							oMdlMOB1:SetValue("CYW_HRBGRP",cHoraRdy)

							oMdlMOB1:SetValue("CYW_DTEDRP",dDTBGSP)
							oMdlMOB1:SetValue("CYW_HREDRP",cHRBGSP)

						ElseIf lDtIniDent .And. !lDtFimDent

							oMdlMOB1:DeleteLine()

							nQtdSegundos := 0

							//INICIO - Calculo de quanto tempo foi removido em segundos
							dDataAnt := aMOB[iCont][1]

							If dDTEDSP > dDataAnt

								nQtdSegundos := 86400 - SFCXHourToSeg(aMOB[iCont][2]) //Qtd Resto do dia
								dDataAnt := dDataAnt + 1

								While dDTEDSP > dDataAnt

									nQtdSegundos := nQtdSegundos + 86400 //Soma um dia em segundos
									dDataAnt := dDataAnt + 1

								End

								nQtdSegundos := nQtdSegundos + SFCXHourToSeg(cHREDSP)

							Else

								nQtdSegundos := SFCXHourToSeg(cHREDSP) - SFCXHourToSeg(aMOB[iCont][2])

							EndIf
							//FIM - Calculo de quanto foi removido

							//INICIO - Calcula a data a ser colocada pra repor o tempo removido
							dDataRdy := aMOB[iCont][3]
							cHoraRdy := aMOB[iCont][4]

							While nQtdSegundos > 86400
								dDataRdy := dDataRdy + 1
								nQtdSegundos := nQtdSegundos - 86400
							End

							If (SFCXHourToSeg(aMOB[iCont][4]) + nQtdSegundos) > 86400

								dDataRdy := dDataRdy + 1
								nQtdSegundos := nQtdSegundos - (86400 - SFCXHourToSeg(aMOB[iCont][4]))
								cHoraRdy := SFCXSegtoHour( nQtdSegundos )

							Else
								cHoraRdy := SFCXSegtoHour( SFCXHourToSeg(aMOB[iCont][4]) + nQtdSegundos )	
							EndIf
							//FIM - Calcula a data a ser colocada pra repor o tempo removido

							oMdlMOB2:SetValue("CYW_DTBGRP",dDTEDSP)
							oMdlMOB2:SetValue("CYW_HRBGRP",cHREDSP)

							oMdlMOB2:SetValue("CYW_DTEDRP",dDataRdy)
							oMdlMOB2:SetValue("CYW_HREDRP",cHoraRdy)

						Else

							//INICIO - Calculo de quanto tempo foi removido em segundos
							dDataAnt := dDTBGSP

							If dDTEDSP > dDataAnt

								nQtdSegundos := 86400 - SFCXHourToSeg(cHRBGSP) //Qtd Resto do dia
								dDataAnt := dDataAnt + 1

								While dDTEDSP > dDataAnt

									nQtdSegundos := nQtdSegundos + 86400 //Soma um dia em segundos
									dDataAnt := dDataAnt + 1

								End

								nQtdSegundos := nQtdSegundos + SFCXHourToSeg(cHREDSP)

							Else

								nQtdSegundos := SFCXHourToSeg(cHREDSP) - SFCXHourToSeg(cHRBGSP)

							EndIf

							nQtdSegundos := nQtdSegundos/2 //Divide a quantidade de segundos para os dois apontamentos
							nQSegundos := nQtdSegundos //Cria um backup do valor

							//FIM - Calculo de quanto foi removido

							//INICIO - Calcula a data a ser colocada pra repor o tempo removido
							dDataRdy := aMOB[iCont][1]
							cHoraRdy := aMOB[iCont][2]

							While nQtdSegundos > 86400
								dDataRdy := dDataRdy - 1
								nQtdSegundos := nQtdSegundos - 86400
							End

							If (SFCXHourToSeg(aMOB[iCont][2]) - nQtdSegundos) < 0

								dDataRdy := dDataRdy - 1
								nQtdSegundos := nQtdSegundos - SFCXHourToSeg(aMOB[iCont][2])
								cHoraRdy := SFCXSegtoHour( 86400 - nQtdSegundos )

							Else
								cHoraRdy := SFCXSegtoHour( SFCXHourToSeg(aMOB[iCont][2]) - nQtdSegundos )
							EndIf
							//FIM - Calcula a data a ser colocada pra repor o tempo removido

							oMdlMOB1:SetValue("CYW_DTBGRP",dDataRdy)
							oMdlMOB1:SetValue("CYW_HRBGRP",cHoraRdy)

							oMdlMOB1:SetValue("CYW_DTEDRP",dDTBGSP)
							oMdlMOB1:SetValue("CYW_HREDRP",cHRBGSP)

							nQtdSegundos := nQSegundos //Repõe a quantidade de segundos para o segundo apontamento

							//INICIO - Calcula a data a ser colocada pra repor o tempo removido
							dDataRdy := aMOB[iCont][3]
							cHoraRdy := aMOB[iCont][4]

							While nQtdSegundos > 86400
								dDataRdy := dDataRdy + 1
								nQtdSegundos := nQtdSegundos - 86400
							End

							If (SFCXHourToSeg(aMOB[iCont][4]) + nQtdSegundos) > 86400

								dDataRdy := dDataRdy + 1
								nQtdSegundos := nQtdSegundos - (86400 - SFCXHourToSeg(aMOB[iCont][4]))
								cHoraRdy := SFCXSegtoHour( nQtdSegundos )

							Else
								cHoraRdy := SFCXSegtoHour( SFCXHourToSeg(aMOB[iCont][4]) + nQtdSegundos )	
							EndIf
							//FIM - Calcula a data a ser colocada pra repor o tempo removido

							oMdlMOB2:SetValue("CYW_DTBGRP",dDTEDSP)
							oMdlMOB2:SetValue("CYW_HRBGRP",cHREDSP)

							oMdlMOB2:SetValue("CYW_DTEDRP",dDataRdy)
							oMdlMOB2:SetValue("CYW_HREDRP",cHoraRdy)

					   	EndIf

					Next

				Else

					For iCont := 1 To Len(aMOB)

						oMdlMOB1:GoLine(iCont)

						lDtIniDent := ( ;
							aMOB[iCont][1] < dDTEDSP .Or. ( ;
								aMOB[iCont][1] == dDTEDSP .And. aMOB[iCont][2] <= cHREDSP ;
							) ;
						) .And. ( ;
							aMOB[iCont][1] > dDTBGSP .Or. ( ;
								aMOB[iCont][1] == dDTBGSP .And. aMOB[iCont][2] >= cHRBGSP ;
							) ;
						)

						lDtFimDent := ( ;
							aMOB[iCont][3] < dDTEDSP .Or. ( ;
								aMOB[iCont][3] == dDTEDSP .And. aMOB[iCont][4] <= cHREDSP ;
							) ;
						) .And. ( ;
							aMOB[iCont][3] > dDTBGSP .Or. ( ;
								aMOB[iCont][3] == dDTBGSP .And. aMOB[iCont][4] >= cHRBGSP ;
							) ;
						)

						If lDtIniDent .And. lDtFimDent

							oMdlMOB1:DeleteLine()
							oMdlMOB2:DeleteLine()

						ElseIf lDtIniDent

							oMdlMOB1:DeleteLine()

							oMdlMOB2:SetValue("CYW_DTBGRP",dDTEDSP)
							oMdlMOB2:SetValue("CYW_HRBGRP",cHREDSP)

						ElseIf lDtFimDent

							oMdlMOB2:DeleteLine()

							oMdlMOB1:SetValue("CYW_DTEDRP",dDTBGSP)
							oMdlMOB1:SetValue("CYW_HREDRP",cHRBGSP)

						Else

							lIniMenor := aMOB[iCont][1] > dDTEDSP .Or. ( aMOB[iCont][1] == dDTEDSP .And. aMOB[iCont][2] > cHREDSP )
							lFimMenor := aMOB[iCont][3] > dDTEDSP .Or. ( aMOB[iCont][3] == dDTEDSP .And. aMOB[iCont][4] > cHREDSP )

							If lIniMenor .And. lFimMenor
								oMdlMOB2:DeleteLine()
							ElseIf !lIniMenor .And. !lFimMenor
								oMdlMOB1:DeleteLine()
							Else

								oMdlMOB1:SetValue("CYW_DTEDRP",dDTBGSP)
								oMdlMOB1:SetValue("CYW_HREDRP",cHRBGSP)

								oMdlMOB2:SetValue("CYW_DTBGRP",dDTEDSP)
								oMdlMOB2:SetValue("CYW_HRBGRP",cHREDSP)

								//Ajusta os tempos de MOB
								oMdlMOB1:SetValue("CYW_HRBGRP",aMOB[iCont,2])
								oMdlMOB1:SetValue("CYW_DTBGRP",aMOB[iCont,1])
								oMdlMOB2:SetValue("CYW_HREDRP",aMOB[iCont,4])
								oMdlMOB2:SetValue("CYW_DTEDRP",aMOB[iCont,3])

							EndIf

						EndIf

					Next

				EndIf

			EndIf

			//Tratamento GGF
			If aGGF[1] != 0
				oMdlGGF1 := oMdlDest1:GetModel("CZWDETAIL")
				oMdlGGF2 := oMdlDest2:GetModel("CZWDETAIL")
					
				lGGF1InsLn := oMdlGGF1:CanInsertLine()
				lGGF1UpdLn := oMdlGGF1:CanUpdateLine()
				lGGF1DelLn := oMdlGGF1:CanDeleteLine()
				lGGF2InsLn := oMdlGGF2:CanInsertLine()
				lGGF2UpdLn := oMdlGGF2:CanUpdateLine()
				lGGF2DelLn := oMdlGGF2:CanDeleteLine()
				
				oMdlGGF1:SetNoInsertLine(.F.)
				oMdlGGF1:SetNoDeleteLine(.F.)
				oMdlGGF1:SetNoUpdateLine(.F.)
				oMdlGGF2:SetNoInsertLine(.F.)
				oMdlGGF2:SetNoDeleteLine(.F.)
				oMdlGGF2:SetNoUpdateLine(.F.)

				If MV_PAR03 == 1

					//oMdlGGF1 := oMdlDest1:GetModel("CZWDETAIL")
					//oMdlGGF2 := oMdlDest2:GetModel("CZWDETAIL")

					For iCont := 1 To Len(aGGF)

						oMdlGGF1:GoLine(iCont)
						oMdlGGF1:SetValue("CZW_HRTEGF",aGGF[iCont])

						oMdlGGF2:GoLine(iCont)
						oMdlGGF2:DeleteLine()

					Next

				ElseIf lGGFEdit .Or. MV_PAR03 == 2

					//oMdlGGF1 := oMdlDest1:GetModel("CZWDETAIL")
					//oMdlGGF2 := oMdlDest2:GetModel("CZWDETAIL")

					For iCont := 1 To Len(aGGF)

						nQtdRp1 := Round(tmpOperac1*aGGF[iCont]/nTempo*nAumProd,TamSX3("CZW_HRTEGF")[2])

						If nQtdRp1 > aGGF[iCont]
							nQtdRp1 := aGGF[iCont]
						EndIf

						If nQtdRp1 == 0
							nQtdRp1 := 1
						EndIf

						nQtdRp2 := aGGF[iCont] - nQtdRp1
						If nQtdRp2 == 0
							nQtdRp2 := nQtdRp1
							nQtdRp1 := 0
						EndIf

						oMdlGGF1:GoLine(iCont) 
						If nQtdRp1 == 0
							oMdlGGF1:DeleteLine()
						Else
							oMdlGGF1:SetValue("CZW_HRTEGF",nQtdRp1)
						EndIf

						oMdlGGF2:GoLine(iCont) 
						If nQtdRp2 == 0
							oMdlGGF2:DeleteLine()
						Else
							oMdlGGF2:SetValue("CZW_HRTEGF",nQtdRp2)
						EndIf

					Next

				Else

					//oMdlGGF1 := oMdlDest1:GetModel("CZWDETAIL")
					//oMdlGGF2 := oMdlDest2:GetModel("CZWDETAIL")

					nQtdRp1 := oMdlDest1:GetValue("CYVMASTER","CYV_HRTERP")
					nQtdRp2 := oMdlDest2:GetValue("CYVMASTER","CYV_HRTERP")

					For iCont := 1 To Len(aGGF)

						oMdlGGF1:GoLine(iCont)
						oMdlGGF1:SetValue("CZW_HRTEGF",nQtdRp1)

						oMdlGGF2:GoLine(iCont)
						oMdlGGF2:SetValue("CZW_HRTEGF",nQtdRp2) 
					Next

				EndIf
				oMdlGGF1:SetNoInsertLine(lGGF1InsLn)
				oMdlGGF1:SetNoDeleteLine(lGGF1DelLn)
				oMdlGGF1:SetNoUpdateLine(lGGF1UpdLn)
				oMdlGGF2:SetNoInsertLine(lGGF2InsLn)
				oMdlGGF2:SetNoDeleteLine(lGGF2DelLn)
				oMdlGGF2:SetNoUpdateLine(lGGF2UpdLn)
			EndIf

			//Tratamento Refugo/Retrabalho
			If lQbrRefRet

				If MV_PAR04 == 1

					oMdlRfRet1 := oMdlDest1:GetModel("CY0DETAIL")
					oMdlRfRet2 := oMdlDest2:GetModel("CY0DETAIL")

					For iCont := 1 To Len(aRefRet)
						//Refugo    
						If aRefRet[iCont][1] > 0
							nQtdRp1 := Round(tmpOperac1*aRefRet[iCont][1]/nTempo*nAumProd,0)

							If nQtdRp1 == 0
								nQtdRp1 := 1
							EndIf

							nQtdRp2 := aRefRet[iCont][1] - nQtdRp1

							oMdlRfRet1:GoLine(iCont)
							If nQtdRp1 == 0
								If oMdlRfRet1:GetValue("CY0_QTRT") == 0
									oMdlRfRet1:DeleteLine()
								EndIf
							Else
								oMdlRfRet1:SetValue("CY0_QTRF",nQtdRp1)
							EndIf

							oMdlRfRet2:GoLine(iCont)
							If nQtdRp2 == 0
								If oMdlRfRet2:GetValue("CY0_QTRT") == 0
									oMdlRfRet2:DeleteLine()
								EndIf
							Else
								oMdlRfRet2:SetValue("CY0_QTRF",nQtdRp2)
							EndIf
						EndIf

						//Retrabalho 
						If aRefRet[iCont][2] > 0
							nQtdRp1 := Round(tmpOperac1*aRefRet[iCont][2]/nTempo*nAumProd,0)

							If nQtdRp1 == 0
								nQtdRp1 := 1
							EndIf

							nQtdRp2 := aRefRet[iCont][2] - nQtdRp1

							oMdlRfRet1:GoLine(iCont)
							If nQtdRp1 == 0
								If oMdlRfRet1:GetValue("CY0_QTRF") == 0
									oMdlRfRet1:DeleteLine()
								EndIf
							Else
								oMdlRfRet1:SetValue("CY0_QTRT",nQtdRp1)
							EndIf

							oMdlRfRet2:GoLine(iCont)
							If nQtdRp2 == 0
								If oMdlRfRet2:GetValue("CY0_QTRF") == 0
									oMdlRfRet2:DeleteLine()
								EndIf
							Else
								oMdlRfRet2:SetValue("CY0_QTRT",nQtdRp2)
							EndIf
						EndIf

					Next

				ElseIf MV_PAR04 == 2

					oMdlRfRet2 := oMdlDest2:GetModel("CY0DETAIL")

					For iCont := 1 To Len(aRefRet)

						oMdlRfRet2:GoLine(iCont)
						oMdlRfRet2:DeleteLine()

					Next
					
					oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_QTATRF",0)
					oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_QTATAP",oMdlDest2:GetModel("CYVMASTER"):GetValue("CYV_QTATRP"))
					
					If oMdlDest1:GetValue("CYVMASTER","CYV_QTATRP") < oMdlDest1:GetValue("CYVMASTER","CYV_QTATRF")
						nDifQtd := oMdlDest1:GetValue("CYVMASTER","CYV_QTATRF") - oMdlDest1:GetValue("CYVMASTER","CYV_QTATRP")
						dDtIni := oMdlDest1:GetValue("CYVMASTER","CYV_DTRPBG")
						dDtFim := oMdlDest1:GetValue("CYVMASTER","CYV_DTRPED")
						cHrIni := oMdlDest1:GetValue("CYVMASTER","CYV_HRRPBG")
						cHrFim := oMdlDest1:GetValue("CYVMASTER","CYV_HRRPED")
						oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_QTATRP", oMdlDest1:GetValue("CYVMASTER","CYV_QTATRP") + nDifQtd)
						oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_DTRPBG", dDtIni)
						oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_HRRPBG", cHrIni)
						oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_DTRPED", dDtFim)
						oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_HRRPED", cHrFim)
						
						dDtIni := oMdlDest2:GetValue("CYVMASTER","CYV_DTRPBG")
						dDtFim := oMdlDest2:GetValue("CYVMASTER","CYV_DTRPED")
						cHrIni := oMdlDest2:GetValue("CYVMASTER","CYV_HRRPBG")
						cHrFim := oMdlDest2:GetValue("CYVMASTER","CYV_HRRPED")
						oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_QTATRP", oMdlDest2:GetValue("CYVMASTER","CYV_QTATRP") - nDifQtd)
						oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_DTRPBG", dDtIni)
						oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_HRRPBG", cHrIni)
						oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_DTRPED", dDtFim)
						oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_HRRPED", cHrFim)
					EndIf

				Else

					oMdlRfRet1 := oMdlDest1:GetModel("CY0DETAIL")
					cQtRpt := oMdlDest1:GetValue("CYVMASTER","CYV_QTATAP")
					nDifQtd := oMdlDest1:GetValue("CYVMASTER","CYV_QTATRP") - oMdlDest1:GetValue("CYVMASTER","CYV_QTATRF")
					nDifQtd2 := oMdlDest2:GetValue("CYVMASTER","CYV_QTATRP") - oMdlDest2:GetValue("CYVMASTER","CYV_QTATRF")
					nQtRefugo := 0
					For iCont := 1 To Len(aRefRet)

						oMdlRfRet1:GoLine(iCont)
						nQtRefugo += oMdlRfRet1:GetValue("CY0_QTRF")
						oMdlRfRet1:DeleteLine()

					Next
					oMdlDest1:GetModel("CYVMASTER"):LoadValue("CYV_QTATAP", Iif(nDifQtd < 0, nDifQtd*-1,cQtRpt+nQtRefugo))
					oMdlDest1:GetModel("CYVMASTER"):LoadValue("CYV_QTATRP", Iif(nDifQtd < 0, nDifQtd*-1,cQtRpt+nQtRefugo))
					oMdlDest1:GetModel("CYVMASTER"):LoadValue("CYV_QTATRF", 0)
					If oMdlDest2:GetValue("CYVMASTER","CYV_QTATRF") > 0
						If nDifQtd2 < 0
							oMdlDest2:GetModel("CYVMASTER"):LoadValue("CYV_QTATAP", nDifQtd2*-1)
							oMdlDest2:GetModel("CYVMASTER"):LoadValue("CYV_QTATRP", oMdlDest2:GetValue("CYVMASTER","CYV_QTATRF") + oMdlDest2:GetValue("CYVMASTER","CYV_QTATAP"))
						Else
							//oMdlDest2:GetModel("CYVMASTER"):LoadValue("CYV_QTATRP", nQtRefugo + oMdlDest2:GetValue("CYVMASTER","CYV_QTATRP"))
							oMdlDest2:GetModel("CYVMASTER"):LoadValue("CYV_QTATAP", oMdlDest2:GetValue("CYVMASTER","CYV_QTATRP") - oMdlDest2:GetValue("CYVMASTER","CYV_QTATRF"))
						EndIf
					EndIf
				EndIf

			EndIf

			lCommit1 := .T.
			lCommit2 := .T.

		ElseIf tmpOperac1 == 0

			oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_QTATRP", nQtd)

			//Final - Parada
			oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_DTRPBG",dDTEDSP)
			oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_HRRPBG",cHREDSP)
			//Final - Origem
			oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_DTRPED",oMdlOrigem:GetValue("CYVMASTER","CYV_DTRPED"))
			oMdlDest2:GetModel("CYVMASTER"):SetValue("CYV_HRRPED",oMdlOrigem:GetValue("CYVMASTER","CYV_HRRPED"))

			lCommit2 := .T.

		ElseIf tmpOperac2 == 0

			oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_QTATRP", nQtd)

			//Começo - Origem
			oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_DTRPBG",oMdlOrigem:GetValue("CYVMASTER","CYV_DTRPBG"))
			oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_HRRPBG",oMdlOrigem:GetValue("CYVMASTER","CYV_HRRPBG"))
			//Começo - Parada
			oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_DTRPED",dDTBGSP)
			oMdlDest1:GetModel("CYVMASTER"):SetValue("CYV_HRRPED",cHRBGSP)

			lCommit1 := .T.

		EndIf

		nSeqRpOri := oMdlOrigem:GetValue("CYVMASTER","CYV_NRSQRP")

		//oMdlOrigem:DeActivate()

		aCY0 := {}
		aCZW := {}
		aCZ0 := {}
		aCZP := {}
		aCYW := {}
		
		aOAreCY0  := CY0->( GetArea() )
		aOAreCZW  := CZW->( GetArea() )
		aOAreCZ0  := CZ0->( GetArea() )
		aOAreCZP  := CZP->( GetArea() )
		aOAreCYW  := CYW->( GetArea() )

		CY0->(dbGoTop())
		If CY0->(dbSeek(xFilial("CY0")+nSeqRpOri))
			While !CY0->(Eof()) .And. CY0->CY0_NRSQRP == nSeqRpOri

				aAdd(aCY0,{})

				aAdd(aCY0[Len(aCY0)],CY0->CY0_FILIAL)
				aAdd(aCY0[Len(aCY0)],CY0->CY0_NRSQRP)
				aAdd(aCY0[Len(aCY0)],CY0->CY0_CDRF)
				aAdd(aCY0[Len(aCY0)],CY0->CY0_QTRF)
				aAdd(aCY0[Len(aCY0)],CY0->CY0_QTRT)

				CY0->(dbSkip())
			End
		EndIf

		CZW->(dbGoTop())
		If CZW->(dbSeek(xFilial("CZW")+nSeqRpOri))
			While !CZW->(Eof()) .And. CZW->CZW_NRSQRP == nSeqRpOri

				aAdd(aCZW,{})

				aAdd(aCZW[Len(aCZW)],CZW->CZW_FILIAL)
				aAdd(aCZW[Len(aCZW)],CZW->CZW_NRSQRP)
				aAdd(aCZW[Len(aCZW)],CZW->CZW_CDCETR)
				aAdd(aCZW[Len(aCZW)],CZW->CZW_QTTEGF)
				aAdd(aCZW[Len(aCZW)],CZW->CZW_HRTEGF)

				CZW->(dbSkip())
			End
		EndIf

		CZ0->(dbGoTop())
		If CZ0->(dbSeek(xFilial("CZ0")+nSeqRpOri))
			While !CZ0->(Eof()) .And. CZ0->CZ0_NRSQRP == nSeqRpOri

				aAdd(aCZ0,{})

				aAdd(aCZ0[Len(aCZ0)],CZ0->CZ0_FILIAL)
				aAdd(aCZ0[Len(aCZ0)],CZ0->CZ0_NRSQRP)
				aAdd(aCZ0[Len(aCZ0)],CZ0->CZ0_IDFE)
				aAdd(aCZ0[Len(aCZ0)],CZ0->CZ0_CDFE)
				aAdd(aCZ0[Len(aCZ0)],CZ0->CZ0_QTTEUN)

				CZ0->(dbSkip())
			End
		EndIf

		CZP->(dbGoTop())
		If CZP->(dbSeek(xFilial("CZP")+nSeqRpOri))
			While !CZP->(Eof()) .And. CZP->CZP_NRSQRP == nSeqRpOri

				aAdd(aCZP,{})

				aAdd(aCZP[Len(aCZP)],CZP->CZP_FILIAL)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_NRSQRP)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_NRORPO)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_CDMT)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_CDRE)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_QTRPPO)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_CDUN)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_CDACPI)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_CDDP)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_CDLC)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_CDLO)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_CDAT)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_CDRT)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_CDES)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_DTMT)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_QTMT)
				aAdd(aCZP[Len(aCZP)],CZP->CZP_IDMTOR)

				CZP->(dbSkip())
			End
		EndIf

		CYW->(dbGoTop())
		If CYW->(dbSeek(xFilial("CYW")+nSeqRpOri))
			While !CYW->(Eof()) .And. CYW->CYW_NRSQRP == nSeqRpOri

				aAdd(aCYW,{})

				aAdd(aCYW[Len(aCYW)],CYW->CYW_FILIAL)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_NRSQRP)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_IDOE)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_CDOE)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_IDGROE)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_CDGROE)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_DTBGRP)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_HRBGRP)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_DTEDRP)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_HREDRP)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_QTTEOE)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_QTTEEX)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_QTTEUT)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_CDTN)
				aAdd(aCYW[Len(aCYW)],CYW->CYW_NRTN)

				CYW->(dbSkip())
			End
		EndIf

		RestArea(aOAreCY0)
		RestArea(aOAreCZW)
		RestArea(aOAreCZ0)
		RestArea(aOAreCZP)
		RestArea(aOAreCYW)

		Begin Transaction

			If lCommit1 .Or. lCommit2
				lRet := SFCA313OK(nSeqRpOri,Date(),.T.)
			EndIf

			If lRet

				If lCommit1 .And. (!SFCA314POS(oMdlDest1,1) .Or. !SFCA314CMM(oMdlDest1))
					lRet := .F.
					aErro := oMdlDest1:GetErrorMessage()
					If !Empty(aErro[6])
						ShowHelpDlg( "SFCA311DAP", { aErro[6] }, , { "" } )//"Apontamento não Reportado" - "Este é um apontamento não reportado, portanto, faça as devidas correções na máquina ou centro de trabalho."
					EndIf
				Else
					If lCommit2 .And. (!SFCA314POS(oMdlDest2,1) .Or. !SFCA314CMM(oMdlDest2))
						lRet := .F.
						aErro := oMdlDest2:GetErrorMessage()
						If !Empty(aErro[6])
							ShowHelpDlg( "SFCA311DAP", { aErro[6] }, , { "" } )//"Apontamento não Reportado" - "Este é um apontamento não reportado, portanto, faça as devidas correções na máquina ou centro de trabalho."
						EndIf
					EndIf
				EndIf

			EndIf

			If !lRet
				DisarmTransaction()
			EndIf
		End Transaction  

		If lRet
			If oMdlDest1:IsActive()
				cNRSQRP1 := oMdlDest1:GetValue("CYVMASTER","CYV_NRSQRP")
			Else
				cNRSQRP1 := Nil
			EndIf
			If oMdlDest2:IsActive()
				cNRSQRP2 := oMdlDest2:GetValue("CYVMASTER","CYV_NRSQRP")
			Else
				cNRSQRP2 := Nil
			EndIf

			//Refugo/Retrabalho
			
			dbSelectArea("CY0")
			CY0->(dbSetOrder(1))
			If cNRSQRP1 != Nil
				If CY0->(dbSeek(xFilial("CY0")+cNRSQRP1))
					While !CY0->(Eof()) .And. CY0->CY0_NRSQRP == cNRSQRP1
						RecLock("CY0", .F.)
						dbDelete()
						MsUnLock()
						CY0->(dbSkip())
					End
				EndIf
			

				For nI := 1 To oMdlDest1:GetModel("CY0DETAIL"):GetQtdLine()
					oMdlDest1:GetModel("CY0DETAIL"):GoLine(nI)
	
					If !oMdlDest1:GetModel("CY0DETAIL"):IsDeleted() .And. !Empty(oMdlDest1:GetValue("CY0DETAIL","CY0_CDRF"))
	
						RecLock('CY0',.T.)
						
						CY0->CY0_FILIAL := xFilial('CY0')
						CY0->CY0_NRSQRP := cNRSQRP1
						CY0->CY0_CDRF   := oMdlDest1:GetValue("CY0DETAIL","CY0_CDRF")
						CY0->CY0_QTRF   := oMdlDest1:GetValue("CY0DETAIL","CY0_QTRF")
						CY0->CY0_QTRT   := oMdlDest1:GetValue("CY0DETAIL","CY0_QTRT")
						
						MsUnLock()
	
					EndIf
	
				Next
			EndIf

			If cNRSQRP2 != Nil
				CY0->(dbGoTop())
				If CY0->(dbSeek(xFilial("CY0")+cNRSQRP2))
					While !CY0->(Eof()) .And. CY0->CY0_NRSQRP == cNRSQRP2
						RecLock("CY0", .F.)
						dbDelete()
						MsUnLock()
						CY0->(dbSkip())
					End
				EndIf
	
				For nI := 1 To oMdlDest2:GetModel("CY0DETAIL"):GetQtdLine()
					oMdlDest2:GetModel("CY0DETAIL"):GoLine(nI)
	
					If !oMdlDest2:GetModel("CY0DETAIL"):IsDeleted() .And. !Empty(oMdlDest2:GetValue("CY0DETAIL","CY0_CDRF"))
	
						RecLock('CY0',.T.)
						
						CY0->CY0_FILIAL := xFilial('CY0')
						CY0->CY0_NRSQRP := cNRSQRP2
						CY0->CY0_CDRF   := oMdlDest2:GetValue("CY0DETAIL","CY0_CDRF")
						CY0->CY0_QTRF   := oMdlDest2:GetValue("CY0DETAIL","CY0_QTRF")
						CY0->CY0_QTRT   := oMdlDest2:GetValue("CY0DETAIL","CY0_QTRT")
							
						MsUnLock()
	
					EndIf
	
				Next
			EndIf

			//GGF
			dbSelectArea("CZW")
			CZW->(dbSetOrder(1))
			If cNRSQRP1 != Nil
				If CZW->(dbSeek(xFilial("CZW")+cNRSQRP1))
					While !CZW->(Eof()) .And. CZW->CZW_NRSQRP == cNRSQRP1
						RecLock("CZW", .F.)
						dbDelete()
						MsUnLock()
						CZW->(dbSkip())
					End
				EndIf
				
				For nI := 1 To oMdlDest1:GetModel("CZWDETAIL"):GetQtdLine()
					oMdlDest1:GetModel("CZWDETAIL"):GoLine(nI)
	
					If !oMdlDest1:GetModel("CZWDETAIL"):IsDeleted() .And. !Empty(oMdlDest1:GetValue("CZWDETAIL","CZW_CDCETR"))
	
						RecLock('CZW',.T.)
						
						CZW->CZW_FILIAL := xFilial('CZW')
						CZW->CZW_NRSQRP := cNRSQRP1
						CZW->CZW_CDCETR := oMdlDest1:GetValue("CZWDETAIL","CZW_CDCETR")
						CZW->CZW_QTTEGF := oMdlDest1:GetValue("CZWDETAIL","CZW_QTTEGF")
						CZW->CZW_HRTEGF := oMdlDest1:GetValue("CZWDETAIL","CZW_HRTEGF")
						
						MsUnLock()
	
					EndIf
	
				Next
	
				CZW->(dbGoTop())
			EndIf

			If cNRSQRP2 != Nil
				If CZW->(dbSeek(xFilial("CZW")+cNRSQRP2))
					While !CZW->(Eof()) .And. CZW->CZW_NRSQRP == cNRSQRP2
						RecLock("CZW", .F.)
						dbDelete()
						MsUnLock()
						CZW->(dbSkip())
					End
				EndIf
	
				For nI := 1 To oMdlDest2:GetModel("CZWDETAIL"):GetQtdLine()
					oMdlDest2:GetModel("CZWDETAIL"):GoLine(nI)
	
					If !oMdlDest2:GetModel("CZWDETAIL"):IsDeleted() .And. !Empty(oMdlDest2:GetValue("CZWDETAIL","CZW_CDCETR"))
	
						RecLock('CZW',.T.)
						
						CZW->CZW_FILIAL := xFilial('CZW')
						CZW->CZW_NRSQRP := cNRSQRP2
						CZW->CZW_CDCETR := oMdlDest2:GetValue("CZWDETAIL","CZW_CDCETR")
						CZW->CZW_QTTEGF := oMdlDest2:GetValue("CZWDETAIL","CZW_QTTEGF")
						CZW->CZW_HRTEGF := oMdlDest2:GetValue("CZWDETAIL","CZW_HRTEGF")
						
						MsUnLock()
	
					EndIf
	
				Next
			EndIf

			//Ferramenta
			dbSelectArea("CZ0")
			CZ0->(dbSetOrder(1))
			If cNRSQRP1 != Nil
				If CZ0->(dbSeek(xFilial("CZ0")+cNRSQRP1))
					While !CZ0->(Eof()) .And. CZ0->CZ0_NRSQRP == cNRSQRP1
						RecLock("CZ0", .F.)
						dbDelete()
						MsUnLock()
						CZ0->(dbSkip())
					End
				EndIf
	
				For nI := 1 To oMdlDest1:GetModel("CZ0DETAIL"):GetQtdLine()
					oMdlDest1:GetModel("CZ0DETAIL"):GoLine(nI)
	
					If !oMdlDest1:GetModel("CZ0DETAIL"):IsDeleted() .And. !Empty(oMdlDest1:GetValue("CZ0DETAIL","CZ0_IDFE"))
	
						RecLock('CZ0',.T.)
						
						CZ0->CZ0_FILIAL := xFilial('CZ0')
						CZ0->CZ0_NRSQRP := cNRSQRP1
						CZ0->CZ0_IDFE   := oMdlDest1:GetValue("CZ0DETAIL","CZ0_IDFE")
						CZ0->CZ0_CDFE   := oMdlDest1:GetValue("CZ0DETAIL","CZ0_CDFE")
						CZ0->CZ0_QTTEUN := oMdlDest1:GetValue("CZ0DETAIL","CZ0_QTTEUN")
						
						MsUnLock()
	
					EndIf
	
				Next
	
				CZ0->(dbGoTop())
			EndIf

			If cNRSQRP2 != Nil
				If CZ0->(dbSeek(xFilial("CZ0")+cNRSQRP2))
					While !CZ0->(Eof()) .And. CZ0->CZ0_NRSQRP == cNRSQRP2
						RecLock("CZ0", .F.)
						dbDelete()
						MsUnLock()
						CZ0->(dbSkip())
					End
				EndIf
	
				For nI := 1 To oMdlDest2:GetModel("CZ0DETAIL"):GetQtdLine()
					oMdlDest2:GetModel("CZ0DETAIL"):GoLine(nI)
	
					If !oMdlDest2:GetModel("CZ0DETAIL"):IsDeleted() .And. !Empty(oMdlDest2:GetValue("CZ0DETAIL","CZ0_IDFE"))
	
						RecLock('CZ0',.T.)
						
						CZ0->CZ0_FILIAL := xFilial('CZ0')
						CZ0->CZ0_NRSQRP := cNRSQRP2
						CZ0->CZ0_IDFE   := oMdlDest2:GetValue("CZ0DETAIL","CZ0_IDFE")
						CZ0->CZ0_CDFE   := oMdlDest2:GetValue("CZ0DETAIL","CZ0_CDFE")
						CZ0->CZ0_QTTEUN := oMdlDest2:GetValue("CZ0DETAIL","CZ0_QTTEUN")
						
						MsUnLock()
	
					EndIf
	
				Next
			EndIf

			//Reservas Usadas
			dbSelectArea("CZP")
			CZP->(dbSetOrder(1))
			If cNRSQRP1 != Nil
				If CZP->(dbSeek(xFilial("CZP")+cNRSQRP1))
					While !CZP->(Eof()) .And. CZP->CZP_NRSQRP == cNRSQRP1
						RecLock("CZP", .F.)
						dbDelete()
						MsUnLock()
						CZP->(dbSkip())
					End
				EndIf
	
				For nI := 1 To oMdlDest1:GetModel("CZPDETAIL"):GetQtdLine()
					oMdlDest1:GetModel("CZPDETAIL"):GoLine(nI)
	
					If !oMdlDest1:GetModel("CZPDETAIL"):IsDeleted() .And. oMdlDest1:GetValue("CZPDETAIL","CZP_QTRPPO") > 0
	
						RecLock('CZP',.T.)
	
						CZP->CZP_FILIAL := xFilial('CZP')
						CZP->CZP_NRSQRP := cNRSQRP1
						CZP->CZP_NRORPO := oMdlDest1:GetValue("CZPDETAIL","CZP_NRORPO")
						CZP->CZP_CDMT   := oMdlDest1:GetValue("CZPDETAIL","CZP_CDMT")
						CZP->CZP_CDRE   := oMdlDest1:GetValue("CZPDETAIL","CZP_CDRE")
						CZP->CZP_QTRPPO := oMdlDest1:GetValue("CZPDETAIL","CZP_QTRPPO")
						CZP->CZP_CDUN   := oMdlDest1:GetValue("CZPDETAIL","CZP_CDUN")
						CZP->CZP_CDACPI := oMdlDest1:GetValue("CZPDETAIL","CZP_CDACPI")
						CZP->CZP_CDDP   := oMdlDest1:GetValue("CZPDETAIL","CZP_CDDP")
						CZP->CZP_CDLC   := oMdlDest1:GetValue("CZPDETAIL","CZP_CDLC")
						CZP->CZP_CDLO   := oMdlDest1:GetValue("CZPDETAIL","CZP_CDLO")
						CZP->CZP_CDAT   := oMdlDest1:GetValue("CZPDETAIL","CZP_CDAT")
						CZP->CZP_CDRT   := oMdlDest1:GetValue("CZPDETAIL","CZP_CDRT")
						CZP->CZP_CDES   := oMdlDest1:GetValue("CZPDETAIL","CZP_CDES")
						CZP->CZP_DTMT   := oMdlDest1:GetValue("CZPDETAIL","CZP_DTMT")
						CZP->CZP_QTMT   := oMdlDest1:GetValue("CZPDETAIL","CZP_QTMT")
						CZP->CZP_IDMTOR := oMdlDest1:GetValue("CZPDETAIL","CZP_IDMTOR")
	
						MsUnLock()
	
					EndIf
	
				Next
	
				CZP->(dbGoTop())
			EndIf

			If cNRSQRP2 != Nil
				If CZP->(dbSeek(xFilial("CZP")+cNRSQRP2))
					While !CZP->(Eof()) .And. CZP->CZP_NRSQRP == cNRSQRP2
						RecLock("CZP", .F.)
						dbDelete()
						MsUnLock()
						CZP->(dbSkip())
					End
				EndIf
	
				For nI := 1 To oMdlDest2:GetModel("CZPDETAIL"):GetQtdLine()
					oMdlDest2:GetModel("CZPDETAIL"):GoLine(nI)
	
					If !oMdlDest2:GetModel("CZPDETAIL"):IsDeleted() .And. oMdlDest2:GetValue("CZPDETAIL","CZP_QTRPPO") > 0
	
						RecLock('CZP',.T.)
	
						CZP->CZP_FILIAL := xFilial('CZP')
						CZP->CZP_NRSQRP := cNRSQRP2
						CZP->CZP_NRORPO := oMdlDest2:GetValue("CZPDETAIL","CZP_NRORPO")
						CZP->CZP_CDMT   := oMdlDest2:GetValue("CZPDETAIL","CZP_CDMT")
						CZP->CZP_CDRE   := oMdlDest2:GetValue("CZPDETAIL","CZP_CDRE")
						CZP->CZP_QTRPPO := oMdlDest2:GetValue("CZPDETAIL","CZP_QTRPPO")
						CZP->CZP_CDUN   := oMdlDest2:GetValue("CZPDETAIL","CZP_CDUN")
						CZP->CZP_CDACPI := oMdlDest2:GetValue("CZPDETAIL","CZP_CDACPI")
						CZP->CZP_CDDP   := oMdlDest2:GetValue("CZPDETAIL","CZP_CDDP")
						CZP->CZP_CDLC   := oMdlDest2:GetValue("CZPDETAIL","CZP_CDLC")
						CZP->CZP_CDLO   := oMdlDest2:GetValue("CZPDETAIL","CZP_CDLO")
						CZP->CZP_CDAT   := oMdlDest2:GetValue("CZPDETAIL","CZP_CDAT")
						CZP->CZP_CDRT   := oMdlDest2:GetValue("CZPDETAIL","CZP_CDRT")
						CZP->CZP_CDES   := oMdlDest2:GetValue("CZPDETAIL","CZP_CDES")
						CZP->CZP_DTMT   := oMdlDest2:GetValue("CZPDETAIL","CZP_DTMT")
						CZP->CZP_QTMT   := oMdlDest2:GetValue("CZPDETAIL","CZP_QTMT")
						CZP->CZP_IDMTOR := oMdlDest2:GetValue("CZPDETAIL","CZP_IDMTOR")
						
						MsUnLock()
	
					EndIf
	
				Next
			EndIf

			//Apontamento de Mao-de-Obra
			dbSelectArea("CYW")
			CYW->(dbSetOrder(1))
			If cNRSQRP1 != Nil
				If CYW->(dbSeek(xFilial("CYW")+cNRSQRP1))
					While !CYW->(Eof()) .And. CYW->CYW_NRSQRP == cNRSQRP1
						RecLock("CYW", .F.)
						dbDelete()
						MsUnLock()
						CYW->(dbSkip())
					End
				EndIf
				
				For nI := 1 To oMdlDest1:GetModel("CYWDETAIL"):GetQtdLine()
					oMdlDest1:GetModel("CYWDETAIL"):GoLine(nI)
	
					If !oMdlDest1:GetModel("CYWDETAIL"):IsDeleted() .And. ( !Empty(oMdlDest1:GetValue("CYWDETAIL","CYW_CDOE")) .Or. !Empty(oMdlDest1:GetValue("CYWDETAIL","CYW_CDGROE")) )
	
						RecLock('CYW',.T.)
	
						CYW->CYW_FILIAL := xFilial('CYW')
						CYW->CYW_NRSQRP := cNRSQRP1
						CYW->CYW_IDOE   := oMdlDest1:GetValue("CYWDETAIL","CYW_IDOE")
						CYW->CYW_CDOE   := oMdlDest1:GetValue("CYWDETAIL","CYW_CDOE")
						CYW->CYW_IDGROE := oMdlDest1:GetValue("CYWDETAIL","CYW_IDGROE")
						CYW->CYW_CDGROE := oMdlDest1:GetValue("CYWDETAIL","CYW_CDGROE")
						CYW->CYW_DTBGRP := oMdlDest1:GetValue("CYWDETAIL","CYW_DTBGRP")
						CYW->CYW_HRBGRP := oMdlDest1:GetValue("CYWDETAIL","CYW_HRBGRP")
						CYW->CYW_DTEDRP := oMdlDest1:GetValue("CYWDETAIL","CYW_DTEDRP")
						CYW->CYW_HREDRP := oMdlDest1:GetValue("CYWDETAIL","CYW_HREDRP")
						CYW->CYW_QTTEOE := oMdlDest1:GetValue("CYWDETAIL","CYW_QTTEOE")
						CYW->CYW_QTTEEX := oMdlDest1:GetValue("CYWDETAIL","CYW_QTTEEX")
						CYW->CYW_QTTEUT := oMdlDest1:GetValue("CYWDETAIL","CYW_QTTEUT")
						CYW->CYW_CDTN   := oMdlDest1:GetValue("CYWDETAIL","CYW_CDTN")
						CYW->CYW_NRTN   := oMdlDest1:GetValue("CYWDETAIL","CYW_NRTN")
	
						MsUnLock()
	
					EndIf
	
				Next
	
				CYW->(dbGoTop())
			EndIf

			If cNRSQRP2 != Nil 
				If CYW->(dbSeek(xFilial("CYW")+cNRSQRP2))
					While !CYW->(Eof()) .And. CYW->CYW_NRSQRP == cNRSQRP2
						RecLock("CYW", .F.)
						dbDelete()
						MsUnLock()
						CYW->(dbSkip())
					End
				EndIf
					
				For nI := 1 To oMdlDest2:GetModel("CYWDETAIL"):GetQtdLine()
					oMdlDest2:GetModel("CYWDETAIL"):GoLine(nI)
	
					If !oMdlDest2:GetModel("CYWDETAIL"):IsDeleted() .And. ( !Empty(oMdlDest2:GetValue("CYWDETAIL","CYW_CDOE")) .Or. !Empty(oMdlDest2:GetValue("CYWDETAIL","CYW_CDGROE")) )
	
						RecLock('CYW',.T.)
	
						CYW->CYW_FILIAL := xFilial('CYW')
						CYW->CYW_NRSQRP := cNRSQRP2
						CYW->CYW_IDOE   := oMdlDest2:GetValue("CYWDETAIL","CYW_IDOE")
						CYW->CYW_CDOE   := oMdlDest2:GetValue("CYWDETAIL","CYW_CDOE")
						CYW->CYW_IDGROE := oMdlDest2:GetValue("CYWDETAIL","CYW_IDGROE")
						CYW->CYW_CDGROE := oMdlDest2:GetValue("CYWDETAIL","CYW_CDGROE")
						CYW->CYW_DTBGRP := oMdlDest2:GetValue("CYWDETAIL","CYW_DTBGRP")
						CYW->CYW_HRBGRP := oMdlDest2:GetValue("CYWDETAIL","CYW_HRBGRP")
						CYW->CYW_DTEDRP := oMdlDest2:GetValue("CYWDETAIL","CYW_DTEDRP")
						CYW->CYW_HREDRP := oMdlDest2:GetValue("CYWDETAIL","CYW_HREDRP")
						CYW->CYW_QTTEOE := oMdlDest2:GetValue("CYWDETAIL","CYW_QTTEOE")
						CYW->CYW_QTTEEX := oMdlDest2:GetValue("CYWDETAIL","CYW_QTTEEX")
						CYW->CYW_QTTEUT := oMdlDest2:GetValue("CYWDETAIL","CYW_QTTEUT")
						CYW->CYW_CDTN   := oMdlDest2:GetValue("CYWDETAIL","CYW_CDTN")
						CYW->CYW_NRTN   := oMdlDest2:GetValue("CYWDETAIL","CYW_NRTN")
	
						MsUnLock()
	
					EndIf
	
				Next
			EndIf

			//----------------------------------------------
			//Regera info apontamento anterior
			//----------------------------------------------
			CY0->(dbGoTop())
			If CY0->(dbSeek(xFilial("CY0")+nSeqRpOri))
				While !CY0->(Eof()) .And. CY0->CY0_NRSQRP == nSeqRpOri

					RecLock("CY0", .F.)
					dbDelete()
					MsUnLock()
					CY0->(dbSkip())

				End
			EndIf

			CZW->(dbGoTop())
			If CZW->(dbSeek(xFilial("CZW")+nSeqRpOri))
				While !CZW->(Eof()) .And. CZW->CZW_NRSQRP == nSeqRpOri

					RecLock("CZW", .F.)
					dbDelete()
					MsUnLock()
					CZW->(dbSkip())

				End
			EndIf

			CZ0->(dbGoTop())
			If CZ0->(dbSeek(xFilial("CZ0")+nSeqRpOri))
				While !CZ0->(Eof()) .And. CZ0->CZ0_NRSQRP == nSeqRpOri

					RecLock("CZ0", .F.)
					dbDelete()
					MsUnLock()
					CZ0->(dbSkip())

				End
			EndIf

			CZP->(dbGoTop())
			If CZP->(dbSeek(xFilial("CZP")+nSeqRpOri))
				While !CZP->(Eof()) .And. CZP->CZP_NRSQRP == nSeqRpOri

					RecLock("CZP", .F.)
					dbDelete()
					MsUnLock()
					CZP->(dbSkip())

				End
			EndIf

			CYW->(dbGoTop())
			If CYW->(dbSeek(xFilial("CYW")+nSeqRpOri))
				While !CYW->(Eof()) .And. CYW->CYW_NRSQRP == nSeqRpOri

					RecLock("CYW", .F.)
					dbDelete()
					MsUnLock()
					CYW->(dbSkip())

				End
			EndIf

			//Inclui
			For nI := 1 To Len(aCY0)

				RecLock('CY0',.T.)

				CY0->CY0_FILIAL := aCY0[nI][1]
				CY0->CY0_NRSQRP := aCY0[nI][2]
				CY0->CY0_CDRF   := aCY0[nI][3]
				CY0->CY0_QTRF   := aCY0[nI][4]
				CY0->CY0_QTRT	:= aCY0[nI][5]
				
				MsUnLock()

			Next

			For nI := 1 To Len(aCZW)

				RecLock('CZW',.T.)

				CZW->CZW_FILIAL := aCZW[nI][1]
				CZW->CZW_NRSQRP := aCZW[nI][2]
				CZW->CZW_CDCETR := aCZW[nI][3]
				CZW->CZW_QTTEGF := aCZW[nI][4]
				CZW->CZW_HRTEGF	:= aCZW[nI][5]
				
				MsUnLock()

			Next

			For nI := 1 To Len(aCZ0)

				RecLock('CZ0',.T.)

				CZ0->CZ0_FILIAL := aCZ0[nI][1]
				CZ0->CZ0_NRSQRP := aCZ0[nI][2]
				CZ0->CZ0_IDFE   := aCZ0[nI][3]
				CZ0->CZ0_CDFE   := aCZ0[nI][4]
				CZ0->CZ0_QTTEUN	:= aCZ0[nI][5]
				
				MsUnLock()

			Next

			For nI := 1 To Len(aCZP)

				RecLock('CZP',.T.)

				CZP->CZP_FILIAL := aCZP[nI][1]
				CZP->CZP_NRSQRP := aCZP[nI][2]
				CZP->CZP_NRORPO := aCZP[nI][3]
				CZP->CZP_CDMT   := aCZP[nI][4]
				CZP->CZP_CDRE	:= aCZP[nI][5]
				CZP->CZP_QTRPPO := aCZP[nI][6]
				CZP->CZP_CDUN   := aCZP[nI][7]
				CZP->CZP_CDACPI := aCZP[nI][8]
				CZP->CZP_CDDP   := aCZP[nI][9]
				CZP->CZP_CDLC	:= aCZP[nI][10]
				CZP->CZP_CDLO   := aCZP[nI][11]
				CZP->CZP_CDAT   := aCZP[nI][12]
				CZP->CZP_CDRT   := aCZP[nI][13]
				CZP->CZP_CDES   := aCZP[nI][14]
				CZP->CZP_DTMT	:= aCZP[nI][15]
				CZP->CZP_QTMT   := aCZP[nI][16]
				CZP->CZP_IDMTOR	:= aCZP[nI][17]
				
				MsUnLock()

			Next

			For nI := 1 To Len(aCYW)

				RecLock('CYW',.T.)

				CYW->CYW_FILIAL := aCYW[nI][1]
				CYW->CYW_NRSQRP := aCYW[nI][2]
				CYW->CYW_IDOE   := aCYW[nI][3]
				CYW->CYW_CDOE   := aCYW[nI][4]
				CYW->CYW_IDGROE	:= aCYW[nI][5]
				CYW->CYW_CDGROE := aCYW[nI][6]
				CYW->CYW_DTBGRP := aCYW[nI][7]
				CYW->CYW_HRBGRP := aCYW[nI][8]
				CYW->CYW_DTEDRP := aCYW[nI][9]
				CYW->CYW_HREDRP	:= aCYW[nI][10]
				CYW->CYW_QTTEOE := aCYW[nI][11]
				CYW->CYW_QTTEEX := aCYW[nI][12]
				CYW->CYW_QTTEUT := aCYW[nI][13]
				CYW->CYW_CDTN   := aCYW[nI][14]
				CYW->CYW_NRTN	:= aCYW[nI][15]
				
				MsUnLock()

			Next

		EndIf

		oMdlDest1:DeActivate()
		oMdlDest2:DeActivate()

	EndIf

Return lRet

//-------------------------------------------------------------------
// - Validações ao salvar registro
// Input: Model
// Retorno: Se erros foram gerados ou não
//-------------------------------------------------------------------
Static Function SFCA311POS( oModel ) 
Local lRet      := .T.             
Local oModelCYX := oModel:GetModel( 'CYXMASTER' )
Local oModelCZ6 := oModel:GetModel( 'CZ6DETAIL' )
Local nOpc      := oModel:GetOperation()
Local cCodBem   := ''
Local aArea     := GetArea()
Local aAreaCYX  := CYX->( GetArea() )
Local aAreaCYM  := CYM->( GetArea() )
Local aAreaCYB  := CYB->( GetArea() )
Local aAreaCYI  := CYI->( GetArea() )
Local aAreaCYV  := CYV->( GetArea() )
Local aAreaCYZ	:= CYZ->( GetArea() )
Local dData
Local cSpltFec	:= ""
Local cCDCL		:= ''
Local aRetorno  := {}
Local lPreparacao
Local cCDMQ     := oModelCYX:GetValue('CYX_CDMQ')
Local dDTBGSP   := oModelCYX:GetValue('CYX_DTBGSP')
Local dDTEDSP   := oModelCYX:GetValue('CYX_DTEDSP')
Local cHRBGSP   := oModelCYX:GetValue('CYX_HRBGSP')
Local cHREDSP   := oModelCYX:GetValue('CYX_HREDSP')
Local cNRORMN   := oModelCYX:GetValue('CYX_NRORMN')
Local cCDGROE   := oModelCYX:GetValue('CYX_CDGROE')
Local cIDGROE   := ''
Local oView     := FwViewActive()
Local iCont     := 0
Local cAliasCYV := GetNextAlias()
Local lSetup    := IsInCallStack('SFCA314SAL')
Local aAptProd
Local nI

CYN->(dbSetOrder(1))
CYN->(dbGoTop())
lPreparacao := CYN->(DbSeek(xFilial('CYN')+oModelCYX:GetValue('CYX_CDSP'))) .AND. CYN->CYN_CDSP == CYX_CDSP .AND. CYN->CYN_LGSU

IF nOpc == 3 .OR. nOpc == 4

	// Verifica se existe apontamento de produção iniciado para esta máquina
	if !lSetup
		BeginSql Alias cAliasCYV
			SELECT COUNT(*) AS QTD FROM %Table:CYV% CYV
				WHERE CYV.CYV_FILIAL=%xFilial:CYV% AND 
					  CYV.CYV_CDMQ=%Exp:cCDMQ% AND
					  CYV.CYV_TPSTRP='1' AND
					  CYV.CYV_LGRPEO='F' AND
					  CYV.%NotDel%
		EndSql
		
		if (cAliasCYV)->QTD > 0
			SFCMsgErro(STR0035, 'SFC_APONTABEMQ', 1, STR0036) // Existe apontamento de produção em aberto para esta máquina ## Finalize antes de iniciar um novo", " apontamento
	   		Return .F.  
		Endif
		
		(cAliasCYV)->(dbCloseArea())
	Endif
	
	aAptProd := SFCA314VAP(cCDMQ,dDTBGSP,dDTEDSP,cHRBGSP,cHREDSP)

	For nI := 1 To Len(aAptProd)
		If aAptProd[nI][2] > 0
			cSpltFec := aAptProd[nI][1]
			Exit
		EndIf
	Next

	// TRATAMENTO PARADA DENTRO DE PRODUÇÃO
	// Valida se existe apontamento de produção no período
	if Len(aAptProd) > 0
		If CYB->CYB_LGQBRP // Se máquina permite quebrar apontamento
			If Empty(cSpltFec)
			
				// Verificar se parada ficam completamente dentro da produção
				For nI := 1 to Len(aAptProd)
					if !((STOD(aAptProd[nI][3]) >  dDTBGSP .OR.;
					      STOD(aAptProd[nI][3]) == dDTBGSP .AND. aAptProd[nI][4] < cHRBGSP) .AND.;
					     (STOD(aAptProd[nI][5]) >  dDTEDSP .OR.;
					      STOD(aAptProd[nI][5]) == dDTEDSP .AND. aAptProd[nI][6] > cHREDSP))
						lRet := .F.					      
					Endif
				Next
				
				IF lRet
			
					For nI := 1 To Len(aAptProd)
						If !SFCA311DAP(aAptProd[nI][1],dDTBGSP,dDTEDSP,cHRBGSP,cHREDSP)
							lRet := .F.
							Exit
						EndIf
					Next
				Else
					SFCMsgErro(STR0037, "SFCA311_APOPER", 1, STR0038) // Já existe apontamento de produção para a máquina e período informado ## Altere a máquina selecionada ou as datas.
					lRet := .F.
				Endif

				RestArea(aAreaCYV)
			Else
				ShowHelpDlg( "SFCA311", { STR0039 }, , { STR0040 + AllTrim(cSpltFec) + "." } ) // "Não é possível fazer a quebra de um apontamento de produção, pois o split esta finalizado." ## "É possivel que rebrir o split estornando o apontamento de produção "
				lRet := .F.
			EndIf
		Else
			SFCMsgErro(STR0037, "SFCA311_APOPER", 1, STR0038) // Já existe apontamento de produção para a máquina e período informado ## Altere a máquina selecionada ou as datas.
			lRet := .F.
		EndIf
	Endif
	// FIM
	
	// Limpa ordem de manutenção
	If AllTrim(cNRORMN) == '0'
		oModelCYX:SetValue('CYX_NRORMN', '')
		cNRORMN := ''
	EndIf

	// Quando estiver integrando com a NG
	If SuperGetMv("MV_NGMNSFC", .T., 1) != 1 
    	
		// Obriga hora estar no passado         
		If (dDTBGSP > Date() .Or. ( dDTBGSP == Date() .And. cHRBGSP > Time())) .And. !Empty(dDTEDSP)
			SFCMsgErro(STR0024, 'SFCA311') // "Início da parada não pode ser maior que a data/hora atual"
			Return .F.  
		EndIf  
		// Obriga data final ser informada quando estiver relacionada uma OM
		If Empty(dDTEDSP) .And. !Empty(cNRORMN)    
			SFCMsgErro(STR0025, 'SFCA311') // "Data final deve ser informada ao relacionar Ordem de Manutenção"
			Return .F.
		EndIf 
		// Obriga hora final ser informada quando estiver relacionada uma OM
		If Empty(cHREDSP) .And. !Empty(cNRORMN)   
			SFCMsgErro(STR0026, 'SFCA311') // "Hora final deve ser informada ao relacionar Ordem de Manutenção"
			Return .F.
		EndIf                  
	EndIf
         
	// Caso a data fim da parada não for informada, preencher com 31/12/9999
	If Empty(dDTEDSP)
		oModelCYX:LoadValue('CYX_DTEDSP', CTOD("31/12/9999"))
		dDTEDSP := CTOD("31/12/9999")
	Endif
	
	CYB->(dbSetOrder(1))
	CYB->(dbGoTop())
	CYB->(dbSeek(xFilial('CYB')+cCDMQ))

	// Verifica se máquina está válida
	if CYB->CYB_DTBGVD > dDTBGSP .OR.;
	   CYB->CYB_DTEDVD < dDTEDSP
		SFCMsgErro(STR0031, "SFCA311") //"Máquina inválida para o período de apontamento de parada informado."
		lRet := .F.
	Endif

	// Caso a hora fim da parada não for informada, preencher com 23:59:59
	If GetMv("MV_SFCTPRE") == '2'
		If Empty(oModelCYX:GetValue('CYX_HCEDSP'))    	
			oModelCYX:LoadValue('CYX_HCEDSP', 23.9998)
			cHREDSP := '23:59:59'
		Endif
		oModelCYX:LoadValue('CYX_HRBGSP',SFCXCENTOHR(oModelCYX:GetValue('CYX_HCBGSP')))
		oModelCYX:LoadValue('CYX_HREDSP',SFCXCENTOHR(oModelCYX:GetValue('CYX_HCEDSP')))
	Else
		If Empty(cHREDSP)    	
			oModelCYX:LoadValue('CYX_HREDSP', "23:59:59")
			cHREDSP := '23:59:59'
		Endif		
	Endif
	
	if dDTEDSP < dDTBGSP
		SFCMsgErro(STR0005,"SFCA311") //"Data Fim não pode ser menor que Data Início"
		lRet := .F.
	Endif
	                                                                              
	if dDTEDSP == dDTBGSP .AND.;
  	   cHREDSP < cHRBGSP
		SFCMsgErro(STR0006,"SFCA311") //"Hora Fim não pode ser menor que Hora Início"
		lRet := .F.
	Endif 
	
	If SuperGetMV('MV_NGMNSFC',.F.,1) != 1 .AND. !Empty(cNRORMN)    
		// O motivo de parada não deve ser preparação	  
		If lPreparacao
			SFCMsgErro(STR0022, 'SFCA311') // "Motivo Parada não pode ser Preparação para informar Ordem de Manutenção"   
			Return .F.     
		EndIf
		
		dbSelectArea('CZ2')
		CZ2->(dbSetOrder(4))
		if CZ2->(dbSeek(xFilial('CZ2')+cNRORMN))
			// Carrega o número da parada baseado na ordem de manutenção
			If Empty(oModelCYX:GetValue('CYX_NRSQSP'))
				oModelCYX:SetValue('CYX_NRSQSP', CZ2->CZ2_NRSQSP)
			EndIf  
		Endif
		
		// Valida se a ordem de manutenção já foi informada 
		If !Empty(Posicione('CYX',11,xFilial('CYX')+cNRORMN,'CYX_CDMQ')) .And. oModelCYX:IsFieldUpdated('CYX_NRORMN')
			SFCMsgErro(STR0027, 'SFCA311') // "Já existe uma parada para esta ordem de manutenção"    
			Return .F.
		// Valida se a manutenção não está mais ativa
		ElseIf !CZ2->CZ2_LGMN
			SFCMsgErro(STR0028, 'SFCA311') // "Ainda não foi efetuada manutenção no equipamento"    
			Return .F.      
		// Carrega o número da parada baseado na ordem de manutenção
		ElseIf Empty(oModelCYX:GetValue('CYX_NRSQSP'))
			oModelCYX:SetValue('CYX_NRSQSP', CZ2->CZ2_NRSQSP)
		EndIf                        
		// A parada sendo apontada deve estar aprovada
		If !Empty(oModelCYX:GetValue('CYX_NRSQSP')) .And. Posicione('CZ2',1,xFilial('CZ2')+cCDMQ+oModelCYX:GetValue('CYX_NRSQSP'),'CZ2_TPSTSP') != '2'
			SFCMsgErro(STR0021, 'SFCA311') // "Parada Programada deve estar aprovada" 
			Return .F.   
		EndIf   		
	EndIf
	
	if lRet .AND. !lSetup
		IF CYB->CYB_LGSU	
			if lPreparacao	
				if dDTEDSP != CTOD("31/12/9999") .OR.;
				   cHREDSP != '23:59:59'
					SFCMsgErro(STR0013,"SFCA311") //"Máquina que exige preparação somente pode ser finalizado no Apontamento de Produção"
					lRet := .F.
				Endif
			Endif
		Endif
		
		RestArea(aAreaCYB)
		
		if nOpc == 4   
			oModelCYX:SetValue( 'CYX_NRORMN', CYX->CYX_NRORMN )
			cNRORMN := CYX->CYX_NRORMN
		Else
			If !Empty(cNRORMN)
				oModelCYX:SetValue('CYX_TPSP', '2')
			EndIf    

			if Empty(IF(GetMv("MV_SFCTPRE") == '2',oModelCYX:GetValue('CYX_HCBGSP'),cHRBGSP))
				SFCMsgErro(STR0002,"SFCA311") //"Hora Inicial deve ser preenchida"
				lRet := .F.
			Endif

			dbSelectArea("CYX")
			CYX->(dbSetOrder(1))
         
			// Verificar chave duplicada - filial + maquina + dataInício + horaInício
			if CYX->(dbSeek(xFilial('CYX')+cCDMQ+DTOS(dDTBGSP)+cHRBGSP))
				SFCMsgErro(STR0003,"SFCA311") //"Já existe parada iniciada na data e hora iniciais informadas"
				lRet := .F. 
			Endif
		
			RestArea( aAreaCYX )
			
			If SFCA314VPA(cCDMQ, dDTBGSP, dDTEDSP, cHRBGSP, cHREDSP) > 0
				SFCMsgErro(STR0004, "SFCA311") //"Já existe um apontamento de parada realizado durante o período informado"
				lRet := .F.		
			EndIf
			
		Endif
	Endif
	
	if lRet
		
		cCDCL := SFCCalendario(cCDMQ)
		
		if dDTEDSP != CTOD('31/12/9999')
		
			for dData := dDTBGSP to dDTEDSP
				CYZ->(dbSetOrder(1))
				CYZ->(dbGoTop())
				IF !CYZ->(DbSeek(xFilial('CYZ')+cCDCL+DTOS(dData))) 
					If (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))								
						oModel:SetErrorMessage('CYXMASTER', 'CYX_DTBGSP',,,,STR0007 + DTOC(dData) + STR0008 )
					Else
						SFCMsgErro(STR0007 + DTOC(dData) + STR0008,'SFCA311',if(IsInCallStack( 'SFCA311POS' ) .OR. IsInCallStack( 'SFCA317CMM' ) .OR. IsInCallStack( 'SFCA320' ),1,2)) //'Não existe calendário para o dia '###' e então não será possível criar uma parada para este período'
					EndIf
					
					lRet := .F.
					Exit
				Endif
		
				RestArea(aAreaCYZ)
				
				if dData >= dDTBGSP + 365
					if !MSGYESNO(STR0009) //'O período informado é superior a um ano e os tempos útil e extra não serão calculados. Deseja continuar?'
						lRet := .F.						
					Endif
					Exit
				Endif
			Next
		Else		
			CYZ->(dbSetOrder(1))
			CYZ->(dbGoTop())
			IF !CYZ->(DbSeek(xFilial('CYZ')+cCDCL+DTOS(dDTBGSP)))								
				If (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))								
					oModel:SetErrorMessage('CYXMASTER', 'CYX_DTBGSP',,,,STR0007 + DTOC(dData) + STR0008 )
				Else
					SFCMsgErro(STR0007 + DTOC(dDTBGSP) + STR0008,'SFCA311',if(IsInCallStack( 'SFCA311POS' ) .OR. IsInCallStack( 'SFCA317CMM' ) .OR. IsInCallStack( 'SFCA320' ),1,2)) //'Não existe calendário para o dia '###' e então não será possível criar uma parada para este período'
				EndIf
					
				lRet := .F.
			Endif
		
			RestArea(aAreaCYZ)			
		Endif
		
		RestArea(aAreaCYI)
		
		if lRet .AND. dDTEDSP != CTOD('31/12/9999')
        
			aRetorno := SFCXTEMPOS(oModelCYX:GetValue('CYX_CDTN'),oModelCYX:GetValue('CYX_NRTN'),nOpc,cCDMQ,dDTBGSP,dDTEDSP,cHRBGSP,cHREDSP,.T.,'SFCA311')
	        
			IF aRetorno[5] == .F. //Empty(aRetorno[1]) .OR. Empty(aRetorno[2])
				lRet := .F.
			Else
				oModelCYX:SetValue('CYX_CDTN'  , aRetorno[1])
				oModelCYX:SetValue('CYX_NRTN'  , STRZERO(VAL(aRetorno[2]), 5))
				oModelCYX:SetValue('CYX_HRTEUT', aRetorno[3] / 3600)
				oModelCYX:SetValue('CYX_HRTEEX', aRetorno[4] / 3600)
			Endif
			
		Else
			// Verificar se tem modelo turno para o dia da data inicial
			aRetorno := SFCA314GTU(,,cCDMQ,dDTBGSP)
			
			IF Empty(aRetorno[1])
				if IsInCallStack( 'SFCA314PRE' ) .OR. IsInCallStack( 'SFCA311CalculaTempos' ) .OR. IsInCallStack( 'SFCA311POS' ) .OR. IsInCallStack( 'SFCA317CMM' )
					SFCMsgErro(STR0010,'SFCA311',if(IsInCallStack( 'SFCA311POS' ) .OR. IsInCallStack( 'SFCA317CMM' ),1,2)) //'Não encontrado Modelo Turno para a Máquina informada'
				Endif
				lRet := .F.
			Else
				dbSelectArea("CYR") // Turno Dia
				dbSetOrder(2)
				If !CYR->(dbSeek(xFilial("CYR")+aRetorno[1]+ALLTRIM(STR(DOW(dDTBGSP)))))
					SFCMsgErro(STR0011,'SFCA311',if(IsInCallStack( 'SFCA311POS' ) .OR. IsInCallStack( 'SFCA317CMM' ),1,2)) //'Não encontrado Número de Turno para a Máquina informada'
					lRet := .F.
				Endif
			Endif
		
			oModelCYX:ClearField('CYX_CDTN')
			oModelCYX:ClearField('CYX_NRTN')
			oModelCYX:ClearField('CYX_HRTEUT')
			oModelCYX:ClearField('CYX_HRTEEX')
		Endif

		if !Empty(oModelCYX:GetValue('CYX_NRTN'))
			CYM->(dbSetOrder(1))
			CYM->(dbGoTop())
			CYM->(DbSeek(xFilial('CYM')+oModelCYX:GetValue('CYX_CDTN')))
	
			oModelCYX:SetValue('CYX_DSTN',CYM->CYM_DSTN)
		
			RestArea( aAreaCYM )
		Endif
		
		oModelCYX:SetValue('CYX_DTRP',DATE())
		oModelCYX:SetValue('CYX_HRRP',TIME())
	EndIf
Endif
        
if lRet .AND. SFCIntegra() == 1 .AND. !IsInCallStack("A682IntSFC") .AND. !lPreparacao	

	If nOpc == 3
		If !(dDTEDSP == CTOD("31/12/9999") .AND. cHREDSP == "23:59:59")
			lRet := AUTO682(nOpc, oModel)
		EndIf
	ElseIf nOpc == 4

		dbSelectArea("CYX")
		CYX->(dbSetOrder(1))
         
		// Verificar chave duplicada - filial + maquina + dataInício + horaInício
		if CYX->(dbSeek(xFilial('CYX')+cCDMQ+DTOS(dDTBGSP)+cHRBGSP))
			If (CYX->CYX_DTEDSP == CTOD("31/12/9999") .AND. CYX->CYX_HREDSP == "23:59:59")
				lRet := AUTO682(3, oModel)
			EndIf                           
		Endif
		
		RestArea( aAreaCYX )

	Else
		If !(CYX->CYX_DTEDSP == CTOD("31/12/9999") .AND. CYX->CYX_HREDSP == "23:59:59")
			lRet := AUTO682(5, oModel)
		Endif
	EndIf
Endif	
  
//---------------------------------------------------
//	Início Alteração para Integração com NG
//---------------------------------------------------
If lRet .And. nOpc == 3 .And. SuperGetMV('MV_NGMNSFC', .F., 1 ) != 1 
	    
	// Quando a parada não for de preparação
	If !lPreparacao
	      
		// Se a parada emitir solicitação de serviço e não for programada
		If Posicione( 'CYN', 1, xFilial('CYN')+oModelCYX:GetValue('CYX_CDSP'), 'CYN_LGSS') .And. Empty(cNRORMN)
			lRet := AUTO280(nOpc, oModel)   
		EndIf
		
	EndIf  
	
	dbSelectArea('STJ')
	If lRet .And. (!Empty(cNRORMN) .And. Empty(Posicione( 'STJ', 1, xFilial('STJ')+AllTrim(cNRORMN), 'TJ_CODBEM' )) )
		SFCMsgErro(STR0029, 'SFCA311')   // Número da Ordem de Manutenção Inexistente
		lRet := .F.                                                           
	ElseIf !Empty(cNRORMN)
		cCodBem := Posicione( 'STJ', 1, xFilial('STJ')+AllTrim(cNRORMN), 'TJ_CODBEM' )
	EndIf
	
	dbSelectArea('ST9')
	If !Empty(cCodBem) .And. AllTrim(Posicione( 'ST9', 1, xFilial('ST9')+cCodBem, 'T9_FERRAME' )) == 'R'
		If AllTrim(Posicione('ST9', 1, xFilial('ST9')+cCodBem, 'T9_RECFERR' )) != AllTrim(cCDMQ)
			SFCMsgErro(STR0030, 'SFCA311')  // Número da Ordem de Manutenção não é válido para a Máquina informada
			lRet := .F.
		EndIf  
	EndIf     
ElseIf lRet .And. nOpc == 4 .And. !Empty(oModelCYX:GetValue('CYX_NRSS')) .And. SuperGetMV('MV_NGMNSFC', .F., 1 ) != 1 
	dbSelectArea('TQB')
	oModelCYX:SetValue('CYX_NRORMN', POSICIONE('TQB',1,xFilial('TQB')+AllTrim(oModelCYX:GetValue('CYX_NRSS')),'TQB_ORDEM') )
EndIf                    

//---------------------------------------------------
//	Fim Alteração para Integração com NG
//---------------------------------------------------

If lRet .And. (nOpc == 3 .Or. nOpc == 4)
	If !Empty(cCDGROE)
		cIDGROE := Posicione('CYH',1,xFilial('CYH')+'3'+cCDGROE, 'CYH_IDRC') 
		
		For iCont := 1 to oModelCZ6:GetQtdLine()
			oModelCZ6:GoLine(iCont)
			
			oModelCZ6:DeleteLine()
		Next
		
		oModelCZ6:GoLine(1)
		
		CZ1->(dbSetOrder(1))
		CZ1->(dbGoTop())
		IF CZ1->(DbSeek(xFilial('CZ1')+cIDGROE)) .AND. CZ1->CZ1_IDRCGR == cIDGROE
		
			iCont := 0
			
			While CZ1->(!EOF()) .AND. CZ1->CZ1_IDRCGR == cIDGROE
				iCont++
			
				if oModelCZ6:GetQtdLine() < iCont
					oModelCZ6:AddLine()
					oModelCZ6:GoLine(iCont)
				Else
					oModelCZ6:GoLine(iCont)
					oModelCZ6:UnDeleteLine()
				Endif				
				
				oModelCZ6:SetValue('CZ6_CDMQ'  ,cCDMQ)
				oModelCZ6:SetValue('CZ6_CDGROE',cCDGROE)
				oModelCZ6:SetValue('CZ6_CDOE'  ,CZ1->CZ1_CDOE)
				oModelCZ6:SetValue('CZ6_CDTN'  ,oModelCYX:GetValue('CYX_CDTN'))
				oModelCZ6:SetValue('CZ6_NRTN'  ,oModelCYX:GetValue('CYX_NRTN'))
				oModelCZ6:SetValue('CZ6_CDSP'  ,oModelCYX:GetValue('CYX_CDSP'))
				oModelCZ6:SetValue('CZ6_DTBGSP',dDTBGSP)
				oModelCZ6:SetValue('CZ6_HRBGSP',cHRBGSP)
				oModelCZ6:SetValue('CZ6_DTEDSP',dDTEDSP)
				oModelCZ6:SetValue('CZ6_HREDSP',cHREDSP)
				oModelCZ6:SetValue('CZ6_QTTEUT',oModelCYX:GetValue('CYX_HRTEUT') * 3600)
				oModelCZ6:SetValue('CZ6_QTTEEX',oModelCYX:GetValue('CYX_HRTEEX') * 3600)
				
				CZ1->(dbSkip())
			End
			
			oModelCZ6:GoLine(1)
		Endif

	ElseIf !Empty(oModelCYX:GetValue('CYX_CDOE'))
		oModelCZ6:SetValue('CZ6_CDMQ'  , cCDMQ)
		oModelCZ6:SetValue('CZ6_CDOE'  , oModelCYX:GetValue('CYX_CDOE'))
		oModelCZ6:SetValue('CZ6_CDTN'  , oModelCYX:GetValue('CYX_CDTN'))
		oModelCZ6:SetValue('CZ6_NRTN'  , oModelCYX:GetValue('CYX_NRTN'))
		oModelCZ6:SetValue('CZ6_CDSP'  , oModelCYX:GetValue('CYX_CDSP'))
		oModelCZ6:SetValue('CZ6_DTBGSP', dDTBGSP)
		oModelCZ6:SetValue('CZ6_HRBGSP', cHRBGSP)
		oModelCZ6:SetValue('CZ6_DTEDSP', dDTEDSP)
		oModelCZ6:SetValue('CZ6_HREDSP', cHREDSP)
		oModelCZ6:SetValue('CZ6_QTTEUT', oModelCYX:GetValue('CYX_HRTEUT') * 3600)
		oModelCZ6:SetValue('CZ6_QTTEEX', oModelCYX:GetValue('CYX_HRTEEX') * 3600) 
	EndIf 
EndIf

RestArea(aArea)

if Type('oView') != "U" //Se o View estiver definido atualiza
	oView:Refresh() 
Endif

Return lRet
 
//-------------------------------------------------------------------
// - Commit de campos que não estão no model
// Input: Model
// Retorno: Se erros foram gerados ou não
//-------------------------------------------------------------------
Static Function SFCA311CMM (oModel)
Local nOpc := oModel:GetOperation()

FWFormCommit( oModel ) // Salva os campos padrões do model
  
if nOpc == 3 .OR. nOpc == 4

	RecLock( 'CYX', .F. ) 

	CYX->CYX_QTTEUT := oModel:GetValue("CYXMASTER","CYX_HRTEUT") * 3600
	CYX->CYX_QTTEEX := oModel:GetValue("CYXMASTER","CYX_HRTEEX") * 3600

	MsUnlock() 

Endif

Return .T.

//-------------------------------------------------------------------
// Leave do campo de hora final, retorna valores de hora útil e extra
//
// Calcula os segundos de hora util e extra de acordo com a hora 
// início e fim da parada, verifica o modelo turno e turno
// Gera valores nas variáveis nSegUtil, nSegExtra, cCDTN, cNRTN
//
// Retorno: Segundos de tempo extra, em horas.
//-------------------------------------------------------------------
Function SFCA311CalculaTempos ( )
Local aArea     := GetArea()
Local aAreaCYM  := CYM->( GetArea() )
Local aAreaCYZ  := CYZ->( GetArea() )
Local oModel    := FWModelActive()
Local oModelCYX := oModel:GetModel( 'CYXMASTER' )
Local aRetorno  := {}
Local lRet		:= .T.
Local dData
Local cCDCL		:= ''
Default lAutomacao 	:= .F.

If GetMv("MV_SFCTPRE") == '2'
	oModelCYX:LoadValue('CYX_HRBGSP',SFCXCENTOHR(oModelCYX:GetValue('CYX_HCBGSP')))
	oModelCYX:LoadValue('CYX_HREDSP',SFCXCENTOHR(oModelCYX:GetValue('CYX_HCEDSP')))
Endif

If !lAutomacao
	cCDCL := SFCCalendario(oModelCYX:GetValue('CYX_CDMQ'))

	IF oModelCYX:GetValue('CYX_DTEDSP') >= oModelCYX:GetValue('CYX_DTBGSP')

		if oModelCYX:GetValue('CYX_DTEDSP') != CTOD('31/12/9999')
			for dData := oModelCYX:GetValue('CYX_DTBGSP') to oModelCYX:GetValue('CYX_DTEDSP')
				CYZ->(dbSetOrder(1))
				CYZ->(dbGoTop())
				IF !CYZ->(DbSeek(xFilial('CYZ')+cCDCL+DTOS(dData)))	
			
					If (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))								
						oModel:SetErrorMessage('CYXMASTER', 'CYX_DTBGSP',,,,STR0007 + DTOC(dData) + STR0008 )
					Else
						SFCMsgErro(STR0007 + DTOC(dData) + STR0008,'SFCA311',IF(IsInCallStack( 'SFCA317CMM' ) .OR. IsInCallStack( 'SFCA317POS' ) .OR. IsInCallStack( 'SFCA320' ),1,2)) //'Não existe calendário para o dia '###' e então não será possível criar uma parada para este período'
					EndIf									
				
					lRet := .F.
					Exit
				Endif
		
				RestArea(aAreaCYZ)
			
				if dData >= oModelCYX:GetValue('CYX_DTBGSP') + 365
					SFCMsgErro(STR0012,'SFCA311',IF(IsInCallStack( 'SFCA317CMM' ) .OR. IsInCallStack( 'SFCA317POS' ),1,2)) //'O período informado é superior a um ano e os tempos útil e extra não serão calculados.'
					lRet := .F.
					Exit
				Endif
			Next
		Endif

		if lRet .AND. oModelCYX:GetValue('CYX_DTEDSP') != CTOD('31/12/9999') .AND. !Empty(oModelCYX:GetValue('CYX_DTEDSP')) .AND. !Empty(oModelCYX:GetValue('CYX_CDMQ'))
			aRetorno := SFCXTEMPOS(oModelCYX:GetValue('CYX_CDTN'),oModelCYX:GetValue('CYX_NRTN'),MODEL_OPERATION_INSERT,oModelCYX:GetValue('CYX_CDMQ'),oModelCYX:GetValue('CYX_DTBGSP'),oModelCYX:GetValue('CYX_DTEDSP'),oModelCYX:GetValue('CYX_HRBGSP'),oModelCYX:GetValue('CYX_HREDSP'),.T.,'SFCA311')
	
			if !Empty(aRetorno[1])
		
				oModelCYX:SetValue('CYX_CDTN'  , aRetorno[1])
				oModelCYX:SetValue('CYX_NRTN'  , STRZERO(VAL(aRetorno[2]), 5))
				oModelCYX:SetValue('CYX_HRTEUT', aRetorno[3] / 3600)
				oModelCYX:SetValue('CYX_HRTEEX', aRetorno[4] / 3600)
		
				CYM->(dbSetOrder(1))
				CYM->(DbSeek(xFilial('CYM')+oModelCYX:GetValue('CYX_CDTN')))
		
				oModelCYX:SetValue('CYX_DSTN',CYM->CYM_DSTN)
			
				RestArea ( aAreaCYM )
			Endif
		
			RestArea(aArea)
		Else
			oModelCYX:ClearField('CYX_CDTN')
			oModelCYX:ClearField('CYX_NRTN')
			oModelCYX:ClearField('CYX_HRTEUT')
			oModelCYX:ClearField('CYX_HRTEEX')
		Endif
	Else
		oModelCYX:ClearField('CYX_HRTEEX')
		oModelCYX:ClearField('CYX_HRTEUT')
		oModelCYX:ClearField('CYX_CDTN')
		oModelCYX:ClearField('CYX_NRTN')
	Endif

	Return oModelCYX:GetValue('CYX_HRTEEX')
EndIf

//-------------------------------------------------------------------
// SFCA311VTP - Verifica turno parada
// Verifica se no período passado, existe um turno de parada
//
// Input: Modelo Turno, Dia da Semana, Hora Inicial, Hora Final,
//		  Tempo Util, Tempo Extra
// Retorno: Array com valores de tempo útil e tempo extra
//-------------------------------------------------------------------
Function SFCA311VTP(cCDTN, cDYWK, cHoraIni, cHoraFim, nSegUtil, nSegExtra)
Local cQuery   := ''
Local cTmp     := ''
Local cHora    := ''
Local aRetorno := {}
Local aArea    := GetArea()
Local cParadaIni := ''
Local cParadaFim := ''

cHora := cHoraIni 

// Procura um turno de parada que cobre todo o período passado, ou que
// comece no período, ou ainda que termine no período
cQuery := ""
cQuery += "SELECT * FROM " + RetSQLName( 'CYR' ) + " CYR WHERE "
cQuery += "		CYR_FILIAL = '" + xFilial('CYR') + "' AND "
cQuery += "		CYR_CDTN   = '" + cCDTN + "' AND "
cQuery += "		CYR_NRDYWK = '" + cDYWK + "' AND "
cQuery += "     CYR_TPTE   = '2' AND "
cQuery += "   ((CYR_HRBG  <= '" + cHoraIni + "' AND CYR_HRED >= '" + cHoraFim + "') OR " // Pega todo o período
cQuery += "    (CYR_HRBG  >= '" + cHoraIni + "' AND CYR_HRBG <= '" + cHoraFim + "') OR " // Inicia no período
cQuery += "    (CYR_HRED  >= '" + cHoraIni + "' AND CYR_HRED <= '" + cHoraFim + "') OR " // Termina no período
cQuery += "    (CYR_HRBG  >  '" + cHoraIni + "' AND CYR_HRED <  '" + cHoraFim + "')) AND " // Inicia e termina dentro do período
cQuery += "     D_E_L_E_T_ = ' ' ORDER BY CYR_HRBG" 

cTmp := GetNextAlias()

dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )

While (cTmp)->(!EOF())

	cParadaIni := (cTmp)->CYR_HRBG
	cParadaFim := (cTmp)->CYR_HRED

	if (cTmp)->CYR_HRBG > cHora
		nSegUtil += SFCXHourToSeg(ELAPTIME(cHora,(cTmp)->CYR_HRBG))
		
		cHora := (cTmp)->CYR_HRBG
	Endif
	
	// Passa direto por toda parada
	if cHoraIni <= (cTmp)->CYR_HRBG .AND. cHoraFim >= (cTmp)->CYR_HRED
	
		If IsInCallStack('SFCA311')
			nSegExtra += SFCXHourToSeg(ELAPTIME((cTmp)->CYR_HRBG,(cTmp)->CYR_HRED))			
		Endif
		
		cHora := (cTmp)->CYR_HRED
	Else

		// Fica dentro de todo o período
		if (cTmp)->CYR_HRBG <= cHoraIni .AND.;
		   (cTmp)->CYR_HRED >= cHoraFim
			nSegExtra += SFCXHourToSeg(ELAPTIME(cHoraIni,cHoraFim))
			
			cHora := cHoraFim
			Exit
		Endif
	
		// Inicia no período
		if (cTmp)->CYR_HRBG <= cHoraIni .AND. (cTmp)->CYR_HRED >= cHoraIni
			// Quando passa por toda parada, no apontamento de produção, não deve contar como hora extra.
			nSegExtra += SFCXHourToSeg(ELAPTIME(cHoraIni,(cTmp)->CYR_HRED))
			
			cHora := (cTmp)->CYR_HRED
		Endif
		
		if (cTmp)->CYR_HRBG <= cHoraFim .AND. (cTmp)->CYR_HRED >= cHoraFim
			nSegExtra += SFCXHourToSeg(ELAPTIME((cTmp)->CYR_HRBG,cHoraFim))
			cHora := cHoraFim
		Endif
	
		// Termina no período
		if (cTmp)->CYR_HRED >= cHoraIni .AND.;
		   (cTmp)->CYR_HRED <= cHoraFim
			nSegExtra += SFCXHourToSeg(ELAPTIME(cHora,(cTmp)->CYR_HRED))
			
			cHora := (cTmp)->CYR_HRED
		Endif
	Endif
	
	(cTmp)->(dbSkip())
End

(cTmp)->(dbCloseArea())

if cHora < cHoraFim
	nSegUtil += SFCXHourToSeg(ELAPTIME(cHora,cHoraFim))
Endif

AADD(aRetorno, nSegUtil)
AADD(aRetorno, nSegExtra)
AADD(aRetorno, cParadaIni)
AADD(aRetorno, cParadaFim)

RestArea(aArea)

Return aRetorno

//-------------------------------------------------------------------
// Função criada para calcular o tempo útil e o tempo extra para um
// período passado.
//                                                                         
// Input: Turno, Número Turno, Operação, Máquina, Data Inicial, 
//	      Data Final, Hora Inicial, Hora Final, 
//		  Se calcula as horas sem turno como hora extra, Programa
// Retorno: Se rotina foi executada com sucesso
//-------------------------------------------------------------------
Function SFCXTEMPOS (cCDTN, cNRTN, nOper, cMaq, dIni, dFim, cHoraIni, cHoraFim, lCalc, cProgram )
Local dData 
Local cHoraIniCalc := '00:00:00'
Local aArea        := GetArea()
Local aAreaCYI     := CYI->( GetArea() )
Local aAreaCYB     := CYB->( GetArea() )
Local aAreaCYZ     := CYZ->( GetArea() )
Local nDia		   := 0
Local nSegUtil     := 0
Local nSegExtra    := 0
Local nHoraAnt     := 0
Local aRetorno     := {}
Local a2Retorno    := {}
Local cQuery       := ''
Local lOk		   := .T. 
Local nRecNumb     := 0
Local cTmp           
Local cHora
Local cCDCL		   := ''
Local dIniVal      := CTOD('01/01/2000')
Local dFimVal      := CTOD('01/01/2100')
Local lDataDif     := .F.

cCDCL := SFCCalendario(cMaq)

if nOper == 3 .OR.;
  (nOper == 4 .AND. Empty(cCDTN))
	
	aRetorno := SFCA314GTU(,,cMaq,dIni) //Buscar o turno, com data inicio e fim de validade
	cCDTN    := aRetorno[1]
	dIniVal  := aRetorno[2]
	dFimVal  := aRetorno[3]
	
	IF Empty(cCDTN)
		if IsInCallStack( 'SFCA314PRE' ) .OR. IsInCallStack( 'SFCA311CalculaTempos' ) .OR. IsInCallStack( 'SFCA311POS' ) .OR. IsInCallStack( 'SFCA317CMM' )
			SFCMsgErro(STR0010,cProgram,if(IsInCallStack( 'SFCA311POS' ) .OR. IsInCallStack( 'SFCA317' ),1,2)) //'Não encontrado Modelo Turno para a Máquina informada'
		Endif
		lOk := .F.
	Endif
Endif

if dIni > dFim .OR.;
   (dIni == dFim .AND. cHoraIni >= cHoraFim)
   
	Return {cCDTN,'00000',0,0,lOk}
Endif

if lOk
	for dData := dIni to dFim
	
		dbSelectArea('CYR')
		CYR->(dbSetOrder(2))
		CYR->(dbGoTop())
		IF CYR->(DbSeek(xFilial('CYR')+cCDTN+ALLTRIM(STR(DOW(dData))))) 
			cHoraIniCalc := CYR->CYR_HRBG
			cNRTN		 := CYR->CYR_NRTN
			nRecNumb     := CYR->(RecNo())
		Endif
		
		While CYR->(!EOF()) .AND. CYR->CYR_CDTN == cCDTN .AND. CYR->CYR_NRDYWK == ALLTRIM(STR(DOW(dData)))
			IF CYR->CYR_TPTE == '1' .AND. cHoraIni >= cHoraIniCalc .AND.;
			   CYR->CYR_HRBG <= cHoraIni .AND. CYR->CYR_HRED >= cHoraIni
			   
				cNRTN        := CYR->CYR_NRTN
				cHoraIniCalc := CYR->CYR_HRBG
				nRecNumb     := CYR->(RecNo())
			Endif

			CYR->(dbSkip())
		End
	
		if !Empty(cNRTN)
			dbSelectArea('CYR')
			CYR->(dbSetOrder(2))
			CYR->(dbGoTop())
			IF CYR->(DbSeek(xFilial('CYR')+cCDTN+ALLTRIM(STR(DOW(dData)))+cHoraIniCalc))
				nRecNumb := CYR->(Recno())
			Endif
		
			Exit		
		Endif		
	Next
	
	IF Empty(cNRTN) .OR. nRecNumb == 0
		if IsInCallStack( 'SFCA310' ) .OR. IsInCallStack( 'SFCA311CalculaTempos' ) .OR. IsInCallStack( 'SFCA311POS' ) .OR. IsInCallStack( 'SFCA317CMM' )
			SFCMsgErro(STR0011,cProgram,if(IsInCallStack( 'SFCA311POS' ) .OR. IsInCallStack( 'SFCA317' ) .OR. IsInCallStack( 'SFCA320' ),1,2)) //'Não encontrado Turno para a Máquina informada'
	   	Endif
		lOk   := .F.
	Endif
	
	if nRecNumb != 0 .AND. lOk
		cQuery := ""
		cQuery += "SELECT * FROM " + RetSQLName( 'CYR' ) + " CYR WHERE "
		cQuery += "		R_E_C_N_O_ = " + STR(nRecNumb)
		
		cTmp := GetNextAlias()
	
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. ) 
	Endif
Endif

if lOk

	// Somente calculo hora útil e extra quando a data final for determinada
	if dFim <> CTOD('31/12/9999') 
		
		nDia := DOW(dIni) // Dia da semana
				
		if cHoraIni < (cTmp)->CYR_HRBG
			if dIni == dFim
				IF cHoraFim < (cTmp)->CYR_HRBG
					nSegExtra := SFCXHourToSeg(ELAPTIME(cHoraIni,cHoraFim))	
					cHora     := cHoraFim
					
					Return {cCDTN,'00000',0,nSegExtra,lOk}
				Else
					nSegExtra := SFCXHourToSeg(ELAPTIME(cHoraIni,(cTmp)->CYR_HRBG))
					cHora     := (cTmp)->CYR_HRBG // Atualiza hora referência com valor que deve-se iniciar os cálculos
				Endif
			Else
				nSegExtra := SFCXHourToSeg(ELAPTIME(cHoraIni,(cTmp)->CYR_HRBG))	
				cHora     := (cTmp)->CYR_HRBG				
			Endif						
		Else
		   	cHora := cHoraIni
		Endif
		
		(cTmp)->(dbCloseArea())
				
		for dData := dData to dFim // Vai dia a dia calcular o tempo util e extra
			
			if dFimVal < dData //data final da validade do turno < data inicio do apontamento
				if dData != dFim //data inicio do apontamento != data fim do apontamento
					nSegExtra += 86400 //soma os segundos de 1 dia
					lDataDif := .T.
				Else
					If lDataDif
						nSegExtra += SFCXHourToSeg(cHoraFim)
					Else
						nSegExtra += SFCXHourToSeg(ELAPTIME(cHora,cHoraFim))
					EndIf
				Endif
			Else
				
				// verifica se o dia é útil no calendário
				CYZ->(dbSetOrder(1))
				CYZ->(dbGoTop())
				IF CYZ->(DbSeek(xFilial('CYZ')+cCDCL+DTOS(dData))) .AND. CYZ->CYZ_TPDY == '1'
			        
					// Busca todos os turnos úteis para o dia da semana
					cQuery := ""
					cQuery += "SELECT * FROM " + RetSQLName( 'CYR' ) + " CYR WHERE "
					cQuery += "		CYR_FILIAL = '" + xFilial('CYR') + "' AND "
					cQuery += "		CYR_CDTN   = '" + cCDTN + "' AND "
					cQuery += "		CYR_NRDYWK = '" + ALLTRIM(STR(nDia)) + "' AND " 
					cQuery += "		CYR_TPTE   = '1' AND "
					cQuery += "     D_E_L_E_T_ = ' ' ORDER BY CYR_HRBG"
				
					cTmp := GetNextAlias()
				
					dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )
				
					While (cTmp)->(!EOF())
					
						// Se a chegar na data de término, deverá ficar de olho nos horários
						if dData == dFim
							IF cHora == '00:00:00' .AND. (cTmp)->CYR_HRBG > cHora
								if cHoraFim <= (cTmp)->CYR_HRBG
									nSegExtra += SFCXHourToSeg(ELAPTIME(cHora,cHoraFim))
									nSegExtra += nHoraAnt
									nHoraAnt  := 0
									cHora := cHoraFim
									
									IF cNRTN != (cTmp)->CYR_NRTN
										cNRTN := '00000'
									Endif
	    		
									Exit
								Else
									if lCalc // e aqui? same
										nSegExtra += SFCXHourToSeg(ELAPTIME(cHora,(cTmp)->CYR_HRBG))
									Endif
									cHora := (cTmp)->CYR_HRBG
									
									IF cNRTN != (cTmp)->CYR_NRTN
										cNRTN := '00000'
									Endif
								Endif
							Endif

							if (cTmp)->CYR_HRED >= cHoraFim
								if (cTmp)->CYR_HRBG >= cHoraFim									
									nSegExtra += SFCXHourToSeg(ELAPTIME(cHora,cHoraFim))
									cHora     := cHoraFim
								Else
									if cHora < (cTmp)->CYR_HRBG
										IF lCalc
											nSegExtra += SFCXHourToSeg(ELAPTIME(cHora,(cTmp)->CYR_HRBG))
										Endif
										cHora := (cTmp)->CYR_HRBG
									Endif
									
									aRetorno  := SFCA311VTP(cCDTN,ALLTRIM(STR(DOW(dData))),cHora,cHoraFim,nSegUtil,nSegExtra)
									
									nSegUtil  := aRetorno[1]
									nSegExtra := aRetorno[2]
									cHora     := (cTmp)->CYR_HRED
									
									IF cNRTN != (cTmp)->CYR_NRTN
										cNRTN := '00000'
									Endif
								Endif
	    		
								Exit
							Else
								if cHora < (cTmp)->CYR_HRED
									if cHora < (cTmp)->CYR_HRBG
										IF lCalc
											nSegExtra += SFCXHourToSeg(ELAPTIME(cHora,(cTmp)->CYR_HRBG))
										Endif
									
										cHora := (cTmp)->CYR_HRBG
									Endif
								
									aRetorno  := SFCA311VTP(cCDTN,ALLTRIM(STR(DOW(dData))),cHora,(cTmp)->CYR_HRED,nSegUtil,nSegExtra)
									nSegUtil  := aRetorno[1]
									nSegExtra := aRetorno[2]
									cHora     := (cTmp)->CYR_HRED
									
									IF cNRTN != (cTmp)->CYR_NRTN
										cNRTN := '00000'
									Endif
						   		Endif
							Endif
						Else
							// Tratamento para primeiro turno encontrado para o dia
							// Se o turno começar depois de 00:00:00 
							// deve considerar esse tempo como extra
						    if cHora == '00:00:00' .AND. (cTmp)->CYR_HRBG > cHora 
								if lCalc
									nSegExtra += SFCXHourToSeg(ELAPTIME(cHora,(cTmp)->CYR_HRBG))
								Endif
							    
								cHora := (cTmp)->CYR_HRBG
						    Endif
						    
						    if cHora < (cTmp)->CYR_HRED
								if cHora < (cTmp)->CYR_HRBG
									cHora := (cTmp)->CYR_HRBG
								Endif
						    
								aRetorno  := SFCA311VTP(cCDTN,ALLTRIM(STR(DOW(dData))),cHora,(cTmp)->CYR_HRED,nSegUtil,nSegExtra)
								
								nSegUtil  := aRetorno[1]
								nSegExtra := aRetorno[2]
								cHora     := (cTmp)->CYR_HRED
															
								IF cNRTN != (cTmp)->CYR_NRTN
									cNRTN := '00000'
								Endif
						    Endif
						Endif
						
						(cTmp)->(dbSkip())
					End
					
					(cTmp)->(dbCloseArea())
				Endif
                
				// Caso no último dia tenham acabado os turnos e ainda falte chegar até o fim, conta como extra
				if dData == dFim
					if cHora < cHoraFim
						nSegExtra += SFCXHourToSeg(ELAPTIME(cHora,cHoraFim))
					Endif
	
					Exit
				Else
					nHoraAnt := SFCXHourToSeg(ELAPTIME(cHora,'24:00:00'))
					cHora := '00:00:00'
				Endif
				
				// Troca o dia da Semana	
				nDia := DOW(dData) + 1
				
				// Se 8, quer dizer que começou a semana de novo
				if nDia == 8
					nDia := 1
				Endif
			Endif
		next
		
		RestArea( aAreaCYZ )
	Endif
Endif

RestArea(aArea)
RestArea(aAreaCYI)
RestArea(aAreaCYB)

nSegUtil := ROUND(nSegUtil,0)
nSegExtra := ROUND(nSegExtra,0)

AADD(a2Retorno,cCDTN)
AADD(a2Retorno,cNRTN)
AADD(a2Retorno,nSegUtil)
AADD(a2Retorno,nSegExtra)
AADD(a2Retorno,lOk)

Return a2Retorno

//-------------------------------------------------------------------
/*/{Protheus.doc} AUTO682
Rotina para Integração com o Protheus - MATA682

@param   oModel      Modelo de Dados

@author Bruno Candido Volpato da Cunha
@since 01/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AUTO682(nOpc, oModelCYX)
Local aMata682  := {}
Local cTipoHr   := 0
Local lRet      := .T.
Local nI        := 0
Local aAutoErro := {}

Private lMSHelpAuto := .T.
Private lMSErroAuto := .F.
Default lAutomacao  := .F.

Pergunte("MTA680",.F.)
cTipoHr := GetMv('MV_SFCTPRE') //-- 1-Normal ; 2-Centesimal

//-- Conversao da hora:
//-- Normal para centesimal: (normal * 100) / 60
//-- Centesimal para normal: (centesimal * 60) / 100

If !lAutomacao	
	aAdd(aMata682,{"H6_RECURSO",PadR(oModelCYX:GetValue('CYXMASTER','CYX_CDMQ'),TamSX3("H6_RECURSO")[1]),NIL})

	//-- Data de Apontamento (Inclusao no Protheus)              
	aAdd(aMata682,{"H6_DTAPONT",oModelCYX:GetValue('CYXMASTER','CYX_DTRP'),NIL})	

	//-- Data de inicio do apontamento:
	aAdd(aMata682,{"H6_DATAINI",oModelCYX:GetValue('CYXMASTER','CYX_DTBGSP'),NIL})	

	//-- Hora inicio do apontamento:
	//-- Respeitar o tipo de hora parametrizado na rotina (cTipoHr)
	aAdd(aMata682,{"H6_HORAINI",If(cTipoHr=='1',PadR(oModelCYX:GetValue('CYXMASTER','CYX_HRBGSP'),5),Substr(oModelCYX:GetValue('CYXMASTER','CYX_HRBGSP'),1,5)),NIL})	

	//-- Data de termino do apontamento
	aAdd(aMata682,{"H6_DATAFIN",oModelCYX:GetValue('CYXMASTER','CYX_DTEDSP'),NIL})	

	//-- Hora de termino do apontamento
	//-- Respeitar o tipo de hora parametrizado na rotina (cTipoHr)
	aAdd(aMata682,{"H6_HORAFIN",If(cTipoHr=='1',PadR(oModelCYX:GetValue('CYXMASTER','CYX_HREDSP'),5),Substr(oModelCYX:GetValue('CYXMASTER','CYX_HREDSP'),1,5)),NIL})	

	aAdd(aMata682,{"H6_TIPO","I",NIL})

	aAdd(aMata682,{"H6_MOTIVO",oModelCYX:GetValue('CYXMASTER','CYX_CDSP'),NIL})
EndIf

//-- Caso for exclusao, enviar INDEX como 4
If nOpc == 5	
	aAdd(aMata682,{"INDEX",4,NIL})
Else
	if PCPIntgPPI()
		aAdd(aMata682,{"H6_OBSERVA","TOTVSMES",NIL})		
	Else
		aAdd(aMata682,{"H6_OBSERVA","SIGASFC",NIL})	 
	Endif	 
EndIf

MsExecAuto({|x,y| MATA682(x,y)},aMata682,nOpc)

If lMSErroAuto //-- Tratativa de erro
	if IsInCallStack('SFCA317POS') .OR. IsInCallStack('MATI682')
		aAutoErro := GETAUTOGRLOG()
		oModelCYX:SetErrorMessage('CYXMASTER', 'CYX_DTBGSP',,,,if(Empty(aAutoErro),'Erro durante o processo', aAutoErro[1]))
	Else
		If !lAutomacao
			If !IsTelNet()
				MostraErro()
			Else
				ErroTelnet()
			EndIf
		EndIf
	Endif
	
	lRet = .F.
Else
	lRet = .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA311VLD
Valida se a parada pode ser alterada

@param   oModel      Modelo de Dados

@author Samantha Preima
@since 01/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA311VLD( oModel )
	Local lRet	:= .T.
	Local nOpc	:= (oModel:GetOperation())  

	If SFCIntegra() == 1 .AND. nOpc == 4 .And. CYX->CYX_DTEDSP != CTOD("31/12/9999")
		SFCMsgErro(STR0014,"SFCA311",1) //"Apontamento de Parada não pode ser alterado, pois já foi integrado com o Protheus e não permite alteração"
		lRet := .F.
	ElseIf nOpc == 5 .And. !IsInCallStack('SFCA313POS') .And. !Empty(CYX->CYX_NRSQRP)
		SFCMsgErro(STR0033 + PULALINHA + STR0034 + " " + AllTrim(CYX->CYX_NRSQRP),"SFCA311",1)
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AUTO280
Rotina para Integração com a NG - MNTA280
Solicitação de Serviço

@param   nOpc        Operação Executada
@param   oModel      Modelo de Dados

@author Ana Carolina Tome Klock
@since 08/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function AUTO280( nOpc,oModel )
Local aDadosAuto := {}			// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica 
Local lHelpDark  := HelpInDark(.F.)
Local lHelp      := HelpLog(.T.) 
Local cCodBem	 := NGVRFMAQ( oModel:GetValue('CYXMASTER', 'CYX_CDMQ'), 2)
Local lRetorno 	 := .T.

Private lMsHelpAuto := .T. 		// Grava help no log
Private lMsErroAuto := .F. 		// Determina se houve alguma inconsistencia na execucao da rotina em relacao aosad
    
If !Empty(cCodBem)
	
	aDadosAuto:= {{'TQB_CODBEM'	, cCodBem									 , Nil},;
				  {'TQB_RAMAL'	, '0000000000'								 , Nil},;
				  {'TQB_DESCSS'	, Posicione( 'CYN', 1, xFilial('CYN')+oModel:GetValue('CYXMASTER', 'CYX_CDSP'), 'CYN_DSSP' ) , Nil}}                                                                                                                            
	
	MSExecAuto( { |x,y,z,w| MNTA280(x,y,z,w) },,,aDadosAuto,nOpc)
	
	If lMsErroAuto 
		lRetorno := .F.
		If !IsTelNet()
			MostraErro()
		Else
			ErroTelnet()
		EndIf
	Else              
		oModel:SetValue('CYXMASTER', 'CYX_NRSS', TQB->TQB_SOLICI )
		lRetorno:=.T.         
	EndIf
	
EndIf

HelpInDark(lHelpDark)
HelpLog(lHelp)        

Return lRetorno               

//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet     := .T.
Local lFound 
Local cXMLRet  := ""    
Local oXML
Local oBusinessContent
Local oDirectLaborContent
Local oBusinessEvent
Local nOpc := 3
Local oModel
Local oModelCZ6
Local nI
Local daData
Local daTime
Local aDirectLabors := {}
             
If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
	Return { .T., 'Envio ignorado.' }
EndIf

// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE          

	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA311 Recebendo Mensagem Business' )
            
			cError := ''
			cWarning := '' 
			
			// Cria um objeto XML a partir da estutura dos dados do Model
			oXML := XmlParser(FwNoAccent(cXML), "_", @cError, @cWarning) 
			                                    
			lValid := .F.
			
			If oXML != NIL
				If XmlChildEx(oXML, '_TOTVSMESSAGE') != NIL
					oBusinessContent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
					oBusinessEvent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_EVENT:TEXT   
					
					lValid := .T.
				ElseIf XmlChildEx(oXML, '_BUSINESSCONTENT') != NIL
					oBusinessContent = oXML:_BusinessContent
					oBusinessEvent = EAI_EVENT_UPSERT   
					
					lValid := .T.
				EndIf
			EndIf
			
            If lValid == .F.
            	Return { lValid, 'Nao foi enviada uma mensagem valida' }	
            EndIf
			        
			// Instancia o modelo	
			oModel := FWLoadModel( 'SFCA311' )
			oModelCZ6 := oModel:GetModel('CZ6DETAIL')
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CYX')
			CYX->(dbSetOrder(1))
			
			daData := SFCXStoX(oBusinessContent:_StartDateTime:TEXT, 'DTDS')
			daTime := SFCXStoX(oBusinessContent:_StartDateTime:TEXT, 'DTTS')
            
   			daData := SFCXXtoS(daData)
   			daTime := SFCXXtoS(daTime)
						
			//conout(xFilial('CYX')+ PadR(oBusinessContent:_MachineCode:TEXT, Len(CYX->CYX_CDMQ)) + DToS(SFCXStoX(daData, 'D')) + daTime)
						
			lFound := CYX->(dbSeek(xFilial('CYX')+ PadR(oBusinessContent:_MachineCode:TEXT, Len(CYX->CYX_CDMQ)) + DToS(SFCXStoX(daData, 'D')) + daTime))
		
			
			//If lFound
				//ConOut('Chave encontrada')
			//EndIf
						
			// Verifica se a mensagem é de Inclusão/Alteração
			If UPPER(oBusinessEvent) == EAI_EVENT_UPSERT
				// Se foi encontrado, envia como Alteração
				If lFound
					nOpc := 4
				Else 
					// Caso não esteja cadastrado na Base de Dados, trata como Inclusão
					nOpc := 3						
				EndIf
			Else  
				// Apaga o registro  
				nOpc := 5						
			EndIf
            
			// Set a operação e Ativa o Model
			oModel:SetOperation(nOpc)
			oModel:Activate()
            
            // Se operação for diferente de exclusão
			If nOpc # 5
				// Adiciona a chave apenas se for inclusão
				If nOpc == 3
					lAssign := oModel:SetValue('CYXMASTER', 'CYX_CDMQ'  , SFCXXtoS(oBusinessContent:_MachineCode:TEXT			) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					// DateTime - Verificar
					lAssign := oModel:SetValue('CYXMASTER', 'CYX_DTBGSP', SFCXStoX(oBusinessContent:_StartDateTime:TEXT, 'DTD') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYXMASTER', 'CYX_HRBGSP', SFCXStoX(oBusinessContent:_StartDateTime:TEXT, 'DTT') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
     			EndIf

				lAssign := oModel:SetValue('CYXMASTER', 'CYX_DSMQ', SFCXXtoS(oBusinessContent:_MachineDescription:TEXT			) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                lAssign := oModel:SetValue('CYXMASTER', 'CYX_CDSP', SFCXXtoS(oBusinessContent:_StopReasonCode:TEXT				) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                lAssign := oModel:SetValue('CYXMASTER', 'CYX_DSSP', SFCXXtoS(oBusinessContent:_StopReasonDescription:TEXT		) )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                
                If XmlChildEx(oBusinessContent, '_TOOLCODE') != NIL
                	lAssign := oModel:SetValue('CYXMASTER', 'CYX_CDFEPO', SFCXXtoS(oBusinessContent:_ToolCode:TEXT					) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                EndIf
                            
	            If XmlChildEx(oBusinessContent, '_TOOLDESCRIPTION') != NIL
	                lAssign := oModel:SetValue('CYXMASTER', 'CYX_DSFEPO', SFCXXtoS(oBusinessContent:_ToolDescription:TEXT					) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
	            EndIf
                                
	            If XmlChildEx(oBusinessContent, '_PRODUCTIONTEAMCODE') != NIL
	                lAssign := oModel:SetValue('CYXMASTER', 'CYX_CDGROE', SFCXXtoS(oBusinessContent:_ProductionTeamCode:TEXT		) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
	            EndIf
                
	            If XmlChildEx(oBusinessContent, '_PRODUCTIONTEAMNAME') != NIL
	            	lAssign := oModel:SetValue('CYXMASTER', 'CYX_DSGR', SFCXXtoS(oBusinessContent:_ProductionTeamName:TEXT			) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
	            EndIf
                
                If XmlChildEx(oBusinessContent, '_OPERATORCODE') != NIL
                	lAssign := oModel:SetValue('CYXMASTER', 'CYX_CDOE', SFCXXtoS(oBusinessContent:_OperatorCode:TEXT				) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                EndIf
                
                If XmlChildEx(oBusinessContent, '_OPERATORNAME') != NIL
                	lAssign := oModel:SetValue('CYXMASTER', 'CYX_NMOE', SFCXXtoS(oBusinessContent:_OperatorName:TEXT				) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                EndIf
                
                If XmlChildEx(oBusinessContent, '_PRODUCTIONSHIFTCODE') != NIL
                	lAssign := oModel:SetValue('CYXMASTER', 'CYX_CDTN', SFCXXtoS(oBusinessContent:_ProductionShiftCode:TEXT		) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                EndIf
                
                If XmlChildEx(oBusinessContent, '_PRODUCTIONSHIFTDESCRIPTION') != NIL
                	lAssign := oModel:SetValue('CYXMASTER', 'CYX_DSTN', SFCXXtoS(oBusinessContent:_ProductionShiftDescription:TEXT ) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                EndIf
                
                If XmlChildEx(oBusinessContent, '_PRODUCTIONSHIFTNUMBER') != NIL
                	lAssign := oModel:SetValue('CYXMASTER', 'CYX_NRTN', SFCXXtoS(oBusinessContent:_ProductionShiftNumber:TEXT		) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                EndIf
                
                If XmlChildEx(oBusinessContent, '_STOPTYPE') != NIL
                	lAssign := oModel:SetValue('CYXMASTER', 'CYX_TPSP', SFCXXtoS(oBusinessContent:_StopType:TEXT					) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                EndIf
                
                If XmlChildEx(oBusinessContent, '_GENERALSTOPCODE') != NIL
                	lAssign := oModel:SetValue('CYXMASTER', 'CYX_IDSPTT', SFCXXtoS(oBusinessContent:_GeneralStopCode:TEXT			) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                EndIf
                
                If XmlChildEx(oBusinessContent, '_REPORTSEQUENCE') != NIL
                	lAssign := oModel:SetValue('CYXMASTER', 'CYX_NRSQRP', SFCXXtoS(oBusinessContent:_ReportSequence:TEXT			) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                EndIf
                
				If XmlChildEx(oBusinessContent, '_ENDDATETIME') != NIL
	                lAssign := oModel:SetValue('CYXMASTER', 'CYX_DTEDSP', SFCXStoX(oBusinessContent:_EndDateTime:TEXT, 'DTD') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYXMASTER', 'CYX_HREDSP', SFCXStoX(oBusinessContent:_EndDateTime:TEXT, 'DTT') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent, '_REPORTDATETIME') != NIL
	                lAssign := oModel:SetValue('CYXMASTER', 'CYX_DTRP', SFCXStoX(oBusinessContent:_ReportDateTime:TEXT, 'DTD') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYXMASTER', 'CYX_HRRP', SFCXStoX(oBusinessContent:_ReportDateTime:TEXT, 'DTT') )                  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
	            EndIf
	                                                                                     
	        	For nI := 1 To oModelCZ6:Length()
			
					oModelCZ6:GoLine( nI )
						
					If !oModelCZ6:IsDeleted()
				       	oModelCZ6:DeleteLine()
					Endif
				Next
	            
		  		If XmlChildEx(oBusinessContent, "_LISTOFDIRECTLABORS") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfDirectLabors) > 0
					aDirectLabors := oBusinessContent:_ListOfDirectLabors:_DirectLabor
			    	If ValType(aDirectLabors) == 'O'
						aDirectLabors := { aDirectLabors }
					EndIf
		   		EndIf
				
				For nI := 1 To Len(aDirectLabors)
					oModelCZ6:AddLine()
				    
				    oDirectLaborContent := aDirectLabors[nI]
	     
					lAssign := oModelCZ6:SetValue('CZ6_CDOE',   SFCXXtoS(oDirectLaborContent:_OperatorCode:TEXT		 ) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCZ6:SetValue('CZ6_CDSP',   SFCXXtoS(oDirectLaborContent:_StopReasonCode:TEXT		 ) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCZ6:SetValue('CZ6_CDTN',   SFCXXtoS(oDirectLaborContent:_ProductionShiftCode:TEXT	 ) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCZ6:SetValue('CZ6_NRTN',   SFCXXtoS(oDirectLaborContent:_ProductionShiftNumber:TEXT) )    ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					     
					//	DateTime - Verificar
					lAssign := oModelCZ6:SetValue('CZ6_DTBGSP', SFCXStoX(oDirectLaborContent:_StartDateTime:TEXT		, 'DTD') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCZ6:SetValue('CZ6_HRBGSP', SFCXXtoS(oDirectLaborContent:_StartDateTime:TEXT		, 'DTT') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCZ6:SetValue('CZ6_DTEDSP', SFCXStoX(oDirectLaborContent:_EndDateTime:TEXT			, 'DTD') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCZ6:SetValue('CZ6_HREDSP', SFCXXtoS(oDirectLaborContent:_EndDateTime:TEXT			, 'DTT') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					
				Next
             EndIf
            
            // Validação no Model    
			if oModel:VldData()  
				// Caso nao ocorra erros, efetiva os dados no banco
				oModel:CommitData()    
				
				// Retorna OK                        
				cXMLRet := 'Mensagem de ' + IF(nOpc == 3,'Criacao', IF(nOpc == 4, 'Alteracao', 'Delecao')) + ' recebida com sucesso.'
			Else
				// Cria TAG com o Erro ocorrido para retornar ao EAI
				aErro := oModel:GetErrorMessage()
				cXMLRet := SFCXXtoS(aErro[6]) + ' (' + SFCXXtoS(aErro[4]) + ' = "' + SFCXXtoS(aErro[9]) + '")'
				lRet := .F.
			EndIf

			// Desativa o Model
			oModel:DeActivate()

	  // Mensagem é de Response
      ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
            //conout( '+ IntegDef SFCA311 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA311 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
// Chamada é para envio, solicitada pelo MODEL      
ElseIf nTypeTrans == TRANS_SEND
      //conout( '+ IntegDef SFCA311 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()
      oModelCZ6 := oModel:GetModel('CZ6DETAIL')

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "StopReport", oModel:GetOperation(), { { "Machine", oModel:GetValue("CYXMASTER", 'CYX_CDMQ') }, { "Date", SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_DTBGSP'))}, {"Hour", SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_HRBGSP'))} }  )         
       
      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'       

		cXMLRet += '<MachineCode>' 					+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_CDMQ')) 		+ '</MachineCode>'
		cXMLRet += '<MachineDescription>' 			+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_DSMQ')) 		+ '</MachineDescription>'
		cXMLRet += '<StopReasonCode>' 				+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_CDSP')) 		+ '</StopReasonCode>'
		cXMLRet += '<StopReasonDescription>'	 	+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_DSSP')) 		+ '</StopReasonDescription>'
		cXMLRet += '<ToolCode>' 					+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_CDFEPO')) 		+ '</ToolCode>'
		cXMLRet += '<ToolDescription>' 				+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_DSFEPO')) 		+ '</ToolDescription>'
		cXMLRet += '<ProductionTeamCode>' 			+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_CDGROE')) 		+ '</ProductionTeamCode>'
		cXMLRet += '<ProductionTeamName>' 			+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_DSGR')) 		+ '</ProductionTeamName>'
		cXMLRet += '<OperatorCode>' 				+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_CDOE')) 		+ '</OperatorCode>'
		cXMLRet += '<OperatorName>' 				+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_NMOE')) 		+ '</OperatorName>'
		cXMLRet += '<ProductionShiftCode>' 			+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_CDTN')) 		+ '</ProductionShiftCode>'
		cXMLRet += '<ProductionShiftDescription>'	+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_DSTN')) 		+ '</ProductionShiftDescription>'
		cXMLRet += '<ProductionShiftNumber>' 		+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_NRTN')) 		+ '</ProductionShiftNumber>'
		cXMLRet += '<StopType>' 					+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_TPSP')) 		+ '</StopType>'
		
		//TODO Verificar
		cXMLRet += '<ReportDateTime>' 				+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_DTRP')) 		+ '</ReportDateTime>'
		cXMLRet += '<ReportDateTime>' 				+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_HRRP')) 		+ '</ReportDateTime>'
		cXMLRet += '<GeneralStopCode>' 				+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_IDSPTT')) 		+ '</GeneralStopCode>'
		cXMLRet += '<ReportSequence>' 				+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_NRSQRP')) 		+ '</ReportSequence>'
         
     // DateTime - Verificar (um dos Datetime é chave)
	 //	cXMLRet += '<StartDateTime>' 				+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_DTBGSP')) 		+ '</StartDateTime>'
	 //	cXMLRet += '<StartDateTime>' 				+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_HRBGSP')) 		+ '</StartDateTime>'
	 //	cXMLRet += '<EndDateTime>' 					+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_DTEDSP')) 		+ '</EndDateTime>'
	 //	cXMLRet += '<EndDateTime>' 					+ SFCXXtoS(oModel:GetValue("CYXMASTER", 'CYX_HREDSP')) 		+ '</EndDateTime>'
		
		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5
			cXMLRet += '<ListOfDirectLabors>'

				For nI := 1 To oModelCZ6:Length()
					oModelCZ6:GoLine( nI )
				
				   	If !oModelCZ6:IsDeleted()
				   		cXMLRet += '<DirectLabor>'  
							cXMLRet += '<OperatorCode>' 			+ SFCXXtoS(oModelCZ6:GetValue('CZ6_CDOE')) 		+ '</OperatorCode>'
							cXMLRet += '<StopReasonCode>' 			+ SFCXXtoS(oModelCZ6:GetValue('CZ6_CDSP')) 		+ '</StopReasonCode>'
							cXMLRet += '<ProductionShiftCode>' 		+ SFCXXtoS(oModelCZ6:GetValue('CZ6_CDTN')) 		+ '</ProductionShiftCode>'
							cXMLRet += '<ProductionShiftNumber>' 	+ SFCXXtoS(oModelCZ6:GetValue('CZ6_NRTN')) 		+ '</ProductionShiftNumber>'
							
						 // DateTime - Verificar 
						 // cXMLRet += '<StartDateTime>'			+ SFCXXtoS(oModelCZ6:GetValue('CZ6_DTBGSP')) 	+ '</StartDateTime>'
						 //	cXMLRet += '<StartDateTime>'			+ SFCXXtoS(oModelCZ6:GetValue('CZ6_HRBGSP')) 	+ '</StartDateTime>'
						 // cXMLRet += '<EndDateTime>' 				+ SFCXXtoS(oModelCZ6:GetValue('CZ6_DTEDSP')) 	+ '</EndDateTime>'
						 // cXMLRet += '<EndDateTime>' 				+ SFCXXtoS(oModelCZ6:GetValue('CZ6_HREDSP')) 	+ '</EndDateTime>'
				   		cXMLRet += '</DirectLabor>'
				   	EndIf	      	        
				Next
			
			cXMLRet += '</ListOfDirectLabors>'
			
        EndIf 
	    		
      cXMLRet += '</BusinessContent>'
      
EndIf

Return { lRet, cXMLRet }

Function INTDF_A311( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)
