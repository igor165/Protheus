/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ RELPECE  ³ Autor ³  Emilton              ³ Data ³ 10/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Imprime Relacao de Pecas em Formulario especifico          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RELPECE()
**********************

SetPrvt("cDesc1,cDesc2,cDesc3,cAlias,aRegistros,cString,cTitulo,cTamanho,aReturn")
SetPrvt("cNomProg,cNomRel,cDrive,cNumOsv,cTipTem,cTipFor")

cAlias     :="VEK"

Private nLin := 1
Private aPag := 1
Private nIte := 1
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
cNumOsv := ParamIxb[1]
cTipTem := ParamIxb[2]
cTipFor := ParamIxb[3]

cKeyAce := cNumOsv+cTipTem
	
VEC->(dbSetOrder(5))
VEC->(dbgotop())

If VEC->(dbSeek(xFilial("VEC")+cKeyAce)) = .f.
   return
endif

cDesc1     :=""
cDesc2     :=""
cDesc3     :=""
cString    :="SD1"
aRegistros := {}
cTitulo    := OemToAnsi("Emissao da Relacao das Pecas Aplicadas")
aReturn    :=  { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
cNomProg   := "RELPECE"
nLastKey   := 0
cNomRel    := cTipFor
cDrive     := GetMv("MV_DRVRLP")
cNomeImp   := GetMv("MV_PORRLP")

/*
[1] Reservado para Formulario
[2] Reservado para nro de Vias
[3] Destinatario
[4] Formato => 1-Comprimido 2-Normal
[5] Midia   => 1-Disco 2-Impressora
[6] Porta ou Arquivo 1-LPT1... 4-COM1...
[7] Expressao do Filtro
[8] Ordem a ser selecionada
[9]..[10]..[n] Campos a Processar (se houver)
*/

Private cTamanho:= "P"           // P/M/G
Private Limite  := 132           // 80/132/220
Private aOrdem  := {}           // Ordem do Relatorio
Private nLastKey:= 0

lServer    := ( GetMv("MV_LSERVER") == "S" )

lForimp    :=   "N" //GetMv("MV_LCOPY")

aReturn 	:= { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }	

if  lForimp = "N"
		
		cNomRel    := SetPrint(cString,cNomRel,nil ,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho,nil    ,nil    ,nil    ,cDrive,.T.  ,lServer,cNomeImp)
		
else
		
		&& Impressao com copy file
		Do While File(__RELDIR+cNomRel+".##R")
			Dele File &(__RELDIR+cNomRel+".##R")
		EndDo
		
		__AIMPRESS[1] := 1
		__AIMPRESS[3] := 1
		
		cNomRel := SetPrint(cString,cNomRel,nil ,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho,nil    ,nil    ,nil    ,,.T.  ,lServer)
		
endif

If nLastKey == 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cAlias)

RptStatus({|lEnd| ImprimeRP(@lEnd,cNomRel,cAlias,cNumOSv,cTipTem,cTipFor)},cTitulo)

Set Filter To

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ IMPRIMERP³ Autor ³  Emilton              ³ Data ³ 11/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Imprime Relacao de Pecas em Formulario especifico          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImprimeRP(lEnd,cNomRel,cAlias,cNumOsv,cTipTem,cTipFor)
*********************************************************

Local nCai := 0
SetPrvt("cNomEmp,cCGCFil,cEndEmp,cCEPFil,cTelFil,cFaxFil,cInsFil,cCidFil")
SetPrvt("cEstFil,nValTot,nValDes,nBasICM,nValICM,nNumLin,lFlgImp")
SetPrvt("oPr","nX","aDriver","lVez","nValor1")
SetPrvt("cNomeEmp","cEndeEmp","cNomeCid","cEstaEmp","cCep_Emp","cFoneEmp")
SetPrvt("cFax_Emp","cCNPJEmp","cInscEmp")

aDriver := LeDriver()
Private cCompac := aDriver[1]
Private cNormal := aDriver[2]
Private cExpand := aDriver[3]

Set Printer to &cNomRel
Set Printer On
Set Device  to Printer

If cTipFor == "RELPECN"   && Formulario Comum
	nNumLin := 7
	nPag    := 1
	nQtdIte := 0
	
	DbSelectArea("SM0")
	dbseek(cEmpant+cFilant)	
	cNomeEmp := SM0->M0_NOMECOM
	cEndeEmp := SM0->M0_ENDENT
	cNomeCid := SM0->M0_CIDENT
	cEstaEmp := "-" + SM0->M0_ESTENT
	cCep_Emp := "CEP: " + transform(SM0->M0_CEPENT,"@R 99.999-999")
	cFoneEmp := "FONE: " + SM0->M0_TEL
	cFax_Emp := "FAX: " + SM0->M0_FAX
	cCNPJEmp := "CNPJ: " + transform(left(SM0->M0_CGC,14),"@R 99.999.999/9999-99")
	cInscEmp := "IE: "+SM0->M0_INSC
//	cCodMun  := transform(SM0->M0_CODMUN,"@R 999.999/9")
	cCodMun  := "" //GetMv("MV_INSCMUN")	
	
	nValTot := nValDes := nBasICM := nValICM := 0
	
	cKeyAce := cNumOsv+cTipTem
	
	dbSelectArea("VEC")
	dbSetOrder(5)
	dbgotop()
	
	If dbSeek(xFilial("VEC")+cKeyAce)
		
		FS_CABEC()
		
	   if SM0->M0_CODIGO != "09"  
			while cKeyAce == VEC->VEC_NUMOSV+VEC->VEC_TIPTEM .and. !eof()
				
				if nQtdIte = 50
					nNumLin ++
					@ nNumLin,01 pSay "      "+"      "+"     "+"Segue na Proxima Pagina"
					eject
					nQtdIte := 0
					FS_CABEC()
				endif
	
				If !Empty(VEC->VEC_ALQICM)
					nBasICM += VEC->VEC_VALVDA
					nValICM += VEC->VEC_VALICM
				EndIf
				
				nValTot += VEC->VEC_VALBRU
				nValDes += VEC->VEC_VALDES
				
				FG_SEEK("SB1","VEC->VEC_GRUITE+VEC->VEC_CODITE",7,.f.)
				
				FS_VERPEC()
//aqui				
				nNumLin ++                //compactado                                                                                                             //78
				if SM0->M0_CODIGO = "20"
					@ nNumLin,01 pSay "      "+"      "+VEC->VEC_GRUITE+left(VEC->VEC_CODITE,18)+" "+SB1->B1_DESC+"         "+SB1->B1_ORIGEM+"   "+transform(VEC->VEC_QTDITE,"@ez 99999")+space(03)+transform(VEC->VEC_VALVDA/VEC->VEC_QTDITE,"@ez 9999,999,999.99")+space(7)+transform(VEC->VEC_VALVDA,"@ez 999,999,999.99")+"  "+transform(VEC->VEC_ALQICM,"@ez 99")
            else
					@ nNumLin,01 pSay "      "+"      "+"     "+VEC->VEC_GRUITE+left(VEC->VEC_CODITE,18)+" "+SB1->B1_DESC+"       "+SB1->B1_ORIGEM+"   "+transform(VEC->VEC_QTDITE,"@ez 99999")+space(03)+transform(VEC->VEC_VALVDA/VEC->VEC_QTDITE,"@ez 9999,999,999.99")+space(10)+transform(VEC->VEC_VALVDA,"@ez 999,999,999.99")+"  "+transform(VEC->VEC_ALQICM,"@ez 99.9")
				endif
				
				nQtdIte += 1
				
	        	dbSelectArea("VEC")
				dbSkip()
				
			EndDo

		else 

         
			aVetCai := {}
			while cKeyAce == VEC->VEC_NUMOSV+VEC->VEC_TIPTEM .and. !eof()
				DBSelectArea("SB1")
				DBSetOrder(7)
				DBSeek(xFilial("SB1")+VEC->VEC_GRUITE+VEC->VEC_CODITE)
				DBSelectArea("SB5")
				DBSetOrder(1)
				DBSeek(xFilial("SB5")+SB1->B1_COD)

				DBSelectArea("VE2")
				if DBSeek(xFilial("VE2")+"SC "+SB5->B5_CODCAI)				
					while VE2->VE2_FILIAL == xFilial("VE2") .AND. !(BOF()) .AND. VE2->VE2_ITETOT # "1"
						DBSkip(-1)
					enddo

					if VE2->VE2_ITETOT == "1" .and. VE2->VE2_FILIAL == xFilial("VE2")
						aAdd(aVetCai,{VEC->VEC_GRUITE,VEC->VEC_CODITE,VE2->VE2_CODCAI,VE2->VE2_DESCAI})
					else
						aAdd(aVetCai,{VEC->VEC_GRUITE,VEC->VEC_CODITE,SB5->B5_CODCAI,"N/A"})
					endif

				else
					aAdd(aVetCai,{VEC->VEC_GRUITE,VEC->VEC_CODITE,SB5->B5_CODCAI,"N/A"})
				endif

	        	dbSelectArea("VEC")
				dbSkip()

			EndDo

			asort(aVetCai,,,{|x,y| x[3]+x[1]+x[2] < y[3]+y[1]+y[2]})
			cCai := ""
			for nCai := 1 to Len(aVetCai)
				dbSeek(xFilial("VEC")+cKeyAce+aVetCai[nCai,1]+aVetCai[nCai,2])	
			
				if nQtdIte = 50
					nNumLin ++
					@ nNumLin,01 pSay "      "+"      "+"     "+"Segue na Proxima Pagina"
					eject
					nQtdIte := 0
					FS_CABEC()
				endif
	
				If !Empty(VEC->VEC_ALQICM)
					nBasICM += VEC->VEC_VALVDA
					nValICM += VEC->VEC_VALICM
				EndIf
				
				nValTot += VEC->VEC_VALBRU
				nValDes += VEC->VEC_VALDES
				
				FG_SEEK("SB1","VEC->VEC_GRUITE+VEC->VEC_CODITE",7,.f.)
				
				FS_VERPEC()
				
				nNumLin ++
				if nCai == 1 .or. cCai # aVetCai[nCai,3]
					cCai := aVetCai[nCai,3]
					@ nNumLin,01 pSay "      "+"      "+"     "+"** CAI :"+aVetCai[nCai,3]+" - " + Alltrim(aVetCai[nCai,4])
					nQtdIte += 1	
					nNumLin ++
					if nQtdIte = 50
						@ nNumLin,01 pSay "      "+"      "+"     "+"Segue na Proxima Pagina"
						eject
						nQtdIte := 0
						FS_CABEC()
						nNumLin ++
					endif
				endif  

		   //26/06/07 - QUANDO FOR SEGURADORA BRADESCO SEGUNDO O SR MAURICIO, O GRUPO DO ITEM
		   //DEVE SER IMPRESSO COM DUAS POSICOES E OS ITENS IMPRESSOS NA NF CONF CADASTRO DO SA1
            If SM0->M0_CODIGO = "09" .and. left(SA1->A1_CGC,8) $ "92682038"  //SEGURADORA BRADESCO
  				   @ nNumLin,01 pSay "      "+"      "+"     "+left(VEC->VEC_GRUITE,2)+"  "+left(VEC->VEC_CODITE,18)+" "+SB1->B1_DESC+"       "+SB1->B1_ORIGEM+"   "+transform(VEC->VEC_QTDITE,"@ez 99999")+space(03)+transform(VEC->VEC_VALVDA/VEC->VEC_QTDITE,"@ez 9999,999,999.99")+space(10)+transform(VEC->VEC_VALVDA,"@ez 999,999,999.99")+"  "+transform(VEC->VEC_ALQICM,"@ez 99.9")
				else
  				   @ nNumLin,01 pSay "      "+"      "+"     "+VEC->VEC_GRUITE+left(VEC->VEC_CODITE,18)+" "+SB1->B1_DESC+"       "+SB1->B1_ORIGEM+"   "+transform(VEC->VEC_QTDITE,"@ez 99999")+space(03)+transform(VEC->VEC_VALVDA/VEC->VEC_QTDITE,"@ez 9999,999,999.99")+space(10)+transform(VEC->VEC_VALVDA,"@ez 999,999,999.99")+"  "+transform(VEC->VEC_ALQICM,"@ez 99.9")
				endif

				nQtdIte += 1

			next

		endif
		
		if SM0->M0_CODIGO # "20"
			@ 61,28        pSay Transform(nBasICM,"@ez 999,999,999,999.99")
			@ 61,pcol()+01 pSay Transform(nValICM,"@ez 999,999,999,999.99")
			@ 61,pcol()+09 pSay Transform(nValTot - nValDes,"@ez 999,999,999,999.99")
			@ 61,pcol()+23 pSay Transform(nValTot - nValDes,"@ez 999,999,999,999.99")
        else
			@ 60,28        pSay Transform(nBasICM,"@ez 999,999,999.99")
			@ 60,pcol()+01 pSay Transform(nValICM,"@ez 999,999,999,999.99")
			@ 60,pcol()+09 pSay Transform(nValTot - nValDes,"@ez 999,999,999,999.99")
			@ 60,pcol()+23 pSay Transform(nValTot - nValDes,"@ez 999,999,999,999.99")

        endif
        
	endif
	
Else                       && Formulario Especifico
	
	nNumLin := 7
	nPag    := 1
	nQtdIte := 0
	
	DbSelectArea("SM0")
	dbseek(cEmpant+cFilant)	
	cNomeEmp := SM0->M0_NOMECOM
	cEndeEmp := SM0->M0_ENDENT
	cNomeCid := SM0->M0_CIDENT
	cEstaEmp := "-" + SM0->M0_ESTENT
	cCep_Emp := "CEP: " + transform(SM0->M0_CEPENT,"@R 99.999-999")
	cFoneEmp := "FONE: " + SM0->M0_TEL
	cFax_Emp := "FAX: " + SM0->M0_FAX
	cCNPJEmp := "CNPJ: " + transform(left(SM0->M0_CGC,14),"@R 99.999.999/9999-99")
	cInscEmp := "IE: "+SM0->M0_INSC
//	cCodMun  := transform(SM0->M0_CODMUN,"@R 999.999/9")
	cCodMun  := "" //GetMv("MV_INSCMUN")	
	
	nValTot := nValDes := nBasICM := nValICM := 0
	
	cKeyAce := cNumOsv+cTipTem
	
	dbSelectArea("VEC")
	dbSetOrder(5)
	dbgotop()
	
	If dbSeek(xFilial("VEC")+cKeyAce)
		
		FS_CABEC()
		
	   if SM0->M0_CODIGO != "09"  
			while cKeyAce == VEC->VEC_NUMOSV+VEC->VEC_TIPTEM .and. !eof()
				
				if nQtdIte = 50
					nNumLin ++
					@ nNumLin,01 pSay "      "+"      "+"     "+"Segue na Proxima Pagina"
					eject
					nQtdIte := 0
					FS_CABEC()
				endif
	
				If !Empty(VEC->VEC_ALQICM)
					nBasICM += VEC->VEC_VALVDA
					nValICM += VEC->VEC_VALICM
				EndIf
				
				nValTot += VEC->VEC_VALBRU
				nValDes += VEC->VEC_VALDES
				
				FG_SEEK("SB1","VEC->VEC_GRUITE+VEC->VEC_CODITE",7,.f.)
				
				FS_VERPEC()
//aqui				
				nNumLin ++                //compactado                                                                                                             //78
				if SM0->M0_CODIGO = "20"
					@ nNumLin,01 pSay "      "+"      "+VEC->VEC_GRUITE+left(VEC->VEC_CODITE,18)+" "+SB1->B1_DESC+"         "+SB1->B1_ORIGEM+"   "+transform(VEC->VEC_QTDITE,"@ez 99999")+space(03)+transform(VEC->VEC_VALVDA/VEC->VEC_QTDITE,"@ez 9999,999,999.99")+space(7)+transform(VEC->VEC_VALVDA,"@ez 999,999,999.99")+"  "+transform(VEC->VEC_ALQICM,"@ez 99")
            else
					@ nNumLin,01 pSay "      "+"      "+"     "+VEC->VEC_GRUITE+left(VEC->VEC_CODITE,18)+" "+SB1->B1_DESC+"       "+SB1->B1_ORIGEM+"   "+transform(VEC->VEC_QTDITE,"@ez 99999")+space(03)+transform(VEC->VEC_VALVDA/VEC->VEC_QTDITE,"@ez 9999,999,999.99")+space(10)+transform(VEC->VEC_VALVDA,"@ez 999,999,999.99")+"  "+transform(VEC->VEC_ALQICM,"@ez 99.9")
				endif
				
				nQtdIte += 1
				
	        	dbSelectArea("VEC")
				dbSkip()
				
			EndDo

		else 

         
			aVetCai := {}
			while cKeyAce == VEC->VEC_NUMOSV+VEC->VEC_TIPTEM .and. !eof()
				DBSelectArea("SB1")
				DBSetOrder(7)
				DBSeek(xFilial("SB1")+VEC->VEC_GRUITE+VEC->VEC_CODITE)
				DBSelectArea("SB5")
				DBSetOrder(1)
				DBSeek(xFilial("SB5")+SB1->B1_COD)

				DBSelectArea("VE2")
				if DBSeek(xFilial("VE2")+"SC "+SB5->B5_CODCAI)				
					while VE2->VE2_FILIAL == xFilial("VE2") .AND. !(BOF()) .AND. VE2->VE2_ITETOT # "1"
						DBSkip(-1)
					enddo

					if VE2->VE2_ITETOT == "1" .and. VE2->VE2_FILIAL == xFilial("VE2")
						aAdd(aVetCai,{VEC->VEC_GRUITE,VEC->VEC_CODITE,VE2->VE2_CODCAI,VE2->VE2_DESCAI})
					else
						aAdd(aVetCai,{VEC->VEC_GRUITE,VEC->VEC_CODITE,SB5->B5_CODCAI,"N/A"})
					endif

				else
					aAdd(aVetCai,{VEC->VEC_GRUITE,VEC->VEC_CODITE,SB5->B5_CODCAI,"N/A"})
				endif

	        	dbSelectArea("VEC")
				dbSkip()

			EndDo

			asort(aVetCai,,,{|x,y| x[3]+x[1]+x[2] < y[3]+y[1]+y[2]})
			cCai := ""
			for nCai := 1 to Len(aVetCai)
				dbSeek(xFilial("VEC")+cKeyAce+aVetCai[nCai,1]+aVetCai[nCai,2])	
			
				if nQtdIte = 50
					nNumLin ++
					@ nNumLin,01 pSay "      "+"      "+"     "+"Segue na Proxima Pagina"
					eject
					nQtdIte := 0
					FS_CABEC()
				endif
	
				If !Empty(VEC->VEC_ALQICM)
					nBasICM += VEC->VEC_VALVDA
					nValICM += VEC->VEC_VALICM
				EndIf
				
				nValTot += VEC->VEC_VALBRU
				nValDes += VEC->VEC_VALDES
				
				FG_SEEK("SB1","VEC->VEC_GRUITE+VEC->VEC_CODITE",7,.f.)
				
				FS_VERPEC()
				
				nNumLin ++
				if nCai == 1 .or. cCai # aVetCai[nCai,3]
					cCai := aVetCai[nCai,3]
					@ nNumLin,01 pSay "      "+"      "+"     "+"** CAI :"+aVetCai[nCai,3]+" - " + Alltrim(aVetCai[nCai,4])
					nQtdIte += 1	
					nNumLin ++
					if nQtdIte = 50
						@ nNumLin,01 pSay "      "+"      "+"     "+"Segue na Proxima Pagina"
						eject
						nQtdIte := 0
						FS_CABEC()
						nNumLin ++
					endif
				endif  

		   //26/06/07 - QUANDO FOR SEGURADORA BRADESCO SEGUNDO O SR MAURICIO, O GRUPO DO ITEM
		   //DEVE SER IMPRESSO COM DUAS POSICOES E OS ITENS IMPRESSOS NA NF CONF CADASTRO DO SA1
            If SM0->M0_CODIGO = "09" .and. left(SA1->A1_CGC,8) $ "92682038"  //SEGURADORA BRADESCO
  				   @ nNumLin,01 pSay "      "+"      "+"     "+left(VEC->VEC_GRUITE,2)+"  "+left(VEC->VEC_CODITE,18)+" "+SB1->B1_DESC+"       "+SB1->B1_ORIGEM+"   "+transform(VEC->VEC_QTDITE,"@ez 99999")+space(03)+transform(VEC->VEC_VALVDA/VEC->VEC_QTDITE,"@ez 9999,999,999.99")+space(10)+transform(VEC->VEC_VALVDA,"@ez 999,999,999.99")+"  "+transform(VEC->VEC_ALQICM,"@ez 99.9")
				else
  				   @ nNumLin,01 pSay "      "+"      "+"     "+VEC->VEC_GRUITE+left(VEC->VEC_CODITE,18)+" "+SB1->B1_DESC+"       "+SB1->B1_ORIGEM+"   "+transform(VEC->VEC_QTDITE,"@ez 99999")+space(03)+transform(VEC->VEC_VALVDA/VEC->VEC_QTDITE,"@ez 9999,999,999.99")+space(10)+transform(VEC->VEC_VALVDA,"@ez 999,999,999.99")+"  "+transform(VEC->VEC_ALQICM,"@ez 99.9")
				endif

				nQtdIte += 1

			next

		endif
		
		if SM0->M0_CODIGO # "20"
			@ 61,28        pSay Transform(nBasICM,"@ez 999,999,999,999.99")
			@ 61,pcol()+01 pSay Transform(nValICM,"@ez 999,999,999,999.99")
			@ 61,pcol()+09 pSay Transform(nValTot - nValDes,"@ez 999,999,999,999.99")
			@ 61,pcol()+23 pSay Transform(nValTot - nValDes,"@ez 999,999,999,999.99")
        else
			@ 60,28        pSay Transform(nBasICM,"@ez 999,999,999.99")
			@ 60,pcol()+01 pSay Transform(nValICM,"@ez 999,999,999,999.99")
			@ 60,pcol()+09 pSay Transform(nValTot - nValDes,"@ez 999,999,999,999.99")
			@ 60,pcol()+23 pSay Transform(nValTot - nValDes,"@ez 999,999,999,999.99")

        endif
        
	endif
	
EndIf

eject
	
Set Printer to
Set Printer off
Set Device  to Screen
	
MS_Flush()

if lForimp = "S"
  	Copy File &(__RELDIR+cNomRel+".##R") to &(cNomeImp)
endif

return

Static Function FS_CABEC()
***************************

FG_SEEK("SF2","VEC->VEC_NUMNFI+VEC->VEC_SERNFI",1,.f.)
FG_SEEK("SE4","SF2->F2_COND",1,.f.)
FG_SEEK("SA1","SF2->F2_CLIENTE",1,.f.)

SETPRC(0,0)
cNormal := "CHR(18)"
cCompac := "CHR(15)"
cExpand := "CHR(27)+'W'+CHR(1)"

if SM0->M0_CODIGO = "20"                                       
	@ 00,01 pSay space(70)+"." // Renata e Alvaro em 09/02/06
//	@ 01,01 pSay space(70)+"." // Silvania e Alvaro em 02/02/06
endif	

@ 01,01         psay &cNormal+chr(14) //EXPANDIDO
@ 01,32         pSay strzero(val(VEC->VEC_NUMREL),8)
@ 02,01         pSay &cNormal + chr(20) + &cCompac  //COMPACTADO

if SM0->M0_CODIGO $ "04/09"
	@ 02,01         psay "*************"
endif

if SM0->M0_CODIGO # "20"
	@ 03,01         pSay cEndeEmp+" "+cNomeCid+" "+cEstaEmp+" "+cCep_Emp
	@ 04,01         pSay cCNPJEmp+" "+cInscEmp+cFoneEmp+cFax_Emp + &cNormal + SPACE(17)+dtoc(VEC->VEC_DATVEN)
Else
	@ 04,07         pSay cCNPJEmp+" "+cInscEmp + &cNormal //+space(30)+dtoc(VEC->VEC_DATVEN)
	@ 04,86  pSay dtoc(VEC->VEC_DATVEN)	
Endif

//@ 04,72  pSay dtoc(VEC->VEC_DATVEN)  //86

@ 06,01         pSay &cNormal+chr(14) //Expandido

if SM0->M0_CODIGO # "20"
	@ 06,05         pSay VEC->VEC_NUMOSV
else
	@ 06,04         pSay VEC->VEC_NUMOSV
endif

@ 06,18         pSay VEC->VEC_NUMNFI + &cNormal + chr(20) //normal
@ 06,35         pSay left(SE4->E4_DESCRI,30)
@ 07,01         pSay &cCompac //compactado

nNumLin := 07

return

Static Function FS_VERPEC()
***************************

Local cSelect := Alias()

FG_SEEK("VO2","VEC->VEC_NUMOSV")
dbSelectArea("VO2")

While VEC->VEC_NUMOSV == VO2->VO2_NUMOSV .and. !eof()
	
	If VO2->VO2_TIPREQ == "S"
		dbSkip()
		loop
	EndIf
	
	FG_SEEK("VO3","VO2->VO2_NOSNUM+VEC->VEC_TIPTEM")
	dbSelectArea("VO3")
	
	While VO2->VO2_NOSNUM+VEC->VEC_TIPTEM == VO3->VO3_NOSNUM+VO3->VO3_TIPTEM .and. !eof()
		
		If VO3->VO3_CODITE == VEC->VEC_CODITE
			Exit
		EndIf
		dbSkip()
		
	EndDo
	
	dbSelectArea("VO2")
	dbSkip()
	
EndDo

dbSelectArea(cSelect)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LeDriver ³ Autor ³ Tecnologia            ³ Data ³ 17/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Emissao da Nota Fiscal de Balcao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LEDriver()
**************************
Local aSettings := {}
Local cStr, cLine, i

if !File(__DRIVER)
	aSettings := {"CHR(15)","CHR(18)","CHR(15)","CHR(18)","CHR(15)","CHR(15)"}
Else
	cStr := MemoRead(__DRIVER)
	For i:= 2 to 7
		cLine := AllTrim(MemoLine(cStr,254,i))
		AADD(aSettings,SubStr(cLine,7))
	Next
Endif
Return aSettings


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

Static Function FG_Seek(cAlias,Chv_,Ord_,Sss_,cCpoDest,cCpoOrig)

LOCAL Atu_:=SELECT(),Ind_, Sem_dbf:=ALIAS(), Achou_
Local i := 0 
Ord_:=IF(Ord_=NIL,1,Ord_)
Sss_:=IF(Sss_=NIL,.f.,Sss_)
cCom:=IF(cCpoOrig=NIL," ",cAlias+"->"+cCpoOrig)

Select(cAlias)
Ind_:=IndexOrd()
DbSetOrder(Ord_)
Set SoftSeek (Sss_)

if Type("aCols") == "A"    && Modelo 3
	
	cChave := ""
	
	if type(readvar()) == "U"
		cUlCpo := ""
	Else
		cUlCpo := &(readvar())
	Endif
	
	//k > 0 .and. ( Subs(chv_,k-1,1) == "+" .or. Subs(chv_,k-1,1) == "" .or. !SX2->(dbSeek(Subs(chv_,k-2,3))) )
	
	k := at("M->",chv_)
	if k > 0 .and. ( Subs(chv_,k-1,1) == "+" .or. (k-1 == 0) .or. !SX2->(dbSeek(Subs(chv_,k-2,3))) )
		bCampo := {|x| aHeader[x,2]}
		w1 := READVAR()
		For i=1 to Len(aHeader)
			wVar := "M->"+(EVAL(bCampo,i))
			If wVar != w1
				Private &wVar := aCols[n,i]
			Endif
		Next
	Endif
	
	While .t.
		
		k := at("+",chv_)
		if k > 0
			cCPO := substr(chv_,1,k-1)
			chv_ := substr(chv_,k+1)
			if at("->",cCpo) == 0 .and. type(cCpo) == "U"
				cChave := cChave + FieldGet(FieldPos(cCPO))
			else
				cChave := cChave + &cCpo
			endif
		Else
			if !Chv_ == readvar()
				cUlCpo := &Chv_
			endif
			Exit
		Endif
		
	Enddo
	
	cChv_ := cChave+cUlCpo
	
Else
	
	cChv_ := (&Chv_)
	
Endif

DbGotop()
DbSeek(xFilial(cAlias)+cChv_)
Achou_:=FOUND()

DbSetOrder(ind_)
IF Empty(sem_dbf)
	Sele 0
ELSE
	Sele (Atu_)
ENDI

Set SoftSeek (.f.)

if cCom != " "
	M->&cCpoDest := &cCom
endif

RETU Achou_

