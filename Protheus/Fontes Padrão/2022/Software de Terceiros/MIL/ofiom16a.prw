// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 50     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "OFIOM16A.ch"

Static lCANUSETT := FindFunction("FMX_CANUSETT")
Static lMsgStatus := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOM160A³ Autor ³  Emilton              ³ Data ³ 30/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fechamento de Ordem de Servico (Segmento funcoes)          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ITEZER ³ Autor ³ Emilton               ³ Data ³ 08/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIOM160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ITEZER()
Local aVetZer := {}
Local ixv    := 0
Local lVO3VALLIQ := VO3->(FieldPos("VO3_VALLIQ")) <> 0

nTotPec := 0
nTotDes := 0

For ixv := 1 to len(aColsFEC[2])
	
	If aColsFEC[2,ixv,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] == 0
		Loop
	EndIf
	
	nTotPec += Round(aColsFEC[2,ixv,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)],2)
	
	if lVO3VALLIQ
		nTotDes := Round(aColsFEC[2,ixv,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)],2)
	endif
	
	aAdd(aVetZer,aColsFEC[2,ixv])
	
Next

Return aVetZer


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VOLTAR ³ Autor ³ Emilton               ³ Data ³ 27/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIOM160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VOLTAR()
Local _ni := 0

If !(cPaisLoc == "BRA") // Manoel - 12/05/2009
	Return .t.
Endif

Do Case
	Case cParam01 == 1
		dbSelectArea("VO1")
		dbSetOrder(nIndexPro+1)
	Case cParam01 == 2
		dbSelectArea("VOO")
		dbSetOrder(nIndexPro+1)
	Case cParam01 == 3
		dbSelectArea("VF4")
		dbSetOrder(nIndexPro+1)
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader da Entrada                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoC:=0
dbSelectArea("SX3")
dbSeek("VS9")
aHeaderC:={}
While !Eof().And.(x3_arquivo=="VS9")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN#VS9_PORTAD#VS9_DESPOR#VS9_TIPTEM#VS9_NATURE#VS9_NATSRV#VS9_CARTEI")
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

aIteParc  := {{cTod(""),0}}
oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
cTipPag := space(3)
cCodBco := space(3)
oTipPag:Refresh()
oCodBco:Refresh()

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CUSIND ³ Autor ³ Emilton               ³ Data ³ 24/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Custo Indireto                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 - Data Inicial para levantamento dos tempos               ³±±
±±³          ³ 2 - Tempo Trabalhado do segmento analisado                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIOM160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CUSIND(dDatIni,nTpoTra)

Local cAlias  := alias()
Local nHorDis := 0
Local nHorTra := 0
Local nIndApr := 0
Local nHorPsV := 0
Local nCusMin := 0
Local nCusInd := 0
Local nCusSeg := 0
Local dDatRef := 0
Local aArea   := {}

return 0

aArea := sGetArea(aArea, alias())

dbSelectArea("VAI")
dbSetOrder(1)
dbGoTop()
dbSeek(xFilial("VAI"))

While VAI->VAI_FILIAL == xFilial("VAI") .And. !Eof()
	
	If VAI->VAI_FUNPRO != "1"
		dbSkip()
		Loop
	EndIf
	
	For dDatRef := dDatIni to dDataBase
		
		nHorDis += FG_CALTEM(VAI->VAI_CODTEC,dDatRef,"0")
		nHorTra += FG_CALTEM(VAI->VAI_CODTEC,dDatRef,"2")
		
	Next
	
	dbSelectArea("VAI")
	dbSkip()
	
EndDo

nIndApr := nHorTra / nHorDis                    && Indice de Aproveitamento da Oficina
nHorPsV := nHorDis * nIndApr                    && Horas passiveis de venda da Oficina

dbSelectArea("VSH")                             && Busca custo administrativo da oficina
cKeyAce := ""
FG_SEEK("VSH","cKeyAce",1,.f.)

while VSH->VSH_FILIAL == xFilial("VSH") .and. !eof()
	
	If dDatIni > VSH_DATCUS
		Exit
	EndIf
	dbSkip()
	
EndDo

nCusInd := VSH_VALCUS / nHorPsV
nCusMin := nCusInd / 100                        && Custo Indireto do Minuto
nCusSeg := nCusMin * nTpoTra                    && Custo Indireto do Segmento que esta sendo tratado

sRestArea(aArea)
dbSelectArea(cAlias)

Return(nCusSeg)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CUSDIR ³ Autor ³ Emilton               ³ Data ³ 24/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Custo Direto do Produtivo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 - Codigo do Produtivo                                     ³±±
±±³          ³ 2 - Data Inicial das Pesquisas                              ³±±
±±³          ³ 3 - Tempo Trabalhado                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIOM160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CUSDIR(cCodPro,dDatIni,nTpoTra)

Local cAlias  := alias()
Local nHorDis := 0
Local nHorTra := 0
Local nHorPsV := 0
Local nIndApr := 0
Local nSalEnc := 0
Local nCusDir := 0
Local nCusMin := 0
Local nCusSeg := 0
Local dDatRef := ctod("  /  /  ")

return 0

For dDatRef := dDatIni to dDataBase
	
	nHorDis += FG_CALTEM(cCodPro,dDatRef,"0")    //  Horas Disponiveis
	nHorTra += FG_CALTEM(cCodPro,dDatRef,"2")    //  Horas Trabalhadas
	
Next

nIndApr := nHorTra / nHorDis                    && Indice de Aproveitamento do tempo disponivel
nHorPsV := nHorDis * nIndApr                    && Horas passiveis de venda

dbSelectArea("VOY")
cKeyAce := cCodPro+"S"
FG_SEEK("VOY","cKeyAce",1,.f.)                  && Busca salario fixo do produtivo

while cKeyAce == VOY_FUNPRO+VOY_TIPALT .and. VOY->VOY_FILIAL == xFilial("VOY") .and. !eof()
	
	If dDataBase > VOY_DATALT
		Exit
	EndIf
	dbSkip()
	
EndDo

dbSelectArea("VSI")                             && Busca percentual de acrescimo para encargos sociais
cKeyAce := ""
FG_SEEK("VSI","cKeyAce",1,.f.)

while VSI->VSI_FILIAL == xFilial("VSI") .and. !eof()
	
	If dDatIni > VSI_DATENC
		Exit
	EndIf
	dbSkip()
	
EndDo

nSalEnc := VOY->VOY_PECSAL + (VOY->VOY_PECSAL * VSI->VSI_PERENC)   && Salario acrescido de encargos
nCusDir := nSalEnc / nHorPsV                                         && Custo da Hora
nCusMin := nCusDir / 100                                             && Custo do Minuto
nCusSeg := nCusMin * nTpoTra                                         && Custo do Segmento que esta sendo tratado

dbSelectArea(cAlias)

Return(nCusSeg)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_COMCON ³ Autor ³ Emilton               ³ Data ³ 21/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica qual consultor tecnico recebera comissao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIOM160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_COMCON(cTipTem)

cKeyAce := cTipTem
If FG_SEEK("VOJ","cKeyAce",1,.f.)
	
	while cKeyAce == VOJ->VOJ_TIPTEM .and. VOJ->VOJ_FILIAL == xFilial("VOJ") .and. !VOJ->(eof())
		
		If dDataBase > VOJ->VOJ_DATVIG
			Exit
		EndIf
		VOJ->(dbSkip())
		
	EndDo
	
	Return(VOJ->VOJ_COMISS)
	
Else
	
	Return("")
	
EndIf


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_BOQPEC ³ Autor ³ Emilton               ³ Data ³ 18/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Armazena boqueteiros para possibilitar comissao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 - Codigo do Boqueteiro                                    ³±±
±±³          ³ 2 - Quantidade Movimentada                                  ³±±
±±³          ³ 3 - 0-Devolucao/1-Requisicao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIOM160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_BOQPEC(cBoqPro,nQtdMov,cMovime)

Local ixb := 0
Local aVetTra := {}

If Len(aBoqPec) == 0 .Or. (ixb := aScan(aBoqPec,{ |x| x[1] == cBoqPro } ) ) == 0
	
	aAdd(aBoqPec,{cBoqPro,0})
	
	If cMovime == "0"
		For ixb := len(aBoqPec) to 1 Step -1
			If aBoqPec[ixb,2] >= nQtdMov
				Exit
			EndIf
		Next
	EndIf
	
	If ixb <= 0
		ixb := Len(aBoqPec)
	EndIf
	
EndIf

If cMovime == "1"
	
	aBoqPec[ixb,02] += nQtdMov
	
Else
	
	aBoqPec[ixb,02] -= nQtdMov
	
EndIf

For ixb := 1 to len(aBoqPec)
	
	If aBoqPec[ixb,02] == 0
		loop
	EndIf
	aAdd(aVetTra,{aBoqPec[ixb,01],aBoqPec[ixb,02] })
	
Next

aBoqPec := aClone(aVetTra)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVVAL ³ Autor ³ Emilton               ³ Data ³ 17/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta valores para avaliacao particular para o fechamento ³±±
±±³          ³      pelo fato de ser necessario ler dois arquivos VSY/VSZ  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1=Tipo de Levantamento (1=Orcamento / 2=Ordem de Servico)    ³±±
±±³          ³2=Numero do Orcamento ou Ordem de Servico                    ³±±
±±³          ³3=Campo a Pesquisar o Valor                                  ³±±
±±³          ³4=Campo a Pesquisar o Valor                                  ³±±
±±³          ³5=Tipo de Tempo (So qdo for Ordem de Servico)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIOM160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_LEVVAL(cTipLev,cNumChv,cContChv,cNomCpo,cTipTmp)

Local nValRet  := 0
Local cNomCpoL := ""
Local cChave   := ""

if Type("cNumeroOs") == "U"
	cNumeroOS := Nil
Endif

cNomCpol := If(SubStr(cNomCpo,4,1) != "_","VSY_"+cNomCpo,cNomCpo)
DbSelectArea("VSY")
DbSetOrder(1)
if cNumeroOS # Nil .and. lCalcTot
	cNumChv := cNumeroOS
	DbSetOrder(2)
Endif
If DbSeek(xFilial("VSY")+Left(cNumChv,8))
	Do While !EOF() .and. VSY->VSY_FILIAL == xFilial("VSY") .and. if(cNumeroOS == Nil,VSY->VSY_NUMIDE == cNumChv,if(lCalcTot,VSY->VSY_NUMOSV == cNumeroOS,VSY->VSY_NUMIDE == cNumChv))
		Do Case
			Case cNomCpo == "TOTVDA"
				nValRet := nValRet + VSY_VALVDA
			Case cNomCpo == "TOTMFR"
				nValRet := nValRet + VSY_VMFVDA
			Case cNomCpo $  "VALISS/VMFISS/CUSSER/CMFSER"
			Case left(cNomCpo,3) == "VSZ"
			OtherWise
				nValRet := nValRet + &cNomCpoL
		EndCase
		DbSkip()
	EndDo
Endif
cNomCpol := If(SubStr(cNomCpo,4,1) != "_","VSZ_"+cNomCpo,cNomCpo)
DbSelectArea("VSZ")
DbSetOrder(1)
if cNumeroOS # Nil .and. lCalcTot
	cNumChv := cNumeroOS
	DbSetOrder(2)
Endif
If DbSeek(xFilial("VSZ")+cNumChv)
	If len(alltrim(cNumChv))  == 8
		cChave := "VSZ->VSZ_NUMIDE"
	Else
		cChave := "VSZ->VSZ_NUMIDE+VSZ->VSZ_CODSER+VSZ->VSZ_NUMOSV"
	EndIf
	Do While !EOF() .and. VSZ->VSZ_FILIAL == xFilial("VSZ") .and. if(cNumeroOS == Nil,VSZ->VSZ_NUMIDE == cNumChv,if(lCalcTot,VSZ->VSZ_NUMOSV == cNumeroOS,VSZ->VSZ_NUMIDE == cNumChv))
		Do Case
			Case cNomCpo == "TOTVDA"
				nValRet := nValRet + VSZ_VALSER
			Case cNomCpo == "TOTMFR"
				nValRet := nValRet + VSZ_VMFSER
			Case cNomCpo $ "VALICM/VMFICM/CUSMED/CMFMED/JUREST/JMFEST"
			Case left(cNomCpo,3) == "VSY"
			OtherWise
				nValRet := nValRet + &cNomCpoL
		EndCase
		DbSkip()
	EndDo
Endif
DbSelectArea("VSZ")
DbSetOrder(1)

Return(nValRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVITE ³ Autor ³ Emilton               ³ Data ³ 17/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta valores para avaliacao particular para o fechamento ³±±
±±³          ³      pelo fato de ser necessario ler dois arquivos VSY/VSZ  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1=Tipo de Levantamento (1=Orcamento / 2=Ordem de Servico)    ³±±
±±³          ³2=Numero do Orcamento ou Ordem de Servico                    ³±±
±±³          ³3=Campo a Pesquisar o Valor                                  ³±±
±±³          ³4=Campo a Pesquisar o Valor                                  ³±±
±±³          ³5=Tipo de Tempo (So qdo for Ordem de Servico)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIOM160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_LEVITE(cTipLev,cNumChv,cContChv,cNomCpo,cTipTmp)

Local nValRet  := 0
Local cNomCpoL := "VSY_"+cNomCpo

If cTipLev == "1"
	
	DbSelectArea("VSY")
	If DbSeek(xFilial("VSY")+cNumChv)
		Do While !EOF() .and. VSY->VSY_FILIAL == xFilial("VSY") .and. &("VSY->VSY_"+cContChv) == cNumChv
			If cNomCpo == "TOTMFR"
				nValRet := nValRet + VSY_VMFVDA
			Else
				nValRet := nValRet + &cNomCpoL
			EndIf
			DbSkip()
		EndDo
	Endif
	cNomCpol := "VSZ_"+cNomCpo
	DbSelectArea("VSZ")
	If DbSeek(xFilial("VSZ")+cNumChv)
		Do While !EOF() .and. VSZ->VSZ_FILIAL == xFilial("VSZ") .and. &("VSZ->VSZ_"+cContChv) == cNumChv
			If cNomCpo == "TOTMFR"
				nValRet := nValRet + VSZ_VMFSER
			Else
				nValRet := nValRet + &cNomCpoL
			EndIf
			DbSkip()
		EndDo
	Endif
	
Else
	
	DbSelectArea("VSY")
	If DbSeek(xFilial("VSY")+cNumChv)
		Do While !EOF() .and. VSY->VSY_FILIAL == xFilial("VSY") .and. &("VSY->VSY_"+cContChv) == cNumChv
			If cNomCpo == "TOTMFR"
				nValRet := nValRet + VSY_VMFVDA
			Else
				nValRet := nValRet + &cNomCpoL
			EndIf
			DbSkip()
		EndDo
	Endif
	cNomCpol := "VSZ_"+cNomCpo
	DbSelectArea("VSZ")
	If DbSeek(xFilial("VSZ")+cNumChv)
		Do While !EOF() .and. VSZ->VSZ_FILIAL == xFilial("VSZ") .and. &("VSZ->VSZ_"+cContChv) == cNumChv
			If cNomCpo == "TOTMFR"
				nValRet := nValRet + VSZ_VMFSER
			Else
				nValRet := nValRet + &cNomCpoL
			EndIf
			DbSkip()
		EndDo
	Endif
	
Endif

Return(nValRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GRAAVA ³ Autor ³ Emilton               ³ Data ³ 15/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava arquivos "ponte" para realizacao da avaliacao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIOM160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAAVA(cNumIde)

Local nRazIte   := 0
Local ixx       := 0
Local nVlrInt   := 0
Local aVetTra   := {}
Local aColsCbkp := {}
Local ixi		:= 0

aColsCbkp := aClone(aColsC)
Do Case
	Case cParam01 == 1
		
		FG_SEEK("VV1","VO1->VO1_CHAINT",1,.f.)
		FG_SEEK("VO5","VO1->VO1_CHAINT",1,.f.)
		FG_SEEK("VE4","VO1->VO1_CODMAR",1,.f.)
		FG_SEEK("VOI","VE4->VE4_TEMINT",1,.f.)
		nVlrInt := VOI->VOI_VALHOR
		
		For ixx := 1 to len(aVetTTp)
			If aVetTTp[ixx,01]
				lRetFech := .t.
				exit
			EndIf
		Next
		
		cKeyAce := aVetTTp[ixx,03]
		FG_SEEK("VOI","cKeyAce",1,.f.)
		cKeyAce := __cUserID
		FG_SEEK("VAI","cKeyAce",4,.f.)
		FG_SEEK("SA3","VAI->VAI_CODVEN")
		
		cComCon := FS_COMCON(VOI->VOI_TIPTEM)
		
		For ixx := 1 to Len(aColsFEC[2])
			
			If Empty(aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)])
				Exit
			EndIf
			
			DbSelectArea("SB1")
			DbSetOrder(7)
			DbSeek(xFilial("SB1")+aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsfec[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)])
			DbSelectArea("SB2")
			DbSeek(xFilial("SB2")+SB1->B1_COD)
			
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+aColsFEC[2,ixx,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)]))
			
			
			DbSelectArea("VSY")
			
			If !RecLock("VSY",.t.)
				Help("  ",1,"REGNLOCK")
				lRetFech := .f.
				DisarmTransaction()
				Break
			EndIf
			
			aPisCof := CalcPisCofSai(aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)])
			
			VSY_FILIAL := xFilial("VSY")
			VSY_NUMIDE := cNumIde
			VSY_TIPTEM := VOI->VOI_TIPTEM
			VSY_DATVEN := dDataBase
			&&VSY_NUMOSV := aVetTTp[ixx,02]
			VSY_NUMOSV := VO1->VO1_NUMOSV
			VSY_GRUITE := aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
			VSY_CODITE := aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
			VSY_PECINT := SB1->B1_COD
			VSY_QTDITE := aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]
			VSY_VALBRU := If(VOI->VOI_SITTPO != "3",aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)],0)
			VSY_VALDES := If(VOI->VOI_SITTPO != "3",aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)],0)
			VSY_VALVDA := If(VOI->VOI_SITTPO != "3",aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)],0)
			VSY_VALICM := aColsFEC[2,ixx,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)]
			VSY_ALQICM := aColsFEC[2,ixx,FS_POSVAR("VO3_ALQICM","aHeaderFEC",2)]
			VSY_VALCOF := aPisCof[1,2] //aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] * nAliCof
			VSY_VALPIS := aPisCof[1,1] //aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] * nAliPis
			VSY_TOTIMP := VSY_VALICM + VSY_VALCOF + VSY_VALPIS
			VSY_CUSMED := SB1->B1_CUSTD * VSY_QTDITE
			VSY_JUREST := FG_JUREST(,SB1->B1_COD,SB1->B1_UCOM,dDataBase,"P")
			VSY_CUSTOT := VSY_CUSMED + VSY_JUREST
			VSY_LUCBRU := VSY_VALVDA - VSY_TOTIMP - VSY_CUSTOT
			aVetTra    := aClone(aBoqPec)
			
			Do Case
				
				Case cComCon == "1"
					
					aAdd(aVetTra,{VO1->VO1_FUNABE,0})
					
				Case cComCon == "2"
					
					aAdd(aVetTra,{VAI->VAI_CODTEC,0})
					
				Case cComCon == "3"
					
					aAdd(aVetTra,{VO1->VO1_FUNABE,0})
					aAdd(aVetTra,{VAI->VAI_CODTEC,0})
					
			EndCase
			
			aValCom    := FG_COMISS("P",aVetTra,VSY_DATVEN,VSY_GRUITE,VSY_VALVDA,"T")
			VSY_COMVEN := aValCom[1]
			VSY_COMGER := aValCom[2]
			
			VSY_DESVAR := VSY_COMVEN + VSY_COMGER
			VSY_LUCLIQ := VSY_LUCBRU - VSY_DESVAR
			VSY_DESFIX := 0
			VSY_CUSFIX := 0
			VSY_DESDEP := 0
			VSY_DESADM := 0
			VSY_RESFIN := VSY_LUCLIQ - VSY_DESFIX - VSY_CUSFIX - VSY_DESDEP - VSY_DESADM
			VSY_BALOFI := "O" && Oficina
			If VOI->VOI_SITTPO == "3"
				VSY_DEPVEN := aColsFEC[2,ixx,FS_POSVAR("VO3_DEPINT","aHeaderFEC",2)]
			EndIf
			If VOI->VOI_SITTPO == "2"
				VSY_DEPVEN := aColsFEC[2,ixx,FS_POSVAR("VO3_DEPGAR","aHeaderFEC",2)]
			EndIf
			
			nRazIte := VSY_VALBRU / (nTotTTp+M->VSF_DESACE)
			
			VSY_VMFBRU := FG_CALCMF(FG_RETVDCP(,,"S",nTotTTp+M->VSF_DESACE)) * nRazIte
			VSY_VMFVDA := VSY_VMFBRU - FG_CALCMF( {{dDataBase,VSY_VALDES}} )
			VSY_VMFICM := FG_CALCMF( { {FG_RTDTIMP("ICM",dDataBase),VSY_VALICM} })
			VSY_VMFPIS := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VSY_VALPIS} })
			VSY_VMFCOF := FG_CALCMF( { {FG_RTDTIMP("COF",dDataBase),VSY_VALCOF} })
			VSY_TMFIMP := VSY_VMFICM + VSY_VMFCOF + VSY_VMFPIS
			
			VSY_CMFMED := FG_CALCMF( { {dDataBase,SB1->B1_CUSTD} }) * VSY_QTDITE
			VSY_JMFEST := FG_CALCMF( { {dDataBase,VSY_JUREST} })
			VSY_CMFTOT := VSY_CMFMED + VSY_JMFEST
			VSY_LMFBRU := VSY_VMFVDA - VSY_TMFIMP - VSY_CMFTOT
			
			aValCom    := FG_COMISS("P",aVetTra,VSY_DATVEN,VSY_GRUITE,VSY_VALVDA,"D")
			VSY_CMFVEN := FG_CALCMF(aValCom[1])
			VSY_CMFGER := FG_CALCMF(aValCom[2])
			VSY_DMFVAR := VSY_CMFVEN + VSY_CMFGER
			VSY_LMFLIQ := VSY_LMFBRU - VSY_DMFVAR
			VSY_DMFFIX := 0
			VSY_CMFFIX := 0
			VSY_CMFDEP := 0
			VSY_DMFADM := 0
			VSY_RMFFIN := VSY_LMFLIQ - VSY_DMFFIX - VSY_CMFFIX - VSY_DMFDEP - VSY_DMFADM
			
			MsUnlock()
			
			If ExistBlock("OX001VEC") // Ponto de Entrada para Atualizacao dos campos referentes ao ST (VSY_ICMSST + VSY_DCLBST + VSY_COPIST)
				ExecBlock("OX001VEC",.f.,.f.,{VSY_PECINT,VSY_DATVEN,aColsFEC[2,ixx,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)],0,VSY_QTDITE,"VSY"})
			EndIf
			
		Next
		
		cComCon := FS_COMCON(VOI->VOI_TIPTEM)
		aVetTra := {}
		
		For ixi := 1 to Len(aVetMec)
			
			dbSelectArea("VO4")
			dbGoTo(aVetMec[ixi,19])
			
			If !RecLock("VO4",.f.)
				Help("  ",1,"REGNLOCK")
				lRetFech := .f.
				DisarmTransaction()
				Break
			EndIf
			
			&& Levanta o valor da hora interna
			VO2->(DbSetOrder(2))
			VO2->(DbSeek(xFilial("VO2")+VO4->VO4_NOSNUM))
			nVlrInt := FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
			
			ix1 := aScan(aColsFEC[4],{ |x| x[FS_POSVAR("VO4_CODSER","aHeaderFEC",4)] == aVetMec[ixi,03] } )
			
			cKeyAce := aVetMec[ixi,02]
			FG_SEEK("VOK","cKeyAce",1,.f.)
			FG_SEEK("SB1","VOK->VOK_GRUITE+VOK->VOK_CODITE",7,.f.)
			cKeyAce := FG_MARSRV(VO1->VO1_CODMAR,aVetMec[ixi,03])+aVetMec[ixi,03]
			FG_SEEK("VO6","cKeyAce",2,.f.)
			
			Do Case
				Case VOK->VOK_INCTEM $ "124"
					
					VO4->VO4_TEMVEN := VO4->VO4_TEMPAD
					VO4->VO4_TEMCOB := aVetMec[ixi,20]
					
				Case VOK->VOK_INCTEM == "3"
					
					VO4->VO4_TEMVEN := VO4->VO4_TEMTRA
					VO4->VO4_TEMCOB := VO4->VO4_TEMTRA
					
			EndCase
			
			If VOI->VOI_SITTPO == "3"            && Tipo de Tempo Interno
				If VOK->VOK_INCMOB $ "1/3/4"
					If VOK->VOK_INCTEM $ "1/2/3/4" && Fabrica/Concessionaria/Informado/Trabalhado
						VO4->VO4_VALINT := (nVlrInt * (aVetMec[ixi,05]/100)) * aVetMec[ixi,10]
					EndIf
				ElseIf VOK->VOK_INCMOB == "2" // Servicos de Terceiros
					VO4->VO4_VALINT := VO4->VO4_VALCUS
				EndIf
			EndIf
			
			MsUnlock()
			
			DbSelectArea("VSZ")
			
			If !RecLock("VSZ",.t.)
				Help("  ",1,"REGNLOCK")
				lRetFech := .f.
				DisarmTransaction()
				Break
			EndIf
			
			VSZ_FILIAL := xFilial("VSZ")
			VSZ_NUMIDE := cNumIde
			ConfirmSx8()
			VSZ_SERINT := VO6->VO6_SERINT
			VSZ_NUMOSV := aVetMec[ixi,01]
			VSZ_CODSER := aVetMec[ixi,03]
			VSZ_TIPSER := aVetMec[ixi,02]
			VSZ_TIPTEM := VOO->VOO_TIPTEM
			VSZ_MODVEI := VV1->VV1_MODVEI
			VSZ_TEMPAD := aVetMec[ixi,05]
			VSZ_TEMTRA := aVetMec[ixi,06]
			VSZ_TEMCOB := VO4->VO4_TEMCOB
			VSZ_TEMVEN := VO4->VO4_TEMVEN
			VSZ_GRUSER := aColsFEC[4,ix1,FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)]
			VSZ_CODPRO := aVetMec[ixi,04]
			VSZ_CODSEC := ""
			VSZ_DATVEN := dDataBase
			aVetTra := {}
			
			If !(VOK->VOK_INCMOB $ "2,6")
				aAdd(aVetTra,{aVetMec[ixi,04],0})
			EndIf
			
			Do Case
				Case cComCon == "1"
					aAdd(aVetTra,{VO1->VO1_FUNABE,0})
				Case cComCon == "2"
					aAdd(aVetTra,{VAI->VAI_CODTEC,0})
				Case cComCon == "3"
					aAdd(aVetTra,{VO1->VO1_FUNABE,0})
					aAdd(aVetTra,{VAI->VAI_CODTEC,0})
			EndCase
			
			If VOI->VOI_SITTPO == "3"            && Tipo de Tempo Interno
				
				Do Case
					Case VOK->VOK_INCMOB == "0"    && Mao-de-Obra Gratuita
						
						VSZ_VALBRU := 0
						VSZ_VALDES := 0
						VSZ_VALSER := 0
						VSZ_CUSSER := FS_CUSDIR(VSZ_CODPRO,dDataBase - 30,VSC_TEMTRA) + FS_CUSIND(dDataBase - 30,VSZ_TEMTRA)
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"T",VSZ_NUMIDE)
						VSZ_COMVEN := aValCom[1]
						VSZ_COMGER := aValCom[2]
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"D",VSZ_NUMIDE)
						VSZ_CMFVEN := FG_CALCMF(aValCom[1])
						VSZ_CMFGER := FG_CALCMF(aValCom[2])
						
					Case VOK->VOK_INCMOB == "1"    && Por Mao-de-Obra
						
						&& Para Tipo de Tempo Interno a comissao sera paga apenas para o mecanico
						&& Podendo ser alterado para os demais no futuro
						VSZ_VALBRU := 0
						VSZ_VALDES := 0
						VSZ_VALSER := 0
						VSZ_CUSSER := FS_CUSDIR(VSZ_CODPRO,dDataBase - 30,VSZ_TEMTRA) + FS_CUSIND(dDataBase - 30,VSZ_TEMTRA)
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"T",VSZ_NUMIDE)
						VSZ_COMVEN := aValCom[1]
						VSZ_COMGER := aValCom[2]
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"D",VSZ_NUMIDE)
						VSZ_CMFVEN := FG_CALCMF(aValCom[1])
						VSZ_CMFGER := FG_CALCMF(aValCom[2])
						
					Case VOK->VOK_INCMOB == "2"    && Nao pagar comissao para servico de terceiro em OS Interna
						
						VSZ_VALBRU := 0
						VSZ_VALDES := 0
						VSZ_VALSER := 0
						VSZ_CUSSER := VO4->VO4_VALCUS
						aVetTra := {}
						
					Case VOK->VOK_INCMOB == "3"    && Valor Livre com Base na Tabela
						
						&& Para Tipo de Tempo Interno a comissao sera paga apenas para o mecanico
						&& Podendo ser alterado para os demais no futuro
						VSZ_VALBRU := 0
						VSZ_VALDES := 0
						VSZ_VALSER := 0
						VSZ_CUSSER := FS_CUSDIR(VSZ_CODPRO,dDataBase - 30,VSZ_TEMTRA) + FS_CUSIND(dDataBase - 30,VSZ_TEMTRA)
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"T",VSZ_NUMIDE)
						VSZ_COMVEN := aValCom[1]
						VSZ_COMGER := aValCom[2]
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"D",VSZ_NUMIDE)
						VSZ_CMFVEN := FG_CALCMF(aValCom[1])
						VSZ_CMFGER := FG_CALCMF(aValCom[2])
						
					Case VOK->VOK_INCMOB == "4"  && Re-Servico, tirara comissao do executor inicial e atribuira para o executor deste momento
						&& Aqui o sistema podera gerar comissao negativa para o mecanico que executou o servico com defeito e
						&& transferir a comissao para o mecanico que esta executando o re-servico
						
					Case VOK->VOK_INCMOB == "5"  && Socorro
						
						VSZ_KILROD := aColsFEC[4,ix1,FS_POSVAR("VO4_KILROD","aHeaderFEC",4)]
						
					Case VOK->VOK_INCMOB == "6"    && Franquia
						
						VSZ_VALBRU := 0
						VSZ_VALDES := 0
						VSZ_VALSER := 0
						VSZ_CUSSER := VO4->VO4_VALCUS
						aVetTra := {}
						
				EndCase
				
			Else             && Tipo de Tempo NAO Interno
				
				Do Case
					Case VOK->VOK_INCMOB == "0"    && Mao-de-Obra Gratuita
						
						VSZ_VALBRU := 0
						VSZ_VALDES := 0
						VSZ_VALSER := 0
						VSZ_CUSSER := FS_CUSDIR(VSZ_CODPRO,dDataBase - 30,VSZ_TEMTRA) + FS_CUSIND(dDataBase - 30,VSZ_TEMTRA)
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"T",VSZ_NUMIDE)
						VSZ_COMVEN := aValCom[1]
						VSZ_COMGER := aValCom[2]
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"D",VSZ_NUMIDE)
						VSZ_CMFVEN := FG_CALCMF(aValCom[1])
						VSZ_CMFGER := FG_CALCMF(aValCom[2])
						
					Case VOK->VOK_INCMOB == "1"    && Por Mao-de-Obra
						
						VSZ_VALBRU := aVetMec[ixi,14]
						VSZ_VALDES := aVetMec[ixi,14] - aVetMec[ixi,15]
						VSZ_VALSER := aVetMec[ixi,15]
						VSZ_CUSSER := FS_CUSDIR(VSZ_CODPRO,dDataBase - 30,VSZ_TEMTRA) + FS_CUSIND(dDataBase - 30,VSZ_TEMTRA)
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"T",VSZ_NUMIDE)
						VSZ_COMVEN := aValCom[1]
						VSZ_COMGER := aValCom[2]
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"D",VSZ_NUMIDE)
						VSZ_CMFVEN := FG_CALCMF(aValCom[1])
						VSZ_CMFGER := FG_CALCMF(aValCom[2])
						
					Case VOK->VOK_INCMOB == "2"    && Servico de Terceiro
						
						VSZ_VALBRU := aVetMec[ixi,14]
						VSZ_VALDES := aVetMec[ixi,14] - aVetMec[ixi,15]
						VSZ_VALSER := aVetMec[ixi,15]
						VSZ_CUSSER := VO4->VO4_VALCUS
						If VOK->VOK_CMSR3R == "1" && Pagar comissao sobre Servico de Terceiro
							aValCom    := FG_COMISS("S",aVetTra,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"T",VSZ_NUMIDE)
							VSZ_COMVEN := aValCom[1]
							VSZ_COMGER := aValCom[2]
							aValCom    := FG_COMISS("S",aVetTra,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"D",VSZ_NUMIDE)
							VSZ_CMFVEN := FG_CALCMF(aValCom[1])
							VSZ_CMFGER := FG_CALCMF(aValCom[2])
						EndIf
						
					Case VOK->VOK_INCMOB == "3"    && Valor Livre com Base na Tabela
						
						VSZ_VALBRU := aVetMec[ixi,14]
						VSZ_VALDES := aVetMec[ixi,14] - aVetMec[ixi,15]
						VSZ_VALSER := aVetMec[ixi,15]   && Se for interno este valor sera zero
						VSZ_CUSSER := FS_CUSDIR(VSZ_CODPRO,dDataBase - 30,VSZ_TEMTRA) + FS_CUSIND(dDataBase - 30,VSZ_TEMTRA)
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"T",VSZ_NUMIDE)
						VSZ_COMVEN := aValCom[1]
						VSZ_COMGER := aValCom[2]
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"D",VSZ_NUMIDE)
						VSZ_CMFVEN := FG_CALCMF(aValCom[1])
						VSZ_CMFGER := FG_CALCMF(aValCom[2])
						
					Case VOK->VOK_INCMOB == "4"  && Re-Servico, tirara comissao do executor inicial e atribuira para o executor deste momento
						&& Aqui o sistema podera gerar comissao negativa para o mecanico que executou o servico com defeito e
						&& transferir a comissao para o mecanico que esta executando o re-servico
						
					Case VOK->VOK_INCMOB == "5"  && Socorro
						
						VSZ_KILROD := aColsFEC[4,ix1,FS_POSVAR("VO4_KILROD","aHeaderFEC",4)]
						
					Case VOK->VOK_INCMOB == "6"    && Franquia
						
						VSZ_VALBRU := aVetMec[ixi,14]
						VSZ_VALDES := aVetMec[ixi,14] - aVetMec[ixi,15]
						VSZ_VALSER := aVetMec[ixi,15]
						VSZ_CUSSER := VO4->VO4_VALCUS
						
				EndCase
				
			EndIf
			
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+VOI->VOI_CODTES))
			aPisCof := CalcPisCofSai(VSZ->VSZ_VALSER)
			
			VSZ_VALISS := VSZ_VALSER * (SB1->B1_ALIQISS / 100)
			VSZ_VALPIS := aPisCof[1,1] //VSZ_VALSER * nAliPis
			VSZ_VALCOF := aPisCof[1,2] //VSZ_VALSER * nAliCof
			VSZ_TOTIMP := VSZ_VALISS + VSZ_VALCOF + VSZ_VALPIS
			VSZ_CUSTOT := VSZ_CUSSER
			VSZ_DESVAR := VSZ_COMVEN + VSZ_COMGER
			VSZ_LUCBRU := VSZ_VALSER - VSZ_TOTIMP - VSZ_CUSTOT
			VSZ_LUCLIQ := VSZ_LUCBRU - VSZ_DESVAR
			VSZ_DESFIX := 0
			VSZ_CUSFIX := 0
			VSZ_DESADM := 0
			VSZ_DESDEP := 0
			VSZ_RECVO4 := strzero(aVetMec[ixi,19],9)
			VSZ_CODMAR := VO1->VO1_CODMAR
			VSZ_RESFIN := VSZ_LUCLIQ - VSZ_CUSFIX - VSZ_DESFIX - VSZ_DESDEP - VSZ_DESADM
			
			nRazIte := VSZ_VALBRU / (nTotTTp+M->VSF_DESACE)
			
			VSZ_VMFBRU := FG_CALCMF(FG_RETVDCP(,,"S",nTotTTp+M->VSF_DESACE)) * nRazIte
			VSZ_VMFSER := VSZ_VMFBRU - FG_CALCMF( {{dDataBase,VSZ_VALDES}} )
			VSZ_VMFISS := FG_CALCMF({{FG_RTDTIMP("ISS",dDataBase),VSZ_VALISS}})
			VSZ_VMFPIS := FG_CALCMF({{FG_RTDTIMP("PIS",dDataBase),VSZ_VALPIS}})
			VSZ_VMFCOF := FG_CALCMF({{FG_RTDTIMP("COF",dDataBase),VSZ_VALCOF}})
			
			VSZ_TMFIMP := VSZ_VMFPIS + VSZ_VMFISS + VSZ_VMFCOF
			VSZ_CMFSER := FG_CALCMF( { {dDataBase,VSZ_CUSSER} })
			VSZ_CMFTOT := VSZ_CMFSER
			VSZ_LMFBRU := VSZ_VMFSER - VSZ_TMFIMP - VSZ_CMFSER
			
			VSZ_DMFVAR := VSZ_CMFVEN + VSZ_CMFGER
			VSZ_LMFLIQ := VSZ_LMFBRU - VSZ_DMFVAR
			VSZ_CMFFIX := 0
			VSZ_DMFFIX := 0
			VSZ_DMFADM := 0
			VSZ_DMFDEP := 0
			VSZ_RMFFIN := VSZ_LMFLIQ - VSZ_CMFFIX - VSZ_DMFFIX - VSZ_DMFADM - VSZ_DMFDEP
			VSZ_DEPINT := VO4->VO4_DEPINT
			VSZ_DEPGAR := VO4->VO4_DEPGAR
			
			FG_SEEK("VO6","FG_MARSRV(VSC->VSC_CODMAR,VSC->VSC_CODSER)+VSC->VSC_CODSER",2,.f.)
			
			VSZ_SERINT := VO6->VO6_SERINT
			MsUnlock()
			
		Next
		
	Case cParam01 == 2
		
		cKeyAce := __cUserID
		FG_SEEK("VAI","cKeyAce",4,.f.)
		FG_SEEK("SA3","VAI->VAI_CODVEN")
		
		cComCon := FS_COMCON(cParam04)
		
		For ixx := 1 to Len(aArrPec)
			
			DbSelectArea("SB1")
			DbSetOrder(7)
			DbSeek(xFilial("SB1")+aArrPec[ixx,02]+aArrPec[ixx,03])
			DbSelectArea("SB2")
			DbSeek(xFilial("SB2")+SB1->B1_COD)
			
			ix1 := aScan(aColsFEC[2],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] == aArrPec[ixx,02]+aArrPec[ixx,03] } )
			
			DbSelectArea("VSY")
			
			If !RecLock("VSY",.t.)
				Help("  ",1,"REGNLOCK")
				lRetFech := .f.
				DisarmTransaction()
				Break
			EndIf
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+aColsFEC[2,ix1,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)]))
			
			aPisCof := CalcPisCofSai((aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]) * aArrPec[ixx,04] )
			
			VSY_FILIAL := xFilial("VSY")
			VSY_NUMIDE := cNumIde
			VSY_GRUITE := aColsFEC[2,ix1,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
			VSY_CODITE := aColsFEC[2,ix1,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
			VSY_PECINT := SB1->B1_COD
			VSY_QTDITE := aArrPec[i,04] && aColsFEC[2,i,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]
			VSY_VALBRU := If(VOI->VOI_SITTPO != "3",(aColsFEC[2,ix1,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]) * aArrPec[ixx,04],0)
			VSY_VALDES := If(VOI->VOI_SITTPO != "3",(aColsFEC[2,ix1,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]) * aArrPec[ixx,04],0)
			VSY_VALVDA := If(VOI->VOI_SITTPO != "3",(aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]) * aArrPec[ixx,04],0)
			VSY_VALICM := (aColsFEC[2,ix1,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)] / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]) * aArrPec[ixx,04]
			VSY_ALQICM := aColsFEC[2,ix1,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)]
			VSY_VALCOF := aPisCof[1,2] //(aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]) * aArrPec[ixx,04] * nAliCof
			VSY_VALPIS := aPisCof[1,1] //(aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]) * aArrPec[ixx,04] * nAliPis
			VSY_TOTIMP := VSY_VALICM + VSY_VALCOF + VSY_VALPIS
			VSY_CUSMED := SB1->B1_CUSTD * VSY_QTDITE
			VSY_JUREST := FG_JUREST(,SB1->B1_COD,SB1->B1_UCOM,dDataBase,"P")
			VSY_CUSTOT := VSY_CUSMED + VSY_JUREST
			VSY_LUCBRU := VSY_VALVDA - VSY_TOTIMP - VSY_CUSTOT
			VSY_DATVEN := dDataBase
			aVetTra    := aClone(aBoqPec)
			
			Do Case
				
				Case cComCon == "1"
					&& Verificar quem e o consultor de abertura em os Agrupada !!
					aAdd(aVetTra,{VO1->VO1_FUNABE,0})
					
				Case cComCon == "2"
					&& Verificar quem e o consultor de abertura em os Agrupada !!
					aAdd(aVetTra,{VAI->VAI_CODTEC,0})
					
				Case cComCon == "3"
					
					aAdd(aVetTra,{VO1->VO1_FUNABE,0})
					aAdd(aVetTra,{VAI->VAI_CODTEC,0})
					
			EndCase
			
			aValCom    := FG_COMISS("P",aVetTra,VSY_DATVEN,VSY_GRUITE,VSY_VALVDA,"T")
			VSY_COMVEN := aValCom[1]
			VSY_COMGER := aValCom[2]
			VSY_DESVAR := VSY_COMVEN + VSY_COMGER
			VSY_LUCLIQ := VSY_LUCBRU - VSY_DESVAR
			VSY_DESFIX := 0
			VSY_CUSFIX := 0
			VSY_DESDEP := 0
			VSY_DESADM := 0
			VSY_RESFIN := VSY_LUCLIQ - VSY_DESFIX - VSY_CUSFIX - VSY_DESDEP - VSY_DESADM
			VSY_BALOFI := "O" // Oficina
			If VOI->VOI_SITTPO == "3"
				VSY_DEPVEN := aColsFEC[2,ix1,FS_POSVAR("VO3_DEPINT","aHeaderFEC",2)]
			EndIf
			If VOI->VOI_SITTPO == "2"
				VSY_DEPVEN := aColsFEC[2,ix1,FS_POSVAR("VO3_DEPGAR","aHeaderFEC",2)]
			EndIf
			VSY_TIPTEM := cParam04
			VSY_NUMOSV := aArrPec[ixx,01]
			
			nRazIte := VSY_VALBRU / (nTotTTp+M->VSF_DESACE)
			
			VSY_VMFBRU := FG_CALCMF(FG_RETVDCP(,,"S",nTotTTp+M->VSF_DESACE)) * nRazIte
			VSY_VMFVDA := VSY_VMFBRU - FG_CALCMF( {{dDataBase,VSY_VALDES}} )
			VSY_VMFICM := FG_CALCMF( { {FG_RTDTIMP("ICM",dDataBase),VSY_VALICM} })
			VSY_VMFPIS := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VSY_VALPIS} })
			VSY_VMFCOF := FG_CALCMF( { {FG_RTDTIMP("COF",dDataBase),VSY_VALCOF} })
			VSY_TMFIMP := VSY_VMFICM + VSY_VMFCOF + VSY_VMFPIS
			
			VSY_CMFMED := FG_CALCMF( { {dDataBase,SB1->B1_CUSTD} }) * VSY_QTDITE
			VSY_JMFEST := FG_CALCMF( { {dDataBase,VSY_JUREST} })
			VSY_CMFTOT := VSY_CMFMED + VSY_JMFEST
			VSY_LMFBRU := VSY_VMFVDA - VSY_TMFIMP - VSY_CMFTOT
			
			aValCom    := FG_COMISS("P",aVetTra,VSY_DATVEN,VSY_GRUITE,VSY_VALVDA,"D")
			VSY_CMFVEN := FG_CALCMF(aValCom[1])
			VSY_CMFGER := FG_CALCMF(aValCom[2])
			VSY_DMFVAR := VSY_CMFVEN + VSY_CMFGER
			VSY_LMFLIQ := VSY_LMFBRU - VSY_DMFVAR
			VSY_DMFFIX := 0
			VSY_CMFFIX := 0
			VSY_CMFDEP := 0
			VSY_DMFADM := 0
			VSY_RMFFIN := VSY_LMFLIQ - VSY_DMFFIX - VSY_CMFFIX - VSY_DMFDEP - VSY_DMFADM
			
			MsUnlock()
			If ExistBlock("OX001VEC") // Ponto de Entrada para Atualizacao dos campos referentes ao ST (VSY_ICMSST + VSY_DCLBST + VSY_COPIST)
				ExecBlock("OX001VEC",.f.,.f.,{VSY_PECINT,VSY_DATVEN,aColsFEC[2,ixx,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)],0,VSY_QTDITE,"VSY"})
			EndIf
			
		Next
		
		aVetTra := {}
		
		For ixi := 1 to Len(aVetMec)
			
			dbSelectArea("VO4")
			dbGoTo(aVetMec[ixi,19])
			
			If !RecLock("VO4",.f.)
				Help("  ",1,"REGNLOCK")
				lRetFech := .f.
				DisarmTransaction()
				Break
			EndIf
			
			&& Levanta o valor da hora interna
			VO2->(DbSetOrder(2))
			VO2->(DbSeek(xFilial("VO2")+VO4->VO4_NOSNUM))
			nVlrInt := FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
			
			ix1 := aScan(aColsFEC[4],{ |x| x[FS_POSVAR("VO4_CODSER","aHeaderFEC",4)] == aVetMec[ixi,03] } )
			
			cKeyAce := aVetMec[ixi,02]
			FG_SEEK("VOK","cKeyAce",1,.f.)
			FG_SEEK("SB1","VOK->VOK_GRUITE+VOK->VOK_CODITE",7,.f.)
			cKeyAce := FG_MARSRV(VO1->VO1_CODMAR,aVetMec[ixi,03])+aVetMec[ixi,03]
			FG_SEEK("VO6","cKeyAce",2,.f.)
			
			Do Case
				Case VOK->VOK_INCTEM $ "124"
					
					VO4->VO4_TEMVEN := VO4->VO4_TEMPAD
					VO4->VO4_TEMCOB := aVetMec[ixi,20]
					
				Case VOK->VOK_INCTEM == "3"
					
					VO4->VO4_TEMVEN := VO4->VO4_TEMTRA
					VO4->VO4_TEMCOB := VO4->VO4_TEMTRA
					
			EndCase
			
			If VOI->VOI_SITTPO == "3"            && Tipo de Tempo Interno
				If VOK->VOK_INCMOB $ "1/3/4"
					If VOK->VOK_INCTEM $ "1/2/3/4" && Fabrica/Concessionaria/Informado/Trabalhado
						VO4->VO4_VALINT := (nVlrInt * (aVetMec[ixi,05]/100)) * aVetMec[ixi,10]
					ElseIf VOK->VOK_INCMOB == "2" // Servicos de Terceiros
						VO4->VO4_VALINT := VO4->VO4_VALCUS
					EndIf
				EndIf
			EndIf
			
			MsUnlock()
			
			DbSelectArea("VSZ")
			
			If !RecLock("VSZ",.t.)
				Help("  ",1,"REGNLOCK")
				lRetFech := .f.
				DisarmTransaction()
				Break
			EndIf
			
			VSZ_FILIAL := xFilial("VSZ")
			VSZ_NUMIDE := cNumIde
			ConfirmSx8()
			VSZ_SERINT := VO6->VO6_SERINT
			VSZ_NUMOSV := aVetMec[ixi,01]
			VSZ_CODSER := aVetMec[ixi,03]
			VSZ_TIPSER := aVetMec[ixi,02]
			VSZ_TIPTEM := VOO->VOO_TIPTEM
			VSZ_MODVEI := VV1->VV1_MODVEI
			VSZ_TEMPAD := aVetMec[ixi,05]
			VSZ_TEMTRA := aVetMec[ixi,06]
			VSZ_TEMCOB := VO4->VO4_TEMCOB
			VSZ_TEMVEN := VO4->VO4_TEMVEN
			VSZ_GRUSER := aColsFEC[4,ix1,FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)]
			VSZ_CODPRO := aVetMec[ixi,04]
			VSZ_CODSEC := ""
			VSZ_DATVEN := dDataBase
			aVetTra := {}
			
			If !(VOK->VOK_INCMOB $ "2,6")
				aAdd(aVetTra,{aVetMec[ixi,04],0})
			EndIf
			
			Do Case
				Case cComCon == "1"
					aAdd(aVetTra,{VO1->VO1_FUNABE,0})
				Case cComCon == "2"
					aAdd(aVetTra,{VAI->VAI_CODTEC,0})
				Case cComCon == "3"
					aAdd(aVetTra,{VO1->VO1_FUNABE,0})
					aAdd(aVetTra,{VAI->VAI_CODTEC,0})
			EndCase
			
			If VOI->VOI_SITTPO == "3"            && Tipo de Tempo Interno
				
				Do Case
					Case VOK->VOK_INCMOB == "0"    && Mao-de-Obra Gratuita
						
						VSZ_VALBRU := 0
						VSZ_VALDES := 0
						VSZ_VALSER := 0
						VSZ_CUSSER := FS_CUSDIR(VSZ_CODPRO,dDataBase - 30,VSC_TEMTRA) + FS_CUSIND(dDataBase - 30,VSZ_TEMTRA)
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"T",VSZ_NUMIDE)
						VSZ_COMVEN := aValCom[1]
						VSZ_COMGER := aValCom[2]
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"D",VSZ_NUMIDE)
						VSZ_CMFVEN := FG_CALCMF(aValCom[1])
						VSZ_CMFGER := FG_CALCMF(aValCom[2])
						
					Case VOK->VOK_INCMOB == "1"    && Por Mao-de-Obra
						
						&& Para Tipo de Tempo Interno a comissao sera paga apenas para o mecanico
						&& Podendo ser alterado para os demais no futuro
						VSZ_VALBRU := 0
						VSZ_VALDES := 0
						VSZ_VALSER := 0
						VSZ_CUSSER := FS_CUSDIR(VSZ_CODPRO,dDataBase - 30,VSZ_TEMTRA) + FS_CUSIND(dDataBase - 30,VSZ_TEMTRA)
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"T",VSZ_NUMIDE)
						VSZ_COMVEN := aValCom[1]
						VSZ_COMGER := aValCom[2]
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"D",VSZ_NUMIDE)
						VSZ_CMFVEN := FG_CALCMF(aValCom[1])
						VSZ_CMFGER := FG_CALCMF(aValCom[2])
						
					Case VOK->VOK_INCMOB == "2"    && Nao pagar comissao para servico de terceiro em OS Interna
						
						VSZ_VALBRU := 0
						VSZ_VALDES := 0
						VSZ_VALSER := 0
						VSZ_CUSSER := VO4->VO4_VALCUS
						aVetTra := {}
						
					Case VOK->VOK_INCMOB == "3"    && Valor Livre com Base na Tabela
						
						&& Para Tipo de Tempo Interno a comissao sera paga apenas para o mecanico
						&& Podendo ser alterado para os demais no futuro
						VSZ_VALBRU := 0
						VSZ_VALDES := 0
						VSZ_VALSER := 0
						VSZ_CUSSER := FS_CUSDIR(VSZ_CODPRO,dDataBase - 30,VSZ_TEMTRA) + FS_CUSIND(dDataBase - 30,VSZ_TEMTRA)
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"T",VSZ_NUMIDE)
						VSZ_COMVEN := aValCom[1]
						VSZ_COMGER := aValCom[2]
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"D",VSZ_NUMIDE)
						VSZ_CMFVEN := FG_CALCMF(aValCom[1])
						VSZ_CMFGER := FG_CALCMF(aValCom[2])
						
					Case VOK->VOK_INCMOB == "4"  && Re-Servico, tirara comissao do executor inicial e atribuira para o executor deste momento
						&& Aqui o sistema podera gerar comissao negativa para o mecanico que executou o servico com defeito e
						&& transferir a comissao para o mecanico que esta executando o re-servico
						
					Case VOK->VOK_INCMOB == "5"  && Socorro
						
						VSZ_KILROD := aColsFEC[4,ix1,FS_POSVAR("VO4_KILROD","aHeaderFEC",4)]
						
					Case VOK->VOK_INCMOB == "6"    && Franquia
						
						VSZ_VALBRU := 0
						VSZ_VALDES := 0
						VSZ_VALSER := 0
						VSZ_CUSSER := VO4->VO4_VALCUS
						aVetTra := {}
						
				EndCase
				
			Else             && Tipo de Tempo NAO Interno
				
				Do Case
					Case VOK->VOK_INCMOB == "0"    && Mao-de-Obra Gratuita
						
						VSZ_VALBRU := 0
						VSZ_VALDES := 0
						VSZ_VALSER := 0
						VSZ_CUSSER := FS_CUSDIR(VSZ_CODPRO,dDataBase - 30,VSZ_TEMTRA) + FS_CUSIND(dDataBase - 30,VSZ_TEMTRA)
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"T",VSZ_NUMIDE)
						VSZ_COMVEN := aValCom[1]
						VSZ_COMGER := aValCom[2]
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VO4->VO4_VALINT,"D",VSZ_NUMIDE)
						VSZ_CMFVEN := FG_CALCMF(aValCom[1])
						VSZ_CMFGER := FG_CALCMF(aValCom[2])
						
					Case VOK->VOK_INCMOB == "1"    && Por Mao-de-Obra
						
						VSZ_VALBRU := aVetMec[ixi,14]
						VSZ_VALDES := aVetMec[ixi,14] - aVetMec[ixi,15]
						VSZ_VALSER := aVetMec[ixi,15]
						VSZ_CUSSER := FS_CUSDIR(VSZ_CODPRO,dDataBase - 30,VSZ_TEMTRA) + FS_CUSIND(dDataBase - 30,VSZ_TEMTRA)
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"T",VSZ_NUMIDE)
						VSZ_COMVEN := aValCom[1]
						VSZ_COMGER := aValCom[2]
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"D",VSZ_NUMIDE)
						VSZ_CMFVEN := FG_CALCMF(aValCom[1])
						VSZ_CMFGER := FG_CALCMF(aValCom[2])
						
					Case VOK->VOK_INCMOB == "2"    && Servico de Terceiro
						
						VSZ_VALBRU := aVetMec[ixi,14]
						VSZ_VALDES := aVetMec[ixi,14] - aVetMec[ixi,15]
						VSZ_VALSER := aVetMec[ixi,15]
						VSZ_CUSSER := VO4->VO4_VALCUS
						If VOK->VOK_CMSR3R == "1" && Pagar comissao sobre Servico de Terceiro
							aValCom    := FG_COMISS("S",aVetTra,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"T",VSZ_NUMIDE)
							VSZ_COMVEN := aValCom[1]
							VSZ_COMGER := aValCom[2]
							aValCom    := FG_COMISS("S",aVetTra,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"D",VSZ_NUMIDE)
							VSZ_CMFVEN := FG_CALCMF(aValCom[1])
							VSZ_CMFGER := FG_CALCMF(aValCom[2])
						EndIf
						
					Case VOK->VOK_INCMOB == "3"    && Valor Livre com Base na Tabela
						
						VSZ_VALBRU := aVetMec[ixi,14]
						VSZ_VALDES := aVetMec[ixi,14] - aVetMec[ixi,15]
						VSZ_VALSER := aVetMec[ixi,15]   && Se for interno este valor sera zero
						VSZ_CUSSER := FS_CUSDIR(VSZ_CODPRO,dDataBase - 30,VSZ_TEMTRA) + FS_CUSIND(dDataBase - 30,VSZ_TEMTRA)
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"T",VSZ_NUMIDE)
						VSZ_COMVEN := aValCom[1]
						VSZ_COMGER := aValCom[2]
						aValCom    := FG_COMISS("S",VSZ_CODPRO,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"D",VSZ_NUMIDE)
						VSZ_CMFVEN := FG_CALCMF(aValCom[1])
						VSZ_CMFGER := FG_CALCMF(aValCom[2])
						
					Case VOK->VOK_INCMOB == "4"  && Re-Servico, tirara comissao do executor inicial e atribuira para o executor deste momento
						&& Aqui o sistema podera gerar comissao negativa para o mecanico que executou o servico com defeito e
						&& transferir a comissao para o mecanico que esta executando o re-servico
						
					Case VOK->VOK_INCMOB == "5"  && Socorro
						
						VSZ_KILROD := aColsFEC[4,ix1,FS_POSVAR("VO4_KILROD","aHeaderFEC",4)]
						
					Case VOK->VOK_INCMOB == "6"    && Franquia
						
						VSZ_VALBRU := aVetMec[ixi,14]
						VSZ_VALDES := aVetMec[ixi,14] - aVetMec[ixi,15]
						VSZ_VALSER := aVetMec[ixi,15]
						VSZ_CUSSER := VO4->VO4_VALCUS
						
				EndCase
				
			EndIf
			
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+VOI->VOI_CODTES))
			aPisCof := CalcPisCofSai(VSZ->VSZ_VALSER)
			
			
			VSZ_VALISS := VSZ_VALSER * (SB1->B1_ALIQISS / 100)
			VSZ_VALPIS := aPisCof[1,1] //VSZ_VALSER * nAliPis
			VSZ_VALCOF := aPisCof[1,2] //VSZ_VALSER * nAliCof
			VSZ_TOTIMP := VSZ_VALISS + VSZ_VALCOF + VSZ_VALPIS
			VSZ_CUSTOT := VSZ_CUSSER
			VSZ_DESVAR := VSZ_COMVEN + VSZ_COMGER
			VSZ_LUCBRU := VSZ_VALSER - VSZ_TOTIMP - VSZ_CUSTOT
			VSZ_LUCLIQ := VSZ_LUCBRU - VSZ_DESVAR
			VSZ_DESFIX := 0
			VSZ_CUSFIX := 0
			VSZ_DESADM := 0
			VSZ_DESDEP := 0
			VSZ_RECVO4 := strzero(aVetMec[ixi,19],9)
			VSZ_CODMAR := VO1->VO1_CODMAR
			VSZ_RESFIN := VSZ_LUCLIQ - VSZ_CUSFIX - VSZ_DESFIX - VSZ_DESDEP - VSZ_DESADM
			
			nRazIte := VSZ_VALBRU / (nTotTTp+M->VSF_DESACE)
			
			VSZ_VMFBRU := FG_CALCMF(FG_RETVDCP(,,"S",nTotTTp+M->VSF_DESACE)) * nRazIte
			VSZ_VMFSER := VSZ_VMFBRU - FG_CALCMF( {{dDataBase,VSZ_VALDES}} )
			VSZ_VMFISS := FG_CALCMF({{FG_RTDTIMP("ISS",dDataBase),VSZ_VALISS}})
			VSZ_VMFPIS := FG_CALCMF({{FG_RTDTIMP("PIS",dDataBase),VSZ_VALPIS}})
			VSZ_VMFCOF := FG_CALCMF({{FG_RTDTIMP("COF",dDataBase),VSZ_VALCOF}})
			
			VSZ_TMFIMP := VSZ_VMFPIS + VSZ_VMFISS + VSZ_VMFCOF
			VSZ_CMFSER := FG_CALCMF( { {dDataBase,VSZ_CUSSER} })
			VSZ_CMFTOT := VSZ_CMFSER
			VSZ_LMFBRU := VSZ_VMFSER - VSZ_TMFIMP - VSZ_CMFSER
			
			VSZ_DMFVAR := VSZ_CMFVEN + VSZ_CMFGER
			VSZ_LMFLIQ := VSZ_LMFBRU - VSZ_DMFVAR
			VSZ_CMFFIX := 0
			VSZ_DMFFIX := 0
			VSZ_DMFADM := 0
			VSZ_DMFDEP := 0
			VSZ_RMFFIN := VSZ_LMFLIQ - VSZ_CMFFIX - VSZ_DMFFIX - VSZ_DMFADM - VSZ_DMFDEP
			VSZ_DEPINT := VO4->VO4_DEPINT
			VSZ_DEPGAR := VO4->VO4_DEPGAR
			
			FG_SEEK("VO6","FG_MARSRV(VSC->VSC_CODMAR,VSC->VSC_CODSER)+VSC->VSC_CODSER",2,.f.)
			
			VSZ_SERINT := VO6->VO6_SERINT
			MsUnlock()
			
		Next
		
	Case cParam01 == 3
		
		cKeyAce := __cUserID
		FG_SEEK("VAI","cKeyAce",4,.f.)
		FG_SEEK("SA3","VAI->VAI_CODVEN")
		
		cComCon := FS_COMCON(cParam04)
		
		For ixi:= 1 to Len(aColsFec[4])
			
			cKeyAce := aColsFEC[4,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
			FG_SEEK("VOK","cKeyAce",1,.f.)
			FG_SEEK("SB1","VOK->VOK_GRUITE+VOK->VOK_CODITE",7,.f.)
			FG_SEEK("VOI","cParam04",1,.f.)
			
			dbSelectArea("VSZ")
			If !RecLock("VSZ",.t.)
				Help("  ",1,"REGNLOCK")
				lRetFech := .f.
				DisarmTransaction()
				Break
			EndIf
			
			VSZ_FILIAL := xFilial("VSZ")
			VSZ_NUMIDE := cNumIde
			VSZ_CODSER := aColsFEC[4,ixi,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]
			VSZ_TIPSER := aColsFEC[4,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
			VSZ_TIPTEM := cParam04
			VSZ_KILROD := aColsFEC[4,ixi,FS_POSVAR("VO4_KILROD","aHeaderFEC",4)]
			VSZ_GRUSER := aColsFEC[4,ixi,FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)]
			VSZ_CODSEC := ""
			VSZ_DATVEN := dDataBase
			VSZ_VALBRU := aColsFEC[4,ixi,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]
			VSZ_VALDES := aColsFEC[4,ixi,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
			VSZ_VALSER := aColsFEC[4,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
			VSZ_VALISS := VSZ_VALSER * (SB1->B1_ALIQISS / 100)
			aPisCof := CalcPisCofASai(VSZ->VSZ_VALSER)
			VSZ_VALPIS := aPisCof[1,1] //VSZ_VALSER * nAliPis
			VSZ_VALCOF := aPisCof[1,2] //VSZ_VALSER * nAliCof
			VSZ_TOTIMP := VSZ_VALISS + VSZ_VALCOF + VSZ_VALPIS
			
			VSZ_RECLIQ := 0
			VSZ_CUSSER := 0       && Kilometragem nao tem custo
			VSZ_CUSTOT := 0       && Kilometragem nao tem custo
			VSZ_LUCBRU := VSZ_VALSER - VSZ_TOTIMP - VSZ_CUSSER
			
			//aAdd(aVetTra,{SA3->A3_COD,0})  // Consultor que abre é o mesmo que fecha
			aValCom    := FG_COMISS("S",SA3->A3_COD,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"T")
			VSZ_COMVEN := aValCom[1]
			VSZ_COMGER := aValCom[2]
			VSZ_DESVAR := VSZ_COMVEN + VSZ_COMGER
			VSZ_LUCLIQ := VSZ_LUCBRU - VSZ_DESVAR
			
			VSZ_DESFIX := 0
			VSZ_CUSFIX := 0
			VSZ_DESADM := 0
			VSZ_DESDEP := 0
			VSZ_RESFIN := VSZ_LUCLIQ - VSZ_DESFIX - VSZ_CUSFIX - VSZ_DESADM - VSZ_DESDEP
			VSZ_CODMAR := "XXX"
			
			FG_SEEK("VO6","FG_MARSRV(VSZ->VSZ_CODMAR,VSZ->VSZ_CODSER)+VSZ->VSZ_CODSER",2,.f.)
			
			VSZ_SERINT := VO6->VO6_SERINT
			VSZ_NUMOSV := "99999999"
			
			nRazIte := VSZ_VALBRU / (nTotTTp+M->VSF_DESACE)
			
			VSZ_VMFBRU := FG_CALCMF(FG_RETVDCP(,,"S",nTotTTp+M->VSF_DESACE)) * nRazIte
			VSZ_VMFSER := VSZ_VMFBRU - FG_CALCMF({ {dDataBase,VSZ_VALDES} })
			VSZ_VMFISS := FG_CALCMF({{FG_RTDTIMP("ISS",dDataBase),VSZ_VALISS}})
			VSZ_VMFPIS := FG_CALCMF({{FG_RTDTIMP("PIS",dDataBase),VSZ_VALPIS}})
			VSZ_VMFCOF := FG_CALCMF({{FG_RTDTIMP("COF",dDataBase),VSZ_VALCOF}})
			
			VSZ_TMFIMP := VSZ_VMFPIS + VSZ_VMFISS + VSZ_VMFCOF
			VSZ_CMFSER := FG_CALCMF( { {dDataBase,VSZ_CUSSER} })
			VSZ_CMFTOT := VSZ_CMFSER
			VSZ_LMFBRU := VSZ_VMFSER - VSZ_TMFIMP - VSZ_CMFTOT
			
			aValCom    := FG_COMISS("S",SA3->A3_COD,VSZ_DATVEN,VSZ_TIPTEM,VSZ_VALSER,"D",VSZ_NUMIDE)
			VSZ_CMFVEN := FG_CALCMF(aValCom[1])
			VSZ_CMFGER := FG_CALCMF(aValCom[2])
			
			VSZ_DMFVAR := VSZ_CMFVEN + VSZ_CMFGER
			VSZ_LMFLIQ := VSZ_LMFBRU - VSZ_DMFVAR
			VSZ_CMFFIX := 0
			VSZ_DMFFIX := 0
			VSZ_DMFADM := 0
			VSZ_DMFDEP := 0
			VSZ_RMFFIN := VSZ_LMFLIQ - VSZ_CMFFIX - VSZ_DMFFIX - VSZ_DMFADM - VSZ_DMFDEP
			
			MsUnlock()
			
		Next
		
EndCase

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_MOTVFB ºAutor  ³Fabio               º Data ³  05/23/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Movimenta arquivos de movimento do veiculo VFB              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MOVVFB(lOperacao)

If lOperacao
	// Grava Ocorrencia do Veiculo
	DbSelectArea("VFB")
	DbSetOrder(4)
	DbSeek(xFilial("VFB")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO+VO1->VO1_CHAINT+"S"+VO4->VO4_CODSER+Dtos(VO2->VO2_DATREQ)+VO1->VO1_NUMOSV)
	
	If !RecLock("VFB",!Found())
		Help("  ",1,"REGNLOCK")
		lRetFech := .f.
		DisarmTransaction()
		Break
	EndIf
	
	VFB->VFB_FILIAL := xFilial("VFB")
	VFB->VFB_CODCLI := VO4->VO4_FATPAR//VV1->VV1_PROATU
	VFB->VFB_LOJA   := VO4->VO4_LOJA //VV1->VV1_LJPATU
	VFB->VFB_CHAINT := VO1->VO1_CHAINT
	VFB->VFB_SERPEC := "S"
	VFB->VFB_NUMOSV := VO1->VO1_NUMOSV
	VFB->VFB_TIPTEM := VO4->VO4_TIPTEM
	VFB->VFB_DATAPL := dDataBase
	VFB->VFB_NUMREQ := VO2->VO2_NOSNUM
	VFB->VFB_KILOME := VO1->VO1_KILOME
	VFB->VFB_CODSER := VO4->VO4_CODSER
	MsUnlock()
	
Else
	
	DbSelectArea("VFB")
	DbSetOrder(4)
	DbSeek(xFilial("VFB")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO+VO1->VO1_CHAINT+"S"+VO4->VO4_CODSER+Dtos(VO2->VO2_DATREQ)+VO1->VO1_NUMOSV)
	
	If !RecLock("VFB",.f.,.t.)
		Help("  ",1,"REGNLOCK")
		lRetFech := .f.
		DisarmTransaction()
		Break
	EndIf
	
	dbdelete()
	MsUnlock()
	WriteSx2("VFB")
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILVF4  ³ Autor ³ Emilton               ³ Data ³ 20/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtra VF4                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FILVF4()
Local cFiltro := ""
cFiltro := "cParam02 == VF4->VF4_PROVEI .and. empty(VF4->VF4_NUMOSV)"
Return cFiltro


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_STATUS  ³ Autor ³ Emilton               ³ Data ³ 26/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza a Variavel VO1_STATUS e VO1_TEMDIS                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ Numero da Ordem de Servico                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_STATUS(cNumOSv,cTipTem,cOperacao)

Local cStatus := ""
Local aStatus := {}
Local nPos	  := 0

/*
aStatus[n,1] = Tipo de Tempo
aStatus[n,2] = Status do Tipo de Tempo
aStatus[n,3] = Saldo do Total das Pecas Req/Dev
aStatus[n,4] = Saldo do Total dos Servicos Req/Dev
*/

DbSelectArea("VO2")
DbSetOrder(1)
DbSeek( xFilial("VO2") + cNumOsv )

Do While !Eof() .And. VO2->VO2_FILIAL + VO2->VO2_NUMOSV == xFilial("VO2") + cNumOSv
	
	DbSelectArea("VO3")
	DbSetOrder(1)
	DbSeek( xFilial("VO3") + VO2->VO2_NOSNUM )
	
	Do While !Eof() .And. VO3->VO3_FILIAL + VO3->VO3_NOSNUM == xFilial("VO3") + VO2->VO2_NOSNUM
		
		nPos := aScan(aStatus,{ |x| x[1] = VO3->VO3_TIPTEM  })
		If nPos == 0
			aAdd(aStatus,{VO3->VO3_TIPTEM,"",0,0})
			nPos := Len(aStatus)
		Endif
		
		If VO2->VO2_DEVOLU == "1" //Requisicao
			aStatus[nPos,3] += VO3->VO3_QTDREQ
		Else
			aStatus[nPos,3] -= VO3->VO3_QTDREQ
		Endif
		
		aStatus[nPos,2] := "1"             && Aberta
		If !Empty(VO3->VO3_DATDIS)
			aStatus[nPos,2] := "2"          && Liberada
		EndIf
		If !Empty(VO3->VO3_DATFEC)
			aStatus[nPos,2] := "3"          && Fechada
		EndIf
		If !Empty(VO3->VO3_DATCAN)
			aStatus[nPos,2] := "4"          && Cancelada
		EndIf
		
		DbSelectArea("VO3")
		DbSkip()
		
	EndDo
	
	DbSelectArea("VO4")
	DbSetOrder(1)
	DbSeek( xFilial("VO4") + VO2->VO2_NOSNUM )
	
	While !Eof() .And. VO4->VO4_FILIAL + VO4->VO4_NOSNUM == xFilial("VO4") + VO2->VO2_NOSNUM
		
		nPos := aScan(aStatus,{ |x| x[1] = VO4->VO4_TIPTEM  })
		If nPos == 0
			aAdd(aStatus,{VO4->VO4_TIPTEM,"",0,0})
			nPos := Len(aStatus)
		Endif
		
		aStatus[nPos,4] += 1
		
		aStatus[nPos,2] := "1"             && Aberta
		If !Empty(VO4->VO4_DATCAN)
			aStatus[nPos,2] := "4"          && Cancelada
		ElseIf !Empty(VO4->VO4_DATFEC)
			aStatus[nPos,2] := "3"          && Fechada
		ElseIf !Empty(VO4->VO4_DATDIS)
			aStatus[nPos,2] := "2"          && Liberada
		EndIf
		
		DbSelectArea("VO4")
		DbSkip()
		
	EndDo
	
	DbSelectArea("VO2")
	DbSkip()
	
EndDo

If cOperacao == "D"  && Testando Disponibilidade
	
	cStatus := "N - "+STR0013
	If Len(aStatus) # 0 .And. Ascan(aStatus,{ |x| x[2] == "2" }) # 0
		
		cStatus := "S - "+STR0012
		
	EndIf
	
Else
	
	cStatus := "A - "+STR0004
	If Len(aStatus) # 0
		
		Asort(aStatus,,,{|x,y| x[2] < y[2] })
		
		For nPos := 1 to Len(aStatus)
			
			cStatus := "A - "+STR0004
			If aStatus[nPos,2] == "2"
				cStatus := "D - "+STR0005
			ElseIf aStatus[nPos,2] == "3"
				cStatus := "F - "+STR0006
			ElseIf aStatus[nPos,2] == "4"
				cStatus := "C - "+STR0007
			EndIf
			
			If ( aStatus[nPos,3] > 0 .Or. aStatus[nPos,4] > 0 )
				Exit
			ElseIf aStatus[nPos,3] <= 0
				
				If !lMsgStatus
					MsgYesNoTimer(STR0008+aStatus[nPos,1]+" "+Substr(cStatus,4)+STR0009+Chr(13)+STR0010+Substr(cStatus,4),OemToAnsi(STR0011))
				EndIf
				
				lMsgStatus := .T.
				Exit
				
			EndIf
			
		Next
		
	EndIf
	
EndIf

Return( Substr(cStatus,1,1) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_HABPRO  ³ Autor ³ Emilton               ³ Data ³ 14/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza data de fechamento no historico do veiculo          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_HABPRO()

If FG_SEEK("VOC","VO4->VO4_CODPRO+VV1->VV1_CODMAR+VO4->VO4_CODSER",1,.f.)
	
	dbSelectArea("VOC")
	
	If !RecLock("VOC",.f.)
		Help("  ",1,"REGNLOCK")
		lRetFech := .f.
		DisarmTransaction()
		Break
	EndIf
	
	VOC_QTDEXE := VOC_QTDEXE + 1
	MsUnlock()
	
EndIf

return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_VFBSRV  ³ Autor ³ Emilton               ³ Data ³ 14/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza data de fechamento no historico do veiculo          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cCodCli = Codigo do Cliente                                  ³±±
±±³          ³ cCodLoj = Codigo da Loja                                     ³±±
±±³          ³ cChaInt = Chassi Interno                                     ³±±
±±³          ³ cNumOsv = Numero da Ordem de Servico                         ³±±
±±³          ³ nKilome = Kilometragem da OS                                 ³±±
±±³          ³ cNumReq = Nosso Numero da Requisicao                         ³±±
±±³          ³ cTipVFB = Tipo de Historico                                  ³±±
±±³          ³ cTipTem = Tipo de Tempo                                      ³±±
±±³          ³ cTipSer = Codigo de Servico                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VFBSRV(cCodCli,cCodLoj,cChaInt,cNumOsv,nKilome,cNumReq,cTipVFB,cTipTem,cCodSer)

If cTipVFB != "K"
	
	cKeyAce := cCodCli+cCodLoj+cChaInt+cNumOsv+"S"
	
	dbSelectArea("VFB")
	If FG_SEEK("VFB","cKeyAce",3,.f.)
		
		while VFB_CODCLI+VFB_LOJA+VFB_CHAINT+VFB_NUMOSV+VFB_SERPEC == cKeyAce .and. VFB->VFB_FILIAL == xFilial("VFB") .and. !eof()
			
			Do Case
				Case cParam01 == 1
					If VFB_TIPTEM != cTipTem
						dbSkip()
						loop
					EndIf
				Case cParam01 == 2
					If VFB_TIPTEM != cTipTem
						dbSkip()
						loop
					EndIf
			EndCase
			If !RecLock("VFB",.f.)
				Return .f.
			EndIf
			
			VFB_DATFEC := dDataBase
			MsUnlock()
			dbSkip()
			
		EndDo
		
	EndIf
	
Else
	
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("VFB")
	While x3_Arquivo == "VFB" .and. !Eof()
		
		If !(X3_CAMPO $ "VFB_GRUITE/VFB_CODITE/VFB_ORDCRO/VFB_TIPREV/VFB_DESSER/VFB_DESGRU/VFB_DESITE/VFB_DESTEM/VFB_ORDCRO/VFB_TIPREV")
			&("M->"+x3_campo) := CriaVar(x3_campo)
		EndIf
		
		DbSelectArea("SX3")
		DbSkip()
		
	EndDo
	
	dbSelectArea("VFB")
	dbSetOrder(1)
	
	If !RecLock("VFB",.t.)
		Return .f.
	EndIf
	
	FG_GRAVAR("VFB")
	
	VFB->VFB_FILIAL := xFilial("VFB")
	VFB->VFB_QTDAPL := 1
	VFB->VFB_DATFEC := dDataBase
	VFB->VFB_DATAPL := dDataBase
	VFB->VFB_CODCLI := cCodCli
	VFB->VFB_LOJA   := cCodLoj
	VFB->VFB_CHAINT := cChaInt
	VFB->VFB_NUMOSV := cNumOsv
	VFB->VFB_SERPEC := "S"
	VFB->VFB_CODSER := cCodSer
	VFB->VFB_TIPTEM := cTipTem
	VFB->VFB_KILOME := nKilome
	***VFB->VFB_NUMREQ := cNumReq
	
	MsUnLock()
	
EndIf

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_VFBFEC  ³ Autor ³ Emilton               ³ Data ³ 14/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza data de fechamento no historico do veiculo          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cCodCli - Codigo do Cliente                                  ³±±
±±³          ³ cCodLoj - Codigo da Loja                                     ³±±
±±³          ³ cChaInt - Chassi Interno                                     ³±±
±±³          ³ cTipTem - Tipo de Tempo                                      ³±±
±±³          ³ cNumOsv - Numero da Ordem de Servico                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VFBPEC(cCodCli,cCodLoj,cChaInt,cTipTem,cNumOsv)

cKeyAce := cCodCli+cCodLoj+cChaInt+cNumOsv+"P"

dbSelectArea("VFB")
If FG_SEEK("VFB","cKeyAce",3,.f.)
	
	while VFB_CODCLI+VFB_LOJA+VFB_CHAINT+VFB_NUMOSV+VFB_SERPEC == cKeyAce .and. VFB->VFB_FILIAL == xFilial("VFB") .and. !eof()
		
		Do Case
			Case cParam01 == 1
				If VFB_TIPTEM != cTipTem
					dbSkip()
					loop
				EndIf
			Case cParam01 == 2
				If VFB_TIPTEM != cParam04
					dbSkip()
					loop
				EndIf
		EndCase
		If !RecLock("VFB",.f.)
			Return .f.
		EndIf
		
		VFB_DATFEC := dDataBase
		MsUnlock()
		dbSkip()
		
	EndDo
	
EndIf

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_FECHAR  ³ Autor ³ Emilton               ³ Data ³ 08/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa o Processo de Fechamento de Ordem de Servico         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FECHAR()
Local cSQL     := ""
Local nDia     := 0
Local lRetFin  := .f.
Local lSerie   := .F.
Local lIncluir := inclui
Local i := 0
Local nWnk := 0
Local cGCFOCEV := ""
Local lMsgSaiVei := .f. // Ja mostrou a Mensagem para registrar a Saida de Veiculo ????
Local ni := 0
Private lMsHelpAuto := .f.
Private lMsErroAuto := .f.
Private lLiberado := .f.
Private lRetFech      := .t.
Private aOSvCri   := {}
Private aIte      := {}
Private aFinanc   := {}
Private aParcelas := {}
Private aTitulos  := {}
Private aVetPar   := {}
Private aVetPer   := {}
Private aValCom   := {}
Private aValVF3   := {}
Private cMark     := GetMark()
Private bCodBlock := {|| SC9->C9_OK = cMark}
Private nSubTotal := 0  // Valida se a Entrada + Financiamento = Valor Total
Private ixa       := 0
Private ixi       := 0
Private ixy       := 0
Private ixx       := 0
Private cCont     := "00"
Private aVetSer   := {}
Private aVetTra   := {}
Private nVlrInt   := 0
Private nTotKil   := 0
Private nValKil   := 0
Private cChaAnt   := ""
Private cOsvAnt   := ""
Private nRazIte   := 0
Private nTotPcs   := 0
Private nTotSer   := 0
Private cContrato := 0
Private aColsSlvc
Private cComCon
Private aPvlNfs   := {}
Private cTipCob   := IIf(!Empty(cCodBco),"1","0")
Private cOrcLoja
// inicio crm
Private cCrmVei   := ""
Private nOpc := 1 // Luis - Compatibilidade com a função FG_CHKLIB
Private lCamposCrm:= .F.
Private cSerie    := IIf(nCheck==1,"",GetNewPar("MV_SERCUP","CUP"))
// fim crm
If cParam01 == 1  // Fechamento Individual (referencia1)
	If !FS_VTTPFEC(aVetTTp[oVetTTp:nAt,02],aVetTTp[oVetTTp:nAt,03])// Verifica se a OS/Tipo de Tempo ja esta Fechado/Cancelado
		Return .f.
	EndIf
EndIf
For i:=1 to Len(aIteParc)
	If aIteParc[i,2] <> 0
		If aIteParc[i,1] < ddatabase
			MsgAlert(STR0024,STR0011) // Data de vencimento da parcela nao pode ser menor que a data atual! - Atencao
			Return .f.
		EndIf
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para CHAMADA DE ALGUMA VALIDACAO EXTERNA		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("OFIM16ACHK") )
	lRetFech := ExecBlock("OFIM16ACHK",.F.,.F.,{VO1->VO1_NUMOSV})
	If !lRetFech
		return .f.
	EndIf
EndIf

//Salva negociacao de pagamento
If !FS_SALVA()
	Return(.f.)
EndIf

If left(aHeader[2,2],3) <> "VS9"
	aHeader := aClone(aHeaderC)
	aCols   := aClone(aColsC)
	n       := Len(aCols)
Endif

If !FS_VERTTP()
	Return .f.
EndIf

If cPaisLoc == "BRA" // Manoel - 13/05/2009
	
	If Empty(cTipPag)
		Help(" ",1,"M160TIPPAG")   // Falta Tipo de Pagamento
		Return .f.
	EndIf
	
	cKeyAce := cTipPag
	FG_SEEK("SE4","cKeyAce",1,.f.)
	
	If Substr(GetMv("MV_LOJAVEI",,"NNN"),2,1) == "N"	//Integrado com o Sigaloja ?
		If SE4->E4_TIPO == "A"
			If !Empty(cCodCDCI)
				If Empty(aIteParc[1,1])
					Help(" ",1,"M160CALPAR")   // As parcelas precisam ser calculadas
					Return .f.
				EndIf
			EndIf
		EndIf
	Endif
	
	For i:=1 to Len(aColsC)
		If !aColsC[i,Len(aColsC[i])] .and. !Empty(aColsC[i,1])
			nSubTotal := nSubtotal + aColsC[i,4]
		Endif
	Next
	
	For i:=1 to Len(aIteParc)
		nSubTotal := nSubtotal + aIteParc[i,2]
	Next
	
	If Empty(cCodCDCI)
		nValor := nTotTTP
		If nSubTotal <> nValor  .and. ABS(nSubTotal - nValor) > 0.01 //nTotTTp+M->VSF_DESACE
			Help(" ",1,"M160BATTOT")   // A soma da entrada e financiamento nao bate com o valor do fechamento
			Return .f.
		EndIf
	Endif
	
	if VOI->VOI_SITTPO <> "2"
		If Empty(GetMv("MV_CPNCLC")) .or. AllTrim(GetMv("MV_CPNCLC")) <> Alltrim(cTipPag)
			If "F" $ GetMv("MV_CHKCRE")
				If !MaAvalCred(SA1->A1_COD,SA1->A1_LOJA, M->VSF_DESACE+FG_AVALCRED(SA1->A1_COD, SA1->A1_LOJA) ,1,.T.)
					Help(" ",1,"LIMITECRED")
					Return .f.
				EndIf
			EndIf
		EndIf
	Endif
	lEntrada := .f.
	For nWnk := 1 to Len(aColsC)
		If !Empty(aColsC[nWnk,1]) .and. !aColsC[nWnk,Len(aColsC[nWnk])]
			lEntrada := .t.
			Exit
		Endif
	Next
	
	if lEntrada .and. !Empty(SA1->A1_TIPPER) .and. !Empty(cForPeri) .and. cForPeri == cTipPag
		MsgInfo(STR0014 ,STR0011 ) //Por se tratar de cliente periodico nao pode ser dada nenhuma entrada... # Atencao!
		Return( .f. )
	EndIf
	
	If !FS_OCHKLIB()
		Return .f.
	EndIf
	
EndIf

FS_SAIVEI(cParam01)

aCabPV  := {}
aItePV  := {}
aIte    := {}
cTipPed := "N"  // Saida Normal

If !MsgYesNo(OemToAnsi(STR0015),OemToAnsi(STR0011))// Confirma o Fechamento ? # Atencao !))
	Return .f.
Endif

If ExistBlock("OFM160A")                       // Ponto de Entrada Antes das Gravacoes
	If !ExecBlock("OFM160A",.f.,.f.)
		Return(.f.)
	EndIf
EndIf

// Verifica a situacao dos TT's ...
If !FS_VTTPSTAT()
	Return .f.
EndIf

If cPaisLoc == "BRA" // Manoel - 12/05/2009
	
	If Substr(GetMv("MV_LOJAVEI",,"NNN"),2,1) == "N"	//Integrado com o Sigaloja ?
		
		If !Empty(aColsFEC[2,1,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]) .Or. VOI->VOI_SITTPO # "3"  // Tipo de Tempo Interno
			
			lSerie := nCheck <> 1
			if nCheck == 1 //Nota Fiscal
				lSerie := Sx5NumNota(.T.,GetNewPar("MV_TPNRNFS","1"))
			Endif
			
		Else
			
			lSerie := .t.
			
		EndIf
		
		If lSerie == .F.
			
			MsgStop( STR0016 )	//Serie de Nota Fiscal invalida.
			
			SX5->(MsRUnLock())
			
			Return .f.
			
		Endif
		
	Endif
	
	lMsHelpAuto := .t.
	lMsErroAuto := .f.
	
	//Por mais estranho que pareca esta funcao deve ser chamada aqui, antes da transacao - nao mexer - farinelli
	If Select("__SE1")==0
		SumAbatRec( "", "", "", 1, "")
	Endif
	
	//Inicio CRM
	cCrmVei := ""
	If Substr(GetMv("MV_CRMVEI",,"N"),1,2)=="SS"
		If FG_PESQTAB("VO1_CRMOK")
			If Pergunte("CRMVEI",.T.)
				cCrmVei	:= MV_PAR01
			Endif
			lCamposCrm := .T.
		Else
			lCamposCrm := .F.
		Endif
	Endif
	//Final CRM
	
	If nVerParFat == 1 // NAO mostrar os Parametros do Faturamento no momento da geracao da NF
		PERGUNTE("MT460A",.f.)
	Else // nVerParFat == 2 // Mostrar os Parametros do Faturamento no momento da geracao da NF
		While .t.
			If PERGUNTE("MT460A",.t.)
				Exit
			EndIf
		EndDo
	EndIf
	
	Inclui := .T.
	
Endif

Begin Transaction

If cPaisLoc == "BRA" // Manoel - 12/05/2009
	If ExistBlock("O160ANGR")      	// Ponto de Entrada Antes das Gravacoes
		ExecBlock("O160ANGR",.f.,.f.)
	EndIf
Endif

Do Case
	
	Case cParam01 == 1   		// Fechamento Individual (referencia1)
		
		OFIOM16B()
		
	Case cParam01 == 2   		// Fechamento Agrupado (referencia2)
		
		OFIOM16C()
		
	Case cParam01 == 3   		// Fechamento de Kilometragem (referencia3)
		
		OFIOM16D()
		
EndCase

If cPaisLoc == "BRA" // Manoel - 12/05/2009
	
	If ExistBlock("O160DPGR")		// Ponto de Entrada Depois das Gravacoes
		ExecBlock("O160DPGR",.f.,.f.)
	EndIf
Endif

End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
MsRUnLock()

If cPaisLoc == "BRA" // Luis - 30/09/2009
	If ExistBlock("O160DPTR")		// Ponto de Entrada Depois da Transacao
		ExecBlock("O160DPTR",.f.,.f.)
	EndIf
Endif

If cPaisLoc == "BRA" // Manoel - 12/05/2009
	
	SX5->(MsRUnLock())
	
	Inclui := lIncluir
	
	If lMSErroAuto .or. !lRetFech
		MostraErro()
		Return .f.
	Endif
	
	If Substr(GetMv("MV_LOJAVEI",,"NNN"),2,1) == "N"	//Integrado com o Sigaloja ?
		If cNota != Nil
			DEFINE FONT oFnt4 NAME "Times New Roman" BOLD  //SIZE 06,13 BOLD
			
			DEFINE MSDIALOG oDlgNota TITLE OemtoAnsi(STR0001) FROM  02,04 TO 07,31 OF oMainWnd  //"Dados da Nota Fiscal"
			
			@ 001, 002 Say STR0002 + cNota  OF oDlgNota PIXEL FONT oFnt4 //"Numero da Nota:  "
			@ 012, 002 Say STR0003 + cSerie OF oDlgNota PIXEL FONT oFnt4 //"Serie  da Nota:  "
			
			DEFINE SBUTTON oOkFecha   FROM 024,070 TYPE 1 ACTION oDlgNota:End() ENABLE OF oDlgNota
			
			ACTIVATE MSDIALOG oDlgNota CENTER
		EndIf
	Else
		if ValType(cOrcLoja) == "C"
			MsgInfo(STR0017 +": " + cOrcLoja, STR0018 )//Orcamento Nº # Operação OK
		EndIf
	EndIf
Else
	if ValType(cOrcLoja) == "C"
		MsgInfo(STR0017 +": " + cOrcLoja, STR0018 )//Orcamento Nº # Operação OK
	EndIf
EndIf

lRetFin := lMSErroAuto

If cParam01 == 1 .or. cParam01 == 2 // Fechamento Individual / Agrupado
	DbSelectArea("VOI")
	DbSetOrder(1)
	DbSeek( xFilial("VOI") + VOO->VOO_TIPTEM )
	If ( VOI->VOI_SITTPO # "3" ) // Tipo de Tempo diferente de '3' ( Interno )
		////////////////////////////////////////////////////////////////////////////////////////
		// CEV - Verificar se ja existe Agenda CEV para esta OS/Cliente                       //
		////////////////////////////////////////////////////////////////////////////////////////
		cGCFOCEV := GetNewPar("MV_GCFOCEV","")
		cSQL := "SELECT VC1.R_E_C_N_O_ AS RECVC1 FROM "+RetSQLName("VC1")+" VC1 WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND "
		cSQL += "VC1.VC1_TIPAGE='"+left(cGCFOCEV,TamSx3("VC1_TIPAGE")[1])+"' AND "
		cSQL += "VC1.VC1_CODCLI='"+VOO->VOO_FATPAR+"' AND VC1.VC1_LOJA='"+VOO->VOO_LOJA+"' AND "
		cSQL += "VC1.VC1_TIPORI='O' AND VC1.VC1_ORIGEM='"+IIf(cParam01==2," ",VOO->VOO_NUMOSV)+"' AND VC1.D_E_L_E_T_=' '"
		If FM_SQL(cSQL) > 0
			cGCFOCEV := "" // Nao Gerar Agenda na Finalizacao quando ja existe Agenda para a OS/Cliente
		Else
			nDia := val(substr(cGCFOCEV+"0000000000000",11,3)) // Qtde minima de dias necessaria para criar nova Agenda
			If nDia > 0
				/////////////////////////////////////////////////////////////////////////////////////////////
				// CEV - Verificar se ja existe Agenda CEV para este Cliente dentro da Qtde minima de dias //
				/////////////////////////////////////////////////////////////////////////////////////////////
				cSQL := "SELECT VC1.R_E_C_N_O_ AS RECVC1 FROM "+RetSQLName("VC1")+" VC1 WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND "
				cSQL += "VC1.VC1_TIPAGE='"+left(cGCFOCEV,TamSx3("VC1_TIPAGE")[1])+"' AND "
				cSQL += "VC1.VC1_CODCLI='"+VOO->VOO_FATPAR+"' AND VC1.VC1_LOJA='"+VOO->VOO_LOJA+"' AND "
				cSQL += "VC1.VC1_TIPORI='O' AND VC1.VC1_DATAGE>='"+dtos(dDataBase-nDia)+"' AND VC1.D_E_L_E_T_=' '"
				If FM_SQL(cSQL) > 0
					cGCFOCEV := "" // Nao Gerar Agenda na Finalizacao quando ja existe Agenda dentro da qtde minima de dias
				EndIf
			EndIf
		EndIf
		// CEV - Agenda Contato quando Finaliza Oficina - Satisfacao do Cliente - Andre Luis Almeida - 04/03/2008 //
		If !Empty( cGCFOCEV )
			FS_AGENDA( Left(cGCFOCEV,1) ,;
			( dDataBase+Val(Substr(cGCFOCEV,2,3)) ) ,;
			Substr(cGCFOCEV,5,6) ,;
			VOO->VOO_FATPAR ,;
			VOO->VOO_LOJA ,;
			"" ,;
			IIf(cParam01==2,"",VOO->VOO_NUMOSV) ,;
			"" ,;
			STR0019+" "+If(cParam01==2, STR0020 ,VOO->VOO_NUMOSV)+" "+ STR0023 +": "+VOO->VOO_NUMNFI+"-"+VOO->VOO_SERNFI ,;
			"" ,;
			"" )//OS # Agrupada # Garantia # Revisao # FINALIZADA - NF
		EndIf
	EndIf
	If cParam01 == 1   // Fechamento Individual (Referencia1)
		If VOI->(FieldPos("VOI_SAIVEI")) <> 0
			If VOI->VOI_SAIVEI == "2" // Registrar SAIDA do VEICULO no Fechamento da OS ( 0=Nao Registra / 1=Liberacao OS / 2=Fechamento OS )
				DbSelectArea("VO1")
				DbSetOrder(1)
				If DbSeek( xFilial("VO1") + VOO->VOO_NUMOSV )
					/////////////////////////////////////////////////////////////////////////////////
					//  Registrar a SAIDA do VEICULO no momento do Fechamento de OS                //
					//  Andre Luis Almeida                                             28/08/2009  //
					/////////////////////////////////////////////////////////////////////////////////
					If Empty(VO1->VO1_DATSAI)
						If MsgYesNo(STR0025,STR0011) // "Deseja registrar a saida do veiculo ?" / "Atencao!!!"
							DbSelectArea("VO1")
							RecLock("VO1",.f.)
							VO1->VO1_DATSAI := dDataBase
							VO1->VO1_HORSAI := val(left(time(),2)+substr(time(),4,2))
							MsUnLock()
						EndIf
					EndIf
				EndIf
				/////////////////////////////////////////////////////////////////////////////////
			EndIf
		EndIf
		FS_IMPDOC1()
		If FindFunction("OFIOA510GRV")
			// "Controle de Valor de Garantia por periodo" - chamada da Funcao para (1-somar) o VPH/VPI. Andre Luis Almeida - 27/03/2009 //
			OFIOA510GRV(1,VOO->VOO_NUMOSV,VOO->VOO_TIPTEM) // Nro OS / Tipo de Tempo
		EndIf
	Else // cParam01 == 2   // Fechamento Agrupado (Referencia2)
		If VOI->(FieldPos("VOI_SAIVEI")) <> 0
			If VOI->VOI_SAIVEI == "2" // Registrar SAIDA do VEICULO no Fechamento da OS ( 0=Nao Registra / 1=Liberacao OS / 2=Fechamento OS )
				For i:=1 to len(aVOOAgrup)
					DbSelectArea("VO1")
					DbSetOrder(1)
					If DbSeek( xFilial("VO1") + aVOOAgrup[ni,1] )
						/////////////////////////////////////////////////////////////////////////////////
						//  Registrar a SAIDA do VEICULO no momento do Fechamento de OS                //
						//  Andre Luis Almeida                                             28/08/2009  //
						/////////////////////////////////////////////////////////////////////////////////
						If Empty(VO1->VO1_DATSAI)
							If lMsgSaiVei .or. MsgYesNo(STR0025,STR0011) // "Deseja registrar a saida do veiculo ?" / "Atencao!!!"
								lMsgSaiVei := .t.
								DbSelectArea("VO1")
								RecLock("VO1",.f.)
								VO1->VO1_DATSAI := dDataBase
								VO1->VO1_HORSAI := val(left(time(),2)+substr(time(),4,2))
								MsUnLock()
							Else
								Exit
							EndIf
						EndIf
						/////////////////////////////////////////////////////////////////////////////////
					EndIf
				Next
			EndIf
		EndIf
		FS_IMPDOC2()
		If FindFunction("OFIOA510GRV")
			For ni:=1 to len(aVOOAgrup)
				// "Controle de Valor de Garantia por periodo" - chamada da Funcao para (1-somar) o VPH/VPI. Andre Luis Almeida - 27/03/2009 //
				OFIOA510GRV(1,aVOOAgrup[ni,1],aVOOAgrup[ni,2]) // Nro OS / Tipo de Tempo
			Next
		EndIf
	EndIf
ElseIf cParam01 == 3   // Fechamento de Kilometragem (Referencia3)
	If VOI->(FieldPos("VOI_SAIVEI")) <> 0
		If VOI->VOI_SAIVEI == "2" // Registrar SAIDA do VEICULO no Fechamento da OS ( 0=Nao Registra / 1=Liberacao OS / 2=Fechamento OS )
			For i:=1 to len(aOSvCri)
				DbSelectArea("VO1")
				DbSetOrder(1)
				If DbSeek( xFilial("VO1") + aOSvCri[1] )
					/////////////////////////////////////////////////////////////////////////////////
					//  Registrar a SAIDA do VEICULO no momento do Fechamento de OS                //
					//  Andre Luis Almeida                                             28/08/2009  //
					/////////////////////////////////////////////////////////////////////////////////
					If Empty(VO1->VO1_DATSAI)
						If lMsgSaiVei .or. MsgYesNo(STR0025,STR0011) // "Deseja registrar a saida do veiculo ?" / "Atencao!!!"
							lMsgSaiVei := .t.
							DbSelectArea("VO1")
							RecLock("VO1",.f.)
							VO1->VO1_DATSAI := dDataBase
							VO1->VO1_HORSAI := val(left(time(),2)+substr(time(),4,2))
							MsUnLock()
						Else
							Exit
						EndIf
					EndIf
					/////////////////////////////////////////////////////////////////////////////////
				EndIf
			Next
		EndIf
	EndIf
	FS_IMPDOC3()
EndIf

FS_VOLTAR()

// Limpa vetor de controle do fechamento agrupado.
aFilMarkBrow := {}

Return(!lRetFin)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_APAGALIB³ Autor ³ Emilton               ³ Data ³ 15/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Apaga Liberacao VS7 / VS6                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_APAGALIB()

DbSelectArea("VS6")
DbSetOrder(1)
If DbSeek(xFilial("VS6")+cNumLib)
	DbSelectArea("VS7")
	DbSetOrder(1)
	If DbSeek(xFilial("VS7")+cNumLib)
		While cNumLib == VS7_NUMIDE .and. xFilial("VS6") == VS7_FILIAL .and. !Eof()
			RecLock("VS7",.F.,.T.)
			Dbdelete()
			MsUnlock()
			WriteSx2("VS7")
			DbSkip()
		EndDo
		dbSelectArea("VS6")
		RecLock("VS6",.f.,.t.)
		Dbdelete()
		MsUnlock()
		WriteSx2("VS6")
	Endif
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_SALVAFPG ³ Autor ³ Andre                 ³ Data ³ 20/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Salva Negociacao de Pagamentos                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SALVAFPG()

Local lAchou
Local i := 0
Local j := 0

DbSelectArea("VSE")
For i:=1 to Len(aGravaEnt)
	RecLock("VSE",.t.)
	VSE->VSE_FILIAL := xFilial("VSE")
	VSE->VSE_NUMIDE := "OF"+cNota+cSerie
	VSE->VSE_TIPOPE := "O"
	VSE->VSE_SEQUEN := StrZero(aGravaEnt[i,1],2)
	VSE->VSE_TIPPAG := aGravaEnt[i,2]
	VSE->VSE_DESCCP := aGravaEnt[i,3]
	VSE->VSE_NOMECP := aGravaEnt[i,4]
	VSE->VSE_TIPOCP := aGravaEnt[i,5]
	VSE->VSE_TAMACP := aGravaEnt[i,6]
	VSE->VSE_DECICP := aGravaEnt[i,7]
	VSE->VSE_PICTCP := aGravaEnt[i,8]
	VSE->VSE_VALDIG := aGravaEnt[i,9]
	If VSE->(FieldPos("VSE_TIPTEM")) <> 0
		VSE->VSE_TIPTEM := VOO->VOO_TIPTEM
	Endif
Next

DbSelectArea("VS9")

For j:=1 to Len(aColsC)
	If Empty(aColsC[j,FG_POSVAR("VS9_TIPPAG","aHeaderC")])
		Loop
	EndIf
	RecLock("VS9",.t.)
	Fg_Gravar("VS9",aColsC,aHeaderC,j)
	VS9->VS9_FILIAL := xFilial("VS9")
	VS9->VS9_NUMIDE := "OF"+cNota+cSerie
	VS9->VS9_TIPOPE := "O"
	If VS9->(FieldPos("VS9_TIPTEM")) <> 0
		VS9->VS9_TIPTEM := VOO->VOO_TIPTEM
	Endif
	cVar := aMemos[1][2]
	MSMM(,TamSx3("VS9_OBSERV")[1],,&cVar,1,,,"VS9","VS9_OBSMEM")
	ConfirmSx8()
	MsUnlock()
Next

For i:=1 to Len(aIteParc)
	if Empty(aIteParc[i,1])
		Exit
	Endif
	RecLock("VS9",.T.)
	VS9->VS9_FILIAL := xFilial("VS9")
	VS9->VS9_NUMIDE := "OF"+cNota+cSerie
	VS9->VS9_TIPOPE := "O"
	VS9->VS9_TIPPAG := "DP"
	VS9->VS9_DATPAG := DataValida(aIteParc[i,1])
	VS9->VS9_VALPAG := aIteParc[i,2]
	if !Empty(cCondic1) .and. !Empty(cCondic3)
		VS9->VS9_REFPAG := alltrim(dtoc(cCondic1))+strzero(val(cCondic2),2)+strzero(val(cCondic3),2)+strzero(val(cCondic4),2)
	Endif
	If VS9->(FieldPos("VS9_TIPTEM")) <> 0
		VS9->VS9_TIPTEM := VOO->VOO_TIPTEM
	Endif
	If VO1->(FieldPos("VO1_NATURE")) <> 0 .and. VS9->(FieldPos("VS9_NATURE")) <> 0
		VS9->VS9_NATURE := cVO1_NATURE
	Endif
	If VO1->(FieldPos("VO1_NATURE")) <> 0 .and. VS9->(FieldPos("VS9_NATSRV")) <> 0
		VS9->VS9_NATSRV := cVO1_NATSRV
	Endif
	MsUnlock()
Next

DbSelectArea("VS9")
if !Empty(cCodCDCI) .and. nValorCom > 0
	RecLock("VS9",.t.)
	VS9->VS9_FILIAL := xFilial("VS9")
	VS9->VS9_NUMIDE := "CD"+cNota
	VS9->VS9_TIPOPE := "O"
	VS9->VS9_TIPPAG := "CD"
	VS9->VS9_DATPAG := dDataBase
	VS9->VS9_VALPAG := nValorCom
	VS9->VS9_REFPAG := cCodCDCI
	If VS9->(FieldPos("VS9_TIPTEM")) <> 0
		VS9->VS9_TIPTEM := VOO->VOO_TIPTEM
	Endif
	If VO1->(FieldPos("VO1_NATURE")) <> 0 .and. VS9->(FieldPos("VS9_NATURE")) <> 0
		VS9->VS9_NATURE := cVO1_NATURE
	Endif
	If VO1->(FieldPos("VO1_NATURE")) <> 0 .and. VS9->(FieldPos("VS9_NATSRV")) <> 0
		VS9->VS9_NATSRV := cVO1_NATSRV
	Endif
	MsUnlock()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_OM160PESQAutor³Emilton              º Data ³  16/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesquisa e nao perde o indice                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OM160PESQ()

Local lRetFech

lRetFech := axPesqui()

Do Case
	
	Case cParam01 == 1                 // Fechamento Individual de Ordem de Servico
		
		dbSelectArea("VO1")
		dbSetOrder(nIndexPro+1)
		
	Case cParam01 == 2                 // Fechamento Agrupado de Ordem de Servico
		
		dbSelectArea("VOO")
		dbSetOrder(nIndexPro+1)
		
	Case cParam01 == 3                 // Fechamento de Ordem de Servico de Kilometragem
		
		dbSelectArea("VF4")
		dbSetOrder(nIndexPro+1)
		
EndCase
Return lRetFech


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GRNFINT³ Autor ³ANDRE                  ³ Data ³ 05/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava nro da Nota qdo OS interna sem Pecas                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRNFINT()

Local cNota_  := SubStr(StrZero(Val(GetMV("MV_SQNFINT"))+1,TamSx3("F2_DOC")[1]),1,TamSx3("F2_DOC")[1])
Local cSerie_ := "INT"

/* Atualiza numero das notas */
dbSelectArea("VOO")
dbSetOrder(1)
if dbSeek(xFilial("VOO")+VO1->VO1_NUMOSV+VOI->VOI_TIPTEM)
	
	RecLock("VOO",.f.)
	VOO->VOO_NUMNFI := cNota_
	VOO->VOO_SERNFI := cSerie_
	MsUnlock()
	
	/* Atualiza Avaliacao de Pecas */
	dbSelectArea("VEC")
	dbSetOrder(5)
	dbSeek(xFilial("VEC")+VOO->VOO_NUMOSV+VOO->VOO_TIPTEM)
	While !Eof() .and. VEC->VEC_FILIAL+VEC->VEC_NUMOSV+VEC->VEC_TIPTEM == xFilial("VEC")+VOO->VOO_NUMOSV+VOO->VOO_TIPTEM
		RecLock("VEC",.f.)
		VEC->VEC_NUMNFI := cNota_
		VEC->VEC_SERNFI := cSerie_
		MsUnlock()
		VEC->(dbSkip())
	EndDo
	
	/* Atualiza Avaliacao de Servicos */
	dbSelectArea("VSC")
	dbSetOrder(1)
	dbSeek(xFilial("VSC")+VOO->VOO_NUMOSV+VOO->VOO_TIPTEM)
	While !Eof() .and. VSC->VSC_FILIAL+VSC->VSC_NUMOSV+VSC->VSC_TIPTEM == xFilial("VSC")+VOO->VOO_NUMOSV+VOO->VOO_TIPTEM
		RecLock("VSC",.f.)
		VSC->VSC_NUMNFI := cNota_
		VSC->VSC_SERNFI := cSerie_
		MsUnlock()
		VSC->(dbSkip())
	EndDo
	
	/* Atualiza Requisicao de Pecas */
	dbSelectArea("VO2")
	dbSetOrder(1)
	dbSeek(xFilial("VO2")+VOO->VOO_NUMOSV)
	
	dbSelectArea("VO3")
	dbSetOrder(1)
	dbSeek(xFilial("VO3")+VO2->VO2_NOSNUM+VOO->VOO_TIPTEM)
	While !Eof() .and. VO3->VO3_FILIAL+VO3->VO3_NOSNUM+VO3->VO3_TIPTEM == xFilial("VO3")+VO2->VO2_NOSNUM+VOO->VOO_TIPTEM
		RecLock("VO3",.f.)
		VO3->VO3_NUMNFI := cNota_
		VO3->VO3_SERNFI := cSerie_
		MsUnlock()
		VO3->(dbSkip())
	EndDo
	
	/* Atualiza Requisicao de Servicos */
	dbSelectArea("VO4")
	dbSetOrder(1)
	dbSeek(xFilial("VO4")+VO2->VO2_NOSNUM+VOO->VOO_TIPTEM)
	While !Eof() .and. VO4->VO4_FILIAL+VO4->VO4_NOSNUM+VO4->VO4_TIPTEM == xFilial("VO4")+VO2->VO2_NOSNUM+VOO->VOO_TIPTEM
		RecLock("VO4",.f.)
		VO4->VO4_NUMNFI := cNota_
		VO4->VO4_SERNFI := cSerie_
		MsUnlock()
		VO4->(dbSkip())
	EndDo
	
	dbSelectArea("SX6")
	dbSetOrder(1)
	if dbSeek(xFilial("SX6")+"MV_SQNFINT")
		RecLock("SX6",.f.)
		X6_CONTEUD := cNota_
		MsUnlock()
	Endif
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VALABATºAutor  ³Rubens              º Data ³  21/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna valor de titulos de abatimento de PIS/COFINS/CSLL  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_160VLAB( _cPrefixo, _cNum, _cParc)

Local nValAbat

nRecSE1 := SE1->(Recno())
nValAbat := 0
SE1->(dbSetOrder(1))
SE1->(dbSeek(xFilial("SE1") + _cPrefixo + _cNum + _cParc ))
While !SE1->(Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") .and. ;
	SE1->E1_PREFIXO == _cPrefixo .and. ;
	SE1->E1_NUM == _cNum .and. ;
	SE1->E1_PARCELA == _cParc
	
	If AllTrim(SE1->E1_TIPO)$MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVISABT+"/"+MVI2ABT
		nValAbat += SE1->E1_VALOR
	EndIf
	
	SE1->(dbSkip())
End

If nRecSE1 <> 0
	SE1->(dbGoTo(nRecSE1))
EndIf

Return nValAbat

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VTTPSTAT ºAutor  ³Rubens            º Data ³  24/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se pode fechar o TT selecionado                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VTTPSTAT()
Local i := 0
Local lAuxRet := .t.
If lCANUSETT
	// Verifica a situacao dos TT's ...
	If cParam01 == 1  // Fechamento Individual (referencia1)
		For i := 1 to len(aVetTTp)
			If aVetTTp[i,01] .and. !FMX_CANUSETT( "6" , aVetTTP[i,2] , aVetTTP[i,3] )
				lAuxRet := .f.
				Exit
			EndIf
		Next i
	ElseIf cParam01 == 2
		For i := 1 to Len(aVetOsv)
			If !FMX_CANUSETT( "6" , aVetOsv[i,1] , aVetOsv[i,2] )
				lAuxRet := .f.
				Exit
			EndIf
		Next i
	EndIf
	//
EndIf
Return lAuxRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM160VLDTES ºAutor  ³Rubens            º Data ³  11/01/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao da configuracao de movimentacao do estoque da TESº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM160VLDTES(cAuxNumOsv, cAuxTipTem, nTipVld)

Local lRetorno := .t.
Local cSQL := ""
Local cSQLAlias := "TMPVLDTES"
Local aArea := GetArea()
Local cMsgTxt := ""
Local cAuxTES

// Verifica se existe requisicao de pecas misturando TES que movimenta e NAO movimenta estoque 
cSQL += "SELECT TEMP.VO3_GRUITE, TEMP.VO3_CODITE, COUNT(*) TPMOV "
cSQL += " FROM ( "
cSQL +=    "SELECT VO3_GRUITE, VO3_CODITE, F4_ESTOQUE, "
cSQL +=          " SUM( CASE VO2_DEVOLU WHEN '1' THEN VO3_QTDREQ ELSE VO3_QTDREQ * -1 END ) VO3_QTDREQ "
cSQL +=     " FROM " + RetSQLName("VO3") + " VO3 JOIN " + RetSQLName("VO2") + " VO2 ON VO2_FILIAL = '" + xFilial("VO2") + "' AND VO2_NOSNUM = VO3_NOSNUM AND VO2.D_E_L_E_T_ = ' '"
cSQL +=            " JOIN " + RetSQLName("SF4") + " F4 ON F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = VO3_CODTES AND F4.D_E_L_E_T_ =	' '"
cSQL +=    " WHERE VO3.VO3_FILIAL = '" + xFilial("VO3") + "'"
cSQL +=      " AND VO3.VO3_NUMOSV = '" + cAuxNumOsv + "'"
cSQL +=      " AND VO3.VO3_TIPTEM = '" + cAuxTipTem + "'"
cSQL +=      " AND VO3.D_E_L_E_T_ = ' '"
cSQL +=    " GROUP BY VO3_GRUITE, VO3_CODITE, F4_ESTOQUE "
cSQL += " ) TEMP "
cSQL += " WHERE VO3_QTDREQ > 0 " // So considera movimentacao com qtde positiva
cSQL += " GROUP BY TEMP.VO3_GRUITE, TEMP.VO3_CODITE "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cSQLAlias , .F., .T. )
While !(cSQLAlias)->(Eof())
	
	If (cSQLAlias)->TPMOV > 1
		cMsgTxt += (cSQLAlias)->VO3_GRUITE + " - " + AllTrim((cSQLAlias)->VO3_CODITE) + CHR(13) + CHR(10)
	EndIf
	
	(cSQLAlias)->(DbSkip())
End
(cSQLAlias)->(dbCloseArea())

If !Empty(cMsgTxt)
	cMsgTxt := STR0026 + chr(13) + chr(10) + ;	// "Impossível continuar, o tipo de tempo possui peças requisitadas com TES de diferentes configurações de movimentação de estoque."
				STR0027 + chr(13) + chr(10) + ;	// "É necessário alterar as requisições antes de prosseguir com fechamento."
				STR0028 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ; // "Produto(s): "
				cMsgTxt
	MsgStop(cMsgTxt)
	RestArea( aArea )
	Return .f.
EndIf
//

cSQL := "SELECT VO3_GRUITE, VO3_CODITE, VO3_OPER , VO3_CODTES, VO3_FATPAR, VO3_LOJA, "
cSQL +=       " SUM( CASE VO2_DEVOLU WHEN '1' THEN VO3_QTDREQ ELSE VO3_QTDREQ * -1 END ) VO3_QTDREQ "
cSQL +=  " FROM " + RetSQLName("VO3") + " VO3 JOIN " + RetSQLName("VO2") + " VO2 ON VO2_FILIAL = '" + xFilial("VO2") + "' AND VO2_NOSNUM = VO3_NOSNUM AND VO2.D_E_L_E_T_ = ' '"
cSQL += " WHERE VO3.VO3_FILIAL = '" + xFilial("VO3") + "'"
cSQL +=   " AND VO3.VO3_NUMOSV = '" + cAuxNumOsv + "'"
cSQL +=   " AND VO3.VO3_TIPTEM = '" + cAuxTipTem + "'"
cSQL +=   " AND VO3.D_E_L_E_T_ = ' '"
cSQL += " GROUP BY VO3_GRUITE, VO3_CODITE, VO3_OPER , VO3_CODTES, VO3_FATPAR, VO3_LOJA"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cSQLAlias , .F., .T. )
While !(cSQLAlias)->(Eof())

	If (cSQLAlias)->VO3_QTDREQ <= 0
		(cSQLAlias)->(dbSkip())
		Loop
	EndIf
	
	SB1->(dbSetOrder(7))
	SB1->(dbSeek(xFilial("SB1") + (cSQLAlias)->VO3_GRUITE + (cSQLAlias)->VO3_CODITE ))
	SB1->(dbSetOrder(1))
	
	If !Empty((cSQLAlias)->VO3_OPER)
		cAuxTES := MaTesInt(2,(cSQLAlias)->VO3_OPER,(cSQLAlias)->VO3_FATPAR,(cSQLAlias)->VO3_LOJA,"C",SB1->B1_COD)
	Else
		cAuxTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
	Endif
	
	If (cSQLAlias)->VO3_CODTES == cAuxTES
		(cSQLAlias)->(dbSkip())
		Loop
	EndIf
	
	If !OM160CMPTES( (cSQLAlias)->VO3_CODTES, cAuxTES )
		lRetorno := .f.
		Exit
	EndIf

	(cSQLAlias)->(DbSkip())
End
(cSQLAlias)->(dbCloseArea())
	
RestArea( aArea )

Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM160CMPTES ºAutor  ³Rubens            º Data ³  11/01/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao da configuracao de movimentacao do estoque da TESº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM160CMPTES( cTESOrig, cTESDest )

Local cMovTesAnt, cMovTesAtu

cMovTesAnt := FM_SQL("SELECT F4_ESTOQUE FROM " + RetSQLName("SF4") + " F4 WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = '" + cTESOrig + "' AND D_E_L_E_T_ = ' '")
cMovTesAtu := FM_SQL("SELECT F4_ESTOQUE FROM " + RetSQLName("SF4") + " F4 WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = '" + cTESDest + "' AND D_E_L_E_T_ = ' '")
	
If cMovTesAtu <> cMovTesAnt
	MsgStop(STR0029 + chr(13) + chr(10) + chr(13) + chr(10) + ;	// "Divergência na configuração de movimentação de estoque das TES."
			"F4_ESTOQUE = '"+ cMovTesAnt +"' ( " + cTESOrig + " )"+CHR(13)+CHR(10)+; 
			"F4_ESTOQUE = '"+ cMovTesAtu +"' ( " + cTESDest + " )" ,STR0030) // "A Operação será cancelada!"
	Return .f.
Endif

Return .t.
