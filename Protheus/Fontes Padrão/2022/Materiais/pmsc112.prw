#include "pmsc112.ch"
#include "protheus.ch"
#include "pmsicons.ch"

Static _oPMSC1121

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSc112  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de consulta a Alocacao dos recursos do Projeto por  ³±±
±±³          ³ Equipe                                                       ³±±
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
Function PMSC112(cProjeto,cVersao,oTree,cArquivo,cEquipe)

Local cAlias
Local nRecAlias
Local nz,nx
Local aChave	:= {}
Local aRecursos	:= {}
Local cNomeTrb

Private cMarca
Private cCadastro	:= STR0057 //"Consulta a Alocacao de Recursos por Equipe"
Private aRotina := MenuDef()
Private cProjSim := cProjeto
Private cVersSim := cVersao


If AMIIn(44) .And. !PMSBLKINT()
	If cEquipe <> Nil .And. !Empty(cEquipe)
		aArea		:=	GetArea()
		aAreaAF8	:=	AF8->(GetArea())
		dbSelectArea("AED")
		dbSetOrder(1)
		If dbSeek(xFilial()+cEquipe)	
			PMSc112View("AE8",AE8->(RecNo()),2)
		EndIf
		RestArea(aAreaAF8)
		RestArea(aArea)
	//Se foram enviados os recursos, nao preciso abrir o browse, chamo a consulta para os recursos enviados
	Else
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

			If _oPMSC1121 <> Nil
				_oPMSC1121:Delete()
				_oPMSC1121 := Nil
			Endif
			
			_oPMSC1121 := FWTemporaryTable():New( "AED" )  
			_oPMSC1121:SetFields(aStruTRB) 	
			_oPMSC1121:AddIndex("1", {"AED_FILIAL","AED_EQUIP"})
			_oPMSC1121:AddIndex("2", {"AED_FILIAL","AED_DESCRI"})
			
			//------------------
			//Criação da tabela temporaria
			//------------------
			_oPMSC1121:Create()	

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
			mBrowse(6,1,22,75,"AED")
			dbSelectArea("AED")
			dbCloseArea()
			If Select("__AED") > 0
				dbSelectArea("__AED")
				dbCloseArea()
			EndIf
			ChkFile("AED",.F.)
			
			If _oPMSC1121 <> Nil
				_oPMSC1121:Delete()
				_oPMSC1121 := Nil
			Endif
			
	   Else
			dbSelectArea("AED")
			dbSetOrder(1)
			mBrowse(6,1,22,75,"AED")
		EndIf
	EndIf
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSc112View³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma tela de consulta com a alocacao do recurso selecio- ³±±
±±³          ³nado.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSc112View(cAlias,nReg,nOpcx)

Local aConfig
Local dIniGnt
Local aGantt
Local aDependencia	:= {}
Local nTsk
Local lRet		:= .T.
If aConfig	== Nil
	aConfig := {6,.F.,.T.,.T.,.T.,dDataBase-20,dDataBase+20,3}
	If !ParamBox({	{3,STR0004,aConfig[1],{STR0005,STR0006,STR0007,STR0035,STR0036,STR0037},70,,.F.},; //"Escala de Tempo"###"Diario"###"Semanal"###"Mensal" //"Mensal (Zoom 30%)"###"Bimestral"###"Melhor escala"
				{4,STR0008,aConfig[2],STR0058,45,,.F.},; //"Exibir detalhes :"###"Codigo" //"Projeto/Tarefa"
				{4,"",aConfig[3],STR0009,40,,.F.},; //"Exibir detalhes :"###"Codigo"
				{4,"",aConfig[4],STR0010,40,,.F.},; //"Descricao"
				{4,"",aConfig[5],STR0011,45,,.F.},;				 //"Exibir Tarefas"
				{1,STR0012,aConfig[6],"","","","",45,.T.},; //"Data Inicial"
				{1,STR0013,aConfig[7],"","","","",45,.T.},;
				{3,STR0042,aConfig[8],{STR0043,STR0044,STR0045},60,,.F.} },;
				STR0014,aConfig) //"Data Final"###"Parametros" //"Considerar"###"Todas as tarefas"###"Tarefas finalizadas"###"Tarefas a executar"
       Return .F.
   Endif    
EndIf


While lRet
	lRet := Auxc112View(@aConfig,@dIniGnt,@aGantt,@nTsk,@aDependencia)
End

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Auxc112View³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma tela de consulta com a alocacao do recurso selecio- ³±±
±±³          ³nado.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Auxc112View(aConfig,dIniGnt,aGantt,nTsk,aDependencia)

Local nTop     := oMainWnd:nTop+35
Local nLeft    := oMainWnd:nLeft+10
Local nBottom  := oMainWnd:nBottom-12
Local nRight   := oMainWnd:nRight-10
Local nColor	:=	0
Local cEquipe  := AED->AED_EQUIP
Local oFont
Local oDlg
Local oBtn
Local oBar

Local lRet		:= .F.
Local aCorBarras := LoadCorBarra( "MV_PMSACOR" )
Local aRGB := {}
Local aRecAF9	:= {}
Local nLenRec	:=	30
Local nLenTar	:=	75
Local lFWGetVersao := .T.
Local aButtons	:= {}

Local nX := 0
Local nY := 0
Local aAreaAE8 := AE8->(GetArea())
Local aAloc		:=	{}
Local aRecAE8	:=	{}

RegToMemory("AFA",.T.)
RegToMemory("AFB",.T.)

If aGantt == Nil
	aGantt := {}
	AE8->(dbSetOrder(4))
	AE8->(dbSeek(xFilial()+cEquipe))   
	While AE8->(AE8_FILIAL = xFilial() .And. !Eof() .And. (Empty(cEquipe) .Or. AE8->AE8_EQUIP == cEquipe))	//loop para carregar todos os 
		aAdd(aRecAE8,AE8->(RECNO()))	
		AE8->(DbSkip())
	Enddo	            
	
	
	For nY := 1 To Len(aRecAE8)
		AE8->(MsGoTo(aRecAE8[nY]))
		aRecAF9	:= {}
		MsgRun(STR0059+AE8->AE8_RECURS, ,	{|| aAloc	:= PmsRetAloc(AE8->AE8_RECURS,aConfig[6],"00:00",aConfig[7],"24:00",aConfig[8],cProjSim,cVersSim,,aRecAF9)}) //'Verificando alocacao do recurso '
		If AF8comAJT(AF8->AF8_PROJET) //Validacao para composicao auxiliar(CCT)
			MsgRun(STR0058+AE8->AE8_RECURS, ,	{|| aAloc	:= PmsRetCUAloc(AE8->AE8_RECURS,aConfig[6],"00:00",aConfig[7],"24:00",aConfig[8],cProjSim,cVersSim, NIL,aRecAF9, NIL, NIL, NIL, aAloc)}) //'Verificando alocacao do recurso '
		EndIf	
		If !Empty(aAloc)
			aAdd(aGantt,{{"",AE8->AE8_RECURS,FATPDObfuscate(AE8->AE8_DESCRI,"AE8_DESCRI",,.T.)},{},CLR_HBLUE,})
			nLenRec	:=	 Max(nLenRec,Len(Alltrim(AE8->AE8_RECURS))*3.7)  
			For nx := 1 to Len(aAloc)-1
				If aAloc[nx][3] > 0
					dIni	:= aAloc[nx][1]  
					cHIni	:= aAloc[nx][2]
					dFim	:= aAloc[nx+1][1]
					cHFim	:= aAloc[nx+1][2]
					cView	:= "PmsDispBox({	{'"+STR0015+"','"+AE8->AE8_RECURS+"'},"+; //'Recurso '
											"	{'"+STR0016+"','"+FATPDObfuscate(AE8->AE8_DESCRI,"AE8_DESCRI",,.T.)+"'},"+; //'Descricao'
											"	{'"+STR0017+"','"+Transform(AE8->AE8_UMAX,"@E 9999.99%")+"'},"+; //'% Aloc.Max.'
											"	{'"+STR0018+"','"+If(AE8->AE8_SUPALO=="1",STR0046,STR0047)+"'},"+;										 //'Perm.Sup.Alo.'
											"	{'"+STR0019+"','"+DTOC(dIni)+"-"+cHIni+"'},"+; //'Data Inicial'
											"	{'"+STR0020+"','"+DTOC(dFim)+"-"+cHFim+"'},"+; //'Data Final'
											"	{'"+STR0021+"','"+Transform(aAloc[nx][3],"@E 9999.99%")+"'}},2,'"+STR0022+"',{40,120},,1)" //'% Aloc.Periodo'###'Detalhes'
					aRGB := ValorCorBarra( "2" ,aCorBarras ,2 )     
					aAdd(aGantt[Len(aGantt)][2],{dIni,cHIni,dFim,cHFim,"",If(aAloc[nx][3]>AE8->AE8_UMAX ,ValorCorBarra( "1" ,aCorBarras ) ;
		 		,RGB( (255-Int((aAloc[nx][3]/AE8->AE8_UMAX*100)*((255-aRGB[1])/100))) ,(255-Int((aAloc[nx][3]/AE8->AE8_UMAX*100)*((255-aRGB[2])/100))) ,(255-Int((aAloc[nx][3]/AE8->AE8_UMAX*100)*((255-aRGB[3])/100))) ) ;
																				),cView,2,CLR_BLACK})
				EndIf
			Next
			If aConfig[5]
				For nx := 1 to Len(aRecAF9)
					dbSelectArea("AF9")				
					dbGoto(aRecAF9[nx])
				 	nColor	:=	RGB( (255-Int(MAx(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[1])/100))) ,(255-Int(Max(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[2])/100))) ,(255-Int(Max(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[3])/100))) )
					Do Case
						Case !Empty(AF9->AF9_DTATUF)
							aAdd(aGantt,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,"",""},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,"["+AllTrim(AF9->AF9_PROJET)+AF9->AF9_TAREFA+"]:"+Alltrim(AF9->AF9_DESCRI)+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,"PmsViewTask("+STR(AF9->(RecNo()))+")",1,CLR_GRAY}},nColor ,}) 
						Case !Empty(AF9->AF9_DTATUI)
							aAdd(aGantt,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,"",""},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,"["+AllTrim(AF9->AF9_PROJET)+AF9->AF9_TAREFA+"]:"+Alltrim(AF9->AF9_DESCRI)+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,"PmsViewTask("+STR(AF9->(RecNo()))+")",1,CLR_BROWN}},nColor ,})
						Case dDataBase > AF9->AF9_START
							aAdd(aGantt,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,"",""},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,"["+AllTrim(AF9->AF9_PROJET)+AF9->AF9_TAREFA+"]:"+Alltrim(AF9->AF9_DESCRI)+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,"PmsViewTask("+STR(AF9->(RecNo()))+")",1,CLR_HRED}},nColor ,}) 
						OtherWise
							aAdd(aGantt,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,"",""},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,"["+AllTrim(AF9->AF9_PROJET)+AF9->AF9_TAREFA+"]:"+Alltrim(AF9->AF9_DESCRI)+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,"PmsViewTask("+STR(AF9->(RecNo()))+")",1,CLR_GREEN}},nColor ,})
					EndCase
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
			EndIf
		EndIf
	Next
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
	DEFINE MSDIALOG oDlg TITLE STR0026 OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight //"Alocacao do Recurso"
		oDlg:lMaximized := .T.	

	If !lFWGetVersao .or. GetVersao(.F.) == "P10"

		DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg
		
		@ 1000,38 BUTTON STR0049 SIZE 35,12 ACTION {|| Nil} OF oDlg PIXEL //"OK"
		
		// opcoes
		oBtn := TBtnBmp():NewBar(BMP_OPCOES, BMP_OPCOES,,, TIP_OPCOES, {|| If(PmsCfgRec(@oDlg,aConfig,@dIniGnt,aGantt),(oDlg:End(),lRet := .T.),Nil) },.T.,oBar,,, TIP_OPCOES)
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
		oBtn := TBtnBmp():NewBar(BMP_SAIR, BMP_SAIR,,, TIP_SAIR, {|| oDlg:End() },.T.,oBar,,, TIP_SAIR)
		oBtn:cTitle := TOOL_SAIR

	Else	
		AADD(aButtons, {BMP_OPCOES			, {|| If(PmsCfgRec(@oDlg,aConfig,@dIniGnt,aGantt),(oDlg:End(),lRet := .T.),Nil) }, TIP_OPCOES })
		AADD(aButtons, {BMP_RETROCEDER_CAL	, {|| (PmsPrvGnt(cVersao,@oDlg,aConfig,@dIniGnt,aGantt,@nTsk),oDlg:End(),lRet := .T.) }, TIP_RETROCEDER_CAL})
		AADD(aButtons, {BMP_AVANCAR_CAL		, {|| (PmsNxtGnt(cVersao,@oDlg,aConfig,@dIniGnt,aGantt,@nTsk),oDlg:End(),lRet := .T.) }, TIP_AVANCAR_CAL })
		AADD(aButtons, {BMP_CORES			, {|| {PMSColorGantt("MV_PMSACOR") ,oDlg:End() ,lRet := .T. ,lAtualiza := .T.} }, TIP_CORES})
		EnchoiceBar(oDlg,{|| oDlg:End()}, {|| oDlg:End()},,aButtons,,,,,.F.,.F.)
	Endif
		
   	PmsGantt(aGantt,aConfig,@dIniGnt,,oDlg,{14,1,(nBottom/2)-40,(nRight/2)-4},{{STR0058,nLenTar},{STR0009,nLenRec},{STR0034,105}},@nTsk,aDependencia,,,,{1,2,3},,,.F.)  //"Codigo"###"Nome" //"Projeto/Tarefa"

	FATPDLogUser("AUXC112VIEW")
	
	ACTIVATE MSDIALOG oDlg
EndIf
AE8->(dbSetOrder(1))
RestArea(aAreaAE8)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCfgRec³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe uma tela com as configuracoes de visualizacao do Gantt  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsCfgRec(oDlg,aConfig,dIni,aGantt)
Local lRet := .F.
Local aOldCfg	:= aClone(aConfig)

If 	ParamBox({	{3,STR0004,aConfig[1],{STR0005,STR0006,STR0007,STR0035,STR0036,STR0037},70,,.F.},; //"Escala de Tempo"###"Diario"###"Semanal"###"Mensal" //"Mensal (Zoom 30%)"###"Bimestral"###"Melhor escala"
				{4,STR0008,aConfig[2],STR0058,45,,.F.},; //"Exibir detalhes :"###"Codigo" //"Projeto/Tarefa"
				{4,"",aConfig[3],STR0009,40,,.F.},; //"Exibir detalhes :"###"Codigo"
				{4,"",aConfig[4],STR0010,40,,.F.},; //"Descricao"
				{4,"",aConfig[5],STR0011,45,,.F.},; //"Exibir Tarefas"
				{1,STR0012,aConfig[6],"","","","",45,.T.},; //"Data Inicial"
				{1,STR0013,aConfig[7],"","","","",45,.T.},;
				{3,STR0042,aConfig[8],{STR0043,STR0044,STR0045},60,,.F.} };
				,STR0014,aConfig,,,.F.,120,3) //"Data Final"###"Parametros" //"Considerar"###"Todas as tarefas"###"Tarefas finalizadas"###"Tarefas a executar"

	If aOldCfg[1] != aConfig[1]
		dIni	:= PMS_EMPTY_DATE
	EndIf
	If aOldCfg[5] != aConfig[5] .Or. aOldCfg[6] != aConfig[6] .Or. aOldCfg[7] != aConfig[7]
		aGantt := Nil
	EndIf
	If aOldCfg[8] != aConfig[8]
		aGantt	:= Nil
	EndIf
	lRet	:= .T.
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
							{ STR0003, "PMSC112View", 0 , 2 }} //"Consultar"
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

