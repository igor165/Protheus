#INCLUDE "QMTA045.CH"
#Include "PROTHEUS.CH"

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � QMTA045	  � Autor � Wanderley Gon嘺lves   � Data � 07/07/98 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Duplica Escalas      					  					潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � SIGAQMT				                 						潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function QMTA045
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define Variaveis					�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

Local bCRepQM9,bCRepQMC,bCRepQMA,bCRepQMH	// Atribuicao no replace
Local bCConQM9,bCConQMC,bCConQMA,bCConQMH	// Condicao para o replace
Local aArq				// Array de arquivos para duplicacao
Local lVolta			// 
Local nRec
Local nCntFor
Private lUpper := .F.
Private aRotina:={ {OemToAnsi(STR0003), "AllwaysTrue",0,3}} // "Duplica噭o de Escala"
//BOPS JJ - Verificar se existe picture cadastrada no SX3 para surgerir na duplicacao somente letras maiusculas...
If Alltrim(GetSx3Cache("QM9_ESCALA","X3_PICTURE")) == "@!"
	lUpper := .T.
Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Variaveis utilizadas para parametros						  	�
//� mv_par01				// Origem								�
//� mv_par02				// Revisao Origem 						�
//� mv_par03				// Destino								�
//� mv_par04				// Revisao Destino						�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

Do while .t.

	If Pergunte("QMA045",.T.)

		QM9->( dbSetOrder(1) )
		If QM9->(DbSeek(xFilial('QM9')+mv_par01+Inverte(mv_par02)))
			If Alltrim(Upper(mv_par01)) == Alltrim(Upper(mv_par03)) .and. Val(mv_par02) > Val(mv_par04)
				MessageDlg(STR0002,,3) //"Nao e permitido gerar revisao anterior dessa escala"
				Return .F.
			Endif
			nRec := QM9->(recno())
			If QM9->(DbSeek(xFilial('QM9')+mv_par03+Inverte(mv_par04)))
				Help(" ",1,"A045EXIREV") // Esta escala/revisao ja esta cadastrada.
				Return(Nil)
			EndIf
			QM9->(DbGoto(nRec))

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Inicializa Array 										  	 �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			aArq	  := {}

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Condicoes para QM9											 �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			bCrepQM9:= { || QM9->QM9_ESCALA  := mv_par03 ,;
								 QM9->QM9_REVESC	:= mv_par04 ,;
								 QM9->QM9_REVINV  := Inverte(QM9->QM9_REVESC),;
								 QM9->QM9_DATREV  := dDataBase }
			bCconQM9 := { || ! eof() .and. xFilial('QM9') == QM9_FILIAL .and.;
												  QM9_ESCALA == mv_par01 .and.;
												  QM9_REVESC == mv_par02 }
			aadd( aArq, { 'QM9', mv_par01+Inverte(mv_par02), bCRepQM9, bCConQM9, 1 } ) 

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Condicoes para QMC											 �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			bCrepQMC:= { || QMC->QMC_ESCALA	:= mv_par03 ,;
								 QMC->QMC_REVESC	:= mv_par04 ,;
								 QMC->QMC_REVINV  := Inverte(mv_par04) }

			bCconQMC := { || ! eof() .and. xFilial('QMC') == QMC_FILIAL .and.;
												  QMC_ESCALA == mv_par01 .and.;
												  QMC_REVESC == mv_par02 }
			aadd( aArq, { 'QMC', mv_par01+Inverte(mv_par02), bCRepQMC, bCConQMC, 1 } ) 

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Condicoes para QMA											 �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			bCrepQMA:= { || QMA->QMA_ESCALA	:= mv_par03 ,;
								 QMA->QMA_REVESC	:= mv_par04 } 
			bCconQMA := { || ! eof() .and. xFilial('QMA') == QMA_FILIAL .and.;
												  QMA_ESCALA == mv_par01 .and.;
												  QMA_REVESC == mv_par02 }
			aadd( aArq, { 'QMA', mv_par01+mv_par02, bCRepQMA, bCConQMA, 1 } ) 

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Condicoes para QMH (somente sera duplicado se as escalas fo- �
			//� rem diferentes (nao existe revisao para esta amarracao)      �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			If mv_par01 <> mv_par03
				bCrepQMH:= { || QMH->QMH_ESCALA	:= mv_par03 }
				bCconQMH := { || ! eof() .and. xFilial('QMH') == QMH_FILIAL .and.;
													  QMH_ESCALA == mv_par01 }
				aadd( aArq, { 'QMH', mv_par01, bCRepQMH, bCConQMH, 1 } ) 
			EndIf


			for nCntFor := 1 to len(aArq)
				dbselectar(aArq[nCntFor,1])
				dbSetOrder(aArq[nCntFor,5])
				dbseek(xFilial()+aArq[nCntFor,2])
				do while eval(aArq[nCntFor,4])
					lVolta := .t.
					if QA_Dupl(lVolta, aArq[nCntFor,3], aArq[nCntFor,1])
						skip
					else
						exit
					endif
				enddo
			next

		EndIf
		MsgInfo( OemToAnsi(STR0004), OemToAnsi(STR0005) )// "Duplica噭o Conclua!!!" ### "Duplica噭o de Escalas"
	Else
		Exit
	EndIf  
EndDo

Return(Nil)

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o	 � A045UpIns  � Autor � Wanderley Gon嘺lves	  � Data � 29/01/98 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Verifica se Campo Escala nao esta vazio                 		潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � X1_VALID do Grupo QMA045 e Ordem 1							潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function A045UpIns()

Local lret := .f.

If naovazio()
	If lUpper 
		mv_par01 := Upper(mv_par01)
	Endif	
	//Sugere ultima revisao da escala origem
	dbSelectArea("QM9")
	dbSetOrder(1)
	If dbSeek(xFilial()+mv_par01)
		mv_par02 := QM9->QM9_REVESC
		lRet := .T.		
	Else
		lRet := .F.
		MSGALERT(OemToAnsi(STR0006))
	Endif	
Else
	lRet := .F.
EndIf

Return(lRet)


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o	 � A045ExIns  � Autor � Wanderley Gon嘺lves	  � Data � 20/01/98 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Verifica se Escala existe para duplicacao				    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � X1_VALID do Grupo QMA045 e Ordem 2 e Ordem 4 				潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function A045ExIns(cPErg)

Local cChave
If cPerg == "O"  // Instrumento Origem
	If !Isdigit(mv_par02)
		Return(.F.)
	EndIf
	dbSelectArea("QM9") 
	dbSeek(xFilial()+mv_par01)
	mv_par02 := QM9->QM9_REVESC
	cChave := mv_par01 + Inverte(mv_par02)
Else
	If !Isdigit(mv_par04) 
		Return(.F.)
	EndIf
	cChave := mv_par03 + Inverte(mv_par04)
EndIf

If naovazio()
	//Localiza a ultima revisao do instrumento Para
	dbSelectArea("QM9")
	dbSetOrder(1)
	If dbSeek(xFilial()+mv_par03)	
		//Compara com a ultima encontrada..	
		If Val(QM9->QM9_REVESC) > Val(mv_par04)
			Return(.T.)
		Endif
	Endif

	QM9->(DbsetOrder(1))

	If QM9->(DbSeek(xFilial('QM9') + cChave ))
		Return(.T.)
	EndIf

EndIf

Return(.F.)

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o	 � A045CkIns  � Autor � Wanderley Gon嘺lves	  � Data � 20/01/98 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Verifica se Instrumento esta cadastrado para sugerir versao  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � X1_VALID do Grupo QMA045 e Ordem 3						    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function A045CkIns()
Local nRec := 0

//BOPS JJ
If lUpper
	mv_par03 := Upper(mv_par03)
Endif	
If naovazio()
	nRec := QM9->(recno())
	QM9->(DbsetOrder(1))
	If QM9->(DbSeek(xFilial('QM9') + mv_par03))
		mv_par04 := StrZero(Val(QM9->QM9_REVESC)+1,2)
	Else
		mv_par04 := "00"		
	EndIf
Else
	Return .f.
EndIf
Return(.T.)
