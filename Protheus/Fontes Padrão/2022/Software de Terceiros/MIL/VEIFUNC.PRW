// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 217    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "PROTHEUS.CH"
#include "VEIFUNC.CH"
#include "OFIXDEF.CH"

Static lInconveniente := (GetNewPar("MV_INCORC","N") == "S")
Static oCabecNF

Static VALID_KIL
Static VALID_HOR

Static ULTKIL_VO1
Static ULTKIL_VV1

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  13/11/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007116_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_STRZERO³ Autor ³  Mil                  ³ Data ³ 22/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Coloca Zeros a Esquerda                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1-Variavel 2-Quantidade de Zeros 3-Valida Zero              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_STRZERO(w_1Par,w_2Par,w_3Par)
Local wReturn := .T.
Local w_Trab := &w_1Par
Local lCont := .f.
Local nX

Default w_3Par := .F.

If w_3Par
	If Val(w_Trab) <= 0
		wReturn := .F.
		Help(" ",1,"VALZERADO")
	Else
		wReturn := .T.
		&w_1Par:= Strzero(Val(w_Trab),w_2Par)
	EndIf
Else
	For nX := 1 to Len(Trim(w_Trab))
		If ! Subs(Trim(w_Trab),nX,1) $ "0123456789"
			lCont := .t.
			Exit
		EndIf
	Next
	If lCont
		&w_1Par:= w_Trab
	Else
		&w_1Par:= Strzero(Val(w_Trab),w_2Par)
	EndIf
	wReturn := .T.
EndIf

Return(wReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_TRIGVP7³ Autor ³  Andre                ³ Data ³ 22/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Trigger do Arquivo VP7                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos (VIP)                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_TRIGVP7(Arg)
Local wReturn
Local wDatAnt := POSICIONE("VP6",1,xFilial("VP7")+M->VP7_CODBEM,"VP6_DATATU")

If M->VP7_DATATU >= wDatAnt
	If Arg == 1
		wReturn := M->VP7_DATATU
	Else
		wReturn := M->VP7_VALBEM
	EndIf
Else
	If Arg == 1
		wReturn := VP6->VP6_DATATU
	Else
		wReturn := VP6->VP6_VALBEM
	EndIf
EndIf

Return(wReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FG_PF    ³ Autor ³  Mil                  ³ Data ³ 22/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Altera para a picture padrao da fabrica                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Arg1 = Nome do Campo                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PF(arg1)
wFab := [M->]+arg1
wReturn := POSICIONE("SBM",1,xFilial("SBM")+&wFab,"BM_PICPAD")
wCodIte := ReadVar()

If Valtype(&wCodIte) == "N"
	&wCodIte := str(&wCodIte)
EndIf

Return(Trim(wReturn)+'%C')

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FG_Seek  ³ Autor ³Alvaro/Andre           ³ Data ³ 05/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Posiciona Reg e permanece nele. Atribui Valor a outro Campo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ (Alias,Chave,Ordem,.t./.f.-p/softseek on/off,CpoDes,CpoOri)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Sintaxe: FG_Seek( <ExpC1>, <ExpC2>, [ExpN], [ExpL], <ExpC3>, <ExpC4> )
Funcao.: Executa pesquisa em tabelas
ExpC1 = arquivo alvo
ExpC2 = chave de pesquisa
ExpN  = numero do indice associado a ExpC1  (Opcional)
Se nao informado assume 1
ExpL  = se .t. softseek ON                  (Opcional)
Se nao informado assume .f.
ExpC3 = Campo Destino (que recebera conteudo)
ExpC4 = Campo Origem do conteudo
Retorna: .t. se o reg. existir, deixando posicionado no mesmo
.f. se o reg. nao existir, deixando posic. no final do Arquivo
*/
Function FG_Seek(cAlias,Chv_,Ord_,Sss_,cCpoDest,cCpoOrig,lVazio)
LOCAL Atu_:=SELECT(), Ind_, Sem_dbf:=ALIAS(), Achou_
LOCAL i := 0
Local nPosDest := 0
Local laCols := .f.

Default lVazio := .f.

Ord_:=IIf(Ord_=NIL,1,Ord_)
Sss_:=IIf(Sss_=NIL,.f.,Sss_)
cCom:=IIf(cCpoOrig=NIL," ",cAlias+"->"+cCpoOrig)

Select(cAlias)
Ind_:=IndexOrd()
DbSetOrder(Ord_)
If Sss_
	Set SoftSeek (Sss_)
Endif

laCols := (Type("aCols") == "A" .and. Type("aHeader") == "A")

If laCols .and. (Len(aCols) > 0 .and. Len(aHeader) == Len(aCols[1]) )// Modelo 3

	cChave := ""

	If type(readvar()) == "U"
		cUlCpo := ""
	Else
		cUlCpo := &(readvar())
	EndIf

	k := at("M->",chv_)
	If k > 0 .and. ( Subs(chv_,k-1,1) == "+" .or. (k-1 == 0) .or. !SX2->(dbSeek(Subs(chv_,k-2,3))) )
		bCampo := {|x| aHeader[x,2]}
		w1 := READVAR()
		For i=1 to Len(aHeader)
			wVar := "M->"+(EVAL(bCampo,i))
			If wVar != w1
				Private &wVar := aCols[n,i]
			EndIf
		Next
	EndIf

	While .t.
		k := at("+",chv_)
		If k > 0
			cCPO := substr(chv_,1,k-1)
			chv_ := substr(chv_,k+1)
			If at("->",cCpo) == 0 .and. type(cCpo) == "U"
				cChave := cChave + FieldGet(FieldPos(cCPO))
			else
				cChave := cChave + &cCpo
			endIf
		Else
			If !Chv_ == readvar()
				cUlCpo := &Chv_
			endIf
			Exit
		EndIf
	Enddo

	cChv_ := cChave+cUlCpo

Else

	cChv_ := (&Chv_)

EndIf

If Empty(cChv_) .and. lVazio
	Achou_ := .t.
Else
	Achou_ := DbSeek(xFilial(cAlias)+cChv_)
EndIf

DbSetOrder(ind_)
If ! Empty(sem_dbf)
	Sele (Atu_)
ENDIF

If Sss_
	Set SoftSeek (.f.)
EndIf

If cCom != " " .and. Achou_
	If Empty(cChv_) .and. lVazio
		cTipo := GetSX3Cache(cCpoDest, "X3_TIPO")
		If cTipo == "N"
			xValorCPODest := 0
		Else
			xValorCPODest := " "
		EndIf
	Else
		xValorCPODest := &cCom
	EndIf

	M->&cCpoDest := xValorCPODest
	If laCols
		nPosDest := FG_POSVAR(cCpoDest,"aHeader")
		If nPosDest > 0 .and. n <> NIL .and. n > 0 .and. n <= len(aCols)
			aCols[n,nPosDest] := xValorCPODest
		EndIf
	EndIf
endIf

Return Achou_

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FG_CusVei ³ Autor ³ Manoel                ³ Data ³ 28/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calculo do Custo Atual Indexado de Veiculos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FG_CusVei(cIndCnv,cChaInt,cDatCpa,cDatAtu) Cod do Indice de³±±
±±³          ³ Conversao, Chassi Interno Veiculo, Dt da Compra e Dt Atual ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_CusVei(cTraCpa,cChaInt,cDatCpa,cDatAtu,nValCus)

Default nValCus := 0

VV1->(DbSetOrder(1))
VV1->(DbSeek(xFilial("VV1")+cChaInt))
FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
VE4->(DbSeek(xFilial("VE4")+VV1->VV1_CODMAR))
FG_Seek("VVH","VVG->VVG_CODIND",1,.f.)

If nValCus == 0
	nValCus := VVG->VVG_VCNVEI
Endif

cChave1 := VVG->VVG_CODIND+dtos(cDatCpa)
cDatAtu1:= cDatAtu

If cDatAtu - cDatCpa > VVH->VVH_DIACAR
	cChave1 := VVG->VVG_CODIND+dtos(cDatCpa+VVH->VVH_DIACAR)
	If !FG_Seek("VVI","cChave1",1,.t.)
		nInd :=1
	Else
		nInd := VVI->VVI_INDICE
	EndIf
	nQtdInd := (nValCus / nInd)
	wDtt := dtos(cDatAtu1+VVH->VVH_DIAPGF-VVH->VVH_DIARET)
	If !FG_Seek("VVI","VVG->VVG_CODIND+wDtt",1,.t.)
		nInd := 1
	Else
		nInd := VVI->VVI_INDICE
	EndIf
	nValCus := (nQtdInd * nInd)
EndIf

Return(nValCus)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_DesVei ³ Autor ³ Manoel                ³ Data ³ 26/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calculo das Despesas efetuadas em Veiculos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FG_DesVei(cTraCpa,cChaInt,cTipOpe) Ultima Trans de Compra, ³±±
±±³          ³                            Chassi Interno do Veiculo       ³±±
±±³          ³                            Tipo Operacao(Receita/Despesa)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_DesVei(cTraCpa,cChaInt,cTipOpe,lDadosUltCpa)
Local lVVD_FILENT := VVD->(FieldPos("VVD_FILENT")) <> 0
Local lVVD_FILUCP := VVD->(FieldPos("VVD_FILUCP")) <> 0
Local cSQL        := ""
Local cQAlias     := "cAliasSQL"
Local cQAlAux     := "SQLAUXILIAR"
Local aMovAux     := {}
Local cFilUCp     := "" // Filial da Ultima Entrada por Compra
Local cTraUCp     := "" // Tracpa da Ultima Entrada por Compra
Local cFilVVD     := ""
Local cChassi     := ""
Local nDRVei      := 0
Default lDadosUltCpa := .f.

If Type("aIteDesp") == "U"
	aIteDesp := {}
EndIf
If Type("aIteRece") == "U"
	aIteRece := {}
EndIf

If lDadosUltCpa .and. lVVD_FILUCP
	cFilUCp := cVarFilEnt
	cTraUCp := cTraCpa
	cChassi := FM_SQL("SELECT VV1_CHASSI FROM "+RetSQLName("VV1")+" WHERE VV1_FILIAL='"+xFilial("VV1")+"' AND VV1_CHAINT='"+cChaInt+"' AND D_E_L_E_T_ = ' '")
	aMovAux := FGX_VEIMOVS( cChassi , "E" , "0" ) // Retorna a ultima Entrada por Compra do Veiculo
	If len(aMovAux) > 0
		cFilUCp := aMovAux[1,2] // Filial da Ultima Entrada por Compra
		cTraUCp := aMovAux[1,3] // Tracpa da Ultima Entrada por Compra
	EndIf
	//
	cSQL := "SELECT DISTINCT VVD_FILIAL FROM "+RetSqlName("VVD")+" WHERE D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cQAlAux , .F., .T. )
	While !( cQAlAux )->( Eof() )
		cFilVVD += "'"+( cQAlAux )->( VVD_FILIAL )+"',"
		( cQAlAux )->( dbSkip() )
	EndDo
	( cQAlAux )->( dbCloseArea() )
	If !Empty(cFilVVD)
		cFilVVD := left(cFilVVD,len(cFilVVD)-1)
	Else
		cFilVVD := "'"+xFilial("VVD")+"'"
	EndIf
	//
EndIf

cSQL := "SELECT VVD.VVD_DATADR , VVD.VVD_CODIGO , VVD.VVD_DESCRI , VVD.VVD_VALOR "
cSQL += "  FROM " + RetSQLName("VVD") + " VVD "
If lDadosUltCpa .and. lVVD_FILUCP
	cSQL += " WHERE VVD.VVD_FILIAL IN (" + cFilVVD + ")"
	cSQL += "   AND VVD.VVD_FILUCP  = '" + cFilUCp + "'"
	cSQL += "   AND VVD.VVD_TRAUCP  = '" + cTraUCp + "'"
Else
	If !lVVD_FILENT
		cSQL += " WHERE VVD.VVD_FILIAL = '" + cVarFilEnt + "'" // antes do VVD_FILENT
	Else
		cSQL += " WHERE ( ( VVD.VVD_FILIAL = '" + xFilial("VVD") + "' AND VVD.VVD_FILENT = '" + cVarFilEnt + "' ) " // novos registros
		cSQL += "       OR (VVD.VVD_FILIAL = '" + cVarFilEnt + "' AND VVD.VVD_FILENT = ' ' ) ) " // registro antigos
	Endif
	cSQL += "   AND VVD.VVD_TRACPA = '" + cTraCpa + "'"
EndIf
cSQL += "   AND VVD.VVD_CHAINT = '" + cChaInt + "'"
If cTipOpe == "D" // Despesas
	cSQL += "   AND VVD.VVD_TIPOPE = '0' "
Else // Receitas
	cSQL += "   AND VVD.VVD_TIPOPE = '1' "
EndIf
cSQL += "   AND VVD.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cQAlias, .T., .T. )
While !( cQAlias )->( Eof() )
	If cTipOpe == "D" // Despesas
		aAdd(aIteDesp,{( cQAlias )->VVD_DATADR,( cQAlias )->VVD_CODIGO,( cQAlias )->VVD_DESCRI,( cQAlias )->VVD_VALOR})
	Else // Receitas
		aAdd(aIteRece,{( cQAlias )->VVD_DATADR,( cQAlias )->VVD_CODIGO,( cQAlias )->VVD_DESCRI,( cQAlias )->VVD_VALOR})
	EndIf
	nDRVei += ( cQAlias )->VVD_VALOR
	( cQAlias )->( DbSkip() )
Enddo
( cQAlias )->( DbCloseArea() )
//
DbSelectArea("VVD")
//
Return(nDRVei)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_JurEst ³ Autor ³ Manoel / Andre        ³ Data ³ 27/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calculo do Juro de Estoque do Veiculo                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FG_JurEst(cTraCpa,cChaInt,dDatInd,dDatFin,cPecVei)         ³±±
±±³          ³ Ultima Transacao de Compra, Chassi Interno do Veiculo,     ³±±
±±³          ³ Flag de Pecas/Veiculos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_JurEst(cTraCpa,cChaInt,dDatIni,dDatFin,cPecVei)
Local cNMF := Alltrim(GetMv("MV_INDMFT"))
Local e := 0
cSavAlias := alias()

If Empty(dDatIni)
	dDatIni := dDataBase
	If dDatIni > dDatFin
		dDatIni := dDatFin
	EndIf
EndIf
If Empty(dDatFin)
	dDatFin := dDataBase
	If dDatFin < dDatIni
		dDatFin := dDatIni
	EndIf
EndIf

If !Empty(cChaInt)
	VV1->(DbSetOrder(1))
	VV1->(DbSeek(xFilial("VV1")+cChaInt))
EndIf

cIndJEst := GetMv("MV_INDJEST")
wDtEt    := dDatIni
wJurVei  := 0
wJurEst  := 0

If cPecVei == "P"
	cTipFat := "0" // Apenas para passar no If
	wCustoV  := SB2->B2_CM1/SB2->B2_QATU
	cSitVei := "0"
else
	wCustoV  := VVG->VVG_VCNVEI
	cSitVei := VV1->VV1_SITVEI
endIf

If VV1->VV1_ESTVEI $ "01"  //Veiculos Novos ou Usados / Qualquer peca no estoque

	if cSitVei != "1" // Veiculo Vendido / peca no estoque

		wDatFin := dDatFin

		if ( (wDatFin-1) - (wDtEt) ) >= 0

			wfor  := ( (WDatFin-1) - (wdtet) )

			For e := 0 to wfor

				wDatDia := dTos(wDtEt+e)

				Set SoftSeek on
				VVI->(DbSeek(xFilial("VVI")+cIndJEst+wDatDia,.t.))
				Set SoftSeek off
				If VVI->VVI_INDICE == 0
					VVI->(dbSkip(-1))
				Else
					If VVI->VVI_DATIND > Stod(wDatDia)
						VVI->(dbSkip(-1))
						If VVI->VVI_CODIND != cIndJEst
							VVI->(dbSkip())
						Endif
					Endif
				Endif
				//         TxCdi   := ( VVI->VVI_INDICE / day(LastDay(wDtEt+e)) ) - Manoel - 19.Nov.2003 (Mes Comercial = 30)
				TxCdi   := ( VVI->VVI_INDICE / 30)

				DbSelectArea("SM2")
				Set SoftSeek on
				//	        DbSeek(wDatDia)   //Valdir Antes
				DbSeek(sToD(wDatDia ))   //Valdir
				if &("SM2->M2_MOEDA"+cNMF) == 0
					dbskip(-1)
				Endif

				TxMf := &("SM2->M2_MOEDA"+cNMF) / 100
				Tx1  := (TxMf + 1)^(1/21)
				Tx2  := (((1 + TxCdi) / Tx1) - 1)
				WJurDia := ( (wCustoV) + wJurEst ) * (Tx2/100) &&(Tx2/100)
				WJurEst := wJurEst + wJurDia

			Next

		Endif

	Endif

EndIf

If !Empty(cSavAlias)
	DbSelectArea(cSavAlias)
EndIf

Return(wJurEst)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_FIMSEMANA ³ Autor ³ Mil               ³ Data  ³ 26/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que Retorna .t. se uma data for um e Final de Semana³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ wDatas = Data                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_FimSemana(wDatas)

If Str(Dow(wDatas),1) $ [1#7]
	Return( .t. )
EndIf

Return( .f. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_PictVar  ³ Autor ³ Fabio             ³ Data  ³ 28/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que Define Picture Variavel de Campos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FG_PictVar(cTipCpo) Ex. FG_PictVar("CGCCPF")               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PictVar(cPict)

Local nPosSX3:=SX3->(Recno()),nIndSX3:=SX3->(IndexOrd())

SX3->(DbSetOrder(2))
SX3->(DbSeek( Substr(ReadVar(),At(">",ReadVar())+1)))

If Valtype(&(ReadVar())) != SX3->X3_TIPO
	If SX3->X3_TIPO == "C"
		&(ReadVar()) := Str(&(ReadVar()),SX3->X3_TAMANHO)
	Else
		&(ReadVar()) := Val(&(ReadVar()))
	EndIf
EndIf

SX3->(DbSetOrder(nIndSX3))
SX3->(DbGoTo(nPosSX3))

Return(cPict)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_PI     ºAutor  ³Fabio               º Data ³  04/18/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica no grupo do item qual a picture que sera usada     º±±
±±º          ³no codigo do item                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PI(cGruIte)

Return( Alltrim( Posicione("SBM",1,xFilial("SBM")+cGruIte,"BM_PICPAD") )+"%C"  )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_MEMVAR ³ Autor ³ Andre/Fabio           ³ Data ³ 16/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria a partir de um aheader/acols variaveis de memoria      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FG_MEMVAR()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       |Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_MEMVAR(aAuxHeader, aAuxCols, nAuxLinha)

Local bCampo := {|x| aHeader[x,2]}
Local z := 0

// Se não for passado parametro ...
if ValType(aAuxHeader) == "U"
	For z=1 to Len(aHeader)
		if Type("M->"+(EVAL(bCampo,z))) # "U"
			If "M->"+(EVAL(bCampo,z)) != READVAR()
				&( "M->"+(EVAL(bCampo,z)) ) := aCols[n,z]
			EndIf

			If Alltrim("M->"+aHeader[z,2]) == Alltrim( READVAR() ) .and. IIf(z < len(aHeader),IIf(aHeader[z+1,10] == "V",.T.,.F.),.F.) ;
				.And. Type("M->"+(aHeader[z+1,2])) # "U"
				aCols[n,z+1] := &( "M->"+(aHeader[z+1,2]) )
			EndIf
		Endif
	Next
else
	bCampo := {|x| aAuxHeader[x,2]}
	For z=1 to Len(aAuxHeader)
		if Type("M->"+(EVAL(bCampo,z))) # "U"
			If aAuxHeader[z,10] <> "V" .AND. "M->"+(EVAL(bCampo,z)) != READVAR()
				&( "M->"+(EVAL(bCampo,z)) ) := aAuxCols[nAuxLinha,z]
			EndIf

			// Se o campo for VIRTUAL ...
			If aAuxHeader[z,10] == "V" .And. !IsHeadRec(aAuxHeader[z,2]) .And. !IsHeadAlias(aAuxHeader[z,2])
				If !Empty(aAuxHeader[z,12])
					// executar o x3_relacao dele ...
					&( "M->"+(EVAL(bCampo,z)) ) := &(aAuxHeader[z,12])
				Else
					&( "M->"+(EVAL(bCampo,z)) ) := aAuxCols[nAuxLinha,z]
				EndIf
			EndIf
			/*
			If Alltrim("M->"+aAuxHeader[z,2]) == Alltrim( READVAR() ) .and.;
			IIf(z < len(aAuxHeader),IIf(aAuxHeader[z+1,10] == "V",.T.,.F.),.F.) ;
			.And. Type("M->"+(aAuxHeader[z+1,2])) # "U"
			aAuxCols[nAuxLinha,z+1] := &( "M->"+(aAuxHeader[z+1,2]) )
			EndIf
			*/
		Endif
	Next
endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_ATRVAL ³ Autor ³ Andre/Manoel          ³ Data ³ 19/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atribui Valor a um Cpo da Enchoice                         ³±±
±±³          ³ Os Campos da Expressao devem ser de Memoria, ou seja, M->? ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FG_ATRVAL(cCpoDest,cExpr,cVltVal)                          ³±±
±±³          ³ Qdo o 3o Parametro (cVltVal) for setado com "S", o retorno ³±±
±±³          ³ da funcao nao sera .t. e sim o resultado da EXPRESSAO.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_ATRVAL(cCpoDest,cExpr,cVltVal)

M->&cCpoDest := &cExpr

wRetu := .t.

If cVltVal == "S"
	wRetu := &cExpr
EndIf

Return(wRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_ULTKIL³ Autor ³  MIL                  ³ Data ³ 16/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Encontra ultima kilometragem                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_UltKil(cChaInt,dDataComp,nHoraComp,nTpComp,cInfOS,cOSAtu,nRetDefault)

Default dDataComp := dDataBase
Default nHoraComp := 2359
Default nTpComp := 1

If VALID_KIL == NIL
	VALID_KIL := Left(GetNewPar("MV_VKILHOR","SN"),1)
EndIf

If VALID_KIL == "N"
	Return 0
Endif

Return FG_RETULT( cChaInt , dDataComp , nHoraComp , nTpComp, "VO1_KILOME" , @cInfOS , cOSAtu , nRetDefault )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_ULTHOR³ Autor ³  Luis Delorme         ³ Data ³ 10/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Encontra ultima hora de pista                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_ULTHOR(cChaInt, dDataComp, nHoraComp, nTpComp, cInfOS, cOSAtu , nRetDefault )

Default dDataComp := dDataBase
Default nHoraComp := 2359
Default nTpComp := 1

If VALID_HOR == NIL
	VALID_HOR := SubStr(GetNewPar("MV_VKILHOR","SN"),2,1)
EndIf

if VALID_HOR == "N" .or. VO1->(FieldPos("VO1_HORTRI")) <= 0
	return 0
endif

Return FG_RETULT( cChaInt , dDataComp , nHoraComp , nTpComp, "VO1_HORTRI", @cInfOS , cOSAtu , nRetDefault )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_RETULT³ Autor ³  Rubens Takahashi     ³ Data ³ 21/08/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a ultima KM/Hora                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_RETULT(cChaInt, dDataComp, nHoraComp, nTpComp, cCpoRet, cInfOS, cOSAtu, nRet )

//Local nRet
Local cSelect  := alias()
Local cQuery   := ""
Local nCont    := 0
Local cChassi
Local cBkpFilAnt
Local cFilVV1  := xFilial("VV1")
Local lVO1DATATE := VO1->(FieldPos("VO1_DATATE")) <> 0
Local oDMSSQL  := DMS_SqlHelper():New()

Local cAliasOS := "TMPKIL"

Local cSinal   := IIf( nTpComp == 1 , "<" , ">" )

//Default nRetDefault := 1
Default nRet := 1

If ULTKIL_VO1 == NIL
	aAuxFilAtu := FWArrFilAtu()
	aAuxSM0    := FWAllFilial( aAuxFilAtu[3] , aAuxFilAtu[4] , aAuxFilAtu[1] , .f. )
	ULTKIL_VO1 := ""
	cBkpFilAnt := cFilAnt
	ULTKIL_VV1 := .t.
	For nCont := 1 to Len(aAuxSM0)
		cFilAnt := aAuxSM0[nCont]
		If ULTKIL_VV1 .and. cFilVV1 <> xFilial("VV1") // Verifica se o VV1 nao eh compartilhado
			ULTKIL_VV1 := .f.
		EndIf
		ULTKIL_VO1 += "'"+xFilial("VO1")+"',"
	Next
	cFilAnt := cBkpFilAnt
	ULTKIL_VO1 := "(" + left(ULTKIL_VO1,len(ULTKIL_VO1)-1) + ")"
EndIf

If !ULTKIL_VV1 // VV1 Exclusivo
	cChassi := FM_SQL("SELECT VV1_CHASSI FROM "+RetSqlName("VV1")+" WHERE VV1_FILIAL='"+cFilVV1+"' AND VV1_CHAINT='"+cChaInt+"' AND D_E_L_E_T_=' '")
EndIf

cQuery := "SELECT VO1.VO1_FILIAL, VO1.VO1_NUMOSV, VO1." + cCpoRet + " NUM "
cQuery +=  " FROM "+RetSqlName("VO1")+" VO1"
cQuery += " WHERE VO1.VO1_FILIAL IN "+ULTKIL_VO1
cQuery += IIf( ULTKIL_VV1 , " AND VO1.VO1_CHAINT='"+cChaInt+"'" , " AND VO1.VO1_CHASSI='"+cChassi+"'" )
cQuery +=   " AND VO1." + cCpoRet + " <> 0 "
cQuery +=   " AND VO1.D_E_L_E_T_=' '"
cQuery += IIf( cOSAtu <> NIL , " AND VO1.VO1_NUMOSV <> '" + cOSAtu + "'" , "" )
If lVO1DATATE
	cQuery += " AND (    ( VO1.VO1_DATATE <> '        ' AND ( VO1.VO1_DATATE " + cSinal + " '" + DtoS(dDataComp) + "' OR ( VO1.VO1_DATATE = '" + DtoS(dDataComp) + "' AND VO1.VO1_HORATE " + cSinal + "= " + Str(nHoraComp,4) + " ) ) ) " // Se informads, trabalha com a data de execucao ...
	cQuery += "       OR ( VO1.VO1_DATATE =  '        ' AND ( VO1.VO1_DATABE " + cSinal + " '" + DtoS(dDataComp) + "' OR ( VO1.VO1_DATABE = '" + DtoS(dDataComp) + "' AND VO1.VO1_HORABE " + cSinal + "= " + Str(nHoraComp,4) + " ) ) ) )"
Else
	cQuery += " AND (    ( VO1.VO1_DATABE <  '" + DtoS(dDataComp) + "' OR ( VO1.VO1_DATABE = '" + DtoS(dDataComp) + "' AND VO1.VO1_HORABE <= " + Str(nHoraComp,4) + " ) ) )"
EndIf
cQuery += " ORDER BY CASE WHEN VO1.VO1_DATATE <> ' ' THEN VO1.VO1_DATATE ELSE VO1.VO1_DATABE END " + IIf( nTpComp == 1 , " DESC" , "" )
cQuery +=         " ,CASE WHEN VO1.VO1_DATATE <> ' ' THEN VO1.VO1_HORATE ELSE VO1.VO1_HORABE END " + IIf( nTpComp == 1 , " DESC" , "" )
cQuery +=         " ," + cCpoRet + IIf( nTpComp == 1 ,  " DESC" , "" )

if cCpoRet $ "VO1_KILOME.VO1_HORTRI" .and. ExistBlock("PEULTKIL") // Ponto de entrada para manipulacao do valor da hora.
	cQuery := ExecBlock("PEULTKIL",.f.,.f.,{cQuery})
Endif

cQuery := oDMSSQL:TOPFunc(cQuery,1)

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasOS , .F., .T. )
If !(cAliasOS)->(Eof())
	nRet := (cAliasOS)->NUM
	cInfOS := (cAliasOS)->VO1_FILIAL + " - " + (cAliasOS)->VO1_NUMOSV
End
(cAliasOS)->(dbCloseArea())
If !Empty(cSelect)
	dbSelectArea(cSelect)
EndIf

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_VKILHOR ³ Autor ³  Rubens Takahashi   ³ Data ³ 21/08/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a ultima KM/Hora do Veiculo                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_VKILHOR( cChaInt, dDataComp, nHoraComp, nKilome, nHoras , cChamada , cOSAtu )

Local nValAnte
Local nValProx

Local cOSAnt := ""
Local cOSPos := ""

Default cChamada := ""
Default cOSAtu := NIL

If VALID_KIL == NIL
	VALID_KIL := Left(GetNewPar("MV_VKILHOR","SN"),1)
EndIf
If VALID_HOR == NIL
	VALID_HOR := SubStr(GetNewPar("MV_VKILHOR","SN"),2,1)
EndIf

If nKilome <> NIL .and. (VALID_KIL == "S" .or. ( VALID_KIL == "P" .and. cChamada == "LIB" ))
	nValAnte := FG_ULTKIL( cChaInt, dDataComp , nHoraComp , 1 , @cOSAnt, cOSAtu )
	If nKilome < nValAnte
		Help("  ",1,"DMSVKIL",,;
			STR0399 + Transform(nKilome,"@E 99,999,999") + CHR(13) + CHR(10) + ;
			STR0400 + Transform(nValAnte,"@E 99,999,999"),3,0) // "KM/Hora informada: " # "Última KM/Hora: "
		Return .f.
	EndIf
	nValProx := FG_ULTKIL( cChaInt, dDataComp , nHoraComp , 2 , @cOSPos, cOSAtu , 0 )
	If nKilome > nValProx .and. nValProx > 0
		Help("  ",1,"DMSVKIL",,;
			STR0399 + Transform(nKilome,"@E 99,999,999") + CHR(13) + CHR(10) + ;
			IIF( !Empty(cOSAnt) , STR0401 + Transform(nValAnte,"@E 99,999,999") + " (" + cOSAnt + ")" , "" ) + CHR(13) + CHR(10) + ;
			STR0402 + Transform(nValProx,"@E 99,999,999") + " (" + cOSPos + ")" ,3,0) // "KM/Hora informada: " # "KM/Hora da OS anterior: "
		Return .f.
	EndIf
EndIf
If nHoras <> NIL .and. ( VALID_HOR == "S" .or. ( VALID_HOR == "P" .and. cChamada == "LIB"))
	If nHoras > nKilome
		Help("  ",1,"DMSVKILHOR",,;
			STR0399 + Transform(nKilome,"@E 99,999,999") + CHR(13) + CHR(10) + ;
			STR0403 + Transform(nHoras,"@E 99,999,999"),3,0) // "KM/Hora informada: " # "Hora Trilha informada: "
		Return .f.
	EndIf
	nValAnte := FG_ULTHOR( cChaInt, dDataComp , nHoraComp , 1 , @cOSAnt, cOSAtu )
	If nHoras < nValAnte
		Help("  ",1,"DMSVHOR",,;
			STR0403 + Transform(nHoras,"@E 99,999,999") + CHR(13) + CHR(10) + ;
			STR0404 + Transform(nValAnte,"@E 99,999,999"),3,0) // "Hora Trilha informada: " # "Última Hora Trilha: "
		Return .f.
	EndIf
	nValProx := FG_ULTHOR( cChaInt, dDataComp , nHoraComp , 2 , @cOSPos, cOSAtu , 0 )
//	If nValProx <> 1 .and. nHoras > nValProx
	If nHoras > nValProx .and. nValProx > 0
		Help("  ",1,"DMSVHOR",,;
			STR0403 + Transform(nHoras,"@E 99,999,999") + CHR(13) + CHR(10) + ;
			IIf( !Empty(cOSAnt) , STR0405 + Transform(nValAnte,"@E 99,999,999") + " (" + cOSAnt + ")" , "" ) + CHR(13) + CHR(10) + ;
			STR0406 + Transform(nValProx,"@E 99,999,999") + " (" + cOSPos + ")" ,3,0) // "Hora Trilha informada: " # "Hora Trilha da OS ant.: " # "Hora Trilha da OS pos.: "
		Return .f.
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_TEMPAD³ Autor ³  MIL                  ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Encontra Tempo Padrao para o Servico / Modelo              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cChaInt - Numero Interno de Chassi                         ³±±
±±³          ³ cCodSer - Codigo do Servico a ser pesquisado               ³±±
±±³          ³ cIncTem - Incidencia de Tempo F=Fabrica C=Concessionaria   ³±±
±±³          ³ cIncMob - Incidencia de Mao de Obra                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_TemPad(cCha,cCod,cInc,cInc2,cMar)

Local cSegMod := ""
Local cMarcaVO6 := ""

cChaint := cCha
cCodSer := cCod
cIncTem := cInc
cIncMob := cInc2
cMarPes := IIf(ValType("cMar")=="U","",cMar)

nTemPad := 0

// VOK_INCMOB = 2 - Servico de Terceiro
If cIncMob == "2"
	Return 0
EndIf

DbSelectArea("VV1")
DbSetOrder(1)
If MsSeek(xFilial("VV1")+cChaInt) .Or. !Empty(cMarPes)
	If VV1->(Found())
		cMarPes := VV1->VV1_CODMAR
		If !Empty(VV1->VV1_SEGMOD)
			cSegMod := VV1->VV1_SEGMOD
		EndIf
	EndIf

	cMarcaVO6 := FG_MARSRV(cMarPes,cCodSer)

	DbSelectArea("VO6")
	DbSetOrder(2)
	If MsSeek(xFilial("VO6")+ cMarcaVO6 + cCodSer )
		DbSelectArea("VO7")
		DbSetOrder(1)
		If VV1->(Found()) .And. DbSeek(xFilial("VO7")+VV1->VV1_CODMAR+cCodSer+VV1->VV1_MODVEI+cSegMod)
			Do Case
				Case (cIncTem == "1")
					nTemPad := VO7->VO7_TEMFAB
				Case (cIncTem == "2")
					nTemPad := VO7->VO7_TEMCON
				Case (cIncTem == "4")
					nTemPad := VO7->VO7_TEMFAB
				Case (cIncTem == "5")
					nTemPad := 0
			EndCase
		Else
			Do Case
				Case (cIncTem == "1")
					nTemPad := VO6->VO6_TEMFAB
				Case (cIncTem == "2")
					nTemPad := VO6->VO6_TEMCON
				Case (cIncTem == "4")
					nTemPad := VO6->VO6_TEMFAB
				Case (cIncTem == "5")
					nTemPad := 0
			EndCase
		EndIf
	Else
		nTemPad := 99999
	EndIf
Else
	nTemPad := 99999
EndIf

Return nTemPad

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_HABPRO³ Autor ³  MIL                  ³ Data ³ 16/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ VerIfica a habilidade do produtivo p/a execucao de servicos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_HabPro(cCodPro,cCodMar,cCodSer,lMensagem)

lMensagem := IIf(lMensagem != NIL,lMensagem,.t.)
cSelect   := Alias()

If VAI->VAI_CODTEC # cCodPro
	DbSelectArea("VAI")
	DbSetOrder(1)
	DbSeek(xFilial("VAI")+cCodPro)
EndIf

If !Empty(VAI->VAI_DATDEM) .And. dDataBase >= VAI->VAI_DATDEM

	If lMensagem
		Help("  ",1,"FUNCJADEM",,VAI->VAI_CODTEC+" "+VAI->VAI_NOMTEC,4,1)
	EndIf

	If !Empty(cSelect)
		DbSelectArea(cSelect)
	EndIf

	Return(.f.)

EndIf

DbSelectArea("VOC")
DbSetOrder(1)
If VOC->(DbSeek(xFilial("VOC")+cCodPro))
	If GETMV("MV_HABPRO") == "S" .And. !(VOC->(DbSeek(xFilial("VOC")+cCodPro+cCodMar+cCodSer)))
		If lMensagem
			Help(" ",1,"PROHABIL")
		EndIf

		If !Empty(cSelect)
			DbSelectArea(cSelect)
		EndIf

		Return(.f.)
	EndIf
EndIf

If !Empty(cSelect)
	DbSelectArea(cSelect)
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_RECREG³ Autor ³  MIL                  ³ Data ³ 16/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Recria Registro para apontamento de servicos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_RecReg(cCodPro,dDataFim,nHoraFim)

Local aTrabMec := {},cSelect:=Alias()
Local nHoraFin,nHoraTrab,nHoraExtra
Local i := 0
Local ni := 0

DbSelectArea("VOE")
If !DbSeek(xFilial("VOE")+cCodPro)
	Return(.f.)
EndIf

DbSelectArea("VOH")
If !DbSeek(xFilial("VOH")+VOE->VOE_CODPER)
	Return(.f.)
EndIf

nHoraFin :=(Val(Left(StrZero(nHoraFin,4),2))*60)+Val(Right(StrZero(nHoraFin,4),2))
nINIPER  :=(Val(Left(StrZero(VOH->VOH_INIPER,4),2))*60)+Val(Right(StrZero(VOH->VOH_INIPER,4),2))
nINICF1  :=(Val(Left(StrZero(VOH->VOH_INICF1,4),2))*60)+Val(Right(StrZero(VOH->VOH_INICF1,4),2))
nFINCF1  :=(Val(Left(StrZero(VOH->VOH_FINCF1,4),2))*60)+Val(Right(StrZero(VOH->VOH_FINCF1,4),2))
nINIREF  :=(Val(Left(StrZero(VOH->VOH_INIREF,4),2))*60)+Val(Right(StrZero(VOH->VOH_INIREF,4),2))
nFINREF  :=(Val(Left(StrZero(VOH->VOH_FINREF,4),2))*60)+Val(Right(StrZero(VOH->VOH_FINREF,4),2))
nINICF2  :=(Val(Left(StrZero(VOH->VOH_INICF2,4),2))*60)+Val(Right(StrZero(VOH->VOH_INICF2,4),2))
nFINCF2  :=(Val(Left(StrZero(VOH->VOH_FINCF2,4),2))*60)+Val(Right(StrZero(VOH->VOH_FINCF2,4),2))
nFINPER  :=(Val(Left(StrZero(VOH->VOH_FINPER,4),2))*60)+Val(Right(StrZero(VOH->VOH_FINPER,4),2))

For i:=0 to 1440     // 1440 e a Quantidade de Minutos que tem Um dia ou 24 Horas.
	If i<nINIPER .Or. i>nFINPER
		nStatus := 0 				          // Hora Fora do Turno
	EndIf
	If i>=nINIPER.And.i<nINICF1 .Or. i>=nFINCF1.And.i<nINIREF .Or. i>=nFINREF.And.i<nINICF2 .Or. i>=nFINCF2.And.i<=nFINPER
		nStatus := 1                           // Hora no Turno e Disponivel
	EndIf
	If i>=nINICF1.And.i<nFINCF1 .Or. i>=nINIREF.And.i<nFINREF .Or. i>=nINICF2.And.i<nFINCF2 //i>=nINIPER.And.i<nINICF1 .Or. i>=nFINCF1.And.i<nINIREF .Or. i>=nFINREF.And.i<nINICF2 .Or. i>=nFINCF2.And.i<=nFINPER
		nStatus := 3                           // Hora no turno mas ausente
	EndIf
	Aadd(aTrabMec,{i,,,nStatus})
Next

DbSelectArea("VO4")
DbSetOrder(2)
If DbSeek(xFilial("VO4")+cCodPro) .And. Empty(VO4->VO4_DATFIM)
	nHoraIni :=(Val(Left(StrZero(VO4->VO4_HORINI,4),2))*60)+Val(Right(StrZero(VO4->VO4_HORINI,4),2))
	For ni:=1  to Len(aTrabMec)
		If aTrabMec[ni,5] >= nHoraIni .And. aTrabMec[ni,5] <= nHoraFim
			If aTrabMec[ni,5]==1
				nHoraTrab++
			Else
				nHoraExtra++
			EndIf
		EndIf
	Next
EndIf

If !Empty(cSelect)
	DbSelectArea(cSelect)
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_ValHor³ Autor ³  MIL                  ³ Data ³ 25/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o Valor da Hora de acordo com o periodo pedido     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cTipTem  := Tipo de tempo                                   ³±±
±±³          ³dDataRef := Data de referencia                              ³±±
±±³          ³dDataComp:= Data de referencia para comparacao              ³±±
±±³          ³nVlrComp := Valor da hora na data da requisicao para compara³±±
±±³          ³            cao.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_ValHor(cTipTem,dDataRef,cVHRDIG,nVlrComp,cCodMar,cCodSrv,cTipSer,cCodCli,cLojCli,cModVei,cSegMod)

Local aArea:={} , nValHor:=0

Default cCodSrv := VO4->VO4_CODSER

If Type("M->VS1_TIPTSV") != "U"
	cTipTem := M->VS1_TIPTSV
Endif

aArea := sGetArea(aArea,"VOI")
aArea := sGetArea(aArea,"VOJ")
aArea := sGetArea(aArea,"VO6")
aArea := sGetArea(aArea,"VV1")

&& Assume o valor informado na requisicao de servico caso tenha sido alterado.
If ( cVHRDIG # NIL .And. cVHRDIG == "1" .And. nVlrComp # NIL)
	nValHor := nVlrComp
EndIf

&& Assume o valor da hora do cliente
If cVHRDIG # NIL .And. cTipSer == NIL .And. cCodCli == NIL .And. cLojCli == NIL
	cTipSer := VO4->VO4_TIPSER
	cCodCli := VO4->VO4_FATPAR
	cLojCli := VO4->VO4_LOJA
EndIf

If cCodMar == NIL
	cCodMar := FM_SQL("SELECT VV1_CODMAR FROM " + RetSQLName("VV1") + " VV1 WHERE VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1_CHAINT = '" + VO1->VO1_CHAINT + "' AND D_E_L_E_T_ = ' '")
EndIf

If cModVei == NIL
	cModVei := FM_SQL("SELECT VV1_MODVEI FROM " + RetSQLName("VV1") + " VV1 WHERE VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1_CHAINT = '" + VO1->VO1_CHAINT + "' AND D_E_L_E_T_ = ' '")
	cSegMod := FM_SQL("SELECT VV1_SEGMOD FROM " + RetSQLName("VV1") + " VV1 WHERE VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1_CHAINT = '" + VO1->VO1_CHAINT + "' AND D_E_L_E_T_ = ' '")
EndIf


nValHor := FMX_VALHOR( cTipTem , dDataRef , cVHRDIG , nVlrComp , cCodMar , cCodSrv , cTipSer , cCodCli , cLojCli , , cModVei , cSegMod )

Return nValHor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_PicHor³ Autor ³  MIL                  ³ Data ³ 16/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Picture de Horavel                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PICHOR(nHor)

nHora := nHor
nHora := strzero(int(nHora *100),5)
nHora := left(nHora,3)+":"+right(nHora,2)

Return(nHora)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_ProTra³ Autor ³  MIL                  ³ Data ³ 16/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Produtivo esta trabalhando ?                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_ProTra(cNumOsv,cCodPro,lMensagem,lRetorno,nPosLin)

Local cNosNumSeq , cSele := Alias()
Local cTTRela := ""  // Tipo de Tempo relacionado
Local lVerTT  := .t. // verifica Tipo de Tempo quando Controla se o Produtivo esta trabalhando no Servico
Default lMensagem := .t.
Default lRetorno  := .t.
Default nPosLin   := 0

If nPosLin == 0 .and. Type("n") <> "U"
	nPosLin := n // Pegar a posicao da aCols
EndIf

aArea1 := GetArea()
aArea2 := VO4->(GetArea())
aArea3 := VO2->(GetArea())
aArea4 := VO1->(GetArea())
aArea5 := VAI->(GetArea())

If lMensagem
	DbSelectArea("VAI")
	DbSetOrder(1)
	DbSeek(xFilial("VAI")+cCodPro)
EndIf

If !Empty(VAI->VAI_DATDEM) .And. dDataBase >= VAI->VAI_DATDEM

	If lMensagem
		Help("  ",1,"FUNCJADEM",,VAI->VAI_CODTEC+" "+VAI->VAI_NOMTEC,4,1)
	EndIf

	Return( IIf( lRetorno , .f. , "" ) )

EndIf

&& Nao controla se o produtivo esta trabalhando no servico.
If VAI->VAI_CONTRB != "1"
	If !Empty(cSele)
		DbSelectArea(cSele)
	EndIf
	Return( IIf( lRetorno , .t. , "" ) )
Else
	lVerTT := (GetNewPar("MV_VERTTCP","S") == "S") // Verifica Tipo de Tempo quando Controla se o Produtivo esta trabalhando no Servico
EndIf


lTipTem := .f.
If Type("aCols") != "U" .and. FG_POSVAR("VO3_TIPTEM") != 0
	lTipTem := .t.
Endif

If lTipTem .and. nPosLin > 0 .and. VOI->(FieldPos("VOI_TTRELA")) > 0
	cTTRela := FM_SQL("SELECT VOI_TTRELA FROM "+RetSQLName("VOI")+" VOI WHERE VOI_FILIAL = '"+xFilial("VOI")+"' AND VOI_TIPTEM = '"+acols[nPosLin,FG_POSVAR("VO3_TIPTEM")]+"' AND VOI.D_E_L_E_T_ = ' '")  // Tipo de Tempo relacionado
	If Empty(cTTRela)
		cTTRela := acols[nPosLin,FG_POSVAR("VO3_TIPTEM")]
	Endif
Endif

DbSelectArea("VO4")
DbSetOrder(3)
If DbSeek(xFilial("VO4")+cCodPro)
	While VO4->VO4_CODPRO == cCodPro .and. Empty(VO4_DATFIN) .and. !eof()
		DbSelectArea("VO2")
		VO2->(DbSetOrder(2))
		VO2->(DbSeek(xFilial("VO2")+VO4->VO4_NOSNUM))

		DbSelectArea("VO1")
		VO1->(DbSetorder(1))
		VO1->(DbSeek(xFilial("VO1")+VO2->VO2_NUMOSV))

		If VO1->VO1_NUMOSV == cNumOsv .And. VO1->VO1_STATUS == "A" .And.;
			( !Empty(VO4->VO4_DATINI) .And. Empty(VO4->VO4_DATFIN) ) .and. IIf(lTipTem,IIf(!lVerTT.and.nPosLin>0,(VO4->VO4_TIPTEM==acols[nPosLin,FG_POSVAR("VO3_TIPTEM")] .or. VO4->VO4_TIPTEM==cTTRela),.t.),.t.)

			cNosNumSeq := VO4->VO4_NOSNUM+VO4->VO4_SEQUEN

			// Volta posicoes originais
			RestArea(aArea1)
			RestArea(aArea2)
			RestArea(aArea3)
			RestArea(aArea4)
			RestArea(aArea5)

			If !Empty(cSele)
				DbSelectArea(cSele)
			EndIf

			Return( IIf( lRetorno , .t. , cNosNumSeq ) )

		EndIf
		DbSelectArea("VO4")
		DbSkip()
	EndDo
EndIf

If lMensagem
	Help(" ",1,"PRODATIVO")
EndIf

// Volta posicoes originais
RestArea(aArea1)
RestArea(aArea2)
RestArea(aArea3)
RestArea(aArea4)
RestArea(aArea5)

If !Empty(cSele)
	DbSelectArea(cSele)
EndIf

Return( IIf( lRetorno , .f. , "" ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FG_DadOsv³ Autor ³  MIL                  ³ Data ³ 16/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Apresenta dados cadastrais basicos para consulta de OS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_DadOsv()

Local lA1_IBGE := IIf(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)

M->VO2_NUMOSV := VO1->VO1_NUMOSV
M->VO2_DATABE := VO1->VO1_DATABE
M->VO2_HORABE := VO1->VO1_HORABE
M->VO2_KILOME := VO1->VO1_KILOME
FG_SEEK("VV1","VO1->VO1_CHAINT",1,.f.)
FG_SEEK("VE1","VV1->VV1_CODMAR",1,.f.)
M->VO2_DESMAR := VE1->VE1_DESMAR
FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
M->VO2_DESMOD := VV2->VV2_DESMOD
M->VO2_CHASSI := VV1->VV1_CHASSI
M->VO2_PLAVEI := VV1->VV1_PLAVEI
M->VO2_CODFRO := VV1->VV1_CODFRO
M->VO2_PROVEI := VO1->VO1_PROVEI
FG_SEEK("SA1","VO1->VO1_PROVEI",1,.f.)
if lA1_IBGE
	FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
	M->VO2_CIDPRO := VAM->VAM_DESCID
	M->VO2_ESTPRO := VAM->VAM_ESTADO
else
	M->VO2_CIDPRO := SA1->A1_MUN
	M->VO2_ESTPRO := SA1->A1_EST
endif
M->VO2_NOMPRO := SA1->A1_NOME
M->VO2_ENDPRO := SA1->A1_END
M->VO2_FONPRO := SA1->A1_TEL
M->VO2_FUNCON := VO1->VO1_FUNABE
M->VO2_NOMFUN := Posicione("VAI",1,xFilial("VAI")+VO1->VO1_FUNABE,"VAI_NOMTEC")
M->VO2_FUNREQ := Posicione("VAI",4,xFilial("VAI")+__cUserID,"VAI_CODTEC")
M->VO2_NOMREQ := VAI->VAI_NOMTEC

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FG_DadVei³ Autor ³  MIL                  ³ Data ³ 22/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Apres dados cadastrais basicos para consulta de Veiculos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FG_DadVei()
Local lA1_IBGE := IIf(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)

If FG_SEEK("VV1","M->VO5_CHAINT",1,.f.)

	FG_SEEK("VE1","VV1->VV1_CODMAR",1,.f.)
	M->VO5_DESMAR := VE1->VE1_DESMAR

	FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
	M->VO5_DESMOD := VV2->VV2_DESMOD
	M->VO5_CHASSI := VV1->VV1_CHASSI
	M->VO5_CODFRO := VV1->VV1_CODFRO
	M->VO5_PLAVEI := VV1->VV1_PLAVEI
	M->VO5_FABMOD := VV1->VV1_FABMOD

	FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
	M->VO5_DESCOR := VVC->VVC_DESCRI

	FG_SEEK("SA1","VV1->VV1_PROATU",1,.f.)
	if lA1_IBGE
		FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
		M->VO5_CIDPRO := VAM->VAM_DESCID
		M->VO5_ESTPRO := VAM->VAM_ESTADO
	else
		M->VO5_CIDPRO := SA1->A1_MUN
		M->VO5_ESTPRO := SA1->A1_EST
	endif
	M->VO5_PROVEI := SA1->A1_COD
	M->VO5_NOMPRO := SA1->A1_NOME
	M->VO5_ENDPRO := SA1->A1_END
	M->VO5_FONPRO := SA1->A1_TEL

	FG_SEEK("VVK","VV1->VV1_CODMAR+VV1->VV1_CODCON",1,.f.)
	M->VO5_RAZSOC := VVK->VVK_RAZSOC
	M->VO5_CGCVEN := VVK->VVK_CGCVEN
	M->VO5_CIDADE := VVK->VVK_CIDADE
Else
	M->VO5_DESMAR := ""
	M->VO5_DESMOD := ""
	M->VO5_CHASSI := ""
	M->VO5_CODFRO := ""
	M->VO5_PLAVEI := ""
	M->VO5_PROVEI := ""
	M->VO5_NOMPRO := ""
	M->VO5_ENDPRO := ""
	M->VO5_CIDPRO := ""
	M->VO5_ESTPRO := ""
	M->VO5_DDDPRO := ""
	M->VO5_FONPRO := ""
	M->VO5_RAZSOC := ""
	M->VO5_CGCVEN := ""
	M->VO5_CIDADE := ""
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FG_VeiOrc³ Autor ³  MIL                  ³ Data ³ 18/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Apresenta Vados de Veiculos para Orcamento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FG_VeiOrc()
Local lA1_IBGE := IIf(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)

If FG_SEEK("VV1","M->VO5_CHAINT",1,.f.)
	FG_SEEK("VE1","VV1->VV1_CODMAR",1,.f.)
	M->VS1_DESMAR := VE1->VE1_DESMAR
	M->VS1_CODMAR := VV1->VV1_CODMAR

	FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
	M->VS1_DESMOD := VV2->VV2_DESMOD
	M->VS1_CHASSI := VV1->VV1_CHASSI
	M->VS1_CODFRO := VV1->VV1_CODFRO
	M->VS1_PLAVEI := VV1->VV1_PLAVEI
	M->VS1_FABMOD := VV1->VV1_FABMOD

	FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
	M->VS1_DESCOR := VVC->VVC_DESCRI

	FG_SEEK("SA1","VV1->VV1_PROATU",1,.f.)
	if lA1_IBGE
		FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
		M->VS1_CIDPRO := VAM->VAM_DESCID
		M->VS1_ESTPRO := VAM->VAM_ESTADO
	else
		M->VS1_CIDPRO := SA1->A1_MUN
		M->VS1_ESTPRO := SA1->A1_EST
	endif
	M->VS1_PROVEI := SA1->A1_COD
	M->VS1_NOMPRO := SA1->A1_NOME
	M->VS1_ENDPRO := SA1->A1_END
	M->VS1_FONPRO := SA1->A1_TEL
Else
	M->VS1_DESMAR := ""
	M->VS1_DESMOD := ""
	M->VS1_CHASSI := ""
	M->VS1_CODFRO := ""
	M->VS1_PLAVEI := ""
	M->VS1_FABMOD := ""
	M->VS1_DESCOR := ""
	M->VS1_PROVEI := ""
	M->VS1_NOMPRO := ""
	M->VS1_ENDPRO := ""
	M->VS1_CIDPRO := ""
	M->VS1_ESTPRO := ""
	M->VS1_FONPRO := ""
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_SitBox³ Autor ³  Emilton/Fabio        ³ Data ³ 23/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Devolve a Situacao do Box                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_SitBox(WP_NUMBOX)

Private WP_NUMBOX_ := WP_NUMBOX

FG_SEEK("VOF","WP_NUMBOX_",1,.F.)

Return(VOF->VOF_SITBOX)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FG_OBRIGAT  ³ Autor ³ Fabio               ³ Data ³ 18/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³VerIfica se campos obrigatorios foram digitados             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_OBRIGAT(aCpoObrigat)

Local w := 0
Local nPCpo := 0

Default aCpoObrigat := {}

// Linha está marcada como deletada
If (aCols[n,Len(aHeader)+1])
	Return .t.
EndIf
//

If Len(aCpoObrigat) > 0
	For nPCpo := 1 to Len(aCpoObrigat)
		If Empty( aCols [ n , aCpoObrigat[nPCpo] ] )
			Help(1," ","OBRIGAT",, aHeader[ aCpoObrigat[nPCpo] ,1] ,4,1)
			Return(.f.)
		Endif
	Next nPCpo
Else
	For w:=1 to Len(aHeader)
		wVar := "M->"+aHeader[w,2]

		cKey := alltrim(aheader[W,2])

		If X3Obrigat(cKey) .And. (Empty(aCols[n,w]))
			Help(1," ","OBRIGAT",,aHeader[w,1],4,1)
			Return(.f.)
		Endif

	Next
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FG_ANOMOD   ³ Autor ³ Manoel              ³ Data ³ 20/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Ano de Fabricacao e Modelo do Veiculo                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_ANOMOD(cCpo, cParAnoFab)

Default cParAnoFab := ""

If Empty(cParAnoFab)
	cCpo := "M->"+cCpo
	cAnoFab := subs(&cCpo,1,4)
	cAnoMod := subs(&cCpo,5,4)
Else
	cAnoFab := subs(cParAnoFab,1,4)
	cAnoMod := subs(cParAnoFab,5,4)
EndIf

If Len(alltrim(cAnoFab)) != 4
	Return(.f.)
EndIf

If Len(alltrim(cAnoMod)) != 4
	Return(.f.)
EndIf

If !(cAnoFab >= str(year(date())-999,4))
	Return(.f.)
EndIf

If !(Val(cAnoMod) >= Val(cAnoFab) .and.  Val(cAnoMod) <= Val(cAnoFab) + 1)
	Return(.f.)
EndIf
If (Val(cAnoMod) - Val(cAnoFab)) > 1
	Return(.f.)
EndIf

If Val(cAnoFab) > (year(date()))
	Return(.f.)
EndIf

If Val(cAnoMod) > (year(date())+2)
	Return(.f.)
EndIf

If Val(cAnoFab) < (year(date())-999)
	Return(.f.)
EndIf

If Val(cAnoMod) < (year(date())-999)
	Return(.f.)
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FG_POSVE4   ³ Autor ³ Renata              ³ Data ³ 24/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³posiciona no VE4                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Garantia                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_POSVE4(W_1GAR1)

W_1MAR  := &w_1Gar1
WRETURN := .F.

If FG_Seek("VE4","W_1MAR",1,.F.) = .t.
	WRETURN := .T.
EndIf

Return(WRETURN)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FG_EXICHAVG1³ Autor ³ Renata              ³ Data ³ 24/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³VerIfica se existe chave no VG1                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Garantia                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_EXICHAVG1()

Return(ExistChav("VG1",M->VG1_CODMAR+M->VG1_CODGAR,1,"EXICODGAR"))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_CODGARVGA|Autor  ³ Renata              ³ Data ³ 24/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Posiciona no VG1                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Garantia                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FG_CODGARVGA()

Return(FG_Seek("VG1","M->VGA_CODMAR+M->VGA_CODGAR",1,.F.,"VGA_DESGAR","VG1_DESGAR"))


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_AcumulaAtraso³ Autor ³ Wilson          ³ Data ³ 27.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Somar os titulos em atraso da filial                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIM010.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_AcumulaAtraso(cFilNew)

Local cSalvFil := cFilAnt, nValAtraso := 0, cAlias := Alias()
cFilAnt := cFilNew

DbSelectarea("SE1")
DbSetorder(8)
DbSeek(xFilial("SE1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI+"A")
While !Eof() .And. SE1->E1_FILIAL == xFilial("SE1") .And. ;
	E1_CLIENTE+E1_LOJA == SC5->C5_CLIENTE+SC5->C5_LOJACLI .And. SE1->E1_STATUS == "A"
	If dDataBase > SE1->E1_VENCREA
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o t¡tulo seja de qualquer natureza credora (-) o saldo  ³
		//³ deve ser abatido. Os t¡tulos tipo RA (Receb.Antecipado),      ³
		//³ NCC (Nota de Cr‚dito) e PR (Provis¢rio) n„o precisam de       ³
		//³ tratamento especial. Bops 00323-A                                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Subst(SE1->E1_TIPO,3,1) == "-"
			nValAtraso += xMoeda( SE1->E1_SALDO , SE1->E1_MOEDA , 1 )
		ElseIf .NOT. SE1->E1_TIPO $ "RA /PR /"+MV_CRNEG
			nValAtraso -= xMoeda( SE1->E1_SALDO , SE1->E1_MOEDA , 1 )
		EndIf
	EndIf
	dbSkip()
End
DbSetorder(1)

cFilAnt := cSalvFIl
If !Empty(cAlias)
	DbSelectarea(cAlias)
EndIf

Return (nValAtraso)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_LimCre³ Autor ³  Emilton              ³ Data ³ 26/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa Limite de Credito do Cliente                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_LIMCRE(cCodCli,cLojCli)
Local nLimCre := 0, nSalOsv := 0, nSalDup := 0, nValAtraso := 0, nSalvEmp

cMCusto := GetMV("MV_MCUSTO")
x := cCodCli+cLojCli

If FG_SEEK("SA1","x",1,.f.)

	DbSelectarea("SM2")                                // Posiciona moeda da data base
	DbSeek(dDataBase,.t.)
	nLimCre := xMoeda(SA1->A1_LC,    1,1,dDatabase)  // Apesar do MV_MCUSTO, estamos passando sempre a moeda 1, que 'e a local do pais
	nSalOsv := xMoeda( FG_SALOSV(cCodCli,cLojCli) ,1,1,dDataBase)
	nSalDup := xMoeda(SA1->A1_SALDUP,1,1,dDataBase)
	nLimcre := nLimCre - (nSalOsv + nSalDup)

	nValAtraso := 0
	nSalvEmp := SM0->(Recno())

	//Pega o atraso de todas as filiais

	If xFilial("SA1") == "  " .and. xFilial("SE1") != "  "

		DbSelectarea("SM0")
		DbSeek(cEmpAnt)

		While !Eof() .and. M0_CODIGO == cEmpAnt

			nValAtraso := nValAtraso + FG_AcumulaAtraso(M0_CODFIL)
			dbSkip()

		Enddo

	Else

		nValAtraso := FG_AcumulaAtraso(cFilAnt)

	EndIf

	SM0->(dbGoto(nSalvEmp))

EndIf

Return(nLimCre)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_Formula³ Autor ³ Manoel                ³ Data ³ 31/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Interpreta formula cadastrada no SM4                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_Formula(cFormula,nPos,aStru)

Local nRetVal  := 0
Local cForm    := " "
Local cAliasSv := Alias()
Local bBlock:=ErrorBlock(),bErro := ErrorBlock( { |e| FGX_CheckBug(e) } )
Local aAreaVEG:=VEG->(GetArea())
Private lRet      := .t.
Private nArrayPos := nPos
aErrAva := IIf( Type("aErrAva") == "U" , {} , Aclone( aErrAva ) )

IIf(Type("cArqPes")== "U",cArqPes := Alias(),.t.)

DbSelectArea("VEG")
DbSetOrder(1)
If DbSeek(xfilial("VEG")+cFormula)
	If "FA_LEVVAL"$VEG_FORMUL
		x := 0
	EndIf
	cForm := AllTrim(VEG_FORMUL)

	If !Empty(cArqPes)
		DbSelectArea(cArqPes)
	EndIf

	BEGIN SEQUENCE
	nRetVal := &cForm
	END SEQUENCE

	If lRet == .f.
		If nArrayPos # Nil
			If Len(aErrAva)==0 .Or. aScan(aErrAva,{|x| x[1] == aStru[nArrayPos,3].and. x[2] == aStru[nArrayPos,4]}) == 0
				aadd(aErrAva,{aStru[nArrayPos,3],aStru[nArrayPos,4],aStru[nArrayPos,5],aStru[nArrayPos,7]})
			EndIf
			nRetVal := 0
		EndIf
	EndIf

Else

	If nArrayPos # Nil
		If aStru[nArrayPos,6] # "0"  // Sintetico
			If Len(aErrAva)==0 .Or. aScan(aErrAva,{|x| x[1] == aStru[nArrayPos,3].and. x[2] == aStru[nArrayPos,4]}) == 0
				aadd(aErrAva,{aStru[nArrayPos,3],aStru[nArrayPos,4],aStru[nArrayPos,5],aStru[nArrayPos,7]})
			EndIf
		EndIf
	EndIf
	nRetVal := 0

EndIf

ErrorBlock(bBlock)

RestArea(aAreaVEG)

If !Empty(cAliasSv)
	DbSelectArea(cAliasSv)
EndIf

Return(nRetVal)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_CAMTEC ³ Autor ³  Emilton              ³ Data ³ 30/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Pesquisa Existencia de Campanha/Pendencia/Assunto           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_CAMTEC(cChassi,lDispon,lAbert,lValApl,cNumOsv,cTipoCam)

Local cSQLAlias  := "SQLVOP"
Local cQuery     := ""
Local aVetCam    := {}
Local cCodMod    := ""
Local lObrigat   := .f.
Local aCamVei    := {}
Local ni         := 1
Local lChoice    := .f.
Local cPerg      := ""
Private aTELA[0][0],aGETS[0]
Private cTitulo1 := ""
Private cTitulo2 := ""
Default lDispon  := .f.
Default lAbert   := .f.
Default lValApl  := .f.
Default cTipoCam := ""

if cTipoCam != "" .and. !(cTipoCam $ GetNewPar("MV_CHKCTEC","APSLGO"))
	If lDispon
		Return {}
	Else
		Return .t.
	Endif
endif

dbSelectArea("VV1")
dbSetOrder(2)
dbSeek(xFilial("VV1")+cChassi)
dbSelectArea("VO5")
dbSetOrder(1)
dbSeek(xFilial("VO5")+VV1->VV1_CHAINT)

cCodMod := VV1->VV1_MODVEI

//VVR => Grupo de modelo
//VV2 => Modelo
dbSelectArea("VV2")
FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)

cSelect := alias()

//verifica se tem faixa de chassi / modelo / data venda com campanha

cQuery := " SELECT * FROM ( "
cQuery += " SELECT  VOU_CHASSI, VOP_DATVEN, VOP_CODMAR, VOP_DATINI, VOP_DATFIN, VOP_ASSMEM , VOP_NUMINT , VOP_TIPPEN , VOP_DATCAM , VOP_NUMCAM  , VOP_NOMCAM , VOP_PEREXE , VOP_OBRIGA , VOP_CHAINI , VOP_CHAFIN  ,VOP_GMDINI, VOP_GMDFIN, VOP_MODINI, VOU_NUMOSV, VOP_MODFIN, (SELECT COUNT(*) FROM "+RetSQLName('VOU')+ " VOU2 WHERE VOU_FILIAL = '"+xFilial("VOU")+"' AND VOU2.VOU_NUMINT = VOP_NUMINT AND VOU2.D_E_L_E_T_ = ' ') QTD_VOUS "
cQuery += " FROM "+RetSQLName('VOP')+ " VOP "
cQuery += " LEFT JOIN "+RetSQLName('VOU')+ " VOU ON VOU.VOU_FILIAL = '"+xFilial("VOU")+"' AND VOU_NUMINT = VOP_NUMINT AND VOU.D_E_L_E_T_ = ' '  AND VOU_NUMOSV =  '   ' "
if VOU->(FieldPos("VOU_FILCAM")) > 0
	cQuery += " AND (VOU_FILCAM = '"+xFilial("SF2")+"' OR VOU_FILCAM = ' ') "
Endif
cQuery += " WHERE VOP_FILIAL='"+xFilial("VOP")+"' "
cQuery += " 	AND ( "
cQuery += " (( VOP_CHAINI=' ' AND VOP_CHAFIN=' ' ) OR ( '"+VV1->VV1_CHASSI+"' BETWEEN VOP_CHAINI AND VOP_CHAFIN ) OR ( '"+VV1->VV1_CHARED+"' BETWEEN VOP_CHAINI AND VOP_CHAFIN)) "
cQuery += " AND "
cQuery += " 		(( VOP_MODINI=' ' AND VOP_MODFIN=' ' ) OR ( '"+cCodMod+"' BETWEEN VOP_MODINI AND VOP_MODFIN))"
cQuery += " 		AND "
cQuery += " 		((VOP_GMDINI =' ' AND VOP_GMDFIN=' ') OR ( '"+VV2->VV2_GRUMOD+"' BETWEEN VOP_GMDINI AND VOP_GMDFIN)) ) "
If !Empty(VO5->VO5_DATVEN)
	cQuery += " AND ( ( VOP_DATINI=' ' AND VOP_DATFIN=' ' ) OR ('"+dtos(VO5->VO5_DATVEN)+"' BETWEEN VOP_DATINI AND VOP_DATFIN) ) "
Endif
cQuery += " AND ( VOP_DATVEN=' ' OR VOP_DATVEN>='"+dtos(dDataBase)+"' )      AND VOP_CODMAR='"+VV1->VV1_CODMAR+" ' AND VOP.D_E_L_E_T_=' ' "
cQuery += " ) TB "
cQuery += " WHERE ( QTD_VOUS = 0 OR VOU_CHASSI IN ('"+VV1->VV1_CHARED+"','"+VV1->VV1_CHASSI+"') ) "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
While !(cSQLAlias)->(Eof())

	aAdd(aCamVei,{(cSQLAlias)->(VOP_ASSMEM),(cSQLAlias)->(VOP_NUMINT),(cSQLAlias)->(VOP_TIPPEN),stod((cSQLAlias)->(VOP_DATCAM)),(cSQLAlias)->(VOP_NUMCAM),stod((cSQLAlias)->(VOP_DATVEN)),(cSQLAlias)->(VOP_NOMCAM),(cSQLAlias)->(VOP_PEREXE),(cSQLAlias)->(VOP_OBRIGA),(cSQLAlias)->(VOP_CHAINI),(cSQLAlias)->(VOP_CHAFIN), Iif(Empty( (cSQLAlias)->(VOU_CHASSI)), VV1->VV1_CHASSI, (cSQLAlias)->(VOU_CHASSI) ) })
	(cSQLAlias)->(dbSkip())

EndDo
(cSQLAlias)->(dbCloseArea())
DbSelectArea("VOP")

aSort(aCamVei,,,{|x,y| x[3]+x[2] < y[3]+y[2] })

For ni := 1 to len(aCamVei) // Mostrar todas as campanhas/pendencias

	If lDispon
		aAdd(aVetCam,{.f.,IIf(aCamVei[ni,3]=="1",STR0152,IIf(aCamVei[ni,3]=="2",STR0153,STR0154)),aCamVei[ni,5],aCamVei[ni,7],aCamVei[ni,4],aCamVei[ni,6],aCamVei[ni,8],aCamVei[ni,2],aCamVei[ni,12]})
	EndIf
	Do Case
		Case aCamVei[ni,3] == "1"

			cTitulo1 := STR0004      // "Veiculo possui CAMPANHA TECNICA"
			cTitulo2 := STR0005      // "Deseja visualizar dados da CAMPANHA TECNICA ?"

			If aCamVei[ni,9] == "1"
				lObrigat := .t.
			EndIf

		Case aCamVei[ni,3] == "3"
			cTitulo1 := STR0006      // "Veiculo possui PENDENCIA TECNICA"
			cTitulo2 := STR0007      // "Deseja visualizar dados de PENDENCIA TECNICA ?"
		Case aCamVei[ni,3] == "2"
			cTitulo1 := STR0008      // "Veiculo possui ASSUNTO TECNICO"
			cTitulo2 := STR0009      // "Deseja visualizar dados de ASSUNTO TECNICO ?"
	EndCase

	If !lChoice .or. !(cPerg $ aCamVei[ni,3])
		cPerg += aCamVei[ni,3]
		lChoice := MsgYesNo((cTitulo2)+ CHR(13)+ CHR(10)+ CHR(13)+ CHR(10)+aCamVei[ni,7],(cTitulo1))
	EndIf

	If lChoice

		cAssMem := MSMM(aCamVei[ni,1],TamSx3("VOP_ASSCAM")[1])
		cAssMem := aCamVei[ni,7] + CHR(13)+CHR(10)+ CHR(13)+CHR(10)+ cAssMem
		DEFINE MSDIALOG odlgcampanha TITLE (strzero(ni,3)+"/"+strzero(len(aCamVei),3)+" - "+STR0010) From 15,15 to 33,80 of oMainWnd		// "Campanha/Pendencia/Assunto Tecnico"
		@ 09,002 TO 030,050 LABEL "" OF odlgcampanha PIXEL COLOR CLR_BLUE     // ""
		@ 17,014 say (strzero(ni,3)+" / "+strzero(len(aCamVei),3)) OF odlgcampanha PIXEL COLOR CLR_RED // "Nro/Total"
		@ 09,050 TO 030,256 LABEL "" OF odlgcampanha PIXEL COLOR CLR_BLUE     // ""
		@ 17,100 say (STR0012+" "+UPPER(X3COMBO("VOP_TIPPEN",aCamVei[ni,3]))) OF odlgcampanha PIXEL COLOR CLR_BLUE           			// "Tipo Pendencia"
		@ 37,020 say STR0013 OF odlgcampanha PIXEL COLOR CLR_BLUE           			//  "Data Campanha:"
		@ 36,061 msget aCamVei[ni,4] picture "@!" OF odlgcampanha PIXEL COLOR CLR_BLACK when .f.
		@ 37,128 say STR0011 OF odlgcampanha PIXEL COLOR CLR_BLUE     			      //  "Nro Interno"
		@ 36,171 msget aCamVei[ni,2] picture PesqPict("VOP","VOP_NUMINT") OF odlgcampanha PIXEL COLOR CLR_BLACK when .f.
		@ 57,020 say STR0015 OF odlgcampanha PIXEL COLOR CLR_BLUE           			// "Data Vencto  "
		@ 56,061 msget aCamVei[ni,6] picture "@D" OF odlgcampanha PIXEL COLOR CLR_BLACK when .f.
		@ 57,128 say STR0014 OF odlgcampanha PIXEL COLOR CLR_BLUE           			// "Nro Campanha "
		@ 56,171 msget aCamVei[ni,5] picture "@!" OF odlgcampanha PIXEL COLOR CLR_BLACK when .f.
		@ 69,002 TO 135,256 LABEL STR0016 OF odlgcampanha PIXEL COLOR CLR_BLUE     // "Descritivo"
		@ 77,004 get cAssMem OF odlgcampanha MEMO size 250,055 PIXEL READONLY
		ACTIVATE MSDIALOG odlgcampanha ON INIT EnchoiceBar(odlgcampanha,{|| nOpca := 1,odlgcampanha:End()},{|| nOpca := 0,odlgcampanha:End()})

	EndIf

Next

If !Empty(cSelect)
	dbSelectArea(cSelect)
EndIf

&& Liberacao
If lDispon

	If lObrigat .And. lValApl

		For ni := 1 to len(aCamVei)

			If aCamVei[ni,9] == "1"

				lValApl := FS_VALCAMAPL(cNumOsv,aCamVei[ni,5])

				If !lValApl
					MSGSTOP(STR0291 +" "+aCamVei[ni,5]+" "+STR0292)
				EndIf

			EndIf

		Next

	Else
		lValApl := .t.
	EndIf

	Return aVetCam
EndIf

&& Abertura
If lObrigat
	If lAbert
		Return( MsgYesNo((STR0293),(STR0294)) )
	Endif
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALCAMAPL ³ Autor ³  Emilton          ³ Data ³ 16/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa Existencia de Campanha/Pendencia/Assunto          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALCAMAPL(cNumOsv,cCodCam)
Local aArea := {}
aArea := sGetArea(aArea,"VO2")
aArea := sGetArea(aArea,"VO3")
aArea := sGetArea(aArea,"VO4")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf

DbSelectArea("VO2")
DbSetOrder(1)
DbSeek( xFilial("VO2") + cNumOsv )
Do While !Eof() .And. VO2->VO2_FILIAL+VO2->VO2_NUMOSV == xFilial("VO2") + cNumOsv
	DbSelectArea("VO3")
	DbSetOrder(1)
	DbSeek( xFilial("VO3") + VO2->VO2_NOSNUM )
	Do While !Eof() .And. VO3->VO3_FILIAL+VO3->VO3_NOSNUM == xFilial("VO3") + VO2->VO2_NOSNUM
		If VO3->VO3_CODCAM == cCodCam
			sRestArea(aArea)
			Return(.t.)
		EndIf
		DbSelectArea("VO3")
		DbSkip()
	EndDo
	DbSelectArea("VO4")
	DbSetOrder(1)
	DbSeek( xFilial("VO4") + VO2->VO2_NOSNUM )
	Do While !Eof() .And. VO4->VO4_FILIAL+VO4->VO4_NOSNUM == xFilial("VO4") + VO2->VO2_NOSNUM
		If VO4->VO4_CODCAM == cCodCam
			sRestArea(aArea)
			Return(.t.)
		EndIf
		DbSelectArea("VO4")
		DbSkip()
	EndDo
	DbSelectArea("VO2")
	DbSkip()
EndDo
sRestArea(aArea)
Return(.f.)



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_WHENVG5  ³ Autor ³ Renata                ³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz when de alguns cpos da do VG5                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FG_WhenVG5(Arg)

wReturn := .f.

Do case
	case Arg == "ITE"
		If !empty(M->VG5_GRUITE)
			wReturn := .t.
		EndIf
EndCase

Return(wReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_PLAREV³ Autor ³ Andre Luis Almeida    ³ Data ³ 03/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza o Plano de Revisao do Veiculo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cChaInt  = Chassi Interno do Veiculo                       ³±±
±±³          ³ nKMAtual = KM atual do veiculo                             ³±±
±±³          ³ nOpc     = nOpc da rotina                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Concessionaria                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PLAREV(cChaInt,nKMAtual,nOpc)
Local lOk     := .f.
Local ni      := 0
Local nTam    := 0
Local cNumOSV := ""
Local cPlaRev := ""
Local aInconv := {}
Local aPlaRev := {}
Local aReturn := {}
Local nCntFor := 1
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cQuery    := ""
Local cQAlSQL   := "SQLPLAREV"
Local lGruMod   := ( VAJ->(FieldPos("VAJ_GRUMOD")) > 0 )
Local lChassi   := ( VST->(FieldPos("VST_CHASSI")) > 0 )
Local aRetVlr   := {}
Local nVlTotal  := 0
Local nVlPec    := 0
Local nVlSrv    := 0
Local cTpTem    := ""
Local cTpTemS   := ""
Local cFormu    := ""
Local cCdCli    := ""
Local cLjCli    := ""
Local lVS1_TIPTSV := ( VS1->(FieldPos("VS1_TIPTSV")) > 0 )
Private oLbNo   := LoadBitmap( GetResources() , "LBNO" )   // Sem Tik
Private oLbTik  := LoadBitmap( GetResources() , "LBTIK" )  // Com Tik
Private oVerd   := LoadBitmap( GetResources() , "BR_VERDE" )  // Plano de Revisao dentro da Faixa de KM e Dias
Private oBran   := LoadBitmap( GetResources() , "BR_BRANCO" ) // Planos de Revisao fora da Faxa de KM ou Dias
Private aBotPlaRev := {}
Default cChaInt  := ""
Default nKMAtual := 0
Default nOpc     := 2
If Empty(cChaInt)
	Return(aClone(aReturn))
EndIf
If VST->(FieldPos("VST_CHASSI")) > 0
	AADD(aBotPlaRev, {"EDITABLE" ,{|| FS_PLAREVE(nOpc,@aPlaRev,@aInconv,VV1->VV1_CHASSI) },( STR0390 )} ) // Registra Revisão EXTERNA
EndIf
VV1->(DbSetOrder(1))
VV1->(DbSeek(xFilial("VV1")+cChaInt))
FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
If VV1->(FieldPos("VV1_PLAREV")) > 0
	If !Empty(VV1->VV1_PLAREV)
		cPlaRev := VV1->VV1_PLAREV // Plano de Revisao pelo Veiculo
	Else
		If !Empty(VV2->VV2_PLAREV)
			cPlaRev := VV2->VV2_PLAREV // Plano de Revisao pelo Modelo
		EndIf
	EndIf
EndIf
//////////////////////
// Plano de Revisao //
//////////////////////
If Empty(cPlaRev) // Inconvenientes de Revisao
	cQuery := "SELECT DISTINCT VSK.VSK_CODGRU , VSK.VSK_DESGRU , VSL.VSL_CODMAR , VSL.VSL_CODINC , VSL.VSL_DESINC , VSL.VSL_PERINI , VSL.VSL_PERFIN , VSL.VSL_KILOME , VSL.VSL_KILFIN , VSL.VSL_TIPTEM , VSL.VSL_TIPTSV "
	cQuery += "FROM "+RetSqlName("VSL")+" VSL "
	cQuery += "JOIN "+RetSqlName("VSK")+" VSK ON ( VSK.VSK_FILIAL='"+xFilial("VSK")+"' AND VSK.VSK_CODMAR=VSL.VSL_CODMAR AND VSK.VSK_CODGRU=VSL.VSL_CODGRU AND VSK.D_E_L_E_T_=' ' ) "
	cQuery += "JOIN "+RetSqlName("VAJ")+" VAJ ON ( VAJ.VAJ_FILIAL='"+xFilial("VAJ")+"' AND VAJ.VAJ_CODMAR=VSL.VSL_CODMAR AND VAJ.VAJ_CODGRU=VSL.VSL_CODGRU AND VAJ.VAJ_CODINC=VSL.VSL_CODINC AND VAJ.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VSL.VSL_FILIAL='"+xFilial("VSL")+"' AND (VSL.VSL_CODMAR='"+VV1->VV1_CODMAR+"' OR VSL.VSL_CODMAR = ' ') AND "
	If lGruMod
		cQuery += "( VAJ.VAJ_CODMOD=' ' OR VAJ.VAJ_CODMOD='"+Alltrim(VV1->VV1_MODVEI)+"' ) AND ( VAJ.VAJ_GRUMOD=' ' OR VAJ.VAJ_GRUMOD='"+Alltrim(VV2->VV2_GRUMOD)+"' ) AND ( VAJ.VAJ_CODSEG=' ' OR VAJ.VAJ_CODSEG='"+Alltrim(VV2->VV2_SEGMOD)+"' ) AND "
	Else
		cQuery += "( VAJ.VAJ_CODMOD=' ' OR VAJ.VAJ_CODMOD='"+Alltrim(VV1->VV1_MODVEI)+"' ) AND ( VAJ.VAJ_CODSEG=' ' OR VAJ.VAJ_CODSEG='"+Alltrim(VV2->VV2_SEGMOD)+"' ) AND "
	EndIf
	cQuery += "VSL.VSL_TIPO<>'1' AND VSL.D_E_L_E_T_=' '"
Else // Cadastro de Plano de Revisao com Inconvenientes de Revisao
	cQuery := "SELECT DISTINCT VSK.VSK_CODGRU , VSK.VSK_DESGRU , VSL.VSL_CODMAR , VSL.VSL_CODINC , VSL.VSL_DESINC , VSL.VSL_PERINI , VSL.VSL_PERFIN , VSL.VSL_KILOME , VSL.VSL_KILFIN , VSL.VSL_TIPTEM , VSL.VSL_TIPTSV "
	cQuery += "FROM "+RetSqlName("VF1")+" VF1 "
	cQuery += "JOIN "+RetSqlName("VSL")+" VSL ON ( VSL.VSL_FILIAL='"+xFilial("VSL")+"' AND VSL.VSL_CODMAR=VF1.VF1_CODMAR AND VSL.VSL_CODGRU=VF1.VF1_CODGRU AND VSL.VSL_CODINC=VF1.VF1_CODINC AND VSL.VSL_TIPO<>'1' AND VSL.D_E_L_E_T_=' ' ) "
	cQuery += "JOIN "+RetSqlName("VSK")+" VSK ON ( VSK.VSK_FILIAL='"+xFilial("VSK")+"' AND VSK.VSK_CODMAR=VSL.VSL_CODMAR AND VSK.VSK_CODGRU=VSL.VSL_CODGRU AND VSK.D_E_L_E_T_=' ' ) "
	cQuery += "JOIN "+RetSqlName("VAJ")+" VAJ ON ( VAJ.VAJ_FILIAL='"+xFilial("VAJ")+"' AND VAJ.VAJ_CODMAR=VSL.VSL_CODMAR AND VAJ.VAJ_CODGRU=VSL.VSL_CODGRU AND VAJ.VAJ_CODINC=VSL.VSL_CODINC AND VAJ.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VF1.VF1_FILIAL='"+xFilial("VF1")+"' AND (VF1.VF1_CODMAR='"+VV1->VV1_CODMAR+"' OR VF1.VF1_CODMAR = ' ') AND VF1.VF1_CODPLA='"+cPlaRev+"' AND VF1.D_E_L_E_T_=' ' AND "
	If lGruMod
		cQuery += "( VAJ.VAJ_CODMOD=' ' OR VAJ.VAJ_CODMOD='"+Alltrim(VV1->VV1_MODVEI)+"' ) AND ( VAJ.VAJ_GRUMOD=' ' OR VAJ.VAJ_GRUMOD='"+Alltrim(VV2->VV2_GRUMOD)+"' ) AND ( VAJ.VAJ_CODSEG=' ' OR VAJ.VAJ_CODSEG='"+Alltrim(VV2->VV2_SEGMOD)+"' )"
	Else
		cQuery += "( VAJ.VAJ_CODMOD=' ' OR VAJ.VAJ_CODMOD='"+Alltrim(VV1->VV1_MODVEI)+"' ) AND ( VAJ.VAJ_CODSEG=' ' OR VAJ.VAJ_CODSEG='"+Alltrim(VV2->VV2_SEGMOD)+"' )"
	EndIf
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	lDias := .f.
	lKMs  := .f.
	If Empty(VV1->VV1_DATVEN)
		lDias := .t.
	Else
		// Verifica se Inconveniente esta dentro da Faixa de Dias pela Data da Venda //
		If dDataBase >= (VV1->VV1_DATVEN + ( cQAlSQL )->( VSL_PERINI )) .and. dDataBase <= (VV1->VV1_DATVEN + ( cQAlSQL )->( VSL_PERFIN ))
			lDias := .t.
		EndIf
	EndIf
	// Verifica se Inconveniente esta dentro da Faixa de KM //
	If nKMAtual >= ( cQAlSQL )->( VSL_KILOME ) .and. nKMAtual <= ( cQAlSQL )->( VSL_KILFIN )
		lKMs  := .t.
	EndIf
	// Verifica se o Plano de Revisao ja foi realizado ( Numero da OS ) para o Veiculo //
	cNumOSV := ""
	If lChassi
		cQuery := "SELECT VST.VST_CODIGO FROM "+RetSqlName("VST")+" VST WHERE "
		cQuery += "VST.VST_CHASSI='"+VV1->VV1_CHASSI+"' AND VST.VST_CODMAR='"+( cQAlSQL )->( VSL_CODMAR )+"' AND "
		cQuery += "VST.VST_GRUINC='"+( cQAlSQL )->( VSK_CODGRU )+"' AND VST.VST_CODINC='"+( cQAlSQL )->( VSL_CODINC )+"' AND "
		cQuery += "( VST.VST_CODIGO IN ( SELECT VO1_NUMOSV FROM "+RetSqlName("VO1")+" VO1 WHERE VO1.VO1_FILIAL=VST.VST_FILIAL AND VO1.VO1_NUMOSV=VST.VST_CODIGO AND VO1.VO1_STATUS<>'C' AND VO1.D_E_L_E_T_=' ' ) "
		cQuery += " OR VST.VST_CODIGO='"+PadR(STR0391,TamSX3("VST_CODIGO")[1])+"' ) AND "
		cQuery += "VST.VST_TIPO='2' AND VST.D_E_L_E_T_=' ' ORDER BY VST.R_E_C_N_O_ DESC"
		cNumOSV := FM_SQL(cQuery)
	EndIf
	cTpTem  := ( cQAlSQL )->( VSL_TIPTEM )
	cTpTemS := ( cQAlSQL )->( VSL_TIPTSV )
	cFormu  := ""
	cCdCli  := ""
	cLjCli  := ""
	If FM_PILHA("OFIXX001") // Orcamento Fases
		If !Empty(M->VS1_TIPTEM)
			cTpTem := M->VS1_TIPTEM
		EndIf
		If lVS1_TIPTSV .and. !Empty(M->VS1_TIPTSV)
			cTpTemS := M->VS1_TIPTSV
		Else
			cTpTemS := cTpTem
		EndIf
		If !Empty(M->VS1_FORMUL)
			cFormu := M->VS1_FORMUL
		EndIf
		cCdCli := M->VS1_CLIFAT
		cLjCli := M->VS1_LOJA
	ElseIf FM_PILHA("OFIOM350") // Agendamento
		cCdCli := M->VSO_PROVEI
		cLjCli := M->VSO_LOJPRO
	EndIf
	If Empty(cFormu)
		VOI->(DbSetOrder(1))
		VOI->(MsSeek( xFilial("VOI") + cTpTem ))
		cFormu := VOI->VOI_VALPEC
	EndIf
	nVlPec  := 0
	nVlSrv  := 0
	aRetVlr := OFIOM420(( cQAlSQL )->( VSK_CODGRU ),( cQAlSQL )->( VSL_CODINC ),cChaInt,nKMAtual,cTpTem,,,cTpTemS,.t.,.t.,cFormu,cCdCli,cLjCli,.f.)
	If len(aRetVlr) > 0
		For ni := 1 to len(aRetVlr[1])
			nVlPec += aRetVlr[1,ni,7] // Valor de Pecas
		Next
		For ni := 1 to len(aRetVlr[2])
			nVlSrv += aRetVlr[2,ni,8] // Valor de Servicos
		Next
	EndIf
	aAdd(aPlaRev,{.f.,IIf(lDias.and.lKMs,"verd","bran"),( cQAlSQL )->( VSK_CODGRU ),( cQAlSQL )->( VSK_DESGRU ),( cQAlSQL )->( VSL_CODINC ),( cQAlSQL )->( VSL_DESINC ),cNumOSV,nVlPec,nVlSrv,( cQAlSQL )->( VSL_CODMAR )})
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
If len(aPlaRev) <= 0
	aAdd(aPlaRev,{.f.,"bran","","","","","",0,0,""})
EndIf
//////////////////////
// Inconvenientes   //
//////////////////////
cQuery := "SELECT DISTINCT VSK.VSK_CODGRU , VSK.VSK_DESGRU , VSL.VSL_CODMAR , VSL.VSL_CODINC , VSL.VSL_DESINC , VSL.VSL_PERINI , VSL.VSL_PERFIN , VSL.VSL_KILOME , VSL.VSL_KILFIN , VSL.VSL_TIPTEM , VSL.VSL_TIPTSV "
cQuery += "FROM "+RetSqlName("VSL")+" VSL "
cQuery += "JOIN "+RetSqlName("VSK")+" VSK ON ( VSK.VSK_FILIAL='"+xFilial("VSK")+"' AND VSK.VSK_CODMAR=VSL.VSL_CODMAR AND VSK.VSK_CODGRU=VSL.VSL_CODGRU AND VSK.D_E_L_E_T_=' ' ) "
cQuery += "JOIN "+RetSqlName("VAJ")+" VAJ ON ( VAJ.VAJ_FILIAL='"+xFilial("VAJ")+"' AND VAJ.VAJ_CODMAR=VSL.VSL_CODMAR AND VAJ.VAJ_CODGRU=VSL.VSL_CODGRU AND VAJ.VAJ_CODINC=VSL.VSL_CODINC AND VAJ.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VSL.VSL_FILIAL='"+xFilial("VSL")+"' AND (VSL.VSL_CODMAR='"+VV1->VV1_CODMAR+"' OR VSL.VSL_CODMAR = ' ') AND "
If lGruMod
	cQuery += "( VAJ.VAJ_CODMOD=' ' OR VAJ.VAJ_CODMOD='"+Alltrim(VV1->VV1_MODVEI)+"' ) AND ( VAJ.VAJ_GRUMOD=' ' OR VAJ.VAJ_GRUMOD='"+Alltrim(VV2->VV2_GRUMOD)+"' ) AND ( VAJ.VAJ_CODSEG=' ' OR VAJ.VAJ_CODSEG='"+Alltrim(VV2->VV2_SEGMOD)+"' ) AND "
Else
	cQuery += "( VAJ.VAJ_CODMOD=' ' OR VAJ.VAJ_CODMOD='"+Alltrim(VV1->VV1_MODVEI)+"' ) AND ( VAJ.VAJ_CODSEG=' ' OR VAJ.VAJ_CODSEG='"+Alltrim(VV2->VV2_SEGMOD)+"' ) AND "
EndIf
cQuery += "VSL.VSL_TIPO='1' AND VSL.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	lDias := .f.
	lKMs  := .f.
	If Empty(VV1->VV1_DATVEN)
		lDias := .t.
	Else
		// Verifica se Inconveniente esta dentro da Faixa de Dias pela Data da Venda //
		If dDataBase >= (VV1->VV1_DATVEN + ( cQAlSQL )->( VSL_PERINI )) .and. dDataBase <= (VV1->VV1_DATVEN + ( cQAlSQL )->( VSL_PERFIN ))
			lDias := .t.
		EndIf
	EndIf
	// Verifica se Inconveniente esta dentro da Faixa de KM //
	If nKMAtual >= ( cQAlSQL )->( VSL_KILOME ) .and. nKMAtual <= ( cQAlSQL )->( VSL_KILFIN )
		lKMs  := .t.
	EndIf
	// Verifica se o Inconveniente ja foi realizado ( Numero da OS ) para o Veiculo //
	cNumOSV := ""
	If lChassi
		cQuery := "SELECT VST.VST_CODIGO FROM "+RetSqlName("VST")+" VST WHERE "
		cQuery += "VST.VST_CHASSI='"+VV1->VV1_CHASSI+"' AND VST.VST_CODMAR='"+( cQAlSQL )->( VSL_CODMAR )+"' AND "
		cQuery += "VST.VST_GRUINC='"+( cQAlSQL )->( VSK_CODGRU )+"' AND VST.VST_CODINC='"+( cQAlSQL )->( VSL_CODINC )+"' AND "
		cQuery += "( VST.VST_CODIGO IN ( SELECT VO1_NUMOSV FROM "+RetSqlName("VO1")+" VO1 WHERE VO1.VO1_FILIAL=VST.VST_FILIAL AND VO1.VO1_NUMOSV=VST.VST_CODIGO AND VO1.VO1_STATUS<>'C' AND VO1.D_E_L_E_T_=' ' ) "
		cQuery += " OR VST.VST_CODIGO='"+PadR(STR0391,TamSX3("VST_CODIGO")[1])+"' ) AND "
		cQuery += "VST.VST_TIPO='2' AND VST.D_E_L_E_T_=' ' ORDER BY VST.R_E_C_N_O_ DESC"
		cNumOSV := FM_SQL(cQuery)
	EndIf
	cTpTem  := ( cQAlSQL )->( VSL_TIPTEM )
	cTpTemS := ( cQAlSQL )->( VSL_TIPTSV )
	cFormu  := ""
	cCdCli  := ""
	cLjCli  := ""
	If FM_PILHA("OFIXX001") // Orcamento Fases
		If !Empty(M->VS1_TIPTEM)
			cTpTem := M->VS1_TIPTEM
		EndIf
		If lVS1_TIPTSV .and. !Empty(M->VS1_TIPTSV)
			cTpTemS := M->VS1_TIPTSV
		Else
			cTpTemS := cTpTem
		EndIf
		If !Empty(M->VS1_FORMUL)
			cFormu := M->VS1_FORMUL
		EndIf
		cCdCli := M->VS1_CLIFAT
		cLjCli := M->VS1_LOJA
	ElseIf FM_PILHA("OFIOM350") // Agendamento
		cCdCli := M->VSO_PROVEI
		cLjCli := M->VSO_LOJPRO
	EndIf
	If Empty(cFormu)
		VOI->(DbSetOrder(1))
		VOI->(MsSeek( xFilial("VOI") + cTpTem ))
		cFormu := VOI->VOI_VALPEC
	EndIf
	nVlPec  := 0
	nVlSrv  := 0
	aRetVlr := OFIOM420(( cQAlSQL )->( VSK_CODGRU ),( cQAlSQL )->( VSL_CODINC ),cChaInt,nKMAtual,cTpTem,,,cTpTemS,.t.,.t.,cFormu,cCdCli,cLjCli,.f.)
	If len(aRetVlr) > 0
		For ni := 1 to len(aRetVlr[1])
			If ValType(aRetVlr[1,ni,7]) == "N"
				nVlPec += aRetVlr[1,ni,7] // Valor de Pecas
			EndIf
		Next
		For ni := 1 to len(aRetVlr[2])
			If ValType(aRetVlr[2,ni,8]) == "N"
				nVlSrv += aRetVlr[2,ni,8] // Valor de Servicos
			EndIf
		Next
	EndIf
	aAdd(aInconv,{.f.,IIf(lDias.and.lKMs,"verd","bran"),( cQAlSQL )->( VSK_CODGRU ),( cQAlSQL )->( VSK_DESGRU ),( cQAlSQL )->( VSL_CODINC ),( cQAlSQL )->( VSL_DESINC ),cNumOSV,nVlPec,nVlSrv,( cQAlSQL )->( VSL_CODMAR )})
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
DbSelectArea("VV1")
If len(aInconv) <= 0
	aAdd(aInconv,{.f.,"bran","","","","","",0,0,""})
EndIf
// Fator de reducao 90%
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.9)
Next
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
aAdd( aObjects, { 0 ,  20 , .T. , .F. } ) // Topo - Dados do Veiculo
AAdd( aObjects, { 0 , 100 , .T. , .T. } ) // ListBox - Plano Revisao
AAdd( aObjects, { 0 , 100 , .T. , .T. } ) // ListBox - Inconvenientes
aAdd( aObjects, { 0 ,  09 , .T. , .F. } ) // Rodape - Legenda
aPos := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlgPlaRev TITLE STR0023 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Plano de Revisao / Inconvenientes
//////////////////////
// Dados do Veiculo //
//////////////////////
@ aPos[1,1]+000,aPos[1,2] TO aPos[1,3],aPos[1,4]+1 LABEL STR0046 OF oDlgPlaRev PIXEL // Dados do Veiculo
@ aPos[1,1]+009,aPos[1,2]+004 SAY (Alltrim(VV1->VV1_CHASSI)+" - "+VV1->VV1_CODMAR+" "+VV2->VV2_DESMOD) SIZE 450,8 OF oDlgPlaRev PIXEL COLOR CLR_BLUE
//////////////////////
// Plano de Revisao //
//////////////////////
@ aPos[2,1]+000,aPos[2,2] TO aPos[2,3],aPos[2,4]+1 LABEL STR0378 OF oDlgPlaRev PIXEL
@ aPos[2,1]+007,aPos[2,2] LISTBOX oLbPlaRev FIELDS HEADER "","",STR0082,STR0202,STR0375,STR0202,STR0389,STR0385,STR0240,STR0342 COLSIZES 10,10,20,60,60,60,25,45,45,45 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1]-5 OF oDlgPlaRev PIXEL ON DBLCLICK FS_TKPLAREV(nOpc,1,oLbPlaRev:nAt,@nVlTotal,@aPlaRev,@aInconv)
oLbPlaRev:SetArray(aPlaRev)
oLbPlaRev:bLine := { || { IIf(aPlaRev[oLbPlaRev:nAt,1],oLbTik,oLbNo) , IIf(aPlaRev[oLbPlaRev:nAt,2]=="verd",oVerd,oBran) , aPlaRev[oLbPlaRev:nAt,3] , aPlaRev[oLbPlaRev:nAt,4] , aPlaRev[oLbPlaRev:nAt,5] , aPlaRev[oLbPlaRev:nAt,6] , aPlaRev[oLbPlaRev:nAt,7] ,;
							FG_AlinVlrs(Transform(aPlaRev[oLbPlaRev:nAt,8],"@E 99,999,999.99")) , FG_AlinVlrs(Transform(aPlaRev[oLbPlaRev:nAt,9],"@E 99,999,999.99")) , FG_AlinVlrs(Transform(aPlaRev[oLbPlaRev:nAt,8]+aPlaRev[oLbPlaRev:nAt,9],"@E 99,999,999.99")) }}
//////////////////////
// Inconvenientes   //
//////////////////////
@ aPos[3,1]+000,aPos[3,2] TO aPos[3,3],aPos[3,4]+1 LABEL STR0379 OF oDlgPlaRev PIXEL
@ aPos[3,1]+007,aPos[3,2] LISTBOX oLbInconv FIELDS HEADER "","",STR0082,STR0202,STR0375,STR0202,STR0389,STR0385,STR0240,STR0342 COLSIZES 10,10,20,60,60,60,25,45,45,45 SIZE aPos[3,4]-2,aPos[3,3]-aPos[3,1]-5 OF oDlgPlaRev PIXEL ON DBLCLICK FS_TKPLAREV(nOpc,2,oLbInconv:nAt,@nVlTotal,@aPlaRev,@aInconv)
oLbInconv:SetArray(aInconv)
oLbInconv:bLine := { || { IIf(aInconv[oLbInconv:nAt,1],oLbTik,oLbNo) , IIf(aInconv[oLbInconv:nAt,2]=="verd",oVerd,oBran) , aInconv[oLbInconv:nAt,3] , aInconv[oLbInconv:nAt,4] , aInconv[oLbInconv:nAt,5] , aInconv[oLbInconv:nAt,6] , aInconv[oLbInconv:nAt,7] ,;
							FG_AlinVlrs(Transform(aInconv[oLbInconv:nAt,8],"@E 99,999,999.99")) , FG_AlinVlrs(Transform(aInconv[oLbInconv:nAt,9],"@E 99,999,999.99")) , FG_AlinVlrs(Transform(aInconv[oLbInconv:nAt,8]+aInconv[oLbInconv:nAt,9],"@E 99,999,999.99")) }}
//////////////////////
// Rodape - Legenda //
//////////////////////
nTam := (aPos[4,4]/2.5)
@ aPos[4,1]+002,(nTam*0)+005 BITMAP oxBran RESOURCE "BR_BRANCO" OF oDlgPlaRev NOBORDER SIZE 10,10 WHEN .f. PIXEL
@ aPos[4,1]+002,(nTam*0)+015 SAY STR0376 SIZE 150,8 OF oDlgPlaRev PIXEL COLOR CLR_BLUE // Inconveniente fora da faixa de KM e/ou dias
@ aPos[4,1]+002,(nTam*1)+005 BITMAP oxVerd RESOURCE "BR_VERDE" OF oDlgPlaRev NOBORDER SIZE 10,10 WHEN .f. PIXEL
@ aPos[4,1]+002,(nTam*1)+015 SAY STR0377 SIZE 150,8 OF oDlgPlaRev PIXEL COLOR CLR_BLUE // Inconveniente dentro da faixa de KM e dias
@ aPos[4,1]+002,(aPos[4,4]-083) SAY STR0342 SIZE 50,8 OF oDlgPlaRev PIXEL COLOR CLR_BLUE // Total
@ aPos[4,1]+001,(aPos[4,4]-060) MSGET oVlTotal VAR nVlTotal PICTURE "@E 9,999,999.99" OF oDlgPlaRev SIZE 60,08 WHEN .f. PIXEL
ACTIVATE MSDIALOG oDlgPlaRev CENTER ON INIT EnchoiceBar(oDlgPlaRev,{|| lOk := .t. , oDlgPlaRev:End()},{|| oDlgPlaRev:End()},,aBotPlaRev)

If lOk
	//////////////////////
	// Plano de Revisao //
	//////////////////////
	For ni := 1 to len(aPlaRev)
		If aPlaRev[ni,1]
			aadd(aReturn,{aPlaRev[ni,3],aPlaRev[ni,5],aPlaRev[ni,6]}) // { Grupo , Codigo , Descricao Inconveniente }
		EndIf
	Next
	//////////////////////
	// Inconvenientes   //
	//////////////////////
	For ni := 1 to len(aInconv)
		If aInconv[ni,1]
			aadd(aReturn,{aInconv[ni,3],aInconv[ni,5],aInconv[ni,6]}) // { Grupo , Codigo , Descricao Inconveniente }
		EndIf
	Next
EndIf
Return(aClone(aReturn))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PLAREVE ³ Autor ³ Andre Luis Almeida  ³ Data ³ 09/03/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Insere Plano de Revisao realizado EXTERNAMENTE             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ nOpc     = nOpc da rotina                                  ³±±
±±³          ³ aPlaRev  = Vetor dos Planos de Revisao                     ³±±
±±³          ³ aInconv  = Vetor dos Inconvenientes                        ³±±
±±³          ³ cChassi  = Chassi do Veiculo                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FG_PLAREV ( Plano de Revisao )                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PLAREVE(nOpc,aPlaRev,aInconv,cChassi)
Local ni := 0
Local cQuery  := ""
Local cNumOSV := ""
Local lChassi := ( VST->(FieldPos("VST_CHASSI")) > 0 )
If nOpc == 3 .or. nOpc == 4 // Inclusao ou Alteracao
	For ni := 1 to len(aPlaRev)
		If aPlaRev[ni,1]
			If Alltrim(aPlaRev[ni,7]) <> Alltrim(Alltrim(PadR(STR0391,TamSX3("VST_CODIGO")[1])))
				If MsgYesNo(STR0392+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Confirma que o Plano de Revisao foi realizado em outra Concessionaria?
					STR0082+": "+Alltrim(aPlaRev[ni,3])+" - "+Alltrim(aPlaRev[ni,4])+CHR(13)+CHR(10)+;
					STR0375+": "+Alltrim(aPlaRev[ni,5])+" - "+Alltrim(aPlaRev[ni,6]),STR0002) // Atencao
					aPlaRev[ni,7] := STR0391 // EXTERNA
					DbSelectArea("VST")
					RecLock("VST",.t.)
						VST->VST_FILIAL := xFilial("VST")
						VST->VST_TIPO   := "2" // OS
						VST->VST_CODIGO := aPlaRev[ni,7] // EXTERNA
						VST->VST_CODMAR := aPlaRev[ni,10]
						VST->VST_SEQINC := "001"
						VST->VST_GRUINC := aPlaRev[ni,3]
						VST->VST_CODINC := aPlaRev[ni,5]
						VST->VST_DESINC := aPlaRev[ni,6]
						VST->VST_CHASSI := cChassi
					MsUnLock()
				EndIf
			Else
				If MsgYesNo(STR0394+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Deseja cancelar a realizacao do Plano de Revisao em outra Concessionaria?
					STR0082+": "+Alltrim(aPlaRev[ni,3])+" - "+Alltrim(aPlaRev[ni,4])+CHR(13)+CHR(10)+;
					STR0375+": "+Alltrim(aPlaRev[ni,5])+" - "+Alltrim(aPlaRev[ni,6]),STR0002) // Atencao
					DbSelectArea("VST")
					DbSetOrder(3)
					If DbSeek(cChassi) // ESTA CERTO!!!  NAO UTILIZAR FILIAL NO SEEK E NO LACO
						While VST->VST_CHASSI == cChassi
							If VST->VST_CODIGO==PadR(STR0391,TamSX3("VST_CODIGO")[1]) .and. ;
								VST->VST_CODMAR==aPlaRev[ni,10] .and. ;
								VST->VST_SEQINC=="001" .and. ;
								VST->VST_GRUINC==aPlaRev[ni,3] .and. ;
								VST->VST_CODINC==aPlaRev[ni,5] .and. ;
								VST->VST_DESINC==aPlaRev[ni,6]
								RecLock("VST",.F.,.T.)
									Dbdelete()
								MsUnlock()
								WriteSX2("VST")
							EndIf
							DbSelectArea("VST")
							DbSkip()
						EndDo
						cNumOSV := ""
						If lChassi
							cQuery := "SELECT VST.VST_CODIGO FROM "+RetSqlName("VST")+" VST WHERE "
							cQuery += "VST.VST_CHASSI='"+cChassi+"' AND VST.VST_CODMAR='"+aPlaRev[ni,10]+"' AND "
							cQuery += "VST.VST_GRUINC='"+aPlaRev[ni,3]+"' AND VST.VST_CODINC='"+aPlaRev[ni,5]+"' AND "
							cQuery += "( VST.VST_CODIGO IN ( SELECT VO1_NUMOSV FROM "+RetSqlName("VO1")+" VO1 WHERE VO1.VO1_FILIAL=VST.VST_FILIAL AND VO1.VO1_NUMOSV=VST.VST_CODIGO AND VO1.VO1_STATUS<>'C' AND VO1.D_E_L_E_T_=' ' ) "
							cQuery += " OR VST.VST_CODIGO='"+PadR(STR0391,TamSX3("VST_CODIGO")[1])+"' ) AND "
							cQuery += "VST.VST_TIPO='2' AND VST.D_E_L_E_T_=' ' ORDER BY VST.R_E_C_N_O_ DESC"
							cNumOSV := FM_SQL(cQuery)
						EndIf
						aPlaRev[ni,7] := cNumOSV
					EndIf
				EndIf
			EndIf
		EndIf
	Next
	oLbPlaRev:Refresh()
	For ni := 1 to len(aInconv)
		If aInconv[ni,1]
			If Alltrim(aInconv[ni,7]) <> Alltrim(PadR(STR0391,TamSX3("VST_CODIGO")[1]))
				If MsgYesNo(STR0393+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Confirma que o Inconveniente foi realizado em outra Concessionaria?
					STR0082+": "+Alltrim(aInconv[ni,3])+" - "+Alltrim(aInconv[ni,4])+CHR(13)+CHR(10)+;
					STR0375+": "+Alltrim(aInconv[ni,5])+" - "+Alltrim(aInconv[ni,6]),STR0002) // Atencao
					aInconv[ni,7] := STR0391 // EXTERNA
					DbSelectArea("VST")
					RecLock("VST",.t.)
						VST_FILIAL := xFilial("VST")
						VST_TIPO   := "2" // OS
						VST_CODIGO := aInconv[ni,7] // EXTERNA
						VST_CODMAR := aInconv[ni,10]
						VST_SEQINC := "001"
						VST_GRUINC := aInconv[ni,3]
						VST_CODINC := aInconv[ni,5]
						VST_DESINC := aInconv[ni,6]
						VST_CHASSI := cChassi
					MsUnLock()
				EndIf
			Else
				If MsgYesNo(STR0395+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Deseja cancelar a realizacao do Inconveniente em outra Concessionaria?
					STR0082+": "+Alltrim(aInconv[ni,3])+" - "+Alltrim(aInconv[ni,4])+CHR(13)+CHR(10)+;
					STR0375+": "+Alltrim(aInconv[ni,5])+" - "+Alltrim(aInconv[ni,6]),STR0002) // Atencao
					DbSelectArea("VST")
					DbSetOrder(3)
					If DbSeek(cChassi) // ESTA CERTO!!!  NAO UTILIZAR FILIAL NO SEEK E NO LACO
						While VST->VST_CHASSI == cChassi
							If VST->VST_CODIGO==PadR(STR0391,TamSX3("VST_CODIGO")[1]) .and. ;
								VST->VST_CODMAR==aInconv[ni,10] .and. ;
								VST->VST_SEQINC=="001" .and. ;
								VST->VST_GRUINC==aInconv[ni,3] .and. ;
								VST->VST_CODINC==aInconv[ni,5] .and. ;
								VST->VST_DESINC==aInconv[ni,6]
								RecLock("VST",.F.,.T.)
									Dbdelete()
								MsUnlock()
								WriteSX2("VST")
							EndIf
							DbSelectArea("VST")
							DbSkip()
						EndDo
						cNumOSV := ""
						If lChassi
							cQuery := "SELECT VST.VST_CODIGO FROM "+RetSqlName("VST")+" VST WHERE "
							cQuery += "VST.VST_CHASSI='"+cChassi+"' AND VST.VST_CODMAR='"+aInconv[ni,10]+"' AND "
							cQuery += "VST.VST_GRUINC='"+aInconv[ni,3]+"' AND VST.VST_CODINC='"+aInconv[ni,5]+"' AND "
							cQuery += "( VST.VST_CODIGO IN ( SELECT VO1_NUMOSV FROM "+RetSqlName("VO1")+" VO1 WHERE VO1.VO1_FILIAL=VST.VST_FILIAL AND VO1.VO1_NUMOSV=VST.VST_CODIGO AND VO1.VO1_STATUS<>'C' AND VO1.D_E_L_E_T_=' ' ) "
							cQuery += " OR VST.VST_CODIGO='"+PadR(STR0391,TamSX3("VST_CODIGO")[1])+"' ) AND "
							cQuery += "VST.VST_TIPO='2' AND VST.D_E_L_E_T_=' ' ORDER BY VST.R_E_C_N_O_ DESC"
							cNumOSV := FM_SQL(cQuery)
						EndIf
						aInconv[ni,7] := cNumOSV
					EndIf
				EndIf
			EndIf
		EndIf
	Next
	oLbInconv:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_TKPLAREV³ Autor ³ Andre Luis Almeida   ³ Data ³ 09/03/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ TIK e soma dos vetores de Plano de Revisao e Inconvenientes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ nOpc    = nOpc da rotina                                   ³±±
±±³          ³ nTp     = 1 - Plano de Revisao / 2 - Inconveniente         ³±±
±±³          ³ nLinha  = Linha do Vetor                                   ³±±
±±³          ³ nVlTotal= Valor Total dos registros selecionados           ³±±
±±³          ³ aPlaRev = Vetor dos Planos de Revisao                      ³±±
±±³          ³ aInconv = Vetor dos Inconvenientes                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FG_PLAREV ( Plano de Revisao )                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TKPLAREV(nOpc,nTp,nLinha,nVlTotal,aPlaRev,aInconv)
If nOpc == 3 .or. nOpc == 4 // Inclusao ou Alteracao
	nVlTotal := 0
	If nTp == 1 // Plano de Revisao
		If !Empty(aPlaRev[nLinha,5])
			aPlaRev[nLinha,1] := !aPlaRev[nLinha,1]
		EndIf
	ElseIf nTp == 2 // Inconvenientes
		If !Empty(aInconv[nLinha,5])
			aInconv[nLinha,1] := !aInconv[nLinha,1]
		EndIf
	EndIf
	aEval(aPlaRev , {|x| nVlTotal += IIF( x[1] == .t. , x[8]+x[9] , 0 ) } )
	aEval(aInconv , {|x| nVlTotal += IIF( x[1] == .t. , x[8]+x[9] , 0 ) } )
	oVlTotal:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_ITEREL³ Autor ³ Fabio                 ³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta um vetor com os itens relacionado da peca.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cGruIte:= Grupo do Item                                    ³±±
±±³          ³ cCodIte:= Codigo do Item                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_ITEREL(cTipTem_,cGruIte_,cCodIte_,cFormula_,cArm_)

Local cFormula
Local nQtdade  := 0
Local cSelect  := Alias()
Local nPosVE0  := SBM->(Recno())
Local nIndVE0  := SBM->(IndexOrd())
Local wPos 	   := 0
Local cCod1    := ""
Local cArmSB2  := ""
Private cGruRelac:=""
Private ItensRel:={},cTipTem:=cTipTem_,cGruIte:=cGruIte_,cCdIte:=cCodIte_
Default cArm_ := ""
cArmSB2 := cArm_ // Armazem passado para funcao
dbSelectArea("SB1")
DBSetOrder(7)
DBSeek(xFilial("SB1")+cGruIte_+cCodIte_)
dbSelectArea("SB5")
DBSetOrder(1)
DBSeek(xFilial("SB5")+SB1->B1_COD)
cFormula :=cFormula_
DbSelectArea("SBM")
DbSeek(xFilial("SBM")+cGruIte)
For wPos:=1 to Len(Alltrim(SBM->BM_GRUREL)) step 5
	cGruRelac:=SubStr(SBM->BM_GRUREL,wPos,4)
	cGrurelac:=left(cGruRelac,4)
	cFormula :=cFormula_
	nTamRela :=SBM->BM_LENREL
	dbSelectArea("SB1")
	If FG_SEEK("SB1","cGruRelac+Substr(cCdIte,1,nTamRela)",7,.f.)
		while !eof() .and. cGruRelac+Substr(cCdIte,1,nTamRela) == SB1->B1_GRUPO+Substr(SB1->B1_CODITE,1,nTamRela)
			if cGruIte+cCdIte == SB1->B1_GRUPO+SB1->B1_CODITE
				dbSelectArea("SB1")
				dbSkip()
				loop
			Endif
			If Empty(cArm_)
				cArmSB2 := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
			EndIf
			dbSelectArea("SB2")
			dbSeek(xFilial("SB2")+SB1->B1_COD+cArmSB2)
			nQtdade := SaldoSb2()
			nValor  := FG_VALPEC(cTipTem_,cFormula,SB1->B1_GRUPO,SB1->B1_CODITE,,.f.,.t.)
			Aadd(ItensRel,{cGruRelac,SB1->B1_CODITE,SB1->B1_DESC,nQtdade,IIf(nValor==0,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1"),nValor)})
			dbSelectArea("SB1")
			dbSkip()
		EndDo
	EndIf
Next

dbSelectArea("SB1")
dbSetOrder(7)
if dbSeek(xFilial("SB1")+cGruIte_+cCodIte_)
	cCod1 := SB1->B1_COD
	SB1->(dbSetOrder(1))
	dbSelectArea("VPD")
	dbSetOrder(1)
	if dbSeek(xFilial("VPD")+cCod1)
		while !EOF() .and. VPD->VPD_COD == cCod1
			if SB1->(dbSeek(xFilial("SB1")+VPD->VPD_CODREL))
				If Empty(cArm_)
					cArmSB2 := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
				EndIf
				dbSelectArea("SB2")
				dbSeek(xFilial("SB2")+SB1->B1_COD+cArmSB2)
				nQtdade := SaldoSb2()
				nValor  := FG_VALPEC(cTipTem_,cFormula,SB1->B1_GRUPO,SB1->B1_CODITE,,.f.,.t.)
				Aadd(ItensRel,{SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC,nQtdade,IIf(nValor==0,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1"),nValor)})
			Endif
			dbSelectArea("VPD")
			dbSkip()
		EndDo
	Endif
	dbSelectArea("VPD")
	dbSetOrder(2)
	if dbSeek(xFilial("VPD")+cCod1)
		while !EOF() .and. VPD->VPD_CODREL == cCod1
			if SB1->(dbSeek(xFilial("SB1")+VPD->VPD_COD))
				wPos := Ascan(ItensRel,{|x| x[1]+x[2] == SB1->B1_GRUPO + SB1->B1_CODITE })
				If wPos <= 0
					If Empty(cArm_)
						cArmSB2 := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
					EndIf
					dbSelectArea("SB2")
					dbSeek(xFilial("SB2")+SB1->B1_COD+cArmSB2)
					nQtdade := SaldoSb2()
					nValor := FG_VALPEC(cTipTem_,cFormula,SB1->B1_GRUPO,SB1->B1_CODITE,,.f.,.t.)
					Aadd(ItensRel,{SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC,nQtdade,IIf(nValor==0,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1"),nValor)})
				EndIf
			Endif
			dbSelectArea("VPD")
			dbSkip()
		EndDo
	Endif
Endif

If Len(ItensRel) == 0
	Aadd(ItensRel,{"  ","  ","  ",0,0})
EndIf

SBM->(DbSetOrder(nIndVE0))
SBM->(DbGoTo(nPosVE0 ))
if Empty(cSelect)
	cSelect := "SB1"
endif
DbSelectArea(cSelect)
Return(ItensRel)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_GRUTEM³ Autor ³  Fabio                ³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ VerIfica se o grupo do item esta no tipo de tempo.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cTipTem:= Tipo de Tempo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_GRUTEM(cTipTem,cGruIte,lMensagem)

Local nPosVOV := VOV->(Recno())
Local nOrdVOV := VOV->(IndexOrd())

Default cGruIte  := &( ReadVar() )
Default lMensagem:= .t.

if VOI->(FieldPos("VOI_CONVOV")) > 0
	VOI->(DbSetOrder(1))
	VOI->(DbSeek( xFilial("VOI") + cTipTem ) )
	if VOI->VOI_CONVOV == "0"
		VOV->( DbGoTo(nPosVOV) )
		VOV->( DbSetOrder(nOrdVOV))
		Return(.t.)
	endif
endif

VOV->(DbSetOrder(1))
If VOV->( DbSeek(xFilial("VOV") + cGruIte + cTipTem ))
	VOV->( DbGoTo(nPosVOV) )
	VOV->( DbSetOrder(nOrdVOV))
	Return(.t.)
EndIf

If lMensagem
	Help(" ",1,"GRUTIPTEM")
EndIf

VOV->(DbSetOrder(nOrdVOV))
VOV->(DbGoTo(nPosVOV))

Return(.f.)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FG_TIPTPFAT³ Autor ³ Fabio                 ³ Data ³ 09/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Determina Faturar par de acordo com o tipo de tempo          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametro³ cTipTem == Tipo de Tempo  VerIfica pode digitar fatpar When  ³±±
±±³          ³ cFatPar == Nome da Variavel que recebera o Fatura Para       ³±±
±±³          ³ cNomcli == Descricao do Faturar Para                         ³±±
±±³          ³ laCols  == Se .t. a Variavel existe no aCols                 ³±±
±±³          ³ cCodMar == Codigo da Marca                                   ³±±
±±³          ³ cTipReq == Tipo de Requisicao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_TIPTPFAT(cTipTem,cFatPar,cLoja,cNomCli,cCodMar,cTipReq,cNumOsv,laCols,lMensagem,lFatParVO1,lValidTT)

Local nPosVOW := VOW->(Recno()),nIndVOW:=VOW->(IndexOrd())
Local nPosSA1 := SA1->(Recno()),nIndSA1:=SA1->(IndexOrd())
Local nPosVO1 := VO1->(Recno()),nIndVO1:=VO1->(IndexOrd())
Local nPosVO2 := VO2->(Recno()),nIndVO2:=VO2->(IndexOrd())
Local nPosVO3 := VO3->(Recno()),nIndVO3:=VO3->(IndexOrd())
Local nPosVO4 := VO4->(Recno()),nIndVO4:=VO4->(IndexOrd())
Local cVarMem := ReadVar(),cSelect := Alias(),lReturn:=.t. ,cSeek  //,I ,iL, x
Local oFilHlp := DMS_FilialHelper():New()
Local aCliLoja:= {}
Local x := 0, cMsgCli := ""

Private cTipCli := ""

Default lMensagem:=.t.
Default lFatParVO1 := .t.
Default lValidTT := .t.

cCodMar := IIf(cCodMar != NIL,cCodMar,"")
cTipTem := IIf(cTipTem != NIL,cTipTem,&cVarMem)
cNomCli := IIf(cNomCli != NIL,cNomCli,"")
cTipReq := IIf(cTipReq != NIL,cTipReq,"P")
laCols  := IIf(laCols != NIL,laCols,Type("aCols") # "U")

AjustaHelp()

DbSelectArea("SA1")

If cNumOsv != NIL
	DbSelectArea("VO1")
	DbSetOrder(1)
	DbSeek(xFilial("VO1") + cNumOsv )
EndIf

DbSelectArea("VOI")
DbSetOrder(1)
If !(DbSeek(xFilial("VOI")+cTipTem))
	Return(.f.)
EndIf

If (cFatPar != NIL)

	If cTipReq=="P".And.VOI->VOI_REQPEC != "1"
		If lMensagem
			Help(" ",1,"TIPTPFAT")
		EndIf
		Return(.F.)
	EndIf

	If VOI->(FieldPos("VOI_REQSER")) > 0
		If cTipReq=="S".And. (!Empty(VOI->VOI_REQSER) .and. VOI->VOI_REQSER != "1")
			If lMensagem
				Help(" ",1,"TPREQSRV")
			EndIf
			Return(.F.)
		EndIf
	EndIf

	DbSelectArea("VOW")
	DbSetOrder(1)
	lConsidera := .t.
	if VOI->(FieldPos("VOI_CONVOW")) > 0
		VOI->(DbSetOrder(1))
		VOI->(DbSeek( xFilial("VOI") + cTipTem ) )
		if VOI->VOI_CONVOW == "0"
			lConsidera := .f.
		endif
	endif
	If!( DbSeek( xFilial("VOW") + Posicione("VAI" , 4 , xFilial("VAI") + __cUserID,"VAI_CODTEC") + cTipTem )) .and. lConsidera
		If lMensagem
			Help(" ",1,"TPPRODUT")
		EndIf
		Return(.f.)
	EndIf

	If lValidTT
		&& Verifica se o tipo de tempo foi disponibilizado
		DbSelectArea("VO2")
		DbSetOrder(1)
		DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV+"P" )
		Do While !Eof() .And. VO2->VO2_NUMOSV == VO1->VO1_NUMOSV .And. VO2->VO2_TIPREQ == "P"
			DbSelectArea("VO3")
			DbSetOrder(1)
			DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM+cTipTem)
			If ( !Empty(VO3->VO3_DATDIS) .Or. !Empty(VO3->VO3_DATFEC) .Or. !Empty(VO3->VO3_DATCAN) )

				If lMensagem
					If !Empty(VO3->VO3_DATCAN)
						Help("  ",1,"TTCANCEL",,STR0298,3,0)
					EndIf

					If !Empty(VO3->VO3_DATDIS)
						Help("  ",1,"TTLIBERA",,STR0299,3,0)
					EndIf

					If !Empty(VO3->VO3_DATFEC)
						Help("  ",1,"TTFECHAD",,STR0300,3,0)
					EndIf
				EndIf

				VO1->(DbSetOrder(nIndVO1))
				VO1->(DbGoTo(nPosVO1))
				VO2->(DbSetOrder(nIndVO2))
				VO2->(DbGoTo(nPosVO2))
				VO3->(DbSetOrder(nIndVO3))
				VO3->(DbGoTo(nPosVO3))

				If !Empty(cSelect)
					DbSelectArea(cSelect)
				EndIf

				Return(.f.)
			EndIf
			DbSelectArea("VO2")
			DbSkip()
		EndDo

		DbSelectArea("VO2")
		DbSetOrder(1)
		if DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV+"S" )
			DbSelectArea("VO4")
			DbSetOrder(1)
			if DbSeek(xFilial("VO4")+VO2->VO2_NOSNUM+cTipTem)

				If ( !Empty(VO4->VO4_DATDIS) .Or. !Empty(VO4->VO4_DATFEC) .Or. !Empty(VO4->VO4_DATCAN) )

					If lMensagem
						If !Empty(VO4->VO4_DATCAN)
							Help("  ",1,"TTCANCEL",,STR0298,3,0)
						EndIf

						If !Empty(VO4->VO4_DATDIS)
							Help("  ",1,"TTLIBERA",,STR0299,3,0)
						EndIf

						If !Empty(VO4->VO4_DATFEC)
							Help("  ",1,"TTFECHAD",,STR0300,3,0)
						EndIf
					EndIf

					VO1->(DbSetOrder(nIndVO1))
					VO1->(DbGoTo(nPosVO1))
					VO2->(DbSetOrder(nIndVO2))
					VO2->(DbGoTo(nPosVO2))
					VO4->(DbSetOrder(nIndVO4))
					VO4->(DbGoTo(nPosVO4))

					If !Empty(cSelect)
						DbSelectArea(cSelect)
					EndIf

					Return(.f.)
				Endif
			EndIf
		Endif
	EndIf

	VO1->(DbSetOrder(nIndVO1))
	VO1->(DbGoTo(nPosVO1))
	VO2->(DbSetOrder(nIndVO2))
	VO2->(DbGoTo(nPosVO2))
	VO3->(DbSetOrder(nIndVO3))
	VO3->(DbGoTo(nPosVO3))
	VO4->(DbSetOrder(nIndVO4))
	VO4->(DbGoTo(nPosVO4))

	If !Empty(cSelect)
		DbSelectArea(cSelect)
	EndIf

	nPosTP:=0
	lTipTP:=.f.
	If laCols
		I := Ascan(aHeader,{|x| x[2] == Substr(cFatPar,At(">",cFatPar)+1) })
		iL:= Ascan(aHeader,{|x| Alltrim(x[2]) == Substr(cLoja  ,At(">",cLoja  )+1) })
		nPosTP := Ascan(aHeader,{|x| x[2] == Substr(cVarMem,At(">",cVarMem)+1) })
		For x:=Len(aCols) to 1 Step -1
			If x != n .And. aCols[x,nPosTP] == &cVarMem
				lTipTP:=.t.
				Exit
			EndIf
		Next
	EndIf

	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)           //VEICULOS

	If VOI->VOI_USAPRO $ [0]
		If lTipTP
			cSeek := aCols[x,i]+aCols[x,iL]           &&  Ultimo fatura para do tipo de tempo
		Else
			If !Empty(VO1->VO1_FATPAR).And. VO1->VO1_FATPAR+VO1->VO1_LOJA != VV1->VV1_PROATU+VV1->VV1_LJPATU .and. lFatParVO1
				cSeek := VO1->VO1_FATPAR+VO1->VO1_LOJA                           &&  Faturar para da Abertura OS
				cTipCli := "2"
			Else
				cSeek := VV1->VV1_PROATU+VV1->VV1_LJPATU                 &&  Proprietario do Veiculo
				cTipCli := "1"
			EndIf
		EndIf
	ElseIf VOI->VOI_USAPRO $ [1]
		VE4->(DbSetOrder(1))
		VE4->(DbSeek(xFilial("VE4")+cCodMar))
		cSeek := VE4->VE4_CODFAB+VE4->VE4_LOJA    &&  Fabrica
		cTipCli := "3"
	ElseIf VOI->VOI_USAPRO $ [3]
		aCliLoja := oFilHlp:GetCodCli(cFilAnt) //  Busca Codigo e Loja de Cliente da Filial
		cSeek    := aCliLoja[1]+aCliLoja[2]    //  Filial Corremte
		cTipCli  := "7"
	Else
		cSeek := VOI->VOI_CLIFAT+VOI->VOI_LOJA //  Cliente Padrao
		cTipCli := "4"
	EndIf

	cSeek := FG_FATSP(cTipTem,cSeek,cNomCli,,.t.)

	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cSeek) )

	If ( Empty(cSeek) .Or. !SA1->(Found()) )

		If lMensagem
			cMsgCli := STR0308 +Chr(13)+Chr(10)

			cMsgCli += STR0301 +VV1->VV1_PROATU+" "+VV1->VV1_LJPATU+IIf(cTipCli $ "1",STR0307,"")+Chr(13)+Chr(10)
			cMsgCli += STR0302 +VO1->VO1_FATPAR+" "+VO1->VO1_LOJA  +IIf(cTipCli $ "2",STR0307,"")+Chr(13)+Chr(10)
			cMsgCli += STR0303 +VE4->VE4_CODFAB+" "+VE4->VE4_LOJA  +IIf(cTipCli $ "3",STR0307,"")+Chr(13)+Chr(10)
			cMsgCli += STR0304 +VOI->VOI_CLIFAT+" "+VOI->VOI_LOJA  +IIf(cTipCli $ "4",STR0307,"")+Chr(13)+Chr(10)
			cMsgCli += STR0305 +SA1->A1_COD    +" "+SA1->A1_LOJA   +IIf(cTipCli $ "5",STR0307,"")+Chr(13)+Chr(10)
			cMsgCli += STR0306 +SA1->A1_COD    +" "+SA1->A1_LOJA   +IIf(cTipCli $ "6",STR0307,"")+Chr(13)+Chr(10)
			Help("  ",1,"INFCLIENT",,cMsgCli,3,0)
		EndIf
		lReturn:=.f.

	EndIf

	If laCols
		aCols[n,i]    := &cFatPar := SA1->A1_COD
		aCols[n,iL]   := &cLoja   := SA1->A1_LOJA
		aCols[n,iL+1] := &cNomCli := SA1->A1_NOME
	Else
		&cFatPar := SA1->A1_COD
		&cLoja   := SA1->A1_LOJA
		&cNomCli := SA1->A1_NOME
	EndIf
Else
	If VOI->VOI_ALTCLI == "0"  // .Or. M->VO2_DEVOLU == "0"
		lReturn:=.f.
	EndIf
EndIf


//VOI->(DbSetOrder(nIndVOI))
//VOI->(DbGoto(nPosVOI))
VO1->(DbSetOrder(nIndVO1))
VO1->(DbGoTo(nPosVO1))
VOW->(DbSetOrder(nIndVOW))
VOW->(DbGoTo(nPosVOW))
SA1->(DbSetOrder(nIndSA1))
SA1->(DbGoTo(nPosSA1))

If !Empty(cSelect)
	DbSelectArea(cSelect)
EndIf

Return(lReturn)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FG_NumNot  ³ Autor ³ Renata                ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VerIfica dados para a garantia de estoque nos arquivos de nf ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_NumNot()

If readvar() == 'M->VGA_NUMNFI'

	If ExistChav("VGA","VW "+M->VGA_NUMNFI+M->VGA_SERIEN,2,"EXINUMNFI") = .f.
		return .f.
	EndIf

	dbselectarea("SF2")
	dbsetorder(1)
	dbgotop()
	lAchou:=dbseek(xFilial("SF2")+M->VGA_NUMNFI+M->VGA_SERIEN)          //NOTAS SAIDAS

	If lAchou = .t.
		M->VGA_CODCLI := SF2->F2_CLIENTE
		M->VGA_LOJA   := SF2->F2_LOJA
		M->VGA_DATFEC := SF2->F2_EMISSAO
		Return .t.
	EndIf

	dbselectarea("SF1")
	dbsetorder(1)
	dbgotop()
	lAchou:=dbseek(xFilial("SF1")+M->VGA_NUMNFI+M->VGA_SERIEN)          //NOTAS ENTRADA

	If lAchou = .t.
		M->VGA_CODCLI := SF1->F1_FORNECE
		M->VGA_LOJA   := SF1->F1_LOJA
		M->VGA_DATFEC := SF1->F1_EMISSAO
	Else
		AVISO(STR0002,STR0095,{STR0096})  //NF nao existe
		Return .f.
	EndIf
EndIf

Return .t.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FG_VALPEC  ³ Autor ³ Fabio                 ³ Data ³ 22/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valor da Unitario da Peca de acordo com a Formula            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cTipTem     == Tipo de Tempo                                 ³±±
±±³          ³ cVarFormula == Nome da Variavel que contem a Formula entre ""³±±
±±³          ³ cGruIte     == Grupo do Item                                 ³±±
±±³          ³ cCodIte     == Codigo do Item                                ³±±
±±³          ³ cVarValor   == Nome da Variavel que recebera o Valor entre ""³±±
±±³          ³ lWhen       == Se a chamada estiver no When .T. se nao .F.   ³±±
±±³          ³ lValor      == Se o Retorno for o Valor .T. "Uso nao Obrigat"³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alterac  ³ 02/05/01 - Utilizacao do MV_ARREFAT para o calculo do valor  ³±±
±±³          ³            da peca (Emilton)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Exclusivo                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_VALPEC(cTipTem,cVarFormula,cGruIte,cCodIte,cVarValor,lWhen,lValor)
Local nValChk    := 0
Local bBlock     := ErrorBlock(),bErro := ErrorBlock( { |e| FGX_CheckBug(e) })
Local nPosVOI:=VOI->(Recno()),nIndVOI:=VOI->(IndexOrd())
Local nPosVEG:=VEG->(Recno()),nIndVEG:=VEG->(IndexOrd())
Local nPosSB1:=SB1->(Recno()),nIndSB1:=SB1->(IndexOrd())
Local nPosSB0:=SB0->(Recno()),nIndSB0:=SB0->(IndexOrd())
Local lReturn:=.t.,nValor:=0
Local i := 0
Local nDecimais := TamSX3("VS3_VALPEC")[2]
Local nVlPc     := 0

cTipTem := IIf(cTipTem != NIL,cTipTem," ")
lValor  := IIf(lValor==NIl,.f.,lValor)

cMCusto := GetMV("MV_MCUSTO")
If !empty(cTipTem)
	If !(VOI->(DbSeek(xFilial("VOI")+cTipTem)))
		VOI->(DbSetOrder(nIndVOI))
		VOI->(DbGoto(nPosVOI))
		lReturn:=IIf(lValor,nValor,.f.)
		ErrorBlock(bBlock)
		Return(lReturn)
	EndIf
EndIf

If cVarFormula == NIL .Or. (!Empty(cTipTem) .And. VOI->VOI_ALTVAL=="0") .Or. Empty(&cVarFormula)
	cFormula := "VOI->VOI_VALPEC"
Else
	cFormula := cVarFormula
EndIf

DbSelectArea("VEG")
DbSetOrder(1)
If DbSeek(xFilial("VEG")+&cFormula)
	lRetChkFor := .t.
	nValChk := &(VEG->VEG_FORMUL)
	if ValType(nValChk) <> "N"
		lRetChkFor := .f.
	Endif
	ErrorBlock(bBlock)
	If !lRetChkFor
		lErroFor := .t.
		lReturn:=IIf(lValor,0,.f.)
		Return(lReturn)
	Else
		lErroFor := .f.
	EndIf
Else
	VOI->(DbSetOrder(nIndVOI))
	VOI->(DbGoto(nPosVOI))
	VEG->(DbSetOrder(nIndVEG))
	VEG->(DbGoto(nPosVEG))
	lReturn:=IIf(lValor,nValor,.f.)
	ErrorBlock(bBlock)
	Return(lReturn)

EndIf

DbSelectArea("SB1")
DbSetOrder(7)
DbSeek( xFilial("SB1") + cGruIte + cCodIte )

DbSelectArea("SB5")
DbSetOrder(1)
DbSeek( xFilial("SB5") + SB1->B1_COD )

cFormula := VEG->VEG_FORMUL
nVlPc := xMoeda(&cFormula,1,1,dDatabase)

If (GetMV("MV_ARREFAT")=="S")
	nValor := Round(nVlPc,nDecimais)
Else
	nValor := NoRound(nVlPc,nDecimais)
EndIf

If cVarValor != NIL
	&cVarValor  :=  nValor
EndIf
If cVarFormula != NIL
	If at(">",cVarFormula) == 3 .Or. at(">",cVarFormula) == 0
		cVarFormula:= VEG->VEG_CODIGO
	EndIf
EndIf
if Type("aCols") != "U"
	For i:=1 to Len(aHeader)
		If cVarValor != NIL .And. ("M->"+aHeader[i,2]) == cVarValor
			aCols[n,i] := nValor
		EndIf
		If cVarFormula != NIL .And. ("M->"+aHeader[i,2]) == cVarFormula
			aCols[n,i] := VEG->VEG_CODIGO
		EndIf
	Next
EndIf

If lWhen
	If VOI->VOI_ALTVAL == "0"
		lReturn:=.f.
	Else
		lReturn:=.t.
	EndIf
EndIf
VOI->(DbSetOrder(nIndVOI))
VOI->(DbGoto(nPosVOI))
SB1->(DbSetOrder(nIndSB1))
SB1->(DbGoto(nPosSB1))
SB0->(DbSetOrder(nIndSB0))
SB0->(DbGoto(nPosSB0))

If lValor
	Return(nValor)
EndIf
cVerFormula := NIL
Return(lReturn)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_NUMASS  ³ Autor ³ Andre                 ³ Data ³ 27/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pega o numero da proxima assembleia                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Exclusivo   ( Modulo de Veiculos - VIP)                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_NUMASS(Arg1)

DbGotop()
wAcha := DbSeek(xFilial("VP5")+Arg1)
If wAcha
	nNro := 1
	wGrp := Arg1
	while !EOF()
		If VP5->VP5_CODGRU == wGrp
			nNro++
		Else
			Exit
		EndIf
		DbSkip()
	Enddo
	M->VP5_NUMASS := StrZero(nNro,3)
Else
	M->VP5_NUMASS := "001"
EndIf

Return (.t.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FG_SALPEC  ³ Autor ³ Fabio                 ³ Data ³ 29/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lista Pecas Requisitadas na OS e Altera os Itens             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cNumOsv == Numero da Os                                      ³±±
±±³          ³ cGruIte == Grupo do Item                                     ³±±
±±³          ³ cCodIte == Codigo do Item                                    ³±±
±±³          ³ cTipTem == Tipo de Tempo      Nao Obrigatorio                ³±±
±±³          ³ cCodCli == Codigo do Cliente  Nao Obrigatorio                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ Se o Tipo Tempo ou Codigo Cliente for Informado totaliza-se  ³±±
±±³          ³ pelo mesmo.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Exclusivo                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_SALPEC(cNumOsv,cGruIte,cCodIte,cTipTem_,cCodCli_,cLoja_)

Local cSele := Alias(),nVO2Posicao := VO2->(Recno()),nVO3Posicao := VO3->(Recno())
Local nQuantReq:=0,nQuantDev:=0

DbSelectArea("VO2")
DbSeek(xFilial("VO2")+cNumOsv)
while !Eof() .and. VO2->VO2_NUMOSV == cNumOsv
	DbSelectArea("VO3")
	DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM)
	while !Eof() .And. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM
		cTipTem := IIf(cTipTem_ == NIL,VO3->VO3_TIPTEM,cTipTem_)
		cCodCli := IIf(cCodCli_ == NIL,VO3->VO3_FATPAR,cCodCli_)
		cLoja   := IIf(cLoja_   == NIL,VO3->VO3_LOJA  ,cLoja_  )
		If VO3->VO3_TIPTEM+VO3->VO3_FATPAR+VO3->VO3_LOJA+VO3->VO3_GRUITE+VO3->VO3_CODITE == cTipTem+cCodCli+cLoja+cGruIte+cCodIte
			If VO2->VO2_DEVOLU == "1"
				nQuantReq := nQuantReq + VO3->VO3_QTDREQ
			Else
				nQuantDev := nQuantDev + VO3->VO3_QTDREQ
			EndIf
		EndIf

		DbSelectArea("VO3")
		DbSkip()
	EndDo

	DbSelectArea("VO2")
	DbSkip()
EndDo

nReturn := nQuantReq-nQuantDev

VO2->(DbGoTo(nVO2Posicao))
VO3->(DbGoTo(nVO3Posicao))

If !Empty(cSele)
	DbSelectArea(cSele)
EndIf

Return(nReturn)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_VALIDA  ³ Autor ³ Andre                 ³ Data ³ 30/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Campos SX3                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Arg1 = Nil ou Pode ser Colocado Qq outro Valor para ser      ³±±
±±³          ³        chamada a Funcao FG_STRZERO().                        ³±±
±±³          ³ Arg2 = Seek                                                  ³±±
±±³          ³ Arg3 = As variaveis do Seek e no final da ultima variavel o  ³±±
±±³          ³        caracter "*"----Obs: Pose Ser indicado mais de um     ³±±
±±³          ³        Arquivo p/ Seek, sendo separado por "*"               ³±±
±±³          ³ Arg4 = Se .t. ou Nil Mostra Msg de Vld se .f. Nao Mostra     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_VALIDA(Arg1,Arg2,Arg3,Arg4)
Local i := 0
wAlias  := Alias()
wReturn := .t.

if Funname()=="OFIXA011" .or. FunName() == "OFIOM350"
	if ReadVar() == "M->VS1_CODBCO"
		return FG_Seek("SA6","M->VS1_CODBCO",1,.f.)
	endif
	return .t.
endif

If Arg1 != Nil
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	Arg1 := ReadVar()
	If DbSeek(Substr(Arg1,4))
		nTamanho := x3_tamanho
		FG_StrZero(Arg1,nTamanho)
	Else
		Return .t.
	EndIf
EndIf

If Arg2 != Nil

	while .t.
		If len(Alltrim(Arg2)) == 0
			Exit
		EndIf
		lRetorno := SubStr(Arg2,4,1)
		If lRetorno == "T"

			If "*" $ SubStr(Arg2,5,2)

				nPosicao := AT("*",Arg2)
				cAlias   := SubStr(Arg2,1,3)
				vCampos  := {}

				nOrdem   := 1
				If SubStr(Arg2,5,1) $ "0123456789"
					cSeek    := SubStr(Arg2,6,nPosicao-5)
					nOrdem := Val(SubStr(Arg2,5,1))
				Else
					cSeek    := SubStr(Arg2,5,nPosicao-5)
				EndIf
				DbSelectArea(cAlias)
				DbSetOrder(nOrdem)

				DbSelectArea("SIX")
				DbGotop()
				DbSeek(cAlias+StrZero(nOrdem,1))
				cString := SubStr(Chave,12)
				while .t.
					nPosStr := AT("+",cString)
					If nPosStr == 0
						If Len(Alltrim(cSTring)) > 0
							nString := Substr(cString,1)
							wVar := "M->"+nString
							If Type(wVar) == "U"
								Exit
							EndIf
							aadd(vCampos,"M->"+nString)
							cString := " "
						Else
							Exit
						EndIf
					Else
						nString := Substr(cString,1,nPosStr-1)
						wVar := "M->"+nString
						If Type(wVar) == "U"
							Exit
						EndIf
						aadd(vCampos,"M->"+nString)
						cString := Substr(cString,nPosStr+1)
					EndIf
				Enddo

				If Len(vCampos) == 0
					Arg2 := SubStr(Arg2,nPosicao+1)
					Loop
				EndIf

				cSeek := ""
				For i:=1 to Len(vCampos)
					cSeek := cSeek+vCampos[i]+"+"
				Next
				cSeek := Substr(cSeek,1,Len(cSeek)-1)

				DbSelectArea(cAlias)
				DbGoTop()
				cSeek2 := cSeek
				If DbSeek(xFilial(cAlias)+&cSeek2)
					If INCLUI
						wReturn := .f.
					EndIf
				Else
					wReturn := wReturn
				EndIf
				Arg2 := SubStr(Arg2,nPosicao+1)

			Else

				nPosicao := AT("*",Arg2)
				cAlias   := SubStr(Arg2,1,3)
				nOrdem   := 1
				If SubStr(Arg2,5,1) $ "0123456789"
					cSeek    := SubStr(Arg2,6,nPosicao-6)
					nOrdem := Val(SubStr(Arg2,5,1))
				Else
					cSeek    := SubStr(Arg2,5,nPosicao-5)
				EndIf
				DbSelectArea(cAlias)
				DbSetOrder(nOrdem)
				DbGoTop()
				cSeek2 := cSeek
				If DbSeek(xFilial(cAlias)+&cSeek2)
					wReturn := wReturn
				Else
					wReturn := .f.
				EndIf
				Arg2 := SubStr(Arg2,nPosicao+1)
			EndIf
		Else
			nPosicao := AT("*",Arg2)
			cAlias   := SubStr(Arg2,1,3)
			vCampos  := {}

			nOrdem   := 1
			If SubStr(Arg2,5,1) $ "0123456789"
				cSeek    := SubStr(Arg2,6,nPosicao-6)
				nOrdem := Val(SubStr(Arg2,5,1))
			Else
				cSeek    := SubStr(Arg2,5,nPosicao-5)
			EndIf
			DbSelectArea(cAlias)
			DbSetOrder(nOrdem)

			DbSelectArea("SIX")
			DbGotop()
			DbSeek(cAlias+StrZero(nOrdem,1))
			cString := SubStr(Chave,12)
			while .t.
				nPosStr := AT("+",cString)
				If nPosStr == 0
					If Len(Alltrim(cSTring)) > 0
						nString := Substr(cString,1)
						wVar := "M->"+nString
						If Type(wVar) == "U"
							Exit
						EndIf
						aadd(vCampos,"M->"+nString)
						cString := " "
					Else
						Exit
					EndIf
				Else
					nString := Substr(cString,1,nPosStr-1)
					wVar := "M->"+nString
					If Type(wVar) == "U"
						Exit
					EndIf
					aadd(vCampos,"M->"+nString)
					cString := Substr(cString,nPosStr+1)
				EndIf
			Enddo

			If Len(vCampos) == 0
				Arg2 := SubStr(Arg2,nPosicao+1)
				Loop
			EndIf

			cSeek := ""
			For i:=1 to Len(vCampos)
				cSeek := cSeek+vCampos[i]+"+"
			Next
			cSeek := Substr(cSeek,1,Len(cSeek)-1)

			DbSelectArea(cAlias)
			DbGoTop()
			cSeek2 := cSeek
			If DbSeek(xFilial(cAlias)+&cSeek2)
				If INCLUI
					wReturn := .f.
				EndIf
			Else
				wReturn := wReturn
			EndIf
			Arg2 := SubStr(Arg2,nPosicao+1)
		EndIf
	Enddo

EndIf

If Arg3 != Nil
	cdBlock := {|| &Arg3}
	EVAL(cdBlock)
EndIf

If Arg4 == Nil            // Se nao passar parametro atribui Verdadeiro
	Arg4 := .t.
EndIf

If Arg4 == .t.
	If wReturn == .f.
		Help("  ",1,"VALIDADE")    // "Registro Duplicado ou nao Encontrado no Cadastro..."
	EndIf
EndIf

If !Empty(wAlias)
	DbSelectArea(wAlias)
EndIf

Return(wReturn)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_INICIA  ³ Autor ³ Andre                 ³ Data ³ 30/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializacao de Campos SX3                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Arg1 = Seek                                                  ³±±
±±³          ³ Arg3 = Formula                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_INICIA(Arg1,Arg2)

Inclui:=IIf(Type("Inclui")=="U",.f.,Inclui)

If Inclui
	Return " "
EndIf

//wAlias  := Alias()
wReturn := " "

while .t.
	If len(Alltrim(Arg1)) == 0
		Exit
	EndIf
	lRetorno := SubStr(Arg1,4,1)
	If lRetorno == "T"
		nPosicao := AT("*",Arg1)
		cAlias   := SubStr(Arg1,1,3)
		cSeek    := SubStr(Arg1,5,nPosicao-5)
		DbSelectArea(cAlias)
		DbGoTop()
		cSeek2 := cSeek
		DbSeek(xFilial(cAlias)+&cSeek2)
		Arg1 := SubStr(Arg1,nPosicao+1)
	Else
		nPosicao := AT("*",Arg1)
		cAlias   := SubStr(Arg1,1,3)
		Arg1 := SubStr(Arg1,nPosicao+1)
	EndIf
Enddo

cdBlock := {|| &Arg2}
wReturn := EVAL(cdBlock)

Return(wReturn)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_PEDREL  ³ Autor ³ Emilton               ³ Data ³ 04/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pedido de Impressao de Relacao de Pecas                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Arg1 = Numero da Ordem de Servico                            ³±±
±±³          ³ Arg2 = Tipo de Tempo                                         ³±±
±±³          ³ Arg3 = Tipo de Formulario                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PEDREL(cNumOSv,cTipTem,cTipFor)
PRIVATE aReturn  := { (""), 1,(""), 2, 2, 2,,1 }

If cTipFor == "N"
	//Ponto de Entrada para o Formulario Comum
	If ExistBlock("RELPECE")             // Relacao de Pecas Formulario Comum
		ExecBlock("RELPECE",.f.,.f.,{cNumOsv,cTipTem,'RELPECN'})
	EndIf
Else
	//Ponto de Entrada para o Formulario EspecIfico
	If ExistBlock("RELPECE")             // Relacao de Pecas (Formulario EspecIfico)
		ExecBlock("RELPECE",.f.,.f.,{cNumOsv,cTipTem,'RELPECE'})
	EndIf
EndIf

Return(.T.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_PEDORD  ³ Autor ³ Luis Delorme          ³ Data ³ 04/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pedido de Impressao de Ordem de Servico                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Arg1 = Numero da Ordem de Servico                            ³±±
±±³          ³ Arg2 = N - Formulario Normal / E - Formulario EspecIfico     ³±±
±±³          ³ Arg3 = Imprime para mecanico                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PEDORD(cNumOSv,cTipFor,cParamt)
PRIVATE aReturn  := { (""), 1,(""), 2, 2, 2,,1 }

If cTipFor == "N"
	// Ponto de Entrada para o Formulario Comum
	If ExistBlock("IMPORD")             // Ordem de Servico (Formulario Comum)
		//		ExecBlock("IMPORD",.f.,.f.,{cNumOsv,'IMPORD',.t.})
		ExecBlock("IMPORD",.f.,.f.,{cNumOsv,'IMPORD',cParamt})
	EndIf
Else
	//Ponto de Entrada para o Formulario EspecIfico
	If ExistBlock("IMPORD")             // Ordem de Servico (Formulario EspecIfico)
		ExecBlock("IMPORD",.f.,.f.,{cNumOsv,'IMPOSV',cParamt})
	EndIf
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_GERPAR³ Autor ³ Andr‚                 ³ Data ³ 14/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ GERA OU ATUALIZA AS PARCELAS DO PARTICIPANTE               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Arg1 = Codigo do Grupo + Numero da Cota + Codigo do Cliente³±±
±±³          ³ Arg2 = Opcao de 1 = inclusao ou 2 = atualizacao            ³±±
±±³          ³ Arg3 = .t. Mostra Mensagens /  .f. Nao Mostra              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GRUPO VIP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_GERPAR(Arg1,Arg2,Arg3)
Local i := 0

If Arg3 == Nil
	Arg3 := .t.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para calculo                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wVLDESP := 0
wDESCOB := 0
wOUTDES := 0
wVLANCE := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega alguns campos do arquivo de participantes               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VP1")
If DbSeek(xFilial("VP1")+Arg1)
	nQtdPar   := VP1->VP1_QTDPAR
	nPerIde   := VP1->VP1_PERIDE
	cCodBem   := VP1->VP1_CODBEM
	wAbertura := substr(dtoc(VP1->VP1_DATADE),3)
	wDataCalc := StrZero(VP1->VP1_DIAPGT,2)+wAbertura
	wDt       := CTOD(wDataCalc)
	wDESCOB   := VP1->VP1_DESCBP
	wOUTDES   := VP1->VP1_OUTDES
Else
	MsgStop(STR0159,STR0160)
	Return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega valor do bem atual                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VP6")
Dbgotop()
If VP6->(DbSeek(xFilial("VP6")+cCodBem))
	wValorBem := VP6->VP6_VALBEM
Else
	MsgStop(STR0161,STR0160)
	Return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega quantidade de meses, para calcular as parcelas          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wNroMeses := 0
wPerSaldo := 0
dbSelectArea("VP3")
If VP3->(DbSeek(xFilial("VP3")+VP1->VP1_CODGRU))
	If Empty(VP3->VP3_DATENC)
		wNroMeses := VP3->VP3_NUMMES
		wVLDESP   := VP3->VP3_VALDES
		If VP1->VP1_QTDPAR != wNroMeses
			wNroMeses := VP1->VP1_QTDPAR
		EndIf
	Else
		MsgStop(STR0162,STR0160)
		Return .f.
	EndIf
EndIf

nValPar := (wValorBem/wNroMeses)

If Arg2 == 1 .or. Arg2 == 2

	If Arg2 == 1
		DbSelectArea("VP2")
		DbGotop()
		If DbSeek(xFilial("VP2")+Arg1)
			If Arg3
				MsgInfo(STR0163,STR0160)
			EndIf
			Return .f.
		EndIf
	Else
		DbSelectArea("VP2")
		DbGotop()
		If !DbSeek(xFilial("VP2")+Arg1)
			If Arg3
				MsgInfo(STR0164,STR0160)
			EndIf
			Return .f.
		EndIf
	EndIf

	DbSelectArea("VP2")
	DbGotop()
	DbSeek(xFilial("VP2")+Arg1)
	wNrPAnt := 0
	while !EOF() .and. VP2_CODGRU+VP2_NUMCOT+VP2_CODCLI+VP2_LOJA == Arg1
		wNrPAnt++
		DbSkip()
	Enddo

	If Arg2 == 2  // Atualizacao

		nPerIdeal := 0
		nQtdPago  := 0
		nQtdNPago := 0
		wDatPagto := ctod("")
		wValDIfer := 0
		nDIfParc  := 0
		nPerParc  := 0
		nPerAume  := 0
		wBemAnter := cCodBem

		dbSelectArea("VP2")
		dbSetOrder(1)
		dbGotop()
		DbSeek(xFilial("VP2")+Arg1)
		while !EOF() .and. VP2->VP2_CODGRU+VP2->VP2_NUMCOT+VP2->VP2_CODCLI+VP2->VP2_LOJA == Arg1
			If !Empty(VP2->VP2_DATPAG) .and. VP2->VP2_VALPAR == 0
				nPerIdeal := nPerIdeal + VP2->VP2_PERIDE
				If VP2->VP2_DATPAG > wDatPagto
					wBemAnter := VP2->VP2_CODBEM
					wDatPagto := VP2->VP2_DATPAG
				EndIf
				nQtdPago++
			EndIf
			dbskip()
		Enddo

		nPerNPago := 100 - nPerIdeal
		nPerAtual := nPerNPago

		dbSelectArea("VP6")
		Dbgotop()
		If VP6->(DbSeek(xFilial("VP6")+wBemAnter))
			wValDIfer := wValorBem - VP6->VP6_VALBEM
		EndIf
		dbSelectArea("VP2")

		nDIfParc := (nPerIdeal * wValDIfer) / 100
		nPerParc := (nDIfParc / wValorBem ) * 100
		nPerAume := (nPerParc / (VP1->VP1_QTDPAR - nQtdPago))

		nValParc := (((wValorBem / (VP1->VP1_QTDPAR - nQtdPago)) / 100) * nPerAtual+nPerAume)

		nPerIde := nPerIde + nPerAume
		nValPar := nValParc

	EndIf

	wDiaDt:= val(Right(dtos(wDt),2))
	wMesDt:= val(substr(dtos(wDt),5,2))
	wAnoDt:= val(Left(dtos(wDt),4))

	wDiaOld := val(Right(dtos(wDt),2))

	nPerSal := 100
	nPerPag := 0
	nPerLan := 0

	For i=1 to wNroMeses

		wMesDt:= wMesDt+1
		If wMesDt > 12
			wMesDt := 01
			wAnoDt := wAnoDt + 1
		EndIf

		If wMesDt == 2
			If wDiaDt > 28
				If DataValida(ctod("29"+"/"+strzero(wMesDt,2)+"/"+Trim(str(wAnoDt,4))))
					wDiaDt := 29
				Else
					wDiaDt := 28
				EndIf
			EndIf
		Else
			wDiaDt := wDiaOld
		EndIf

		wDt2 := ctod(strzero(wDiadt,2)+"/"+strzero(wMesDt,2)+"/"+Trim(str(wAnoDt,4)))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se encontrar as parcelas so da Replace senao Cria            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("VP2")
		dbGotop()
		wAchou := VP2->(DbSeek(xFilial("VP2")+VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI+VP1->VP1_LOJA+STRZERO(I,3)))
		RecLock("VP2",IIf(wAchou,.f.,.t.))
		If Empty(VP2->VP2_DATPAG)
			VP2->VP2_FILIAL := xFilial("VP2")
			VP2->VP2_CODGRU := VP1->VP1_CODGRU
			VP2->VP2_NUMCOT := VP1->VP1_NUMCOT
			VP2->VP2_CODCLI := VP1->VP1_CODCLI
			VP2->VP2_LOJA   := VP1->VP1_LOJA
			VP2->VP2_NUMPAR := strzero(i,3)
			VP2->VP2_DATPAR := wDt2
			VP2->VP2_CODBEM := cCodBem
			VP2->VP2_VALBEM := wValorBem
			VP2->VP2_PERIDE := nPerIde
			VP2->VP2_VALPAR := nValPar - VP2->VP2_VALLAN
			VP2->VP2_VALDES := wVLDESP+(wDESCOB+wOUTDES)
			VP2->VP2_PERPAG := (VP2->VP2_PARPAG / wValorBem ) * 100
			If VP2->VP2_PERPAG > 0
				VP2->VP2_PERDIf := nPerIde - VP2->VP2_PERPAG
			Else
				VP2->VP2_PERDIf := 0
			EndIf
			VP2->VP2_PERSAL := nPerSal - VP2->VP2_PERPAG
			If VP2->VP2_VALPAR == 0
				VP2->VP2_VALDES := 0
			EndIf
			If !wachou
				VP2->VP2_NUMBOL := GetSxeNum("VP2","VP2_NUMBOL")
				ConfirmSx8()
			EndIf
			MsUnlock()
			nPerPag := nPerPag + VP2->VP2_PERPAG
			nPerLan := nPerLan + VP2->VP2_PERLAN
			nPerSal := nPerSal - VP2->VP2_PERPAG
		EndIf
	Next

	DbSelectArea("VP2")
	DbGotop()
	DbSeek(xFilial("VP2")+Arg1)
	while !EOF() .and. VP2->VP2_CODGRU+VP2->VP2_NUMCOT+VP2->VP2_CODCLI+VP2->VP2_LOJA == Arg1
		RecLock("VP2",.f.)
		VP2->VP2_PERSAL := nPerSal - VP2->VP2_PERPAG
		nPerSal := nPerSal - VP2->VP2_PERPAG
		MsUnlock()
		DbSkip()
	Enddo

	DbSelectArea("VP1")
	RecLock("VP1",.f.)
	VP1->VP1_PERLAN := nPerLan
	VP1->VP1_PERPAG := nPerPag
	VP1->VP1_VALCRE := wValorBem
	MsUnlock()

	If Arg3
		If Arg2 == 1
			MsgInfo(STR0165,STR0160)
		Else
			MsgInfo(STR0166,STR0160)
		EndIf
	EndIf

ElseIf Arg2 == 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica se ja foi feita alguma exclusao                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("VP2")
	DbGotop()
	nCont := 0
	If DbSeek(xFilial("VP2")+Arg1)
		while !EOF() .and. VP2_CODGRU+VP2_NUMCOT+VP2_CODCLI+VP2_LOJA == Arg1
			If Empty(VP2_DATPAG)
				If VP2_PARANT > 0 .and. VP2_SALANT > 0
					nCont++
				EndIf
			EndIf
			DbSkip()
		Enddo
	EndIf
	If nCont == 0
		If Arg3
			MsgStop(STR0167,STR0160)
		EndIf
		Return .f.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica quando o Lance foi do Final p/ o Inicio             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If VP4->VP4_PARINI == "2"
		DbSelectArea("VP2")
		DbGotop()
		nCont := 0
		If DbSeek(xFilial("VP2")+Arg1)
			while !EOF() .and. VP2_CODGRU+VP2_NUMCOT+VP2_CODCLI+VP2_LOJA == Arg1
				If Empty(VP2_DATPAG) .and. VP2_VALPAR > 0
					nCont++
				EndIf
				DbSkip()
			Enddo
		EndIf
		If nCont == 0
			Return .f.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o VP1 - Cadastro de Participantes                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("VP1")
	DbGotop()
	If DbSeek(xFilial("VP1")+VP4->VP4_CODGRU+VP4->VP4_NUMCOT+VP4->VP4_CODCLI+VP4->VP4_LOJA)
		RecLock("VP1",.f.)
		VP1->VP1_PERLAN := VP1->VP1_PERLAN - VP4->VP4_PERLAN
		VP1->VP1_PERPAG := VP1->VP1_PERPAG - VP4->VP4_PERLAN
		nNumPar := VP1->VP1_QTDPAR
		MsUnlock()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Volta as Parcelas com Valores Anteriores                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("VP3")
	DbGotop()
	nValDes := 0
	If DbSeek(xFilial("VP3")+VP4->VP4_CODGRU)
		nValDes := VP3_VALDES
	EndIf
	DbSelectArea("VP2")
	DbGotop()
	If DbSeek(xFilial("VP2")+Arg1)
		while !EOF() .and. VP2_CODGRU+VP2_NUMCOT+VP2_CODCLI+VP2_LOJA == Arg1
			If Empty(VP2_DATPAG)
				RecLock("VP2",.f.)
				VP2_VALPAR := VP2_PARANT
				VP2_PARPAG := VP2_PGTANT
				VP2_VALDES := nValDes+VP1->VP1_DESCBP

				VP2_PERLAN := VP2_LANANT
				VP2_VALLAN := VP2_VALANT
				VP2_PERPAG := VP2_PERANT
				VP2_PERSAL := VP2_SALANT
				VP2_TOTPAG := VP2_VALLAN

				If VP2_VALPAR == 0
					VP2_TOTPAG := (VP2_VALBEM/100)*VP2_PERPAG
				EndIf

				VP2_PARANT := 0
				VP2_PGTANT := 0
				VP2_LANANT := 0
				VP2_VALANT := 0
				VP2_PERANT := 0
				VP2_SALANT := 0
				MsUnlock()
			EndIf
			DbSkip()
		Enddo
	EndIf

	DbSelectArea("VP1")
	RecLock("VP1",.f.)
	VP1_PARPAG := VP2->VP2_PERSAL
	VP1_VALCRE := wValorBem
	MsUnlock()

EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_VALPAR³ Autor ³ Andr‚                 ³ Data ³ 14/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ LEVANTAMENTO DE PARCELAS P/ ABATIMENTO DE LANCE I->F       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Arg1 = Codigo do Grupo + Numero da Cota + Codigo do Cliente³±±
±±³          ³ Arg2 = Valor do Lance                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GRUPO VIP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_VALPAR(Arg1,Arg2)

DbSelectArea("VP2")
DbGotop()
DbSeek(xFilial("VP2")+Arg1)
nQtdPar := 0
while !EOF() .and. VP2_CODGRU+VP2_NUMCOT+VP2_CODCLI+VP2_LOJA == Arg1
	if VP2_VALPAR > 0
		nQtdPar++
	Endif
	DbSkip()
Enddo

nQtdFim := 0

while nQtdPar > 0 .and. nQtdPar != nQtdFim
	DbGotop()
	DbSeek(xFilial("VP2")+Arg1)
	while !EOF() .and. VP2_CODGRU+VP2_NUMCOT+VP2_CODCLI+VP2_LOJA == Arg1
		if VP2_VALPAR >= (Arg2 / nQtdPar)
			nQtdFim++
		Endif
		DbSkip()
	Enddo
	if nQtdPar == nQtdFim
		Exit
	Endif
	nQtdPar := nQtdFim
	nQtdFim := 0
Enddo

Return(nQtdPar)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_RELATORIO³ Autor ³ Andr‚                 ³ Data ³ 22/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Descri‡ao ³ Funcao Geral de Criacao de Relatorio                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FG_RELATORIO(vTitRel,vAlias,vOrdem,vChave,vFiltro,vCampos,vTipRel)

//vAlias  := {"Alias1","Alias2","..."}
//vOrdem  := {"Ordem Arquivo1","Ordem Arquivo2","..."}
//vTitRel := {"Nome do Relatorio"}
//           {"Titulo do Relatorio"}
//           {"Descricao do Relatorio"}
//           {"Nome do Programa"}
//           {"Cabecalho1"}
//           {"Cabecalho2"}
//vChave  := {"Chave do Arquivo1","Chave do Arquivo2","..."}
//vFiltro := {"Filtro do Arquivo1","Filtro do Arquivo2","..."}
//vCampos := {"Campos do Arquivo1 separados por #","..."}
//vTipRel := {"H","V","..."}   // H=Horizontal V=Vertical

LOCAL i := 0
LOCAL _ni := 0
LOCAL j := 0
LOCAL x := 0
PRIVATE aReturn  := { (STR0004), 1,(STR0005), 2, 2, 2,,1 }  //"Zebrado"###"Administracao"

For i:=1 to Len(vAlias)

	cAlias  := vAlias[i]
	cNomRel := vTitRel[1]
	cGPerg  := "Nao Sei"
	cTitulo := vTitRel[2]
	cDesc1  := vTitRel[3]
	aOrdem  := vOrdem[i]
	lHabil  := .f.
	cTamanho:= "P"
	nOpca   := 0

	NomeRel := SetPrint(cAlias,cNomRel,cGPerg,@cTitulo,cDesc1,,,lHabil,aOrdem,,cTamanho)

	if nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cAlias)

	Set Printer to &NomeRel
	Set Printer On
	Set Device  to Printer

	cbTxt    := Space(10)
	cbCont   := 0
	cString  := "VP3"
	Li       := 80
	m_Pag    := 1
	wnRel    := vTitRel[1]
	cTitulo  := vTitRel[2]
	cabec1   := vTitRel[5]
	cabec2   := vTitRel[6]
	nomeprog := vTitRel[4]
	tamanho  := "M"
	nCaracter:= 15
	nLin     := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	aPosGru  := {}

	DbSelectArea(vAlias[i])
	DbGotop()
	if DbSeek(xFilial(cAlias)+vChave[i])

		nUsado:=0
		dbSelectArea("SX3")
		dbSeek(cAlias)
		a1&cAlias :={}
		While !Eof().And.(x3_arquivo==cAlias)
			if X3USO(x3_usado).and.cNivel>=x3_nivel.and.IIf(len(vCampos[i])>0,x3_campo $ vCampos[i,1],.t.)
				nUsado:=nUsado+1
				aadd(a1&cAlias,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )
			Endif
			dbSkip()
		End

		a2&cAlias :={}
		dbSelectArea(cAlias)
		dbSetOrder(1)
		dbSeek(xFilial(cAlias)+vChave[i])
		While !eof() .and. vFiltro[i]
			AADD(aVP12,Array(nUsado+1))
			For _ni:=1 to nUsado
				aVP12[Len(aVP12),_ni]:=FieldGet(FieldPos(aVP11[_ni,2]))
			Next
			aVP12[Len(aVP12),nUsado+1]:=.F.
			dbSkip()
		End

	Endif

Next

For i:=1 to Len(vAlias)

	cAlias := vAlias[i]

	@ nLin,0 PSAY Repl("*",132)

	if vTipRel[i] == "V"

		For i:=1 to Len(a2&cAlias)
			For j:=1 to Len(a1cAlias)
				@ ++nLin,001 PSAY a1&cAlias[j,1]
				@ nLin  ,015 PSAY a2&cAlias[i,j]
				if j+1 <= Len(aVP11)
					j++
					@ nLin,040 PSAY  a1&cAlias[j,1]
					@ nLin,055 PSAY  a2&cAlias[i,j]
				Endif
			Next
		Next

	Else

		For x:=1 to Len(a1&cAlias)
			@ nLin,Col PSAY  Substr(a1&cAlias[x,1],1,a1&cAlias[x,4])
			if Col < 133
				Col := Col + a1&cAlias[x,4]+2
			Else
				Col := 001
				nLin++
			Endif
		Next

		Col := 001
		nLin++

		For i:=1 to Len(a2&cAlias)
			For j:=1 to Len(a1&cAlias)
				if a1&cAlias[j,8] == "C"
					@ nLin,Col PSAY  a2&cAlias[i,j]
				Elseif aVP21[j,8] == "N"
					aVP22[i,j] := Trans(a2&cAlias[i,j],a1&cAlias[j,3])
					@ nLin,Col PSAY  a2&cAlias[i,j]
				Else
					@ nLin,Col PSAY  a2&cAlias[i,j]
				Endif
				if Col < 133
					Col := Col + a1&cAlias[j,4]+2
				Else
					Col := 001
					nLin++
				Endif
			Next
			Col := 001
			nLin++
		Next

	Endif

	if Len(vAlias) > 1
		@ ++nLin,1 PSAY Repl("-",131)
	Endif

	Col := 001
	nLin++

Next

@ nLin++,0 PSAY Repl("=",132)

Set Printer to
Set Device  to Screen

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_CDOW     ³ Autor ³ Fabio                 ³ Data ³ 04/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Descri‡ao ³ Retorma String com o dia da semana                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_CDOW(dData)

Do Case
	Case Upper(Alltrim(Cdow(dData))) == "SUNDAY"
		cData := STR0088
	Case Upper(Alltrim(Cdow(dData))) == "MONDAY"
		cData := STR0089
	Case Upper(Alltrim(Cdow(dData))) == "TUESDAY"
		cData := STR0090
	Case Upper(Alltrim(Cdow(dData))) == "WEDNESDAY"
		cData := STR0091
	Case Upper(Alltrim(Cdow(dData))) == "THURSDAY"
		cData := STR0092
	Case Upper(Alltrim(Cdow(dData))) == "FRIDAY"
		cData := STR0093
	Otherwise
		cData := STR0094
EndCase

Return(cData)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_SDOPECREQ³ Autor ³ Fabio                 ³ Data ³ 04/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNumOsv := Numero da OS                                      ³±±
±±³          ³ cGruIte := Grupo do Item                                     ³±±
±±³          ³ cCodIte := Codigo do Item                                    ³±±
±±³          ³ cCodCli := Codigo do Cliente , Se informado filtra saldo do  ³±±
±±³          ³            cliente.       Uso Nao Obrigatorio                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Descri‡ao ³ Retorma Quantidade do item que foi requisitada               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FG_SDOPECREQ(cNumOsv,cGruIte,cCodIte,cCodCli)

aQtdValor := {}
cSelect   := Alias()
nValPec   := 0
nQuantReq := nQuantDev := 0

nRecnoVO2 := VO2->(recno())
nRecnoVO3 := VO3->(recno())
nRecnoVO1 := VO1->(recno())
nRecnoVV1 := VV1->(recno())
nRecnoVE4 := VE4->(recno())
nRecnoVOI := VOI->(recno())

DbSelectArea("VO1")
DbSetOrder(1)
DbSeek(xFilial("VO1")+cNumOsv)

DbSelectArea("VV1")
DbSetOrder(1)
DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)

DbSelectArea("VE4")
DbSetOrder(1)
DbSeek(xFilial("VE4")+VV1->VV1_CODMAR)

DbSelectArea("VO2")
DbSetOrder(1)
DbSeek(xFilial("VO2")+cNumOsv)
while !Eof() .and. VO2->VO2_NUMOSV == cNumOsv
	DbSelectArea("VO3")
	DbSetOrder(1)
	DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM)
	while !Eof() .And. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM
		cCliente := IIf(cCodCli != NIL,cCodCli,VO3->VO3_FATPAR)
		If VO3->VO3_FATPAR==cCliente .And. (VO3->VO3_GRUITE+VO3->VO3_CODITE == cGruIte+cCodIte)

			DbSelectArea("VOI")
			DbSetOrder(1)
			DbSeek(xFilial("VOI")+VO3->VO3_TIPTEM)

			If VO2->VO2_DEVOLU == "1"
				nQuantReq := nQuantReq + VO3->VO3_QTDREQ
			Else
				nQuantDev := nQuantDev + VO3->VO3_QTDREQ
			EndIf

			If VOI->VOI_VLPCAC == "1"
				nValPec := VO3->VO3_VALPEC
			Else
				nValPec := FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.)
			EndIf

		EndIf

		DbSelectArea("VO3")
		DbSkip()
	EndDo

	DbSelectArea("VO2")
	DbSkip()
EndDo


VO2->(dbgoto(nRecnoVO2))
VO3->(dbgoto(nRecnoVO3))
VO1->(dbgoto(nRecnoVO1))
VV1->(dbgoto(nRecnoVV1))
VE4->(dbgoto(nRecnoVE4))
VOI->(dbgoto(nRecnoVOI))

Aadd(aQtdValor,{nQuantReq-nQuantDev,nValPec})

If !Empty(cSelect)
	DbSelectArea(cSelect)
EndIf

Return(aQtdValor)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_ResAva ³ Autor ³Manoel/Andre           ³ Data ³ 28/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta o Resultado da Venda/Simul Veiculo/Peca/Servico  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FG_ResAva(cOutMoed,nOpc) - 2a.Moeda p/Calculo,Opcao do Menu³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_ResAva(cOutMoed,nOpc,cSimVda,cTipSai,cPrg,aStruSrv)

Local aTitles
Local nOpca    := 0
Local cCor1 := FS_PegaCor(VS5->VS5_PRICOR)
Local cCor2 := FS_PegaCor(VS5->VS5_SEGCOR)
Local cCor3 := FS_PegaCor(VS5->VS5_TERCOR)
Local i		:= 0
Local alb	:= 0
Local oAuxContainer
Local cCadastroAux := cCadastro

cCadastro := STR0168
cMoedCor := GetMv("MV_SIMB1")

//Private aNewBot := {{"DBG07","FG_MostErro()",STR0169}}
//For i:=1 to Len(aNewBot)
//	Private cFunc&(alltrim(Str(i))) := aNewBot[i,2]
//Next

Private aListIte := {{STR0170,""}}
Private aListSrv := {{STR0170,""}}
Private aListOSV := {{STR0170,""}}
Private aLista   := aClone(aListIte)
Private aLista2  := aClone(aListIte)
Private aLista3  := aClone(aListIte)
Private aListaS  := aClone(aListSrv)
Private oLbFicVei
Private oLbFicVei2
Private oLbFicVei3
Private oLbFicPec
Private oOk     := LoadBitmap( GetResources(), "LBOK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )
Private oObjCor1:= LoadBitmap( GetResources(), cCor1 )
Private oObjCor2:= LoadBitmap( GetResources(), cCor2 )
Private oObjCor3:= LoadBitmap( GetResources(), cCor3 )
Private oObjCor4:= LoadBitmap( GetResources(), "BR_CINZA" )

Private aStruLB := {}
Private aStruLBS:= {}
Private aStruLBO:= {}

If Pcount() == 4
	lPrgSai := ""
EndIf

If aStruSrv != Nil
	aStru  := aClone(aStruSrv[1])
	aStruS := aClone(aStruSrv[2])
	aStruO := aClone(aStruSrv[3])
EndIf

If cSimVda == "V"
	For alb := 1 to len(aStru)
		If aStru[alb,6] == "0" // Sintetico
			aadd(aStruLB,{aStru[alb,01],aStru[alb,02],aStru[alb,03],aStru[alb,04],aStru[alb,05],;
			aStru[alb,06],aStru[alb,07],aStru[alb,08],aStru[alb,09],aStru[alb,10],;
			aStru[alb,11],aStru[alb,12],aStru[alb,13],aStru[alb,14],aStru[alb,15],;
			aStru[alb,16],aStru[alb,17],aStru[alb,18],aStru[alb,19],aStru[alb,20],;
			aStru[alb,21],aStru[alb,22]})
		EndIf
	Next
ElseIf cSimVda == "P"
	For alb := 1 to len(aStru)
		If aStru[alb,3] == STR0170
			If aStru[alb,6] == "0" // Sintetico
				aadd(aStruLB,{aStru[alb,01],aStru[alb,02],aStru[alb,03],aStru[alb,04],aStru[alb,05],;
				aStru[alb,06],aStru[alb,07],aStru[alb,08],aStru[alb,09],aStru[alb,10],;
				aStru[alb,11],aStru[alb,12],aStru[alb,13],aStru[alb,14],aStru[alb,15],aStru[alb,16],aStru[alb,17],aStru[alb,18],aStru[alb,19],aStru[alb,20],aStru[alb,21],aStru[alb,22]})
			EndIf
		EndIf
		lExiste := .f.
		For i:=1 to Len(aListIte)
			If aLista[i,1] == aStru[alb,3]
				lExiste := .t.
			EndIf
		Next
		If lExiste == .f.
			cAlias := Alias()
			dbSelectArea("SB1")
			Dbsetorder(1)
			DbSeek(xFilial("SB1")+aStru[alb,3])
			If !Empty(cAlias)
				DbSelectarea(cAlias)
			EndIf
			aadd(aLista  ,{SB1->B1_COD,SB1->B1_DESC})
			aadd(aListIte,{SB1->B1_GRUPO+"-"+SB1->B1_CODITE,SB1->B1_DESC})
		EndIf
	Next
ElseIf cSimVda == "S"
	// Pecas
	For alb := 1 to len(aStru)
		If aStru[alb,3] == STR0170
			If aStru[alb,6] == "0" // Sintetico
				aadd(aStruLB,{aStru[alb,01],aStru[alb,02],aStru[alb,03],aStru[alb,04],aStru[alb,05],;
				aStru[alb,06],aStru[alb,07],aStru[alb,08],aStru[alb,09],aStru[alb,10],;
				aStru[alb,11],aStru[alb,12],aStru[alb,13],aStru[alb,14],aStru[alb,15],aStru[alb,16],aStru[alb,17],aStru[alb,18],aStru[alb,19],aStru[alb,20],aStru[alb,21],aStru[alb,22]})
			EndIf
		EndIf
		lExiste := .f.
		For i:=1 to Len(aListIte)
			If aLista[i,1] == aStru[alb,3]
				lExiste := .t.
			EndIf
		Next
		If lExiste == .f.
			cAlias := Alias()
			dbSelectArea("SB1")
			Dbsetorder(1)
			DbSeek(xFilial("SB1")+aStru[alb,3])
			If !Empty(cAlias)
				DbSelectarea(cAlias)
			EndIf
			aadd(aLista  ,{SB1->B1_COD,SB1->B1_DESC})
			aadd(aListIte,{SB1->B1_GRUPO+"-"+SB1->B1_CODITE,SB1->B1_DESC})
		EndIf
	Next

	// Servicos

	For alb := 1 to len(aStruS)
		If aStruS[alb,3] == STR0170
			If aStruS[alb,6] == "0" // Sintetico
				aadd(aStruLBS,{aStruS[alb,01],aStruS[alb,02],aStruS[alb,03],aStruS[alb,04],aStruS[alb,05],;
				aStruS[alb,06],aStruS[alb,07],aStruS[alb,08],aStruS[alb,09],aStruS[alb,10],;
				aStruS[alb,11],aStruS[alb,12],aStruS[alb,13],aStruS[alb,14],aStruS[alb,15],aStruS[alb,16],aStruS[alb,17],aStruS[alb,18],aStruS[alb,19],aStruS[alb,20],aStruS[alb,21],aStruS[alb,22]})
			EndIf
		EndIf
		lExiste := .f.
		For i:=1 to Len(aListSrv)
			If len(aListaS) > 0
				If aListaS[i,1] == aStruS[alb,3]
					lExiste := .t.
				EndIf
			EndIf
		Next
		If lExiste == .f.
			cAlias := Alias()
			dbSelectArea("VO6")
			Dbsetorder(2)
			DbSeek(xFilial("VO6")+ FG_MARSRV(VV1->VV1_CODMAR,aStruS[alb,3]) + aStruS[alb,3] )
			If !Empty(cAlias)
				DbSelectarea(cAlias)
			EndIf
			aadd(aListaS ,{VO6->VO6_CODSER,VO6->VO6_DESSER})
			aadd(aListSrv,{VO6->VO6_CODSER,VO6->VO6_DESSER})
		EndIf
	Next

	// Ordem de Servico

	For alb := 1 to len(aStruO)
		If aStruO[alb,3] == STR0170
			If aStruO[alb,6] == "0" // Sintetico
				aadd(aStruLBO,{aStruO[alb,01],aStruO[alb,02],aStruO[alb,03],aStruO[alb,04],aStruO[alb,05],;
				aStruO[alb,06],aStruO[alb,07],aStruO[alb,08],aStruO[alb,09],aStruO[alb,10],;
				aStruO[alb,11],aStruO[alb,12],aStruO[alb,13],aStruO[alb,14],aStruO[alb,15],aStruO[alb,16],aStruO[alb,17],aStruO[alb,18],aStruO[alb,19],aStruO[alb,20],aStruO[alb,21],aStruO[alb,22]})
			EndIf
		EndIf
		lExiste := .f.
		For i:=1 to Len(aListOSV)
			If aLista3[i,1] == aStruO[alb,3]
				lExiste := .t.
			EndIf
		Next
	Next

EndIf

If Len(aStruLB) == 0
	aadd(aStruLB,{"","","","","","","","",0,0,"",0,0,.f.,0,0,"","","",0,0,""})
EndIf
If Len(aStruLBS) == 0
	aadd(aStruLBS,{"","","","","","","","",0,0,"",0,0,.f.,0,0,"","","",0,0,""})
EndIf
If Len(aStruLBO) == 0
	aadd(aStruLBO,{"","","","","","","","",0,0,"",0,0,.f.,0,0,"","","",0,0,""})
EndIf
For alb := 1 to Len(aStruLBS)
	aStruLBS[alb,10] := ( aStruLBS[alb,9]/aStruLBS[1,9] ) * 100
Next
For alb := 1 to Len(aStruLBO)
	aStruLBO[alb,10] := ( aStruLBO[alb,9]/aStruLBO[1,9] ) * 100
Next
For alb := 1 to Len(aStruLB)
	aStruLB[alb,10] := ( aStruLB[alb,9]/aStruLB[1,9] ) * 100
Next
If cPrg == "VEIVC050"
	FG_PrtFic()
	Return
EndIf

lCarrBot := .t.

If cSimVda == "S"
	aTitles := { STR0171,STR0172,STR0025 }
EndIf

DEFINE MSDIALOG oDlgVV TITLE STR0168 FROM  000,030 TO 040,160 OF oMainWnd

Dlg1 := oDlgVV

If cSimVda == "S"
	@ 001,001 FOLDER oFolderAva SIZE 001,001 OF oDlgVV PROMPTS aTitles[1],aTitles[2],aTitles[3] PIXEL
	oFolderAva:Align := CONTROL_ALIGN_ALLCLIENT
	oFolderAva:bSetOption := {|x| FS_PEGFAI(x)}
EndIf

oAuxContainer := IIf(cSimVda == "S",oFolderAva:aDialogs[1],oDlgVV)

@ 001,001 LISTBOX oLbFicVei FIELDS HEADER  (""),;                   // Indicador de Resultado
	(STR0174),;    // Titulo das Colunas
	(STR0100)+cMoedCor,;
	("       %"),;
	(STR0100)+cOutMoed,;    //cSimOMoe
	("       %"),;
	(STR0136),;             // Valor Presente
	("       %");
	COLSIZES 10,90,50,20,50,20,50,20;
	SIZE 001,001 OF oAuxContainer PIXEL ;
	ON DBLCLICK (nPos:=oLbFicVei:nAt,;
						FG_FilLB010(),;
						oLbFicVei:Refresh(),;
						oLbFicVei:nAt:=nPos,;
						IIf(len(aStru) > 0,(IIf(aStruLb[oLbFicVei:nAt,14]==.f.,aStruLb[oLbFicVei:nAt,14]:=.t.,aStruLb[oLbFicVei:nAt,14]:=.f.)),.f.))

oLbFicVei:Align := CONTROL_ALIGN_ALLCLIENT
oLbFicVei:SetArray(aStruLB)
oLbFicVei:bLine := { || { FG_VeFxaRes(),aStruLB[oLbFicVei:nAt,05],;
	FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,09],"@E 9,999,999.99")),;
	FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,10],"@E 999.99")),;
	FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,12],"@E 9,999,999.99")),;
	FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,13],"@E 999.99")),;
	FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,20],"@E 9,999,999.99")),;
	FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,21],"@E 999.99"))}}

If cSimVda $ "SP"

	@ 001,001 LISTBOX oLbFicPec FIELDS HEADER  (STR0175),;
		(STR0176);
		COLSIZES 200,240;
		SIZE 400,100 OF oAuxContainer PIXEL ON DBLCLICK (nPos:=oLbFicPec:nAt,FG_FILTITE(aLista[oLbFicPec:nAt,01],cSimVda),oLbFicPec:Refresh())
	oLbFicPec:Align := CONTROL_ALIGN_BOTTOM

	FG_FILTITE(aLista[oLbFicPec:nAt,01],"P")

	oLbFicPec:SetArray(aListIte)
	oLbFicPec:bLine := { || { aListIte[oLbFicPec:nAt,01], aListIte[oLbFicPec:nAt,02]}}

	oPanSeparacao := TPanel():New(0,0,"",oAuxContainer,NIL,.T.,.F.,NIL,NIL,0,3,.T.,.F.)
	oPanSeparacao:Align :=  CONTROL_ALIGN_BOTTOM

EndIf


If cSimVda == "S"

	// Servicos
	@ 001,001 LISTBOX oLbFicVei2 FIELDS HEADER  (""),; // Indicador de Resultado
		(STR0177),; // Titulo das Colunas
		(STR0100)+cMoedCor,;
		("       %"),;
		(STR0100)+cOutMoed,; //cSimOMoe
		("       %"),;
		(STR0136),; // Valor Presente
		("       %");
		COLSIZES 10,90,50,20,50,20,50,20;
		SIZE 001,001 OF oFolderAva:aDialogs[2] PIXEL ;
		ON DBLCLICK (nPos:=oLbFicVei2:nAt,;
							FG_FilLB010(oLbFicVei2:nAt,"aStruLBS","aStruS"),;
							oLbFicVei2:Refresh(),;
							oLbFicVei2:nAt:=nPos,;
							IIf(!aStruLbS[oLbFicVei2:nAt,14],aStruLbS[oLbFicVei2:nAt,14]:=.t.,aStruLbS[oLbFicVei2:nAt,14]:=.f.))
    oLbFicVei2:Align := CONTROL_ALIGN_ALLCLIENT
	oLbFicVei2:SetArray(aStruLBS)
	oLbFicVei2:bLine := { || { FG_VeFxaRes("aStruLBS"),aStruLBS[oLbFicVei2:nAt,05],;
		FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,09],"@E 9,999,999.99")),;
		FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,10],"@E 999.99")),;
		FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,12],"@E 9,999,999.99")),;
		FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,13],"@E 999.99")),;
		FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,20],"@E 9,999,999.99")),;
		FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,21],"@E 999.99"))}}

	@ 001,001 LISTBOX oLbFicSer FIELDS HEADER  (STR0178),;
		(STR0176);
		COLSIZES 060,240;
		SIZE 400,100 OF oFolderAva:aDialogs[2] PIXEL ON DBLCLICK (nPos:=oLbFicSer:nAt,FG_FILTSRV(aListaS[oLbFicSer:nAt,01],cSimVda),oLbFicSer:Refresh())
    oLbFicSer:Align := CONTROL_ALIGN_BOTTOM
	oLbFicSer:SetArray(aListSrv)
	oLbFicSer:bLine := { || { aListSrv[oLbFicSer:nAt,01],;
		aListSrv[oLbFicSer:nAt,02]}}

	oPanSeparacao2 := TPanel():New(0,0,"",oFolderAva:aDialogs[2],NIL,.T.,.F.,NIL,NIL,0,3,.T.,.F.)
	oPanSeparacao2:Align :=  CONTROL_ALIGN_BOTTOM		

	// Ordem de Servico

	@ 001,001 LISTBOX oLbFicVei3 FIELDS HEADER  (""),; // Indicador de Resultado
		(STR0177),; // Titulo das Colunas
		(STR0100)+cMoedCor,;
		("       %"),;
		(STR0100)+cOutMoed,; // Moeda Forte
		("       %"),;
		(STR0136),; // Valor Presente
		("       %");
		COLSIZES 10,90,50,20,50,20,50,20;
		SIZE 001,001 OF oFolderAva:aDialogs[3] PIXEL ON DBLCLICK (nPos:=oLbFicVei3:nAt,FG_FIlLB010(oLbFicVei3:nAt,"aStruLBO","aStruO"),oLbFicVei3:Refresh(),;
		oLbFicVei3:nAt := nPos, IIf( !aStruLbO[oLbFicVei3:nAt,14] , aStruLbO[oLbFicVei3:nAt,14] := .t. , aStruLbO[oLbFicVei3:nAt,14] := .f.))
	oLbFicVei3:Align := CONTROL_ALIGN_ALLCLIENT
	oLbFicVei3:SetArray(aStruLBO)
	oLbFicVei3:bLine := { || { FG_VeFxaRes("aStruLBO"),aStruLBO[oLbFicVei3:nAt,05],;
		FG_AlinVlrs(Transform(aStruLBO[oLbFicVei3:nAt,09],"@E 9,999,999.99")),;
		FG_AlinVlrs(Transform(aStruLBO[oLbFicVei3:nAt,10],"@E 999.99")),;
		FG_AlinVlrs(Transform(aStruLBO[oLbFicVei3:nAt,12],"@E 9,999,999.99")),;
		FG_AlinVlrs(Transform(aStruLBO[oLbFicVei3:nAt,13],"@E 999.99")),;
		FG_AlinVlrs(Transform(aStruLBO[oLbFicVei3:nAt,20],"@E 9,999,999.99")),;
		FG_AlinVlrs(Transform(aStruLBO[oLbFicVei3:nAt,21],"@E 999.99"))}}
EndIf

nOpca := 0

if  cPrg $ "VEIVM010#VEIVC050#OFIOM170"
	ACTIVATE MSDIALOG oDlgVV CENTER ON INIT EnchoiceBar(oDlgVV,{||IIf(nopca != 1,nOpca := 2,nopca:=1),oDlgVV:End()},{||nOpca := 2,oDlgVV:End()},,)
else
	ACTIVATE MSDIALOG oDlgVV CENTER ON INIT EnchoiceBar(oDlgVV,{||nOpca := 1,oDlgVV:End()},{||nOpca := 2,oDlgVV:End()},,)
EndIf

cCadastro := cCadastroAux

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_PEGFAI     ³ Autor ³  Manoel          ³ Data ³ 24/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Veiculos/Oficina                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PEGFAI(nAbaAtu)

Do Case
	Case nAbaAtu == 1
		FG_Seek("VS5","cMapPecas",1,.f.)
		oFolderAva:nOption := 1
	Case nAbaAtu == 2
		FG_Seek("VS5","cMapSrvcs",1,.f.)
		oFolderAva:nOption := 2
	OtherWise
		FG_Seek("VS5","cMapOdSrv",1,.f.)
		oFolderAva:nOption := 3
EndCase

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_CalcVlrs   ³ Autor ³  Manoel          ³ Data ³ 24/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fg_CalcVlrs()    Processa Vetor p/ Simulacao/Avaliacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta Array p/ Calculo da Simulacao / Avaliacao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Vetor com Dados a Serem Avaliados / Cod do Produto Avaliado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos/Oficina                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_CalcVlrs(aStru,cCod,cCpoDivP,lSM2,aFormul,lMapVei,cAuxNumOsv)

Local bBlock:=ErrorBlock(),bErro := ErrorBlock( { |e| FGX_CheckBug(e,cCodFormul,cDesFormul) } )
Local cNMF := Alltrim(GetMv("MV_INDMFT"))
Local cSavAlias := alias()
Local nDivis := 0
Local nDivOm := 0
Local nDivMp := 0
Local ct	 := 0
Local ct1	 := 0
Local nPosCpo := 1
Local lFormul := .f.
Local dPesqSM2 := CtoD(" ")
Private cCodFormul := ""
Private cDesFormul := ""
Default lMapVei := ( GetNewPar("MV_CODMAPV","001") == cCodMap )
If Type("lPriVez") == "U"
	Private lPriVez := .t.
Endif
Default lSM2 := .t.
Default aFormul := {}
Default cCpoDivP := "    1"
Default cAuxNumOsv := ""
If len(aFormul) > 0
	lFormul := .t.
EndIf
If type("cCpoDiv") <> "U"
	cCpoDivP := cCpoDiv
EndIf

If cCod <> Nil
	nPosCpo := Ascan(aStru,{|x| x[3] == cCod .and. IIf( !Empty(cAuxNumOsv) , x[1] == cAuxNumOsv , .t. ) })
	If nPosCpo == 0
		nPosCpo := 1
	EndIf
EndIf

For ct := nPosCpo to len(aStru)
	If !cCod == nil
		If aStru[ct,3] != cCod
			Exit
		EndIf
	EndIf
	//    If (aStru[ct,09] +  aStru[ct,12] +  aStru[ct,20]) == 0
	If aStru[ct,6] != "0" //Analitico
		If lFormul
			cCodFormul   := aFormul[ct,3] // Codigo da Formula Moeda Normal
			cDesFormul   := aFormul[ct,1] // Conteudo da Formula Moeda Normal
			aStru[ct,9]  := &(Alltrim(aFormul[ct,1])) // Normal
			cCodFormul   := aFormul[ct,4] // Codigo da Formula Moeda Forte
			cDesFormul   := aFormul[ct,2] // Conteudo da Formula Moeda Forte
			aStru[ct,12] := &(Alltrim(aFormul[ct,2])) // Moeda Forte
		Else
			aStru[ct,9]  := FG_Formula(aStru[ct,7] ,ct,aStru) // Normal
			aStru[ct,12] := FG_Formula(aStru[ct,18],ct,aStru) // Moeda Forte
		EndIf
		// Quando o retorno da formula for booleano //
		If ValType(aStru[ct,9]) <> "N"
			aStru[ct,9] := 0
		EndIf
		If ValType(aStru[ct,12]) <> "N"
			aStru[ct,12] := 0
		EndIf
		//////////////////////////////////////////////
		If lSM2
			If dPesqSM2 <> aStru[ct,19]
				DbSelectArea("SM2")
				Set SoftSeek on
				DbSeek(aStru[ct,19])
				If &("SM2->M2_MOEDA"+cNMF) == 0
					dbskip(-1)
				EndIf
				If !Empty(cSavAlias)
					DbSelectArea(cSavAlias)
				EndIf
				Set SoftSeek off
				dPesqSM2 := aStru[ct,19]
			EndIf
			aStru[ct,20] := aStru[ct,12] * &("SM2->M2_MOEDA"+cNMF) // Valor Presente
		EndIf
	EndIf
	//    EndIf
Next

For ct := nPosCpo to Len(aStru)

	If !cCod == nil
		If aStru[ct,3] != cCod
			Exit
		EndIf
	EndIf

	if aStru[ct,6] == "0"     // Sintetico

		If lFormul
			cCodFormul   := aFormul[ct,3] // Codigo da Formula Moeda Normal
			cDesFormul   := aFormul[ct,1] // Conteudo da Formula Moeda Normal
			aStru[ct,9]  := &(Alltrim(aFormul[ct,1])) // Normal
			cCodFormul   := aFormul[ct,4] // Codigo da Formula Moeda Forte
			cDesFormul   := aFormul[ct,2] // Conteudo da Formula Moeda Forte
			aStru[ct,12] := &(Alltrim(aFormul[ct,2])) // Moeda Forte
		Else
			aStru[ct,9]  := FG_Formula(aStru[ct,7],ct,aStru)  // Normal
			aStru[ct,12] := FG_Formula(aStru[ct,18],ct,aStru) // Moeda Forte
		EndIf
		// Quando o retorno da formula for booleano //
		If ValType(aStru[ct,9]) <> "N"
			aStru[ct,9] := 0
		EndIf
		If ValType(aStru[ct,12]) <> "N"
			aStru[ct,12] := 0
		EndIf
		//////////////////////////////////////////////
		If lMapVei
			nContCt := 1
		Else
			nContCt := nPosCpo
		Endif

		If Type("nSvTam") != "U"
			nLimiteFor := nContCt+(nSvTam-1)
		Else
			nLimiteFor := Len(aStru)
		Endif

		For ct1 := nContCt to nLimiteFor
			if !cCod == nil
				if aStru[ct1,3] != cCod
					Exit
				Endif
			Endif
			if aStru[ct1,22] == aStru[ct,4]
				if aStru[ct1,8] == "+"
					aStru[ct,09] := aStru[ct,09] + aStru[ct1,09]
					aStru[ct,12] := aStru[ct,12] + aStru[ct1,12]
				Elseif aStru[ct1,8] == "-"
					aStru[ct,09] := aStru[ct,09] - aStru[ct1,09]
					aStru[ct,12] := aStru[ct,12] - aStru[ct1,12]
				Endif
			Endif
		Next

		if aStru[ct,09] == 0

			If lMapVei // Veiculos
				nContCt := 1
			Else
				//	           nContCt := ct
				nContCt := nPosCpo//Val(right(cCpoDiv,5))
			Endif

			//		    For ct1 := ct to len(aStru) // Alteracao para totalizar inclusive pelos itens acima na Tabela VOQ - Manoel Filho - 19/Nov/2003
			For ct1 = nContCt to len(aStru)
				if !cCod == nil
					if aStru[ct1,3] != cCod
						Exit
					Endif
				Endif
				if aStru[ct1,6] == "0" .and. aStru[ct,8] == "=" .and. aStru[ct1,22] == aStru[ct,4]
					if aStru[ct1,8] == "+"
						aStru[ct,09] := aStru[ct,09] + aStru[ct1,09]
						aStru[ct,12] := aStru[ct,12] + aStru[ct1,12]
					Elseif aStru[ct1,8] == "-"
						aStru[ct,09] := aStru[ct,09] - aStru[ct1,09]
						aStru[ct,12] := aStru[ct,12] - aStru[ct1,12]
					Endif
				Endif
			Next
		Endif
		If lSM2
			If dPesqSM2 <> aStru[ct,19]
				DbSelectArea("SM2")
				Set SoftSeek on
				DbSeek(aStru[ct,19])
				if &("SM2->M2_MOEDA"+cNMF) == 0
					DbSkip(-1)
				Endif
				Set SoftSeek off
				dPesqSM2 := aStru[ct,19]
			EndIf
			aStru[ct,20] := aStru[ct,12] * &("SM2->M2_MOEDA"+cNMF) // Valor Presente
		EndIf
	Endif
	//    EndIf

	If !cCod == nil
		If Str(ct,5) $ cCpoDivP
			nDivis := aStru[ct,9]
			nDivOm := aStru[ct,12]
			nDivMp := aStru[ct,20]
		EndIf
	Else
		If ct == 1
			nDivis := aStru[ct,9]
			nDivOm := aStru[ct,12]
			nDivMp := aStru[ct,20]
		EndIf
	EndIf

	aStru[ct,10] :=( aStru[ct,09] / nDivis ) * 100
	aStru[ct,13] :=( aStru[ct,12] / nDivOm ) * 100
	aStru[ct,21] :=( aStru[ct,20] / nDivMp ) * 100

Next

ErrorBlock(bBlock)

If !Empty(cSavAlias)
	DbSelectArea(cSavAlias)
EndIf

Return(aStru)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_MOSTERRO   ³ Autor ³  Andre           ³ Data ³ 28/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra os erros de formula na avaliacao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_MostErro()

if  Type("aErrAva") == "U"
	aErrAva := {}
	aadd(aErrAva,{"","","",""})
Else
	if Len(aErrAva) == 0
		aadd(aErrAva,{"","","",""})
	Endif
Endif
DEFINE MSDIALOG oDlgErro TITLE STR0179 From 9,10 to 28,72 of oMainWnd

@ 012,001 LISTBOX oLbxErro FIELDS HEADER  (STR0180),;
(STR0181),;
(STR0182),;
(STR0183);
COLSIZES 60,30,110,40;
SIZE 245,131 OF oDlgErro PIXEL

oLbxErro:SetArray(aErrAva)
oLbxErro:bLine := { || { aErrAva[oLbxErro:nAt,1] ,;
aErrAva[oLbxErro:nAt,2] ,;
aErrAva[oLbxErro:nAt,3] ,;
aErrAva[oLbxErro:nAt,4] }}

ACTIVATE MSDIALOG oDlgErro ON INIT ENCHOICEBAR(oDlgErro,{||oDlgErro:End()},{||oDlgErro:End()},1) CENTER

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_FILTITE    ³ Autor ³  Andre           ³ Data ³ 28/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Posicao da coluna                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtra itens para ser mostrado no listbox                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_FILTITE(cNro,cSimVda)

Local alb
Local nPosCpo

aStruLB   := {}

nPosCpo := Ascan(aStru,{|x| x[3] == cNro})
if nPosCpo == 0
	nPosCpo := 1
Endif

For alb := nPosCpo to len(aStru)
	if cSimVda $ "SP"
		If aStru[alb,3] == cNro
			If aStru[alb,6] == "0" && Sintetico
				aadd(aStruLB,{aStru[alb,01],aStru[alb,02],aStru[alb,03],aStru[alb,04],aStru[alb,05],;
				aStru[alb,06],aStru[alb,07],aStru[alb,08],aStru[alb,09],aStru[alb,10],;
				aStru[alb,11],aStru[alb,12],aStru[alb,13],aStru[alb,14],aStru[alb,15],aStru[alb,16],aStru[alb,17],aStru[alb,18],aStru[alb,19],aStru[alb,20],aStru[alb,21],aStru[alb,22]})
			Endif
		Endif
	Else
		If aStru[alb,6] == "0" && Sintetico
			aadd(aStruLB,{aStru[alb,01],aStru[alb,02],aStru[alb,03],aStru[alb,04],aStru[alb,05],;
			aStru[alb,06],aStru[alb,07],aStru[alb,08],aStru[alb,09],aStru[alb,10],;
			aStru[alb,11],aStru[alb,12],aStru[alb,13],aStru[alb,14],aStru[alb,15],aStru[alb,16],aStru[alb,17],aStru[alb,18],aStru[alb,19],aStru[alb,20],aStru[alb,21],aStru[alb,22]})
		Endif
	Endif
Next

oLbFicVei:SetArray(aStruLB)
oLbFicVei:bLine := { || { FG_VeFxaRes(),aStruLB[oLbFicVei:nAt,05],;
FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,09],"@E 9,999,999.99")),;
FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,10],"@E 999.99")),;
FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,12],"@E 9,999,999.99")),;
FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,13],"@E 999.99")),;
FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,20],"@E 9,999,999.99")),;
FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,21],"@E 999.99"))}}


oLbFicVei:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_FILTSRV    ³ Autor ³  Andre           ³ Data ³ 28/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Posicao da coluna                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtra itens para ser mostrado no listbox                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_FILTSRV(cNro,cSimVda)

Local alb := 0
aStruLBS   := {}

For alb := 1 to len(aStruS)
	if cSimVda $ "SP"
		If aStruS[alb,3] == cNro
			If aStruS[alb,6] == "0" && Sintetico
				aadd(aStruLBS,{aStruS[alb,01],aStruS[alb,02],aStruS[alb,03],aStruS[alb,04],aStruS[alb,05],;
				aStruS[alb,06],aStruS[alb,07],aStruS[alb,08],aStruS[alb,09],aStruS[alb,10],;
				aStruS[alb,11],aStruS[alb,12],aStruS[alb,13],aStruS[alb,14],aStruS[alb,15],aStruS[alb,16],;
				aStruS[alb,17],aStruS[alb,18],aStruS[alb,19],aStruS[alb,20],aStruS[alb,21],aStruS[alb,22]})
			Endif
		Endif
	Else
		If aStruS[alb,6] == "0" && Sintetico
			aadd(aStruLBS,{aStruS[alb,01],aStruS[alb,02],aStruS[alb,03],aStruS[alb,04],aStruS[alb,05],;
			aStruS[alb,06],aStruS[alb,07],aStruS[alb,08],aStruS[alb,09],aStruS[alb,10],;
			aStruS[alb,11],aStruS[alb,12],aStruS[alb,13],aStruS[alb,14],aStruS[alb,15],aStruS[alb,16],;
			aStruS[alb,17],aStruS[alb,18],aStruS[alb,19],aStruS[alb,20],aStruS[alb,21],aStruS[alb,22]})
		Endif
	Endif
Next

oLbFicVei2:SetArray(aStruLBS)
oLbFicVei2:bLine := { || { FG_VeFxaRes("aStruLbS"),aStruLBS[oLbFicVei2:nAt,05],;
FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,09],"@E 9,999,999.99")),;
FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,10],"@E 999.99")),;
FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,12],"@E 9,999,999.99")),;
FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,13],"@E 999.99")),;
FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,20],"@E 9,999,999.99")),;
FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,21],"@E 999.99"))}}

oLbFicVei2:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FG_ReconsSC  ³ Autor ³  Renata          ³ Data ³ 04/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ VerIfica a reconsideracao da Scania                 o      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_ReconsSc()

If !empty(M->VG6_RRCOLD)
	If M->VG6_RRCOLD != M->VG6_NUMRRC
		If M->VG8_RECONS = "0"
			Aviso(STR0002,STR0103,{STR0104})
		endIf
	endIf
endIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FG_ITESUB    ³ Autor ³ Andre            ³ Data ³ 20/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Funcao para ver as substituicoes do item informado        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  1=Codigo do Item                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Geral                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_ITESUB(cItem,cTipRet)

Local nCntFor
Local nPos := 0
Private  cRet  := Substr(cItem,TamSX3("B1_GRUPO")[1]+1) , nOpcao := 0
Private aItem := {} , oOk , aArea := {}
Private cSQLSUB := "TSQLSUB", cQuery
Private cGrupoOrig := Left(cItem,TamSX3("B1_GRUPO")[1])
Private cItemOrig  := cRet
Private nRecno := 0 // Variavel para nao deixar entrar em LOOP Infinito
Private bOk     := LoadBitmap( GetResources(), "LBOK" )
Private bNo     := LoadBitmap( GetResources(), "LBNO" )
Private oLbxSub
Private lGruNov := (VE9->(FieldPos("VE9_GRUNOV"))>0)

Default cTipRet := "C"

aArea := sGetArea(aArea , "VE9")
aArea := sGetArea(aArea , "SB1")
aArea := sGetArea(aArea , "SB2")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf

If FM_PILHA("OFINJD35") .OR. FM_PILHA("VEICLSAD") .OR. FM_PILHA("VEICLSAP")
	return cRet
EndIf

// Verifica se foi chamado pelo MATA297M
If FM_PILHA("MATA297M")
	Return(cRet)
Endif

//Ponto de Entrada para validar se continua na função de Substituição de Itens
If ExistBlock("VLDITSUB")
	If !ExecBlock("VLDITSUB",.f.,.f.)
		Return cRet
	Endif
EndIf

// Monta Consulta

DbSelectArea("VE9")
DbSetOrder(4)
if DbSeek(xFilial("VE9")+cRet)

	if VE9->(FieldPos("VE9_SEGMEN")) > 0
		while xFilial("VE9")+cRet == VE9->VE9_FILIAL + VE9->VE9_ITENOV
			cGruNov := ""
			if lGruNov
				cGruNov := VE9->VE9_GRUNOV
			endif
			if VE9->VE9_SEGMEN == "04"
				aadd(aItem,{.F.,dtoc(VE9->VE9_DATSUB),VE9->VE9_GRUITE,VE9->VE9_ITEANT,VE9->VE9_ITENOV,SaldoSB2(),"0000000000",cGruNov })
				exit
			endif
			DBSkip()
		enddo
	else
		cGruNov := ""
		if lGruNov
			cGruNov := VE9->VE9_GRUNOV
		endif
		aadd(aItem,{.F.,dtoc(VE9->VE9_DATSUB),VE9->VE9_GRUITE,VE9->VE9_ITEANT,VE9->VE9_ITENOV,SaldoSB2(),"0000000000",cGruNov })
	endif
endif
//
nContaLoop := 0
lAcabou := .f.
cRetComp := cRet
aResta := {}
While !lAcabou .and. nContaLoop < 500
	if lGruNov
		cQuery := "SELECT VE9.VE9_DATSUB, VE9.VE9_GRUITE, VE9.VE9_ITEANT, VE9.VE9_GRUNOV, VE9.VE9_ITENOV, VE9.VE9_NROSUB, VE9.R_E_C_N_O_ RECNO"
	else
		cQuery := "SELECT VE9.VE9_DATSUB, VE9.VE9_GRUITE, VE9.VE9_ITEANT, VE9.VE9_ITENOV, VE9.VE9_NROSUB, VE9.R_E_C_N_O_ RECNO"
	endif
	cQuery +=  " FROM " + RetSQLName("VE9")+" VE9"
	cQuery += " WHERE VE9.VE9_FILIAL = '" + xFilial("VE9") + "'"
	cQuery +=   " AND VE9.VE9_GRUITE = '" + cGrupoOrig + "'"
	cQuery +=   " AND VE9.VE9_ITEANT = '" + cRet + "'"
	cQuery +=   " AND VE9.VE9_DATSUB <= '" + DtoS(dDataBase) + "'"
	// Segmento da Substituicao / 04 = Substituicao manual
	if VE9->(FieldPos("VE9_SEGMEN")) > 0
		cQuery +=   " AND VE9.VE9_SEGMEN = '04'"
	endif
	if nRecno <> 0
		cQuery +=   " AND VE9.R_E_C_N_O_ >= " + AllTrim(Str(nRecno))
	endif
	cQuery +=   " AND VE9.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VE9.VE9_DATSUB DESC,VE9.VE9_NROSUB DESC, VE9.R_E_C_N_O_ DESC"

	//Ponto de Entrada para Alterar o SQL
	If ExistBlock("PEITESUB")
		ExecBlock("PEITESUB",.f.,.f.,{cQuery})
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSUB , .F., .T. )

	while !(cSQLSUB)->(eof())
		DbSelectArea("SB1")
		DbSetOrder(7)
		if lGruNov
			DbSeek( xFilial("SB1") + (cSQLSUB)->VE9_GRUNOV + (cSQLSUB)->VE9_ITENOV )
		else
			DbSeek( xFilial("SB1") + (cSQLSUB)->VE9_GRUITE + (cSQLSUB)->VE9_ITENOV )
		endif
		dbSelectArea("SB2")
		dbSetOrder(1)
		DbSeek( xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"))
		if lGruNov
			aadd(aItem,{.F.,DtoC(StoD((cSQLSUB)->VE9_DATSUB)),(cSQLSUB)->VE9_GRUITE,(cSQLSUB)->VE9_ITEANT,(cSQLSUB)->VE9_ITENOV,SaldoSB2(),(cSQLSUB)->VE9_NROSUB,(cSQLSUB)->VE9_GRUNOV })
			aAdd(aResta,{(cSQLSUB)->VE9_ITENOV,.f.,(cSQLSUB)->VE9_GRUNOV})
		else
			aadd(aItem,{.F.,DtoC(StoD((cSQLSUB)->VE9_DATSUB)),(cSQLSUB)->VE9_GRUITE,(cSQLSUB)->VE9_ITEANT,(cSQLSUB)->VE9_ITENOV,SaldoSB2(),(cSQLSUB)->VE9_NROSUB})
			aAdd(aResta,{(cSQLSUB)->VE9_ITENOV,.f.})
		endif

		(cSQLSUB)->(dbSkip())
	enddo

	(cSQLSUB)->(dbCloseArea())
	lAcabou := .t.
	for nCntFor := 1 to Len(aResta)
		if aResta[nCntFor,1] == cRet
			aResta[nCntFor,2] := .t.
		endif
	next
	for nCntFor := 1 to Len(aResta)
		if aResta[nCntFor,2] == .f. .and. lAcabou == .t.
			cRet := aResta[nCntFor,1]
			nContaLoop++
			lAcabou := .f.
		endif
	next
Enddo
dbSelectArea("VE9")

If Len(aItem) # 0 .and. cRetComp != cRet

	cslvReadVar := readvar()

	nOpcao := Aviso(STR0309 ,STR0310, {  STR0311 , STR0312 } )

	__readVar := cslvReadVar

	If nOpcao == 1

		aSort(aItem,,,{|x,y| x[2]+x[7] > y[2]+y[7]})

		DEFINE MSDIALOG oDlgSub TITLE (STR0309 ) FROM  02,04 TO 17,70 OF oMainWnd

		if lGruNov
			@ 015,001 LISTBOX oLbxSub FIELDS HEADER  (""),;
			(STR0313),;
			(STR0314),;
			(STR0374),;
			(STR0314),;
			(STR0315),;
			(STR0316),;
			(STR0317);
			COLSIZES 10,30,20,50,20,50,40,40;
			SIZE 260,081 OF oDlgSub PIXEL ON DBLCLICK FS_FLAGSUB(@aItem,oLbxSub:nAt,@cRet)

			oLbxSub:Align := CONTROL_ALIGN_ALLCLIENT
			oLbxSub:SetArray(aItem)
			oLbxSub:bLine := { || { IIf(aItem[oLbxSub:nAt,1],bOk,bNo) ,;
			aItem[oLbxSub:nAt,2] ,;
			aItem[oLbxSub:nAt,3] ,;
			aItem[oLbxSub:nAt,4] ,;
			aItem[oLbxSub:nAt,8] ,;
			aItem[oLbxSub:nAt,5] ,;
			aItem[oLbxSub:nAt,6] ,;
			aItem[oLbxSub:nAt,7] }}
		else
			@ 015,001 LISTBOX oLbxSub FIELDS HEADER  (""),;
			(STR0313),;
			(STR0314),;
			(STR0374),;
			(STR0315),;
			(STR0316),;
			(STR0317);
			COLSIZES 10,30,20,50,50,40,40;
			SIZE 260,081 OF oDlgSub PIXEL ON DBLCLICK FS_FLAGSUB(@aItem,oLbxSub:nAt,@cRet)

			oLbxSub:Align := CONTROL_ALIGN_ALLCLIENT
			oLbxSub:SetArray(aItem)
			oLbxSub:bLine := { || { IIf(aItem[oLbxSub:nAt,1],bOk,bNo) ,;
			aItem[oLbxSub:nAt,2] ,;
			aItem[oLbxSub:nAt,3] ,;
			aItem[oLbxSub:nAt,4] ,;
			aItem[oLbxSub:nAt,5] ,;
			aItem[oLbxSub:nAt,6] ,;
			aItem[oLbxSub:nAt,7] }}
		endif

		FS_FLAGSUB(@aItem,oLbxSub:nAt,@cRet)

		oTPanelTOP := TPanel():New(0,0,"",oDlgSub,NIL,.T.,.F.,NIL,NIL,0,16,.T.,.F.)
		oTPanelTOP:Align := CONTROL_ALIGN_TOP

		@ 004, 001 say STR0314  OF oTPanelTOP Pixel
		@ 003, 020 MSGET cGrupoOrig PICTURE "@!" SIZE 30,01 OF oTPanelTOP PIXEL COLOR CLR_BLACK When .F.

		@ 004, 080 say STR0318 OF oTPanelTOP Pixel
		@ 003, 109 MSGET cItemOrig PICTURE "@!" SIZE 100,01 OF oTPanelTOP PIXEL COLOR CLR_BLACK When .F.

		ACTIVATE MSDIALOG oDlgSub CENTER ON INIT EnchoiceBar(oDlgSub,{|| oDlgSub:End()},{|| cRet := cItemOrig ,oDlgSub:End()})

	else
		return cRetComp

	EndIf

Endif

nPos := aScan(aItem,{|x| x[1] = .t.})
If nPos > 0
	cQuery := "SELECT VE9.VE9_ITEANT, VE9.VE9_GRUNOV, SB1.R_E_C_N_O_ AS B1RECNO "
	cQuery += " FROM " + RetSQLName("VE9")+" VE9"
	cQuery += " JOIN "+RetSqlName("SB1")+" SB1 ON "
	cQuery += " ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
	cQuery +=   " SB1.B1_GRUPO=VE9.VE9_GRUITE AND "
	cQuery +=   " SB1.B1_CODITE=VE9.VE9_ITEANT AND "
	cQuery +=   " SB1.B1_MSBLQL <> '1' AND "
	cQuery +=   " SB1.D_E_L_E_T_=' ' ) "
	cQuery += " WHERE VE9.VE9_FILIAL = '" + xFilial("VE9") + "'"
	cQuery += " AND VE9.VE9_GRUNOV = '" + aItem[nPos,8] + "'"
	cQuery += " AND VE9.VE9_ITENOV = '" + cRet + "'"
	if VE9->(FieldPos("VE9_SEGMEN")) > 0
		cQuery += " AND VE9.VE9_SEGMEN = '04'"
	endif
	cQuery += " AND VE9.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VE9.VE9_GRUNOV, VE9.VE9_ITENOV"

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSUB , .F., .T. )

	While (cSQLSUB)->(!EOF())

		SB1->(Dbgoto((cSQLSUB)->(B1RECNO)))

		DbSelectArea("SB2")
		DbSetOrder(1)
		DbSeek( xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"))

		if SaldoSB2() > 0

			If FM_PILHA("OFIXC001") .or. GetNewPar("MV_CHKQSUB","N") <> "S"
				MsgStop(STR0319;
				+Chr(13)+Chr(13)+STR0321 +(cSQLSUB)->VE9_ITEANT+STR0322 +Transform(SB2->B2_QATU,"99999999.99"),STR0002)
			Else
				MsgStop(STR0319;
				+Chr(13)+STR0320;
				+Chr(13)+Chr(13)+STR0321 +(cSQLSUB)->VE9_ITEANT+STR0322 +Transform(SB2->B2_QATU,"99999999.99"),STR0002)
				cRet := (cSQLSUB)->VE9_ITEANT
			Endif
			if lGruNov
				cGruNov := (cSQLSUB)->VE9_GRUNOV
			endif
			sRestArea(aArea)
			if lGruNov
				(cSQLSUB)->(dbCloseArea()) // Fechando Area
				Return(IIf(Upper(cTipRet)=="C",{cGruNov,cRet},.f.))
			else
				(cSQLSUB)->(dbCloseArea()) // Fechando Area
				Return(IIf(Upper(cTipRet)=="C",cRet,.f.))
			endif
		EndIf

		(cSQLSUB)->(DbSkip())

	EndDo
	(cSQLSUB)->(dbCloseArea())
Endif

DbSelectArea("VE9")

If ExistBlock("CHKITESUB")
	cRet := ExecBlock("CHKITESUB",.f.,.f.)
EndIf

sRestArea(aArea)

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FLAGSUB   ³ Autor ³  Andre            ³ Data ³ 16/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 													          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FLAGSUB(aItem,nLinha,cRet)

Local nFlag := 0
Local cRetOld := cRet
Local lNov := .f.

Private lGruNov := (VE9->(FieldPos("VE9_GRUNOV"))>0)

For nFlag := 1 to Len(aItem)

	If nFlag == nLinha
		aItem[nFlag,1] := !aItem[nFlag,1]
		If aItem[nFlag,1]
			cRet := aItem[nFlag,5]
			lNov := .t.
		Else
			cRet := aItem[nFlag,4]
		EndIf
	Else
		aItem[nFlag,1] := .F.
	EndIf

Next

if cRet <> cRetOld
	DbSelectArea("SB1")
	DbSetOrder(7)
	if lGruNov .and. lNov
		if !DbSeek( xFilial("SB1")+aItem[nLinha,8]+cRet )
			MsgInfo(STR0323,STR0002)
			cRet := cRetOld
		endif
	else
		if !DbSeek( xFilial("SB1")+aItem[nLinha,3]+cRet )
			MsgInfo(STR0323,STR0002)
			cRet := cRetOld
		Endif
	endif
Endif

oLbxSub:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FG_POSVAR    ³ Autor ³ Andre/Emilton    ³ Data ³ 05/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Retorna a posicao do campo no aHeader                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  Nome do Campo                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Posicao do Campo                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Geral                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_POSVAR(Arg1,Arg2)

If Arg2 == Nil
	Arg2 := "aHeader"
Endif

Return (aScan(&Arg2,{|x| AllTrim(x[2])==Alltrim(Arg1)}))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FG_GRAVAR    ³ Autor ³ Fabio            ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Gravacao da modelo3                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  cAliasArq := Alias do arquivo a ser gravado               ³±±
±±³          ³  aColsVet  := Nome do vetor da Gravacao                    ³±±
±±³          ³  aHeaderVet:= Obrigatorio quando for gravar o aColsVet     ³±±
±±³          ³  nx1       := Linha do aCols que sera brafada Obrigat=aCols³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Posicao do Campo                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  AP5                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FG_GRAVAR(cAliasArq,aColsVet,aHeaderVet,ni, lVldPrefixo)
Local cSelect   := Alias()
Local nXi
Local cFieldName

Default lVldPrefixo := .t.

DbSelectArea(cAliasArq)

If aColsVet == NIL
	For nXi:=1 to FCount()
		cFieldName := FieldName(nXi)
		If lVldPrefixo .and. FWTabPref( cFieldName ) <> cAliasArq
			loop
		endif
		If Type("M->"+cFieldName) != "U"
			&(cFieldName) := M->&(cFieldName)
		EndIf
	Next

Else

	For nXi:=1 to Len(aHeaderVet)
		&(aHeaderVet[nXi,2]) := aColsVet[ni,nXi]
	Next

EndIf

&(PrefixoCpo(cAliasArq)+"_FILIAL")  := xFilial(cAliasArq)

If !Empty(cSelect)
	DbSelectArea(cSelect)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_IMPGARMFºAutor ³Antonio             º Data ³  17/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gravacao da OS de garantia Massey Ferguson                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cSituac  := "D"-Disponibilidade / "C"-Cancelament. disponib º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FG_IMPGARMF(cSituac,cTipTem)
***********************

Local lTransm := .t.
Local aArea   := {}

Local nTotIte := 0
Local nTotSer := 0
Local nTotSOS := 0
Local nTotSR3 := 0
Local ii	  := 0

Local aOSTTPC := {}
Local aOSTTSC := {}

Local dDatLib := Ctod("")
Local cNumNfi := ""
Local cSerNfi := ""
Local dDatNfi := Ctod("")

aArea := sGetArea(aArea,"VO2")
aArea := sGetArea(aArea,"VO3")
aArea := sGetArea(aArea,"VO4")
aArea := sGetArea(aArea,"VO1")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf

If Upper(cSituac) == "F"

	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)

	aOSTTPC := FMX_CALPEC(VO1->VO1_NUMOSV,cTipTem,,,.f.,.f.,.t.,.f.,.t.,.t.,.f.,,)

	For ii := 1 to Len(aOSTTPC) // Pecas

		RecLock("VG6",.t.)
		VG6->VG6_FILIAL := xFilial("VG6")
		VG6->VG6_CODMAR := VO1->VO1_CODMAR
		VG6->VG6_NUMOSV := VO1->VO1_NUMOSV
		VG6->VG6_ANORRC := Str(Year(ddatabase),4)
		VG6->VG6_ITEEXT := "0"
		VG6->VG6_GRUITE := aOSTTPC[ii,1]
		VG6->VG6_CODITE := aOSTTPC[ii,2]
		VG6->VG6_PECINT := VO3->VO3_PECINT
		VG6->VG6_TRANSM := "N"
		VG6->VG6_TIPTEM := aOSTTPC[ii,3]
		VG6->VG6_VALITE := aOSTTPC[ii,9]*aOSTTPC[ii,5]
		VG6->VG6_QTDITE := aOSTTPC[ii,5]
		MsUnlock()

		If Empty(cNumNFI)
			cNumNFI := aOSTTPC[ii,29]
			cSerNFI := aOSTTPC[ii,30]
			dDatNFI := aOSTTPC[ii,19]
		EndIf

		nTotIte += VG6->VG6_VALITE

	Next

	aOSTTSC := FMX_CALSER(VO1->VO1_NUMOSV,cTipTem,,,.f.,.f.,.f.,.t.,.t.,.f.,,)

	For ii := 1 to Len(aOSTTSC) //Serviços

		RecLock("VG6",.t.)
		VG6->VG6_FILIAL := xFilial("VG6")
		VG6->VG6_CODMAR := VO1->VO1_CODMAR
		VG6->VG6_NUMOSV := VO1->VO1_NUMOSV
		VG6->VG6_ANORRC := Str(Year(ddatabase),4)
		VG6->VG6_SEREXT := "0"
		VG6->VG6_CODSER := aOSTTSC[ii,2]
		VG6->VG6_TPOGAR := aOSTTSC[ii,10]
		VG6->VG6_VALSER := aOSTTSC[ii,9]
		VG6->VG6_TRANSM := "N"
		VG6->VG6_TIPTEM := aOSTTSC[ii,4]
		MsUnlock()

		If Empty(cNumNFI)
			cNumNFI := aOSTTSC[ii,40]
			cSerNFI := aOSTTSC[ii,41]
			dDatNFI := aOSTTSC[ii,24]
		EndIf

        If aOSTTSC[ii,6] == "5" // Socorro
			nTotSOS += aOSTTSC[ii,9]
		Else
			If aOSTTSC[ii,32] > 0 // Serv 3os
				nTotSR3 += aOSTTSC[ii,32]
			Else // Todos os outros Serviços (menos Serv 3os e Socorro)
				nTotSer += aOSTTSC[ii,9]
			Endif
		Endif

		dDatLib := aOSTTSC[ii,22]

    Next

	DbSelectArea("VG8")
	DbSetOrder(1)
	DbSeek(xFilial("VG8")+VO1->VO1_CODMAR+VO1->VO1_NUMOSV+Str(Year(ddatabase),4))
	RecLock("VG8",!found())
	VG8->VG8_FILIAL := xFilial("VG8")
	VG8->VG8_CODMAR := VO1->VO1_CODMAR
	VG8->VG8_NUMOSV := VO1->VO1_NUMOSV
	VG8->VG8_DATDIS := dDatLib
	VG8->VG8_NUMNFI := cNumNfi
	VG8->VG8_SERNFI := cSerNfi
	VG8->VG8_DATNFI := dDatNfi
	VG8->VG8_ANORRC := VG6->VG6_ANORRC
	VG8->VG8_CHAINT := VO1->VO1_CHAINT
	VG8->VG8_ABEGAR := VO1->VO1_DATABE
	VG8->VG8_KILGAR := VO1->VO1_KILOME
	VG8->VG8_CODCLI := VO1->VO1_PROVEI
	VG8->VG8_LOJA   := VO1->VO1_LOJPRO
	VG8->VG8_VALITE := nTotIte
	VG8->VG8_VALSER := nTotSer
	VG8->VG8_VLRSET := nTotSR3
	VG8->VG8_VLKMCA := nTotSOS
	VG8->VG8_TRANSM := "N"
	VG8->VG8_EXPGAR := "S"
	MsUnlock()


	&&Grava Situacao da OS com Relacao a Garantia
	DbSelectArea("VO1")
	RecLock("VO1",.F.)
	VO1->VO1_SITGAR := "E"   //OS GARANTIA JA EXPORTADA
	MsUnlock()

ElseIf Upper(cSituac) = "C" &&Cancelamento da liberacao, verifica a garantia

	DbSelectArea("VG8")
	DbSetOrder(1)
	DbSeek(xFilial("VG8")+VO1->VO1_CODMAR+VO1->VO1_NUMOSV)
	Do While !Eof() .And. VO1->VO1_FILIAL+VO1->VO1_CODMAR+VO1->VO1_NUMOSV = VG8->VG8_FILIAL+VG8->VG8_CODMAR+VG8->VG8_NUMOSV

		If VG8->VG8_TRANSM == "S"
			lTransm := .f.
			Help("  ",1,"OSNCANSC")
		EndIf

		RecLock("VG8",.F.,.T.)
		DbDelete()
		MsUnlock()
		WriteSX2("VG8")
		DbSkip()

	EndDo

	If lTransm

		DbSelectArea("VG6")
		DbSetOrder(1)
		DbSeek(xFilial("VG6")+VO1->VO1_CODMAR+VO1->VO1_NUMOSV)
		Do While !Eof() .And. VO1->VO1_FILIAL+VO1->VO1_CODMAR+VO1->VO1_NUMOSV = VG6->VG6_FILIAL+VG6->VG6_CODMAR+VG6->VG6_NUMOSV

			If VG6->VG6_TRANSM == "S"
				lTransm := .f.
				Help("  ",1,"OSNCANSC")
			EndIf

			RecLock("VG6",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSX2("VG6")
			DbSkip()

		EndDo

	EndIf

	If lTransm

		DbSelectArea("VO1")
		RecLock("VO1",.F.)
		VO1->VO1_SITGAR := " "   //OS GARANTIA P/ SER EXPORTADA
		MsUnlock()

	EndIf

EndIf

sRestArea(aArea)

return(lTransm)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_IMPGARSºAutor  ³Fabio               º Data ³  27/08/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gravacao da OS de garantia nos arq. de garantia SC          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cSituac  := "D"-Disponibilidade / "C"-Cancelament. disponib º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FG_IMPGARSC(cSituac)

Local lTransm := .t.
Local aArea  := {} , aCodSer := {}

aArea := sGetArea(aArea , "VO2")
aArea := sGetArea(aArea , "VO3")
aArea := sGetArea(aArea , "VO4")
aArea := sGetArea(aArea , "VO1")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf

If Upper(cSituac) == "D"

	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)           //VEICULOS

	DbSelectArea("VO2")
	DbSetOrder(1)
	DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV)      //CABECALHO REQ.

	Do While !VO2->(eof()) .and. VO2->VO2_NUMOSV ==  VO1->VO1_NUMOSV

		If VO2->VO2_TIPREQ == "P"

			&& Pecas
			DbSelectArea("VO3")
			DbSetOrder(1)
			DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM)        //REQ. PECA

			Do While !VO3->(eof()) .and. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM

				DbSelectArea("VOI")
				DbSetOrder(1)
				DbSeek(xFilial("VOI")+VO3->VO3_TIPTEM)        //REQ. PECA

				If VOI->VOI_SITTPO == "2"

					//	            If Empty(VO3->VO3_DEPGAR)

					DbSelectArea("VG6")
					DbSetOrder(1)
					DbSeek(xFilial("VG6")+VO1->VO1_CODMAR+VO1->VO1_NUMOSV+VO3->VO3_PECINT)

					RecLock("VG6",!Found())
					VG6->VG6_FILIAL := xFilial("VG6")
					VG6->VG6_CODMAR := VO1->VO1_CODMAR
					VG6->VG6_NUMOSV := VO1->VO1_NUMOSV
					VG6->VG6_ANORRC := Str(Year(ddatabase),4)
					VG6->VG6_ITEEXT := "0"
					VG6->VG6_GRUITE := VO3->VO3_GRUITE
					VG6->VG6_CODITE := VO3->VO3_CODITE
					VG6->VG6_PECINT := VO3->VO3_PECINT
					VG6->VG6_NOSNUP := VO3->VO3_NOSNUM
					VG6->VG6_TRANSM := "N"
					VG6->VG6_TIPTEM := VO3->VO3_TIPTEM

					If VO2->VO2_DEVOLU == "0"
						VG6->VG6_QTDITE -= VO3->VO3_QTDREQ
						VG6->VG6_VALITE -= VO3->VO3_VALPEC * VO3->VO3_QTDREQ
					ElseIf VO2->VO2_DEVOLU == "1"
						VG6->VG6_QTDITE += VO3->VO3_QTDREQ
						VG6->VG6_VALITE += VO3->VO3_VALPEC * VO3->VO3_QTDREQ
					EndIf

					MsUnlock()

					DbSelectArea("VG8")
					DbSetOrder(1)
					DbSeek(xFilial("VG8")+VO1->VO1_CODMAR+VO1->VO1_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC)

					RecLock("VG8",!Found())
					VG8->VG8_FILIAL := xFilial("VG8")
					VG8->VG8_NUMOSV := VO1->VO1_NUMOSV
					VG8->VG8_ANORRC := Str(Year(ddatabase),4)
					VG8->VG8_NUMRRC := VG6->VG6_NUMRRC
					VG8->VG8_CODMAR := VO1->VO1_CODMAR
					VG8->VG8_CHAINT := VO1->VO1_CHAINT
					VG8->VG8_DATDIS := VO3->VO3_DATDIS
					VG8->VG8_ABEGAR := VO1->VO1_DATABE
					VG8->VG8_KILGAR := VO1->VO1_KILOME
					VG8->VG8_CODCLI := VO1->VO1_PROVEI
					VG8->VG8_LOJA   := VO1->VO1_LOJPRO
					VG8->VG8_TRANSM := "N"
					VG8->VG8_EXPGAR := "S"

					If VO2->VO2_DEVOLU == "0"
						VG8->VG8_VALITE -= VO3->VO3_VALPEC * VO3->VO3_QTDREQ
					ElseIf VO2->VO2_DEVOLU == "1"
						VG8->VG8_VALITE += VO3->VO3_VALPEC * VO3->VO3_QTDREQ
					EndIf

					MsUnlock()

					&& Deleta registro se o saldo do item for <= 0
					If VG6->VG6_QTDITE <= 0
						RecLock("VG6",.F.,.T.)
						Dbdelete()
						MsUnlock()
						WriteSX2("VG6")

						If VG8->VG8_VALITE <= 0
							RecLock("VG8",.F.,.T.)
							Dbdelete()
							MsUnlock()
							WriteSX2("VG8")

						EndIf

					EndIf

					//	            EndIf

				EndIf

				DbSelectArea("VO3")
				DbSkip()

			EndDo

		ElseIf VO2->VO2_TIPREQ == "S"

			&& Servicos
			DbSelectArea("VO4")
			DbSetOrder(1)
			DbSeek(xFilial("VO4")+VO2->VO2_NOSNUM)        //REQ. PECA

			Do While !VO4->(eof()) .And. VO4->VO4_NOSNUM == VO2->VO2_NOSNUM

				DbSelectArea("VOI")
				DbSetOrder(1)
				DbSeek(xFilial("VOI")+VO4->VO4_TIPTEM)        //REQ. PECA

				If VOI->VOI_SITTPO == "2"

					If Empty(VO4->VO4_DEPGAR)

						DbSelectArea("VG6")
						DbSetOrder(2)
						DbSeek(xFilial("VG6")+VO1->VO1_CODMAR+VO1->VO1_NUMOSV+VO4->VO4_SERINT)

						aCodSer := FG_CALVLSER( aCodSer , VO4->VO4_TIPTEM+VO4->VO4_TIPSER+VO4->VO4_CODSER )

						RecLock("VG6",!Found())
						VG6->VG6_FILIAL := xFilial("VG6")
						VG6->VG6_CODMAR := VO1->VO1_CODMAR
						VG6->VG6_NUMOSV := VO1->VO1_NUMOSV
						VG6->VG6_ANORRC := Str(Year(ddatabase),4)
						VG6->VG6_SEREXT := "0"
						VG6->VG6_CODSER := VO4->VO4_CODSER
						VG6->VG6_SERINT := VO4->VO4_SERINT
						VG6->VG6_TPOGAR += VO4->VO4_TEMPAD
						VG6->VG6_VALSER += aCodSer[1]
						VG6->VG6_NOSNUS := VO4->VO4_NOSNUM
						VG6->VG6_TRANSM := "N"
						VG6->VG6_TIPTEM := VO4->VO4_TIPTEM
						MsUnlock()

						DbSelectArea("VG8")
						DbSetOrder(1)
						DbSeek(xFilial("VG8")+VO1->VO1_CODMAR+VO1->VO1_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC)

						RecLock("VG8",!Found())
						VG8->VG8_FILIAL := xFilial("VG8")
						VG8->VG8_NUMOSV := VO1->VO1_NUMOSV
						VG8->VG8_ANORRC := Str(Year(ddatabase),4)
						VG8->VG8_NUMRRC := VG6->VG6_NUMRRC
						VG8->VG8_CODMAR := VO1->VO1_CODMAR
						VG8->VG8_CHAINT := VO1->VO1_CHAINT
						VG8->VG8_DATDIS := VO4->VO4_DATDIS
						VG8->VG8_ABEGAR := VO1->VO1_DATABE
						VG8->VG8_KILGAR := VO1->VO1_KILOME
						VG8->VG8_CODCLI := VO1->VO1_PROVEI
						VG8->VG8_LOJA   := VO1->VO1_LOJPRO
						VG8->VG8_TRANSM := "N"
						VG8->VG8_EXPGAR := "S"
						VG8->VG8_VALSER += aCodSer[1]

						MsUnlock()

					EndIf

				EndIf

				DbSelectArea("VO4")
				DbSkip()

			EndDo

		EndIf

		DbSelectArea("VO2")
		dbskip()

	EndDo

	&&Grava Situacao da OS com Relacao a Garantia
	DbSelectArea("VO1")
	RecLock("VO1",.F.)
	VO1->VO1_SITGAR := "E"   //OS GARANTIA JA EXPORTADA
	MsUnlock()

ElseIf Upper(cSituac) = "C" &&Cancelamento da liberacao, verifica a garantia

	DbSelectArea("VG8")
	DbSetOrder(1)
	DbSeek(xFilial("VG8")+VO1->VO1_CODMAR+VO1->VO1_NUMOSV)
	Do While !Eof() .And. VO1->VO1_FILIAL+VO1->VO1_CODMAR+VO1->VO1_NUMOSV = VG8->VG8_FILIAL+VG8->VG8_CODMAR+VG8->VG8_NUMOSV

		If VG8->VG8_TRANSM == "S"
			lTransm := .f.
			Help("  ",1,"OSNCANSC")
		EndIf

		RecLock("VG8",.F.,.T.)
		DbDelete()
		MsUnlock()
		WriteSX2("VG8")
		DbSkip()

	EndDo

	If lTransm

		DbSelectArea("VG6")
		DbSetOrder(1)
		DbSeek(xFilial("VG6")+VO1->VO1_CODMAR+VO1->VO1_NUMOSV)
		Do While !Eof() .And. VO1->VO1_FILIAL+VO1->VO1_CODMAR+VO1->VO1_NUMOSV = VG6->VG6_FILIAL+VG6->VG6_CODMAR+VG6->VG6_NUMOSV

			If VG6->VG6_TRANSM == "S"
				lTransm := .f.
				Help("  ",1,"OSNCANSC")
			EndIf

			RecLock("VG6",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSX2("VG6")
			DbSkip()

		EndDo

	EndIf

	If lTransm

		DbSelectArea("VO1")
		RecLock("VO1",.F.)
		VO1->VO1_SITGAR := " "   //OS GARANTIA P/ SER EXPORTADA
		MsUnlock()

	EndIf

EndIf

sRestArea(aArea)

return(lTransm)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_GARVW  ºAutor  ³Renata              º Data ³  18/01/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gravacao da OS de garantia nos arq. de garantia VW          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cSituac  := "F"-Fechamento / "C"-Cancelament. Fechamento    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FG_IMPGARVW(cSituac)
lOCAL lRet := .f.
MsgInfo(STR0380,"")
return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_IMPGARGºAutor  ³Fabio               º Data ³  23/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gravacao da OS de garantia nos arq. de garantia GM          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cSituac  := "D"-Disponibilidade / "C"-Cancelament. disponib º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FG_IMPGARGM(cSituac)

Local lTransm := .t.
Local aArea  := {} , aCodSer := {}
Local nTotPec := 0
Local nTemPad := 0
Local nValTpo := 0
Local aInconv := {}
Private cEspGar := " "
Default cSituac := "D"

aArea := sGetArea(aArea,"VO2")
aArea := sGetArea(aArea,"VO3")
aArea := sGetArea(aArea,"VO4")
aArea := sGetArea(aArea,"VO1")
aArea := sGetArea(aArea,"VOI")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf

If Upper(cSituac) $ "DF"

	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)           //VEICULOS

	DbSelectArea("VO2")
	DbSetOrder(1)
	DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV)      //CABECALHO REQ.

	Do While !VO2->(eof()) .and. VO2->VO2_NUMOSV ==  VO1->VO1_NUMOSV

		If VO2->VO2_TIPREQ == "P"

			&& Pecas
			DbSelectArea("VO3")
			DbSetOrder(1)
			DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM)        //REQ. PECA

			Do While !VO3->(eof()) .and. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM

				DbSelectArea("VOI")
				DbSetOrder(1)
				DbSeek(xFilial("VOI")+VO3->VO3_TIPTEM)        //REQ. PECA

				If VOI->VOI_SITTPO $ "2/4"

					Do Case
						Case VOI->VOI_SITTPO == "2"
							cEspGar := "S"
						Case VOI->VOI_SITTPO == "4"
							cEspGar := "R"
					EndCase

					dbSelectArea("VG5")
					DbSetOrder(1)
					lProcura:=dbSeek(xFilial("VG5")+VO1->VO1_CODMAR+VO1->VO1_NUMOSV+VO3->VO3_PECINT)

					RecLock("VG5",IIf(lProcura,.f.,.t.))

					VG5->VG5_FILIAL := xFilial("VG5")
					VG5->VG5_NUMOSV := VO1->VO1_NUMOSV
					VG5->VG5_CODMAR := VO1->VO1_CODMAR
					VG5->VG5_GRUITE := VO3->VO3_GRUITE
					VG5->VG5_PECINT := VO3->VO3_PECINT
					VG5->VG5_CODITE := VO3->VO3_CODITE
					VG5->VG5_ITEEXT := "0"
					VG5->VG5_SEREXT := "0"
					VG5->VG5_TRANSM := "N"
					VG5->VG5_QTDITE := VO3->VO3_QTDREQ

					If VO2->VO2_DEVOLU == "0"
						VG5->VG5_QTDITE -= VO3->VO3_QTDREQ
						VG5->VG5_VALPEC -= VO3->VO3_VALPEC * VO3->VO3_QTDREQ
						nTotPec         -= VO3->VO3_VALPEC * VO3->VO3_QTDREQ
					ElseIf VO2->VO2_DEVOLU == "1"
						VG5->VG5_QTDITE += VO3->VO3_QTDREQ
						VG5->VG5_VALPEC += VO3->VO3_VALPEC * VO3->VO3_QTDREQ
						nTotPec         += VO3->VO3_VALPEC * VO3->VO3_QTDREQ
					EndIf

					If lInconveniente // Utiliza Inconveniente MV_INCORC == "S"
						aInconv := OM420CONSINC( "2" , VO1->VO1_NUMOSV , VO3->VO3_SEQINC )
						VG5->VG5_GRUINC := aInconv[1] // Grupo
						VG5->VG5_CODINC := aInconv[2] // Codigo
					EndIf

					MsUnlock()

					If VG5->VG5_QTDITE <= 0
						RecLock("VG5",.F.,.T.)
						Dbdelete()
						MsUnlock()
						WriteSX2("VG5")
					EndIf

				EndIf

				DbSelectArea("VO3")
				DbSkip()

			EndDo

		ElseIf VO2->VO2_TIPREQ == "S"

			&& Servicos
			DbSelectArea("VO4")
			DbSetOrder(1)
			DbSeek(xFilial("VO4")+VO2->VO2_NOSNUM)        //REQ. PECA

			Do While !VO4->(eof()) .And. VO4->VO4_NOSNUM == VO2->VO2_NOSNUM

				DbSelectArea("VOI")
				DbSetOrder(1)
				DbSeek(xFilial("VOI")+VO4->VO4_TIPTEM)        //REQ. PECA

				If VOI->VOI_SITTPO $ "2/4"

					If Empty(VO4->VO4_DEPGAR)

						aCodSer := FG_CALVLSER( aCodSer , VO4->VO4_TIPTEM+VO4->VO4_TIPSER+VO4->VO4_CODSER )

						Do Case
							Case VOI->VOI_SITTPO == "2"
								cEspGar := "S"
							Case VOI->VOI_SITTPO == "4"
								cEspGar := "R"
						EndCase

						dbSelectArea("VG5")
						DbSetOrder(1)
						lProcura:=dbSeek(xFilial("VG5")+VO1->VO1_CODMAR+VO1->VO1_NUMOSV+Space(Len(VG5->VG5_PECINT))+VO4->VO4_SERINT)

						RecLock("VG5",IIf(lProcura,.f.,.t.))

						VG5->VG5_FILIAL := xFilial("VG5")
						VG5->VG5_NUMOSV := VO1->VO1_NUMOSV
						VG5->VG5_CODMAR := VO1->VO1_CODMAR
						VG5->VG5_CODSER := VO4->VO4_CODSER
						VG5->VG5_SERINT := VO4->VO4_SERINT
						If aCodSer[6]
							VG5->VG5_TEMPAD := aCodSer[2]
							nTemPad         += aCodSer[2]
						EndIf
						VG5->VG5_ITEEXT := "0"
						VG5->VG5_SEREXT := "0"
						VG5->VG5_TRANSM := "N"

						If lInconveniente // Utiliza Inconveniente MV_INCORC == "S"
							aInconv := OM420CONSINC( "2" , VO1->VO1_NUMOSV , VO4->VO4_SEQINC )
							VG5->VG5_GRUINC := aInconv[1] // Grupo
							VG5->VG5_CODINC := aInconv[2] // Codigo
						EndIf

						MsUnlock()

						nValTpo += aCodSer[1]

					EndIf

				EndIf

				DbSelectArea("VO4")
				DbSkip()

			EndDo

		EndIf

		DbSelectArea("VO2")
		dbskip()

	EndDo

	DbSelectArea("VGA")
	DbSetOrder(1)
	If !DbSeek( xFilial("VGA")+VO1->VO1_CODMAR+VO1->VO1_NUMOSV+cEspGar )

		VO5->(DbSetOrder(1))
		VO5->(DbSeek( xFilial("VO5") + VO1->VO1_CHAINT ))

		dbSelectArea("VGA")

		RecLock("VGA",.t.)

		VGA->VGA_FILIAL := xFilial("VGA")
		VGA->VGA_NUMOSV := VO1->VO1_NUMOSV
		VGA->VGA_CODMAR := VO1->VO1_CODMAR
		VGA->VGA_ESPGAR := cEspGar
		VGA->VGA_CHAINT := VO1->VO1_CHAINT
		VGA->VGA_ABEGAR := VO1->VO1_DATABE
		VGA->VGA_DTAVDA := VO5->VO5_DATVEN
		&&VGA->VGA_KILGAR := VO1->VO1_KILOME
		//      VGA->VGA_SEGMOD := Substr(VV1->VV1_CHASSI,5,3)    //TMA
		VGA->VGA_SEGMOD := VV1->VV1_MODVEI                 //TMA
		VGA->VGA_CODCLI := VV1->VV1_PROATU
		VGA->VGA_LOJA   := VV1->VV1_LJPATU
		VGA->VGA_IMPOSV := "S"
		VGA->VGA_TRANSM := "N"
		VGA->VGA_KILGAR := VO1->VO1_KILOME
		VGA->VGA_EXPGAR := "S"

		If cEspGar == "S"
			VGA->VGA_VALPEC := nTotPec
			VGA->VGA_VALTPO := nValTpo
			VGA->VGA_TEMPAD := nTemPad
		EndIf

		MsUnlock()

	EndIf

	&&Grava Situacao da OS com Relacao a Garantia
	DbSelectArea("VO1")
	RecLock("VO1",.F.)
	VO1->VO1_SITGAR := "E"   //OS GARANTIA JA EXPORTADA
	MsUnlock()

ElseIf Upper(cSituac) = "C" &&Cancelamento da liberacao, verifica a garantia

	If VOI->VOI_SITTPO == "4"     //GARANTIA (R/ )
		cEspGar := "R"
	ElseIf VOI->VOI_SITTPO == "2"     //GARANTIA (R/ )
		cEspGar := "S"
	EndIf

	lTransm := .t.

	dbselectArea("VGA")
	if FG_SEEK("VGA","VO1->VO1_CODMAR+VO1->VO1_NUMOSV+cEspGar",1,.f.)

		if VGA->VGA_TRANSM == "S"
			ltransm := .f.
			lRet := .f.
			Help("  ",1,"GARJATRANS")
		endif

	endif

	if lTransm
		if FG_SEEK("VGA","VO1->VO1_CODMAR+VO1->VO1_NUMOSV+cEspGar",1,.f.)
			dbselectArea("VGC")
			RecLock("VGC",.T.)
			VGC->VGC_FILIAL := xFilial("VGC")
			VGC->VGC_NUMOSV := VGA->VGA_NUMOSV
			VGC->VGC_CODMAR := VGA->VGA_CODMAR
			VGC->VGC_ESPGAR := VGA->VGA_ESPGAR
			VGC->VGC_CHAINT := VGA->VGA_CHAINT
			VGC->VGC_NFIFEC := VGA->VGA_NFIFEC
			VGC->VGC_SERFEC := VGA->VGA_SERFEC
			VGC->VGC_DATFEC := VGA->VGA_DATFEC
			VGC->VGC_VALPEC := VGA->VGA_VALPEC
			VGC->VGC_VALTPO := VGA->VGA_VALTPO
			VGC->VGC_DATTRA := VGA->VGA_DATTRA
			VGC->VGC_DATRET := VGA->VGA_DATRET
			VGC->VGC_SITUAC := VGA->VGA_SITUAC
			VGC->VGC_DESSIT := VGA->VGA_DESSIT
			MsUnlock()
		endif

		dbselectArea("VGA")
		If FG_SEEK("VGA","VO1->VO1_CODMAR+VO1->VO1_NUMOSV+cEspGar",1,.f.)
			RecLock("VGA",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSX2("VGA")
		endif

		If VOI->VOI_SITTPO == "2"

			dbselectArea("VG5")
			if FG_SEEK("VG5","VO1->VO1_CODMAR+VO1->VO1_NUMOSV",1,.F.)
				while VO1->VO1_FILIAL+VO1->VO1_CODMAR+VO1->VO1_NUMOSV == VG5->VG5_FILIAL+VG5->VG5_CODMAR+VG5->VG5_NUMOSV .and.!eof()
					RecLock("VG5",.F.,.T.)
					dbdelete()
					MsUnlock()
					WriteSX2("VG5")
					dbskip()
				enddo
			endif
		Endif

		dbselectArea("VO1")
		dbseek(xFilial("VO1")+VO1->VO1_NUMOSV)
		RecLock("VO1",.F.)
		VO1->VO1_SITGAR := " "   //OS GARANTIA P/ SER EXPORTADA
		MsUnlock()

	EndIf

EndIf

sRestArea(aArea)

return(lTransm)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_ParcelasºAutor  ³Manoel              º Data ³  12/01/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualizacao das Percelas de uma determinada condicao de Pagto±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³nValor    := Valor total a ser parcelado                     º±±
±±º          ³cCondicao := Codigo da Condicao de Pagamento (SE4)           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_Parcelas(nValor,cCondicao)
Local aVenc	:= {}
Local nParcelas := 0
nValFat := nValor

if !Type("aHeader") == "U"
	aSavaHeader := aClone(aHeader)
Endif
if !Type("aCols") == "U"
	aSavaCols   := aClone(aCols)
Endif

//If !VC999Con(cCondicao)
//	Return
//Endif

Private aHeader	:= {}
Private aCols	:= {}
Private cPrefixo:= ""

aVenc := Condicao(nValFat,cCondicao,0)

nParcelas := Len(aVenc)

PRIVATE oLboxPrc
PRIVATE oOk    := LoadBitmap( GetResources(), "LBOK" )
PRIVATE oNo    := LoadBitmap( GetResources(), "LBNO" )

While .t.

	DEFINE MSDIALOG oDlgPrc TITLE (STR0190) FROM  00,05 TO 9,38 OF oMainWnd

	@ 12,.1 LISTBOX oLboxPrc FIELDS HEADER ; // Indicador de Relacionamento
	(STR0191),;
	(STR0192),;
	(STR0193);
	COLSIZES 30,30,40;
	SIZE 132,56 OF OdlgPrc PIXEL

	oLboxPrc:SetArray(aVenc)
	oLboxPrc:bLine := { || { str(oLboxPrc:nAt,03)+'ª Parcela',;
	dtoc(aVenc[oLboxPrc:nAt,01]),;
	FG_AlinVlrs(Transform(aVenc[oLboxPrc:nAt,02],"9,999,999.99")) } }
	nOpca := 0

	ACTIVATE MSDIALOG oDlgPrc CENTER ON INIT EnchoiceBar(oDlgPrc,{||nOpca := 1,oDlgPrc:End()},{||nOpca := 2,oDlgPrc:End()})

	If nOpca == 1
		exit
	Else
		aVenc := {}
		exit
	Endif

Enddo


if !Type("aSavaHeader") == "U"
	aHeader := aClone(aSavaHeader)
Endif

if !Type("aSavaCols") == "U"
	aCols   := aClone(AsavaCols)
Endif

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_FATSP()ºAutor  ³Fabio               º Data ³  31/01/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o Faturar para da req. Peca e Servico.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_FATSP(cTipTem,cChave,cDestino,cOrigem,lValor,aColsFP,aHeaderFP_,cPosTipTem,cPosFatPar,cPosLoja,nLinha,cNumOsv)

Local cAliasArq,nPosVO2,nPosVO3,nPosVO4,lReturn,cSelect:=Alias()

Local cSQL
Local cAliasVLD := "TVLD"

Default cNumOsv := VO1->VO1_NUMOSV

lValor   := IIf(lValor != NIL,lValor,.f.)
cOrigem  := IIf(cOrigem != NIL,cOrigem,"A1_NOME")
aHeaderFP:= IIf(aColsFP != NIL,IIf(aHeaderFP_ != NIL,aHeaderFP_,aHeader),NIL)

cSQL := "SELECT VO3_FATPAR FATPAR, VO3_LOJA LOJA"
cSQL += " FROM " + RetSQLName("VO3") + " VO3 "
cSQL += " WHERE VO3.VO3_FILIAL = '" + xFilial("VO3") + "'"
cSQL +=   " AND VO3.VO3_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VO3.VO3_TIPTEM = '" + cTipTem + "'"
cSQL +=   " AND VO3.D_E_L_E_T_ = ' '"
cSQL += " UNION "
cSQL += "SELECT VO4_FATPAR, VO4_LOJA"
cSQL += " FROM " + RetSQLName("VO4") + " VO4 "
cSQL += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
cSQL +=   " AND VO4.VO4_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VO4.VO4_TIPTEM = '" + cTipTem + "'"
cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVLD , .F., .T. )
While !(cAliasVLD)->(Eof())
	If cChave <> (cAliasVLD)->FATPAR + (cAliasVLD)->LOJA
		If !lValor
			Help(" ",1,"FATPARSP")
		EndIf
		cTipCli := "6"
		cChave  := (cAliasVLD)->FATPAR + (cAliasVLD)->LOJA
		(cAliasVLD)->(dbCloseArea())
		If !Empty(cSelect)
			DbSelectArea(cSelect)
		EndIf
		Return(IIf(lValor,cChave,.f.))
	EndIf
	(cAliasVLD)->(dbSkip())
End
(cAliasVLD)->(dbCloseArea())

If ValType(aColsFP) != "U"
	nPos := Ascan(aColsFP,{|x| x[FG_POSVAR(cPosTipTem,"aHeaderFP")] == cTipTem .and. x[Len(x)] == .f. })
	If nPos != 0 .And. nPos != nLinha .And. aColsFP[nPos,FG_POSVAR(cPosFatPar,"aHeaderFP")]+aColsFP[nPos,FG_POSVAR(cPosLoja,"aHeaderFP")] != cChave
		If !lValor
			Help(" ",1,"FATPARSP")
		EndIf
		cChave := aColsFP[nPos,FG_POSVAR(cPosFatPar,"aHeaderFP")]+aColsFP[nPos,FG_POSVAR(cPosLoja,"aHeaderFP")]
		If !Empty(cSelect)
			DbSelectArea(cSelect)
		EndIf
		Return(IIf(lValor,cChave,.f.))
	EndIf
EndIf

DbSelectArea("SA1")
DbSetOrder(1)
If !(lReturn := DbSeek( xFilial("SA1") + cChave ) )
	Help("  ",1,"REGNOIS",,(STR0324),5,1)
EndIf
&(cDestino) := &("SA1->"+cOrigem)

If Type("aCols") != "U" .and. ValType(nLinha) != "U" .and. FG_POSVAR( Substr(cDestino,At(">",cDestino)+1) ) # 0

	aCols[nLinha,FG_POSVAR( Substr(cDestino,At(">",cDestino)+1) )] := &(cDestino)

EndIf

If !Empty(cSelect)
	DbSelectArea(cSelect)
EndIf

Return( IIf( lValor , cChave , lReturn ) )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Fg_AlinVlrs  ³ Autor ³ Vinicius Barreira     ³ Data ³ 23/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alinhamento de textos ou valores.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cReturn = Texto a alinhar                                      ³±±
±±³          ³ cAlinha = (D=Direta) / (E=Esquerda)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fg_AlinVlrs(cReturn,cAlinha)
Local nTamanho  := GETTextWidth(0,Replicate("9",Len(cReturn)))
Default cAlinha := "D"
cReturn  := AllTrim( cReturn )
While GETTextWidth(0,cReturn) < nTamanho
	If cAlinha == "D"
		cReturn := " "+cReturn
	ElseIf cAlinha == "E"
		cReturn := cReturn+" "
	EndIf
EndDo
Return cReturn


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_FilLB010³ Autor ³ Manoel                ³ Data ³ 04/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Trata Abertura e Fechto das ctas no ListBox da Avaliacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_FILLB010(nPos,cArray,aStruPar)

Local aStruLBSlv
Local aStruSlv
Local albFil := 0

If Len(aStruLB) == 0
	aadd(aStruLB,{"","","","","","","","",0,0,"",0,0,.f.,0,0,"","","",0,0,""})
EndIf
If Len(aStruLBS) == 0
	aadd(aStruLBS,{"","","","","","","","",0,0,"",0,0,.f.,0,0,"","","",0,0,""})
EndIf
If Len(aStruLBO) == 0
	aadd(aStruLBO,{"","","","","","","","",0,0,"",0,0,.f.,0,0,"","","",0,0,""})
EndIf

if cArray != nil
	aStruLBSlv := aClone(aStruLB)
	aStruLB    := aClone(&(cArray))
	aStruSlv   := aClone(aStru)
	aStru      := aClone(&(aStruPar))
	if oFolderAva:nOption == 2   // Servicos
		cClaVOQ := Subs(aStruLb[oLbFicVei2:nAt,04],1,1)
	Else  // == 3  // Ordem de Servico
		cClaVOQ := Subs(aStruLb[oLbFicVei3:nAt,04],1,1)
	Endif
	if nPos == Nil
		nPos := oLbFicVei2:nAt
	Endif
Else  // Pecas e Veiculos
	cClaVOQ := Subs(aStruLb[oLbFicVei:nAt,04],1,1)
	if nPos == Nil
		nPos := oLbFicVei:nAt
	Endif
Endif

If aStruLb[nPos,06] == "0"
	If aStruLb[nPos,14] == .f. && Fechado
		For albFil := 1 to len(aStru)
			if FS_VERITEMAVA("1",albFil)
				If Subs(aStru[albFil,04],1,1) ==  Subs(aStruLb[nPos,04],1,1) .and. aStru[albFil,06] != "0"
					aadd(aStruLB,{aStru[albFil,01],aStru[albFil,02],aStru[albFil,03],aStru[albFil,04],aStru[albFil,05],;
					aStru[albFil,06],aStru[albFil,07],aStru[albFil,08],aStru[albFil,09],aStru[albFil,10],;
					aStru[albFil,11],aStru[albFil,12],aStru[albFil,13],aStru[albFil,14],aStru[albfil,15],aStru[albfil,16],;
					aStru[albfil,17],aStru[albfil,18],aStru[albfil,19],aStru[albfil,20],aStru[albfil,21],aStru[albfil,22]})
				Endif
			Endif
		Next
	Else
		aStruTemp := {}
		For albFil := 1 to len(aStruLb)
			if FS_VERITEMAVA("2",albFil)
				If !(Subs(aStruLb[albFil,04],1,1) == cClaVOQ .and.  aStruLb[albFil,06] != "0")
					aadd(aStruTemp,{aStrulb[albfil,01],aStrulb[albfil,02],aStrulb[albfil,03],aStrulb[albfil,04],aStrulb[albfil,05],;
					aStrulb[albfil,06],aStrulb[albfil,07],aStrulb[albfil,08],aStrulb[albfil,09],aStrulb[albfil,10],;
					aStrulb[albfil,11],aStrulb[albfil,12],aStrulb[albfil,13],aStrulb[albfil,14],aStrulb[albfil,15],aStrulb[albfil,16],;
					aStrulb[albfil,17],aStrulb[albfil,18],aStrulb[albfil,19],aStrulb[albfil,20],aStrulb[albfil,21],aStrulb[albfil,22]})
				Endif
			Endif
		Next
		aStruLb := aClone(aStruTemp)
	Endif
Endif

if cArray != Nil
	&(cArray)  := aClone(aStruLB)
	aStruLB     := aClone(aStruLBSlv)
	&(aStruPar):= aClone(aStru)
	aStru       := aClone(aStruSlv)
Endif

if cArray == Nil

	if aStruLb[oLbFicVei:nAt,17] != Space(11)
		cExecFun := aStruLb[oLbFicVei:nAt,17]
		&cExecFun
	Endif
	asort(aStruLB,,,{|x,y| x[4] < y[4]})
	If oLbFicVei:nAt == 0 .or. oLbFicVei:nAt > Len(aStruLB)
		oLbFicVei:nAt := 1
	Endif
	oLbFicVei:SetArray(aStruLB)
	oLbFicVei:bLine := { || { FG_VeFxaRes(),aStruLB[oLbFicVei:nAt,05],;
	FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,09],"@E 9,999,999.99")),;
	FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,10],"@E 999.99")),;
	FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,12],"@E 9,999,999.99")),;
	FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,13],"@E 999.99")),;
	FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,20],"@E 9,999,999.99")),;
	FG_AlinVlrs(Transform(aStruLB[oLbFicVei:nAt,21],"@E 999.99"))}}
	oLbFicVei:SetFocus()
	oLbFicVei:Refresh()

ElseIf cArray == "aStruLBS"

	if aStruLbs[oLbFicVei2:nAt,17] != Space(11)
		cExecFun := aStruLbs[oLbFicVei2:nAt,17]
		&cExecFun
	Endif
	asort(aStruLBS,,,{|x,y| x[4] < y[4]})
	If oLbFicVei2:nAt == 0 .or. oLbFicVei2:nAt > Len(aStruLBS)
		oLbFicVei2:nAt := 1
	Endif
	oLbFicVei2:SetArray(aStruLBS)
	oLbFicVei2:bLine := { || { FG_VeFxaRes("aStruLBS"),aStruLBS[oLbFicVei2:nAt,05],;
	FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,09],"@E 9,999,999.99")),;
	FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,10],"@E 999.99")),;
	FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,12],"@E 9,999,999.99")),;
	FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,13],"@E 999.99")),;
	FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,20],"@E 9,999,999.99")),;
	FG_AlinVlrs(Transform(aStruLBS[oLbFicVei2:nAt,21],"@E 999.99"))}}
	oLbFicVei2:SetFocus()
	oLbFicVei2:Refresh()

Else

	if aStruLbO[oLbFicVei3:nAt,17] != Space(11)
		cExecFun := aStruLbO[oLbFicVei3:nAt,17]
		&cExecFun
	Endif
	asort(aStruLBO,,,{|x,y| x[4] < y[4]})
	If oLbFicVei3:nAt == 0 .or. oLbFicVei3:nAt > Len(aStruLBO)
		oLbFicVei3:nAt := 1
	Endif
	oLbFicVei3:SetArray(aStruLBO)
	oLbFicVei3:bLine := { || { FG_VeFxaRes("aStruLBO"),aStruLBO[oLbFicVei3:nAt,05],;
	FG_AlinVlrs(Transform(aStruLBO[oLbFicVei3:nAt,09],"@E 9,999,999.99")),;
	FG_AlinVlrs(Transform(aStruLBO[oLbFicVei3:nAt,10],"@E 999.99")),;
	FG_AlinVlrs(Transform(aStruLBO[oLbFicVei3:nAt,12],"@E 9,999,999.99")),;
	FG_AlinVlrs(Transform(aStruLBO[oLbFicVei3:nAt,13],"@E 999.99")),;
	FG_AlinVlrs(Transform(aStruLBO[oLbFicVei3:nAt,20],"@E 9,999,999.99")),;
	FG_AlinVlrs(Transform(aStruLBO[oLbFicVei3:nAt,21],"@E 999.99"))}}
	oLbFicVei3:SetFocus()
	oLbFicVei3:Refresh()

Endif

Return


Function FS_VERITEMAVA(cPar,albfil)
Local lRet := .t.

if cPar == "1"

	if cSimVda == "V"
		lRet := .t.
	Elseif cSimVda == "P"
		if aStru[albfil,03] != aLista[oLbFicPec:nAt,01]
			lRet := .f.
		Endif
	Elseif cSimVda == "S"
		if oFolderAva:nOption == 1
			if aStru[albfil,03] != aLista[oLbFicPec:nAt,01]
				lRet := .f.
			Endif
		Elseif oFolderAva:nOption == 2
			if aStru[albfil,03] != aListSrv[oLbFicSer:nAt,01]
				lRet := .f.
			Endif
		Else
			if aStru[albfil,03] != STR0325
				lRet := .f.
			Endif
		Endif
	Endif

Else //if cPar == "2"

	if cSimVda == "V"
		lRet := .t.
	Elseif cSimVda == "P"
		if aStruLB[albfil,03] != aLista[oLbFicPec:nAt,01]
			lRet := .f.
		Endif
	Elseif cSimVda == "S"
		if oFolderAva:nOption == 1
			if aStruLB[albfil,03] != aLista[oLbFicPec:nAt,01]
				lRet := .f.
			Endif
		Elseif oFolderAva:nOption == 2
			if aStruLB[albfil,03] != aListSrv[oLbFicSer:nAt,01]
				lRet := .f.
			Endif
		Else
			if aStruLB[albfil,03] != STR0325
				lRet := .f.
			Endif
		Endif
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_VeFxaRes³ Autor ³ Manoel                ³ Data ³ 04/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Colori a linha da Conta de Resultado de acordo com as Faixas ³±±
±±³          ³de resultado definidas no VOQ (*VS5)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_VeFxaRes(cArray)

Local aStruLBSlv

If cArray != nil
	aStruLBSlv := aClone(aStruLB)
	aStruLB := aClone(&(cArray))
EndIf
// VerIfica Faixa de Resultado e Colore linhas de acordo com o resultado da mesma

if Len(aStruLB) == 0
	aadd(aStruLB,{"","","","","","","","",0,0,"",0,0,.f.,0,0,"","","",0,0,""})
Endif

If cSimvda != "S" .or. (cSimVda == "S" .and. oFolderAva:nOption == 1)// Pecas e Veiculos

	If aStruLB[oLbFicVei:nAt,15]+aStruLB[oLbFicVei:nAt,16] != 0
		If aStruLB[oLbFicVei:nAt,15] > aStruLB[oLbFicVei:nAt,16]
			If aStruLB[oLbFicVei:nAt,10] > aStruLB[oLbFicVei:nAt,16]
				oObjRet := oObjCor1
			ElseIf  aStruLB[oLbFicVei:nAt,10] >= aStruLB[oLbFicVei:nAt,15] .and. aStruLB[oLbFicVei:nAt,10] <= aStruLB[oLbFicVei:nAt,16]
				oObjret := oObjCor2
			ElseIf aStruLB[oLbFicVei:nAt,10] < aStruLB[oLbFicVei:nAt,15]
				oObjret := oObjCor3
			Else
				oObjret := oObjCor4
			EndIf
		Else
			If aStruLB[oLbFicVei:nAt,10] < aStruLB[oLbFicVei:nAt,15]
				oObjret := oObjCor1
			ElseIf  aStruLB[oLbFicVei:nAt,10] >= aStruLB[oLbFicVei:nAt,15] .and. aStruLB[oLbFicVei:nAt,10] <= aStruLB[oLbFicVei:nAt,16]
				oObjret := oObjCor2
			ElseIf aStruLB[oLbFicVei:nAt,10] > aStruLB[oLbFicVei:nAt,16]
				oObjret := oObjCor3
			Else
				oObjret := oObjCor4
			EndIf
		EndIf
	Else
		oObjret := oObjCor4
	EndIf

Else // Servicos  e  Ordens de Servico

	If  oFolderAva:nOption == 2 // Servicos
		If aStruLB[oLbficvei2:nAt,15]+aStruLB[oLbficvei2:nAt,16] != 0
			If aStruLB[oLbficvei2:nAt,15] > aStruLB[oLbficvei2:nAt,16]
				If aStruLB[oLbficvei2:nAt,10] > aStruLB[oLbficvei2:nAt,16]
					oObjret := oObjCor1
				ElseIf  aStruLB[oLbficvei2:nAt,10] >= aStruLB[oLbficvei2:nAt,15] .and. aStruLB[oLbficvei2:nAt,10] <= aStruLB[oLbficvei2:nAt,16]
					oObjret := oObjCor2
				ElseIf aStruLB[oLbficvei2:nAt,10] < aStruLB[oLbficvei2:nAt,15]
					oObjret := oObjCor3
				Else
					oObjret := oObjCor4
				EndIf
			Else
				If aStruLB[oLbficvei2:nAt,10] < aStruLB[oLbficvei2:nAt,15]
					oObjret := oObjCor1
				ElseIf  aStruLB[oLbficvei2:nAt,10] >= aStruLB[oLbficvei2:nAt,15] .and. aStruLB[oLbficvei2:nAt,10] <= aStruLB[oLbficvei2:nAt,16]
					oObjret := oObjCor2
				ElseIf aStruLB[oLbficvei2:nAt,10] > aStruLB[oLbficvei2:nAt,16]
					oObjret := oObjCor3
				Else
					oObjret := oObjCor4
				EndIf
			EndIf
		Else
			oObjret := oObjCor4
		EndIf
	Else //oFolderAva:nOption == 3 - Ordem de Servico
		If aStruLB[oLbficvei3:nAt,15]+aStruLB[oLbficvei3:nAt,16] != 0
			If aStruLB[oLbficvei3:nAt,15] > aStruLB[oLbficvei3:nAt,16]
				If aStruLB[oLbficvei3:nAt,10] > aStruLB[oLbficvei3:nAt,16]
					oObjret := oObjCor1
				ElseIf  aStruLB[oLbficvei3:nAt,10] >= aStruLB[oLbficvei3:nAt,15] .and. aStruLB[oLbficvei3:nAt,10] <= aStruLB[oLbficvei3:nAt,16]
					oObjret := oObjCor2
				ElseIf aStruLB[oLbficvei3:nAt,10] < aStruLB[oLbficvei3:nAt,15]
					oObjret := oObjCor3
				Else
					oObjret := oObjCor4
				EndIf
			Else
				If aStruLB[oLbficvei3:nAt,10] < aStruLB[oLbficvei3:nAt,15]
					oObjret := oObjCor1
				ElseIf  aStruLB[oLbficvei3:nAt,10] >= aStruLB[oLbficvei3:nAt,15] .and. aStruLB[oLbficvei3:nAt,10] <= aStruLB[oLbficvei3:nAt,16]
					oObjret := oObjCor2
				ElseIf aStruLB[oLbficvei3:nAt,10] > aStruLB[oLbficvei3:nAt,16]
					oObjret := oObjCor3
				Else
					oObjret := oObjCor4
				EndIf
			EndIf
		Else
			oObjret := oObjCor4
		EndIf
	EndIf

EndIf
If cArray != nil
	&(cArray) := aClone(aStruLB)
	aStruLB    := aClone(aStruLBSlv)
EndIf

Return(oObjRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_PegaCor ³ Autor ³ Manoel                ³ Data ³ 28/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna nome do BitMap correspondente a cor de acordo com os ³±±
±±³          ³campos VS5_PRICOR, VS5_SEGCOR e VS5_TERCOR                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PegaCor(cParam)

If cParam == "1"
	Return("BR_AMARELO")
ElseIf cParam == "2"
	Return("BR_AZUL")
ElseIf cParam == "3"
	Return("BR_ROSA")
ElseIf cParam == "4"
	Return("BR_VERDE")
ElseIf cParam == "5"
	Return("BR_VERMELHO")
ElseIf cParam == "6"
	Return("BR_MARROM")
EndIf

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_DSPV010 ³ Autor ³ Manoel                ³ Data ³ 04/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra Despesas com o Veiculo                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_DspV010()

If Len(aIteDesp) > 0

	PRIVATE oLbDesVei

	DEFINE MSDIALOG oDlgDesVei TITLE (STR0194) FROM  10,05 TO 20,67 OF oMainWnd

	@ 12,.1 LISTBOX oLbDesVei FIELDS HEADER   (STR0195),; // Titulo das Colunas
	(STR0196),;
	(STR0197),;
	(STR0198);
	COLSIZES 25,20,70,50;
	SIZE 254,223 OF OdlgDesVei PIXEL

	oLbDesVei:SetArray(aIteDesp)
	oLbDesVei:bLine := { || { dToc(aIteDesp[oLbDesVei:nAt,01]),;
	aIteDesp[oLbDesVei:nAt,02],;
	aIteDesp[oLbDesVei:nAt,03],;
	Transform(aIteDesp[oLbDesVei:nAt,04],"9,999,999.99")}}
	nOpca := 0

	ACTIVATE MSDIALOG oDlgDesVei CENTER ON INIT EnchoiceBar(oDlgDesVei,{||nOpca := 1,oDlgDesVei:End()},{||nOpca := 2,oDlgDesVei:End()})

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FG_RECV010 ³ Autor ³ Manoel                ³ Data ³ 18/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra Receitas do Veiculo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_RecV010()

If Len(aIteRece) > 0

	PRIVATE oLbRecVei

	DEFINE MSDIALOG oDlgRecVei TITLE (STR0199) FROM  10,05 TO 20,67 OF oMainWnd

	@ 12,.1 LISTBOX oLbRecVei FIELDS HEADER   (STR0200),; // Titulo das Colunas
	(STR0201),;
	(STR0202),;
	(STR0203);
	COLSIZES 25,20,70,50;
	SIZE 254,223 OF OdlgRecVei PIXEL

	oLbRecVei:SetArray(aIteRece)
	oLbRecVei:bLine := { || { dToc(aIteRece[oLbRecVei:nAt,01]),;
	aIteRece[oLbRecVei:nAt,02],;
	aIteRece[oLbRecVei:nAt,03],;
	Transform(aIteRece[oLbRecVei:nAt,04],"9,999,999.99")}}
	nOpca := 0

	ACTIVATE MSDIALOG oDlgRecVei CENTER ON INIT EnchoiceBar(oDlgRecVei,{||nOpca := 1,oDlgRecVei:End()},{||nOpca := 2,oDlgRecVei:End()})

EndIf

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FG_PrtFic     ³ Autor ³ Manoel                ³ Data ³ 25/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara Impressao da Ficha do Veiculo                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Veiculos                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PrtFic()
Local cOpcao := STR0326
LocaL vv	 := 0

if !lOpcGN


	aOpcao := {STR0204,STR0205}
	xOpc   := 1

	DEFINE MSDIALOG oDlgPerg TITLE (STR0206) FROM  02,04 TO 07,31 OF oMainWnd

	@  13, 02 TO 33,106 LABEL (STR0207) OF oDlgPerg PIXEL

	@  19, 04 MSCOMBOBOX oOpcao VAR cOpcao SIZE 100,50 ITEMS aOpcao OF oDlgPerg PIXEL

	ACTIVATE MSDIALOG oDlgPerg CENTER ON INIT (ENCHOICEBAR(oDlgPerg,{|| xOpc := 1,oDlgPerg:End()},{|| xOpc := 2,oDlgPerg:End()}))

	if xOpc == 1
		//	   if cOpcao == STR0204
		if Left(cOpcao,1) == "1"
			//Executa RdMake da Proposta de Venda
			if ExistBlock("FICVEI")
				ExecBlock("FICVEI",.f.,.f.)
			Endif

		Else

			cNomRel:= "FichaVei"

			dbselectarea("VVS")

			IF Ma280Flock("VVS")
				Set Filter To
				DbClearInd()
				OpenIndx("VVS",.F.)
				Zap
				DbCloseArea()
			Endif

			ChkFile("VVS",.F.)

			for vv = 1 to len(aStru)

				if  aStru[vv,14] == .f. .or. aStru[vv,06] == "0"
					RecLock("VVS",.t.)
					VVS->VVS_FILIAL := xFilial("VVS")
					VVS->VVS_NUMTRA := aStru[vv,01]
					VVS->VVS_CHAINT := aStru[vv,03]
					VVS->VVS_DESCRI := aStru[vv,05]
					VVS->VVS_VLRCTA := aStru[vv,09]
					VVS->VVS_PERCTA := aStru[vv,10]
					VVS->VVS_VLROCT := aStru[vv,12]
					VVS->VVS_PEROCT := aStru[vv,13]
					VVS->VVS_VLRMPR := aStru[vv,20]
					VVS->VVS_PERMPR := aStru[vv,21]
					MsUnlock()
				endif

			next

			dbgotop()

			If Type("MV_PAR01") == "U" .or. Empty(MV_PAR01)
				CallCrys("FICVEI",VVS->VVS_CHAINT+";"+cOutMoed+";"+cMoedCor)
			Else
				If MV_PAR01 == 1 && Por Chassi
					CallCrys("FICVEI",VVS->VVS_CHAINT+";"+cOutMoed+";"+cMoedCor)
				Else && Por Periodo
					CallCrys("FICVEI",VVS->VVS_CHAINT+";"+cOutMoed+";"+cMoedCor,"1;1;1;''")
				EndIf
			EndIf

		Endif

		if MV_PAR01 # 1 && Por Periodo
			lOpcGN := .t.
			nOpcGN := cOpcao
		Endif

	Endif

Else

	if nOpcGN == STR0204
		//Executa RdMake da Proposta de Venda
		if ExistBlock("FICVEI")
			ExecBlock("FICVEI",.f.,.f.)
		Endif

	Else

		cNomRel:= "FichaVei"

		dbselectarea("VVS")

		IF Ma280Flock("VVS")
			Set Filter To
			DbClearInd()
			OpenIndx("VVS",.F.)
			Zap
			DbCloseArea()
		Endif

		ChkFile("VVS",.F.)

		for vv = 1 to len(aStru)

			if  aStru[vv,14] == .f. .or. aStru[vv,06] == "0"
				RecLock("VVS",.t.)
				VVS->VVS_FILIAL := xFilial("VVS")
				VVS->VVS_NUMTRA := aStru[vv,01]
				VVS->VVS_CHAINT := aStru[vv,03]
				VVS->VVS_DESCRI := aStru[vv,05]
				VVS->VVS_VLRCTA := aStru[vv,09]
				VVS->VVS_PERCTA := aStru[vv,10]
				VVS->VVS_VLROCT := aStru[vv,12]
				VVS->VVS_PEROCT := aStru[vv,13]
				VVS->VVS_VLRMPR := aStru[vv,20]
				VVS->VVS_PERMPR := aStru[vv,21]
				MsUnlock()
			endif

		next

		dbgotop()

		CallCrys("FICVEI",VVS->VVS_CHAINT+";"+cOutMoed+";"+cMoedCor,"1;1;1;''")

	Endif

Endif

Return .t.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FG_SITBOX    ³ Autor ³ Emilton               ³ Data ³ 09/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtra Situacao desejada de Box                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FG_FILBOX(cSitBox)
FG_SEEK("VON","VOF->VOF_NUMBOX",1,.f.)

If cSitBox == "V"
	If VOF->VOF_SITBOX == "V"
		Return .t.
	Else
		Return .f.
	EndIf
EndIf

return .t.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FG_ESTSVGAR  ³ Autor ³ Renata                ³ Data ³ 10/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apaga reg. serv. na GA, em caso de estorno na oficina          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FG_ESTSVGAR()
Local nValSer := 0
Local aArea := sGetArea()
sGetArea(aArea,"VO2")
sGetArea(aArea,"VO3")
sGetArea(aArea,"VO4")
sGetArea(aArea,"VO1")
sGetArea(aArea,"VG6")

dbselectArea("VG6")
dbgotop()
dbSetOrder(2)
lProcura:=dbseek(xFilial("VG6")+VO1->VO1_CODMAR+VO1->VO1_NUMOSV+VO4->VO4_SERINT)

If lProcura
	nValSer := VG6->VG6_VALSER
	Reclock("VG6",.T.,.F.)
	Dbdelete()
	MsUnlock()
	WriteSX2()
	dbselectArea("VG8")
	dbgotop()
	dbSetOrder(1)
	lProcura:=dbseek(xFilial("VG8")+VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC)

	If lProcura
		RecLock("VG8",.F.)
		VG8->VG8_VALSER := VG8->VG8_VALSER - nValser
		MsUnlock()
	endIf

endIf
sRestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FG_AltSx1³ Autor ³  Manoel               ³ Data ³ 28/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1o (Nome da Pergunte) / 2o (Z-Zera ou A-Altera)            ³±±
±±³          ³ 3o (Vetor c/ conteudo a alterar. Qdo Vazio nao Altera)     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_AltSx1(cPar01,cPar02,aPar03)

Local iSx1 := 0
// Montagem do aPar03:  * Sempre preencher todos os elementos, mesmo que com ""
//    1o elemento  -  Ordem
//    2o elemento  -  CNT01
//    3o elemento  -  CNT02
//    4o elemento  -  CNT03
//    5o elemento  -  CNT04
//    6o elemento  -  CNT05
//    7o elemento  -  DEF01
//    8o elemento  -  DEF02
//    9o elemento  -  DEF03
//   10o elemento  -  DEF04
//   11o elemento  -  DEF05
//   12o elemento  -  Var01
//   13o elemento  -  Var02
//   14o elemento  -  Var03
//   15o elemento  -  Var04
//   16o elemento  -  Var05
dbSelectArea("SX1")
dbSetOrder(1)
cPar01 := LEFT(cPar01+SPACE(LEN(SX1->X1_GRUPO)),LEN(SX1->X1_GRUPO))

If cPar02 == "Z" // Zeramento

	dbGoTop()
	dbSeek(cPar01)

	If X1_GRUPO == cPar01

		RecLock("SX1",.f.)
		If X1_GSC == "G" // Get
			X1_CNT01 := Space(30)
			X1_CNT02 := Space(30)
			X1_CNT03 := Space(30)
			X1_CNT04 := Space(30)
			X1_CNT05 := Space(30)
		ElseIf X1_GSC == "C" // ComboBox
			X1_PRESEL := 1
		EndIf
		MsUnlock()
	EndIf
Else

	for iSx1 := 1 to Len(aPar03)
		dbGoTop()
		dbSeek(cPar01+aPar03[iSx1,1])

		If X1_GRUPO+X1_ORDEM == cPar01+aPar03[iSx1,1]

			RecLock("SX1",.f.)
			If !Empty(aPar03[iSx1,2])
				X1_CNT01 := aPar03[iSx1,2]
			EndIf
			If !Empty(aPar03[iSx1,03])
				X1_CNT02 := aPar03[iSx1,03]
			EndIf
			If !Empty(aPar03[iSx1,04])
				X1_CNT03 := aPar03[iSx1,04]
			EndIf
			If !Empty(aPar03[iSx1,05])
				X1_CNT04 := aPar03[iSx1,05]
			EndIf
			If !Empty(aPar03[iSx1,06])
				X1_CNT05 := aPar03[iSx1,06]
			EndIf
			If !Empty(aPar03[iSx1,07])
				X1_DEF01 := aPar03[iSx1,07]
			EndIf
			If !Empty(aPar03[iSx1,08])
				X1_DEF02 := aPar03[iSx1,08]
			EndIf
			If !Empty(aPar03[iSx1,09])
				X1_DEF03 := aPar03[iSx1,09]
			EndIf
			If !Empty(aPar03[iSx1,10])
				X1_DEF04 := aPar03[iSx1,10]
			EndIf
			If !Empty(aPar03[iSx1,11])
				X1_DEF05 := aPar03[iSx1,11]
			EndIf
			If !Empty(aPar03[iSx1,12])
				X1_VAR01 := aPar03[iSx1,12]
			EndIf
			If !Empty(aPar03[iSx1,13])
				X1_VAR02 := aPar03[iSx1,13]
			EndIf
			If !Empty(aPar03[iSx1,14])
				X1_VAR03 := aPar03[iSx1,14]
			EndIf
			If !Empty(aPar03[iSx1,15])
				X1_VAR04 := aPar03[iSx1,15]
			EndIf
			If !Empty(aPar03[iSx1,16])
				X1_VAR05 := aPar03[iSx1,16]
			EndIf
			MsUnlock()
		EndIf
	Next
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_TABTRIB³ Autor ³  Fabio                ³ Data ³ 08/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±± Descricao |Busca os TES diferenciados na tabela VG8                    |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodOpe = Codigio da Operacao                               ³±±
±±³          ³cOrigem = Codigo da Origem                                  ³±±
±±³          ³cCodTesDefault = Tes Saida Padrão do SB1                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_TABTRIB( cCodOpe , cOrigem , cCodTesDefault )

Local cRet := ""
Default cCodTesDefault := ""

cRet := cCodTesDefault

If !Empty(cCodOpe)

	DbSelectArea("VEB")
	DbSetOrder(1)
	DbSeek( xFilial("VEB") + cCodOpe )

	DbSelectArea("VEL")
	DbSetOrder(1)
	If !Empty(cOrigem) .And. DbSeek( xFilial("VEL") + cCodOpe + cOrigem )

		cRet := VEL->VEL_TESESP

	ElseIf !Empty(cCodOpe) .And. VEB->(Found())

		cRet := VEB->VEB_TESPAD

	EndIf
	//Ponto de Entrada para verificar se trocara ou nao a TES // Claudia
	//Curinga - nao trocar a TES do Oleo para venda interna
	If ExistBlock("CHKTES")             // Relacao de Pecas Formulario Comum
		cRet := ExecBlock("CHKTES",.f.,.f.,{cRet})
	EndIf

EndIf

Return( cRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA_LEVVAL ³ Autor ³  Andre                ³ Data ³ 21/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1=Tipo de Levantamento (1=Orcamento / 2=Ordem de Servico)   ³±±
±±³          ³2=Numero do Orcamento ou Ordem de Servico                   ³±±
±±³          ³3=Campo a Pesquisar o Valor                                 ³±±
±±³          ³4=Campo a Pesquisar o Valor                                 ³±±
±±³          ³5=Tipo de Tempo (So qdo for Ordem de Servico)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Levanta Valores para a Avaliacao de Resultado               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA_LEVVAL(cTipLev,nNumChv,cContChv,cArqPes,cNomCpo,cTipTmp)

Local nValRet := 0
Local cAliasSv := Alias()
Local nIteAva := 0 // nro de itens na Avaliacao
Local ii  := 0
Local iii := 0
Local cPriCta    := 0
Local nPos       := 0
Local nTotStru   := 0 // Total de elementos no Vetor, exceto os elementos do Total da Venda
Local nPosTotVda := 0 // Posicao ultimo elemento do vetor, anterior ao primeiro elemento do Total da Venda

If Type("aStru") == "A"

	cPriCta    := aStru[1,4]
	nQtdEMap   := aScan(aStru,{|x| x[4] == cPriCta},2) - 1  // Qtd de Elementos por Item no Mapa
	nTotStru   := (Len(aStru)-nQtdEMap) // Total de elementos no Vetor, exceto os elementos do Total da Venda
	nPosTotVda := nTotStru // Posicao ultimo elemento do vetor, anterior ao primeiro elemento do Total da Venda

	// Limpeza dos elementos do Total da Venda
	for ii := nPosTotVda+1 To Len(aStru)
		aStru[ii,09] := 0
		aStru[ii,12] := 0
	Next

	// Gravacao dos elementos do Total da Venda
	for ii := 1 To nQtdEmap
		for iii := ii To nTotStru step nQtdEmap
			aStru[nTotStru + ii,09] += aStru[iii,09]
			aStru[nTotStru + ii,12] += aStru[iii,12]
		next
	Next

Endif
If !Empty(cAliasSv)
	DbSelectarea(cAliasSv)
EndIf

Return(nValRet)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_OIC     ³ Autor ³ Fabio                 ³ Data ³ 25/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imporata Requisicao de peca Fabrica CD Volksvagen            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_OIC()

Local x := 0
Local cDiretTxt := Alltrim(VE4->VE4_DIRFAB)
Local cDiretorio:= Alltrim( Substr( VE4->VE4_DIRFAB , 1 , Rat("\",VE4->VE4_DIRFAB) ) )
Local cStringTxt := "" , cArquivo := ""
Local ni := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Vetor com os Arquivos do Diretorio                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aArqTxt := {}
aArqTxt := Directory(cDiretTxt,"D")

If len(aArqTxt) == 0
	MsgStop((STR0137))  // Nao foi possivel abrir o arquivo texto. Operacao cancelada !
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre Arquivo binario e faz leitura                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cString := space(200)
aPecas := {}

For x:=1 to Len(aArqTxt)

	cArquivo := Alltrim( cDiretorio ) + Alltrim( aArqTxt[x,1] )

	If !File(cArquivo)
		Loop
	EndIf

	FT_FUSE( cArquivo )
	FT_FGOTOP()

	ni   := 0
	nPos := 0
	cCod := ""

	While !FT_FEOF()

		cStringTxt := FT_FREADLN()

		cCod := Substr(cStringTxt,VE4->VE4_CODINI,VE4->VE4_CODTAM)
		nPos := Len(cCod)
		For ni:=1 to nPos
			If Substr(cCod,ni,1) $ " /"
				cCod := Substr(cCod,1,ni-1)+Substr(cCod,ni+1)
				ni--
			EndIf
		Next

		Aadd(aPecas,{aArqTxt[x,1],Alltrim(cCod),Alltrim(Substr(cStringTxt,VE4->VE4_DESINI,VE4->VE4_DESTAM)),Alltrim(Substr(cStringTxt,VE4->VE4_QTDINI,VE4->VE4_QTDTAM))})
		FT_FSKIP()

	End

Next

FT_FUSE()

Return(aPecas)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FI_TOTREG³ Autor ³  Renata               ³ Data ³ 27/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o nro de registro dos arquivos textos gerados      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FI_TOTREG(cParam)
Local nTotReg := 0

If cParam = "VW "
	nTotReg := ("TRA")->(reccount())
ElseIf cParam = "SC "
	nTotReg := ("TRA")->(reccount())
EndIf

Return(nTotReg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FI_DATHOR³ Autor ³  Renata               ³ Data ³ 27/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna AAMMDDHHMMSS00 para arquivos Scania                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FI_DATHOR()
cRetorno := right(strzero(year(date()),4),2)+strzero(month(date()),2)+strzero(day(date()),2)
cRetorno := cRetorno + subs(time(),1,2) + subs(time(),4,2) + subs(time(),7,2) + "00"

Return(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FI_NOMARQ³ Autor ³  Renata               ³ Data ³ 27/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna nome                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FI_NOMARQ()
dData := right(strzero(year(date()),4),2)+strzero(month(date()),2)+strzero(day(date()),2)
nCont := 1
FG_SEEK("VE4","VH6->VH6_CODMAR",1,.F.)

do while nCont <= 10
	cNome := "T" + dData + str(nCont,1) + "." + VE4->VE4_ESTACA
	cArq    := cDirect + cNome
	if file(cArq)
		nCont++
	else
		exit
	endif
enddo

RETURN(cNome)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FG_PERDES³ Autor ³ Andre/Emilton         ³ Data ³ 11/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se Desconto pode ser Aplicado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Par1 = Marca                                               ³±±
±±³          ³ Par2 = Codigo do Centro de Custo                           ³±±
±±³          ³ Par3 = P - Peca / S - Servicos                             ³±±
±±³          ³ Par4 = Grupo do Item ou Servico                            ³±±
±±³          ³ Par5 = Codigo do Item ou Servico                           ³±±
±±³          ³ Par6 = Quantidade de Itens                                 ³±±
±±³          ³ Par7 = Percentual de Desconto                              ³±±
±±³          ³ Par8 = .t. = Mostra o Help de Desconto maior q Permitido   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PERDES(cMar,cCCC,cPec,cGru,cCod,nQtd,nPer,lHlp,cMod)

Local lRet := .t.
Local yx_  := 0
Local wy_  := 0

Private lRet1    := lRet2    := lRet3    := lRet4    := lRet5    := lRet6    := .t.
Private lDes1    := lDes2    := lDes3    := lDes4    := lDes5    := lDes6    := .t.
Private nDesPer1 := nDesPer2 := nDesPer3 := nDesPer4 := nDesPer5 := nDesPer6 := 0

If lHlp == Nil
	lHlp := .t.
EndIf

If nPer == 0
	Return .t.
EndIf

If cPec == "P"
	If Empty(cCod)
		lRet := .t.
	Else
		cKeyAce := cGru+cCod
		FG_Seek("SB1","cKeyAce",7,.f.)
		FG_Seek("SB5","SB1->B1_COD",1,.f.)

		//Item na Promocao
		DbSelectArea("VEN")
		DbSetOrder(2)
		if DbSeek(xFilial("VEN")+cMar+cCCC+cKeyAce)
			if dDataBase >= VEN->VEN_DATINI .and. dDataBase <= VEN->VEN_DATFIN
				if VEN->VEN_ITEDES > 0 .and. VEN->VEN_ITEDES >= nQtd
					if VEN->VEN_ITEPER < nPer
						nDesPer1 := VEN->VEN_ITEPER
						lDes1 := .f.
						lRet1 := .f.
					Endif
				Elseif nQtd >= VEN->VEN_QTDITE .and. VEN->VEN_PERQTD != 0
					if VEN->VEN_PERQTD < nPer
						nDesPer1 := VEN->VEN_PERQTD
						lRet1 := .f.
						lDes1 := .f.
					Endif
				Else
					if nPer > VEN->VEN_PERDES
						nDesPer1 := VEN->VEN_PERDES
						lRet1 := .f.
						lDes1 := .f.
					Endif
				Endif
			Else
				lRet1 := .f.
			Endif
		Else
			lRet1 := .f.
		Endif

		//CAI
		DbSelectArea("VEN")
		DbSetOrder(3)
		if DbSeek(xFilial("VEN")+cMar+cCCC+SB5->B5_CODCAI) .and. !Empty(SB5->B5_CODCAI)
			if dDataBase >= VEN->VEN_DATINI .and. dDataBase <= VEN->VEN_DATFIN
				if nPer > VEN->VEN_PERDES
					nDesPer2 := VEN->VEN_PERDES
					lRet2 := .f.
					lDes2 := .f.
				Endif
			Else
				lRet2 := .f.
			Endif
		Else
			lRet2 := .f.
		Endif

		//Grupo da Peca
		DbSelectArea("VEN")
		DbSetOrder(4)
		if DbSeek(xFilial("VEN")+cMar+cCCC+cGru) .and. !Empty(cGru)
			if dDataBase >= VEN->VEN_DATINI .and. dDataBase <= VEN->VEN_DATFIN
				if nPer > VEN->VEN_PERDES
					nDesPer3 := VEN->VEN_PERDES
					lRet3 := .f.
					lDes3 := .f.
				Endif
			Else
				lRet3 := .f.
			Endif
		Else
			lRet3 := .f.
		Endif

		//Grupo de Desconto
		DbSelectArea("VEN")
		DbSetOrder(5)
		if DbSeek(xFilial("VEN")+cMar+cCCC+SB1->B1_GRUDES) .and. !Empty(SB1->B1_GRUDES)
			if dDataBase >= VEN->VEN_DATINI .and. dDataBase <= VEN->VEN_DATFIN
				if nPer > VEN->VEN_PERDES
					nDesPer4 := VEN->VEN_PERDES
					lRet4 := .f.
					lDes4 := .f.
				Endif
			Else
				lRet4 := .f.
			Endif
		Else
			lRet4 := .f.
		Endif

		//Classificacao Financeira
		If Month(dDataBase)==1
			cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
		Else
			cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
		EndIf
		DbSelectArea("SBL")
		DbSetOrder(1)
		DbSeek(xFilial("SBL")+SB1->B1_COD+cAnoMes)
		FG_Seek("VS2","SBL->BL_ABCVEND+SBL->BL_ABCCUST")
		DbSelectArea("VEN")
		DbSetOrder(6)
		if DbSeek(xFilial("VEN")+cMar+cCCC+VS2->VS2_CODCLA) .and. !Empty(VS2->VS2_CODCLA)
			if dDataBase >= VEN->VEN_DATINI .and. dDataBase <= VEN->VEN_DATFIN
				if nPer > VEN->VEN_PERDES
					nDesPer5 := VEN->VEN_PERDES
					lRet5 := .f.
					lDes5 := .f.
				Endif
			Else
				lRet5 := .f.
			Endif
		Else
			lRet5 := .f.
		Endif

		//Modelo do Veiculo
		if Type("cMod") # "U" .and. cMod # Nil
			DbSelectarea("VV2")
			DbSetOrder(1)
			if DbSeek(xFilial("VV2")+cMod)
				DbSelectArea("VEN")
				DbSetOrder(7)
				if DbSeek(xFilial("VEN")+cMar+cCCC+VV2->VV2_MODVEI) .and. !Empty(VV2->VV2_MODVEI)
					if dDataBase >= VEN->VEN_DATINI .and. dDataBase <= VEN->VEN_DATFIN
						if nPer > VEN->VEN_PERDES
							nDesPer6 := VEN->VEN_PERDES
							lRet6    := .f.
							lDes6    := .f.
						Endif
					Else
						lRet6 := .f.
					Endif
				Endif
			Else
				lRet6 := .f.
			Endif
		Else
			lRet6 := .f.
		Endif
		VEM->(DbSetOrder(1))
		VEM->(Dbseek(xFilial("VEM")+cMar+cCCC))
		cOrdem := ""
		For yx_ :=1 to 6
			if &("lRet"+str(yx_,1))
				cOrdem := cOrdem + Str(yx_,1)
			Endif
		Next
		if Len(alltrim(cOrdem)) > 0
			For wy_:=1 to Len(alltrim(VEM->VEM_ORDPRI))
				if Substr(VEM->VEM_ORDPRI,wy_,1) $ alltrim(cOrdem)
					if &("lDes"+str(wy_,1))
						nDesPer := &("nDesPer"+str(wy_,1))
						lRet    := .t.
						if Substr(VEM->VEM_ORDPRI,wy_,1) == "1"
							RecLock("VEN",.f.)
							VEN->VEN_ITEDES -= nQtd
							MsUnlock()
						Endif
						Exit
					Else
						nDesPer := &("nDesPer"+str(wy_,1))
						lRet    := .f.
					Endif
				Endif
			Next
		Else
			lRet := .f.
		Endif

	EndIf
Else
	cKeyAce := cGru
	if FG_SEEK("VOK","cKeyAce",1,.f.)
		If nPer > VOK->VOK_PERMAX
			lRet := .f.
		Endif
	Else
		lRet := .f.
	Endif
Endif

if ExistBlock("DESCOM110")
	lRet := ExecBlock("DESCOM110",.f.,.f.,{lRet})
Endif

if !lRet
	if lHlp
		if !Empty(cCod) .and. cPec == "P"
			MSGStop( cGru +" "+alltrim(cCod)+"  ( " + alltrim(sb1->b1_desc) + STR0223,STR0160)
		Else
			MSGStop(STR0224,STR0160)
		Endif
	Endif
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FV_FilVei³ Autor ³  Manoel               ³ Data ³ 20/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtra veiculos no Estoque                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Function FV_FILVEI()
//
//If !Pergunte("FILVEI",.t.)
//	Return
//Endif
//
//wLinFilt := "Subs(VV1->VV1_FABMOD,1,4) >= " + MV_PAR01 + " .and. Subs(VV1->VV1_FABMOD,1,4) <= " + MV_PAR02 + " .and. VV1->VV1_MODVEI == " + MV_PAR03 +;
//"VV1->VV1_COMVEI == " + MV_PAR04 + " .and. IVV1->VV1_SUGVDA >= " + MV_PAR05 + " .and. VV1->VV1_SUGVDA <= " + MV_PAR06 + ".or. VV1->VV1_SUGVDA == 0)"
//
//Return(wLinFilt)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_DADOSENT ³ Autor ³ Andre               ³ Data ³ 29/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Digita Dados da entrada do Pagamento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Valor Total                                                 ³±±
±±³          |cTipOpe 1 -> Condicao de Pagamento para Pecas               ³±±
±±³          |cTipOpe 2 -> Condicao de Pagamento para Oficina             ³±±
±±³          |cTipOpe 3 -> Condicao de Pagamento para Saida   de Veiculos ³±±
±±³          |lPriDig   -> Se .t. o de Pagamento para Saida   de Veiculos ³±±
±±³          |nPosC     -> Se lPriDig = .f. este parametro e Obrigatorio  ³±±
±±³          |             e a posicao da lunha do aColsC                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_DADOSENT(_nValor,cTipOpe,lPriDig,nPosC)

Local aCamposTRB := {}
Local cCadastro  := STR0225
Local i			 := 0
Local nPosT		 := 0
Local wy		 := 0
Local x			 := 0
Local j			 := 0
Local xy		 := 0

Private wVar05
Private oScroll, Lin
Private nValor := _nValor

if lPriDig == Nil
	lPriDig := .t.
Endif

wAlias := alias()

//Array contendo os Campos do Arquivo de Trabalho.

Lin := n

if aCols[Lin,Len(aCols[Lin])] == .t.
	Return .t.
Endif

if Lin <= Len(aCols) .and. !Empty(aCols[Lin,FG_POSVAR("VS9_TIPPAG","aHeaderC")])
	if ReadVar() # "M->VS9_REFPAG"
		Return .f.
	Endif
Endif

if !Readvar() = "M->VS9_TIPPAG"
	if !Readvar() = "M->VS9_REFPAG"
		Return .t.
	Endif
Endif

aColsCSlv := aClone(aColsC)

if M->VS9_TIPPAG = "CD"
	MsgInfo(STR0350,STR0002) //Codigo de pagamento para referencia interna... #Atencao
	Return .f.
Endif

if lPriDig
	aadd(aCamposTRB,{"QTDEPARC","2",03,0,STR0226,"999"              ,".t." })
	aadd(aCamposTRB,{"INTERVAL","2",02,0,STR0227,"99"               ,".t." })
	aadd(aCamposTRB,{"PRIMPARC","2",02,0,STR0228,"99"               ,".t." })
	aadd(aCamposTRB,{"NUMDOCTO","2",10,0,STR0229,"9999999999"       ,".t." })
	aadd(aCamposTRB,{"VALDOCTO","2",10,0,STR0230,"@E 999,999,999.99","FG_VALVALOR(nValor,wVar05,cTipOpe)" })
Endif

DbSelectarea("VSA")
if DbSeek(xFilial("VSA")+M->VS9_TIPPAG)
	DbSelectarea("VSB")
	if DbSeek(xFilial("VSB")+M->VS9_TIPPAG)
		Do While !EOF() .and. VSB_TIPPAG == VSA->VSA_TIPPAG
			if !Empty(VSB_NOMECP) .and. !Empty(VSB_TIPOCP)
				aadd(aCamposTRB,{VSB_NOMECP,VSB_TIPOCP,VSB_TAMACP,VSB_DECICP,VSB_DESCCP,VSB_PICTCP,VSB_VALICP})
			Endif
			DbSkip()
		Enddo
	Endif
Else
	Return(.f.)
Endif

aTela := {}
aGets := {}

For i:=1 to Len(aCamposTRB)
	if Empty(aCamposTRB[i,7])
		aCamposTRB[i,7] := ".t."
	Endif
	if aCamposTRB[i,2] == [1]
		wSpa  := aCamposTRB[i,3]
		wVar  := "wVar"+StrZero(i,2)
		wPic  := "wPic"+StrZero(i,2)
		wSiz  := "wSiz"+StrZero(i,2)
		wVal  := "wVal"+StrZero(i,2)
		&wSiz := IIf(wSpa*8>90,90,wSpa*8)
		&wPic := aCamposTRB[i,6]
		&wVal := aCamposTRB[i,7]
		&wVar := Space(wSpa)
	Elseif aCamposTRB[i,2] == [2]
		wSpa  := aCamposTRB[i,3]
		wVar  := "wVar"+StrZero(i,2)
		wPic  := "wPic"+StrZero(i,2)
		wSiz  := "wSiz"+StrZero(i,2)
		wVal  := "wVal"+StrZero(i,2)
		&wSiz := IIf(wSpa*8>90,90,wSpa*8)
		&wPic := aCamposTRB[i,6]
		&wVal := aCamposTRB[i,7]
		&wVar := 0
	Else
		wSpa  := aCamposTRB[i,3]
		wVar  := "wVar"+StrZero(i,2)
		wPic  := "wPic"+StrZero(i,2)
		wSiz  := "wSiz"+StrZero(i,2)
		wVal  := "wVal"+StrZero(i,2)
		&wSiz := IIf(wSpa*8>90,90,wSpa*8)
		&wPic := aCamposTRB[i,6]
		&wVal := aCamposTRB[i,7]
		&wVar := ctod('')
	Endif
	if !Empty(&wVal)
		if !"(" $ &wVal
			if Type(&WVal) $ "UE/UI"
				MsgStop(STR0231+ aCamposTRB[i,5] +STR0232,STR0233)
				&wVal := ".t."
			Endif
		Endif
	Endif
Next

if !lPriDig
	For nPosT := 1 to Len(aGravaEnt)
		if aGravaEnt[nPosT,1] == nPosC
			For x := 1 to Len(aCamposTRB)
				if Empty(aCamposTRB[x,7])
					aCamposTRB[x,7] := ".t."
				Endif
				wSpa  := aCamposTRB[x,3]
				wVar  := "wVar"+StrZero(x,2)
				wPic  := "wPic"+StrZero(x,2)
				wSiz  := "wSiz"+StrZero(x,2)
				wVal  := "wVal"+StrZero(x,2)
				&wSiz := IIf(wSpa*8>90,90,wSpa*8)
				&wPic := aCamposTRB[x,6]
				&wVal := aCamposTRB[x,7]
				if aCamposTRB[x,2] == [1]
					&wVar := aGravaEnt[nPosT,9]
				Elseif aCamposTRB[x,2] == [2]
					&wVar := Val(aGravaEnt[nPosT,9])
				Else
					&wVar := CToD(aGravaEnt[nPosT,9])
				Endif
				nPosT++
			Next
		Endif
	Next
Endif

zOpca := 1

DEFINE MSDIALOG oDlgEPar FROM  06,12 TO 29,90 TITLE cCadastro OF oMainWnd

Lin := 15

If Len(aCamposTRB) > 0
	@ Lin, 005 say aCamposTRB[1,5] OF oDlgEPar Pixel
	@ Lin, 050 MSGET wVar01 PICTURE wPic01 VALID &wVal01 SIZE wSiz01,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 1
	@ Lin, 005 say aCamposTRB[2,5] OF oDlgEPar Pixel
	@ Lin, 050 MSGET wVar02 PICTURE wPic02 VALID &wVal02 SIZE wSiz02,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 2
	@ Lin, 005 say aCamposTRB[3,5] OF oDlgEPar Pixel
	@ Lin, 050 MSGET wVar03 PICTURE wPic03 VALID &wVal03 SIZE wSiz03,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 3
	@ Lin, 005 say aCamposTRB[4,5] OF oDlgEPar Pixel
	@ Lin, 050 MSGET wVar04 PICTURE wPic04 VALID &wVal04 SIZE wSiz04,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 4
	@ Lin, 005 say aCamposTRB[5,5] OF oDlgEPar Pixel
	@ Lin, 050 MSGET wVar05 PICTURE wPic05 VALID &wVal05 SIZE wSiz05,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 5
	@ Lin, 005 say aCamposTRB[6,5] OF oDlgEPar Pixel
	@ Lin, 050 MSGET wVar06 PICTURE wPic06 VALID &wVal06 SIZE wSiz06,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 6
	@ Lin, 005 say aCamposTRB[7,5] OF oDlgEPar Pixel
	@ Lin, 050 MSGET wVar07 PICTURE wPic07 VALID &wVal07 SIZE wSiz07,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 7
	@ Lin, 005 say aCamposTRB[8,5] OF oDlgEPar Pixel
	@ Lin, 050 MSGET wVar08 PICTURE wPic08 VALID &wVal08 SIZE wSiz08,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 8
	@ Lin, 005 say aCamposTRB[9,5] OF oDlgEPar Pixel
	@ Lin, 050 MSGET wVar09 PICTURE wPic09 VALID &wVal09 SIZE wSiz09,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 9
	@ Lin, 005 say aCamposTRB[10,5] OF oDlgEPar Pixel
	@ Lin, 050 MSGET wVar10 PICTURE wPic10 VALID &wVal10 SIZE wSiz10,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

Lin := 15

If Len(aCamposTRB) > 10
	@ Lin, 150 say aCamposTRB[11,5] OF oDlgEPar Pixel
	@ Lin, 205 MSGET wVar11 PICTURE wPic11 VALID &wVal11 SIZE wSiz11,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 11
	@ Lin, 150 say aCamposTRB[12,5] OF oDlgEPar Pixel
	@ Lin, 205 MSGET wVar12 PICTURE wPic12 VALID &wVal12 SIZE wSiz12,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 12
	@ Lin, 150 say aCamposTRB[13,5] OF oDlgEPar Pixel
	@ Lin, 205 MSGET wVar13 PICTURE wPic13 VALID &wVal13 SIZE wSiz13,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 13
	@ Lin, 150 say aCamposTRB[14,5] OF oDlgEPar Pixel
	@ Lin, 205 MSGET wVar14 PICTURE wPic14 VALID &wVal14 SIZE wSiz14,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 14
	@ Lin, 150 say aCamposTRB[15,5] OF oDlgEPar Pixel
	@ Lin, 205 MSGET wVar15 PICTURE wPic15 VALID &wVal15 SIZE wSiz15,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 15
	@ Lin, 150 say aCamposTRB[16,5] OF oDlgEPar Pixel
	@ Lin, 205 MSGET wVar16 PICTURE wPic16 VALID &wVal16 SIZE wSiz16,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 16
	@ Lin, 150 say aCamposTRB[17,5] OF oDlgEPar Pixel
	@ Lin, 205 MSGET wVar17 PICTURE wPic17 VALID &wVal17 SIZE wSiz17,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 17
	@ Lin, 150 say aCamposTRB[18,5] OF oDlgEPar Pixel
	@ Lin, 205 MSGET wVar18 PICTURE wPic18 VALID &wVal18 SIZE wSiz18,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 18
	@ Lin, 150 say aCamposTRB[19,5] OF oDlgEPar Pixel
	@ Lin, 205 MSGET wVar19 PICTURE wPic19 VALID &wVal19 SIZE wSiz19,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 19
	@ Lin, 150 say aCamposTRB[20,5] OF oDlgEPar Pixel
	@ Lin, 205 MSGET wVar20 PICTURE wPic20 VALID &wVal20 SIZE wSiz20,10 OF oDlgEPar PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

ACTIVATE MSDIALOG oDlgEPar CENTER ON INIT (EnchoiceBar(oDlgEPar,{|| zOpca := 1, oDlgEPar:End()},{|| zOpca := 2,oDlgEPar:End()}) )

If zOpca == 1
	If lPriDig
		dDataCal := dDataBase+wVar03
		For i:=1 to wVar01
			If i=1
				aCols[len(aCols),1] := M->VS9_TIPPAG
				aCols[len(aCols),2] := VSA->VSA_DESPAG
				aCols[len(aCols),3] := dDataCal
				aCols[len(aCols),4] := (wVar05/wVar01)
				if wVar04 > 0
					aCols[len(aCols),5] := alltrim(Str(wVar04))+space(15-Len(alltrim(Str(wVar04))))
				Else
					aCols[len(aCols),5] := space(10)
				Endif
				aCols[len(aCols),7] := StrZero(i,2)
				aCols[len(aCols),Len(aCols[i])] := .f.
			Else
				aadd(aCols,array(nUsadoC+1))
				For xy:=1 to Len(aHeader)
					aCols[Len(aCols),xy] := CriaVar(aHeader[xy,2])
				Next

				aCols[len(aCols),1] := M->VS9_TIPPAG
				aCols[len(aCols),2] := Posicione("VSA",1,xFilial("VSA")+M->VS9_TIPPAG,"VSA_DESPAG")
				aCols[len(aCols),3] := dDataCal
				aCols[len(aCols),4] := (wVar05/wVar01)
				if wVar04 > 0
					aCols[len(aCols),5] := alltrim(Str(wVar04+(i-1)))+space(15-Len(alltrim(Str(wVar04))))
				Else
					aCols[len(aCols),5] := space(10)
				Endif
				aCols[len(aCols),7] := StrZero(i,2)
				aCols[len(aCols),Len(aCols[i])] := .f.
			EndIf
			dDataCal := dDataCal+wVar02
		Next
	EndIf

	//Ajusta os tipos de pagamentos iguais e com a mesma sequencia
	cTipIte := ""
	cSeqIte := ""
	For xy:=1 to Len(aCols)
		cTipIte := Alltrim(aCols[xy,1])
		cSeqIte := Alltrim(aCols[xy,7])
		For wy:=xy to Len(aCols)
			If wy == xy
				Loop
			EndIf
			If Alltrim(aCols[wy,1]) == cTipIte
				aCols[wy,7] := StrZero(Val(cSeqIte)+1,2)
				cSeqIte := Alltrim(aCols[wy,7])
			EndIf
		Next
	Next

	// Array com dados dos Tipos de Pagamentos p/ gravar no Arquivo "VSE"
	// aGravaEnt[n,1] == Posicao do aCols
	// aGravaEnt[n,2] == Tipo de Pagamento
	// aGravaEnt[n,3] == Descricao do Campo
	// aGravaEnt[n,4] == Nome do Campo
	// aGravaEnt[n,5] == Tipo de Campo "C/N/D"
	// aGravaEnt[n,6] == Tamanho do Campo
	// aGravaEnt[n,7] == Decimal do Campo
	// aGravaEnt[n,8] == Picture do Campo
	// aGravaEnt[n,9] == Valor Digitado

	If lPriDig
		nPos := n
		For j:=1 to wVar01
			For x:=6 to len(aCamposTRB)
				If aCamposTRB[x,2] == "1"
					cConteudo := "wVar"+Strzero(x,2)
					aadd(aGravaEnt,{nPos,M->VS9_TIPPAG,(aCamposTRB[x,5]),aCamposTRB[x,1],aCamposTRB[x,2],aCamposTRB[x,3],aCamposTRB[x,4],aCamposTRB[x,6],&cConteudo})
				ElseIf aCamposTRB[x,2] == "2"
					//cConteudo := Str(&("wVar"+Strzero(x,2)),aCamposTRB[x,3]+aCamposTRB[x,4])
					cConteudo := Transform(&("wVar"+Strzero(x,2)),aCamposTRB[x,6])
					aadd(aGravaEnt,{nPos,M->VS9_TIPPAG,(aCamposTRB[x,5]),aCamposTRB[x,1],aCamposTRB[x,2],aCamposTRB[x,3],aCamposTRB[x,4],aCamposTRB[x,6],cConteudo})
				Else
					cConteudo := dToc(&("wVar"+Strzero(x,2)))
					aadd(aGravaEnt,{nPos,M->VS9_TIPPAG,(aCamposTRB[x,5]),aCamposTRB[x,1],aCamposTRB[x,2],aCamposTRB[x,3],aCamposTRB[x,4],aCamposTRB[x,6],cConteudo})
				EndIf
			Next
			nPos++
		Next
	Else
		For nPosT := 1 to Len(aGravaEnt)
			If aGravaEnt[nPosT,1] == nPosC
				For x := 1 to Len(aCamposTRB)
					aGravaEnt[nPosT,1] := nPosC
					aGravaEnt[nPosT,2] := aColsC[nPosC,FG_POSVAR("VS9_TIPPAG","aHeaderC")]
					aGravaEnt[nPosT,3] := aCamposTRB[x,5]
					aGravaEnt[nPosT,4] := aCamposTRB[x,1]
					aGravaEnt[nPosT,5] := aCamposTRB[x,2]
					aGravaEnt[nPosT,6] := aCamposTRB[x,3]
					aGravaEnt[nPosT,7] := aCamposTRB[x,4]
					aGravaEnt[nPosT,8] := aCamposTRB[x,6]
					If aCamposTRB[x,2] == "1"
						cConteudo := "wVar"+Strzero(x,2)
						aGravaEnt[nPosT,9] := &cConteudo
					ElseIf aCamposTRB[x,2] == "2"
						cConteudo := Transform(&("wVar"+Strzero(x,2)),aCamposTRB[x,6])
						aGravaEnt[nPosT,9] := cConteudo
					Else
						cConteudo := dToc(&("wVar"+Strzero(x,2)))
						aGravaEnt[nPosT,9] := cConteudo
					EndIf
					nPosT++
				Next
			EndIf
		Next
	EndIf

	If lPriDig
		nVlCal := 0
		For i:=Len(aCols) to (Len(aCols)-(wVar01-1)) Step -1
			If !aCols[i,Len(aCols[i])]
				nVlCal := nVlCal + Round(aCols[i,fg_posvar("VS9_VALPAG","aHeaderC")],2)
			EndIf
		Next
		nVlDIf := wVar05 - nVlCal
		aCols[len(aCols),fg_posvar("VS9_VALPAG","aHeaderC")] := aCols[Len(aCols),fg_posvar("VS9_VALPAG","aHeaderC")] + nVlDIf
	EndIf

	For j := 1 to Len(aCols)
		If !(aCols[j,Len(aCols[j])])
			nTotalEnt := nTotalEnt + aCols[j,fg_posvar("VS9_VALPAG","aHeaderC")]
		EndIf
	Next

	If lPriDig
		n := Len(aCols)
	EndIf
	aColsC := aClone(aCols)
	oGetCondicao:oBrowse:Refresh()

	dbSelectarea("VSA")
	if dbSeek(xFilial("VSA")+M->VS9_TIPPAG)
		M->VS9_DESPAG := VSA->VSA_DESPAG
		aCols[n,FG_POSVAR("VS9_DESPAG")] := VSA->VSA_DESPAG
	Endif

	FS_CALPAR(cTipOpe)

Else
	aColsC := aClone(aColsCSlv)
	aCols[n,1] := "  "
	aCols[n,2] := ""
	M->VS9_TIPPAG := "  "
	If cTipOpe # 3
		oCabecNf:oBox:SetFocus()
	EndIf
EndIf

If !Empty(wAlias)
	DbSelectarea(wAlias)
EndIf

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_VALVALOR ³ Autor ³ Andre               ³ Data ³ 29/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³VerIfica se o Valor Total e menor que o Combinado           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          |nValorTot                                                   ³±±
±±³          |nValorDig                                                   ³±±
±±³          |cTipOpe 1 -> Condicao de Pagamento para Pecas               ³±±
±±³          |cTipOpe 2 -> Condicao de Pagamento para Oficina             ³±±
±±³          |cTipOpe 3 -> Condicao de Pagamento para Saida   de Veiculos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³CDCI                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_VALVALOR(nValorTot,nValorDig,cTipOpe)

Local nSoma := 0
Local nValTot := nValorTot
Local lMsg  := .t.
Local lRet  := .t.
Local i		:= 0

if cTipOpe <> 2
	if cTipOpe == 3
		nValTot := IIf(M->VV0_VALFIN>0,M->VV0_VALTOT-M->VV0_VALFIN,M->VV0_VALTOT)
	Endif
	For i:=1 to Len(aCols)
		If !aCols[i,Len(aCols[i])]
			nSoma+=aCols[i,FG_POSVAR("VS9_VALPAG","aHeaderC")]
		EndIf
	Next
	nValTot -= nSoma
Else
	nValtot := M->VSF_VTOTNF
Endif

If nValordig > nValTot
	nValDif := nValorDig - nValorTot
	M->VV0_VALTRO := nValorDig - nValTot
	//Pergunta se e Troca com Troco
	If cTipOpe == 3
		if !Empty(M->VV0_VALFIN)
			nSoma += M->VV0_VALFIN
		Endif
		nValDif := nValorTot-nSoma-nValorDig
		if !Empty(M->VV0_NUMNFI)
			lTroco := .f.
			lMsg   := .t.
			lRet   := .f.
		Else
			M->VV0_VALTRO := 0
			if (lTroco := (M->VV0_TOTENT+M->VV0_VALFIN) > VV0->VV0_VALTOT)
				M->VV0_VALTRO := M->VV0_TOTENT + M->VV0_VALFIN - M->VV0_VALTOT
			Endif
			lTroco := .t.
			lMsg   := .f.
			lRet   := .t.
			FG_DesfPag()
			/*
			if MsgYesNo("Esta e uma TROCA com TROCO ?","Atencao!!!")
			lTroco := .t.
			lMsg   := .f.
			lRet   := .t.
			FG_DesfPag()
			Endif
			*/
		Endif
	Endif

	if lMsg
		MsgInfo(STR0234, STR0160)

		DEFINE MSDIALOG oDlg2 FROM  10,30 TO 21,55 TITLE cCadastro OF oMainWnd

		@ 002, 003 say STR0235 OF oDlg2 Pixel
		@ 002, 060 MSGET nValorTot PICTURE "@E 999,999,999.99" SIZE 40,10 OF oDlg2 PIXEL COLOR CLR_BLACK when .f.

		@ 016, 003 say STR0328 OF oDlg2 Pixel
		@ 016, 060 MSGET nSoma PICTURE "@E 999,999,999.99" SIZE 40,10 OF oDlg2 PIXEL COLOR CLR_BLACK when .f.

		@ 031, 003 say STR0329 OF oDlg2 Pixel
		@ 031, 060 MSGET nValorDig PICTURE "@E 999,999,999.99" SIZE 40,10 OF oDlg2 PIXEL COLOR CLR_BLACK when .f.

		@ 046, 003 say STR0237 OF oDlg2 Pixel
		@ 046, 060 MSGET nValDIf PICTURE "@E 999,999,999.99" SIZE 40,10 OF oDlg2 PIXEL COLOR CLR_BLACK when .f.

		@ 065, 003 BUTTON oOk     PROMPT (STR0330)       OF oDlg2 SIZE 43,11 PIXEL ACTION oDlg2:End()
		@ 065, 055 BUTTON oCancel PROMPT (STR0331) OF oDlg2 SIZE 43,11 PIXEL ACTION oDlg2:End()

		ACTIVATE MSDIALOG oDlg2 CENTER

		aColsC := aClone(aColsCSlv)
		If cTipOpe # 3
			oCabecNF:oBox:SetFocus()
		EndIf
		lRet := .f.
	Endif
Else
	lRet := .t.
EndIf

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_CONDICAO ³ Autor ³ Andre               ³ Data ³ 29/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula as Parcelas do Financiamento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCond1  = Data                                             ³±±
±±³          ³ cCond2  = Dias para o 1. pagamento                         ³±±
±±³          ³ cCond3  = Qtdade de parcelas                               ³±±
±±³          ³ cCond4  = Intervalo de dias                                ³±±
±±³          ³ cCond5  = Tipo de parcelamento                             ³±±
±±³          ³ cCond6  = Campo Condicao de Pagto do Arquivo de            ³±±
±±³          ³           Entrada/Saida                                    ³±±
±±³          ³ cCond7  = Valor Total a ser Financiado (inclusive c/       ³±±
±±³          ³           Entrada)                                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_CONDICAO(cCond1,cCond2,cCond3,cCond4,cCond5,cCond6,cCond7,cTipOpe)
Local nValEnt := 0
Local aSE4
Local x_
Local i		  := 0
Local x		  := 0

If !SE4->(DbSeek(xFilial("SE4")+IIf(cTipOpe != 2,&("M->"+cCond6),cCond6)))
	FG_DesfPag()
	cCondic1:=ctod(" ")
	cCondic2:=space(02)
	cCondic3:=space(Len(SE1->E1_PARCELA))
	cCondic4:=space(02)
	Return
EndIf

If Empty(cCond2) .or. Val(cCond2) <= 0
	cCond2 := "0"
Else
	cCond2 := strzero(Val(cCond2)+1,4)
EndIf

If !Empty(cCond3).and.!Empty(cCond4) .and. Val(cCond3) > 0 .and. Val(cCond4) > 0
	if Empty(cCond2) .or. Val(cCond2) <= 0
		cCond2 := "0"
	Endif
	aSE4 := {}
	If cCond5 == [1]
		cCondicao := strzero(Val(cCond2),4)
		wDias := Val(cCond2)
		For i:=1 to val(cCond3)-1
			wDias := wDias + Val(cCond4)
			cCondicao := Alltrim(cCondicao)+","+strzero(wDias,4)
		Next
	Else
		cCondicao := strzero(val(cCond2),4)+","+strzero(val(cCond3),4)+","+strzero(val(cCond4),4)
	EndIf
	aadd(aSE4,"999")
	aadd(aSE4,cCondicao)
	aadd(aSE4,cCond5)
	aadd(aSE4," ")
	aadd(aSE4," ")
	aadd(aSE4," ")
Else
	If cTipOpe == 2
		DbSelectarea("SE4")
		If DbSeek(xFilial("SE4")+cCond6)
			cCondicao := E4_CODIGO
		Else
			cCondicao := "0"
		EndIf
	Else
		DbSelectarea("SE4")
		If DbSeek(xFilial("SE4")+&("M->"+cCond6))
			cCondicao := E4_CODIGO
		Else
			cCondicao := "0"
		EndIf
	EndIf
EndIf

// Valor a Financiar - Entrada
For x_:=1 to Len(aColsC)
	If !aColsC[x_,Len(aColsC[x_])]
		dbSelectArea("VSA")
		dbSetOrder(1)
		if dbSeek(xFilial("VSA")+aColsC[x_,FG_POSVAR("VS9_TIPPAG","aHeaderC")]) .and. VSA->VSA_FINANC != "1"
			nValEnt := nValEnt + val(Transform(aColsC[x_,FG_POSVAR("VS9_VALPAG","aHeaderC")],"999999.99"))
		Endif
	EndIf
Next

if cTipOpe == 3
	if M->VV0_VALFIN <> M->VV0_VALTOT
		nValEnt := 0
	Endif
Endif

nValFin := cCond7 - nValEnt

// Executa a Funcao de Financiamento das parcelas
aIteParc := Condicao(nValFin,IIf(cTipOpe != 2,&("M->"+cCond6),cCond6),0,IIf(Empty(cCond1),dDataBase,cCond1),,,IIf(aSE4==Nil,Nil,aSE4))

If Len(aIteParc) == 0 .or. nValFin = 0
	aIteParc  := {{cTod(""),0}}
	If oLbParc != Nil
		oLbParc:SetArray(aIteParc)
		oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
		Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
		oLbParc:Refresh()
	Endif
	Return(.t.)
EndIf

For x:=1 to Len(aIteParc)
	//aIteParc[x,2] := val(Transform(aIteParc[x,2],"999999.99"))
	aIteParc[x,2] := NoRound(aIteParc[x,2],2)
Next

nVlCal := 0
For i:=1 to Len(aIteParc)
	nVlCal := nVlCal + aIteParc[i,2]
Next

nVlDIf := cCond7 - (nVlCal+nValEnt)
aIteParc[Len(aIteParc),2] := aIteParc[Len(aIteParc),2] + nVlDIf

// Refaz o ListBox das Parcelas
If oLbParc != Nil
	oLbParc:SetArray(aIteParc)
	oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
	Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
	oLbParc:Refresh()
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_QTDMEC ºAutor  ³Fabio               º Data ³  05/09/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Quantidade de mecanicos que vai fazer o servico             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cNumOsv := Numero da Os                                     º±±
±±º          ³cSerInt := Numero Interno do Servico                        º±±
±±º          ³cCodPro := Codigo do Produtivo                              º±±
±±º          ³lMensagem := .t. Mostra a Mensagem "Nao Obrigatorio .t."    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_QTDMEC(cNumOsv,cSerInt,cCodPro,dDataIni,nHoraIni,dDataFin,nHoraFin,lMensagem)

Local cSele := Alias(),nPosVO6 := VO6->(Recno()),nIndVO6 := VO6->(IndexOrd()),;
nPosVO1 := VO1->(Recno()),nIndVO1 := VO1->(IndexOrd()),;
nPosVO2 := VO2->(Recno()),nIndVO2 := VO2->(IndexOrd()),;
nPosVO4 := VO4->(Recno()),nIndVO4 := VO4->(IndexOrd()),;
nQtdMec := 0 , aProdTrab := {}

lMensagem := IIf(lMensagem != NIL,lMensagem,.t.)

If Empty( dDataIni )

	Return( .t. )

EndIf

DbSelectArea("VO6")
DbSetOrder(1)
DbSeek(xFilial("VO6")+cSerInt)

DbSelectArea("VO1")
DbSetOrder(1)
DbSeek(xFilial("VO1")+cNumOsv)
Do While !Eof() .And. VO1->VO1_NUMOSV == cNumOsv

	DbSelectArea("VO2")
	DbSetOrder(1)
	DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV+"S")
	Do While !Eof() .And. VO2->VO2_NUMOSV == VO1->VO1_NUMOSV .And. VO2->VO2_TIPREQ == "S"

		DbSelectArea("VO4")
		DbSetOrder(1)
		DbSeek(xFilial("VO4")+VO2->VO2_NOSNUM)
		Do While !Eof() .And. VO4->VO4_NOSNUM == VO2->VO2_NOSNUM

			If VO4->VO4_SERINT == cSerInt .And. !Empty(VO4->VO4_CODPRO) .And. VO4->VO4_CODPRO != cCodPro

				If      Dtos(VO4->VO4_DATINI) + Str(VO4->VO4_HORINI,4) >= Dtos( dDataIni ) + Str( nHoraIni ,4) .And. Dtos(VO4->VO4_DATINI) + Str(VO4->VO4_HORINI,4) <= Dtos( dDataFin ) + Str( nHoraFin ,4)  ;
					.Or. Dtos(VO4->VO4_DATFIN) + Str(VO4->VO4_HORFIN,4) >= Dtos( dDataIni ) + Str( nHoraIni ,4) .And. Dtos(VO4->VO4_DATFIN) + Str(VO4->VO4_HORFIN,4) <= Dtos( dDataFin ) + Str( nHoraFin ,4)  ;
					.Or. Dtos(VO4->VO4_DATINI) + Str(VO4->VO4_HORINI,4) <= Dtos( dDataIni ) + Str( nHoraIni ,4) .And. Dtos(VO4->VO4_DATFIN) + Str(VO4->VO4_HORFIN,4) >= Dtos( dDataIni ) + Str( nHoraIni ,4)  ;
					.Or. Dtos(VO4->VO4_DATINI) + Str(VO4->VO4_HORINI,4) <= Dtos( dDataFin ) + Str( nHoraFin ,4) .And. Dtos(VO4->VO4_DATFIN) + Str(VO4->VO4_HORFIN,4) >= Dtos( dDataFin ) + Str( nHoraFin ,4)

					If Len( aProdTrab ) == 0 .Or. Ascan( aProdTrab , VO4->VO4_CODPRO ) == 0

						Aadd( aProdTrab , VO4->VO4_CODPRO )

						nQtdMec++

					EndIf

				EndIf

			EndIf

			DbSelectArea("VO4")
			DbSkip()

		EndDo

		DbSelectArea("VO2")
		DbSkip()

	EndDo

	DbSelectArea("VO1")
	DbSkip()

EndDo

VO1->(DbSetOrder(nIndVO1))
VO1->(DbGoto(nPosVO1))
VO2->(DbSetOrder(nIndVO2))
VO2->(DbGoto(nPosVO2))
VO4->(DbSetOrder(nIndVO4))
VO4->(DbGoto(nPosVO4))

If !Empty(cSele)
	DbSelectArea(cSele)
EndIf

If nQtdMec > VO6->VO6_QTDMEC

	If lMensagem
		Help("  ",1,"QTDMEC")
	EndIf

	VO6->(DbSetOrder(nIndVO6))
	VO6->(DbGoto(nPosVO6))

	Return(.f.)
EndIf

VO6->(DbSetOrder(nIndVO6))
VO6->(DbGoto(nPosVO6))

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_DESFPAG  ³ Autor ³ Andre               ³ Data ³ 29/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Apaga as parcelas geradas do Financiamento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_DesfPag()

Local aHeaderOld, aColsOld

if Type("aCols") <> "U" .and. Type("aHeader") <> "U"
	aHeaderOld := aClone(aHeader)
	aColsOld   := aClone(aCols)
Endif

if Type("cCodCDCI") <> "U" .and. !Empty(cCodCDCI)
	Do Case
		Case cTipOpe == 1
			if Type("aColsAnt") # "U"
				cCodCDCI  := Space(4)
				nValorCom := 0

				if Type("aColsAnt") <> "U"
					aColsP    := aClone(aColsAnt)
				Endif

				aCols     := aClone(aColsP)
				aHeader   := aClone(aHeaderP)

				oGetPecas:oBrowse:Refresh()

				FS_CALCVAL("S",.f.)

				oCodCDCI:Refresh()
				oValorCom:Refresh()
			Endif
		Case cTipOpe == 2
			if Type("aColsBKP") # "U"
				lFlgVet := .f.
				cCodCDCI  := Space(4)
				nValorCom := 0
				aColsFEC[2] := aClone(aColsBKP[2])
				oCodCDCI:Refresh()
				oValorCom:Refresh()
			Endif
	EndCase
Endif

FS_CALPAR(cTipOpe)

If oLbParc != Nil
	oLbParc:SetArray(aIteParc)
	oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
	Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
	oLbParc:Refresh()
EndIf
if Type("aCols") <> "U" .and. Type("aHeader") <> "U"
	aHeader := aClone(aHeaderOld)
	aCols   := aClone(aColsOld)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_MARCABOXºAutor ³Fabio               º Data ³  05/09/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Marca Status do box                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_MARCABOX(cBox,cCor,cPrisma,cNumOsv,lLibera,lSaiVei)

Local cSele := Alias(),nPosVOF := VOF->(Recno()),nIndVOF := VOF->(IndexOrd()),;
nPosVO1 := VO1->(Recno()),nIndVO1 := VO1->(IndexOrd()),;
nPosVO2 := VO2->(Recno()),nIndVO2 := VO2->(IndexOrd()),;
nPosVO4 := VO4->(Recno()),nIndVO4 := VO4->(IndexOrd()),;
nPosReg := 0 , nHora := 0 ,aTempBox := {} , aTempPrisma := {}
Local ni := 0

Default lLibera := .f.
Default lSaiVei := .f.

nHora := Val(Substr(time(),1,2)+Substr(time(),4,2))

If cBox # NIL .and. !Empty(cBox)

	DbSelectArea("VOF")
	DbSetOrder(1)
	DbSeek(xFilial("VOF")+cBox)
	Do While !Eof() .And. VOF->VOF_FILIAL == xFilial("VOF") .And. IIf( !Empty(cBox) , VOF->VOF_NUMBOX == cBox , .t. )

		If !Empty(VOF->VOF_FUNPRO) .Or. Empty(VOF->VOF_NUMBOX)
			DbSelectArea("VOF")
			DbSkip()
			Loop
		EndIf

		DbSelectArea("VO1")
		DbSetOrder(1)
		If DbSeek( xFilial("VO1") + IIf( cNumOsv == NIL .Or. Empty(cNumOsv) , VOF->VOF_NUMOSV , cNumOsv ) )

			DbSelectArea("VO2")
			DbSetOrder(1)
			DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV+"S")

			DbSelectArea("VO4")
			DbSetOrder(1)
			DbSeek(xFilial("VO4")+VO2->VO2_NOSNUM)
			Do While !Eof() .And. VO4->VO4_FILIAL == xFilial("VO4") .And. VO4->VO4_NOSNUM == VO2->VO2_NOSNUM

				If Empty(VO4->VO4_DATDIS) .Or. lLibera

					&& Box
					If Len(aTempBox) == 0 .Or. (Len(aTempBox) != 0 .And. Ascan(aTempBox,{|x| x[1] == VOF->VOF_NUMBOX}) == 0 )
						Aadd(aTempBox,{VOF->VOF_NUMBOX,VO1->VO1_NUMOSV,"D" , Space(8) })
					EndIf

					If !lLibera

						aTempBox[Len(aTempBox),2] := VO1->VO1_NUMOSV
						aTempBox[Len(aTempBox),4] := VO1->VO1_NUMOSV

						If !Empty(VO4->VO4_DATINI) .And. Empty(VO4->VO4_DATFIN)  && Ocupado e trabalhando
							aTempBox[Len(aTempBox),3] := "O"
						ElseIf aTempBox[Len(aTempBox),3] # "O"                    && se tiver srv trabalhando no srv parado prevalese o trabalhando
							aTempBox[Len(aTempBox),3] := "P"
						EndIf

					EndIf

				EndIf

				DbSelectArea("VO4")
				DbSkip()

			EndDo

			If Len(aTempBox) == 0 .Or. Ascan(aTempBox,{|x| x[1] == VOF->VOF_NUMBOX}) == 0

				If VO1->VO1_STATUS == "A" .And. !lLibera

					Aadd(aTempBox,{VOF->VOF_NUMBOX,VO1->VO1_NUMOSV,"P",VO1->VO1_NUMOSV})

				Else

					Aadd(aTempBox,{VOF->VOF_NUMBOX,VO1->VO1_NUMOSV,"D",Space(8)})

				EndIf

			EndIf

		EndIf

		DbSelectArea("VOF")
		DbSkip()

	EndDo

EndIf

If cCor # NIL .And. cPrisma # NIL .And. cNumOsv # NIL

	&& Prisma
	DbSelectArea("VOF")
	DbSetOrder(3)
	DbSeek(xFilial("VOF")+cCor+cPrisma)
	Do While !Eof() .And. VOF->VOF_FILIAL == xFilial("VOF") .And. IIf( !Empty(cCor+cPrisma) , VOF->VOF_CODCOR+VOF->VOF_PRISMA == cCor+cPrisma , !Empty(VOF->VOF_CODCOR+VOF->VOF_PRISMA) )

		&& Levanta prisma por OS
		DbSelectArea("VO1")
		DbSetOrder(7)
		DbSeek(xFilial("VO1")+VOF->VOF_CODCOR+VOF->VOF_PRISMA)

		Do While !Eof() .And. VO1->VO1_FILIAL+VO1->VO1_CODCOR+VO1->VO1_PRISMA == xFilial("VO1")+VOF->VOF_CODCOR+VOF->VOF_PRISMA

			&& Box
			If !lLibera

				If Len(aTempPrisma) == 0 .Or. (Len(aTempPrisma) != 0 .And. Ascan(aTempPrisma,{|x| x[1]+x[2]+x[3] == VOF->VOF_CODCOR+VOF->VOF_PRISMA+VO1->VO1_NUMOSV}) == 0 )
					Aadd(aTempPrisma,{VOF->VOF_CODCOR,VOF->VOF_PRISMA,VO1->VO1_NUMOSV,VO1->VO1_NUMOSV,"P"})
				EndIf
				If !Empty(VO4->VO4_DATINI) .And. Empty(VO4->VO4_DATFIN)
					aTempPrisma[Len(aTempPrisma),5] := "O"
				EndIf

			Else

				RecLock("VO1",.f.)
				VO1->VO1_CODCOR := Space( Len( VO1->VO1_CODCOR ) )
				VO1->VO1_PRISMA := Space( Len( VO1->VO1_PRISMA ) )
				MsUnLock()

			EndIf

			DbSelectArea("VO1")
			DbSkip()

		EndDo

		&& Levanta prisma por Servicos
		DbSelectArea("VO4")
		DbSetOrder(9)
		DbSeek(xFilial("VO4")+VOF->VOF_CODCOR+VOF->VOF_PRISMA)

		Do While !Eof() .And. VO4->VO4_FILIAL == xFilial("VO4") .And. VO4->VO4_FILIAL+VO4->VO4_CODCOR+VO4->VO4_PRISMA == xFilial("VO4")+VOF->VOF_CODCOR+VOF->VOF_PRISMA

			If Empty(VO4->VO4_DATDIS) .Or. lLibera

				DbSelectArea("VO2")
				DbSetOrder(2)
				DbSeek(xFilial("VO2")+VO4->VO4_NOSNUM)

				DbSelectArea("VO1")
				DbSetOrder(1)
				DbSeek(xFilial("VO1")+VO2->VO2_NUMOSV)

				If !lLibera

					&& Box
					If Len(aTempPrisma) == 0 .Or. (Len(aTempPrisma) != 0 .And. Ascan(aTempPrisma,{|x| x[1]+x[2]+x[3] == VOF->VOF_CODCOR+VOF->VOF_PRISMA+VO1->VO1_NUMOSV}) == 0 )
						Aadd(aTempPrisma,{VOF->VOF_CODCOR,VOF->VOF_PRISMA,VO1->VO1_NUMOSV,VO1->VO1_NUMOSV,"P"})
					EndIf
					If !Empty(VO4->VO4_DATINI) .And. Empty(VO4->VO4_DATFIN)
						aTempPrisma[Len(aTempPrisma),5] := "O"
					EndIf

				Else

					RecLock("VO4",.f.)
					VO4->VO4_CODCOR := Space( Len( VO4->VO4_CODCOR ) )
					VO4->VO4_PRISMA := Space( Len( VO4->VO4_PRISMA ) )
					MsUnLock()

				EndIf

			EndIf

			DbSelectArea("VO4")
			DbSkip()

		EndDo

		If Len(aTempPrisma) == 0

			Aadd(aTempPrisma,{cCor,cPrisma,cNumOsv,Space(Len(cNumOsv)),"D"})

		EndIf

		DbSelectArea("VOF")
		DbSkip()

	EndDo

	&& Marca Prisma
	If lLibera

		Aadd(aTempPrisma,{cCor,cPrisma,cNumOsv,Space(Len(cNumOsv)),"D"})

	EndIf

EndIf

&& Marca Box
For ni:=1 to Len(aTempBox)

	DbSelectArea("VO1")
	DbSetOrder(1)
	If DbSeek( xFilial("VO1") + aTempBox[ni,2] )

		if lSaiVei
			RecLock("VO1" , .f. )
			If lLibera

				VO1->VO1_NUMBOX := Space( Len( VO1->VO1_NUMBOX ) )
				VO1->VO1_DATSAI := dDataBase
				VO1->VO1_HORSAI := Val( Substr(Time(),1,2)+Substr(Time(),4,2) )

			Else

				VO1->VO1_NUMBOX := aTempBox[ni,1]
				VO1->VO1_DATSAI := Ctod("  /  /  ")
				VO1->VO1_HORSAI := 0

			EndIf
			MsUnLock()
		Endif

	EndIf

	DbSelectArea("VOF")
	DbSetOrder(1)
	DbSeek(xFilial("VOF")+aTempBox[ni,1])

	RecLock("VOF",!VOF->(Found()))
	VOF->VOF_FILIAL := xFilial("VOF")
	VOF->VOF_NUMBOX := aTempBox[ni,1]
	VOF->VOF_NUMOSV := aTempBox[ni,4]
	VOF->VOF_SITBOX := aTempBox[ni,3]

	MsUnLock()

Next

For ni:=1 to Len(aTempPrisma)

	DbSelectArea("VOF")
	DbSetOrder(3)
	If DbSeek(xFilial("VOF")+aTempPrisma[ni,1]+aTempPrisma[ni,2]+aTempPrisma[ni,3])

		RecLock("VOF",.f.)

	Else

		DbSeek(xFilial("VOF")+aTempPrisma[ni,1]+aTempPrisma[ni,2])

		RecLock("VOF", !( Found() .And. Empty( VOF->VOF_NUMOSV ) ) )

	EndIf

	VOF->VOF_FILIAL := xFilial("VOF")
	VOF->VOF_CODCOR := aTempPrisma[ni,1]
	VOF->VOF_PRISMA := aTempPrisma[ni,2]
	VOF->VOF_NUMOSV := aTempPrisma[ni,4]
	VOF->VOF_SITBOX := aTempPrisma[ni,5]
	MsUnLock()

Next

VOF->(DbSetOrder(nIndVOF))
VOF->(DbGoTo(nPosVOF))
VO1->(DbSetOrder(nIndVO1))
VO1->(DbGoTo(nPosVO1))
VO2->(DbSetOrder(nIndVO2))
VO2->(DbGoTo(nPosVO2))
VO4->(DbSetOrder(nIndVO4))
VO4->(DbGoTo(nPosVO4))

If !Empty(cSele)
	DbSelectArea(cSele)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FG_GravaVV1ºAutor  ³Manoel             º Data ³  26/05/2000 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava Cadastro de Veiculos qdo alterado no momento da Entra º±±
±±º          ³da da Nota Fiscal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_GravaVV1()

Local bCampo3   := { |nCPO| FieldName(nCPO) }
Local cSavAlias := Alias()
Local nxi		:= 0

DbSelectArea("VV1")

For nxi:=1 to FCount()
	If Type("M->"+(EVAL(bCampo3,nxi))) != "U" .and. "M->"+(EVAL(bCampo3,nxi)) != "M->VV1_FILIAL"
		If &("VV1->"+(EVAL(bCampo3,nxi))) !=  &("M->"+(EVAL(bCampo3,nxi)))
			If MsgYesNo((STR0238),(""))
				RecLock("VV1",.f.)
				FG_GRAVAR("VV1")
				MsUnlock()
			EndIf
			Return .t.
		EndIf
	EndIf
Next

If !Empty(cSavAlias)
	DbSelectArea(cSavAlias)
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_TELACOND³ Autor ³ Andre                ³ Data ³ 29/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Condicao de Pagamento (Financiamento e CDCI)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cObjeto   -> oBjeto de Tela do Programa que chamou a funcao ³±±
±±³          |cTipOpe 1 -> Condicao de Pagamento para Pecas               ³±±
±±³          |cTipOpe 2 -> Condicao de Pagamento para Oficina             ³±±
±±³          |cTipOpe 3 -> Condicao de Pagamento para Saida   de Veiculos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_TELACOND(oObjeto,cTipOpe,nOpc)

Local nLin
Local nLinhas  := 99
Local cLinOk   := "FG_PERGUNTA()"
Local cTudoOk  := "AllwaysTrue()"
Local cFieldOk := "FG_MEMVAR(),FG_DADOSENT(IIf(cTipOpe == 1,nTotOrc,IIf(cTipOpe == 2,nTotTTp,IIf(M->VV0_VALFIN>0,M->VV0_VALFIN,M->VV0_VALTOT))),cTipOpe,IIf(ReadVar()=='M->VS9_REFPAG',.f.,.t.),n),IIf(Readvar() == 'M->VS9_VALPAG',(aCols[n,FG_POSVAR('VS9_VALPAG','aHeaderC')]:=M->VS9_VALPAG, aColsC := aClone(aCols),aHeaderC := aClone(aHeader),FS_CALPAR(cTipOpe)),.t.),FG_MEMVAR()"
Local _ni	   := 0
_SetOwnerPrvt("oBtnFoco") // Para ser utilizado como um botao apenas para ganhar foco - farinelli
If nTotEntr==Nil
	_SetOwnerPrvt("nTotEntr")
Endif
_SetOwnerPrvt("oTotEntr") 	// Declarado pra fora para poder dar o refresh nele de dentro da getdados de itens da entrada

Private oFolderSlv

If cTipOpe == 1
	nLin := 109
ElseIf cTipOpe == 2
	nLin := 109
ElseIf cTipOpe == 3
	nLin := 080
EndIf

If Len(aColsC) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aHeader da Entrada                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsadoC:=0
	DbSelectArea("SX3")
	DbSeek("VS9")
	aHeaderC:={}
	While !Eof().And.(x3_arquivo=="VS9")
		If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN#VS9_PORTAD#VS9_DESPOR#VS9_TIPTEM#VS9_NATURE#VS9_NATSRV#VS9_CARTEI#VS9_SEQTAR")
			//	   If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN#VS9_PORTAD#VS9_DESPOR#VS9_TIPTEM#VS9_NATURE#VS9_CARTEI")
			nUsadoC++
			Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
			wVar := "M->"+x3_campo
			&wVar := CriaVar(x3_campo)
		Endif
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols da Entrada                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For _ni:=1 to nUsadoC
		aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
	Next
Endif

// Dados do Cabecalho da Nota Fiscal
aTela := {}
aGets := {}

// nenhum botao da toolbar ganha foco, por isso nao atualiza o acols e aheader da getdados atual
// este botao foi criado para possibilitar que ao clicar em um botao valido, o sistema
// tenha como tirar o foco da getdados e executar seus eventos onde esta o codigo de atualizacao
// do acols e aheader

@ 5000,5000 BUTTON oBtnFoco PROMPT "" OF oObjeto ACTION (.T.) PIXEL

If cTipOpe == 1
	dbSelectArea("VS1")
	Zero()
	oCabecNF:= MsMGet():New("VS1" ,0,nOpcE,,,,aSegEnc,{015,002,065,312},,2,,,,oObjeto,,.T.,.F.,"aSvATela[2]")
	oCabecNF:oBox:bGotFocus   := {|| AL_Entra(2,"VS1")}
	oCabecNF:oBox:bLostFocus  := {|| AL_Sai(2)}
	aSvATela[2] := aClone(aTela)
	aSvAGets[2] := aClone(aGets)
Elseif  cTipOpe == 2
	dbSelectArea("VSF")
	Zero()
	oCabecNF:= MsMGet():New("VSF" ,0,4,,,,aSegEnc,{015,002,065,312},,2,,,,oObjeto,,.T.,.F.,"aSvATela[2]")
	oCabecNF:oBox:bGotFocus   := {|| FS_Entra(2,IIf(cParam01 == 1,"VO1","SA1"))}
	oCabecNF:oBox:bLostFocus  := {|| FS_Sai(2)}
	aSvATela[2] := aClone(aTela)
	aSvAGets[2] := aClone(aGets)
Elseif  cTipOpe == 3
	@ 013,007 Say oTitVLF Var cTitVLF +"   " + trans(nTotEnt,"@E 999,999,999.99")   OF oObjeto PIXEL COLOR CLR_BLUE FONT oFnt5
Endif

// Dados e Valores do Orcamento
if cTipOpe != 3

	@ 068,002 TO 087,311 LABEL STR0239+Space(180)  OF oObjeto PIXEL

	@ 067,030 Say (STR0240) SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLUE
	@ 074,030 msget oTotSrv1 VAR nTotSrv Picture "@E 999,999,999.99" SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLACK when .f.

	@ 067,080 Say (STR0241) SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLUE
	@ 074,080 msget oTotPec1 VAR nTotPec Picture "@E 999,999,999.99" SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLACK when .f.

	@ 067,130 Say (STR0242) SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLUE
	@ 074,130 msget oTotDes1 VAR nTotDes Picture "@E 999,999,999.99" SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLACK when .f.

	@ 067,180 Say IIf(cTipOpe == 1,(STR0243),IIf(cTipOpe == 2,(STR0244),(STR0245)))  SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLUE
	@ 074,180 msget oTotOrc1 VAR IIf(cTipOpe == 1,nTotOrc,IIf(cTipOpe == 2,nTotTTp,IIf(M->VV0_VALFIN>0,M->VV0_VALFIN,M->VV0_VALTOT))) Picture "@E 999,999,999.99" SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLACK when .f.

	@ 067,230 Say (STR0290) SIZE 30,08 OF oObjeto PIXEL COLOR CLR_BLUE
	@ 074,230 msget oTotEntr VAR nTotEntr Picture "@E 999,999,999.99" SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLACK when .f.

	If ( Type("cObsNF") # "U" .And. SF2->(FieldPos("F2_OBSMEM")) # 0 )
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek("F2_OBSERV"))
			@ 074,282 BUTTON oObsNF PROMPT (STR0332) OF oObjeto SIZE 26,11 PIXEL  ACTION ( cObsNF := FG_OBSERVACAO(cObsNF,SX3->X3_TAMANHO,ALLTRIM(SX3->X3_VALID)) )
		Endif
	Endif

Endif

If cTipOpe == 1
	cTipPag := M->VS1_FORPAG
	cTipPag1:= "VS1_FORPAG"
	cDesPag := M->VS1_DESFPG
	cCodBco := M->VS1_CODBCO
	cDesBco := M->VS1_NOMBCO
Elseif  cTipOpe == 2
	cDepVOO := Space(TAMSX3("VOO_DEPTO")[1])
	DbSelectArea("VS1")
	DbSetOrder(6)//filial + ordem de servico
	If DbSeek(xFilial("VS1")+VO1->VO1_NUMOSV)
		cDepVOO := VS1->VS1_DEPTO
	EndIf
Elseif  cTipOpe == 3
	cTipPag := M->VV0_FORPAG
	cTipPag1:= "VV0_FORPAG"
	cDesPag := M->VV0_DESFPG
EndIf


if  cTipOpe # 3
	@ 088,002 TO 108,311 LABEL STR0246+space(180)  OF oObjeto PIXEL
Endif

If cTipOpe == 1             && Pecas Balcao
	@ 088,030 Say (STR0247) SIZE 60,08 OF oObjeto PIXEL COLOR CLR_BLUE
	@ 088,150 Say (STR0248) SIZE 60,08 OF oObjeto PIXEL COLOR CLR_BLUE
	@ 095,030 msget oTipPag VAR cTipPag Picture "@!" F3 "SE4" VALID (lSalvou := .f.,FS_MUDAFPG() .and. FG_TIRABANCO(cTipPag)) SIZE 05,08 OF oObjeto PIXEL COLOR CLR_BLACK  when FG_TIRACOND("cTipPag")
	@ 095,150 msget oCodBco VAR cCodBco Picture "@!" F3 IIf(Empty(GetMv("MV_BCOCPG")),"A62",GetMv("MV_BCOCPG")) VALID (lSalvou := .f.,IIf(Empty(GetNewPar("MV_VALBCO","")),.t.,IIf(cCodBco$GetNewPar("MV_VALBCO",""),.f.,.t.)),FS_MUDABCO()) SIZE 05,08 OF oObjeto PIXEL COLOR CLR_BLACK //when FG_TIRABANCO(cTipPag)

	if cTipOpe # 3
		@ 096,060 Say oDesPag VAR cDesPag SIZE 100,08 OF oObjeto PIXEL COLOR CLR_BLUE FONT oFnt4
		@ 096,180 Say oDesBco VAR left(cDesBco,23) SIZE 100,08 OF oObjeto PIXEL COLOR CLR_BLUE FONT oFnt4
	Endif

Elseif cTipOpe == 2         && Fechamento de Ordem de Servico
	@ 095,030 msget oTipPag VAR cTipPag Picture "@!" F3 "SE4" VALID (lSalvou := .f., !Empty(cTipPag) .and. FS_MUDAFPG1() .and. FG_TIRABANCO(cTipPag)) SIZE 05,08 OF oObjeto PIXEL COLOR CLR_BLACK when FG_TIRACOND("cTipPag")
	@ 088,120 Say (STR0248) SIZE 60,08 OF oObjeto PIXEL COLOR CLR_BLUE
	@ 095,120 msget oCodBco VAR cCodBco Picture "@!" F3 IIf(Empty(GetMv("MV_BCOCPG")),"A62",GetMv("MV_BCOCPG")) VALID (lSalvou := .f.,IIf(Empty(GetNewPar("MV_VALBCO","")),.t.,IIf(cCodBco$GetNewPar("MV_VALBCO",""),.f.,.t.)),FS_MUDABCO1()) SIZE 05,08 OF oObjeto PIXEL COLOR CLR_BLACK //when FG_TIRABANCO(cTipPag)
	@ 088,164 Say (Alltrim(RetTitle("VOO_DEPTO"))) SIZE 60,08 OF oObjeto PIXEL COLOR CLR_BLUE
	@ 095,164 msget oDeptoVOO VAR cDepVOO  VALID (Empty(cDepVOO) .or. FS_VLDFOS("DP",cDepVOO)) Picture "@!" F3 "76" SIZE 05,08 OF oObjeto PIXEL COLOR CLR_BLACK when .t.
	If lVO1_NATURE
		// 17/11/08 - Natureza Financeiro de Pecas para gravar no SE1 - Quando OFICINA
		@ 088,208 Say (Alltrim(RetTitle("VO1_NATURE"))) SIZE 60,08 OF oObjeto PIXEL COLOR CLR_BLUE
		@ 095,208 msget oNature VAR cVO1_NATURE VALID (Empty(cVO1_NATURE) .or. FS_VLDFOS("NT",cVO1_NATURE)) Picture "@!" F3 "SED" SIZE 40,08 OF oObjeto PIXEL COLOR CLR_BLACK
	EndIf
	If lVO1_NATSRV
		// 17/11/08 - Natureza Financeiro de Servicos para gravar no SE1 - Quando OFICINA
		@ 088,252 Say (Alltrim(RetTitle("VOO_NATSRV"))) SIZE 60,08 OF oObjeto PIXEL COLOR CLR_BLUE
		@ 095,252 msget oNatSrv VAR cVO1_NATSRV VALID (Empty(cVO1_NATSRV) .or. FS_VLDFOS("NT",cVO1_NATSRV)) Picture "@!" F3 "SED" SIZE 40,08 OF oObjeto PIXEL COLOR CLR_BLACK
	EndIf
	//	if cTipOpe # 3
	@ 096,060 Say oDesPag VAR cDesPag SIZE 100,08 OF oObjeto PIXEL COLOR CLR_BLUE FONT oFnt4
	//	   @ 096,180 Say oDesBco VAR "" SIZE 10,08 OF oObjeto PIXEL COLOR CLR_BLUE FONT oFnt4
	//	Endif
Elseif  cTipOpe == 3        && Veiculos
	cTipPag := M->VV0_FORPAG
	cDesPag := M->VV0_DESFPG

	//@ 058, 002 TO 078,311  OF oObjeto PIXEL

	@ 055, 002 Say STR0249 SIZE 86,08 OF oObjeto PIXEL COLOR CLR_BLACK
	@ 065, 004 msget oTipPag VAR cTipPag Picture "@!" F3 "SE4" VALID (lSalvou := .f., Empty(cTipPag) .or. FS_MUDAFPGS()) SIZE 05,08 OF oObjeto PIXEL COLOR CLR_BLACK when (FG_TIRACOND("cTipPag") .and. nOpc # 2 )
	@ 065, 036 Say oDesPag VAR cDesPag SIZE 200,08 OF oObjeto PIXEL COLOR CLR_BLUE FONT oFnt4

	@ 055, 134 Say (STR0290) SIZE 30,08 OF oObjeto PIXEL COLOR CLR_BLACK
	@ 065, 134 msget oTotEntr VAR nTotEntr Picture "@E 999,999,999.99" SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLACK when .f.

	if cTipOpe # 3
		@ 096,060 Say oDesPag VAR cDesPag SIZE 100,08 OF oObjeto PIXEL COLOR CLR_BLUE FONT oFnt4
		//   @ 096,180 Say oDesBco VAR left(cDesBco,23) SIZE 100,08 OF oObjeto PIXEL COLOR CLR_BLUE FONT oFnt4
		@ 096,180 Say oDesBco VAR "" SIZE 10,08 OF oObjeto PIXEL COLOR CLR_BLUE FONT oFnt4
	Endif

EndIf


if nOpc # Nil
	nOpcG := nOpc
Else
	nOpc  := 3
Endif

@ nLin,002 TO nLin+62,311 LABEL STR0250 OF oObjeto PIXEL
aHeader  := aClone(aHeaderC)
aCols    := aClone(aColsC)

nOpcSlv := nOpcG
If cTipOpe == 2 // Fechamento de Ordem de Servicos
	If VAI->(FieldPos("VAI_ALTPAR")) > 0
		VAI->(Dbsetorder(4))
		if VAI->(DbSeek(xFilial("VAI")+__cUserID))
			If VAI->VAI_ALTPAR != "1"
				nOpcG := 2
			Endif
		EndIf
	Endif
Endif

oGetCondicao  := MsGetDados():New(nLin+6,004,nLin+58,308,nOpcG,cLinOk,cTudoOk,"",IIf(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,nLinhas,cFieldOk,,,,oObjeto)
oGetCondicao:oBrowse:Default()
oGetCondicao:oBrowse:bChange       := {|| FG_MEMVAR(), lSalvou := .f. }
oGetCondicao:oBrowse:bEditCol      := {|| FG_TOTENT(.T.),IIf(!Empty(aCols[n,FG_POSVAR("VS9_TIPPAG")]),aCols[n,FG_POSVAR("VS9_DESPAG")] := VSA->VSA_DESPAG,.t.), FS_CALPAR(cTipOpe),lSalvou := .f. }
oGetCondicao:oBrowse:bAltered      := {|| lSalvou := .f. ,FG_TOTENT(.T.)}
oGetCondicao:oBrowse:bDelete       := {|| IIf(aCols[n,Len(aCols[n])] , aCols[n,Len(aCols[n])] := .f. , aCols[n,Len(aCols[n])] := .t.),FG_TOTENT(.T.,.T.),FS_CALPAR(cTipOpe),oGetCondicao:oBrowse:Refresh()}
oGetCondicao:oBrowse:bGotFocus     := {|| IIf(cTipOpe > 1,(aHeader:=aClone(aHeaderC),aCols:=aClone(aColsC),FG_TOTENT(),IIf(nC > Len(aColsC) , nC := n := 1 , n:=nC),oGetCondicao:oBrowse:Refresh()),.t.),IIf(Empty(cTipPag),oTipPag:SetFocus(),.t.)}
oGetCondicao:oBrowse:bLostFocus    := {|| IIf(cTipOpe > 1,(FG_INTEGRI(),aHeaderC:=aClone(aHeader),aColsC:=aClone(aCols),FG_TOTENT(),nC:=n),.t.)}

nOpcG := nOpcSlv

//oGetCondicao:oBrowse:Refresh()
@ nLin+64, 002 TO nLin+131,311 LABEL STR0251       OF oObjeto PIXEL

// Retirada do CDCI - 11/09/08 //
//if cTipOpe # 3    //Veiculos nao possui CDCI
//   @ nLin+104,004 TO nLin+129,148 LABEL STR0252                OF oObjeto PIXEL
//Endif

@ nLin+68, 198 LISTBOX oLbParc FIELDS HEADER  (STR0253),(STR0254) COLSIZES 40,50;
SIZE 110,061 OF oObjeto PIXEL ON DBLCLICK IIf(nOpc # 2,(IIf(cTipope != 3,FG_ALTFINAN(oLbParc:nAt),IIf(cTipFat#"2",IIf(inclui .or. altera,FG_ALTFINAN(oLbPArc:nAt),.t.),.f.))),.f.)

oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}

@ nLin+70, 120 BUTTON oObserv PROMPT (STR0255) OF oObjeto SIZE 26,11 PIXEL  ACTION ( lSalvou := .f.,FS_CALPAR(cTipOpe))
@ nLin+70, 150 BUTTON oObserv PROMPT (STR0256) OF oObjeto SIZE 26,11 PIXEL  ACTION ( n := oGetCondicao:oBrowse:nAt , oGetCondicao:oBrowse:SetFocus() , lSalvou := .f.,FG_DesfPag(),cCondic1:=ctod(" "),cCondic2:=cCondic4:=space(02),cCondic3:=space(Len(SE1->E1_PARCELA)))

@ nLin+70,005 SAY STR0257 SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLUE
@ nLin+70,045 msget oCondic1 VAR cCondic1 Picture "@!"  VALID FG_TIPOPAGTO() SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLACK   when FG_TIRACOND("cCondic1") .and. IIf(nOpc#Nil,nOpc # 2,.t.)

@ nLin+83,005 SAY STR0258 SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLUE
@ nLin+91,005 msget oCondic2 VAR cCondic2 Picture "@!"  VALID FG_TIPOPAGTO() SIZE 30,08 OF oObjeto PIXEL COLOR CLR_BLACK   when FG_TIRACOND("cCondic2") .and. IIf(nOpc#Nil,nOpc # 2,.t.)

@ nLin+83,050 SAY STR0259     SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLUE
@ nLin+91,050 msget oCondic3 VAR cCondic3 Picture "@!"  VALID FG_TIPOPAGTO() SIZE 30,08 OF oObjeto PIXEL COLOR CLR_BLACK   when FG_TIRACOND("cCondic3") .and. IIf(nOpc#Nil,nOpc # 2,.t.)

@ nLin+83,105 SAY STR0260    SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLUE
@ nLin+91,105 msget oCondic4 VAR cCondic4 Picture "@!"  VALID FG_TIPOPAGTO() SIZE 30,08 OF oObjeto PIXEL COLOR CLR_BLACK   when FG_TIRACOND("cCondic4") .and. IIf(nOpc#Nil,nOpc # 2,.t.)
/*
@ nLin+83,150 SAY "Tipo:"         SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLUE
@ nLin+91,150 msget oCondic5 VAR cCondic5 Picture "@!" SIZE 30,08 OF oObjeto PIXEL COLOR CLR_BLACK   when .f.
*/
//CDCI
if cTipOpe # 3    //Veiculos nao possui CDCI
	cCodCDCI := left(cCodCDCI+space(4),4)
	// Retirada do CDCI - 11/09/08 //
	//   @ nLin+108,010 SAY STR0261   SIZE 50,08 OF oObjeto PIXEL COLOR CLR_BLUE
	@ nLin+116,010 msget oCodCDCI  VAR cCodCDCI Picture "@!" F3 "SEN"   VALID (Empty(cCodCDCI) .or. ExistCpo("SEN",cCodCDCI)) SIZE 30,08 OF oObjeto PIXEL COLOR CLR_BLACK
	//   @ nLin+108,050 SAY STR0262  SIZE 50,08   OF oObjeto PIXEL COLOR CLR_BLUE
	@ nLin+116,050 msget oValorCom  VAR nValorCom VALID FS_VVLRCDCI() Picture "@E 999,999,999.99"  SIZE 60,08 OF oObjeto PIXEL COLOR CLR_BLACK
	//   @ nLin+116, 120 BUTTON oObserv PROMPT (STR0263) OF oObjeto SIZE 26,11 PIXEL ACTION (lSalvou := .f. , cCondic1:=ctod(" ") , cCondic2:=cCondic3:=cCondic4:=space(02) , FG_DesfPag() , FS_VVLRCDCI() ) When  !Empty(cCodCDCI) .and. (nTotDes = 0)
	oCodCDCI:lVisible:=.f.
	oValorCom:lVisible:=.f.
	//////////////////////////////////
Endif
If cTipOpe <> 1 // Pecas Balcao
	@ nLin+116, 150 BUTTON oObserv PROMPT (STR0264) OF oObjeto SIZE 26,11 PIXEL ACTION (FS_SLVFOL(1), Pergunte("FIC010",.t.) , FC010CON(), lSalvou := .f.,FS_SLVFOL(2))
Else
	@ nLin+90, 150 BUTTON oObserv PROMPT (STR0264) OF oObjeto SIZE 26,11 PIXEL ACTION (FS_SLVFOL(1), FG_SEEK("SA1","M->VS1_CLIFAT",1,.f.), Pergunte("FIC010",.t.) ,FC010CON(), lSalvou := .f.,FS_SLVFOL(2))
	nCheck := 1
	If Substr(GetMv("MV_LOJAVEI",,"NNNNNN"),1,1) == "S" .and. Substr(GetMv("MV_LOJAVEI",,"NNNNNN"),4,1) == "C"
		nCheck := 2
	EndIf
	//	@ nLin+110,150 RADIO oCheck1 VAR nCheck 3D SIZE 44,10 PROMPT (STR0333), (STR0334) OF oObjeto PIXEL ON CHANGE FS_TICKCOND() WHEN ( Substr(GetMv("MV_LOJAVEI",,"NNNNNN"),1,1) == "S" )
	@ nLin+110,150 RADIO oCheck1 VAR nCheck 3D SIZE 44,10 PROMPT (STR0333), (STR0334) OF oObjeto PIXEL WHEN ( Substr(GetMv("MV_LOJAVEI",,"NNNNNN"),1,1) == "S" )
Endif
Return

//Static Function FS_TICKCOND()
//If nCheck == 2 // CupomFiscal
//	M->VS1_ORCACE := " "
//EndIf
//Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FS_VVLRCDCIºAutor  ³Andre			     º Data ³  26/05/2000 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida CDCI												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VVLRCDCI()
Local lRet := .t.
If !Empty(cCodCDCI)
	lRet := FG_CDCI()
	lSalvou := .f.
EndIf
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_OBSERVAºAutor  ³Fabio               º Data ³  12/14/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³MOnta tela para digitar a observacao                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_OBSERVACAO(cObsTela,nTamanho,cValidacao,lEdita)

Local cSalvaObs := cObsTela, oObsTela, oDlgObsTela, oObsOk, oObsCancel, nButClick := 2
Default nTamanho := 70
Default cValidacao := ".T."
Default lEdita := .t.

DEFINE MSDIALOG oDlgObsTela TITLE (STR0335) FROM  001,000 TO 15,50 OF oMainWnd

//@ 001,001 GET oObsTela VAR cSalvaObs VALID &(cValidacao) OF oDlgObsTela MEMO SIZE 195,80 PIXEL
@ 001,001 GET oObsTela VAR cSalvaObs OF oDlgObsTela MEMO SIZE 195,80 PIXEL When lEdita

DEFINE SBUTTON oObsOk       FROM 090,130 TYPE 1 ACTION (nButClick := 1,oDlgObsTela:End()) ENABLE OF oDlgObsTela
DEFINE SBUTTON oObsCancel   FROM 090,160 TYPE 2 ACTION (nButClick := 2,oDlgObsTela:End()) ENABLE OF oDlgObsTela

ACTIVATE MSDIALOG oDlgObsTela CENTER

If nButClick == 1
	cObsTela := cSalvaObs
EndIf

Return( cObsTela )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CALPAR   | Autor ³ Andre               ³ Data ³ 02/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula parcelas do Financiamento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTipOpe                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CALPAR(cTipOpe, nValPar)

Local nValor      := 0
Local aOldaCols
Local aOldaHeader
Local nOld

If Type("aCols") == "A"
	aOldaCols   := aClone(aCols)
	aOldaHeader := aClone(aHeader)
	nOld        := n
Else
	aOldaCols   := {}
	aOldaHeader := {}
	nOld        := 0
Endif

if cTipOpe == 1
	if oFolder:nOption # 3
		Return(.t.)
	Endif
Endif

if cTipOpe == 3
	if Type("lTroco") <> "U" .and. lTroco .and. M->VV0_VALFIN == M->VV0_VALTOT
		Return .t.
	Endif
Endif

if !Empty(aIteParc[1,1]) .and. cTipOpe == 4
	Return(.t.)
Endif

if type("cCodCDCI") <> "U" .and. !Empty(cCodCDCI) .and. nValorCom > 0
	FG_CDCI()
	if cTipOpe == 1
		aHeader := aClone(aHeaderP)
		aCols   := aClone(aColsP)
		FS_CALCVAL("S",.f.)
		aHeader := aClone(aOldaHeader)
		aCols   := aClone(aOldaCols)
	Endif
	Return(.t.)
Endif

if nValPar == Nil .and. cTipOpe <> 4
	nValor := IIf(cTipOpe == 1,nTotTit,IIf(cTipOpe == 2,nTotTTp,IIf(M->VV0_VALFIN>0,M->VV0_VALFIN,M->VV0_VALTOT)))
	if cTipOpe == 2
		//      if SA1->A1_RECISS == "1" .and. nTotSrv > 0
		//         MsgInfo(STR0336,STR0002)
		//         nIssRet := Round(((nTotSrv * GetMV("MV_ALIQISS"))/100),2)
		//         nValor := nTotTTP - nIssRet
		//      Endif
	Endif
Else
	nValor := nValPar
Endif
If cTipOpe <> 4

	nValor -= nTotEntr

	FG_Condicao(cCondic1,cCondic2,cCondic3,cCondic4,cCondic5,IIf(cTipOpe == 2,cTipPag,cTipPag1),nValor,cTipOpe)

	if cTipOpe == 1
		aHeader := aClone(aHeaderP)
		aCols   := aClone(aColsP)
		FS_CALCVAL("N",.f.)
		aHeader := aClone(aOldaHeader)
		aCols   := aClone(aOldaCols)
	Endif

	if cTipOpe = 2
		if left(aOldaHeader[2,2],3) == "VS9"
			aColsC   := aClone(aOldaCols)
			aHeaderC := aClone(aOldaHeader)
			nC       := nOld
		Else
			aCols   := aClone(aColsC)
			aHeader := aClone(aHeaderC)
			n       := nC
		Endif
	Endif

Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_VALORENT | Autor ³ Andre               ³ Data ³ 02/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida o valor da Entrada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_VALORENT()

Local lRet  := .t.
Local nSoma := 0
Local i		:= 0
//
if Funname()=="OFIXA011" .or. FunName() == "OFIOM350" .or. FunName() == "OFIXA021"
	return .t.
endif
if FM_PILHA("OFIXX100")
	Return .t.
endif
//
For i:=1 to Len(aCols)
	if !aCols[i,Len(aCols[i])]
		dbSelectArea("VSA")
		dbSetOrder(1)
		if dbSeek(xFilial("VSA")+aCols[i,FG_POSVAR("VS9_TIPPAG","aHeaderC")])
			If VSA->(FieldPos("VSA_FINANC")) > 0
				If VSA->VSA_FINANC != "1"
					if i # n
						nSoma+=aCols[i,FG_POSVAR("VS9_VALPAG","aHeaderC")]
					Else
						nSoma+=M->VS9_VALPAG
					Endif
				Endif
			Else
				if i # n
					nSoma+=aCols[i,FG_POSVAR("VS9_VALPAG","aHeaderC")]
				Else
					nSoma+=M->VS9_VALPAG
				Endif
			Endif
		Endif
	Endif
Next

Do Case
	Case cTipOpe == 1
		if nSoma > nTotOrc
			lRet := .f.
		Endif
	Case cTipOpe == 2
		if nSoma > nTotTTP
			lRet := .f.
		Endif
	Case cTipOpe  == 3
		nValTot := IIf(M->VV0_VALFIN>0,M->VV0_VALTOT-M->VV0_VALFIN,M->VV0_VALTOT)
		M->VV0_VALTRO := nSoma - nValTot
		if nSoma > nValTot .and. !lTroco
			if !Empty(M->VV0_NUMNFI)
				lTroco := .f.
				lRet   := .f.
			Else
				if !MsgYesNo(STR0337,STR0002)
					lRet := .f.
				Else
					lTroco := .t.
					FG_DesfPag()
				Endif
			Endif
		Endif
EndCase

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_TIPOPAGTO| Autor ³ Andre               ³ Data ³ 02/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Muda Tipo de Pagamento para um que nao gera titulo          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FG_TIPOPAGTO()

Local i := 0

if !Empty(cCondic1) .or. !Empty(cCondic2) .or. !Empty(cCondic3) .or. !Empty(cCondic4)
	cTipPag := RetCondVei()
	if Empty(cTipPag)
		DbSelectArea("SE4")
		For i:= 1 to 1000
			if !DbSeek(xFilial("SE4")+StrZero(i,3))
				RecLock("SE4",.t.)
				SE4->E4_FILIAL := xFilial("SE4")
				SE4->E4_CODIGO := StrZero(i,3)
				SE4->E4_TIPO   := "A"
				SE4->E4_COND   := "CONDICAO NEGOCIADA"
				SE4->E4_DESCRI := "COND. NEGOCIADA"
				SE4->E4_IPI    := "N"
				MsUnlock()
				cTipPag := SE4->E4_CODIGO
				Exit
			Endif
		Next
	Endif
	oTipPag:Refresh()
	dbSelectArea("SE4")
	dbGoTop()
	If DbSeek(xFilial("SE4")+cTipPag)
		cDesPag := SE4->E4_DESCRI
		oDesPag:Refresh()
	EndIf
Endif

lSalvou := .f.

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_TIRACOND ³ Autor ³ Andre               ³ Data ³ 02/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Elimina Condicao de pagto quando houver financiamento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Campo do Get                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FG_TIRACOND(cOpcaoPag)

Local lRet := .t.

If cOpcaoPag == "cTipPag"
	If !Empty(cCondic1) .or. !Empty(cCondic2) .or. !Empty(cCondic3) .or. !Empty(cCondic4)
		lRet := .f.
	Endif
Else
	If !Empty(cTipPag)
		if FG_SEEK("SE4","cTipPag",1,.f.)
			if SE4->E4_TIPO # "A"
				lRet := .f.
			Endif
		Endif
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_TIRABANCO³ Autor ³ Andre               ³ Data ³ 02/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Elimina Banco                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Campo do Get                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FG_TIRABANCO(cCondPagto)
Local ni        := 0
Local cE4_COND  := ""
Local lCondZero := .t.
Local lRet      := .t.
cKeyAce := cCondPagto
FG_SEEK("SE4","cKeyAce",1,.f.)
cE4_COND := Alltrim(SE4->E4_COND)
// Verificar se condicao (SE4->E4_COND) e' diferente de 0 ou 00 ou ... ou 00000000
For ni := 1 to len(cE4_COND)
	If substr(cE4_COND,ni,1) <> "0"
		lCondZero := .f.
		Exit
	EndIf
Next
If type("oCodBco") == "O"
	oCodBco:enable()
EndIf
If lCondZero .and. Empty(cCondic1) .and. alltrim(SE4->E4_TIPO) # "A"
	cCodBco := Space(03)
	cDesBco := Space(20)
	MsgInfo(STR0388,STR0002) // Por se tratar de condicao de pagamento A VISTA, o campo Banco nao podera ser informado! / Atencao
	If type("oCodBco") == "O"
		oCodBco:disable()
	EndIf
	If type("oDesBco") == "O"
		oDesBco:Refresh()
	EndIf
	n := 1
EndIf
If type("oCodBco") == "O"
	oCodBco:Refresh()
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_PERGUNTA ³ Autor ³ Andre               ³ Data ³ 02/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Pergunta se Inclui Nova Entrada                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PERGUNTA()

Local lRet := .t.

if Empty(aCols[n,1]) .and. !aCols[n,Len(aCols[n])]
	MsgInfo(STR0265,STR0160)
	lRet := .f.
Else
	lRet := .t.
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_CDCI     ³ Autor ³ Andre               ³ Data ³ 29/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula as parcelas de CDCI                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_CDCI()

Local x := 0
Local i := 0
if !FS_VerValCom(nValorCom,IIf(cTipOpe == 1,nTotOrc,nTotTTp))
	Return .f.
Endif

If cTipOpe == 1
	nValorBruto := nTotOrc
Elseif cTipOpe == 2
	nValorBruto := nTotTTP
Else
	nValorBruto := IIf(M->VV0_VALFIN>0,M->VV0_VALFIN,M->VV0_VALTOT)
Endif

// Valor a Financiar - Entrada
nValEnt := 0
For x:=1 to Len(aColsC)
	if !aColsC[x,Len(aColsC[x])]
		nValEnt := nValEnt + aColsC[x,FG_POSVAR("VS9_VALPAG","aHeaderC")]
	Endif
Next
nValorCom-=nValEnt

aCalculo := CalcCDCI(nValorBruto, nValorCom, nTotalEnt,cCodCDCI)
aIteParc := aClone(aCalculo[2])

if Len(aIteParc) == 0
	aIteParc  := {{cTod(""),0}}
	Return(.t.)
Endif

if aIteParc[1,2] <= 0
	MsgInfo(STR0351,STR0002)//Valor para negociacao invalido... # Atencao
	nValorCom := 0
	cCodCDCI  := space(4)
	aIteParc  := {{cTod(""),0}}
	oLbParc:SetArray(aIteParc)
	oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
	Transform(aIteParc[oLbParc:nAt,2],"999,999,999.99")}}
	Return(.t.)
Endif

For x:=1 to Len(aIteParc)
	aIteParc[x,2] := val(Transform(aIteParc[x,2],"999999.99"))
Next

nVlCal := 0
For i:=1 to Len(aIteParc)
	nVlCal := nVlCal + aIteParc[i,2]
Next

nVlDif := nValorBruto - (nVlCal+nValEnt)
aIteParc[Len(aIteParc),2] := aIteParc[Len(aIteParc),2] + nVlDif


oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"999,999,999.99")}}
oLbParc:Refresh()

If cTipOpe == 1
	FS_RATEIO110(nValorCom,aIteParc,aCalculo[1])
ElseIf cTipOpe == 2
	FS_RATCDCI(nValorCom,aIteParc,aCalculo[1])
Endif

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_VERVALCOM³ Autor ³ Andre               ³ Data ³ 29/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se o Valor Combinado e maior que o Total           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERVALCOM(nValorCom,nValor)
If nValorCom > nValor
	Help(" ",1,"VALORCOM")  && Valor Combinado eh maior do que o valor da operacao
	Return .f.
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_ALTFINAN³ Autor ³ Andre                ³ Data ³ 29/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Muda manualmente o financiamento                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_ALTFINAN(nCel)

Local nOpca := 0
Local nPar1  := nPar2  := nPar3  := 0
Local nSoma1 := nSoma2 := nSoma3 := 0
Local dNovaData := aIteParc[nCel,1]
Local nNovoValor:= aIteParc[nCel,2]
Local x := 0
Local y := 0

If VAI->(FieldPos("VAI_ALTPAR")) > 0
	VAI->(Dbsetorder(4))
	if VAI->(DbSeek(xFilial("VAI")+__cUserID))
		If VAI->VAI_ALTPAR != "1"
			MsgStop(STR0349,STR0002)  //"Usuario sem permissão para alterar a data e/ou valor da parcela
			Return
		EndIf
	EndIf
EndIf

if Empty(dNovaData) .and. (nNovoValor = 0)
	Return
Endif

if type("cTipOpe") <> "U" .and. cTipOpe <> 3
	if !Empty(cCodCDCI) .and. nValorcom > 0
		Return
	Endif
Endif

DEFINE MSDIALOG oDlgFin TITLE STR0266 From 01,01 to 08,40 of oMainWnd

@ 020, 025 SAY   STR0267 SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_BLUE
@ 020, 048 MSGET oNovaData  VAR dNovaData  PICTURE "@D"                VALID !EMPTY(dNovaData) SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_HBLUE

@ 033, 025 SAY   STR0268 SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_BLUE
@ 033, 048 MSGET oNovoValor VAR nNovoValor PICTURE "@E 999,999,999.99" VALID (nNovoValor > 0)  SIZE 58,08 OF oDlgFin PIXEL COLOR CLR_HBLUE

ACTIVATE MSDIALOG oDlgFin ON INIT (ENCHOICEBAR(oDlgFin,{|| nOpca := 1,oDlgFin:End()},{|| nOpca := 2,oDlgFin:End()}))

if nOpca == 1

	For x:=1 to Len(aIteParc)
		nSoma1 := nSoma1 + aIteParc[x,2]
	Next

	aIteParc[nCel,1] := dNovaData

	aIteParc[nCel,2] := nNovoValor

	For x:=1 to nCel
		nSoma2 := nSoma2 + aIteParc[x,2]
	Next

	nPar1:= (Len(aIteParc)-nCel)

	nSoma3 := (nSoma1 - nSoma2) / nPar1

	For y:=nCel+1 to Len(aIteParc)
		aIteParc[y,2] := nSoma3
	Next

	oLbParc:Refresh()

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_PRCGARVWºAutor ³Renata              º Data ³  26/05/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Formula para o calculo do valor de garantia VW              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estoque                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PRCGARVW()
private n_IPI:= nAlqIPI               //ALIQUOTA IPI
private n_PP := nPrePlu               //VI2->VI2_PREPLU-PRECO PUBLICO
private n_FR := VE5->VE5_REGPRE        //FATOR DE REGIONALIZACAO
private n_FD := VE5->VE5_INDDES        //FATOR DE DESCONTO
private n_TD := VE5->VE5_TXDESP        //TAXA DE DESPESA
private n_ICM:= VE5->VE5_ALIICM        //ALIQUOTA ICMS
private n_IG := VE5->VE5_INDGAR /100   //INDICE GARANTIA
private c_DSH:= VE5->VE5_DSH           //DSH
private c_Gru:= VE5->VE5_GRUDST

private n_Divisor := 0.82              //DIVISOR PARA CALCULO DE PRECO COM ICMS (FIXO)

private n_PrRev1 := 0                  //PRECO REVENDEDOR COM IPI REGIONALIZADO
private n_PrRev2 := 0                  //PRECO REVENDEDOR SEM IPI
private n_PrRev3 := 0                  //PRECO REVENDEDOR SEM IPI (base Sao Paulo)

n_PrRev1 := n_PP * n_FD * n_FR
n_PrRev2 := (n_PrRev1 * 100)/(n_IPI + 100)
n_PrRev3 := (n_PP * n_FD * 100)/(n_IPI + 100)

if c_DSH = "1" .and. c_Gru $ "W  /V  /X  /Y  /"

	nValGar := ROUND((n_PrRev3 * (1 + n_IPI) / 0.74),2)

elseif c_DSH = "1" .and. c_Gru $ "T  /Z  /"

	nValGar := ROUND(n_PP * n_IG,2)

Elseif VE4->VE4_TIPCON = "1"           //AUTOMOVEL

	nValgar := ROUND(n_PrRev3 * ((1 + (n_TD + n_IPI - n_ICM) * 0.01) / n_Divisor),2)

Elseif VE4->VE4_TIPCON = "2"           //CAMINHAO

	nValGar := ROUND(n_PP * n_IG,2)

Endif

Return(nValGar)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_PRCGARSCºAutor ³Renata              º Data ³  26/05/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Formula para o calculo do valor de garantia SC              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estoque                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PRCGARSC()

private n_IG :=(VE5->VE5_INDGAR) /100         //INDICE GARANTIA
private n_PP := nPrePlu                       //PRECO PUBLICO

nValGar := round(n_PP * n_IG,2)

Return(nValGar)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_PRCVDAVWºAutor ³Renata              º Data ³  26/05/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Formula para o calculo do valor de venda VW                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estoque                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PRCVDAVW()
private n_PP := nPrePlu                      //PRECO PUBLICO
nValVda := ROUND(n_PP,2)

Return(nValVda)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_PRCVDASCºAutor ³Renata              º Data ³  26/05/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Formula para o calculo do valor de venda SC                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estoque                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PRCVDASC()
private n_PP := ROUND(nPrePlu,2)                          //PRECO PUBLICO
nValVda := ROUND(n_PP,2)

Return(nValVda)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_PRCREPVWºAutor ³Renata              º Data ³  29/05/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Formula para o calculo do valor de reposicao VW             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estoque                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PRCREPVW()

private n_FR := VE5->VE5_REGPRE     //FATOR DE REGIONALIZACAO
private n_FD := VE5->VE5_INDDES     //FATOR DE DESCONTO

nValRep := ROUND(nPrePlu * n_FR * n_FD,2)

return(nValRep)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_PRCREPSCºAutor ³Renata              º Data ³  29/05/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Formula para o calculo do valor de reposicao SC             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estoque                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_PRCREPSC()
private n_FD   := VE5->VE5_INDDES                      //FATOR DE DESCONTO
private n_IPI  := nAlqIPI/100                          //ALIQ IPI
private n_PP   := nPrePlu                              //PRECO PUBLICO
private n_ICMS := VE5->VE5_ALIICM / 100                //ICMS

WY      := (((100 - n_FD) * n_IPI) / 100) + 1
WVR1    := (n_PP / WY) * (1 - (n_FD/100))              //VALOR COM ICM
WVR2    := WVR1 * (1 - n_ICMS)                         //VALOR SEM ICM
WVIPI   := WVR1 * n_IPI
nValRep := ROUND(WVR2 + WVIPI,2)

Return(nValRep)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_BMP()  ºAutor  ³Fabio               º Data ³  06/30/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostra Bmp do Repositorio                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_BMP(cNomeBmp,cObj)

Local lExist := .f. , cNomeTrunc ,nPosPonto
Local nBmp := 0

nPosPonto  := At( ".",cNomeBmp)
nPosPonto  := IIf(nPosPonto == 0 , Len(cNomeBmp) , nPosPonto - 1 )

cNomeTrunc := Substr(cNomeBmp,1, nPosPonto  )

For nBmp:=1 to &(cObj):RecordCount()

	If Trim(Upper(&(cObj):EntryName(nBmp))) == cNomeTrunc

		lExist := .t.
		Exit

	EndIf

Next

If !lExist

	If MsgYesNo(STR0115,STR0113+" "+cNomeBmp+" "+STR0114)

		cMask := (STR0118)+"(*.BMP) |*.bmp|"+(STR0119)+"(*.*)|*.*|"

		nTamOri := Len(cNomeBmp)

		cArquivo := cGetFile(cMask,(STR0120+" "+cNomeBmp))

		If !Empty(cArquivo)

			&(cObj):InsertBmp( cArquivo ,,)

			lExist := .t.

		EndIf

	EndIf

EndIf

If lExist

	&(cObj):LoadBmp(cNomeTrunc)
	&(cObj):Refresh()

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FG_CALCVD ºAutor  ³Manoel              º Data ³  07/07/2000 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa formula de calculo de comissao/venda/desconto nas   º±±
±±º          ³operacoes de Faturamento Direto da Fabrica                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³cParVD													                 ³±±
±±³"V" - Calcula Valor de Comissao e Desconto a partir do Valor de Venda  ³±±
±±³"C" - Calcula Valor de Venda e Desconto a partir do Valor de Comissao  ³±±
±±³"P" - Calcula Valor de Comissao a partir do % de Comissao e % de Desc  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³FG_CALCVD(cParVD)                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_CALCVD(cParVD)
if cParVD == "V"
	M->VVA_VALCVD := (M->VVA_VALVDA-(M->VVA_VALVDA-(M->VVA_VALVDA/(1+(M->VVA_ALIIPI/100))))-M->VVA_VALVDA*(M->VVA_ALIICM/100)-(M->VVA_ALIPIC/100)*(M->VVA_VALVDA/(1+(M->VVA_ALIIPI/100)))-(M->VVA_VRENET-M->VVA_VRENET*(M->VVA_PERDES/100)))
ElseIf cParVD == "C"
	M->VVA_VALVDA := (M->VVA_VALCVD+(M->VVA_VRENET-M->VVA_VRENET*(M->VVA_PERDES/100)))/(1-(1-(1/(1+(M->VVA_ALIIPI/100))))-(M->VVA_ALIICM/100)-(M->VVA_ALIPIC/100)/(1+(M->VVA_ALIIPI/100)))
ElseIf cParVD == "P"
	M->VVA_VALCVD := (M->VVA_VALVDA-(M->VVA_VALVDA*M->VVA_PERDES)/100)*(M->VVA_PERCVD/100)
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_INIFOLDºAutor  ³Fabio/Manoel        º Data ³  07/13/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Soluciona erro da tecnologia Microsiga na chamada do Folder º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_INIFOLDER(oObj)

Local i:=0 , nOpcA := Len(&(oObj):aDialogs)

For i:=1 to nOpcA
	DEFINE SBUTTON  FROM 1000,1000 TYPE 13 ACTION .t.  ENABLE OF &(oObj):aDialogs[i]
Next

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_VALGRUPO³ Autor ³ Andre                ³ Data ³ 22/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida se o Grupo pode estar na Formula de Precos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_VALGRUPO()

local lRet, cGrupo
Local i

lRet := .t.

if !Empty(M->VEG_GRUPOS )
	For i:=1 to 25
		DbSelectArea("SBM")
		cGrupo := Substr(M->VEG_GRUPOS,(i*4)-3,4)
		if Empty(cGrupo)
			Exit
		Endif
		if !DbSeek(xFilial("SBM")+cGrupo)
			lRet := .f.
			Exit
		Endif
	Next
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_GRUPOFOR³ Autor ³ Andre                ³ Data ³ 22/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida se a Formula pode ser usada para esse Grupo          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Codigo do Grupo e Formula                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_GRUPOFOR(cGrupo,cFormula)

Local i
Local lRet := .t.

if cFormula == Nil
	cFormula := &(ReadVar())
	DbSelectArea("VEG")
	DbSetOrder(1)
	if !DbSeek(xFILIAL("VEG")+cFormula)
		lRet := .f.
	EndIf
Else
	if Type("cGruFor") # "U"
		if VEG->VEG_GRUFOR # cGruFor
			lRet := .f.
		Endif
	Endif

	if lRet
		if !Empty(VEG->VEG_GRUPOS)
			lRet := .f.
			For i:=1 to 25
				if Empty(Substr(VEG->VEG_GRUPOS,(i*4)-3,4))
					Exit
				Else
					if cGrupo == Substr(VEG->VEG_GRUPOS,(i*4)-3,4)
						lRet := .t.
						Exit
					Endif
				Endif
			Next
		Endif
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FG_EnchoiceBar³ Autor ³ Andre                 ³ Data ³25/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Poe a enchoicebar na tela                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_EnchoiceBar(oDlg,bOk,bCancel,nBot,aMoreFunc)

Local oBar, bSet6, bSet15, bSet24, lOk, oBtOk, oBtCan, oBtFab
Local lVolta :=.f.

if nBot == Nil
	nBot := 0
Endif

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

//DEFINE BUTTON RESOURCE "S4WB005N" OF oBar ACTION NaoDisp()     TOOLTIP (STR0269)
//DEFINE BUTTON RESOURCE "S4WB006N" OF oBar ACTION NaoDisp()     TOOLTIP (STR0270)
//DEFINE BUTTON RESOURCE "S4WB007N" OF oBar ACTION NaoDisp()     TOOLTIP (STR0271)
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar ACTION Calculadora() TOOLTIP (STR0272)
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar ACTION Agenda()      TOOLTIP (STR0273)
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar ACTION OurSpool()    TOOLTIP (STR0274)
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar ACTION HelProg()     TOOLTIP (STR0275)

If aMoreFunc # Nil .and. len(aMoreFunc) > 0
	If Type("aNewBot") # "U"
		If Len(aNewBot) >= 1
			cFunc&(alltrim(Str(1))) := aNewBot[1,2]
			DEFINE BUTTON RESOURCE aNewBot[1,1] OF oBar GROUP ACTION &(cFunc&(alltrim(Str(1))))  TOOLTIP (aNewBot[1,3])
		EndIf
		If Len(aNewBot) >= 2
			cFunc&(alltrim(Str(2))) := aNewBot[2,2]
			DEFINE BUTTON RESOURCE aNewBot[2,1] OF oBar GROUP ACTION &(cFunc&(alltrim(Str(2)))) TOOLTIP (aNewBot[2,3])
		EndIf
		If Len(aNewBot) >= 3
			cFunc&(alltrim(Str(3))) := aNewBot[3,2]
			DEFINE BUTTON RESOURCE aNewBot[3,1] OF oBar GROUP ACTION &(cFunc&(alltrim(Str(3)))) TOOLTIP (aNewBot[3,3])
		EndIf
		If Len(aNewBot) >= 4
			cFunc&(alltrim(Str(4))) := aNewBot[4,2]
			DEFINE BUTTON RESOURCE aNewBot[4,1] OF oBar GROUP ACTION &(cFunc&(alltrim(Str(4)))) TOOLTIP (aNewBot[4,3])
		EndIf
		If Len(aNewBot) >= 5
			cFunc&(alltrim(Str(5))) := aNewBot[5,2]
			DEFINE BUTTON RESOURCE aNewBot[5,1] OF oBar GROUP ACTION &(cFunc&(alltrim(Str(5)))) TOOLTIP (aNewBot[5,3])
		EndIf
		If Len(aNewBot) >= 6
			cFunc&(alltrim(Str(6))) := aNewBot[6,2]
			DEFINE BUTTON RESOURCE aNewBot[6,1] OF oBar GROUP ACTION &(cFunc&(alltrim(Str(6)))) TOOLTIP (aNewBot[6,3])
		EndIf
		If Len(aNewBot) >= 7
			cFunc&(alltrim(Str(7))) := aNewBot[7,2]
			DEFINE BUTTON RESOURCE aNewBot[7,1] OF oBar GROUP ACTION &(cFunc&(alltrim(Str(7)))) TOOLTIP (aNewBot[7,3])
		EndIf
		If Len(aNewBot) >= 8
			cFunc&(alltrim(Str(8))) := aNewBot[8,2]
			DEFINE BUTTON RESOURCE aNewBot[8,1] OF oBar GROUP ACTION &(cFunc&(alltrim(Str(8)))) TOOLTIP (aNewBot[8,3])
		EndIf
	EndIf
EndIf

oBar:nGroups += 6
If !nBot == 1
	DEFINE BUTTON oBtOk RESOURCE "Ok" OF oBar GROUP ACTION ( IIf(type("cTudoOk") == "U","AllwaysTrue()",cTudoOk), lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP STR0330  //"OK"###"Ok - <Ctrl-O>"
	SetKEY(15,oBtOk:bAction)
	oDlg:bSet15 := oBtOk:bAction
EndIf

If !nBot == 2
	DEFINE BUTTON oBtCan RESOURCE "Cancel" OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtOff(bSet6,bSet15,bSet24,.T.)) TOOLTIP STR0339  //"CANCEL"###"Cancelar - <Ctrl-X>"
	SetKEY(24,oBtCan:bAction)
	oDlg:bSet24 := oBtCan:bAction
EndIf

oBar:bRClicked := {|| AllwaysTrue()}

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ButtOff   ºAutor  ³Andre 				 º Data ³  08/05/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Botao												      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Concessionaria                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ButtOff(bSet6,bSet15,bSet24,lOk)

DEFAULT lOk := .t.

if lOk
	SetKey(6,bSet6)
	SetKey(15,bSet15)
	SetKey(24,bSet24)
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_SALOSV ºAutor  ³Andre Luis Almeida  º Data ³  08/05/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Saldos - Ordem de Servico / Veiculos do Cliente / CEV      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Concessionaria chamada pelo FINC010 <<<-------------       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_SALOSV(_cCodCli,_cLoja,_cNumOsv)
Local aArea      := {}
Local nBkpMod := 0
Default _cNumOsv := ""
aArea := sGetArea(aArea,"VAI")
aArea := sGetArea(aArea,"SA1")
aArea := sGetArea(aArea,"SA3")
aArea := sGetArea(aArea,"VAM")
aArea := sGetArea(aArea,"VV1")
aArea := sGetArea(aArea,"VV2")
aArea := sGetArea(aArea,"VVC")
aArea := sGetArea(aArea,"VC1")
aArea := sGetArea(aArea,"VC5")
aArea := sGetArea(aArea,"VSO")
aArea := sGetArea(aArea,"VV9")
aArea := sGetArea(aArea,"VO1")
aArea := sGetArea(aArea,"VO2")
aArea := sGetArea(aArea,"VO3")
aArea := sGetArea(aArea,"VO4")
aArea := sGetArea(aArea,"VOK")
aArea := sGetArea(aArea,"VOI")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf

nBkpMod := nModulo
IF nModulo <> 11 .and. nModulo <> 14 .and. nModulo <> 41 //Acesso por outros modulos que não sejam Veiculo/Oficina/Auto Pecas
	nModulo := 14 //Modulo de Oficina
EndIf

DEFINE MSDIALOG oPConces FROM 000,000 TO 021,030 TITLE STR0338 OF oMainWnd // "Dados Concessionaria"
	@ 010,010 BUTTON oOSs PROMPT STR0025 OF oPConces SIZE 100,10 PIXEL ACTION FG_SALDOS(_cCodCli,_cLoja,_cNumOsv,"") // "Ordem de Servico"
	@ 025,010 BUTTON oVei PROMPT STR0173 OF oPConces SIZE 100,10 PIXEL ACTION VEIVC090(_cCodCli,_cLoja,.t.) // "Veiculos do Cliente"
	@ 040,010 BUTTON oCEV PROMPT STR0027 OF oPConces SIZE 100,10 PIXEL ACTION VEICC500(_cCodCli,_cLoja) // "Contatos CEV"
	@ 055,010 BUTTON oOrc PROMPT STR0352 OF oPConces SIZE 100,10 PIXEL ACTION FG_SALDORC(_cCodCli,_cLoja) // "Orcamento"
	@ 070,010 BUTTON oCre PROMPT STR0409 OF oPConces SIZE 100,10 PIXEL ACTION FG_CKCLINI(_cCodCli+_cLoja,.t.,.t.) // Visualiza Crédito do Cliente
//	@ 085,010 BUTTON oPot PROMPT STR0398 OF oPConces SIZE 100,10 PIXEL ACTION OFIOC570(_cCodCli,_cLoja) // Potencial do Cliente
	DEFINE SBUTTON FROM 140,082 TYPE 2 ACTION (oPConces:End()) ENABLE OF oPConces
ACTIVATE MSDIALOG oPConces CENTER

nModulo := nBkpMod
DbSelectArea("SA1")
sRestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_SALDOS ºAutor  ³Fabio               º Data ³  08/05/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Levanta Saldo da Ordem de Servico.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cCodCli = Codigo do Cliente                                º±±
±±º          ³ cLoja   = Loja do Cliente                                  º±±
±±º          ³ cNumOsv = Numero da Ordem de Servico                       º±±
±±º          ³ cChaInt = ChaInt do Veiculo                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina / Veiculo                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_SALDOS(cCodCli,cLoja,cNumOsv,cChaInt)
Local cQuery     := ""
Local cVO3VO4    := "SQLVO3VO4"
Local aRetPec    := {} // Pecas
Local aRetSrv    := {} // Servicos
Local aObjects   := {} , aPosObj := {} , aInfo := {}
Local aSizeAut   := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor    := 0
Local nTamCampo  := 0
Local nTotPecSrv := 0 // Total Geral Pecas + Servicos
Local nATotalPec := 0 // Total Abertas Pecas
Local nATotalSrv := 0 // Total Abertas Servicos
Local nATotPecSrv:= 0 // Total Abertas Pecas + Servicos
Local nFTotalPec := 0 // Total Fechadas Pecas
Local nFTotalSrv := 0 // Total Fechadas Servicos
Local nFTotPecSrv:= 0 // Total Fechadas Pecas + Servicos
Local nValPec    := 0
Local nValSrv    := 0
Local ni         := 0
Local cDesTTpo   := ""
Local aTTSalOsv  := {}
Local aFilAtu    := FWArrFilAtu()
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
Local cFilVO1    := xFilial("VO1")
Private oAzul    := LoadBitmap( GetResources(), "BR_AZUL"  )
Private oVerde   := LoadBitmap( GetResources(), "BR_VERDE" )
Private oPreto   := LoadBitmap( GetResources(), "BR_PRETO" )
Private aCodSer  := {}
Private oVermelho:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Default cCodCli  := ""
Default cLoja    := ""
Default cNumOsv  := ""
Default cChaInt  := ""
aObjects := {}
AAdd( aObjects, { 01, 30, .T. , .F. } )   		//Cabecalho
AAdd( aObjects, { 01, 20, .T. , .T. } )   		//Centro
AAdd( aObjects, { 01, 34, .T. , .F. } )   		//Rodape
for nCntFor := 1 to Len(aSizeAut)
	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
next
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

if TYPE("aSelFil") == "U"
	aSelFil := aClone(aSM0)
Endif


For nCont := 1 to Len(aSelFil)

	cFilAnt := aSelFil[nCont]

	If !Empty(cNumOsv) // Caso for informada o Nro da OS, pegar somente registros da Filial corrente
		If cFilVO1 <> xFilial("VO1")
			Loop
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz levantamento da OS de grava no aTTSalOsv³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT DISTINCT VO3.VO3_FILIAL AS VO_FILIAL , VO1.VO1_STATUS AS VO_STATUS , VO3.VO3_NUMOSV AS VO_NUMOSV , VO3.VO3_TIPTEM AS VO_TIPTEM , VO3.VO3_DATFEC AS VO_DATFEC , VO3.VO3_DATDIS AS VO_DATDIS "
	cQuery += "FROM "+RetSQLName("VO3")+" VO3 "
	cQuery += "JOIN "+RetSQLName("VO1")+" VO1 ON ( VO1.VO1_FILIAL=VO3.VO3_FILIAL AND VO1.VO1_NUMOSV=VO3.VO3_NUMOSV AND "
	If !Empty(cChaInt)
		cQuery += "VO1.VO1_CHAINT='"+cChaInt+"' AND "
	EndIf
	cQuery += "VO1.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VO3.VO3_FILIAL='"+xFilial("VO3")+"' AND "
	If !Empty(cNumOsv)
		cQuery += "VO3.VO3_NUMOSV='"+cNumOsv+"' AND "
	EndIf
	If !Empty(cCodCli+cLoja)
		cQuery += "VO3.VO3_FATPAR='"+cCodCli+"' AND VO3.VO3_LOJA='"+cLoja+"' AND "
	EndIf
	cQuery += "VO3.VO3_DATCAN = ' ' AND "
	cQuery += "VO3.D_E_L_E_T_=' ' "
	//
	cQuery += "UNION "
	//
	cQuery += "SELECT DISTINCT VO4.VO4_FILIAL AS VO_FILIAL , VO1.VO1_STATUS AS VO_STATUS , VO4.VO4_NUMOSV AS VO_NUMOSV , VO4.VO4_TIPTEM AS VO_TIPTEM , VO4.VO4_DATFEC AS VO_DATFEC , VO4.VO4_DATDIS AS VO_DATDIS "
	cQuery += "FROM "+RetSQLName("VO4")+" VO4 "
	cQuery += "JOIN "+RetSQLName("VO1")+" VO1 ON ( VO1.VO1_FILIAL=VO4.VO4_FILIAL AND VO1.VO1_NUMOSV=VO4.VO4_NUMOSV AND "
	If !Empty(cChaInt)
		cQuery += "VO1.VO1_CHAINT='"+cChaInt+"' AND "
	EndIf
	cQuery += "VO1.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VO4.VO4_FILIAL='"+xFilial("VO4")+"' AND "
	If !Empty(cNumOsv)
		cQuery += "VO4.VO4_NUMOSV='"+cNumOsv+"' AND "
	EndIf
	If !Empty(cCodCli+cLoja)
		cQuery += "VO4.VO4_FATPAR='"+cCodCli+"' AND VO4.VO4_LOJA='"+cLoja+"' AND "
	EndIf
	cQuery += "VO4.VO4_DATCAN = ' ' AND "
	cQuery += "VO4.D_E_L_E_T_=' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cVO3VO4 , .F., .T. )
	//
	While !(cVO3VO4)->(Eof())
		////////////////
		// Cria Vetor //
		////////////////
		lRetLib      := .f.
		lRetFec      := .f.
		cFilAdiP     := ""
		cFilAdiS     := ""
		if !Empty((cVO3VO4)->( VO_DATFEC ))
			cStatusOS  := "F"
			lRetFec    := .t.
			lRetLib    := .t.
			cFilAdiP   := "VO3.VO3_DATFEC <> '        '"
			cFilAdiS   := "VO4.VO4_DATFEC <> '        '"
		Elseif !Empty((cVO3VO4)->( VO_DATDIS ))
			cStatusOS  := "D"
			lRetLib    := .t.
		Else
			cStatusOS  := "A"
		Endif
		Aadd(aTTSalOsv,{ cStatusOS , (cVO3VO4)->( VO_FILIAL ) , (cVO3VO4)->( VO_NUMOSV ) , (cVO3VO4)->( VO_TIPTEM ) , 0 , 0 , 0 , 0 , 0 } )
		////////////////
		// Pecas      //
		////////////////
		aRetPec := FMX_CALPEC( (cVO3VO4)->( VO_NUMOSV ) , (cVO3VO4)->( VO_TIPTEM ) ,  ,  , .f. , .f. , .t. , .t. , lRetLib , lRetFec , .f., , cFilAdiP )
		For ni := 1 to len(aRetPec)
			nValPec := ( aRetPec[ni,PECA_VALBRU]-aRetPec[ni,PECA_VALDES] ) // ( Valor Bruto Total do Item - Valor do Desconto )
			aTTSalOsv[len(aTTSalOsv),05] += nValPec // Total de Peca
			aTTSalOsv[len(aTTSalOsv),09] += nValPec // Total da OS
			If !Empty(aRetPec[ni,PECA_DATFEC]) // Data de Fechamento
				nFTotalPec  += nValPec // Total Fechadas Pecas
				nFTotPecSrv += nValPec // Total Fechadas Pecas + Servicos
			Else
				nATotalPec  += nValPec // Total Abertas Pecas
				nATotPecSrv += nValPec // Total Abertas Pecas + Servicos
			EndIf
		Next
		////////////////
		// Servicos   //
		////////////////
		aRetSrv := FMX_CALSER( (cVO3VO4)->( VO_NUMOSV ) , (cVO3VO4)->( VO_TIPTEM ) ,  ,  , .f. , .t. , .t. , lRetLib , lRetFec , .f. , , cFilAdiS )
		For ni := 1 to len(aRetSrv)
			nValSrv := aRetSrv[ni,SRVC_VALLIQ] // Valor Liquido do Servico
			aTTSalOsv[len(aTTSalOsv),06] += aRetSrv[ni,SRVC_TEMPAD] // Tempo Padrao
			aTTSalOsv[len(aTTSalOsv),07] += aRetSrv[ni,SRVC_TEMTRA] // Tempo Trabalhado
			aTTSalOsv[len(aTTSalOsv),08] += nValSrv // Total do Servico
			aTTSalOsv[len(aTTSalOsv),09] += nValSrv // Total da OS
			If !Empty(aRetSrv[ni,24]) // Data de Fechamento
				nFTotalSrv  += nValSrv // Total Fechadas Servicos
				nFTotPecSrv += nValSrv // Total Fechadas Pecas + Servicos
			Else
				nATotalSrv  += nValSrv // Total Abertas Servicos
				nATotPecSrv += nValSrv // Total Abertas Pecas + Servicos
			EndIf
		Next
		(cVO3VO4)->(DbSkip())
	EndDo
	( cVO3VO4 )->( DbCloseArea() )

Next
cFilAnt := cBkpFilAnt

dbSelectArea("VO1")
//
nTotPecSrv += ( nATotPecSrv + nFTotPecSrv ) // Pecas + Servicos ( Abertas + Fechadas )
//
If len(aTTSalOsv) > 0
	Asort(aTTSalOsv,,,{|x,y| x[2]+x[3] < y[2]+y[3] } )
Else
	Aadd(aTTSalOsv,{ "" , "" , "" , "" , 0 , 0 , 0 , 0 , 0 } )
EndIf
//
DEFINE MSDIALOG oDlgOs FROM aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE STR0121 OF oMainWnd PIXEL
	@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4]-50 LABEL "" OF oDlgOs PIXEL
	If !Empty(cCodCli+cLoja)
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+cCodCli+cLoja))
		@ aPosObj[1,1]+004,010 SAY (STR0122) SIZE 025,07          OF oDlgOs PIXEL //Codigo
		@ aPosObj[1,1]+012,010 MSGET SA1->A1_COD      SIZE 035,09 WHEN .F. OF oDlgOs PIXEL
		@ aPosObj[1,1]+004,050 SAY (STR0123) SIZE 020,07          OF oDlgOs PIXEL //Loja
		@ aPosObj[1,1]+012,050 MSGET SA1->A1_LOJA     SIZE 020,09 WHEN .F. OF oDlgOs PIXEL
		@ aPosObj[1,1]+004,075 SAY (STR0124) SIZE 025,07 OF oDlgOs PIXEL //Nome
		@ aPosObj[1,1]+012,075 MSGET SA1->A1_NOME     SIZE 165,09 WHEN .F. OF oDlgOs PIXEL
	Else
		If !Empty(cChaInt)
			VV1->(DbSetOrder(1))
			VV1->(DbSeek(xFilial("VV1")+cChaInt))
			@ aPosObj[1,1]+004,010 SAY Alltrim(STR0048) SIZE 025,07          OF oDlgOs PIXEL //Chassi:
			@ aPosObj[1,1]+012,010 MSGET VV1->VV1_CHASSI SIZE 160,09 WHEN .F. OF oDlgOs PIXEL
		EndIf
	EndIf
	@ aPosObj[2,1],aPosObj[2,2] LISTBOX oLbSalOsv FIELDS HEADER "",STR0127,STR0125,STR0126,STR0128,STR0129,STR0130,STR0131,STR0132;
	 		COLSIZES 10,20,45,20,45,45,45,45,45 SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] OF oDlgOs PIXEL
	oLbSalOsv:SetArray(aTTSalOsv)
	oLbSalOsv:bLine := { || {IIf(aTTSalOsv[oLbSalOsv:nAt,01]=="F",oVermelho,IIf(aTTSalOsv[oLbSalOsv:nAt,01]=="D",oAzul,oVerde)) ,;
	aTTSalOsv[oLbSalOsv:nAt,02] ,;
	aTTSalOsv[oLbSalOsv:nAt,03] ,;
	aTTSalOsv[oLbSalOsv:nAt,04] ,;
	FG_AlinVlrs(Transform(aTTSalOsv[oLbSalOsv:nAt,05],"@E 99,999,999.99")) ,;
	FG_AlinVlrs(Transform(aTTSalOsv[oLbSalOsv:nAt,06],"@E 99:99")) ,;
	FG_AlinVlrs(Transform(aTTSalOsv[oLbSalOsv:nAt,07],"@E 99:99")) ,;
	FG_AlinVlrs(Transform(aTTSalOsv[oLbSalOsv:nAt,08],"@E 99,999,999.99")) ,;
	FG_AlinVlrs(Transform(aTTSalOsv[oLbSalOsv:nAt,09],"@E 99,999,999.99")) }}

	DEFINE SBUTTON FROM aPosObj[1,1]+003,aPosObj[1,4]-35 TYPE 1  ACTION (oDlgOs:End()) ENABLE OF oDlgOs PIXEL
	DEFINE SBUTTON FROM aPosObj[1,1]+016,aPosObj[1,4]-35 TYPE 15 ACTION FS_COFIOC060(aTTSalOsv[oLbSalOsv:nAt,03],aTTSalOsv[oLbSalOsv:nAt,02]) ENABLE OF oDlgOs PIXEL

	nTamCampo := ( ((aPosObj[3,4]/5)*2) / 3 ) - 2

	@ aPosObj[3,1],((aPosObj[3,4]/5)*0)+002 TO aPosObj[3,3],(aPosObj[3,4]/5)*2 LABEL space(50) OF oDlgOs PIXEL
	@ aPosObj[3,1],((aPosObj[3,4]/5)*2)+002 TO aPosObj[3,3],(aPosObj[3,4]/5)*4 LABEL space(25) OF oDlgOs PIXEL

	@ aPosObj[3,1]+000,((aPosObj[3,4]/5)*0)+010 BITMAP oxVerde RESOURCE "BR_VERDE" OF oDlgOs NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+000,((aPosObj[3,4]/5)*0)+020 SAY STR0381 OF oDlgOs SIZE 32,08 PIXEL COLOR CLR_BLACK
	@ aPosObj[3,1]+000,((aPosObj[3,4]/5)*0)+048 BITMAP oxAzul RESOURCE "BR_AZUL" OF oDlgOs NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+000,((aPosObj[3,4]/5)*0)+058 SAY STR0341 OF oDlgOs SIZE 32,08 PIXEL COLOR CLR_BLACK

	@ aPosObj[3,1]+011,((aPosObj[3,4]/5)*0)+005+(nTamCampo*0) SAY STR0133 OF oDlgOs SIZE 105,08 PIXEL COLOR CLR_BLACK //TOTAL PECA
	@ aPosObj[3,1]+011,((aPosObj[3,4]/5)*0)+005+(nTamCampo*1) SAY STR0134 OF oDlgOs SIZE 105,08 PIXEL COLOR CLR_BLACK //TOTAL SERVICO
	@ aPosObj[3,1]+011,((aPosObj[3,4]/5)*0)+005+(nTamCampo*2) SAY STR0342 OF oDlgOs SIZE 105,08 PIXEL COLOR CLR_BLACK //TOTAL

	@ aPosObj[3,1]+019,((aPosObj[3,4]/5)*0)+005+(nTamCampo*0) MSGET oValPec VAR nATotalPec PICTURE "@E 999,999,999.99" SIZE nTamCampo,8  OF oDlgOs PIXEL COLOR CLR_BLACK WHEN .F.
	@ aPosObj[3,1]+019,((aPosObj[3,4]/5)*0)+005+(nTamCampo*1) MSGET oValSer VAR nATotalSrv PICTURE "@E 999,999,999.99" SIZE nTamCampo,8  OF oDlgOs PIXEL COLOR CLR_BLACK WHEN .F.
	@ aPosObj[3,1]+019,((aPosObj[3,4]/5)*0)+005+(nTamCampo*2) MSGET oValTot VAR nATotPecSrv PICTURE "@E 999,999,999.99" SIZE nTamCampo,8  OF oDlgOs PIXEL COLOR CLR_BLACK WHEN .F.

	@ aPosObj[3,1]+000,((aPosObj[3,4]/5)*2)+010 BITMAP oxVermelho RESOURCE "BR_VERMELHO" OF oDlgOs NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+000,((aPosObj[3,4]/5)*2)+020 SAY STR0343 OF oDlgOs SIZE 32,08 PIXEL COLOR CLR_BLACK

	@ aPosObj[3,1]+011,((aPosObj[3,4]/5)*2)+005+(nTamCampo*0) SAY STR0133 OF oDlgOs SIZE 105,08 PIXEL COLOR CLR_BLACK
	@ aPosObj[3,1]+011,((aPosObj[3,4]/5)*2)+005+(nTamCampo*1) SAY STR0134 OF oDlgOs SIZE 105,08 PIXEL COLOR CLR_BLACK
	@ aPosObj[3,1]+011,((aPosObj[3,4]/5)*2)+005+(nTamCampo*2) SAY STR0342 OF oDlgOs SIZE 105,08 PIXEL COLOR CLR_BLACK

	nFTotPecSrv := nFTotalPec+nFTotalSrv
	@ aPosObj[3,1]+019,((aPosObj[3,4]/5)*2)+005+(nTamCampo*0) MSGET oFValPecFec VAR nFTotalPec PICTURE "@E 999,999,999.99" SIZE nTamCampo,8  OF oDlgOs PIXEL COLOR CLR_BLACK WHEN .F.
	@ aPosObj[3,1]+019,((aPosObj[3,4]/5)*2)+005+(nTamCampo*1) MSGET oFValSerFec VAR nFTotalSrv PICTURE "@E 999,999,999.99" SIZE nTamCampo,8  OF oDlgOs PIXEL COLOR CLR_BLACK WHEN .F.
	@ aPosObj[3,1]+019,((aPosObj[3,4]/5)*2)+005+(nTamCampo*2) MSGET oFValTotFec VAR nFTotPecSrv PICTURE "@E 999,999,999.99" SIZE nTamCampo,8  OF oDlgOs PIXEL COLOR CLR_BLACK WHEN .F.

	@ aPosObj[3,1],((aPosObj[3,4]/5)*4)+002 TO aPosObj[3,3],(aPosObj[3,4]/5)*5 LABEL " " OF oDlgOs PIXEL
	@ aPosObj[3,1]+011,((aPosObj[3,4]/5)*4)+005 SAY STR0135 OF oDlgOs SIZE 105,08 PIXEL COLOR CLR_BLACK
	@ aPosObj[3,1]+019,((aPosObj[3,4]/5)*4)+005 MSGET oTotOsv VAR nTotPecSrv PICTURE "@E 9999,999,999.99" SIZE (aPosObj[3,4]/5)-007,8 OF oDlgOs PIXEL COLOR CLR_BLUE WHEN .F.

ACTIVATE MSDIALOG oDlgOs CENTER

Return(nTotPecSrv)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_COFIOC0ºAutor  ³Fabio               º Data ³  08/12/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chama consulta da Ordem de Servico                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_COFIOC060(cNumOsv,cFilOsv)

Local aArea     := {}
Local cSalvFil  := cFilAnt // Salva SM0
Default cFilOsv := xFilial("VO1")

If !Empty( cNumOsv )
	////////////////////
	// Salva Arquivos //
	////////////////////
	cFilAnt := cFilOsv
	aArea := sGetArea(aArea , "SA1")
	aArea := sGetArea(aArea , "VO1")
	If !Empty(Alias())
		aArea := sGetArea(aArea , Alias())
	EndIf
	///////////////////////////////////////////////
	// Consulta da ordem de servico OFIOC060.PRW //
	///////////////////////////////////////////////
	DbSelectArea("VO1")
	DbSetOrder(1)
	DbSeek( cFilOsv + cNumOsv )
	OC060("VO1",Recno(),2)
	////////////////////
	// Volta Arquivos //
	////////////////////
	cFilAnt := cSalvFil
	sRestArea(aArea)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_TRANSITO³ Autor ³ Andre                ³ Data ³ 16/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria um almoxarifado referente a mercadoria em Transito     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Grupo e Codigo da Mercadoria                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_TRANSITO(cGrupo,cCodigo)

Local nQtd := 0

DbSelectArea("VIA")
DbSetOrder(2)
DbSeek(xFilial("VIA")+VE4->VE4_PREFAB+VIA->VIA_CODITE)
DbSelectArea("VE4")
DbSeek(xFilial("VE4")+VIA->VIA_CODMAR)
DbSelectArea("VIA")
While !EOF() .and. VIA->VIA_FILIAL == xFilial("VIA")
	if VE4->VE4_PREFAB+VIA->VIA_CODITE == cGrupo+cCodigo
		nQtd := nQtd + VIA->VIA_QTDFAT
	Endif
	DbSkip()
Enddo

Return(nQtd)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_COMISS ºAutor  ³Fabio               º Data ³  08/19/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula valor da comissao do vendedor                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cTipComissao - Tipo de Comissao - P = Pecas                 º±±
±±º          ³                                  S = Servicos              º±±
±±º          ³                                  V = Veiculos              º±±
±±º          ³xCodVen - Codigo do/s Vendedor/es String Unico Vendedor     º±±
±±º          ³                                  Array varios Vendedores   º±±
±±º          ³dDataCom  - Data da Comissao                                º±±
±±º          ³cTipBus - Tipo de Busca - Se for Peca = Grupo do item       º±±
±±º          ³                                 Servicos = Tipo de Tempo   º±±
±±º          ³                                 Veiculos = Tipo de Venda   º±±
±±º          ³nValor - Valor a ser Calculado                              º±±
±±º          ³cTipRetorno - S - Sintetico                                 º±±
±±º          ³               Retorna matriz com duas posicoes p/ cada     º±±
±±º          ³               vendedor(Codigo Vendedor , Valor) , a        º±±
±±º          ³               primeira com o valor da comissao e a segunda º±±
±±º          ³               com o total das comissoes dos superiores     º±±
±±º          ³              A - Analitico                                 º±±
±±º          ³               Retorna matriz onde a primeira posicao e o   º±±
±±º          ³               codigo e o valor da comissao do vendedor e   º±±
±±º          ³               as outras posicoes e o codigo e o valor da   º±±
±±º          ³               comissao de cada superior.                   º±±
±±º          ³cNosNum - Numero de identificacao para avaliacao.           º±±
±±º          ³lMosHelp - Se .t. mostra Help qdo nao existe Comissao cadas-º±±
±±º          ³           trada. Caso Contrario, nao mostra.               º±±
±±º          ³cMoedaForte - "M" Grava valor no campo da moeda forte.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina / Veiculos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_COMISS(cTipComissao,xCodVen,dDataCom,cTipBus,nValor,cTipRetorno,cNosNum,lMosHelp,cMoedaForte)

Local cSele := Alias() , nPosSA3 := SA3->(RecNo()) , nIndSA3 := SA3->(IndexOrd()) ,;
nPosVEK := VEK->(RecNo()) , nIndVEK := VEK->(IndexOrd())
Local nOrdem := 1 , aComissao := {} , ni := 0 , cNomeCampo , nTamVen := 0 , cType , nValorTotal := nValor ,;
nQtd := 0 , lHelp := .f. , nQtdIndiv := 0 , dDatPagto := Ctod("  /  /  ")
Local aAvaliacao := {} , nPosVSG := 0 , nIndVSG := 0 , aTotaliza := {} , aDeflacao := {}
Local nVend := 0

cMoedaForte:= IIf(cMoedaForte == Nil,"N",cMoedaForte)

if Type("lMosHelp") == "U"
	lMosHelp := .f.
Endif

&& Se tipo for array "A" comissao agrupada
cType := ValType(xCodVen)
If cType == "A"
	nTamVen := Len(xCodVen)
	For ni := 1 to Len(xCodVen)
		nQtd := nQtd+xCodVen[ni,2]
	Next
Else
	nTamVen := 1
EndIf

&& Prepara chave p/ verificar comissao ( "P"-> Pecas , "S"-> Servico, "V"-> Veiculo )
If Upper(cTipComissao) == "P"
	nOrdem := 1                  && Indice utilizado na pesquisa
	cNomeCampo := "GRUITE"       && Campo que sera utilizado n comparacao
ElseIf Upper(cTipComissao) == "S"
	nOrdem := 2
	cNomeCampo := "TIPTEM"
Else
	nOrdem := 3
	cNomeCampo := "TIPVEN"
EndIf

For nVend := 1 to nTamVen

	&& Codigo do vendedor que sera usado p/ calcular a comissao
	If cType == "A"
		cCodVen := xCodVen[nVend,1]
	Else
		cCodVen := xCodVen
	EndIf

	&& Se for Consultor Calculo baseado em cima do valor total se nao calculo em cima valor individual.
	If cType == "A" .And. !Empty(xCodVen[nVend,2])
		nValor    := ( nValorTotal/nQtd )
		nQtdIndiv := xCodVen[nVend,2]
	Else
		nValor    := nValorTotal
		nQtdIndiv := 1
	EndIf

	&& Verifica se existe comissao cadastrada p/ o vendedor.
	DbSelectArea("VEK")
	DbSetOrder(nOrdem)
	If !DbSeek( xFilial("VEK") + cCodVen + cTipComissao + cTipBus + Dtos(dDataCom) , .t. )
		DbSkip(-1)
	EndIf

	If VEK->VEK_CODVEN # cCodVen .Or. VEK->VEK_TIPCOM # cTipComissao .Or. &("VEK->VEK_"+cNomeCampo) # cTipBus .Or. VEK->VEK_DATCOM > dDataCom
		lHelp := .t.
		If Upper(cTipRetorno) # "A" .And. Upper(cTipRetorno) # "D"
			Aadd(aComissao, { cCodVen , 0 } )
			Aadd(aComissao, { cCodVen , 0 } )
		Else
			Aadd(aComissao, { cCodVen , Ctod("  /  /  ") , 0 } )
		EndIf

		&& Vetor para avaliacao
		Aadd(aAvaliacao,{ cCodVen , 0 , 0 })

		Loop

	EndIf

	If Upper(cTipRetorno) # "A" .And. Upper(cTipRetorno) # "D"   && Comissao Sintetica

		&& Comissao do Vendedor
		Aadd(aComissao,{ cCodVen , ( (nValor*VEK->VEK_PERCOM)/100 ) * nQtdIndiv } )

		&& Vetor para avaliacao
		Aadd(aAvaliacao,{ aComissao[Len(aComissao),1] , VEK->VEK_PERCOM , aComissao[Len(aComissao),2] })

		&& Comissao Totalizada dos Superiores ligados ao vendedor
		Aadd(aComissao,{ cCodVen , 0 })

		For ni:=1 to 5
			aComissao[Len(aComissao),Len(aComissao[Len(aComissao)])] := aComissao[Len(aComissao),Len(aComissao[Len(aComissao)])] + ( ( ( ( nValor*&("VEK->VEK_PERSP"+Str(ni,1)) )/100) * nQtdIndiv ) )
		Next

	Else                     && Comissao Analitica
		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek(xFilial("SA3") + VEK->VEK_CODVEN)
		&& Monta dia do pagamente de dia para data
		dDatPagto := Ctod(Str(SA3->A3_DIA,2)+Substr(Dtoc(dDataCom),3))
		If !Empty(SA3->A3_DIA) .And. Day(dDataCom) > SA3->A3_DIA
			dDatPagto := dDatPagto+Day(Lastday( dDatPagto,0))
		EndIf

		&& Comissao do Vendedor
		Aadd(aComissao,{ VEK->VEK_CODVEN , dDatPagto , ( (nValor*VEK->VEK_PERCOM)/100 ) * nQtdIndiv })

		&& Vetor para avaliacao
		Aadd(aAvaliacao,{ VEK->VEK_CODVEN , VEK->VEK_PERCOM , aComissao[Len(aComissao),3] })

		&& Vetor para deflacao
		If Len(aDeflacao) == 0
			Aadd(aDeflacao, {} )
			Aadd(aDeflacao, {} )
		EndIf

		Aadd(aDeflacao[1], { aComissao[Len(aComissao),2] , aComissao[Len(aComissao),3] } )

		&& Comissao de cada superior ligado ao vendedor
		For ni:=1 to 5
			If !Empty( &("VEK->VEK_SUPER"+Str(ni,1)) )
				DbSeek(xFilial("SA3") + &("VEK->VEK_SUPER"+Str(ni,1)) )

				&& Monta dia do pagamente de dia para data
				dDatPagto := Ctod(Str(SA3->A3_DIA,2)+Substr(Dtoc(dDataCom),3))
				If !Empty(SA3->A3_DIA) .And. Day(dDataCom) > SA3->A3_DIA
					dDatPagto := dDatPagto+Day(Lastday( dDatPagto,0))
				EndIf

				Aadd(aComissao,{ &("VEK->VEK_SUPER"+Str(ni,1)) , dDatPagto , ( ( nValor*&("VEK->VEK_PERSP"+Str(ni,1)) )/100 ) * nQtdIndiv } )

				&& Vetor para avaliacao
				Aadd(aAvaliacao,{ aComissao[Len(aComissao),1] , &("VEK->VEK_PERSP"+Str(ni,1)) , aComissao[Len(aComissao),3] })

				&& Vetor para deflacao
				Aadd(aDeflacao[2], { aComissao[Len(aComissao),2] , aComissao[Len(aComissao),3] } )

			EndIf
		Next
	EndIf

	If Upper(cTipRetorno) == "T"    && Totaliza Comissao
		If Len(aTotaliza) == 0
			Aadd(aTotaliza, 0 )
			Aadd(aTotaliza, 0 )
		EndIf

		aTotaliza[1] := aTotaliza[1] + aComissao[Len(aComissao)-1,2]    && Totaliza vendedor
		aTotaliza[2] := aTotaliza[2] + aComissao[Len(aComissao),2]      && Totaliza Superiores
	EndIf

Next

&& Grava valores para avaliacao
If cNosNum # NIL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abre os arquivos se ja nao estiverem abertos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !("VSG"$cFOPENed)
		ChkFile("VSG",.F.)
	EndIf

	nIndVSG := VSG->(IndexOrd())
	nPosVSG := VSG->(RecNo())

	For ni := 1 to Len(aAvaliacao)

		DbSelectArea("VSG")
		DbSetOrder(1)
		DbSeek(xFilial("VSG") + cNosNum + cTipComissao + aAvaliacao[ni,1] )
		RecLock("VSG",!Found())
		VSG->VSG_FILIAL := xFilial("VSG")
		VSG->VSG_NOSNUM := cNosNum
		VSG->VSG_TIPCOM := cTipComissao
		VSG->VSG_CODVEN := aAvaliacao[ni,1]
		VSG->VSG_PERCOM := aAvaliacao[ni,2]

		If cMoedaForte == "N"

			VSG->VSG_VALCOM := aAvaliacao[ni,3]

		Else

			VSG->VSG_MODFOR := aAvaliacao[ni,3]

		EndIf

		MsUnLock()

		//Ponto de Entrada após o desbloqueio do registro na gravação da tabela de Comissão do DMS
		if ExistBlock("PECOMVSG")
			ExecBlock("PECOMVSG",.f.,.f.)
		Endif

	Next

	VSG->(DbSetOrder(nIndVSG))
	VSG->(DbGoTo(nPosVSG))

EndIf

&& Totaliza comissao
If Upper(cTipRetorno) == "T"

	If Len(aTotaliza) == 0
		Aadd(aTotaliza, 0 )
		Aadd(aTotaliza, 0 )
	EndIf

	aComissao := aClone(aTotaliza)

EndIf

&& Deflacao
If Upper(cTipRetorno) == "D"

	&& Vetor para deflacao
	If Len(aDeflacao) == 0
		Aadd(aDeflacao, {} )
		Aadd(aDeflacao, {} )
		Aadd(aDeflacao[1], { Ctod("  /  /  ") , 0 } )
		Aadd(aDeflacao[2], { Ctod("  /  /  ") , 0 } )
	EndIf

	aComissao := aClone(aDeflacao)

EndIf

&& Mostra Help Caso nao exista comissao cadastrada para vendedor

If lHelp .and. lMosHelp
	Help("  ",1,"CNOCOMISS")
EndIf

&& Volta arquivos para suas respectivas condicoes
VEK->(DbSetOrder(nIndVEK))
VEK->(DbGoTo(nPosVEK))
SA3->(DbSetOrder(nIndSA3))
SA3->(DbGoTo(nPosSA3))

//Ponto de Entrada no final da função de gravação da tabela de Comissão do DMS
if ExistBlock("PECOMSE3")
	ExecBlock("PECOMSE3",.f.,.f.)
Endif

If !Empty(cSele)
	DbSelectArea(cSele)
EndIf

Return(aComissao)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_DELETA ºAutor  ³Fabio               º Data ³  08/23/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se registro pode ser deletado                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³aChave - Matriz com Alias do Arquivo, ordem de pesquisa ,   º±±
±±º          ³         chave a procurar e Filtro .                        º±±
±±º          ³cArqDel- Nome do alias do arquivo que vai ter o registro    º±±
±±º          ³         deletado.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina / Veiculos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_DELETA(aChave,cArqDel)

Local cSele := Alias() , lRet := .t. , ni := 0 , cRet
Local aArea,cArqPes,cFilDel,cFilPes,nPosFil,lFil,lIndtemp
Private cIndice , cChave

If cArqDel == NIL
	cArqDel := cSele
EndIf

cFilDel := xFilial(cArqDel)

aArea := sGetArea(aArea,"SX2")

&& Procura se existe registro
For ni := 1 to Len(aChave)

	If !(aChave[ni,1]$cFOPENed)
		ChkFile(aChave[ni,1],.F.)
	EndIf
	cArqPes  := aChave[ni,1]
	cFilPes  := xFilial(cArqPes)
	lFil     := .T.
	lIndTemp := .F.

	DbSelectArea(aChave[ni,1])
	&& Salva configuracao dos arquivos relacionados
	aArea := sGetArea(aArea,aChave[nI,1])

	&& Se nao existir indice acessivel cria indregua
	If ValType(aChave[ni,2]) == "N" .And. aChave[ni,4] == NIL .And. cFilDel == cFilPes

		DbSetOrder(aChave[ni,2])

	Else

		cIndice := CriaTrab(Nil, .F.)

		If ValType(aChave[ni,2]) == "N"

			DbSetOrder(aChave[ni,2])
			cChave  := IndexKey()

		Else

			cChave  := Alltrim(aChave[ni,1])+"_FILIAL+"+Alltrim(aChave[ni,2])
			If SubStr(cChave,1,1) == "S"    // quando e' um alias que comeca com "S" tipo (SA1,SB1,SB2,etc) as iniciais do campo sao apenas 2 caracteres (ALTERADO POR EDUARDO MOTTA - MICROSIGA)
				cChave := SubStr(cChave,2)
			EndIf

		EndIf

		If Empty(cFilDel) .and. !Empty(cFilPes)    // se o Alias do registro que sera deletado for compartilhado e o outro nao ignora a filial
			nPosFil := At("_FILIAL+",cChave)+8
			cChave  := substr(cChave,nPosFil)
			lFil    := .F.
		EndIf

		IndRegua(aChave[ni,1],cIndice,cChave,,aChave[ni,4],(aChave[ni,1]) )
		lIndTemp := .T.

	EndIf

	lRet := !DbSeek( IIf(lFil,xFilial(aChave[ni,1]),"") + aChave[ni,3] )

	&& Apaga indice criado pela indregua
	If lIndTemp
		RetIndex()

		#IFNDEF TOP
			If File(cIndice+OrdBagExt())
				fErase(cIndice+OrdBagExt())
			Endif
		#ENDIF
	EndIf

	If !lRet
		cRet := aChave[nI,1]
		Exit
	EndIf

Next

&& Volta posicoes originais
sRestArea(aArea)

If !lRet
	lRet := .F.
	SX2->(DbSeek(cRet))
	Help("  ",1,"CANCELDEL",,cRet+"- "+(X2Nome() ),4,1)
EndIf

If !Empty(cSele)
	DbSelectArea(cSele)
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_RtDtImpºAutor  ³Manoel              º Data ³  22/08/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna datas de Impostaos para Deflacao                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cTipImp - Tipo de Imposto (Ex. ICM,ISS,IPI,etc)             º±±
±±º          ³dDat    - Data do Movimento                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina / Veiculos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_RtDtImp(cTipImp,dDat)

Local cVenc
Local nDias
Local nPeriodo
Local nDia
Local nMes
Local nAno
Local dData

If cTipImp == "ICM"
	cVenc := GetMV("MV_ICMVENC")
ElseIf cTipImp == "IPI"
	cVenc := GetMV("MV_IPIVENC")
ElseIf cTipImp == "ISS"
	cVenc := GetMV("MV_ISSVENC")
ElseIf cTipImp == "PIS"
	cVenc := GetMV("MV_PISVENC")
ElseIf cTipImp == "COF"
	cVenc := GetMV("MV_COFVENC")
EndIf

nDias    := Val(SubStr(cVenc,1,2))
nPeriodo := Val(SubStr(cVenc,4,1))
nDia     := Day(dDat)
nMes     := Month(dDat)
nAno 	   := Year(dDat)
dData    := dVencto := Ctod("")

dData := Ctod(StrZero(nDia,2)+"/"+ ;			// Dia
StrZero(nMes,2) +"/"+;				// Mes
SubStr(lTrim(Str(nAno)),3,2))  //,"ddmmyy")	// Ano
dVencto := Ctod(StrZero(nDias,2)+"/"+ ;	// Dia
StrZero(nMes,2) +"/"+;				// Mes
SubStr(lTrim(Str(nAno)),3,2)) //,"ddmmyy")	// Ano
Do Case
	Case nPeriodo == 1 // Decendial
		If ( Day( dData ) < 11 )
			dVencto += 10
		Else
			If ( Day( dData ) < 21 )
				dVencto += 20
			Else
				dVencto := Lastday( dVencto,0)+nDias
			EndIf
		EndIf
	Case nPeriodo == 2 // Quinzenal
		If ( Day( dData ) < 15 )
			dVencto += 15
		Else
			dVencto := Lastday( dVencto,0)+nDias
		EndIf
	Case nPeriodo == 3 // Mensal
		dVencto := Lastday( dVencto,0)+nDias
EndCase

dVencto := DataValida(dVencto+1)

Return( dVencto )	// Data Pagto do ICM

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_RtDtCV ºAutor  ³Manoel              º Data ³  22/08/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna datas ou Valores de Custos com Veiculos             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cPar - SGV-Seguro Viagem/FVD-Frete Vd Direta/ASS-Associacao º±±
±±º          ³dDat - Data do Movimento                                    º±±
±±º          ³lValor  - se .t. retorna apenas Valor, senao apenas Data    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina / Veiculos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_RtDtCV(cPar,cMar,dDat,lValor) // Retorna Data de Custos com Veiculos (Seguro Viagem/Associacao/Frete Vda Direta)

Local cAno
Local cMes
Local dDatCorr  := dDataBase
Local nValRet   := 0
Local cSavAlias := alias()

if lValor == nil
	lvalor := .f.
Endif

VE4->(dbSeek(xFilial("VE4")+cMar))

If cPar == "SGV"
	If lValor
		nValRet := FG_Formula(VE4->VE4_FVLSGV)
	Else
		If VE4->VE4_DIASGV # 0
			If Month(M->VV0_DATMOV)+VE4->VE4_MESSGV > 12
				cMes  := StrZero((Month(M->VV0_DATMOV)+VE4->VE4_MESSGV) - 12,2)
				cAno  := StrZero(year(dDat) + 1,4)
			Else
				cMes  := StrZero(Month(dDat)+VE4->VE4_MESSGV,2)
				cAno  := StrZero(year(dDat),4)
			EndIf
			dDatCorr := Ctod( Strzero(VE4->VE4_DIASGV,2) + "/" + cMes + "/" + cAno)
		Else
			dDatCorr := dDat
		EndIf
	EndIf
ElseIf cPar == "ASS"
	if lValor
		nValRet := FG_Formula(VE4->VE4_FVLASS)
	Else
		if VE4->VE4_DIAASS # 0
			if Month(dDat)+VE4->VE4_MESASS > 12
				cMes  := StrZero((Month(dDat)+VE4->VE4_MESASS) - 12,2)
				cAno  := StrZero(year(dDat) + 1,4)
			Else
				cMes  := StrZero(Month(dDat)+VE4->VE4_MESASS,2)
				cAno  := StrZero(year(dDat),4)
			Endif
			dDatCorr := Ctod( Strzero(VE4->VE4_DIAASS,2) + "/" + cMes + "/" + cAno)
		Else
			dDatCorr := dDat
		Endif
	Endif
ElseIf cPar == "FVD"
	if lValor
		nValRet := FG_Formula(VE4->VE4_FVLFVD)
	Else
		if VE4->VE4_DIAFVD # 0
			if Month(dDat)+VE4->VE4_MESFVD > 12
				cMes  := StrZero((Month(dDat)+VE4->VE4_MESFVD) - 12,2)
				cAno  := StrZero(year(dDat) + 1,4)
			Else
				cMes  := StrZero(Month(dDat)+VE4->VE4_MESFVD,2)
				cAno  := StrZero(year(dDat),4)
			Endif
			dDatCorr := Ctod( Strzero(VE4->VE4_DIAFVD,2) + "/" + cMes + "/" + cAno)
		Else
			dDatCorr := dDat
		Endif
	Endif
Endif

If !Empty(cSavAlias)
	DbSelectArea(cSavAlias)
EndIf

if lValor
	if nValRet == nil
		nValRet := 0
	Endif
	Return(nValRet)
Else
	Return(dDatCorr)
Endif

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_CalcMF ºAutor  ³Manoel              º Data ³  22/08/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula Valores em Moeda Forte                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³aVetCalc - Array contendo datas e respectivos valores para  º±±
±±º          ³           calculos em MF                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina / Veiculos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_CalcMF(aVetCalc)

Local cNMF := Alltrim(GetMv("MV_INDMFT"))
Local nValDefl   := 0
Local cSavAlias := alias()
Local nMF		:= 0

DbSelectArea("SM2")
Set SoftSeek on

for nMF = 1 to Len(aVetCalc)

	if Empty(aVetCalc[nMF][1])
		DbSeek(dDataBase)
	Else
		DbSeek(aVetCalc[nMF][1])
	Endif
	if &("SM2->M2_MOEDA"+cNMF) == 0
		dbskip(-1)
	Endif
	if !(aVetCalc[nMF,2] == nil)
		nValDefl := nValDefl + (aVetCalc[nMF,2]/&("SM2->M2_MOEDA"+cNMF))
	Else
		nValDefl := nValDefl + 0
	Endif

Next

If !Empty(cSavAlias)
	DbSelectArea(cSavAlias)
EndIf

Set SoftSeek off

Return(nValDefl)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_RtDtCV ºAutor  ³Manoel              º Data ³  22/08/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna datas e Valores das Parcelas de Compra ou Venda de  º±±
±±º          ³Veiculos                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cNumNota -> Numero do Pedido de Venda ou Numero NF Entrada  º±±
±±º          ³cPrefixo -> Parcelas da Venda ou Serie da NF Entrada        º±±
±±º          ³cTipES   == "E" - Entrada / "S" - Saida                     º±±
±±º          ³nValor   -> Valor da Nota Fiscal                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina / Veiculos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_RetVdCp(cNumNota,cPrefixo,cTipES,nValor)

Local   aRet := {}
Local   cSavAlias := alias()
Local   i := 0

If cTipES == "S" //- Saida

	if (Len(aColsC) = 1) .and. (Empty(aColsC[1,1])) .and. (Empty(aIteParc[1,1]))
		aColsC[Len(aColsC),1] := "DP"
		aColsC[Len(aColsC),2] := "DUPLICATA"
		aColsC[Len(aColsC),3] := dDataBase
		aColsC[Len(aColsC),4] := nValor
	Endif

	For i:=1 to len(aColsC) // Parcelas da Entrada
		if Empty(aColsC[1,1])
			Loop
		Endif
		if aColsC[i,Len(aColsC[i])] == .t.
			Loop
		Endif
		aAdd(aRet,{DataValida(aColsC[i,3]),aColsC[i,4]})
	Next

	For i:=1 to Len(aIteParc) // Parcelas do Financiamento
		if Empty(aIteParc[i,1])
			Exit
		Endif
		aAdd(aRet,{DataValida(aIteParc[i,1]),aIteParc[i,2]})
	Next
Else
	DbSelectArea("SE2")
	SE2->(DBSetOrder(1))
	If SE2->(DBSeek(xFilial('SE2')+cPrefixo+cNumNota))
		while ! Eof() .and. SE2->E2_FILIAL== xFilial('SE2') .and.;
			SE2->E2_NUM == cNumNota  .and.;
			SE2->E2_PREFIXO == cPrefixo
			aadd(aRet,{SE2->E2_VENCREA,SE2->E2_VALOR})
			dbskip()
		Enddo
	Endif
Endif

If !Empty(cSavAlias)
	DbSelectArea(cSavAlias)
EndIf

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_CGC/CPFºAutor  ³Renata              º Data ³  24/08/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Acerta picture do cgc/cpf atraves da PICT variavel          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cTipPes  -> Tipo da pessoa (juridica ou fisica)             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³geral                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_CGC(cTipPes)

If cTipPes = "F"
	cReturn := "@R 999.999.999-99"
ElseIf cTipPes = "J"
	cReturn := "@R 99.999.999/999-99"
Else
	cReturn := "99999999999999"
EndIf

Return(cReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_AltLocalºAutor  ³Renata/Manoel       º Data ³  30/08/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera Almoxarifado do Veiculo no SB1/VVG atraves do VV1     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Veiculos e Oficina                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_AltLocal()

if Empty(VV1->VV1_LOCPAD)
	Return .f.
Endif

cGruVei    := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))

if FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
	DbSelectArea("SB1")
	RecLock("SB1",.f.)
	SB1->B1_LOCPAD := VV1->VV1_LOCPAD
	MsUnlock()
Endif

if FG_Seek("VVG","VV1->VV1_CHAINT+VV1->VV1_TRACPA",2,.f.)
	DbSelectArea("VVG")
	RecLock("VVG",.f.)
	VVG->VVG_LOCPAD := VV1->VV1_LOCPAD
	MsUnlock()
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_B1_PICM ºAutor  ³Renata              º Data ³  18/09/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz validacao no SX3 no cpo validacao do usuario             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Veiculos e Oficina                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_B1_PICM()

help(" ",1,"B1_PICMHLP")

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_ATUALOBJ³ Autor ³ Andre                ³ Data ³ 29/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualiza Objeto da FG_TELACOND() que esta Static            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_ATUALOBJ()

oCabecNF:oBox:SetFocus()
oCabecNf:EnchRefreshAll()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MilImpG   ³ Autor ³ Eduardo Motta		     ³ Data ³ 12.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de impressao em Modo Grafico         	  	           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³MilImpG(oPrn,cTipPar,uPar01,...,uPar10)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oPrn    - Objeto para impressao em modo grafico             ³±±
±±³          ³cTipPar - Tipo de Parametro que pode ser passado            ³±±
±±³          ³uPar99  - Parametros referentes ao cTipTex                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico													              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
cTipPar => 	"NEWPRINT"   - Cria Objeto PRN para iniciar a Impressao
uPar01 - Nome para apresentar na tela (C)

"FONT"       - Cria Fonte para ser usado na impressao, e' retornado um numero para ser usado na escolha da fonte quando se imprimir um texto
uPar01 - Nome da Fonte (C)
uPar02 - Tamanho       (N)
Retorna o Numero da Fonte a ser passado para impressao

"BITMAP"     - Imprime um BitMap
uPar01 - Linha a Imprimir   (N)
uPar02 - Coluna a Imprimir  (N)
uPar03 - Caminho do BITMAP  (C)
uPar04 - Largura            (N)
uPar05 - Altura             (N)

"LINE"       - Faz uma Linha
uPar01 - Linha Inicial      (N)
uPar02 - Coluna Inicial     (N)
uPar03 - Linha Final        (N)
uPar04 - Coluna Final       (N)
uPar05 - Objeto oPen        (O)

"SAY"        - Imprime o Texto
uPar01 - Linha a Imprimir   (N)
uPar02 - Coluna a Imprimir  (N)
uPar03 - Texto              (C)
uPar04 - Fonte a imprimir o texto (N)    ==> ESTE NUMERO E' O NUMERO RETORNADO QUANDO SE CRIA UMA FONTE
uPar05 - Tamanho do Texto (usado no caso de centralizar ou alinhar a direita) (N)
uPar06 - Cor do Texto       (N)
uPar07 - Cor do Fundo 1-transparante   2-Opaco   (N)
uPar08 - Posicao do texto, 0-Esquerda (default)   1-Direita     2-Centralizado (N)

"BOX"        - Faz um retangulo
uPar01 - Linha Inicial    (N)
uPar02 - Coluna Inicial   (N)
uPar03 - Linha Final      (N)
uPar04 - Coluna Final     (N)

"ENDPRINT"   - Finaliza o Objeto PRN e todas as fontes criadas
NAO E' NECESSARIO PASSAR NENHUM PARAMETRO

"BEGIN"      - Inicializa pagina
NAO E' NECESSARIO PASSAR NENHUM PARAMETRO

"END"        - Finaliza pagina
NAO E' NECESSARIO PASSAR NENHUM PARAMETRO
*/

Function MilImpG(cTipPar,uPar01,uPar02,uPar03,uPar04,uPar05,uPar06,uPar07,uPar08,uPar09,uPar10)

Static oPrn
Static aFontes := {}

Local uRet := NIL,oFont

cTipPar := Upper(cTipPar)
If cTipPar == "NEWPRINT"
	oPrn := AvPrintBegin( uPar01)
ElseIf cTipPar == "FONT"
	oFont := oSend(TFont(),"New",uPar01,0,uPar02,,.T.,,,,,,,,,,,oPrn )
	aadd(aFontes,oFont)
	uRet := Len(aFontes)
ElseIf cTipPar == "BITMAP"
	oPrn:Cmtr2Pix(@uPar01, @uPar02)
	If uPar04 # NIL .and. uPar05 # NIL
		oPrn:Cmtr2Pix(@uPar04, @uPar05)
	EndIf
	oSend(oPrn, "SayBitmap", uPar01, uPar02, uPar03 , uPar04, uPar05 )
ElseIf cTipPar == "LINE"
	oPrn:Cmtr2Pix(@uPar01, @uPar02)
	If uPar03 # NIL .and. uPar04 # NIL
		oPrn:Cmtr2Pix(@uPar03, @uPar04)
	EndIf
	oSend(oPrn,"Line", uPar01,uPar02,uPar03,uPar04, uPar05)
ElseIf cTipPar == "SAY"
	oPrn:Cmtr2Pix(@uPar01, @uPar02)
	oSend(oPrn, "Say",  uPar01, uPar02,uPar03, IIf(uPar04#NIL,aFontes[uPar04],NIL),uPar05,uPar06,uPar07,uPar08)
ElseIf cTipPar == "BOX"
	oPrn:Cmtr2Pix(@uPar01, @uPar02)
	oPrn:Cmtr2Pix(@uPar03, @uPar04)
	oSend(oPrn, "Box",  uPar01, uPar02,uPar03, uPar04)
ElseIf cTipPar == "BEGIN"
	AvPageBegin()
ElseIf cTipPar == "END"
	AvPageEnd()
ElseIf cTipPar == "ENDPRINT"
	AvPrintEnd()
	AvSetPortrait()
	aFontes := {}
	oPrn    := NIL
EndIf

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³RetImpGObj³ Autor ³ Eduardo Motta	        ³ Data ³ 12.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina para retornar o objeto                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³RetImpGObj()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetImpGObj()
Return oPrn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³FiltroVEG ³ Autor ³ Andre                 ³ Data ³ 12.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina para Filtrar o VEG (Problema Protheus)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³FiltroVEG()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FiltroVEG()

Local lReT

lRet := IIf(type("cGruFor")=="U",.t.,VEG->VEG_GRUFOR == cGruFor).and.IIf(type("cGruite") == "U",.t.,FG_GRUPOFOR(cGruIte,VEG->VEG_FORMUL))

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_MOSLIB   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Mostra Liberacao dos Items na Tela                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1 - Nro da Liberacao                                        ³±±
±±³          ³2 - Tipo de Operacao (1-Pecas/Oficina, 2 - Veiculos)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_MOSLIB(NumLib,cTipOpe_)
Local bCampo   := { |nCPO| Field(nCPO) }
Local lRet
Local nCntFor  := 0
Default cTipOpe_ := "1"

Private aTELA[0][0], aGETS[0], aHeader[0]

aRotina := MenuDef()

//+--------------------------------------------------------------+
//¦ Opcoes de acesso para a Modelo 3                             ¦
//+--------------------------------------------------------------+

cTitulo       :=STR0277
cAliasEnchoice:="VS6"
cAliasGetD    :="VS7"
cLinOk        :="AllwaysTrue()"
cTudoOk       :="AllwaysTrue()"

nOpc :=2
nOpcE:=2
nOpcG:=2

nOpca:=0

Inclui   := .f.
lVirtual := .F.
nLinhas  := 99
lRet     := .t.

//+--------------------------------------------------------------+
//¦ Cria variaveis M->????? da Enchoice                          ¦
//+--------------------------------------------------------------+
RegToMemory("VS6",.T.)
aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VS6")
While !Eof().and.(x3_arquivo=="VS6")
	If X3USO(x3_usado).and.cNivel >= x3_nivel
		AADD(aCpoEnchoice,x3_campo)
	EndIf
	wVar := "M->"+x3_campo
	&wVar:= CriaVar(x3_campo)
	dbSkip()
End

DbSelectArea("VS6")
DbSeek(xFilial("VS6")+NumLib)
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

If cTipOpe_ == "1"                 // Pecas e Oficina
	aColsL:={}
	dbSelectArea("VS7")
	dbSetOrder(1)
	dbSeek(xFilial()+M->VS6_NUMIDE)
	While !eof() .and. VS7->VS7_FILIAL == xFilial("VS7") .and. M->VS6_NUMIDE == VS7_NUMIDE
		If VS7_TIPAUT == "1"
			AADD(aColsL,{IIf(VS7_ITELIB=="S",.t.,.f.),VS7_SEQUEN,VS7_GRUITE,VS7_CODITE,TRANS(VS7_DESPER,"@R 999,999,999.99"),TRANS(VS7_DESDES,"@R 999,999,999.99"),TRANS(VS7_VALORI,"@R 999,999,999.99"),TRANS(VS7_VALPER,"@R 999,999,999.99"),TRANS(VS7_VALDES,"@R 999,999,999.99")})
			If VS7_ITELIB == "N"
				lRet := .f.
			EndIf
		EndIf
		dbSkip()
	End

	If Len(aColsL) == 0
		AADD(aColsL,{.F.," "," "," "," "," "," "," "," "})
	EndIf

	aColsR:={}
	dbSelectArea("VS7")
	dbSetOrder(1)
	dbSeek(xFilial()+M->VS6_NUMIDE)
	While !eof() .and. VS7->VS7_FILIAL == xFilial("VS7") .and. M->VS6_NUMIDE == VS7_NUMIDE
		If VS7_TIPAUT == "2"
			AADD(aColsR,{IIf(VS7_ITELIB=="S",.t.,.f.),VS7_SEQUEN,VS7_GRUSER,VS7_CODSER,VS7_TIPSER,TRANS(VS7_DESPER,"@R 999,999,999.99"),TRANS(VS7_DESDES,"@R 999,999,999.99"),TRANS(VS7_VALORI,"@R 999,999,999.99"),TRANS(VS7_VALPER,"@R 999,999,999.99"),TRANS(VS7_VALDES,"@R 999,999,999.99")})
			If VS7_ITELIB == "N"
				lRet := .f.
			EndIf
		EndIf
		dbSkip()
	End

	If Len(aColsR) == 0
		AADD(aColsR,{.F.," "," "," "," "," "," "," "," "," "," "})
	EndIf
Else

	aColsV:={}
	dbSelectArea("VS7")
	dbSetOrder(1)
	dbSeek(xFilial()+M->VS6_NUMIDE)
	While !eof() .and. M->VS6_NUMIDE == VS7_NUMIDE .and. xFilial("VS7") == VS7_FILIAL
		If VS7_TIPAUT == "3"
			aAdd(aColsV,{IIf(VS7_ITELIB=="S",.t.,.f.),VS7_CODITE,Transform(VS7_VALORI,"@R 999,999,999.99"),Transform(VS7_VALPER,"@R 999,999,999.99"),Transform(VS7_VALDES,"@R 999,999,999.99")})
			If VS7_ITELIB == "N"
				lRet := .f.
			EndIf
		EndIf
		dbSkip()
	EndDo

	If Len(aColsV) == 0
		aAdd(aColsV,{.F.," "," "," "," "})
	EndIf
EndIf

If !lRet

	If cTipOpe_ == "1"

		MsgInfo(STR0278,STR0160)

	EndIf

	DEFINE MSDIALOG oDlgMLib TITLE cTitulo From 06,15 to 38,105    of oMainWnd
	EnChoice("VS6",0,nOpcE,,,,aCpoEnchoice,{13,1,100,355},aCpoEnchoice,3,,,,,,lVirtual)

	If cTipOpe_ == "1"

		// Pecas

		@ 100,001 LISTBOX oLbItens FIELDS HEADER (""),;
		(STR0279),;
		(STR0280),;
		(STR0281),;
		(STR0282),;
		(STR0283),;
		(STR0284),;
		(STR0285),;
		(STR0286);
		COLSIZES 10,15,25,55,40,40,40,40,40,40 ;
		SIZE 354,070 OF oDlgMLib ON DBLCLICK((IIf(nOpc#2,IIf(aColsL[oLbItens:nAt,1],aColsL[oLbItens:nAt,1]:=.F.,aColsL[oLbItens:nAt,1]:=.T.),IIf(aColsL[oLbItens:nAt,1],oOk,oNo)),.f.)) PIXEL

		oLbItens:SetArray(aColsL)
		oLbItens:bLine := { || {  IIf(aColsL[oLbItens:nAt,1],oOk,oNo) ,;
		aColsL[oLbItens:nAt,2] ,;
		aColsL[oLbItens:nAt,3] ,;
		aColsL[oLbItens:nAt,4] ,;
		aColsL[oLbItens:nAt,5] ,;
		aColsL[oLbItens:nAt,6] ,;
		aColsL[oLbItens:nAt,7] ,;
		aColsL[oLbItens:nAt,8] ,;
		aColsL[oLbItens:nAt,9] }}

		// Servicos

		@ 171,001 LISTBOX oLbIten2 FIELDS HEADER (""),;
		(STR0279),;
		(STR0280),;
		(STR0287),;
		(STR0288),;
		(STR0282),;
		(STR0283),;
		(STR0284),;
		(STR0285),;
		(STR0286);
		COLSIZES 10,15,20,50,25,40,40,40,40,40 ;
		SIZE 354,070 OF oDlgMLib ON DBLCLICK((IIf(nOpc#2,IIf(aColsR[oLbIten2:nAt,1],aColsR[oLbIten2:nAt,1]:=.F.,aColsR[oLbIten2:nAt,1]:=.T.),IIf(aColsR[oLbIten2:nAt,1],oOk,oNo)),.f.)) PIXEL

		oLbIten2:SetArray(aColsR)
		oLbIten2:bLine := { || {  IIf(aColsR[oLbIten2:nAt,1],oOk,oNo) ,;
		aColsR[oLbIten2:nAt,2] ,;
		aColsR[oLbIten2:nAt,3] ,;
		aColsR[oLbIten2:nAt,4] ,;
		aColsR[oLbIten2:nAt,5] ,;
		aColsR[oLbIten2:nAt,6] ,;
		aColsR[oLbIten2:nAt,7] ,;
		aColsR[oLbIten2:nAt,8] ,;
		aColsR[oLbIten2:nAt,9] ,;
		aColsR[oLbIten2:nAt,10]}}
	Else

		//Veiculos

		@ 100,001 LISTBOX oLbItens FIELDS HEADER (""),;
		(STR0289),;
		(STR0284),;
		(STR0285),;
		(STR0286);
		COLSIZES 10,92,40,40,40 ;
		SIZE 354,140 OF oDlgMLib ON DBLCLICK((IIf(nOpc#2,IIf(aColsV[oLbItens:nAt,1],aColsV[oLbItens:nAt,1]:=.F.,aColsV[oLbItens:nAt,1]:=.T.),IIf(aColsV[oLbItens:nAt,1],oOk,oNo)),.f.)) PIXEL

		oLbItens:SetArray(aColsV)
		oLbItens:bLine := { || {  IIf(aColsV[oLbItens:nAt,1],oOk,oNo) ,;
		aColsV[oLbItens:nAt,2] ,;
		aColsV[oLbItens:nAt,3] ,;
		aColsV[oLbItens:nAt,4] ,;
		aColsV[oLbItens:nAt,5] }}

	EndIf

	ACTIVATE MSDIALOG oDlgMLib ON INIT EnchoiceBar(oDlgMLib,{||nOpca:=1,IIf(!obrigatorio(aGets,aTela),nOpca := 0,oDlgMLib:End()),nOpca := 0},{||oDlgMLib:End()})

EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_FILSXB   ³ Autor ³ ANDRE               ³ Data ³ 31/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Filtra o SXB                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Grupo / Codigo do Item                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_FILSXB( cTipo )
Local cRet := ""
Local cAlias := alias()
//Local cFiltraBox := ""
If cTipo+'/' $ "BM2/VVR/VV2/"
	If type("cCodMar") # "U"
		If !Empty(cCodMar)
			cRet := cCodMar+"/"
		Else
			cRet := FS_Marcas()
		EndIf
	Else
		cRet := FS_Marcas()
	EndIf
ElseIf cTipo == "VOI"
	If type("cTemInt") # "U"
		cRet :=cTemInt
	Else
		cRet :='1234'
	EndIf
Elseif cTipo == "BOX"
	//   cRet :=  IIf(FG_SEEK("VOF","VON->VON_NUMBOX",1,.F.),IIf(VOF->VOF_SITBOX == "D",.t.,.f.),.f.)
	//	  cRet :=  If (FG_SEEK("VSO","VON->VON_NUMBOX+dtos(M->VSO_DATAGE)+M->VSO_HORAGE",4,.t.),IIf(VSO->VSO_STATUS $ "1/2",.t.,.f.),.f.)
	cRet := .t.
	/*
	if FunName() == "OFIOM350" // Utilizava somente no Agendamento Antigo
	If VAI->(FieldPos("VAI_BOXAGE")) > 0
	DbSelectArea("VAI")
	DbSetOrder(4)
	DbSeek( xFilial("VAI") + __CUSERID )
	cFiltraBox := VAI->VAI_BOXAGE
	EndIf
	cRet := .t.
	If !Empty(cFiltraBox) .and. cFiltraBox <> VON->VON_NUMBOX
	cRet := .f.
	Else
	DbSelectArea("VSO")
	DbSetOrder(4)
	if DbSeek( xFilial("VSO") + VON->VON_NUMBOX + Dtos(M->VSO_DATAGE) ,.t. )
	Do While VSO->VSO_FILIAL == xFilial("VSO") .and. VON->VON_NUMBOX == VSO->VSO_NUMBOX .AND. M->VSO_DATAGE == VSO->VSO_DATAGE
	if ( M->VSO_HORAGE >=  VSO->VSO_HORAGE .AND. M->VSO_HORAGE <= Str( Val(VSO->VSO_HORAGE) +VSO->VSO_TEMPAD  , 4 ) )
	If ( VSO->VSO_STATUS $ "1/2" )
	cRet := .f.
	Exit
	EndIf
	Endif
	DbSelectArea("VSO")
	DbSkip()
	EndDo
	EndIf
	Endif
	endif
	*/
Elseif cTipo == "SBM"
	cRet := IIf(type("M->VEM_CODMAR") == "U",.T., SBM->SBM_CODMAR == M->VEM_CODMAR)
Elseif cTipo == "VA2"
	cRet := IIf(type("lFilTrans") == "U",.T.,SA2->A2_CGC == SM0->M0_CGC)
Endif
If !Empty(cAlias)
	dbSelectArea(cAlias)
EndIf
Return( cRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_CalVlSer ³ Autor ³ ANDRE               ³ Data ³ 27/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula Tempos's e valor do servico                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aRetVal =  Vetor acumulativo                               ³±±
±±³          ³ cChave  =  Chave que sera quebrado                         ³±±
±±³          ³ cStatus =  "A"  abertas                                    ³±±
±±³          ³            "F"  Fechado                                    ³±±
±±³          ³ cChaveVO4VSC = chave de acesso VO4/VSC caso nao esteja po_ ³±±
±±³          ³                sicionado                                   ³±±
±±³          ³ cChaveVOK    = chave de acesso VOK     caso nao esteja po_ ³±±
±±³          ³                sicionado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetVal == retorno da funcao                               ³±±
±±³          ³ Posicoes do vetor = [1] valor do servico                   ³±±
±±³          ³                     [2] tempo padrao                       ³±±
±±³          ³                     [3] tempo cobrado                      ³±±
±±³          ³                     [4] tempo vendido                      ³±±
±±³          ³                     [5] tempo trabalhado                   ³±±
±±³          ³                     [6] se o valor ja foi somado           ³±±
±±³          ³                     [7] chaves ja somadas                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_CalVlSer( aRetVal , cChave , cStatus , cChaveVO4VSC , cChaveVOK , dDataRef )

Local lSomaTmp := .f. , nTempTra := 0 , aArea := {}
Local lVOIVLSVAC    := (VOI->(FieldPos("VOI_VLSVAC")) <> 0)
Local dDtReq := dDataBase

Default cStatus := "A"
Default dDataRef:=dDataBase

aArea := sGetArea(aArea,"VO1")
aArea := sGetArea(aArea,"VO4")
aArea := sGetArea(aArea,"VSC")
aArea := sGetArea(aArea,"VOK")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf

If cChaveVO4VSC # NIL

	If cStatus == "A"

		VO4->( DbSeek( xFilial("VO4") + cChaveVO4VSC ) )

	Else

		VSC->( DbSeek( xFilial("VSC") + cChaveVO4VSC ) )

	EndIf

EndIf

DbSelectArea("VOK")
DbSetOrder(1)

If cChaveVOK # NIL
	DbSeek( xFilial("VOK") + cChaveVOK )
Else
	If cStatus == "A"
		DbSeek( xFilial("VOK") + VO4->VO4_TIPSER )
	Else
		DbSeek( xFilial("VOK") + VSC->VSC_TIPSER )
	EndIf
EndIf

If Len(aRetVal) == 0
	aAdd( aRetVal , 0 )
	aAdd( aRetVal , 0 )
	aAdd( aRetVal , 0 )
	aAdd( aRetVal , 0 )
	aAdd( aRetVal , 0 )
	aAdd( aRetVal , .t. )
	aAdd( aRetVal , {} )
EndIf

aRetVal[1] :=  0
aRetVal[2] :=  0
aRetVal[3] :=  0
aRetVal[4] :=  0
aRetVal[5] :=  0

If aScan( aRetVal[7] , cChave ) == 0
	aAdd( aRetVal[7] , cChave )
	lSomaTmp := .t.
EndIf

If cStatus # "F"
	VO2->(DbSetOrder(2))
	VO2->(MsSeek(xFilial("VO2")+VO4->VO4_NOSNUM))
	
	VOI->(DbSetOrder(1))
	VOI->(MsSeek(xFilial("VOI")+VO4->VO4_TIPTEM))
	
	If lVOIVLSVAC
		If VOI->VOI_VLSVAC == "1" //Valor da Requisição
			dDtReq := VO2->VO2_DATREQ
		ElseIf VOI->VOI_VLSVAC == "3" // Valor da Data de Abertura da OS
			VO1->(dbSetOrder(1))
			VO1->(MsSeek(xFilial("VO1") + VO4->VO4_NUMOSV))
			dDtReq := IIf( !Empty(VO1->VO1_DATATE), VO1->VO1_DATATE , VO1->VO1_DATABE )
		EndIf
	EndIf

	aRetVal[2] := VO4->VO4_TEMPAD
	aRetVal[3] := VO4->VO4_TEMCOB
	aRetVal[4] := VO4->VO4_TEMVEN

	aRetVal[5] := VO4->VO4_TEMTRA

	aRetVal[6] := lSomaTmp

	Do Case
		Case VOK->VOK_INCMOB == "1"                     && Mao-de-Obra

			If VOK->VOK_INCTEM == "3"                  && Tempo Trabalhado

				If !Empty(VO4->VO4_TEMTRA)
					//	              aRetVal[1] := ((VO4->VO4_TEMTRA/100) * FG_ValHor(VO4->VO4_TIPTEM,dDataRef) )
					aRetVal[1] := ((VO4->VO4_TEMTRA/100) * FG_VALHOR(VO4->VO4_TIPTEM,dDtReq,VO4->VO4_VHRDIG,VO4->VO4_VALHOR,VV1->VV1_CODMAR,VO4->VO4_CODSER,VO4->VO4_TIPSER,VO4->VO4_FATPAR,VO4->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))
				Else
					nTempTra   := FG_TEMPTRA(VO4->VO4_CODPRO,VO4->VO4_DATINI,VO4->VO4_HORINI,dDataBase, Val(Substr(Time(),1,2)+Substr(Time(),4,2)) ,"N",.f.,"O/E")

					//	              aRetVal[1] := (nTempTra * FG_ValHor(VO4->VO4_TIPTEM,dDataRef) )
					aRetVal[1] := (nTempTra * FG_VALHOR(VO4->VO4_TIPTEM,dDtReq,VO4->VO4_VHRDIG,VO4->VO4_VALHOR,VV1->VV1_CODMAR,VO4->VO4_CODSER,VO4->VO4_TIPSER,VO4->VO4_FATPAR,VO4->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))
				EndIf

			Else                                       && Tempo Fabrica/Concessionaria/Informado
				If lSomaTmp

					//		           aRetVal[1] := ((VO4->VO4_TEMPAD/100)*FG_ValHor(VO4->VO4_TIPTEM,dDataRef))
					aRetVal[1] := ((VO4->VO4_TEMPAD/100)*FG_VALHOR(VO4->VO4_TIPTEM,dDtReq,VO4->VO4_VHRDIG,VO4->VO4_VALHOR,VV1->VV1_CODMAR,VO4->VO4_CODSER,VO4->VO4_TIPSER,VO4->VO4_FATPAR,VO4->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))
					
				EndIf

			EndIf

		Case VOK->VOK_INCMOB == "2"                     && Servico de Terceiro

			aRetVal[1] := VO4->VO4_VALVEN

		Case VOK->VOK_INCMOB == "3"                     && Valor Livre com Base na Tabela

			If VOK->VOK_INCTEM == "3"                  && Tempo Trabalhado

				If !Empty(VO4->VO4_TEMTRA)

					//	               aRetVal[1] := ((VO4->VO4_TEMTRA/100) * FG_ValHor(VO4->VO4_TIPTEM,dDataRef) )
					aRetVal[1] := ((VO4->VO4_TEMTRA/100) * FG_VALHOR(VO4->VO4_TIPTEM,dDtReq,VO4->VO4_VHRDIG,VO4->VO4_VALHOR,VV1->VV1_CODMAR,VO4->VO4_CODSER,VO4->VO4_TIPSER,VO4->VO4_FATPAR,VO4->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))

				Else

					nTempTra   := FG_TEMPTRA(VO4->VO4_CODPRO,VO4->VO4_DATINI,VO4->VO4_HORINI,dDataBase, Val(Substr(Time(),1,2)+Substr(Time(),4,2)) ,"N",.f.,"O/E")

					//	               aRetVal[1] := (nTempTra * FG_ValHor(VO4->VO4_TIPTEM,dDataRef) )
					aRetVal[1] := (nTempTra * FG_VALHOR(VO4->VO4_TIPTEM,dDtReq,VO4->VO4_VHRDIG,VO4->VO4_VALHOR,VV1->VV1_CODMAR,VO4->VO4_CODSER,VO4->VO4_TIPSER,VO4->VO4_FATPAR,VO4->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))
					
				EndIf

			Else                                       && Tempo Fabrica/Concessionaria/Informado

				If lSomaTmp

					//		           aRetVal[1] := ((VO4->VO4_TEMPAD/100)*FG_ValHor(VO4->VO4_TIPTEM,dDataRef))
					aRetVal[1] := ((VO4->VO4_TEMPAD/100)*FG_VALHOR(VO4->VO4_TIPTEM,dDtReq,VO4->VO4_VHRDIG,VO4->VO4_VALHOR,VV1->VV1_CODMAR,VO4->VO4_CODSER,VO4->VO4_TIPSER,VO4->VO4_FATPAR,VO4->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))
					
				EndIf

			EndIf

		Case VOK->VOK_INCMOB == "4"                     && Valor Livre com Base na Tabela

			If VOK->VOK_INCTEM == "3"                  && Tempo Trabalhado

				If !Empty(VO4->VO4_TEMTRA)

					//	              aRetVal[1] := ((VO4->VO4_TEMTRA/100) * FG_ValHor(VO4->VO4_TIPTEM,dDataRef) )
					aRetVal[1] := ((VO4->VO4_TEMTRA/100) * FG_VALHOR(VO4->VO4_TIPTEM,dDtReq,VO4->VO4_VHRDIG,VO4->VO4_VALHOR,VV1->VV1_CODMAR,VO4->VO4_CODSER,VO4->VO4_TIPSER,VO4->VO4_FATPAR,VO4->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))
					
				Else
					nTempTra   := FG_TEMPTRA(VO4->VO4_CODPRO,VO4->VO4_DATINI,VO4->VO4_HORINI,dDataBase, Val(Substr(Time(),1,2)+Substr(Time(),4,2)) ,"N",.f.,"O/E")

					//                 aRetVal[1] := (nTempTra * FG_ValHor(VO4->VO4_TIPTEM,dDataRef) )
					aRetVal[1] := (nTempTra * FG_VALHOR(VO4->VO4_TIPTEM,dDtReq,VO4->VO4_VHRDIG,VO4->VO4_VALHOR,VV1->VV1_CODMAR,VO4->VO4_CODSER,VO4->VO4_TIPSER,VO4->VO4_FATPAR,VO4->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))
				EndIf

			Else                                       && Tempo Fabrica/Concessionaria/Informado

				If lSomaTmp

					//		          aRetVal[1] := ((VO4->VO4_TEMPAD/100)*FG_ValHor(VO4->VO4_TIPTEM,dDataRef))
					aRetVal[1] := ((VO4->VO4_TEMPAD/100)*FG_VALHOR(VO4->VO4_TIPTEM,dDtReq,VO4->VO4_VHRDIG,VO4->VO4_VALHOR,VV1->VV1_CODMAR,VO4->VO4_CODSER,VO4->VO4_TIPSER,VO4->VO4_FATPAR,VO4->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))
					
				EndIf

			EndIf

		Case VOK->VOK_INCMOB == "5"                     && Socorro

			aRetVal[1] := (VO4->VO4_KILROD*VOK->VOK_PREKIL)

		Case VOK->VOK_INCMOB == "6"                     && Franquia

			aRetVal[1] := VO4->VO4_VALVEN


	EndCase

Else

	aRetVal[2] := VSC->VSC_TEMPAD
	aRetVal[3] := VSC->VSC_TEMCOB
	aRetVal[4] := VSC->VSC_TEMVEN

	aRetVal[5] := VSC->VSC_TEMTRA

	aRetVal[6] := lSomaTmp

	&& Valor do Servico
	aRetVal[1] := VSC->VSC_VALSER

EndIf

&& Volta posicoes originais
sRestArea(aArea)

Return( aRetVal )

Function FS_VLSERTP(dDtIni,nHrIni,dDtFin,nHrFin)

Local nTp := 0 , nMinutIni:=0 , nMinutFin := 0

If !Empty(dDtIni) .And. !Empty(dDtFin)

	nMinutIni := (Val(Substr(StrZero(nHrIni,4),1,2))*60) + Val(Substr(StrZero(nHrIni,4),3,2))  && Transforma hora em minuto
	nMinutFin := (Val(Substr(StrZero(nHrFin,4),1,2))*60) + Val(Substr(StrZero(nHrFin,4),3,2))  && Transforma hora em minuto

	nTp := ( ( ( dDtFin - dDtIni ) * 24 ) * 60 )   && Acha a quantidade de dias e transforma em minutos
	nTp := Int( ((( (nTp+nMinutFin) - nMinutIni ) / 60 ) * 100 ) )        && Acha a quantidade de minutos entre a hora final e inicial e depois transforma em hora centezimais

	If nTp < 0
		nTp := 0
	EndIf

EndIf

Return(nTp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_TEMPTRAºAutor  ³Fabio               º Data ³  02/18/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Marca o Tempo Trabalhado                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cCodPro = Codigo do produtivo                               º±±
±±º          ³dDataIni = Data Inicial                                     º±±
±±º          ³nHoraIni = Hora Inicial                                     º±±
±±º          ³dDataFin = Data Final                                       º±±
±±º          ³nHoraFin = Hora Final                                       º±±
±±º          ³lRef     = Refaz Periodo                                    º±±
±±º          ³cSitMecR = Levanta situacao do mecanico                     º±±
±±º          ³           "A" Retorna array com o periodo                  º±±
±±º          ³           "N" Retorna valor com o tempo trabalhado         º±±
±±º          ³lMarcaAus = Marca Periodo com ausencia                      º±±
±±º          ³lMensagem = .t. mostra mensagem                             º±±
±±º          ³lVerificVO4 = levanta prosicao de acordo com o VO4          º±±
±±º          ³cTipLevant  = Tipo de Levantamento "D/F/A/O/E"              º±±
±±º          ³              "D" - Disponivel                              º±±
±±º          ³              "F" - Fora do turno                           º±±
±±º          ³              "A" - Ausente                                 º±±
±±º          ³              "O" - Ocupado                                 º±±
±±º          ³              "E" - Hora Extra                              º±±
±±º          ³cSrvIdent = Identifica o registro que sera validado         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_TEMPTRA(cCodPro,dDataIni,nHoraIni,dDataFin,nHoraFin,cSitMecR,lMensagem,cTipLevant,cSrvIdent,aVetCols,aVetHeader)

Local aArea := {}

Local lReturn := .t. , aSitMec := {} , nHoraTrab := 0, nSitMec1 := 0, nTpTrb := 0
Local nSitMec := 0

Default cSitMecR   := " "
Default cTipLevant := "D/F/O/E/A"
Default cSrvIdent  := ""
Default aVetCols   := {}
Default aVetHeader := {}

//Conout("FG_TEMPTRA - " + Time() + " - " + ProcName(1) + " - " + cValToChar(ProcLine(1) ))

aArea := sGetArea(aArea,"VOE")
aArea := sGetArea(aArea,"VOH")
aArea := sGetArea(aArea,"VO1")
aArea := sGetArea(aArea,"VO2")
aArea := sGetArea(aArea,"VO4")
aArea := sGetArea(aArea,"VO6")
aArea := sGetArea(aArea,"VAI")
aArea := sGetArea(aArea,"VV1")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf

lMensagem  := IIf( lMensagem  # NIL , lMensagem  , .t. )

if Empty(dDataIni)
	Return( IIf(!Empty(cSitMecR), IIf( cSitMecR == "A" , {{Ctod("  /  /  "),0,Ctod("  /  /  "),0," ",0,"","",""}} , 0 ) , .f. ) )
Endif

If Empty(dDataFin) .Or. ( Dtos(dDataIni)+StrZero(nHoraIni,4) > Dtos(dDataFin)+StrZero(nHoraFin,4) )
	dDataFin := dDataIni
	nHoraFin := nHoraIni
EndIf

If Dtos(dDataIni)+StrZero(nHoraIni,4) > Dtos(dDataFin)+StrZero(nHoraFin,4)

	If lMensagem
		Help("  ",1,"DTINIFINAL")
	EndIf

	&& Volta posicao
	sRestArea(aArea)

	Return( IIf(!Empty(cSitMecR), IIf( cSitMecR == "A" , {{Ctod("  /  /  "),0,Ctod("  /  /  "),0," ",0,"","",""}} , 0 ) , .f. ) )

EndIf

// Monta vetor com o tempo trabalhado
aSitMec := FS_VETPER( cCodPro , @dDataIni , @nHoraIni , @dDataFin , @nHoraFin , cSitMecR , lMensagem , cTipLevant , cSrvIdent , aVetCols , aVetHeader )

If !Empty( cSitMecR )

	If Len(aSitMec) == 0
		Aadd(aSitMec,{Ctod("  /  /  "), 0, Ctod("  /  /  "), 0, "", 0,"","","",0,0,0})
	EndIf

	&& Volta posicao
	sRestArea(aArea)

	If cSitMecR == "N"

		nHoraTrab := 0

		For nSitMec := 1 to Len( aSitMec )

			nHoraTrab += aSitMec[nSitMec,6]

		Next

		Return( nHoraTrab )

	EndIf

	Return(aSitMec)

EndIf

lReturn := .f.

If Len(aSitMec) # 0

	aMostraSitMec := {}
	cStatus := ""

	For nSitMec := 1 to Len(aSitMec)

		// If aSitMec[nSitMec,5] $ "O/E/A" .And. IIf(cStatus$"O/E/A",.t.,Dtos(aSitMec[nSitMec,1])+Str(aSitMec[nSitMec,2]) # Dtos(dDataIni)+Str(nHoraIni) ) && ni # 1 para nao comparar data inicial
		If aSitMec[nSitMec,5] $ "O/E/A"

			aAdd(aMostraSitMec,{aSitMec[nSitMec,7],aSitMec[nSitMec,8],aSitMec[nSitMec,9],aSitMec[nSitMec,1],aSitMec[nSitMec,2],aSitMec[nSitMec,3], aSitMec[nSitMec,4] ,aSitMec[nSitMec,5],aSitMec[nSitMec,12],aSitMec[nSitMec,10],aSitMec[nSitMec,11]})

			cStatus := aSitMec[ nSitMec , 5 ]

		EndIf

	Next

	If Empty( cStatus )

		cStatus := aSitMec[ Len(aSitMec) , 5 ]

	EndIf

	If cStatus  == "F"

		If lMensagem
			Help(" ",1,"FORATUR")
			//	      Return(.f.)
		EndIf

		lReturn:=.t.

	Elseif cStatus  == "O" .Or. cStatus  == "E" .Or. cStatus  == "A"

		If lMensagem

			VO1->(DbSetOrder(1))
			VO1->(DbSeek( xFilial("VO1") + aMostraSitMec[1,1] ))
			SA1->(DbSetOrder(1))
			SA1->(DbSeek( xFilial("SA1") + VO1->VO1_PROVEI + VO1->VO1_LOJPRO ))

			cObserv := STR0138+" "+Alltrim(Posicione("VAI",1,xFilial("VAI")+cCodPro,"VAI_NOMTEC"))+" "+IIf(cStatus=="A",STR0139,STR0140) + Chr(13) + Chr(10)
			cObserv += STR0344 + VO1->VO1_NUMBOX + Chr(13) + Chr(10)
			cObserv += STR0345 + VO1->VO1_PROVEI +" "+ VO1->VO1_LOJPRO + " " + SA1->A1_NOME + Chr(13) + Chr(10)

			DEFINE MSDIALOG oDlgSitMec FROM 001,000 TO 014,070 TITLE STR0141 OF oMainWnd // Mecanico em Atividade

			@ 001,002 GET oObserv VAR cObserv OF oDlgSitMec MEMO SIZE 275,030 PIXEL READONLY MEMO

			@ 031,002 LISTBOX oLbSitMec FIELDS HEADER   (STR0142),; // "Cod item"
				(STR0143),;
				(STR0145),;
				(STR0146),;
				(STR0147),;
				(STR0148),;
				(STR0149),;
				(STR0150),;
				(STR0382),;
				(STR0383),;
				(STR0384);
				COLSIZES 30,40,50,30,30,30,30,20,40,40,40;
				SIZE 275,50 OF oDlgSitMec PIXEL

			oLbSitMec:SetArray(aMostraSitMec)
			oLbSitMec:bLine := { || { aMostraSitMec[oLbSitMec:nAt,1] ,;
				aMostraSitMec[oLbSitMec:nAt,2] ,;
				aMostraSitMec[oLbSitMec:nAt,3] ,;
				Dtoc(aMostraSitMec[oLbSitMec:nAt,4]) ,;
				Transform(aMostraSitMec[oLbSitMec:nAt,5],"@R 99:99") ,;
				Dtoc(aMostraSitMec[oLbSitMec:nAt,6]) ,;
				Transform(aMostraSitMec[oLbSitMec:nAt,7],"@R 99:99") ,;
				aMostraSitMec[oLbSitMec:nAt,8] ,;
				Transform(aMostraSitMec[oLbSitMec:nAt,10],"@R 999:99") ,;
				Transform(aMostraSitMec[oLbSitMec:nAt,09],"@R 999:99") ,;
				Transform( IIf( aMostraSitMec[oLbSitMec:nAt,11] > aMostraSitMec[oLbSitMec:nAt,10], (aMostraSitMec[oLbSitMec:nAt,11] - aMostraSitMec[oLbSitMec:nAt,10]) ,0) ,"@R 999:99") }}

			DEFINE SBUTTON FROM 085,233 TYPE 2 ACTION (oDlgSitMec:End()) ENABLE OF oDlgSitMec

			ACTIVATE MSDIALOG oDlgSitMec CENTER

		EndIf

		lReturn:=.f.

	Else

		lReturn:=.t.

	EndIf

EndIf

&& Volta posicao
sRestArea(aArea)

Return(lReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VETPER ºAutor  ³Fabio               º Data ³  01/30/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna vetor com o periodo                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VETPER( cCodPro , dDataIni , nHoraIni , dDataFin , nHoraFin , cSitMecR , lMensagem , cStatus , cSrvIdent , aVet_Cols , aVet_Header )

Local nPosReg1 := 0 , nPosReg2 := 0 , nDias := 0 , aIntervalo := {} , nIni := 0 , nFin := 0 , aVetor := {} , aStatus := {} , nTempoFin := 0 , nTempoIni := 0
Local bVarComp  := {|x| Substr("VOH->VOH_INIPER/VOH->VOH_INICF1/VOH->VOH_FINCF1/VOH->VOH_INIREF/VOH->VOH_FINREF/VOH->VOH_INICF2/VOH->VOH_FINCF2/VOH->VOH_FINPER" , x , 15 ) }
Local nVar		 := 0
Local nSitMec   := 0
Local nSitMec1  := 0
Local cCpoPerProc := ""
Local cMVMIL0111 := AllTrim(GetNewPar("MV_MIL0111","000"))

Local lApoI_1    := SubStr(cMVMIL0111,1,1) == "1"
Local lApoI_Almo := SubStr(cMVMIL0111,2,1) == "1"
Local lApoI_2    := SubStr(cMVMIL0111,3,1) == "1"

Private cQryVO4 := "SQLSB1"
Private  aVetCols := {} , aVetHeader := {} , aEscala := {}

Aadd(aStatus, "F")
Aadd(aStatus, "F")

aVetCols   := aClone( aVet_Cols )
aVetHeader := aClone( aVet_Header )
nTotDias   := ( dDataFin - dDataIni )
// Periodo
For nDias := 0 to nTotDias

	//
	DbSelectArea("VOE")
	DbSetOrder(1)
	If !DbSeek(xFilial("VOE")+cCodPro+Dtos(dDataIni+nDias),.t.)

		If eof() .or. xFilial("VOE") != VOE->VOE_FILIAL
			dbskip(-1)
		Endif

		While xFilial("VOE") == VOE->VOE_FILIAL .and. !bof()
			If ( VOE->VOE_CODPRO # cCodPro .or. ( VOE->VOE_CODPRO == cCodPro  .and. VOE->VOE_DATESC > (dDataIni+nDias) ) )
				DbSkip(-1)
				loop
			EndIf
			Exit
		EndDo

	EndIf

	If VOE->VOE_CODPRO # cCodPro

		If lMensagem
			Help(" ",1,"PROESCALA")
		EndIf

		Return( {} )

	EndIf

	DbSelectArea("VOH")
	DbSetOrder(1)
	If !DbSeek(xFilial("VOH")+VOE->VOE_CODPER)

		If lMensagem
			Help(" ",1,"HORATRAB")
		EndIf

		Return( {} )

	EndIf

	aEscala := {}

	For nVar := 1 to 120 Step 16

		cCpoPerProc := Eval( bVarComp , nVar )

		If Dtos( dDataIni+nDias ) + StrZero( &( cCpoPerProc ) , 4 ) > Dtos( dDataIni ) + StrZero( nHoraIni , 4 ) ;
			.And. Dtos( dDataIni+nDias ) + StrZero( &( cCpoPerProc ) , 4 ) < Dtos( dDataFin ) + StrZero( nHoraFin , 4 ) ;
			.And. ( "PER" $ cCpoPerProc ;
			        .Or. ( !Empty( &( cCpoPerProc ) ) .And. !Empty( &( Eval( bVarComp , nVar+IIf( "INI" $ cCpoPerProc , 16 , -16 ) ) ) ) ) )

			nAscan := Ascan( aIntervalo , { |x| Dtos(x[1])+StrZero(x[2],4) == Dtos(dDataIni+nDias)+StrZero( &( cCpoPerProc ) ,4) } )
			lPer   := "PER" $ cCpoPerProc     // Campo de Inicio do Periodo ou Fim do Periodo VOH_INIPER ou VOH_FINPER
			lEmpty1:= Empty( &( Eval( bVarComp , 1 )) )   // Inicio do Periodo - VOH->VOH_INIPER
			lEmpty2:= Empty( &( Eval( bVarComp , 113 )) ) // Fim do Periodo    - VOH->VOH_FINPER


			If ( Len( aIntervalo ) == 0 .Or. nAscan == 0 .Or. ( lPer .And. lEmpty1 .And. lEmpty2 ) )

				Aadd( aIntervalo , { ;
					dDataIni+nDias ,;
					&( cCpoPerProc ) ,;
					"D",;
					"",;
					"",;
					"" ,;
					IIf( ( "INI" $ cCpoPerProc .And. !("PER" $ cCpoPerProc) ) .Or. ( "FINPER" $ cCpoPerProc )  , "B" , "A" ) ,;
					0 ,;
					Space(8);
				} )

				// Sistema configurado para gerar apontamentos nos intervalos 
				If ( cCpoPerProc == "VOH->VOH_INICF1" .and. lApoI_1 ) .or. ;
					( cCpoPerProc == "VOH->VOH_INIREF" .and. lApoI_Almo ) .or. ;
					( cCpoPerProc == "VOH->VOH_INICF2" .and. lApoI_2 )

					Aadd( aIntervalo , { ;
						dDataIni+nDias ,;
						&( cCpoPerProc ) ,;
						"F",;
						"",;
						"",;
						"" ,;
						"I" ,;
						0 ,;
						Space(8);
					} )
				EndIf

			EndIf

		EndIf

		If !Empty( &( cCpoPerProc ) )
			If Len(aEscala) == 0 .Or. !Empty(aEscala[Len(aEscala),2])
				Aadd(aEscala, { &( cCpoPerProc ) , 0 , "" } )
			Else
				If aEscala[Len(aEscala),1] > &( cCpoPerProc )
					aEscala[Len(aEscala),2] := 2359
					Aadd(aEscala, { 0 , 0 , "" } )
				EndIf
				aEscala[Len(aEscala),2] := &( cCpoPerProc )
			EndIf

			// Sistema configurado para gerar apontamentos nos intervalos 
			If ( cCpoPerProc == "VOH->VOH_INICF1" .and. lApoI_1 ) .or. ;
				( cCpoPerProc == "VOH->VOH_INIREF" .and. lApoI_Almo ) .or. ;
				( cCpoPerProc == "VOH->VOH_INICF2" .and. lApoI_2 )

				Aadd(aEscala, { ;
					SomaHoras( &( cCpoPerProc )                  , 1 ) ,;
					SubHoras(  &( Eval( bVarComp , nVar + 16 ) ) , 1 ) ,;
					"E" } )
			EndIf
		EndIf

	Next

	For nVar := 1 to Len(aEscala)
		If nDias == 0 .And. ( nHoraIni > aEscala[nVar,1] .And. nHoraIni < aEscala[nVar,2] )
			aStatus[1] := IIf( aEscala[nVar,3] == "E" , "F" , "D" )
		EndIf

		If nDias == ( dDataFin - dDataIni ) .And. ( nHoraFin > aEscala[nVar,1] .And. nHoraFin < aEscala[nVar,2] )
			aStatus[2] := IIf( aEscala[nVar,3] == "E" , "F" , "D" )
		EndIf

		If nDias == 0 .And. nHoraIni == aEscala[nVar,1]

			aStatus[1] := IIf( aEscala[nVar,3] == "E" , "F" , "D" )

			If Dtos(dDataIni)+StrZero(nHoraIni,4) == Dtos(dDataFin)+StrZero(nHoraFin,4)
				aStatus[2] := IIf( aEscala[nVar,3] == "E" , "F" , "D" )
			EndIf

		EndIf

		If nDias == ( dDataFin - dDataIni ) .And. nHoraFin == aEscala[nVar,2]
			aStatus[2] := IIf( aEscala[nVar,3] == "E" , "F" , "D" )
		EndIf
	Next

Next

// Configura variaveis que serao utilizadas nas validações abaixo ...
cIni_DatHora := Dtos(dDataIni) + StrZero( nHoraIni , 4 )
cFin_DatHora := Dtos(dDataFin) + StrZero( nHoraFin , 4 )
//


// Tempo Trabalhado
cQuery := "SELECT VO4.VO4_CODSER,VO4.VO4_NOSNUM,VO4.VO4_DATINI,VO4.VO4_DATFIN,VO4.VO4_HOREXT,VO4.VO4_TEMPAD,VO4.VO4_SEQUEN,VO4.VO4_HORINI,VO4.VO4_HORFIN,VO2.VO2_NUMOSV,VV1.VV1_CODMAR "
cQuery +=  " FROM "+RetSQLName("VO4")+" VO4 "
cQuery +=        " LEFT JOIN "+RetSQLName("VO2")+" VO2 ON ( VO2.VO2_FILIAL='"+xFilial("VO2")+"' AND VO2.VO2_NOSNUM=VO4.VO4_NOSNUM ) "
cQuery +=        " LEFT JOIN "+RetSQLName("VO1")+" VO1 ON ( VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND VO1.VO1_NUMOSV=VO2.VO2_NUMOSV ) "
cQuery +=        " LEFT JOIN "+RetSQLName("VV1")+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VO1.VO1_CHAINT ) "
cQuery += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
cQuery +=   " AND VO4.VO4_CODPRO = '" + cCodPro + "'"
cQuery +=   " AND VO4.VO4_DATINI >= '" + dtos(dDataIni) + "'"
cQuery +=   " AND VO4.VO4_DATFIN <= '" + dtos(dDataFin) + "'"
cQuery +=   " AND VO4.D_E_L_E_T_=' '"
cQuery +=   " AND (VO2.D_E_L_E_T_=' ' OR VO2.D_E_L_E_T_ IS NULL)"
cQuery +=   " AND (VO1.D_E_L_E_T_=' ' OR VO1.D_E_L_E_T_ IS NULL)"
cQuery +=   " AND (VV1.D_E_L_E_T_=' ' OR VV1.D_E_L_E_T_ IS NULL)"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryVO4, .F., .T. )
//
while !(cQryVO4)->(eof())

	DbSelectArea("VO6")
	DbSetOrder(2)
	DbSeek( xFilial("VO6") + FG_MARSRV( (cQryVO4)->VV1_CODMAR, (cQryVO4)->VO4_CODSER ) + (cQryVO4)->VO4_CODSER )

	If Empty( cSrvIdent ) .Or. (cQryVO4)->VO4_NOSNUM+(cQryVO4)->VO4_SEQUEN # cSrvIdent

		cVO4_Ini_DatHora := (cQryVO4)->VO4_DATINI+StrZero( (cQryVO4)->VO4_HORINI , 4 )
		cVO4_Fin_DatHora := (cQryVO4)->VO4_DATFIN+StrZero( (cQryVO4)->VO4_HORFIN , 4 )

		If !Empty((cQryVO4)->VO4_DATINI) .And. (;
			     cVO4_Ini_DatHora > cIni_DatHora .And. cVO4_Ini_DatHora < cFin_DatHora ;
			.Or. cVO4_Fin_DatHora > cIni_DatHora .And. cVO4_Fin_DatHora < cFin_DatHora ;
			.Or. cVO4_Ini_DatHora < cIni_DatHora .And. cVO4_Fin_DatHora > cIni_DatHora ;
			.Or. cVO4_Ini_DatHora < cFin_DatHora .And. cVO4_Fin_DatHora > cFin_DatHora ;
			.Or. cVO4_Ini_DatHora == cIni_DatHora .And. cVO4_Fin_DatHora == cFin_DatHora )

			nPosReg1 := 0
			If Len(aIntervalo) # 0
				If ( nPosReg1 := Ascan( aIntervalo , { |x| Dtos(x[1])+StrZero(x[2],4)+x[9] == cVO4_Ini_DatHora + Space(8) } ) ) == 0
					nPosReg1 := Ascan( aIntervalo , { |x| Dtos(x[1])+StrZero(x[2],4)+x[9] == cVO4_Ini_DatHora + (cQryVO4)->VO4_SEQUEN } )
				EndIf
			EndIf

			If nPosReg1 == 0

				Aadd( aIntervalo , { ;
					stod((cQryVO4)->VO4_DATINI) , ;
					(cQryVO4)->VO4_HORINI , ;
					(cQryVO4)->VO4_HOREXT , ;
					(cQryVO4)->VO2_NUMOSV,;
					(cQryVO4)->VO4_CODSER,;
					VO6->VO6_DESSER ,;
					"A" ,;
					(cQryVO4)->VO4_TEMPAD , ;
					(cQryVO4)->VO4_SEQUEN ;
				} )

				nPosReg1 := Len(aIntervalo)
			Else

				aIntervalo[nPosReg1 , 3 ] := (cQryVO4)->VO4_HOREXT
				aIntervalo[nPosReg1 , 4 ] := (cQryVO4)->VO2_NUMOSV
				aIntervalo[nPosReg1 , 5 ] := VO6->VO6_CODSER
				aIntervalo[nPosReg1 , 6 ] := VO6->VO6_DESSER
				aIntervalo[nPosReg1 , 8 ] := (cQryVO4)->VO4_TEMPAD
				aIntervalo[nPosReg1 , 9 ] := (cQryVO4)->VO4_SEQUEN

			EndIf

			nPosReg2 := 0
			If Len(aIntervalo) # 0
				If ( nPosReg2 := Ascan( aIntervalo , { |x| Dtos(x[1])+StrZero(x[2],4)+x[9] == cVO4_Fin_DatHora + Space(8) } ) ) == 0
					nPosReg2 := Ascan( aIntervalo , { |x| dtos(x[1])+StrZero(x[2],4) == cVO4_Fin_DatHora + (cQryVO4)->VO4_SEQUEN } )
				EndIf
			EndIf

			If nPosReg2 == 0

				Aadd( aIntervalo , { ;
					stod((cQryVO4)->VO4_DATFIN) , ;
					(cQryVO4)->VO4_HORFIN , ;
					IIf( (cQryVO4)->VO4_HOREXT == "O" , "D" , "F" ) , ;
					(cQryVO4)->VO2_NUMOSV,;
					(cQryVO4)->VO4_CODSER,;
					VO6->VO6_DESSER , ;
					"A", ;
					(cQryVO4)->VO4_TEMPAD , ;
					(cQryVO4)->VO4_SEQUEN ;
				} )

				nPosReg2 := Len(aIntervalo)

				If (cQryVO4)->VO4_HOREXT == "F"
					aIntervalo[Len(aIntervalo),7] := "B"
				EndIf

				If Empty( aIntervalo[Len(aIntervalo) , 1] )
					aIntervalo[Len(aIntervalo)]   := aClone( aIntervalo[nPosReg1] )
					aIntervalo[Len(aIntervalo),7] := "C"
				EndIf

			Else

				aIntervalo[nPosReg2 , 3 ] := (cQryVO4)->VO4_HOREXT
				aIntervalo[nPosReg2 , 4 ] := (cQryVO4)->VO2_NUMOSV
				aIntervalo[nPosReg2 , 5 ] := VO6->VO6_CODSER
				aIntervalo[nPosReg2 , 6 ] := VO6->VO6_DESSER
				aIntervalo[nPosReg2 , 8 ] := (cQryVO4)->VO4_TEMPAD
				aIntervalo[nPosReg2 , 9 ] := (cQryVO4)->VO4_SEQUEN

			EndIf

		EndIf

	EndIf

	DbSelectArea(cQryVO4)
	(cQryVO4)->(DbSkip())

EndDo

( cQryVO4 )->( DbCloseArea() )
dbSelectArea("VO4")

If len(aVetCols) > 0
	n_COD_SER_VO4 := FG_POSVAR("VO4_CODSER","aVetHeader")
	n_DAT_INI_VO4 := FG_POSVAR("VO4_DATINI","aVetHeader")
	n_DAT_FIN_VO4 := FG_POSVAR("VO4_DATFIN","aVetHeader")
	n_HOR_INI_VO4 := FG_POSVAR("VO4_HORINI","aVetHeader")
	n_HOR_FIN_VO4 := FG_POSVAR("VO4_HORFIN","aVetHeader")
	n_SEQUEN_VO4  := FG_POSVAR("VO4_SEQUEN","aVetHeader")
	n_HOREXT_VO4  := FG_POSVAR("VO4_HOREXT","aVetHeader")
EndIf
// Valida Vetor
For nIni := 1 to len(aVetCols)

	If aVetCols[nIni,FG_POSVAR("VO4_CODPRO","aVetHeader")] == cCodPro


		DbSelectArea("VO2")
		DbSetOrder(2)
		MsSeek( xFilial("VO2") + Substr( cSrvIdent , 1 , Len(VO4->VO4_NOSNUM) ) )

		DbSelectArea("VO1")
		DbSetOrder(1)
		MsSeek( xFilial("VO1") + VO2->VO2_NUMOSV )

		DbSelectArea("VV1")
		DbSetOrder(1)
		MsSeek( xFilial("VV1") + VO1->VO1_CHAINT )

		If VO6->VO6_CODSER <> aVetCols[nIni, n_COD_SER_VO4 ]
			DbSelectArea("VO6")
			DbSetOrder(2)
			DbSeek( xFilial("VO6") + FG_MARSRV( VV1->VV1_CODMAR, aVetCols[nIni, n_COD_SER_VO4 ] ) + aVetCols[nIni, n_COD_SER_VO4 ] )
		EndIf

		If Empty( cSrvIdent ) .Or. aVetCols[nIni, n_SEQUEN_VO4 ] # Substr( cSrvIdent , Len(VO4->VO4_NOSNUM)+1 )

			cACols_Ini_DatHora := Dtos( aVetCols[nIni, n_DAT_INI_VO4 ] ) + StrZero( aVetCols[ nIni , n_HOR_INI_VO4 ] , 4 )
			cACols_Fin_DatHora := Dtos( aVetCols[nIni, n_DAT_FIN_VO4 ] ) + StrZero( aVetCols[ nIni , n_HOR_FIN_VO4 ] , 4 )

			If !aVetCols[ nIni , Len(aVetCols[nIni]) ] .And. ( ;
				     ( !Empty( aVetCols[nIni, n_DAT_INI_VO4 ] ) .And. cACols_Ini_DatHora > cIni_DatHora .And. cACols_Ini_DatHora < cFin_DatHora ) ;
				.Or. ( !Empty( aVetCols[nIni, n_DAT_FIN_VO4 ] ) .And. cACols_Fin_DatHora > cIni_DatHora .And. cACols_Fin_DatHora < cFin_DatHora ) ;
				.Or. ( !Empty( aVetCols[nIni, n_DAT_INI_VO4 ] ) .And. cACols_Ini_DatHora < cIni_DatHora .And. cACols_Fin_DatHora > cIni_DatHora ) ;
				.Or. ( !Empty( aVetCols[nIni, n_DAT_FIN_VO4 ] ) .And. cACols_Ini_DatHora < cFin_DatHora .And. cACols_Fin_DatHora > cFin_DatHora ) ;
				.Or. ( !Empty( aVetCols[nIni, n_DAT_INI_VO4 ] ) .And. cACols_Ini_DatHora == cIni_DatHora .And. cACols_Fin_DatHora == cFin_DatHora );
				 )

				nPosReg1 := 0
				If Len(aIntervalo) # 0
					If ( nPosReg1 := Ascan( aIntervalo , { |x| Dtos(x[1])+StrZero(x[2],4)+x[9] == cACols_Ini_DatHora + Space(8) } ) ) == 0
						nPosReg1 := Ascan( aIntervalo , { |x| Dtos(x[1])+StrZero(x[2],4)+x[9] == cACols_Ini_DatHora + aVetCols[nIni, n_SEQUEN_VO4 ] } )
					EndIf
				EndIf
				If nPosReg1 == 0

					Aadd( aIntervalo , {;
						aVetCols[nIni, n_DAT_INI_VO4 ] , ;
						aVetCols[nIni, n_HOR_INI_VO4 ] , ;
						aVetCols[nIni, n_HOREXT_VO4 ] , ;
						VO2->VO2_NUMOSV , ;
						VO6->VO6_CODSER , ;
						VO6->VO6_DESSER , ;
						"A" , ;
						0 , ;
						aVetCols[nIni, n_SEQUEN_VO4 ] ;
					} )

					nPosReg1 := Len(aIntervalo)

				Else

					aIntervalo[nPosReg1 , 3 ] := aVetCols[nIni, n_HOREXT_VO4 ]
					aIntervalo[nPosReg1 , 4 ] := VO2->VO2_NUMOSV
					aIntervalo[nPosReg1 , 5 ] := VO6->VO6_CODSER
					aIntervalo[nPosReg1 , 6 ] := VO6->VO6_DESSER
					aIntervalo[nPosReg1 , 9 ] := aVetCols[nIni, n_SEQUEN_VO4 ]

				EndIf

				nPosReg2 := 0
				If Len(aIntervalo) # 0

					If ( nPosReg2 := Ascan( aIntervalo , { |x| Dtos(x[1])+StrZero(x[2],4)+x[9] == Dtos(aVetCols[nIni, n_DAT_FIN_VO4 ])+StrZero( aVetCols[nIni, n_HOR_FIN_VO4 ] ,4)+Space(8) } ) ) == 0

						nPosReg2 := Ascan( aIntervalo , { |x| Dtos(x[1])+StrZero(x[2],4)+x[9] == Dtos(aVetCols[nIni, n_DAT_FIN_VO4 ])+StrZero( aVetCols[nIni, n_HOR_FIN_VO4 ] ,4)+aVetCols[nIni, n_SEQUEN_VO4 ] } )

					EndIf

				EndIf

				If nPosReg2 == 0

					Aadd( aIntervalo , { ;
						aVetCols[nIni, n_DAT_FIN_VO4 ] , ;
						aVetCols[nIni, n_HOR_FIN_VO4 ] , ;
						IIf( aVetCols[nIni, n_HOREXT_VO4 ] == "O" , "D" , "F" ) , ;
						VO2->VO2_NUMOSV , ;
						VO6->VO6_CODSER , ;
						VO6->VO6_DESSER , ;
						"A" , ;
						0 , ;
						aVetCols[nIni, n_SEQUEN_VO4 ];
					} )
					nPosReg2 := Len(aIntervalo)

					If aVetCols[nIni, n_HOREXT_VO4 ] == "F"

						aIntervalo[Len(aIntervalo),7] := "B"

					EndIf

					If Empty( aIntervalo[Len(aIntervalo) , 1] )

						aIntervalo[Len(aIntervalo)]   := aClone( aIntervalo[nPosReg1] )
						aIntervalo[Len(aIntervalo),7] := "C"

					EndIf

				Else

					aIntervalo[nPosReg2 , 3 ] := aVetCols[nIni, n_HOREXT_VO4 ]

					aIntervalo[nPosReg2 , 4 ] := VO2->VO2_NUMOSV
					aIntervalo[nPosReg2 , 5 ] := VO6->VO6_CODSER
					aIntervalo[nPosReg2 , 6 ] := VO6->VO6_DESSER
					aIntervalo[nPosReg2 , 9 ] := aVetCols[nIni, n_SEQUEN_VO4 ]

				EndIf

			EndIf

		EndIf

	EndIf

Next

// Ordena vetor - Data + Hora + SEQUEN + Coluna com conteudo A/B
Asort(aIntervalo,,,{|x,y| Dtos( x[1] ) + StrZero( x[2] , 4 ) + x[9] + x[7] < Dtos( y[1] ) + StrZero( y[2] , 4 ) + y[9] + y[7] } )

// Adiciona hora inicial / hora Final
//If len(aIntervalo) == 0 .Or. Dtos( aIntervalo[Len(aIntervalo),1] ) + StrZero( aIntervalo[Len(aIntervalo),2] , 4 ) <= Dtos( dDataFin ) + StrZero( nHoraFin , 4 )
If len(aIntervalo) == 0 .Or. Dtos( aIntervalo[Len(aIntervalo),1] ) + StrZero( aIntervalo[Len(aIntervalo),2] , 4 ) < Dtos( dDataFin ) + StrZero( nHoraFin , 4 )

	If Len(aIntervalo) # 0

		aIntervalo[Len(aIntervalo),3] := aStatus[2]

	EndIf
	if nHoraFin > VOH->VOH_FINPER .and. nHoraIni < VOH->VOH_FINPER
		Aadd(aIntervalo,{ dDataFin , VOH->VOH_FINPER+1 , aStatus[2] , "" , "" , "" , "A" , 0 , Space(8) })
	Endif
	Aadd(aIntervalo,{ dDataFin , nHoraFin , aStatus[2] , "" , "" , "" , "A" , 0 , Space(8) })

EndIf

If Dtos( aIntervalo[1,1] ) + StrZero( aIntervalo[1,2] , 4 ) > Dtos( dDataIni ) + StrZero( nHoraIni , 4 )
	Aadd(aIntervalo,{ dDataIni , nHoraIni , aStatus[1] , "" , "" , "" , "A" , 0 , Space(8) })
EndIf

// Ordena vetor
Asort(aIntervalo,,,{|x,y| Dtos( x[1] ) + StrZero( x[2] , 4 ) + x[9] + x[7] < Dtos( y[1] ) + StrZero( y[2] , 4 ) + y[9] + y[7] } )

// Monta vetor de retorno
For nIni := 1 to IIf( Len( aIntervalo ) == 1 , 1 , Len(aIntervalo)-1 )

	If aIntervalo[ nIni , 3 ] $ cStatus .And. aIntervalo[ nIni , 7 ] $ "A/I"

		Aadd( aVetor , { ;
			aIntervalo[ nIni , 1 ] , ;
			aIntervalo[ nIni , 2 ] , ;
			Ctod("  /  /  ") , ;
			0 , ;
			aIntervalo[ nIni , 3 ] , ;
			0 , ;
			aIntervalo[ nIni , 4 ] , ;
			aIntervalo[ nIni , 5 ] , ;
			aIntervalo[ nIni , 6 ] , ;
			aIntervalo[ nIni , 8 ] , ;
			0 , ;
			0 } )

		If nIni+1 <= Len(aIntervalo) .And. aIntervalo[ nIni+1 , 7 ] # "C"

			aVetor[ Len( aVetor ) , 3 ] := aIntervalo[ nIni+1 , 1 ]
			aVetor[ Len( aVetor ) , 4 ] := aIntervalo[ nIni+1 , 2 ]
			aVetor[ Len(aVetor) , 6 ]   := FS_VLSERTP( aVetor[ Len( aVetor ) , 1 ] , aVetor[ Len( aVetor ) , 2 ] , aVetor[ Len( aVetor ) , 3 ] , aVetor[ Len( aVetor ) , 4 ] )

		EndIf

	EndIf

Next

&& Levanta tempo trabalhado inclusive disponivel quando nao tem hora final
For nSitMec := 1 to Len(aVetor)
	For nSitMec1 := 1 to Len(aVetor)

		nTpTrb := 0
		If Empty(aVetor[nSitMec1,6])
			If ( nIni := Ascan(aIntervalo,{|x| Dtos(x[1])+Str(x[2],4) > Dtos(aVetor[nSitMec1,1])+Str(aVetor[nSitMec1,2],4) }) ) # 0
				nTpTrb := FS_VLSERTP( aVetor[nSitMec1,1] , aVetor[nSitMec1,2] , aIntervalo[ nIni , 1 ] , aIntervalo[ nIni , 2 ] )
			Else
				nTpTrb := FS_VLSERTP( aVetor[nSitMec1,1] , aVetor[nSitMec1,2] , dDataBase , Val(Substr(Time(),1,2)+Substr(Time(),4,2)) )
			EndIf
		Else
			nTpTrb := aVetor[nSitMec1,6]
		EndIf

		If nSitMec1 > nSitMec
			If ( aVetor[nSitMec1,7]+aVetor[nSitMec1,8] == aVetor[nSitMec,7]+aVetor[nSitMec,8] .Or. Empty(aVetor[nSitMec1,7]+aVetor[nSitMec1,8]) )
				If !Empty(aVetor[nSitMec,1]) .And. Empty(aVetor[nSitMec,3])
					If aVetor[nSitMec1,5] $ "D"
						aVetor[nSitMec,11] += nTpTrb
						aVetor[nSitMec,12] += nTpTrb
					EndIf
				EndIf
			EndIf
		Else
			If aVetor[nSitMec1,7]+aVetor[nSitMec1,8] == aVetor[nSitMec,7]+aVetor[nSitMec,8]
				If aVetor[nSitMec1,5] $ "O/E"
					aVetor[nSitMec,11] += nTpTrb
					aVetor[nSitMec,12] := nTpTrb
				EndIf
			EndIf
		EndIf

	Next
Next
Return( aVetor )
*/
/* F U N C A O   T E M P O R A R I A  -  A P E N A S   P/  C O N T O R N A R   P R O B L E M A - B00
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FG_RetGru ³Autor  ³Manoel              ³ Data ³ 22/12/2000  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Filtra os itens de um Grupo                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_RetGru()
Local cReturn :='.T.'
Local nPos
Local cVar
If (Type('aHeader') == 'A') .and.  (Type('N') == 'N')
	nPos	:= aScan(aHeader,{|x|SubStr(x[2],3,7)== '_GRPVEI' })
	If nPos == 0
		nPos	:= aScan(aHeader,{|x|SubStr(x[2],3,7)== '_CODITE' })
	EndIF
	IF nPos > 0
		cReturn:=aCols[n,nPos]
	Endif
Else
	nPos	:= aScan(aHeader,{|x|SubStr(x[2],3,7)== '_GRPVEI' })
	If nPos == 0
		nPos	:= aScan(aHeader,{|x|SubStr(x[2],3,7)== '_CODITE' })
	EndIF
	IF nPos > 0
		cVar := Subst(aGets[nPos],9,10)
		cReturn:=m->&cVar
	Endif
EndIf
Return (cReturn)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³FG_FilVEG4³ Autor ³ Manoel                ³ Data ³ 27.12.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina para Filtrar o VEG                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico	(Arquivos VE4 e VE5)					                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_FilVEG4()
Local cRet := "08/06/04/"

If Trim(Readvar())+"/" $ "M->VE4_FVLSGV/M->VE4_FVLASS/M->VE4_FVLFVD/M->VE4_FDDAFD/M->VE4_FVMIVD"
	cRet := "08/" // Grupo de Formulas de VEICULOS
Elseif Readvar() == "M->VE4_FOREXP/"
	cRet := "06/" // Grupo de Formulas da GARANTIA
Elseif Trim(Readvar())+"/" $ "M->VE4_FORVDA/M->VE4_FORGAR/M->VE4_FORPRP/"
	cRet := "04/" // Grupo de Formulas de Pecas
Endif

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_MNU    ºAutor  ³Fabio               º Data ³  01/28/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Interpreta menu do usuario                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cUsuario   := Codigo do usuario do menu                    º±±
±±º          ³ nChaveProc := Chave que sera verificada.  1-Codigo         º±±
±±º          ³                                           2-Nome           º±±
±±º          ³                                           3-Senha          º±±
±±º          ³ cStrFound  := Se necessario validar o acesso do usuario    º±±
±±º          ³               a programa do menu.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_MNU( cUsr , nChaveProc , cStrFound )

Local aMnu := {} , cMenu , i := 0 , nHandle , cStr
Local cUserSalva := __cUserID
Private aUser := {}

PswOrder(nChaveProc)
PswSeek(cUsr) //senha

aUser   := PswRet(3)
if Len(aUser) <> 0
	For i := 1 To Len( aUser[1] )

		cMenu := Alltrim( Substr( aUser[1,i] , 4 ) )
		If !File(cMenu) .Or. Substr( aUser[1,i] , 3 , 1 ) == "X"
			Loop
		EndIf

		Aadd(aMnu,{ Substr( cMenu , Rat("\" , cMenu ) + 1 ) , cMenu , {} })

		if (nHandle:= FT_FUse( cMenu )) == -1
			Loop
		endif

		FT_FGotop()
		While ! FT_FEof()

			cStr := FT_FReadLN()

			Aadd( aMnu[Len(aMnu),3] , cStr )

			If cStrFound # NIL .And. cStrFound $ cStr

				&& Volta configuracao
				PswOrder(1)
				PswSeek(cUserSalva)

				Return( .t. )

			EndIf

			FT_FSkip()
		End
		FT_FUse()

	Next
Endif

&& Volta configuracao
PswOrder(1)
PswSeek(cUserSalva)

Return( IIf( cStrFound # NIL , .f. , aMnu ) )


/////////////////////
Function FG_INTEGRI()

If left(aHeader[2,2],3) # "VS9"
	aHeader := aClone(aHeaderC)
	aCols   := aClone(aColsC)
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³FS_MARCAS ³ Autor ³ Andre	                ³ Data ³ 27.12.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Marcas						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MARCAS()
Local nRec:=VE1->(Recno())
Local cRet := "   /"
VE1->(DbSeek(xFilial("VE1")))
While !VE1->(Eof()) .and. xFilial("VE1") == VE1->VE1_FILIAL
	cRet+=VE1->VE1_CODMAR+'/'
	VE1->(DbSkip())
EndDo
VE1->(DbGoto(nRec))
Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_TOTENT ºAutor  ³Ricardo Farinelli   º Data ³  04/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Totaliza a variavel de entrada digitada pelo usuario na     º±±
±±º          ³getdados de entrada na negociacao do pagamento              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_TOTENT(laHeader, lDelete)

Local nTot := 0
Local nwnk := 0
Default laHeader := .F.
Default lDelete  := .F.

nTotEntr := 0
If !laHeader
	For nwnk := 1 To Len(aColsC)
		If !aColsC[nwnk,Len(aColsC[nwnk])] .and. !Empty(aColsC[nwnk,1])
			if (lDelete .and. !aColsC[nwnk,Len(aColsC[nwnk])])
				nTot := aColsC[nwnk,FG_POSVAR("VS9_VALPAG","aHeaderC")]
			Endif
			nTotEntr += nTot
		Endif
	Next
Else
	For nwnk := 1 To Len(aCols)
		If !aCols[nwnk,Len(aCols[nwnk])] .and. !Empty(aCols[nwnk,1])
			if (lDelete .and. !aColsC[nwnk,Len(aColsC[nwnk])])
				nTot := aCols[nwnk,FG_POSVAR("VS9_VALPAG")]
			Endif
			nTotEntr += nTot
		Endif
	Next
Endif
if Type("oTotEntr") == "O"
	oTotEntr:Refresh()
Endif
if lDelete
	if aCols[n,Len(aCols[n])]
		If cTipOpe == 1
			nTotTit += nTotEntr
		elseif cTipOpe == 2
			nTotTTp += nTotEntr
		else
			M->VV0_TOTENT += nTotEntr
		Endif
	Endif
	aColsC := aClone(aCols)
Endif

Return(nTotEntr)


///////////////////////////
Function FS_SLVFOL(nOption)

if nOption == 1
	if Type("oFolder") <> "U"
		oFolderSlv := oFolder
	Endif
Else
	if Type("oFolder") <> "U" .and. Type("oFolderSlv") <> "U"
		oFolder := oFolderSlv
	Endif
Endif

Return(.t.)

Function CalcPISCOFSAI(nbase)
/* Devera estar posicionado no SF4 e no SB1
nBase - Base de calculo do Imposto
Retornara um array com o valor do PIS e Cofins e as respectivas aliquotas (De entrada ou de Saida, depende da TES enviada
*/
aRetPisCof := {}
nValPisSai := 0
nBasPisSai := 0
nValCofSai := 0
nBasCofSai := 0
nTxPIS	:= GetMv("MV_TXPIS")
nTxCOF	:=	GetMv("MV_TXCOFIN")
nRedPis  := 1
nRedCof  := 1
If SF4->F4_AGREG <> "N"
	If SB1->(FieldPos("B1_PPIS")) >0
		nTxPIS	:= 	IIf(SB1->B1_PPIS <> 0,SB1->B1_PPIS , GetMv("MV_TXPIS"))
	Endif
	If SB1->(FieldPos("B1_REDPIS")) > 0
		nRedPIS	:= 	IIf(SB1->B1_REDPIS > 0,1-(SB1->B1_REDPIS / 100 ), 1 )
	Endif
	If SF4->(FieldPos("F4_BASEPIS")) > 0
		nRedPIS	*= 	IIf(SF4->F4_BASEPIS > 0,1-(SF4->F4_BASEPIS / 100 ), 1 )
	Endif
	If SB1->(FieldPos("B1_REDCOF")) > 0
		nRedCOF	:= 	IIf(SB1->B1_REDCOF > 0,1-(SB1->B1_REDCOF / 100 ), 1 )
	EndIf
	If SB1->(FieldPos("B1_PCOFINS")) > 0
		nTxCOF	:=	IIf(SB1->B1_PCOFINS <> 0,SB1->B1_PCOFINS , GetMv("MV_TXCOFIN"))
	Endif
	If SF4->(FieldPos("F4_PISCOF")) > 0
		If SF4->(FieldPos("F4_PISCRED")) >0 .and. SF4->F4_PISCRED $ "1|2"
			If SF4->F4_PISCRED =="2"  //1-Credita;2-Debita
				nValPisSai := ( nBase * nRedPis ) * (nTxPis / 100)
				nBasPisSai := nBase * nRedPis
				nValCofSai := (nBase * nRedCOF) * ( nTxCof / 100)
				nBasCofSai := nBase * nRedCOF
			Endif
		EndIf
	Endif
EndIF
If nValPisSai < 0 .or. nBasPisSai < 0
	nValPisSai := 0
	nBasPisSai := 0
Endif
If nValCofSai < 0 .or. nBasCofSai < 0
	nValCofSai := 0
	nBasCofSai := 0
Endif

aAdd ( aRetPisCof , {nvalPisSai,nValCofSai,nTxPis,nTxCof} )


Return (aRetPiscof)

Function PIPL(ctipo)
/* retorna picture da placa do veiculo para veiculos importados*/

wReturn := VV1->(X3PICTURE("VV1_PLAVEI"))
//wPlaca := ReadVar()
If cTipo <> "1" // veiculos importados tem placa com formato diferente
	wReturn := "@!"
Endif

Return(Trim(wReturn)+'%C')

Function GrvPiscof(nBase,aPiscof,ctipo)
/*Grava os campos de PIS e Cofins no SD1/SD2 */
Local aRelImp	:= MaFisRelImp("MT100",{ "SD1" })
Local aRelImp2:= MaFisRelImp("MT100",{ "SD2" })
Local nScanPis  := 0
Local nScanCof := 0
Local cCpVlPisEn:= ""
Local cCpBsPisEn:= ""
Local cCpVlPisSa:= ""
Local cCpBsPisSa:= ""
Local cCpAlPisSa:= ""
Local cCpAlPisEt:= ""
Local cCpVlCofEn:= ""
Local cCpBsCofEn:= ""
Local cCpVlCofSa:= ""
Local cCpBsCofSa:= ""
Local cCpAlCofSa:= ""
Local cCpAlCofEt:= ""
If cTipo == "E" // Gravar campo de Entrada
	/* Tratamento dos campos de Pis de Entrada */
	If !Empty( nScanPis := aScan(aRelImp ,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQPS2"} ) )
		cCpAlPisEt := aRelImp[nScanPis,2]
		SD1->( &( cCpAlPisEt ) )  := aPisCof[1,3]
	EndIf

	If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASEPS2"} ) )
		cCpBsPisEn := aRelImp[nScanPis,2]
		SD1->(&(cCpBsPisEn)) := nBase
	EndIf
	If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALPS2"} ) )
		cCpVlPisEn := aRelImp[nScanPis,2]
		SD1->(&(cCpVlPisEn)) := aPisCof[1,1]
	EndIf
	/* Tratamento dos campos de Cofins de Entrada */
	If !Empty( nScanCof := aScan(aRelImp ,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQCF2"} ) )
		cCpAlCofEt := aRelImp[nScanCof,2]
		SD1->( &( cCpAlCofEt ) ) := aPiscof[1,4]
	EndIf

	If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASECF2"} ) )
		cCpBsCofEn := aRelImp[nScanCof,2]
		SD1->(&(cCpBsCofEn)) := nbase
	EndIf
	If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALCF2"} ) )
		cCpVlCofEn := aRelImp[nScanPis,2]
		SD1->(&(cCpVlCofEn)) := aPisCof[1,2]
	EndIf
Else
	/* Tratamento dos campos de Pis de saida*/
	If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_ALIQPS2"} ) )
		cCpAlPisSa := aRelImp2[nScanPis,2]
		SD2->( &( cCpAlPisSa ) ) := aPisCof[1,3]
	EndIf
	If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_BASEPS2"} ) )
		cCpBsPisSa := aRelImp2[nScanPis,2]
		SD2->(&(cCpBsPisSa)) :=  nBase
	EndIf
	If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_VALPS2"} ) )
		cCpVlPisSa := aRelImp2[nScanPis,2]
		SD2->(&(cCpVlPisSa)) := aPiscof[1,1]
	EndIf
	/* Tratamento dos campos de Cofins de Saída */
	If !Empty( nScanCof := aScan(aRelImp2 ,{|x| x[1]=="SD2" .And. x[3]=="IT_ALIQCF2"} ) )
		cCpAlCofSa := aRelImp2[nScanCof,2]
		SD2->(&( cCpAlCofSa ) ) := aPiscof[1,4]
	EndIf

	If !Empty( nScanCOF := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_BASECF2"} ) )
		cCpBsCofSa := aRelImp2[nScanCof,2]
		SD2->(&(cCpBsCofSa)) := nBase
	EndIf
	If !Empty( nScanCof := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_VALCF2"} ) )
		cCpVlCofSa := aRelImp2[nScanCof,2]
		SD2->(&(cCpVlCofSa)) := aPisCof[1,2]
	EndIf
EndIf
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Ricardo Farinelli   º Data ³  04/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Menu														  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { { " " ," " , 0, 1},;       //Pesquisar
{ " " ," " , 0, 2},;   //Visualizar
{ " " ," " , 0, 3},;   //Incluir
{ " " ," " , 0, 4},;   //Alterar
{ " " ," " , 0, 5} }   //Excluir
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_FAPLGM ºAutor  ³Fabio               º Data ³  03/26/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtra aplicacao do servico por chassi                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_FAPLGM(cMarPes,cCodSer,cSrvAdi,cCodApl,cContro,lMsg)

Local cSalvaAlias := Alias()

Default cMarPes := VV1->VV1_CODMAR
Default cCodSer := VO6->VO6_CODSER
Default cSrvAdi := VJ9->VJ9_SRVADI
Default cCodApl := Substr(VV1->VV1_CHASSI,4,4)+Space(2)
Default cContro := VJ9->VJ9_CONTRO
Default lMsg    := .t.

&& Verifica tempo por aplicacao
If cMarPes == FG_MARCA("CHEVROLET",,.f.)
	DbSelectArea("VJ9")
	DbSetOrder(1)
	If !DbSeek( xFilial("VJ9")+ cMarPes + cCodSer + cSrvAdi + cCodApl + cContro )
		OFIOC250(cCodSer)
		cMarPes := VV1->VV1_CODMAR
		cCodSer := VO6->VO6_CODSER
		cSrvAdi := VJ9->VJ9_SRVADI
		cCodApl := Substr(VV1->VV1_CHASSI,4,4)+Space(2)
		cContro := VJ9->VJ9_CONTRO

		If VO6->(FieldPos("VO6_KMINI")) # 0 .AND. VO6->(FieldPos("VO6_KMFIN")) # 0  .AND. VO6->(FieldPos("VO6_LIMITE")) # 0
			if FUNNAME() == "OFIOM030"
				DbSelectArea("VOI")
				DbSetOrder(1)
				DbSeek( xFilial("VOI") + M->VO4_TIPTEM)
			Else
				DbSelectArea("VOI")
				DbSetOrder(1)
				DbSeek( xFilial("VOI") + M->VS1_TIPTEM)
			Endif
			//			if VOI->VOI_SITTPO == "4"

			DbSelectArea("VVL")
			DbSetOrder(1)
			If DbSeek( xFilial("VVL") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD )
				if (VO1->VO1_KILOME < VO6->VO6_KMINI .or. VO1->VO1_KILOME > VO6->VO6_KMFIN) .or. ((VV1->VV1_DATVEN+VVL->VVL_PERGAR - ddatabase) > VO6->VO6_LIMITE)
					MsgStop(STR0340,STR0002)
					Return(.f.)
				Endif
			Endif
		Endif
		DbSelectArea("VJ9")
		DbSetOrder(1)
		If !DbSeek( xFilial("VJ9")+ cMarPes + cCodSer + cSrvAdi + cCodApl + cContro )
			If lMsg
				MsgStop(STR0346+cCodSer+STR0347,STR0002)
			EndIf
		EndIf
		If !Empty(cSalvaAlias)
			DbSelectArea(cSalvaAlias)
		EndIf
		Return(.f.)
	EndIf
	If VJ9->VJ9_SERATI == "0"
		If lMsg
			MsgStop(STR0346+cCodSer+STR0348 ,STR0002 )
		EndIf
		If !Empty(cSalvaAlias)
			DbSelectArea(cSalvaAlias)
		EndIf
		Return(.f.)
	EndIf
Endif
If !Empty(cSalvaAlias)
	DbSelectArea(cSalvaAlias)
EndIf

Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FG_VLTCHASSI³Autor³ Alvaro / Manoel Filho   ³ Data ³ 19/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Volta Chassi quando Informado o Chassi Reduzido		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FG_VLTCHASSI("MV_Par??")                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico	  									 	  	   	    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_VltChassi(cPar)

FG_POSVEI(cPar,)//Posicione("VV1",10,xFilial("VV1")+Alltrim(&cPar),"VV1_CHASSI")

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_SALDORCºAutor  ³Thiago              º Data ³  05/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Levanta Saldo Orcamento.                      		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cCodCli := Codigo do Cliente                               º±±
±±º          ³ cLoja   := Loja                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_SALDORC(cCodCli,cLoja)
Local cQuery   := ""
Local cVS3VS4  := "SQLVS3VS4"
Local aObjects := {} , aPosObj := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor  := 0
Local nTamCampo:= 0
Local nPos     := 0
Local nVS1Tot  := 0
Local cTpOrc   := ""
Local nOrcDig  := 0
Local nMarPen  := 0
Local nAvaCre  := 0
Local nAguSep  := 0
Local nLibDiv  := 0
Local nLibOOr  := 0
Local nLibFat  := 0
Local nOrcImp  := 0
Local nOrcCan  := 0
Local nOrcFat  := 0
Local nOrcOut  := 0
Local aSalOrc  := {}
Local aFilAtu    := FWArrFilAtu()
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
Private oVerde   := LoadBitmap( GetResources(), "BR_VERDE" )
Private oPink    := LoadBitmap( GetResources(), "BR_PINK" )
Private oBranco  := LoadBitmap( GetResources(), "BR_BRANCO" )
Private oAzul    := LoadBitmap( GetResources(), "BR_AZUL" )
Private oMarrom  := LoadBitmap( GetResources(), "BR_MARROM" )
Private oAzulC   := LoadBitmap( GetResources(), "BR_AZUL_CLARO" )
Private oAmarelo := LoadBitmap( GetResources(), "BR_AMARELO" )
Private oLaranja := LoadBitmap( GetResources(), "BR_LARANJA" )
Private oVermelho:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oPreto   := LoadBitmap( GetResources(), "BR_PRETO" )
Private oLBNO    := LoadBitmap( GetResources(), "LBNO" )
aObjects := {}
AAdd( aObjects, { 01, 30, .T. , .F. } )   		//Cabecalho
AAdd( aObjects, { 01, 20, .T. , .T. } )   		//Centro
AAdd( aObjects, { 01, 45, .T. , .F. } )   		//Rodape
For nCntFor := 1 to Len(aSizeAut)
	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
Next
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)
//

if TYPE("aSelFil") == "U"
	aSelFil := aClone(aSM0)
Endif


For nCont := 1 to Len(aSelFil)

	cFilAnt := aSelFil[nCont]

	cQuery := "SELECT VS1.VS1_FILIAL , VS1.VS1_STATUS , VS1.VS1_NUMORC , VS1.VS1_TIPORC , "
	cQuery += "VS1.VS1_DATORC , VS1.VS1_NUMNFI , VS1.VS1_SERNFI , SA3.A3_NOME , "
	cQuery += "SUM(VS3.VS3_VALTOT) AS VALTOT "
	cQuery += "FROM "+RetSQLName("VS1")+" VS1 "
	cQuery += "LEFT JOIN "+RetSQLName("VS3")+" VS3 ON ( VS3.VS3_FILIAL=VS1.VS1_FILIAL AND VS3.VS3_NUMORC=VS1.VS1_NUMORC AND VS3.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VS1.VS1_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE "
	cQuery += "VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_TIPORC IN ('1','2') AND "
	cQuery += "( VS1.VS1_STATUS IN ('X','I','C') OR VS1.VS1_DATVAL >= '"+Dtos(dDataBase)+"' ) AND "
	cQuery += "VS1.VS1_CLIFAT='"+cCodCli+"' AND VS1.VS1_LOJA='"+cLoja+"' AND VS1.D_E_L_E_T_=' ' "
	cQuery += "GROUP BY VS1.VS1_FILIAL , VS1.VS1_STATUS , VS1.VS1_NUMORC , VS1.VS1_TIPORC , "
	cQuery += "VS1.VS1_DATORC , VS1.VS1_NUMNFI , VS1.VS1_SERNFI , SA3.A3_NOME "

	cQuery += " UNION ALL "

	cQuery += "SELECT VS1.VS1_FILIAL , VS1.VS1_STATUS , VS1.VS1_NUMORC , VS1.VS1_TIPORC , "
	cQuery += "VS1.VS1_DATORC , VS1.VS1_NUMNFI , VS1.VS1_SERNFI , SA3.A3_NOME , "
	cQuery += "SUM(VS4.VS4_VALTOT) AS VALTOT "
	cQuery += "FROM "+RetSQLName("VS1")+" VS1 "
	cQuery += "LEFT JOIN "+RetSQLName("VS4")+" VS4 ON ( VS4.VS4_FILIAL=VS1.VS1_FILIAL AND VS4.VS4_NUMORC=VS1.VS1_NUMORC AND VS4.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VS1.VS1_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE "
	cQuery += "VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_TIPORC IN ('1','2') AND "
	cQuery += "( VS1.VS1_STATUS IN ('X','I','C') OR VS1.VS1_DATVAL >= '"+Dtos(dDataBase)+"' ) AND "
	cQuery += "VS1.VS1_CLIFAT='"+cCodCli+"' AND VS1.VS1_LOJA='"+cLoja+"' AND VS1.D_E_L_E_T_=' ' "
	cQuery += "GROUP BY VS1.VS1_FILIAL , VS1.VS1_STATUS , VS1.VS1_NUMORC , VS1.VS1_TIPORC , "
	cQuery += "VS1.VS1_DATORC , VS1.VS1_NUMNFI , VS1.VS1_SERNFI , SA3.A3_NOME "
	//
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cVS3VS4 , .F., .T. )
	//
	While !(cVS3VS4)->(Eof())
		//
		nVS1Tot := (cVS3VS4)->VALTOT
		////////////////
		// Cria Vetor //
		////////////////
		nPos := Ascan( aSalOrc , { |x| x[2]+x[3] == (cVS3VS4)->(VS1_FILIAL)+(cVS3VS4)->(VS1_NUMORC) } )
		If nPos <= 0
			If (cVS3VS4)->(VS1_TIPORC) == "1"
				cTpOrc := STR0385 // Pecas
			ElseIf (cVS3VS4)->(VS1_TIPORC) == "2"
				cTpOrc := STR0386 // Oficina
			Else
				cTpOrc := STR0387 // Transf
			EndIf
			aAdd(aSalOrc,{(cVS3VS4)->(VS1_STATUS),(cVS3VS4)->(VS1_FILIAL),(cVS3VS4)->(VS1_NUMORC),cTpOrc,(cVS3VS4)->(A3_NOME),stod((cVS3VS4)->(VS1_DATORC)),(cVS3VS4)->(VS1_NUMNFI),(cVS3VS4)->(VS1_SERNFI),0} )
			nPos := len(aSalOrc)
		EndIf
		aSalOrc[nPos,9] += nVS1Tot // Soma na linha do Orcamento
		////////////////
		// Totaliza   //
		////////////////
		Do Case
			Case (cVS3VS4)->(VS1_STATUS) == "0" .or. (cVS3VS4)->(VS1_STATUS) == " "  //Orcamento digitado
				nOrcDig += nVS1Tot
			Case (cVS3VS4)->(VS1_STATUS) == "2" //Margem pendente
				nMarPen += nVS1Tot
			Case (cVS3VS4)->(VS1_STATUS) == "3" //Avaliacao de credito
				nAvaCre += nVS1Tot
			Case (cVS3VS4)->(VS1_STATUS) == "4"  //Aguardando separacao
				nAguSep += nVS1Tot
			Case (cVS3VS4)->(VS1_STATUS) == "5" //Aguardando liberacao de divergencia
				nLibDiv += nVS1Tot
			Case (cVS3VS4)->(VS1_STATUS) == "G" //Aguardando outro Orçamento
				nLibOOr += nVS1Tot
			Case (cVS3VS4)->(VS1_STATUS) == "F" //Liberado para faturamento
				nLibFat += nVS1Tot
			Case (cVS3VS4)->(VS1_STATUS) == "I"  //Orcamento importado para uma ordem de serviço
				nOrcImp += nVS1Tot
			Case (cVS3VS4)->(VS1_STATUS) == "C" //Cancelado
				nOrcCan += nVS1Tot
			Case (cVS3VS4)->(VS1_STATUS) == "X" //Faturado
				nOrcFat += nVS1Tot
			Otherwise // Outras Fases / Fases Customizadas
				nOrcOut += nVS1Tot
		EndCase
		(cVS3VS4)->(DbSkip())
	EndDo
	( cVS3VS4 )->( DbCloseArea() )

Next
cFilAnt := cBkpFilAnt

dbSelectArea("VS1")

If Len(aSalOrc) # 0

	Asort(aSalOrc,,,{|x,y| x[2]+x[3] < y[2]+y[3] } )

	DEFINE MSDIALOG oDlgOrc FROM aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE STR0353 OF oMainWnd PIXEL


	@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4]-50 LABEL "" OF oDlgOrc PIXEL

	@ aPosObj[1,1]+004,010 SAY (STR0122) SIZE 025,07          OF oDlgOrc PIXEL //"Codigo"
	@ aPosObj[1,1]+012,010 MSGET SA1->A1_COD      SIZE 035,09 WHEN .F. OF oDlgOrc PIXEL

	@ aPosObj[1,1]+004,050 SAY (STR0123) SIZE 020,07          OF oDlgOrc PIXEL //"Loja"
	@ aPosObj[1,1]+012,050 MSGET SA1->A1_LOJA     SIZE 020,09 WHEN .F. OF oDlgOrc PIXEL

	@ aPosObj[1,1]+004,075 SAY (STR0124) SIZE 025,07 OF oDlgOrc PIXEL //"Nome"
	@ aPosObj[1,1]+012,075 MSGET SA1->A1_NOME     SIZE 165,09 WHEN .F. OF oDlgOrc PIXEL

	@ aPosObj[2,1],aPosObj[2,2] LISTBOX oLbSalOrc FIELDS HEADER "",STR0127,STR0357,STR0358,STR0360,STR0361,STR0362,STR0373,"Status",STR0359;
		COLSIZES 10,20,50,35,70,35,35,25,25,45 SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] OF oDlgOrc PIXEL ON DBLCLICK OFIC170( aSalOrc[oLbSalOrc:nAt,02] , aSalOrc[oLbSalOrc:nAt,03] )
	oLbSalOrc:SetArray(aSalOrc)
	oLbSalOrc:bLine := { || {IIf(aSalOrc[oLbSalOrc:nAt,01]=="0",oVerde,IIf(aSalOrc[oLbSalOrc:nAt,01]=="2",oPink,IIf(aSalOrc[oLbSalOrc:nAt,01]=="3",oBranco,IIf(aSalOrc[oLbSalOrc:nAt,01]=="4",oAzul,IIf(aSalOrc[oLbSalOrc:nAt,01]=="5",oMarrom,IIf(aSalOrc[oLbSalOrc:nAt,01]=="G",oAzulC,IIf(aSalOrc[oLbSalOrc:nAt,01]=="F",oAmarelo,IIf(aSalOrc[oLbSalOrc:nAt,01]=="I",oLaranja,IIf(aSalOrc[oLbSalOrc:nAt,01]=="C",oVermelho,IIf(aSalOrc[oLbSalOrc:nAt,01]=="X",oPreto,oLBNO)))))))))) ,;
	aSalOrc[oLbSalOrc:nAt,02] ,;
	aSalOrc[oLbSalOrc:nAt,03] ,;
	aSalOrc[oLbSalOrc:nAt,04] ,;
	aSalOrc[oLbSalOrc:nAt,05] ,;
	aSalOrc[oLbSalOrc:nAt,06] ,;
	aSalOrc[oLbSalOrc:nAt,07] ,;
	aSalOrc[oLbSalOrc:nAt,08] ,;
	aSalOrc[oLbSalOrc:nAt,01] ,;
	FG_AlinVlrs(Transform(aSalOrc[oLbSalOrc:nAt,09],"@E 999,999,999.99")) }}

	DEFINE SBUTTON FROM aPosObj[1,1]+010,aPosObj[1,4]-35 TYPE 1 ACTION (oDlgOrc:End()) ENABLE OF oDlgOrc PIXEL

	nTamCampo := (aPosObj[3,4]/9)

	@ aPosObj[3,1],(nTamCampo*0)+002 TO aPosObj[3,3],(nTamCampo*3) LABEL "" OF oDlgOrc PIXEL

	@ aPosObj[3,1]+003,(nTamCampo*0)+005 BITMAP oxVerde RESOURCE "BR_VERDE" OF oDlgOrc NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+003,(nTamCampo*0)+015 SAY STR0363 OF oDlgOrc SIZE 60,08 PIXEL COLOR CLR_BLACK
	@ aPosObj[3,1]+002,(nTamCampo*2)-008 MSGET onOrcDig VAR nOrcDig PICTURE "@E 999,999,999.99" SIZE nTamCampo+5,8 OF oDlgOrc PIXEL COLOR CLR_BLACK WHEN .F.

	@ aPosObj[3,1]+013,(nTamCampo*0)+005 BITMAP oxPink RESOURCE "BR_PINK" OF oDlgOrc NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+013,(nTamCampo*0)+015 SAY STR0364 OF oDlgOrc SIZE 60,08 PIXEL COLOR CLR_BLACK
	@ aPosObj[3,1]+012,(nTamCampo*2)-008 MSGET onMarPen VAR nMarPen PICTURE "@E 999,999,999.99" SIZE nTamCampo+5,8 OF oDlgOrc PIXEL COLOR CLR_BLACK WHEN .F.

	@ aPosObj[3,1]+023,(nTamCampo*0)+005 BITMAP oxBranco RESOURCE "BR_BRANCO" OF oDlgOrc NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+023,(nTamCampo*0)+015 SAY STR0365 OF oDlgOrc SIZE 60,08 PIXEL COLOR CLR_BLACK
	@ aPosObj[3,1]+022,(nTamCampo*2)-008 MSGET onAvaCre VAR nAvaCre PICTURE "@E 999,999,999.99" SIZE nTamCampo+5,8 OF oDlgOrc PIXEL COLOR CLR_BLACK WHEN .F.

	@ aPosObj[3,1],(nTamCampo*3)+002 TO aPosObj[3,3],(nTamCampo*6) LABEL "" OF oDlgOrc PIXEL

	@ aPosObj[3,1]+003,(nTamCampo*3)+005 BITMAP oxAzul RESOURCE "BR_AZUL" OF oDlgOrc NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+003,(nTamCampo*3)+015 SAY STR0366 OF oDlgOrc SIZE 60,08 PIXEL COLOR CLR_BLACK
	@ aPosObj[3,1]+002,(nTamCampo*5)-008 MSGET onAguSep VAR nAguSep PICTURE "@E 999,999,999.99" SIZE nTamCampo+5,8 OF oDlgOrc PIXEL COLOR CLR_BLACK WHEN .F.

	@ aPosObj[3,1]+013,(nTamCampo*3)+005 BITMAP oxMarrom RESOURCE "BR_MARROM" OF oDlgOrc NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+013,(nTamCampo*3)+015 SAY STR0367 OF oDlgOrc SIZE 60,08 PIXEL COLOR CLR_BLACK
	@ aPosObj[3,1]+012,(nTamCampo*5)-008 MSGET onLibDiv VAR nLibDiv PICTURE "@E 999,999,999.99" SIZE nTamCampo+5,8 OF oDlgOrc PIXEL COLOR CLR_BLACK WHEN .F.

	@ aPosObj[3,1]+023,(nTamCampo*3)+005 BITMAP oxAmar RESOURCE "BR_AZUL_CLARO" OF oDlgOrc NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+023,(nTamCampo*3)+015 SAY STR0410 OF oDlgOrc SIZE 100,08 PIXEL COLOR CLR_BLACK // Aguardando outro Orçamento
	@ aPosObj[3,1]+022,(nTamCampo*5)-008 MSGET onLibOOr VAR nLibOOr PICTURE "@E 999,999,999.99" SIZE nTamCampo+5,8 OF oDlgOrc PIXEL COLOR CLR_BLACK WHEN .F.

	@ aPosObj[3,1]+033,(nTamCampo*3)+005 BITMAP oxAmar RESOURCE "BR_AMARELO" OF oDlgOrc NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+033,(nTamCampo*3)+015 SAY STR0368 OF oDlgOrc SIZE 60,08 PIXEL COLOR CLR_BLACK
	@ aPosObj[3,1]+032,(nTamCampo*5)-008 MSGET onLibFat VAR nLibFat PICTURE "@E 999,999,999.99" SIZE nTamCampo+5,8 OF oDlgOrc PIXEL COLOR CLR_BLACK WHEN .F.

	@ aPosObj[3,1],(nTamCampo*6)+002 TO aPosObj[3,3],(nTamCampo*9) LABEL "" OF oDlgOrc PIXEL

	@ aPosObj[3,1]+003,(nTamCampo*6)+005 BITMAP oxLaranja RESOURCE 'BR_LARANJA' OF oDlgOrc NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+003,(nTamCampo*6)+015 SAY STR0369 OF oDlgOrc SIZE 60,08 PIXEL COLOR CLR_BLACK
	@ aPosObj[3,1]+002,(nTamCampo*8)-008 MSGET onOrcImp VAR nOrcImp PICTURE "@E 999,999,999.99" SIZE nTamCampo+5,8 OF oDlgOrc PIXEL COLOR CLR_BLACK WHEN .F.

	@ aPosObj[3,1]+013,(nTamCampo*6)+005 BITMAP oxVerm RESOURCE 'BR_VERMELHO' OF oDlgOrc NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+013,(nTamCampo*6)+015 SAY STR0370 OF oDlgOrc SIZE 60,08 PIXEL COLOR CLR_BLACK
	@ aPosObj[3,1]+012,(nTamCampo*8)-008 MSGET onOrcCan VAR nOrcCan PICTURE "@E 999,999,999.99" SIZE nTamCampo+5,8 OF oDlgOrc PIXEL COLOR CLR_BLACK WHEN .F.

	@ aPosObj[3,1]+023,(nTamCampo*6)+005 BITMAP oxPreto RESOURCE 'BR_PRETO' OF oDlgOrc NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+023,(nTamCampo*6)+015 SAY STR0371 OF oDlgOrc SIZE 60,08 PIXEL COLOR CLR_BLACK
	@ aPosObj[3,1]+022,(nTamCampo*8)-008 MSGET onOrcFat VAR nOrcFat PICTURE "@E 999,999,999.99" SIZE nTamCampo+5,8 OF oDlgOrc PIXEL COLOR CLR_BLACK WHEN .F.

	@ aPosObj[3,1]+033,(nTamCampo*6)+005 BITMAP oxLBNO RESOURCE 'LBNO' OF oDlgOrc NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[3,1]+033,(nTamCampo*6)+015 SAY STR0411 OF oDlgOrc SIZE 60,08 PIXEL COLOR CLR_BLACK // Outros
	@ aPosObj[3,1]+032,(nTamCampo*8)-008 MSGET onOrcOut VAR nOrcOut PICTURE "@E 999,999,999.99" SIZE nTamCampo+5,8 OF oDlgOrc PIXEL COLOR CLR_BLACK WHEN .F.

	ACTIVATE MSDIALOG oDlgOrc CENTER
Else
	MsgInfo(STR0372)
EndIf

Return(aSalOrc)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FS_VLDFOS    ³Autor³ Luis Delorme           ³ Data ³ 01/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Departamento e Natureza no Como Pagar 		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico	  									 	  	   	    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VLDFOS(cChave,cVrVal)

if cChave == "DP"
	return SX5->(DBSeek(xFilial("SX5")+"76"+cVrVal))
else
	DBSelectArea("SED")
	DBSetOrder(1)
	return dbSeek(xFilial("SED")+cVrVal)
endif

return .f.

/*/{Protheus.doc} AjustaHelp
Ajusta Help da rotina
@author Renato Vinicius
@since 10/10/2017
@version undefined
@param
@type function
/*/

Static Function AjustaHelp()

Local aHelpEng, aHelpSpa, aHelpPor

aHelpPor := { STR0407 }
aHelpEng := aHelpSpa :=	aHelpPor
PutHelp("PTPREQSRV",aHelpPor,aHelpEng,aHelpSpa,.f.)

Return
