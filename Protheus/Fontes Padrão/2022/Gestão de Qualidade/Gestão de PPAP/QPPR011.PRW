#INCLUDE "QPPR011.CH"
#INCLUDE "PROTHEUS.CH"


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � QPPR011	  � Autor � Robson Ramiro A. Olive� Data � 20/01/04 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Impressao por nivel de submissao  		  				    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � QPPR011()                                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpL1 : Browse ou menu                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � SIGAPPAP				                 					    潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       潮�
北媚哪哪哪哪哪哪穆哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� PROGRAMADOR  � DATA   � BOPS  � MOTIVO DA ALTERACAO                     潮�
北媚哪哪哪哪哪哪呐哪哪哪哪拍哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪哪牧哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/

Function QPPR011(lBrow)

Local cPecaRev	:= ""
Local lPergunte	:= .F.
Local lEquipe	:= .F.

Default lBrow := .F.

Private lFMEA4A := GetMV("MV_QVEFMEA",.T.,"3") == "4" //FMEA 4a. EDICAO...
If !lBrow

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Variaveis utilizadas para parametros							�
	//� mv_par01				// Peca      							�
	//� mv_par02				// Revisao      						�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

	lPergunte := Pergunte("PPR011",.T.)
	
	If lPergunte
		cPecaRev := mv_par01 + mv_par02	
	Else
		Return Nil
	Endif

Else
	cPecaRev := QKI->QKI_PECA + QKI->QKI_REV
Endif

DbSelectArea("QK1")
DbSetOrder(1)

If DbSeek(xFilial()+cPecaRev)
	lEquipe := !Empty(QK1->QK1_CODEQU)
Endif

DbSelectArea("QKI")
DbSetOrder(1)

If DbSeek(xFilial()+cPecaRev)
	Processa({|| QPPR011PROC(cPecaRev,lEquipe)})
Else
	Help(" ",1,"QPPCERSUB") // "Para usar essa opcao e necessario fazer o Certificado de Submissao."
Endif

Return Nil

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � QPPR011PROC� Autor � Robson Ramiro A. Olive� Data � 20/01/04 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Executa a impressao por nivel de submissao   			    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � QPPR011PROC()                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpC1 : Peca e Revisao                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � SIGAPPAP				                 					    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function QPPR011PROC(cPecaRev,lEquipe)

Local nQtde
Local aCarac := {}
Local nCont
Local nPos	:= 0
Local nSeq	:= 0
Local cFiltro
Local cSeqQKB := ""
Local cSeqQKC := ""
Local cSeqQKD := ""

Do Case
	Case QKI->QKI_FLNISU == "1"; 	nQtde := 2
	Case QKI->QKI_FLNISU == "2";	nQtde := 5
	Case QKI->QKI_FLNISU == "3"; 	nQtde := 11
	Case QKI->QKI_FLNISU == "4"; 	nQtde := 1
	Case QKI->QKI_FLNISU == "5";	nQtde := 0
	Otherwise; 						nQtde := 0
Endcase

If nQtde == 0
	Help(" ",1,"QPPNIVSUB")//"Nao existe nivel de submissao informado, ou e nivel 5"
	Return Nil
Endif

QK2->(DbSetOrder(1))
QK2->(DbSeek(xFilial("QK2")+cPecaRev))

Do While QK2->(!Eof()) .and. cPecaRev == QK2->QK2_PECA + QK2->QK2_REV;
						.and. xFilial("QK2") == QK2->QK2_FILIAL
	aAdd(aCarac, {QK2->QK2_CODCAR,"  "})
	QK2->(DbSkip())
Enddo

QK9->(DbSetOrder(1))
QK9->(DbSeek(xFilial("QK9")+cPecaRev))

Do While QK9->(!Eof()) .and. cPecaRev == QK9->QK9_PECA + QK9->QK9_REV; 
						.and. xFilial("QK9") == QK9->QK9_FILIAL
						
	nPos := aScan(aCarac, {|x| x[1] == QK9->QK9_CARAC})

	If nPos <> 0
		aCarac[nPos,2] := QK9->QK9_SEQ  //Guarda apenas a Maior Sequencia
	Endif

	QK9->(DbSkip())
Enddo

cFiltro := "QKB->QKB_ITEM == '"+StrZero(1,Len(QKB->QKB_ITEM))+"'"

QKB->(DbSetFilter({|| &cFiltro }, cFiltro))
QKB->(DbSetOrder(1))
QKB->(DbSeek(xFilial("QKB")+cPecaRev))

Do While QKB->(!Eof()) .and. cPecaRev == QKB->QKB_PECA + QKB->QKB_REV; 
						.and. xFilial("QKB") == QKB->QKB_FILIAL
						
	cSeqQKB := QKB->QKB_SEQ  //Guarda apenas a Maior Sequencia
	QKB->(DbSkip())

Enddo

QKB->(DbClearFilter())

cFiltro := "QKC->QKC_ITEM == '"+StrZero(1,Len(QKC->QKC_ITEM))+"'"

QKC->(DbSetFilter({|| &cFiltro }, cFiltro))
QKC->(DbSetOrder(1))
QKC->(DbSeek(xFilial("QKC")+cPecaRev))

Do While QKC->(!Eof()) .and. cPecaRev == QKC->QKC_PECA + QKC->QKC_REV; 
						.and. xFilial("QKC") == QKC->QKC_FILIAL
						
	cSeqQKC := QKC->QKC_SEQ  //Guarda apenas a Maior Sequencia
	QKC->(DbSkip())

Enddo

QKC->(DbClearFilter())

cFiltro := "QKD->QKD_ITEM == '"+StrZero(1,Len(QKD->QKD_ITEM))+"'"

QKD->(DbSetFilter({|| &cFiltro }, cFiltro))
QKD->(DbSetOrder(1))
QKD->(DbSeek(xFilial("QKD")+cPecaRev))

Do While QKD->(!Eof()) .and. cPecaRev == QKD->QKD_PECA + QKD->QKD_REV; 
						.and. xFilial("QKC") == QKD->QKD_FILIAL
						
	cSeqQKD := QKD->QKD_SEQ  //Guarda apenas a Maior Sequencia
	QKD->(DbSkip())

Enddo

QKD->(DbClearFilter())

If lEquipe
	nQtde++
Endif

ProcRegua(nQtde)

If QKI->QKI_FLNISU$"3"
	IncProc(STR0001+STR0002) //"Imprimindo "###"FMEA de Projeto"
	If lFMEA4a
		QPPR370(Nil,Nil,cPecaRev)	
	Else
		QPPR120(Nil,cPecaRev)
	Endif

	IncProc(STR0001+STR0003) //"Imprimindo "###"FMEA de Processo"
	If lFMEA4a
		QPPR380(Nil,cPecaRev)
	Else
		QPPR130(Nil,cPecaRev)
	Endif	
	
	IncProc(STR0001+STR0004) //"Imprimindo "###"Diagrama de Fluxo"
	QPPR150(Nil,cPecaRev)

	IncProc(STR0001+STR0005) //"Imprimindo "###"Plano de Controle"
	QPPR160(Nil,cPecaRev)

	IncProc(STR0001+STR0006) //"Imprimindo "###"Capabilidade"
	For nCont := 1 To Len(aCarac)
		For nSeq := 0 To Val(aCarac[nCont,2])
			QPPR170(Nil,Nil,cPecaRev+aCarac[nCont,1]+StrZero(nSeq,3))
		Next nSeq
	Next nCont

	IncProc(STR0001+STR0007) //"Imprimindo "###"RR"
	For nCont := 1 To Len(aCarac)
		QMTR150(Nil,cPecaRev+aCarac[nCont,1])
	Next nCont

Endif

If QKI->QKI_FLNISU$"23"
	IncProc(STR0001+STR0008) //"Imprimindo "###"Ensaio Dimensional"
	If !EMPTY(cSeqQKB)
		For nSeq := 0 To Val(cSeqQKB)
			QPPR180(Nil,cPecaRev+StrZero(nSeq,3))
		Next nSeq
	Else
		QPPR180(Nil,cPecaRev)
	Endif

	IncProc(STR0001+STR0009) //"Imprimindo "###"Ensaio Material"
	If !EMPTY(cSeqQKD)
		For nSeq := 0 To Val(cSeqQKD)
			QPPR190(Nil,cPecaRev+StrZero(nSeq,3))
		Next nSeq
	Else
		QPPR190(Nil,cPecaRev)
	Endif

	IncProc(STR0001+STR0010) //"Imprimindo "###"Ensaio Desempenho"
	If !EMPTY(cSeqQKC)
		For nSeq := 0 To Val(cSeqQKC)
			QPPR200(Nil,cPecaRev+StrZero(nSeq,3))
		Next nSeq
	Else
		QPPR200(Nil,cPecaRev)
	Endif
Endif

If QKI->QKI_FLNISU$"123"
	IncProc(STR0001+STR0011) //"Imprimindo "###"Aprovacao de Aparencia"
	QPPR210(Nil,cPecaRev)
Endif

IncProc(STR0001+STR0012) //"Imprimindo "###"Certificado de Submissao"
QPPR220(Nil,cPecaRev)

If lEquipe
	IncProc(STR0001+STR0013)	//"Imprimindo "###"Equipe Multifuncional"
	QPPR040(.F., cPecaRev)  	// Imprime a Equipe Multifuncional
Endif

Return Nil