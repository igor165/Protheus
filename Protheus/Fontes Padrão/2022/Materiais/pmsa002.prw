#INCLUDE "protheus.ch"
#INCLUDE "pmsa002.ch"
#include "PMSICONS.CH"

Static lFWCodFil := FindFunction("FWCodFil")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA002  ³ Autor ³ Cristiano G. da Cunha ³ Data ³ 18-02-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exportacao de projetos para o MS-Project atraves ³±±
±±³          ³ de arquivo texto.                                            ³±±
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
Function PMSA002()

If PMSBLKINT()
	Return Nil
EndIf
      
Processa({||A002Export()},STR0001) //"Exportando CSV. Aguarde..."

Return

Function A002Export()

Local nHandle
Local nRecAFC
Local cMv1
Local cMv2
Local cLin
Local cCampo1
Local cRetFun
Local lGravou
Local xCampo1
Local nCntCpo
Local cWrite	:= ""
Local nx
Local aEDTs

Local aCpExp1 		:= {}
Local cValWork 	:= ''
Local aDadosWork 	:= {}
Local cArqTmp 		:= "" 

PRIVATE nCntLin
PRIVATE lUsaAJT	:= .F.				// Variavel para determinaar se usa composicoes aux
PRIVATE cCadastro	:= STR0002 			//"Exportar projeto para arquivo .CSV"
PRIVATE aPredec   := {}
PRIVATE aRoteiro 	:= {}
PRIVATE aRet 		:= {}
PRIVATE aRotina 	:= {{"", "AxPesqui" , 0, 1, , .F.},;
                    	{"", "PMS200Dlg", 0, 2},;
                    	{"", "PMS200Dlg", 0, 3},;
                    	{"", "PMS200Alt", 0, 4},;
                    	{"", "PMS200Dlg", 0, 4}}
Private aCpSelec := {} 

Inclui   := .T.
Altera   := .F.
lRefresh := .T.

aCamposExc := {"FILIAL","PROJET","EDT","TAREFA","DESCRI","NIVEL","HUTEIS","TPMEDI","START","FINISH","HORAI","HORAF","TIPO","HRETAR"}

dbSelectArea("AF8")
dbSetOrder(1)
dbGoTop()
If ParamBox({	{1,STR0003,SPACE(TamSX3("AF8_PROJET")[1]),"","ExistCpo('AF8',MV_PAR01,1)","AF8","", 85 ,.T.},; //"Projeto"
			    {6,STR0004,SPACE(50),,,"", 55 ,.T.,STR0005},; //"Arquivo"###"Arquivo .CSV |*.CSV"
 			    {3,STR0006,1,{STR0007,STR0008,OemToAnsi(STR0040)},70,,.F.},; //Versao do MS-Project;Portugues;Ingles;Espanhol
				{1,STR0039,SPACE(Len(AF8->AF8_REVISA)),"","","","", 35 ,.F.},;//"Versao"
				{3,STR0034,1,{STR0035,STR0036},80,,.F.};//"Exportar"###'Projeto completo'###'Selecionar EDT'
			},STR0009,@aRet,,{{5,{|| A002CfgCol(aCamposExc)}}}) //"Versao do MS-Project"###"Portugues"###"Ingles"###"Exportar .CSV"
   			    
   	cArqTmp := Criatrab( , .f. ) + ".TMP"		    
	If (nHandle := FCreate(cArqTmp))== -1
		Alert(STR0038)//"Erro na criacao do arquivo temporario!"
		Return
	EndIf

	dbSelectArea("AF8")
	dbSeek(xFilial()+aRet[1])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Determina se usa composicoes aux   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lUsaAJT := AF8ComAJT( AF8->AF8_PROJET )

	If aRet[5]==2                       
		PmsSetF3('AF9',2)
		aRetEDT := PmsSelTsk(STR0037,"AF9/AFC","AFC",,"AF8",AF8->AF8_PROJET,.F.,.F.)//"Selecione a EDT a exportar"
		If  Len(aRetEDT)	== 0
			Return
		Else
			AFC->(MsGoTo(aRetEDT[2]))
			aEDTs	:=	{AFC->AFC_EDT}
			AFC->(DbSetOrder(2)) 
			PMSAFCFilh(@aEDTs,AFC->AFC_EDT)
		Endif			
	Endif
	If (nConfirma := AxVisual("AF8",Recno(),1)) == 1
		cMv1    := GetMv("MV_PMSEXP1")
		cMv2    := GetMv("MV_PMSEXP2")
		cMv1Aux := cMv1
		cMv2Aux := cMv2
		While Len(cMv1Aux) > 1
			nPosSep  := At("#",cMv1Aux)
			aAdd(aCpExp1,Substr(cMv1Aux,2,nPosSep-2))
		    aAdd(aCpSelec,Substr(cMv1Aux,2,nPosSep-2))  
			cMv1Aux := Substr(cMv1Aux,nPosSep+1,Len(cMv1Aux)-nPosSep)
		End
		While Len(cMv2Aux) > 1
			nPosSep  := At("#",cMv2Aux)
			aAdd(aCpExp1,Substr(cMv2Aux,2,nPosSep-2))
			aAdd(aCpSelec,Substr(cMv1Aux,2,nPosSep-2))  
			cMv2Aux := Substr(cMv2Aux,nPosSep+1,Len(cMv2Aux)-nPosSep)
		End
		nCntLin := 0
		aPredec := {}
		dbSelectArea("AFC")
		dbSetOrder(3)
		dbSelectArea("AF9")
		dbSetOrder(2)
		dbSelectArea("AFC")
		cRevisa := If(Empty(aRet[4]),AF8->AF8_REVISA,aRet[4])
		If dbSeek(xFilial("AFC")+AF8->AF8_PROJET+cRevisa)
			nRecAFC := Recno()
			ProcAFCPredec(AFC->AFC_PROJET+cRevisa+AFC->AFC_EDT)
			nCntLin := 0
			ProcRegua(Len(aRoteiro))			
			For nx := 1 to Len(aRoteiro)
				IncProc()
				If aRoteiro[nx,1]=="AFC" .And.PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,1,"ESTRUT",AFC->AFC_REVISA) .And. (aEDTs==Nil .Or. aScan(aEDTs, {|x| x==AFC->AFC_EDT}) > 0)
					nCntLin := nCntLin + 1
					cLin := ""
					dbSelectArea("AFC")
					dbGoto(aRoteiro[nx,2])
					For nCntCpo := 1 to Len(aCpExp1)
						If Substr(aCpExp1[nCntCpo],1,1) == "$"
							If aCpExp1[nCntCpo] <> "$A002PREDEC"
								cCpoFun := Substr(aCpExp1[nCntCpo],2,Len(aCpExp1[nCntCpo])-1)+'("AFC")'
								cRetFun := &(cCpoFun)
								cLin := cLin + Xls002Format(cRetFun) + "#"
							Else
								cLin := cLin + "#"
							EndIf
						Else
							cCampo1 := "AFC_" + aCpExp1[nCntCpo]
							xCampo1 := ""
							dbSelectArea("AFC")
							If FieldPos(cCampo1) > 0
								xCampo1 := &(cCampo1)
								If !Empty(xCampo1)
									If ValType(xCampo1) == "N"
										//Formatar o campo numerico conforme o SX3
										If !Empty( GetSx3Cache(cCampo1,"X3_TAMANHO") )
												xCampo1 := Str(xCampo1,GetSx3Cache(cCampo1,"X3_TAMANHO"),;
																		GetSx3Cache(cCampo1,"X3_DECIMAL"))
										Else
											xCampo1 := Str(xCampo1,17,4)
										EndIf
										If ( At(".",xCampo1) > 0 )
											xCampo1 := Stuff(xCampo1,At(".",xCampo1),1,",")
										EndIf
									ElseIf ValType(xCampo1) == "D"
										xCampo1 := DTOC(xCampo1)
									EndIf
								Else
									xCampo1 := ""
								EndIf
							EndIf
							cLin := cLin + Xls002Format(xCampo1) + "#"
						Endif
					Next
					cLin := Substr(cLin,1,Len(cLin)-1) + CHR(13) + CHR(10)
					FWrite(nHandle,cLin,Len(cLin))
				Else
					dbSelectArea("AF9")
					dbGoto(aRoteiro[nx,2])
					If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",AF9->AF9_REVISA) .And. (aEDTs==Nil .Or. aScan(aEDTs, {|x| x==AF9->AF9_EDTPAI}) > 0)
						nCntLin := nCntLin + 1
						cLin   := ""
						For nCntCpo := 1 to Len(aCpExp1)
							If Substr(aCpExp1[nCntCpo],1,1) == "$"
								cCpoFun := Substr(aCpExp1[nCntCpo],2,Len(aCpExp1[nCntCpo])-1)+'("AF9")'
								cRetFun := &(cCpoFun)
								cLin := cLin + Xls002Format(cRetFun) + "#"
							Else
								cCampo1 := "AF9_" + aCpExp1[nCntCpo]
								xCampo1 := ""
								dbSelectArea("AF9")
								If FieldPos(cCampo1) > 0
									xCampo1 := &(cCampo1)
									If !Empty(xCampo1)
										If ValType(xCampo1) == "N"
											//Formatar o campo numerico conforme o SX3
											If !Empty( GetSx3Cache(cCampo1,"X3_TAMANHO") )
													xCampo1 := Str(xCampo1,GetSx3Cache(cCampo1,"X3_TAMANHO"),;
																			GetSx3Cache(cCampo1,"X3_DECIMAL"))
											Else
												xCampo1 := Str(xCampo1,17,4)
											EndIf
											If ( At(".",xCampo1) > 0 )
												xCampo1 := Stuff(xCampo1,At(".",xCampo1),1,",")
											EndIf
										ElseIf ValType(xCampo1) == "D"
											xCampo1 := DTOC(xCampo1)
										EndIf
									Else
										If ValType(xCampo1) == "N"
											xCampo1 := Str(xCampo1,17,4)
											xCampo1 := Stuff(xCampo1,At(".",xCampo1),1,",")										
										Else										
											xCampo1 := ""
										EndIf
									EndIf
								Else
									cCampo1 := "AFD_" + aCpExp1[nCntCpo]
									xCampo1 := ""
									dbSelectArea("AFD")
									If ( FieldPos(cCampo1) > 0 )										
										xCampo1 := AFDInfoPred(cCampo1)
										If Empty(xCampo1)
											xCampo1 := ""
										EndIf
									EndIf
								EndIf
								cLin := cLin + Xls002Format(xCampo1) + "#"
							Endif
						Next
						cLin := Substr(cLin,1,Len(cLin)-1) + CHR(13) + CHR(10)
						FWrite(nHandle,cLin,Len(cLin))
					Endif
				EndIf
			Next
		EndIf
	EndIf
	fClose(nHandle)
	__CopyFile( cArqTmp, aRet[2])
	FErase(cArqTmp)	

Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A002CfgCol ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 07-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Configuracao das colunas do projeto a serem exportadas para o ³±±
±±³          ³MS-Project.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array com os campos padroes                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A002CfgCol(aCamposExc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local nCampos1
Local nCampos2
Local nPos1      := 0
Local nPos2      := 0
Local cCampoAux
Local aCampos1 	:= {}
Local aCampos2 	:= {}
Local aCamposA 	:= {}
Local aCamposB 	:= {}
Local aBtn 		:= Array(6)
Local oCampos1
Local oCampos2
Local oBtn1
Local oBtn2
Local lCampos1 	:= .T.
Local lCampos2 	:= .F.
Local aFunc 		:= { 	{STR0013,"$A002CODIGO"},; //"*Codigo da EDT/Tarefa"
							{STR0014,"$A002NIVEL"},; //"*Nivel da Estrutura de Topicos"
							{STR0015,"$A002DESCRI"},; //"*Descricao da EDT/Tarefa"
							{STR0016,"$A002DATAI"},; //"*Data e Hora Inicial da EDT/Tarefa"
							{STR0017,"$A002DATAF"},; //"*Data e Hora Final da EDT/Tarefa"
							{STR0018,"$A002PREDEC"},; //"*Predecessoras"
							{STR0019,"$A002ID"} ;     //"*ID"
						} 
Local aFuncNO 		:= {	{STR0033,"$A002CONF"},; //"%Concluido"
                    	    {STR0043,"$A002NR"}, ; // "Nome de Recursos"
							{STR0044,"$A002ESF"} ;     //'*Esforço Real'
                    	}
Local nx 			:= 0
Local nCnt1		:= 0
Local nCnt2 		:= 0

Local lA002UsrBlk := ExistBlock("PM002BLK")
Local lRetUsrBlk  := .F.

DEFAULT aCamposExc := {"FILIAL"}

nOrdSX3  := SX3->(IndexOrd())
nRegSX3  := SX3->(Recno())

cPln1SX6 := GetMv("MV_PMSEXP1")
cPln2SX6 := GetMv("MV_PMSEXP2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do array de campos selecionados                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While At("#",cPln1SX6) <> 0
	nPosSep := At("#",cPln1SX6)
	aAdd(aCampos2,{,})
	aCampos2[Len(aCampos2)][2] := AllTrim(Substr(cPln1Sx6,2,nPosSep-2))
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek("AF9"+"_"+aCampos2[Len(aCampos2)][2])
		aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
	ElseIf dbSeek("AFC"+"_"+aCampos2[Len(aCampos2)][2])
		aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
	ElseIf dbSeek("AFD"+"_"+aCampos2[Len(aCampos2)][2])
		aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
	Else
		nPosFunc := aScan(aFunc,{|x| AllTrim(x[2])==AllTrim(aCampos2[Len(aCampos2)][2])}) 
		If nPosFunc > 0
			aCampos2[Len(aCampos2)][1] := aFunc[nPosFunc][1]
		Else
			nPosFunc := aScan(aFuncNO,{|x| AllTrim(x[2])==AllTrim(aCampos2[Len(aCampos2)][2])}) 
			If nPosFunc > 0
				aCampos2[Len(aCampos2)][1] := aFuncNO[nPosFunc][1]
			EndIf
		EndIf
	Endif
	cPln1Sx6 := Substr(cPln1SX6,nPosSep+1,Len(cPln1SX6)-nPosSep)
End

While At("#",cPln2SX6) <> 0
	nPosSep := At("#",cPln2SX6)
	aAdd(aCampos2,{,})
	aCampos2[Len(aCampos2)][2] := AllTrim(Substr(cPln2Sx6,2,nPosSep-2))
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek("AF9"+"_"+aCampos2[Len(aCampos2)][2])
		aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
	ElseIf dbSeek("AFC"+"_"+aCampos2[Len(aCampos2)][2])
		aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
	ElseIf dbSeek("AFD"+"_"+aCampos2[Len(aCampos2)][2])
		aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
	Else
		nPosFunc := aScan(aFunc,{|x| AllTrim(x[2])==AllTrim(aCampos2[Len(aCampos2)][2])}) 
		If nPosFunc > 0
			aCampos2[Len(aCampos2)][1] := aFunc[nPosFunc][1]
		Else
			nPosFunc := aScan(aFuncNO,{|x| AllTrim(x[2])==AllTrim(aCampos2[Len(aCampos2)][2])}) 
			If nPosFunc > 0
				aCampos2[Len(aCampos2)][1] := aFuncNO[nPosFunc][1]
			EndIf
		EndIf
	Endif
	cPln2Sx6 := Substr(cPln2SX6,nPosSep+1,Len(cPln2SX6)-nPosSep)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do array de campos disponiveis                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
If (dbSeek("AF9"))
	While SX3->X3_ARQUIVO == "AF9"
		If (X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL ).Or. SX3->X3_CAMPO == "AF9_DTREST"
			cCampoAux := AllTrim(Substr(SX3->X3_CAMPO,5,6))
			If Len(aCampos1) <> 0
				If  (nPosCampo := aScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
				Endif
			Else
				If  (nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
				Endif
			Endif
		Endif
		dbSkip()
	End
Endif

If (dbSeek("AFC"))
	While SX3->X3_ARQUIVO == "AFC"
		If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			cCampoAux := AllTrim(Substr(SX3->X3_CAMPO,5,6))
			If Len(aCampos1) <> 0
				If  (nPosCampo := aScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
				Endif
			Else
				If  (nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
				Endif
			Endif
		Endif
		dbSkip()
	End
Endif

If (dbSeek("AFD"))
	While SX3->X3_ARQUIVO == "AFD"
		If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			cCampoAux := AllTrim(Substr(SX3->X3_CAMPO,5,6))
			If Len(aCampos1) <> 0
				If  (nPosCampo := aScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
				Endif
			Else
				If  (nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := aScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
				Endif
			Endif
		Endif
		dbSkip()
	End
Endif

If Len(aCampos1) <> 0
	If  aScan(aCampos1,{|x| AllTrim(x[2]) == '$A002ESF' }) == 0 .And.;
		aScan(aCampos2,{|x| AllTrim(x[2]) == '$A002ESF' }) == 0
		aAdd(aCampos1,{STR0044,'$A002ESF'})
	Endif
Endif
For nx := 1 to Len(aFunc)
	If Len(aCampos1) <> 0
		If  (nPosCampo := aScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := aScan(aCamposExc,aFunc[nx][2])) == 0
			aAdd(aCampos1,{aFunc[nx][1],aFunc[nx][2]})
		Endif
	Else
		If  (nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := aScan(aCamposExc,aFunc[nx][2])) == 0
			aAdd(aCampos1,{aFunc[nx][1],aFunc[nx][2]})
		Endif
	Endif
Next

For nx := 1 to Len(aFuncNO)
	If Len(aCampos1) <> 0
		If  (nPosCampo := aScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(aFuncNO[nx][2])})) == 0 .And.;
			(nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFuncNO[nx][2])})) == 0 .And.;
			(nPosCampo := aScan(aCamposExc,aFuncNO[nx][2])) == 0
			aAdd(aCampos1,{aFuncNO[nx][1],aFuncNO[nx][2]})
		Endif
	Else
		If  (nPosCampo := aScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFuncNO[nx][2])})) == 0 .And.;
			(nPosCampo := aScan(aCamposExc,aFuncNO[nx][2])) == 0
			aAdd(aCampos1,{aFuncNO[nx][1],aFuncNO[nx][2]})
		Endif
	Endif
Next                                              

aSort(aCampos1,,, {|x,y| x[1] < y[1]})
aCampos3 := aClone(aCampos1)
aCampos4 := aClone(aCampos2)
aCamposA  := {}
aCamposB  := {}
For nCnt1 := 1 to Len(aCampos1)
	aAdd(aCamposA,aCampos1[nCnt1][1])
Next
For nCnt2 := 1 to Len(aCampos2)
	aAdd(aCamposB,aCampos2[nCnt2][1])
Next

If lA002UsrBlk
	lRetUsrBlk := ExecBlock("PM002BLK",.F.,.F.)
	If !( ValType(lRetUsrBlk) == "L" )
		lRetUsrBlk := .T.
	EndIf 
EndIf
DEFINE MSDIALOG oDlg1 FROM 00,00 TO 300,520 TITLE STR0020 PIXEL //"Selecione os campos"

@08,05  SAY STR0021 PIXEL OF oDlg1 //"Campos Disponiveis"
@08,143 SAY STR0022 PIXEL OF oDlg1 //"Campos Selecionados"
@45,240 SAY STR0023 PIXEL OF oDlg1 //"Mover"
@50,237 SAY STR0024 PIXEL OF oDlg1 //"Campos"

@16,05  LISTBOX oCampos1 VAR nCampos1 ITEMS aCamposA SIZE 90,110 ON DBLCLICK;
AddFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nPos1,nPos2) PIXEL OF oDlg1 WHEN IIf(lA002UsrBlk,lRetUsrBlk,.T.)
oCampos1:SetArray(aCamposA)
oCampos1:bChange    := {|| nCampos2 := 0,nPos1:=oCampos1:nAT,oCampos2:Refresh(),lCampos1 := .T.,lCampos2 := .F.}
oCampos1:bGotFocus  := {|| lCampos1 := .T.,lCampos2 := .F.}

@16,143 LISTBOX oCampos2 VAR nCampos2 ITEMS aCamposB SIZE 90,110 ON DBLCLICK;
DelFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nPos1,nPos2,aFunc) PIXEL OF oDlg1 WHEN IIf(lA002UsrBlk,lRetUsrBlk,.T.)
oCampos2:SetArray(aCamposB)
oCampos2:bChange    := {|| nCampos1 := 0,nPos2:=oCampos2:nAT,oCampos1:Refresh(),lCampos1 := .F.,lCampos2 := .T.}
oCampos2:bGotFocus  := {|| lCampos1 := .F.,lCampos2 := .T.}

@16,98  BUTTON aBtn[1] PROMPT STR0025 SIZE 42,11 PIXEL; //" Add.Todos >>"
ACTION AddAllFld(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) WHEN IIf(lA002UsrBlk,lRetUsrBlk,.T.)

@28,98  BUTTON aBtn[2] PROMPT STR0026 SIZE 42,11 PIXEL; //"&Adicionar >>"
ACTION AddFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nPos1,nPos2) WHEN (lCampos1 .and. IIf(lA002UsrBlk,lRetUsrBlk,.T.))

@40,98  BUTTON aBtn[3] PROMPT STR0027 SIZE 42,11 PIXEL; //"<< &Remover "
ACTION DelFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nPos1,nPos2,aFunc) WHEN (lCampos2 .and. IIf(lA002UsrBlk,lRetUsrBlk,.T.))

@52,98  BUTTON aBtn[4] PROMPT STR0028 SIZE 42,11 PIXEL; //"<< Rem.Todos"
ACTION DelAllFld(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,aFunc) WHEN IIf(lA002UsrBlk,lRetUsrBlk,.T.)

@115,98 BUTTON aBtn[5] PROMPT STR0029 SIZE 42,11 PIXEL; //"  Restaurar "
ACTION RestFields(@aCampos1,oCampos1,@aCampos2,oCampos2,aCampos3,aCampos4,@aCamposA,@aCamposB) WHEN IIf(lA002UsrBlk,lRetUsrBlk,.T.)

@115,480 BTNBMP oBtn1 RESOURCE BMP_SETA_UP   SIZE 25,25 ACTION UpField(@aCampos2,oCampos2,@aCamposB,nPos2);
MESSAGE STR0030 WHEN lCampos2 //"Mover campo para cima"

@140,480 BTNBMP oBtn2 RESOURCE BMP_SETA_DOWN SIZE 25,25 ACTION DwField(@aCampos2,oCampos2,@aCamposB,nPos2);
MESSAGE STR0031 WHEN lCampos2 //"Mover campo para baixo"

DEFINE SBUTTON FROM 130,175 TYPE 1 ENABLE OF oDlg1 ACTION {|| GravaMvSX6(aCampos2,{"MV_PMSEXP1","MV_PMSEXP2"}),oDlg1:End()}
DEFINE SBUTTON FROM 130,205 TYPE 2 ENABLE OF oDlg1 ACTION oDlg1:End()

ACTIVATE DIALOG oDlg1 CENTERED

dbSelectArea("SX3")
dbSetOrder(nOrdSX3)
dbGoTo(nRegSX3)

Return Nil



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddFields  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move campo disponivel para array de campos selecionados       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AddFields(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB,nPos1,nPos2,aFunc)
Local nCnt1 := 0
Local nCnt2 := 0

If nPos1 <> 0 .And. Len(aCampos1) <> 0
	aAdd(aCampos2,{aCampos1[nPos1][1],aCampos1[nPos1][2]})
	aDel(aCampos1,nPos1)
	aSize(aCampos1,Len(aCampos1)-1)
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposA  := {}
	aCamposB  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	For nCnt2 := 1 to Len(aCampos2)
		aAdd(aCamposB,aCampos2[nCnt2][1])
	Next
	oCampos1:SetArray(aCamposA)
	oCampos1:nAt := 1
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Refresh()
	oCampos1:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelFields  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move campo selecionados para array de campos disponiveis      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DelFields(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB,nPos1,nPos2,aFunc)
Local nCnt1 := 0
Local nCnt2 := 0

If nPos2 <> 0 .And. Len(aCampos2) <> 0
	If (nPosCampo := aScan(aFunc,{|x| AllTrim(x[2]) == aCampos2[nPos2][2]})) == 0
		aAdd(aCampos1,{aCampos2[nPos2][1],aCampos2[nPos2][2]})
		aDel(aCampos2,nPos2)
		aSize(aCampos2,Len(aCampos2)-1)
		aSort(aCampos1,,, {|x,y| x[1] < y[1]})
		aCamposA  := {}
		aCamposB  := {}
		For nCnt1 := 1 to Len(aCampos1)
			aAdd(aCamposA,aCampos1[nCnt1][1])
		Next
		For nCnt2 := 1 to Len(aCampos2)
			aAdd(aCamposB,aCampos2[nCnt2][1])
		Next
	Else
		MsgAlert(STR0032) //"Os campos fixos nao podem ser retirados da lista de selecionados"
	Endif
	oCampos1:SetArray(aCamposA)
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt := 1
	oCampos2:Refresh()
	oCampos2:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddAllFld  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move todos os campos do array de campos disponiveis para      ³±±
±±³          ³array de campos selecionados.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AddAllFld(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0
Local nCnt2 := 0

If Len(aCampos1) <> 0
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCampos2,{aCampos1[nCnt1][1],aCampos1[nCnt1][2]})
	Next
	aCampos1 := {}
	aCamposA := {}
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposB  := {}
	For nCnt2 := 1 to Len(aCampos2)
		aAdd(aCamposB,aCampos2[nCnt2][1])
	Next
	oCampos1:SetArray(aCamposA)
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt := 1
	oCampos2:Refresh()
	oCampos2:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelAllFld  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move todos os campos do array de campos selecionados para     ³±±
±±³          ³array de campos disponiveis.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DelAllFld(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB,aFunc)
Local nCnt1 		:= 0
Local aCamposAux 	:= {}

aCamposAux := aClone(aCampos2)
aCampos2   := {}
aCamposB   := {}

If Len(aCamposAux) <> 0
	For nCnt1 := 1 to Len(aCamposAux)
		If (nPosCampo := aScan(aFunc,{|x| AllTrim(x[2]) == aCamposAux[nCnt1][2]})) == 0
			aAdd(aCampos1,{aCamposAux[nCnt1][1],aCamposAux[nCnt1][2]})
		Else
			aAdd(aCampos2,{aCamposAux[nCnt1][1],aCamposAux[nCnt1][2]})
			aAdd(aCamposB,aCamposAux[nCnt1][1])
		Endif
	Next
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposA  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	oCampos1:SetArray(aCamposA)
	oCampos1:nAt   := 1
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Refresh()
	oCampos1:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UpField    ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move o campo para uma posicao acima dentro do array           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function UpField(aCampos2,oCampos2,aCamposB,nPos2)
Local cCampoAux
Local nCnt2 := 0

If nPos2 <> 1 .And. nPos2 <> 0
	cCampoAux := aCampos2[nPos2-1][1]
	aCampos2[nPos2-1][1] := aCampos2[nPos2][1]
	aCampos2[nPos2][1] := cCampoAux
	cCampoAux := aCampos2[nPos2-1][2]
	aCampos2[nPos2-1][2] := aCampos2[nPos2][2]
	aCampos2[nPos2][2] := cCampoAux
	aCamposB  := {}
	For nCnt2 := 1 to Len(aCampos2)
		aAdd(aCamposB,aCampos2[nCnt2][1])
	Next
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt:=nPos2-1
	oCampos2:Refresh()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DwField    ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move o campo para uma posicao abaixo dentro do array          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DwField(aCampos2,oCampos2,aCamposB,nPos2)
Local cCampoAux
Local nCnt2 := 0

If nPos2 < Len(aCampos2) .And. nPos2 <> 0
	cCampoAux := aCampos2[nPos2+1][1]
	aCampos2[nPos2+1][1] := aCampos2[nPos2][1]
	aCampos2[nPos2][1] := cCampoAux
	cCampoAux := aCampos2[nPos2+1][2]
	aCampos2[nPos2+1][2] := aCampos2[nPos2][2]
	aCampos2[nPos2][2] := cCampoAux
	aCamposB  := {}
	For nCnt2 := 1 to Len(aCampos2)
		aAdd(aCamposB,aCampos2[nCnt2][1])
	Next
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt:=nPos2+1
	oCampos2:Refresh()
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RestFields ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Restaura arrays originais                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RestFields(aCampos1,oCampos1,aCampos2,oCampos2,aCampos3,aCampos4,aCamposA,aCamposB)
Local nCnt1 := 0
Local nCnt2 := 0

aCampos1  := aClone(aCampos3)
aCampos2  := aClone(aCampos4)
aSort(aCampos1,,, {|x,y| x[1] < y[1]})
aCamposA  := {}
aCamposB  := {}
For nCnt1 := 1 to Len(aCampos1)
	aAdd(aCamposA,aCampos1[nCnt1][1])
Next
For nCnt2 := 1 to Len(aCampos2)
	aAdd(aCamposB,aCampos2[nCnt2][1])
Next
oCampos1:SetArray(aCamposA)
oCampos2:SetArray(aCamposB)
If Len(aCampos1) > 0
	oCampos1:nAt := 1
	oCampos1:Refresh()
	oCampos1:SetFocus()
Else
	If Len(aCampos2) > 0
		oCampos2:nAt := 1
		oCampos2:Refresh()
		oCampos2:SetFocus()
	Else
		oCampos1:Refresh()
		oCampos2:Refresh()
	Endif
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GravaMvSX6 ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os campos selecionados nos parametros MV_PMSPLN? (SX6)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GravaMvSX6(aCampos2,aMvPmsExp)
Local nCntFields := 0
Local nCntMv    := 1
Local cMvFldPln := ""

For nCntFields := 1 to Len(aCampos2)

	If Len(cMvFldPln + ("_"+aCampos2[nCntFields][2]+"#")) <= 240
		cMvFldPln := cMvFldPln + ("_"+aCampos2[nCntFields][2]+"#")
	Else
		PutMv(aMvPmsExp[nCntMv],cMvFldPln)
		If len(aMvPmsExp) > nCntMv
			cMvFldPln := "_"+aCampos2[nCntFields][2]+"#"
			nCntMv++
		EndIf
	Endif
Next nCntFields
PutMv(aMvPmsExp[nCntMv],cMvFldPln)
If nCntMv==1
	PutMv(aMvPmsExp[2],"")
EndIf

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A002Codigo ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Restona o Codigo da EDT/Tarefa.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A002Codigo(cAliasFun)
Local cEDTTrf := ""

If cAliasFun == "AFC"
	cEDTTrf := AllTrim(AFC->AFC_EDT)
ElseIf cAliasFun == "AF9"
	cEDTTrf := AllTrim(AF9->AF9_TAREFA)
EndIf
Return(cEDTTrf)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A002Nivel  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o Nivel da EDT/Tarefa.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A002Nivel(cAliasFun)
Local cNivEDTTrf := ""

If cAliasFun == "AFC"
	cNivEDTTrf := StrZero(Val(AFC->AFC_NIVEL)-1 , TamSX3("AFC_NIVEL")[1])
ElseIf cAliasFun == "AF9"
	cNivEDTTrf := StrZero(Val(AF9->AF9_NIVEL)-1 , TamSX3("AF9_NIVEL")[1])
EndIf
Return(cNivEDTTrf)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A002Descri ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a Descricao da EDT/Tarefa.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A002Descri(cAliasFun)
Local cDescEDTTrf := ""

If cAliasFun == "AFC"
	cDescEDTTrf := AllTrim(AFC->AFC_DESCRI)
ElseIf cAliasFun == "AF9"
	cDescEDTTrf := AllTrim(AF9->AF9_DESCRI)
EndIf
Return(cDescEDTTrf)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A002DataI  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a Data e a Hora Inicial da EDT/Tarefa.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A002DataI(cAliasFun)
Local cDataI
Local cHoraI
Local cDHIni := ""

If cAliasFun == "AFC"
	cDataI := DTOC(AFC->AFC_START)
	cHoraI := AFC->AFC_HORAI
ElseIf cAliasFun == "AF9"
	cDataI := DTOC(AF9->AF9_START)
	cHoraI := AF9->AF9_HORAI
EndIf
cDHIni := cDataI + " " + cHoraI
Return(cDHIni)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A002DataF  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a Data e a Hora Final da EDT/Tarefa.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A002DataF(cAliasFun)
Local cDHFin := ""

If cAliasFun == "AFC"
	cDataF := DTOC(AFC->AFC_FINISH)
	cHoraF := AFC->AFC_HORAF
ElseIf cAliasFun == "AF9"
	cDataF := DTOC(AF9->AF9_FINISH)
	cHoraF := AF9->AF9_HORAF
Endif
cDHFin := cDataF + " " + cHoraF
Return(cDHFin)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A002Predec ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os relacionamentos da tarefa.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A002Predec(cAliasFun)
Local nPosPredec
Local cPredec := ""
Local aTipos  := {}
Local Ix      := 0               

If ( (aRet[3] == 1) .or. (aRet[3] == 3) )
	aTipos := {"TI","II","TT","IT"}
Else	
	aTipos := {"FS","SS","FF","SF"}
Endif

If aPredec <> Nil .ANd. !Empty(aPredec)
	dbSelectArea("AFD")
	dbSetOrder(1)
	If dbSeek(xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
		While AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA == xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
			nPosPredec := Ascan(aPredec,{|x| x[1] == AFD->AFD_PREDEC})
			If nPosPredec > 0 .And. Len(aPredec[nPosPredec])>1 .And. Val(AFD->AFD_TIPO) > 0
				If Len(cPredec) > 0
					cPredec := cPredec + ";"
				Endif
				cPredec := cPredec + aPredec[nPosPredec][2]
				If (AFD->AFD_TIPO == "1" .And. AFD->AFD_HRETAR > 0) .Or. AFD->AFD_TIPO <> "1"
					cPredec := cPredec + aTipos[Val(AFD->AFD_TIPO)]
				Endif	
				If AFD->AFD_HRETAR > 0
					If AFD->AFD_HRETAR < 24
						cPredec := cPredec + "+" + AllTrim(Str(Int(AFD->AFD_HRETAR))) + If(AFD->AFD_HRETAR == 1," hr"," hrs")
					Else
						nDias := 0
						nDias := Int(AFD->AFD_HRETAR / 24)						
						cPredec := cPredec + "+" + Alltrim(Str(nDias,4)) + If(nDias == 1,OemToAnsi(STR0041),OemToAnsi(STR0042)) //Dia;Dias
					Endif
				Endif
			EndIf
			dbSelectArea("AFD")
			dbSkip()
		End
		If At(";",cPredec) > 0
			cPredec := '"' + cPredec + '"'
		Endif
	Endif
	dbSelectArea("AJ4")
	dbSetOrder(1)
	If dbSeek(xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
		While AJ4->AJ4_FILIAL+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_TAREFA == xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
			nPosPredec := Ascan(aPredec,{|x| x[1] == AJ4->AJ4_PREDEC})
			If nPosPredec > 0.And. Len(aPredec[nPosPredec])>1.And. Val(AJ4->AJ4_TIPO) > 0
				If Len(cPredec) > 0
					cPredec := cPredec + ";"
				Endif
				cPredec := cPredec + aPredec[nPosPredec][2]
				If (AJ4->AJ4_TIPO == "1" .And. AJ4->AJ4_HRETAR > 0) .Or. AJ4->AJ4_TIPO <> "1"
					cPredec := cPredec + aTipos[Val(AJ4->AJ4_TIPO)]
				Endif	
				If AJ4->AJ4_HRETAR > 0
					If AJ4->AJ4_HRETAR < 24
						cPredec := cPredec + "+" + AllTrim(Str(Int(AJ4->AJ4_HRETAR))) + If(AJ4->AJ4_HRETAR == 1," hr"," hrs")
					Else
						nDias := 0
						nDias := Int(AJ4->AJ4_HRETAR / 24)
						cPredec := cPredec + "+" + Alltrim(Str(nDias,4)) + If(nDias == 1,OemToAnsi(STR0041),OemToAnsi(STR0042)) //Dia;Dias
					Endif
				Endif
			EndIf
			dbSelectArea("AJ4")
			dbSkip()
		End
		If At(";",cPredec) > 0
			cPredec := '"' + cPredec + '"'
		Endif
	Endif
EndIf
	

Return(cPredec)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A002ID     ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o ID da EDT/Tarefa.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A002ID(cAliasFun)

Local cID

cID := AllTrim(Str(nCntLin,8))

Return(cID)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A002CONF   ³ Autor ³ Fabio Rogerio Pereira³ Data ³ 18-11-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o %POC da EDT/Tarefa.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A002CONF(cAliasFun)
Local nPOC:= 0
Local cRet:= ""

If !lUsaAJT
	If cAliasFun == "AF9"
		nPOC:= PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataBase)
	ElseIf cAliasFun == "AFC"
		nPOC:= PmsPOCAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,dDataBase)
	EndIf
	
	cRet:= AllTrim(StrTran(Str(nPoc),".",","))+"%"
EndIf

Return(cRet)


/*/{Protheus.doc} A002ESF()

Calcula o total de horas de apontamento de recursos da tarefa corrente

@author Clovis Magenta

@since 20/07/2013

@version P11


@param cAliasFun, caracter, alias da tabela corrente

@return caracter, o Total de horas de apontamento de recursos referente a tarefa corrente

/*/
Static Function A002ESF(cAliasFun)
Local aDadosWork := {}
Local xRet	:= ""

aDadosWork := PmsQryWork() // inicializa a tabela temporária de trabalho realizado (AFU)
xRet :=	PmsGetWork(aDadosWork) // pega informações
xRet := Str(xRet,17,4)
xRet := Stuff(xRet,At(".",xRet),1,",")

Return(xRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A002NR     ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o ID da EDT/Tarefa.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A002NR(cAliasFun)
Local aArea 		:= {}
Local aAreaAFA 	:= {}
Local cRecurs 		:= ""

If cAliasFun == "AF9" .AND. !lUsaAJT
	aArea := GetArea()
	dbSelectArea( "AFA" )
	aAreaAFA := AFA->(GetArea())
	dbSetOrder( 1 )
	If dbSeek( xFilial( "AFA" ) + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA )
		While AFA->AFA_FILIAL + AFA->AFA_PROJET + AFA->AFA_REVISA + AFA->AFA_TAREFA == xFilial( "AFA" ) + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA
			If !Empty( AFA->AFA_RECURS )
				AE8->( dbSetOrder( 1 ) )
				AE8->( MsSeek( xFilial() + AFA->AFA_RECURS ) )
				If Empty( cRecurs )
					cRecurs += AFA->AFA_RECURS + AllTrim( AE8->AE8_DESCRI ) + "[" + AllTrim( Str( AFA->AFA_ALOC, 3, 0 ) ) + "%]"
				Else
					cRecurs += ";" + AFA->AFA_RECURS + AllTrim( AE8->AE8_DESCRI ) + "[" + AllTrim( Str( AFA->AFA_ALOC, 3, 0 ) ) + "%]"
				EndIf
			EndIf
			
			dbSelectArea( "AFA" )
			dbSkip()
		End
	Endif
	RestArea(aAreaAFA)
	RestArea(aArea)
	
	cRecurs := '"' + cRecurs + '"'
EndIf                                 

Return( cRecurs )


/*/{Protheus.doc} ProcAFCPredec()

Relaciona o codigo da EDT com o ID gerado

@author <> 

@since 20/07/2013

@version P11


@param cChave, caracter, Chave de busca da EDT

@return nenhum

/*/
Function ProcAFCPredec(cChave)
Local aArea	 := GetArea()
Local aAreaAFC	 := AFC->(GetArea())
Local aAreaAF9	 := AF9->(GetArea())

dbSelectArea("AFC")
dbSetOrder(1)
If dbSeek(xFilial()+cChave)
	PmsIncProc(.T.)
	nCntLin := nCntLin + 1
	aAdd(aPredec,{AFC->AFC_EDT,Alltrim(Str(nCntLin,8))})
	aAdd(aRoteiro,{"AFC",AFC->(RecNo())})
	
	dbSelectArea("AF9")
	dbSetOrder(2)
	If dbSeek(xFilial("AF9")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
		While AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI == AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT
			PmsIncProc(.T.)
			nCntLin := nCntLin + 1
			aAdd(aPredec,{AF9->AF9_TAREFA,Alltrim(Str(nCntLin,8))})
			aAdd(aRoteiro,{"AF9",AF9->(RecNo())})			
			dbSelectArea("AF9")
			dbSkip()
		End
	Endif
	dbSelectArea("AFC")
	dbSetOrder(2)
	dbSeek(xFilial()+cChave)
	While !Eof() .And. xFilial()+cChave==AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI
		ProcAFCPredec(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
		dbSelectArea("AFC")
		dbSkip()
	End
EndIf	
	
RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)
Return 

/*/{Protheus.doc} Xls002Format()

retira da string os codigos de control ChR 13 e 10

@author <desconhecido> 

@since <desconhecido>

@version P11

@param xValue, caracter, Conteudo a ser "formatado"

@return caracter, retorna o valor atualizado

/*/
Function Xls002Format(xValue)

xValue := StrTran(xValue, Chr(13),"" )
xValue := StrTran(xValue, Chr(10),"" )
xValue := AllTrim(xValue)

Return xValue

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AFDInfoPred ³ Autor ³ Igor Franzoi			³ Data ³ 29/12/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o item solicitado da tarefa predecessora				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA002														³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AFDInfoPred(cCampo)

Local cReturn 		:= ""
Local xCampo1 		:= ""
Local aArea 		:= GetArea()
Local aAreaAFD 	:= {}

dbSelectArea("AFD")
aAreaAFD := GetArea()

AFD->(dbSetOrder(RetOrder(AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM)))
If AFD->(dbSeek(xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA))
	While ( AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA == ;
			xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA )

		If ( ValType(AFD->&(cCampo)) == "C" )
			cReturn += AllTrim(AFD->&(cCampo))		
		ElseIf ( ValType(AFD->&(cCampo)) == "N" )
			//Formatar o campo numerico conforme o SX3
			If !Empty( GetSx3Cache(&(cCampo),"X3_TAMANHO") )
					cReturn := Str(AFD->&(cCampo),GetSx3Cache(&(cCampo),"X3_TAMANHO"),;
											GetSx3Cache(&(cCampo),"X3_DECIMAL"))
			Else
				xCampo1 := Str(AFD->&(cCampo),17,4)
			EndIf
			If ( At(".",xCampo1) > 0 )
				xCampo1 := Stuff(xCampo1,At(".",xCampo1),1,",")
			EndIf
		ElseIf ( ValType(AFD->&(cCampo)) == "D" )
			cReturn += DTOC(AFD->&(cCampo))
		Else
			cReturn += AFD->&(cCampo)		
		EndIf		
		AFD->(dbSkip())
	EndDo
EndIf

RestArea(aAreaAFD)
RestArea(aArea)

Return (cReturn)


/*/{Protheus.doc} PmsGetWork()

retira da string os codigos de control ChR 13 e 10

@author Clovis Magenta

@since 20/07/2013

@version P11

@param aDadosWork, caracter, 

@return numerico, retorna o total de horas apontadas na tarefa

/*/
Static Function PmsGetWork(aDadosWork)
Local nValWork 	:= 0
Local nPos			:= 0

If (nPos := aScan(aDadosWork, {|x| x[1] == AF9->AF9_TAREFA})) > 0
	nValWork := aDadosWork[nPos][2]
Endif

Return nValWork

/*/{Protheus.doc} PmsGetWork()

retira da string os codigos de control ChR 13 e 10

@author Clovis Magenta

@since 20/07/2013

@version P11

@param nenhum

@return array, contendo para cada tarefa o total de horas apontadas

/*/
Static Function PmsQryWork()
Local cQuery 		:= ""
Local aArea 		:= GetArea()
Local cTemp		:= "_AFU"
Local aDadosWork	:=	{}

cQuery += "SELECT AFU_FILIAL,AFU_PROJET,AFU_REVISA,AFU_TAREFA,SUM(AFU_HQUANT) AFU_HQUANT FROM " + RetSqlName("AFU")
cQuery += " WHERE D_E_L_E_T_ = '' "
cQuery += " AND AFU_CTRRVS = '1' "
cQuery += " AND AFU_PROJET = '"+AF8->AF8_PROJET+"'"
cQuery += " AND AFU_REVISA = '"+AF8->AF8_REVISA+"'"
cQuery += " GROUP BY AFU_FILIAL,AFU_PROJET,AFU_REVISA,AFU_TAREFA"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTemp , .T., .T.)

DbSelectArea(cTemp)
While (cTemp)->(!EOF())
	aadd(aDadosWork,{AFU_TAREFA , AFU_HQUANT})
	(cTemp)->(dbSkip())
Enddo

(cTemp)->(dbCloseArea())

RestArea(aArea)
Return aDadosWork
