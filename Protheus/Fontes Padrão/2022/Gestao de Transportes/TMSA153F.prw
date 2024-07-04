#INCLUDE 'PROTHEUS.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TMSA153F.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TMS153F()
Cadastro de meta detalhada
@author  Ruan Ricardo Salvador
@since   15/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TMS153F()
	Local oDialog := Nil//Objeto tela
	Local oMark  := Nil//Objeto marca/desmarca
	Local oTempTable := Nil//Tabela temporaria
	Local oQtdDia  := Nil //Objeto do campo quantidade de dias
	Local oQtdMeta := Nil //Objeto do campo quantidade da meta
	Local oObjQtdSem := {Nil,Nil,Nil,Nil,Nil,Nil,Nil} //Objeto dos campos quantidade dias da semana
	
	Local aCombo := {STR0002, STR0003, STR0004, STR0005} //Combo box '1=Diario', '2=Semanal', '3=Mensal', '4=Personalizada'
	Local aQtdSem := {0,0,0,0,0,0,0} //Campo get dias da semana
	Local aTmpStu := {} //Estrutura da tabela temporaria
	Local aCpoBro := {} //Campos do grid tipo de veiculo
	Local aAreaDLE := DLE->(GetArea())
	Local aAreaDLF := DLF->(GetArea())
	Local aAreaDLG := DLG->(GetArea())

 	Local cGRD := Posicione('DLC', 1, xFilial('DLC')+DLE->DLE_CODGRD,'DLC_DESCRI') //Descricao do grupo de regioes
 	Local cUM  := Iif(DL7->DL7_UM == '1', STR0006, STR0007) //Descricao da unidade de medida - Peso / Quantidade de veiculos
	Local cCombo := '' //Variavel que recebe valor do combo
	Local cMascQtd := '' //Mascara dos campos quantidade
	Local cAliasTab := GetNextAlias() //Aliais da tabela temporaria
	Local cMark := GetMark() //Recebe proxima marca disponivela
	
	Local nQtdDia  := 0 //Campo get
	Local nQtdMeta := 0 //Campo get
	Local nOpca := 0 //0 - Continuar 1 - Sair

	Local bOk := {||TM153FBTOK(@oDialog, cAliasTab, cCombo, nQtdDia, nQtdMeta, aQtdSem)} //Botao salvar
 	Local bCancel:= {||nOpca := 1,oDialog:End()} //botao cancelar
 	 
 	Local lRet := .F.
	Local aRet := {}

	//--Realiza o LOCK do registro posicionado em tela - Filial + Contrato + Grupo Regiao
	aRet := TMLockDmd("TMSA153D_" +DLE->DLE_FILIAL+DLE->DLE_CRTDMD+DLE->DLE_CODGRD)

	//--aRet[1] - Retorno da função podendo ser .T. ou .F.
	If aRet[1]
		IF DL7->DL7_STATUS == '2'
			Help( ,, 'Help',, STR0054, 1, 0 ) //"O contrato da meta está suspenso."
			aRet[1] := .F.
		ElseIf DL7->DL7_STATUS == '3'
			Help( ,, 'Help',, STR0055, 1, 0 ) //"O contrato da meta está encerrado."
			aRet[1] := .F.
		EndIf			
		
		If aRet[1]
			//Verifica se grupo de regioes ja possui meta cadastrada
			DLG->(DbSetOrder(1))
			If DLG->(dbSeek(xFilial('DLG')+DLE->DLE_CRTDMD+DLE->DLE_CODGRD))
				If DLF->(dbSeek(xFilial('DLF')+DLE->DLE_CRTDMD+DLE->DLE_CODGRD)) //Verifica meta por tipo de veiculo
					While DLF->(!EOF()) .And. DLF->DLF_CRTDMD == DLE->DLE_CRTDMD .And. DLF->DLF_CODGRD == DLE->DLE_CODGRD 
						Iif(!DLG->(dbSeek(xFilial('DLG')+DLE->DLE_CRTDMD+DLE->DLE_CODGRD+DLF->DLF_TIPVEI)), lRet := .T.,)
						DLF->(DbSkip())
					EndDo	
					If !lRet
						Help( ,, 'Help',, STR0027, 1, 0 ) //Meta ja cadastrada para este grupo de regiao 
					EndIf
				Else
					Help( ,, 'Help',, STR0027, 1, 0 ) //Meta ja cadastrada para este grupo de regiao
				EndIf
			ElseIf !Empty(DLE->DLE_CRTDMD)
				lRet := .T.
			EndIf
		EndIf 

		If lRet
			//Cria a tela de cadastro de meta detalhada 
			DEFINE MSDIALOG oDialog TITLE STR0001 From 000,000 TO 570,520 OF oMainWnd PIXEL //Cadastro de meta detalhada
				
				//Recebe mascara dos campos quantidade de acordo com a unidade de medida
				IIf(DL7->DL7_UM == '1', cMascQtd := '@E 999,999,999.9999', cMascQtd := '@E 999,999,999')
				
				//Cabecalho
				@ 33, 3   SAY STR0008         Of oDialog PIXEL SIZE 56 ,9 //Contrato:  
				@ 33, 28  SAY DL7->DL7_COD    Of oDialog FONT  oDialog:oFont COLOR CLR_BLUE PIXEL SIZE 56 ,9 //Cod. Contrato
				@ 33, 78  SAY STR0009         Of oDialog PIXEL SIZE 56 ,9 //Ini. Vigencia:   
				@ 33, 110 SAY DL7->DL7_INIVIG Of oDialog FONT  oDialog:oFont COLOR CLR_BLUE PIXEL SIZE 56 ,9 //Ini. Vigencia
				@ 33, 163 SAY STR0010         Of oDialog PIXEL SIZE 56 ,9 //Fim Vigencia:   
				@ 33, 196 SAY DL7->DL7_FIMVIG Of oDialog FONT  oDialog:oFont COLOR CLR_BLUE PIXEL SIZE 56 ,9 //Fim Vigencia
				
				@ 45, 3   SAY STR0011         Of oDialog PIXEL SIZE 56 ,9 //Grupo de Regioes: 
				@ 45, 51  SAY cGRD            Of oDialog FONT  oDialog:oFont COLOR CLR_BLUE PIXEL SIZE 120 ,9 //Grupo de Regioes
				
				@ 57, 3   SAY STR0012         Of oDialog PIXEL SIZE 56 ,9 //Quantidade: 
				@ 57, 33  SAY DLE->DLE_QTD    Of oDialog FONT  oDialog:oFont COLOR CLR_BLUE PIXEL SIZE 56 ,9 PICTURE cMascQtd //Quantidade
				
				@ 57, 103 SAY STR0013         Of oDialog PIXEL SIZE 56 ,9 //Unidade: 
				@ 57, 126 SAY cUM             Of oDialog FONT  oDialog:oFont COLOR CLR_BLUE PIXEL SIZE 90 ,9 //Unidade
				
				//Tip da _meta
				oCombo1 := TComboBox():New(78,3,{|u|if(PCount()>0,cCombo:=u,cCombo)},aCombo,150,18,oDialog,,{||TM153FLimp(@nQtdDia, @nQtdMeta, @aQtdSem)},,,,.T.,,,,,,,,,'cCombo',STR0013,1) //Tipo de meta
				oCombo1:bHelp := {||ShowHelpCpo(STR0014,{STR0033+Chr(13)+Chr(10),STR0034,STR0035,STR0036,STR0037},10,{STR0038,Chr(13)+Chr(10)+STR0039},2)} //Help do campo
				
				@ 78, 200 SAY STR0015 Of oDialog PIXEL SIZE 56 ,9 //Quantidade de dias
				@ 86, 200 MSGET oQtdDia VAR nQtdDia SIZE 40,13 OF oDialog VALID Positivo(nQtdDia) WHEN IiF(cCombo == '4', .T., .F.) PIXEL PICTURE '@E 99999'
				oQtdDia:bHelp := {||ShowHelpCpo(STR0015,{STR0040},3,{STR0041,Chr(13)+Chr(10)+STR0042},2)} //Help do campo
				
				@ 108, 3   SAY STR0016  Of oDialog PIXEL SIZE 56 ,9 //Quantidade da meta
				@ 116, 3   MSGET oQtdMeta VAR nQtdMeta SIZE 70,13 OF oDialog VALID Positivo(nQtdMeta) WHEN IiF(cCombo != '1', .T., .F.) PIXEL PICTURE cMascQtd //Quantidade da meta
				oQtdMeta:bHelp := {||ShowHelpCpo(STR0016,{STR0043},3,{STR0044,Chr(13)+Chr(10)+STR0045},2)} //Help do campo
				
				@ 140, 3   SAY STR0017  Of oDialog PIXEL SIZE 120 ,9 //Quantidade da meta por dia da semana
				
				@ 150, 3   SAY STR0018  Of oDialog PIXEL SIZE 56 ,9 //Domingo		
				@ 158, 3   MSGET oObjQtdSem[1] VAR aQtdSem[1] SIZE 60,13 OF oDialog VALID Positivo(aQtdSem[1]) WHEN IiF(cCombo == '1', .T., .F.) PIXEL PICTURE cMascQtd
				oObjQtdSem[1]:bHelp := {||ShowHelpCpo(STR0018,{STR0046},4,{STR0044,Chr(13)+Chr(10)+STR0053},2)} //Help do campo
				
				@ 150, 67  SAY STR0019  Of oDialog PIXEL SIZE 56 ,9 //Segunda		
				@ 158, 67  MSGET oObjQtdSem[2] VAR aQtdSem[2] SIZE 60,13 OF oDialog VALID Positivo(aQtdSem[2]) WHEN IiF(cCombo == '1', .T., .F.) PIXEL PICTURE cMascQtd
				oObjQtdSem[2]:bHelp := {||ShowHelpCpo(STR0019,{STR0047},4,{STR0044,Chr(13)+Chr(10)+STR0053},2)} //Help do campo
				
				@ 150, 131 SAY STR0020  Of oDialog PIXEL SIZE 56 ,9 //Terca		
				@ 158, 131 MSGET oObjQtdSem[3] VAR aQtdSem[3] SIZE 60,13 OF oDialog VALID Positivo(aQtdSem[3]) WHEN IiF(cCombo == '1', .T., .F.) PIXEL PICTURE cMascQtd
				oObjQtdSem[3]:bHelp := {||ShowHelpCpo(STR0020,{STR0048},43,{STR0044,Chr(13)+Chr(10)+STR0053},2)} //Help do campo
				
				@ 150, 195 SAY STR0021  Of oDialog PIXEL SIZE 56 ,9 //Quarta		
				@ 158, 195 MSGET oObjQtdSem[4] VAR aQtdSem[4] SIZE 60,13 OF oDialog VALID Positivo(aQtdSem[4]) WHEN IiF(cCombo == '1', .T., .F.) PIXEL PICTURE cMascQtd
				oObjQtdSem[4]:bHelp := {||ShowHelpCpo(STR0021,{STR0049},4,{STR0044,Chr(13)+Chr(10)+STR0053},2)} //Help do campo
				
				@ 175, 3   SAY STR0022  Of oDialog PIXEL SIZE 56 ,9 //Quinta		
				@ 183, 3   MSGET oObjQtdSem[5] VAR aQtdSem[5] SIZE 60,13 OF oDialog VALID Positivo(aQtdSem[5]) WHEN IiF(cCombo == '1', .T., .F.) PIXEL PICTURE cMascQtd
				oObjQtdSem[5]:bHelp := {||ShowHelpCpo(STR0022,{STR0050},4,{STR0044,Chr(13)+Chr(10)+STR0053},2)} //Help do campo
				
				@ 175, 67  SAY STR0023  Of oDialog PIXEL SIZE 56 ,9 //Sexta		
				@ 183, 67  MSGET oObjQtdSem[6] VAR aQtdSem[6] SIZE 60,13 OF oDialog VALID Positivo(aQtdSem[6]) WHEN IiF(cCombo == '1', .T., .F.) PIXEL PICTURE cMascQtd
				oObjQtdSem[6]:bHelp := {||ShowHelpCpo(STR0023,{STR0051},4,{STR0044,Chr(13)+Chr(10)+STR0053},2)} //Help do campo
				
				@ 175, 131 SAY STR0024  Of oDialog PIXEL SIZE 56 ,9 //Sabado		
				@ 183, 131 MSGET oObjQtdSem[7] VAR aQtdSem[7] SIZE 60,13 OF oDialog VALID Positivo(aQtdSem[7]) WHEN IiF(cCombo == '1', .T., .F.) PIXEL PICTURE cMascQtd
				oObjQtdSem[7]:bHelp := {||ShowHelpCpo(STR0024,{STR0052},4,{STR0044,Chr(13)+Chr(10)+STR0053},2)} //Help do campo
				
				//Grid do tipo de veiculo
				@ 205, 3 SAY STR0025  Of oDialog PIXEL SIZE 56 ,9 //Tipo de Veiculo		
				
				aadd(aTmpStu , {'TPV_MARK',   'C', 2, 0}) //Campo utilizado para marcar e desmarcar)
				aadd(aTmpStu , {'TPV_TIPVEI', 'C', TAMSX3('DLF_TIPVEI')[1], 0}) //Cod. Tipo do veiculo)
				aadd(aTmpStu , {'TPV_DESCRI', 'C', TAMSX3('DLF_DESCRI')[1], 0}) //Descricao)	
				
				oTempTable := FWTemporaryTable():New(cAliasTab) //Cria a tabela temporaria
				oTempTable:SetFields(aTmpStu)                   //Seta estrutura 
				oTempTable:AddIndex('01',{'TPV_TIPVEI'})        //Cria indice
				oTempTable:Create()
				
				//Preenche a tabela criada com as informacoes da tabela DLF
				DLF->(DbSetOrder(1))
				If DLF->(dbSeek(xFilial('DLF')+DLE->DLE_CRTDMD+DLE->DLE_CODGRD))
					DbSelectArea(cAliasTab)
					While DLF->(!EOF()) .And. DLF->DLF_CRTDMD == DLE->DLE_CRTDMD .And. DLF->DLF_CODGRD == DLE->DLE_CODGRD
						DLG->(DbSetOrder(1))
						If !DLG->(dbSeek(xFilial('DLG')+DLE->DLE_CRTDMD+DLE->DLE_CODGRD+DLF->DLF_TIPVEI))
							RecLock(cAliasTab,.T.)
							(cAliasTab)->TPV_TIPVEI := DLF->DLF_TIPVEI
							(cAliasTab)->TPV_DESCRI := Posicione('DUT', 1, xFilial('DUT')+DLF->DLF_TIPVEI, 'DUT_DESCRI')
							(cAliasTab)->(MsUnlock())
						EndIf
						DLF->(DbSkip())
					EndDo
				EndIf
				
				//Array de campos que serao apresentados em tela
				aCpoBro := {{'TPV_MARK',, '', '@!'},; //Mark
							{'TPV_TIPVEI',, STR0025, '@!'},; //Tipo do veiculo
							{'TPV_DESCRI',, STR0026, '@!'}}  //Descricao
				
				//Posiciona no primeiro registro
				(cAliasTab)->(DbGotop())
				
				//Cria a MsSelect
				oMark := MsSelect():New(cAliasTab,'TPV_MARK','',aCpoBro,.F.,cMark,{213,3,280,260},,,oDialog,,)
				oMark:bMark := {|| TM153FMark(cMark, cAliasTab, oMark)} 	
				
			ACTIVATE MSDIALOG oDialog ON INIT EnchoiceBar(oDialog, bOk , bCancel) CENTERED
			
			//Libera tabela temporaria
			(cAliasTab)->(DbCloseArea())
		EndIf
		//--Retira o LOCK do registro posicionado em tela - Filial + Contrato + Grupo Regiao
		TMUnLockDmd("TMSA153D_" +DLE->DLE_FILIAL+DLE->DLE_CRTDMD+DLE->DLE_CODGRD, .T.)
	Else 
		//--Caso o Retorno da função de LOCK for .F. apresenta MSG do Retorno. 
		Help( ,, 'Help',, aRet[2], 1, 0 )	//--Registro bloqueado pelo usuário XXXX.
	EndIf

	RestArea(aAreaDLE)
	RestArea(aAreaDLF)
	RestArea(aAreaDLG)
	
	//Libera memoria
	FwFreeObj(aAreaDLE)
	FwFreeObj(aAreaDLF)
	FwFreeObj(aAreaDLG)
	
	FwFreeObj(oDialog)
	FwFreeObj(oMark)
	FwFreeObj(oTempTable)
	FwFreeObj(oQtdDia)
	FwFreeObj(oQtdMeta)
	FwFreeObj(oObjQtdSem)

	FwFreeObj(aCombo)
	FwFreeObj(aQtdSem)
	FwFreeObj(aTmpStu)
	FwFreeObj(aCpoBro)
	FwFreeObj(aRet)
		
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} TM153FMark()
Grid mark do tipo de veiculos do grupo de região
@author  Ruan Ricardo Salvador
@since   15/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TM153FMark(cMark, cAliasTab, oMark)
	
	RecLock(cAliasTab,.F.)
		If Marked('TPV_MARK')	
			(cAliasTab)->TPV_MARK := cMark //Realiza a marcacao
		Else	
			(cAliasTab)->TPV_MARK  := '' //Retira a marcacao
		Endif             
	MsUnLock()
	
	oMark:oBrowse:Refresh() //Refresh no grid
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TM153FLimp()
Limpa as variaveis da tela quando alterado o tipo da meta
@author  Ruan Ricardo Salvador
@since   15/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TM153FLimp(nQtdDia, nQtdMeta, aQtdSem)
	Local nI := 0
	
	nQtdDia := 0
	nQtdMeta := 0	
	
	For nI := 1 To 7
		aQtdSem[nI] := 0
	Next i
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} TM153FBTOK()
Funcao botão Salvar
@author  Ruan Ricardo Salvador
@since   15/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function TM153FBTOK(oDialog, cAliasTab, cCombo, nQtdDia, nQtdMeta, aQtdSem)
	Local aMeta := {} //Array com as metas
	Local aTipVei := {} //Array com os tipos de veiculos
	Local lRet := .T.
	Local nX := 0
		
	(cAliasTab)->(DbGoTop())
	
	If !Empty((cAliasTab)->TPV_TIPVEI)
		//Verifica se existe tipo de veiculo para meta e se ao menos um esta selecionado
		While (cAliasTab)->(!EOF())
			If !Empty((cAliasTab)->TPV_MARK)
				aadd(aTipVei,(cAliasTab)->TPV_TIPVEI)
			EndIf
			(cAliasTab)->(DbSkip())
		EndDo
		
		If Empty(aTipVei)
			Help( ,, 'Help',, STR0028, 1, 0 ) //Para metas que possuem tipo de veiculos cadastrados e necessario selecionar ao menos um tipo para gerar meta.
			lRet := .F.
		EndIf
	EndIf
	
	(cAliasTab)->(DbGoTop())
	
	If cCombo == '4' .And. nQtdDia <= 0 //Tipo de meta: 4-Personalizada 
		Help( ,, 'Help',, STR0029, 1, 0 ) //Para tipo de meta: Personalizada, o campo Quantidade de Dias deve ser maior que zero.
		lRet := .F.
	EndIf
		
	If lRet
		//Monta array com as datas e quantidades da meta
		aMeta := TM153FQbMt(cCombo, nQtdDia, nQtdMeta, aQtdSem)
		
		If !Empty(aMeta)
			Processa( {|| TM153FMeta(aMeta, aTipVei, oDialog) }, STR0031, STR0032,.F.) //Aguarde... - Carregando as metas...
		EndIf
	Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TM153FQbMt()
Função que monta o array aMetas
@author  Ruan Ricardo Salvador
@since   18/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function TM153FQbMt(cCombo, nQtdDia, nQtdMeta, aQtdSem)
	Local cDataIni := DL7->DL7_INIVIG //Data inicio de vigencia do contrato 
	Local cDataFim := DL7->DL7_FIMVIG //Data fim de vigencia do contrato 
	Local cDtIniAx 
	Local aMeta := {}
	Local nI := 0
	
	Do Case
	Case cCombo == '1' //Tipo de meta: 1-Diaria
		While cDataIni <= cDataFim
			aadd(aMeta,{cDataIni, cDataIni, aQtdSem[Dow(cDataIni)]})
			cDataIni++
		EndDo
	Case cCombo == '2' //Tipo de meta: 2-Semanal
		While cDataIni <= cDataFim			
			If Dow(cDataIni) != 1
				cDtIniAx := cDataIni + (7 - Dow(cDataIni))
				If !(cDtIniAx > cDataFim)
					aadd(aMeta,{cDataIni, cDtIniAx, nQtdMeta})
				Else
					aadd(aMeta,{cDataIni, cDataFim, nQtdMeta})
				EndIf
				cDataIni := cDtIniAx+1
			Else
				cDtIniAx := cDataIni+6
				If cDtIniAx <= cDataFim
					aadd(aMeta,{cDataIni, cDtIniAx, nQtdMeta})
				Else
					aadd(aMeta,{cDataIni, cDataFim, nQtdMeta})
				EndIf				
				cDataIni := cDtIniAx+1				
			EndIf
		EndDo
	Case cCombo == '3' //Tipo de meta: 3-Mensal
		While cDataIni <= cDataFim
			cDtIniAx := lastday(cDataIni)
			If cDtIniAx <= cDataFim 
				aadd(aMeta,{cDataIni, cDtIniAx, nQtdMeta})
			Else 
				aadd(aMeta,{cDataIni, cDataFim, nQtdMeta})
			EndIf
			cDataIni := cDtIniAx+1
		EndDo
	Case cCombo == '4' //Tipo de meta: 4-Personalizada
		While cDataIni <= cDataFim
			cDtIniAx := cDataIni + (nQtdDia - 1)
			If cDtIniAx <= cDataFim
				aadd(aMeta,{cDataIni, cDtIniAx, nQtdMeta})
			Else
				aadd(aMeta,{cDataIni, cDataFim, nQtdMeta})
			EndIf
			cDataIni := cDataIni + nQtdDia
		EndDo
	EndCase
	
Return aMeta

//-------------------------------------------------------------------
/*/{Protheus.doc} TM153FMeta()
Função carrega o model TMSA153D para criar as metas
@author  Ruan Ricardo Salvador
@since   22/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function TM153FMeta(aMeta, aTipVei, oDialog)
	Local oModelDLG := Nil //Modelo da tela TMSA153D
	Local nX, nI
	
	oModelDLG := FWLoadModel('TMSA153D')
	oModelDLG:SetOperation(MODEL_OPERATION_UPDATE)
	oModelDLG:Activate()
	
	//Meta por tipo de veiculo
	If !Empty(aTipVei)
		ProcRegua(Len(aTipVei)+(Len(aMeta)*Len(aTipVei)))
		For nI := 1 to len(aTipVei)
			IncProc()
			For nX := 1 to Len(aMeta)
				IncProc()
				oModelDLG:SetValue('GRID_TPV'+aTipVei[nI],'DLG_DATINI', aMeta[nX][1])
				oModelDLG:SetValue('GRID_TPV'+aTipVei[nI],'DLG_DATFIM', aMeta[nX][2])
				oModelDLG:SetValue('GRID_TPV'+aTipVei[nI],'DLG_QTD'   , aMeta[nX][3])
				If nX < Len(aMeta)
					oModelDLG:GetModel('GRID_TPV'+aTipVei[nI]):AddLine()
				EndIf
			Next nX
			oModelDLG:GetModel('GRID_TPV'+aTipVei[nI]):SetLine(1)
		Next nI
	Else		
		ProcRegua(Len(aMeta))			
		For nX := 1 to Len(aMeta)
			IncProc()
			oModelDLG:SetValue('GRID_META','DLG_DATINI', aMeta[nX][1])
			oModelDLG:SetValue('GRID_META','DLG_DATFIM', aMeta[nX][2])
			oModelDLG:SetValue('GRID_META','DLG_QTD'   , aMeta[nX][3])
			If nX < Len(aMeta)
				oModelDLG:GetModel('GRID_META'):AddLine()
			EndIf
		Next nX
		oModelDLG:GetModel('GRID_META'):SetLine(1)
	EndIf
	oDialog:End()
	
	//Executa a tela de metas com o modelo carregado
	FWExecView(STR0030,'TMSA153D',MODEL_OPERATION_UPDATE,, { || .T. },{ || .T.  },,,{ || .T. },,,oModelDLG)
		
Return 