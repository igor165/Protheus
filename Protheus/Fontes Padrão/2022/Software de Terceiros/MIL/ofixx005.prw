// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 39     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "OFIXX005.ch"

Static lVZO := TCCanOpen(RetSqlName("VZO"))

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFIXX005   | Autor |  Luis Delorme         | Data | 25/09/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Politicas de Descontos e Promocoes de Pecas                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina / AutoPecas                                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXX005(cAlias,nReg,nOpc,lDuplica)
Local cTitle := STR0001 // ###"Formas de Descontos"
Local aTitles:= {STR0007,STR0008,STR0009,STR0010,STR0011} //###"1-Promocao"###"2-CAI"###"3-Grupo Peca"###"4-Grupo Desconto"###"5-Clas.Financ"###
Local aSizeAut	:= MsAdvSize(.t.)
Local aObjects := {}
Local nCntFor, nCntFor2
Local bCampo := { |nCPO| Field(nCPO) }
// Variaveis da Enchoice
Local aCpos := {}
Local nModelo := 3
Local cTudoOk := ".t."
Local lF3 := .f.
Local lMemoria := .t.
Local lColumn := .f.
Local cATela := ""
Local lNoFolder := .t.
Local lProperty := .f.
Private aCpoEncS := {}
Private lGerado := .f.
//
Private aNewBot := {}
Private aHeader1 := {}
Private aHeader2 := {}
Private aHeader3 := {}
Private aHeader4 := {}
Private aHeader5 := {}
Private aCols1   := {}
Private aTELA[0][0],aGETS[0]
Private aCols2   := {}
Private aCols3   := {}
Private aCols4   := {}
Private aCols5   := {}
//
Private lMLF := SB5->(FieldPos("B5_MARPEC")) > 0 .and. SB5->(FieldPos("B5_CODLIN")) > 0 .and. SB5->(FieldPos("B5_CODFAM")) > 0// quando .T. trabalha com Marca / Linha / Familia
//
If lMLF
	aTitles:= {STR0007,STR0008,STR0009,STR0010,STR0011,STR0012} //###"1-Promocao"###"2-CAI"###"3-Grupo Peca"###"4-Grupo Desconto"###"5-Clas.Financ"###6-Marca/Linha/Familia
	Private aHeader6 := {}
	Private aCols6   := {}
Endif
//
Private nOpcPE := nOpc
//
Private lPassou
Private nOpcSlv := nOpc
//
Default lDuplica := .f. // Duplica Cadastro ?
//                     
VISUALIZA	:= nOpc==2
INCLUI 		:= nOpc==3
ALTERA 		:= nOpc==4
EXCLUI 		:= nOpc==5
//
if ExistBlock("OX005BOT")
	aNewBot := ExecBlock("OX005BOT",.f.,.f.,{aNewBot})
endif
//
//################################################################
//# Especifica o espacamento entre os objetos principais da tela #
//################################################################
// Tela Superior - Enchoice do VEM - Tamanho vertical fixo
AAdd( aObjects, { 0,	90, .T., .F. } )
// Tela Dois - Folder (Pecas e Servicos) - Tamanho vertical VARIAVEL
AAdd( aObjects, { 0,	40, .T., .T. } )
//
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }// Tamanho total da tela
aPosObj := MsObjSize( aInfo, aObjects ) // Monta objetos conforme especificacoes
//
lMostraHist := .f.
//
If !lDuplica // NAO Duplica Cadastro
	if VISUALIZA .or. ALTERA
		if MsgYesNo(STR0029,STR0027)
			lMostraHist := .t.
		endif
	endif
EndIf

// ###############################################
// # Cria variaveis M->????? da Enchoice do VEM  #
// ###############################################
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VEM")
//
aCpoEncS  := {} 	// ARRAY DE CAMPOS DA ENCHOICE
aCpos  := {} 		// ARRAY DE CAMPOS DA ENCHOICE NAO EDITAVEIS
//
cEncNEdit := ""
cEnvNMostra := ""  
//
If lDuplica // Duplica Cadastro
	FS_NOPC(4) // manipula nOpc para 4
EndIf
While !Eof().and.(x3_arquivo=="VEM")
	If X3USO(x3_usado).and.cNivel>=x3_nivel .and. !(Alltrim(x3_campo)+"," $ cEnvNMostra)
		AADD(acpoEncS,x3_campo)
	EndIf
	If Inclui .and. !(Alltrim(x3_campo)+"," $ cEnvNMostra)
		&("M->"+x3_campo):= CriaVar(x3_campo)
	Else
		If x3_context == "V"
			&("M->"+x3_campo):= CriaVar(x3_campo)
		Else
			&("M->"+x3_campo):= &("VEM->"+x3_campo)
			&("cAnt"+Subs(x3_campo,5,6)):= &("VEM->"+x3_campo)
		EndIf
	EndIf
	If x3_context != "V"
		if !(Alltrim(x3_campo) $ cEncNEdit) .and.  !(Alltrim(x3_campo)+"," $ cEnvNMostra)
			if !(Altera .and. x3_campo $ "VEM_CODMAR,VEM_CENCUS") .or. lDuplica
				aAdd(aCpos,X3_CAMPO)
			endif
		endif
	endif
	DbSkip()
Enddo
//
For nCntFor:=1 to Iif(!lMLF,5,6)
	//###################################################################
	//# Cria variaveis de memoria, aHeader e aCols da GetDados          #
	//###################################################################
	cNaoMostra := OFX0050031_NaoMostra(nCntFor)
	//
	nUsadoTemp:=0
	//
	dbSelectArea("SX3")
	dbSetOrder(1)
	DBGoTop()
	dbSeek("VEN")
	// Cria Variaveis de Memoria e aHeader
	aHeaderTemp:= {}
	aAlterTemp := {}
	While !Eof().And.(x3_arquivo=="VEN")
		If  X3USO(x3_usado) .And. cNivel>=x3_nivel .and. !(Alltrim(x3_campo)+"," $ cNaoMostra)
			nUsadoTemp:=nUsadoTemp+1
			Aadd(aHeaderTemp,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,X3CBOX(),SX3->X3_RELACAO,".T."})
			if x3_usado != "V" .and. (INCLUI .or. ALTERA)
				aAdd(aAlterTemp,x3_campo)
			endif
		EndIf
		DbSkip()
	EndDo
	// Cria aCols
	If INCLUI
		aColsTemp := { Array(nUsadoTemp + 1) }
		aColsTemp[1,nUsadoTemp+1] := .F.
		For nCntFor2:=1 to nUsadoTemp
			aColsTemp[1,nCntFor2]:=CriaVar(aHeaderTemp[nCntFor2,2])
		Next
	Else
		aColsTemp:={}
		DbSelectArea("VEN")
		DbSetOrder(1) // VEN_FILIAL + VEN_CODMAR + VEN_CENCUS + VEN_TIPVEN + VEN_TIPNEG + VEN_CODCLI + VEN_LOJA + VEN_GRUITE + VEN_CODITE + VEN_FORPAG
		DbSeek( xFilial("VEN") + M->VEM_CODMAR + M->VEM_CENCUS + M->VEM_TIPVEN + M->VEM_TIPNEG + M->VEM_CODCLI + M->VEM_LOJA )
		While !Eof() .And. VEN->VEN_FILIAL == xFilial("VEN") .And. VEN->VEN_CODMAR == M->VEM_CODMAR .And. VEN->VEN_CENCUS == M->VEM_CENCUS ;
			.and. VEN->VEN_TIPVEN ==  M->VEM_TIPVEN .and. VEN->VEN_TIPNEG == M->VEM_TIPNEG ;
			.and. VEN->VEN_CODCLI ==  M->VEM_CODCLI .and. VEN->VEN_LOJA ==  M->VEM_LOJA

			if VEN->VEN_FORPAG <> M->VEM_FORPAG
				DBSkip()
				Loop
			EndIf
 
			if nCntFor == 1 .and. ( Empty(VEN->VEN_GRUITE) .or. Empty(VEN->VEN_CODITE))
				DBSkip()
				Loop
			Elseif nCntFor == 2 .and. Empty(VEN->VEN_CODCAI)
				DBSkip()
				Loop
			Elseif nCntFor == 3 .and. Empty(VEN->VEN_GRUPEC)
				DBSkip()
				Loop
			Elseif nCntFor == 4 .and. Empty(VEN->VEN_GRUDES)
				DBSkip()
				Loop
			Elseif nCntFor == 5 .and.  Empty(VEN->VEN_CLAFIN)
				DBSkip()
				Loop
			Elseif nCntFor == 6 .and. ( Empty(VEN->VEN_MARPEC) .and. Empty(VEN->VEN_CODLIN) .and. Empty(VEN->VEN_CODFAM))
				DBSkip()
				Loop
			Endif
			//
			if !lMostraHist
				if ddatabase > VEN->VEN_DATFIN
					DBSkip()
					loop
				endif
			endif
			//
			AADD(aColsTemp,Array(nUsadoTemp+1))
			//
			For nCntFor2:=1 to nUsadoTemp
				if aHeaderTemp[nCntFor2,10] == "V"
					SX3->(DBSetOrder(2))
					SX3->(DBSeek(aHeaderTemp[nCntFor2,2]))
					aColsTemp[Len(aColsTemp),nCntFor2] := &(sx3->x3_relacao)
				else
					aColsTemp[Len(aColsTemp),nCntFor2] := FieldGet(FieldPos(aHeaderTemp[nCntFor2,2]))
				endif
			Next
			aColsTemp[Len(aColsTemp),nUsadoTemp+1]:=.F.
			DbSkip()
		EndDo
	EndIf
	if nCntFor == 1
		aHeader1 := aClone(aHeaderTemp)
		aAlter1 := aClone(aAlterTemp)
		aCols1 := aClone(aColsTemp)
		nUsado1 := nUsadoTemp
	elseif nCntFor == 2
		aHeader2 := aClone(aHeaderTemp)
		aAlter2 := aClone(aAlterTemp)
		aCols2 := aClone(aColsTemp)
		nUsado2 := nUsadoTemp
	elseif nCntFor == 3
		aHeader3 := aClone(aHeaderTemp)
		aAlter3 := aClone(aAlterTemp)
		aCols3 := aClone(aColsTemp)
		nUsado3 := nUsadoTemp
	elseif nCntFor == 4
		aHeader4 := aClone(aHeaderTemp)
		aAlter4 := aClone(aAlterTemp)
		aCols4 := aClone(aColsTemp)
		nUsado4 := nUsadoTemp
	elseif nCntFor == 5
		aHeader5 := aClone(aHeaderTemp)
		aAlter5 := aClone(aAlterTemp)
		aCols5 := aClone(aColsTemp)
		nUsado5 := nUsadoTemp
	elseif nCntFor == 6
		aHeader6 := aClone(aHeaderTemp)
		aAlter6 := aClone(aAlterTemp)
		aCols6 := aClone(aColsTemp)
		nUsado6 := nUsadoTemp
	endif
Next
// Monta variaveis de memoria da acols
RegToMemory("VEN",(nOpc==3))
//
If lDuplica // Duplica Cadastro
	FS_NOPC(nOpcSlv) // volta nOpc padrao
EndIf
//
cLinOk   := "OX005LOK()" // LinOk das acols
cTudOk   := "OX005TOK()" // TudoOk da gravacao (botao da enchoicebar)
cFieldOk := "OX005FOK()" // FieldOk das acols
//
DbSelectArea("VEM")
nOpca := 0
oDialog := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cTitle,,,,,,,,,.t.)
//
oEnch := MSMGet():New( cAlias ,nReg,nOpc,,,,aCpoEncS, aPosObj[1],aCpos,nModelo,,,cTudOk,oDialog,lF3,lMemoria,lColumn,caTela,lNoFolder, lProperty)
//
oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{}, oDialog,,,,.t.,.f.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
oFolder:bChange    := {||  OX005MUDFOL() }   // Executa na mudanca da aba
//
DbSelectArea("VEN")
oGet1 := MsNewGetDados():New(0, 0, aPosObj[2,3]-aPosObj[2,1]-14 ,aPosObj[2,4]-aPosObj[2,2],3,cLinOK,cTudOk,,aAlter1,0,9999,cFieldOk,,,oFolder:aDialogs[1],aHeader1,aCols1 )
oGet1:oBrowse:bDelete       := {||OX005DLIN() }
oGet1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGet2 := MsNewGetDados():New(0, 0, aPosObj[2,3]-aPosObj[2,1]-14 ,aPosObj[2,4]-aPosObj[2,2],3,cLinOK,cTudOk,,aAlter2,0,999,cFieldOk,,,oFolder:aDialogs[2],aHeader2,aCols2 )
oGet2:oBrowse:bDelete       := {||OX005DLIN() }
oGet2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGet3 := MsNewGetDados():New(0, 0, aPosObj[2,3]-aPosObj[2,1]-14 ,aPosObj[2,4]-aPosObj[2,2],3,cLinOK,cTudOk,,aAlter3,0,999,cFieldOk,,,oFolder:aDialogs[3],aHeader3,aCols3 )
oGet3:oBrowse:bDelete       := {||OX005DLIN() }
oGet3:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGet4 := MsNewGetDados():New(0, 0, aPosObj[2,3]-aPosObj[2,1]-14 ,aPosObj[2,4]-aPosObj[2,2],3,cLinOK,cTudOk,,aAlter4,0,999,cFieldOk,,,oFolder:aDialogs[4],aHeader4,aCols4 )
oGet4:oBrowse:bDelete       := {||OX005DLIN() }
oGet4:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGet5 := MsNewGetDados():New(0, 0, aPosObj[2,3]-aPosObj[2,1]-14 ,aPosObj[2,4]-aPosObj[2,2],3,cLinOK,cTudOk,,aAlter5,0,999,cFieldOk,,,oFolder:aDialogs[5],aHeader5,aCols5 )
oGet5:oBrowse:bDelete       := {||OX005DLIN() }
oGet5:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
If lMLF
	oGet6 := MsNewGetDados():New(0, 0, aPosObj[2,3]-aPosObj[2,1]-14 ,aPosObj[2,4]-aPosObj[2,2],3,cLinOK,cTudOk,,aAlter6,0,999,cFieldOk,,,oFolder:aDialogs[6],aHeader6,aCols6)
	oGet6:oBrowse:bDelete       := {||OX005DLIN() }
	oGet6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Endif
//
oDialog:bInit := {|| EnchoiceBar(oDialog, { || If(obrigatorio(aGets,aTela) .and. OX005TOK(nOpc),OX005GRV(nOpc),.t.) } , { || nOpca := 0,lRet:=OX005SAIR(nOpc) },,aNewBot )}
oDialog:Activate()
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX005LOK   | Autor |  Luis Delorme         | Data | 25/09/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | LinOK das aCols                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX005LOK(nFolder, lDel)
Local lRet := .T.
Local cCaption := oFolder:aDialogs[oFolder:nOption]:cCaption
Local nCntFor
Local nPosGruite
Local nPosCodite
Local nPosDatIni
Local nPosDatFin
Local nPosCodCai
Local nPosGruPec
Local nPosGruDes
Local nPosClaFin
Local nPosModVei
Local nPosMarPec
Local nPosCodLin
Local nPosCodFam
//
Local wnk, nwnk2, nwnk
//
Default nFolder := oFolder:nOption
Default lDel := .f.
//
if VISUALIZA
	return .t.
endif
//
oGet := &("oGet"+strzero(nFolder,1))
aHeader := &("aHeader"+strzero(nFolder,1))
nPosGruite := Ascan(&("aHeader"+strzero(nFolder,1)),{|x| Alltrim(Upper(x[2]))=="VEN_GRUITE"})
nPosCodite := Ascan(&("aHeader"+strzero(nFolder,1)),{|x| Alltrim(Upper(x[2]))=="VEN_CODITE"})
nPosDatIni := Ascan(&("aHeader"+strzero(nFolder,1)),{|x| Alltrim(Upper(x[2]))=="VEN_DATINI"})
nPosDatFin := Ascan(&("aHeader"+strzero(nFolder,1)),{|x| Alltrim(Upper(x[2]))=="VEN_DATFIN"})
nPosCodCai := Ascan(&("aHeader"+strzero(nFolder,1)),{|x| Alltrim(Upper(x[2]))=="VEN_CODCAI"})
nPosGruPec := Ascan(&("aHeader"+strzero(nFolder,1)),{|x| Alltrim(Upper(x[2]))=="VEN_GRUPEC"})
nPosGruDes := Ascan(&("aHeader"+strzero(nFolder,1)),{|x| Alltrim(Upper(x[2]))=="VEN_GRUDES"})
nPosClaFin := Ascan(&("aHeader"+strzero(nFolder,1)),{|x| Alltrim(Upper(x[2]))=="VEN_CLAFIN"})
nPosModVei := Ascan(&("aHeader"+strzero(nFolder,1)),{|x| Alltrim(Upper(x[2]))=="VEN_MODVEI"})
nPosQtdMin := Ascan(&("aHeader"+strzero(nFolder,1)),{|x| Alltrim(Upper(x[2]))=="VEN_QTDITE"})
nPosMarPec := Ascan(&("aHeader"+strzero(nFolder,1)),{|x| Alltrim(Upper(x[2]))=="VEN_MARPEC"})
nPosCodLin := Ascan(&("aHeader"+strzero(nFolder,1)),{|x| Alltrim(Upper(x[2]))=="VEN_CODLIN"})
nPosCodFam := Ascan(&("aHeader"+strzero(nFolder,1)),{|x| Alltrim(Upper(x[2]))=="VEN_CODFAM"})

// se estiver deletado
If oGet:aCols[oGet:nAt,Len(oGet:aCols[oGet:nAt])]
	Return .T.
Endif

// confere se os campos principais não customizados estão em branco
lTudoBranco := .t.
Do Case
	Case nFolder == 1 .and. (!Empty(oGet:aCols[oGet:nAt,nPosCodIte]) .or. !Empty(oGet:aCols[oGet:nAt,nPosGruIte]))
		lTudoBranco := .f.
	Case nFolder == 2 .and. !Empty(oGet:aCols[oGet:nAt,nPosCodCai])
		lTudoBranco := .f.
	Case nFolder == 3 .and. !Empty(oGet:aCols[oGet:nAt,nPosGruPec])
		lTudoBranco := .f.
	Case nFolder == 4 .and. !Empty(oGet:aCols[oGet:nAt,nPosGruDes])
		lTudoBranco := .f.
	Case nFolder == 5 .and. !Empty(oGet:aCols[oGet:nAt,nPosClaFin])
		lTudoBranco := .f.
	Case nFolder == 6 .and. !Empty(oGet:aCols[oGet:nAt,nPosMarPec])
		lTudoBranco := .f.
EndCase

if lTudoBranco
	return .t.
endif
// verifica campos chave da linha
// caso a chamada tenha sido executada a partir de uma operacao de delecao nao podemos olhar obrigatoriedade de campos
if !lDel
	If nFolder == 1 .And. Empty(oGet:aCols[oGet:nAt,nPosCodIte])
		Help(" ",1,"OBRIGAT",,STR0017+cCaption +": "+ RetTitle("VEN_GRUITE") ,3,1) // "Pasta: "
		return .f.
	endif
	If nFolder == 1 .And. Empty(oGet:aCols[oGet:nAt,nPosGruIte])
		Help(" ",1,"OBRIGAT",,STR0017+cCaption +": "+ RetTitle("VEN_CODITE") ,3,1) // "Pasta: "
		return .f.
	endif
	If nFolder == 2 .And. Empty(oGet:aCols[oGet:nAt,nPosCodCai])
		Help(" ",1,"OBRIGAT",,STR0017+cCaption +": "+ RetTitle("VEN_CODCAI") ,3,1) // "Pasta: "
		return .f.
	endif
	If nFolder == 3 .And. Empty(oGet:aCols[oGet:nAt,nPosGruPec])
		Help(" ",1,"OBRIGAT",,STR0017+cCaption +": "+ RetTitle("VEN_GRUPEC") ,3,1) // "Pasta: "
		return .f.
	endif
	If nFolder == 4 .And. Empty(oGet:aCols[oGet:nAt,nPosGruDes])
		Help(" ",1,"OBRIGAT",,STR0017+cCaption +": "+ RetTitle("VEN_GRUDES") ,3,1) // "Pasta: "
		return .f.
	endif
	If nFolder == 5 .And. Empty(oGet:aCols[oGet:nAt,nPosClaFin])
		Help(" ",1,"OBRIGAT",,STR0017+cCaption +": "+ RetTitle("VEN_MODVEI") ,3,1) // "Pasta: "
		return .f.
	endif
	If nFolder == 6 .And. Empty(oGet:aCols[oGet:nAt,nPosMarPec])
		Help(" ",1,"OBRIGAT",,STR0017+cCaption +": "+ RetTitle("VEN_MARPEC") ,3,1) // "Pasta: "
		return .f.
	endif
	If nPosDatIni > 0 .and. nPosDatFin > 0
		If Empty(oGet:aCols[oGet:nAt,nPosDatIni])
			Help(" ",1,"OBRIGAT",,STR0017+cCaption +": "+ RetTitle("VEN_DATINI")  ,3,1) // "Pasta: "
			return .f.
		endif
		If Empty(oGet:aCols[oGet:nAt,nPosDatFin])
			Help(" ",1,"OBRIGAT",,STR0017+cCaption +": "+ RetTitle("VEN_DATFIN")  ,3,1) // "Pasta: "
			return .f.
		endif
		If oGet:aCols[oGet:nAt,nPosDatIni] > oGet:aCols[oGet:nAt,nPosDatFin]
			Help(" ",1,"DATAMENOR",,STR0017+cCaption ,3,1)
			Return .F.
		Endif
	endif
EndIf
// verifica duplicidades
For nCntFor := 1 to Len(oGet:aCols)
	if nCntFor != oGet:nAt
		if  !(oGet:aCols[nCntFor,len(oGet:aCols[nCntFor])])
			if !(oGet:aCols[nCntFor,nPosDatFin] < oGet:aCols[oGet:nAt,nPosDatIni] .or. oGet:aCols[oGet:nAt,nPosDatFin] < oGet:aCols[nCntFor,nPosDatIni])
				If nFolder == 1 .and. oGet:aCols[oGet:nAt,nPosGruIte]+oGet:aCols[oGet:nAt,nPosCodIte] == oGet:aCols[nCntFor,nPosGruIte]+oGet:aCols[nCntFor,nPosCodIte];
					.and. oGet:aCols[oGet:nAt,nPosQtdMin] == oGet:aCols[nCntFor,nPosQtdMin]
					Help("  ",1,"JAGRAVADO",,STR0018+cCaption,3,1)  //"Item Duplicado na Pasta: "
					return .f.
				Elseif nFolder == 2 .and. oGet:aCols[oGet:nAt,nPosCodCai] == oGet:aCols[nCntFor,nPosCodCai]
					Help("  ",1,"JAGRAVADO",,STR0018+cCaption,3,1)  //"Item Duplicado na Pasta: "
					return .f.
				Elseif nFolder == 3 .and. oGet:aCols[oGet:nAt,nPosGruPec] == oGet:aCols[nCntFor,nPosGruPec]
					Help("  ",1,"JAGRAVADO",,STR0018+cCaption,3,1)  //"Item Duplicado na Pasta: "
					return .f.
				Elseif nFolder == 4 .and. oGet:aCols[oGet:nAt,nPosGruDes] == oGet:aCols[nCntFor,nPosGruDes]
					Help("  ",1,"JAGRAVADO",,STR0018+cCaption,3,1)  //"Item Duplicado na Pasta: "
					return .f.
				Elseif nFolder == 5 .and. oGet:aCols[oGet:nAt,nPosClaFin] == oGet:aCols[nCntFor,nPosClaFin]
					Help("  ",1,"JAGRAVADO",,STR0018+cCaption,3,1)  //"Item Duplicado na Pasta: "
					return .f.
				Elseif nFolder == 6 .and. oGet:aCols[oGet:nAt,nPosMarPec]+oGet:aCols[oGet:nAt,nPosCodLin]+oGet:aCols[oGet:nAt,nPosCodFam] == oGet:aCols[nCntFor,nPosMarPec]+oGet:aCols[nCntFor,nPosCodLin]+oGet:aCols[nCntFor,nPosCodFam]
					Help("  ",1,"JAGRAVADO",,STR0018+cCaption,3,1)  //"Item Duplicado na Pasta: "
					return .f.
				endif
			endif
		endif
	endif
Next
//
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX005TOK   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Tudo OK                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX005TOK()
Local cQuery  := ""
Local nRECVEM := 0
if VISUALIZA
	return .t.
endif
DBSelectArea("VEM")
DBSetOrder(1) // VEM_FILIAL+VEM_CODMAR+VEM_CENCUS+VEM_TIPVEN+VEM_TIPNEG+VEM_CODCLI+VEM_LOJA 
if INCLUI
	If !lGerado
		cQuery := "SELECT VEM.R_E_C_N_O_ RECVEM FROM "+RetSqlName("VEM")+" VEM "
		cQuery += "WHERE VEM.VEM_FILIAL='"+xFilial("VEM")+"' AND "
		cQuery += "VEM.VEM_CODMAR='"+M->VEM_CODMAR+"' AND "
		cQuery += "VEM.VEM_CENCUS='"+M->VEM_CENCUS+"' AND "
		cQuery += "VEM.VEM_TIPVEN='"+M->VEM_TIPVEN+"' AND "
		cQuery += "VEM.VEM_TIPNEG='"+M->VEM_TIPNEG+"' AND "
		cQuery += "VEM.VEM_CODCLI='"+M->VEM_CODCLI+"' AND VEM.VEM_LOJA='"+M->VEM_LOJA+"'  AND "
		cQuery += "VEM.VEM_FORPAG='"+M->VEM_FORPAG+"' AND "
		cQuery += "VEM.D_E_L_E_T_=' '"
		nRECVEM := FM_SQL(cQuery)
		If nRECVEM > 0
			if !MsgYesNo(STR0030,STR0027)
				return .f.
			endif
			DBSelectArea("VEM")
			DBGoTo(nRECVEM)
		endif
	endif
endif
if !OX005LOK()
	return .f.
endif
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX005FOK   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Field OK                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX005FOK()
if ReadVar() == "M->VEN_CODITE"
	If Empty(aCols[n,FG_POSVAR("VEN_GRUITE","aHeader1")])
		M->VEN_GRUITE := ""
	Endif	
	if !Empty(M->VEN_CODITE)
		if !FG_POSSB1("M->VEN_CODITE","SB1->B1_CODITE", "M->VEN_GRUITE") 
			MsgStop(STR0042)
			return(.f.)
		Endif
		aCols[n,FG_POSVAR("VEN_GRUITE","aHeader1")] := M->VEN_GRUITE
		if !FG_VALIDA(,"SB1T7M->VEN_GRUITE+M->VEN_CODITE*")	
			return(.f.)
		Endif
	Endif
Endif	
return(.t.)
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX005MUDFOL| Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Mudanca de Folder                                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX005MUDFOL()
Local nCntFor
Local lMLF := SB5->(FieldPos("B5_MARPEC")) > 0 .and. SB5->(FieldPos("B5_CODLIN")) > 0 .and. SB5->(FieldPos("B5_CODFAM")) > 0// quando .T. trabalha com Marca / Linha / Familia
//
if lPassou
	lPassou := .f.
	return .t.
endif
for nCntFor := 1 to Iif(!lMLF,5,6)
	if nCntFor != oFolder:nOption
		if !OX005LOK(nCntFor)
			lPassou := .t.
			oFolder:nOption := nCntFor
			return .f.
		endif
	endif
next

return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX005DLIN  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Deletar Linha                                                |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX005DLIN()
//
Local nCntFor

oGet := &("oGet"+strzero(oFolder:nOption,1))
aHeader := &("aHeader"+strzero(oFolder:nOption,1))

If oGet:aCols[oGet:nAt,Len(oGet:aCols[oGet:nAt])]
	oGet:aCols[oGet:nAt,Len(oGet:aCols[oGet:nAt])] := .f.
	// Verifica se o produto ja foi lancado no orcamento
	if !OX005LOK(,.t.)
		oGet:aCols[oGet:nAt,Len(oGet:aCols[oGet:nAt])] := .t.
	endif
Else
	oGet:aCols[oGet:nAt,Len(oGet:aCols[oGet:nAt])] := .t.
EndIf
//
oGet:obrowse:Refresh()
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX005SAIR  | Autor |  Luis Delorme         | Data | 28/09/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Funcao de saida da enchoicebar                               |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX005SAIR(nOpc)
if nOpc == 2
	oDialog:End()
	return .t.
endif
if MsgYesNo(STR0031,STR0027)
	oDialog:End()
	return .t.
endif
return .f.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX005GRV   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Gravacao da Politica de Desconto e Promocao de Pecas         |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX005GRV(nOpc, lEncerra)
Local nCntFor,nCntFor2,nCntFor3
Local lMLF := SB5->(FieldPos("B5_MARPEC")) > 0 .and. SB5->(FieldPos("B5_CODLIN")) > 0 .and. SB5->(FieldPos("B5_CODFAM")) > 0// quando .T. trabalha com Marca / Linha / Familia

Default lEncerra := .t.
// quando esta visualizando, apenas retorna
if nOpc == 2
	return .t.
endif
//
// ------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION // --------I-N-I-C-I-O---D-A---T-R-A-N-S-A-C-A-O---------------------------------------------
// ------------------------------------------------------------------------------------------------------------
If !TCCanOpen(RetSqlName("VEM"))
	DisarmTransaction()
	MsgStop(STR0032+CHR(10)+STR0033,STR0027)
	return .f.
endif
If !TCCanOpen(RetSqlName("VEN"))
	DisarmTransaction()
	MsgStop(STR0034+CHR(10)+STR0035,STR0016)
	return .f.
endif

// ############################################################
// # Apaga qualquer gravacao anterior                         #
// ############################################################
if INCLUI
	cString := "DELETE FROM "+RetSqlName("VEM")+ " WHERE VEM_FILIAL='"+ xFilial("VEM")+"' AND VEM_CODMAR='"+M->VEM_CODMAR+"' AND VEM_CENCUS='"+M->VEM_CENCUS+"' AND VEM_TIPVEN='"+M->VEM_TIPVEN+"' "
	cString += "AND VEM_CODCLI='"+M->VEM_CODCLI+"' AND VEM_LOJA='"+M->VEM_LOJA+"' AND VEM_TIPNEG='"+M->VEM_TIPNEG+"' AND VEM_FORPAG='"+M->VEM_FORPAG+"'"
	TCSqlExec(cString)
	cString := "DELETE FROM "+RetSqlName("VEN")+ " WHERE VEN_FILIAL='"+ xFilial("VEN")+"' AND VEN_CODMAR='"+M->VEM_CODMAR+"' AND VEN_CENCUS='"+M->VEM_CENCUS+"' AND VEN_TIPVEN='"+M->VEM_TIPVEN+"' "
	cString += "AND VEN_CODCLI='"+M->VEM_CODCLI+"' AND VEN_LOJA='"+M->VEM_LOJA+"' AND VEN_TIPNEG='"+M->VEM_TIPNEG+"' AND VEN_FORPAG='"+M->VEM_FORPAG+"'"
	TCSqlExec(cString)
else
	cString := "DELETE FROM "+RetSqlName("VEM")+ " WHERE VEM_FILIAL='"+ xFilial("VEM")+"' AND VEM_CODMAR='"+cAntCODMAR+"' AND VEM_CENCUS='"+cAntCENCUS+"' AND VEM_TIPVEN='"+cAntTIPVEN+"' "
	cString += "AND VEM_CODCLI='"+cAntCODCLI+"' AND VEM_LOJA='"+cAntLOJA+"' AND VEM_TIPNEG='"+cAntTIPNEG+"' AND VEM_FORPAG='"+cAntFORPAG+"'"
	TCSqlExec(cString)
	cString := "DELETE FROM "+RetSqlName("VEN")+ " WHERE VEN_FILIAL='"+ xFilial("VEN")+"' AND VEN_CODMAR='"+cAntCODMAR+"' AND VEN_CENCUS='"+cAntCENCUS+"' AND VEN_TIPVEN='"+cAntTIPVEN+"' "
	cString += "AND VEN_CODCLI='"+cAntCODCLI+"' AND VEN_LOJA='"+cAntLOJA+"' AND VEN_TIPNEG='"+cAntTIPNEG+"' AND VEN_FORPAG='"+cAntFORPAG+"'"
	TCSqlExec(cString)
endif
//
if nOpc != 5
	reclock("VEM",.t.)
	VEM->VEM_FILIAL := xFilial("VEM")
	FG_GRAVAR("VEM")
	msunlock()
	//
	DBSelectArea("VEN")
	for nCntFor3 := 1 to Iif(!lMLF,5,6)
		oGet := &("oGet"+strzero(nCntFor3,1))
		aHeader := &("aHeader"+strzero(nCntFor3,1))
		//
		nPosGruite := Ascan(&("aHeader"+strzero(nCntFor3,1)),{|x| Alltrim(Upper(x[2]))=="VEN_GRUITE"})
		nPosCodite := Ascan(&("aHeader"+strzero(nCntFor3,1)),{|x| Alltrim(Upper(x[2]))=="VEN_CODITE"})
		nPosDatIni := Ascan(&("aHeader"+strzero(nCntFor3,1)),{|x| Alltrim(Upper(x[2]))=="VEN_DATINI"})
		nPosDatFin := Ascan(&("aHeader"+strzero(nCntFor3,1)),{|x| Alltrim(Upper(x[2]))=="VEN_DATFIN"})
		nPosCodCai := Ascan(&("aHeader"+strzero(nCntFor3,1)),{|x| Alltrim(Upper(x[2]))=="VEN_CODCAI"})
		nPosGruPec := Ascan(&("aHeader"+strzero(nCntFor3,1)),{|x| Alltrim(Upper(x[2]))=="VEN_GRUPEC"})
		nPosGruDes := Ascan(&("aHeader"+strzero(nCntFor3,1)),{|x| Alltrim(Upper(x[2]))=="VEN_GRUDES"})
		nPosClaFin := Ascan(&("aHeader"+strzero(nCntFor3,1)),{|x| Alltrim(Upper(x[2]))=="VEN_CLAFIN"})
		nPosModVei := Ascan(&("aHeader"+strzero(nCntFor3,1)),{|x| Alltrim(Upper(x[2]))=="VEN_MODVEI"})
		nPosMarPec := Ascan(&("aHeader"+strzero(nCntFor3,1)),{|x| Alltrim(Upper(x[2]))=="VEN_MARPEC"})
		nPosCodLin := Ascan(&("aHeader"+strzero(nCntFor3,1)),{|x| Alltrim(Upper(x[2]))=="VEN_CODLIN"})
		nPosCodFam := Ascan(&("aHeader"+strzero(nCntFor3,1)),{|x| Alltrim(Upper(x[2]))=="VEN_CODFAM"})
		//
		for nCntFor := 1 to Len(oGet:aCols)
			lProcessa := .t.
			if !oGet:aCols[nCntFor,len(oGet:aCols[nCntFor])]
				Do Case
					Case nCntFor3 == 1 .and. Empty(oGet:aCols[nCntFor,nPosGruIte]) .and. Empty(oGet:aCols[nCntFor,nPosCodIte])
						lProcessa := .f.
					Case nCntFor3 == 2 .and. Empty(oGet:aCols[nCntFor,nPosCodCai])
						lProcessa := .f.
					Case nCntFor3 == 3 .and. Empty(oGet:aCols[nCntFor,nPosGruPec])
						lProcessa := .f.
					Case nCntFor3 == 4 .and. Empty(oGet:aCols[nCntFor,nPosGruDes])
						lProcessa := .f.
					Case nCntFor3 == 5 .and. Empty(oGet:aCols[nCntFor,nPosClaFin])
						lProcessa := .f.
					Case nCntFor3 == 6 .and. Empty(oGet:aCols[nCntFor,nPosMarPec])
						lProcessa := .f.
				EndCase
				if lProcessa
					reclock("VEN",.t.)
					VEN->VEN_FILIAL := xFilial("VEN")
					VEN->VEN_CODMAR := M->VEM_CODMAR
					VEN->VEN_CENCUS := M->VEM_CENCUS
					VEN->VEN_CODCLI := M->VEM_CODCLI
					VEN->VEN_LOJA   := M->VEM_LOJA
					VEN->VEN_FORPAG := M->VEM_FORPAG
					VEN->VEN_TIPVEN := M->VEM_TIPVEN
					VEN->VEN_TIPNEG := M->VEM_TIPNEG
					for nCntFor2 := 1 to Len(aHeader)
						if aHeader[nCntFor2,10] <> "V"
							&(aHeader[nCntFor2,2]) := oGet:aCols[nCntFor,nCntFor2]
						endif
					next
				endif
			endif
		next
	next
endif
// ------------------------------------------------------------------------------------------------------------
END TRANSACTION // --------F-I-N-A-L---D-A---T-R-A-N-S-A-C-A-O-------------------------------------------------
// ------------------------------------------------------------------------------------------------------------
If ExistBlock("OX005DGR")
	ExecBlock("OX005DGR",.f.,.f.)
EndIf
//
if lEncerra
	lGerado := .f.
	oDialog:End()
endif
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | PROMOKIT2  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Kit                                                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function PROMOKIT2()

Local cGruKit := ""
Local cCodKit := ""
Local lRet := .f.
Local _ni, cont
Local aRet := {}
Private lJaPerg := .t.

return .t.
aRet := OFIOC040(M->VEN_GRUITE,M->VEN_CODITE)
if (valtype(aRet) = "A") .and. (Len(aRet) > 0)
	cGruKit := M->VEN_GRUITE
	cCodKit := M->VEN_CODITE
	For cont:=1 to Len(aRet)
		if cont > 1
			AADD(aCols,Array(nUsado1+1))
		Endif
		aCols[Len(aCols),nUsado1+1]:=.F.
		For _ni:=1 to nUsado1
			aCols[Len(aCols),_ni]:=CriaVar(aHeader1[_ni,2])
		Next
		
		SB1->(dbSetOrder(7))
		SB1->(dbSeek(xFilial("SB1")+aRet[cont,1]+aRet[cont,2]))
		n := Len(aCols)
		M->VEN_GRUITE := aRet[cont,1]
		M->VEN_CODITE := aRet[cont,2]
		aCols[Len(aCols),FG_POSVAR("VEN_GRUITE","aHeader1")] := aRet[cont,1]
		aCols[Len(aCols),FG_POSVAR("VEN_CODITE","aHeader1")] := aRet[cont,2]
		if FG_POSVAR("VEN_GRUKIT","aHeader1") > 0
			aCols[Len(aCols),FG_POSVAR("VEN_GRUKIT","aHeader1")] := cGruKit
			aCols[Len(aCols),FG_POSVAR("VEN_CODKIT","aHeader1")] := cCodKit
		Endif
		lRet := .t.
	Next
Endif
dbSelectArea("VEN")

Return(lRet)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX005PERDES| Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Retorna Politica de Desconto                                 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX005PERDES(cMarca,cCenRes,cGrupo,cCodite,nQtd,nPercent,lHlp,cCliente,cLoja,cTipVen,nValUni,nTipoRet,cForPag,cFormAlu,lFechOfi,lConMrgLuc)
//
Local nCntFor
Local aRet := {}
Local aRet2 := {0,999999,999999,"1"}
Local aRet3 := {0,999999,999999}
//
Private lMLF := SB5->(FieldPos("B5_MARPEC")) > 0 .and. SB5->(FieldPos("B5_CODLIN")) > 0 .and. SB5->(FieldPos("B5_CODFAM")) > 0// quando .T. trabalha com Marca / Linha / Familia
Private lSBZ := ( SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ" )
//
Default cCliente   := ""
Default cLoja      := ""
Default cTipVen    := ""
Default nValUni    := 0
Default nTipoRet   := 1
Default cForPag    := ""
Default cFormAlu   := GetNewPar("MV_FORMALU","")
Default lFechOfi   := .f. 	// Indica que é fachamento de oficina 
Default lConMrgLuc := .t.
//
cTipNeg := ""
//
//if TCCanOpen(RetSqlName("VZO"))
If lVZO
	cTipNeg := space(TamSX3("VZO_TIPO")[1])
	DBSelectArea("VZO")
	DBSetOrder(1)
	if DBSeek(xFilial("VZO")+SA1->A1_COD+SA1->A1_LOJA)
		while xFilial("VZO")+SA1->A1_COD+SA1->A1_LOJA == VZO_FILIAL+VZO_CLIENT+VZO_LOJA
			cTipNeg := VZO->VZO_TIPO
			aAdd(aRet, OX005PDU(cMarca,cCenRes,cGrupo,cCodite,nQtd,nPercent,lHlp,cCliente,cLoja,cTipVen,nValUni,nTipoRet,cTipNeg,cForPag,cFormAlu,lFechOfi,lConMrgLuc))
			DBSelectArea("VZO")
			DBSkip()
		enddo

		for nCntFor := 1 to Len(aRet)
			if  nTipoRet == 1
				if aRet[nCntFor] == .f.
					return .f.
				endif
			elseif  nTipoRet == 2
				IF aRet[nCntFor,1] > aRet2[1]
					aRet2[1] := aRet[nCntFor,1]
				endif
				IF aRet[nCntFor,2] < aRet2[2]
					aRet2[2] := aRet[nCntFor,2]
				endif
				IF aRet[nCntFor,3] < aRet2[3]
					aRet2[3] := aRet[nCntFor,3]
				endif
				aRet2[4] := aRet[nCntFor,4]
			else
				IF aRet[nCntFor,1] > aRet3[1]
					aRet3[1] := aRet[nCntFor,1]
				endif
				IF aRet[nCntFor,2] < aRet3[2]
					aRet3[2] := aRet[nCntFor,2]
				endif
				IF aRet[nCntFor,3] < aRet3[3]
					aRet3[3] := aRet[nCntFor,3]
				endif
			endif
		next
		if  nTipoRet == 1
			return .t.
		elseif nTipoRet == 2
			return aRet2
		else
			return aRet3
		endif
	endif
endif	
//
return OX005PDU(cMarca,cCenRes,cGrupo,cCodite,nQtd,nPercent,lHlp,cCliente,cLoja,cTipVen,nValUni,nTipoRet,cTipNeg,cForPag,cFormAlu,lFechOfi,lConMrgLuc)
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX005PDU   | Autor |  Luis Delorme      	  | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Retorna Politica de Desconto                                 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX005PDU(cMarca,cCenRes,cGrupo,cCodite,nQtd,nPercent,lHlp,cCliente,cLoja,cTipVen,nValUni,nTipoRet,cTipNeg,cForPag,cFormAlu,lFechOfi,lConMrgLuc)
Local nCntFor    := 0
Local cQuery     := ""
Local cSQLAlias  := "SQLVEMVEN"
Local nRECVEM    := 0
//
Local cMarPec := ""
Local cCodLin := ""
Local cCodFam := ""
//
Local lContMlf := .t.
//
Local cPermDesc  := "1" // 1=Permite Desconto em Promocao - Default
Local lVENPERDCP := ( VEN->(ColumnPos("VEN_PERDCP")) > 0 ) // Permite Desconto MAIOR no Item da Promocao ?
//
Default nTipoRet   := 1
Default cFormAlu   := GetNewPar("MV_FORMALU","")
Default lFechOfi   := .f.	// Indica que é fechamento de oficina
Default lConMrgLuc := .t.
//
aMaxDesc    := {  -1,-1,-1,-1,-1,-1}
aMargMin    := {  -1,-1,-1,-1,-1,-1}
aFormulas	:= { "","","","","","" }
nPrecoFixo := -1
nDescoFixo := -1
aRet  := { 0,0,0,"1" }
aRet3 := { 0,0,0 }
//
DBSelectArea("SB1")
DBSetOrder(7)
MsSeek(xFilial("SB1") + cGrupo + cCodite)
//
DBSelectArea("SB5")
DBSetOrder(1)
MsSeek(xFilial("SB5") + SB1->B1_COD )
If  lSBZ
	DBSelectArea("SBZ")
	DBSetOrder(1)
	MsSeek(xFilial("SBZ") + SB1->B1_COD )                                    
Endif
If lMLF
	cMarPec := SB5->B5_MARPEC
	cCodLin := SB5->B5_CODLIN
	cCodFam := SB5->B5_CODFAM
	If  lSBZ
		If SBZ->(FieldPos("BZ_MARPEC")) > 0 .and. !Empty(SBZ->BZ_MARPEC)
			cMarPec := SBZ->BZ_MARPEC
		Endif
		If SBZ->(FieldPos("BZ_CODLIN")) > 0 .and. !Empty(SBZ->BZ_CODLIN)
			cCodLin := SBZ->BZ_CODLIN
		Endif
		If SBZ->(FieldPos("BZ_CODFAM")) > 0 .and. !Empty(SBZ->BZ_CODFAM)
			cCodFam := SBZ->BZ_CODFAM
		Endif
	Endif
Endif
//
DBSelectArea("SB2")
DBSetOrder(1)
MsSeek( xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") )
//
If Month(dDataBase)==1
	cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
Else
	cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
EndIf
DbSelectArea("SBL")
DbSetOrder(1)
MsSeek(xFilial("SBL")+SB1->B1_COD+cAnoMes)
//
DBSelectArea("VEM")
DBSetOrder(1)
//
nQtdTopo := 0
//
For nCntFor := 1 to 4
	//
	cQuery := "SELECT VEN.VEN_GRUITE , VEN.VEN_CODITE , VEN.VEN_CLAFIN , VEN.VEN_CODCAI , VEN.VEN_GRUDES , "
	cQuery += "VEN.VEN_GRUPEC , VEN.VEN_MARMIN , VEN.VEN_PERDES , VEN.VEN_QTDITE , VEN.VEN_VALPRO , "
	If lVENPERDCP
		cQuery += "VEN.VEN_PERDCP , "
	EndIf
	If lMLF // Utiliza Marca / Linha / Familia
		cQuery += "VEN.VEN_MARPEC , VEN.VEN_CODLIN , VEN.VEN_CODFAM , "
	Endif
	cQuery += "VEM.R_E_C_N_O_ RECVEM FROM "+RetSqlName("VEM")+" VEM "
	cQuery += "JOIN "+RetSqlName("VEN")+" VEN ON ( "
	cQuery += "VEN.VEN_FILIAL=VEM.VEM_FILIAL AND "
	cQuery += "VEN.VEN_CODMAR=VEM.VEM_CODMAR AND "
	cQuery += "VEN.VEN_CENCUS=VEM.VEM_CENCUS AND "
	cQuery += "VEN.VEN_TIPVEN=VEM.VEM_TIPVEN AND "
	cQuery += "VEN.VEN_TIPNEG=VEM.VEM_TIPNEG AND "
	cQuery += "VEN.VEN_CODCLI=VEM.VEM_CODCLI AND VEN.VEN_LOJA=VEM.VEM_LOJA AND "
	cQuery += "VEN.VEN_FORPAG=VEM.VEM_FORPAG AND "
	cQuery += "VEN.VEN_DATINI<='"+dtos(dDataBase)+"' AND VEN.VEN_DATFIN>='"+dtos(dDataBase)+"'  AND VEN.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VEM.VEM_FILIAL='"+xFilial("VEM")+"' AND "
	cQuery += "( VEM.VEM_CODMAR='"+cMarca+"' OR VEM.VEM_CODMAR='"+space(TamSX3("VEM_CODMAR")[1])+"' ) AND "
	cQuery += "( VEM.VEM_CENCUS='"+cCenRes+"' OR VEM.VEM_CENCUS='"+space(TamSX3("VEM_CENCUS")[1])+"' ) AND "
	cQuery += "VEM.VEM_TIPVEN IN ('"+cTipVen+"','4',' ') AND "
	//
	Do Case
		Case nCntFor == 1 // Cliente/Loja exato
			//
			cQuery += "VEM.VEM_CODCLI='"+cCliente+"' AND VEM.VEM_LOJA='"+cLoja+"' AND "
			//
		Case nCntFor == 2 // Cliente sem Loja
			//
			cQuery += "VEM.VEM_CODCLI='"+cCliente+"' AND VEM.VEM_LOJA='"+space(TamSX3("VEM_LOJA")[1])+"' AND "
			//
		Case nCntFor == 3
			If Empty(cTipNeg) // Grupo de Cliente
				loop
			Else
				cQuery += "VEM.VEM_TIPNEG='"+cTipNeg+"' AND "
			EndIf
		Case nCntFor == 4 // Cliente/Loja em branco
			//
			cQuery += "VEM.VEM_CODCLI='"+space(TamSX3("VEM_CODCLI")[1])+"' AND VEM.VEM_LOJA='"+space(TamSX3("VEM_LOJA")[1])+"' AND "
			//
	EndCase
	//
	cQuery += "( VEM.VEM_FORPAG='"+cForPag+"' OR VEM.VEM_FORPAG='"+space(TamSX3("VEM_FORPAG")[1])+"' ) AND "
	cQuery += "VEM.D_E_L_E_T_=' '"
	//
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		//
		nRECVEM := (cSQLAlias)->( RECVEM )
		//
		Do Case
			Case (cSQLAlias)->VEN_GRUITE + (cSQLAlias)->VEN_CODITE == cGrupo + cCodite
				if nQtd >= (cSQLAlias)->VEN_QTDITE
					if nQtdTopo == 0 .or. nQtdTopo < (cSQLAlias)->VEN_QTDITE
						aMaxDesc[1]  := (cSQLAlias)->VEN_PERDES
						aMargMin[1]  := (cSQLAlias)->VEN_MARMIN
						aFormulas[1] := cFormAlu
						nPrecoFixo   := (cSQLAlias)->VEN_VALPRO
						nDescoFixo   := (cSQLAlias)->VEN_PERDES
						nQtdTopo     := (cSQLAlias)->VEN_QTDITE
						If lVENPERDCP .and. (cSQLAlias)->VEN_PERDCP == "0" // Nao Permitir Desconto quando Item esta em Promocao
							cPermDesc := "0" // 0=Não Permite Desconto em Promocao
						EndIf
					endif
				endif
			Case !Empty((cSQLAlias)->VEN_CODCAI)
				if SB5->B5_CODCAI == (cSQLAlias)->VEN_CODCAI
					aMaxDesc[2]  := (cSQLAlias)->VEN_PERDES
					aMargMin[2]  := (cSQLAlias)->VEN_MARMIN
					aFormulas[2] := cFormAlu
				endif
			Case !Empty((cSQLAlias)->VEN_GRUPEC)
				if cGrupo == (cSQLAlias)->VEN_GRUPEC
					aMaxDesc[3]  := (cSQLAlias)->VEN_PERDES
					aMargMin[3]  := (cSQLAlias)->VEN_MARMIN
					aFormulas[3] := cFormAlu
				endif
			Case !Empty((cSQLAlias)->VEN_GRUDES)
				if SB1->B1_GRUDES == (cSQLAlias)->VEN_GRUDES
					aMaxDesc[4]  := (cSQLAlias)->VEN_PERDES
					aMargMin[4]  := (cSQLAlias)->VEN_MARMIN
					aFormulas[4] := cFormAlu
				endif
			Case !Empty((cSQLAlias)->VEN_CLAFIN)
				if SBL->BL_ABCVEND+SBL->BL_ABCCUST == (cSQLAlias)->VEN_CLAFIN
					aMaxDesc[5]  := (cSQLAlias)->VEN_PERDES
					aMargMin[5]  := (cSQLAlias)->VEN_MARMIN
					aFormulas[5] := cFormAlu
				endif
			Case lMLF
				If !Empty((cSQLAlias)->VEN_MARPEC) .and. !Empty((cSQLAlias)->VEN_CODLIN) .and. !Empty((cSQLAlias)->VEN_CODFAM)
					if  cMarPec == (cSQLAlias)->VEN_MARPEC .and. cCodLin == (cSQLAlias)->VEN_CODLIN .and. cCodFam == (cSQLAlias)->VEN_CODFAM
						aMaxDesc[6]  := (cSQLAlias)->VEN_PERDES
						aMargMin[6]  := (cSQLAlias)->VEN_MARMIN
						aFormulas[6] := cFormAlu
						lContMlf := .f.
					endif
				else
					If lContMlf .and. !Empty((cSQLAlias)->VEN_MARPEC) .and. !Empty((cSQLAlias)->VEN_CODLIN)
						if  cMarPec == (cSQLAlias)->VEN_MARPEC .and. cCodLin == (cSQLAlias)->VEN_CODLIN
							aMaxDesc[6]  := (cSQLAlias)->VEN_PERDES
							aMargMin[6]  := (cSQLAlias)->VEN_MARMIN
							aFormulas[6] := cFormAlu
							lContMlf := .f.
						endif
					else
						If lContMlf .and. !Empty((cSQLAlias)->VEN_MARPEC)
							if  cMarPec == (cSQLAlias)->VEN_MARPEC
								aMaxDesc[6]  := (cSQLAlias)->VEN_PERDES
								aMargMin[6]  := (cSQLAlias)->VEN_MARMIN
								aFormulas[6] := cFormAlu
							endif
						endif
					endif
				endif
		EndCase
	    //
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	DBSelectArea("VEM")
	If nRECVEM > 0
		DbGoTo(nRECVEM)
		Exit // Sair do For
	Else
		If nCntFor == 4 // Somente vai retornar que nao deu certo caso passou pelos 4 SQLs 
			If nTipoRet == 1
				return .f.
			ElseIf nTipoRet == 2
				return {0, OXX005FML( cFormAlu ), 0 , "1" }
			Else
				return {0,0,0}
			EndIf
		EndIf
	EndIf
Next
//
// Verifica as precedencias
nDMax := 0
//
// PRIMEIRAMENTE VERIFICA-SE SE EXISTE PRECO FIXO PARA A PECA
//
if nPrecoFixo > 0 .or. nDescoFixo > 0
	lPrecoFixo := .t. // Preco Fixo - variavel Private utilizada no OFIXX001 >>> NAO RETIRAR <<<
	if nTipoRet == 1
		If nPrecoFixo > 0 // Com Preco Fixo
			if nValUni < nPrecoFixo
				If lHlp
					MsgInfo(STR0036 + Alltrim(cGrupo) + " - " + Alltrim(cCodIte) + STR0037,STR0027)
				EndIf
				return .f.
			else
				return .t.
			endif
		Else // Com % Descto Fixo
			if nPercent > 0
				If lHlp
					MsgInfo(STR0036 + Alltrim(cGrupo) + " - " + Alltrim(cCodIte) + STR0044,STR0027) //  "A Peça "  /  " possui % Fixo de Promoção"  / "Atenção"
				EndIf
				return .f.
			else
				return .t.
			endif
		EndIf
	elseif nTipoRet == 2
		aRet[1] := nPrecoFixo
		aRet[2] := OXX005FML( aFormulas[1] )
		aRet[3] := nDescoFixo //nValUni-(nValUni*(nDescoFixo/100)) // Quando há % de Desconto na Promoção
		aRet[4] := cPermDesc
		return aRet
	else
		aRet3[1] := nPrecoFixo
		aRet3[2] := 0
		aRet3[3] := 0
		return aRet3
	endif
endif
//
// A SEGUIR PRECISAMOS VERIFICAR SE EXISTE DESCONTO PROMOCIONAL PARA A PECA
//
if aMaxDesc[1] != -1
	if nTipoRet == 1
		if nPercent > aMaxDesc[1]
			If lHlp
				MsgInfo(STR0036 + Alltrim(cGrupo) + " - " + Alltrim(cCodIte) + STR0038,STR0038)
			EndIf
			return .f.
		else
			// Caso Fechamento de Oficina e parâmetro para não verificar margem de lucro
			if lFechOfi .And. !(lConMrgLuc)
				return .t.
			else
				if aMargMin[1] != 0 .and. aMargMin[1] > OXX005FML( aFormulas[1] )
					If lHlp
						MsgInfo(STR0036 + Alltrim(cGrupo) + " - " + Alltrim(cCodIte) + STR0039,STR0039)
					EndIf
					return .f.
				else
					return .t.
				endif
			endif
		endif
	elseif nTipoRet == 2
		aRet[2] := OXX005FML( aFormulas[1] )
		return aRet
	else
		aRet3[1] := 0
		aRet3[2] := aMaxDesc[1]
		aRet3[3] := aMargMin[1]
		return aRet3
	endif
endif
//
// SE NAO HA DESCONTO PARA A PECA, PROCURA-SE PELA PRIORIDADE
//
for nCntFor := 1 to Len(Alltrim(VEM->VEM_ORDPRI))
	if !Empty(Subs(Alltrim(VEM->VEM_ORDPRI),nCntFor,1))
		nCriterio := Val(Subs(Alltrim(VEM->VEM_ORDPRI),nCntFor,1))
		if aMaxDesc[nCriterio] != -1
			if nTipoRet == 1
				if nPercent > aMaxDesc[nCriterio]
					If lHlp
						MsgInfo(STR0036 + Alltrim(cGrupo) + " - " + Alltrim(cCodIte) + STR0038,STR0027)
					EndIf
					return .f.
				else
					// Caso Fechamento de Oficina e parâmetro para não verificar margem de lucro
					if lFechOfi .And. !(lConMrgLuc)
						return .t.
					else
						if aMargMin[nCriterio] != 0 .and. aMargMin[nCriterio] > OXX005FML( aFormulas[nCriterio] )
							If lHlp
								MsgInfo(STR0036 + Alltrim(cGrupo) + " - " + Alltrim(cCodIte) + STR0039,STR0027)
							EndIf
							return .f.
						else
							return .t.
						endif
					endif
				endif
			elseif nTipoRet == 2
				aRet[2] := OXX005FML( aFormulas[nCriterio] )
				return aRet
			else
				aRet3[1] := 0
				aRet3[2] := aMaxDesc[nCriterio]
				aRet3[3] := aMargMin[nCriterio]
				return aRet3
			endif
		endif
	endif
next
//
// SE NAO ACHOU NENHUMA PRIORIDADE PEGA O MAIOR DESCONTO OU A MAIOR MARGEM
//
if nTipoRet == 1
	nDMax := 0
	for nCntFor := 1 to 6
		if aMaxDesc[nCntFor] > nDMax
			nDMax := aMaxDesc[nCntFor]
		endif
	next
	//
	if nPercent > nDMax
		If lHlp
			MsgInfo(Alltrim(cGrupo) + " - " + Alltrim(cCodIte) + STR0038 ) // STR0040 )
		EndIf
		return .f.
	endif
	//
	// Caso Fechamento de Oficina e parâmetro para não verificar margem de lucro
	if lFechOfi .And. !(lConMrgLuc)
		return .t.
	else
		if GetNewPar("MV_MARMIN",0) > OXX005FML( cFormAlu )
			If lHlp
				MsgInfo(Alltrim(cGrupo) + " - " + Alltrim(cCodIte) + STR0039 ) // STR0041 )
			EndIf
			return .f.
		endif
	endif
elseif nTipoRet == 2
	// TODO: CALCULA MARGEM GERAL
	return {0, OXX005FML( cFormAlu ) , 0 , "1" }
else
	aRet3[1] := 0
	aRet3[2] := nDMax
	aRet3[3] := GetNewPar("MV_MARMIN",0)
	return aRet3
endif
//
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX005RETMIN| Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Retorna o Minimo                                             |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX005RETMIN(cMarca,cCenRes,cGrupo,cCodite,nQtd,nPercent,lHlp,cCliente,cLoja,cTipVen,nValUni,nTipoRet,cForPag,cFormAlu,lFechOfi)
Local aRetFunc := {}
Private lSBZ := ( SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ" )

//
Default cFormAlu := "MV_FORMALI" 
DBSelectArea("SB1")
DBSetOrder(7)
MsSeek(xFilial("SB1") + cGrupo + cCodite)
//
DBSelectArea("SB5")
DBSetOrder(1)
MsSeek(xFilial("SB5") + SB1->B1_COD )
If  lSBZ
	DBSelectArea("SBZ")
	DBSetOrder(1)
	MsSeek(xFilial("SBZ") + SB1->B1_COD )                                    
Endif
//
DBSelectArea("SB2")
DBSetOrder(1)
MsSeek( xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") )
//
aRetFunc := OX005PERDES(cMarca,cCenRes,cGrupo,cCodite,nQtd,nPercent,lHlp,cCliente,cLoja,cTipVen,0,3,cForPag,cFormAlu,lFechOfi)

//
if aRetFunc[1] != 0
	return aRetFunc[1]
endif
nPercMin := aRetFunc[3]
nValPerc = 	OXX005FML( GetNewPar(cFormAlu,"") ) // MV_FORMALI
nValDesc = (1- aRetFunc[2]/100) * nValUni
If nValPerc == 0 .and. M->VS1_PERDES > 0
	nValPerc := nValUni - (nValUni * (M->VS1_PERDES/100))
Endif
if nValPerc < nValDesc
	return nValPerc
endif
//
return nValDesc

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFX005DUP  | Autor | Andre Luis Almeida    | Data | 06/04/17 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Chamada para duplicar Cadastro de Forma de Desconto          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFX005DUP()
If MsgYesNo(STR0043,STR0027) // Deseja duplicar a Forma de Desconto? / Atencao!
	nOpc := 3
	OFIXX005("VEM",VEM->(RECNO()),nOpc,.t.)
EndIf
Return()

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | FS_NOPC    | Autor | Andre Luis Almeida    | Data | 06/04/17 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Atribui valor para nOpc e variaveis de controle              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_NOPC(xOpc)
//
nOpc := xOpc
//
VISUALIZA	:= nOpc==2
INCLUI 		:= nOpc==3
ALTERA 		:= nOpc==4
EXCLUI 		:= nOpc==5
//
Return

/*/{Protheus.doc} OXX005FML
Executa a Formula FG_FORMULA ou retorna 0 caso a Formula estiver em branco

@author Andre Luis Almeida
@since 30/05/2018

@type function
/*/
Static Function OXX005FML(cFml)
Local nRet := 0
Default cFml := ""
If !Empty(cFml)
	nRet := FG_FORMULA(cFml)
EndIf
Return nRet

/*/{Protheus.doc} OFX0050011_ReplicarCadastro
Replicar Dados entre os Criterios de Descontos

@author Andre Luis Almeida
@since 18/08/2020

@type function
/*/
Function OFX0050011_ReplicarCadastro()
Local nRecVEM   := VEM->(RecNo())
Local aCoord    := {}
Local cTitulo   := STR0045 // Replicar Cadastro
Local aTitles   := {STR0007,STR0008,STR0009,STR0010,STR0011} //###"1-Promocao"###"2-CAI"###"3-Grupo Peca"###"4-Grupo Desconto"###"5-Clas.Financ"###
Local lMLF      := SB5->(FieldPos("B5_MARPEC")) > 0 .and. SB5->(FieldPos("B5_CODLIN")) > 0 .and. SB5->(FieldPos("B5_CODFAM")) > 0// quando .T. trabalha com Marca / Linha / Familia
Local aVEMOut   := {}
Local lVEMOut   := .f.
Local nCntFor   := 0
Local nCntFor2  := 0
Local cQuery    := ""
Local cQueryAux := ""
Local cSQLAlias := "SQLAUX"
Local coObj     := ""
Local cFld      := ""
Local cAlinha   := ""
Local cConteudo := ""
Local lSemNome  := .f. // Verifica se existem registros SEM NOME
Local nLinha    := 0
Local aCombo    := {}
Local aCposVEN  := FWFormStruct(3,"VEN") // Todos os campos possiveis da Tabela VEN
Local aHeadVEN  := array(Iif(!lMLF,5,6)) // Campos por Folder
Private aDados  := array(Iif(!lMLF,5,6)) // Dados por Folder
Private aTik    := { .f. , .f. , .f. , .f. , .f. , .f. }
Private oOkTik  := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik  := LoadBitmap( GetResources() , "LBNO" )
//
If VEM->(ColumnPos("VEM_NOMCRI")) <= 0 // VERIFICA SE EXISTE O CAMPO QUE É NECESSARIO PARA REPLICA
	MsgStop(STR0056,STR0027) // Para executar esta funcionalidade, é necessário a criação do campo VEM_NOMCRI. Favor contactar o administrador do sistema. / Atenção
	Return
EndIf
//
If lMLF
	aTitles:= {STR0007,STR0008,STR0009,STR0010,STR0011,STR0012} //###"1-Promocao"###"2-CAI"###"3-Grupo Peca"###"4-Grupo Desconto"###"5-Clas.Financ"###6-Marca/Linha/Familia
EndIf
//
cQuery := "SELECT R_E_C_N_O_ AS RECVEM , VEM_FILIAL , VEM_NOMCRI"
cQuery += "  FROM "+RetSqlName("VEM")
cQuery += " WHERE R_E_C_N_O_ <> "+Alltrim(str(nRecVEM))
cQuery += "   AND D_E_L_E_T_=' '"
if ExistBlock("OX005QRP")
	cQueryAux := ExecBlock("OX005QRP",.f.,.f.)
	If !Empty(cQueryAux)
		cQuery += " AND ( "+cQueryAux+" )"
	EndIf
endif
cQuery += " ORDER BY VEM_FILIAL , VEM_NOMCRI"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
While !(cSQLAlias)->(Eof())
	If !Empty( (cSQLAlias)->( VEM_NOMCRI ) )
		aAdd(aVEMOut,{ .f. , (cSQLAlias)->( VEM_FILIAL ) , (cSQLAlias)->( VEM_NOMCRI ) , (cSQLAlias)->( RECVEM ) })
	Else
		lSemNome := .t. // Existem registros SEM NOME
	EndIf
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
DBSelectArea("VEM")
If len(aVEMOut) == 0
	MsgStop(STR0046,STR0027) // Necessário existir Critérios de Descontos cadastrados com Nome. / Atenção
	Return
Else
	If lSemNome // Existem registros de Criterios SEM NOME
		If !MsgYesNo(STR0047,STR0027) // Existem registros de Critérios SEM NOME, esses não poderão ser selecionados para réplica. Deseja Continuar? / Atenção
			Return
		EndIf
	EndIf
EndIf
//
OFX0050041_Levanta_Dados( aHeadVEN , aCposVEN )
//
aCoord := MsAdvSize(.t.)
DEFINE MSDIALOG oDlgReplicar TITLE cTitulo FROM aCoord[7],00 TO aCoord[6],aCoord[5] OF oMainWnd PIXEL

oFWLayer := FWLayer():New()
oFWLayer:Init(oDlgReplicar,.f.)

oFWLayer:AddLine("UP",42,.F.)
oFWLayer:AddCollumn("UPESQ",55,.F.,"UP")
oFWLayer:AddCollumn("UPDIR",45,.F.,"UP")
oFWLayer:AddWindow("UPESQ","oPanelTopEsq",STR0048,100,.F.,.F.,,"UP",{ || }) // Critério Base
oPanelTopEsq := oFWLayer:GetWinPanel("UPESQ","oPanelTopEsq","UP")
oFWLayer:AddWindow("UPDIR","oPanelTopDir",STR0049,100,.F.,.F.,,"UP",{ || }) // Critérios que receberão os Dados selecionados
oPanelTopDir := oFWLayer:GetWinPanel("UPDIR","oPanelTopDir","UP")

oFWLayer:AddLine("DOWN",52,.F.)
oFWLayer:AddCollumn("ALL",100,.F.,"DOWN")
oFWLayer:AddWindow("ALL","oPanelDown",STR0050,91,.F.,.F.,,"DOWN",{ || }) // Selecionar Dados a serem replicados
oPanelDown := oFWLayer:GetWinPanel("ALL","oPanelDown","DOWN")

VEM->(RegToMemory("VEM",.F.))
oMsMGet := MsMGet():New("VEM",	VEM->(RecNo()),2,,,,,{2,2,100,350},,3,,,,oPanelTopEsq,,,.t.)
oMsMGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

oLbVEMOut := TWBrowse():New(0,0,100,100,,,,oPanelTopDir,,,,,{ || OFX0050021_Tik( .t. , @aVEMOut , oLbVEMOut:nAt ) },,,,,,,.F.,,.T.,,.F.,,,)
oLbVEMOut:setArray( aVEMOut )
oLbVEMOut:addColumn( TCColumn():New( ""      , { || IIf(aVEMOut[oLbVEMOut:nAt,1],oOkTik,oNoTik) } ,,,,"LEFT", 08,.T.,.F.,,,,.F.,) ) // Tik
oLbVEMOut:addColumn( TCColumn():New( STR0051 , { || aVEMOut[oLbVEMOut:nAt,2] }                    ,,,,"LEFT",100,.F.,.F.,,,,.F.,) ) // Filial
oLbVEMOut:addColumn( TCColumn():New( STR0052 , { || aVEMOut[oLbVEMOut:nAt,3] }                    ,,,,"LEFT",150,.F.,.F.,,,,.F.,) ) // Nome
oLbVEMOut:bHeaderClick := {|oObj,nCol| ( lVEMOut := !lVEMOut , OFX0050021_Tik( lVEMOut , @aVEMOut , 0 ) , oLbVEMOut:Refresh() ) , }
oLbVEMOut:Align := CONTROL_ALIGN_ALLCLIENT

oFolder := TFolder():New(2,2,aTitles,{}, oPanelDown,,,,.t.,.f.,100,350)
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

For nCntFor := 1 to Iif(!lMLF,5,6)
	cFld  := strzero(nCntFor,1)
	coObj := "oLb"+cFld // Nome do Objeto
	&(coObj):= TWBrowse():New(0,0,100,100,,,,oFolder:aDialogs[nCntFor],,,,, &("{ || OFX0050021_Tik( .t. , @aDados["+cFld+"] , "+coObj+":nAt ) }") ,,,,,,,.F.,,.T.,,.F.,,,)
	&(coObj):addColumn( TCColumn():New( "" , &("{ || IIf(aDados["+cFld+","+coObj+":nAt,1],oOkTik,oNoTik) }") ,,,,"LEFT", 08,.T.,.F.,,,,.F.,) ) // Tik
	cNaoMostra := OFX0050031_NaoMostra(nCntFor)
	nCampo := 1 // 1 = Campo de Tik
	For nCntFor2 := 1 to len(aCposVEN[3]) // Colunas
		If !( aCposVEN[3,nCntFor2,1]+"," $ cNaoMostra )
			nCampo++
			cAlinha   := "LEFT"
			cConteudo := ""
			If len(aCposVEN[3,nCntFor2,13]) > 0 // Campo possui ComboBox
				aCombo := aclone(aCposVEN[3,nCntFor2,13])
				nLinha := ascan(aCombo,&("aDados["+cFld+","+coObj+":nAt,"+str(nCampo)+"]"))
				If nLinha > 0
					cConteudo := '"'+aCombo[nLinha]+'"'
				EndIf
			Else
				cConteudo := "Transform(aDados["+cFld+","+coObj+":nAt,"+str(nCampo)+"],'"+aCposVEN[3,nCntFor2,7]+"')"
			EndIf
			&(coObj):addColumn( TCColumn():New( aCposVEN[3,nCntFor2,3] , &("{ || "+cConteudo+" }") ) ,,,,cAlinha,50,.F.,.F.,,,,.F.,)
		EndIf
	Next
	&(coObj+":nAT") := 1
	&(coObj+":SetArray(aDados["+cFld+"])")
	&(coObj+":bHeaderClick") := &("{|oObj,nCol| ( aTik["+cFld+"] := !aTik["+cFld+"] , OFX0050021_Tik( aTik["+cFld+"] , @aDados["+cFld+"] , 0 ) , "+coObj+":Refresh() ) , }")
	&(coObj+":Align") := CONTROL_ALIGN_ALLCLIENT
Next

ACTIVATE MSDIALOG oDlgReplicar ON INIT EnchoiceBar(oDlgReplicar,{|| IIf(OFX0050051_Grava_Replica( aHeadVEN , aVEMOut ),oDlgReplicar:End(),.t.) },{|| oDlgReplicar:End() },,)

DbSelectArea("VEM")
DbGoto(nRecVEM)

Return

/*/{Protheus.doc} OFX0050021_Tik
Funcao para Tikar os registros da tela de Replica

@author Andre Luis Almeida
@since 18/08/2020

@type function
/*/
Static Function OFX0050021_Tik(lTik,aVet,nLinha)
Local nCntFor := 0
If nLinha == 0 // Todas linhas do ListBox
	For nCntFor := 1 to len(aVet)
		If aVet[nCntFor,len(aVet[nCntFor])] > 0
			aVet[nCntFor,1] := lTik
		EndIf
	Next
Else // Tik Individual ( linha a linha )
	If aVet[nLinha,len(aVet[nLinha])] > 0
		aVet[nLinha,1] := !aVet[nLinha,1]
	EndIf
EndIf
Return

/*/{Protheus.doc} OFX0050031_NaoMostra
Retorna os campos que NAO serão mostrados por ABA

@author Andre Luis Almeida
@since 18/08/2020

@type function
/*/
Static Function OFX0050031_NaoMostra(nFld)
Local cNaoMostra := ""
Do Case
	Case nFld == 1 // Promocao
		cNaoMostra := "VEN_FILIAL,VEN_CENCUS,VEN_CODMAR,VEN_CODCAI,VEN_GRUPEC,VEN_GRUDES,VEN_CLAFIN,VEN_MODVEI,VEN_ITEPER,VEN_PERQTD,VEN_GRUKIT,VEN_CODKIT,VEN_ITEDES,VEN_CONTAD,VEN_CODCLI,VEN_LOJA,VEN_TIPVEN,VEN_FORMUL,VEN_TIPNEG,VEN_FORPAG,VEN_MARPEC,VEN_CODLIN,VEN_CODFAM,"
	Case nFld == 2 // CAI
		cNaoMostra := "VEN_FILIAL,VEN_CENCUS,VEN_VALPRO,VEN_CODMAR,VEN_GRUPEC,VEN_GRUDES,VEN_CLAFIN,VEN_GRUITE,VEN_CODITE,VEN_MODVEI,VEN_QTDITE,VEN_PERQTD,VEN_ITEDES,VEN_ITEPER,VEN_PROMOCAO,VEN_GRUKIT,VEN_CODKIT,VEN_CONTAD,VEN_CODCLI,VEN_LOJA,VEN_TIPVEN,VEN_FORMUL,VEN_TIPNEG,VEN_FORPAG,VEN_PRODIA,VEN_MARPEC,VEN_CODLIN,VEN_CODFAM,VEN_PERDCP,"
	Case nFld == 3 // Grupo de Peca
		cNaoMostra := "VEN_FILIAL,VEN_CENCUS,VEN_VALPRO,VEN_CODMAR,VEN_CODCAI,VEN_GRUDES,VEN_CLAFIN,VEN_GRUITE,VEN_CODITE,VEN_MODVEI,VEN_QTDITE,VEN_PERQTD,VEN_ITEDES,VEN_ITEPER,VEN_PROMOCAO,VEN_GRUKIT,VEN_CODKIT,VEN_CONTAD,VEN_CODCLI,VEN_LOJA,VEN_TIPVEN,VEN_FORMUL,VEN_TIPNEG,VEN_FORPAG,VEN_PRODIA,VEN_MARPEC,VEN_CODLIN,VEN_CODFAM,VEN_PERDCP,"
	Case nFld == 4 // Grupo de Desconto
		cNaoMostra := "VEN_FILIAL,VEN_CENCUS,VEN_VALPRO,VEN_CODMAR,VEN_CODCAI,VEN_GRUPEC,VEN_CLAFIN,VEN_GRUITE,VEN_CODITE,VEN_MODVEI,VEN_QTDITE,VEN_PERQTD,VEN_ITEDES,VEN_ITEPER,VEN_PROMOCAO,VEN_GRUKIT,VEN_CODKIT,VEN_CONTAD,VEN_CODCLI,VEN_LOJA,VEN_TIPVEN,VEN_FORMUL,VEN_TIPNEG,VEN_FORPAG,VEN_PRODIA,VEN_MARPEC,VEN_CODLIN,VEN_CODFAM,VEN_PERDCP,"
	Case nFld == 5 // Classificacao Financeira
		cNaoMostra := "VEN_FILIAL,VEN_CENCUS,VEN_VALPRO,VEN_CODMAR,VEN_CODCAI,VEN_GRUPEC,VEN_GRUDES,VEN_GRUITE,VEN_CODITE,VEN_MODVEI,VEN_QTDITE,VEN_PERQTD,VEN_ITEDES,VEN_ITEPER,VEN_PROMOCAO,VEN_GRUKIT,VEN_CODKIT,VEN_CONTAD,VEN_CODCLI,VEN_LOJA,VEN_TIPVEN,VEN_FORMUL,VEN_TIPNEG,VEN_FORPAG,VEN_PRODIA,VEN_MARPEC,VEN_CODLIN,VEN_CODFAM,VEN_PERDCP,"
	Case nFld == 6 // Marca Linha Familia
		cNaoMostra := "VEN_FILIAL,VEN_CENCUS,VEN_VALPRO,VEN_CODMAR,VEN_CODCAI,VEN_GRUPEC,VEN_CLAFIN,VEN_GRUDES,VEN_GRUITE,VEN_CODITE,VEN_MODVEI,VEN_QTDITE,VEN_PERQTD,VEN_ITEDES,VEN_ITEPER,VEN_PROMOCAO,VEN_GRUKIT,VEN_CODKIT,VEN_CONTAD,VEN_CODCLI,VEN_LOJA,VEN_TIPVEN,VEN_FORMUL,VEN_TIPNEG,VEN_FORPAG,VEN_PRODIA,VEN_PERDCP,"
EndCase
Return cNaoMostra

/*/{Protheus.doc} OFX0050041_Levanta_Dados
Levanta dos Dados do VEN relacionados ao VEM posicionado

@author Andre Luis Almeida
@since 19/08/2020

@type function
/*/
Static Function OFX0050041_Levanta_Dados( aHeadVEN , aCposVEN )
Local cQuery     := ""
Local cSQLAlias  := "SQLAUX"
Local nCntFor    := 0
Local nFld       := 0
Local nLin       := 0
Local cConteudo  := ""
Local cNaoMostra := ""
//
For nFld := 1 to len(aHeadVEN)
	aDados[nFld] := {}
	aHeadVEN[nFld] := {}
	cNaoMostra := OFX0050031_NaoMostra(nFld)
	aAdd(aHeadVEN[nFld],"TIK")
	For nCntFor := 1 to len(aCposVEN[3]) // Colunas
		If !( aCposVEN[3,nCntFor,1]+"," $ cNaoMostra )
			aAdd(aHeadVEN[nFld],aCposVEN[3,nCntFor,1])
		EndIf
	Next
	aAdd(aHeadVEN[nFld],"RECNO")
Next
//
cQuery := "SELECT R_E_C_N_O_ AS RECVEN , * "
cQuery += "  FROM "+RetSqlName("VEN")
cQuery += " WHERE VEN_FILIAL='"+VEM->VEM_FILIAL+"'"
cQuery += "   AND VEN_CODMAR='"+VEM->VEM_CODMAR+"'"
cQuery += "   AND VEN_CENCUS='"+VEM->VEM_CENCUS+"'"
cQuery += "   AND VEN_TIPVEN='"+VEM->VEM_TIPVEN+"'"
cQuery += "   AND VEN_TIPNEG='"+VEM->VEM_TIPNEG+"'"
cQuery += "   AND VEN_CODCLI='"+VEM->VEM_CODCLI+"'"
cQuery += "   AND VEN_LOJA='"  +VEM->VEM_LOJA  +"'"
cQuery += "   AND VEN_FORPAG='"+VEM->VEM_FORPAG+"'"
cQuery += "   AND VEN_DATFIN>='"+dtos(dDatabase)+"'" // Somente dentro do periodo (validos)
cQuery += "   AND D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
While !(cSQLAlias)->(Eof())
	nFld := 0
	Do Case
		Case !Empty((cSQLAlias)->( VEN_GRUITE )) .and. !Empty((cSQLAlias)->( VEN_CODITE ))
			nFld := 1 // Promocao
		Case !Empty((cSQLAlias)->( VEN_CODCAI ))
			nFld := 2 // CAI
		Case !Empty((cSQLAlias)->( VEN_GRUPEC ))
			nFld := 3 // Grupo de Peca
		Case !Empty((cSQLAlias)->( VEN_GRUDES ))
			nFld := 4 // Grupo de Desconto
		Case !Empty((cSQLAlias)->( VEN_CLAFIN ))
			nFld := 5 // Classificacao Financeira
		Case !Empty((cSQLAlias)->( VEN_MARPEC )) .or. !Empty((cSQLAlias)->( VEN_CODLIN )) .or. !Empty((cSQLAlias)->(VEN_CODFAM ))
			nFld := 6 // Marca Linha Familia
	EndCase
	If nFld > 0
		aAdd(aDados[nFld],array(len(aHeadVEN[nFld])))
		nLin := len(aDados[nFld])
		aDados[nFld,nLin,1] := .f.
		For nCntFor := 2 to (len(aHeadVEN[nFld])-1)
			If GeTSX3Cache(aHeadVEN[nFld,nCntFor],"X3_TIPO") == "D"
				cConteudo := stod( (cSQLAlias)->( &(aHeadVEN[nFld,nCntFor]) ) )
			Else
				cConteudo := (cSQLAlias)->( &(aHeadVEN[nFld,nCntFor]) )
			EndIf
			aDados[nFld,nLin,nCntFor] := cConteudo
		Next
		aDados[nFld,nLin,len(aHeadVEN[nFld])] := (cSQLAlias)->( RECVEN )
	EndIf
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
DBSelectArea("VEM")
// Inserir Vetores em Branco caso nao exista registros na ABA correspondente //
For nFld := 1 to len(aHeadVEN)
	If len(aDados[nFld]) == 0
		aAdd(aDados[nFld],array(len(aHeadVEN[nFld])))
		nLin := len(aDados[nFld])
		aDados[nFld,nLin,1] := .f.
		aDados[nFld,nLin,len(aHeadVEN[nFld])] := 0
	EndIf
Next
//
Return()

/*/{Protheus.doc} OFX0050051_Grava_Replica
Grava os Dados replicados do VEN

@author Andre Luis Almeida
@since 19/08/2020

@type function
/*/
Static Function OFX0050051_Grava_Replica( aHeadVEN , aVEMOut )
Local nRecVEM := VEM->(RecNo())
Local lOk     := .f.
Local lRet    := .t.
Local lIncAlt := .t.
Local nCntFor := 0
Local nLin    := 0
Local nCpo    := 0
Local nFld    := 0
For nCntFor := 1 to len(aVEMOut)
	If aVEMOut[nCntFor,1]
		lOk := .t.
		Exit
	EndIf
Next
If !lOk
	MsgStop(STR0053,STR0027) // Necessário selecionar Critérios que receberão os Dados. / Atenção
	lRet := .f.
Else
	lOk := .f.
	For nFld := 1 to len(aHeadVEN)
		For nCntFor := 1 to len(aDados[nFld])
			If aDados[nFld,nCntFor,1]
				lOk := .t.
				Exit
			EndIf
		Next
		If lOk
			Exit
		EndIf
	Next
	If !lOk
		MsgStop(STR0054,STR0027) // Necessário selecionar os Dados a serem replicados. / Atenção
		lRet := .f.
	EndIf
EndIf
//
If lRet
	//
	For nCntFor := 1 to len(aVEMOut) // Percorrer os Criterios selecionados
		//
		If aVEMOut[nCntFor,1] // Tikado
			//
			DbSelectArea("VEM")
			DbGoTo( aVEMOut[nCntFor,len(aVEMOut[nCntFor])] ) // RecNo do VEM
			//
			For nFld := 1 to len(aHeadVEN) // Percorrer as ABAs (Promocao, CAI, Grupo/Cod.Item, ...)
				//
				For nLin := 1 to len(aDados[nFld]) // Percorrer os Dados dentro da ABA correspondente
					//
					If aDados[nFld,nLin,1] // Tikado
						//
						lIncAlt := .t. // Incluir VEN
						nRecVEN := OFX0050061_Verifica_Existencia_VEN( aHeadVEN , nFld , nLin ) // Verifica se Inclui ou Altera registro do VEN
						If nRecVEN > 0
							DbSelectArea("VEN")
							DbGoTo(nRecVEN)
							lIncAlt := .f. // Alterar VEN
						EndIf
						//
						DbSelectArea("VEN")
						RecLock("VEN",lIncAlt)
							If lIncAlt // Inclusao
								VEN->VEN_FILIAL := VEM->VEM_FILIAL
								VEN->VEN_CODMAR := VEM->VEM_CODMAR
								VEN->VEN_CENCUS := VEM->VEM_CENCUS
								VEN->VEN_TIPVEN := VEM->VEM_TIPVEN
								VEN->VEN_TIPNEG := VEM->VEM_TIPNEG
								VEN->VEN_CODCLI := VEM->VEM_CODCLI
								VEN->VEN_LOJA   := VEM->VEM_LOJA
								VEN->VEN_FORPAG := VEM->VEM_FORPAG
							EndIf
							For nCpo := 2 to (len(aHeadVEN[nFld])-1) // Percorrer CAMPOS da ABA
								&("VEN->"+aHeadVEN[nFld,nCpo]) := aDados[nFld,nLin,nCpo]
							Next
						MsUnLock()
						//
					EndIf
					//
				Next
				//
			Next
			//
		EndIf
		//
	Next
	//
	MsgInfo(STR0055,STR0027) // Dados replicados com sucesso! / Atenção
	//
	DbSelectArea("VEM")
	DbGoto(nRecVEM)
	//
EndIf
//
Return lRet

/*/{Protheus.doc} OFX0050061_Verifica_Existencia_VEN
Verifica a existencia do VEN para poder Incluir ou Alterar o registro

@author Andre Luis Almeida
@since 19/08/2020

@type function
/*/
Static Function OFX0050061_Verifica_Existencia_VEN( aHeadVEN , nFld , nLin )
Local cQuery := ""
cQuery := "SELECT R_E_C_N_O_ AS RECVEN "
cQuery += "  FROM "+RetSqlName("VEN")
cQuery += " WHERE VEN_FILIAL='"+VEM->VEM_FILIAL+"'"
cQuery += "   AND VEN_CODMAR='"+VEM->VEM_CODMAR+"'"
cQuery += "   AND VEN_CENCUS='"+VEM->VEM_CENCUS+"'"
cQuery += "   AND VEN_TIPVEN='"+VEM->VEM_TIPVEN+"'"
cQuery += "   AND VEN_TIPNEG='"+VEM->VEM_TIPNEG+"'"
cQuery += "   AND VEN_CODCLI='"+VEM->VEM_CODCLI+"'"
cQuery += "   AND VEN_LOJA='"  +VEM->VEM_LOJA  +"'"
cQuery += "   AND VEN_FORPAG='"+VEM->VEM_FORPAG+"'"
Do Case 
	Case nFld == 1 // Promocao
		cQuery += " AND VEN_GRUITE='"+aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_GRUITE")]+"'"
		cQuery += " AND VEN_CODITE='"+aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_CODITE")]+"'"
		cQuery += " AND VEN_QTDITE="+Alltrim(str(aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_QTDITE")]))
	Case nFld == 2 // CAI
		cQuery += " AND VEN_CODCAI='"+aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_CODCAI")]+"'"
	Case nFld == 3 // Grupo de Peca
		cQuery += " AND VEN_GRUPEC='"+aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_GRUPEC")]+"'"
	Case nFld == 4 // Grupo de Desconto
		cQuery += " AND VEN_GRUDES='"+aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_GRUDES")]+"'"
	Case nFld == 5 // Classificacao Financeira
		cQuery += " AND VEN_CLAFIN='"+aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_CLAFIN")]+"'"
	Case nFld == 6 // Marca Linha Familia
		cQuery += " AND VEN_MARPEC='"+aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_MARPEC")]+"'"
		cQuery += " AND VEN_CODLIN='"+aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_CODLIN")]+"'"
		cQuery += " AND VEN_CODFAM='"+aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_CODFAM")]+"'"
EndCase
cQuery += " AND "
cQuery += "   ( "
cQuery += "     ( VEN_DATINI<='"+dtos(aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_DATINI")])+"' AND "
cQuery += "       VEN_DATFIN>='"+dtos(aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_DATINI")])+"' )"
cQuery += "     OR "
cQuery += "     ( VEN_DATINI>='"+dtos(aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_DATFIN")])+"' AND "
cQuery += "       VEN_DATFIN<='"+dtos(aDados[nFld,nLin,ascan(aHeadVEN[nFld],"VEN_DATFIN")])+"' )"
cQuery += "   ) "
cQuery += " AND D_E_L_E_T_=' '"
Return FM_SQL(cQuery)