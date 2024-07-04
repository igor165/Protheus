#include "PMSC115.ch"
#include "protheus.ch"
#include "pmsicons.ch"

Static _oPMSC1151 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PMSC115  ³ Autor ³ Adriano Ueda          ³ Data ³ 22-05-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de consulta a Alocacao das Equipes do Projeto.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC115(cProjeto,cVersao,oTree,cArquivo)

Local cAlias
Local nRecAlias
Local nz,nx
Local aChave	:= {}
Local aRecursos	:= {}
Local cNomeTrb

Private cMarca
Private cCadastro	:= STR0001 //"Consulta a alocacao de Equipes"
Private aRotina := MenuDef()
Private cProjSim := cProjeto
Private cVersSim := cVersao


If AMIIn(44) .And. !PMSBLKINT()
	If cProjeto <> Nil
		If oTree!= Nil
			cAlias	:= SubStr(oTree:GetCargo(),1,3)
			nRecAlias	:= Val(SubStr(oTree:GetCargo(),4,12))
		Else 
			cAlias := (cArquivo)->ALIAS
			nRecAlias := (cArquivo)->RECNO
		EndIf
		If cAlias == "AF8"
			dbSelectArea("AF8")
			dbGoto(nRecAlias)
			dbSelectArea("AFC")
			dbSetOrder(1)
			dbSeek(xFilial()+AF8->AF8_PROJET+cVersao+Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)))
			PmsLoadRec(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aRecursos)
		ElseIf cAlias == "AFC"
			dbSelectArea("AFC")
			dbGoto(nRecAlias)
			PmsLoadRec(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aRecursos)
		ElseIf cAlias == "AF9"
			dbSelectArea("AF9")
			dbGoto(nRecAlias)
			PmsLoadRec(AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,aRecursos,.T.)
		Endif
		ChkFile("AED",.F.,"__AED")
		dbSelectArea("SIX")
		dbSetOrder(1)
		dbSeek("AED")
		While !Eof() .And. INDICE == "AED"
			aAdd(aChave,{CHAVE,ORDEM})
			dbSkip()
		End
		aStruTRB	:= AED->(dbStruct())
	
		dbSelectArea("AED")
		dbCloseArea()	
		
		If _oPMSC1151 <> Nil
			_oPMSC1151:Delete()
			_oPMSC1151 := Nil
		Endif
		
		_oPMSC1151 := FWTemporaryTable():New( "AED" )  
		_oPMSC1151:SetFields(aStruTRB) 	
		_oPMSC1151:AddIndex("1", {"AED_FILIAL","AED_EQUIP"})
		_oPMSC1151:AddIndex("2", {"AED_FILIAL","AED_DESCRI"})
		
		//------------------
		//Criação da tabela temporaria
		//------------------
		_oPMSC1151:Create()			
		
		dbSelectArea("AED")
		
		For nz := 1 to Len(aRecursos)
			AE8->(dbSetOrder(1))
			AE8->(dbSeek(xFilial("AE8")+aRecursos[nz]))
         dbSelectArea("AED")
         dbSetOrder(1)
         If !Empty(AE8->AE8_EQUIP) .And. !dbSeek(xFilial("AED")+AE8->AE8_EQUIP)
         	__AED->(dbSetOrder(1))
         	__AED->(dbSeek(xFilial("AED")+AE8->AE8_EQUIP))
	         RecLock("AED",.T.)
				For nx := 1 to fCount()
					FieldPut(nx,__AED->(FieldGet(FieldPos("AED"+Substr(AED->(FieldName(nx)),4,9)))))
				Next
            MsUnlock()
    		EndIf
		Next nz		
		dbSelectArea("AED")
		dbSetOrder(1) 
		dbSeek(xFilial("AED"))
		FATPDLogUser("PMSC115")
		MarkBrow("AED","AED_OK",,,,GetMark(,"AED","AED_OK")) 
		dbSelectArea("AED")
		dbCloseArea()
		dbSelectArea("__AED")
		dbCloseArea()
		ChkFile("AED",.F.)
		If _oPMSC1151 <> Nil
			_oPMSC1151:Delete()
			_oPMSC1151 := Nil
		Endif
   Else
		dbSelectArea("AED")
		dbSetOrder(1)
		FATPDLogUser("PMSC115")
		MarkBrow("AED","AED_OK",,,,GetMark(,"AED", "AED_OK"))
	EndIf
End If
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PMSC115View³ Autor ³ Adriano Ueda         ³ Data ³ 22-05-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta uma tela de consulta com a alocacao da equipe seleciona-³±±
±±³          ³da.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC115View(cAlias, nReg, nOpcx)
Local aConfig
Local dIniGnt
Local aGantt 
Local nTsk
Local lRet		:= .T.
Local aDependencia	:= {}

// parametros da consulta

If aConfig	== Nil
	aConfig := {6,.F.,.T.,.T.,.T.,dDataBase-20,dDataBase+20,3,1}
	If !ParamBox({	;
				{3,STR0004,aConfig[1],{STR0005, STR0006, STR0007, STR0008, STR0009, STR0010},70,,.F.},; //"Escala de Tempo"###"Diario"###"Semanal"###"Mensal"###"Mensal (Zoom 30%)"###"Bimestral"###"Melhor escala"
				{4,STR0011,aConfig[2],STR0033,45,,.F.},; //"Exibir detalhes :"###"Codigo" //"Projeto/Tarefa"
				{4,"",aConfig[3],STR0012,40,,.F.},; //"Exibir detalhes :"###"Codigo"
				{4,"",aConfig[4],STR0013,40,,.F.},; //"Descricao"
				{4,"",aConfig[5],STR0014,45,,.F.},; //"Exibir Tarefas"
				{1,STR0015,aConfig[6],"","","","",45,.T.},; //"Data Inicial"
				{1,STR0016,aConfig[7],"","","","",45,.T.},; //"Data Final"
				{3,STR0017,aConfig[8],{STR0018,STR0019,STR0020},60,,.F.},;//"Considerar"###"Todas as tarefas"###"Tarefas finalizadas"###"Tarefas a executar"###
				{3,STR0034,aConfig[9],{STR0035,STR0036},60,,.F.}},STR0021,aConfig) //"Parametros" //"Ordenado Por"###"Recurso"###"Datas"
		Return lRet
	Endif					
EndIf

While lRet
	lRet :=  AuxC115View(@aConfig, @dIniGnt, @aGantt, @nTsk,@aDependencia)
EndDo
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AuxC115View³ Autor ³ Adriano Ueda         ³ Data ³ 22-05-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta uma tela de consulta com a alocacao da equipe seleciona-³±±
±±³          ³da.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AuxC115View(aConfig, dIniGnt, aGantt, nTsk,aDependencia)
Local lRet := .F.

Local aAreaAE8 := AE8->(GetArea())
Local aAreaAED := AED->(GetArea())

Local nTop    := oMainWnd:nTop+35
Local nLeft   := oMainWnd:nLeft+10
Local nBottom := oMainWnd:nBottom-12
Local nRight  := oMainWnd:nRight-10
Local lInverte	:= ThisInv()
Local cMarca	:= ThisMark()
Local aRecAF9	:= {}

Local aAE8xAF9	:= {}

Local oFont
Local oDlg
Local oBtn
Local oBar
Local nx := 0
Local nUMaxEqp := 0
Local nLenRec	:=	30
Local nLenTar	:=	75

Local aCorBarras := LoadCorBarra( "MV_PMSACOR" )
Local aRGB := {}
Local aAloc	:=	{}
Local lFWGetVersao := .T.
Local aButtons	:= {}

If aGantt == Nil
	aGantt := {} 
	
	RegToMemory("AFA",.T.)
	RegToMemory("AFB",.T.)
	
	// recupera o codigo e a descricao das equipes selecionadas
	// e os armazena em aEquipes
	AED->(dbSetOrder(1))
	AED->(dbSeek(xFilial()))   //GoTop()- Posiciona no inicio do arquivo cons. Filial
	
	While AED->(AED_FILIAL == xFilial() .And. ! Eof())
		If (AED->AED_OK == cMarca .And. !lInverte) .Or. (AED->AED_OK <> cMarca .And. lInverte)
			aRecAF9	:= {}
			aAE8xAF9	:= {}

			MsgRun(STR0037+AED->AED_EQUIP, ,{|| aAloc := PmsEqpAloc(AED->AED_EQUIP,aConfig[6],"00:00",aConfig[7],"24:00",aConfig[8],cProjSim,cVersSim,,aRecAF9,aAE8xAF9)} ) //'Verificando alocacao da equipe '

			If HasTemplate( "CCT" ) 
				MsgRun(STR0037+AED->AED_EQUIP, ,{|| aAloc := PmsEqpCUAloc(AED->AED_EQUIP,aConfig[6],"00:00",aConfig[7],"24:00",aConfig[8],cProjSim,cVersSim,,aRecAF9,aAE8xAF9,aAloc)} ) //'Verificando alocacao da equipe '
			EndIf
	
			nUMaxEqp := UMaxEquip(AED->AED_EQUIP)
			
			If !Empty(aAloc)
				aAdd(aGantt,{{"",AED->AED_EQUIP,AED->AED_DESCRI},{},CLR_HBLUE,})
				For nx := 1 to Len(aAloc)-1
					If aAloc[nx][3] > 0
						dIni	:= aAloc[nx][1]
						cHIni	:= aAloc[nx][2]
						dFim	:= aAloc[nx+1][1]
						cHFim	:= aAloc[nx+1][2]
						cView	:= "PmsDispBox({	{'"+'Equipe '+"','"+AED->AED_EQUIP+"'},"+;
												"	{'"+'Descricao'+"','"+AED->AED_DESCRI+"'},"+;
												"	{'"+'% Aloc.Max.'+"','"+Transform(nUMaxEqp, "@E 9999.99%")+"'},"+;
												"	{'"+'Data Inicial'+"','"+DTOC(dIni)+"-"+cHIni+"'},"+;
												"	{'"+'Data Final'+"','"+DTOC(dFim)+"-"+cHFim+"'},"+;
												"	{'"+'% Aloc.Periodo'+"','"+Transform(aAloc[nx][3],"@E 9999.99%")+"'}},2,'"+'Detalhes'+"',{40,120},,1)"
						
						// o calculo do tom da cor e feito atraves de regra de tres, sendo:
						//
						// 255 - o valor maximo possivel para o tom de verde (alocacao minima)
						// 155 - o valor minimo possivel para o tom de verde (alocacao maxima)
						
						aRGB := ValorCorBarra( "2" ,aCorBarras ,2 )					
						aAdd(aGantt[Len(aGantt)][2],{dIni,cHIni,dFim,cHFim,"",If(aAloc[nx][3]>nUMaxEqp,ValorCorBarra( "1" ,aCorBarras ) ;
																						 		,RGB( (255-Int(aAloc[nx][3]/nUMaxEqp*((255-aRGB[1])))) ,(255-Int(aAloc[nx][3]/nUMaxEqp*((255-aRGB[2])))) ,(255-Int(aAloc[nx][3]/nUMaxEqp*((255-aRGB[3])))) ) ;
																		),cView,2,CLR_BLACK})
	
																		
					EndIf
				Next
				If aConfig[5]
					Processa({|| CarregaGantt(@aGantt,aRecAf9,aAE8XAF9,aConfig,aDependencia,@nLenRec,@nLenTar)},STR0038+AED->AED_EQUIP,STR0038+AED->AED_EQUIP)	 //"Carregando tarefas de "###"Carregando tarefas de "
				EndIf
			EndIf
		EndIf
		dbSelectArea("AED") 
		AED->(dbSkip()) 
	End
Else
	For nX := 1 To Len(aGantt)
		If Empty(aGantt[nX,1,2])
 		// o fator eh 3 porque geralmente a tarefa esta composta por numeros.
			nLenTar	:=	 Max(nLenTar,Len(aGantt[nX,1,1])*3)
		Else
			nLenRec	:=	 Max(nLenRec,Len(aGantt[nX,1,2])*3.7)
		Endif
	Next
EndIf
	
If Empty(aGantt)
	Aviso(STR0023,STR0024,{STR0025},2) //"Atencao!"###"Nao existem projetos alocados para este recurso na data selecionada. Verifique o recurso e o periodo selecionado."###"Fechar"
Else
	DEFINE FONT oFont NAME "Arial" SIZE 0, -10
	DEFINE MSDIALOG oDlg TITLE STR0026 OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight
		oDlg:lMaximized := .T.	

	If !lFWGetVersao .or. GetVersao(.F.) == "P10"

		DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

		@ 1000,38 BUTTON "OK" SIZE 35,12 ACTION {|| Nil} OF oDlg PIXEL

		// opcoes
		oBtn := TBtnBmp():NewBar(BMP_OPCOES, BMP_OPCOES,,, TIP_OPCOES, {|| If(A115CfgEqp(cVersao, @oDlg,aConfig,@dIniGnt,aGantt),(oDlg:End(),lRet := .T.),Nil) },.T.,oBar,,, TIP_OPCOES)
		oBtn:cTitle := TOOL_OPCOES

		// retroceder calendario
		oBtn := TBtnBmp():NewBar(BMP_RETROCEDER_CAL, BMP_RETROCEDER_CAL,,, TIP_RETROCEDER_CAL, {|| (PmsPrvGnt(cVersao,@oDlg,aConfig,@dIniGnt,aGantt,@nTsk),oDlg:End(),lRet := .T.) },.T.,oBar,,, TIP_RETROCEDER_CAL)
		oBtn:cTitle := TOOL_RETROCEDER_CAL

		// avancar calendario	
		oBtn := TBtnBmp():NewBar(BMP_AVANCAR_CAL, BMP_AVANCAR_CAL,,, TIP_AVANCAR_CAL, {|| (PmsNxtGnt(cVersao,@oDlg,aConfig,@dIniGnt,aGantt,@nTsk),oDlg:End(),lRet := .T.) },.T.,oBar,,, TIP_AVANCAR_CAL)
		oBtn:cTitle := TOOL_AVANCAR_CAL

        // cores
		oBtn := TBtnBmp():NewBar( BMP_CORES ,BMP_CORES ,, ,TIP_CORES , {|| {PMSColorGantt("MV_PMSACOR") ,oDlg:End() ,lRet := .T. ,lAtualiza := .T.} },.T.,oBar,,,TIP_CORES)
		oBtn:cTitle := TOOL_CORES
	
		// sair		
		oBtn := TBtnBmp():NewBar(BMP_SAIR, BMP_SAIR,,, TIP_SAIR, {|| oDlg:End() },.T.,oBar,,, TOOL_SAIR)
		oBtn:cTitle := TOOL_SAIR

	Else	
		AADD(aButtons, {BMP_OPCOES			, {|| If(A115CfgEqp(cVersao, @oDlg,aConfig,@dIniGnt,aGantt),(oDlg:End(),lRet := .T.),Nil) }	, TIP_OPCOES })
		AADD(aButtons, {BMP_RETROCEDER_CAL	, {|| (PmsPrvGnt(cVersao,@oDlg,aConfig,@dIniGnt,aGantt,@nTsk),oDlg:End(),lRet := .T.) }		, TIP_RETROCEDER_CAL})
		AADD(aButtons, {BMP_AVANCAR_CAL		, {|| (PmsNxtGnt(cVersao,@oDlg,aConfig,@dIniGnt,aGantt,@nTsk),oDlg:End(),lRet := .T.) }		, TIP_AVANCAR_CAL })
		AADD(aButtons, {BMP_CORES			, {|| {PMSColorGantt("MV_PMSACOR") ,oDlg:End() ,lRet := .T. ,lAtualiza := .T.} }				, TIP_CORES})
		EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButtons,,,,,.F.,.F.)
	Endif

	PmsGantt(aGantt,aConfig,@dIniGnt,,oDlg,{14,1,(nBottom/2)-40,(nRight/2)-4},{{STR0033,nLenTar},{STR0012,nLenRec},{STR0031,105}},@nTsk,aDependencia,,,,{1,2,3}) //"Codigo"###"Nome" //"Projeto/Tarefa"
	
	ACTIVATE MSDIALOG oDlg
EndIf

RestArea(aAreaAED)
RestArea(aAreaAE8)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UMaxEquip  ³ Autor ³ Adriano Ueda         ³ Data ³ 22-05-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula a unidade maxima de uma equipe                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function UMaxEquip(cEquipe)
Local aAreaAE8 := AE8->(GetArea())
Local nUnMax   := 0

dbSelectArea("AE8")
dbSetOrder(4) // AE8_FILIAL + AE8_EQUIP + AE8_RECURS
AE8->(MSSeek(xFilial("AE8") + cEquipe))

While (!Eof() .And. AE8->AE8_EQUIP==cEquipe)
	nUnMax += AE8->AE8_UMAX
	AE8->(dbSkip())
End

RestArea(aAreaAE8)
Return nUnMax
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CarregaGant³ Autor ³ Bruno Sobieski       ³ Data ³ 10-06-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega o GANTT nas alocacao de recursos com uma regua        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CarregaGantt(aGantt,aRecAF9,aAE8xAF9,aConfig,aDependencia,nLenRec,nLenTar)
Local	aGanttTmp	:=	{}
Local nX			:=	0
Local nPosAE8		:=	0
Local	cRecurso	:=	""
Local cDescriRec	:=	""
Local nColor		:=	0
Local aCorBarras 	:= LoadCorBarra( "MV_PMSACOR" )
	

ProcRegua(Len(aRecAF9))
For nx := 1 to Len(aRecAF9)
	dbSelectArea("AF9")				
	dbGoto(aRecAF9[nx])
	If (nPosAE8	:=	AScan(aAE8xAF9,{|x| x[1] == nX})) > 0
		AE8->(MsGoto(aAE8xAF9[nPosAE8][2]))
		cRecurso		:=	AE8->AE8_RECURS
		cDescriRec  	:=	FATPDObfuscate(AE8->AE8_DESCRI,"AE8_DESCRI",,.T.)    
	Else
		cRecurso		:=	""
		cDescriRec  	:=	"" 
	Endif
	IncProc(STR0039+AF9->AF9_TAREFA) //'Carregando tarefa '
	dbSelectArea("AF9")
 	nColor	:=	RGB( (255-Int(MAx(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[1])/100))) ,(255-Int(Max(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[2])/100))) ,(255-Int(Max(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[3])/100))) )
	Do Case
		Case !Empty(AF9->AF9_DTATUF)
			aAdd(aGanttTmp,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,cRecurso,cDescriRec},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,"["+AllTrim(AF9->AF9_PROJET)+AF9->AF9_TAREFA+"]:"+Alltrim(AF9->AF9_DESCRI)+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,"PmsViewTask("+STR(AF9->(RecNo()))+")",1,CLR_GRAY}},nColor ,}) 
		Case !Empty(AF9->AF9_DTATUI)
			aAdd(aGanttTmp,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,cRecurso,cDescriRec},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,"["+AllTrim(AF9->AF9_PROJET)+AF9->AF9_TAREFA+"]:"+Alltrim(AF9->AF9_DESCRI)+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,"PmsViewTask("+STR(AF9->(RecNo()))+")",1,CLR_BROWN}},nColor ,})
		Case dDataBase > AF9->AF9_START
			aAdd(aGanttTmp,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,cRecurso,cDescriRec},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,"["+AllTrim(AF9->AF9_PROJET)+AF9->AF9_TAREFA+"]:"+Alltrim(AF9->AF9_DESCRI)+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,"PmsViewTask("+STR(AF9->(RecNo()))+")",1,CLR_HRED}},nColor ,}) 
		OtherWise
			aAdd(aGanttTmp,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,cRecurso,cDescriRec},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,"["+AllTrim(AF9->AF9_PROJET)+AF9->AF9_TAREFA+"]:"+Alltrim(AF9->AF9_DESCRI)+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,"PmsViewTask("+STR(AF9->(RecNo()))+")",1,CLR_GREEN}},nColor ,})
	EndCase
	nLenRec	:=	 Max(nLenRec,Len(Alltrim(cRecurso))*3.7)
 	// o fator eh 3 porque geralmente a tarefa esta composta por numeros.
	nLenTar	:=	 Max(nLenTar,Len(Alltrim(AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA))*3)
	dbSelectArea("AFD")
	dbSetOrder(1)
	If MsSeek(xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
		While !AFD->(EOF()) .And. xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA
			nPos := aScan( aDependencia ,{|aTarefa| aTarefa[1] == AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_TAREFA})
			If nPos > 0
				aadd( aDependencia[nPos][2],{ AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_PREDEC ,AFD->AFD_TIPO } )
			Else	                               
				aadd( aDependencia ,{ AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_TAREFA ,{ {AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_PREDEC ,AFD->AFD_TIPO} }} )
			Endif		
			AFD->(dbSkip())
		End
	EndIf
Next nx	
If aConfig[9]==1
	//Ordena por recurso
	aSort(aGanttTmp,,,{|x,y| x[1][2] < y[1][2]})
Else                   
	//Ordena por data de inicio
	aSort(aGanttTmp,,,{|x,y| Dtos(x[2][1][1])+x[2][1][2]+Dtos(x[2][1][3])+x[2][1][4] < Dtos(y[2][1][1])+y[2][1][2]+Dtos(y[2][1][3])+y[2][1][4]})	
Endif				               
For nX	:=	1	To Len(aGanttTmp)
	AAdd(aGantt,aGanttTmp[nX])
	If aConfig[9]==1 
		If cRecurso == aGantt[Len(aGantt)][1][2]
			aGantt[Len(aGantt)][1][2]	:= ""
			aGantt[Len(aGantt)][1][3]	:= ""
		Else
			cRecurso	:=	aGantt[Len(aGantt)][1][2]
		Endif
	Endif
Next nX

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³115CfgEqp³ Autor ³ Adriano Ueda           ³ Data ³ 01-08-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe uma tela com as configuracoes de visualizacao do Gantt  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A115CfgEqp(cVersao,oDlg,aConfig,dIni,aGantt)
Local lRet		:= .F.
Local aOldCfg	:= aClone(aConfig)

If ParamBox({	{3,STR0004,aConfig[1],{STR0005, STR0006, STR0007, STR0008, STR0009, STR0010},70,,.F.},; //"Escala de Tempo"###"Diario"###"Semanal"###"Mensal"###"Mensal (Zoom 30%)"###"Bimestral"###"Melhor escala"
			{4,STR0011,aConfig[2],STR0033,45,,.F.},; //"Exibir detalhes :"###"Codigo" //"Projeto/Tarefa"
			{4,"",aConfig[3],STR0012,40,,.F.},; //"Exibir detalhes :"###"Codigo"
			{4,"",aConfig[4],STR0013,40,,.F.},; //"Descricao"
			{4,"",aConfig[5],STR0014,45,,.F.},; //"Exibir Tarefas"
			{1,STR0015,aConfig[6],"","","","",45,.T.},; //"Data Inicial"
			{1,STR0016,aConfig[7],"","","","",45,.T.},; //"Data Final"
			{3,STR0017,aConfig[8],{STR0018,STR0019,STR0020},60,,.F.},;//"Considerar"###"Todas as tarefas"###"Tarefas finalizadas"###"Tarefas a executar"###
			{3,STR0034,aConfig[9],{STR0035,STR0036},60,,.F.}},STR0021,aConfig) //"Parametros" //"Ordenado Por"###"Recurso"###"Datas"

	If aOldCfg[1] != aConfig[1]
		dIni := PMS_EMPTY_DATE
	EndIf
	lRet := .T.
	If aConfig[5]!=aOldCfg[5]
		aGantt	:= Nil
	EndIf
	If aConfig[6]!=aOldCfg[6]
		aGantt	:= Nil
	EndIf
	If aConfig[7]!=aOldCfg[7]
		aGantt	:= Nil
	EndIf
	If aConfig[8]!=aOldCfg[8]
		aGantt	:= Nil
	EndIf
	If aConfig[9]!=aOldCfg[9]
		aGantt	:= Nil
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002, "AxPesqui"  , 0 , 1},; //"Pesquisar"
							{ STR0003, "PMSC115View", 0 , 2 }} //"Consultar"
Return(aRotina)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   



//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
