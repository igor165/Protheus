#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOSSEMNF   บ Autor ณ Klaus S. Peres     บ Data ณ  03/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Programa de Impressao das NFดs que estใo no Loja mas       บฑฑ
ฑฑบ          ณ nao foram gravadas nos arqs do Gestao de Concessionarias   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Curinga Caminhoes do DF Ltda.                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function OSSEMNF()

local aCampos,cArqTmp,nTot
local cAlias := "SL1"

//Variaveis padrao de relatorio
Private cCabec1		:= ""
Private cCabec2		:= ""
Private cDesc1			:= "Impressao das NFs que nao foram gravadas no Gestao de Concessionarias"
Private cQuery			:= ""
Private cDesc2			:= ""
Private cDesc3			:= ""
Private aReturn		:= { "", 1,"", 2, 2, 1, "",1 } 	//"Zebrado"###"Administracao"
Private cTamanho		:= "M"           					// P/M/G
Private Limite			:= 80         						// 80/132/220
Private cTitulo		:= "Impressao das NFs que nao foram gravadas no Gestao de Concessionarias"
Private cNomProg		:= "OSSEMNF"
Private cNomeRel		:= "OSSEMNF"
Private nLastKey		:= 0
Private nCaracter		:= 15
Private aVetCampos	:= {}

set printer to &cNomeRel
set printer on
set device to printer

cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)

if nlastkey == 27
	return
Endif

SetDefault(aReturn,cAlias)

RptStatus({|lEnd| OSSEMNF2(@lEnd,cNomeRel,cAlias)},cTitulo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Desc.    ณ Monta o Relatorio para Impressao                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function OSSEMNF2(lEnd,wNRel,cAlias)
lCorrigiu := .F.
cProdede  := ""
M_PAG		:= 1
aPag		:= 1
clin		:= 1
nf			:= ""
serie		:= ""
emissao	:= ""
nCont		:= 0
nLin		:= Cabec(cTitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter) + 1

cQuery := "select * from " + retsqlname("SL1") +" "+;
		    "where D_E_L_E_T_<>'*' AND L1_VEIPESQ <> '          ' "
TCQUERY cQuery new alias "XL1"


SetRegua(XL1->(RecCount()))

XL1->(dbgotop())

do while !XL1->(Eof())
	cProcede := ""
	If nLin >= 65
		nLin 	:= Cabec(cTitulo,cCabec1,cCabec2,cNomProg, cTamanho,nCaracter) + 1
	Endif

	nf			:= XL1->L1_DOC
	serie		:= XL1->L1_SERIE
	emissao	:= XL1->L1_EMISNF
           

	If XL1->L1_VEICTIP == "1" 
	
		//Atualiza Orcamento
		dbSelectArea("VS1")
		dbSetOrder(1)
		If dbSeek(xFilial("VS1")+Trim(XL1->L1_VEIPESQ))
			If Empty(VS1->VS1_NUMNFI)
				RecLock("VS1",.F.)
				VS1->VS1_NUMNFI := XL1->L1_DOC
				VS1->VS1_SERNFI := XL1->L1_SERIE
				MsUnlock()
				lCorrigiu :=  .T.
				cProcede += IIF(Empty(cProcede),"VS1", ", VS1"  )
			EndIf	
		EndIf
		
		//Atualiza Mapa de Avaliacao
		dbSelectArea("VEC")
		dbSetOrder(1)
		If dbSeek(xFilial("VEC")+Trim(XL1->L1_VEIPESQ))
			While !Eof() .and. VEC_FILIAL == xFilial("VEC") .and. VEC_NUMORC == Trim(XL1->L1_VEIPESQ)
				If Empty(VEC->VEC_NUMNFI)
					RecLock("VEC",.f.)
					VEC->VEC_NUMNFI := XL1->L1_DOC
					VEC->VEC_SERNFI := XL1->L1_SERIE
					VEC->VEC_DATVEN := dDataBase
					IF VEC->VEC_DATVEN<>stod(XL1->L1_EMISNF)
	            	VEC->VEC_DATVEN := stod(XL1->L1_EMISNF)
	         	Endif 				
					MsUnlock()                                   
					cProcede += IIF(Empty(cProcede),"VEC", ", VEC"  )
					lCorrigiu :=  .T.
				Endif	
				dbSkip()
			EndDo
		EndIf
	
	ElseIf XL1->L1_VEICTIP == "2" 
	
		dbSelectArea("VFE")
		dbSetOrder(1)
		dbSeek(xFilial("VFE")+XL1->L1_NUM)
		While !Eof() .and. VFE->VFE_NUMORC == XL1->L1_NUM
		//Atualiza numero das notas
			dbSelectArea("VOO")
			dbSetOrder(1)
			if dbSeek(xFilial("VOO")+VFE->VFE_NUMOSV+VFE->VFE_TIPTEM)
				if Empty(VOO->VOO_NUMNFI)
					RecLock("VOO",.f.)
					VOO->VOO_NUMNFI := XL1->L1_DOC
			      VOO->VOO_SERNFI := XL1->L1_SERIE
			      MsUnlock()                         
			      cProcede += IIF(Empty(cProcede),"VOO", ", VOO"  )
			      lCorrigiu :=  .T.
				Endif	
		    Endif
			//Atualiza Avaliacao de Pecas
			dbSelectArea("VEC")
			dbSetOrder(5)
			dbSeek(xFilial("VEC")+VFE->VFE_NUMOSV+VFE->VFE_TIPTEM)
			While !Eof() .and. VEC->VEC_FILIAL+VEC->VEC_NUMOSV+VEC->VEC_TIPTEM == xFilial("VEC")+VFE->VFE_NUMOSV+VFE->VFE_TIPTEM
		   	if Empty(VEC->VEC_NUMNFI)
					RecLock("VEC",.f.)
					VEC->VEC_NUMNFI := XL1->L1_DOC
					VEC->VEC_SERNFI := XL1->L1_SERIE
	   			VEC->VEC_DATVEN := dDataBase
	   			IF VEC->VEC_DATVEN<>stod(XL1->L1_EMISNF)
		          	VEC->VEC_DATVEN := stod(XL1->L1_EMISNF)
	   	     	Endif 				
					MsUnlock()                         
					cProcede += IIF(Empty(cProcede),"VEC", ", VEC"  )
					lCorrigiu :=  .T.
			   Endif	
				VEC->(dbSkip())
			EndDo	
			
				//Atualiza Avaliacao de Servicos
				dbSelectArea("VSC")
				dbSetOrder(1)
			    dbSeek(xFilial("VSC")+VFE->VFE_NUMOSV+VFE->VFE_TIPTEM)
				While !Eof() .and. VSC->VSC_FILIAL+VSC->VSC_NUMOSV+VSC->VSC_TIPTEM == xFilial("VSC")+VFE->VFE_NUMOSV+VFE->VFE_TIPTEM
		         if Empty(VSC->VSC_NUMNFI)
						RecLock("VSC",.f.)
						VSC->VSC_NUMNFI := XL1->L1_DOC
			      	VSC->VSC_SERNFI := XL1->L1_SERIE
	   				VSC->VSC_DATVEN := dDataBase
	   				IF VSC->VSC_DATVEN<>stod(XL1->L1_EMISNF)
		   	         VSC->VSC_DATVEN := stod(XL1->L1_EMISNF)
	      	      Endif 
						MsUnlock()                                    
						cProcede += IIF(Empty(cProcede),"VSC", ", VSC"  )
						lCorrigiu :=  .T.
				  Endif	
					VSC->(dbSkip())
				EndDo	
			
				//Atualiza Requisicao de Pecas
				dbSelectArea("VO2")
				dbSetOrder(1)
				dbSeek(xFilial("VO2")+VFE->VFE_NUMOSV)
				
				dbSelectArea("VO3")
				dbSetOrder(1)
				dbSeek(xFilial("VO3")+VO2->VO2_NOSNUM+VFE->VFE_TIPTEM)
				While !Eof() .and. VO3->VO3_FILIAL+VO3->VO3_NOSNUM+VO3->VO3_TIPTEM == xFilial("VO3")+VO2->VO2_NOSNUM+VFE->VFE_TIPTEM
		         if Empty(VO3->VO3_NUMNFI)
						RecLock("VO3",.f.)
						VO3->VO3_NUMNFI := XL1->L1_DOC
				     	VO3->VO3_SERNFI := XL1->L1_SERIE
						MsUnlock()                         
						cProcede += IIF(Empty(cProcede),"VO3", ", VO3"  )
						lCorrigiu :=  .T.
					Endif
					VO3->(dbSkip())
				EndDo	
				
				//Atualiza Requisicao de Servicos
				dbSelectArea("VO4")
				dbSetOrder(1)
				dbSeek(xFilial("VO4")+VO2->VO2_NOSNUM+VFE->VFE_TIPTEM)
				While !Eof() .and. VO4->VO4_FILIAL+VO4->VO4_NOSNUM+VO4->VO4_TIPTEM == xFilial("VO4")+VO2->VO2_NOSNUM+VFE->VFE_TIPTEM
		         if Empty(VO4->VO4_NUMNFI)
						RecLock("VO4",.f.)
						VO4->VO4_NUMNFI := XL1->L1_DOC
		   	   	VO4->VO4_SERNFI := XL1->L1_SERIE
						MsUnlock()                          
						cProcede += IIF(Empty(cProcede),"VO4", ", VO4"  )
						lCorrigiu :=  .T.
					Endif	
					VO4->(dbSkip())
				EndDo	
			
	   	dbSelectArea("VFE")
	   	dbSkip()
	   EndDo
	
	ElseIf XL1->L1_VEICTIP == "3"
	
		//Atualiza Proposta
		dbSelectArea("VV0")
		dbSetOrder(1)
		If dbSeek(xFilial("VV0")+Trim(XL1->L1_VEIPESQ))
			If Empty(VV0->VV0_NUMNFI)
				RecLock("VV0",.F.)
				VV0->VV0_NUMNFI := XL1->L1_DOC
				VV0->VV0_SERNFI := XL1->L1_SERIE
				VV0->VV0_DATMOV := dDataBase
				VV0->VV0_DATEMI := dDataBase                 
				IF VV0->VV0_DATMOV<>stod(XL1->L1_EMISNF)
	         	VV0->VV0_DATMOV := stod(XL1->L1_EMISNF)
		      Endif 
				MsUnlock()                                
				cProcede += IIF(Empty(cProcede),"VV0", ", VV0"  )
				lCorrigiu :=  .T.
			Endif	
	   EndIf
	EndIf             
	If lcorrigiu
		@ nLin, 002 pSay nf + space(5) + serie + space(5) + emissao + space(1)+ cProcede
		nLin++
		nCont++      	
	Endif             
	
	XL1->(DBSKIP()) 
	IncRegua()
	lCorrigiu := .F.
EndDo

@ nLin, 002 pSay "Total de NFS..: " + str(nCont)
XL1->(dbclosearea())

Set Printer to
Set device to Screen

If aReturn[5] == 1
	OurSpool(cNomeRel)
EndIf

MS_FLUSH()

Return