#include "pmsc050.ch"
#include "protheus.ch"
#include "pmsicons.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSC050  ³ Autor ³ Cristiano G. da Cunha ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Planilhas de Consulta do Orcamento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±³          ³ Utiliza a funcao RenFld, definida no PMSC200                 ³±±
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
Function PMSC050()


If AMIIn(44) .And. !PMSBLKINT()
	PRIVATE cCadastro	:= STR0001 //"Planilha de Consulta do Orcamento"
	Private aRotina := MenuDef()	
	Private aCores     := PmsAF1Color()
	Private cCmpPLN
	Private cArqPLN
	Private cPLNVer    := ""
	Private cPLNDescri := ""
	Private lSenha     := .F.
	Private cPLNSenha  := ""
	Private nFreeze    := 0
	Private nIndent    := PMS_SHEET_INDENT
	
	mBrowse(6,1,22,75,"AF1",,,,,,aCores)
	
EndIf

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS050Leg³ Autor ³ Cristiano G. da Cunha  ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Exibicao de Legendas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC050 , SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC050Leg(cAlias,nReg,nOpcx)
Local aLegenda:= {}
Local i       := 0

For i:= 1 To Len(aCores)
	Aadd(aLegenda,{aCores[i,2],aCores[i,3]})
Next i

aLegenda:= aSort(aLegenda,,,{|x,y| x[1] < y[1]})

BrwLegenda(cCadastro,STR0007,aLegenda) //"Legenda" //"Legenda"

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMC050Dlg³ Autor ³ Cristiano G. da Cunha  ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a tela de exibicao do orcamento selecionado.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC050 , SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMC050Dlg(cAlias,nReg,nOpcx)

Local oDlg
Local cArquivo	:= CriaTrab(,.F.)
Local aCampos	:= {}
Local aMenu		:= {}

PRIVATE aHandCOT	:= {}

aMenu := {{TIP_ORC_INFO, {|| PmsOrcInf()}, BMP_ORC_INFO, TOOL_ORC_INFO}}

aCampos := {{"AF2_TAREFA","AF5_EDT",8,,,.F.,"",},{"AF2_DESCRI","AF5_DESCRI",55,,,.F.,"",150}}

C050ChkPln(@aCampos)

C050COT(4,,,aCampos)

PmsPlanAF1(cCadastro+"-"+cPLNDescri,aCampos,@cArquivo,,,nFreeze,aMenu,@oDlg,.T.,nIndent)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C050ChkPln³ Autor ³ Cristiano G. da Cunha ³ Data ³ 25.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica quais os campos que devem aparecer na planilha.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C050ChkPln(aCampos)
Local cCampos := cCmpPLN

While !Empty(AllTrim(cCampos))
	If AT("#",cCampos) > 0
		cAux := Substr(cCampos,1,AT("#",cCampos)-1)
		If Substr(cAux,2,1)$"$%|"
			aAdd(aCampos,{Substr(cAux,2,Len(cAux)-1),Substr(cAux,2,Len(cAux)-1),,,,.F.,"",})
		Else
			aAdd(aCampos,{"AF2"+cAux,"AF5"+cAux,,,,.F.,"",})
		EndIf
		cCampos := Substr(cCampos,AT("#",cCampos)+1,Len(cCampos)-AT("#",cCampos))
	Else
		cCampos := ''
	EndIf
End

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMC050Opn³ Autor ³ Cristiano G. da Cunha  ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma tela de selecao de arquivos.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC050 , SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMC050Opn(cAlias,nReg,nOpcx)
Local aRet
Local cPath := GetNewPar("MV_PMSP050" ,Curdir())
Local cPathRoot := ""
Local aFile := {}  
Local cFilePlan	:= ""
Local cFilePath

If !Empty(cPath)
	cPathRoot := "SERVIDOR"+iIf(left(cPath ,1) == "\" ,"" ,"\")+cPath
	If IsSrvUnix()
		cPathRoot := STRTRAN(cPathRoot ,"\" ,"/")
	Else
		cPathRoot := STRTRAN(cPathRoot ,"/" ,"\")
	EndIF
EndIf

If ParamBox({ {6,STR0010,SPACE(254),,"FILE(mv_par01)","", 55 ,.T. ,STR0011 ,cPathRoot}},STR0012,@aRet) //"Arquivo"###"Arquivo .PLN |*.PLN"###"Selecione o arquivo"

	cFilePath := ExtFilePath(aRet[1])
	cFilePlan := MountFile( if(empty(cFilePath),cPath,cFilePath), ExtFileName(aRet[1]) ,PMS_SHEET_EXT )	

	If ReadSheetFile(cFilePlan ,aFile)

		// {versao, campos, senha, descricao, freeze, nindent}
		cPLNVer    := aFile[1]
		cArqPLN    := cFilePlan
		cCmpPLN    := aFile[2]
		cPLNSenha  := aFile[3]
		cPLNDescri := aFile[4]
		nFreeze    := aFile[5]
		nIndent    := aFile[6]
		lSenha := !Empty(aFile[3])		

		If lSenha
			cCmpPLN    := Embaralha(cCmpPLN, 0)
			cPLNDescri := Embaralha(cPLNDescri, 0)
		EndIf
	Else
		Aviso(STR0013,STR0014,{STR0015},2) //"Falha na Abertura."###"Erro na abertura do arquivo. Verifique a existencia do arquivo selecionado."###"Ok"
	EndIf
EndIf

If AllTrim(cPLNVer) != "001" .And. AllTrim(cPLNVer) != "002"
	Aviso(STR0016,STR0017,{STR0015},2 ) //"Falha no Arquivo"###"Estrutura do arquivo incompativel. Verifique o arquivo selecionado."###"Ok"
	cCmpPLN	:= ''
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C050CfgCol ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Configuracao das colunas para exibicao da EDT/Tarefa na       ³±±
±±³          ³planilha.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array com os parametros MV_PMSPLN? (SX6)              ³±±
±±³          ³ExpA2 : Array com os campos padroes                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C050CfgCol(aCamposExc)

Local nCampos1
Local nCampos2
Local cCampoAux
Local aCampos1   := {}
Local aCampos2   := {{STR0049,"COD"},{STR0032,"Descricao"}} //"Codigo"###"Descricao"
Local aCpsVar2   := {}
Local aCamposA   := {}
Local aCamposB   := {}
Local aBtn       := Array(6)
Local oCampos1
Local oCampos2
Local oBtn1
Local oBtn2
Local lCampos1   := .T.
Local lCampos2   := .F.
Local cPln1SX6   := cCmpPLN

Local nx    := 0
Local nCnt1 := 0

Local lRet := .F.
Local aFunc		 := { {STR0018,"$C050COT"} } //"*COT - Custo Orcado do Trabalho"
Local nGetFreeze := nFreeze   
Local nGetIndent := nIndent

DEFAULT aCamposExc := {"FILIAL","ORCAME","DESCRI","NIVEL","TAREFA","EDT"}

nOrdSX3  := SX3->(IndexOrd())
nRegSX3  := SX3->(Recno())

// montagem do array de campos selecionados
While At("#",cPln1SX6) <> 0
	nPosSep := At("#",cPln1SX6)
	
	If Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),1,1)=="|"
		aAdd(aCpsVar2,{,,,,,,,})
		aCpsVar2[Len(aCpsVar2)][1] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),02,10)  // nome
		aCpsVar2[Len(aCpsVar2)][2] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),13,25)  // titulo
		aCpsVar2[Len(aCpsVar2)][4] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),70,01)  // tipo
		aCpsVar2[Len(aCpsVar2)][5] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),72,02))  // tamanhho
		aCpsVar2[Len(aCpsVar2)][6] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),75,01))  // decimal
		aCpsVar2[Len(aCpsVar2)][7] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),77,60)	 // picture
		Do Case
			Case aCpsVar2[Len(aCpsVar2)][4]=="C"
				aCpsVar2[Len(aCpsVar2)][3] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30)
			Case aCpsVar2[Len(aCpsVar2)][4]=="N"
				aCpsVar2[Len(aCpsVar2)][3] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30))
			Case aCpsVar2[Len(aCpsVar2)][4]=="D"
				aCpsVar2[Len(aCpsVar2)][3] := CTOD(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30))
		EndCase		
		aCpsVar2[Len(aCpsVar2)][8] := "_|"+PadR(aCpsVar2[Len(aCpsVar2)][1], 10, " ")+;                // nome
														"|"+PadR(aCpsVar2[Len(aCpsVar2)][2], 25, " ")+;                 // titulo
														"|"+PadR(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30), 30, " ")+;  // valor  - direto do arquivo
														"|"+PadR(aCpsVar2[Len(aCpsVar2)][4], 1, " ")+;                   // tipo
														"|"+StrZero(aCpsVar2[Len(aCpsVar2)][5],2,0)+;                 // tamanho
														"|"+StrZero(aCpsVar2[Len(aCpsVar2)][6],1,0)+;                 // decimal
														"|"+PadR(aCpsVar2[Len(aCpsVar2)][7], 60, " ")
	Else
		aAdd(aCampos2,{,})
		aCampos2[Len(aCampos2)][2] := AllTrim(Substr(cPln1Sx6,2,nPosSep-2))
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek("AF2_"+aCampos2[Len(aCampos2)][2])
			//aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
			aCampos2[Len(aCampos2)][1] := AllTrim(X3Descric())
		ElseIf dbSeek("AF5_"+aCampos2[Len(aCampos2)][2])
			//aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
			aCampos2[Len(aCampos2)][1] := AllTrim(X3Descric())
		ElseIf Substr(aCampos2[Len(aCampos2)][2],1,1)=="%"
			aCampos2[Len(aCampos2)][1] := "="+Substr(aCampos2[Len(aCampos2)][2],2,12)
		Else
			nPosFunc := aScan(aFunc,{|x| AllTrim(x[2])==AllTrim(aCampos2[Len(aCampos2)][2])})
			If nPosFunc > 0
				aCampos2[Len(aCampos2)][1] := aFunc[nPosFunc][1]
			EndIf
		Endif
	Endif
	cPln1Sx6 := Substr(cPln1SX6,nPosSep+1,Len(cPln1SX6)-nPosSep)
End

// montagem do array de campos disponiveis
dbSelectArea("SX3")
dbSetOrder(1)
If (dbSeek("AF2"))
	While SX3->X3_ARQUIVO == "AF2"
		If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CONTEXT <> "V"
			cCampoAux := AllTrim(Substr(SX3->X3_CAMPO,5,6))
			If Len(aCampos1) <> 0
				If  (nPosCampo := AScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
					//aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
					aAdd(aCampos1,{X3Descric(),cCampoAux})
				Endif
			Else
				If  (nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
					//aAdd(aCampos1,{X3_DESCRIC(),cCampoAux})
					aAdd(aCampos1,{X3Descric(),cCampoAux})
				Endif
			Endif
		Endif
		dbSkip()
	End
Endif

If (dbSeek("AF5"))
	While SX3->X3_ARQUIVO == "AF5"
		If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CONTEXT <> "V"
			cCampoAux := AllTrim(Substr(SX3->X3_CAMPO,5,6))
			If Len(aCampos1) <> 0
				If  (nPosCampo := AScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
					//aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
					aAdd(aCampos1,{X3Descric(),cCampoAux})
				Endif
			Else
				If  (nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
					//aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
					aAdd(aCampos1,{X3Descric(),cCampoAux}) 
				Endif
			Endif
		Endif
		dbSkip()
	End
Endif
For nx := 1 to Len(aFunc)
	If Len(aCampos1) <> 0
		If  (nPosCampo := AScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := AScan(aCamposExc,aFunc[nx][2])) == 0
			aAdd(aCampos1,{aFunc[nx][1],aFunc[nx][2]})
		Endif
	Else
		If  (nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := AScan(aCamposExc,aFunc[nx][2])) == 0
			aAdd(aCampos1,{aFunc[nx][1],aFunc[nx][2]})
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

RenFld(@aCamposB, aCampos2)

DEFINE MSDIALOG oDlg1 FROM 00,00 TO 550,520 TITLE STR0050 PIXEL //Selecione os campos

@ 172,05 SAY STR0051 PIXEL OF oDlg1 //Variaveis globais

@ 180,05 LISTBOX oCpoSel FIELDS HEADER STR0052, STR0053, STR0054  MESSAGE;
STR0055;
ON DBLCLICK PMSEdtValOrc(@aCpsVar2, @oCpoSel) SIZE 250,65 OF oDlg1 PIXEL
aAuxVar := aClone(aCpsVar2)

If Len(aAuxVar) < 1
	aAdd(aAuxVar, {"","","","","","","",""})
EndIf

oCpoSel:SetArray(aAuxVar)
oCpoSel:bLine:={||{aAuxVar[oCpoSel:nAt,1], aAuxVar[oCpoSel:nAt,2], Transform(aAuxVar[oCpoSel:nAt,3], aAuxVar[oCpoSel:nAt,7])}}
oCpoSel:Refresh()

@18,05  SAY STR0020 PIXEL OF oDlg1  //"Campos Disponiveis"
@18,143 SAY STR0021 PIXEL OF oDlg1  //"Campos Selecionados"
@35,240 SAY STR0022 PIXEL OF oDlg1  //"Mover"
@40,237 SAY STR0023 PIXEL OF oDlg1  //"Campos"

@26,05  LISTBOX oCampos1 VAR nCampos1 ITEMS aCamposA SIZE 90,110 ON DBLCLICK;
AddFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) PIXEL OF oDlg1

oCampos1:SetArray(aCamposA)
oCampos1:bChange    := {|| nCampos2 := 0,oCampos2:Refresh(),,lCampos1 := .T.,lCampos2 := .F.}
oCampos1:bGotFocus  := {|| lCampos1 := .T.,lCampos2 := .F.}

@26,143 LISTBOX oCampos2 VAR nCampos2 ITEMS aCamposB SIZE 90,110 ON DBLCLICK;
DelFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) PIXEL OF oDlg1
oCampos2:SetArray(aCamposB)
oCampos2:bChange    := {|| nCampos1 := 0,oCampos1:Refresh(),lCampos1 := .F.,lCampos2 := .T.}
oCampos2:bGotFocus  := {|| lCampos1 := .F.,lCampos2 := .T.}

@26,98  BUTTON aBtn[1] PROMPT STR0024 SIZE 42,11 PIXEL; //" Add.Todos >>"
ACTION AddAllFld(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB)

@38,98  BUTTON aBtn[2] PROMPT STR0025 SIZE 42,11 PIXEL;  //"&Adicionar >>"
ACTION AddFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) WHEN lCampos1

@50,98  BUTTON aBtn[3] PROMPT STR0026 SIZE 42,11 PIXEL; //"<< &Remover "
ACTION DelFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) WHEN lCampos2

@62,98  BUTTON aBtn[4] PROMPT STR0027  SIZE 42,11 PIXEL;  //"<< Rem.Todos"
ACTION DelAllFld(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB)

@76,98  BUTTON aBtn[6] PROMPT STR0037  SIZE 42,11 PIXEL;  //"Formula >>"
ACTION AddFormula(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB)

@88,98  BUTTON aBtn[6] PROMPT STR0038  SIZE 42,11 PIXEL;  //"Editar"
ACTION EdtFormula(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB)

@125,98 BUTTON aBtn[5] PROMPT STR0028 SIZE 42,11 PIXEL; //"  Restaurar "
ACTION RestFields(@aCampos1,oCampos1,@aCampos2,oCampos2,aCampos3,aCampos4,@aCamposA,@aCamposB)

@115,480 BTNBMP oBtn1 RESOURCE BMP_SETA_UP   SIZE 25,25 ACTION UpField(@aCampos2,oCampos2,@aCamposB);
MESSAGE STR0029 WHEN lCampos2  //"Mover campo para cima"

@150,480 BTNBMP oBtn2 RESOURCE BMP_SETA_DOWN SIZE 25,25 ACTION DwField(@aCampos2,oCampos2,@aCamposB);
MESSAGE STR0030 WHEN lCampos2 //"Mover campo para baixo"

@ 143,05 CHECKBOX oUsado VAR lSenha PROMPT STR0071 SIZE 86, 10 ON CHANGE ProtArq() OF oDlg1 PIXEL //"Proteger arquivo com senha"

// desabilitado - o remote ainda nao implementa o freeze
//@ 143, 145 SAY STR0076 Of oDlg1 PIXEL Size 60, 60 //"Congelar colunas:" 
//@ 142, 195 MSGET nGetFreeze Picture "@E 999" Valid Empty(nGetFreeze) .Or. (nGetFreeze > 0 .And. nGetFreeze < 999) Of oDlg1 Pixel Size 20, 08
  
@ 157, 05 SAY STR0077 Of oDlg1 PIXEL Size 60, 60 //"Indentação"
@ 157, 70 MSGET nGetIndent Picture "@E 99" Valid Empty(nGetIndent) .Or. (nGetIndent >= 0 .And. nGetIndent < 100) Of oDlg1 Pixel Size 20, 08

@ 248, 05 BUTTON STR0056 SIZE 42, 11 PIXEL ACTION AddVarOrc(@aCpsVar2, @oCpoSel)
@ 248, 60 BUTTON STR0057 SIZE 42, 11 PIXEL ACTION DelVarOrc(@aCpsVar2, @oCpoSel)
@ 248,115 BUTTON STR0058 SIZE 42, 11 PIXEL ACTION EdtVarOrc(@aCpsVar2, @oCpoSel)

ACTIVATE DIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||lRet := .T., nFreeze := nGetFreeze, nIndent := nGetIndent, SalvarOrc(aCampos2, aCpsVar2, cArqPln)},{|| oDlg1:End()}) CENTERED

dbSelectArea("SX3")
dbSetOrder(nOrdSX3)
dbGoTo(nRegSX3)

Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddFields  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move campo disponivel para array de campos selecionados       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AddFields(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0
Local nPos1 := oCampos1:nAt

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
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	If Len(aCamposA) > 0
		oCampos1:nAt := 1
	EndIf
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
±±³Fun‡…o    ³AddFormula ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona um campo de formula nos campos selecionados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AddFormula(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0
Local aRet	:= {}

If ParamBox({	{1,STR0039,SPACE(12),"","","","", 85 ,.T.},;  //"Titulo"
	{3,STR0040,2,{STR0041,STR0042,STR0043},60,,.F.},; //"Tipo"###"Caracter"###"Numerico"###"Data"
	{1,STR0044,12,"","","","", 30 ,.T.},;  //"Tamanho"
	{1,STR0045,0,"","","","", 15 ,.F.},; //"Decimal"
	{1,STR0046,SPACE(35),"","","","", 85 ,.F.},; //"Picture"
	{1,STR0047,SPACE(60),"","","","", 85 ,.T.} },STR0048,@aRet) //"Formula"###"Configuracoes"
	
	Do Case
		Case aRet[2]==1
			cTipo := "C"
		Case aRet[2]==2
			cTipo := "N"
		Case aRet[2]==3
			cTipo := "D"
	EndCase
	aAdd(aCampos2,{aRet[1],"%"+aRet[1]+"%"+cTipo+"%"+StrZero(aRet[3],2,0)+"%"+StrZero(aRet[4],1,0)+"%"+aRet[5]+"%"+aRet[6]})
	aCamposA  := {}
	aCamposB  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	If Len(aCamposA) > 0
		oCampos1:nAt := 1
	EndIf
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Refresh()
	oCampos1:SetFocus()
	
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EdtFormula ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Edita a formula .                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function EdtFormula(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0
Local aRet	:= {}
Local nPos2 := oCampos2:nAt

If nPos2 > 0 .And. Len(aCampos2) > 0
	If Substr(aCampos2[nPos2][2],1,1)=="%"
		//%123456789012%C%99%2%12345678901234567890123456789012345%123456789012345678901234567890123456789012345678901234567890¨
		Do case
			Case Substr(aCampos2[nPos2][2],15,1)=="C"
				nTipo := 1
			Case Substr(aCampos2[nPos2][2],15,1)=="N"
				nTipo := 2
			Case Substr(aCampos2[nPos2][2],15,1)=="D"
				nTipo := 3
		EndCase
		If ParamBox({	{1,STR0039,Substr(aCampos2[nPos2][2],2,12),"","","","", 85 ,.T.},;  //"Titulo"
			{3,STR0040,nTipo,{STR0041,STR0042,STR0043},60,,.F.},; //"Tipo"###"Caracter"###"Numerico"###"Data"
			{1,STR0044,Val(Substr(aCampos2[nPos2][2],17,2)),"","","","", 30 ,.T.},;  //"Tamanho"
			{1,STR0045,Val(Substr(aCampos2[nPos2][2],20,1)),"","","","", 15 ,.F.},; //"Decimal"
			{1,STR0046,Substr(aCampos2[nPos2][2],22,35),"","","","", 85 ,.F.},; //"Picture"
			{1,STR0047,Substr(aCampos2[nPos2][2],58,60)+SPACE(60-LEN(Substr(aCampos2[nPos2][2],58,60))),"","","","", 85 ,.T.} },STR0048,@aRet) //"Formula"###"Configuracoes"
			
			Do Case
				Case aRet[2]==1
					cTipo := "C"
				Case aRet[2]==2
					cTipo := "N"
				Case aRet[2]==3
					cTipo := "D"
			EndCase
			aCampos2[nPos2] := {aRet[1],"%"+aRet[1]+"%"+cTipo+"%"+StrZero(aRet[3],2,0)+"%"+StrZero(aRet[4],1,0)+"%"+aRet[5]+"%"+aRet[6]}
			aCamposA  := {}
			aCamposB  := {}
			For nCnt1 := 1 to Len(aCampos1)
				aAdd(aCamposA,aCampos1[nCnt1][1])
			Next
			
			RenFld(@aCamposB, aCampos2)
			
			oCampos1:SetArray(aCamposA)
			If Len(aCamposA) > 0
				oCampos1:nAt := 1
			EndIf
			oCampos1:Refresh()
			oCampos2:SetArray(aCamposB)
			oCampos2:Refresh()
			oCampos1:SetFocus()
			
		EndIf
	EndIf
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelFields  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move campo selecionados para array de campos disponiveis      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DelFields(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0
Local nPos2 := oCampos2:nAt

If nPos2 <> 0 .And. Len(aCampos2) <> 0 .ANd. nPos2 > 2
	If Substr(aCampos2[nPos2][2],1,1) != "%"
		aAdd(aCampos1,{aCampos2[nPos2][1],aCampos2[nPos2][2]})
		aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	EndIf
	aDel(aCampos2,nPos2)
	aSize(aCampos2,Len(aCampos2)-1)
	aCamposA  := {}
	aCamposB  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	
	RenFld(@aCamposB, aCampos2)
	
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
±±³Fun‡…o    ³AddAllFld  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 25-04-2002 ³±±
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

If Len(aCampos1) <> 0
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCampos2,{aCampos1[nCnt1][1],aCampos1[nCnt1][2]})
	Next
	aCampos1 := {}
	aCamposA := {}
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposB  := {}
	
	RenFld(@aCamposB, aCampos2)
	
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
±±³Fun‡…o    ³DelAllFld  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move todos os campos do array de campos selecionados para     ³±±
±±³          ³array de campos disponiveis.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DelAllFld(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0

If Len(aCampos2) <> 0
	For nCnt1 := 3 to Len(aCampos2)
		If Substr(aCampos2[nCnt1][2], 1, 1) # "%"
			aAdd(aCampos1,{aCampos2[nCnt1][1],aCampos2[nCnt1][2]})
		EndIf
	Next
	aCampos2   := {{STR0049,"COD"},{STR0032,"Descricao"}} //"Codigo"###"Descricao"
	aCamposB := {}
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposA  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	If Len(aCamposA) > 0
		oCampos1:nAt   := 1
	EndIf
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
±±³Fun‡…o    ³UpField    ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move o campo para uma posicao acima dentro do array           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function UpField(aCampos2,oCampos2,aCamposB)
Local cCampoAux
Local nPos2 := oCampos2:nAt

If nPos2 <> 1 .And. nPos2 <> 0 .And. nPos2 > 3
	cCampoAux := aCampos2[nPos2-1][1]
	aCampos2[nPos2-1][1] := aCampos2[nPos2][1]
	aCampos2[nPos2][1] := cCampoAux
	cCampoAux := aCampos2[nPos2-1][2]
	aCampos2[nPos2-1][2] := aCampos2[nPos2][2]
	aCampos2[nPos2][2] := cCampoAux
	aCamposB  := {}
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt:=nPos2-1
	oCampos2:Refresh()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DwField    ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move o campo para uma posicao abaixo dentro do array          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DwField(aCampos2,oCampos2,aCamposB)

Local cCampoAux
Local nPos2 := oCampos2:nAt

If nPos2 < Len(aCampos2) .And. nPos2 <> 0 .And. nPos2 > 2
	cCampoAux := aCampos2[nPos2+1][1]
	aCampos2[nPos2+1][1] := aCampos2[nPos2][1]
	aCampos2[nPos2][1] := cCampoAux
	cCampoAux := aCampos2[nPos2+1][2]
	aCampos2[nPos2+1][2] := aCampos2[nPos2][2]
	aCampos2[nPos2][2] := cCampoAux
	aCamposB  := {}
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt:=nPos2+1
	oCampos2:Refresh()
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RestFields ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 25-04-2002 ³±±
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

aCampos1  := aClone(aCampos3)
aCampos2  := aClone(aCampos4)
aSort(aCampos1,,, {|x,y| x[1] < y[1]})
aCamposA  := {}
aCamposB  := {}
For nCnt1 := 1 to Len(aCampos1)
	aAdd(aCamposA,aCampos1[nCnt1][1])
Next

RenFld(@aCamposB, aCampos2)

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
±±³Fun‡…o    ³ C050COT   ³ Autor ³Cristiano G. da Cunha ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o Custo Orcado do Trabalho na Data Base               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC050                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C050COT(nRet,cAlias,nRecNo,aCampos)

// nRet = 1 // Retorna as informacoes do campo
If nRet==1
	Return {"C050COT","N",14,2}

	// nRet = 2 // Retorna as informacoes do campo + Picture
ElseIf nRet==2
	Return {STR0031,"C050COT","@E 999,999,999.99",14,"N"} //"Vlr. COT"

	// nRet = 3 // Retorna o valor do COT
ElseIf nRet==3
	If cAlias=="AF2"
		AF2->(MsGoto(nRecNo))
		nRet := PmsRetCOT(aHandCOT,1,AF2->AF2_TAREFA)[1]
	ElseIf cAlias=="AF5"
		AF5->(MsGoto(nRecNo))
		nRet := PmsRetCOT(aHandCOT,2,AF5->AF5_EDT)[1]
	EndIf
	Return nRet

	// nRet = 4 // Inicializa os valores da planilha
ElseIf nRet==4
	If aScan(aCampos,{|x| AllTrim(x[1])=="$C050COT"})>0
		aHandCOT := PmsIniCOT(AF1->AF1_ORCAME)
	EndIf
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMC050New³ Autor ³ Cristiano G. da Cunha  ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma nova configuracao de planilha.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC050 , SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMC050New(cAlias,nReg,nOpcx)

Local aRet
Local aFile := {}
Local nFrz     := nFreeze
Local cCmpPLN2 := cCmpPLN
Local cArqPLN2 := cArqPLN
Local cPath    := GetNewPar("MV_PMSP050" ,Curdir())
Local cPathRoot := ""
Local cFilePath := ""

	If !Empty(cPath)
	Else
	EndIf
	
	cPathRoot := "SERVIDOR"+iIf(left(cPath ,1) == "\" ,"" ,"\")+cPath
	If IsSrvUnix()
		cPathRoot := STRTRAN(cPathRoot ,"\" ,"/")
	Else
		cPathRoot := STRTRAN(cPathRoot ,"/" ,"\")
	EndIF

cCmpPLN := ''
cArqPLN	:= ''
nFreeze := 0     
nIndent := PMS_SHEET_INDENT

If ParamBox({	{1,STR0032,SPACE(050),"","","","", 85 ,.T.},; //"Descricao"
	{6,STR0010,SPACE(254) ,,,"" ,55 ,.T. ,STR0011 ,cPathRoot} },STR0033,@aRet) //"Arquivo"###"Arquivo .PLN |*.PLN"###"Nova Planilha"
	
	lSenha := .F.
	cFilePath := ExtFilePath(aRet[2])
	cArqPLN   := MountFile( if(empty(cFilePath),cPath,cFilePath), ExtFileName(aRet[2]) ,PMS_SHEET_EXT )	

	If C050CfgCol()  
		
		If ReadSheetFile(cArqPLN ,aFile)

			// {versao, campos, senha, descricao, freeze, indent}
			cPLNVer    := aFile[1]
			cCmpPLN    := aFile[2]
			cPLNSenha  := aFile[3]
			cPLNDescri := aFile[4]
			nFreeze    := aFile[5]
			nIndent    := aFile[6]
			lSenha := !Empty(aFile[3])

			If lSenha
				cCmpPLN    := Embaralha(cCmpPLN, 0)
				cPLNDescri := Embaralha(cPLNDescri, 0)
			EndIf
				
			PMC050Dlg(cAlias,nReg,nOpcx)
		Else
			Aviso(STR0013,STR0014,{STR0015},2) //"Falha na Abertura."###"Erro na abertura do arquivo. Verifique a existencia do arquivo selecionado."###"Ok"
		EndIf
	Else

		cCmpPLN := cCmpPLN2
		cArqPLN	:= cArqPLN2		
		nFreeze	:= nFrz	
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMC050Cfg³ Autor ³ Cristiano G. da Cunha  ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma nova configuracao de planilha.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC050 , SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMC050Cfg(cAlias,nReg,nOpcx)
Local aRet2 := {}
Local aFile := {}
Local lRet	:=	.F.

If !Empty(cArqPLN)
	lSenha := .F.

	If ReadSheetFile(cArqPLN, aFile)

		//{versao, campos, senha, descricao, freeze, indent}
		cPLNVer    := aFile[1]
		cArqPLN    := cArqPLN
		cCmpPLN    := aFile[2]
		cPLNSenha  := aFile[3]
		cPLNDescri := aFile[4]
		nFreeze    := aFile[5]                            
		nIndent    := aFile[6]
		lSenha     := !Empty(aFile[3])
	
		If lSenha
			cCmpPLN    := Embaralha(cCmpPLN, 0)
			cPLNDescri := Embaralha(cPLNDescri, 0)

			// Verifica a senha
			// Se a senha estiver errada, cancela a abertura
			If Parambox({{8, STR0072, SPACE(10), "@A!", "", "", "", 30, .T.}}, STR0073, @aRet2) //"Senha"###"Desproteger arquivo"
				If Encript(aRet2[1], 1)#cPLNSenha
					Alert(STR0074) //"Senha incorreta"
					Return lRet
				EndIf
			Else
				Alert(STR0074) //"Senha incorreta"
        Return lRet
			EndIf
		EndIf
		
		lRet := C050CfgCol()		
	Else
		Aviso(STR0013,STR0014,{STR0015},2) //"Falha na Abertura."###"Erro na abertura do arquivo. Verifique a existencia do arquivo selecionado."###"Ok"
	EndIf
Else
	Aviso(STR0013,STR0014,{STR0015},2) //"Falha na Abertura."###"Erro na abertura do arquivo. Verifique a existencia do arquivo selecionado."###"Ok"
EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsIniCOT ³ Autor ³ Cristiano G. da Cunha ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa as funcoes de calculo de Custos do Orcamento(COT)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsIniCOT(cOrcame,cTrfDe,cTrfAte)

Local aArea		:= GetArea()
Local aAreaAF2	:= AF2->(GetArea())
Local aAreaAF3	:= AF3->(GetArea())
Local aAreaAF4	:= AF4->(GetArea())
Local aArrayTrb	:= {}
Local aCusto	:= {}

DEFAULT cTrfDe		:= ""
DEFAULT cTrfAte		:= "ZZZZZZZZZZZZ"

dbSelectArea("AF2")
dbSetOrder(1)
dbSeek(xFilial()+cOrcame+cTrfDe,.T.)
While !Eof() .And. AF2->AF2_FILIAL+AF2->AF2_ORCAME== xFilial()+cOrcame .And. AF2->AF2_TAREFA <= cTrfAte
	
	aAdd(aArrayTrb,{AF2->AF2_TAREFA,,{0,0,0,0,0}})
	nPosTrf	:= Len(aArrayTrb)
	dbSelectArea("AF3")
	dbSetOrder(1)
	dbSeek(xFilial()+cOrcame+AF2->AF2_TAREFA)
	While !Eof().And.AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_TAREFA==;
		xFilial("AF3")+cOrcame+AF2->AF2_TAREFA
		If PmsCOTAF3(AF3->(RecNo()),AF2->(RecNo()),@aCusto)
			aArrayTrb[nPosTrf][3][1] += aCusto[1]
			aArrayTrb[nPosTrf][3][2] += aCusto[2]
			aArrayTrb[nPosTrf][3][3] += aCusto[3]
			aArrayTrb[nPosTrf][3][4] += aCusto[4]
			aArrayTrb[nPosTrf][3][5] += aCusto[5]
			AddCOTEDT(@aArrayTrb,aCusto,cOrcame,AF2->AF2_EDTPAI)
		EndIf
		dbSelectArea("AF3")
		dbSkip()
	End
	
	dbSelectArea("AF4")
	dbSetOrder(1)
	dbSeek(xFilial()+cOrcame+AF2->AF2_TAREFA)
	While !Eof().And.AF4->AF4_FILIAL+AF4->AF4_ORCAME+AF4->AF4_TAREFA==;
		xFilial("AF4")+cOrcame+AF2->AF2_TAREFA
		If PmsCOTAF4(AF4->(RecNo()),AF2->(RecNo()),@aCusto)
			aArrayTrb[nPosTrf][3][1] += aCusto[1]
			aArrayTrb[nPosTrf][3][2] += aCusto[2]
			aArrayTrb[nPosTrf][3][3] += aCusto[3]
			aArrayTrb[nPosTrf][3][4] += aCusto[4]
			aArrayTrb[nPosTrf][3][5] += aCusto[5]
			AddCOTEDT(@aArrayTrb,aCusto,cOrcame,AF2->AF2_EDTPAI)
		EndIf
		dbSelectArea("AF4")
		dbSkip()
	End
	
	dbSelectArea("AF2")
	dbSkip()
End

RestArea(aAreaAF3)
RestArea(aAreaAF4)
RestArea(aAreaAF2)
RestArea(aArea)
Return aArrayTrb

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddCOTEDT ³ Autor ³ Cristiano G. da Cunha ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona o custo na EDT do Arquivo de trabalho especificado.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AddCOTEDT(aArrayTrb,aCusto,cOrcame,cEDT)
Local aArea		:= GetArea()
Local aAreaAF5	:= AF5->(GetArea())
Local nPosEDT	:= aScan(aArrayTrb,{|x|x[2]==cEDT})

If nPosEDT > 0
	aArrayTrb[nPosEDT][3][1] += aCusto[1]
	aArrayTrb[nPosEDT][3][2] += aCusto[2]
	aArrayTrb[nPosEDT][3][3] += aCusto[3]
	aArrayTrb[nPosEDT][3][4] += aCusto[4]
	aArrayTrb[nPosEDT][3][5] += aCusto[5]
Else
	aAdd(aArrayTrb,{,cEdt,{0,0,0,0,0}})
	nPosEDT	:= Len(aArrayTrb)
	aArrayTrb[nPosEDT][3][1] := aCusto[1]
	aArrayTrb[nPosEDT][3][2] := aCusto[2]
	aArrayTrb[nPosEDT][3][3] := aCusto[3]
	aArrayTrb[nPosEDT][3][4] := aCusto[4]
	aArrayTrb[nPosEDT][3][5] := aCusto[5]
EndIf

dbSelectArea("AF5")
dbSetOrder(1)
If dbSeek(xFilial()+cOrcame+cEDT) .And. !Empty(AF5_EDTPAI)
	AddCOTEDT(aArrayTrb,aCusto,cOrcame,AF5_EDTPAI)
EndIf

RestArea(aAreaAF5)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsRetCOT ³ Autor ³ Cristiano G. da Cunha ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os custos da tarefa,EDT ou Bloco de Trabalho          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsRetCOT(aArrayTrb,nTipo,cCodigo)
Local aCusto := {0,0,0,0,0}

Do Case
	Case nTipo == 1
		nPosSeek := aScan(aArrayTrb,{|x|x[1]==cCodigo})
		If nPosSeek>0
			aCusto := aArrayTrb[nPosSeek][3]
		EndIf
	Case nTipo == 2
		nPosSeek := aScan(aArrayTrb,{|x|x[2]==cCodigo})
		If nPosSeek>0
			aCusto := aArrayTrb[nPosSeek][3]
		EndIf
EndCase

Return aCusto


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCOTAF3 ³ Autor ³ Cristiano G. da Cunha ³ Data ³ 25-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os custos previstos do Recurso na data.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsCOTAF3(nRecAF3,nRecAF2,aCusto)

Local lRet		:= .F.
Local aArea		:= GetArea()
Local aAreaAF3	:= AF3->(GetArea())
Local aAreaAF2	:= AF2->(GetArea())


aCusto	:= {0,0,0,0,0}

AF3->(MsGoto(nRecAF3))
If nRecAF2==Nil
	dbSelectArea("AF2")
	dbSetOrder(1)
	dbSeek(xFilial()+AF3->AF3_ORCAME+AF3->AF3_TAREFA)
Else
	AF2->(MsGoto(nRecAF2))
EndIf

nQuant:= PmsAF3Quant(AF2->AF2_ORCAME,AF2->AF2_TAREFA,AF3->AF3_PRODUT,AF2->AF2_QUANT,AF3->AF3_QUANT)

aCusto[1]	:= xMoeda(AF3->AF3_CUSTD*nQuant,AF3->AF3_MOEDA,1)
aCusto[2]	:= xMoeda(AF3->AF3_CUSTD*nQuant,AF3->AF3_MOEDA,2)
aCusto[3]	:= xMoeda(AF3->AF3_CUSTD*nQuant,AF3->AF3_MOEDA,3)
aCusto[4]	:= xMoeda(AF3->AF3_CUSTD*nQuant,AF3->AF3_MOEDA,4)
aCusto[5]	:= xMoeda(AF3->AF3_CUSTD*nQuant,AF3->AF3_MOEDA,5)
lRet		:= .T.

RestArea(aAreaAF2)
RestArea(aAreaAF3)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCOTAF4 ³ Autor ³ Edson Maricate        ³ Data ³ 04-07-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os custos previstos do Recurso na data.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsCOTAF4(nRecAF4,nRecAF2,aCusto)

Local lRet		:= .F.
Local aArea		:= GetArea()
Local aAreaAF4	:= AF4->(GetArea())
Local aAreaAF2	:= AF2->(GetArea())
Local nValor    := 0

aCusto	:= {0,0,0,0,0}

AF4->(MsGoto(nRecAF4))
If nRecAF2==Nil
	dbSelectArea("AF2")
	dbSetOrder(1)
	dbSeek(xFilial()+AF4->AF4_ORCAME+AF4->AF4_TAREFA)
Else
	AF2->(MsGoto(nRecAF2))
EndIf

nValor:= PmsAF4Valor(AF2->AF2_QUANT,AF4->AF4_VALOR)

aCusto[1]	:= xMoeda(nValor,AF4->AF4_MOEDA,1)
aCusto[2]	:= xMoeda(nValor,AF4->AF4_MOEDA,2)
aCusto[3]	:= xMoeda(nValor,AF4->AF4_MOEDA,3)
aCusto[4]	:= xMoeda(nValor,AF4->AF4_MOEDA,4)
aCusto[5]	:= xMoeda(nValor,AF4->AF4_MOEDA,5)
lRet		:= .T.

RestArea(aAreaAF2)
RestArea(aAreaAF4)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AddVarOrc ³ Autor ³ Adriano Ueda         ³ Data ³ 09-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona variavel global para ser utilizada em formulas      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array para ser incluido                               ³±±
±±³          ³ExpA2 : Listbox para exibicao                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AddVarOrc(aVars, oCpoSel)
Local xBuffer
Local cBuffer
Local aRet := {}
Local cTipo := ""
Local aAuxVar	

Private aVars2 := aClone(aVars)

If ParamBox({ {1,STR0059, SPACE(10), "","VldVarNome(MV_PAR01) .And. !VarExists(aVars2, MV_PAR01)","","", 85, .T.},; // Nome
	{1,STR0060,SPACE(25),"","","","", 85 ,.T.},;  // Descricao
	{3,STR0062,2,{STR0066,STR0067,STR0068},60,,.T.},;  // Tipo"###"Caracter"###"Numerico"###"Data"
	{1,STR0063,12,"@E 99","VldVarTam(MV_PAR03, MV_PAR04, MV_PAR05)","","", 30 ,.T.},;           // Tamanho
	{1,STR0064,0,"@E 9","VldVarTam(MV_PAR03, MV_PAR04, MV_PAR05)","(MV_PAR03==2)","", 15 ,.F.},;            // Decimal
	{1,STR0065,SPACE(60),"","","","", 85 ,.F.};     // Picture
	},STR0069,@aRet)
	
	Do Case
		Case aRet[3]==1
			cTipo := "C"
			cBuffer := Space(30)
			xBuffer := Space(30)
			aRet[5] := 0
		Case aRet[3]==2
			cTipo := "N"
			cBuffer := PadL("0", 30, " ")
			xBuffer := 0
		Case aRet[3]==3
			cTipo := "D"
			cBuffer := PadR("01/01/80", 30, " ")
			xBuffer := PMS_MIN_DATE
			aRet[5] := 0
	EndCase
	
	If Chr(0) $ aRet[6]
		aRet[6] := RetNulos(aRet[6])	
	EndIf
	
	aAdd(aVars, {aRet[1], aRet[2], xBuffer, cTipo, aRet[4], aRet[5], aRet[6], "_|"+PadR(aRet[1], 10, " ")+;                // nome
																																					  "|"+PadR(aRet[2], 25, " ")+;                 // titulo
																																						"|"+cBuffer+;  // valor
																																						"|"+PadR(cTipo, 1, " ")+;                   // tipo
																																						"|"+StrZero(aRet[4],2,0)+;                 // tamanho
																																						"|"+StrZero(aRet[5],1,0)+;                 // decimal
																																						"|"+PadR(aRet[6], 60, " ")})
	aAuxVar := aClone(aVars)
	
	If Len(aAuxVar) > 0
		oCpoSel:SetArray(aAuxVar)
		oCpoSel:bLine:={||{aAuxVar[oCpoSel:nAt,1], aAuxVar[oCpoSel:nAt,2], TransForm(aAuxVar[oCpoSel:nAt,3],aAuxVar[oCpoSel:nAt,7] )}}
		oCpoSel:Refresh()
	EndIf
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EdtVarOrc ³ Autor ³ Adriano Ueda         ³ Data ³ 09-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Edita variavel global a ser utilizada em formulas            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array para ser editado                                ³±±
±±³          ³ExpA2 : Listbox para exibicao                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function EdtVarOrc(aVars, oCpoSel)
Local aRet := {}
Local cTipo := ""
Local nBuffer := 0
Local aAuxVar
Local cPict := SPACE(60)

Private cNomeAnt
Private aVars2 := aClone(aVars)

If oCpoSel:nAt < 1
	Return
EndIf
If Len(aVars) < 1
	Return
EndIf

cNomeAnt := aVars[oCpoSel:nAt, 1]
cTipo := aVars[oCpoSel:nAt, 4]
cPict := PadR(aVars[oCpoSel:nAt, 7], 60, " ")

Do Case
	Case cTipo=="C"
		nBuffer := 1
	Case cTipo=="N"
		nBuffer := 2
	Case cTipo=="D"
		nBuffer := 3
End Case

If ParamBox({ {1,STR0059, aVars[oCpoSel:nAt, 1], "","VldVarNome(MV_PAR01) .And. !VarExists2(aVars2, MV_PAR01, cNomeAnt)","","", 85, .T.},; // Nome
	{1,STR0060,aVars[oCpoSel:nAt, 2],"","","","", 85 ,.T.},;                                   // Descricao
	{3,STR0062,nBuffer,{STR0066,STR0067,STR0068},60,,.T.},;                                    // Tipo"###"Caracter"###"Numerico"###"Data"
	{1,STR0063,aVars[oCpoSel:nAt, 5],"@E 99","VldVarTam(MV_PAR03, MV_PAR04, MV_PAR05)","","", 30 ,.T.},;                                   // Tamanho
	{1,STR0064,aVars[oCpoSel:nAt, 6],"@E 9","VldVarTam(MV_PAR03, MV_PAR04, MV_PAR05)","(MV_PAR03==2)","", 15 ,.F.},;                                   // Decimal
	{1,STR0065,cPict,"@!","","","", 85 ,.F.};     // Picture
	},STR0070,@aRet) // Editar variavel global	

	Do Case
		Case aRet[3]==1
			cTipo := "C"
			aRet[5] := 0
		Case aRet[3]==2
			cTipo := "N"
		Case aRet[3]==3
			cTipo := "D"
			aRet[5] := 0
	EndCase
	
	If Len(aVars) > 0
		aVars[oCpoSel:nAt,1] := aRet[1]
		aVars[oCpoSel:nAt,2] := aRet[2]

		If nBuffer # aRet[3]
			Do Case
				Case aRet[3]==1
					aVars[oCpoSel:nAt,3] := Space(30)
				Case aRet[3]==2
					aVars[oCpoSel:nAt,3] := PadL("0", 30, " ")
				Case aRet[3]==3
					aVars[oCpoSel:nAt,3] := PadR(DToC(MSDate()), 30, " ")
			EndCase
		EndIf	

		aVars[oCpoSel:nAt,4] := cTipo
		aVars[oCpoSel:nAt,5] := aRet[4]
		aVars[oCpoSel:nAt,6] := aRet[5] 
		aVars[oCpoSel:nAt,7] := PadR(AllTrim(aRet[6]), 60, " ") // + Space(60-Len(aRet[6]))

		If Chr(0) $ aVars[oCpoSel:nAt,7]
			aVars[oCpoSel:nAt,7] := RetNulos(aVars[oCpoSel:nAt,7])
		EndIf		
		
		aVars[oCpoSel:nAt,8] := "_|"+aRet[1]+;                // nome
														"|"+aRet[2]+;                 // titulo
														"|"+PadR(aVars[oCpoSel:nAt,3], 30, " ")+;  // valor
														"|"+cTipo+;                   // tipo
														"|"+StrZero(aRet[4],2,0)+;                 // tamanho
														"|"+StrZero(aRet[5],1,0)+;                 // decimal
														"|"+PadR(AllTrim(aRet[6]), 60, " ")

		aAuxVar := aClone(aVars)
	
		oCpoSel:SetArray(aAuxVar)
		oCpoSel:bLine:={||{aAuxVar[oCpoSel:nAt,1], aAuxVar[oCpoSel:nAt,2], TransForm(aAuxVar[oCpoSel:nAt,3],aAuxVar[oCpoSel:nAt,7] )}}
		oCpoSel:Refresh()
	EndIf
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DelVarOrc ³ Autor ³ Adriano Ueda         ³ Data ³ 15-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui variavel global utilizada em formulas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array a ser excluido                                  ³±±
±±³          ³ExpA2 : Listbox para exibicao                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function DelVarOrc(aVars, oCpoSel)
Local aLen := 0
Local aVarVis

If Len(aVars) > 0
	aDel(aVars, oCpoSel:nAt)
	aLen := Len(aVars) - 1
	aSize(aVars, aLen)
	aVarVis := aClone(aVars)
	
	oCpoSel:SetArray(aVarVis)
	If Len(aVarVis) > 0
		oCpoSel:bLine:={||{aVarVis[oCpoSel:nAt,1], aVarVis[oCpoSel:nAt,2], Transform(aVarVis[oCpoSel:nAt,3], aVarVis[oCpoSel:nAt,7])}}
	EndIf
	oCpoSel:Refresh()
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GravaOrc  ³ Autor ³ Adriano Ueda         ³ Data ³ 15-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os campos, formulas e variaveis em arquivo             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Campos e formulas a serem gravados                    ³±±
±±³          ³ExpA2 : Variaveis a serem gravadas                            ³±±
±±³          ³ExpC3 : Arquivo a ser salvo (pode ou nao conter a extensao    ³±±
±±³          ³        .pln - a extensao nao e obrigatoria)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³ a variavel cVersao indica a versao do arquivo                ³±±
±±³          ³                                                              ³±±
±±³          ³ 001 - arquivo nao codificado                                 ³±±
±±³          ³ 002 - arquivo codificado                                     ³±±
±±³          ³                                                              ³±±
±±³          ³ lSenha indica se o arquivo sera protegido ou nao             ³±±
±±³          ³ .T. - o arquivo sera gravado com os dados codificados        ³±±
±±³          ³ .F. - o arquivo sera gravado sem os dados codificados        ³±±
±±³          ³                                                              ³±±
±±³          ³ cPLNSenha contem a senha para acessar o arquivo              ³±±
±±³          ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GravaOrc(aCampos, aVars, cArquivo, nStart)
Local cMvFldPln  := ""
Local cWrite
Local nCount := 0   

Default nStart := 3

// campos e formulas
For nCount := nStart to Len(aCampos)
	cMvFldPln += ("_"+aCampos[nCount][2]+"#")
Next

// variaveis
For nCount := 1 To Len(aVars)
	If !Empty(aVars[nCount][1])
		If Chr(0) $ aVars[nCount][8]
			cMvFldPln += RetNulos(aVars[nCount][8]) +"#"
		Else
			cMvFldPln += aVars[nCount][8] +"#"
		Endif
	EndIf
Next

// acrescenta extensao ao arquivo se nao existir
// no nome do arquivo
If Upper(Right(AllTrim(cArquivo), 4)) != Upper(PMS_SHEET_EXT)
	cArquivo := AllTrim(cArquivo) + PMS_SHEET_EXT
EndIf

// Codifica o arquivo
If lSenha
	cWrite := Embaralha(cMvFldPln, 1)+Chr(13)+Chr(10)
	cWrite += "002"+Chr(13)+Chr(10)  // arquivo codificado
	cWrite += cPLNSenha+Chr(13)+Chr(10)
	cWrite += Embaralha(cPLNDescri, 1)
Else
	cWrite := cMvFldPln+Chr(13)+Chr(10)
	cWrite += "001"+Chr(13)+Chr(10)  // arquivo nao codificado (default)
	cWrite += cPLNDescri
EndIf

If Type("nFreeze") == "U"
	cWrite += CRLF + "0"
Else
	cWrite += CRLF + AllTrim(Str(nFreeze))
EndIf

If Type("nIndent") == "U"
	cWrite += CRLF + "4"
Else
	cWrite += CRLF + AllTrim(Str(nIndent))
EndIf

MemoWrit(cArquivo,cWrite)
cCmpPLN	:= cMvFldPln
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSEdtValOrc³ Autor ³ Adriano Ueda         ³ Data ³ 22-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Permite a edicao de valores na listbox contendo as variaveis ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 : Arrays contendo as variaveis                         ³±±
±±³          ³ ExpO1 : Listbox                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PMSEdtValOrc(aVars, oCpoSel)
Local xBuffer := Nil
Local cPict   := ""

If oCpoSel:nAt > 0
	If Len(aVars) > 0
		xBuffer := aVars[oCpoSel:nAt][3]
		cPict   := aVars[oCpoSel:nAt][7]
	Else
		Return .T.
   EndIf

	MaFisEditCell(@xBuffer, oCpoSel, @cPict, 3, '!Vazio()')
	
	aVars[oCpoSel:nAt, 3] := xBuffer
	
	Do Case
		Case ValType(xBuffer)=="C"
			xBuffer := PadR(xBuffer, 30, " ")
		Case ValType(xBuffer)=="N"
			xBuffer := PadL(Str(xBuffer), 30, " ")
		Case ValType(xBuffer)=="D"
			xBuffer := PadR(DToC(xBuffer), 30, " ")
	EndCase
	
	aVars[oCpoSel:nAt,8] := "_|"+aVars[oCpoSel:nAt,1]+;                 // nome
													"|" +aVars[oCpoSel:nAt,2]+;                 // titulo
													"|" +xBuffer             +;                 // valor
													"|" +aVars[oCpoSel:nAt,4]+;                 // tipo
													"|" +StrZero(aVars[oCpoSel:nAt,5],2,0)+;    // tamanho
													"|" +StrZero(aVars[oCpoSel:nAt,6],1,0)+;    // decimal
													"|" +PadR(aVars[oCpoSel:nAt,7], 60, " ")    // picture
EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SalvarOrc ³ Autor ³ Adriano Ueda         ³ Data ³ 29-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para salvar a planilha com senha                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 : Arrays contendo os campos                            ³±±
±±³          ³ ExpA2 : Arrays contendo as variaveis                         ³±±
±±³          ³ ExpC1 : Nome do arquivo                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SalvarOrc(aCpos, aVars, cArq)
Local aRet := {}

If lSenha
	// Verifica a senha
	// Se a senha estivsr errada, cancela o salvamento
	If Parambox({{8, STR0072, SPACE(10), "@A!", "", "", "", 30, .T.}}, STR0075, @aRet) //"Senha"###"Digite a senha para a gravacao"
		If Encript(aRet[1], 1)#cPLNSenha
			Alert(STR0074) //"Senha incorreta"
			Return .F.
		EndIf
	Else
		Alert(STR0074) //"Senha incorreta"
    Return .F.
	EndIf
EndIf

GravaOrc(aCpos, aVars, cArq)
oDlg1:End()
Return

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
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
Local aRotina 	:= {	{ STR0002, "AxPesqui" , 0 , 1},; //"Pesquisar"
						{ STR0003, "PMC050New", 0 , 2},; //"Nova"
						{ STR0004, "PMC050Opn", 0 , 2},; //"Abrir"
						{ STR0005, "PMC050Cfg", 0 , 2},; //"Configurar"
						{ STR0006, "PMC050Dlg", 0 , 2} } //"Consultar"
Return(aRotina)

Static Function MountFile( cPath ,cFile ,cExtension )
Local cBarra := iIf(IsSrvUnix() ,"/" ,"\")

DEFAULT cPath := ""
DEFAULT cFile := ""
DEFAULT cExtension := ""

	cPath := Alltrim(cPath)
	
	If IsSrvUnix()
		cPath := STRTRAN(cPath ,"\" ,"/")
	Else
		cPath := STRTRAN(cPath ,"/" ,"\")
	EndIF
	
	If !(Right(cPath ,1) == cBarra)
		cPath += cBarra
	EndIf
	
	cFile := Alltrim(cFile)
	cExtension := Alltrim(cExtension)
	
	If !(upper(Right( cFile ,len(cExtension))) == upper(cExtension))
		cFile	+= cExtension
	EndIf

Return(cPath+cFile)	

Static Function ExtFileName( cFile )
Local nPos, cFileName

	cFile := AllTrim(cFile)
	If (nPos := RAT("\", cFile)) != 0
 		cFileName = Right( cFile, len(cFile)-nPos )
	ElseIf (nPos := RAT(":", cFile)) != 0
 		cFileName = Right( cFile, len(cFile)-nPos )
	Else
		cFileName = cFile
	EndIf

Return cFileName

Static Function ExtFilePath( cFile )
Local nPos, cFilePath

	cFile := AllTrim(cFile)
	If (nPos := RAT("\", cFile)) != 0
 		cFilePath = SUBSTR(cFile, 1, nPos)
	ElseIf (nPos := RAT(":", cFile)) != 0
 		cFilePath = SUBSTR(cFile, 1, nPos)
	Else
		cFilePath = ""
	EndIf

Return cFilePath
